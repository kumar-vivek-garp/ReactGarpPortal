@isTest
public class BatchUpdateSiteOppProd_Test {
    
    static Exam_Attempt__c attempt;
    Static Exam_Attempt__c attempt1;
    Static Exam_Attempt__c attempt2;
    static Exam_Group__c objExamGrp;
    static Exam__c exam;
    static Opportunity opportunity; 
    static Exam_Sites__c exmSite;
    static Site__c site;
    static Integration_Data__c intdata;
    
    static void testdata(){
        
        Account account = new Account(Name = 'test');
        insert account;
        
        opportunity = new Opportunity(amount = 123,Name = 'Test',ia_crm__Intacct_Sync_Status_1__c = 'OK',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity; 
        
        Opportunity opportunity1 = new Opportunity(amount = 123,Name = 'Test1',ia_crm__Intacct_Sync_Status_1__c = 'OK',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', stageName = 'New Lead',accountId = account.id,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity1;
        
        Opportunity opportunity2 = new Opportunity(amount = 123,Name = 'Test2',ia_crm__Intacct_Sync_Status_1__c = 'OK',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', stageName = 'New Lead',accountId = account.id,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity2;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = opportunity.accountid,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        Contract contract  = new Contract(ContractTerm =2,Membership_Type__c = 'Individual',startDate = system.today()- 1,recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program') ,Opportunity__c = opportunity.id,accountId = opportunity.AccountId);
        insert contract;
        contract.Status = 'Activated';
        update contract;
        
        List<Product2> Product2List = new List<Product2>();
        
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',
                                   productCode = 'FRM1E',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Class__c='Test',Department__c = 'testdept',Weight__c=5,GL_Code__c='4020');
        Product2List.add(p1);
        Product2 p2 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',
                                   productCode = 'FRM2E',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Class__c='Test',Department__c = 'testdept',Weight__c=6,GL_Code__c='4020');
        Product2List.add(p2);
        
        Product2 p3 = new Product2(Name = ' Test Product3',Description='Test Product Entry3 For Product',
                                   productCode = 'SCRME',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Class__c='Test',Department__c = 'testdept',Weight__c=6,GL_Code__c='4020');
        Product2List.add(p3);
        
        insert Product2List;
        
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice1;
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[1].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice2;
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[2].Id,UnitPrice = 250,IsActive = true);
        insert standardPrice3;
        
        list<OpportunityLineItem> oppLineItemList =new List<OpportunityLineItem>();
        
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opportunity.Id,Product2Id = Product2List[0].Id,PricebookEntryId = standardPrice1.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test');
        
        oppLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = opportunity1.Id,Product2Id = Product2List[1].Id,PricebookEntryId = standardPrice2.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test');
        
        
        oppLineItemList.add(oppLineItem2);
        OpportunityLineItem oppLineItem3 = new OpportunityLineItem(OpportunityId = opportunity2.Id,Product2Id = Product2List[2].Id,PricebookEntryId = standardPrice3.Id,UnitPrice = 7000,Description='test',
                                                                   Product_ID__c = '2022SCRPE2022',Quantity = 5,Product_company__c='GRA Test');
        
        oppLineItemList.add(oppLineItem3);
        
        insert oppLineItemList;
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true; 
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;    
        insert objExamGrp;
        
        exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1'; 
        insert exam;
        
        Exam__c exam1 = new Exam__c();
        exam1.Exam_Group__c = objExamGrp.id;
        exam1.Exam_Date__c = system.today() + 30;
        exam1.exam__c = 'FRM Part 2'; 
        insert exam1;
        
        Exam__c exam2 = new Exam__c();
        exam2.Exam_Group__c = objExamGrp.id;
        exam2.Exam_Date__c = system.today() + 30;
        exam2.exam__c = 'SCR'; 
        insert exam2;
        
        exmSite = new Exam_Sites__c(Name = 'Swaziland',Site__c = site.id,exam__c = exam.id);
        insert exmSite; 
        
        Exam_Sites__c exmSite1 = new Exam_Sites__c(Name = 'Swaziland',Site__c = site.id,exam__c = exam1.id);
        insert exmSite1; 
        
        Exam_Sites__c exmSite2 = new Exam_Sites__c(Name = 'Swaziland',Site__c = site.id,exam__c = exam2.id);
        insert exmSite2; 
        
        List<Exam_Administration__c> examAdminList = new List<Exam_Administration__c>();
        Exam_Administration__c examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = objExamGrp.id;
        examAdmin.Exam_Date__c = system.today();
        examAdminList.add(examAdmin);
        insert examAdminList;
        
        List<Exam_Part__c> examPartList = new List<Exam_Part__c>();
        Exam_Part__c examPart = new Exam_Part__c(Exam__c = exam.id,
                                                 Exam_Administration__c = examAdmin.id,
                                                 Exam_Date__c = system.today(),Delivery_Method__c = 'CBT',ATA_Batch_Code__c = '123456');
        examPartList.add(examPart);
        
        insert examPartList;
        
        attempt = new Exam_Attempt__c(Opportunity__c = opportunity.id, Member__c = contact.id,
                                      Exam_Site__c = exmSite.id,Exam_Part__c = examPart.Id,cancelled__c = false,Result__c = 'No-Show');
        insert attempt;    
        
        attempt1 = new Exam_Attempt__c(Opportunity__c = opportunity1.id, Member__c = contact.id,
                                       Exam_Site__c = exmSite1.id,Exam_Part__c = examPart.Id,cancelled__c = false,Result__c = 'No-Show');
        insert attempt1; 
        
        intdata = new Integration_Data__c();
        intdata.Contract__c = contract.Id;
        intdata.Email__c = contact.Email;
        intdata.First_Name__c = contact.FirstName;
        intdata.Last_Name__c = contact.LastName;
        intdata.Exam_Location_Country__c = 'Swaziland';
        insert intdata;
        
        attempt2 = new Exam_Attempt__c(Opportunity__c = opportunity2.id,Active_Integration_Data__c = intData.id, Exam_Site__c = exmSite2.id,Exam_Part__c = examPart.Id,
                                       cancelled__c = false,Member__c = contact.id,Result__c = 'NoShow');
        insert attempt2; 
        
    }
    
    @isTest
    Public Static void unitTest_1(){
        testdata();
        ia_crm__Intacct_User_Dimension__c ciud = new ia_crm__Intacct_User_Dimension__c(Name='1116');
        insert ciud;
        Test.startTest();
        Database.executeBatch(new BatchUpdateSiteOppProd(attempt.id));
        
        Test.stopTest();    
    }
    
    @isTest
    Public Static void unitTest_2(){
        testdata();
        Test.startTest();
        
        Database.executeBatch(new BatchUpdateSiteOppProd(attempt1.id));
        
        Test.stopTest();
        
    }
    
    @isTest
    Public Static void unitTest_3(){
        testdata();
        Test.startTest();
        
        Database.executeBatch(new BatchUpdateSiteOppProd(attempt2.id));
        Test.stopTest();
        
    }
    
    
}