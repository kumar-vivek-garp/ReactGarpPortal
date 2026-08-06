@IsTest
public class StripeTaxCalculationBatchTest {
 @IsTest
    static void testBatchExecution() {
         insert new GARP_StripeSettings__c(
            Name = 'T_tax_direct',
            Is_Active__c = true,
            Use_Stripe__c = true,
            Server_Side_API_Key__c = 'sk_test',
            Client_Side_API_Key__c = 'pk_test'
        );
         String pcode = ('TXF' + String.valueOf(Math.abs(Crypto.getRandomInteger()))).left(20);
        Product2 prd = new Product2(
            Name = 'Stripe Tax Full Test',
            ProductCode = pcode,
            IsActive = true,
            Stripe_Tax_Code__c = 'txr_full_test'
        );
        insert prd;
        Id pbId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = prd.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Account acc = new Account(Name = 'TaxFullAcct');
        insert acc;
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Tax Full Opp',
            StageName = 'New Lead',
            CloseDate = System.today() + 10,
            Amount = 100,
            Billing_Email__c = 'taxfull@test.com',
            Display_Invoice_Number__c = 'TAXFULL1',
            Program__c = 'Print',
            company__c = 'Payment',
            Eligible_for_Membership_Extension__c = false,
            Pricebook2Id = pbId,
            Billing_Address__c = '100 Main Street',
            Billing_City__c = 'New York',
            Billing_State_Text__c = 'NY',
            Billing_Zip_Postal__c = '10001',
            Billing_Country__c = 'United States',
			StripeTaxMethod__c = 'Batch Tax Calculate'
        );
        insert opp;
        insert new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100);

        // If StripeTaxCalUtil makes HTTP callouts, register mock
        Test.setMock(HttpCalloutMock.class, new StripeTaxMock());

        Test.startTest();
        Database.executeBatch(new StripeTaxCalculationBatch(), 1);
        Test.stopTest();

        // Optional assertion: confirm record still exists / was processed
        Opportunity result = [
            SELECT Id, StripeTaxMethod__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals(
            null,
            result.StripeTaxMethod__c
        );
    }

    private class StripeTaxMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"id":"evt_3","object":"event","api_version":"2020-08-27","created":1747662347,"type":"payment_intent.succeeded","data":{"object":{"id":"pi_3","object":"payment_intent","amount":1732713,"metadata":{"orderid":"123456"},"customer":"cus_1","description":null,"payment_method":"pm_1","charges":{"data":[{"id":"ch_1","amount":1732713,"paid":true,"refunded":false,"status":"succeeded","payment_method_details":{"type":"card","card":{"brand":"visa","last4":"4242"}}}]}}}}');
            return res;
        }
    }
}