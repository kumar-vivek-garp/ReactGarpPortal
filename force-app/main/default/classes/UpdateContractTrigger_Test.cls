@isTest
private class UpdateContractTrigger_Test {
    Static List<Candidate_Requirement__c> CandidateCommitmentResults;
    
    @TestSetup
    static void createTestData() {

        Integer totalCount=6;
        
        List<Opportunity> OppResults =TestDataFactory.createOpportunity(totalCount);
        insert OppResults;
        
        List<Contact> ContactResults =TestDataFactory.createContacts(totalCount);
        for(Integer counter=0; counter < totalCount; counter++) {
            ContactResults[counter].AccountId = OppResults[counter].AccountId;
        }
        insert ContactResults;
        
        List<Contract> ContractResults = TestDataFactory.createContract(totalCount,OppResults,ContactResults); 	
        insert ContractResults;
        CandidateCommitmentResults=TestDataFactory.createCandidateCommitment(totalCount,OppResults,ContractResults);
        insert CandidateCommitmentResults;

    }
    
    
    @isTest static void testUpdateContractTriggerV1(){
        
        List<Contract> ContractResults = [Select id,Status,recordTypeId from Contract where Status = 'Completed'];
        ContractResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');
        update ContractResults;
        test.startTest();
        CandidateCommitmentResults=[Select id,Status__c,RecordTypeId,Certificate_Sent_Date__c,Date_of_Completion__c from Candidate_Requirement__c
                                    Limit 2];
        CandidateCommitmentResults[0].Candidate_Commitment__c = ContractResults[0].id;
        update CandidateCommitmentResults;
        CandidateCommitmentResults[0].Status__c ='Draft';
        CandidateCommitmentResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        CandidateCommitmentResults[0].Certificate_Sent_Date__c =system.today() + 1; 
        update CandidateCommitmentResults;
        test.stopTest();
    }
    
    @isTest static void testUpdateContractTriggerV2(){
       
        test.startTest();
        List<Contract> ContractResults = [Select id,Status,recordTypeId,StartDate from Contract where Status = 'Completed'];
        //ContractResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Contract','ERP Program');
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ERP_Program');
        update ContractResults;
        CandidateCommitmentResults=[Select id,Exam__c,Status__c,RecordTypeId,Certificate_Sent_Date__c,Date_of_Completion__c from Candidate_Requirement__c
                                    Limit 2];
        CandidateCommitmentResults[0].Candidate_Commitment__c = ContractResults[0].id;
        update CandidateCommitmentResults;
        //CandidateCommitmentResults[0].Status__c ='Draft';
        CandidateCommitmentResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        CandidateCommitmentResults[0].Certificate_Sent_Date__c =system.today() + 2; 
        CandidateCommitmentResults[0].Exam__c = 'ERP Part II';
        update CandidateCommitmentResults;
        test.stopTest();
    }
    
    @isTest static void testUpdateContractTriggerV3(){
       
        List<Contact> lstCont = [select Id, Name, AccountId, KPI_FRM_Resume_Program_Requirement_ID__c, KPI_ERP_Resume_Program_Requirement_ID__c, 
                                 KPI_FRM_Resume_Status__c, KPI_FRM_Resume_Status_Date__c, KPI_FRM_Resume_Certificate_Sent_Date__c,
                                 KPI_ERP_Resume_Status__c, KPI_ERP_Resume_Status_Date__c, KPI_ERP_Resume_Certificate_Sent_Date__c 
                                 from Contact limit 6];
        update lstCont;
        List<Contract> ContractResults = [Select id,Status,recordTypeId from Contract where Status = 'Completed'];
        ContractResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Contract','ERP Program');
        update ContractResults;
        ContractResults[0].CustomerSignedId=lstCont[0].id;
        update ContractResults;
        test.startTest();
        CandidateCommitmentResults=[Select id,Status__c,RecordTypeId,Date_of_Completion__c,Certificate_Sent_Date__c from Candidate_Requirement__c
                                    where Status__c ='completed'];
        
        CandidateCommitmentResults[0].Status__c = 'Initial';
        CandidateCommitmentResults[0].Candidate_Commitment__c = ContractResults[0].id;
        CandidateCommitmentResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        CandidateCommitmentResults[0].Certificate_Sent_Date__c =system.today() + 3; 
        update CandidateCommitmentResults;
        CandidateCommitmentResults=[Select id,Status__c,RecordTypeId,Certificate_Sent_Date__c from Candidate_Requirement__c
                                    where Status__c ='Initial'];
        
        CandidateCommitmentResults[0].Status__c = 'Ready For Review'; 
        update CandidateCommitmentResults;
        test.stopTest();
    }
    
