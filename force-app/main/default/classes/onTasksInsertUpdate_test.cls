@isTest
public class onTasksInsertUpdate_test {

    static testMethod void unitTest_1(){
        
        test.startTest();

        Story__c sty = new Story__c(name = 'test story', Status__c = 'new');
        insert sty;
        
        Story_Task__c tsk1 = new Story_Task__c(name = 'task 1', Status__c = 'new', Story__c = sty.Id);
        insert tsk1;

        Story_Task__c tsk2 = new Story_Task__c(name = 'task 1', Status__c = 'new', Story__c = sty.Id);
        insert tsk2;
        
        try{

            tsk1.Status__c = 'In Progress';
            update tsk1;
            
            tsk2.Status__c = 'Blocked';
            update tsk2;

            tsk1.Status__c = 'Completed';
            update tsk1;

            tsk2.Status__c = 'Completed';
            update tsk1;
            
        }catch(Exception ex){}
        test.stopTest();
    }
    
       
}