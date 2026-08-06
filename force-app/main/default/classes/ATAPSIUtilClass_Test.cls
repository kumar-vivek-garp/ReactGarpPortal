@isTest
public class ATAPSIUtilClass_Test {
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
        intData.ATA_Outbound_Batch_Code__c = '2020090713';
        intData.ATA_subject_code__c = 'ERP01';
        lstIntdata.add(intdata);
        
        insert lstIntdata;
        
        
        List<Integration_Data__c> lstIntdata1 = new List<Integration_Data__c>();
        id ATARecordTypeId1 = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('ATA').getRecordTypeId();        
        intdata1 = new Integration_Data__c();
        intdata1.Contract__c = contract.Id;
        intdata1.Exam_Registrations__c = attempt.id;
        intdata1.Version_Number__c = 1;
        intdata1.Name ='test';
        intdata1.Is_Active__c =true;
        intdata1.Garp_Id__c ='01404258';
        intdata1.Exam_Type__c = 'FRR';
        intdata1.Outbound_Event_Types__c = 'ATA';
        intdata1.Integration_Type__c = 'Import Registration New';
        intdata1.RecordTypeId = ATARecordTypeId1;
        intdata1.ATA_Cert_id__c = 'Test';
        intdata1.ATA_Cert_type__c = 'Others';
        intdata1.ATA_Name_as_it_appears_on_ID__c = 'Test User';
        intdata1.ATA_Batch_Code__c = '1234';
        intdata1.ATA_Outbound_Batch_Code__c = '2020090713';
        intdata1.ATA_subject_code__c = 'ERP01';
        lstintdata1.add(intdata1);
        insert lstintdata1;
        
        Api_Transaction__c at = new Api_Transaction__c(Integration_Data__c = lstIntdata[0].id );
        insert at;
        
    }
    static testmethod void testMethods(){
        testSetup();
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new ATA_ScheduleInterfaceClass_TestMock());
        PSI_Eligibility__mdt mtdt = ATAPSIUtilClass.getPSIEligibility_mdt();
        ATA_Scheduling_Interface__mdt ataMtdt = ATAPSIUtilClass.getATASchedulingInterface_mdt();
        //ATAPSIUtilClass.getPSIaccesstoken(mtdt);
        ATAPSIUtilClass.getLatestVersionIntegritaion(attempt.id);
        ATAPSIUtilClass.cloneActiveIntegrationData(new Set<Id>{intData.id});
        ATAPSIUtilClass.updateActiveRecordsPSIATA(new Set<Id>{intData.id});
        ATAPSIUtilClass.updateActiveRecords(new Set<Id>{intData.id},new Set<Id>{attempt.id});
        ATAPSIUtilClass.updateActiveRecords(new Set<Id>{intData1.id},new Set<Id>{attempt.id});
        ATAPSIUtilClass.getATAstatus('{"FIELD_NAME":"resp_msg"}');
        ATAPSIUtilClass.stripJsonNulls('{"Name":"Test"}');
        ATAPSIUtilClass.getATACertTypeList();
        test.stoptest();
    }
}