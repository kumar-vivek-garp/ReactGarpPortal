@isTest
public class paymentUtils_Test {
    @isTest
    static void testEvent(){
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'AFREE',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(
            Name = 'Test',
            ChargentBase__Active__c = TRUE,
            ChargentBase__Test_Mode__c = TRUE
        );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Id manualRecId = RecordTypeHelper.GetRecordTypeId('Opportunity','Manual'); 
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',RecordTypeID = manualRecId,Inst_Sale_Service_End_Date__c=system.today()+ 15,Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print',closedate = system.today()+ 15);        
        insert opp;
        
        OpportunityLineItem oppli = new OpportunityLineItem();
        oppli.Quantity=2;
        oppli.OpportunityId=opp.Id; 
        oppli.TotalPrice=10;
        oppli.PriceBookEntryId = standardPrice.Id;
        insert oppli;
        
        test.startTest();
        paymentUtils.publishPaymentEvent(opp.Id, 0.00, 'Approved');
        test.stopTest();
    }
}