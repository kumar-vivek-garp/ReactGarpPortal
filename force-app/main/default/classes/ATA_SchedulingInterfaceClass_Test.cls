@isTest
public class ATA_SchedulingInterfaceClass_Test {
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
        lstIntdata.add(intdata);
        
        intdata1 = new Integration_Data__c();
        intdata1.Contract__c = contract.Id;
        intdata1.Exam_Registrations__c = attempt.id;
        intdata1.Version_Number__c = 1;
        intdata1.Name ='test';
        intdata1.Is_Active__c =true;
        intdata1.Garp_Id__c ='01404258';
        intdata1.Exam_Type__c = 'FRR';
        intdata1.Pearson_Event_Type__c ='ExamDelivered';
        intdata1.Outbound_Event_Types__c = 'ATA';
        intdata1.Integration_Type__c = 'Query Exam Cert';
        intdata1.ATA_Cert_id__c = 'Test';
        intdata1.ATA_Cert_type__c = 'Others';
        intdata1.ATA_Name_as_it_appears_on_ID__c = 'Test User';
        intdata1.ATA_Batch_Code__c = '5678';
        lstIntdata.add(intdata1);
        
        intdata2 = new Integration_Data__c();
        intdata2.Contract__c = contract.Id;
        intdata2.Exam_Registrations__c = attempt.id;
        intdata2.Version_Number__c = 1;
        intdata2.Name ='OSTA Information';
        intdata2.Is_Active__c =true;
        intdata2.Garp_Id__c ='01404258';
        intdata2.Exam_Type__c = 'FRR';
        intdata2.Outbound_Event_Types__c = 'ATA';
        intdata2.Integration_Type__c = 'Delete Registration';
        intData2.ATA_Cert_id__c = 'Test';
        intdata2.ATA_Cert_type__c = 'Others';
        intdata2.ATA_Name_as_it_appears_on_ID__c = 'Test User';
        intdata2.ATA_Batch_Code__c = '9012';
        lstIntdata.add(intdata2);
        
        insert lstIntdata;
    }
    static testMethod void testATAInterface() {
        testSetup();
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ATA_ScheduleInterfaceClass_TestMock());
        ATA_SchedulingInterfaceClass.ATASchedulingIntegration(new Set<Id>{intData.id,intData1.id,intData2.id});
        test.stopTest();
    }
    
    static testMethod void testATAInterfaceQueueable() {
        testSetup();
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ATA_ScheduleInterfaceClass_TestMock());
        ID jobID = System.enqueueJob(new ATACallOutQueueable(new Set<Id>{intData.id,intData1.id,intData2.id}));
        test.stopTest();
     }
}