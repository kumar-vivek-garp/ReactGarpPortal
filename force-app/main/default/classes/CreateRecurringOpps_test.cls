@isTest
private class CreateRecurringOpps_test{
   
     Static Account account;
    
    static void testdata(){
        
        Account = new Account(Name = 'test',Member_Email__c= 'test@test.garp.com');
        insert account;
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'MEMI',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        insert prod;
		
        
        Product2 prod1 = new Product2(Name = 'Laptop X200',productCode = 'MEMS',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        insert prod1;
        
        
        Product2 prod2 = new Product2(Name = 'Laptop X200',productCode = 'MEMC',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        insert prod2;
        
        Product2 prod3 = new Product2(Name = 'Laptop X200',productCode = 'GSTTAX',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        insert prod3;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod3.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice3;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        
        PricebookEntry customPrice1 = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod1.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice1;
        
        
        PricebookEntry customPrice2 = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod2.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice2;
        
        
        PricebookEntry customPrice3 = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod3.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice3;
        
    }
    
    @isTest
    static void myUnitTest_2(){
        testdata();
        
        Opportunity opportunity = new Opportunity(Charge_Amount__c = 195,Charge_Amount_VAT__c = 2.5,Payment_Start_Date__c = System.today(),Payment_Frequency__c = 'Once',Payment_Status__c = 'Recurring',amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today(),Payment_Method_New__c = 'Credit Card');        
        insert opportunity;
        
        ChargentOrders__ChargentOrder__c order = [Select Id from ChargentOrders__ChargentOrder__c where Opportunity__c =: opportunity.Id];
             
        ChargentOrders__Transaction__c chargentTrans = new ChargentOrders__Transaction__c();
           
        chargentTrans.Opportunity__c = opportunity.iD;
        chargentTrans.ChargentOrders__Order__c = order.id;
        chargentTrans.ChargentOrders__Response_Status__c = 'Approved';
        chargentTrans.ChargentOrders__Amount__c = 123;
        chargentTrans.ChargentOrders__Type__c = 'Charge';
        chargentTrans.ChargentOrders__Recurring__c = true;
        chargentTrans.ChargentOrders__Gateway_Date__c = system.today()+1 ;
        insert chargentTrans;
        
        test.startTest();
        OpportunityHandler.stopRecurssion = false;
    	CreateRecurringOpps.CreateOpps(new Set<Id>{opportunity.Id},new Map<Id,ChargentOrders__Transaction__c>{opportunity.Id => chargentTrans});
        
        test.stopTest();
    }
    
   
     @isTest
    static void myUnitTest_3(){
        testdata();
        
        Opportunity opportunity = new Opportunity(Charge_Amount__c = 95,Charge_Amount_VAT__c = 2.5,Payment_Start_Date__c = System.today(),Payment_Frequency__c = 'Once',Payment_Status__c = 'Recurring',amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today(),Payment_Method_New__c = 'Credit Card');        
        insert opportunity;
        
        ChargentOrders__ChargentOrder__c order = [Select Id from ChargentOrders__ChargentOrder__c where Opportunity__c =: opportunity.Id];
        
        ChargentOrders__Transaction__c chargentTrans = new ChargentOrders__Transaction__c();
           
        chargentTrans.Opportunity__c = opportunity.iD;
        chargentTrans.ChargentOrders__Order__c = order.id;
        chargentTrans.ChargentOrders__Response_Status__c = 'Approved';
        chargentTrans.ChargentOrders__Amount__c = 123;
        chargentTrans.ChargentOrders__Type__c = 'Charge';
        chargentTrans.ChargentOrders__Recurring__c = true;
        chargentTrans.ChargentOrders__Gateway_Date__c = system.today()+1 ;
        insert chargentTrans;
        
        test.startTest();
        OpportunityHandler.stopRecurssion = false;
    	CreateRecurringOpps.CreateOpps(new Set<Id>{opportunity.Id},new Map<Id,ChargentOrders__Transaction__c>{opportunity.Id => chargentTrans});
        test.stopTest();
    }
    
     @isTest
    static void myUnitTest_4(){
        testdata();
        
        Opportunity opportunity = new Opportunity(Charge_Amount__c = 150,Charge_Amount_VAT__c = 2.5,Payment_Start_Date__c = System.today(),Payment_Frequency__c = 'Once',Payment_Status__c = 'Recurring',amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today(),Payment_Method_New__c = 'Credit Card');        
        insert opportunity;
        
        ChargentOrders__ChargentOrder__c order = [Select Id from ChargentOrders__ChargentOrder__c where Opportunity__c =: opportunity.Id];
        
        ChargentOrders__Transaction__c chargentTrans = new ChargentOrders__Transaction__c();
           
        chargentTrans.Opportunity__c = opportunity.iD;
        chargentTrans.ChargentOrders__Order__c = order.id;
        chargentTrans.ChargentOrders__Response_Status__c = 'Approved';
        chargentTrans.ChargentOrders__Amount__c = 123;
        chargentTrans.ChargentOrders__Type__c = 'Charge';
        chargentTrans.ChargentOrders__Recurring__c = true;
        chargentTrans.ChargentOrders__Gateway_Date__c = system.today()+1 ;
        insert chargentTrans;
        
        test.startTest();
        OpportunityHandler.stopRecurssion = false;
        CreateRecurringOpps.CreateOpps(new Set<Id>{opportunity.Id},new Map<Id,ChargentOrders__Transaction__c>{opportunity.Id => chargentTrans});
        test.stopTest();
    }
    
}