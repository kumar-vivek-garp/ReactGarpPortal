@isTest
public class BulkOrderTriggerHandler_Test {
    
    @testSetUp
    static void TestSetupMethod(){
        
        Account acc=new Account(name='Test');
        insert acc;
        
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;
        
        String[] pc = new String[]{'FRM1H','FRM2H','CBRHB','SCRH','SHIPBULK'};
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
            pelist.add(CusPentry);
        }
        INSERT pelist;
        
        Team_Registration__c Reg = new Team_Registration__c(BD_Rep_Email__c='test123@gmail.com',FRM_Part_I_Books__c=1,FRM_Part_II_Books__c=1,
                                                            FRR_Books__c =1,Account__c = acc.id,Name='test team reg',SCR_Books__c=1,Shipping_Cost__c=1);
        insert Reg;
        
        Map<String,Bulk_Orders__c> bulkOrderMap = new Map<String,Bulk_Orders__c>();
        for(Integer i=0;i<5;i++){
            Bulk_Orders__c bo = new Bulk_Orders__c (Ups_Stage__c='New Order',Shipping_Country__c = 'AU', Weight__c = '30',Team_Registration__c= Reg.id,Country_Code_for_UPS__c='US',Customs_Cost__c='15',Duty_Tax_to_Garp__c=True);
            insert bo;
            bulkOrderMap.put(bo.id,bo);   
        }
        
    }
    
    @isTest
    static void unitTest(){
        
        
        Map<String,Bulk_Orders__c> bulkOrderMap = new Map<String,Bulk_Orders__c>();
        for(Bulk_Orders__c bo : [SELECT Id,Ups_Stage__c,Team_Registration__c,Country_Code_for_UPS__c,Customs_Cost__c from Bulk_Orders__c]){
            bo.Status__c = 'Approved';
            bulkOrderMap.put(bo.id,bo);   
        }
        
        Test.startTest();
        update bulkOrderMap.values();
        delete bulkOrderMap.values()[0];
        
        Test.stopTest();
    }
}