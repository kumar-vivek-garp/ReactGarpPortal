@isTest
public class batchStudyVoteStatusUpdate_test {
   static Study_Vote__c sve; 
    
     static void testData(){
     sve = new Study_Vote__c(Name='TestVote', Start_Date__c = system.today()-10, End_Date__C = system.today()-1, Status__c= 'Opened');
     insert sve;
     
     }
    
     static testMethod void unitTest_1(){
    
        testData();
        test.startTest();
        batchStudyVoteStatusUpdate sv = new batchStudyVoteStatusUpdate ();
        Database.executebatch(sv);
        
        test.stopTest();
    }   
    
}