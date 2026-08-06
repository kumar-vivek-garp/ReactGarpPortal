@isTest
private class batchAddProcessingFee_Test {
    
    static Account acc ;
    static Opportunity opp; 
   
    static void testData(){ 
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'prfee',isActive = true);
        insert prod;
    
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 50.00, IsActive = true);
        insert standardPrice;
     
        Acc = new Account(Name = 'test');
        insert acc;
         
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opp.id,PricebookEntryId = standardPrice.id,Quantity = 1,UnitPrice = 0.00);
        insert lineItem;
        
        
   }
        
        
   Static testMethod Void unit_test1()
    {
        testdata();
        test.startTest();
        batchAddProcessingFee b = new batchAddProcessingFee();
        database.executeBatch(b);
        test.stopTest();
    }}