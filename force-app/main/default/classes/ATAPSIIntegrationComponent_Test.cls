@isTest
public class ATAPSIIntegrationComponent_Test {
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
    
    static void testSetup() {
        account = new Account();
        account.Name = 'test';
        insert account;
        
        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),GARP_Member_ID__c = '10012');
        insert contact;
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        objExamGrp = new Exam_Group__c(
            Active__c = TRUE,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRM/ERP'),
            Exam_Date__c = System.today().addDays(60),
            Registration_Start_Date__c = System.today().addDays(-10),
            Last_Date_For_Early_Registration__c = System.today().addDays(10),
            Last_Date_For_Standard_Registration__c = System.today().addDays(20),
            Last_Date_For_Late_Registration__c = System.today().addDays(30)
        );
        INSERT objExamGrp;
        
        exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'ERP Exam Part I'; 
        insert exam;
        
        exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        insert exmSite;
        
        opportunity = new Opportunity(amount = 123,Name = 'Test',company__c = 'Payment', accountId = account.id,stageName = 'Closed Won',Eligible_for_Membership_Extension__c = true,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity;
        
        contract  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program'),Opportunity__c = opportunity.id,accountId = opportunity.AccountId); 
        insert contract;
        
        attempt = new Exam_Attempt__c(Opportunity__c = opportunity.id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false,Candidate_Commitment__c = contract.id,ATA_Cert_id__c = 'Test',ATA_Cert_Type__c = 'Test Type',ATA_Name_as_it_appears_on_ID__c = 'Test User');
        insert attempt; 
		
        List<Integration_Data__c> lstIntdata = new List<Integration_Data__c>();
		id ATARecordTypeId = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('ATA').getRecordTypeId();        
        intdata = new Integration_Data__c();
        intdata.Contract__c = contract.Id;
        intdata.Exam_Registrations__c = attempt.id;
        intdata.Version_Number__c = 1;
        intdata.Name ='test';
        intdata.Is_Active__c =true;
        intdata.Garp_Id__c ='01404258';
        intdata.Exam_Type__c = 'FRR';
        intdata.Outbound_Event_Types__c = 'ATA';
        intdata.Integration_Type__c = 'Import Registration New';
        intdata.RecordTypeId = ATARecordTypeId;
        intData.ATA_Cert_id__c = 'Test';
        intData.ATA_Cert_type__c = 'Others';
        intData.ATA_Name_as_it_appears_on_ID__c = 'Test User';
        intData.ATA_Batch_Code__c = '1234';
        intData.Is_Active__c = true;
        intData.ATA_Outbound_Batch_Code__c = '2020090713';
        intData.ATA_subject_code__c = 'ERP01';
        lstIntdata.add(intdata);
        
        insert lstIntdata;
        
        attempt.Active_Integration_Data__c = intData.id;
        update attempt;
    }
    
    static testMethod void testIntegrations() {
        testSetup();
        test.startTest();
        Exam_Attempt__c att = [Select Id, Garp_Id__c,Section__c from Exam_Attempt__c where Id =: attempt.id Limit 1];
        ATAPSIIntegrationComponentClass.getExamAttempt(att.id);
        Test.setMock(HttpCalloutMock.class, new ATA_ScheduleInterfaceClass_TestMock());
        ATAPSIIntegrationComponentClass.getPSIeligiblitiesCandidateId(att);
        test.stopTest();
     }
    
    static testMethod void testIntegrations2() {
        testSetup();
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ATA_ScheduleInterfaceClass_TestMock());
        ATAPSIIntegrationComponentClass.getExamAttemptList('ATA');
        ATAPSIIntegrationComponentClass.ATAQueryExamRegistation(attempt,'CheckReservation');
        ATAPSIIntegrationComponentClass.stripJsonNulls('{"timestamp":"2020-10-13T11:59:55-04:00","biz_content":[{"status":2,"region_subject":[{"subject_name":"FRM Exam Part I","subject_code":"FRM01","region_name":"China, Beijing","region_code":"086001"}],"reg_time":"2020-10-13T11:59:52-04:00","reg_code":"1496386","pay_status":2,"name":"testuser","gender":null,"cert_type":"5","cert_id":"1496386","batch_no":"202009071"}],"resp_msg": "SUCCESS"}');
        test.stopTest();
     }
    
    
}