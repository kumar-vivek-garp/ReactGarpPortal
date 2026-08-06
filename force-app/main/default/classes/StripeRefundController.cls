public class StripeRefundController {
    @AuraEnabled
    public ChargentOrders__Transaction__c transactionObj;
    @AuraEnabled
    public Decimal approvedAmount;
    @AuraEnabled
    public Boolean isApprovedPayment;
    @AuraEnabled(cacheable=true)
    public static StripeRefundController getTransactionData(Id recordId) {
        StripeRefundController cls = new StripeRefundController();
        cls.transactionObj = new ChargentOrders__Transaction__c();
        cls.approvedAmount = 0;
        cls.isApprovedPayment = false;
        cls.transactionObj = [
            SELECT Id, ChargentOrders__Amount__c,ChargentOrders__Payment_Method__c,ChargentOrders__Tokenization__c,ChargentOrders__Order__c,ChargentOrders__Gateway_Date__c,ChargentOrders__Gateway_ID__c, Opportunity__c, Opportunity__r.Name,Opportunity__r.GARP_Member_ID__c,
            Opportunity__r.Amount
            FROM ChargentOrders__Transaction__c
            WHERE Id =:recordId
            LIMIT 1
        ];
        
        for(Product_Refunds__c pr:[Select Id,Refund_amount__c From Product_Refunds__c Where Opportunity__c =:cls.transactionObj.Opportunity__c and Status__c = 'Approved']){
            cls.approvedAmount = cls.approvedAmount + pr.Refund_amount__c;
            cls.isApprovedPayment = true;
        }
        return cls;
    }
    
    @AuraEnabled
    public static Map<String, String> processRefund(Id recordId,Decimal amount,ChargentOrders__Transaction__c transactionObj) { 
        Map<String, String> result = new Map<String, String>();
        try{
            Stripe_Auth_Configuration__mdt authconfig = getToken();
            Long amountInCents = (Long)(amount * 100);  
            String chargeId = transactionObj.ChargentOrders__Gateway_ID__c;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(authconfig.Refund_Endpoint__c);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + authconfig.Api_Key__c);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            List<String> bodyParts = new List<String>();
            bodyParts.add('charge=' + EncodingUtil.urlEncode(chargeId, 'UTF-8'));
            if (amountInCents != null) {
                bodyParts.add('amount=' + String.valueOf(amountInCents));
            }
            req.setBody(String.join(bodyParts, '&'));
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            system.debug(res.getBody());
            if (res.getStatusCode() == 200) {
                // Success 
                ChargentOrders__Transaction__c tr = new ChargentOrders__Transaction__c();
                tr.ChargentOrders__Order__c = transactionObj.ChargentOrders__Order__c;
                tr.Opportunity__c = transactionObj.Opportunity__c;
                tr.ChargentOrders__Tokenization__c = transactionObj.ChargentOrders__Tokenization__c;
                tr.ChargentOrders__Gateway_ID__c = transactionObj.ChargentOrders__Gateway_ID__c;
                tr.ChargentOrders__Payment_Method__c = transactionObj.ChargentOrders__Payment_Method__c;			
                tr.ChargentOrders__Gateway_Response__c = res.getBody();
                tr.ChargentOrders__Response_Message__c = 'Approved';
                tr.ChargentOrders__Response_Status__c = 'Approved'; 
                tr.ChargentOrders__Type__c = 'Refund'; 
                tr.ChargentOrders__Amount__c = amount*-1; 
                tr.ChargentOrders__Gateway_Date__c = system.now(); 
                insert tr;
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                result.put('status', 'success');
                result.put('refundId', (String) responseMap.get('id'));
                result.put('message', 'Refund processed successfully.'); 
            } else {
                // Error
                Map<String, Object> errorMap = new  Map<String, Object>();
                try {
                    errorMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    Map<String, Object> errDetail = (Map<String, Object>) errorMap.get('error');
                    result.put('status', 'error');
                    result.put('message', (String) errDetail.get('message'));
                } catch (Exception e) {
                    result.put('status', 'error');
                    result.put('message', 'Unknown error: ' + res.getBody());
                }
            }
        }catch(Exception ex){
            result.put('status', 'error');
            result.put('message', 'Exception : ' + ex.getLineNumber()+' '+ex.getMessage());
        }
        return result;
    }
    
    public static Stripe_Auth_Configuration__mdt getToken(){
        List<Stripe_Auth_Configuration__mdt> settings = [
            SELECT Api_Key__c,Refund_Endpoint__c,Endpoint__c 
            FROM Stripe_Auth_Configuration__mdt 
            LIMIT 1
        ];
        return settings[0];
    }
}