@isTest
public class OpportunityLineItemTriggerClass_Test {

    
    @isTest static void unitTest(){
        
        Map<String,List<OpportunityLineItem>> OppIdOLIMap = new Map<String,List<OpportunityLineItem>>();
        List<OpportunityLineItem> oliitems = new List<OpportunityLineItem>();
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Id manualRecId = RecordTypeHelper.GetRecordTypeId('Opportunity','Manual'); 
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                          company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',
                                          Program__c = 'Print' ,closedate = system.today()+ 15, 
                                          Display_Invoice_Number__c = 'W123');        
        insert opp;
        
        Product2 prod = new Product2(Name = 'enrollment',productCode = 'FRM1',GL_Code__c = '4020',Family = 'Hardware',isActive = true, Company__c  = 'GARP');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
		ia_crm__Intacct_User_Dimension__c IuD = new ia_crm__Intacct_User_Dimension__c(Name = 'test');
        insert IuD;
		
        OpportunityLineItem oppli = new OpportunityLineItem();
        oppli.Quantity=2;
        oppli.OpportunityId=opp.Id; 
        oppli.TotalPrice=10;
        oppli.PriceBookEntryId = standardPrice.Id;
        oppli.Product_ID__c = prod.productCode ;
        oppli.Site_Code__c = IuD.id ;
        oliitems.add(oppli);      
        insert oliitems;

        ia_crm__Sales_Order__c sOrder = new ia_crm__Sales_Order__c(Name ='W123');
        insert sOrder;
        
        ia_crm__Sales_Order_Item__c sorderitems = new ia_crm__Sales_Order_Item__c(
            ia_crm__Opportunity__c = opp.id,
            ia_crm__Sales_Order__c = sOrder.id,
            ia_crm__Item__c = prod.productCode
        );
        insert sorderitems;
                
        OppIdOLIMap.put(String.valueOf(opp.id),oliitems);
		
        Test.startTest();
        System.enqueueJob(new OpportunityLineItemQueueableClass(OppIdOLIMap));
        Test.stopTest();
    }   
    
    
}