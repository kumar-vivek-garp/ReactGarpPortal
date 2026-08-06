@isTest
public class updateFreeDeferralBatch_Test {
@testSetup
    public static void testSetup(){
        String StrDefered = 'Approved';       
        String oppstatus = 'closed';
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp = new Opportunity(amount = 0,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = oppstatus,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
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
        insert examPartList;
        
        List<Exam_Sites__c> siteList = new List<Exam_Sites__c>();
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM1.id);
        siteList.add(exmSite);
        insert siteList;
        
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c = StrDefered,Opportunity__c = opp.id,Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt);
        insert examAttemptList;
        
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Defered__c = StrDefered,Opportunity__c = opp.id,Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false,Cloned_From__c = attempt.id);
        insert attempt2;
        
        Exam_Registration_Modification__c erm = new Exam_Registration_Modification__c();
        erm.Part_I_Exam_Registration__c = attempt.id;
        erm.Status__c = 'Completed';
        insert erm;
        
        opp.Exam_Registration_Modification__c = erm.id;
        update opp;
    }
    
    @isTest
    public static void testFRM1(){
        test.startTest();
        Id batchInstanceId = Database.executeBatch(new updateFreeDeferralBatch('FRM Part 1'),1);
        
        test.stopTest();
    }
}