@isTest

public class updateScrContracts_test{

    static Account acc;
    static Opportunity opp;
    static Contract contract;
    static Candidate_Requirement__c reqt;
    
    static void testData(){
        
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Merchant_ID__c = 'dasghjtru548709-4',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
        Acc = new Account(Name = 'test');
        insert acc;
         
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()- 100);        
        insert opp;
        
       

        string memRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
        string ScrRecordType = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program');
      
        
        Contract Contract6  = new Contract(recordtypeId = ScrRecordType ,Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contract6;
        contract6.Status = 'Draft';
        update contract6;
        
               
       
  
    }
    
    static testMethod void unitTest_1(){
    
        testData();
        test.startTest();
        updateScrContracts contracts = new updateScrContracts();
        Database.executebatch(contracts,1);
        test.stopTest();
    }


}