@isTest
private class AccountingExportCtrlTest {

    private static testMethod void test_HelperMethods() {
        AccountingExportCtrl.convertDate(System.today());
        
        AccountingExportCtrl.toDate(System.now());
        
        System.assertEquals('American Express', AccountingExportCtrl.getCardName('Amex'));
        System.assertEquals('First Data', AccountingExportCtrl.getCardName('Visa'));
        
        AccountingExportCtrl.getDocNumber(System.now(), 'American Express', false, false);
        AccountingExportCtrl.getDocNumber(System.now(), 'First Data', true, true);
        
        AccountingExportCtrl.getCompanyCode('GARP');
        AccountingExportCtrl.getCompanyCode('GRA');
        
        AccountingExportCtrl.newShipProd('ENC1B');
        AccountingExportCtrl.newShipProd('ENC2B');
        AccountingExportCtrl.newShipProd('FCBR');
        Map<String, Decimal> weightMap = AccountingExportCtrl.prodToWeightMap;
        
        AccountingExportCtrl expCtrl = new AccountingExportCtrl();
        expCtrl.getCompanies();
        expCtrl.getRenderKey();
        Temp_Product__mdt tmpProd = new Temp_Product__mdt(Company__c = 'GARP', Department__c = 'ADM', GL_Code__c = '4000', Product_Code__c = 'MISC', GL_Short_Title__c = 'Test Misc', Sort_Order__c = 1);
        
        AccountingExportCtrl.ProductInfo miscProdInfo = new AccountingExportCtrl.ProductInfo(tmpProd, 10, false);
    }
    
    private static testMethod void test_pageActions() {
        AccountingExportCtrl expCtrl = new AccountingExportCtrl();
        expCtrl.refreshPage();
        
        Product2 testProd = new Product2(Company__c = 'GARP', Acct_Dept_Code__c = 'Test_Dep', Acct_Prod_Code__c = 'Test_Prod', GL_Code__c = '4030Test', Acct_GL_Short_Title__c = 'Test Title');
        
        OpportunityLineItem test_oli = new OpportunityLineItem();
        test_oli.Product2 = testProd;
        
        Product_Refunds__c refund = new Product_Refunds__c();
        refund.Product__r = testProd;
        
        AccountingExportCtrl.ProductInfo prodInfoItem = new AccountingExportCtrl.ProductInfo(test_oli);
        AccountingExportCtrl.ProductInfo prodInfoRefund = new AccountingExportCtrl.ProductInfo(refund);
        
        AccountingExportCtrl.LineItemInfo item = new AccountingExportCtrl.LineItemInfo(test_oli, 100, 'GARP');
        AccountingExportCtrl.LineItemInfo refundItem = new AccountingExportCtrl.LineItemInfo(refund, 100, 'GRA');
        AccountingExportCtrl.LineItemInfo refundItem2 = new AccountingExportCtrl.LineItemInfo(prodInfoRefund, 100);
        
        expCtrl.dataRows.add(new AccountingExportCtrl.ExportData(System.today(), 'American Express', item));
        expCtrl.dataRows.add(new AccountingExportCtrl.ExportData(System.today(), 'First Data', refundItem));
        expCtrl.dataRows.add(new AccountingExportCtrl.ExportData(System.today(), 'First Data', refundItem2));
        
        expCtrl.exportCsv();
        
        expCtrl.lastStDate = expCtrl.lastStDate.addDays(-1);
        expCtrl.exportCsv();
        
        for(String oneCode : new List<String>{'ENC1E','ENC2E','FRM1E','FRM2E'}) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.Product2 = new Product2(GL_Code__c = '4001', ProductCode = oneCode);
            expCtrl.getProductKey(oli, null, 'GRA');
            
            oli.Product2 = new Product2(GL_Code__c = '4002', ProductCode = oneCode);
            expCtrl.getProductKey(oli, null, 'GARP');
        }
        
        for(String oneCode : new List<String>{'FRM1H','FRM2H','FCBR','CBR'}) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.Product2 = new Product2(GL_Code__c = '4030', ProductCode = oneCode);
            expCtrl.getProductKey(oli, null, 'GARP');
            
