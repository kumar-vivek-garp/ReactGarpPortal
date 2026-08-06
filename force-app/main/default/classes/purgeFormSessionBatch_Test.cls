@isTest
public class purgeFormSessionBatch_Test {
	@isTest
    static void testBatch(){
        Form_Session__c formSess = new Form_Session__c();
        insert formSess ;
        
        test.startTest();
        purgeFormSessionBatch batchable = new purgeFormSessionBatch();
        database.executeBatch(batchable);
        test.stopTest();
    }
}