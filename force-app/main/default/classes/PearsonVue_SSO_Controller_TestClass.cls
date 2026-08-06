@isTest
public class PearsonVue_SSO_Controller_TestClass {
  @testSetup
    Public static void createObjects(){
        Account account = new Account();
        account.Name = 'TEST';
        INSERT account;
        
        Contact contact = new Contact();
        contact.FirstName = 'TEST';
        contact.LastName = 'TEST';
        contact.Email = 'test@test.com';
        contact.AccountId = account.Id;
        contact.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contact', 'Member');
        INSERT contact;
        
        Exam__c exam = new Exam__c ();
        exam.Name = 'Test Exam';
        exam.Exam__c = 'Test Exam';
        Id stExam = Schema.SObjectType.Exam__c.getRecordTypeInfosByName().get('SCR').getRecordTypeId();
        exam.RecordtypeId= stExam;
        exam.Exam_Date__c = system.now().date();
       // exam.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam', 'SCR');
        insert exam;
        
        Exam_Sites__c ExamSite = new Exam_Sites__c ();
        ExamSite.Name = 'Test ExamSite';
        insert ExamSite;
        
        Exam_Attempt__c  ExamReg = new Exam_Attempt__c ();
        ExamReg.Name = 'Test Exam Registration';
        ExamReg.Exam_Site__c = ExamSite.Id;
        ExamReg.Member__c = contact.Id; 
        insert ExamReg;
    }
    
    Public testMethod static void testAll(){
        PearsonVue_SSO_Controller PearsonSSO = new PearsonVue_SSO_Controller();
    }
}