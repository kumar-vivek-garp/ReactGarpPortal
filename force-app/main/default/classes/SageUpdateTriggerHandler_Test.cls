@isTest
public class SageUpdateTriggerHandler_Test {
    
    @isTest
    static void unitTest_1(){
        
        Account account = new Account();
        account.Name = 'TEST CO';
        account.BillingCountry = 'Palestine';
        account.ShippingCountry = 'Palestine';
        INSERT account;
        
        ia_crm__Project__c crmProj = new ia_crm__Project__c();
        crmProj.ia_crm__Project_ID__c = 'uniqueTest';
        insert crmProj;
        
        Contact contact = new Contact();
        contact.Email = 'TEST@TEST.com';
        contact.FirstName = 'TEST';
        contact.LastName = 'TEST';
        contact.AccountId = account.Id;
        INSERT contact;
        
        List<Exam_Group__c> examGroupList = new List<Exam_Group__c>();
        
        Exam_Group__c examGroup = new Exam_Group__c();
		examGroup.Name = '21-SCR';
        examGroup.Exam_Date__c = Date.newInstance(2022, 11, 1).addDays(28);
        examGroup.Active__c = True;
        examGroupList.add(examGroup);
        
        for(Integer i=1;i<8;i++){    
            Exam_Group__c examGroup1 = new Exam_Group__c();
            examGroup1.Name = '21-SCR';
            examGroup1.Exam_Date__c = Date.newInstance(2022, 11, 1).addDays(28*(i+1));
            examGroup1.Active__c = false;
            examGroupList.add(examGroup1);
        }
        insert examGroupList;
        
        Exam__c frmPart1 = new Exam__c();
        frmPart1.Name = 'May 2018 FRM Exam Part I';
        frmPart1.Exam_Group__c = examGroupList[0].Id;
        frmPart1.Exam__c = 'FRM Part 1';
        frmPart1.Exam_Date__c = system.today().adddays(Integer.valueof((Math.random() * 365)));
        INSERT frmPart1; 
        
        Exam__c frmPart2 = new Exam__c();
        frmPart2.Name = 'May 2018 FRM Exam Part II';
        frmPart2.Exam_Group__c = examGroupList[1].Id;
        frmPart2.Exam__c = 'FRM Part 2';
        frmPart2.Exam_Date__c = system.today().adddays(Integer.valueof((Math.random() * 365)));
        INSERT frmPart2;
        
        Site__c testSite = new Site__c();
        testSite.Active__c = true;
        testSite.Is_OSTA_Information_Required__c = true;
        INSERT testSite;
        
        List<Exam_Administration__c> examAdminList = new List<Exam_Administration__c>();
        
        
        
        for(Integer i=0; i<8; i++){
            Exam_Administration__c examAdmin = new Exam_Administration__c();
            examAdmin.Exam_Group__c = examGroupList[i].id;
            examAdminList.add(examAdmin);
        }
        insert examAdminList;
        
        
        Exam_Part__c exampart = new Exam_Part__c();
        exampart.Exam__c = frmPart1.Id;
        exampart.Exam_Administration__c = examAdminList[0].Id ;
        exampart.Delivery_Method__c = 'CBT';
        exampart.Exam_Start_Date__c = Date.newInstance(2022, 1, 10);
        exampart.Exam_Date__c = Date.newInstance(2022, 2, 10).adddays(Integer.valueof((Math.random() * 365)));
        exampart.Exam_End_Date__c = Date.newInstance(2022, 1, 10)+60;
        
        insert exampart;
        
        Exam_Part__c examPart2 = new Exam_Part__c();
        examPart2.Exam__c = frmPart2.id;
        examPart2.Exam_Administration__c = examAdminList[1].id;
        exampart.Exam_Start_Date__c = Date.newInstance(2022, 2, 10);
        exampart.Exam_Date__c = Date.newInstance(2022, 3, 10).adddays(Integer.valueof((Math.random() * 365)));
        exampart.Exam_End_Date__c = Date.newInstance(2022, 2, 10)+60;
        examPart2.Delivery_Method__c = 'CBT';
        
        insert examPart2;
        
        Exam_Part__c examPart3 = new Exam_Part__c();
        examPart3.Exam__c = frmPart2.id;
        examPart3.Exam_Administration__c = examAdminList[2].id;
        examPart3.Exam_Start_Date__c = Date.newInstance(2022, 5, 10);
        examPart3.Exam_Date__c = Date.newInstance(2022, 5, 10);
        examPart3.Exam_End_Date__c = Date.newInstance(2022, 5, 10)+60;
        examPart3.Delivery_Method__c = 'CBT';
        insert examPart3;
		
        Exam_Part__c examPart4 = new Exam_Part__c();
        examPart4.Exam__c = frmPart2.id;
        examPart4.Exam_Administration__c = examAdminList[3].id;
        examPart4.Exam_Start_Date__c = Date.newInstance(2022, 6, 10);
        examPart4.Exam_Date__c = Date.newInstance(2020, 6, 10);
        examPart4.Exam_End_Date__c = Date.newInstance(2022, 6, 10)+60;
        examPart4.Delivery_Method__c = 'CBT';
        insert examPart4;
        
        Exam_Sites__c examSitePart1 = new Exam_Sites__c();
        examSitePart1.Name = 'China';
        examSitePart1.Site__c = testSite.Id;
        examSitePart1.Exam__c = frmPart1.Id;
        examSitePart1.Exam_Part__c = exampart.Id;
        INSERT examSitePart1;
        
        Exam_Sites__c examSitePart2 = new Exam_Sites__c();
        examSitePart2.Name = 'China';
        examSitePart2.Site__c = testSite.Id;
        examSitePart2.Exam__c = frmPart2.Id;
        examSitePart2.Exam_Part__c = exampart2.Id;
        INSERT examSitePart2;
        
        Opportunity opp1 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                           /*ia_crm__Intacct_Transaction__c = 'Sales Invoice - Salesforce',*/
                                           company__c = 'Payment', accountId = account.id,stageName = 'Closed',
                                           Shipping_Country__c = 'test',Program__c = 'Print',Payment_Method_New__c = 'Credit Card',
                                           CardType__c = 'AMEX',closedate = system.today()+ 15);  
        insert opp1;
        
