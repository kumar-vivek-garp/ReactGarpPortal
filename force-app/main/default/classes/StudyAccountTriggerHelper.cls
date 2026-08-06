public with sharing class StudyAccountTriggerHelper {

    public static Boolean firstExecution = true;

    public static void onBeforeInsert(Map<Id, Study_Account__c> newStudyAccountMap, Map<Id, Study_Account__c> oldStudyAccountMap){}

    public static void onAfterInsert(Map<Id, Study_Account__c> newStudyAccountMap, Map<Id, Study_Account__c> oldStudyAccountMap){
        syncStudyAccountToQualtrics(newStudyAccountMap.values());
    }

    public static void onBeforeUpdate(Map<Id, Study_Account__c> newStudyAccountMap, Map<Id, Study_Account__c> oldStudyAccountMap){}

    public static void onAfterUpdate(Map<Id, Study_Account__c> newStudyAccountMap, Map<Id, Study_Account__c> oldStudyAccountMap){
        syncStudyAccountToQualtrics(newStudyAccountMap, oldStudyAccountMap);
    }  

    public static List<Study_Account__c> fetchStudyAccounts(Set<Id> studyAccountIds){
        return [
            SELECT 
            Id, 
            Qualtrics_Mailing_List_ID__c, 
            Qualtrics_Contact_ID__c,
            Qualtrics_Survey_Sync_Study__c,
            Qualtrics_Survey_Integration_Status__c,
            Study__r.Qualtrics_Survey_ID__c, 
            Study__r.Qualtrics_Survey_Sync_Study__c,
            Study__r.Qualtrics_Survey_Integration_Status__c
            FROM Study_Account__c
            WHERE 
                Id IN :studyAccountIds AND 
                Study__r.Qualtrics_Survey_ID__c != null AND
                Qualtrics_Survey_Sync_Study__c = TRUE AND
                Qualtrics_Survey_Integration_Status__c = 'Enabled'
        ];
    }

    public static void syncStudyAccountToQualtrics(List<Study_Account__c> studyAccounts){

        Set<Id> studyAccountIds = new Set<Id>();
        for(Study_Account__c studyAccount: studyAccounts){
            if(
                studyAccount.Qualtrics_Survey_Integration_Status__c == 'Enabled' && 
                studyAccount.Qualtrics_Survey_Sync_Study__c == TRUE
                
            ){
                studyAccountIds.add(studyAccount.Id);
            }
        }

        List<Study_Account__c> studyAccountsToSync = fetchStudyAccounts(studyAccountIds);

        if(!studyAccountsToSync.isEmpty()){
            Id jobId = System.enqueueJob(new QualtricsApiQueueable(studyAccountsToSync, 0));
        }

    }

    public static void syncStudyAccountToQualtrics(Map<Id, Study_Account__c> newStudyAccountMap, Map<Id, Study_Account__c> oldStudyAccountMap){

        Set<Id> studyAccountIds = new Set<Id>();
        for(Study_Account__c studyAccount: newStudyAccountMap.values()){
            if(
                studyAccount.Qualtrics_Survey_Integration_Status__c == 'Enabled' &&
                oldStudyAccountMap.get(studyAccount.Id).Qualtrics_Survey_Integration_Status__c != 'Enabled' &&
                studyAccount.Qualtrics_Survey_Sync_Study__c == TRUE && 
                oldStudyAccountMap.get(studyAccount.Id).Qualtrics_Survey_Sync_Study__c == FALSE
            ){
                studyAccountIds.add(studyAccount.Id);
            }
        }

        List<Study_Account__c> studyAccountsToSync = fetchStudyAccounts(studyAccountIds);

        if(!studyAccountsToSync.isEmpty()){
            Id jobId = System.enqueueJob(new QualtricsApiQueueable(studyAccountsToSync, 0));
        }

    }

}