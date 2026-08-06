@isTest
private class ExamSendingAuthorizationClsTest {
    @testSetup static void setupDate() {
        Default_Settings__c ds = new Default_Settings__c();
        ds.Name = 'Default';
        ds.ATA_PSI_Callout__c = true;
        insert ds;
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment',
                              accountId = acc.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',
                              KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        Site__c site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        List<Exam_Group__c> examGrpList = new List<Exam_Group__c>();
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true; 
        objExamGrp.Exam_Date__c = system.today().addDays(13);
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today().addDays(1);
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today().addDays(9) ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today().addDays(10) ; 
        examGrpList.add(objExamGrp);
        
        Exam_Group__c objExamGrpNew = new Exam_Group__c();
        objExamGrpNew.Active__c = false; 
        objExamGrpNew.Exam_Date__c = system.today().addDays(15);
        objExamGrpNew.Registration_Start_Date__c = system.today().addDays(5);
        objExamGrpNew.Last_Date_For_Early_Registration__c = system.today().addDays(3);
        objExamGrpNew.Last_Date_For_Standard_Registration__c = system.today().addDays(11) ;
        objExamGrpNew.Last_Date_For_Late_Registration__c = system.today().addDays(12) ;
        examGrpList.add(objExamGrpNew);
        
        insert examGrpList;
        Date examDate = date.newInstance(2021,01,16);
        List<Exam__c> examList = new List<Exam__c>();
        Exam__c examFRM1 = new Exam__c(Exam_Group__c = objExamGrp.id,Exam_Date__c = examDate,exam__c = 'FRM Part 1');
        examList.add(examFRM1);  
        insert examList;
        
        List<Exam_Administration__c> examAdminList = new List<Exam_Administration__c>();
        Exam_Administration__c examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = objExamGrp.id;
        examAdmin.Exam_Date__c = system.today();
        examAdminList.add(examAdmin);
         
        insert examAdminList;
        
        List<Exam_Part__c> examPartList = new List<Exam_Part__c>();
        Exam_Part__c examPart = new Exam_Part__c(Exam__c = examFRM1.id,Exam_Administration__c = examAdmin.id,
                                    Exam_End_Date__c=System.today()+30,Exam_Start_Date__c=System.today(),Exam_Date__c = null,Delivery_Method__c = 'CBT',ATA_Batch_Code__c = '123456');
        examPartList.add(examPart); 
         
        insert examPartList;
        
        List<Exam_Sites__c> siteList = new List<Exam_Sites__c>();
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM1.id);
        siteList.add(exmSite); 
        
        insert siteList; 
         

        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,
                                                      Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt); 
        insert examAttemptList;
    }

    @isTest static void unittest1() {
        test.startTest(); 
         Exam_Attempt__c attempt = [select Id From Exam_Attempt__c limit 1];
            ExamSendingAuthorizationCls.getExamRegistrations(null);
            ExamSendingAuthorizationCls.sendForAuthorization(attempt.Id);
        test.stopTest();        
    }
}