        Opportunity opp2 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                           company__c = 'Payment', accountId = account.id,stageName = 'Closed',
                                           Shipping_Country__c = 'test',Program__c = 'Print' ,
                                           ia_crm__Intacct_Transaction__c = 'Salesforce - Postponed',closedate = system.today()+ 15);  
        insert opp2;
        
        Opportunity opp3 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                           company__c = 'Payment', accountId = account.id,stageName = 'Closed',
                                           Shipping_Country__c = 'test',Program__c = 'Print',Payment_Method_New__c = 'Charge Back Loss',
                                           CardType__c = 'AMEX',closedate = system.today()+ 15);  
        insert opp3;
        
        /*Opportunity opp4 = new Opportunity(amount = 123,Name = 'Test4',Eligible_for_Membership_Extension__c = false,
                                           company__c = 'Payment', accountId = account.id,stageName = 'Closed',
                                           Shipping_Country__c = 'test',Program__c = 'Print' ,closedate = system.today()+ 15);  
        insert opp4;*/
        
        List<Exam_Attempt__c> attemptList = new List<Exam_Attempt__c>();
        Exam_Attempt__c examRegistration1 = new Exam_Attempt__c();
        examRegistration1.Member__c = contact.Id;
        examRegistration1.Opportunity__c = opp1.Id;
        examRegistration1.Defered__c = 'Pending';
        examRegistration1.Cancelled__c=True;
        examRegistration1.Exam_Site__c=examSitePart1.id;
        attemptList.add(examRegistration1);
        
        Exam_Attempt__c examRegistration2 = new Exam_Attempt__c();
        examRegistration2.Member__c = contact.Id;
        examRegistration2.Exam_Part__c = exampart.Id;
        examRegistration2.Opportunity__c = opp1.Id;
        examRegistration2.Exam_Site__c = examSitePart2.Id;
        examRegistration2.Defered__c = 'Pending';
        attemptList.add(examRegistration2);
        
        INSERT attemptList;
        
        Exam_Registration_Modification__c examRegMod = new Exam_Registration_Modification__c();
        examRegMod.Part_I_Exam_Admin_From__c = examAdminList[0].id ;
        examRegMod.Part_II_Exam_Admin_From__c  = examAdminList[1].id ;
        examRegMod.Part_I_Exam_Registration__c = examRegistration1.id;
        examRegMod.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod.Part_I_Exam_Admin_To__c  = examAdminList[2].id;
        examRegMod.Part_II_Exam_Admin_To__c  = examAdminList[3].id ;
        examRegMod.Part_I_Exam_Part_From__c = exampart.Id;
        examRegMod.Part_I_Exam_Part_To__c = exampart2.Id;
        examRegMod.Part_II_Exam_Part_To__c = examPart2.Id;
        examRegMod.Part_II_Exam_Part_From__c = examPart.Id;
        examRegMod.Status__c = 'Pending';
        insert examRegMod ;
        
        Exam_Registration_Modification__c examRegMod1 = new Exam_Registration_Modification__c();
        examRegMod1.Part_I_Exam_Admin_From__c = examAdminList[5].id ;
        examRegMod1.Part_II_Exam_Admin_From__c  = examAdminList[4].id ;
        examRegMod1.Part_I_Exam_Registration__c = examRegistration1.id;
        examRegMod1.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod1.Part_I_Exam_Admin_To__c  = examAdminList[3].id;
        examRegMod1.Part_II_Exam_Admin_To__c  = examAdminList[2].id ;
        examRegMod1.Part_I_Exam_Part_From__c = examPart4.Id;
        examRegMod1.Part_I_Exam_Part_To__c = examPart3.Id;
        examRegMod1.Part_II_Exam_Part_To__c = examPart3.Id;
        examRegMod1.Part_II_Exam_Part_From__c = examPart4.Id;
        examRegMod1.Status__c = 'Pending';
        insert examRegMod1 ;

        Exam_Registration_Modification__c examRegMod2 = new Exam_Registration_Modification__c();
        examRegMod2.Part_I_Exam_Admin_From__c = examAdminList[4].id ;
        examRegMod2.Part_II_Exam_Admin_From__c  = examAdminList[5].id ;
        examRegMod2.Part_I_Exam_Registration__c = examRegistration2.id;
        examRegMod2.Part_II_Exam_Registration__c = examRegistration1.id;
        examRegMod2.Part_I_Exam_Admin_To__c  = examAdminList[6].id;
        examRegMod2.Part_II_Exam_Admin_To__c  = examAdminList[7].id ;
        examRegMod2.Part_I_Exam_Part_From__c = exampart3.Id;
        examRegMod2.Part_I_Exam_Part_To__c = exampart.Id;
        examRegMod2.Part_II_Exam_Part_To__c = examPart3.Id;
        examRegMod2.Part_II_Exam_Part_From__c = examPart.Id;
        examRegMod2.Status__c = 'Pending';
        insert examRegMod2 ;
        
        
        opp1.Exam_Registration_Modification__c = examRegMod.id;
        opp1.Billing_Country__c = 'United States';
        opp1.ia_crm__Intacct_Transaction__c = 'Salesforce - Deferral';
        update opp1;
        
        opp2.Billing_Country__c = 'United States';
        opp2.Exam_Registration_Modification__c = examRegMod2.id;
        update opp2;
        
        
        List<Product2> Product2List = new List<Product2>();
        
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',
                                   productCode = 'CHLF',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Class__c='Test',Department__c = 'testdept',Weight__c=5,GL_Code__c='4020');
        Product2List.add(p1);
        Product2 p2 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',
                                   productCode = 'CHNDF',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Class__c='Test',Department__c = 'testdept',Weight__c=6,GL_Code__c='4020');
        Product2List.add(p2);
        
        Product2 p3 = new Product2(Name = ' Test Product3',Description='Test Product Entry3 For Product',
                                   productCode = 'FRM1E',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Class__c='Test',Department__c = 'testdept',Weight__c=6,GL_Code__c='4020');
        Product2List.add(p3);
        
        Product2 p4 = new Product2(Name = ' Test Product4',Description='Test Product Entry4 For Product',
                                   productCode = 'CBRD',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Class__c='Test',Department__c = 'testdept',Weight__c=5,GL_Code__c='4020');
        Product2List.add(p4);
        
        Product2 p5 = new Product2(Name = ' Test Product54',Description='Test Product Entry4 For Product',
                                   productCode = 'MEMI',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4020');
        Product2List.add(p5);
        Product2 p6 = new Product2(Name = ' Test Product54',Description='Test Product Entry4 For Product',
                                   productCode = 'FRM2X',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4020');
        Product2List.add(p6);
        Product2 p7 = new Product2(Name = ' Test Product54',Description='Test Product Entry4 For Product',
                                   productCode = 'SAFRM2',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4020');
        Product2List.add(p7);
        Product2 p8 = new Product2(Name = ' Test Product54',Description='Test Product Entry4 For Product',
                                   productCode = 'FRM1',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4020');
        Product2List.add(p8);
        insert Product2List;
        
        
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 customPB = new Pricebook2(Name = 'GARP 2015/2016', isActive=true);
        insert customPB;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice1;
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[1].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice2;
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[2].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice3;
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[3].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice4;
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[4].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice5;
        PricebookEntry standardPrice6 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[5].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice6;
        PricebookEntry standardPrice7 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[6].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice7;
        PricebookEntry standardPrice8 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[7].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice8;
        PricebookEntry customPBEntry = new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true);
		insert customPBEntry;
        
        insert(new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = Product2List[1].Id,UnitPrice = 250,IsActive = true));
		
        Contract frmProgram = new Contract(AccountId = account.Id,CustomerSignedId = contact.Id,
                                           RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership'),
                                           Status = 'Draft',Name = 'FRM Program', Opportunity__c=opp1.Id,StartDate = Date.today()+20, ContractTerm = 9999);
        INSERT frmProgram;   
        frmProgram.Status = 'Activated';
        frmProgram.Membership_Type__c = 'Individual';
        update frmProgram;
        
                
        Scholarship_Application__c sa = new Scholarship_Application__c(Applicant__c = frmProgram.CustomerSignedId,
                                                                       Exam_Type__c='FRM',Status__c='Submitted', Exam_Group__c= examGroupList[0].Id);
        insert sa;
        
        ia_crm__Department__c dep = new ia_crm__Department__c(
            ia_crm__Department_ID__c = 'testdept',
            ia_crm__Status__c = 'Active');
        insert dep;
        
 		   ia_crm__Class__c cls = new ia_crm__Class__c(
            ia_crm__Class_ID__c = 'TEstclass',
            ia_crm__Status__c= True,
            Name = 'Test');
        insert cls;       
     
        ia_crm__Intacct_Entity__c Icie = new ia_crm__Intacct_Entity__c(Name = 'China Sage',ia_crm__Intacct_Entity_ID__c='20-01');
        insert Icie;
        
        ia_crm__Intacct_User_Dimension__c ciud = new ia_crm__Intacct_User_Dimension__c(Name='1013');
        insert ciud;
        
        ia_crm__Revenue_Recognition_Template__c Icrrt = new ia_crm__Revenue_Recognition_Template__c(Name = 'Exam');
        insert Icrrt;
        
        list<OpportunityLineItem> oppLineItemList =new List<OpportunityLineItem>();
        
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp1.Id,Product2Id = Product2List[0].Id,PricebookEntryId = standardPrice1.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Sage_Reporting_Country__c = 'United States',Sage_Shipping_Country__c = 'United States',Quantity = 5,Product_company__c='GRA Test',Scholarship_Application__c = sa.Id);
        
        oppLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = opp1.Id,Product2Id = Product2List[1].Id,PricebookEntryId = standardPrice2.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test',Scholarship_Application__c = sa.Id);
        
        
        oppLineItemList.add(oppLineItem2);
        OpportunityLineItem oppLineItem3 = new OpportunityLineItem(OpportunityId = opp1.Id,Product2Id = Product2List[2].Id,PricebookEntryId = standardPrice3.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test',Scholarship_Application__c = sa.Id);
        
        oppLineItemList.add(oppLineItem3);
        OpportunityLineItem oppLineItem4 = new OpportunityLineItem(OpportunityId = opp1.Id,Product2Id = Product2List[3].Id,PricebookEntryId = standardPrice4.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test',Scholarship_Application__c = sa.Id);
        
        oppLineItemList.add(oppLineItem4);
        OpportunityLineItem oppLineItem5 = new OpportunityLineItem(OpportunityId = opp1.Id,Product2Id = Product2List[4].Id,PricebookEntryId = standardPrice5.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test',Scholarship_Application__c = sa.Id);
        
        oppLineItemList.add(oppLineItem5);
        OpportunityLineItem oppLineItem6 = new OpportunityLineItem(OpportunityId = opp1.Id,Product2Id = Product2List[5].Id,PricebookEntryId = standardPrice6.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test',Scholarship_Application__c = sa.Id);
        
        oppLineItemList.add(oppLineItem6);
        OpportunityLineItem oppLineItem7 = new OpportunityLineItem(OpportunityId = opp1.Id,Product2Id = Product2List[6].Id,PricebookEntryId = standardPrice7.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test',Scholarship_Application__c = sa.Id);
        
        oppLineItemList.add(oppLineItem7);
        OpportunityLineItem oppLineItem8 = new OpportunityLineItem(OpportunityId = opp1.Id,Product2Id = Product2List[7].Id,PricebookEntryId = standardPrice8.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = examRegistration1.Id,Scholarship_Application__c = sa.Id);
        
        oppLineItemList.add(oppLineItem8);
        OpportunityLineItem oppLineItem9 = new OpportunityLineItem(OpportunityId = opp3.Id,Product2Id = Product2List[6].Id,PricebookEntryId = standardPrice7.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test',Scholarship_Application__c = sa.Id);
        
        oppLineItemList.add(oppLineItem9);
        OpportunityLineItem oppLineItem10 = new OpportunityLineItem(OpportunityId = opp3.Id,Product2Id = Product2List[7].Id,PricebookEntryId = standardPrice8.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test',Scholarship_Application__c = sa.Id);
        oppLineItemList.add(oppLineItem10);
        
        insert oppLineItemList;    
        
        List<Sage_Updates__e> sageEventsList = new List<Sage_Updates__e>(); 
        sageEventsList.add(new Sage_Updates__e(Opportunity_Id__c = opp1.Id));
        sageEventsList.add(new Sage_Updates__e(Opportunity_Id__c = opp2.Id));      
        //sageEventsList.add(new Sage_Updates__e(Opportunity_Id__c = opp3.Id));
        Test.startTest();
        
        Eventbus.publish(sageEventsList);
        Test.getEventBus().deliver(); 
        
        Contract ostaProgram = new Contract(AccountId = account.Id,CustomerSignedId = contact.Id,
                                           RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'OSTA_Program'),
                                           Status = 'Draft',Name = 'OSTA Program', Opportunity__c=opp1.Id,
                                           /*OSTA_Last_Upload_Date__c = Date.today()+20,*/ StartDate = Date.today()+20, ContractTerm = 9999);
        INSERT ostaProgram;   
        ostaProgram.Status = 'Activated';
        ostaProgram.Membership_Type__c = 'Individual';
        update ostaProgram;
        
               
        //exampart.Exam_Date__c = null;
        //exampart2.Exam_Date__c = null;
        //update exampart;
        //update exampart2;
        
        examPart2.Exam_Date__c = Date.newInstance(2022, 9, 10);
        examPart.Exam_Date__c = Date.newInstance(2022, 8, 10);
        update examPart2;
        update examPart;
        
        opp1.CardType__c = 'AMEX';
        opp1.ia_crm__Intacct_Transaction__c = 'Salesforce - Sales Invoice';
        opp1.Shipping_Country__c = 'United States of America (USA)';
        opp1.Billing_Country__c = 'United States';
        update opp1;
        
        opp3.Exam_Registration_Modification__c = examRegMod1.id;
        opp3.Billing_Country__c = 'India';
        opp3.Shipping_Country__c = 'United States of America (USA)';
        //opp3.ia_crm__Intacct_Transaction__c = 'Salesforce - Refund';
        opp3.ia_crm__Intacct_Transaction__c =  'Salesforce - Postponed';
        update opp3;
        
        examPart3.Exam_Date__c = Date.newInstance(2022, 7, 10);
        examPart4.Exam_Date__c = Date.newInstance(2022, 8, 10);
        update examPart3;
        update examPart4;
        
        sageEventsList.add(new Sage_Updates__e(Opportunity_Id__c = opp1.Id));
        //sageEventsList.add(new Sage_Updates__e(Opportunity_Id__c = opp2.Id));
        sageEventsList.add(new Sage_Updates__e(Opportunity_Id__c = opp3.Id));
        Eventbus.publish(sageEventsList);
        Test.getEventBus().deliver();
        
        opp1.ia_crm__Intacct_Transaction__c =  'Salesforce - Postponed';
        update opp1;
        
        sageEventsList.clear();
        sageEventsList.add(new Sage_Updates__e(Opportunity_Id__c = opp1.Id));
        Eventbus.publish(sageEventsList);
        Test.getEventBus().deliver();
        
        //SageUpdateTriggerHandler suth = new SageUpdateTriggerHandler();
        //suth.convertMonthNumberToText(1);
       
     
        Test.stopTest();    
    }
}