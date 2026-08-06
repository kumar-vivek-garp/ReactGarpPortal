@isTest
public class provisionEBooks_Queueable_Test {
	@TestSetup
    static void createTestData() {
        Integer totalCount = 1;
        Integer totalCountOpp = 1;
        
        List<Exam_Group__c> examGrpResults = TestDataFactory.createExamGroup(totalCount);
        insert examGrpResults;
        
        // insert product 
        List<Product2> OppProduct2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'FCBR',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '5',GL_Code__c = '4999',Weight__c=5);
        OppProduct2List.add(p1);
        Product2 p2 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',productCode = 'FRM1X',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '6',GL_Code__c = '4999',Weight__c=6);
        OppProduct2List.add(p2);
        Product2 p3 = new Product2(Name = ' Test Product3',Description='Test Product Entry3 For Product',productCode = 'MEMC',isActive = true,Is_Shippable__c = true,Family='AffiliateMember',
                                   Customs_Cost__c = '6',GL_Code__c = '4999',Weight__c=6);
        OppProduct2List.add(p3);
        insert OppProduct2List;
        
        
        // insert pricebook entry for the product
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice1);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[1].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice2);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[2].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice3);
        insert PricebookEntryList ;
        
        List<Opportunity> OppResults=TestDataFactory.createOpportunity(totalCountOpp);
        for(Opportunity opp : OppResults){
            Opp.Pricebook2Id = Test.getStandardPricebookId();
        }
        insert OppResults;
        
        
        List<Contact> ContactResults=TestDataFactory.createContacts(totalCount);
        ContactResults[0].AccountId = OppResults[0].AccountId;
        insert ContactResults;
        
        
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[0].Id,UnitPrice = 550,
                                                                   Quantity = 1,Product_company__c='GRA Test');
        OpportunityLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[1].Id,UnitPrice = 550,
                                                                   Quantity = 1,Product_company__c='GRA Test');
        OpportunityLineItemList.add(oppLineItem2);
        OpportunityLineItem oppLineItem3 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[2].Id,UnitPrice = 550,
                                                                   Quantity = 1,Product_company__c='GRA Test');
        OpportunityLineItemList.add(oppLineItem3);
        insert OpportunityLineItemList;
        
        Mobius_Products__c prod = new Mobius_Products__c();
        prod.Name = 'FRM Current Year';
        prod.Year__c = '2022';
        insert prod;
        
        Mobius_Products__c prod1 = new Mobius_Products__c();
        prod1.Name = 'FRM 1 2022';
        prod1.Year__c = '2022';
        prod1.Access_Duration_in_Months__c = 12;
        prod1.Exam__c = 'FRM';
        prod1.Part__c = 'I';
        insert prod1;
    }
    
    @isTest
    static void testFRMBook(){
        Opportunity opp = [Select Id from Opportunity Limit 1];
        test.startTest();
        provisionEBooks_Queueable queueable = new provisionEBooks_Queueable('FRM1',new set<Id>{opp.id},false,null);
        system.enqueueJob(queueable);
        test.stopTest();
    }
    
    @isTest
    static void testFBRBook(){
        Opportunity opp = [Select Id from Opportunity Limit 1];
        
        EBook_Key__c key = new EBook_Key__c();
        key.Key__c = 'TEST'; 
        key.Access_Duration_in_Months__c = 12;
        key.Type__c = 'FFR'; 
        insert key;
        test.startTest();
        provisionEBooks_Queueable queueable = new provisionEBooks_Queueable('FFR',new set<Id>{opp.id},false,2560);
        system.enqueueJob(queueable);
        test.stopTest();
    }
}