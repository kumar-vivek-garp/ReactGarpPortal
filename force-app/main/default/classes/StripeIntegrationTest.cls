@isTest
public class StripeIntegrationTest {
    
    
    @TestSetup
    static void testdata(){
        
        Account account= new Account(Name = 'test',Member_Email__c= 'test@test.garp.com');
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
    static void striptestmethod(){  
        Account account = [Select Id from Account limit 1];
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
    static void striptestmethod1(){  
        Account account = [Select Id from Account limit 1];
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
        
        
        
        Stripe_Integration__e st = new Stripe_Integration__e();
        st.Action_Type__c = 'Update'; 
        st.Opportunity_Id__c = opportunity.Id; 
        st.Subscription_Id__c = 'testdata';
        st.Vat_Amount__c = 19;
        st.Charge_Amount__c = 150; 
         Test.setMock(HttpCalloutMock.class, new StripeRecurringMock());
        Test.startTest();
        opportunity.Stripe_Subscription_Id__c = 'test_testid';
        opportunity.Stripe_Outbound_Type__c = 'Update';
        opportunity.Payment_Start_Date__c = system.today();
        update opportunity;
        OpportunityHandler.stopRecurssion = false;
        // Step 2: Publish the event
        System.enqueueJob(new StripeIntegrationQueueable(new List<Stripe_Integration__e>{st}));
        
        Test.stopTest(); 
    } 
    
    @isTest
    static void striptestmethod2(){  
        Account account = [Select Id from Account limit 1];
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
        
        
        Stripe_Integration__e st = new Stripe_Integration__e();
        st.Action_Type__c = 'Cancel'; 
        st.Opportunity_Id__c = opportunity.Id;
        //st.Product_Price_Type__c = opportunity.Charge_Amount__c+'';  
        st.Subscription_Id__c = 'testdata';
        
        Test.startTest();
        opportunity.Payment_Status__c = 'Stopped';
        opportunity.Stripe_Subscription_Id__c = 'test_testid';
        opportunity.Stripe_Outbound_Type__c = 'Cancel';
        update opportunity;
         Test.setMock(HttpCalloutMock.class, new StripeRecurringMock());
        OpportunityHandler.stopRecurssion = false;
        // Step 2: Publish the event
      System.enqueueJob(new StripeIntegrationQueueable(new List<Stripe_Integration__e>{st}));
        
        Test.stopTest(); 
    }
    
    
    @isTest
    static void striptestmethod3(){ 
        Account account = [Select Id from Account limit 1];
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
        
        
        Stripe_Integration__e st = new Stripe_Integration__e();
        st.Action_Type__c = 'Create'; 
        st.Opportunity_Id__c = opportunity.Id;  
        st.Customer_Id__c = 'testcusid';
        Test.setMock(HttpCalloutMock.class, new StripeRecurringMock());
        Test.startTest();
        OpportunityHandler.stopRecurssion = false; 
        System.enqueueJob(new StripeIntegrationQueueable(new List<Stripe_Integration__e>{st}));
        Test.stopTest(); 
    }
    
    @isTest
    static void striptestmethod4(){ 
        Account account = [Select Id from Account limit 1];
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
        
        
        Stripe_Integration__e st = new Stripe_Integration__e();
        st.Action_Type__c = 'Create'; 
        st.Opportunity_Id__c = opportunity.Id;  
        st.Customer_Id__c = 'testcusid';
        Test.setMock(HttpCalloutMock.class, new StripeTaxRecurringMock());
        Test.startTest();
        OpportunityHandler.stopRecurssion = false; 
        System.enqueueJob(new StripeIntegrationQueueable(new List<Stripe_Integration__e>{st}));
        Test.stopTest(); 
    }
    
     // Mock class for successful refund
    private class StripeRecurringMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"id":"sub_1SKlPkAyydB05IeXDY5j1hFb","object":"subscription","items":{"object":"list","data":[{"price":{"id":"price_1SKlPkAyydB05IeXIFpMbqMQ"}}]},"quantity":1,"status":"active"}');
            return res;
        }
    }
    
      // Mock class for successful refund
    private class StripeTaxRecurringMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"subtotal":5000,"total":5500,"amount_due":5500,"currency":"USD","total_tax_amounts":[{"amount":300,"inclusive":false,"tax_rate":"txr_12345"},{"amount":200,"inclusive":false,"tax_rate":"txr_67890"}]}');
            return res;
        }
    }
}