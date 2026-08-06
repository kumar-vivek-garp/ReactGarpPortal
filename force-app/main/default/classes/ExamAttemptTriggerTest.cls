@isTest
private class ExamAttemptTriggerTest {
    Static List<Candidate_Requirement__c> CandidateRequirementResults;
    
    @TestSetup
    static void createTestData() {
        Integer totalCount = 4;
        List<Account> AccountResults=TestDataFactory.createAccounts(totalCount);
        insert AccountResults;
        
        List<Contact> ContactResults=TestDataFactory.createContacts(totalCount);
        for(Integer i = 0; i < totalCount ; i++){
            ContactResults[i].AccountId = AccountResults[i].Id;
        }
        insert ContactResults;
        
        List<Opportunity> OppResults=TestDataFactory.createOpportunity(totalCount);
        OppResults[0].StageName = 'Closed';
        OppResults[1].StageName = 'Closed';
        OppResults[2].StageName = 'Closed';
        OppResults[3].StageName = 'Closed';
        insert OppResults;
        
        List<Contract> ContractResults=TestDataFactory.createContract(totalCount,OppResults,ContactResults);
        for(Integer i = 0; i < totalCount ; i++){
            ContractResults[i].AccountId = AccountResults[i].Id;
        }
        ContractResults[0].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        insert ContractResults;
        ContractResults[0].Status = 'Activated';
        ContractResults[1].Status = 'Activated';
        ContractResults[2].Status = 'Activated';
        ContractResults[3].Status = 'Activated';
        update ContractResults;
        
        CandidateRequirementResults=TestDataFactory.createCandidateCommitment(totalCount,OppResults,ContractResults);
        //List<Candidate_Requirement__c> CandidateRequirementResults=TestDataFactory.createCandidateCommitment(totalCount,OppResults,ContractResults);
        //CandidateCommitmentResults=TestDataFactory.createCandidateCommitment(totalCount,OppResults,ContractResults);
        
        insert CandidateRequirementResults;
        
        List<Exam_Attempt__c> ExamAttemptResults = TestDataFactory.createExamAttempt(totalCount,OppResults,contractResults);
        ExamAttemptResults[0].Result__c = 'Not Graded';
        ExamAttemptResults[0].Legacy_Unpaid_Registration_Date__c = null;
        ExamAttemptResults[1].Result__c = 'Not Graded';
        ExamAttemptResults[2].Result__c = 'Not Graded';
        ExamAttemptResults[3].Result__c = 'Not Graded';
        ExamAttemptResults[0].Member__c = ContactResults[0].Id;
        ExamAttemptResults[1].Member__c = ContactResults[1].Id;
        ExamAttemptResults[2].Member__c = ContactResults[2].Id;
        ExamAttemptResults[3].Member__c = ContactResults[3].Id;
        insert ExamAttemptResults;
        
    }
    
    @isTest static void testExamAttemptV1(){
        test.startTest();
        List<Exam_Attempt__c> ExamAttemptList = [Select Id  from Exam_Attempt__c  LIMIT 2];
        List<Candidate_Requirement__c> CandidateRequirementList = [Select Id  from Candidate_Requirement__c  LIMIT 2];
        ExamAttemptList[0].Result__c = 'Pass';
        ExamAttemptList[1].Result__c = 'Fail';
        ExamAttemptList[0].Candidate_Requirement__c = CandidateRequirementList[0].Id;
        ExamAttemptList[1].Candidate_Requirement__c = CandidateRequirementList[0].Id;
        update ExamAttemptList;
        test.stopTest();
    }
    
    @isTest static void testExamAttemptV2(){
        test.startTest();
        List<Exam_Attempt__c> ExamAttemptList = [Select Id  from Exam_Attempt__c  LIMIT 2];
        List<Candidate_Requirement__c> CandidateRequirementList = [Select Id  from Candidate_Requirement__c  LIMIT 2];
        ExamAttemptList[0].Result__c = 'Pass';
        ExamAttemptList[1].Result__c = 'Pass';
        ExamAttemptList[0].Candidate_Requirement__c = CandidateRequirementList[0].Id;
        ExamAttemptList[1].Candidate_Requirement__c = CandidateRequirementList[0].Id;
        update ExamAttemptList;
        test.stopTest();
    }
    
    @isTest static void testExamAttemptV3(){
        test.startTest();
        List<Exam_Attempt__c> ExamAttemptList = [Select Id  from Exam_Attempt__c  LIMIT 2];
        List<Candidate_Requirement__c> CandidateRequirementList = [Select Id  from Candidate_Requirement__c  LIMIT 2];
        ExamAttemptList[0].Result__c = 'Fail';
        ExamAttemptList[1].Result__c = 'Fail';
        ExamAttemptList[0].Cancelled__c = False;
        ExamAttemptList[1].Cancelled__c = False;
        ExamAttemptList[0].Candidate_Requirement__c = CandidateRequirementList[0].Id;
        ExamAttemptList[1].Candidate_Requirement__c = CandidateRequirementList[1].Id;
        update ExamAttemptList;
        test.stopTest();
    }
    
    @isTest static void testExamAttemptV4(){
        test.startTest();
        List<Exam_Attempt__c> ExamAttemptList = [Select Id  from Exam_Attempt__c  LIMIT 4];
        List<Candidate_Requirement__c> CandidateRequirementList = [Select Id  from Candidate_Requirement__c  LIMIT 4];
        ExamAttemptList[2].Result__c = 'Pass';
        ExamAttemptList[3].Result__c = 'Pass';
        ExamAttemptList[2].Cancelled__c = False;
        ExamAttemptList[3].Cancelled__c = False;
        ExamAttemptList[2].Candidate_Requirement__c = CandidateRequirementList[2].Id;
        ExamAttemptList[3].Candidate_Requirement__c = CandidateRequirementList[3].Id;
        update ExamAttemptList;
        test.stopTest();
    }
    
    @isTest static void testInsert(){
        test.startTest();
        Exam_Attempt__c record = new Exam_Attempt__c();
        record.cancelled__c = false;
        record.ATA_Cert_id__c = 'Test';
        record.ATA_Cert_Type__c = 'TestType';
        record.ATA_Name_as_it_appears_on_ID__c = 'Test User';
        insert record;
        test.stopTest();
    }
}