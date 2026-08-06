@istest
public class testFreeInvoiceController {
    static Account acc ;
    static Opportunity opp; 
    static ChargentOrders__Transaction__c chargentTrans;
    static Contact contact; 
    
    static testMethod void myUnitTest_1() {
        
        ChargentBase__Gateway__c gate = new ChargentBase__Gateway__c(name = 'paypal garp');
        insert gate;
        
        Product2 prod = new Product2(Name = 'enrollment',productCode = 'FRM1',GL_Code__c = '4020',Family = 'Hardware',isActive = true, Company__c  = 'GARP');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        Acc = new Account(Name = 'test');
        insert acc;
                
        contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        Id manualRecId = RecordTypeHelper.GetRecordTypeId('Opportunity','Manual'); 
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                              company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',
                              Program__c = 'Print' ,closedate = system.today()+ 15, 
                              Display_Invoice_Number__c = 'W123');        
        
        insert opp;
        
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opp.id);
        insert order;  
        
               
        OpportunityLineItem oppli3 = new OpportunityLineItem();
        oppli3.Quantity=1;
        oppli3.OpportunityId=opp.Id; 
        oppli3.TotalPrice=10;
        //oppli3.ProductCode = 'FRM1';
        oppli3.PriceBookEntryId = standardPrice.Id;
        oppli3.Product2Id = prod.Id;
        insert oppli3;
              
        ChargentOrderTransactionTriggerHandler.OppListToUpdate.clear();
        Opportunity opp1 = [select Id, Display_Invoice_Number__c from Opportunity];
        system.debug('opp1==========>'+opp1);
        system.debug('opp.Display_Invoice_Number__c======>'+opp1.Display_Invoice_Number__c);
        system.debug('oppli3=======>'+oppli3);
        system.debug('prod8.ProductCodec======>'+oppli3.Product2.ProductCode);
        system.debug('product2.GL_Code__c======>'+oppli3.Product2.GL_Code__c);
        test.startTest();
        freeInvoiceController.cloneOpp(opp1.Display_Invoice_Number__c);
        test.stopTest();
    }
}