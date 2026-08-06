@isTest
public class CalculateExperienceBatchTrigger_Test {
    
    static Account account ;
    static Opportunity opportunity; 
    static Contact contact;
    static Candidate_Requirement__c cr;
    static contract con;
    
    @testSetup static void testdata(){
        
        account = new Account(Name = 'test');
        insert account;
        
        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        opportunity = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity; 
        
        con = new contract(StartDate = system.today(),ContractTerm = 12,Accountid = account.id,Status = 'Draft',CurrencyIsoCode = 'USD');
        insert con;
        con.Status = 'Activated ( Auto-Renew )';
        con.ContractTerm = 24;
        con.StartDate = date.newInstance(2021, 01, 01);
        con.recordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
        update con;        
        
        cr = new Candidate_Requirement__c();
        cr.Date_Of_Completion__c=System.today();
        cr.Name='CPD Credit';
        cr.Candidate_Commitment__c = con.id;
        cr.Status__c = 'Ready For Review';
        insert cr;
    }
    
    @isTest
    static void unitTest1(){
        testdata();

        
        List<Experience__c> expList = new List<Experience__c>();
        Experience__c exprn1 = new Experience__c ();
        exprn1.company__c = account.id;
        exprn1.Contact__c = contact.id;
        exprn1.Program_Requirement__c = cr.id;
        exprn1.CompanyOther__c = 'yteurisskjb';
        exprn1.Job_Description__c = 'trew';
        exprn1.Start_Date__c = Date.newInstance(2023, 3, 7);
        exprn1.End_Date__c = system.today() +12;
        expList.add(exprn1);
        
        Experience__c exprn2 = new Experience__c ();
        exprn2.company__c = account.id;
        exprn2.Contact__c = contact.id;
        exprn2.CompanyOther__c = 'yteuriskjb';
        exprn2.Program_Requirement__c = cr.id;
        exprn2.Job_Description__c = 'tresw';
        exprn2.Start_Date__c = Date.newInstance(2023, 1, 7);
        exprn2.End_Date__c = Date.newInstance(2023, 6, 7);
        expList.add(exprn2);
        
        test.startTest();
        
        insert expList;
        system.schedule('Test Schedule','0 0 0 * * ?',new CalculateExperienceBatch_Scheduler());
        exprn2.End_Date__c = Date.newInstance(2023, 9, 7);
        update expList;
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest2(){
        testdata();
        
        Experience__c exprn1 = new Experience__c ();
        exprn1.company__c = account.id;
        exprn1.Contact__c = contact.id;
        exprn1.Program_Requirement__c = cr.id;
        exprn1.CompanyOther__c = 'yteurisskjb';
        exprn1.Job_Description__c = 'trew';
        exprn1.Start_Date__c = Date.newInstance(2023, 3, 7);
        exprn1.End_Date__c = system.today() +12;
        insert exprn1;
        
        test.startTest();
        system.schedule('Test Schedule','0 0 0 * * ?',new CalculateExperienceBatch_Scheduler());
        delete exprn1;
        test.stopTest();
    }
}