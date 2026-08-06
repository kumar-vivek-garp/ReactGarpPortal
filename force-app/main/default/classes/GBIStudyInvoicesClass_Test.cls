@isTest
public class GBIStudyInvoicesClass_Test {
  
  
    @isTest
    Static void unitTest(){
        Test.startTest();
        
        Study_Disclose_Protocol_Submission__c sdps = new Study_Disclose_Protocol_Submission__c(Name = 'test');
        insert sdps;
            
        Test.stopTest();
        
        
    }
}