@isTest
public class expireBenchPrep_Queueable_Test {
    
    @TestSetup
    static void createTestData() {
        Integer totalCount = 1;
        
        List<Exam_Group__c> examGrpResults = TestDataFactory.createExamGroup(totalCount);
        insert examGrpResults;
        
        List<Product2> OppProduct2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'FCBR',isActive = true,
                                   Is_Shippable__c = true,Family='IndividualMember',Customs_Cost__c = '5',GL_Code__c = '4999',Weight__c=5);
        OppProduct2List.add(p1);
        insert OppProduct2List;
        
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[0].Id,
                                                           UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice1);
        insert PricebookEntryList ;
        
        List<Opportunity> OppResults=TestDataFactory.createOpportunity(totalCount);
        for(Opportunity opp : OppResults){
            Opp.Pricebook2Id = Test.getStandardPricebookId();
        }
        insert OppResults;
        
        List<Contact> ContactResults=TestDataFactory.createContacts(totalCount);
        ContactResults[0].AccountId = OppResults[0].AccountId;
        ContactResults[0].GARP_Member_ID__c = OppResults[0].GARP_Member_ID__c;
        insert ContactResults;
        
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[0].Id,
                                                                   Product_ID__c = '2022SCRPE2022',UnitPrice = 550, Quantity = 1,
                                                                   Product_company__c='GRA Test');
        OpportunityLineItemList.add(oppLineItem1);
        insert OpportunityLineItemList;
        
        List<eBook_Key__c> EbookKey=TestDataFactory.createEbookKey(totalCount,OppResults);
        for(eBook_Key__c bk: EbookKey){
            bk.Product_Id__c='2022SCRPE2022';
            bk.Type__c = 'BenchPrep';
        }
        insert EbookKey;
        
        List<Contact> conList = new List<Contact>();
        for(Contact con : [SELECT Id,GARP_Member_ID__c FROM Contact]){
            con.GARP_Member_ID__c = OppResults[0].GARP_Member_ID__c;
            conList.add(con);
        }
        update conList;
    }
    
    @IsTest
    static void unitTest(){
        
        List<User> userList = [select Id, Bench_Prep_SSO_Attribute__c,ContactId,Community_Contact_GARP_ID__c 
                               FROM User where Community_Contact_GARP_ID__c != null];
        
        system.debug(userList.size()+'   ::userList::>>   '+userList);
        for(User u : userList){
            u.Bench_Prep_SSO_Attribute__c = '[{"unlock_events":null,"expiration_date":"2025-01-18","course_slug":"scr24"}]';
        }
        update userList;
        
        Map<Id,List<OpportunityLineItem>> oppIdToProdsMap = new Map<Id,List<OpportunityLineItem>>();
        for(OpportunityLineItem oli : [SELECT Id,OpportunityId,ProductCode,Product_Id__c FROM OpportunityLineItem LIMIT 10]){
            if(oppIdToProdsMap.containsKey(oli.OpportunityId)){
                oppIdToProdsMap.get(oli.OpportunityId).add(oli);
            }else{
                oppIdToProdsMap.put(oli.OpportunityId, new List<OpportunityLineItem>{oli} );
            }
        }
        
        test.startTest();
        expireBenchPrep_Queueable ebpq = new expireBenchPrep_Queueable(oppIdToProdsMap);
        system.enqueueJob(ebpq);
        test.stopTest();
    }
}