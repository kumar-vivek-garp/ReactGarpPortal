public class StripeBillingRecurringQueueable implements Queueable, Database.AllowsCallouts {
    
    public Set<Id> oppIds; 
    public Map<Id,ChargentOrders__Transaction__c> lstTrans;
    
    public StripeBillingRecurringQueueable(List<Id> transIds){
        oppIds = new Set<Id>();
        lstTrans = new Map<Id,ChargentOrders__Transaction__c>();
        for(ChargentOrders__Transaction__c trans:[select id,ChargentOrders__Gateway__r.Name,ChargentOrders__Tokenization__c,ChargentOrders__Gateway_ID__c,ChargentOrders__Order__c,Created_New_Opportunity__c ,Opportunity__c,ChargentOrders__Response_Status__c,ChargentOrders__Type__c,ChargentOrders__Recurring__c,ChargentOrders__Gateway_Date__c from ChargentOrders__Transaction__c where Id In:transIds]){
            oppIds.add(trans.Opportunity__c);
            lstTrans.put(trans.Opportunity__c,trans);
        } 
        
        
    }
    
    
    public void execute(QueueableContext context) { 
        
        if(!oppIds.isEmpty())
        {
            CreateRecurringOpps.CreateOpps(oppIds,lstTrans);
            
        }
    }
}