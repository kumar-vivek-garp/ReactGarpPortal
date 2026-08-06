@isTest

public class batchExpireStudyNDAs_test{

    static Account acc;
    
    static Study_NDA__c study;
    
    static void testData(){
        
        acc = new Account(Name = 'test');
        insert acc;
         
        study = new Study_NDA__c(Name = 'test study', Status__c ='none', Next_NDA_Review_Date__c = date.today());
        insert study;
        
      } 
    
    static testMethod void unitTest_1(){
    
        testData();
        test.startTest();
        batchExpireStudyNDAs nda = new batchExpireStudyNDAs(NULL);
        Database.executebatch(nda);

        test.stopTest();
    }


}