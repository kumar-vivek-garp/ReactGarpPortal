@isTest
public class processRegModfAndDeferralsBatches_Test {
    static Account acc;
    static Contact contact;
    static PriceBook2 pb;
    static Exam_Group__c objExamGrp;
    static Exam_Group__c objExamGrpNew;
    static Exam_Attempt__c attempt;
    static Exam_Attempt__c attempt2,attempt3,attempt4;
    static Exam__c exam;
    static Exam__c exam2;
    static Exam_Sites__c exmSite;
    static Exam_Sites__c exmSite2;
    static Site__c site;
    static venue__c venue;
    static room__c room;
    static Exam_Administration__c examAdmin;
    static Exam_Administration__c examAdmin2;
    static Exam_Part__c examPart;
    static Exam_Part__c examPart2;
    static Exam_Registration_Modification__c modification; 
    
    static void testData(){ 
        Acc = new Account(Name = 'test');
        insert acc;
        
        contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        pb = new PriceBook2();
        pb.Id = Test.getStandardPricebookId();
        pb.IsActive = true;
        
        update pb;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prd = new Product2();
        prd.Name = 'FRM1';
        prd.ProductCode = 'FRM1';
        prd.GL_Code__c = '4020';
        prd.IsActive = true;
        prd.Company__c = 'GARP';
        prodList.add(prd);
        
        Product2 prd2 = new Product2();
        prd2.Name = 'ERP';
        prd2.ProductCode = 'ENC';
        prd2.GL_Code__c = '4020';
        prd2.IsActive = true;
        prd2.Company__c = 'GARP';
        prodList.add(prd2);
        
        insert prodList;
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.IsActive = true;
        pbe.UnitPrice = 150;
        pbe.PriceBook2Id = pb.Id;
        pbe.Product2Id = prodList[0].id;
        pbeList.add(pbe);
        
        PriceBookEntry pbe2 = new PriceBookEntry();
        pbe2.IsActive = true;
        pbe2.UnitPrice = 150;
        pbe2.PriceBook2Id = pb.Id;
        pbe2.Product2Id = prodList[1].id;
        pbeList.add(pbe2);
        
        insert pbeList;
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        List<Exam_Group__c> examGrpList = new List<Exam_Group__c>();
        objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true; 
        objExamGrp.Exam_Date__c = system.today().addDays(13);
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today().addDays(1);
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today().addDays(9) ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today().addDays(10) ; 
        examGrpList.add(objExamGrp);
        
        objExamGrpNew = new Exam_Group__c();
        objExamGrpNew.Active__c = false; 
        objExamGrpNew.Exam_Date__c = system.today().addDays(15);
        objExamGrpNew.Registration_Start_Date__c = system.today().addDays(5);
        objExamGrpNew.Last_Date_For_Early_Registration__c = system.today().addDays(3);
        objExamGrpNew.Last_Date_For_Standard_Registration__c = system.today().addDays(11) ;
        objExamGrpNew.Last_Date_For_Late_Registration__c = system.today().addDays(12) ;
        examGrpList.add(objExamGrpNew);
        
        insert examGrpList;
        
        List<Exam__c> examList = new List<Exam__c>();
        exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1';
        examList.add(exam);
        
        exam2 = new Exam__c();
        exam2.Exam_Group__c = objExamGrp.id;
        exam2.Exam_Date__c = system.today() + 30;
        exam2.exam__c = 'FRM Part 2'; 
        examList.add(exam2);
        insert examList;
        
        List<Exam_Administration__c> examAdminList = new List<Exam_Administration__c>();
        examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = objExamGrp.id;
        examAdmin.Exam_Date__c = system.today();
        examAdminList.add(examAdmin);
        
        examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = objExamGrpNew.id;
        examAdmin2.Exam_Date__c = system.today().addDays(30);
        examAdminList.add(examAdmin2);
        insert examAdminList;
        
        List<Exam_Part__c> examPartList = new List<Exam_Part__c>();
        examPart = new Exam_Part__c();
        examPart.Exam__c = exam.id;
        examPart.Exam_Administration__c = examAdmin.id;
        examPart.Exam_Date__c = system.today();
        examPart.Delivery_Method__c = 'CBT';
        
        examPart2 = new Exam_Part__c();
        examPart2.Exam__c = exam2.id;
        examPart2.Exam_Administration__c = examAdmin2.id;
        examPart.Exam_Date__c = system.today().adddays(30);
        examPart2.Delivery_Method__c = 'CBT';
        insert examPart;
        
        List<Exam_Sites__c> siteList = new List<Exam_Sites__c>();
        exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        siteList.add(exmSite);
        exmSite2 = new Exam_Sites__c(Site__c = site.id,exam__c = exam2.id);
        siteList.add(exmSite2);
        insert siteList; 
        
        venue = new venue__c(site__c = site.id,active__c = true);
        insert venue;
        
        room = new room__c (Venue__c  = venue.id,Capacity__c = 100,Active__c = true);
        insert room;
        //ATAPSIUtilClass.examRegistrationTriggerRecursion = true;
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        attempt = new Exam_Attempt__c(Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt);
        
        attempt2 = new Exam_Attempt__c(Exam_Administration__c = examAdmin2.Id,Exam_Part__c = examPart2.Id, Exam_Site__c = exmSite2.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt2);
        
        attempt3 = new Exam_Attempt__c(Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart2.Id, Exam_Site__c = exmSite2.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt3);
        
        attempt4 = new Exam_Attempt__c(Exam_Administration__c = examAdmin2.Id,Exam_Part__c = examPart2.Id, Exam_Site__c = exmSite2.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt4);
        insert examAttemptList;
        
        modification = new Exam_Registration_Modification__c();
        modification.Part_I_Exam_Registration__c = attempt.id;
        modification.Part_I_Exam_Admin_From__c = examAdmin.id;
        modification.Part_I_Exam_Admin_To__c = examAdmin2.id;
        modification.Part_I_Exam_Group_From__c = objExamGrp.Id;
        modification.Part_I_Exam_Group_To__c = objExamGrpNew.Id;
        modification.Part_I_Exam_Part_From__c = examPart.Id;
        modification.Part_I_Exam_Part_To__c = examPart2.Id;
        modification.Part_I_Exam_Site_From__c = exmSite.id;
        modification.Part_I_Exam_Site_To__c = exmSIte2.id;
        modification.Part_II_Exam_Registration__c = attempt2.id;
        modification.Part_II_Exam_Admin_To__c = examAdmin.id;
        modification.Part_II_Exam_Admin_From__c = examAdmin2.id;
        modification.Part_II_Exam_Group_To__c = objExamGrp.Id;
        modification.Part_II_Exam_Group_From__c = objExamGrpNew.Id;
        modification.Part_II_Exam_Part_To__c = examPart.Id;
        modification.Part_II_Exam_Part_From__c = examPart2.Id;
        modification.Part_II_Exam_Site_To__c = exmSite.id;
        modification.Part_II_Exam_Site_From__c = exmSIte2.id;
        modification.Status__c = 'Pending Bulk Modification';
        insert modification;
        
        
    }
    
