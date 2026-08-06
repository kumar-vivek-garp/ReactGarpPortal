@isTest
public class BulkOrderTriggerHandlerHelper_Test {
    
    Static Opportunity opp;
    Static Map<String,PricebookEntry> pbeMap = new Map<String,PricebookEntry>();
    
    @testSetUp
    static void TestSetupMethod(){
        
        Account acc = new Account(name='Test');
        insert acc;
        
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;
        
        String[] pc = new String[]{'FRM1H','DISCFRMEPP','DISCSCREPP','FRM2H','CBRHB','SCRH','RAIH','SHIPBULK'};
            List<Product2> ProdList = new  List<Product2>();
        for(String pcode : pc){
            Product2 Prod = new Product2(Name = 'FRM 1 Early', Customs_Cost__c='5',productCode = pcode,Is_Shippable__c = TRUE, GL_Code__c = '4002', Family = 'Hardware', isActive = true);
            ProdList.add(Prod) ;
        }
        insert ProdList;
        Pricebook2 customPB = new Pricebook2(Name='GARP 2015/2016', isActive=true);
        insert customPB;
        List<PricebookEntry> pelist = new List<PricebookEntry>();
        for(Product2 p : ProdList){
            PricebookEntry pentry = new PricebookEntry(Pricebook2Id = activePricebook.Id, Product2Id = p.Id, UnitPrice = 425.00, IsActive = true);
            insert pentry;
            PricebookEntry CusPentry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = 425.00, IsActive = true);
            insert CusPentry;
           // pelist.add(CusPentry);
            //if(p.productCode == 'DISCFRMEPP')
                pbeMap.put(p.ProductCode,CusPentry);
        }
     //   INSERT pelist;
        System.debug('pbeMap-->'+pbeMap);
        Team_Registration__c Reg = new Team_Registration__c(BD_Rep_Email__c='test123@gmail.com',FRM_Part_I_Books__c=1,FRM_Part_II_Books__c=1,
                                                            FRR_Books__c =1,Account__c = acc.id,Name='test team reg',SCR_Books__c=1,Shipping_Cost__c=1);
        insert Reg;
        
        Country_Code__c cc = new Country_Code__c(Name='US',Country__c='United States',VAT__c = 8000);
        insert cc;
        
        String studyMaterialRT = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Study_Materials');
        B2B_Deal_Item__c bdi = new B2B_Deal_Item__c();
		bdi.B2B_Deal__c = Reg.id;
        bdi.RecordTypeId = studyMaterialRT;
        bdi.FRM_Part_I_Hard_Books__c = 4;
        bdi.Discount_Percent__c = 20;
        bdi.Discount_Type__c = 'EPP';
        bdi.FRM_Part_II_Hard_Books__c = 34;
        bdi.SCR_Hard_Books__c = 34;
        bdi.FRR_Hard_Books__c = 34;
        bdi.RAI_Hard_Books__c = 34;
        bdi.Shipping_Cost__c = 45.2;
        bdi.Shipping_Country__c = 'United States';
        insert bdi;
        
        List<Bulk_Orders__c> bulkOrderMap = new List<Bulk_Orders__c>();
        for(Integer i=0;i<5;i++){
            Bulk_Orders__c bo = new Bulk_Orders__c (Ups_Stage__c='New Order',Shipping_Country__c = 'AU', Weight__c = '30',Team_Registration__c= Reg.id,B2B_Deal_Item__c = bdi.id,
                                                    Status__c = 'Approved',Country_Code_for_UPS__c='US',Customs_Cost__c='15',Duty_Tax_to_Garp__c=True);
            //insert bo;
            bulkOrderMap.add(bo);   
        }
        insert bulkOrderMap;
        //Status__c = 'Cancelled'
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false, 
                                           company__c = 'Payment', accountId = acc.id,stageName = 'Closed',
                                           Shipping_Country__c = 'test',Program__c = 'Print',Payment_Method_New__c = 'Credit Card',
                                           CardType__c = 'AMEX',closedate = system.today()+ 15);  
        insert opp;
        
        
    }
    
    @isTest
    static void unitTest(){
 		TestSetupMethod();
        Map<String,Bulk_Orders__c> bulkOrderMap = new Map<String,Bulk_Orders__c>();
        for(Bulk_Orders__c bo : [SELECT Id,Ups_Stage__c,B2B_Deal_Item__r.Shipping_Cost__c,B2B_Deal_Item__r.Discount_Type__c,SCR_Books__c,B2B_Deal_Item__r.Discount_Percent__c,FRM_Part_I_Books__c,FRM_Part_II_Books__c,
                                 		B2B_Deal_Item__r.FRM_Part_II_Hard_Books__c,B2B_Deal_Item__r.FRM_Part_I_Hard_Books__c,Team_Registration__c,Country_Code_for_UPS__c,Customs_Cost__c from Bulk_Orders__c]){
            bo.Status__c = 'Approved';
            bulkOrderMap.put(bo.id,bo);   
        }
        
        
        update bulkOrderMap.values();
        Test.startTest();
        //BulkOrderTriggerHandlerHelper.discountCalculation(opp,bulkOrderMap.values()[0],pbeMap);
        delete bulkOrderMap.values()[0];    
        Test.stopTest();
    }
    
}