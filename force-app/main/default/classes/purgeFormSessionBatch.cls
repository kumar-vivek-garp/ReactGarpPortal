global class purgeFormSessionBatch implements Database.Batchable<sObject>, schedulable {
	global purgeFormSessionBatch() {
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        if(test.isRunningTest()){
            query = 'SELECT Id FROM Form_Session__c LIMIT 1';
        } else {
            query = 'SELECT Id FROM Form_Session__c where Createddate < LAST_WEEK';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Form_Session__c> scope){
        if(!scope.isEmpty()){
            delete scope;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    global void execute(SchedulableContext SC) {
 		database.executebatch(new purgeFormSessionBatch());
    }
}