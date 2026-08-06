global class CheckContactsBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = '';
        if(test.isRunningTest()){
            query = 'Select Id,AccountId,KPI_CPE_Participation__c,KPI_CPE_Current_Cycle__c from Contact where KPI_CPE_Participation__c = true and KPI_CPE_Current_Cycle__c = null';
        } else {
            query = 'Select Id,AccountId,KPI_CPE_Participation__c,KPI_CPE_Current_Cycle__c from Contact where KPI_CPE_Participation__c = true and KPI_CPE_Current_Cycle__c = null';
        }
        return Database.getQueryLocator(query);
    }
    
     global void execute(Database.BatchableContext BC, List<Contact> scope)
    { 
        List<Contact_Update_Event__e> evtList = new List<Contact_Update_Event__e>();
        for(Contact con : scope){
            Contact_Update_Event__e evt = new Contact_Update_Event__e();
            evt.Record_Id__c = con.AccountId;
            evt.Update_type__c = 'Contract';
            evtList.add(evt);
        }
        
        Eventbus.publish(evtList);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
}