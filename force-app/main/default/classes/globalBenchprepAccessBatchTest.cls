@isTest
public class globalBenchprepAccessBatchTest {
     @TestSetup
    static void createTestData() {
        Integer totalCount = 1; 
        
        List<Opportunity> OppResults =TestDataFactory.createOpportunity(totalCount);
        //oppresults
        insert OppResults;
        
    }
    
    @isTest static void globalBenchprepAccessBatchTest(){
        Opportunity opp = [Select Id From Opportunity limit 1];
        test.startTest();
        Database.executebatch(new globalBenchprepAccessBatch(opp.Id));
        test.stopTest();
    }
    
    static testMethod void myTestMethod() {        
        test.starttest();
        globalBenchprepAccessBatch myClass = new globalBenchprepAccessBatch ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}