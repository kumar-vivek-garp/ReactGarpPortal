@isTest
public class AffiliateProgramTriggerTest {
    
    @IsTest
    static void unitTest(){
        
        Affiliate_Program__c ap = new Affiliate_Program__c();
        insert ap;
        update ap;
        
        test.startTest();
        
        Affiliate_Program__c ap1 = new Affiliate_Program__c();
        insert ap1;
        
        test.stopTest();
    }
}