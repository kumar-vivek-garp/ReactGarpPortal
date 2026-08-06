@RestResource(urlMapping='/stripe/*')
global without sharing class GARP_Stripe_Webhook {

    public class eventObjectMetaData {
        public String orderid;
        public String formname;
    }

    public class eventObjectChragesDataPaymentMethodDetails {
        public String type;
    }
    
    public class eventObjectChragesData {
        public String id;
        public Long amount;
        public Boolean paid;
        public Boolean refunded;
        public String status;
        public eventObjectChragesDataPaymentMethodDetails payment_method_details;
    }    
    
    public class eventObjectCharges {
        public List<eventObjectChragesData> data;
    }
    
    public class eventObjectObject {
        public String id;
        public String customer;
        public String description;
        public eventObjectMetaData metadata;
        public eventObjectCharges charges;
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
    
    // Errors
    public class eventLastPaymentErrorPaymentMethod {
        String type;
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
    
    
    // AG TODO
    // Get Subscription 
    // -- if enabled flip amounts Membership = $195 / $150, Main Prod = $0
    // -- if no recurr, cancel subscription
    
    @HttpPost
    global static void handlePost(){
        
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        
        String rawJson ;
        
        rawJson = req.requestBody.toString();
        System.Debug('rawJson:' + rawJson);
        
        if(rawJson != NULL) {
            
            GARP_StripeClass.processWebhook(rawJson);
            
        }
    }
    
}