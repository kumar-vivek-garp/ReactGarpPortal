@isTest
public class OpportunityProductEntryClsTest {
	 @TestSetup
    static void createTestData() {
        List<Opportunity> OppResults=TestDataFactory.createOpportunity(1);
        OppResults[0].StageName ='New Lead';
        OppResults[0].Billing_Country__c = 'United States';
        OppResults[0].Billing_State_Text__c = 'New Jersey';
         insert OppResults;
        List<Product2> OppProduct2List = new List<Product2>(); 
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'FRM1',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '5',GL_Code__c = '4999',Weight__c=5,Tax_Authority__c = 'SGP');
        OppProduct2List.add(p1);
        insert OppProduct2List;
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        Pricebook2 prb = new Pricebook2();
        prb.Id = Test.getStandardPricebookId();
        prb.IsActive = true;
        update prb;
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice1);
        insert PricebookEntryList ;
        
        
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[0].Id,UnitPrice = 250,
                                                                   Quantity = 1,Product_company__c='GRA Test');
         insert oppLineItem1;
    }
    static testMethod void unitTest1(){
       	Test.startTest();
        Opportunity opp = [Select Id,Display_Invoice_Number__c,Billing_Country__c,Billing_State_Text__c,Shipping_Country__c,Account.Name,AccountId From Opportunity where  StageName = 'New Lead' LIMIT 1];
        Product2 pro = [Select Id From Product2 LIMIT 1];
        OpportunityProductEntryCls.getOpportunityProducts(opp.Display_Invoice_Number__c);
         OpportunityProductEntryCls.getPriceBookEntry(pro.Id);
        Test.stopTest();
    }
    
    static testMethod void delateOppline(){
       	Test.startTest();
        OpportunityLineItem opp = [Select Id From OpportunityLineItem  LIMIT 1];
        OpportunityProductEntryCls.createOpportunityLineItems(new List<OpportunityLineItem>{opp});
        OpportunityProductEntryCls.dateleOpportunityLineItem(opp.Id);
        Test.stopTest();
    }
     static testMethod void calculateStripe(){
       	Test.startTest();
        OpportunityLineItem opp = [Select Id,OpportunityId From OpportunityLineItem  LIMIT 1];
        OpportunityProductEntryCls.calculateStripeTax(opp.OpportunityId); 
        Test.stopTest();
    }
    
}