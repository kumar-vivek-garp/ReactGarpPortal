public with sharing class StudyTriggerHelper {

    public static Boolean firstExecution = true;

    public static void onBeforeInsert(Map<Id, Study__c> newStudyMap, Map<Id, Study__c> oldStudyMap){}

    public static void onAfterInsert(Map<Id, Study__c> newStudyMap, Map<Id, Study__c> oldStudyMap){}

    public static void onBeforeUpdate(Map<Id, Study__c> newStudyMap, Map<Id, Study__c> oldStudyMap){}

    public static void onAfterUpdate(Map<Id, Study__c> newStudyMap, Map<Id, Study__c> oldStudyMap){
        syncStudyAccountToQualtrics(newStudyMap, oldStudyMap);
    }  

    public static List<Study_Account__c> fetchStudyAccounts(Set<Id> studyIds){
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
                Study__c IN :studyIds AND 
                Study__r.Qualtrics_Survey_ID__c != null AND 
                Qualtrics_Survey_Sync_Study__c = TRUE AND
                Qualtrics_Survey_Integration_Status__c = 'Enabled'
        ];
    }

    public static void syncStudyAccountToQualtrics(Map<Id, Study__c> newStudyMap, Map<Id, Study__c> oldStudyMap){

        StudyAccountTriggerHelper.firstExecution = false;

        Set<Id> studyIds = new Set<Id>();
        for(Study__c study: newStudyMap.values()){
            if(
                study.Qualtrics_Survey_Integration_Status__c == 'Enabled' && 
                oldStudyMap.get(study.Id).Qualtrics_Survey_Integration_Status__c != 'Enabled' &&
                study.Qualtrics_Survey_Sync_Study__c == TRUE && 
                oldStudyMap.get(study.Id).Qualtrics_Survey_Sync_Study__c == FALSE
            ){
                studyIds.add(study.Id);
            }
        }

        List<Study_Account__c> studyAccountsToSync = fetchStudyAccounts(studyIds);

        if(!studyAccountsToSync.isEmpty()){
            Id jobId = System.enqueueJob(new QualtricsApiQueueable(studyAccountsToSync, 0));
        }

    }

}