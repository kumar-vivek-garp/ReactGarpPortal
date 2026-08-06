global class RiskDotNetReTryBatchClass implements Database.Batchable<sObject>, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String statusCheck = '' ;
        String query = 'select id,Re_try__c from Contract '+
            'WHERE API_Transaction_Status__c = \'Failure\''+ 
            ' AND RecordtypeId = \'' + RecordTypeHelper.GetRecordTypeId('Contract', 'Risk.Net') +'\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Contract> records){
        for(Contract con : records) {  
            con.Re_try__c = true ;
        }
        update records;
    }    
    global void finish(Database.BatchableContext bc){
    }    
    global void execute (SchedulableContext sc){
        RiskDotNetReTryBatchClass rb = new RiskDotNetReTryBatchClass();
        database.executeBatch(rb);
    }
}