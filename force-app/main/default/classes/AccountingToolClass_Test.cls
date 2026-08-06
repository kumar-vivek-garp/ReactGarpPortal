@isTest
public class AccountingToolClass_Test {
    
    @isTest 
    static void unitTest_1(){
        
        Account acc=new Account(name='Test');
        insert acc;
        
        Pricebook2 activePricebook = new Pricebook2( Id = Test.getStandardPricebookId(), IsActive = TRUE);
        UPDATE activePricebook;  
        
        Id pricebookId = activePricebook.Id;
        
        Product2 MEMI = new Product2(Company__c = 'GARP', Name = 'Individual Membership', ProductCode = 'MEMI', GL_Code__c = '4040', 
                                     Family = 'Hardware', IsActive = true);
        Product2 MEMC = new Product2(Company__c = 'GARP', Name = 'Certified Membership', ProductCode = 'MEMC', GL_Code__c = '4040', 
                                     Family = 'Hardware', IsActive = true);
        INSERT MEMI;
        INSERT MEMC;
        
        
       	 PricebookEntry MEMIPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = MEMI.Id, UnitPrice = 10000, IsActive = true);
         PricebookEntry MEMCPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = MEMC.Id, UnitPrice = 10000, IsActive = true);
		 INSERT MEMIPBE;
         INSERT MEMCPBE;
        
        
		Opportunity opp = new Opportunity(name = 'Test Opportunity1', Amount = 195, CloseDate = Date.newInstance(2012, 4, 17), 
                                          StageName = 'Closed', Display_Invoice_Number__c = 'W123', AccountId = acc.Id);
        insert opp;
        
        list<OpportunityLineItem> lineItemListMEMI = new list<OpportunityLineItem> ();
        OpportunityLineItem lineItemMEMI = new OpportunityLineItem(UnitPrice=3.0,Quantity = 1,OpportunityId = opp.id,
                                                                   PricebookEntryId = MEMIPBE.id);
        lineItemListMEMI.add(lineItemMEMI);
        
        OpportunityLineItem lineItemMEMI1 = new OpportunityLineItem(UnitPrice=3.2,Quantity = 1,OpportunityId = opp.id,
                                                                    PricebookEntryId = MEMCPBE.id);
        lineItemListMEMI.add(lineItemMEMI1);
        insert lineItemListMEMI;
        
        Test.startTest();
        
        opp = [select id,name,CloseDate,StageName,Display_Invoice_Number__c from opportunity];
        
        List<OpportunityLineItem> oliList = AccountingToolClass.getAllProducts((String)opp.Display_Invoice_Number__c);
        AccountingToolClass.createNewOppAndOli((String)opp.Display_Invoice_Number__c,oliList,'MEMI');
        
        Test.stopTest();
    }
}