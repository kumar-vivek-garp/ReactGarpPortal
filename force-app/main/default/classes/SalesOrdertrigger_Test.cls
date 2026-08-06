@isTest
public class SalesOrdertrigger_Test {
    @isTest
    Static void unitTest(){
        
        Account Acc = new Account(Name = 'test',GARP_ID__c ='12345');
        insert acc;
        
        Id manualRecId = RecordTypeHelper.GetRecordTypeId('Opportunity','Manual'); 
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                          company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',
                                          Program__c = 'Print' ,closedate = system.today()+ 15, ia_crm__Intacct_Transaction__c = 'Salesforce - Refund',
                                          Display_Invoice_Number__c = 'W123',ia_crm__Intacct_Sync_Errors_1__c = 'Error',
                                          Payment_Method_New__c = 'Credit Card');        
        
        insert opp;
        
        Test.startTest();
        ia_crm__Sales_Order__c ord =  new ia_crm__Sales_Order__c();
        ord.ia_crm__Opportunity__c = opp.Id;
        insert ord;
        SalesOrderHandler soh = new SalesOrderHandler();
        soh.bulkBefore();
        soh.afterDelete(ord);
        soh.beforeInsert(ord);
        soh.beforeDelete(ord);
        Test.stopTest();
    }
}