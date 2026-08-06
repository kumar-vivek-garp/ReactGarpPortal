@isTest
public class batchCompleteOrExpireCPD_Test {

    Static Account acc;
    Static contract c;
    static void testdata()
    {
        acc = new Account(name = 'Test Account1', CurrencyIsoCode = 'USD', Calculated_Expire_Date__c = system.today(), Last_Contract_Exp_Calc__c = system.today());
        insert acc;
        Contact c1 = new contact(lastname = 'Test Contact1', AccountID = acc.ID, email = 'testcontact1@contact.com', KPI_Member__c = True );
        insert c1;
        contract con = new contract(StartDate = system.today(),ContractTerm = 12,Accountid = acc.id,Status = 'Draft',CurrencyIsoCode = 'USD');
        insert con;
        con.Status = 'Activated ( Auto-Renew )';
        con.ContractTerm = 24;
        Integer dty = System.today().addYears(-2).year();
        Date StartDate = date.newInstance(dty, 01, 01);
        con.StartDate = StartDate;
        con.recordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','CPE');
        update con;
        Id CPEPRRecordTypeID = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        Candidate_Requirement__c cr = new Candidate_Requirement__c(Name='CPD Credit',Candidate_Commitment__c = con.id,recordTypeID=CPEPRRecordTypeID,Status__c = 'Initial');
        insert cr;
        CPE_Activity_Type__c activity = new CPE_Activity_Type__c (name = 'Webcasts', Active__c = true);
        insert activity;
        CPE_Claim__c claim = new CPE_Claim__c (Candidate_Requirement__c = cr.id, Credits_Earned__c =40, Approved__c  = True, ApprovedCredits__c = 40);
        insert claim;
        
        Candidate_Requirement__c cr1 = new Candidate_Requirement__c(Name='CPD Credit',Candidate_Commitment__c = con.id,recordTypeID=CPEPRRecordTypeID,Status__c = 'Initial');
        insert cr1;
        CPE_Activity_Type__c activity1 = new CPE_Activity_Type__c (name = 'Webcasts', Active__c = true);
        insert activity1;
        CPE_Claim__c claim1 = new CPE_Claim__c (Candidate_Requirement__c = cr.id, Credits_Earned__c =30, Approved__c  = True, ApprovedCredits__c = 30);
        insert claim1;
        
    }
    
     static testMethod void myUnitTest() {
        testData();
         test.startTest();
        batchCompleteOrExpireCPD batch = new batchCompleteOrExpireCPD();
        database.executeBatch(batch);
         test.stopTest();
     }
}