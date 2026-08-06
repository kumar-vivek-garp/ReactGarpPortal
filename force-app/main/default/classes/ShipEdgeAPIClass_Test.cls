@isTest
private class ShipEdgeAPIClass_Test { 
    
    
    @isTest static void getShipEdgeAddOrder(){
       
        Account acc=new Account(name='Test');
        insert acc;
       
        
		Opportunity Opp=new Opportunity(Name = 'Test',stageName = 'New Lead', CloseDate = Date.today(),accountid=acc.id,Display_Invoice_Number__c = '68129',Customs_Cost__c = '1200',
                                               Payment_Method_New__c = 'Check',Products_SKU__c = '111-01950',Shipping_E_mail__c = 'test@testmail.com',Shipping_Phone_No__c = '5345353453',
                                               Shipping_First_Name__c = 'test', Shipping_Last_Name__c = 'last name test', Shipping_Company_Name__c = 'test1',
                                               Shipping_Address1__c = 'address 1',Shipping_Address2__c = 'address 2',Shipping_City__c = 'test city',Shipping_State__c = 'test state',Shipping_Postal_Code__c = '4234342',
                                               Shipping_Country__c = 'test coun',Billing_First_Name__c = 'test first',Billing_Last_Name__c = 'test last',Billing_Company__c = 'comp test',Billing_Address__c = 'add1',
            Billing_Address_Line_2__c ='add line1',Billing_City__c = 'test bill city',Billing_State_Text__c = 'Alaska',Billing_Zip_Postal__c = '2321',Billing_Country__c = 'test countr');
        insert Opp;
        
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;
        
        Product2 Prod1 = new Product2(Name = 'FRM 1 Early', Customs_Cost__c='5',productCode = 'FRM1E',Is_Shippable__c = TRUE, GL_Code__c = '4002', Family = 'Hardware', isActive = true);
        INSERT Prod1; 
        
        Product2 Prod2 = new Product2(Name = 'FRM Part 1 Scholarship Refund',Customs_Cost__c='7',Is_Shippable__c = TRUE, ProductCode = 'SAFRM1', GL_Code__c = '4003', Family = 'Hardware', isActive = true);
        INSERT Prod2; 
        
        PricebookEntry PE1 = new PricebookEntry(Pricebook2Id = activePricebook.Id, Product2Id = Prod1.Id, UnitPrice = 425.00, IsActive = true);
        INSERT PE1;
        
        PricebookEntry PE2 = new PricebookEntry(Pricebook2Id = activePricebook.Id, Product2Id = Prod2.Id, UnitPrice = 0.00, IsActive = true);
        INSERT PE2;
        
        OpportunityLineItem oppli1 = new OpportunityLineItem();
        oppli1.Quantity=5;
        oppli1.OpportunityId=opp.Id; 
        oppli1.UnitPrice = PE1.UnitPrice;
        oppli1.product2id= Prod1.Id;
        oppli1.PriceBookEntryId = PE1.Id;
        INSERT oppli1;
        
        OpportunityLineItem oppli2 = new OpportunityLineItem();
        oppli2.Quantity=1;
        oppli2.OpportunityId=opp.Id; 
        oppli2.UnitPrice = PE2.UnitPrice;
        oppli2.product2id= Prod2.Id;
        oppli2.PriceBookEntryId = PE2.Id;
        INSERT oppli2;
        Set<id> SetOpp=new Set<id>{Opp.id};
        
        Test.startTest();
        opp.Display_Invoice_Number__c = 'W3368129';
        update opp;
        ShipEdgeAPIClass.getShipEdgeAddOrder(SetOpp);
        ShipEdgeAPIClass.getShipEdgeGetOrder((String)Opp.Id);
        ShipEdgeAPIClass.cancelOrder((String)Opp.Id);
        ShipEdgeAPIClass.getShipEdgePing();
        
        opp.Display_Invoice_Number__c = 'W3368130';
        update opp;
        ShipEdgeAPIClass.getShipEdgeAddOrder(SetOpp);
        Test.stopTest();
    }
}