@isTest
public class BatchSyncSiteToCreateSageTest {
    @TestSetup
    static void createTestData() { 
        List<Opportunity> OppResults = TestDataFactory.createOpportunity(2);
        for(Opportunity opp : OppResults){
            Opp.Pricebook2Id = Test.getStandardPricebookId();
        }
        insert OppResults;
        
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode= 'FCBR',GL_Code__c = '4999',
                                   isActive = true,Is_Shippable__c = true,Family='IndividualMember',Customs_Cost__c = '5',Weight__c=5);
        insert p1;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = p1.Id,
                                                           UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        insert standardPrice1;
        
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = standardPrice1.Id,
                                                                   Site_Sync_Status__c = 'Create to Sync',
                                                                   UnitPrice = 550, Quantity = 1,Product_company__c='GRA Test');
        insert oppLineItem1;
    }
    
    @isTest 
    Public static void MyUnitTest1(){
        test.starttest(); 
        BatchSyncSiteToCreateSage batch = new BatchSyncSiteToCreateSage();
        database.executeBatch(batch,10); 
        Test.stoptest();
    }
}