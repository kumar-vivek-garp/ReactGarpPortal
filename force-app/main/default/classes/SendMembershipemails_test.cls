@isTest

public class SendMembershipemails_test{

    static Account acc;
    static Opportunity opp;
    static Contract contract;
    static Candidate_Requirement__c reqt;
    
    static void testData(){
        
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Merchant_ID__c = 'dasghjtru548709-4',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
        Acc = new Account(Name = 'test');
        insert acc;
        
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()- 100);        
        insert opp; 
       
    }
    
    static testMethod void unitTest_1(){
    
        testData();
        string memRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
        
        
        Contract Contract6  = new Contract(recordtypeId = memRecordType ,Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 1,StartDate = system.today()- 30);
        insert contract6;
        contract6.Status = 'Activated';
        contract6.Days_Left__c = contract6.Days_remaining__c;
        update contract6;
         
        test.startTest();
        SendMembershipemails contracts = new SendMembershipemails(NULL);
        Database.executebatch(contracts,1);
        test.stopTest();
    }
    
    static testMethod void unitTest_2(){
        testData();
    	 string frmProgram = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program'); 
        
        Contract frmAttempt  = new Contract(recordtypeId = frmProgram ,Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 1,StartDate = system.today()- 30);
        insert frmAttempt;
        frmAttempt.Status = 'Activated';
        frmAttempt.Days_Left__c = frmAttempt.Days_remaining__c;
        update frmAttempt;
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience'); 
        
        Candidate_Requirement__c crExam1 = GARP_TestFactory.createCandidateCommitment(frmAttempt,'FRM Part I',ProgReqRecId);
        Candidate_Requirement__c crExam2 = GARP_TestFactory.createCandidateCommitment(frmAttempt,'FRM Part II',ProgReqRecId);
         
        
        crExam1.Status__c = 'Completed';
        crExam1.Date_of_Completion__c = Date.Today().AddDays(-365);
        update crExam1;

        crExam2.Status__c = 'Completed';
        crExam2.Date_of_Completion__c = Date.Today().AddDays(-365);
        update crExam2;
       
        test.startTest();
        SendMembershipemails contracts = new SendMembershipemails(NULL);
        Database.executebatch(contracts,1);
        test.stopTest();
    }


}