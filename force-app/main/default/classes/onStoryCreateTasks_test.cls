@isTest
public class onStoryCreateTasks_test{

    static testMethod void unit_test()
   
    {
        test.startTest();
        Story__c s = new  Story__c (Name = 'Test', Type__c = 'Operational', Add_Tasks__c = true, Create_Tasks__c = 'Edit Copy');
        Story__c sto = new  Story__c (Name = 'Peer Review', Type__c = 'Operational');
        Insert s;
        Insert sto;
        test.stopTest();
    }

}