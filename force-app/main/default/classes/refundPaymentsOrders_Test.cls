@isTest
public class refundPaymentsOrders_Test {
    
	Static ChargentOrders__Transaction__c trans;
    Static ChargentOrders__Transaction__c trans1;
    Static OpportunityLineItem oppLineItem;
    Static OpportunityLineItem oppLineItem1;
    Static Opportunity opp;
    Static Product_Refunds__c refund;
    Static Product_Refunds__c refund1;
    Static Exam_Attempt__c ea;
    
    
    static void setupData() {
       
        Id profileId1 = [select id from profile where name=: 'Customer Community'].id;
        Account ac = new Account(name = 'Test Customer Community') ;
        insert ac;
       
        Contact con = new Contact(LastName = 'Test_Contact_Community' ,
                                  AccountId = ac.Id,
                                  First_Name_as_it_Appears_on_ID__c = 'Test',
                                  Middle_Name_as_it_Appears_on_ID__c = 'T',
                                  Last_Name_as_it_Appears_on_ID__c = 'Test');
        insert con;
       
        System.debug('@mal-CON-ID'+con.Id);
       
        User communityUser = new User(alias = 'comUser'
                                      ,email = 'testUsermig123@testingsfdc.com'
                                      ,emailencodingkey='UTF-8'
                                      ,lastname = 'Batman'
                                      ,languagelocalekey='en_US'
                                      ,localesidkey='en_US'
                                      ,profileid = profileId1
                                      ,country = 'France'
                                      ,IsActive = true
                                      ,ContactId = con.Id
                                      ,timezonesidkey='America/Los_Angeles'
                                      ,username = 'testUsermig123@testingsfdc.com');
        insert communityUser;
        
        
        // insert product
        List<Product2> Product2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'ENC2X',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4011');
        Product2List.add(p1);
        Product2 p2 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'MEMW',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4011');
        Product2List.add(p2);
        insert Product2List;
        
                
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        // insert pricebook entry for the product
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice1);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[1].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice2);
        insert PricebookEntryList ;
        
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = ac.id,stageName = 'closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        ChargentOrders__ChargentOrder__c order = [select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: opp.id];
        
        trans = new ChargentOrders__Transaction__c();
        trans.Opportunity__c = opp.Id;
        trans.ChargentOrders__Amount__c = -350;
        trans.ChargentOrders__Order__c = order.id;
        trans.ChargentOrders__Response_Message__c = 'Approved';
        trans.ChargentOrders__Response_Status__c = 'Approved';
        trans.ChargentOrders__Type__c = 'Charge';
        trans.ChargentOrders__Gateway_Date__c =system.now();
        insert trans;
        
        trans1 = new ChargentOrders__Transaction__c();
        trans1.Opportunity__c = opp.Id;
        trans1.ChargentOrders__Amount__c = -30;
        trans1.ChargentOrders__Order__c = order.id;
        trans1.ChargentOrders__Response_Message__c = 'Approved';
        trans1.ChargentOrders__Response_Status__c = 'test';
        trans1.ChargentOrders__Type__c = 'Void';
        trans1.ChargentOrders__Gateway_Date__c =system.now();
        insert trans1;
        
        
        oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id,PricebookEntryId = PricebookEntryList[0].Id,Product2Id = Product2List[0].Id,UnitPrice = 7,
                                                                   Quantity = 5,Product_company__c='GRA Test');
        insert oppLineItem;
        
        oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id,PricebookEntryId = PricebookEntryList[1].Id,Product2Id = Product2List[1].Id,UnitPrice = 7,
                                                                   Quantity = 5,Product_company__c='GRA Test');
        insert oppLineItem1;
        
        refund = new Product_Refunds__c (Refund_amount__c =200,Opportunity__c = opp.id,product__c = Product2List[0].id,Status__c='Submitted',Take_Membership__c = true);
        insert refund;
        
        refund1 = new Product_Refunds__c (Refund_amount__c =400,Opportunity__c = opp.id,product__c = Product2List[1].id,Status__c='Approved');
        insert refund1;
        
        Exam_Provider__c ep =new Exam_Provider__c(Name ='Pearson');
        insert ep;
        Exam_Sites__c es = new Exam_Sites__c(name = 'Test ES1',Exam_Provider__c=ep.id);
        insert es;
        
		Exam_Attempt__c ea = new Exam_Attempt__c(name = 'Test EA5',Exam_Site__c = es.Id, Opportunity__c =opp.Id );
        insert ea;    
        
        Integration_Data__c intdata = new Integration_Data__c();
        
        intdata.Exam_Registrations__c = ea.id;
        intdata.Version_Number__c = 1;
        intdata.Name ='test';
        intdata.Is_Active__c =true;
        intdata.Garp_Id__c ='01404258';
        intdata.Exam_Type__c = 'SCR';
        intdata.Pearson_Event_Type__c ='ExamDelivered';
        intdata.Pearson_Vue_Appointment_ID__c = '210378726';
        intdata.PSI_Test_code__c = 'test123';
        intdata.ExamDelivered__c = false;
        intdata.Integration_Type__c = 'Eligibility Lifecycle';
        intdata.PSI_schedule_start_date__c = date.today().format();
        intdata.PSI_eligibility_end_date__c = date.today().format();
        intdata.Scheduled_Date_Time__c = datetime.now();
        intdata.RecordTypeId = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('PSI').getRecordTypeId();
        intdata.PSI_client_eligibility_id__c = 'PSI-0000000';
        insert intdata;
           
    }

	
    @isTest
    Static void unitTest(){
        setupData();
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(trans);
        refundPaymentsOrders cfrle = new refundPaymentsOrders(sc);
        refundPaymentsOrders.wrapperOpps wo = new refundPaymentsOrders.wrapperOpps(oppLineItem,trans);
        wo.isSelected = true;
        wo.objProductRefund = refund;
        wo.Sale_Price = 200.0;
        wo.dAmount = 200.0;
        wo.Refund_Code = 'test';
        cfrle.lstWrapper = new refundPaymentsOrders.wrapperOpps[]{wo};
        cfrle.scheduledRegList = new Exam_Attempt__c[]{};
        cfrle.saveData();
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(trans1);
        refundPaymentsOrders cfrle1 = new refundPaymentsOrders(sc1);
        refundPaymentsOrders.wrapperOpps wo1 = new refundPaymentsOrders.wrapperOpps(oppLineItem,trans1);
        wo1.isSelected = false;
        wo1.objProductRefund = refund;
        cfrle1.lstWrapper = new refundPaymentsOrders.wrapperOpps[]{wo1};
        cfrle1.scheduledRegList = new Exam_Attempt__c[]{};
        cfrle1.saveData();
        
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(trans);
        refundPaymentsOrders cfrle2 = new refundPaymentsOrders(sc2);
        refundPaymentsOrders.wrapperOpps wo2 = new refundPaymentsOrders.wrapperOpps(oppLineItem1,trans);
        wo2.isSelected = true;
        cfrle2.lstWrapper = new refundPaymentsOrders.wrapperOpps[]{wo2};
        cfrle2.scheduledRegList = new Exam_Attempt__c[]{ea};
        cfrle2.saveData();
        
        ApexPages.StandardController sc3 = new ApexPages.StandardController(trans1);
        refundPaymentsOrders cfrle3 = new refundPaymentsOrders(sc3);
        refundPaymentsOrders.wrapperOpps wo3 = new refundPaymentsOrders.wrapperOpps(oppLineItem,trans1);
        wo3.isSelected = true;
        wo3.objProductRefund = refund;
        cfrle3.lstWrapper = new refundPaymentsOrders.wrapperOpps[]{wo};
        cfrle3.scheduledRegList = new Exam_Attempt__c[]{};
        cfrle3.saveData();
        
        Test.stopTest();
    }
   
}