global class deleteLeadRecordBatch implements database.batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String whereClause = System.Label.WhereClauseToDelete;
        String query = 'SELECT Id,(SELECT Id FROM Webcast_Registrations__r),(SELECT Id FROM Event_Registrations__r),(SELECT Id FROM Chapter_Meeting_Registrations__r) FROM Lead';
        system.debug('query::>>  '+query+' '+whereClause); 
        return Database.getQueryLocator(query+' '+whereClause);
    }
    global void execute(Database.BatchableContext BC, List<Lead> scope){
        system.debug(scope.size()+'   <<::scope::>>  '+scope);
        List<Lead> leadToDelete = new List<Lead>();
        for (Lead ld : scope) {
            Boolean isPresent = FALSE;
            if(!ld.Event_Registrations__r.isEmpty() || !ld.Chapter_Meeting_Registrations__r.isEmpty() || !ld.Webcast_Registrations__r.isEmpty()){
                isPresent = TRUE;
            }
            if(!isPresent){
                leadToDelete.add(ld);
            }
        }
        if(leadToDelete.size() > 0){
            system.debug(leadToDelete.size()+'  <<::leadToDelete::>>  '+leadToDelete);
            delete leadToDelete;
        }
    }
    global void finish(Database.BatchableContext BC){}
}