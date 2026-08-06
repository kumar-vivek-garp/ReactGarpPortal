/**
 * Builds Stripe Checkout sessions in HOSTED mode (ui_mode=hosted) for the
 * garpStripeCheckout LWC.
 *
 * Why this exists separately from GARP_StripeClass:
 *   The garpStripeCheckout LWC runs under Lightning Web Security (LWS). LWS wraps
 *   objects crossing the realm boundary in non-cloneable proxies, which breaks
 *   Stripe Embedded Checkout's internal postMessage to its iframe
 *   (DataCloneError -> "Timed out waiting for client secret"). Hosted checkout
 *   sidesteps this entirely: the browser is redirected to checkout.stripe.com,
 *   so there is no in-page iframe and no postMessage.
 *
 *   GARP_StripeClass (and the legacy stripe_checkout Visualforce page that uses
 *   it) must stay on Embedded Checkout and is intentionally NOT modified. This
 *   class re-implements the session payload in hosted mode while reusing
 *   GARP_StripeClass's read-only helpers (getStripeSettings, getStripeCustomer)
 *   and its public return types so behaviour stays in lock-step with the
 *   embedded build.
 *
 * Hosted vs embedded payload differences:
 *   - success_url   instead of return_url
 *   - cancel_url    added (the URL Stripe's back button returns to)
 *   - ui_mode=hosted instead of ui_mode=embedded
 *   The Stripe response carries `url` (the hosted page) instead of client_secret.
 */
