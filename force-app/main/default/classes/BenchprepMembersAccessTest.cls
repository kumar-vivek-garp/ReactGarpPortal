@isTest
public class BenchprepMembersAccessTest {
    public static Datetime yesterday;
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
        ContractResults[5].Status = 'Activated ( Auto-Renew )';
        ContractResults[5].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'Membership');
        ContractResults[5].Membership_type__C = 'Individual';
        update ContractResults;
        
    }
    
    @isTest static void updateMemberBenchprepSCRTest(){
        Id profileId1 = [select id from profile where name=: 'Customer Community'].id;
        contact con = [Select Id,AccountId From Contact limit 1];
         User communityUser = new User();
       communityUser = [Select Id From User where ContactId =:con.Id]; 
        communityUser.Bench_Prep_SSO_Attribute__c = '[{"unlock_events":null,"expiration_date":"2025-03-21","course_slug":"scr"},{"unlock_events":null,"expiration_date":"2025-03-21","course_slug":"scr25m"}]';
                                    
        update communityUser;
        system.runAs(communityUser){
            test.startTest();
            
            List<Contract> ContractResults = [Select id,Status from Contract Where Status = 'Activated ( Auto-Renew )' Limit 10];
            Recordtype Recordtype = RecordTypeHelper.GetRecordType('Contract', 'SCR Program');
            RecordTypeHelper.GetRecordTypeName(Recordtype.id);    
            ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'SCR_Program');
            ContractResults[0].All_Requirements_Completed__c = true;
            ContractResults[0].StartDate = date.newInstance(date.today().year()-1, 1, 1 );
            ContractResults[0].Status = 'Completed';
            update ContractResults;
            test.stopTest();
        }
    }
    
    @isTest static void removeMemberBenchprepTest(){
        Id profileId1 = [select id from profile where name=: 'Customer Community'].id;
        contact con = [Select Id,AccountId From Contact limit 1];
         User communityUser = new User();
       communityUser = [Select Id From User where ContactId =:con.Id]; 
        communityUser.Bench_Prep_SSO_Attribute__c = '[{"unlock_events":null,"expiration_date":"2025-03-21","course_slug":"scr"},{"unlock_events":null,"expiration_date":"2025-03-21","course_slug":"scr25m"}]';
                                    
        update communityUser;
        system.runAs(communityUser){
            test.startTest();
            
            List<Contract> ContractResults = [Select id,Status from Contract Where Status = 'Activated ( Auto-Renew )' Limit 10];
              
            ContractResults[0].Status = 'Expired';
            update ContractResults;
            test.stopTest();
        }
    }
    @isTest static void BenchprepMembersAccessBatchTest(){
        contact con = [Select Id,AccountId From Contact limit 1];
        test.startTest();
        Database.executebatch(new BenchprepMembersAccessBatch(new List<String>{con.AccountId}));
        test.stopTest();
    }
}