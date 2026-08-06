@isTest
public class CreateFreeOppEBookAndPracExams_Test {
	@testSetup
    public static void testSetup(){
        String StrDefered = 'Approved';       
        String oppstatus = 'closed';
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp = new Opportunity(amount = 123,Payment_Method_New__c = 'Check',Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = oppstatus,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
       	Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;
        
        Product2 FRM1X = new Product2(Company__c = 'GARP', Name = 'FRM 1 EBook', ProductCode = 'FRM1X', GL_Code__c = '4999',Family = 'Hardware',IsActive = true);
        Product2 FRMC1 = new Product2(Company__c = 'GARP', Name = 'FRM 1 Exam', ProductCode = 'FRMC1', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 FRM2X = new Product2(Company__c = 'GARP', Name = 'FRM 2 EBook', ProductCode = 'FRM2X', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);        
        Product2 FRMC2 = new Product2(Company__c = 'GARP', Name = 'FRM 2 Exam', ProductCode = 'FRMC2', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 ENC1X = new Product2(Company__c = 'GARP', Name = 'ERP 1 Ebook', ProductCode = 'ENC1X', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 ENCC1 = new Product2(Company__c = 'GARP', Name = 'ERP 1 Exam', ProductCode = 'ENCC1', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 ENC2X = new Product2(Company__c = 'GARP', Name = 'ERP 2 Ebook', ProductCode = 'ENC2X', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 ENCC2 = new Product2(Company__c = 'GARP', Name = 'ERP 2 Ebook', ProductCode = 'ENCC2', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 SCRX = new Product2(Company__c = 'GARP', Name = 'SCR Ebook', ProductCode = 'SCRX', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 SCRCN = new Product2(Company__c = 'GARP', Name = 'SCR Exam', ProductCode = 'SCRCN', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);  
        INSERT new List<Product2>{FRM1X,FRMC1,FRM2X,FRMC2,ENC1X,ENCC1,ENC2X,ENCC2,SCRX,SCRCN};
        
        PricebookEntry FRM1XPBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = FRM1X.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry FRMC1PBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = FRMC1.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry FRM2XPBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = FRM2X.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry FRMC2PBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = FRMC2.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry ENC1XPBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = ENC1X.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry ENCC1PBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = ENCC1.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry ENC2XPBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = ENC2X.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry ENCC2PBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = ENCC2.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry SCRXPBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = SCRX.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry SCRCNPBE = new PricebookEntry(Pricebook2Id = activePricebook.id, Product2Id = SCRCN.Id, UnitPrice = 0, IsActive = true);
        
        INSERT new List<PricebookEntry>{FRM1XPBE,FRMC1PBE,FRM2XPBE,FRMC2PBE,ENC1XPBE,ENCC1PBE,ENC2XPBE,ENCC2PBE,SCRXPBE,SCRCNPBE};
        
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
        
        Exam__c examSCR = new Exam__c();
        examSCR.Exam_Group__c = objExamGrp.id;
        examSCR.Exam_Date__c = system.today().addDays(30);
        examSCR.exam__c = 'SCR'; 
        examList.add(examSCR);
        
        Exam__c examERP1 = new Exam__c();
        examERP1.Exam_Group__c = objExamGrp.id;
        examERP1.Exam_Date__c = system.today().addDays(30);
        examERP1.exam__c = 'ERP Exam Part I'; 
        examList.add(examERP1);
        
        Exam__c examERP2 = new Exam__c();
        examERP2.Exam_Group__c = objExamGrp.id;
        examERP2.Exam_Date__c = system.today().addDays(30);
        examERP2.exam__c = 'ERP Exam Part II'; 
        examList.add(examERP2);
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
        
        Exam_Part__c examPart3 = new Exam_Part__c();
        examPart3.Exam__c = examSCR.id;
        examPart3.Exam_Administration__c = examAdmin.id;
        examPart3.Exam_Date__c = system.today().adddays(30);
        examPart3.Delivery_Method__c = 'CBT';
        examPartList.add(examPart3);
        
        Exam_Part__c examPart4 = new Exam_Part__c();
        examPart4.Exam__c = examERP1.id;
        examPart4.Exam_Administration__c = examAdmin.id;
        examPart4.Exam_Date__c = system.today().adddays(30);
        examPart4.Delivery_Method__c = 'CBT';
        examPartList.add(examPart4);
        
        Exam_Part__c examPart5 = new Exam_Part__c();
        examPart5.Exam__c = examERP2.id;
        examPart5.Exam_Administration__c = examAdmin.id;
        examPart5.Exam_Date__c = system.today().adddays(30);
        examPart5.Delivery_Method__c = 'CBT';
        examPartList.add(examPart5);
        insert examPartList;
        
        List<Exam_Sites__c> siteList = new List<Exam_Sites__c>();
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM1.id);
        siteList.add(exmSite);
        Exam_Sites__c exmSite2 = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM2.id);
        siteList.add(exmSite2);
        Exam_Sites__c exmSite3 = new Exam_Sites__c(Site__c = site.id,exam__c = examSCR.id);
        siteList.add(exmSite3);
        Exam_Sites__c exmSite4 = new Exam_Sites__c(Site__c = site.id,exam__c = examERP1.id);
        siteList.add(exmSite4);
        Exam_Sites__c exmSite5 = new Exam_Sites__c(Site__c = site.id,exam__c = examERP2.id);
        siteList.add(exmSite5);
        insert siteList;
        
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c = StrDefered,Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt);
        
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Defered__c = StrDefered,Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart2.Id, Exam_Site__c = exmSite2.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt2);
        
        Exam_Attempt__c attempt3 = new Exam_Attempt__c(Defered__c = StrDefered,Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart3.Id, Exam_Site__c = exmSite3.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt3);
        
        Exam_Attempt__c attempt4 = new Exam_Attempt__c(Defered__c = StrDefered,Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart4.Id, Exam_Site__c = exmSite4.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt4);
        
        Exam_Attempt__c attempt5 = new Exam_Attempt__c(Defered__c = StrDefered,Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart5.Id, Exam_Site__c = exmSite5.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt5);
        insert examAttemptList;
    }
    
    @isTest
    public static void testFRM1(){
        test.startTest();
        Id batchInstanceId = Database.executeBatch(new CreateFreeOppEBookAndPracExams('FRM Part 1'),1);
        
        test.stopTest();
    }
    
    @isTest
    public static void testFRM2(){
        test.startTest();
        Id batchInstanceId = Database.executeBatch(new CreateFreeOppEBookAndPracExams('FRM Part 2'),1);
        
        test.stopTest();
    }
    
    @isTest
    public static void testSCR(){
        test.startTest();
        Id batchInstanceId = Database.executeBatch(new CreateFreeOppEBookAndPracExams('SCR'),1);
        
        test.stopTest();
    }
    
    @isTest
    public static void testERP1(){
        test.startTest();
        Id batchInstanceId = Database.executeBatch(new CreateFreeOppEBookAndPracExams('ERP Exam Part I'),1);
        
        test.stopTest();
    }
    
    @isTest
    public static void testERP2(){
        test.startTest();
        Id batchInstanceId = Database.executeBatch(new CreateFreeOppEBookAndPracExams('ERP Exam Part II'),1);
        
        test.stopTest();
    }
}