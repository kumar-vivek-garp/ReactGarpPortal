@isTest
private class ContractTriggerTest { 
    
    public static Datetime yesterday;
    static Map<id,Contract> newlyCompletedContractMap=new Map<id,Contract>();
    static Map<id,id> currentContractAndAccountIds=new Map<id,id>();
    
    @TestSetup
    static void createTestData() {
        Integer totalCount = 10;
        yesterday = Datetime.now().addDays(-1);
        
        List<Opportunity> OppResults =TestDataFactory.createOpportunity(totalCount);
        //oppresults
        insert OppResults;
        
        List<Contact> ContactResults =TestDataFactory.createContacts(totalCount);
        for(Integer counter=0; counter < totalCount; counter++) {
            ContactResults[counter].AccountId = OppResults[counter].AccountId;
        }
        insert ContactResults;
        
        List<Contract> ContractResults = TestDataFactory.createContract(totalCount,OppResults,ContactResults);
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'SCR_Program');
        ContractResults[1].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRM_Program');
        ContractResults[2].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'SCR_Program');
        ContractResults[0].Member_Email__c = 'testcontract@test.com';
        ContractResults[0].ContractTerm = totalCount - 1;
        ContractResults[0].Membership_type__C = 'Individual';
        ContractResults[0].KPI_Last_Updated__c = yesterday;
        insert ContractResults;
        ContractResults[0].Status = 'completed';
        ContractResults[0].All_Requirements_Completed__c = false;
        ContractResults[1].All_Requirements_Completed__c = true;
        ContractResults[0].ContractTerm = totalCount;
        ContractResults[0].accountId = OppResults[0].AccountId;
        ContractResults[0].CustomerSignedId=contactresults[0].id;
        ContractResults[2].Status = 'Completed';
        ContractResults[2].All_Requirements_Completed__c = true;
        ContractResults[2].KPI_Last_Updated__c = yesterday;
        ContractResults[2].Membership_type__C = 'Individual';
        ContractResults[2].accountId = OppResults[0].AccountId;
        ContractResults[2].CustomerSignedId=contactresults[0].id;
        ContractResults[3].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'CPE');
        ContractResults[3].accountId = OppResults[0].AccountId;
        ContractResults[3].StartDate = date.newInstance(date.today().year()-1, 1, 1 );
        ContractResults[3].CustomerSignedId=contactresults[1].id;
        ContractResults[4].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'ERP_Program');
        ContractResults[3].Status = 'Activated ( Auto-Renew )';
        ContractResults[3].All_Requirements_Completed__c = false;
        ContractResults[5].Status = 'Activated ( Auto-Renew )';
        ContractResults[5].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'Membership');
        ContractResults[5].Membership_type__C = 'student';
        update ContractResults;
        
        List<Candidate_Requirement__c> CandidateRequirementResults = TestDataFactory.createCandidateCommitment(totalCount,OppResults,ContractResults);
        for(Candidate_Requirement__c cr : CandidateRequirementResults){
            cr.recordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Candidate_Requirement__c','CPE');
            
        }
        insert CandidateRequirementResults;
        
    }
    
    
    @isTest static void testContractTriggerV2(){
        test.startTest();
        List<Contract> ContractResults = [Select id,Status from Contract Where Status = 'Activated ( Auto-Renew )' Limit 10];
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'CPE');
        ContractResults[0].All_Requirements_Completed__c = true;
        ContractResults[0].StartDate = date.newInstance(date.today().year()-1, 1, 1 );
        ContractResults[0].Status = 'Completed';
        update ContractResults;
        test.stopTest();
    }
    
    
    @isTest static void testContractTriggerV3(){
        test.startTest();
        List<Contract> ContractResults = [Select id,Status from Contract Where Status = 'Activated ( Auto-Renew )' Limit 10];
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'ERP_Program');
        ContractResults[0].Status = 'Completed';
        ContractResults[0].All_Requirements_Completed__c = true;
        update ContractResults;
        test.stopTest();
    }
    
    
    @isTest static void testContractTriggerV4(){
        test.startTest();
        List<Contract> ContractResults = [Select id,Status from Contract Where Status = 'Activated ( Auto-Renew )' Limit 10];
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'ERP_Program');
        ContractResults[0].All_Requirements_Completed__c = true;
        ContractResults[0].StartDate = date.newInstance(date.today().year()-1, 1, 1 );
        update ContractResults;
        test.stopTest();
    }
    
    
    @isTest static void testContractTriggerV5(){
        
        List<Contract> ContractResults = [Select Id,  AccountId,OwnerId,Opportunity__c,CustomerSignedId, StartDate,
                                          Status,EndDate,RecordTypeId,Opportunity__r.AccountId,Opportunity__r.Frm1__c,Opportunity__r.Frm2__c,
                                          Opportunity__r.Erp1__c,Opportunity__r.Erp2__c from Contract limit 4];
        ContractResults[3].RecordTypeId=RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'CPE');
        ContractResults[0].All_Requirements_Completed__c = true;
        ContractResults[3].StartDate = date.newInstance(date.today().year()-1, 1, 1 );
        ContractResults[0].Status = 'Activated ( Auto-Renew )';
        update ContractResults;
        newlyCompletedContractMap.put(ContractResults[0].id,ContractResults[0]);
        currentContractAndAccountIds.put(ContractResults[3].accountId,ContractResults[3].id);
        system.debug('ContractResults-->'+ContractResults);
        test.startTest();
        ContractTriggerHelper.CPEContract(newlyCompletedContractMap,currentContractAndAccountIds);
        test.stopTest();
    }
    @isTest static void testContractTriggerV5_2(){
        
        List<Contract> ContractResults = [Select Id,  AccountId,OwnerId,Opportunity__c,CustomerSignedId, StartDate,
                                          Status,EndDate,RecordTypeId,Opportunity__r.AccountId,Opportunity__r.Frm1__c,Opportunity__r.Frm2__c,
                                          Opportunity__r.Erp1__c,Opportunity__r.Erp2__c from Contract limit 4];
        ContractResults[3].RecordTypeId=RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'CPE');
        ContractResults[0].RecordTypeId=RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRM_Program');
        ContractResults[0].All_Requirements_Completed__c = true;
        ContractResults[3].StartDate = date.newInstance(date.today().year()-1, 1, 1 );
        ContractResults[3].Status = 'Completed';
        update ContractResults;
        newlyCompletedContractMap.put(ContractResults[0].id,ContractResults[0]);
        currentContractAndAccountIds.put(ContractResults[3].accountId,ContractResults[3].id);
        system.debug('ContractResults-->'+ContractResults);
        test.startTest();
        ContractTriggerHelper.CPEContract(newlyCompletedContractMap,currentContractAndAccountIds);
        test.stopTest();
    }
    
    @isTest static void testContractTriggerV5_1(){
        test.startTest();
        List<Contract> ContractResults = [Select id,Status from Contract Where Status = 'Activated ( Auto-Renew )' Limit 10];
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'SCR_Program');
        ContractResults[0].All_Requirements_Completed__c = true;
        ContractResults[0].StartDate = date.newInstance(date.today().year()-1, 1, 1 );
        ContractResults[0].Status = 'Activated';
        update ContractResults;
        test.stopTest();
    }
    
    @isTest static void testContractTriggerV6(){
        test.startTest();
        List<Contract> ContractResults = [Select id,Status from Contract Where Status = 'Activated ( Auto-Renew )' Limit 10];
        Recordtype Recordtype = RecordTypeHelper.GetRecordType('Contract', 'SCR Program');
        RecordTypeHelper.GetRecordTypeName(Recordtype.id);   
        //ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'SCR_Program');
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'SCR_Program');
        ContractResults[0].All_Requirements_Completed__c = true;
        ContractResults[0].StartDate = date.newInstance(date.today().year()-1, 1, 1 );
        ContractResults[0].Status = 'Completed';
        update ContractResults;
        test.stopTest();
    } 
    
    
    
    @isTest static void test_StoppingChargentPayment(){
        test.startTest();
        List<Contract> ContractResults = [Select id,Status from Contract Where Status = 'Activated ( Auto-Renew )' AND Membership_type__C = 'student' Limit 10];
        system.debug('ContractResults::>>   '+ContractResults);
        ContractResults[0].All_Requirements_Completed__c = true;
        ContractResults[0].StartDate = date.newInstance(date.today().year()-1, 1, 1 );
        ContractResults[0].Status = 'Completed';
        update ContractResults;
        test.stopTest();
    }
    
}