global class GBI_StudySubmissionReminderBatch implements Database.Batchable<SObject>, Database.Stateful {

    Public String studyAccountId; 
    Public String studyId; 
    
    global GBI_StudySubmissionReminderBatch(String studyAccountIdIn, String studyIdIn) {
        System.debug('studyAccountIdIn:' + studyAccountIdIn);
        System.debug('studyIdIn:' + studyIdIn);
        
        this.studyAccountId= studyAccountIdIn;   
        this.studyId = studyIdIn;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        String query = 'select id, Study__c, Study_Account__c, Data_Submission_Reminder_Sent_On__c, Data_Submission_End_Date__c';
              query += ' from Study_Contact__c where Study_Contact_Email__c != NULL AND Status__c != \'Suspended\' AND Study__r.Status__c = \'In Progress\'';
        	  query += ' AND (Study__r.End_Date__c = NULL OR Study__r.End_Date__c >= TODAY) AND (Study__r.Start_Date__c = NULL OR Study__r.Start_Date__c <= TODAY) AND Study__r.Disable_Study_Submission_Reminder__c = FALSE';
        	  query += ' AND Role__c INCLUDES (\'Data Manager\')';
        
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
        
        List<Study_Round__c> lstStudyRounds = [select Id, Study__c, Data_Collection_End_Date__c from Study_Round__c where Status__c = 'Data Collection' AND Data_Collection_Start_Date__c <= TODAY];
        System.debug('lstStudyRounds:' + lstStudyRounds);
        
        Set<String> studiesWithDataCollection = new Set<String>();
        MAP<String,Study_Round__c> mapStudiesWithDataCollection = new MAP<String,Study_Round__c>();
        for(Study_Round__c sr :lstStudyRounds) {
            studiesWithDataCollection.add(sr.Study__c);
            mapStudiesWithDataCollection.put(sr.Study__c, sr);
        }
        System.debug('studiesWithDataCollection:' + studiesWithDataCollection);
        System.debug('mapStudiesWithDataCollection:' + mapStudiesWithDataCollection);
        
        List<Study_Data_Submission__c> lstStudySubmissions = [select Id, Study_Account__c, Study_Round__c from Study_Data_Submission__c where Study_Account__c in :studyAccountIds];
        System.debug('lstStudySubmissions:' + lstStudySubmissions);
            
        Set<String> studiesAccountWithDataSubmissions = new Set<String>();
        for(Study_Data_Submission__c ss :lstStudySubmissions) {
            studiesAccountWithDataSubmissions.add(ss.Study_Account__c);
        }
        System.debug('studiesAccountWithDataSubmissions:' + studiesAccountWithDataSubmissions);

        DateTime now = DateTime.Now(); 
        
        List<Study_Contact__c> updateContacts = new List<Study_Contact__c>();
        for(Study_Contact__c sc :scope) {
            System.debug('Loop Study Contacts:' + sc);
            
            if(studiesWithDataCollection.Contains(sc.Study__c) && !studiesAccountWithDataSubmissions.Contains(sc.Study_Account__c)) {
                System.debug('Data Submission Missing:' + sc);
                
                Decimal diff = 0;
                if(sc.Data_Submission_Reminder_Sent_On__c != NULL) {
                    diff = (now.getTime() - sc.Data_Submission_Reminder_Sent_On__c.getTime()) / (1000 * 60 * 60);
                    System.debug('hours diff:' + diff);
                }
                
                if(sc.Data_Submission_Reminder_Sent_On__c == NULL || diff >= 48) {                    
                    sc.Data_Submission_Reminder_Sent_On__c = now;
                    
                    Study_Round__c fndStudyRound = mapStudiesWithDataCollection.get(sc.Study__c);
                    if(fndStudyRound != NULL) {
                    	sc.Data_Submission_End_Date__c = fndStudyRound.Data_Collection_End_Date__c;
                    }
                    
                    System.debug('Notify Study Contact:' + sc);
                    
                    updateContacts.add(sc);
                }
            }
        }
        if(!updateContacts.IsEmpty()) {
            update updateContacts;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){        
    }
    
}