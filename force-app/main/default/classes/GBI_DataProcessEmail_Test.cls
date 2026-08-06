@isTest
private class GBI_DataProcessEmail_Test {
	
    private static void setData() {
        Study__c study = new Study__c(Name='Apex Test Study', Status__c = 'In Progress');
        insert study;
        Study_Round__c studyVersion = new Study_Round__c(Name='Apex Test Round 1', Study__c = study.Id, Status__c = 'Active');
		insert studyVersion;
        Account account = new Account(Name = 'Apex Test Account', RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'].Id);
        insert account;
        Study_Account__c studyAccount = new Study_Account__c(Name = 'Apex Study Account', Study__c = study.Id, Account__c = account.Id,Study_Fee_Type__c='Free');
        insert studyAccount;
    }
    
    @isTest static void test_dataProcessEmail() {
        setData();
        
        Test.startTest();
        Study__c study = [SELECT Id, (SELECT Id FROM Study_Accounts__r), (SELECT Id FROM Study_Drafts__r) FROM Study__c LIMIT 1];
        Study_Data_Submission__c dataSubmit = new Study_Data_Submission__c(
            Study_Account__c=study.Study_Accounts__r[0].Id, 
            Study_Round__c=study.Study_Drafts__r[0].Id);
        
        insert dataSubmit;
        Test.stopTest();
    }
    
}