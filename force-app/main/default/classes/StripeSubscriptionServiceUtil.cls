public class StripeSubscriptionServiceUtil { 
    
    public class SubscriptionItem {
        public String priceId; 
        public String productPriceId; 
        public Integer quantity;
        public Decimal unitamount;
       
    }
    
    public class SubscriptionRequest {
        public String action;
        public String subscriptionId; // required for UPDATE or CANCEL
        public String customerId;     // required for CREATE
        public List<SubscriptionItem> items; // multiple prices + quantities
        public Map<String, String> metadata; // additional info
        public String accountId; //contact recordId 
        public String oppId; 
        public Long billingCycleAnchor;
        public String actionType;
        Public Boolean isAutotax;
    }
    
    public class SubscriptionResult {
        public String subscriptionId;
        public Boolean isSuccess;
        public String resBody;
        public String actionType; 
        public String oppId;
        public Integer statusCode;
        public Boolean isException;
        public String requestBody;
        public String accountId;
    }
    
    // -----------------------------
    // Class variable
    // -----------------------------
    private String stripeApiKey;
    private String endPointURL;
    // -----------------------------
    // Constructor
    // -----------------------------
    public StripeSubscriptionServiceUtil() {
        List<Stripe_Auth_Configuration__mdt> settings = [
            SELECT Api_Key__c,Endpoint__c 
            FROM Stripe_Auth_Configuration__mdt 
            LIMIT 1
        ];
        if (!settings.isEmpty() && settings[0].Api_Key__c != null) {
            this.stripeApiKey = settings[0].Api_Key__c;
             this.endPointURL = settings[0].Endpoint__c;
        } 
    }
    
    // -----------------------------
    // Public bulkified method
    // -----------------------------
    public List<SubscriptionResult> processSubscriptions(List<SubscriptionRequest> requests) {
        List<SubscriptionResult> results = new List<SubscriptionResult>();
        Http http = new Http();
        
        for (SubscriptionRequest req : requests) {
            SubscriptionResult res = new SubscriptionResult();
            res.actionType = req.actionType; 
            res.oppId = req.oppId;
            res.accountId = req.accountId;
            try {
                HttpRequest request = new HttpRequest();
                request.setHeader('Authorization', 'Bearer ' + stripeApiKey);
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                
                // Build endpoint and method based on action
                if (req.action == 'Create') {
                    request.setEndpoint(endPointURL);
                    request.setMethod('POST');
                    request.setBody(buildRequestBody(req));
                    
                } else if (req.action == 'Update') {
                    if (req.subscriptionId == null) throw new AuraHandledException('SubscriptionId required for UPDATE');
                    request.setEndpoint(endPointURL +'/'+ req.subscriptionId);
                    request.setMethod('POST');
                    request.setBody(buildRequestBody(req));
                    
                } else if (req.action == 'Cancel') {
                    if (req.subscriptionId == null) throw new AuraHandledException('SubscriptionId required for CANCEL');
                    request.setEndpoint(endPointURL +'/'+ req.subscriptionId);
                    request.setMethod('DELETE');
                }
                
                // Make callout
                HttpResponse response = http.send(request); 
                res.subscriptionId = req.subscriptionId;
                res.isSuccess = (response.getStatusCode() >= 200 && response.getStatusCode() < 300); 
                res.statusCode = response.getStatusCode();
				res.resBody = response.getBody();
                res.isException = false;
                res.requestBody = JSON.serialize(req);
                
            } catch (Exception ex) { 
                res.isSuccess = false;
                res.isException = true;
                res.resBody = ex.getMessage();
                res.requestBody = JSON.serialize(req);
            }
            
            results.add(res);
        }
        
        return results;
    }
    
    // -----------------------------
    // Private helper to build request body dynamically
    // -----------------------------
    private String buildRequestBody(SubscriptionRequest req) {
        List<String> params = new List<String>();
        
        // Customer for CREATE
        if (req.action == 'Create' && req.customerId != null) {
            params.add('customer=' + EncodingUtil.urlEncode(req.customerId, 'UTF-8'));
        }
        
        // Items (multiple prices and quantities)
        if (req.items != null) {
            for (Integer i = 0; i < req.items.size(); i++) {
                SubscriptionItem item = req.items[i];
                if (item.priceId != null)
                    params.add('items[' + i + '][id]=' + EncodingUtil.urlEncode(item.priceId, 'UTF-8'));
                if (item.productPriceId != null){
                    params.add('items[' + i + '][price_data][currency]=usd');
                    params.add('items[' + i + '][price_data][product]=' + EncodingUtil.urlEncode(item.productPriceId, 'UTF-8'));
                    params.add('items[' + i + '][price_data][unit_amount]=' + Math.round(item.unitamount * 100));
                    params.add('items[' + i + '][price_data][recurring][interval]=year');
                }
                if (item.quantity != null)
                    params.add('items[' + i + '][quantity]=' + item.quantity); 
            } 
        }
        
            if(req.billingCycleAnchor != null){
               // params.add('billing_cycle_anchor=' + String.valueOf(req.billingCycleAnchor));
                params.add('trial_end=' + String.valueOf(req.billingCycleAnchor));                
            }   
            if(req.isAutotax == true){
				params.add('automatic_tax[enabled]=true');            
            }
            params.add('proration_behavior=' + EncodingUtil.urlEncode('none', 'UTF-8'));
         
        
         
        // Metadata
        if (req.metadata != null) {
            for (String key : req.metadata.keySet()) {
                params.add('metadata[' + EncodingUtil.urlEncode(key, 'UTF-8') + ']=' +
                           EncodingUtil.urlEncode(req.metadata.get(key), 'UTF-8'));
            }
        }
        
        return String.join(params, '&');
    }
    
    public static Long dateToUnixTimestamp(Date d) {
        if (d == null) return null;
        DateTime dt = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
        return dt.getTime() / 1000;
    }
     
}