@isTest
private class ProdRefundsOrderCreate_QueueableTest {
    
    Static Product_Refunds__c refund,refund1;
    Static Opportunity opp,opp1;
    
    @TestSetup
    static void createTestData() {
        Account acc = new Account(Name = 'Test');                
        insert acc;
        // insert product
        List<Product2> Product2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'ENC2X',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4011');
        Product2List.add(p1);
        insert Product2List;
        
                
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        // insert pricebook entry for the product
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice1);
        insert PricebookEntryList ;
                
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
                
        opp1 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp1;
                
        ChargentOrders__ChargentOrder__c order = [select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: opp.id];
        
        Legacy_Transaction__c Chargent = new Legacy_Transaction__c(Opportunity__c=opp.Id,
                                                                          Type__c='Charge',
                                                                          Response_Status__c='Approved');
        insert Chargent;
        
        refund = new Product_Refunds__c (Status__c='Completed',Cancel_E_book__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = opp.id,product__c = Product2List[0].id,Legacy_Transaction__c = Chargent.id);
        insert refund;
        
        refund1 = new Product_Refunds__c (Status__c='Completed',Cancel_E_book__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = opp1.id, product__c = Product2List[0].id);
        insert refund1;
    } 
        
    @isTest static void testProductRefundsOrder(){
        
        createTestData();
        test.startTest();
        System.enqueueJob(new ProdRefundsOrderCreate_Queueable(new set<id>{refund.id,refund1.id}));
        test.stopTest();
    }
}