@istest
public class batchCreateProfileIds_test
{
 
 static Contract cont;
 
    static void testdata()
    {
            
             
             
            Account a1 = new Account(name = 'Test Account1',Profile_ID_Created_Date__c=system.today());
            insert a1;
        
            ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Merchant_ID__c = 'test-4',ChargentBase__Active__c = true );
            insert chrgGtway;
        
            insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
            
            opportunity o1 = new Opportunity(Gateway__c = chrgGtway.id,Token__c ='vx123456',amount = 123,Name = 'Test', CurrencyIsoCode = 'USD', Eligible_for_Membership_Extension__c = false,Company__c = 'GARP', accountId = a1.id,stageName = 'New Lead',Program__c = 'Print',closedate = system.today().addYears(-1),Pay_By_Wire_Check__c=false);        
            insert o1; 
         
         
        cont  = new Contract(Opportunity__c = o1.id, AccountId = a1.id ,ContractTerm = 12,StartDate = o1.CloseDate);
        insert cont;

        cont.Status = 'Activated ( Auto-Renew )';
        update cont;
        cont = [select Id, status ,EndDate ,Account.Profile_ID_Created_Date__c,Opportunity__c,Opportunity__r.AccountId,Opportunity__r.Token__c from contract where id =: cont.Id];
        system.debug('Con :'+cont);     
        
        PayPal_Recurring_Settings__c  payPal = new PayPal_Recurring_Settings__c(Vendor__c = 'test',UserName__c='test U Name',Password__c='Test pwd',Partner__c='test Vendor',EndPoint__c='https://pilot-payflowpro.paypal.com');
        insert payPal;
        
    }
    
        public static testmethod void myunittest()
        {
        test.starttest();
        testdata();
        batchCreateProfileIds Process1 = new batchCreateProfileIds();
        database.executebatch(Process1);
            
       test.stoptest();  
        
        
        }
}