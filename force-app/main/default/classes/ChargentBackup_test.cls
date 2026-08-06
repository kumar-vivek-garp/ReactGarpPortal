@istest
public class ChargentBackup_test{
 
        static string oppid;
        static void testdata(){
                 
                Account a1 = new Account(name = 'Test Account1');
                insert a1;
                
                ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(
                        Name = 'Test',
                        ChargentBase__Merchant_ID__c = 'test-4',
                        ChargentBase__Active__c = true 
                );
                insert chrgGtway;
                
                insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
                
                opportunity o1 = new Opportunity(Gateway__c = chrgGtway.id, amount = 123,Name = 'Test', CurrencyIsoCode = 'USD', Eligible_for_Membership_Extension__c = false,Company__c = 'GARP', accountId = a1.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15,Pay_By_Wire_Check__c=false);        
                insert o1; 
                
                oppid = o1.id;

                Paypalsettings__c prs = new Paypalsettings__c();
                prs.Partner__c = 'VeriSign';          
                prs.EndPoint__c = 'https://payflowpro.paypal.com';
                prs.Password__c = 'Test';
                prs.Paypal_GateWay_ID__c = chrgGtway.id;
                prs.UserName__c = 'Test';
                prs.Vendor__c = 'Test';
                prs.name ='GARP';
                insert prs;
        
        }
    
        public static testmethod void myunittest(){
                test.starttest();
                testdata();
                decimal amount =12.00;
                string cardnumber ='4111111111111111';
                string cardtype ='visa';
                string cardMonth ='5';
                string cvv ='123';
                string cardYear ='2020';
                ChargentBackup.paypalcallout(oppid,cardMonth,cardYear,cardType,cardNumber,cvv,amount);
        }
}