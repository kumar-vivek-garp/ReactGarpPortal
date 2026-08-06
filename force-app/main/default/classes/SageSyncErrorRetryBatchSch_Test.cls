@isTest
public class SageSyncErrorRetryBatchSch_Test {
    
    @isTest
    Static void unitTest(){
        
        /*ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway;*/
        
        Account Acc = new Account(Name = 'test',GARP_ID__c ='12345');
        insert acc;
        
        Id manualRecId = RecordTypeHelper.GetRecordTypeId('Opportunity','Manual'); 
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                          company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',
                                          Program__c = 'Print' ,closedate = system.today()+ 15, 
                                          Display_Invoice_Number__c = 'W123',ia_crm__Intacct_Sync_Errors_1__c = 'Error',
                                          Payment_Method_New__c = 'Credit Card');        
                
        insert opp;
        
        Test.startTest();
        
        System.schedule('SageSyncReTryBatchScheduler Testing', '0 0 0 * * ?', new SageSyncReTryBatchScheduler());
        System.schedule('SageSyncErrorBatchScheduler Testing', '0 0 0 * * ?', new SageSyncErrorBatchScheduler());
        Test.stopTest();
    }

}