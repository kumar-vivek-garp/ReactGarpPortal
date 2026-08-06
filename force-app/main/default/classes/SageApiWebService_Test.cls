@isTest
private class SageApiWebService_Test {
    
    static Map<String,List<OpportunityLineItem>> OppIdOLIMap = new Map<String,List<OpportunityLineItem>>();
	static List<OpportunityLineItem> oliitems = new List<OpportunityLineItem>();
	static Opportunity opp;
    static PricebookEntry standardPrice ;
    static Product2 prod;
    
    @TestSetup
    static void createtestdata(){
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp1 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                           company__c = 'Payment', accountId = Acc.id,stageName = 'New Lead',
                                           closedate = system.today()+ 15);  
        insert opp1;
        
        Id manualRecId = RecordTypeHelper.GetRecordTypeId('Opportunity','Manual'); 
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                          company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',
                                          Program__c = 'Print' ,closedate = system.today()+ 15, 
                                          Display_Invoice_Number__c = 'W123',Refund_Opportunity__c = opp1.Id);        
        
        insert opp;
        
        insert(new Product_Refunds__c (Status__c='Completed',Cancel_ERP_Enrollment__c = True,Cancel_ERP2__c = True,Cancel_ERP1__c = True,Cancel_E_book__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             			opportunity__c = opp1.id));	
        
        prod = new Product2(Name = 'enrollment',productCode = 'FRM1',GL_Code__c = '4020',Family = 'Hardware',isActive = true, Company__c  = 'GARP');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
    }
    
    @isTest static void unitTest_1(){
        
        createtestdata();
        
        ia_crm__Intacct_User_Dimension__c IuD = new ia_crm__Intacct_User_Dimension__c(Name = 'Test');
        insert IuD;
        
        ia_crm__Sales_Order__c sOrder = new ia_crm__Sales_Order__c(Name ='W123');
        insert sOrder;
        
        ia_crm__Sales_Order_Item__c sorderitems = new ia_crm__Sales_Order_Item__c(
            ia_crm__Opportunity__c = opp.id,
            ia_crm__Sales_Order__c = sOrder.id,
            ia_crm__Item__c = prod.productCode
        );
        insert sorderitems;
        
        OpportunityLineItem oppli = new OpportunityLineItem();
        oppli.Quantity=2;
        oppli.OpportunityId=opp.Id; 
        oppli.TotalPrice=10;
        oppli.PriceBookEntryId = standardPrice.Id;
        oppli.Product_ID__c = prod.productCode ;
        oppli.Site_Code__c = IuD.id ;
        oliitems.add(oppli);
        insert oliitems;
        
        System.debug('oliitems'+oliitems);
        System.debug('String.valueOf(opp.id)'+String.valueOf(opp.id));
        OppIdOLIMap.put(String.valueOf(opp.id),oliitems);
       
        
        Test.setMock(HttpCalloutMock.class, new SageAPIClassCallout());   
        Test.startTest();
        //SageApiWebService.reallocation('W123', System.today()/*today or higher date value*/);
        SageApiWebService.updateOppLineItems(OppIdOLIMap);
        List<String> sageFieldsList = new List<String>();
        sageFieldsList.add('projectid');
        sageFieldsList.add('SHIPPING_COUNTRY');
        sageFieldsList.add('QUANTITY');
        
        SageApiWebService.updateOppFieldsLineItems(OppIdOLIMap,sageFieldsList);
        Test.stopTest();
    }
    
    @isTest static void unitTest_2(){
        
        createtestdata();
        SageApiWebService.xmlString('');
        Test.startTest();
        System.enqueueJob(new SageAPIReallocation_Queueable(new Set<id>{opp.id}));
        Test.stopTest();
    }
}