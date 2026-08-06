@isTest

public class batchUpdateuserEmail_test{

    static Account acc;
    static contact con;
    static Opportunity opp;
    static Contract contract;
    static Candidate_Requirement__c reqt;
    
    static void testData(){
        Acc = new Account(Name = 'test', Member_Email__c='vvkat@g.com');
        insert acc;
         
        con = new contact(lastname='vv',email='vvkat@g.com',accountid=acc.id);
        insert con;
        con.email='vf1@f.com';
        update con;
        contactHistory hist=new contactHistory(Field='email',contactId =con.Id);
        insert hist;
        
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
       
         
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()- 100);        
        insert opp;
        
       

        string memRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
        string icbrrRecordType = RecordTypeHelper.GetRecordTypeId('Contract','ICBRR Program');
       
     
        
        Contract Contract1  = new Contract(Opportunity__c = opp.id, AccountId = acc.id ,ContractTerm = 12, Member_Email__c='vvkat@g.com' ,recordtypeID = icbrrRecordType  ,StartDate = opp.CloseDate);
        insert contract1;

        contract1.Status = 'Draft';
        update contract1;
        
        
        
        reqt = new Candidate_Requirement__c(Candidate_Email__c='vvkat@g.com', Email_GARP_Member__c='vvkat@g.com');
        reqt.Candidate_Commitment__c = contract1.id;
        reqt.name = 'FRM1 test';
        insert reqt;
        
       
        
    }
    
    static testMethod void unitTest_1(){
    
       
        
        testData();
        test.startTest();
        batchUpdateuserEmail contracts = new batchUpdateuserEmail();
        Database.executebatch(contracts);
        test.stopTest();
    }


}