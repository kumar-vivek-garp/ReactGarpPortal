global class GBI_StudyVoteReminderBatch implements Database.Batchable<SObject>, Database.Stateful {

    Public String studyAccountId; 
    Public String studyId; 
    
    global GBI_StudyVoteReminderBatch(String studyAccountIdIn, String studyIdIn) {
        System.debug('studyAccountIdIn:' + studyAccountIdIn);
        System.debug('studyIdIn:' + studyIdIn);
        
        this.studyAccountId= studyAccountIdIn;   
        this.studyId = studyIdIn;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        String query = 'select id, Study__c, Study_Account__c, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c';
              query += ' from Study_Contact__c where Study_Contact_Email__c != NULL AND Status__c != \'Suspended\' AND Study__r.Status__c = \'In Progress\'';
			  query += ' AND (Study__r.End_Date__c = NULL OR Study__r.End_Date__c >= TODAY) AND (Study__r.Start_Date__c = NULL OR Study__r.Start_Date__c <= TODAY) AND Study__r.Disable_Study_Submission_Reminder__c = FALSE';
              query += ' AND Role__c INCLUDES (\'Voter\')';
              
        
        if(studyAccountId != NULL) {
            query += ' AND Study_Account__c = \'' + studyAccountId + '\'';
        } else if(studyId != NULL) {
            query += ' AND Study__c = \'' + studyId + '\'';
        }
        
        System.debug('query:' + query);
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<Study_Contact__c> scope){
        
        Set<String> studyIds = new Set<String>();
        Set<String> studyAccountIds = new Set<String>();
        for(Study_Contact__c sc :scope) {
            studyIds.add(sc.Study__c);
            studyAccountIds.add(sc.Study_Account__c);
        }
        System.debug('studyIds:' + studyIds);
        
        List<Study_Vote__c> lstStudyVotes = [select Id, Study__c, Start_Date__c, End_Date__c from Study_Vote__c where Status__c = 'Opened' AND Start_Date__c <= TODAY AND End_Date__c >= TODAY];
        System.debug('lstStudyVotes:' + lstStudyVotes);
        
        Set<String> studiesWithVotes = new Set<String>();
        Set<String> openStudyVotes = new Set<String>();
        MAP<String,Study_Vote__c> mapStudiesWithVotes = new MAP<String,Study_Vote__c>();
        for(Study_Vote__c sv :lstStudyVotes) {
            studiesWithVotes.add(sv.Study__c);
            mapStudiesWithVotes.put(sv.Study__c, sv);
            openStudyVotes.add(sv.id);
        }
        System.debug('studiesWithVotes:' + studiesWithVotes);
        System.debug('mapStudiesWithVotes:' + mapStudiesWithVotes);
        System.debug('openStudyVotes:' + openStudyVotes);
        
        List<Study_Contact_Vote__c> lstStudyContacVotes = [select Id, Study_Contact__r.Study_Account__c, Study_Vote_Question__r.Study_Vote__c from Study_Contact_Vote__c where Study_Contact__r.Study_Account__c in :studyAccountIds AND Study_Vote_Question__r.Study_Vote__c in :openStudyVotes];
        System.debug('lstStudyContacVotes:' + lstStudyContacVotes);
            
        Set<String> studiesAccountWithVoteSubmissions = new Set<String>();
        for(Study_Contact_Vote__c scv :lstStudyContacVotes) {
            studiesAccountWithVoteSubmissions.add(scv.Study_Contact__r.Study_Account__c);
        }
        System.debug('studiesAccountWithVoteSubmissions:' + studiesAccountWithVoteSubmissions);

        DateTime now = DateTime.Now(); 
        
        List<Study_Contact__c> updateContacts = new List<Study_Contact__c>();
        for(Study_Contact__c sc :scope) {
            System.debug('Loop Study Contacts:' + sc);
            
            if(studiesWithVotes.Contains(sc.Study__c) && !studiesAccountWithVoteSubmissions.Contains(sc.Study_Account__c)) {
                System.debug('Study Contact needs to votes:' + sc);
                
                sc.Study_Vote_Reminder_Sent_On__c = now;
                
                Study_Vote__c fndStudyVote = mapStudiesWithVotes.get(sc.Study__c);
                if(fndStudyVote != NULL) {
                    sc.Vote_End_Date__c = fndStudyVote.End_Date__c;
                }
                
                System.debug('Notify Study Contact:' + sc);
                
                updateContacts.add(sc);
            }
        }
        if(!updateContacts.IsEmpty()) {
            update updateContacts;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){        
    }
    
}