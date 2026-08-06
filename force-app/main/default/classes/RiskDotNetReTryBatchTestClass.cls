@isTest
private class RiskDotNetReTryBatchTestClass {
    static testmethod void test() {
        List<Contract> con = new List<Contract>();
        Account acc = new Account (Name = 'Account');
        Insert acc;
        opportunity opportunity = new Opportunity(amount = 123,
                                      Name = 'Test',
                                      company__c = 'Payment', 
                                      accountId = acc.id,
                                      stageName = 'New Lead',
                                      Program__c = 'Print' ,
                                      closedate = system.today()+ 15);        
        insert opportunity; 
        Contract c = new Contract(Name = 'Contract',
                                  AccountId  = acc.Id,
                                  recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','Risk.Net'),
                                  API_Transaction_Status__c = 'Failure',
                                 Opportunity__c = opportunity.id);
        con.add(c);
        insert con;
        
        Test.startTest();
        RiskDotNetReTryBatchClass testRiskDotNet = new RiskDotNetReTryBatchClass();
        Database.executeBatch(testRiskDotNet);
        Test.stopTest();
    }
    
    static testMethod void Schedulable() {
        Test.startTest();
        RiskDotNetReTryBatchClass s1= new RiskDotNetReTryBatchClass();
        system.schedule('Test Schedule','0 0 0 * * ?',s1);
        Test.stopTest();
    }
}