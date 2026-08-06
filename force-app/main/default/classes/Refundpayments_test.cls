@isTest
public class Refundpayments_test {

    static Account account ;
    static Opportunity opportunity; 
    static ChargentBase__Gateway__c chrgGtway;
    static Product_Refunds__c refund;
    static Product_Refunds__c refund1;
    static Legacy_Transaction__c payment;
    static OpportunityLineItem lineItem ;
    static Contract contract;
    
    static void testData(){
        
        chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Merchant_ID__c = 'dasghjtru548709-4',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
        account = new Account(Name = 'test');
        insert account;
         
        opportunity = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity; 
		
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opportunity.id);
        insert order;
        
        payment = new Legacy_Transaction__c(Opportunity__c = opportunity.id,Type__c = 'Charge', Response_Status__c= 'Approved');
        insert payment;
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'FRM1',GL_Code__c = '4999',Family = 'Hardware');
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'Laptop X200',productCode = 'MEMW',GL_Code__c = '4999',Family = 'Hardware');
        insert prod1;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        lineItem = new OpportunityLineItem(Quantity = 12,unitPrice = 12,OpportunityId = opportunity.id,PricebookEntryId = standardPrice.id);
        insert lineItem;
        lineItem = new OpportunityLineItem(Quantity = 12,unitPrice = 12,OpportunityId = opportunity.id,PricebookEntryId = standardPrice1.id);
        insert lineItem;
        
        refund = new Product_Refunds__c (Refund_amount__c =123,opportunity__c = opportunity.id,product__c = prod.id,Status__c='Completed',Take_Membership__c = true);
        insert refund;
        
        refund1 = new Product_Refunds__c (Refund_amount__c =123,opportunity__c = opportunity.id,product__c = prod1.id,Status__c='Completed',cancel_wiley__C = true,wiley_quantity__C =10.00);
        insert refund1;
    }
    
    static testMethod void unitTest_1(){
        
        test.startTest();
        testData();
        Apexpages.StandardController std = new Apexpages.StandardController(payment);
        refundPayments wrpr = new refundPayments(std);
        
        refundPayments.wrapperOpps opps = new refundPayments.wrapperOpps(lineItem,payment);
        opps.isSelected = true;
        opps.objProductRefund = refund;
        opps.dAmount = 123;
        wrpr.lstWrapper = new refundPayments.wrapperOpps[]{opps};
        wrpr.saveData();
        wrpr.loadLineItems(payment );
        test.stopTest();
    }
}