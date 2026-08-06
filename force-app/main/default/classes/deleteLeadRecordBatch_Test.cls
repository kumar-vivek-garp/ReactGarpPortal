@isTest
public class deleteLeadRecordBatch_Test {
    
    @isTest
    static void testBatch(){
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'test';
        ld.Company = 'test';
        insert ld;
        
        test.startTest();
        database.executeBatch(new deleteLeadRecordBatch());
        test.stopTest();
    }

}