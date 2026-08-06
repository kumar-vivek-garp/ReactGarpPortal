@isTest
public class CPDClaimsApprovalBatchClass_Test {
    
    @isTest
    static void unitTest_Batch(){
        Account acc = new Account(Name = 'test');
        insert acc;
        
        Contact contact = new Contact(KPI_ERP_Certified__c = true,KPI_FRM_Certified__c = true,GARP_Directory_Opt_In__c = true,
                                      lastname = 'Test',AccountId = acc.id,email='fn.ln@garp.com',
                                      KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        contract con = new contract(StartDate = system.today(),Accountid = acc.id,Status = 'Draft',CurrencyIsoCode = 'USD',ContractTerm = 12);
        insert con;
        con.Status = 'Activated ( Auto-Renew )';
        con.ContractTerm = 24;
        con.StartDate = date.newInstance(2022, 01, 01);
        con.recordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','CPE');
        update con; 
        
        Candidate_Requirement__c cr = new Candidate_Requirement__c(Name='CPD Credit',Candidate_Commitment__c = con.id,Status__c = 'Initial');
        insert cr;
        
        CPE_Activity_Type__c acttype = new CPE_Activity_Type__c (name = 'test');
        insert acttype;
        
        CPE_Activity__c activity = new CPE_Activity__c(Description__c='desc',Organization__c='Org',Account__c=acc.Id,Area_of_Study__c='Area',Publication__c='Pub',URL__c='url',Title__c = 'test',Activity_Type_Description__c = 'test',Provider__c = 'test',CPE_Activity_Type__c  = acttype.id,Status__c = 'Active',Credit__c=1.0,End_Date__c=system.today()+ 15);
        insert activity;
        
        Datetime OnorBefore48 = Datetime.now().addDays(-3);
                
        CPE_Claim__c CPEClam = new  CPE_Claim__c(
            Credits_Earned__c =10,
            Candidate_Requirement__c = cr.id,
            CPD_Activity__c=activity.id,
            CPE_Activity_Type__c=acttype.id,
            To_Be_Approved__c = true,
            Approved__c = False);
        insert CPEClam;
        
        Test.setCreatedDate(CPEClam.Id, OnorBefore48);
        Test.startTest();
        // Schedule the test job
      	String jobId = System.Schedule('Scheduled for 9 AM Job Everyday','0 0 0 * * ?',new CPDClaimsApprovalBatchScheduler()) ;
        // Database.executeBatch(new CPDClaimsApprovalBatchClass());
        Test.stopTest();
        
    }
    
}