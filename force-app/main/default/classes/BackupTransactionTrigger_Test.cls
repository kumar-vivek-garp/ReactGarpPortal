@isTest
public class BackupTransactionTrigger_Test {
    
    @isTest
    static void unitTest(){
               
        Chargent_Backup_Event__e eve = new Chargent_Backup_Event__e(); 
       
        eve.Object_JSON__c = '[{"ChargentSFA__Type__c" : "Charge"}]';
               
        Eventbus.publish(eve);
        Test.getEventBus().deliver();       
        Test.StartTest();
    }
}