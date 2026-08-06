@isTest
public class AccountingLWCToolController_Test {
    
    @isTest static void unitTest(){
        
        Account acc=new Account(name='Test');
        insert acc;

        Opportunity Opp=new Opportunity(Name = 'Test',stageName = 'New Lead', CloseDate = Date.today(),accountid=acc.id,
                                         ia_crm__Intacct_Transaction__c = 'Salesforce - Internal Refund',Display_Invoice_Number__c = 'W7896');
                                        
        
        
        insert opp;
        
        Product2 prod = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',
                                     productCode = 'SCR',isActive = true,Is_Shippable__c = true,
                                     Customs_Cost__c = '5',Class__c='Test',Department__c = 'testdept',Weight__c=5,GL_Code__c='4020');
        insert prod;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 customPB = new Pricebook2(Name = 'GARP 2015/2016', isActive=true);
        insert customPB;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = prod.Id,UnitPrice = 250,IsActive = true);
        insert standardPrice;
        
        PricebookEntry customPBEntry = new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = prod.Id,UnitPrice = 250,IsActive = true);
        insert customPBEntry;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id,Product2Id = prod.Id,PricebookEntryId = customPBEntry.Id,UnitPrice = 7000,Description='test',Quantity = 5,Product_company__c='GRA Test');
        
        insert oppLineItem;
        
        Test.startTest();
        
        AccountingLWCToolController.createDeferralRefund('W7896');
        
        Test.stopTest();
    }
    
}