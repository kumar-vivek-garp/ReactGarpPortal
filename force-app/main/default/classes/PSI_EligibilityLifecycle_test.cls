@istest 
public class PSI_EligibilityLifecycle_test {

    Static Account account;
	Static Contact contact;
    Static Site__c site;
    Static Exam_Group__c objExamGrp;
    Static Exam__c exam;
    Static Exam_Sites__c exmSite;
    Static Opportunity opportunity;
    Static Contract contract;
    Static Exam_Attempt__c attempt;
    Static Integration_Data__c intdata;
    Static Integration_Data__c intdata1;
    Static Integration_Data__c intdata2;
    Static List<Integration_Data__c> lstIntdata = new List<Integration_Data__c>();
    
    @testSetup
    public static void testSetup() {
        account = new Account();
        account.Name = 'test';
        insert account;
        
        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
       /* objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today()+4;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today()+6 ;    
        insert objExamGrp;*/
        
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
        exam.exam__c = 'FRM Part 1'; 
        insert exam;
        
        exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        insert exmSite;
        
        opportunity = new Opportunity(amount = 123,Name = 'Test',company__c = 'Payment', accountId = account.id,stageName = 'Closed Won',Eligible_for_Membership_Extension__c = true,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity;
        
        contract  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program'),Opportunity__c = opportunity.id,accountId = opportunity.AccountId); 
        insert contract;
        
        attempt = new Exam_Attempt__c(Opportunity__c = opportunity.id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false,Candidate_Commitment__c = contract.id,Integration_Type__c='');
        insert attempt; 
        
        intdata = new Integration_Data__c();
        intdata.Contract__c = contract.Id;
        intdata.Exam_Registrations__c = attempt.id;
        intdata.Version_Number__c = 1;
        intdata.Name ='test';
        intdata.Is_Active__c =true;
        intdata.Garp_Id__c ='01404258';
        intdata.Exam_Type__c = 'SCR';
        intdata.Pearson_Event_Type__c ='ExamDelivered';
        intdata.Pearson_Vue_Appointment_ID__c = '210378726';
        intdata.PSI_Test_code__c = 'test123';
        intdata.Integration_Type__c = 'Eligibility Lifecycle';
        intdata.PSI_schedule_start_date__c = date.today().format();
        intdata.PSI_eligibility_end_date__c = date.today().format();
        intdata.RecordTypeId = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('PSI').getRecordTypeId();
        intdata.PSI_client_eligibility_id__c = 'PSI-0000000';
        lstIntdata.add(intdata);
        
        intdata1 = new Integration_Data__c();
        intdata1.Contract__c = contract.Id;
        intdata1.Exam_Registrations__c = attempt.id;
        intdata1.Version_Number__c = 1;
        intdata1.Name ='test';
        intdata1.Is_Active__c =true;
        intdata1.Garp_Id__c ='01404258';
        intdata1.Exam_Type__c = 'SCR';
        intdata1.Pearson_Event_Type__c ='ExamDelivered';
        intdata1.Pearson_Vue_Appointment_ID__c = '210378726';
        intdata1.PSI_Test_code__c = 'test123';
        intdata1.Integration_Type__c = 'Update Eligibility Lifecycle';
        intdata1.PSI_schedule_start_date__c = date.today().format();
        intdata1.PSI_eligibility_end_date__c = date.today().format();
        lstIntdata.add(intdata1);
        
        intdata2 = new Integration_Data__c();
        intdata2.Contract__c = contract.Id;
        intdata2.Exam_Registrations__c = attempt.id;
        intdata2.Version_Number__c = 1;
        intdata2.Name ='test';
        intdata2.Is_Active__c =true;
        intdata2.Garp_Id__c ='01404258';
        intdata2.Exam_Type__c = 'SCR';
        intdata2.Pearson_Event_Type__c ='ExamDelivered';
        intdata2.Pearson_Vue_Appointment_ID__c = '210378726';
        intdata2.PSI_Test_code__c = 'test123';
        intdata2.Integration_Type__c = 'Cancel Eligibility Lifecycle';
        intdata2.PSI_schedule_start_date__c = date.today().format();
        intdata2.PSI_eligibility_end_date__c = date.today().format();
        lstIntdata.add(intdata2);
        
        insert lstIntdata;
    }
    Private static testMethod void PSIEligibilityLifecycleCallout() {
        
        Set<Id> intIds = new Set<Id>();
        for(Integration_Data__c intId :[Select id from Integration_Data__c]) {
            intIds.add(intId.id);
        }
        test.startTest();
        // Test.setMock(HttpCalloutMock.class, new Mock_PSI_EligibilityLifeCycle_test());
        system.debug('===========STARTED===========');
        PSI_EligibilityLifecycle.PSIEligibilityLifecycleCallout(intIds);
        test.stopTest();
    }
    
    Private static testMethod void PSIEligibilityLifecycleCalloutQueueTest() {
        
        Set<Id> intIds = new Set<Id>();
        for(Integration_Data__c intId :[Select id from Integration_Data__c]) {
            intIds.add(intId.id);
        }
        test.startTest();
        ID jobID = System.enqueueJob(new PSICallOutQueueable(intIds));
        test.stopTest();
     }
   	 
}