global class SageSyncReTryBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        if(test.isRunningTest()){
            query = 'SELECT Id,ia_crm__Intacct_Sync_Errors_1__c,Display_Invoice_Number__c,Payment_Method_New__c,GARP_Member_ID__c '+ 
                'FROM Opportunity LIMIT 2   ';
        } else {
            query = 'SELECT Id,ia_crm__Intacct_Sync_Errors_1__c,Display_Invoice_Number__c,Payment_Method_New__c,GARP_Member_ID__c '+ 
                'FROM Opportunity where ia_crm__Intacct_Sync_Status_1__c = \'Error\' LIMIT 15';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
       List<ia_crm.SyncOpportunityTransactionAction.SyncOpportunityTransactionRequest> recordIds = 
                new List<ia_crm.SyncOpportunityTransactionAction.SyncOpportunityTransactionRequest>();
        for(Opportunity oppData : scope){
            ia_crm.SyncOpportunityTransactionAction.SyncOpportunityTransactionRequest recordId = 
                new ia_crm.SyncOpportunityTransactionAction.SyncOpportunityTransactionRequest();
            recordId.recordId = oppData.Id;
            recordIds.add(recordId);
        }
        ia_crm.SyncOpportunityTransactionAction.syncOpportunityTransaction(recordIds);
    }
    global void finish(Database.BatchableContext BC){
        
    }
}