@isTest
public class ATA_SSOIntegrationClass_Test {
	Static Account account;
	Static Contact contact;
    Static Site__c site;
    Static Exam_Group__c objExamGrp;
    Static Exam__c exam;
    Static Exam_Sites__c exmSite;
    Static Opportunity opportunity;
    Static Contract contract;
    Static Exam_Attempt__c attempt;
    static Exam_Administration__c examAdmin;
    static Exam_Part__c examPart;
    
    static void testSetup() {
        account = new Account();
        account.Name = 'test';
        insert account;
        
        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        Exam_Group__c examGroup = new Exam_Group__c(
            Active__c = TRUE,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRM/ERP'),
            Exam_Date__c = System.today().addDays(60),
            Registration_Start_Date__c = System.today().addDays(-10),
            Last_Date_For_Early_Registration__c = System.today().addDays(10),
            Last_Date_For_Standard_Registration__c = System.today().addDays(20),
            Last_Date_For_Late_Registration__c = System.today().addDays(30)
        );
        INSERT examGroup;
        
        exam = new Exam__c();
        exam.Exam_Group__c = examGroup.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 2'; 
        insert exam;
        
        exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        insert exmSite;
        
        opportunity = new Opportunity(amount = 123,Name = 'Test',company__c = 'Payment', accountId = account.id,stageName = 'Closed Won',Eligible_for_Membership_Extension__c = true,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity;
        
        contract  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program'),Opportunity__c = opportunity.id,accountId = opportunity.AccountId); 
        insert contract;
        
        examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = examGroup.id;
        examAdmin.Exam_Date__c = system.today();
        insert examAdmin;
        
        examPart = new Exam_Part__c();
        examPart.Exam__c = exam.id;
        examPart.Exam_Administration__c = examAdmin.id;
        examPart.Exam_Date__c = system.today();
        examPart.Delivery_Method__c = 'CBT';
        examPart.ATA_Batch_Code__c = '12345';
        insert examPart;
        
        attempt = new Exam_Attempt__c(Opportunity__c = opportunity.id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false,
                                      Candidate_Commitment__c = contract.id,ATA_Cert_id__c = 'Test',ATA_Cert_Type__c = 'Test Type',
                                      ATA_Name_as_it_appears_on_ID__c = 'Test User',Exam_Administration__c = examAdmin.id,Exam_Part__c = examPart.Id);
        insert attempt;
    }
    
    static testmethod void testSSOResponse(){
        testSetup();
        Test.StartTest(); 
        PageReference pageRef = Page.ATA_SSOPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',attempt.id);
        ATA_SSOIntegrationClass ssoTest = new ATA_SSOIntegrationClass();
        ssoTest.getATASSOjwtResponse();
		Test.StopTest();
    }
}