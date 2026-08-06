@isTest
public class GARP_Shipping_test {

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
        
        GARP_MS_Shipping.getShippingRate(order);
        GARP_MS_Shipping.getShippingRate('Test', 'Test', 'US');
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_2(){
        
        List<String> code1 = new List<String>{'FRM1H','FRM2H','SCRH','CBRHB','FBRHB'}; 
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
    
    @isTest
    public static void testVerifyAddress(){
        Test.setMock(HttpCalloutMock.class, new UpsXmlAddressValidationRequestMock(TRUE));
        
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.createForm('form');
        insert new GARP_StripeSettings__c(
            Name = 'StripeSettings',
            Is_Active__c = true,
            Use_Stripe__c = true,
            Server_Side_API_Key__c = 'test',
            Client_Side_API_Key__c = 'testclientkey'
        );
        
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = new GARP_BC_Registration.verifyExistingCustomerInfo();
        verifyExistingCustomerInfo.firstName = 'joe';
        verifyExistingCustomerInfo.lastName = 'smith';
        verifyExistingCustomerInfo.email = 'joe@joe.com';
        verifyExistingCustomerInfo.leadId = NULL;
        verifyExistingCustomerInfo.formKey = 'form';
        verifyExistingCustomerInfo.cta = NULL;
        verifyExistingCustomerInfo.allowMemberPublicRegistration = FALSE;
        
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        
        GARP_BC_Shipping.verifyAddressInfo verifyAddressInfo = new GARP_BC_Shipping.verifyAddressInfo();
        verifyAddressInfo.hasShipping = True;
        verifyAddressInfo.billingSameAsShipping = False;
        verifyAddressInfo.billingAddress = new GARP_Common.address();
        verifyAddressInfo.billingAddress.country = 'United States';
        verifyAddressInfo.billingAddress.province = 'New Jersey';
        verifyAddressInfo.billingAddress.postalCode = '07310';
        verifyAddressInfo.billingAddress.street1 = '111 Town Square Place';
        verifyAddressInfo.billingAddress.street2 = '14th Floor';
        verifyAddressInfo.billingAddress.street3 = 'In the back';
        verifyAddressInfo.billingAddress.city = 'JERSEY CITY';
        verifyAddressInfo.billingAddress.phone = '1234567890';
        verifyAddressInfo.shippingAddress = new GARP_Common.address();
        verifyAddressInfo.shippingAddress.country = 'United States';
        verifyAddressInfo.shippingAddress.province = 'New Jersey';
        verifyAddressInfo.shippingAddress.postalCode = '07310';
        verifyAddressInfo.shippingAddress.street1 = '111 Town Square Place';
        verifyAddressInfo.shippingAddress.street2 = '14th Floor';
        verifyAddressInfo.shippingAddress.street3 = 'In the back';
        
        verifyAddressInfo.shippingAddress.city = 'JERSEY CITY';
        verifyAddressInfo.shippingAddress.phone = '1234567890';
        //verifyAddressInfo.selectedProducts = new List<GARP_BC_Orders.productInfo>();
        
        GARP_MS_Shipping.verifyAddress(verifyAddressInfo);
    }
    
    @isTest
    public static void testVerifyAddress1(){
        Test.setMock(HttpCalloutMock.class, new UpsXmlAddressValidationRequestMock(TRUE));
        
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.createForm('form');
        
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = new GARP_BC_Registration.verifyExistingCustomerInfo();
        verifyExistingCustomerInfo.firstName = 'joe';
        verifyExistingCustomerInfo.lastName = 'smith';
        verifyExistingCustomerInfo.email = 'joe@joe.com';
        verifyExistingCustomerInfo.leadId = NULL;
        verifyExistingCustomerInfo.formKey = 'form';
        verifyExistingCustomerInfo.cta = NULL;
        verifyExistingCustomerInfo.allowMemberPublicRegistration = FALSE;
        
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);        
    }
    
    @isTest
    public static void testVerifyAddress2(){
        Test.setMock(HttpCalloutMock.class, new UpsXmlAddressValidationRequestMock(TRUE));
        test.startTest();
        GARP_MS_Shipping.verifyShippingAddress('111 Town Square Place', '14th Floor', 'JERSEY CITY', 'New Jersey', '07310', 'US');
        test.stopTest();
    }
    
    @isTest
    static void getShippingRateTest(){
        
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
        
            
        test.startTest();
        
        GARP_MS_Shipping.getShippingRate('Test','Test','US');
        GARP_MS_Shipping.getShippingRate(order);
        
        GARP_Common.address shippingAddress = new GARP_Common.address();
        shippingAddress.country = 'United States';
        shippingAddress.province = 'New Jersey';
        shippingAddress.postalCode = '07310';
        shippingAddress.street1 = '111 Town Square Place';
        shippingAddress.street2 = '14th Floor';
        shippingAddress.street3 = 'In the back';
        
        GARP_TestFactory.createCountryCodes();
        MAP<String, Country_Code__c> mapCountryCodes = GARP_BC_Shipping.getCountryCodesMap();
        
        List<String> prodsAUX = new List<String>{'FRM1H:FRM1H:4040:100'};
        Set<String> prodsStudy = new Set<String>{'FRM1H'};
        GARP_TestFactory.createProducts(prodsAUX, new Set<String>{}, prodsStudy, prodsStudy);
        MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(new List<String>{'FRM1H'}, null);         
        PricebookEntry pbe = mapProdByCodes.get('FRM1H');
        GARP_BC_Orders.productInfo pi = new GARP_BC_Orders.productInfo(pbe);
        
        List<GARP_BC_Orders.productInfo> selectedProducts = new List<GARP_BC_Orders.productInfo>();
        selectedProducts.add(pi);
        GARP_BC_Shipping.getShippingRate(shippingAddress, selectedProducts, mapCountryCodes);
        
        GARP_BC_Shipping.getBulkShippingRate('United States', 'FRM1',4,Null);
        test.stopTest();
    }
    
    @isTest
    static void getShippingRateTest2(){
                
        GARP_Common.address shippingAddress = new GARP_Common.address();
        shippingAddress.country = 'United States';
        shippingAddress.province = 'New Jersey';
        shippingAddress.postalCode = '07310';
        shippingAddress.street1 = '111 Town Square Place';
        shippingAddress.street2 = '14th Floor';
        shippingAddress.street3 = 'In the back';
        
        GARP_TestFactory.createCountryCodes();
        MAP<String, Country_Code__c> mapCountryCodes = GARP_BC_Shipping.getCountryCodesMap();
        
        List<String> prodsAUX = new List<String>{'FRM1H:FRM1H:4040:100'};
        Set<String> prodsStudy = new Set<String>{'FRM1H'};
        GARP_TestFactory.createProducts(prodsAUX, new Set<String>{}, prodsStudy, prodsStudy);
        MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(new List<String>{'FRM1H'}, null);         
        PricebookEntry pbe = mapProdByCodes.get('FRM1H:4040');
        GARP_BC_Orders.productInfo pi = new GARP_BC_Orders.productInfo(pbe);
        
        List<GARP_BC_Orders.productInfo> selectedProducts = new List<GARP_BC_Orders.productInfo>();
        selectedProducts.add(pi);
        
        test.startTest();
        
        GARP_BC_Shipping.getShippingRate(shippingAddress, selectedProducts, mapCountryCodes);
        
        test.stopTest();
    }
}