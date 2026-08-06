@isTest
public class ReusableLookupControllerTest {
	 @TestSetup
    static void createTestData() {
         Account Acc = new Account(Name = 'test');
        insert acc;
    }
    static testMethod void unitTest1(){
        Test.startTest(); 
        ReusableLookupController.SearchWrapper reue = new ReusableLookupController.SearchWrapper();
        reue.objectApiName = 'Account';
        reue.fieldApiName = 'Name';
        reue.otherFieldApiName = 'GARP_ID__c';
        reue.searchString = 'test';
		 ReusableLookupController.fetchRecords(reue);        
        Test.stopTest();
    }
    
}