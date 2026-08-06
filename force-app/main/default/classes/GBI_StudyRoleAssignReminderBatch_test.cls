@isTest
public class GBI_StudyRoleAssignReminderBatch_test {

    static Study__c study;
    static Study_Account__c sa;
    static Study_Contact__c sc;
    static Study_Round__c sr;
    
    static void testData(){ 
        
        study = new Study__c(Name='study1', Status__c='In Progress', Start_Date__c = Date.today().addDays(-30));
        insert study;
        
        sa = new Study_Account__c(Name='SA', Role__c='  Participant', Status__c='Active', Study__c=study.Id, Secure_File_Platform__c = 'ShareFile;AWS');
        insert sa;
        
        sc = new Study_Contact__c(Role__c='Voter', Status__c='Active', Can_Manage_Users__c = True, Study__c=study.Id, Study_Account__c=sa.Id, Study_Contact_Email__c = 'studycontact@garpqa.com');
        insert sc;
        
        sr = new Study_Round__c(Name='Version 1', Published_Date__c=system.today(), Round__c = 'Version 1', Study__c=study.Id, Status__c='Data Collection', Data_Collection_Start_Date__c=system.today().AddDays(-30), Study_Part__c = 'Part 1');
        insert sr;
    }
    
    @isTest
    static void unitTest1(){
        
        testData();
        
        Test.startTest();
        
        Database.executeBatch(new GBI_StudyRoleAssignmentReminderBatch(NULL,NULL));
        
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, new GBI_StudyRoleAssignReminderBatchSchedule());
        
        Test.stopTest();
        
    }
    
}