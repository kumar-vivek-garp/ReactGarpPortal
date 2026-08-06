global class GBI_StudyRoleAssignmentReminderBatch implements Database.Batchable<SObject>, Database.Stateful {

    Public String studyAccountId; 
    Public String studyId; 
    
    global GBI_StudyRoleAssignmentReminderBatch(String studyAccountIn, String studyIdIn) {
        GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','consrtuctor','studyAccountIn',studyAccountIn);
        GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','consrtuctor','studyIdIn',studyIdIn);
        
        this.studyAccountId = studyAccountIn;   
        this.studyId = studyIdIn;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        String query = 'select id, Study__c, Study_Account__c, Role__c, Can_Manage_Users__c, Role_Assignment_Reminder_Sent_On__c';
              query += ' from Study_Contact__c where Study_Contact_Email__c != NULL AND Status__c != \'Suspended\' AND Study__r.Status__c = \'In Progress\'';
        	  query += ' AND (Study__r.End_Date__c = NULL OR Study__r.End_Date__c <= TODAY) AND (Study__r.Start_Date__c = NULL OR Study__r.Start_Date__c <= TODAY) AND Study__r.Disable_Role_Assignment_Reminder__c = FALSE';
              query += ' AND Can_Manage_Users__c = True';
        
        if(studyAccountId != NULL) {
            query += ' AND Study_Account__c = \'' + studyAccountId + '\'';
        } else if(studyId != NULL) {
            query += ' AND Study__c = \'' + studyId + '\'';
        }
        
        GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','start','query',query);
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<Study_Contact__c> scope){
        
        SET<String> studies = new SET<String>();
        SET<String> studyAccountsWithManageUserAssigned = new SET<String>();
        SET<String> studyAccountsWithVoterAssigned = new SET<String>();
        SET<String> studyAccountsWithDataManagerAssigned = new SET<String>();
        
        for(Study_Contact__c sc :scope) {
            studies.add(sc.Study__c);
            if(sc.Can_Manage_Users__c) {
                studyAccountsWithManageUserAssigned.add(sc.Study_Account__c);
            }            
            if(sc.Role__c != NULL && sc.Role__c.IndexOf('Voter') > -1) {
                studyAccountsWithVoterAssigned.add(sc.Study_Account__c);
            }            
            if(sc.Role__c != NULL && sc.Role__c.IndexOf('Data Manager') > -1) {
                studyAccountsWithDataManagerAssigned.add(sc.Study_Account__c);
            }            
        }
        GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','execute','studyAccountsWithManageUserAssigned',studyAccountsWithManageUserAssigned);
        GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','execute','studyAccountsWithVoterAssigned',studyAccountsWithVoterAssigned);
        GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','execute','studyAccountsWithDataManagerAssigned',studyAccountsWithDataManagerAssigned);
        
        
        List<Study_Contact__c> updateContacts = new List<Study_Contact__c>();
        DateTime now = DateTime.Now();
        for(Study_Contact__c sc :scope) {
            if(sc.Can_Manage_Users__c) {
                GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','execute','Loop sc',sc);
                
                if(!studyAccountsWithVoterAssigned.contains(sc.Study_Account__c) || !studyAccountsWithDataManagerAssigned.contains(sc.Study_Account__c)) {
                    
                    GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','execute','Study Account Missing Roles',sc.Study_Account__c);
                    GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','execute','Last Reminder_Sent_On',sc.Role_Assignment_Reminder_Sent_On__c);
                    
                    if(sc.Role_Assignment_Reminder_Sent_On__c == NULL) {
                        sc.Role_Assignment_Reminder_Sent_On__c = now;
                        updateContacts.add(sc);
                    } else {
                        Decimal diff = (now.getTime() - sc.Role_Assignment_Reminder_Sent_On__c.getTime()) / (1000 * 60 * 60);
                        GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','execute','hours diff',diff);
                        
                        if(diff >= 48) {
                            sc.Role_Assignment_Reminder_Sent_On__c = now;
                            updateContacts.add(sc);
                        } else {
                            GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','execute','Skip Until Tomorrow',null);
                        }
                    }
                }
            }
        }
        
        GARP_Common.debugLog('GBI_StudyRoleAssignmentReminderBatch','execute','updateContacts',updateContacts);
        if(!updateContacts.IsEmpty()) {
            update updateContacts;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){        
    }
    
}