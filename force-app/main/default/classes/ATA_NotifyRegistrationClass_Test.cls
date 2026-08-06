@isTest
public class ATA_NotifyRegistrationClass_Test {
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
        exam.exam__c = 'FRM Part 2'; 
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
        intData.ATA_subject_code__c = 'FRM01';
        lstIntdata.add(intdata);
        
        insert lstIntdata;
    }
    
    static testMethod void testATAReservation() {
        testSetup();
        test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://Garp.com';  // sample Endpoint
        req.httpMethod = 'POST';
        
        ATA_NotifyRegistrationResponse nrr = new ATA_NotifyRegistrationResponse();
        nrr.event_id = '24beb856-bd20ab812712';
        nrr.sign = 'testSign';
        nrr.sign = 'testsign';
        nrr.event_created_at = '2020-10-14T00:01:27.721136+08:00';
        
        ATA_NotifyRegistrationResponse.reservation resrvtn = new ATA_NotifyRegistrationResponse.reservation();
        resrvtn.batch_no = '202009071317268869983496';
        resrvtn.cert_id = '1122334';
        resrvtn.batch_no = '2020090713';
        resrvtn.reg_code = '01404258';
        resrvtn.name = 'testUser';
        resrvtn.cert_type = '5';
        resrvtn.cert_id = '12345';
        resrvtn.exam_cert_no = '2020090713';
        resrvtn.start_time = '2021-05-20T08:00:00+08:00';
        resrvtn.end_time = '2021-05-21T08:00:00+08:00';
        resrvtn.region_code = '086001';
        resrvtn.region_name = 'Test Region';
        resrvtn.subject_code = 'FRM01';
        resrvtn.subject_name = 'FRM Exam Part I';
        resrvtn.org_name = 'Test Org';
        resrvtn.room_name = 'Test room';
        resrvtn.org_address = 'Test Address';
        resrvtn.room_address = 'Test Room Adrress';
        resrvtn.client_id = '1';
        resrvtn.reservation_at = '2020-10-19T16:01:27+08:00';
        
        nrr.event_data = json.serialize(resrvtn);
        nrr.event_type = 'reservation';
        
        req.requestBody = Blob.valueOf(json.serialize(nrr));
        
        RestContext.request = req;
        RestContext.response = res;
        ATA_NotifyRegistrationClass.ATA_NotifyRegistrationPost();
        test.stopTest();
     }
    
    static testMethod void testATACancelReservation() {
        testSetup();
        test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://Garp.com';  // sample Endpoint
        req.httpMethod = 'POST';
        
        ATA_NotifyRegistrationResponse nrr = new ATA_NotifyRegistrationResponse();
        nrr.event_id = '24beb856-bd20ab812712';
        nrr.sign = 'testSign';
        nrr.event_created_at = '2020-10-14T00:01:27.721136+08:00';
        
        ATA_NotifyRegistrationResponse.reservation resrvtn = new ATA_NotifyRegistrationResponse.reservation();
        resrvtn.batch_no = '202009071317268869983496';
        resrvtn.cert_id = '1122334';
        resrvtn.batch_no = '2020090713';
        resrvtn.reg_code = '01404258';
        resrvtn.name = 'testUser';
        resrvtn.cert_type = '5';
        resrvtn.cert_id = '12345';
        resrvtn.exam_cert_no = '2020090713';
        resrvtn.start_time = '2021-05-20T08:00:00+08:00';
        resrvtn.end_time = '2021-05-21T08:00:00+08:00';
        resrvtn.region_code = '086001';
        resrvtn.region_name = 'Test Region';
        resrvtn.subject_code = 'FRM01';
        resrvtn.subject_name = 'FRM Exam Part I';
        resrvtn.org_name = 'Test Org';
        resrvtn.room_name = 'Test room';
        resrvtn.org_address = 'Test Address';
        resrvtn.room_address = 'Test Room Adrress';
        resrvtn.client_id = '1';
        resrvtn.reservation_at = '2020-10-19T16:01:27+08:00';
        
        nrr.event_data = json.serialize(resrvtn);
        nrr.event_type = 'cancel_reservation';
        
        req.requestBody = Blob.valueOf(json.serialize(nrr));
        
        RestContext.request = req;
        RestContext.response = res;
        ATA_NotifyRegistrationClass.ATA_NotifyRegistrationPost();
        test.stopTest();
     }
}