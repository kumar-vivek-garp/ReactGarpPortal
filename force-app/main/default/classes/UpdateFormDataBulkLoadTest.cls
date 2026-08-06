@istest
public class UpdateFormDataBulkLoadTest {
    public static testmethod void UpdateFormDataBulkLoad(){
        
        Form__c fromobj = new Form__c();
        fromobj.Name = 'Test Form Data';
        fromobj.Subscriptions__c = 'A';
          insert fromobj;
        
        Form_Data__c fd = new Form_Data__c();
        fd.Form__c = fromobj.id; 
        
        fd.Subscription__c = 'Yes';
        fd.Bulk_Load__c =true;
        fd.Last_Name__c = 'TestLname';
        fd.First_Name__c = 'TestLname';
        fd.Marketing_Cloud_Conversion__c = true;
        insert fd;
        Test.StartTest();
        String CRON_EXP = '0 0 0 15 3 ? *';
        String jobId = System.schedule('UpdateFormDataBulkLoadBatchTest',  CRON_EXP, new ScheduleUpdateFormDataBulkLoad());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }
}