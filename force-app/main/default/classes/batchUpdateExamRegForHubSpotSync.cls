global class batchUpdateExamRegForHubSpotSync implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Exam_Group__c eg = [select id from Exam_Group__c where Active__c = True];
        String egid = eg.Id;
        
        Exam_Group__c screg = [select id from Exam_Group__c where SCR_Active__c = True];
        String scregid = screg.id;
        
        return Database.getQueryLocator('select id, name from Exam_attempt__c where (Exam_Site__r.Exam__r.Exam_Group__c = :egid OR Exam_Site__r.Exam__r.Exam_Group__c = :scregid OR Exam_Site__r.Exam__r.Exam_Group__r.Next_Exam_Group__c = :egid OR Exam_Site__r.Exam__r.Exam_Group__r.Next_Exam_Group__c = :scregid) AND LastModifiedDate < YESTERDAY');
     }
    
    
    global void execute(Database.BatchableContext BC, List<Exam_attempt__c> scope){
            
        update scope;
            
    }
        

    global void finish(Database.BatchableContext BC){
         
       
    }

}