public without sharing class GARP_StripeHostedCheckout {

    /**
     * Hosted equivalent of GARP_StripeClass.initializeCheckoutSession(opp).
     * Resolves the Stripe customer then creates a hosted Checkout session for the
     * order. On success ret.respCreateSession.url holds the redirect target.
     */
    // Backward-compatible overload (default success_url = stripe_checkout_complete).
    public static GARP_StripeClass.returnInitializeStripeCheckoutSession initializeCheckoutSession(Opportunity opp, String cancelUrl) {
        return initializeCheckoutSession(opp, cancelUrl, null);
    }

    /**
     * @param successUrl  Optional. When provided, Stripe redirects here after a
     *   successful payment instead of the stripe_checkout_complete VF page. Needed
     *   for LWR sites, where VF pages aren't served on the community path (the
     *   default URL 404s). Order finalization happens via GARP_Stripe_Webhook, so
     *   this URL is UX-only.
     */
    public static GARP_StripeClass.returnInitializeStripeCheckoutSession initializeCheckoutSession(Opportunity opp, String cancelUrl, String successUrl) {
        GARP_Common.debugLog('GARP_StripeHostedCheckout','initializeCheckoutSession','opp',opp);

        GARP_StripeClass.returnInitializeStripeCheckoutSession ret = new GARP_StripeClass.returnInitializeStripeCheckoutSession();

        if(opp == NULL) {
            ret.status = 'Failure';
            ret.message = 'Required params missing';
            return ret;
        }

        String orderName = opp.Name;
        String orderNumber = opp.Display_Invoice_Number__c;
        String userName = opp.Account.Member_First_Name__c + ' ' + opp.Account.Member_Last_Name__c;
        Decimal amount = opp.Amount;
        String email = opp.Billing_Email__c;
        Boolean isMembershipAutoRenew = opp.Auto_Renew__c;

        GARP_Common.address shippingAddress = GARP_Common.parseMultiAddressLine(opp.Shipping_Street__c);
        shippingAddress.city = opp.Shipping_City__c;
        shippingAddress.postalCode = opp.Shipping_Postal_Code__c;
        shippingAddress.phone = opp.Shipping_Phone_No__c;
        shippingAddress.country = opp.Shipping_Country__c;
        shippingAddress.province = opp.Shipping_State__c;

        GARP_Common.address billingAddress = GARP_Common.parseMultiAddressLine(opp.Billing_Address__c);
        billingAddress.city = opp.Billing_City__c;
        billingAddress.postalCode = opp.Billing_Zip_Postal__c;
        billingAddress.phone = opp.Billing_Phone__c;
        billingAddress.country = opp.Billing_Country__c;
        billingAddress.province = opp.Billing_State_Text__c;

        String garpId;
        String name;
        String stripeCustomerId;

        Id userId = UserInfo.getUserId();
        List<User> users = [SELECT Id, Email, ContactId, Contact.Email, Contact.FirstName, Contact.LastName, Contact.GARP_Member_ID__c, Contact.Stripe_Customer_ID__c, AccountId, Profile.Name FROM User WHERE Id = :userId];

        if(!users.isEmpty() && users[0].Profile.Name == 'Customer Community') {
            User u = users[0];
            if(u.Contact.GARP_Member_ID__c != NULL) {
                garpId = u.Contact.GARP_Member_ID__c;
            }
            if(u.Contact.Stripe_Customer_ID__c != NULL) {
                stripeCustomerId = u.Contact.Stripe_Customer_ID__c;
            }
            name = u.Contact.FirstName + ' ' + u.Contact.LastName;
        } else {
            name = userName;
        }

        GARP_StripeClass.returnGetStripeCustomer retGetStripeCustomer =
            GARP_StripeClass.getStripeCustomer(stripeCustomerId, name, garpId, email, billingAddress, shippingAddress);

        if(retGetStripeCustomer.status != 'Success') {
            ret.status = 'Failure';
            ret.message = retGetStripeCustomer.message;
            return ret;
        }

        return createHostedCheckoutSession(orderNumber, orderName, amount, email, retGetStripeCustomer.stripeCustomerId, garpId, isMembershipAutoRenew, opp, cancelUrl, successUrl);
    }

    /**
     * Hosted equivalent of GARP_StripeClass.initializeEnableAutoRenewSession().
     * Creates a hosted setup-mode session so a logged-in member can enable
     * auto-renew (save a payment method off-session).
     */
    public static GARP_StripeClass.returnInitializeStripeCheckoutSession initializeEnableAutoRenewSession(String cancelUrl) {
        GARP_StripeClass.returnInitializeStripeCheckoutSession ret = new GARP_StripeClass.returnInitializeStripeCheckoutSession();

        Id userId = UserInfo.getUserId();
        List<User> users = [SELECT Id, ContactId, Contact.Email, Contact.FirstName, Contact.GARP_Member_ID__c, Contact.Stripe_Customer_ID__c, AccountId, Profile.Name
                            FROM User WHERE Id = :userId];

        if(users.isEmpty() || users[0].Profile.Name != 'Customer Community') {
            ret.status = 'Failure';
            ret.message = 'Must be a logged in user';
            return ret;
        }

        User u = users[0];
        if(u.Contact.Stripe_Customer_ID__c == NULL) {
            ret.status = 'Contact Stripe_Customer_ID__c required';
            ret.message = 'Must be a logged in user';
            return ret;
        }

        return createHostedAutoRenewSession(u.Contact.Stripe_Customer_ID__c, u.Contact.GARP_Member_ID__c, cancelUrl);
    }

    // ---- Stripe API calls --------------------------------------------------

    /** Mirrors GARP_StripeClass.initializeStripeCheckoutSession in hosted mode. */
    private static GARP_StripeClass.returnInitializeStripeCheckoutSession createHostedCheckoutSession(String orderNumber, String orderName, Decimal amount, String email, String customerId, String garpId, Boolean isMembershipAutoRenew, Opportunity opp, String cancelUrl, String successUrl) {
        GARP_StripeClass.returnInitializeStripeCheckoutSession ret = new GARP_StripeClass.returnInitializeStripeCheckoutSession();

        GARP_StripeSettings__c stripeSetting = GARP_StripeClass.getStripeSettings();
        ret.clientAPIKey = stripeSetting.Client_Side_API_Key__c;

        HttpRequest request = buildSessionRequest(stripeSetting);

        // Caller-supplied success URL (e.g. an LWR page) takes precedence over the
        // VF completion page, which isn't reachable on LWR community paths. It is
        // URL-encoded because it carries its own query params; the default case is
        // left as-is so Stripe's {CHECKOUT_SESSION_ID} placeholder still substitutes.
        String completeURL = String.isNotBlank(successUrl)
            ? EncodingUtil.urlEncode(successUrl, 'UTF-8')
            : baseUrl() + '/stripe_checkout_complete?session_id={CHECKOUT_SESSION_ID}';
        String formName = 'registration';

        String payload = 'success_url=' + completeURL +
                         '&metadata[orderid]=' + orderNumber +
                         '&metadata[formname]=' + formName +
                         '&payment_intent_data[description]=' + EncodingUtil.urlEncode(orderNumber + ';' + garpId + ';' + orderName, 'UTF-8') +
                         '&mode=payment' +
                         '&ui_mode=hosted';

        payload += cancelUrlParam(cancelUrl);

        if(isMembershipAutoRenew) {
            payload += '&payment_intent_data[setup_future_usage]=off_session';
        }

        if(customerId != NULL) {
            payload += '&customer=' + customerId;
        } else {
            payload += '&customer_email=' + EncodingUtil.urlEncode(email,'UTF-8');
        }

        if(!stripeSetting.Use_Stripe_Tax__c) {
            String strAmount = String.ValueOf(Integer.ValueOf(amount * 100));
            payload += '&line_items[0][price_data][unit_amount]=' + EncodingUtil.urlEncode(strAmount,'UTF-8') +
                       '&line_items[0][price_data][currency]=usd' +
                       '&line_items[0][price_data][product]=' + stripeSetting.Default_Product_ID__c +
                       '&line_items[0][quantity]=1';
        } else {
            payload += '&automatic_tax[enabled]=true';

            Integer i = 0;
            Boolean bookDiscount = False;
            Boolean hasShipping = False;
            for(OpportunityLineItem ol :opp.OpportunityLineItems){
                if(ol.TotalPrice < 0) {
                    bookDiscount = True;
                }
                if(ol.Product2.ProductCode == 'SHIPRAI' || ol.Product2.ProductCode == 'SHIPRAIJ' || ol.Product2.ProductCode == 'SHIPSCR' || ol.Product2.ProductCode == 'SHIPFFR' || ol.Product2.ProductCode == 'SHIPFRR' || ol.Product2.ProductCode == 'SHIPFRM1' || ol.Product2.ProductCode == 'SHIPFRM2') {
                    hasShipping = True;
                }
            }

            for(OpportunityLineItem ol :opp.OpportunityLineItems){
                if(ol.TotalPrice == 0) {
                    continue;
                }
                if(ol.Product2.ProductCode == 'SCRCANDISC' || ol.Product2.ProductCode == 'RAICANDISC' || ol.Product2.ProductCode == 'RAIJCANDISC') {
                    continue;
                }
                if(bookDiscount && (ol.Product2.ProductCode == 'SCRH' || ol.Product2.ProductCode == 'RAIH' || ol.Product2.ProductCode == 'RAIJH')) {
                    ol.TotalPrice = 100;
                }

                String strAmount = String.ValueOf(Integer.ValueOf(ol.TotalPrice * 100));
                String productName = ol.Product2.Name;
                productName = productName.replace(' (Complimentary)','');

                payload += '&line_items[' + i + '][quantity]=1';
                payload += '&line_items[' + i + '][price_data][currency]=usd';
                payload += '&line_items[' + i + '][price_data][unit_amount]=' + strAmount;
                payload += '&line_items[' + i + '][price_data][tax_behavior]=exclusive';
                payload += '&line_items[' + i + '][price_data][product_data][name]=' + EncodingUtil.urlEncode(productName, 'UTF-8');
                payload += '&line_items[' + i + '][price_data][product_data][tax_code]=' + EncodingUtil.urlEncode(ol.Product2.Stripe_Tax_Code__c, 'UTF-8');
                i++;
            }

            payload += '&billing_address_collection=required';

            if(hasShipping) {
                List<Country_Code__c> lstCountries = [select id, Country__c, LetterCode__c
                                                      from Country_Code__c
                                                      where Is_Shipping_Allowed__c = True AND
                                                      Country__c = :opp.Shipping_Country__c AND
                                                      LetterCode__c != NULL AND LetterCode__c not in ('AS','CX','CC','CU','HM','IR','MH','FM','NF','KP','MP','PW','SY','UM','VI') Order By Country__c];
                if(lstCountries.IsEmpty()) {
                    ret.status = 'Failure';
                    ret.message = 'Shipping country not found';
                    return ret;
                }
                Integer j = 0;
                for(Country_Code__c cc :lstCountries) {
                    payload += '&shipping_address_collection[allowed_countries][' + j + ']=' + cc.LetterCode__c;
                    j++;
                }
                payload += '&customer_update[shipping]=auto';
            } else {
                payload += '&customer_update[address]=auto';
            }
        }

        GARP_Common.debugLog('GARP_StripeHostedCheckout','createHostedCheckoutSession','payload',payload);
        return sendAndParse(request, payload, ret);
    }

    /** Mirrors GARP_StripeClass.initializeStripeEnableAutoRenewCheckoutSession in hosted mode. */
    private static GARP_StripeClass.returnInitializeStripeCheckoutSession createHostedAutoRenewSession(String customerId, String garpId, String cancelUrl) {
        GARP_StripeClass.returnInitializeStripeCheckoutSession ret = new GARP_StripeClass.returnInitializeStripeCheckoutSession();

        GARP_StripeSettings__c stripeSetting = GARP_StripeClass.getStripeSettings();
        ret.clientAPIKey = stripeSetting.Client_Side_API_Key__c;

        HttpRequest request = buildSessionRequest(stripeSetting);

        String completeURL = baseUrl() + '/stripe_checkout_complete?mode=setup';

        String payload = 'success_url=' + completeURL +
                         '&metadata[garpid]=' + garpId +
                         '&metadata[mode]=setup' +
                         '&currency=usd' +
                         '&mode=setup' +
                         '&ui_mode=hosted';

        payload += cancelUrlParam(cancelUrl);

        if(customerId != NULL) {
            payload += '&customer=' + customerId;
        }

        GARP_Common.debugLog('GARP_StripeHostedCheckout','createHostedAutoRenewSession','payload',payload);
        return sendAndParse(request, payload, ret);
    }

    // ---- Shared helpers ----------------------------------------------------

    private static String baseUrl() {
        String communityId = Network.getNetworkId();
        String url = Network.getLoginUrl(communityId);
        if(url != NULL) {
            return url.Replace('/Login','');
        }
        return '';
    }

    private static String cancelUrlParam(String cancelUrl) {
        if(String.isNotBlank(cancelUrl)) {
            return '&cancel_url=' + EncodingUtil.urlEncode(cancelUrl, 'UTF-8');
        }
        return '';
    }

    private static HttpRequest buildSessionRequest(GARP_StripeSettings__c stripeSetting) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.stripe.com/v1/checkout/sessions');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('authorization', 'Bearer ' + stripeSetting.Server_Side_API_Key__c);
        return request;
    }

    private static GARP_StripeClass.returnInitializeStripeCheckoutSession sendAndParse(HttpRequest request, String payload, GARP_StripeClass.returnInitializeStripeCheckoutSession ret) {
        request.setBody(payload);

        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            HttpResponse response = new Http().send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            statusCode = 200;
            respbody = '{"id":"cs_test_hosted_123","object":"checkout.session","client_secret":null,"url":"https://checkout.stripe.com/c/pay/cs_test_hosted_123","status":"open"}';
        }
        GARP_Common.debugLog('GARP_StripeHostedCheckout','sendAndParse','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeHostedCheckout','sendAndParse','respbody',respbody);

        if(statusCode == 200) {
            GARP_StripeClass.respCreateSession resp = (GARP_StripeClass.respCreateSession)JSON.deserialize(respbody, GARP_StripeClass.respCreateSession.class);
            ret.respCreateSession = resp;
            ret.status = 'Success';
            ret.message = 'Checkout Session Initialized';
        } else {
            ret.status = 'Failure';
            ret.message = 'Failed to Initialize Checkout Session';
        }

        return ret;
    }
}