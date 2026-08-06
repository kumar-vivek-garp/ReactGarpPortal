@isTest
public class ErrorIntegrationDataBatch_TestClass {
    
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
        
        for(integer i = 0 ;i<10;i++){
        intdata = new Integration_Data__c();
        intdata.Contract__c = contract.Id;
        intdata.Exam_Registrations__c = attempt.id;
        intdata.Version_Number__c = 1;
        intdata.Name ='test'+i;
        intdata.Call_out_Status__c = 'Error';
        intdata.RecordTypeId = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('PSI').getRecordTypeId();
        intdata.Integration_Type__c = 'Eligibility Lifecycle';
        intdata.Outbound_Event_Types__c = 'PSI';
        intdata.Is_Active__c =true;
        intdata.Garp_Id__c ='01404258';
        intdata.Exam_Type__c = 'SCR';
        
        lstIntdata.add(intdata);
        }
        insert lstIntdata;
    }
        // List<Integration_Data__c> lst = [SELECT Id,Name,Call_out_Status__c,RecordTypeId,Call_out_Type__c, Integration_Type__c,Outbound_Event_Types__c,Contract__c,Exam_Registrations__c from Integration_Data__c];
    static testMethod void testBatch() {
		testSetup();        
        test.starttest();
        ErrorIntegrationDataBatchClass batch = new ErrorIntegrationDataBatchClass ();   
        database.executeBatch(batch);
    }
    
    static testMethod void testScheduler() {  
        testSetup(); 
        test.starttest();
        ErrorIntegrationDataBatchClassScheduler myClass = new ErrorIntegrationDataBatchClassScheduler ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}