@isTest
public class B2BCreateOpportunityClsTest {
    @TestSetup
    static void createTestData() {
        List<Opportunity> OppResults=TestDataFactory.createOpportunity(1);
          List<Product2> OppProduct2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'RAIH',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
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
        
         String studyMaterialRT = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Study_Materials');
        String EventRT = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Events');
  		Team_Registration__c reg1 = new Team_registration__c();
        reg1.Name='test team reg1'; 
        reg1.Exam_Type__c = 'FRM I';
        reg1.Start_Date__c = system.today() ;
        reg1.End_Date__c=system.today();
        reg1.Seats_Allowed__c =1; 
        reg1.Include_Exam_or_Courses__c = true;
        reg1.Shipping_Contact_Name__c = 'test';
        reg1.Shipping_Contact_Phone__c = '99078979876878';
        reg1.Shipping_Address__c = 'test';
        reg1.Shipping_Postal_Code__c = 'test';
        reg1.Shipping_City__c = 'test';
        reg1.BD_Rep_Email__c = 'test@test.garp.com';
        insert reg1;
        
        B2B_Deal_Item__c bdi = new B2B_Deal_Item__c();
		bdi.B2B_Deal__c = reg1.id;
        bdi.RecordTypeId = studyMaterialRT;
        bdi.Discounted_RAI_Hard_Books__c = 2;
        bdi.End_Date__c = system.today().addMonths(10);
        insert bdi;
    }
    static testMethod void unitTest1(){
       	Test.startTest();
        Product2 pr = [Select Id From Product2 limit 1];
        Account acc = [Select Id From Account limit 1];
        PricebookEntry pbe = [Select Id,UnitPrice From PricebookEntry limit 1];
        B2BCreateOpportunityCls.getProductName(pr.Id);
        B2BCreateOpportunityCls.getAccountName(acc.Id);
        List<B2BCreateOpportunityCls.OpportunityLineItemWrapper> pliwrapList = new List<B2BCreateOpportunityCls.OpportunityLineItemWrapper>();
        B2BCreateOpportunityCls.OpportunityLineItemWrapper bw = new B2BCreateOpportunityCls.OpportunityLineItemWrapper();
        bw.priceBookEntryId = pbe.Id;
        bw.productId = pr.Id;
        bw.quantity = 1;
        bw.unitPrice = pbe.UnitPrice;
        pliwrapList.add(bw);
        B2B_Deal_Item__c bi = [Select Id From B2B_Deal_Item__c limit 1];
        B2BCreateOpportunityCls.createOpportunityLineItems(pliwrapList,acc.Id,bi.Id);
        Test.stopTest();
    }

    static testMethod void unitTest2(){
       	Test.startTest();
        
        B2B_Deal_Item__c bi = [Select Id From B2B_Deal_Item__c limit 1];
        B2BCreateOpportunityCls.getDefaultAccount(bi.Id);
        B2BCreateOpportunityCls.getdefaultProductListName(bi.Id);
        Test.stopTest();
    }
}