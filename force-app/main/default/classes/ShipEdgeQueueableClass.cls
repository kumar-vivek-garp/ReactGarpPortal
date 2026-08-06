public class ShipEdgeQueueableClass implements Queueable, Database.AllowsCallouts {
    
    public Set<Id> oppIdSet ;
    public string callOutType;
    
    public ShipEdgeQueueableClass(Set<Id> oppIdSet,string callType){
        this.oppIdSet = oppIdSet ;
        this.callOutType = callType;
    }
    
    public void execute(QueueableContext context) {
        
        ShipEdgeResponseWrapper pingResponseWrapper = new ShipEdgeResponseWrapper();
        string response = ShipEdgeAPIClass.getShipEdgePing();
        if(response != 'Failed'){
            pingResponseWrapper = ShipEdgeResponseWrapper.parse(response);
            system.debug('Check here');
        }
        
        if(pingResponseWrapper != null && pingResponseWrapper.status == 'successful' && pingResponseWrapper.result == 'pong!'){
            
            if(callOutType == 'AddOrder'){
                ShipEdgeAddOrderResponseWrapper AddOrderResponseWrapper =  ShipEdgeAPIClass.getShipEdgeAddOrder(oppIdSet);
            }else if(callOutType == 'CancelOrder'){
                List<Opportunity> updateOpps = new List<Opportunity>();
                List<Integration_Log__c> insertLogs = new List<Integration_Log__c>();
                for(Id oppId : oppIdSet){
                    system.debug('Check here');
                    cancelWrapper cancelResponse = ShipEdgeAPIClass.cancelOrder(oppId);
                    updateOpps.add(cancelResponse.opp);
                    insertLogs.add(cancelResponse.log);
                }
                
                update updateOpps;
                
                insert insertLogs;
            }
        }else{
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(id oppId : oppIdSet){
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                if(callOutType == 'AddOrder'){
                    opp.Ups_Stage__c = 'Order Error';
                    opp.ShipEdge_Order_Error__c = 'Ping Unsuccessful For Add Order';
                }else if(callOutType == 'CancelOrder'){
                    opp.ShipEdge_Order_Error__c = 'Ping Unsuccessful For Cancel Order';
                }
                opp.Resend_Order_To_ShipEdge__c = false;
                updateOpps.add(opp);
            }
            if(!updateOpps.isEmpty()){
            	update updateOpps;
            }
        }
    }
    
    public class cancelWrapper{
        public Opportunity opp;
        public Integration_Log__c log;
    }
}