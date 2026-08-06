public class stripe_checkout {

    public String clientSecret {get;set;} 
    public String clientAPIKey {get;set;} 
    public String orderId {get;set;} 
    public String accountId {get;set;} 
    public String orderNumber {get;set;} 
    public String orderName {get;set;}
    public String sessionId {get;set;}
    public String source {get;set;}
    public String mode {get;set;}
    
    public String userName {get;set;}
    public String examName {get;set;}
    
    public String regType {get;set;}
    public String regSlug {get;set;}
    public String logoURL {get;set;}
    public String logoWebSiteUrl {get;set;}
    
    public String msg {get;set;} 
    public Boolean isError {get;set;} 
    
    public Boolean isMember {get;set;} 
    
    public stripe_checkout() {
        clientSecret = Null;
        orderId = Null;
        accountId = Null;
        orderNumber = Null;
        sessionId = Null;
        msg = Null;
        isError = False;
        isMember = False;
        regType = Null;
    }
    
    public PageReference initializeStripe() {
        
        regType = ApexPages.currentPage().getParameters().get('regType');
        logoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP%20Corporate%20Logo%20-%20Short%20Knockout.png';
        logoWebSiteUrl = 'https://www.garp.org/';
        regSlug = regType;
        
        if(regType != NULL) {
            switch on regType {
                when 'frm' {
                    logoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP%20FRM%20Logo%20-%20Knockout.png';
                    logoWebSiteUrl = 'https://www.garp.org/frm';
                    regSlug = 'frm';
                }   
                when 'mem' {
                    logoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP-Membership-Knockout.png';
                    logoWebSiteUrl = 'https://www.garp.org/membership';
                    regSlug = 'membership';
                }
                when 'scr' {
                    logoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP%20SCR%20Logo%20-%20Knockout.png';
                    logoWebSiteUrl = 'https://www.garp.org/scr';
                    regSlug = 'membership';
                }
                when 'riskai' {
                    logoURL = 'https://www.garp.org/hubfs/Website/Logos/RAI-short-knockout.png';
                    logoWebSiteUrl = 'https://www.garp.org/rai';
                    regSlug = 'rai';
                }   
                when 'raij' {
                    logoURL = 'https://www.garp.org/hubfs/Website/Logos/RAI-short-knockout.png';
                    logoWebSiteUrl = 'https://www.garp.org/rai';
                    regSlug = 'rai';
                }
                when else {
                    logoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP%20Corporate%20Logo%20-%20Short%20Knockout.png';
                    logoWebSiteUrl = 'https://www.garp.org';
                    regSlug = null;
                }
            }
        }
        
        mode = ApexPages.currentPage().getParameters().get('mode');
        sessionId = ApexPages.currentPage().getParameters().get('session_id');
        source = ApexPages.currentPage().getParameters().get('src');
        orderId = ApexPages.currentPage().getParameters().get('id');
        
        GARP_Common.debugLog('RESTStripeController','initializeStripe','mode',mode);
        GARP_Common.debugLog('RESTStripeController','initializeStripe','sessionId',sessionId);
        GARP_Common.debugLog('RESTStripeController','initializeStripe','source',source);
        GARP_Common.debugLog('RESTStripeController','initializeStripe','orderId',orderId);
        
        if(orderId == NULL && sessionId == NULL && mode == NULL) {
            isError = True;
            msg = 'Order not found';
            return NULL;
        }
        
        
        Id userId = UserInfo.getUserId();
        List<User> users = [SELECT Id, ContactId, Contact.FirstName, Contact.LastName, AccountId, Profile.Name, Email, Username FROM User WHERE Id = :userId];
        GARP_Common.debugLog('RESTStripeController','initializeStripe','users',users);
        if((!users.isEmpty() && users[0].Profile.Name == 'Customer Community') || Test.isRunningTest()) {
            User user = users[0];
            isMember = True;
            accountId = user.AccountId;
            userName =  user.Contact.FirstName + ' ' + user.Contact.LastName;
        }
        GARP_Common.debugLog('RESTStripeController','initializeStripe','isMember',isMember);
        GARP_Common.debugLog('RESTStripeController','initializeStripe','accountId',accountId);
        
        
        String relativeUrl = ApexPages.currentPage().getUrl();
        GARP_Common.debugLog('RESTStripeController','initializeStripe','relativeUrl',relativeUrl);
        
        // Go to Setup
        if(mode == 'setup' && (relativeUrl.indexOf('complete') == -1 || Test.isRunningTest())) {
            
            // Create New Session
            GARP_StripeClass.returnInitializeStripeCheckoutSession ret = GARP_StripeClass.initializeEnableAutoRenewSession();
            
            if(ret != NULL && ret.respCreateSession != NULL && ret.respCreateSession.client_secret != NULL) {
                clientSecret = ret.respCreateSession.client_secret;
                clientAPIKey = ret.clientAPIKey;
            } else {
                isError = True;
                msg = 'Session failed to create';
            }
            
        } else if(mode == 'setup' && relativeUrl.indexOf('complete') > -1) {
            
            // Return from Setup
            return new PageReference('/garpapp#/my-account?status=autorenewsetupcomplete');
            
        } else if(orderId != NULL) {
            
            // Fetch Order
            List<Opportunity> lstOpp = [select Id, AccountId, Account.Member_First_Name__c, Account.Member_Last_Name__c, Name, StageName, Display_Invoice_Number__c, Amount, Billing_Email__c, Auto_Renew__c, B2B_Deal_Item__r.Access_Code__c,
                                        Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Postal_Code__c, Shipping_Country__c, Shipping_Phone_No__c,
                                        Billing_Address__c, Billing_City__c, Billing_State_Text__c, Billing_Zip_Postal__c, Billing_Country__c, Billing_Phone__c,
                                        (select Id, Description, PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice, Product2.Name, Product2.Stripe_Tax_Code__c, Product2.ProductCode, Product2.Tax_Rate__c, Product2.Do_Not_Charge_VAT__c, Product2.Do_Not_Charge_VAT_Countries__c FROM OpportunityLineItems),
                                        (select id, ChargentOrders__Gateway__c, ChargentOrders__Subtotal__c, ChargentOrders__Charge_Amount__c,
                                         ChargentOrders__Tokenization__c, ChargentOrders__Order_Information__c
                                         from Chargent_Orders__r)
                                        from Opportunity where id = :orderId];
            GARP_Common.debugLog('RESTStripeController','initializeStripe','lstOpp',lstOpp);
            if(!lstOpp.IsEmpty()) {
                Opportunity opp = lstOpp[0];
                
                orderName = opp.Name;
                orderNumber = opp.Display_Invoice_Number__c;
                accountId = opp.AccountId;
                
                if(opp.StageName != 'New Lead') {
                    isError = True;
                    msg = 'Order is already paid';
                } else {
                    List<Exam_Attempt__c> lstExamAttempt = [select id, RPT_Exam_Program__c, RPT_Administration_Month__c, RPT_Administration_Year__c from Exam_Attempt__c where Opportunity__c = :opp.Id];
                    if(!lstExamAttempt.IsEmpty()) {
                        Exam_Attempt__c examAttempt = lstExamAttempt[0];
                        examName = examAttempt.RPT_Exam_Program__c + ' Exam - ' + examAttempt.RPT_Administration_Month__c + ' ' + examAttempt.RPT_Administration_Year__c;
                    }
                    
                    // Create New Session
                    GARP_StripeClass.returnInitializeStripeCheckoutSession ret = GARP_StripeClass.initializeCheckoutSession(opp,false);
                    
                    if(ret.status != 'Success') {                       
                        if(ret.message.contains('valid address') || ret.message.contains('Set a valid customer address')){
                            GARP_StripeClass.returnInitializeStripeCheckoutSession retw = GARP_StripeClass.initializeCheckoutSession(opp,true);
                            if(retw.status != 'Success') {
                                isError = True;
                                msg = retw.message;
                            }else if(retw != NULL && retw.respCreateSession != NULL && retw.respCreateSession.client_secret != NULL) {
                                clientSecret = retw.respCreateSession.client_secret;
                                clientAPIKey = retw.clientAPIKey;
                            }
                        }else{
                            isError = True;
                            msg = ret.message;
                        }
                    } else if(ret != NULL && ret.respCreateSession != NULL && ret.respCreateSession.client_secret != NULL) {
                        clientSecret = ret.respCreateSession.client_secret;
                        clientAPIKey = ret.clientAPIKey;
                    }
                }
                
            } else {
                isError = True;
                msg = 'Order Not Found';
            }
            
            
        } else if(sessionId != NULL) {
            
            if(source == 'garpapp') {
                // GARPAPP New Reg
                return new PageReference('/garpapp2#/registration/survey');
            } else {
                // Legacy Checkout Complete
                return new PageReference('/sfdcApp#!/registration/information');                
            }   
        }
        return Null;
    }
    
    public PageReference goToOrders() {
        
        // Revert Order
        if(!Test.isRunningTest()) {
            GARP_Common.returnInfo ret = GARP_BC_Orders.abandonPayPendingOrder(accountId, orderId);    
        }
        
        // Redirect to the Account record page
        PageReference pr = new PageReference('/garpapp#/purchase-history');
        pr.setRedirect(true);
        return pr;        
    }
    
    public PageReference goToMyAccount() {
                
        // Cancel Order
        if(!Test.isRunningTest()) {
            GARP_Common.returnInfo ret = GARP_BC_Orders.cancelUnpaidOrder(accountId, orderId);
        }
        
        // Redirect to the Account record page
        PageReference pr = new PageReference('/garpapp#/my-account');
        pr.setRedirect(true);
        return pr;        
    }
    
    public PageReference goToRegistration() {
        
        PageReference pr;
        if(source == 'garpapp') {
            pr = new PageReference('/garpApp2#/registration/' + regSlug);
            pr.setRedirect(true);
        } else {
            pr = new PageReference('/sfdcApp?redirect_status=cancel#!/registration/information');
            pr.setRedirect(true);            
        }
        return pr;
    }
}