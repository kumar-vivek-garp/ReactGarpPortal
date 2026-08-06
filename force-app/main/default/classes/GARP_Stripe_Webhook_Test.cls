@isTest
public class GARP_Stripe_Webhook_Test {
    
    Static Opportunity opp;
    
    public static void testData(){
        Account acc = new Account(Name = 'Test');                
        insert acc;
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;   
        opp.Display_Invoice_Number__c = '123';
        update opp;
    }
    
    @isTest
    public static void unitTest1() {
        testData();
        test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/stripe/';
        String rawJson = '{\"id\":\"evt_3O4jphAyydB05IeX3BlAWGx3\",\"object\":\"event\",\"api_version\":\"2020-08-27\",\"created\":1698151298,\"type\":\"authorized\",\"data\":{\"object\":{\"id\":\"pi_3O4jphAyydB05IeX3Rsuyn1b\",\"object\":\"payment_intent\",\"amount\":100000,\"amount_capturable\":0,\"amount_details\":{\"tip\":{}},\"amount_received\":100000,\"application\":null,\"application_fee_amount\":null,\"automatic_payment_methods\":null,\"canceled_at\":null,\"cancellation_reason\":null,\"capture_method\":\"automatic\",\"charges\":{\"object\":\"list\",\"data\":[{\"id\":\"py_3O4jphAyydB05IeX3gzofjai\",\"object\":\"charge\",\"amount\":100000,\"amount_captured\":100000,\"amount_refunded\":0,\"application\":null,\"application_fee\":null,\"application_fee_amount\":null,\"balance_transaction\":\"txn_3O4jphAyydB05IeX3qgyh1sJ\",\"billing_details\":{\"address\":{\"city\":null,\"country\":null,\"line1\":null,\"line2\":null,\"postal_code\":null,\"state\":null},\"email\":\"garcia.alberto.crespo@gmail.com\",\"name\":null,\"phone\":null},\"calculated_statement_descriptor\":null,\"captured\":true,\"created\":1698151297,\"currency\":\"usd\",\"customer\":null,\"description\":null,\"destination\":null,\"dispute\":null,\"disputed\":false,\"failure_balance_transaction\":null,\"failure_code\":null,\"failure_message\":null,\"fraud_details\":{},\"invoice\":null,\"livemode\":false,\"metadata\":{\"orderid\":\"'+opp.Display_Invoice_Number__c+'\"},\"on_behalf_of\":null,\"order\":null,\"outcome\":{\"network_status\":\"approved_by_network\",\"reason\":null,\"risk_level\":\"not_assessed\",\"seller_message\":\"Payment complete.\",\"type\":\"authorized\"},\"paid\":true,\"payment_intent\":\"pi_3O4jphAyydB05IeX3Rsuyn1b\",\"payment_method\":\"pm_1O4jv4AyydB05IeXhb1A7w3g\",\"payment_method_details\":{\"alipay\":{\"fingerprint\":null,\"transaction_id\":null},\"type\":\"alipay\"},\"receipt_email\":\"alberto.garciaxxxxxssdsdaaaaaaaaaa@garp.com\",\"receipt_number\":null,\"receipt_url\":\"https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xSmhJbTBBeXlkQjA1SWVYKIL33qkGMgZ5bfe_ukA6LBYJAVMUr_8Qg939adE8upeWONLAGE_20YcXwHxwDg2ydCA764POcsbRuU6f\",\"refunded\":false,\"refunds\":{\"object\":\"list\",\"data\":[],\"has_more\":false,\"total_count\":0,\"url\":\"/v1/charges/py_3O4jphAyydB05IeX3gzofjai/refunds\"},\"review\":null,\"shipping\":null,\"source\":null,\"source_transfer\":null,\"statement_descriptor\":null,\"statement_descriptor_suffix\":null,\"status\":\"succeeded\",\"transfer_data\":null,\"transfer_group\":null}],\"has_more\":false,\"total_count\":1,\"url\":\"/v1/charges?payment_intent=pi_3O4jphAyydB05IeX3Rsuyn1b\"},\"client_secret\":\"pi_3O4jphAyydB05IeX3Rsuyn1b_secret_ZkDR0lEw0o9utxf5tPplRKvoo\",\"confirmation_method\":\"automatic\",\"created\":1698150941,\"currency\":\"usd\",\"customer\":null,\"description\":null,\"invoice\":null,\"last_payment_error\":null,\"latest_charge\":\"py_3O4jphAyydB05IeX3gzofjai\",\"livemode\":false,\"metadata\":{\"orderid\":\"'+opp.Display_Invoice_Number__c+'\"},\"next_action\":null,\"on_behalf_of\":null,\"payment_method\":\"pm_1O4jv4AyydB05IeXhb1A7w3g\",\"payment_method_configuration_details\":null,\"payment_method_options\":{\"alipay\":{},\"wechat_pay\":{\"app_id\":null,\"client\":null}},\"payment_method_types\":[\"alipay\",\"wechat_pay\"],\"processing\":null,\"receipt_email\":\"alberto.garciaxxxxxssdsdaaaaaaaaaa@garp.com\",\"review\":null,\"setup_future_usage\":null,\"shipping\":null,\"source\":null,\"statement_descriptor\":null,\"statement_descriptor_suffix\":null,\"status\":\"succeeded\",\"transfer_data\":null,\"transfer_group\":null}}}}';
        req.requestBody = Blob.valueof(rawJson);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;        
        
        GARP_Stripe_Webhook.handlePost();
        test.stopTest();
    }
    
}