@isTest
public class batchExamPartConversion_Test {

    
    @testSetup
    public static void testSetup(){
        String StrDefered = 'Approved';       
        String oppstatus = 'closed';
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp1= new Opportunity(amount = 123,Name = 'Test1',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = oppstatus,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp1;
        
        Opportunity opp = new Opportunity(amount = 123,Cloned_From__c = opp1.id,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = oppstatus,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
       	Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;
        
        Product2 FRM1X = new Product2(Company__c = 'GARP', Product_Id__c ='23FRMNOV2E' ,Name = 'FRM 1 EBook', ProductCode = 'FRM2E', GL_Code__c = '4999',Family = 'Hardware',IsActive = true);
        INSERT FRM1X;
        
        Product2 FRM2X = new Product2(Company__c = 'GARP', Product_Id__c ='23FRMNOV1E' ,Name = 'FRM 2 EBook', ProductCode = 'FRM1E', GL_Code__c = '4999',Family = 'Hardware',IsActive = true);
        INSERT FRM2X;
        
        Pricebook2 customPB = new Pricebook2(Name='GARP 2015/2016', isActive=true);
        insert customPB;
        
        PricebookEntry FRM1XPBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = FRM1X.Id, UnitPrice = 0, IsActive = true);
        INSERT FRM1XPBE;
        PricebookEntry Entry2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = FRM1X.Id,UnitPrice = 10000, IsActive = true);
        insert Entry2;
        
        PricebookEntry FRM2XPBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = FRM2X.Id, UnitPrice = 0, IsActive = true);
        INSERT FRM2XPBE;
        PricebookEntry Entry3 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = FRM2X.Id,UnitPrice = 10000, IsActive = true);
        insert Entry3;
            
        Site__c site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site;
        
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true; 
        objExamGrp.Exam_Date__c = system.today().addDays(30);
        objExamGrp.Registration_Start_Date__c = system.today().addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today().addDays(1);
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today().addDays(9) ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today().addDays(10) ;
        insert objExamGrp;
        
        List<Exam__c> examList = new List<Exam__c>();
        Exam__c examFRM1 = new Exam__c();
        examFRM1.Exam_Group__c = objExamGrp.id;
        examFRM1.Exam_Date__c = system.today().addDays(30);
        examFRM1.exam__c = 'FRM Part 1';
        examList.add(examFRM1);
        
        Exam__c examFRM2 = new Exam__c();
        examFRM2.Exam_Group__c = objExamGrp.id;
        examFRM2.Exam_Date__c = system.today().addDays(30);
        examFRM2.exam__c = 'FRM Part 2'; 
        examList.add(examFRM2);
        insert examList;
        
        Exam_Administration__c examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = objExamGrp.id;
        examAdmin.Exam_Date__c = system.today().addDays(30);
        insert examAdmin;
        
        List<Exam_Part__c> examPartList = new List<Exam_Part__c>();
        Exam_Part__c examPart = new Exam_Part__c();
        examPart.Exam__c = examFRM1.id;
        examPart.Exam_Administration__c = examAdmin.id;
        examPart.Exam_Date__c = system.today().adddays(30);
        examPart.Delivery_Method__c = 'CBT';
        examPartList.add(examPart);
		
        Exam_Part__c examPart2 = new Exam_Part__c();
        examPart2.Exam__c = examFRM2.id;
        examPart2.Exam_Administration__c = examAdmin.id;
        examPart2.Exam_Date__c = system.today().adddays(30);
        examPart2.Delivery_Method__c = 'CBT';
        examPartList.add(examPart2);
        
        insert examPartList;
        
        List<Exam_Sites__c> siteList = new List<Exam_Sites__c>();
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM1.id);
        siteList.add(exmSite);
        Exam_Sites__c exmSite2 = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM2.id);
        siteList.add(exmSite2);
        insert siteList;
        
        
        /*Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c = StrDefered,Cancelled__c = false,Result__c = 'Pass',Opportunity__c = opp1.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id);
		insert  attempt;*/
        
		Exam_Attempt__c attempt1 = new Exam_Attempt__c(Defered__c = StrDefered,Cancelled__c = false,Result__c = 'Pass',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id);
		insert  attempt1;
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id,PricebookEntryId = Entry2.Id,UnitPrice = 7000,
                                                                   Quantity = 5,Product_ID__c = '23FRMNOV2E',Product_company__c='GRA Test',Exam_Registration__c = attempt1.Id);
        insert oppLineItem;
        /*OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp1.Id,PricebookEntryId = Entry2.Id,UnitPrice = 7000,
                                                                   Quantity = 5,Product_ID__c = '2022SCRPE2022',Product_company__c='GRA Test',Exam_Registration__c = attempt.Id);
        insert oppLineItem1;*/

    }
    
    @istest
    static void unitTest(){
        ia_crm__Class__c cls = new ia_crm__Class__c(
            ia_crm__Class_ID__c = 'TEstclass',
            ia_crm__Status__c= True,
            Name = 'Test');
        insert cls;       
        Test.startTest();
        Database.executeBatch(new batchExamPartConversion('FRM Part 1',false));
        Test.stopTest();
        
    }
}