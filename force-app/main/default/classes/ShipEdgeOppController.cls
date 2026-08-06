public class ShipEdgeOppController {

    @AuraEnabled
    Public Static OrderResponse getShipEdgeGetOrderDetails(String OppId){
    	Opportunity opp = [Select Id,Has_books__c,Cancel_Books__c,UPS_Stage__c,Ship_Edge_Order_Id__c from Opportunity where Id =: oppId];
        OrderResponse resp = new OrderResponse();
        
        if(opp.Has_Books__c == true && String.isNotBlank(opp.Ship_Edge_Order_Id__c)){
            ShipEdgeGetOrderResponseWrapper details = new ShipEdgeGetOrderResponseWrapper();
            if(!test.isRunningTest()){
        		details = ShipEdgeAPIClass.getShipEdgeGetOrder(OppId);
            }
            if(details != null){
                resp.response = JSON.serialize(details);
                resp.showOrderDetails = true;
                resp.showError = false;
            }else{
                resp.message = 'Get Order Details Integrations Failed';
            	resp.showOrderDetails = false;
                resp.showError = true;
            }
        }else if(opp.Has_Books__c == true && String.isBlank(opp.Ship_Edge_Order_Id__c)){
            resp.message = 'Ship Edge Order Id not available on Invoice';
            resp.showOrderDetails = false;
            resp.showError = true;
        }else if(opp.Has_Books__c == false){
            resp.message = 'Invoice has no products to ship';
            resp.showOrderDetails = false;
            resp.showError = true;
        }
        return resp;
        
    }
    
    public class OrderResponse{
        @AuraEnabled
        public boolean showOrderDetails{get;set;}
        @AuraEnabled
        public boolean showError{get;set;}
        @AuraEnabled
        public string response{get;set;}
        @AuraEnabled
        public string message{get;set;}
    }
}