@istest
public class processRecurringTransactions_test
{
 
	Static  opportunity o1;
    static void testdata()
    {
            
            
            Account a1 = new Account(name = 'Test Account1', Profile_ID__c = 'RP0000041014');
            insert a1;
        
            Contact c1 = new contact(lastname = 'Test Contact1', AccountID = a1.ID, email = 'testcontact1@contact.com', KPI_Member__c = True );
            insert c1;
        
            ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Merchant_ID__c = 'test-4',ChargentBase__Active__c = true );
            insert chrgGtway;
        
            insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
            o1 = new Opportunity(Gateway__c = chrgGtway.id, amount = 123,Name = 'Test', CurrencyIsoCode = 'USD', Eligible_for_Membership_Extension__c = false,Company__c = 'GARP', accountId = a1.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15,Pay_By_Wire_Check__c=false);        
            insert o1; 
        	
        	ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = o1.id);
        	insert order;  
        
            ChargentOrders__Transaction__c chargentTrans = new ChargentOrders__Transaction__c();
            chargentTrans.Opportunity__c = o1.id;
            chargentTrans.ChargentOrders__Type__c='Credit';
            chargentTrans.Backup_Auto_Renewal__c = True;
            chargentTrans.ChargentOrders__Amount__c = 123;
        	chargentTrans.ChargentOrders__Order__c = order.id;
            chargentTrans.ChargentOrders__Recurring__c = true;
            chargentTrans.ChargentOrders__Gateway_Date__c = system.today();
            chargentTrans.Charge_Now__c = true;
            chargentTrans.ChargentOrders__Response_Status__c = 'Denied';
            insert chargentTrans;

            PayPal_Recurring_Settings__c prs = new PayPal_Recurring_Settings__c();
            prs.Partner__c = 'VeriSign';
            prs.Email_Address__c = 'vvkathi@gmail.com';
            prs.EndPoint__c = 'https://payflowpro.paypal.com';
            prs.Password__c = 'Test';
            prs.Paypal_GateWay_ID__c = 'a1lf000000045VS';
            prs.UserName__c = 'Test';
            prs.Vendor__c = 'Test';
            insert prs;
        
    }
    
        public static testmethod void myunittest()
        {
		testdata();
        Test.setCreatedDate(o1.Id, Datetime.now().addDays(-3));
        test.starttest();
        processRecurringTransactions Process1 = new processRecurringTransactions();
        database.executebatch(Process1);
        test.stoptest();
        }
}