    @isTest static void testUpdateContractTriggerNewV3(){
        List<Contact> lstCont = [select Id, Name, AccountId, KPI_FRM_Resume_Program_Requirement_ID__c, KPI_ERP_Resume_Program_Requirement_ID__c, 
                                 KPI_FRM_Resume_Status__c, KPI_FRM_Resume_Status_Date__c, KPI_FRM_Resume_Certificate_Sent_Date__c,
                                 KPI_ERP_Resume_Status__c, KPI_ERP_Resume_Status_Date__c, KPI_ERP_Resume_Certificate_Sent_Date__c 
                                 from Contact limit 6];
        update lstCont;
        
        List<Contract> ContractResults = [Select id,Status,recordTypeId from Contract where Status = 'Completed'];
        ContractResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Contract','ERP Program');
        update ContractResults;
        ContractResults[0].CustomerSignedId=lstCont[0].id;
        update ContractResults;
        test.startTest();
        CandidateCommitmentResults=[Select id,Status__c,RecordTypeId,Certificate_Sent_Date__c from Candidate_Requirement__c
                                    where Status__c ='completed'];
        
        CandidateCommitmentResults[0].Status__c = 'Initial';
        CandidateCommitmentResults[0].Candidate_Commitment__c = ContractResults[0].id;
        CandidateCommitmentResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        CandidateCommitmentResults[0].Certificate_Sent_Date__c =system.today() + 3; 
        update CandidateCommitmentResults;
        CandidateCommitmentResults=[Select id,Status__c,RecordTypeId,Certificate_Sent_Date__c from Candidate_Requirement__c
                                    where Status__c ='Initial'];
        
        CandidateCommitmentResults[0].Status__c = 'Ready For Review'; 
        update CandidateCommitmentResults;
        test.stopTest();
    }
    @isTest static void testUpdateContractTriggerNewV4(){
        
        List<Contact> lstCont = [select Id, Name, AccountId, KPI_FRM_Resume_Program_Requirement_ID__c, KPI_ERP_Resume_Program_Requirement_ID__c, 
                                 KPI_FRM_Resume_Status__c, KPI_FRM_Resume_Status_Date__c, KPI_FRM_Resume_Certificate_Sent_Date__c,
                                 KPI_ERP_Resume_Status__c, KPI_ERP_Resume_Status_Date__c, KPI_ERP_Resume_Certificate_Sent_Date__c 
                                 from Contact limit 6];
        update lstCont;
        List<Contract> ContractResults = [Select id,Status,recordTypeId from Contract where Status = 'Completed'];
        ContractResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');
        update ContractResults;
        ContractResults[0].CustomerSignedId=lstCont[0].id;
        update ContractResults;
        test.startTest();
        CandidateCommitmentResults=[Select id,Status__c,RecordTypeId,Date_of_Completion__c,Certificate_Sent_Date__c from Candidate_Requirement__c
                                    where Status__c ='completed'];
        
        CandidateCommitmentResults[0].Status__c = 'Initial';
        CandidateCommitmentResults[0].Candidate_Commitment__c = ContractResults[0].id;
        CandidateCommitmentResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        CandidateCommitmentResults[0].Certificate_Sent_Date__c =system.today() + 3; 
        update CandidateCommitmentResults;
        CandidateCommitmentResults=[Select id,Status__c,RecordTypeId,Certificate_Sent_Date__c from Candidate_Requirement__c
                                    where Status__c ='Initial'];
        
        CandidateCommitmentResults[0].Status__c = 'Ready For Review'; 
        update CandidateCommitmentResults;
        test.stopTest();
    }
    @isTest static void testUpdateContractTriggerV5(){
        test.startTest();
        List<Contract> ContractResults = [Select id,Status,recordTypeId,StartDate from Contract where Status = 'Completed'];
        
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        update ContractResults;
        CandidateCommitmentResults=[Select id,Exam__c,Status__c,RecordTypeId,Certificate_Sent_Date__c,Date_of_Completion__c from Candidate_Requirement__c
                                    Limit 2];
        CandidateCommitmentResults[0].Candidate_Commitment__c = ContractResults[0].id;
        update CandidateCommitmentResults;
        
        CandidateCommitmentResults[0].RecordTypeId=RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        CandidateCommitmentResults[0].Certificate_Sent_Date__c =system.today() + 2; 
        CandidateCommitmentResults[0].Exam__c = 'FRM Part I';
        update CandidateCommitmentResults;
        
        
        ContractResults[1].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ICBRR_Program');
        update ContractResults;
        CandidateCommitmentResults=[Select id,Exam__c,Status__c,RecordTypeId,Certificate_Sent_Date__c,Date_of_Completion__c from Candidate_Requirement__c
                                    Limit 2];
        CandidateCommitmentResults[1].Candidate_Commitment__c = ContractResults[1].id;
        update CandidateCommitmentResults;
        //CandidateCommitmentResults[0].Status__c ='Draft';
        CandidateCommitmentResults[1].RecordTypeId=RecordTypeHelper.getRecordTypeIdFromSchema('Candidate_Requirement__c','Exam');
        CandidateCommitmentResults[1].Certificate_Sent_Date__c =system.today() + 2; 
        CandidateCommitmentResults[1].Exam__c = 'FRM Part I';
        CandidateCommitmentResults[1].Status__c = 'Completed';
        update CandidateCommitmentResults;
        
        test.stopTest();
    }
    
}