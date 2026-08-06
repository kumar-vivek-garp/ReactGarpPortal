global class CreateOppRecurringsBatch implements Database.Batchable<SObject>
{
   global Database.QueryLocator start(Database.BatchableContext BC){
        String strType = 'Charge';
        String strStatus = 'Approved';
        Boolean bRecurring = true; 
        boolean createopp = false;
     return Database.getQueryLocator([select id,ChargentOrders__Gateway__r.Name,ChargentOrders__Tokenization__c,ChargentOrders__Gateway_ID__c,ChargentOrders__Order__c,Created_New_Opportunity__c ,Opportunity__c,ChargentOrders__Response_Status__c,ChargentOrders__Type__c,ChargentOrders__Recurring__c,ChargentOrders__Gateway_Date__c from ChargentOrders__Transaction__c where ChargentOrders__Type__c =: strType and ChargentOrders__Response_Status__c =: strStatus and ChargentOrders__Recurring__c =: bRecurring and ChargentOrders__Gateway_Date__c != null and ChargentOrders__Gateway_Date__c = TODAY and Opportunity__c != null and Created_New_Opportunity__c=:createopp]);
    
     }
    
    
    global void execute(Database.BatchableContext BC, List<ChargentOrders__Transaction__c> scope){
        
        Set<Id> oppIds = new Set<Id>();
        Map<Id,ChargentOrders__Transaction__c> lstTrans = new Map<Id,ChargentOrders__Transaction__c>();
        for(ChargentOrders__Transaction__c trans : scope)
        {
                oppIds.add(trans.Opportunity__c);
                lstTrans.put(trans.Opportunity__c,trans);

        }

        if(!oppIds.isEmpty())
        {
            CreateRecurringOpps.CreateOpps(oppIds,lstTrans);

        }
        
    }
   
    global void finish(Database.BatchableContext BC){
         
       
    }

}