global class GBI_StudyDPSignReminderBatch implements Database.Batchable<SObject>, Database.Stateful {

    Public String studyAccountId; 
    Public String studyId; 
    
    global GBI_StudyDPSignReminderBatch(String studyAccountIn, String studyIdIn) {
        GARP_Common.debugLog('GBI_StudyDPSignReminderBatch','consrtuctor','studyAccountIn',studyAccountIn);
        GARP_Common.debugLog('GBI_StudyDPSignReminderBatch','consrtuctor','studyIdIn',studyIdIn);
        
        this.studyAccountId = studyAccountIn;   
        this.studyId = studyIdIn;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        String query = 'select id, Role__c, Study__c, Study_Account__c, DP_Sign_Reminder_Sent_On__c';
              query += ' from Study_Contact__c where Study_Contact_Email__c != NULL AND Status__c = \'Active\' AND Study__r.Status__c = \'In Progress\'';
        	  query += ' AND (Study__r.End_Date__c = NULL OR Study__r.End_Date__c <= TODAY) AND (Study__r.Start_Date__c = NULL OR Study__r.Start_Date__c <= TODAY) AND Study__r.Disable_DP_Sign_Reminder__c = FALSE';
              query += ' AND Role__c INCLUDES (\'Voter\')';
        
        if(studyAccountId != NULL) {
            query += ' AND Study_Account__c = \'' + studyAccountId + '\'';
        } else if(studyId != NULL) {
            query += ' AND Study__c = \'' + studyId + '\'';
        }
        
        GARP_Common.debugLog('GBI_StudyDPSignReminderBatch','start','query',query);
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<Study_Contact__c> scope){
        SET<String> studies = new SET<String>();
        
         for(Study_Contact__c sc :scope) {
            studies.add(sc.Study__c);
         }
        
        List<Study_Disclose_Protocol_Submission__c> lstDPSubmissions = [select Id, Study__c, Study_Account__c 
                                                                        from Study_Disclose_Protocol_Submission__c
                                                                        where Disclosure_Protocol__r.DP_Status__c = 'Active' AND Study__c in :studies];
        GARP_Common.debugLog('GBI_StudyDPSignReminderBatch','execute','lstDPSubmissions',lstDPSubmissions);
        
        
        SET<String> studyAccountsWithDPSubmission = new SET<String>();
        for(Study_Disclose_Protocol_Submission__c dps :lstDPSubmissions) {
            studyAccountsWithDPSubmission.add(dps.Study_Account__c);
        }
        
        DateTime now = DateTime.Now(); 
        
        List<Study_Contact__c> updateContacts = new List<Study_Contact__c>();
        for(Study_Contact__c sc :scope) {
            GARP_Common.debugLog('GBI_StudyDPSignReminderBatch','execute','Loop Study Contacts',sc);
            
            if(!studyAccountsWithDPSubmission.contains(sc.Study_Account__c)) {
                
                GARP_Common.debugLog('GBI_StudyDPSignReminderBatch','execute','DP Sumission Missing',sc);
                
                Decimal diff = 0;
                if(sc.DP_Sign_Reminder_Sent_On__c != NULL) {
                    diff = (now.getTime() - sc.DP_Sign_Reminder_Sent_On__c.getTime()) / (1000 * 60 * 60);
                    System.debug('hours diff:' + diff);
                }
                
                if(sc.DP_Sign_Reminder_Sent_On__c == NULL || diff >= 48) {  
                    sc.DP_Sign_Reminder_Sent_On__c = DateTime.now();
                    updateContacts.add(sc);
                }
            }
        }
        
        GARP_Common.debugLog('GBI_StudyDPSignReminderBatch','execute','updateContacts',updateContacts);
        if(!updateContacts.IsEmpty()) {
            update updateContacts;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){        
    }
    
}