@isTest
Public class BatchSyncSiteToSage_Test{
    
    
    @TestSetup
    static void setupData() {
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
                                                                   Site_Sync_Status__c = 'Ready To Sync',
                                                                   UnitPrice = 550, Quantity = 1,Product_company__c='GRA Test');
        insert oppLineItem1;
        
    }
    
    @isTest 
    Public static void MyUnitTest1(){
        test.starttest();
        BatchSyncSiteToSageScheduler sv1= new BatchSyncSiteToSageScheduler();
        system.schedule('Test Schedule', '0 0 0 * * ?', sv1);
        Test.stoptest();
    }

	@isTest 
    Public static void MyUnitTest2(){
        test.starttest();
        List<String> sageFieldsList = new List<String>();
        sageFieldsList.add('projectid');
        sageFieldsList.add('SHIPPING_COUNTRY');
        BatchSyncSiteToSage batch = new BatchSyncSiteToSage(null,sageFieldsList);
	  database.executeBatch(batch,10);

        Test.stoptest();
    }
}