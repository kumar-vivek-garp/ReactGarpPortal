public class GARP_StripeClass {
    
    // API Calls
    public class respSubscriptionLatestInvoicePaymentIntent {
        public String id;
        public String client_secret;
    }
    
    public class respSubscriptionLatestInvoice {
        public String id;
        public respSubscriptionLatestInvoicePaymentIntent payment_intent;
    }
    
    public class respSubscriptionItemsData {
        public String id;
    }
    
    public class respSubscriptionItems {
        public List<respSubscriptionItemsData> data;
    }
    
    public class respSubscription {
        public String id;
        respSubscriptionLatestInvoice latest_invoice;
        respSubscriptionItems items;
    }
    
    public class respPaymentIntent {
        public String id;
        public Long amount;
        public String client_secret;
    }
    // End API Calls
    
    // Webhook
    public class eventObjectMetaData {
        public String orderid;
        public String mode;
        public String formname;
    }
    
    public class eventObjectChragesDataPaymentMethodDetailsCard {
        public String brand;
        public String last4;
    }
    
    public class eventObjectChragesDataPaymentMethodDetails {
        public String type;
        public eventObjectChragesDataPaymentMethodDetailsCard card;
    }
    
    public class eventObjectPresentmentDetails {
        public Long presentment_amount;
        public String presentment_currency;
    }

    public class eventObjectChragesDataBillingDetails {
        public eventObjectAddress address;
    }
    
    public class eventObjectChragesData {
        public String id;
        public Long amount;
        public Boolean paid;
        public Boolean refunded;
        public String status;
        public eventObjectChragesDataBillingDetails billing_details;
        public eventObjectChragesDataPaymentMethodDetails payment_method_details;
        public eventObjectPresentmentDetails presentment_details;
    }    
    
    public class eventObjectCharges {
        public List<eventObjectChragesData> data;
    }
    
    public class eventObjectAmountDetailsTax {
        public Long total_tax_amount;
    }
    
    public class eventObjectAmountDetails {
        eventObjectAmountDetailsTax tax;
    }
    
    public class eventObjectPaymentDetails {
        String order_reference;
    }
    
    public class eventObjectAddress {
        public String city;
        public String country;
        public String line1;
        public String line2;
        public String postal_code;
        public String state;
    }
    
    public class eventObjectShipping {
        public eventObjectAddress address;
    }
    
    public class eventObjectObject {
        public String id;
        public String customer;
        public String description;
        public String payment_method;        
        public eventObjectMetaData metadata;
        public eventObjectCharges charges;
        public eventObjectAmountDetails amount_details;
        public eventObjectShipping shipping;
        public eventObjectPaymentDetails payment_details;
    }
    
    public class eventObjectData {
        public eventObjectObject objectSTR;   
    }
    
    public class eventObject {
        public String id;        
        public String objectSTR;
        public String api_version;
        public String type;
        public Long created;
        public eventObjectData data;
    }
    
    // Adaptive Pricing Webhook
    
    // Errors
    public class eventLastPaymentErrorPaymentMethod {
        String type;
        public eventObjectChragesDataPaymentMethodDetailsCard card;
    }
    
    public class eventLastPaymentError {
        public String code;
        public String message;
        public eventLastPaymentErrorPaymentMethod payment_method;
    }
    
    public class eventErrorObjectObject {
        public String id;
        public eventLastPaymentError last_payment_error;
        public eventObjectMetaData metadata;
    }
    
    public class eventErrorObjectData {
        public eventErrorObjectObject objectSTR;   
    }
    
    public class eventErrorObject {
        public String id;        
        public String objectSTR;
        public String api_version;
        public String type;
        public Long created;
        public eventErrorObjectData data;
    }
    // End Webhook
    
    // GARP Methods 
    public class retSetupSubscription {
        public String paymentIntentId;
        public String clientSecret;
        public String subscriptionId;
        public String mainSubItemId;
        public String recurSubItemId;        
        public String status;
        public String message;
    }
    
    public class retSetupPaymentIntent {
        public String paymentIntentId;
        public String clientSecret;
        public String status;
        public String message;
    }
    
    /* Old not in use
public class retCheckoutGetURL {
public String id;
public Long amount_total;
public String url;
}

public class prod {
public String name;
public Integer amount;
}    
*/
    
    public class respCustomerInvoiceSettings {
        public String default_payment_method;
    }
    
    public class respCustomerMetaData {
        public String garpId;
    }
    
    public class respCustomer {
        public String id;
        public String email;
        public String name;
        public respCustomerMetaData metadata;
        public respCustomerInvoiceSettings invoice_settings;
        public eventObjectAddress address;
        public eventObjectShipping shipping;
    }
    
    public class retGetCustomer {
        public respCustomer customer;
        public String status;
        public String message;
    }
    
    public class retSetupCustomer {
        public String customerId;
        public String status;
        public String message;
    }
    
    public class stripeInfo {
        public String customerId;
        public String wechatPaymentIntentId;
        public String wechatClientSecret;
        public String alipayPaymentIntentId;
        public String alipayClientSecret;
        public String alipaySubscriptionId;
        public String mainSubItemId;
        public String recurSubItemId;
        public String clientSideAPIKey;
    }
    
    public class retSetupStripe {
        public stripeInfo stripeInfo;
        public Boolean useStripe;
        public Boolean useStripeTax;
        public String status;
        public String message;
    }
    
    public static GARP_StripeSettings__c getStripeSettings() {
        
        Map<String, GARP_StripeSettings__c> stripeSettings = GARP_StripeSettings__c.getAll();
        GARP_Common.debugLog('GARP_StripeClass','isStripeEnabled','getStripeSettings',stripeSettings);
        
        if(!stripeSettings.IsEmpty()) {
            for(GARP_StripeSettings__c ss :stripeSettings.values()) {
                if(ss.Is_Active__c) {
                    GARP_Common.debugLog('GARP_StripeClass','isStripeEnabled','Found Settings',ss);
                    return ss;
                }
            }
            return NULL;
        } else {
            return NULL;
        }
    }
    
    public static retSetupStripe isStripeEnabled() {
        GARP_Common.debugLog('GARP_StripeClass','isStripeEnabled','',NULL);
        
        retSetupStripe ret = new retSetupStripe();
        ret.stripeInfo = new stripeInfo();
        ret.useStripe = False;
        ret.useStripeTax = False;
        
        GARP_StripeSettings__c stripeSetting = getStripeSettings();
        GARP_Common.debugLog('GARP_StripeClass','isStripeEnabled','stripeSetting',stripeSetting);
        
        if(stripeSetting != NULL) {
            if(stripeSetting.Use_Stripe__c) {
                ret.useStripe = True;
                
                if(stripeSetting.Use_Stripe_Tax__c) {
                    ret.useStripeTax = True;
                    ret.stripeInfo.clientSideAPIKey = stripeSetting.Client_Side_API_Key__c;
                }
                
                if(stripeSetting.Client_Side_API_Key__c == NULL) {
                    // Error setting not found
                    ret.status = 'Failure';
                    ret.message = 'Stripe setting not found';
                    return ret;
                } else {
                    ret.stripeInfo.clientSideAPIKey = stripeSetting.Client_Side_API_Key__c;
                }
            } else {
                ret.useStripe = False;
                ret.status = 'Success';
                ret.message = 'Stripe disabled';
                return ret;
            }
        } else {
            ret.status = 'Failure';
            ret.message = 'Stripe setting not found';
            return ret;            
        }
        
        ret.status = 'Success';
        ret.message = 'Return data';
        
        GARP_Common.debugLog('GARP_StripeClass','isStripeEnabled','final ret',ret);
        return ret;
    }
        
    public class respCreateSession {
        public String id;
        public String client_secret;
        public String url;
    }
    
    public class returnInitializeStripeCheckoutSession {
        public string status;
        public string message;
        public respCreateSession respCreateSession;
        public string clientAPIKey; 
    }
    
    public static returnInitializeStripeCheckoutSession initializeStripeCheckoutSession(String orderNumber, String orderName, Decimal amount, String email, String customerId, String garpId, Boolean isMembershipAutoRenew, Opportunity opp) {
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','orderNumber',orderNumber);
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','orderName',orderName);
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','amount',amount);
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','email',email);
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','customerId',customerId);
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','garpId',garpId);
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','isMembershipAutoRenew',isMembershipAutoRenew);
        
        returnInitializeStripeCheckoutSession ret = new returnInitializeStripeCheckoutSession();
        
        GARP_StripeSettings__c stripeSetting = GARP_StripeClass.getStripeSettings();
    
        ret.clientAPIKey = stripeSetting.Client_Side_API_Key__c;
        
        String endpoint = 'https://api.stripe.com/v1/checkout/sessions';
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','endpoint',endpoint);
                
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String apikey = stripeSetting.Server_Side_API_Key__c;
        request.setHeader('authorization', 'Bearer ' + apikey);
        
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','apikey',apikey);
    
        String communityId = Network.getNetworkId();
        String baseUrl = Network.getLoginUrl(communityId);
        
        if(baseUrl != NULL) {
            baseUrl = baseUrl.Replace('/Login','');    
        } else {
            baseUrl = '';
        }
        
        
        String completeURL = baseUrl+ '/stripe_checkout_complete?session_id={CHECKOUT_SESSION_ID}';
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','completeURL',completeURL);
        
        // TO DO Get this from order?
        String formName = 'registration';
                
        String payload = 'return_url=' + completeURL +
                         '&metadata[orderid]=' + orderNumber +
                         '&metadata[formname]=' + formName +
                         '&payment_intent_data[description]=' + EncodingUtil.urlEncode(orderNumber + ';' + garpId + ';' + orderName, 'UTF-8') +
                         '&mode=payment' +
                         '&ui_mode=embedded';
                         
        if(isMembershipAutoRenew) {
            payload += '&payment_intent_data[setup_future_usage]=off_session';
        }
        
        if(customerId != NULL) {
            payload += '&customer=' + customerId;
        } else {
            payload += '&customer_email=' + EncodingUtil.urlEncode(email,'UTF-8'); // test%2blocation_IN@example.com
        }
        
        if(!stripeSetting.Use_Stripe_Tax__c) {
            String strAmount = String.ValueOf(Integer.ValueOf(amount * 100));
            String prodPayload = '';
            prodPayload = '&line_items[0][price_data][unit_amount]=' + EncodingUtil.urlEncode(strAmount,'UTF-8') +
                         '&line_items[0][price_data][currency]=usd' +
                         '&line_items[0][price_data][product]=' + stripeSetting.Default_Product_ID__c +
                         '&line_items[0][quantity]=1';
            
            GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','Product Payload',prodPayload);
            
            payload += prodPayload;
            
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
            GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','bookDiscount',bookDiscount);
            GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','hasShipping',hasShipping);
            
            for(OpportunityLineItem ol :opp.OpportunityLineItems){
                GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','Loop Line Items',ol);
                
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
                
                String prodPayload = '';                
                prodPayload += '&line_items[' + i + '][quantity]=1';
                prodPayload += '&line_items[' + i + '][price_data][currency]=usd';
                prodPayload += '&line_items[' + i + '][price_data][unit_amount]=' + strAmount;
                prodPayload += '&line_items[' + i + '][price_data][tax_behavior]=exclusive';
                prodPayload += '&line_items[' + i + '][price_data][product_data][name]=' +
                    EncodingUtil.urlEncode(productName, 'UTF-8');
                prodPayload += '&line_items[' + i + '][price_data][product_data][tax_code]=' +
                    EncodingUtil.urlEncode(ol.Product2.Stripe_Tax_Code__c, 'UTF-8');
                
                GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','Product Payload',prodPayload);
                payload += prodPayload;
                
                i++;
            }
            
            payload += '&billing_address_collection=required';
            
            if(hasShipping) {
                List<Country_Code__c> lstCountries = [select id, Country__c, LetterCode__c 
                                                      from Country_Code__c 
                                                      where Is_Shipping_Allowed__c = True AND
                                                      Country__c = :opp.Shipping_Country__c AND
                                                      LetterCode__c != NULL AND LetterCode__c not in ('AS','CX','CC','CU','HM','IR','MH','FM','NF','KP','MP','PW','SY','UM','VI') Order By Country__c];
                GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','lstCountries',lstCountries);
                
                if(lstCountries.IsEmpty()) {
                    ret.status = 'Failure';
                    ret.message = 'Shipping country not found';
                    return ret;
                }
                
                String shipCountryPayload = '';  
                i = 0;
                for(Country_Code__c cc :lstCountries) {
                    shipCountryPayload += '&shipping_address_collection[allowed_countries][' + i + ']=' + cc.LetterCode__c;
                    i++;
                }
                GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','shipCountryPayload',shipCountryPayload);
                payload += shipCountryPayload;
            }
            if(hasShipping) {
                payload += '&customer_update[shipping]=auto';
            } else {
                payload += '&customer_update[address]=auto';    
            }
        }
        
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','payload',payload);

        request.setBody(payload);

        Http httpProtocol = new Http();
        HttpResponse response;
        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            response = new HttpResponse();
            statusCode = 200;
            respbody = '{"id":"pi_3OAfA6AyydB05IeX3YYtgyoI","object":"payment_intent","amount":100,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":null,"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","charges":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges?payment_intent=pi_3OAfA6AyydB05IeX3YYtgyoI"},"client_secret":"pi_3OAfA6AyydB05IeX3YYtgyoI_secret_V18tncALPUAPqDu3Qyyl6wU98","confirmation_method":"automatic","created":1699562954,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":null,"livemode":false,"metadata":{"orderid":"1234567"},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_configuration_details":null,"payment_method_options":{"alipay":{},"wechat_pay":{"app_id":null,"client":null}},"payment_method_types":["alipay","wechat_pay"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}';
        }
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','respbody',respbody);
        
        if(statusCode == 200) {    
            respCreateSession resp = (respCreateSession)JSON.deserialize(respbody, respCreateSession.class);
            ret.respCreateSession = resp;
            ret.status = 'Success';
            ret.message = 'Checkout Session Initialized';
        } else {
           	 ret.status = 'Failure';
            try{
                Map<String, Object> responseMap =
                    (Map<String, Object>) JSON.deserializeUntyped(respbody);
                if (responseMap.containsKey('error')) {
                    Map<String, Object> errorMap =
                        (Map<String, Object>) responseMap.get('error');
                    
                    ret.message = (String) errorMap.get('message');
                    
                }else{
                     ret.message = 'Failed to Initialize Checkout Session'; 
                }
            }catch(exception e){
                
                ret.message = 'Failed to Initialize Checkout Session';    
            }
                  
        }
        
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeCheckoutSession','final ret',ret);
        return ret;
    }
    
    public static returnInitializeStripeCheckoutSession initializeStripeEnableAutoRenewCheckoutSession(String customerId, String garpId) {
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeEnableAutoRenewCheckoutSession','customerId',customerId);
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeEnableAutoRenewCheckoutSession','garpId',garpId);
        
        returnInitializeStripeCheckoutSession ret = new returnInitializeStripeCheckoutSession();
        
        GARP_StripeSettings__c stripeSetting = GARP_StripeClass.getStripeSettings();
    
        ret.clientAPIKey = stripeSetting.Client_Side_API_Key__c;
        
        String endpoint = 'https://api.stripe.com/v1/checkout/sessions';
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeEnableAutoRenewCheckoutSession','endpoint',endpoint);
                
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String apikey = stripeSetting.Server_Side_API_Key__c;
        request.setHeader('authorization', 'Bearer ' + apikey);
        
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeEnableAutoRenewCheckoutSession','apikey',apikey);
    
        String communityId = Network.getNetworkId();
        String baseUrl = Network.getLoginUrl(communityId);
        
        if(baseUrl != NULL) {
            baseUrl = baseUrl.Replace('/Login','');    
        } else {
            baseUrl = '';
        }
        
        String completeURL = baseUrl+ '/stripe_checkout_complete?mode=setup';
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeEnableAutoRenewCheckoutSession','completeURL',completeURL);
        
        // TO DO Get this from order?
        String formName = 'registration';
                
        String payload = 'return_url=' + completeURL +
                         '&metadata[garpid]=' + garpId +
                         '&metadata[mode]=setup' +
                         '&currency=usd' + 
                         '&mode=setup' +
                         '&ui_mode=embedded';
                                 
        if(customerId != NULL) {
            payload += '&customer=' + customerId;
        }
        
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeEnableAutoRenewCheckoutSession','payload',payload);

        request.setBody(payload);
        
        Http httpProtocol = new Http();
        HttpResponse response;
        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            response = new HttpResponse();
            statusCode = 200;
            respbody = '{"id":"pi_3OAfA6AyydB05IeX3YYtgyoI","object":"payment_intent","amount":100,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":null,"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","charges":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges?payment_intent=pi_3OAfA6AyydB05IeX3YYtgyoI"},"client_secret":"pi_3OAfA6AyydB05IeX3YYtgyoI_secret_V18tncALPUAPqDu3Qyyl6wU98","confirmation_method":"automatic","created":1699562954,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":null,"livemode":false,"metadata":{"orderid":"1234567"},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_configuration_details":null,"payment_method_options":{"alipay":{},"wechat_pay":{"app_id":null,"client":null}},"payment_method_types":["alipay","wechat_pay"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}';
        }
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeEnableAutoRenewCheckoutSession','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeEnableAutoRenewCheckoutSession','respbody',respbody);
        
        if(statusCode == 200) {    
            respCreateSession resp = (respCreateSession)JSON.deserialize(respbody, respCreateSession.class);
            ret.respCreateSession = resp;
            ret.status = 'Success';
            ret.message = 'Checkout Session Initialized';
        } else {
            ret.status = 'Failure';
            ret.message = 'Failed to Initialize Checkout Session';            
        }
        
        GARP_Common.debugLog('GARP_StripeClass','initializeStripeEnableAutoRenewCheckoutSession','final ret',ret);
        return ret;
    }
    
    public class returnGetStripeCustomer {
        public String status;
        public String message;
        public String stripeCustomerId;
    }
    
    public static returnGetStripeCustomer getStripeCustomer(String stripeCustomerId, String name, String garpId, String email, GARP_Common.address billingAddress, GARP_Common.address shippingAddress) {
        GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','stripeCustomerId', stripeCustomerId);
        GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','name', name);
        GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','garpId', garpId);
        GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','email', email);
        GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','billingAddress', billingAddress);
        GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','shippingAddress', shippingAddress);
        
        returnGetStripeCustomer ret = new returnGetStripeCustomer();
        
        GARP_StripeSettings__c stripeSetting = getStripeSettings();
        GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','stripeSetting',stripeSetting);
        
        MAP<String,Country_Code__c> mapCC = GARP_Common.getCountriesMapByCountryName();
        GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','mapCC',mapCC);
        
        respCustomer respCustomer;

        // Stripe ID not on Contact yet
        if(stripeCustomerId == NULL) {
        
            // Search for customer
            if(garpId != NULL && !String.IsEmpty(garpId)) {
                retSearchCustomer retSearchCustomer = findCustomer(NULL, garpId, stripeSetting);
                if(retSearchCustomer.status == 'Success' && retSearchCustomer.customer != NULL) {
                    stripeCustomerId = retSearchCustomer.customer.id;
                    respCustomer = retSearchCustomer.customer;
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','found stripe customer via GARP ID', stripeCustomerId);
                }
            }
            
            if(stripeCustomerId == NULL) {
                retSearchCustomer retSearchCustomer = findCustomer(email, null, stripeSetting);
                if(retSearchCustomer.status == 'Success' && retSearchCustomer.customer != NULL) {
                    stripeCustomerId = retSearchCustomer.customer.id;
                    respCustomer = retSearchCustomer.customer;
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','found stripe customer via email', stripeCustomerId);                 
                }            
            }
        } else {
            retGetCustomer retGet = getCustomer(stripeSetting, stripeCustomerId);
            
            if(retGet.status != 'Success' || retGet.customer == NULL) {
                ret.status = 'Failure';
                ret.message = 'Stripe customer not found';
                return ret;
            }
            respCustomer = retGet.customer;
        }
        
        // Billing - If address was given, fix it
        Boolean givenBillingAddess = False;
        if(billingAddress.street1 != NULL && billingAddress.city != NULL && billingAddress.country != NULL) {
            
            givenBillingAddess = True;
            
            Country_Code__c fndCountry = mapCC.get(billingAddress.country);
            GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndCountry by name',fndCountry);  
            
            if(fndCountry != NULL) {
                billingAddress.country = fndCountry.LetterCode__c;
            }
            
            if(billingAddress.province != NULL) {
                
                if(fndCountry == NULL) {
                    mapCC = GARP_Common.getCountriesMapByCountryCode();
                    fndCountry = mapCC.get(billingAddress.country);
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndCountry by code',fndCountry);
                }
                
                if(fndCountry != NULL) {
                    MAP<String,Province__c> mapProvince = GARP_Common.getProvinceMapByName(fndCountry.Id);
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','mapProvince',mapProvince);  
                    
                    Province__c fndProvince = mapProvince.get(billingAddress.province);
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndProvince',fndProvince);  
                    
                    if(fndProvince != NULL) {
                        billingAddress.province = fndProvince.code__c;
                    }
                }
            }
            GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','adjusted billing address',billingAddress);   
        } 
        
        // Shipping - If address was given, fix it
        Boolean givenShippingAddess = False;
        if(shippingAddress.street1 != NULL && shippingAddress.city != NULL && shippingAddress.country != NULL) {
            
            givenShippingAddess = True;
            
            Country_Code__c fndCountry = mapCC.get(shippingAddress.country);
            GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndCountry',fndCountry);  
            
            if(fndCountry != NULL) {
                shippingAddress.country = fndCountry.LetterCode__c;
            }
            
            if(shippingAddress.province != NULL) {
                
                if(fndCountry == NULL) {
                    mapCC = GARP_Common.getCountriesMapByCountryCode();
                    fndCountry = mapCC.get(shippingAddress.country);
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndCountry by code',fndCountry);
                }
                
                if(fndCountry != NULL) {
                    MAP<String,Province__c> mapProvince = GARP_Common.getProvinceMapByName(fndCountry.Id);
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','mapProvince',mapProvince);  
                    
                    Province__c fndProvince = mapProvince.get(shippingAddress.province);
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndProvince',fndProvince);  
                    
                    if(fndProvince != NULL) {
                        shippingAddress.province = fndProvince.code__c;
                    }
                }
            }
            GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','adjusted shipping address',shippingAddress);   
        } 
        
        GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','givenBillingAddess',givenBillingAddess); 
        GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','givenShippingAddess',givenShippingAddess); 
        
        
        // If already existed update
        if(stripeCustomerId != NULL) {
            
            if(!givenBillingAddess && respCustomer != NULL && respCustomer.address != NULL) {
                // If no new address given and Stripe customer has an existing address - fix if needed
                if(respCustomer.address.country != NULL) {
                    
                    // Set fields for update
                    billingAddress.city = respCustomer.address.city;
                    billingAddress.street1 = respCustomer.address.line1;
                    billingAddress.street2 = respCustomer.address.line2;
                    billingAddress.postalCode = respCustomer.address.postal_code;
                    billingAddress.province = respCustomer.address.state;
                    billingAddress.country = respCustomer.address.country;
                    
                    Country_Code__c fndCountry = mapCC.get(respCustomer.address.country);
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndCountry',fndCountry);  
                    
                    if(fndCountry != NULL) {
                        billingAddress.country = fndCountry.LetterCode__c;
                    }
                    
                    if(respCustomer.address.state != NULL) {
                        
                        if(fndCountry == NULL) {
                            mapCC = GARP_Common.getCountriesMapByCountryCode();
                            fndCountry = mapCC.get(respCustomer.address.country);
                            GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndCountry by code',fndCountry);
                        }
                        
                        if(fndCountry != NULL) {
                            
                            if(respCustomer.shipping != null && respCustomer.shipping.address.state != NULL) {
                                MAP<String,Province__c> mapProvince = GARP_Common.getProvinceMapByName(fndCountry.Id);
                                GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','mapProvince',mapProvince);  
                                
                                Province__c fndProvince = mapProvince.get(respCustomer.address.state);
                                GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndProvince',fndProvince);  
                                
                                if(fndProvince != NULL) {
                                    billingAddress.province = fndProvince.code__c;
                                }
                            }
                        }
                    }
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','adjusted billing address',billingAddress);
                }
            }
            
            if(!givenShippingAddess && respCustomer != NULL && respCustomer.shipping != NULL && respCustomer.shipping.address != NULL) {
                // If no new address given and Stripe customer has an existing address - fix if needed
                if(respCustomer.shipping.address.country != NULL) {

                    // Set fields for update
                    shippingAddress.city = respCustomer.shipping.address.city;
                    shippingAddress.street1 = respCustomer.shipping.address.line1;
                    shippingAddress.street2 = respCustomer.shipping.address.line2;
                    shippingAddress.postalCode = respCustomer.shipping.address.postal_code;
                    shippingAddress.province = respCustomer.shipping.address.state;
                    shippingAddress.country = respCustomer.shipping.address.country;
                    
                    Country_Code__c fndCountry = mapCC.get(respCustomer.shipping.address.country);
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndCountry',fndCountry);  
                    
                    if(fndCountry != NULL) {
                        shippingAddress.country = fndCountry.LetterCode__c;
                    }
                    
                    if(respCustomer.shipping.address.state != NULL) {
                        
                        if(fndCountry == NULL) {
                            mapCC = GARP_Common.getCountriesMapByCountryCode();
                            fndCountry = mapCC.get(respCustomer.shipping.address.country);
                            GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndCountry by code',fndCountry);
                        }
                        
                        if(fndCountry != NULL) {
                            MAP<String,Province__c> mapProvince = GARP_Common.getProvinceMapByName(fndCountry.Id);
                            GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','mapProvince',mapProvince);  
                            
                            Province__c fndProvince = mapProvince.get(respCustomer.shipping.address.state);
                            GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','fndProvince',fndProvince);  
                            
                            if(fndProvince != NULL) {
                                shippingAddress.province = fndProvince.code__c;
                            }
                        }
                    }
                    GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','adjusted shipping address',shippingAddress);
                }
            }
            
            retSetupCustomer retUpdate = updateCustomer(stripeSetting, stripeCustomerId, name, email, garpId, NULL, billingAddress, shippingAddress);
            GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','retUpdate',retUpdate);
            
            if(retUpdate.status != 'Success') {
                ret.status = 'Failure';
                ret.message = retUpdate.message;//'Stripe customer update failed';
                return ret;
            }
        } else {
            // Create New Customer
            retSetupCustomer retCreateCustomer = createCustomer(stripeSetting, email, name, garpId, billingAddress, shippingAddress);
            GARP_Common.debugLog('GARP_StripeClass','getStripeCustomer','retCreateCustomer',retCreateCustomer);
            
            if(retCreateCustomer.status != 'Success') {
                ret.status = 'Failure';
                ret.message = 'Unable to create customer';
                return ret;
            }
            stripeCustomerId = retCreateCustomer.customerId;
        }
        
        ret.stripeCustomerId = stripeCustomerId;
        ret.status = 'Success';
        ret.message = 'Customer returned';
        return ret;
    }
   
    public static returnInitializeStripeCheckoutSession initializeCheckoutSession(Opportunity opp,boolean isValidaddress) {
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','opp',opp);
        
        returnInitializeStripeCheckoutSession ret = new returnInitializeStripeCheckoutSession();
        
        if(opp == NULL) {
            ret.status = 'Failure';
            ret.message = 'Required params missing';            
            return ret;
        }
        
        String userName;
        String orderNumber;
        String orderName;
        
        orderName = opp.Name;
        orderNumber = opp.Display_Invoice_Number__c;
        userName =  opp.Account.Member_First_Name__c + ' ' + opp.Account.Member_Last_Name__c;
        
        Decimal amount = opp.Amount;
        String email = opp.Billing_Email__c;
        Boolean isMembershipAutoRenew = opp.Auto_Renew__c;

        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','userName',userName);
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','orderNumber',orderNumber);
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','orderName',orderName);
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','amount',amount); 
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','email',email);        
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','isMembershipAutoRenew',isMembershipAutoRenew);        
        
        MAP<String,Country_Code__c> mapCC = GARP_Common.getCountriesMapByCountryName();
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','mapCC',mapCC);  
        
        GARP_Common.address shippingAddress = GARP_Common.parseMultiAddressLine(opp.Shipping_Street__c);
        shippingAddress.city = opp.Shipping_City__c;
        shippingAddress.postalCode = opp.Shipping_Postal_Code__c;
        shippingAddress.phone = opp.Shipping_Phone_No__c;
        shippingAddress.country = opp.Shipping_Country__c;
        shippingAddress.province = opp.Shipping_State__c;
        shippingAddress.validaddress = isValidaddress;
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','shippingAddress',shippingAddress);        

        GARP_Common.address billingAddress = GARP_Common.parseMultiAddressLine(opp.Billing_Address__c);
        billingAddress.city = opp.Billing_City__c;
        billingAddress.postalCode = opp.Billing_Zip_Postal__c;
        billingAddress.phone = opp.Billing_Phone__c;
        billingAddress.country = opp.Billing_Country__c;
        billingAddress.province = opp.Billing_State_Text__c;
        billingAddress.validaddress = isValidaddress;
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','billingAddress',billingAddress);        
        
        String garpId;
        String name;
        String stripeCustomerId;
        respCustomer respCustomer;
        
        Id userId = UserInfo.getUserId();
        List<User> users = [SELECT Id, Email, ContactId, Contact.Email, Contact.FirstName, Contact.LastName, Contact.GARP_Member_ID__c, Contact.Stripe_Customer_ID__c, AccountId, Profile.Name FROM User WHERE Id = :userId];
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','get logged in user', users);
        User user;
        
        if(!users.isEmpty() && users[0].Profile.Name == 'Customer Community') {
            user = users[0];
            if(user.Contact.GARP_Member_ID__c != NULL) {
                garpId = user.Contact.GARP_Member_ID__c;  
            }
            if(user.Contact.Stripe_Customer_ID__c != NULL) {
                stripeCustomerId = user.Contact.Stripe_Customer_ID__c;
            }
            name = user.Contact.FirstName + ' ' + user.Contact.LastName;
        } else {
            name = userName;
        }
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','garpId', garpId);
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','stripeCustomerId', stripeCustomerId);
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','name', name);
 
        returnGetStripeCustomer retGetStripeCustomer = getStripeCustomer(stripeCustomerId, name, garpId, email, billingAddress, shippingAddress);
        GARP_Common.debugLog('GARP_StripeClass','initializeCheckoutSession','retGetStripeCustomer', retGetStripeCustomer);
        
        if(retGetStripeCustomer.status != 'Success') {
            ret.status = 'Failure';
            ret.message = retGetStripeCustomer.message;
            return ret;    
        }
        
        return initializeStripeCheckoutSession(orderNumber, orderName, amount, email, retGetStripeCustomer.stripeCustomerId, garpId, isMembershipAutoRenew, opp);
    }
    
    public class returnGetCustomer {
        public String status;
        public String message;
        public String stripeCustomerId;
        public String defaultPaymentMethodId;
        public Boolean stripeIDExistsOnContact;
    }
    
    public static returnGetCustomer getCustomerPaymentInfo(Contact contact, GARP_Common.address billingAddress, GARP_Common.address shippingAddress) {
        GARP_Common.debugLog('GARP_StripeClass','getCustomerPaymentInfo','contact', contact);
        
        returnGetCustomer ret = new returnGetCustomer();
        ret.stripeIDExistsOnContact = False;
        
        String garpId = contact.GARP_Member_ID__c;
        String email = contact.Email;
        String name = contact.FirstName + ' ' + contact.LastName;
        
        returnGetStripeCustomer retGetStripeCustomer = getStripeCustomer(contact.Stripe_Customer_ID__c, name, garpId, email, billingAddress, shippingAddress);
        if(retGetStripeCustomer.status != 'Success') {
            ret.status = 'Failure';
            ret.message = retGetStripeCustomer.message;
            return ret;    
        }
        
        ret.stripeIDExistsOnContact = False;
        if(retGetStripeCustomer.stripeCustomerId != NULL) {
            ret.stripeIDExistsOnContact = True;
            ret.stripeCustomerId = retGetStripeCustomer.stripeCustomerId;    
        }
        
        GARP_Common.debugLog('GARP_StripeClass','getCustomerPaymentInfo','final',ret);
        return ret;
    }
    
    public static returnInitializeStripeCheckoutSession initializeEnableAutoRenewSession() {
        returnInitializeStripeCheckoutSession ret = new returnInitializeStripeCheckoutSession();
        
        Id userId = UserInfo.getUserId();
        List<User> users = [SELECT Id, ContactId, Contact.Email, Contact.FirstName, Contact.GARP_Member_ID__c, Contact.Stripe_Customer_ID__c, AccountId, Profile.Name,
                            Contact.Account.Billing_Address_Company__c, Contact.Account.BillingCity, Contact.Account.BillingState, Contact.Account.BillingPostalCode, 
                            Contact.Account.BillingCountry, Contact.HomePhone, Contact.Account.BillingStreet
                            FROM User WHERE Id = :userId];
        GARP_Common.debugLog('GARP_StripeClass','initializeEnableAutoRenewSession','get logged in user', users);
        
        User user;
        
        if(!users.isEmpty() && users[0].Profile.Name == 'Customer Community') {
            user = users[0];
        } else {
            ret.status = 'Failure';
            ret.message = 'Must be a logged in user';
            return ret;  
        }
        GARP_Common.debugLog('GARP_StripeClass','initializeEnableAutoRenewSession','user', user);
        
        if(user.Contact.Stripe_Customer_ID__c != NULL) {
            return initializeStripeEnableAutoRenewCheckoutSession(user.Contact.Stripe_Customer_ID__c, user.Contact.GARP_Member_ID__c);
        } else {
            ret.status = 'Contact Stripe_Customer_ID__c required';
            ret.message = 'Must be a logged in user';
            return ret;
        }
    }
        
    public class respSearchCustomer {
        String objectSTR;
        List<respCustomer> data;
    }
        
    public class retSearchCustomer {
        public respCustomer customer;
        public String status;
        public String message;    
    }
    
    public static retSearchCustomer findCustomer(String email, String garpId, GARP_StripeSettings__c stripeSetting) {
        
        GARP_Common.debugLog('GARP_StripeClass','findCustomer','email',email);
        GARP_Common.debugLog('GARP_StripeClass','findCustomer','garpId',garpId);        

        retSearchCustomer ret = new retSearchCustomer();
        
        if(email == NULL || stripeSetting == NULL) {
            ret.status = 'Failure';
            ret.message = 'Required params missing';            
            return ret;
        }
        
        String endpoint = 'https://api.stripe.com/v1/customers/search';
        GARP_Common.debugLog('GARP_StripeClass','findCustomer','endpoint',endpoint);
        
        String query;
        if(garpId != NULL) {
            query = 'metadata["garpId"]:\'' + garpId + '\'';
            endpoint += '?query=' + EncodingUtil.urlEncode(query, 'UTF-8');
        } else if(email != NULL) {
            endpoint = 'https://api.stripe.com/v1/customers?email=' + EncodingUtil.urlEncode(email,'UTF-8');
        }        
        
        GARP_Common.debugLog('GARP_StripeClass','findCustomer','endpoint final',endpoint);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String apikey = stripeSetting.Server_Side_API_Key__c;
        request.setHeader('authorization', 'Bearer ' + apikey);
        
        
        //metadata[customerId]:\'' + customerId + '\' OR email:\'' + email + '\'';
        //request.setBody(payload);
        
        Http httpProtocol = new Http();
        HttpResponse response;
        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            response = new HttpResponse();
            statusCode = 200;
            respbody = '{"object":"search_result","data":[{"id":"cus_1234567890","object":"customer","email":"jane@example.com","name":"Jane Doe","phone":"+15555555555","metadata":{"userId":"12345","accountType":"premium"},"created":1693857890,"livemode":false,"balance":0,"currency":"usd","delinquent":false,"invoice_prefix":"ABCD1234","invoice_settings":{"custom_fields":null,"default_payment_method":"pm_123abc","footer":null,"rendering_options":null},"shipping":null}],"has_more":false,"url":"/v1/customers/search"}';
        }
        GARP_Common.debugLog('GARP_StripeClass','findCustomer','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeClass','findCustomer','respbody',respbody);
        
        if(statusCode == 200) {        
            
            respbody = respbody.replace('object','objectSTR');
            
            respSearchCustomer resp = (respSearchCustomer)JSON.deserialize(respbody, respSearchCustomer.class);
            GARP_Common.debugLog('GARP_StripeClass','findCustomer','resp',resp);                    
            
            if(resp != NULL && resp.data != NULL && !resp.data.IsEmpty()) {
                ret.customer = resp.data[0];
                ret.status = 'Success';
                ret.message = 'Stripe data returned';
            } else {
                ret.status = 'Failure';
                ret.message = 'Respone was empty';
            }
        }
        
        return ret;
    }   
    
    public class returnSetCustomerDefaultPaymentMethod {
        public String status;
        public String message;
    }
    
    public static returnSetCustomerDefaultPaymentMethod setCustomerDefaultPaymentMethod(GARP_StripeSettings__c stripeSetting, String stripeCustomerId, String paymentMethodId) {
        
        GARP_Common.debugLog('GARP_StripeClass','setCustomerDefaultPaymentMethod','stripeSetting',stripeSetting);
        GARP_Common.debugLog('GARP_StripeClass','setCustomerDefaultPaymentMethod','stripeCustomerId',stripeCustomerId);
        GARP_Common.debugLog('GARP_StripeClass','setCustomerDefaultPaymentMethod','paymentMethodId',paymentMethodId);
        
        returnSetCustomerDefaultPaymentMethod ret = new returnSetCustomerDefaultPaymentMethod();
        
        if(stripeSetting == NULL) {
            ret.status = 'Failure';
            ret.message = 'Required params missing';            
            return ret;
        }
        
        String endpoint = 'https://api.stripe.com/v1/customers/' + stripeCustomerId;
        GARP_Common.debugLog('GARP_StripeClass','setCustomerDefaultPaymentMethod','endpoint',endpoint);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String apikey = stripeSetting.Server_Side_API_Key__c;
        request.setHeader('authorization', 'Bearer ' + apikey);
                
        String payload = 'invoice_settings[default_payment_method]='+paymentMethodId;
        request.setBody(payload);
        
        Http httpProtocol = new Http();
        HttpResponse response;
        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            response = new HttpResponse();
            statusCode = 200;
            respbody = '{"id":"cus_OycLmuN9yjQPCE","object":"customer","address":null,"balance":0,"created":1699562772,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"joe.bob@garpqa.com","invoice_prefix":"FA260BD9","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"joe bob","next_invoice_sequence":1,"phone":null,"preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}';
        }
        GARP_Common.debugLog('GARP_StripeClass','setCustomerDefaultPaymentMethod','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeClass','setCustomerDefaultPaymentMethod','respbody',respbody);
        
        if(statusCode == 200) {        
            respCustomer resp = (respCustomer)JSON.deserialize(respbody, respCustomer.class);
            GARP_Common.debugLog('GARP_StripeClass','setCustomerDefaultPaymentMethod','resp',resp);                    
            
            if(resp != NULL && resp.id != NULL) {
                ret.status = 'Success';
                ret.message = 'Stripe data returned';
            } else {
                ret.status = 'Failure';
                ret.message = 'Respone was empty';
            }
        }
        
        return ret;
    }
    
    
    public static retGetCustomer getCustomer(GARP_StripeSettings__c stripeSetting, String stripeCustomerId) {
        
        GARP_Common.debugLog('GARP_StripeClass','getCustomer','stripeSetting',stripeSetting);
        GARP_Common.debugLog('GARP_StripeClass','getCustomer','stripeCustomerId',stripeCustomerId);
        
        retGetCustomer ret = new retGetCustomer();
        
        if(stripeSetting == NULL || stripeCustomerId == NULL) {
            ret.status = 'Failure';
            ret.message = 'Required params missing';            
            return ret;
        }
        
        String endpoint = 'https://api.stripe.com/v1/customers/' + stripeCustomerId;
        GARP_Common.debugLog('GARP_StripeClass','getCustomer','endpoint',endpoint);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String apikey = stripeSetting.Server_Side_API_Key__c;
        request.setHeader('authorization', 'Bearer ' + apikey);
                
        Http httpProtocol = new Http();
        HttpResponse response;
        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            response = new HttpResponse();
            statusCode = 200;
            respbody = '{"id":"cus_OycLmuN9yjQPCE","object":"customer","address":null,"balance":0,"created":1699562772,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"joe.bob@garpqa.com","invoice_prefix":"FA260BD9","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"joe bob","next_invoice_sequence":1,"phone":null,"preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}';
        }
        GARP_Common.debugLog('GARP_StripeClass','getCustomer','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeClass','getCustomer','respbody',respbody);
        
        if(statusCode == 200) {        
            respCustomer resp = (respCustomer)JSON.deserialize(respbody, respCustomer.class);
            GARP_Common.debugLog('GARP_StripeClass','getCustomer','resp',resp);                    
            
            if(resp != NULL && resp.id != NULL) {
                ret.customer = resp;
                ret.status = 'Success';
                ret.message = 'Stripe data returned';
            } else {
                ret.status = 'Failure';
                ret.message = 'Respone was empty';
            }
        }
        
        return ret;
    }
    
    public static retSetupCustomer createCustomer(GARP_StripeSettings__c stripeSetting, String email, String name, String garpId, GARP_Common.address billingAddress, GARP_Common.address shippingAddress) {
        
        GARP_Common.debugLog('GARP_StripeClass','createCustomer','stripeSetting',stripeSetting);
        GARP_Common.debugLog('GARP_StripeClass','createCustomer','email',email);
        GARP_Common.debugLog('GARP_StripeClass','createCustomer','name',name);
        GARP_Common.debugLog('GARP_StripeClass','createCustomer','garpId',garpId);
        GARP_Common.debugLog('GARP_StripeClass','createCustomer','shippingAddress',shippingAddress);
        GARP_Common.debugLog('GARP_StripeClass','createCustomer','billingAddress',billingAddress);
        
        retSetupCustomer ret = new retSetupCustomer();
        
        if(stripeSetting == NULL) {
            ret.status = 'Failure';
            ret.message = 'Required params missing';            
            return ret;
        }
        
        String endpoint = 'https://api.stripe.com/v1/customers';
        GARP_Common.debugLog('GARP_StripeClass','createCustomer','endpoint',endpoint);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String apikey = stripeSetting.Server_Side_API_Key__c;
        request.setHeader('authorization', 'Bearer ' + apikey);
                
        String payload = 'name='+name + '&email=' + EncodingUtil.urlEncode(email,'UTF-8') + '&metadata[garpId]=' + garpId;
        
        if(shippingAddress != NULL && shippingAddress.street1 != NULL && shippingAddress.city != NULL && shippingAddress.country != NULL) {
            payload += '&shipping[name]=' + name;
            
            if(shippingAddress.phone != NULL) {
                payload += '&shipping[phone]=' + shippingAddress.phone;    
            }
            if(shippingAddress.validaddress == true){
                payload += '&shipping[address][postal_code]=' + '';  
                payload += '&shipping[address][state]=' + ''; 
                payload += '&shipping[address][city]=' + '';  
                payload += '&shipping[address][line2]=' + ''; 
                payload += '&shipping[address][line1]=' + ''; 
                payload += '&shipping[address][country]=' + '';
            }else{
                if(shippingAddress.street1 != NULL) {
                    payload += '&shipping[address][line1]=' + shippingAddress.street1;    
                }
                if(shippingAddress.street2 != NULL) {
                    payload += '&shipping[address][line2]=' + shippingAddress.street2;    
                }
                if(shippingAddress.city != NULL) {
                    payload += '&shipping[address][city]=' + shippingAddress.city;    
                }
                if(shippingAddress.province != NULL) {
                    payload += '&shipping[address][state]=' + shippingAddress.province;    
                }
                if(shippingAddress.postalCode != NULL) {
                    payload += '&shipping[address][postal_code]=' + shippingAddress.postalCode;    
                }
                if(shippingAddress.country != NULL) {
                    payload += '&shipping[address][country]=' + shippingAddress.country;    
                }
            }
        }
        
        if(billingAddress != NULL && billingAddress.street1 != NULL && billingAddress.city != NULL && billingAddress.country != NULL) {
            if(billingAddress.validaddress == true) {
                payload += '&address[postal_code]=' + '';  
                payload += '&address[state]=' + '';  
                payload += '&address[city]=' + '';  
                payload += '&address[line2]=' + '';  
                payload += '&address[line1]=' + '';
                payload += '&address[country]=' + '';
            }else{
                
                if(billingAddress.street1 != NULL) {
                    payload += '&address[line1]=' + billingAddress.street1;    
                }
                if(billingAddress.street2 != NULL) {
                    payload += '&address[line2]=' + billingAddress.street2;    
                }
                if(billingAddress.city != NULL) {
                    payload += '&address[city]=' + billingAddress.city;    
                }
                if(billingAddress.province != NULL) {
                    payload += '&address[state]=' + billingAddress.province;    
                }
                if(billingAddress.postalCode != NULL) {
                    payload += '&address[postal_code]=' + billingAddress.postalCode;    
                }
                if(billingAddress.country != NULL) {
                    payload += '&address[country]=' + billingAddress.country;    
                }
            }
        }
        
        GARP_Common.debugLog('GARP_StripeClass','createCustomer','payload',payload);        
        request.setBody(payload);
        
        Http httpProtocol = new Http();
        HttpResponse response;
        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            response = new HttpResponse();
            statusCode = 200;
            respbody = '{"id":"cus_OycLmuN9yjQPCE","object":"customer","address":null,"balance":0,"created":1699562772,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"joe.bob@garpqa.com","invoice_prefix":"FA260BD9","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"joe bob","next_invoice_sequence":1,"phone":null,"preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}';
        }
        GARP_Common.debugLog('GARP_StripeClass','createCustomer','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeClass','createCustomer','respbody',respbody);
        
        if(statusCode == 200) {        
            respCustomer resp = (respCustomer)JSON.deserialize(respbody, respCustomer.class);
            GARP_Common.debugLog('GARP_StripeClass','createCustomer','resp',resp);                    
            
            if(resp != NULL && resp.id != NULL) {
                ret.customerId = resp.id;
                ret.status = 'Success';
                ret.message = 'Stripe data returned';
            } else {
                ret.status = 'Failure';
                ret.message = 'Respone was empty';
            }
        }
        
        return ret;
    }
    
    public static retSetupCustomer updateCustomer(String contactId) {
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','contactId',contactId);
        
        retSetupCustomer ret = new retSetupCustomer();

        if(contactId == NULL) {
            ret.status = 'Failure';
            ret.message = 'Required params missing';            
            return ret;
        }
        
        GARP_StripeSettings__c stripeSetting = getStripeSettings();
        
        List<Contact> lstContact = [select id, FirstName, LastName, Email, GARP_Member_ID__c, Stripe_Customer_ID__c,
                                    MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                                    Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry
                                    FROM Contact where id = :contactId
                                   ];
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','lstContact',lstContact);
        
        if(!lstContact.IsEmpty()) {
            Contact cont;
            
            GARP_Common.address shippingAddress;
            GARP_Common.address billingAddress;
                
            if(cont.MailingStreet != NULL && cont.MailingCity != NULL && cont.MailingCountry != NULL) {
                shippingAddress = GARP_Common.parseMultiAddressLine(cont.MailingStreet);
                shippingAddress.city = cont.MailingCity;
                shippingAddress.postalCode = cont.MailingPostalCode;
                shippingAddress.country = cont.MailingCountry;
                shippingAddress.province = cont.MailingState;
            }
                
            if(cont.Account.BillingStreet != NULL && cont.Account.BillingCity != NULL && cont.Account.BillingCountry != NULL) {
                billingAddress = GARP_Common.parseMultiAddressLine(cont.Account.BillingStreet);
                billingAddress.city = cont.Account.BillingCity;
                billingAddress.postalCode = cont.Account.BillingPostalCode;
                billingAddress.country = cont.Account.BillingCountry;
                billingAddress.province = cont.Account.BillingState;
            }
            
            GARP_Common.debugLog('GARP_StripeClass','updateCustomer','shippingAddress',shippingAddress);
            GARP_Common.debugLog('GARP_StripeClass','updateCustomer','billingAddress',billingAddress);
            
            return updateCustomer(stripeSetting, cont.Stripe_Customer_ID__c, cont.FirstName + ' ' + cont.LastName, cont.Email, cont.GARP_Member_ID__c, NULL, billingAddress, shippingAddress);
        } else {
            ret.status = 'Failure';
            ret.message = 'Contact not found';            
            return ret;
        }
    }
    
    public static retSetupCustomer updateCustomer(GARP_StripeSettings__c stripeSetting, String customerId, String name, String email, String garpId, String paymentMethodId, GARP_Common.address billingAddress, GARP_Common.address shippingAddress) {
        
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','customerId',customerId);
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','name',name);
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','email',email);
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','garpId',garpId);
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','paymentMethodId',paymentMethodId);
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','billingAddress',billingAddress);
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','shippingAddress',shippingAddress);
        
        retSetupCustomer ret = new retSetupCustomer();
        
        if(customerId == NULL || name == NULL || email == NULL) {
            ret.status = 'Failure';
            ret.message = 'Required params missing';            
            return ret;
        }
        
        if(stripeSetting == NULL) {
            stripeSetting = getStripeSettings();
        }
        
        String endpoint = 'https://api.stripe.com/v1/customers/' + customerId;
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','endpoint',endpoint);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String apikey = stripeSetting.Server_Side_API_Key__c;
        request.setHeader('authorization', 'Bearer ' + apikey);
        
        String payload = 'name='+name + '&email=' + EncodingUtil.urlEncode(email,'UTF-8') + '&metadata[garpId]=' + garpId;
        
        if(shippingAddress != NULL && shippingAddress.street1 != NULL && shippingAddress.city != NULL && shippingAddress.country != NULL) {
            payload += '&shipping[name]=' + name;
            
            if(shippingAddress.phone != NULL) {
                payload += '&shipping[phone]=' + shippingAddress.phone;    
            }
            if(shippingAddress.validaddress == true){                
                payload += '&shipping[address][postal_code]=' + '';  
                payload += '&shipping[address][state]=' + ''; 
                payload += '&shipping[address][city]=' + '';  
                payload += '&shipping[address][line2]=' + ''; 
                payload += '&shipping[address][line1]=' + ''; 
                payload += '&shipping[address][country]=' + ''; 
                
            }else{
                if(shippingAddress.street1 != NULL) {
                    payload += '&shipping[address][line1]=' + shippingAddress.street1;    
                }
                if(shippingAddress.street2 != NULL) {
                    payload += '&shipping[address][line2]=' + shippingAddress.street2;    
                }
                if(shippingAddress.city != NULL) {
                    payload += '&shipping[address][city]=' + shippingAddress.city;    
                }
                if(shippingAddress.province != NULL) {
                    payload += '&shipping[address][state]=' + shippingAddress.province;    
                }
                if(shippingAddress.postalCode != NULL) {
                    payload += '&shipping[address][postal_code]=' + shippingAddress.postalCode;    
                } 
                if(shippingAddress.country != NULL) {
                    payload += '&shipping[address][country]=' + shippingAddress.country;    
                }  
            }
        }
        
        if(billingAddress != NULL && billingAddress.street1 != NULL && billingAddress.city != NULL && billingAddress.country != NULL) {
            if(billingAddress.validaddress == true) {
                payload += '&address[postal_code]=' + '';  
                payload += '&address[state]=' + '';  
                payload += '&address[city]=' + '';  
                payload += '&address[line2]=' + '';  
                payload += '&address[line1]=' + ''; 
                payload += '&address[country]=' + '';
            }else{
                if(billingAddress.street1 != NULL) {
                    payload += '&address[line1]=' + billingAddress.street1;    
                }
                if(billingAddress.street2 != NULL) {
                    payload += '&address[line2]=' + billingAddress.street2;    
                }
                if(billingAddress.city != NULL) {
                    payload += '&address[city]=' + billingAddress.city;    
                }
                if(billingAddress.province != NULL) {
                    payload += '&address[state]=' + billingAddress.province;    
                }
                if(billingAddress.postalCode != NULL) {
                    payload += '&address[postal_code]=' + billingAddress.postalCode;    
                }
                if(billingAddress.country != NULL) {
                    payload += '&address[country]=' + billingAddress.country;    
                }
            }
        }
        
        if(paymentMethodId != NULL) {
            payload += '&invoice_settings[default_payment_method]=' + paymentMethodId;
        }
        
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','payload',payload);
        request.setBody(payload);
        
        Http httpProtocol = new Http();
        HttpResponse response;
        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            response = new HttpResponse();
            statusCode = 200;
            respbody = '{"id":"cus_OycLmuN9yjQPCE","object":"customer","address":null,"balance":0,"created":1699562772,"currency":null,"default_currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"joe.bob@garpqa.com","invoice_prefix":"FA260BD9","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null,"rendering_options":null},"livemode":false,"metadata":{},"name":"joe bob","next_invoice_sequence":1,"phone":null,"preferred_locales":[],"shipping":null,"tax_exempt":"none","test_clock":null}';
        }
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeClass','updateCustomer','respbody',respbody);
        
        if(statusCode == 200) {        
            respCustomer resp = (respCustomer)JSON.deserialize(respbody, respCustomer.class);
            GARP_Common.debugLog('GARP_StripeClass','updateCustomer','resp',resp);                    
            
            if(resp != NULL && resp.id != NULL) {
                ret.customerId = resp.id;
                ret.status = 'Success';
                ret.message = 'Stripe data returned';
            } else {
                ret.status = 'Failure';
                ret.message = 'Respone was empty';
            }
        }else{
            ret.status = 'Failure';
            try{
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(respbody);            
                String errorMessage;            
                if (responseMap.containsKey('error')) {
                    Map<String, Object> errorMap = (Map<String, Object>) responseMap.get('error');
                    errorMessage = (String) errorMap.get('message');
                }  
                ret.message = errorMessage;
            }catch(Exception ex){ 
                ret.message = 'Stripe customer update failed';
            }
        }
        
        return ret;
    }    
  
    public class respGetCheckoutSessionLineItems {
        public List<retGetCheckoutTaxLineItemsData> data;
    }
    
    public class respGetCheckoutSession {
        String id;
        eventObjectMetaData metaData;
        public respGetCheckoutSessionLineItems line_items;
    }
    
    public class retGetCheckoutSession {
        public String status;
        public String message;   
        public eventObjectMetaData metaData;
        public List<retGetCheckoutTaxLineItemsData> lineItems;
    }
    
    public static retGetCheckoutSession getCheckoutSession(GARP_StripeSettings__c stripeSetting, String checkOutSessionId) {
        
        GARP_Common.debugLog('GARP_StripeClass','getCheckoutSession','checkOutSessionId',checkOutSessionId);
        
        retGetCheckoutSession ret = new retGetCheckoutSession();
        
        if(checkOutSessionId == NULL) {
            ret.status = 'Failure';
            ret.message = 'Required params missing';            
            return ret;
        }
        
        String endpoint = 'https://api.stripe.com/v1/checkout/sessions/' + checkOutSessionId + '?expand[]=line_items&expand[]=line_items.data.taxes';
        GARP_Common.debugLog('GARP_StripeClass','getTaxTransaction','endpoint',endpoint);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String apikey = stripeSetting.Server_Side_API_Key__c;
        request.setHeader('authorization', 'Bearer ' + apikey);
        
        Http httpProtocol = new Http();
        HttpResponse response;
        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            response = new HttpResponse();
            statusCode = 200;
            respbody = '{"data":[{"id":"123","metaData":{"orderid":"abc","formname":"form"}}]}';
        }
        GARP_Common.debugLog('GARP_StripeClass','getCheckoutSession','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeClass','getCheckoutSession','respbody',respbody);
        
        if(statusCode == 200) {        
            respGetCheckoutSession resp = (respGetCheckoutSession)JSON.deserialize(respbody, respGetCheckoutSession.class);
            GARP_Common.debugLog('GARP_StripeClass','getCheckoutSession','resp',resp);                    
            
            if(resp != NULL && resp.metaData != NULL) {
                ret.metaData = resp.metaData;
                ret.status = 'Success';
                ret.message = 'Stripe data returned';
                
                if(resp.line_items != NULL && resp.line_items.data != NULL && !resp.line_items.data.IsEmpty()) {
                    ret.lineItems = resp.line_items.data;
                }
            } else {
                ret.status = 'Failure';
                ret.message = 'Meta Data not found';
            }
        }
        
        GARP_Common.debugLog('GARP_StripeClass','getCheckoutSession','final ret',ret); 
        return ret;
    }
    
    public class respGetCheckoutTax {
        public String id;
        public Integer amount_total;
        public Integer tax_amount_exclusive;
        public List<retGetCheckoutTaxBreakdownInfo> tax_breakdown;
        public retGetCheckoutTaxLineItems line_items;
        public retGetCheckoutTaxLineItemsData shipping_cost;
    }
    
    public class retGetCheckoutTaxLineItems {
        List<retGetCheckoutTaxLineItemsData> data;
    }
    
    public class retGetCheckoutTaxLineItemsData {
        public String id;
        public Long amount;
        public Long amount_tax;
        public Long amount_subtotal;
        public String tax_code;
        public String reference;
        public String description;
        public List<retGetCheckoutTaxLineItemsTaxData> taxes;
    }
    
    public class retGetCheckoutTaxLineItemsTaxData {
        public Long amount;
        public retGetCheckoutTaxLineItemsTaxRateData rate;
    }

    public class retGetCheckoutTaxLineItemsTaxRateData {
        public String id;
        public String country;
        public String tax_type;
    }
    
    public class retGetCheckoutTaxBreakdownInfo {
        public Long amount;
        public Long taxable_amount;
        public String percentage_decimal;
        public retGetCheckoutTaxBreakdownInfoDetail tax_rate_details;
    }

    public class retGetCheckoutTaxBreakdownInfoDetail {
        public String country;
        public Decimal percentage_decimal;
        public String rate_type;
        public String tax_type;
        public String state;
    }    
    
    public class retGetCheckoutTax {
        public String status;
        public String message;
        public orderTaxInfo orderTaxInfo;
    }

    public class orderTaxInfo {
        public String country;
        public String state;
        public String taxType;
        public Long amount;
        public Long taxableAmount;
        public Decimal percentageDecimal;
        public String taxPrdId;
        public MAP<String, retGetCheckoutTaxLineItemsData> mapTaxLineItems;
        public List<retGetCheckoutTaxLineItemsData> lineItems;
        public List<OpportunityLineItem> updatedOppLineItems;
    }

    public static retGetCheckoutTax getCheckoutTax(String oppId, Opportunity opp) {
        GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','oppId','oppId');
        GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','opp','opp');
        
        retGetCheckoutTax ret = new retGetCheckoutTax();
        
        if(opp == NULL) {
            opp = GARP_BC_Orders.getOppAdjustOrder(oppId);
        }
        
        if(opp == NULL) {
            ret.status = 'Failure';
            ret.message = 'Order not found';
            GARP_Common.debugLog('GARP_BC_Orders','getCheckoutTax','Final ret',ret);
            return ret;
        }
        
        List<GARP_BC_Orders.productInfo> feeProducts = new List<GARP_BC_Orders.productInfo>();
        GARP_BC_Registration.addressInfo addressInfo = new GARP_BC_Registration.addressInfo();
        
        addressInfo.shippingAddress = GARP_Common.parseMultiAddressLine(opp.Shipping_Street__c);
        addressInfo.shippingAddress.city = opp.Shipping_City__c;
        addressInfo.shippingAddress.province = opp.Shipping_State__c;
        addressInfo.shippingAddress.postalCode = opp.Shipping_Postal_Code__c;
        
        MAP<String,Country_Code__c> mapCountries = GARP_Common.getCountriesMapByCountryName();
        
        Country_Code__c fndShipCountry = mapCountries.get(opp.Shipping_Country__c);
        if(fndShipCountry != NULL) {
            addressInfo.shippingAddress.country = fndShipCountry.LetterCode__c;
        } else {
            addressInfo.shippingAddress.country = opp.Shipping_Country__c;
        }
        GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','shippingAddress','addressInfo.shippingAddress');
        
        addressInfo.billingAddress = GARP_Common.parseMultiAddressLine(opp.Billing_Address__c);
        addressInfo.billingAddress.city = opp.Billing_City__c;
        addressInfo.billingAddress.province = opp.Billing_State_Text__c;
        addressInfo.billingAddress.postalCode = opp.Billing_Zip_Postal__c;
        Country_Code__c fndBillCountry = mapCountries.get(opp.Billing_Country__c);
        if(fndBillCountry != NULL) {
            addressInfo.billingAddress.country = fndBillCountry.LetterCode__c;
        } else {
            addressInfo.billingAddress.country = opp.Billing_Country__c;
        }
        GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','billingAddress','addressInfo.billingAddress');
        
        addressInfo.billingAndShippingSame = false;
        
        Set<String> taxCodes = new Set<String>{'SLSTX','IGSTTAX','GSTTAX'};
        Map<String,String> taxTypeMap = new Map<String,String>(); 
        taxTypeMap.put('sales_tax','SLSTX');
        taxTypeMap.put('igst','IGSTTAX');
        taxTypeMap.put('gst','GSTTAX'); 
        Map<String,String> taxProductMap = new Map<String,String>(); 
        for(OpportunityLineItem ol :opp.OpportunityLineItems){
            GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','Loop Line Items',ol + ':' + ol.Product2.ProductCode);
            
            if(taxCodes.Contains(ol.Product2.ProductCode)) {
                GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','Skip',ol);
                taxProductMap.put(ol.Product2.ProductCode,ol.Id);
                continue;
            }
            
            GARP_BC_Orders.productInfo prod = new GARP_BC_Orders.productInfo();
            
            prod.productCode = ol.Product2.ProductCode;
            prod.amount = ol.TotalPrice;
            prod.productName = ol.Product2.Name;
            
            if(ol.Product2.Stripe_Tax_Code__c == NULL) {
                ret.status = 'Failure';
                ret.message = 'Stripe Tax Code Missing for ' + ol.Product2.ProductCode;                   
                return ret;
            }
            
            prod.stripeTaxCode = ol.Product2.Stripe_Tax_Code__c;
            
            GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','add prod',prod);
            feeProducts.add(prod);
        }
        
        if(!feeProducts.IsEmpty()) {
            
            ret = sendGetCheckoutTax(feeProducts, addressInfo); 
            
            if(ret.message == 'Not enough Address Info') {
                GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','final ret',ret);
                return ret;
            }
            
            // Set Tax Product
            if(ret.orderTaxInfo != null && ret.orderTaxInfo.taxType != null){
                GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','taxType',ret.orderTaxInfo.taxType);
                
                if(taxTypeMap.containsKey(ret.orderTaxInfo.taxType)){
                    String taxkey = taxTypeMap.get(ret.orderTaxInfo.taxType);
                    ret.orderTaxInfo.taxPrdId = taxProductMap.containsKey(taxkey) ? taxProductMap.get(taxkey):null;
                }
                
                GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','taxPrdId',ret.orderTaxInfo.taxPrdId);
                
                // Set Updated Line Items
                ret.orderTaxInfo.updatedOppLineItems = new List<OpportunityLineItem>();
                
                for(OpportunityLineItem li :opp.OpportunityLineItems) {
                    GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','loop opp line items',li);
                    
                    // Reset Old Values
                    li.Stripe_Tax_Amount__c = NULL;
                    li.Stripe_Tax_Code__c = NULL;
                    
                    GARP_StripeClass.retGetCheckoutTaxLineItemsData fndLineItem = ret.orderTaxInfo.mapTaxLineItems.get(li.Product2.Name);
                    GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','fndLineItem',fndLineItem);
                    
                    if(fndLineItem != NULL && fndLineItem.amount_tax > 0) {
                        li.Stripe_Tax_Amount__c = ((Decimal)fndLineItem.amount_tax / 100).setScale(2);
                        li.Stripe_Tax_Code__c = li.Product2.Stripe_Tax_Code__c;
                        GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','updateLineItem',li);
                        ret.orderTaxInfo.updatedOppLineItems.add(li);
                    }
                }                
            }
            ret.status = 'Success';
            ret.message = 'Tax info returned';
            
        } else {
            ret.status = 'Failure';
            ret.message = 'No products';   
        }
        GARP_Common.debugLog('GARP_StripeClass','getCheckoutTax','final ret',ret);
        return ret;
    }
    
    public static Map<String,retGetCheckoutTax> getCheckoutListTax(List<Opportunity> oppList) {
        Map<String,retGetCheckoutTax> returnMap = new Map<String,retGetCheckoutTax>();
        Set<String> taxCodes = new Set<String>{'SLSTX','IGSTTAX','GSTTAX'};
        Map<String,String> taxTypeMap = new Map<String,String>(); 
        
        taxTypeMap.put('sales_tax','SLSTX');
        taxTypeMap.put('igst','IGSTTAX');
        taxTypeMap.put('gst','GSTTAX'); 
        
        for(Opportunity opp:oppList){ 
            List<GARP_BC_Orders.productInfo> feeProducts = new List<GARP_BC_Orders.productInfo>();
            GARP_BC_Registration.addressInfo addressInfo = new GARP_BC_Registration.addressInfo();
            
            addressInfo.shippingAddress = GARP_Common.parseMultiAddressLine(opp.Shipping_Street__c);
            addressInfo.shippingAddress.city = opp.Shipping_City__c;
            addressInfo.shippingAddress.province = opp.Shipping_State__c;
            addressInfo.shippingAddress.postalCode = opp.Shipping_Postal_Code__c;
            
            MAP<String,Country_Code__c> mapCountries = GARP_Common.getCountriesMapByCountryName();
            
            Country_Code__c fndShipCountry = mapCountries.get(opp.Shipping_Country__c);
            if(fndShipCountry != NULL) {
                addressInfo.shippingAddress.country = fndShipCountry.LetterCode__c;
            } else {
                addressInfo.shippingAddress.country = opp.Shipping_Country__c;
            }
            
            addressInfo.billingAddress = GARP_Common.parseMultiAddressLine(opp.Billing_Address__c);
            addressInfo.billingAddress.city = opp.Billing_City__c;
            addressInfo.billingAddress.province = opp.Billing_State_Text__c;
            addressInfo.billingAddress.postalCode = opp.Billing_Zip_Postal__c;
            Country_Code__c fndBillCountry = mapCountries.get(opp.Billing_Country__c);
            if(fndBillCountry != NULL) {
                addressInfo.billingAddress.country = fndBillCountry.LetterCode__c;
            } else {
                addressInfo.billingAddress.country = opp.Billing_Country__c;
            }
            
            addressInfo.billingAndShippingSame = false;
            
            Map<String,String> taxProductMap = new Map<String,String>(); 
            for(OpportunityLineItem ol :opp.OpportunityLineItems){
                GARP_Common.debugLog('GARP_StripeClass','getCheckoutListTax','Loop Line Items',ol + ':' + ol.Product2.ProductCode);
                
                if(taxCodes.Contains(ol.Product2.ProductCode)) {
                    GARP_Common.debugLog('GARP_StripeClass','getCheckoutListTax','Skip',ol);
                    taxProductMap.put(ol.Product2.ProductCode,ol.Id);
                    continue;
                }
                
                GARP_BC_Orders.productInfo prod = new GARP_BC_Orders.productInfo();
                
                prod.productCode = ol.Product2.ProductCode;
                prod.amount = ol.TotalPrice;
                prod.productName = ol.Product2.Name;
                prod.stripeTaxCode = ol.Product2.Stripe_Tax_Code__c;
                
                GARP_Common.debugLog('GARP_StripeClass','getCheckoutListTax','add prod',prod);
                feeProducts.add(prod);
            }
            retGetCheckoutTax rest = sendGetCheckoutTax(feeProducts, addressInfo);
            if(rest.orderTaxInfo != null && rest.orderTaxInfo.taxType != null){
                if(taxTypeMap.containsKey(rest.orderTaxInfo.taxType)){
                    String taxkey = taxTypeMap.get(rest.orderTaxInfo.taxType);
                    rest.orderTaxInfo.taxPrdId = taxProductMap.containsKey(taxkey) ? taxProductMap.get(taxkey):null;
                }
                
                // Set Updated Line Items
                rest.orderTaxInfo.updatedOppLineItems = new List<OpportunityLineItem>();
                
                for(OpportunityLineItem li :opp.OpportunityLineItems) {
                     
                    // Reset Old Values
                    li.Stripe_Tax_Amount__c = NULL;
                    li.Stripe_Tax_Code__c = NULL;
                    
                    GARP_StripeClass.retGetCheckoutTaxLineItemsData fndLineItem = rest.orderTaxInfo.mapTaxLineItems.get(li.Product2.Name);
                              
                    if(fndLineItem != NULL && fndLineItem.amount_tax > 0) {
                        li.Stripe_Tax_Amount__c = ((Decimal)fndLineItem.amount_tax / 100).setScale(2);
                        li.Stripe_Tax_Code__c = li.Product2.Stripe_Tax_Code__c;
                        rest.orderTaxInfo.updatedOppLineItems.add(li);
                    }
                }
            }
            returnMap.put(opp.Id,rest);
        }
        return returnMap;
    }
    
    public static retGetCheckoutTax sendGetCheckoutTax(List<GARP_BC_Orders.productInfo> feeProducts, GARP_BC_Registration.addressInfo addressInfo) {
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','feeProducts',feeProducts);  
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','addressInfo',addressInfo);  
        
        retGetCheckoutTax ret = new retGetCheckoutTax();
        ret.orderTaxInfo = new orderTaxInfo();
        
        Boolean bookDiscount = False;
        Boolean hasShipping = False;
        String shipProdName;
        for(GARP_BC_Orders.productInfo prod :feeProducts){
            
            if(prod.stripeTaxCode == NULL) {
                ret.status = 'Failure';
                ret.message = 'Stripe Tax Code Missing for ' + prod.productCode;       
                return ret;
            }
            
            if(prod.amount < 0) {
                bookDiscount = True;
            }
            if(prod.productCode == 'SHIP' || prod.productCode == 'SHIPRAI' || prod.productCode == 'SHIPRAIJ' || prod.productCode == 'SHIPSCR' || prod.productCode == 'SHIPFFR' || prod.productCode == 'SHIPFRR' || prod.productCode == 'SHIPFRM1' || prod.productCode == 'SHIPFRM2') {
                hasShipping = True;
                shipProdName = prod.productName;
            }
        }
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','bookDiscount',bookDiscount);
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','hasShipping',hasShipping);
        
        String payload = '';
        GARP_Common.address address = new GARP_Common.address();
        
        if(hasShipping) {
            payload += 'customer_details[address_source]=shipping';
            if(addressInfo.billingAndShippingSame) {
                address = addressInfo.billingAddress;    
            } else {
                address = addressInfo.shippingAddress;    
            }
            
        } else {
            payload += 'customer_details[address_source]=billing';
            address = addressInfo.billingAddress;            
        }
        
        payload += '&currency=usd';
        payload += '&expand[]=line_items';
        
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','address',address);
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','payload 1',payload);
        
        if(address.street1 != NULL && !String.IsEmpty(address.street1) && address.city != NULL && !String.IsEmpty(address.city) && address.country != NULL && !String.IsEmpty(address.country)) {
            payload += '&customer_details[address][line1]=' + EncodingUtil.urlEncode(address.street1, 'UTF-8');
            if(address.street2 != NULL) {
                payload += '&customer_details[address][line2]=' + EncodingUtil.urlEncode(address.street2, 'UTF-8');    
            }
            payload += '&customer_details[address][city]=' + EncodingUtil.urlEncode(address.city, 'UTF-8');
            
            if(address.province!= NULL) {
                payload += '&customer_details[address][state]=' + EncodingUtil.urlEncode(address.province, 'UTF-8');
            }
            if(address.postalCode!= NULL) {
                payload += '&customer_details[address][postal_code]=' + EncodingUtil.urlEncode(address.postalCode, 'UTF-8');
            }
    
            GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','address.country',address.country);
            MAP<String,Country_Code__c> mapCountries = GARP_Common.getCountriesMapByCountryName();        
            Country_Code__c fndCountry = mapCountries.get(address.country);
            GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','fndCountry',fndCountry);
            
            String countryTxt = address.country;
            if(fndCountry != NULL) {
                countryTxt = fndCountry.LetterCode__c;
            }
            GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','countryTxt',countryTxt);
            
            payload += '&customer_details[address][country]=' + EncodingUtil.urlEncode(countryTxt, 'UTF-8');
    
            GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','payload 2',payload);
        } else {
            // Not enough Address Info
            ret.status = 'Success';
            ret.message = 'Not enough Address Info';
            return ret;
        }
        
        Integer i=0;
        Set<String> shipCodes = new Set<String>{'SHIP','SHIPFRM1','SHIPFRM2','SHIPSCR','SHIPFFR','SHIPFRR','SHIPFRRS','SHIPMC','SHIPRAI','SHIPRAIJ'};
        Set<String> bookDiscountCodes = new Set<String>{'SCRCANDISC','RAICANDISC','RAIJCANDISC'};
        Set<String> hardBookCodes = new Set<String>{'SCRH','RAIH','RAIJH'};
        
        String shipTaxCode;
        Decimal shipAmount = 0;
        for(GARP_BC_Orders.productInfo prod :feeProducts){
            GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','Loop Fee Products',prod);
            
            if(prod.amount == 0) {
                continue;
            }
            
            if(bookDiscountCodes.Contains(prod.productCode)) {
                continue;
            }
            
            Decimal prodAmount = prod.amount;
            if(bookDiscount && hardBookCodes.Contains(prod.productCode)) {
                prodAmount = 100;
            }
            
            String strAmount = String.ValueOf(Integer.ValueOf(prodAmount * 100));
            
            String productName = prod.productName;
            productName = productName.replace(' (Complimentary)','');
            
            if(shipCodes.Contains(prod.productCode)) {
                shipAmount += prodAmount;
                shipTaxCode = prod.stripeTaxCode;
            } else {
                String prodPayload = '';                
                prodPayload += '&line_items[' + i + '][quantity]=1';
                prodPayload += '&line_items[' + i + '][amount]=' + strAmount;
                prodPayload += '&line_items[' + i + '][tax_behavior]=exclusive';
                prodPayload += '&line_items[' + i + '][reference]=' +
                    EncodingUtil.urlEncode(productName, 'UTF-8');
                prodPayload += '&line_items[' + i + '][tax_code]=' +
                    EncodingUtil.urlEncode(prod.stripeTaxCode, 'UTF-8');
                
                GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','Product Payload',prodPayload);
                payload += prodPayload;
                i++;
            }
        }
        
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','shipAmount',shipAmount);
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','shipTaxCode',shipTaxCode);
        
        if(shipAmount > 0) {
            String shipPayload = '';
            String strAmount = String.ValueOf(Integer.ValueOf(shipAmount * 100));
            shipPayload += '&shipping_cost[amount]=' + strAmount;                
            shipPayload += '&shipping_cost[tax_behavior]=exclusive';
            shipPayload += '&shipping_cost[tax_code]=' +
                EncodingUtil.urlEncode(shipTaxCode, 'UTF-8');
            GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','shipPayload',shipPayload);
            payload += shipPayload;
        }
        
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','Final Payload',payload);
        
        GARP_StripeSettings__c stripeSetting = GARP_StripeClass.getStripeSettings();
    
        String endpoint = 'https://api.stripe.com/v1/tax/calculations';
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','endpoint',endpoint);
                
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String apikey = stripeSetting.Server_Side_API_Key__c;
        request.setHeader('authorization', 'Bearer ' + apikey);
        
        //GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','apikey',apikey);  
      
        request.setBody(payload);

        Http httpProtocol = new Http();
        HttpResponse response;
        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            response = new HttpResponse();
            statusCode = 200;
            respbody = '{"id":"pi_3OAfA6AyydB05IeX3YYtgyoI","object":"payment_intent","amount":100,"amount_capturable":0,"amount_details":{"tip":{}},"amount_received":0,"application":null,"application_fee_amount":null,"automatic_payment_methods":null,"canceled_at":null,"cancellation_reason":null,"capture_method":"automatic","charges":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/charges?payment_intent=pi_3OAfA6AyydB05IeX3YYtgyoI"},"client_secret":"pi_3OAfA6AyydB05IeX3YYtgyoI_secret_V18tncALPUAPqDu3Qyyl6wU98","confirmation_method":"automatic","created":1699562954,"currency":"usd","customer":null,"description":null,"invoice":null,"last_payment_error":null,"latest_charge":null,"livemode":false,"metadata":{"orderid":"1234567"},"next_action":null,"on_behalf_of":null,"payment_method":null,"payment_method_configuration_details":null,"payment_method_options":{"alipay":{},"wechat_pay":{"app_id":null,"client":null}},"payment_method_types":["alipay","wechat_pay"],"processing":null,"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":null,"statement_descriptor":null,"statement_descriptor_suffix":null,"status":"requires_payment_method","transfer_data":null,"transfer_group":null}';
        }
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','respbody',respbody);
        
        if(statusCode == 200) {    
            respGetCheckoutTax resp = (respGetCheckoutTax)JSON.deserialize(respbody, respGetCheckoutTax.class);
            GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','resp',resp);

            // Find Details
            if(resp.tax_breakdown != NULL && !resp.tax_breakdown.IsEmpty()) {
                GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','tax_breakdown',resp.tax_breakdown);
                
                for(retGetCheckoutTaxBreakdownInfo tbd :resp.tax_breakdown) {
                    GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','loop tax breakdown',tbd);
                    if(tbd.amount > 0) {
                        ret.orderTaxInfo.amount = tbd.amount;
                        ret.orderTaxInfo.taxableAmount = tbd.taxable_amount;
                        if(tbd.tax_rate_details != NULL) {
                            ret.orderTaxInfo.taxType = tbd.tax_rate_details.tax_type;
                            ret.orderTaxInfo.country = tbd.tax_rate_details.country;
                            ret.orderTaxInfo.state = tbd.tax_rate_details.state;
                            ret.orderTaxInfo.percentageDecimal = tbd.tax_rate_details.percentage_decimal;
                        }
                        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','set tax values',ret);
                        break;
                    }
                }
            }
            
            if(resp.line_items != NULL && resp.line_items != NULL && resp.line_items.data != NULL && !resp.line_items.data.IsEmpty()) {
                GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','line_items',resp.line_items);
                ret.orderTaxInfo.lineItems = resp.line_items.data;
                
                if(resp.shipping_cost != NULL) {
                    resp.shipping_cost.reference = shipProdName;
                    GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','add shippping prod',resp.shipping_cost);
                    ret.orderTaxInfo.lineItems.add(resp.shipping_cost);
                }
            }
            
            ret.status = 'Success';
            ret.message = 'Checkout Stripe Tax Calculated';
        } else {
            ret.status = 'Failure';
            ret.message = 'Failed to Calculate Checkout Stripe Tax';
        }
        
        ret.orderTaxInfo.mapTaxLineItems = new MAP<String,GARP_StripeClass.retGetCheckoutTaxLineItemsData>();
        if(ret.orderTaxInfo.lineItems != NULL) {
            for(retGetCheckoutTaxLineItemsData tli :ret.orderTaxInfo.lineItems) {
                GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','Loop lineItems',tli);
                ret.orderTaxInfo.mapTaxLineItems.put(tli.reference,tli);
            }
        }
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','mapTaxLineItems',ret.orderTaxInfo.mapTaxLineItems);
       
        
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','final amount',ret.orderTaxInfo.amount);
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','final taxableAmount',ret.orderTaxInfo.taxableAmount);
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','final taxType',ret.orderTaxInfo.taxType);
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','final country',ret.orderTaxInfo.country);
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','final state',ret.orderTaxInfo.state);
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','final percentageDecimal',ret.orderTaxInfo.percentageDecimal);
        
        GARP_Common.debugLog('GARP_StripeClass','sendGetCheckoutTax','final ret',ret);
        return ret;
    }
   
    public class respGetTaxTrans {
        public List<respGetTaxTransData> data;
    }
    
    public class respGetTaxTransData {
        String id;
        String reference;
        String currencySTR;
        Long total_amount;
        Long total_tax_amount;
        List<respGetTaxTransDataLineItem> line_items;
    }
    
    public class respGetTaxTransDataLineItem {
        String id;
        Long amount;
        Long amount_tax;
        String tax_code;
        List<retGetCheckoutTaxBreakdownInfo> tax_breakdown;
    }
    
    public class returnGetTaxTransaction {
        public String status;
        public String message;
        public respGetTaxTrans resp;
    }
    
