@isTest
public class ATA_ExamStatusCallOut_Test {
    static testMethod void testATA1() {
        //ATA_ExamStatusCallOut.ATAExamStatusIntegrationCallOut('Pul');
       // System.enqueueJob(Aesc);
       ATA_ExamStatusCallOut Aec = new ATA_ExamStatusCallOut('Pul');
       System.enqueueJob(Aec); 
    }
}