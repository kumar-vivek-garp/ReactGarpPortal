@isTest
public class GARP_MC_MS_BC_Shipping_Test {
    
    
    @isTest
    static void unitTest_1(){
        
        Country_Code__c cc = new Country_Code__c(LetterCode__c='US');
        insert cc;
        
        Shipping_Charge__c sc = new Shipping_Charge__c();
        sc.Product_Code__c = 'Test';
        sc.GL_Code__c = 'Test';
        sc.Country_Code__c = cc.id;
        insert sc;
        
        GARP_MS_Shipping.shipOrderCustomer cust = new GARP_MS_Shipping.shipOrderCustomer();
        cust.contactId = 'Test';
        
        GARP_MS_Shipping.shipOrderAddress addr = new GARP_MS_Shipping.shipOrderAddress();
        addr.countryCode = 'US';
        
        GARP_MS_Shipping.shipOrderLineItem item = new GARP_MS_Shipping.shipOrderLineItem();
        item.glCode = 'Test';
        item.productCode = 'Test';
        item.quantity = 2;
        
        GARP_MS_Shipping.shipOrder order = new GARP_MS_Shipping.shipOrder();
        order.customer = cust;
        order.address = addr;
        order.lineItems = new List<GARP_MS_Shipping.shipOrderLineItem>{item};
            
            string req = json.serialize(order);
        test.startTest();
        
        GARP_MC_Shipping.getShippingRateByProduct('Test','Test','US');
        GARP_MC_Shipping.getShippingRate(req);
        GARP_BC_Shipping.getShippingRate(order);
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_2(){
        Account acc = new Account(Name = 'test');
        insert acc;
        
        Contact  contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com');
        insert contact;
        
        User user = [select Id from User where contactId = :contact.Id];
        
        test.startTest();
        
        System.runas(user){
            
            GARP_MC_MemberNotifications.getExamAlerts();
            GARP_MC_MemberNotifications.setMemberNotificationAsViewed('Test');
            
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_3(){
        
        List<String> code1 = new List<String>{'FRM1H','FRM2H','SCRH','CBRHI','FBRHB'}; 
		List<String> code2 = new List<String>{'SHIPFRM1','SHIPFRM2','SHIPSCR','SHIPFRR','SHIPFFR'}; 
                
		Country_Code__c cc = new Country_Code__c(LetterCode__c='Test');
        insert cc;
        
        GARP_MS_Shipping.shipOrderCustomer cust = new GARP_MS_Shipping.shipOrderCustomer();
        cust.contactId = 'Test';
        
        GARP_MS_Shipping.shipOrderAddress addr = new GARP_MS_Shipping.shipOrderAddress();
        addr.countryCode = 'Test';
        
        test.startTest();
        
        for(Integer i=0;i<5;i++)
        {
            
            Shipping_Charge__c sc = new Shipping_Charge__c();
            sc.Product_Code__c = code1[i];
            sc.GL_Code__c = 'Test';
            sc.Country_Code__c = cc.id;
            insert sc;
            
            GARP_MS_Shipping.shipOrderLineItem item = new GARP_MS_Shipping.shipOrderLineItem();
            item.glCode = 'Test';
            item.productCode = code1[i];
            item.quantity = i+2;
            
            GARP_MS_Shipping.shipOrder order = new GARP_MS_Shipping.shipOrder();
            order.customer = cust;
            order.address = addr;
            order.lineItems = new List<GARP_MS_Shipping.shipOrderLineItem>{item};
                
			List<Product2> prodlist = new List<Product2>();
            Product2 prod = new Product2(isActive = true,Name = 'Laptop X200',productCode =code2[i] ,Weight__c=4,GL_Code__c = 'Test',Family = 'Hardware');
            prodlist.add(prod);
            
            Product2 prod1 = new Product2(isActive = true,Name = 'Laptop X200',productCode =code1[i] ,Weight__c=2,GL_Code__c = 'Test',Family = 'Hardware');
            prodlist.add(prod1);
            insert prodlist;
            
            Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        	Update standardPricebook;
                        
            List<PricebookEntry>  PricebookList = new List<PricebookEntry> ();
            
            for(Integer j=0;j<2;j++)
            {
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodlist[j].Id,UnitPrice = 10000, IsActive = true);
                PricebookList.add(standardPrice);               
            }
            insert PricebookList;      
            
            GARP_BC_Shipping.stageShippingOpportunityLineItems(order);
            
        }
        test.stopTest();
    }
    
}