/*
    public static returnGetTaxTransaction getTaxTransaction(GARP_StripeSettings__c stripeSetting, String checkOutSessionId) {
        GARP_Common.debugLog('GARP_StripeClass','getTaxTransaction','checkOutSessionId', checkOutSessionId);
        
        returnGetTaxTransaction ret = new returnGetTaxTransaction();
        
        if(checkOutSessionId == NULL || String.IsEmpty(checkOutSessionId)) {
            ret.status = 'Failure';
            ret.message = 'Required params missing';            
            return ret;
        }
        
        String endpoint = 'https://api.stripe.com/v1/checkout/sessions/' + checkOutSessionId + '/line_items';
        GARP_Common.debugLog('GARP_StripeClass','getTaxTransaction','endpoint',endpoint);
              
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String apikey = stripeSetting.Server_Side_API_Key__c;
        request.setHeader('authorization', 'Bearer ' + apikey);
                
        Http httpProtocol = new Http();
        HttpResponse response;
        Integer statusCode;
        String respbody;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
            respbody = response.getBody();
        } else {
            response = new HttpResponse();
            statusCode = 200;
            respbody = '{"object":"search_result","data":[{"id":"cus_1234567890","object":"customer","email":"jane@example.com","name":"Jane Doe","phone":"+15555555555","metadata":{"userId":"12345","accountType":"premium"},"created":1693857890,"livemode":false,"balance":0,"currency":"usd","delinquent":false,"invoice_prefix":"ABCD1234","invoice_settings":{"custom_fields":null,"default_payment_method":"pm_123abc","footer":null,"rendering_options":null},"shipping":null}],"has_more":false,"url":"/v1/customers/search"}';
        }
        GARP_Common.debugLog('GARP_StripeClass','getTaxTransaction','statusCode',statusCode);
        GARP_Common.debugLog('GARP_StripeClass','getTaxTransaction','respbody',respbody);
        
        if(statusCode == 200) {        
            
            respbody = respbody.replace('currency','currencySTR');
            
            respGetTaxTrans resp = (respGetTaxTrans)JSON.deserialize(respbody, respGetTaxTrans.class);
            GARP_Common.debugLog('GARP_StripeClass','getTaxTransaction','resp',resp);                    
            
            if(resp != NULL && resp.data != NULL && !resp.data.IsEmpty()) {
                ret.resp = resp;
                ret.status = 'Success';
                ret.message = 'Stripe data returned';
            } else {
                ret.status = 'Failure';
                ret.message = 'Respone was empty';
            }
        }
        
        return ret;
    }
*/

    public static Boolean processWebhook(String rawJson) {
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','rawJson',rawJson); 
        
        Boolean ret = False;
        
        rawJson = rawJson.replace('object','objectSTR');
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','rawJson replace',rawJson);
        
        eventObject eo = (eventObject)JSON.deserialize(rawJson, eventObject.class);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','eo',eo);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','metadata',eo.data.objectSTR.metadata);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','charges',eo.data.objectSTR.charges);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','customer',eo.data.objectSTR.customer);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','description',eo.data.objectSTR.description);
        
        String paymentIntentId;
        String paymentMethodId;
        String orderType;
        String orderId;
        String orderDescription;
        String customerId;
        String formName;
        String checkOutSessionId;
        List<retGetCheckoutTaxLineItemsData> lineItems;
        String stripeEventId = (eo != NULL) ? eo.id : NULL;
        API_Transaction__c apitrans = new API_Transaction__c (
            Type__c = 'Stripe',
            Response_Body__c = GARP_Common.limitSize(rawJson, 32000),
            Description__c = 'webhook',
            StripeEventID__c = stripeEventId
        );
        if(stripeEventId != NULL) {
            List<API_Transaction__c> priorEvents = [SELECT Id
                                                    FROM API_Transaction__c
                                                    WHERE Type__c = 'Stripe'
                                                    AND Description__c = 'webhook'
                                                    AND StripeEventID__c = :stripeEventId
                                                    LIMIT 1];
            if(!priorEvents.IsEmpty()) {
                GARP_Common.debugLog('GARP_StripeClass','processWebhook','Duplicate event already processed - skipping',stripeEventId);
                return FALSE;
            }
        }
        if(eo != NULL && eo.type != NULL && eo.data != NULL && eo.data.objectSTR != NULL && eo.data.objectSTR.id != NULL) {
            paymentIntentId = eo.data.objectSTR.id;
            orderType = eo.type;
            orderDescription = eo.data.objectSTR.description;
            customerId = eo.data.objectSTR.customer;
            paymentMethodId = eo.data.objectSTR.payment_method;
        }
        
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','paymentIntentId',paymentIntentId);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','paymentMethodId',paymentMethodId);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','orderType',orderType);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','orderDescription',orderDescription);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','customerId',customerId);
        
        GARP_StripeSettings__c stripeSetting = getStripeSettings();
        
        // AliPay Logic
        if(eo.data.objectSTR.metadata != NULL && eo.data.objectSTR.metadata.orderid != NULL) {
            
            orderId = eo.data.objectSTR.metadata.orderid;
            formName = eo.data.objectSTR.metadata.formname;
            
        } else {
            // Adaptive Procing
            if(eo != NULL && eo.type != NULL && eo.data != NULL && eo.data.objectSTR != NULL && 
               eo.data.objectSTR.payment_details != NULL && eo.data.objectSTR.payment_details.order_reference != NULL) {
                   
                   checkOutSessionId = eo.data.objectSTR.payment_details.order_reference;
                   
                   // Fetch Checkout Session                   
                   retGetCheckoutSession retGetCheckoutSession = getCheckoutSession(stripeSetting, checkOutSessionId);
                   
                   if(retGetCheckoutSession.metaData != NULL && retGetCheckoutSession.metaData.orderid != NULL) {
                       orderId = retGetCheckoutSession.metaData.orderid;
                       formName = retGetCheckoutSession.metaData.formname;
                   }
                   
                   if(retGetCheckoutSession.lineItems != NULL) {
                       lineItems = retGetCheckoutSession.lineItems;
                   }
                   
               }
        }
        
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','orderType',orderType);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','orderId',orderId);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','orderDescription',orderDescription);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','customerId',customerId);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','formName',formName);
        
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','checkOutSessionId',checkOutSessionId);
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','lineItems',lineItems);
        
        // Setup Recurring
        if(orderType == 'setup_intent.succeeded') {
            
            GARP_Common.debugLog('GARP_StripeClass','processWebhook','Setup Auto-Renew?','');
            
            List<Contact> lstContact = [select id, AccountId, Email, Stripe_Customer_ID__c,
                                        MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry 
                                        FROM Contact where Stripe_Customer_ID__c = :customerId];
            GARP_Common.debugLog('GARP_BC_Membership','processWebhook','lstContact',lstContact);
            
            if(!lstContact.IsEmpty()) {
                Contact contact = lstContact[0];
                
                List<Account> lstAcct = [select id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                                         ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
                                         FROM Account where id = :contact.AccountId];
                GARP_Common.debugLog('GARP_BC_Membership','processWebhook','lstAcct',lstAcct);
                
                if(lstAcct != NULL) {
                    Account acct = lstAcct[0];
                    
                    List<Contract> lstContracts = [SELECT Id, AccountId, Status, Opportunity__c, RecordType.DeveloperName
                                                   FROM Contract
                                                   WHERE status in ('Activated','Activated ( Auto-Renew )','Completed') AND
                                                   AccountId = :contact.AccountId
                                                   ORDER BY recordType.DeveloperName, StartDate DESC];
                    GARP_Common.debugLog('GARP_BC_MemberPortal','processWebhook','lstContracts',lstContracts);
                    
                    Boolean isCertHolder = False;
                    Contract membershipContract;
                    if(!lstContracts.IsEmpty()) {
                        for(Contract c :lstContracts) {
                            if(c.RecordType.DeveloperName == 'Membership' && (c.Status == 'Activated' || c.Status == 'Activated ( Auto-Renew )')) {
                                membershipContract = c;
                            } else if((c.RecordType.DeveloperName == 'FRM_Program' || c.RecordType.DeveloperName == 'SCR_Program' || c.RecordType.DeveloperName == 'Risk_AI_Program')  && c.Status == 'Completed') {
                                isCertHolder = True;
                            }
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_Membership','processWebhook','membershipContract',membershipContract);
                    GARP_Common.debugLog('GARP_BC_Membership','processWebhook','isCertHolder',isCertHolder);
                    
                    if(membershipContract == NULL) {
                        // Membership Contract Not Found
                        GARP_Common.debugLog('GARP_BC_Membership','processWebhook','Error: Membership Contract Not Found',membershipContract);
                        apitrans.Response_Code__c = 'Error: Membership Contract Not Found';
                        insert apitrans;
                        return False;
                    } else {
                        
                        // Look for staged Opp
                        List<Opportunity> lstOpps = [select id, StageName 
                                                     from Opportunity 
                                                     where AccountId = :contact.AccountId AND Renew_Membership__c = True AND Auto_Renew__c = True AND Manual_Charge__c = True AND Eligible_for_Membership_Extension__c = False 
                                                     AND Stripe_Outbound_Type__c = 'Create' AND StageName = 'New Lead' AND Token__c = :customerId AND CreatedDate >= :System.now().addMinutes(-5)
                                                     Order By CreatedDate desc];
                        GARP_Common.debugLog('GARP_BC_Membership','processWebhook','lstOpps',lstOpps);
                        
                        if(!lstOpps.IsEmpty()) {
                            
                            apitrans.Opportunity__c = lstOpps[0].id;
                            
                            if(paymentMethodId != NULL) {
                                setCustomerDefaultPaymentMethod(stripeSetting, customerId, paymentMethodId);
                            } else {
                                // Error Payment Method Not Found
                                GARP_Common.debugLog('GARP_BC_Membership','processWebhook','Error: Payment Method Not Found',paymentMethodId);
                                
                                apitrans.Response_Code__c = 'Error: Payment Method Not Found';
                                insert apitrans;
                                
                                return False;
                            }
                            
                            Opportunity stagedOpp = lstOpps[0];
                            GARP_Common.debugLog('GARP_BC_Membership','processWebhook','found recent staged opp',stagedOpp);
                            
                            stagedOpp.StageName = 'Recurring Intent';
                            update stagedOpp;
                            GARP_Common.debugLog('GARP_BC_Membership','processWebhook','update staged opp',stagedOpp);
                            
                            apitrans.Response_Code__c = 'update staged opp Recurring Intent';
                            insert apitrans;                            
                            
                            return True;
                        } else {
                            // Error Staged Opp Not found
                            GARP_Common.debugLog('GARP_BC_Membership','processWebhook','Error: Staged Opp Not found','');

                            apitrans.Response_Code__c = 'Error: Staged Opp Not found';
                            insert apitrans;
                            
                            return false;
                        }
                    }
                }
            } else {
                // Error Contact not found
                GARP_Common.debugLog('GARP_BC_Membership','processWebhook','Error: Contact not found','');
                
                apitrans.Response_Code__c = 'Error: Contact not found';
                insert apitrans;
                
                return False;
            }
            
        } else if(orderId != NULL) {
            ret = True;
            
            // Process Order
            List<Opportunity> lstOpp = [select Id, StageName, AccountId, Amount, Billing_Email__c, Billing_State_Text__c, Billing_Country__c, B2B_Deal_Item__r.Access_Code__c, Email_Purchase_Complete__c, Order_Summary_CTA__c,
                                        (select id, ChargentOrders__Gateway__c, ChargentOrders__Subtotal__c, ChargentOrders__Charge_Amount__c, 
                                         ChargentOrders__Tokenization__c, ChargentOrders__Order_Information__c 
                                         from Chargent_Orders__r),
                                        (SELECT Id, Stripe_Tax_Code__c, Stripe_Tax_Amount__c, TotalPrice, Product2.Name, Product2.Stripe_Tax_Code__c FROM OpportunityLineItems)
                                        from Opportunity where Display_Invoice_Number__c = :orderId];
            GARP_Common.debugLog('GARP_StripeClass','processWebhook','lstOpp',lstOpp);
            
            List<ChargentOrders__Transaction__c> addTrans = new List<ChargentOrders__Transaction__c>();
            ChargentOrders__ChargentOrder__c chargentOrder;
            String payType;
            Boolean success = FALSE;
            
            Opportunity opp;
            if(!lstOpp.IsEmpty()) {
                opp = lstOpp[0];
                apitrans.Opportunity__c = opp.id;
            }
            
            Contact contact;
            Account account;
            GARP_Common.address shippingAddress = new GARP_Common.address();
            GARP_Common.address billingAddress = new GARP_Common.address();
            
            String taxCurreny; // Stripe_Tax_Currency
            Long total_amount; // Stripe_Tax_Total_Amount
            Long total_tax_amount; // Stripe_Tax_Total_Tax_Amount
            Long amount_tax; // Stripe_Tax_Amount_Tax
            String percentage_decimal; // Stripe_Tax_Percentage
            String rate_type; // Stripe_Tax_Rate
            String tax_type; // Stripe_Tax_Type
            String state; // Stripe_Tax_State
            orderTaxInfo orderTaxInfo = new orderTaxInfo();
            
            
            if(opp != NULL && orderType != 'payment_intent.payment_failed' && eo.data.objectSTR.charges != NULL && eo.data.objectSTR.charges.data.size() > 0) {
                success = TRUE;
                
                List<Contact> lstContacts = [select Id, AccountId, FirstName, LastName, Email, GARP_Member_ID__c , Stripe_Customer_ID__c , DO_NOT_FIRE__c from Contact where AccountId = :opp.AccountId];
                GARP_Common.debugLog('GARP_StripeClass','processWebhook','lstContacts',lstContacts);

                if(!lstContacts.IsEmpty()) {
                    contact = lstContacts[0];    
                    
                    List<Account> lstAcct = [select id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                                             ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
                                             FROM Account where id = :contact.AccountId];
                    GARP_Common.debugLog('GARP_BC_Membership','processWebhook','lstAcct',lstAcct);
                    
                    if(lstAcct != NULL) {
                        account = lstAcct[0];
                    }
                }
            }
            
            Integration_Log__c il;
            if(opp != NULL) {
                
                il = new Integration_Log__c(
                    New_Record__c = rawJson,
                    Integration_Type__c = 'Stripe',
                    Opportunity__c = opp.Id
                );
                
                if(opp.StageName == 'Closed') {
                    
                    apitrans.Response_Code__c = 'Error: Opp already closed';
                    insert apitrans;          
                    
                    return FALSE;
                }
                
                GARP_Common.debugLog('GARP_StripeClass','processWebhook','***Chargent_Orders__r',opp.Chargent_Orders__r);
                
                MAP<String,Country_Code__c> mapCC = GARP_Common.getCountriesMapByCountryCode();
                
                MAP<String,retGetCheckoutTaxLineItemsData> mapTaxLintItems = new MAP<String,retGetCheckoutTaxLineItemsData>();
                
                if(!opp.Chargent_Orders__r.IsEmpty()) {
                    chargentOrder = opp.Chargent_Orders__r[0];
                    
                    chargentOrder.ChargentOrders__Tokenization__c = customerId;
                    chargentOrder.ChargentOrders__Subtotal__c = opp.Amount;
                    chargentOrder.ChargentOrders__Charge_Amount__c = opp.Amount;
                    chargentOrder.ChargentOrders__Order_Information__c = orderDescription;
                    
                    if(orderType == 'payment_intent.payment_failed') {
                        
                        GARP_Common.debugLog('GARP_StripeClass','processWebhook','Payment Failed',orderType);
                        
                        eventErrorObject ero = (eventErrorObject)JSON.deserialize(rawJson, eventErrorObject.class);
                        GARP_Common.debugLog('GARP_StripeClass','processWebhook','eventObject Id',ero.data.objectSTR.id);
                        GARP_Common.debugLog('GARP_StripeClass','processWebhook','eventObject Type',ero.data.objectSTR.last_payment_error.payment_method.type);
                        GARP_Common.debugLog('GARP_StripeClass','processWebhook','eventObject error code',ero.data.objectSTR.last_payment_error.code);
                        
                        ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
                        trans.ChargentOrders__Gateway_Date__c = DateTime.Now();
                        trans.ChargentOrders__Gateway_ID__c = ero.data.objectSTR.id;
                        trans.ChargentOrders__Order__c = chargentOrder.Id;
                        trans.Opportunity__c = opp.Id;
                        trans.ChargentOrders__Type__c = 'Charge';
                        trans.ChargentOrders__Response_Status__c = 'Failure';
                        trans.ChargentOrders__Gateway__c = chargentOrder.ChargentOrders__Gateway__c;
                        trans.ChargentOrders__Reason_Code__c = 200;
                        trans.ChargentOrders__Response__c = ero.data.objectSTR.last_payment_error.code;
                        trans.ChargentOrders__Authorization__c = '';
                        // Seems that for Stripe it puts the Customer ID/Token in here
                        trans.ChargentOrders__Tokenization__c = customerId;
                        trans.ChargentOrders__Amount__c = opp.Amount;
                        trans.ChargentOrders__Amount_available_for_Refund__c = opp.Amount; 
                        trans.isStripePay__c = true;
                        if(ero.data.objectSTR.last_payment_error.payment_method.type == 'alipay') {
                            payType = 'Alipay';
                        } else if(ero.data.objectSTR.last_payment_error.payment_method.type == 'wechat_pay') {
                            payType = 'Wechatpay';   
                        } else {
                            payType = 'Credit Card';
                        }
                        trans.ChargentOrders__Payment_Method__c = payType;
                        
                        if(ero.data.objectSTR.last_payment_error.payment_method.card != NULL) {
                            if(ero.data.objectSTR.last_payment_error.payment_method.card.brand != NULL) {
                                trans.ChargentOrders__Credit_Card_Type__c = ero.data.objectSTR.last_payment_error.payment_method.card.brand;
                            }
                            
                            if(ero.data.objectSTR.last_payment_error.payment_method.card.last4 != NULL) {
                                trans.ChargentOrders__Card_Last_4__c = ero.data.objectSTR.last_payment_error.payment_method.card.last4;
                            }
                        }
                        
                        GARP_Common.debugLog('GARP_StripeClass','processWebhook','Add trans',trans);
                        
                        addTrans.add(trans);
                        
                    } else if(eo.data.objectSTR.charges != NULL && eo.data.objectSTR.charges.data.size() > 0) {
                        
                        success = TRUE;
                        
                        // Create Transactions
                        for(eventObjectChragesData cd :eo.data.objectSTR.charges.data) {
                            GARP_Common.debugLog('GARP_StripeClass','processWebhook','Loop charges',cd);
                            
                            if(cd.paid && !cd.refunded && cd.status == 'succeeded') {
                                ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
                                trans.ChargentOrders__Gateway_Date__c = DateTime.Now();
                                trans.ChargentOrders__Gateway_ID__c = cd.id;
                                trans.ChargentOrders__Order__c = chargentOrder.Id;
                                trans.Opportunity__c = opp.Id;
                                trans.ChargentOrders__Type__c = 'Charge';
                                trans.ChargentOrders__Response_Status__c = 'Approved';
                                trans.ChargentOrders__Response_Message__c = 'Approved';
                                trans.ChargentOrders__Gateway__c = chargentOrder.ChargentOrders__Gateway__c;
                                trans.ChargentOrders__Reason_Code__c = 200;
                                trans.ChargentOrders__Response__c = 'OK';
                                trans.ChargentOrders__Authorization__c = '';
                                trans.isStripePay__c = true;
                                // Seems that for Stripe it puts the Customer ID/Token in here
                                trans.ChargentOrders__Tokenization__c = customerId;                                
                                if(cd.amount != null){
                                    trans.ChargentOrders__Amount__c = ((Decimal)cd.amount / 100).setScale(2);
                                    trans.ChargentOrders__Amount_available_for_Refund__c = ((Decimal)cd.amount / 100).setScale(2);                                    
                                }else{
                                    trans.ChargentOrders__Amount__c = opp.Amount;
                                    trans.ChargentOrders__Amount_available_for_Refund__c = opp.Amount;
                                }                                
                                if(cd.payment_method_details.type == 'alipay') {
                                    payType = 'Alipay';
                                } else if(cd.payment_method_details.type == 'wechat_pay') {
                                    payType = 'Wechatpay';   
                                } else {
                                    payType = 'Credit Card';
                                }
                                trans.ChargentOrders__Payment_Method__c = payType;
                                
                                if(cd.payment_method_details.card != NULL) {
                                    if(cd.payment_method_details.card.brand != NULL) {
                                        trans.ChargentOrders__Credit_Card_Type__c = cd.payment_method_details.card.brand;
                                    }
                                    
                                    if(cd.payment_method_details.card.last4 != NULL) {
                                        trans.ChargentOrders__Card_Last_4__c = cd.payment_method_details.card.last4;
                                    }
                                }
                                
                                if(cd.presentment_details != NULL) {
                                    if(cd.presentment_details.presentment_amount != NULL) {
                                        trans.StripePresentmentAmount__c = cd.presentment_details.presentment_amount;
                                    }
                                    if(cd.presentment_details.presentment_currency != NULL) {
                                        trans.StripePresentmentCurrency__c = cd.presentment_details.presentment_currency;
                                    }
                                    
                                }
                                
                                if(cd.billing_details != NULL && cd.billing_details.address != NULL) {
                                    trans.ChargentOrders__Billing_Address__c = GARP_Common.limitSize(GARP_Common.formatAddressTextArea(cd.billing_details.address.line1, cd.billing_details.address.line2, null), 255);
                                    trans.ChargentOrders__Billing_City__c = GARP_Common.limitSize(cd.billing_details.address.city, 40);
                                    trans.ChargentOrders__Billing_Province__c = GARP_Common.limitSize(cd.billing_details.address.state, 80);
                                    trans.ChargentOrders__Billing_Postal_Code__c = GARP_Common.limitSize(cd.billing_details.address.postal_code, 20);
                                    trans.ChargentOrders__Billing_Country__c = GARP_Common.limitSize(GARP_Common.getMappedCountry(mapCC, cd.billing_details.address.country), 80);

                                    billingAddress.street1 = cd.billing_details.address.line1;
                                    billingAddress.street2 = cd.billing_details.address.line2;
                                    billingAddress.street3 = null;
                                    billingAddress.city = cd.billing_details.address.city;
                                    billingAddress.province = cd.billing_details.address.state;
                                    billingAddress.postalCode = cd.billing_details.address.postal_code;
                                    billingAddress.country = cd.billing_details.address.country;
                                    
                                }
                                
                                if(eo.data.objectSTR.shipping != NULL && eo.data.objectSTR.shipping.address != NULL) {
                                    trans.Shipping_Street__c = GARP_Common.limitSize(GARP_Common.formatAddressTextArea(eo.data.objectSTR.shipping.address.line1, eo.data.objectSTR.shipping.address.line2, null), 255);
                                    trans.Shipping_City__c = GARP_Common.limitSize(eo.data.objectSTR.shipping.address.city, 40);
                                    trans.Shipping_State__c = GARP_Common.limitSize(eo.data.objectSTR.shipping.address.state, 80);
                                    trans.Shipping_Postal_Code__c = GARP_Common.limitSize(eo.data.objectSTR.shipping.address.postal_code, 20);
                                    trans.Shipping_Country__c = GARP_Common.limitSize(GARP_Common.getMappedCountry(mapCC, eo.data.objectSTR.shipping.address.country), 80);
                                    
                                    shippingAddress.street1 = eo.data.objectSTR.shipping.address.line1;
                                    shippingAddress.street2 = eo.data.objectSTR.shipping.address.line2;
                                    shippingAddress.street3 = null;
                                    shippingAddress.city = eo.data.objectSTR.shipping.address.city;
                                    shippingAddress.province = eo.data.objectSTR.shipping.address.state;
                                    shippingAddress.postalCode = eo.data.objectSTR.shipping.address.postal_code;
                                    shippingAddress.country = eo.data.objectSTR.shipping.address.country;
                                }
                                
                                GARP_Common.debugLog('GARP_StripeClass','processWebhook','Add trans',trans);
                                
                                GARP_Common.debugLog('GARP_StripeClass','processWebhook','billingAddress',billingAddress);
                                GARP_Common.debugLog('GARP_StripeClass','processWebhook','shippingAddress',shippingAddress);
                                
                                addTrans.add(trans);
                            }
                        }   
                    }
                }
                
                // Get Tax Info
                if(lineItems != NULL && !lineItems.IsEmpty()) {
                    
                    orderTaxInfo.amount = 0;
                    orderTaxInfo.taxableAmount = 0;
                    orderTaxInfo.country = NULL;
                    orderTaxInfo.taxType = NULL;
                    
                    for(retGetCheckoutTaxLineItemsData tli :lineItems) {
                        GARP_Common.debugLog('GARP_StripeClass','processWebhook','loop tax line items',tli);
                        
                        mapTaxLintItems.put(tli.description,tli);
                        
                        if(tli.amount_tax > 0) {
                            orderTaxInfo.amount += tli.amount_tax;
                            orderTaxInfo.taxableAmount += tli.amount_subtotal;
                            
                            if(tli.taxes != NULL && !tli.taxes.IsEmpty()) {
                                orderTaxInfo.country = tli.taxes[0].rate.country;
                                orderTaxInfo.taxType = tli.taxes[0].rate.tax_type;
                            }
                        }
                    }
                    
                    /*
                    if(orderTaxInfo.amount > 0) {
                        if(shippingAddress.country == 'US' && shippingAddress.province == 'NJ') {
                            orderTaxInfo.country = 'US';
                            orderTaxInfo.taxType = 'sales_tax';
                        } else if(billingAddress.country == 'IN') {
                            orderTaxInfo.country = 'IN';
                            orderTaxInfo.taxType = 'igst';
                        } else if(billingAddress.country == 'SG') {
                            orderTaxInfo.country = 'SG';
                            orderTaxInfo.taxType = 'sgst';
                        }
                    }
					*/
                }
                GARP_Common.debugLog('GARP_StripeClass','processWebhook','orderTaxInfo',orderTaxInfo);
                
                // Update trans
                if(!addTrans.IsEmpty()) {
                    for(ChargentOrders__Transaction__c trans :addTrans) {
                        
                        if(orderTaxInfo.taxableAmount != NULL) {
                            trans.Stripe_Tax_Country__c = orderTaxInfo.country;
                            trans.Stripe_Tax_State__c = orderTaxInfo.state;
                            trans.Stripe_Tax_Taxable_Amount__c = ((Decimal)orderTaxInfo.taxableAmount / 100).setScale(2);
                            trans.Stripe_Tax_Type__c = orderTaxInfo.taxType;
                        }
                    }
                }
                GARP_Common.debugLog('GARP_StripeClass','processWebhook','updated addTrans',addTrans);
                
                List<OpportunityLineItem> updateLineItems = new List<OpportunityLineItem>();
                if(!opp.OpportunityLineItems.IsEmpty()) {
                    for(OpportunityLineItem li :opp.OpportunityLineItems) {
                        GARP_Common.debugLog('GARP_StripeClass','processWebhook','loop opp line items',li);
                        
                        retGetCheckoutTaxLineItemsData fndLineItem = mapTaxLintItems.get(li.Product2.Name);
                        GARP_Common.debugLog('GARP_StripeClass','processWebhook','fndLineItem',fndLineItem);
                        
                        if(fndLineItem != NULL && fndLineItem.amount_tax > 0) {
                            li.Stripe_Tax_Amount__c = ((Decimal)fndLineItem.amount_tax / 100).setScale(2);
                            li.Stripe_Tax_Code__c = li.Product2.Stripe_Tax_Code__c;
                            GARP_Common.debugLog('GARP_StripeClass','processWebhook','updateLineItem',li);
                            updateLineItems.add(li);
                        }
                    }
                }
                GARP_Common.debugLog('GARP_StripeClass','processWebhook','updateLineItems',updateLineItems);
                
                if(success) {   
                    // Update Stripe Customer Info
                    
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','stripeSetting',stripeSetting);
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','eo.data.objectSTR.customer',eo.data.objectSTR.customer);
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','contact.FirstName',contact.FirstName);
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','contact.LastName',contact.LastName);
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','contact.Email',contact.Email);
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','contact.GARP_Member_ID__c',contact.GARP_Member_ID__c);
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','paymentMethodId',paymentMethodId);
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','billingAddress',billingAddress);
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','shippingAddress',shippingAddress);
                     
                    
                    updateCustomer(stripeSetting, eo.data.objectSTR.customer, contact.FirstName + ' ' + contact.LastName, contact.Email, contact.GARP_Member_ID__c, paymentMethodId, billingAddress, shippingAddress);
                    
                    if(stripeEventId != NULL) {
                        apitrans.StripeEventID__c = stripeEventId;
                        try {
                            insert apitrans;
                        } catch(DmlException e) {}
                    }
                    if(shippingAddress.city != NULL && shippingAddress.country != NULL) {
                        contact.MailingStreet = GARP_Common.limitSize(GARP_Common.formatAddressTextArea(shippingAddress.street1, shippingAddress.street2, shippingAddress.street3), 255);
                        contact.MailingCity = GARP_Common.limitSize(shippingAddress.city, 40);
                        contact.MailingState = GARP_Common.limitSize(shippingAddress.province, 80);
                        contact.MailingPostalCode = GARP_Common.limitSize(shippingAddress.postalCode, 20);
                        contact.MailingCountry =  GARP_Common.limitSize(GARP_Common.getMappedCountry(mapCC, shippingAddress.country), 80);
                    } else {
                        contact.MailingStreet = GARP_Common.limitSize(GARP_Common.formatAddressTextArea(billingAddress.street1, billingAddress.street2, billingAddress.street3), 255);
                        contact.MailingCity = GARP_Common.limitSize(billingAddress.city, 40);
                        contact.MailingState = GARP_Common.limitSize(billingAddress.province, 80);
                        contact.MailingPostalCode = GARP_Common.limitSize(billingAddress.postalCode, 20);
                        contact.MailingCountry =  GARP_Common.limitSize(GARP_Common.getMappedCountry(mapCC, billingAddress.country), 80);
                    }
                    
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','update contact',contact);
                    update contact;

                    account.BillingStreet = GARP_Common.limitSize(GARP_Common.formatAddressTextArea(billingAddress.street1, billingAddress.street2, billingAddress.street3), 255);
                    account.BillingCity = GARP_Common.limitSize(billingAddress.city, 40);
                    account.BillingState = GARP_Common.limitSize(billingAddress.province, 80);
                    account.BillingPostalCode = GARP_Common.limitSize(billingAddress.postalCode, 20);
                    account.BillingCountry =  GARP_Common.limitSize(GARP_Common.getMappedCountry(mapCC, billingAddress.country), 80);
                    
                    if(shippingAddress.city != NULL && shippingAddress.country != NULL) {
                        account.ShippingStreet = GARP_Common.limitSize(GARP_Common.formatAddressTextArea(shippingAddress.street1, shippingAddress.street2, shippingAddress.street3), 255);
                        account.ShippingCity = GARP_Common.limitSize(shippingAddress.city, 40);
                        account.ShippingState = GARP_Common.limitSize(shippingAddress.province, 80);
                        account.ShippingPostalCode = GARP_Common.limitSize(shippingAddress.postalCode, 20);
                        account.ShippingCountry =  GARP_Common.limitSize(GARP_Common.getMappedCountry(mapCC, shippingAddress.country), 80);
                    } else {
                        account.ShippingStreet = GARP_Common.limitSize(GARP_Common.formatAddressTextArea(billingAddress.street1, billingAddress.street2, billingAddress.street3), 255);
                        account.ShippingCity = GARP_Common.limitSize(billingAddress.city, 40);
                        account.ShippingState = GARP_Common.limitSize(billingAddress.province, 80);
                        account.ShippingPostalCode = GARP_Common.limitSize(billingAddress.postalCode, 20);
                        account.ShippingCountry =  GARP_Common.limitSize(GARP_Common.getMappedCountry(mapCC, billingAddress.country), 80);                        
                    }
                    
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','update account',account);
                    update account;
                    
                }
                
                if(il != NULL) {
                    insert il;
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','insert log',rawJson);
                }
                
                if(!updateLineItems.IsEmpty()) {
                    update updateLineItems;
                }
                
                // Update Order with payment type
                if(chargentOrder != NULL && payType != NULL) {
                    chargentOrder.ChargentOrders__Payment_Method__c = payType;
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','update chargentOrder',chargentOrder);
                    update chargentOrder;
                }
                
                GARP_Common.debugLog('GARP_StripeClass','processWebhook','success',success);
                
                // Form Data
                if(success) {                    
                    
                    Form_Data__c returnFormData = GARP_BC_Registration.closeFormData(NULL, opp);
                    
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','Add Tax:',orderTaxInfo.country);
                    
                    // ===== Tax OpportunityLineItem — DYNAMIC via custom metadata =====
                    // The tax product code is now resolved from the country -> product-code
                    // JSON mapping on Stripe_Auth_Configuration__mdt.Stripe_Product_Code__c
                    // (parsed by StripeInvoicePreview.resolveProductCode), instead of the
                    // hardcoded US/IN/SG branches below. To onboard a new tax country, just add
                    // an entry to that metadata mapping — no code change needed.
                    /* --- legacy hardcoded logic (retained for reference) ---
                    if(orderTaxInfo.country == 'US') {
                        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE ProductCode = 'SLSTX' AND Product2.IsActive = TRUE AND Pricebook2.Name = 'GARP 2015/2016' LIMIT 1];
                        Decimal amount = Decimal.ValueOf(orderTaxInfo.amount);
                        amount = ((Decimal)amount / 100).setScale(2);
                        OpportunityLineItem taxLineItem = new OpportunityLineItem(
                            OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Product2Id = pbe.Product2Id,
                            UnitPrice = amount, Quantity = 1, Description = 'Sales Tax');
                        insert taxLineItem;
                    } else if(orderTaxInfo.country == 'IN') {
                        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE ProductCode = 'IGSTTAX' AND Product2.IsActive = TRUE AND Pricebook2.Name = 'GARP 2015/2016' LIMIT 1];
                        Decimal amount = Decimal.ValueOf(orderTaxInfo.amount);
                        amount = ((Decimal)amount / 100).setScale(2);
                        OpportunityLineItem taxLineItem = new OpportunityLineItem(
                            OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Product2Id = pbe.Product2Id,
                            UnitPrice = amount, Quantity = 1, Description = 'IGST');
                        insert taxLineItem;
                    } else if(orderTaxInfo.country == 'SG') {
                        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE ProductCode = 'GSTTAX' AND Product2.IsActive = TRUE AND Pricebook2.Name = 'GARP 2015/2016' LIMIT 1];
                        Decimal amount = Decimal.ValueOf(orderTaxInfo.amount);
                        amount = ((Decimal)amount / 100).setScale(2);
                        OpportunityLineItem taxLineItem = new OpportunityLineItem(
                            OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Product2Id = pbe.Product2Id,
                            UnitPrice = amount, Quantity = 1, Description = 'SGST');
                        insert taxLineItem;
                    }
                    --- end legacy hardcoded logic --- */

                    if(orderTaxInfo.amount != NULL && orderTaxInfo.country != NULL) {
                        // Country -> tax product-code mapping from custom metadata.
                        String taxMappingJson;
                        List<Stripe_Auth_Configuration__mdt> taxCfgs = [
                            SELECT Stripe_Product_Code__c FROM Stripe_Auth_Configuration__mdt LIMIT 1
                        ];
                        if(!taxCfgs.IsEmpty()) { taxMappingJson = taxCfgs[0].Stripe_Product_Code__c; }

                        String taxProductCode = StripeInvoicePreview.resolveProductCode(taxMappingJson, orderTaxInfo.country);
                        GARP_Common.debugLog('GARP_StripeClass','processWebhook','taxProductCode',taxProductCode);

                        if(String.isNotBlank(taxProductCode)) {
                            List<PricebookEntry> taxPbes = [
                                SELECT Id, Product2Id, Product2.Name
                                FROM PricebookEntry
                                WHERE ProductCode = :taxProductCode AND Product2.IsActive = TRUE AND Pricebook2.Name = 'GARP 2015/2016'
                                LIMIT 1
                            ];
                            GARP_Common.debugLog('GARP_StripeClass','processWebhook','taxPbes',taxPbes);

                            if(!taxPbes.IsEmpty()) {
                                PricebookEntry pbe = taxPbes[0];
                                Decimal amount = ((Decimal)Decimal.ValueOf(orderTaxInfo.amount) / 100).setScale(2);

                                OpportunityLineItem taxLineItem = new OpportunityLineItem(
                                    OpportunityId       = opp.Id,
                                    PricebookEntryId    = pbe.Id,
                                    Product2Id          = pbe.Product2Id,
                                    UnitPrice           = amount,
                                    Quantity            = 1,
                                    Description         = pbe.Product2.Name
                                );

                                GARP_Common.debugLog('GARP_StripeClass','processWebhook','taxLineItem',taxLineItem);
                                insert taxLineItem;
                            } else {
                                GARP_Common.debugLog('GARP_StripeClass','processWebhook','No PricebookEntry for tax code',taxProductCode);
                            }
                        }
                    }
                }

                // Insert Transactions
                if(!addTrans.IsEmpty()) {
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','insert addTrans',addTrans);
                    insert addTrans;
                }
                
                // If Payment is Successful
                GARP_Common.debugLog('GARP_StripeClass','processWebhook','success?',success);
                if(success) {
                    
                    if(contact != NULL) {
                                                
                        // Fire Member Profile Summary Update
                        List<Member_Profile_Update__e> events = new List<Member_Profile_Update__e>();
                        events.add(new Member_Profile_Update__e(
                            Contact_ID__c = contact.Id
                        ));     
                        eventbus.publish(events);
                        GARP_Common.debugLog('GARP_StripeClass','processWebhook','Fire event',events);
                        
                        // Fire community user 
                        contact.DO_NOT_FIRE__c = false;
                        
                        contact.Stripe_Customer_ID__c = eo.data.objectSTR.customer;
                        update contact;                        
                    }
                    
                    // Complete Registration Process
                    String existingEventRegistrationId;
                    String teamRegCode;
                    
                    List<Event_Registration__c> existingEventRegistrations = [SELECT Id FROM Event_Registration__c WHERE Opportunity__c = :opp.Id];
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','existingEventRegistrations', existingEventRegistrations); 
                    
                    if(!existingEventRegistrations.IsEmpty()) {
                        existingEventRegistrationId = existingEventRegistrations[0].Id;
                    }                   
                    if(opp.B2B_Deal_Item__r != NULL && opp.B2B_Deal_Item__r.Access_Code__c != NULL) {
                        teamRegCode = opp.B2B_Deal_Item__r.Access_Code__c;
                    }
                    
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','existingEventRegistrationId', existingEventRegistrationId); 
                    GARP_Common.debugLog('GARP_StripeClass','processWebhook','teamRegCode', teamRegCode); 
                    
                    if(existingEventRegistrationId != NULL || teamRegCode != NULL) {
                        GARP_BC_Registration.payOrderSuccessComplete(existingEventRegistrationId, teamRegCode);    
                    }
                    
                } else {
                    // Rollback
                    //GARP_BC_Registration.rollbackSetRegistration(NULL, opp.AccountId, opp.Billing_Email__c, opp.Id, 'Webhook failed transaction');
                }
                
                // Update Log
                if(il != NULL) {
                    il.Opportunity__c = opp.Id;
                    update il;
                }
            } else {
                il = new Integration_Log__c(
                    New_Record__c = rawJson,
                    Integration_Type__c = 'Stripe'
                );
                insert il;
                GARP_Common.debugLog('GARP_StripeClass','processWebhook','insert log',rawJson);
                
            }
        }

        apitrans.Response_Code__c = 'Completed';
        upsert apitrans;         
        
        return ret;
    }
    
}