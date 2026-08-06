@istest
public class YardstickApi_test
{
    
    static opportunity opp;
    static void testdata()
    {
        
        
        Account a1 = new Account(name = 'Test Account1');
        insert a1;
        
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Merchant_ID__c = 'test-4',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
        opp = new Opportunity(Gateway__c = chrgGtway.id, amount = 123,Name = 'Test', CurrencyIsoCode = 'USD', 
                              Eligible_for_Membership_Extension__c = false,Company__c = 'GARP', accountId = a1.id,stageName = 'New Lead',
                              Billing_Email__c='test@test.com',Program__c = 'Print' ,closedate = system.today()+ 15,Pay_By_Wire_Check__c=false, Billing_First_Name__c ='vivek', Billing_Last_Name__c ='kathi');        
        insert opp; 
        
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'CBR',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        OpportunityLineItem oppli = new OpportunityLineItem();
        oppli.Quantity=2;
        oppli.OpportunityId=opp.Id; 
        oppli.TotalPrice=10;
        oppli.PriceBookEntryId = customPrice.Id;
        insert oppli;
        
    }
    
    public static testmethod void myunittest()
    {
        test.starttest();
        
        
        
        testdata();
        
        opportunity opportunity2 = [select Id, name,stagename,Billing_Email__c, Billing_First_Name__c, Billing_Last_Name__c from Opportunity where id =:opp.id];
        opportunity2.stagename='Closed';
        string oid = opportunity2.id;
        string programid ='14747';
        string FirstName =opportunity2.Billing_First_Name__c;
        string LastName =opportunity2.Billing_Last_Name__c;
        update opportunity2;
             
        yardStickApi.CreateUserToken(opportunity2.Billing_Email__c,oid,programid,FirstName,LastName);
        
        test.stopTest();
        
    }
}