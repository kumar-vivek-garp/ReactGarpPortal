global class BenchprepMembersAccessBatch implements Database.Batchable<sObject>, Database.Stateful {
	
    private List<String> recordId = new List<String>();
    private Id MembershipContractRTId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
    
    public BenchprepMembersAccessBatch(List<String> inputRecId){
        this.recordId = inputRecId;
    }
    
     global Database.QueryLocator start(Database.BatchableContext BC){
         string query;  
         List<String> statusList = new List<String>{'Activated ( Auto-Renew )','Activated'};
             query = 'Select Id,AccountId From Contract where RecordTypeId =:MembershipContractRTId and Membership_Type__c = \'Individual\' and Status In:statusList';
         if(!recordId.isEmpty()){
             query += ' AND AccountId In: recordId';
         }
         system.debug('in start'+recordId);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contract> scope){
		List<String> accoutIds = new List<String>();        
        for(Contract con:scope){
            accoutIds.add(con.AccountId);
        }
        BenchprepMembersAccess.updateMemberBenchprep(accoutIds,'MemberBenchprep');
    }
    global void finish(Database.BatchableContext BC){ 
    }

}