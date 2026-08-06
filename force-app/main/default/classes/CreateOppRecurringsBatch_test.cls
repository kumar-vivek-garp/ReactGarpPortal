@isTest
private class CreateOppRecurringsBatch_test {
	static Account account ;
    static Opportunity opportunity; 
    static ChargentBase__Gateway__c chrgGtway;
    
    static ChargentOrders__Transaction__c chargentTrans;
    
    static void testData(){
        /*
        chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Merchant_ID__c = 'dasghjtru548709-4',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        */
        account = new Account(Name = 'test');
        insert account;
         
        opportunity = new Opportunity(Payment_Start_Date__c = System.today(),Payment_Frequency__c = 'Once',Payment_Status__c = 'Recurring',amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today(),Payment_Method_New__c = 'Credit Card');        
        insert opportunity;
        
        ChargentOrders__ChargentOrder__c order = [Select Id from ChargentOrders__ChargentOrder__c where Opportunity__c =: opportunity.Id];
         
        chargentTrans = new ChargentOrders__Transaction__c();
           
        chargentTrans.Opportunity__c = opportunity.iD;
        chargentTrans.ChargentOrders__Order__c = order.id;
        chargentTrans.ChargentOrders__Response_Status__c = 'Approved';
        chargentTrans.ChargentOrders__Amount__c = 123;
        chargentTrans.ChargentOrders__Type__c = 'Charge';
        chargentTrans.ChargentOrders__Recurring__c = true;
        chargentTrans.ChargentOrders__Gateway_Date__c = system.today()+1 ;
        insert chargentTrans;
    }
    static testMethod void myUnitTest() {
    	testdata();
        test.startTest();
        OpportunityHandler.stopRecurssion = false;
    	CreateOppRecurringsBatch batch  = new CreateOppRecurringsBatch();
    	database.executebatch(batch);
        test.stopTest();
    }
}