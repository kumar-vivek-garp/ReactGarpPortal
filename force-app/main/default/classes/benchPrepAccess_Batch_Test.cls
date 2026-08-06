@isTest
public class benchPrepAccess_Batch_Test {
    
    @TestSetup
    static void createTestData() {
        Integer totalCount = 4;
        List<Contact> ContactResults=TestDataFactory.createContacts(totalCount);
        insert ContactResults;
        
        List<Opportunity> OppResults=TestDataFactory.createOpportunity(totalCount);
        OppResults[0].StageName = 'Closed';
        OppResults[1].StageName = 'Closed';
        OppResults[2].StageName = 'Closed';
        OppResults[3].StageName = 'Closed';
        insert OppResults;
        
        List<Contract> ContractResults=TestDataFactory.createContract(totalCount,OppResults,ContactResults);
        ContractResults[0].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        insert ContractResults;
        ContractResults[0].Status = 'Activated';
        ContractResults[1].Status = 'Activated';
        ContractResults[2].Status = 'Activated';
        ContractResults[3].Status = 'Activated';
        update ContractResults;
        
        List<Candidate_Requirement__c> CandidateRequirementResults=TestDataFactory.createCandidateCommitment(totalCount,OppResults,ContractResults);
        insert CandidateRequirementResults;
        
        List<Exam_Attempt__c> ExamAttemptResults = TestDataFactory.createExamAttempt(totalCount,OppResults,contractResults);
        ExamAttemptResults[0].Result__c = 'Not Graded';
        ExamAttemptResults[0].Legacy_Unpaid_Registration_Date__c = null;
        ExamAttemptResults[1].Result__c = 'Not Graded';
        ExamAttemptResults[2].Result__c = 'Not Graded';
        ExamAttemptResults[3].Result__c = 'Not Graded';
        insert ExamAttemptResults;
        
    }
    
    
    @IsTest
    static void unitTest1(){
         
        List<User> userList = [select Id, Bench_Prep_SSO_Attribute__c,ContactId 
                               FROM User where ContactId != null LIMIT 5];
        
        for(User u : userList){
            u.Bench_Prep_SSO_Attribute__c = '[{"unlock_events":null,"expiration_date":"2025-01-18","course_slug":"FRMBP"}]';
        }
        update userList;
        
        if(!userList.isEmpty()){
            List<Exam_Attempt__c> ealist = new List<Exam_Attempt__c>();
            for(Exam_Attempt__c ea : [SELECT Id,Member__c FROM Exam_Attempt__c]){
                ea.Member__c = userList[0].ContactId;
                ealist.add(ea);
            }
            update ealist;
            system.debug(ealist.size()+'  ::ealist::>>  '+ealist);
        }
        test.startTest();
        benchPrepAccess_Batch bat = new benchPrepAccess_Batch('SCR',null);
        database.executeBatch(bat);
        test.stopTest();
    }
    
    @IsTest
    static void unitTest2(){
         
        List<User> userList = [select Id, Bench_Prep_SSO_Attribute__c,ContactId 
                               FROM User where ContactId != null LIMIT 5];
        
        for(User u : userList){
            u.Bench_Prep_SSO_Attribute__c = '[{"unlock_events":null,"expiration_date":"2025-01-18","course_slug":"scr24"}]';
        }
        update userList;
        
        if(!userList.isEmpty()){
            List<Exam_Attempt__c> ealist = new List<Exam_Attempt__c>();
            for(Exam_Attempt__c ea : [SELECT Id,Member__c FROM Exam_Attempt__c]){
                ea.Member__c = userList[0].ContactId;
                ealist.add(ea);
            }
            update ealist;
            system.debug(ealist.size()+'  ::ealist::>>  '+ealist);
        }
        test.startTest();
        benchPrepAccess_Batch bat = new benchPrepAccess_Batch('FRM Part 1',null);
        database.executeBatch(bat);
        test.stopTest();
    }
    
    @IsTest
    static void unitTest3(){
         
        List<User> userList = [select Id, Bench_Prep_SSO_Attribute__c,ContactId 
                               FROM User where ContactId != null LIMIT 5];
        
        for(User u : userList){
            u.Bench_Prep_SSO_Attribute__c = '[{"unlock_events":null,"expiration_date":"2025-01-18","course_slug":"scr24"}]';
        }
        update userList;
        
        if(!userList.isEmpty()){
            List<Exam_Attempt__c> ealist = new List<Exam_Attempt__c>();
            for(Exam_Attempt__c ea : [SELECT Id,Member__c FROM Exam_Attempt__c]){
                ea.Member__c = userList[0].ContactId;
                ealist.add(ea);
            }
            update ealist;
            system.debug(ealist.size()+'  ::ealist::>>  '+ealist);
            test.startTest(); 
        benchPrepAccess_Batch bat = new benchPrepAccess_Batch('FRM Part 1',ealist[0].Id,null);
          BenchPrepClass.getBenchPrepConfig(); 
        database.executeBatch(bat);
        test.stopTest();
        }
        
    }
}