    static testMethod void testOpportunityCreation(){
        testData();
        
        Exam_Registration_Modification__c modification2 = new Exam_Registration_Modification__c();
        modification2.Part_I_Exam_Registration__c = attempt.id;
        modification2.Part_I_Exam_Admin_From__c = examAdmin.id;
        modification2.Part_I_Exam_Admin_To__c = examAdmin2.id;
        modification2.Part_I_Exam_Group_From__c = objExamGrp.Id;
        modification2.Part_I_Exam_Group_To__c = objExamGrpNew.Id;
        modification2.Part_I_Exam_Part_From__c = examPart.Id;
        modification2.Part_I_Exam_Part_To__c = examPart2.Id;
        modification2.Part_I_Exam_Site_From__c = exmSite.id;
        modification2.Part_I_Exam_Site_To__c = exmSIte2.id;
        modification2.Part_II_Exam_Registration__c = attempt2.id;
        modification2.Part_II_Exam_Admin_To__c = examAdmin.id;
        modification2.Part_II_Exam_Admin_From__c = examAdmin2.id;
        modification2.Part_II_Exam_Group_To__c = objExamGrp.Id;
        modification2.Part_II_Exam_Group_From__c = objExamGrpNew.Id;
        modification2.Part_II_Exam_Part_To__c = examPart.Id;
        modification2.Part_II_Exam_Part_From__c = examPart2.Id;
        modification2.Part_II_Exam_Site_To__c = exmSite.id;
        modification2.Part_II_Exam_Site_From__c = exmSIte2.id;
        modification2.Status__c = 'Pending Bulk Modification';
        
        insert modification2;
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        opp.EA_Id__c = attempt.id;
        opp.Exam_Registration_Modification__c = modification.id;
        update opp;
               
        test.startTest();
        Id batchInstanceId1 = Database.executeBatch(new processRegModifications_Batch('October 24,2020','January 16,2021',modification2.Id),1);
        test.stopTest();
    }
    
