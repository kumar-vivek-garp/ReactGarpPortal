@isTest
public class CBTVerifyJob_test {

    static testMethod void unitTest_1(){
        test.startTest();
        
        
        string CRON_EXP = '0 0 0 15 3 ? 2040';
        System.schedule('CBTVerifyJobTest',
                        CRON_EXP, 
                        new CBTVerifyJob());
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;

        Contact contact = new Contact(ID_Type__c='Driver#39%s License',lastname = 'Test',email='test@test.com');
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
        Exam_Part__c examPart = new Exam_Part__c(Exam__c = examFRM1.id,Exam_Administration__c = examAdmin.id,Exam_Date__c = system.today(),Delivery_Method__c = 'CBT',ATA_Batch_Code__c = '123456');
        examPartList.add(examPart);
        insert examPartList;
        
        List<Exam_Sites__c> siteList = new List<Exam_Sites__c>();
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM1.id);
        siteList.add(exmSite);
        insert siteList; 
        
        venue__c venue = new venue__c(site__c = site.id,active__c = true);
        insert venue;
        
        room__c room = new room__c (Venue__c  = venue.id,Capacity__c = 100,Active__c = true);
        insert room;
        
        Exam_Attempt__c attempt = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,ATA_Cert_Type__c = 'Driver#39%s License',Member__c = contact.id,cancelled__c = false );
        insert attempt;

        Integration_Data__c intd = new Integration_Data__c (Name='Int Data');
        insert intd;

        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,ATA_Cert_Type__c = 'Driver#39%s License',Member__c = contact.id,cancelled__c = false, Active_Integration_Data__c=intd.Id );
        insert attempt1;
        
        Lead lead = new Lead(lastname = 'test',firstName = 'test' ,status = 'Open',email= 'test@test.com', ID_Type__c= 'Driver#39%s License',company = acc.id);
        insert lead;
        
        AppError__c apperr = new AppError__c(Name='CBT Auth Failed',Message__c=attempt.Id);
        insert apperr;

        AppError__c apperr1 = new AppError__c(Name='CBT Auth Failed',Message__c=attempt1.Id);
        insert apperr1;

        CBTVerifyJob.fixID();               
        test.stopTest();
    }
}