@isTest
public class PaymentTransactionErrorBatch_Test {
	@isTest
    static void testBatch(){
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        eComm_Transaction__c tran = new eComm_Transaction__c(Opportunity_Id__c = opp.Id,Authorization__c = 'TestAuth',Chargent_Token__c = 'TestToken',Gateway_Id__c = 'TestToken',Response_Status__c = 'Approved',Gateway_Date__c = system.now());
        insert tran;
        
        test.startTest();
        PaymentTransactionErrorBatch_Sch myClass = new PaymentTransactionErrorBatch_Sch();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}