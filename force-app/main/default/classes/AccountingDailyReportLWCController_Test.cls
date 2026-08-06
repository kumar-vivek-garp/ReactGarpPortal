@isTest
private class AccountingDailyReportLWCController_Test {
    
    @isTest
    static void UnitTest() {
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp0 = new Opportunity(Name = 'Test0', accountId = acc.id,ia_crm__Intacct_Transaction__c = 'Test Intacct',
                                           stageName = 'New Lead',Payment_Method_New__c = 'Check',
                                           Sage_Paid_Date__c = system.today(), closedate = system.today()+ 15);  
        insert opp0;
        
        Opportunity opp = new Opportunity(Name = 'Test', accountId = acc.id,ia_crm__Intacct_Transaction__c = 'Test Intacct',
                                          stageName = 'Closed',Payment_Method_New__c = 'Check',
                                          Sage_Paid_Date__c = system.today(), closedate = system.today()+ 15);  
        insert opp;
        Opportunity opp2 = new Opportunity(Name = 'Test', accountId = acc.id,ia_crm__Intacct_Transaction__c = 'Test Intacct',
                                           stageName = 'Closed',Payment_Method_New__c = 'TestPay',
                                           Sage_Paid_Date__c = system.today(), closedate = system.today()+ 15);  
        insert opp2;
        Opportunity opp1 = new Opportunity(Name = 'Test1', accountId = acc.id,stageName = 'New Lead',
                                           closedate = system.today()+ 15);  
        
        Product2 prod = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'CHLF', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        insert prod;
        PricebookEntry pricebook = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        
        insert pricebook;
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem( OpportunityId = opp.Id,Product2Id = prod.Id,
                                                                          UnitPrice = 100.00,Quantity = 1,Product_ID__c ='CHLF',PricebookEntryId = pricebook.Id);
        INSERT opportunityLineItem;
        OpportunityLineItem opportunityLineItem1 = new OpportunityLineItem( OpportunityId = opp.Id,Product2Id = prod.Id,
                                                                           UnitPrice = 100.00,Quantity = 1,Product_ID__c ='CHLF',PricebookEntryId = pricebook.Id);
        INSERT opportunityLineItem1;
        OpportunityLineItem opportunityLineItem2 = new OpportunityLineItem( OpportunityId = opp2.Id,Product2Id = prod.Id,
                                                                           UnitPrice = 100.00,Quantity = 1,Product_ID__c ='CHLF',PricebookEntryId = pricebook.Id);
        INSERT opportunityLineItem2;
        
        Order_Transaction_Item__c orderTransItem = new Order_Transaction_Item__c(Status__c = ' Approved',Opportunity__c = opp0.id);
        insert orderTransItem;
        
        Test.startTest();
        AccountingDailyReportLWCController.getAccountingDailyReport(new List<String>{'Test Intacct'},new List<String>{'Testpay1','Testpay','Testpay2'},system.today().adddays(-1),system.today(),'est');
        AccountingDailyReportLWCController.insertOrderTransactionItems(new List<String>{opp.id});
        AccountingDailyReportLWCController.insertOrderTransactionItems(new List<String>{opp1.id});
        Test.stopTest();
        
    }
}