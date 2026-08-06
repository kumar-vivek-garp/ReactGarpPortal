@isTest
public class OrderTransactionInvocableBatch_Test {
	@isTest
    static void testBatch(){
        Integer totalCount = 5;
        Integer totalCountOpp = 1;
        
        // insert product 
        List<Product2> OppProduct2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'FRM1',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '5',GL_Code__c = '4999',Weight__c=5);
        OppProduct2List.add(p1);
        Product2 p2 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',productCode = 'FRM1E',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '6',GL_Code__c = '4999',Weight__c=6);
        OppProduct2List.add(p2);
        insert OppProduct2List;
        
        
        // insert pricebook entry for the product
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice1);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[1].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice2);
        insert PricebookEntryList ;
        
        Opportunity opp = new Opportunity();
        Opp.Pricebook2Id = Test.getStandardPricebookId();
        Opp.stagename = 'New Lead';
        opp.Ups_Stage__c = 'Sent to GT';
        opp.Name = 'Test';
        opp.CloseDate = system.today();
        insert opp;
        
        Order_Transaction_item__c oti = new Order_Transaction_item__c();
        oti.Opportunity__c = opp.Id;
        oti.Status__c = 'Approved';
        insert oti;
        
        test.startTest();
        OrderTransactionInvocableBatch_Sch myClass = new OrderTransactionInvocableBatch_Sch ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}