            oli.Product2 = new Product2(GL_Code__c = '4000', ProductCode = oneCode);
            expCtrl.getProductKey(oli, null, 'GRA');
        }
        
    }
    
    private static testMethod void test_fetchData() {
        List<Product2> prods = TestingHelper.createFRMProds();
        
        Opportunity oppty = TestingHelper.createOppty('Apex Test Oppty', true);
        Opportunity oppty1 = TestingHelper.createOppty('Apex Test Oppty1', true);
        
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        for(Product2 prod : prods) {
            if(prod.Name == 'Misc Product') {
                lineItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, Product2Id = prod.Id, Quantity = 1, UnitPrice = 10, Description = 'Canadian Customs Duty'));
            }else {
                lineItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, Product2Id = prod.Id, Quantity = 1, UnitPrice = 10));
            }
        }
        insert lineItems;
        
        ChargentBase__Gateway__c gateway = new ChargentBase__Gateway__c(Name = 'paypal garp');
        insert gateway;
		
		
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = oppty.id);
        insert order;
        
		
        ChargentOrders__ChargentOrder__c order1 = new ChargentOrders__ChargentOrder__c(Opportunity__c = oppty1.id);
        insert order1;
        
        List<ChargentOrders__Transaction__c> tranList = new List<ChargentOrders__Transaction__c>();
        ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c(
            Opportunity__c = oppty.Id, ChargentOrders__Type__c = 'Charge', ChargentOrders__Response_Status__c = 'Approved', ChargentOrders__Gateway_Date__c = System.now(), ChargentOrders__Payment_Method__c = 'Credit Card', ChargentOrders__Credit_Card_Type__c = 'Amex', ChargentOrders__Gateway__c = gateway.Id,ChargentOrders__Order__c = order.id);
        tranList.add(trans);
        
        ChargentOrders__Transaction__c trans2 = new ChargentOrders__Transaction__c(
            Opportunity__c = oppty1.Id, ChargentOrders__Type__c = 'Refund', ChargentOrders__Response_Status__c = 'Approved', ChargentOrders__Gateway_Date__c = System.now().addDays(1), ChargentOrders__Payment_Method__c = 'Credit Card', ChargentOrders__Credit_Card_Type__c = 'Amex', ChargentOrders__Gateway__c = gateway.Id,ChargentOrders__Order__c = order1.id);
        tranList.add(trans2);
        insert tranList;
        
        Product_Refunds__c refund = new Product_Refunds__c(Opportunity__c = oppty1.Id, Product__c = prods[3].Id, Refund_amount__c = 5, Payment_Order_Transaction__c =trans2.Id);
        insert refund;
        
        Product_Refunds__c refund2 = new Product_Refunds__c(Opportunity__c = oppty1.Id, Product__c = prods[2].Id, Refund_amount__c = 2, Payment_Order_Transaction__c =trans2.Id);
        insert refund2;
        
        Product_Refunds__c refund3 = new Product_Refunds__c(Opportunity__c = oppty1.Id, Product__c = prods[4].Id, Refund_amount__c = 2, Payment_Order_Transaction__c =trans2.Id);
        insert refund3;
        
        Test.startTest();
        AccountingExportCtrl expCtrl = new AccountingExportCtrl();
        expCtrl.fetchDataByDate(System.today(), System.today().addDays(2), 'All');
        Test.stopTest();
    }
    
    
    private static testMethod void test_HelperMethods1() {
        AccountingExportCtrl1.convertDate(System.today());
        
        AccountingExportCtrl1.toDate(System.now());
        
        System.assertEquals('American Express', AccountingExportCtrl1.getCardName('Amex'));
        System.assertEquals('First Data', AccountingExportCtrl1.getCardName('Visa'));
        
        AccountingExportCtrl1.getDocNumber(System.now(), 'American Express', false, false);
        AccountingExportCtrl1.getDocNumber(System.now(), 'First Data', true, true);
        
        AccountingExportCtrl1.getCompanyCode('GARP');
        AccountingExportCtrl1.getCompanyCode('GRA');
        
        AccountingExportCtrl1.newShipProd('ENC1B');
        AccountingExportCtrl1.newShipProd('ENC2B');
        AccountingExportCtrl1.newShipProd('FCBR');
        Map<String, Decimal> weightMap = AccountingExportCtrl1.prodToWeightMap;
        
        AccountingExportCtrl1 expCtrl = new AccountingExportCtrl1();
        expCtrl.getCompanies();
        expCtrl.getRenderKey();
        Temp_Product__mdt tmpProd = new Temp_Product__mdt(Company__c = 'GARP', Department__c = 'ADM', GL_Code__c = '4000', Product_Code__c = 'MISC', GL_Short_Title__c = 'Test Misc', Sort_Order__c = 1);
        
        AccountingExportCtrl1.ProductInfo miscProdInfo = new AccountingExportCtrl1.ProductInfo(tmpProd, 10, false);
    }
    
    private static testMethod void test_pageActions1() {
        AccountingExportCtrl1 expCtrl = new AccountingExportCtrl1();
        expCtrl.refreshPage();
        
        Product2 testProd = new Product2(Company__c = 'GARP', Acct_Dept_Code__c = 'Test_Dep', Acct_Prod_Code__c = 'Test_Prod', GL_Code__c = '4030Test', Acct_GL_Short_Title__c = 'Test Title');
        
        OpportunityLineItem test_oli = new OpportunityLineItem();
        test_oli.Product2 = testProd;
        
        Product_Refunds__c refund = new Product_Refunds__c();
        refund.Product__r = testProd;
        
        AccountingExportCtrl1.ProductInfo prodInfoItem = new AccountingExportCtrl1.ProductInfo(test_oli);
        AccountingExportCtrl1.ProductInfo prodInfoRefund = new AccountingExportCtrl1.ProductInfo(refund);
        
        AccountingExportCtrl1.LineItemInfo item = new AccountingExportCtrl1.LineItemInfo(test_oli, 100, 'GARP');
        AccountingExportCtrl1.LineItemInfo refundItem = new AccountingExportCtrl1.LineItemInfo(refund, 100, 'GRA');
        AccountingExportCtrl1.LineItemInfo refundItem2 = new AccountingExportCtrl1.LineItemInfo(prodInfoRefund, 100);
        
        expCtrl.dataRows.add(new AccountingExportCtrl1.ExportData(System.today(), 'American Express', item));
        expCtrl.dataRows.add(new AccountingExportCtrl1.ExportData(System.today(), 'First Data', refundItem));
        expCtrl.dataRows.add(new AccountingExportCtrl1.ExportData(System.today(), 'First Data', refundItem2));
        
        expCtrl.exportCsv();
        
        expCtrl.lastStDate = expCtrl.lastStDate.addDays(-1);
        expCtrl.exportCsv();
        
        for(String oneCode : new List<String>{'ENC1E','ENC2E','FRM1E','FRM2E'}) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.Product2 = new Product2(GL_Code__c = '4001', ProductCode = oneCode);
            expCtrl.getProductKey(oli, null, 'GRA');
            
            oli.Product2 = new Product2(GL_Code__c = '4002', ProductCode = oneCode);
            expCtrl.getProductKey(oli, null, 'GARP');
        }
        
        for(String oneCode : new List<String>{'FRM1H','FRM2H','FCBR','CBR'}) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.Product2 = new Product2(GL_Code__c = '4030', ProductCode = oneCode);
            expCtrl.getProductKey(oli, null, 'GARP');
            
            oli.Product2 = new Product2(GL_Code__c = '4000', ProductCode = oneCode);
            expCtrl.getProductKey(oli, null, 'GRA');
        }
        
    }
    
    private static testMethod void test_fetchData1() {
        List<Product2> prods = TestingHelper.createFRMProds();
        
        Opportunity oppty = TestingHelper.createOppty('Apex Test Oppty', true);
        Opportunity oppty1 = TestingHelper.createOppty('Apex Test Oppty1', true);
        
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        for(Product2 prod : prods) {
            if(prod.Name == 'Misc Product') {
                lineItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, Product2Id = prod.Id, Quantity = 1, UnitPrice = 10, Description = 'Canadian Customs Duty'));
            }else {
                lineItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, Product2Id = prod.Id, Quantity = 1, UnitPrice = 10));
            }
        }
        insert lineItems;
        
        ChargentBase__Gateway__c gateway = new ChargentBase__Gateway__c(Name = 'paypal garp');
        insert gateway;
		
		
		
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = oppty.id);
        insert order;
        
		
        ChargentOrders__ChargentOrder__c order1 = new ChargentOrders__ChargentOrder__c(Opportunity__c = oppty1.id);
        insert order1;
        
		
        
        List<ChargentOrders__Transaction__c> tranList = new List<ChargentOrders__Transaction__c>();
        ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c(
            Opportunity__c = oppty.Id, ChargentOrders__Type__c = 'Charge', ChargentOrders__Response_Status__c = 'Approved', ChargentOrders__Gateway_Date__c = System.now(), ChargentOrders__Payment_Method__c = 'Credit Card', ChargentOrders__Credit_Card_Type__c = 'Amex', ChargentOrders__Gateway__c = gateway.Id,ChargentOrders__Order__c = order.id);
        tranList.add(trans);
        
        ChargentOrders__Transaction__c trans2 = new ChargentOrders__Transaction__c(
            Opportunity__c = oppty1.Id, ChargentOrders__Type__c = 'Refund', ChargentOrders__Response_Status__c = 'Approved', ChargentOrders__Gateway_Date__c = System.now().addDays(1), ChargentOrders__Payment_Method__c = 'Credit Card', ChargentOrders__Credit_Card_Type__c = 'Amex', ChargentOrders__Gateway__c = gateway.Id,ChargentOrders__Order__c = order1.id);
        tranList.add(trans2);
        insert tranList;
        
        Product_Refunds__c refund = new Product_Refunds__c(Opportunity__c = oppty1.Id, Product__c = prods[3].Id, Refund_amount__c = 5, Payment_Order_Transaction__c =trans2.Id);
        insert refund;
        
        Product_Refunds__c refund2 = new Product_Refunds__c(Opportunity__c = oppty1.Id, Product__c = prods[2].Id, Refund_amount__c = 2, Payment_Order_Transaction__c =trans2.Id);
        insert refund2;
        
        Product_Refunds__c refund3 = new Product_Refunds__c(Opportunity__c = oppty1.Id, Product__c = prods[4].Id, Refund_amount__c = 2, Payment_Order_Transaction__c =trans2.Id);
        insert refund3;
        
        Test.startTest();
        AccountingExportCtrl1 expCtrl = new AccountingExportCtrl1();
        expCtrl.fetchDataByDate(System.today(), System.today().addDays(2), 'All');
        Test.stopTest();
    }      
}