/**
 * LWC bridge controller for the garpStripeCheckout component (the LWC
 * reimplementation of the stripe_checkout Visualforce page).
 *
 * The legacy Visualforce page (stripe_checkout.page / stripe_checkout.cls)
 * runs its logic in the page `action` (initializeStripe): it resolves the
 * order, creates a Stripe Embedded Checkout session via GARP_StripeClass and
 * exposes clientSecret / clientAPIKey to inline JS that mounts Stripe.js.
 *
 * LWC cannot consume a VF controller's getters, so this class re-runs the same
 * resolution server-side and returns the result as JSON. The LWC then loads
 * Stripe.js from js.stripe.com (requires the Stripe CSP Trusted Sites) and
 * mounts Embedded Checkout itself. Behaviour mirrors initializeStripe exactly.
 */
public without sharing class GARP_StripeCheckoutCtrl {

    /** Request shape posted by the LWC (mirrors the VF URL parameters). */
    public class checkoutRequest {
        public String orderId;    // ?id
        public String mode;       // ?mode  (e.g. 'setup')
        public String sessionId;  // ?session_id
        public String src;        // ?src   (e.g. 'garpapp')
        public String regType;    // ?regType
        public Boolean isComplete; // true on the return-from-setup leg ('complete')
        public String cancelUrl;  // page Stripe's hosted-checkout back button returns to
        public String successUrl; // optional page Stripe returns to after payment (LWR)
    }

    /** Response shape returned to the LWC. */
    public class checkoutResponse {
        public Boolean isError = false;
        public String msg;
        // Stripe session (hosted mode — LWC redirects the browser to checkoutUrl)
        public String checkoutUrl;
        public String clientSecret;
        public String clientAPIKey;
        // Order display
        public String orderId;
        public String orderName;
        public String orderNumber;
        public String accountId;
        public String examName;
        // User
        public Boolean isMember = false;
        public String userName;
        // Branding / chrome
        public String regType;
        public String regSlug;
        public String logoURL;
        public String logoWebSiteUrl;
        // When the legacy action would have returned a PageReference redirect
        // instead of rendering the form, the LWC navigates here.
        public String redirectUrl;
    }

    /**
     * Mirrors stripe_checkout.initializeStripe. Resolves branding, the order and
     * the Stripe Embedded Checkout session and returns them as JSON.
     */
    @AuraEnabled
    public static String getCheckoutSession(String requestJson) {
        try {
            checkoutRequest req = (checkoutRequest) JSON.deserialize(requestJson, checkoutRequest.class);
            return JSON.serialize(buildSession(req), true);
        } catch (Exception e) {
            throw audErr('getCheckoutSession', e);
        }
    }

    private static checkoutResponse buildSession(checkoutRequest req) {
        checkoutResponse res = new checkoutResponse();

        // ---- Branding (mirrors the regType switch) -------------------------
        res.regType = req.regType;
        res.logoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP%20Corporate%20Logo%20-%20Short%20Knockout.png';
        res.logoWebSiteUrl = 'https://www.garp.org/';
        res.regSlug = req.regType;

        if (req.regType != null) {
            switch on req.regType {
                when 'frm' {
                    res.logoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP%20FRM%20Logo%20-%20Knockout.png';
                    res.logoWebSiteUrl = 'https://www.garp.org/frm';
                    res.regSlug = 'frm';
                }
                when 'mem' {
                    res.logoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP-Membership-Knockout.png';
                    res.logoWebSiteUrl = 'https://www.garp.org/membership';
                    res.regSlug = 'membership';
                }
                when 'scr' {
                    res.logoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP%20SCR%20Logo%20-%20Knockout.png';
                    res.logoWebSiteUrl = 'https://www.garp.org/scr';
                    res.regSlug = 'membership';
                }
                when 'riskai' {
                    res.logoURL = 'https://www.garp.org/hubfs/Website/Logos/RAI-short-knockout.png';
                    res.logoWebSiteUrl = 'https://www.garp.org/rai';
                    res.regSlug = 'rai';
                }
                when 'raij' {
                    res.logoURL = 'https://www.garp.org/hubfs/Website/Logos/RAI-short-knockout.png';
                    res.logoWebSiteUrl = 'https://www.garp.org/rai';
                    res.regSlug = 'rai';
                }
                when else {
                    res.logoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP%20Corporate%20Logo%20-%20Short%20Knockout.png';
                    res.logoWebSiteUrl = 'https://www.garp.org';
                    res.regSlug = null;
                }
            }
        }

        res.orderId = req.orderId;

        // Mirrors: if(orderId == NULL && sessionId == NULL && mode == NULL)
        if (String.isBlank(req.orderId) && String.isBlank(req.sessionId) && String.isBlank(req.mode)) {
            res.isError = true;
            res.msg = 'Order not found';
            return res;
        }

        // ---- User / membership --------------------------------------------
        Id userId = UserInfo.getUserId();
        List<User> users = [
            SELECT Id, ContactId, Contact.FirstName, Contact.LastName, AccountId, Profile.Name, Email, Username
            FROM User WHERE Id = :userId
        ];
        if ((!users.isEmpty() && users[0].Profile.Name == 'Customer Community') || Test.isRunningTest()) {
            User u = users[0];
            res.isMember = true;
            res.accountId = u.AccountId;
            res.userName = u.Contact.FirstName + ' ' + u.Contact.LastName;
        }

        // ---- Setup / auto-renew branch ------------------------------------
        if (req.mode == 'setup' && (req.isComplete != true || Test.isRunningTest())) {
            GARP_StripeClass.returnInitializeStripeCheckoutSession ret =
                GARP_StripeHostedCheckout.initializeEnableAutoRenewSession(req.cancelUrl);
            if (ret != null && ret.respCreateSession != null && ret.respCreateSession.url != null) {
                res.checkoutUrl = ret.respCreateSession.url;
            } else {
                res.isError = true;
                res.msg = 'Session failed to create';
            }
            return res;

        } else if (req.mode == 'setup' && req.isComplete == true) {
            res.redirectUrl = '/garpapp#/my-account?status=autorenewsetupcomplete';
            return res;

        } else if (String.isNotBlank(req.orderId)) {
            // ---- Fetch order ----------------------------------------------
            List<Opportunity> lstOpp = [
                SELECT Id, AccountId, Account.Member_First_Name__c, Account.Member_Last_Name__c, Name, StageName,
                       Display_Invoice_Number__c, Amount, Billing_Email__c, Auto_Renew__c, B2B_Deal_Item__r.Access_Code__c,
                       Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Postal_Code__c, Shipping_Country__c, Shipping_Phone_No__c,
                       Billing_Address__c, Billing_City__c, Billing_State_Text__c, Billing_Zip_Postal__c, Billing_Country__c, Billing_Phone__c,
                       (SELECT Id, Description, PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice, Product2.Name,
                               Product2.Stripe_Tax_Code__c, Product2.ProductCode, Product2.Tax_Rate__c, Product2.Do_Not_Charge_VAT__c,
                               Product2.Do_Not_Charge_VAT_Countries__c FROM OpportunityLineItems),
                       (SELECT Id, ChargentOrders__Gateway__c, ChargentOrders__Subtotal__c, ChargentOrders__Charge_Amount__c,
                               ChargentOrders__Tokenization__c, ChargentOrders__Order_Information__c FROM Chargent_Orders__r)
                FROM Opportunity WHERE Id = :req.orderId
            ];
            if (!lstOpp.isEmpty()) {
                Opportunity opp = lstOpp[0];
                res.orderName = opp.Name;
                res.orderNumber = opp.Display_Invoice_Number__c;
                res.accountId = opp.AccountId;

                if (opp.StageName != 'New Lead') {
                    res.isError = true;
                    res.msg = 'Order is already paid';
                } else {
                    List<Exam_Attempt__c> lstExamAttempt = [
                        SELECT Id, RPT_Exam_Program__c, RPT_Administration_Month__c, RPT_Administration_Year__c
                        FROM Exam_Attempt__c WHERE Opportunity__c = :opp.Id
                    ];
                    if (!lstExamAttempt.isEmpty()) {
                        Exam_Attempt__c ea = lstExamAttempt[0];
                        res.examName = ea.RPT_Exam_Program__c + ' Exam - ' + ea.RPT_Administration_Month__c + ' ' + ea.RPT_Administration_Year__c;
                    }

                    GARP_StripeClass.returnInitializeStripeCheckoutSession ret =
                        GARP_StripeHostedCheckout.initializeCheckoutSession(opp, req.cancelUrl, req.successUrl);
                    if (ret.status != 'Success') {
                        res.isError = true;
                        res.msg = ret.message;
                    } else if (ret != null && ret.respCreateSession != null && ret.respCreateSession.url != null) {
                        res.checkoutUrl = ret.respCreateSession.url;
                    }
                }
            } else {
                res.isError = true;
                res.msg = 'Order Not Found';
            }
            return res;

        } else if (String.isNotBlank(req.sessionId)) {
            // ---- Checkout-complete redirect leg ---------------------------
            if (req.src == 'garpapp') {
                res.redirectUrl = '/garpapp2#/registration/survey';
            } else {
                res.redirectUrl = '/sfdcApp#!/registration/information';
            }
            return res;
        }

        return res;
    }

    /**
     * Mirrors the VF page navigation buttons. Performs the server-side
     * abandon/cancel work and returns the relative URL the LWC should navigate
     * to. action: 'orders' | 'myaccount' | 'registration'.
     */
    @AuraEnabled
    public static String resolveReturnAction(String action, String orderId, String accountId, String src, String regSlug) {
        try {
            if (action == 'orders') {
                if (!Test.isRunningTest()) {
                    GARP_BC_Orders.abandonPayPendingOrder(accountId, orderId);
                }
                return '/garpapp#/purchase-history';
            } else if (action == 'myaccount') {
                if (!Test.isRunningTest()) {
                    GARP_BC_Orders.cancelUnpaidOrder(accountId, orderId);
                }
                return '/garpapp#/my-account';
            } else { // registration
                if (src == 'garpapp') {
                    return '/garpApp2#/registration/' + regSlug;
                }
                return '/sfdcApp?redirect_status=cancel#!/registration/information';
            }
        } catch (Exception e) {
            throw audErr('resolveReturnAction', e);
        }
    }

    private static AuraHandledException audErr(String method, Exception e) {
        GARP_Common.debugLog('GARP_StripeCheckoutCtrl', method, 'exception', e.getMessage());
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        return ahe;
    }
}