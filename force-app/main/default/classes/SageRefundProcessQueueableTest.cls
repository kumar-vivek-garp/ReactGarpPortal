@isTest
public class SageRefundProcessQueueableTest {
    
    @isTest
    public static void unitTest(){
        
        List<Product_Refunds__c> ProductRefundsList = new List<Product_Refunds__c>();
        Map<Id,List<Product_Refunds__c>> inputMap = new  Map<Id,List<Product_Refunds__c>>();
        Map<String,ChargentOrders__Transaction__c> oppToTransactionMap = new Map<String,ChargentOrders__Transaction__c>();
        Map<Id,Id> switchTransMap = new Map<Id,Id>();
        Integer totalCountOpp = 1;
        
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',
                                   productCode = 'FRM1',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '5',Product_ID__c = 'SCRPE',GL_Code__c = '4999',Weight__c=5);
        insert p1;
        
        Product2 p2 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',
                                   productCode = 'FRM2E',Product_ID__c = '2022SCRPE2022',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '5',GL_Code__c = '4999',Weight__c=5);
        insert p2;
        
        Product2 p3 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',
                                   productCode = 'SCRME',Product_ID__c = '22SCRDefer',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '5',GL_Code__c = '4999',Weight__c=5);
        insert p3;
        
        // insert pricebook entry for the product
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                                          Product2Id = p1.Id,UnitPrice = 250,IsActive = true,
                                                          UseStandardPrice = false);
        insert standardPrice ;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                                          Product2Id = p2.Id,UnitPrice = 250,IsActive = true,
                                                          UseStandardPrice = false);
        insert standardPrice1 ;
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                                          Product2Id = p3.Id,UnitPrice = 250,IsActive = true,
                                                          UseStandardPrice = false);
        insert standardPrice2 ;
        
        Pricebook2 customPB = new Pricebook2(Name='GARP 2015/2016', isActive=true);
        insert customPB;
        
        PricebookEntry Entry2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p1.Id,UnitPrice = 250, IsActive = true);
        insert Entry2;
        
        PricebookEntry Entry3 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p2.Id,UnitPrice = 250, IsActive = true);
        insert Entry3;
        
        PricebookEntry Entry4 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p3.Id,UnitPrice = 250, IsActive = true);
        insert Entry4;
        Account acc = new Account();
        acc.Name = 'TEST CO';
        INSERT acc;
        
        /*List<Opportunity> OppResults = new List<Opportunity> ();
        OppResults = TestDataFactory.createOpportunity(totalCountOpp);
        OppResults[0].StageName = 'New Lead';
        insert OppResults;*/
        
        Opportunity OppResults = new Opportunity(accountId = acc.id,Auto_Renew__c = true,Payment_Start_Date__c = System.today(),Payment_Status__c='Recurring',
                                          Company__c = 'GARP',Payment_Frequency__c='Once',name='Test Name',StageName='Closed',
                                          ia_crm__Intacct_Transaction__c = 'Salesforce Deferral',CloseDate=system.today(),Charge_Amount__c=95);
        insert OppResults;
        
        /*ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = OppResults[0].id);
        insert order;*/
        
        ChargentOrders__ChargentOrder__c order = [select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: OppResults.id limit 1];
            
        ChargentOrders__Transaction__c payment = new ChargentOrders__Transaction__c(Opportunity__c = OppResults.id,ChargentOrders__Type__c = 'Charge',
                                                                              		ChargentOrders__Order__c = order.id,ChargentOrders__Gateway_Date__c=system.today(),
                                                                                    ChargentOrders__Response_Status__c= 'Approved',ChargentOrders__Tokenization__c ='test');
        insert payment;
        
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = OppResults.Id,PricebookEntryId = Entry2.Id,
                                                                  UnitPrice = 250,Product2Id = p1.Id,Quantity = 1,Product_company__c='GRA Test');
        insert oppLineItem;
        
		OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = OppResults.Id,PricebookEntryId = Entry3.Id,
                                                                  UnitPrice = 250,Product2Id = p2.Id,Quantity = 1,Product_company__c='GRA Test');
        insert oppLineItem1;
        
		OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = OppResults.Id,PricebookEntryId = Entry4.Id,
                                                                  UnitPrice = 250,Product2Id = p3.Id,Quantity = 1,Product_company__c='GRA Test');
        insert oppLineItem2;
        
        ProductRefundsList.add(new Product_Refunds__c (Status__c='Completed',Discount_Product_Code__c= 'FRM1',
                                                       Refund_amount__c =123,opportunity__c = OppResults.id,
                                                       product__c = p1.id));//,Payment_Order_Transaction__c = payment.id));*/
        
        ProductRefundsList.add(new Product_Refunds__c (Status__c='Completed',Discount_Product_Code__c= 'SCR',
                                                       Refund_amount__c =123,opportunity__c = OppResults.id,
                                                       product__c = p3.id));//,Payment_Order_Transaction__c = payment.id));*/
        //insert ProductRefundsList;                       
        
        Test.startTest();
        
        Set<id> SetProdID = new Set<id>();
        SetProdID.add((id)p1.id);
        SetProdID.add((id)p2.id);
        inputMap.put((id)OppResults.id,ProductRefundsList);
        oppToTransactionMap.put((String)OppResults.id,payment);  
        //switchTransMap.put(payment.Id,OppResults[0].id);
        OpportunityHandler.stopRecurssion = false;
        System.enqueueJob(new SageRefundProcessQueueable(inputMap,oppToTransactionMap,switchTransMap));
        //(Map<Id,List<Product_Refunds__c>> inputMap,Map<String,ChargentOrders__Transaction__c> oppTransactionMap,Map<Id,Id> switchTransactionMap){
        Test.stopTest();
    }
    
     @isTest
    public static void unitTest2(){
        
        List<Product_Refunds__c> ProductRefundsList = new List<Product_Refunds__c>();
        Map<Id,List<Product_Refunds__c>> inputMap1 = new  Map<Id,List<Product_Refunds__c>>();
        
        Map<String,ChargentOrders__Transaction__c> oppToTransactionMap1 = new Map<String,ChargentOrders__Transaction__c>();
        Map<Id,Id> switchTransMap = new Map<Id,Id>();
        Integer totalCountOpp = 1;
        
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',
                                   productCode = 'FRM1E',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '5',Product_ID__c = 'SCRPE',GL_Code__c = '4999',Weight__c=5);
        insert p1;
        
        // insert pricebook entry for the product
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                                          Product2Id = p1.Id,UnitPrice = 250,IsActive = true,
                                                          UseStandardPrice = false);
        insert standardPrice ;
                
        Pricebook2 customPB = new Pricebook2(Name='GARP 2015/2016', isActive=true);
        insert customPB;
        
        PricebookEntry Entry2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p1.Id,UnitPrice = 250, IsActive = true);
        insert Entry2;
        
        Account acc = new Account();
        acc.Name = 'TEST CO';
        INSERT acc;
        
        Opportunity OppResults1 = new Opportunity(accountId = acc.id,Auto_Renew__c = true,Payment_Start_Date__c = System.today(),Payment_Status__c='Recurring',
                                          Company__c = 'GARP',Payment_Frequency__c='Once',name='Test Name',StageName='Closed',
                                          ia_crm__Intacct_Transaction__c = 'Salesforce - Deferral',CloseDate=system.today(),Charge_Amount__c=95);
        insert OppResults1;
        
		ChargentOrders__ChargentOrder__c order = [select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: OppResults1.id limit 1];
            
        ChargentOrders__Transaction__c payment = new ChargentOrders__Transaction__c(Opportunity__c = OppResults1.id,ChargentOrders__Type__c = 'Charge',
                                                                              		ChargentOrders__Order__c = order.id,ChargentOrders__Gateway_Date__c=system.today(),
                                                                                    ChargentOrders__Response_Status__c= 'Approved',ChargentOrders__Tokenization__c ='test');
        insert payment;
        
        
		Opportunity OppResults = new Opportunity(accountId = acc.id,Auto_Renew__c = true,Payment_Start_Date__c = System.today(),Payment_Status__c='Recurring',
                                          Company__c = 'GARP',Payment_Frequency__c='Once',name='Test Name',StageName='Closed',
                                          ia_crm__Intacct_Transaction__c = 'Salesforce Deferral',CloseDate=system.today(),Charge_Amount__c=95);
        insert OppResults;
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = OppResults1.Id,PricebookEntryId = Entry2.Id,
                                                                  UnitPrice = 250,Product2Id = p1.Id,Quantity = 1,Product_company__c='GRA Test');
        insert oppLineItem;
        
        ProductRefundsList.add(new Product_Refunds__c (Status__c='Completed',Discount_Product_Code__c= 'FRM1',
                                                       Refund_amount__c =123,opportunity__c = OppResults.id,
                                                       product__c = p1.id));
        Test.startTest();
        
        Set<id> SetProdID = new Set<id>();
        SetProdID.add((id)p1.id);
        inputMap1.put((id)OppResults1.id,ProductRefundsList);
        oppToTransactionMap1.put((String)OppResults1.id,payment);  
        
        OpportunityHandler.stopRecurssion = false;
        
        System.enqueueJob(new SageRefundProcessQueueable(inputMap1,oppToTransactionMap1,switchTransMap));
        
		Test.stopTest();
    }

}