    static testMethod void testOpportunityCreation1(){
        testData();
        Exam_Registration_modification__c modification1 = new Exam_Registration_modification__c();
        
        modification1.Part_I_Exam_Admin_From__c = examAdmin.id;
        modification1.Part_I_Exam_Admin_To__c = examAdmin2.id;
        modification1.Part_I_Exam_Group_From__c = objExamGrp.Id;
        modification1.Part_I_Exam_Group_To__c = objExamGrpNew.Id;
        modification1.Part_I_Exam_Part_From__c = examPart.Id;
        modification1.Part_I_Exam_Part_To__c = examPart2.Id;
        modification1.Part_I_Exam_Site_From__c = exmSite.id;
        modification1.Part_I_Exam_Site_To__c = exmSIte2.id;
        modification1.Part_II_Exam_Registration__c = attempt4.id;
        modification1.Part_II_Exam_Admin_To__c = examAdmin.id;
        modification1.Part_II_Exam_Admin_From__c = examAdmin2.id;
        modification1.Part_II_Exam_Group_To__c = objExamGrp.Id;
        modification1.Part_II_Exam_Group_From__c = objExamGrpNew.Id;
        modification1.Part_II_Exam_Part_To__c = examPart.Id;
        modification1.Part_II_Exam_Part_From__c = examPart2.Id;
        modification1.Part_II_Exam_Site_To__c = exmSite.id;
        modification1.Part_II_Exam_Site_From__c = exmSIte2.id;
        modification1.Status__c = 'Pending Bulk modification';
        
        insert modification1;
        
        
        Opportunity opp1 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp1;
        
        opp1.Late_Ea_Id__c = attempt4.id;
        opp1.Exam_Registration_Modification__c = modification1.id;
        update opp1;
        
        test.startTest();
        Database.executeBatch(new processRegModifications_Batch('October 24,2020','January 16,2021',modification1.id),1);
        test.stopTest();
    }
    
    static testMethod void testOpportunityCreation2(){
        testData();
        
        
        test.startTest();
        Database.executeBatch(new processRegModifications_Batch('October 24,2020','January 16,2021'),1);
        test.stopTest();
    }
    
    static testMethod void testAttemptCreation(){
        testData();
        test.startTest();
        modification.Status__c = 'Opportunity Created';
        update modification;
                
        Id batchInstanceId = Database.executeBatch(new processRegistrationDeferral_Batch(),1);
        
        test.stopTest();
    }
    
    static testMethod void testDeferPending(){
        testData();
        test.startTest();
        modification.Status__c = 'Opportunity Created';
        update modification;
        Id batchInstanceId = Database.executeBatch(new processExamRegModificationToPndngBatch(),1);
        
        test.stopTest();
    }
    
    static testMethod void testDefSameGrp_Batch(){
        testData();
        test.startTest();
        modification.Part_I_Exam_Group_To__c = objExamGrp.Id;
        modification.Status__c = 'Opportunity Created';
        update modification;
        Id batchInstanceId = Database.executeBatch(new processRefDefSameGrp_Batch(),1);
        
        test.stopTest();
    }
}