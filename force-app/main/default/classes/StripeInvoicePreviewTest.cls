@isTest
public class StripeInvoicePreviewTest {
    private static final String PRODUCT_CODE_JSON =
        '[' +
            '{"code":"AD","name":"Andorra","prcode":""},' +
            '{"code":"US","name":"United States","prcode":"PR_US_001"},' +
            '{"code":"ZW","name":"Zimbabwe","prcode":"PR_ZW_009"}' +
        ']';

    /** Mock returning a successful invoice-preview response with tax details and an address object. */
    private class SuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Confirm the request was built as expected.
            System.assertEquals('POST', req.getMethod(), 'Should POST to Stripe');
            System.assert(req.getHeader('Authorization') != null, 'Authorization header expected');
            System.assert(req.getBody().contains('automatic_tax[enabled]=true'), 'Body should enable automatic tax');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{' +
                    '"amount_due":12345,' +
                    '"customer_address":{"city":"Jersey City","country":"US","line1":"111 Town Square Place","line2":null,"postal_code":"07310","state":"NJ"},' +
                    '"total_tax_amounts":[' +
                        '{"amount":825,"taxable_amount":11520,"tax_rate":"txr_123"}' +
                    ']' +
                '}'
            );
            return res;
        }
    }

    /** Mock returning a non-2xx error status. */
    private class ErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"error":{"message":"Bad request"}}');
            return res;
        }
    }

    /** Mock returning a body that cannot be parsed into a Map (forces the catch block). */
    private class BadJsonMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('not-valid-json');
            return res;
        }
    }

    private static StripeInvoicePreview.stRequest buildRequest(String oppId) {
        StripeInvoicePreview.stRequest st = new StripeInvoicePreview.stRequest();
        st.customerId = 'cus_test123';
        st.priceId = 'price_test123';
        st.quantity = 2;
        st.oppId = oppId;
        return st;
    }

    private static StripeInvoicePreview.StripeConfig buildConfig() {
        StripeInvoicePreview.StripeConfig cfg = new StripeInvoicePreview.StripeConfig();
        cfg.apikey = 'sk_test_key';
        cfg.endpoint = 'https://api.stripe.com/v1/invoices/create_preview';
        cfg.productCodeJson = PRODUCT_CODE_JSON;
        return cfg;
    }

    @isTest
    static void testPreviewSubTax_success() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        StripeInvoicePreview.stResult result = StripeInvoicePreview.previewSubTax(buildRequest('006000000000001'), buildConfig());
        Test.stopTest();

        System.assertEquals(null, result.errorMesage, 'No error expected on success');
        System.assertEquals(123.45, result.amountDue, 'amount_due should be divided by 100');
        System.assertEquals(8.25, result.taxRate, 'tax amount/100 maps to taxRate');
        System.assertEquals(115.20, result.taxAmount, 'taxable_amount/100 maps to taxAmount');
        System.assertEquals('txr_123', result.taxRateId, 'tax_rate id should be captured');
        System.assertEquals(null, result.texPersent, 'texPersent is explicitly nulled in tax loop');
        // customer_address is an object; country US should resolve to the configured product code.
        System.assertEquals('PR_US_001', result.productCode, 'US country should map to its configured product code');
    }

    @isTest
    static void testPreviewSubTax_errorStatus() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Test.startTest();
        StripeInvoicePreview.stResult result = StripeInvoicePreview.previewSubTax(buildRequest('006000000000002'), buildConfig());
        Test.stopTest();

        System.assertNotEquals(null, result.errorMesage, 'Error message expected on non-2xx');
        System.assert(result.errorMesage.contains('400'), 'Error message should include the status code');
    }

    @isTest
    static void testPreviewSubTax_badJsonHitsCatch() {
        Test.setMock(HttpCalloutMock.class, new BadJsonMock());

        Test.startTest();
        StripeInvoicePreview.stResult result = StripeInvoicePreview.previewSubTax(buildRequest('006000000000003'), buildConfig());
        Test.stopTest();

        System.assertNotEquals(null, result.errorMesage, 'Unparseable body should set an error message');
        System.assert(result.errorMesage.startsWith('Stripe Error:'), 'Catch block should prefix the error message');
    }

    @isTest
    static void testPreviewSubTax_singleOverloadUsesConfig() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        StripeInvoicePreview.stResult result = StripeInvoicePreview.previewSubTax(buildRequest('006000000000004'));
        Test.stopTest();

        System.assertNotEquals(null, result, 'Single-request overload should return a result');
        System.assertEquals(123.45, result.amountDue, 'Should parse amount_due via config overload');
    }

    @isTest
    static void testResolveProductCode() {
        // Exact match (case-insensitive).
        System.assertEquals('PR_US_001', StripeInvoicePreview.resolveProductCode(PRODUCT_CODE_JSON, 'us'), 'Should match US case-insensitively');
        System.assertEquals('PR_ZW_009', StripeInvoicePreview.resolveProductCode(PRODUCT_CODE_JSON, 'ZW'), 'Should match ZW');
        // No matching country.
        System.assertEquals(null, StripeInvoicePreview.resolveProductCode(PRODUCT_CODE_JSON, 'IN'), 'Unmatched country returns null');
        // Blank inputs.
        System.assertEquals(null, StripeInvoicePreview.resolveProductCode(null, 'US'), 'Null mapping returns null');
        System.assertEquals(null, StripeInvoicePreview.resolveProductCode(PRODUCT_CODE_JSON, null), 'Null country returns null');
        // Malformed JSON is swallowed.
        System.assertEquals(null, StripeInvoicePreview.resolveProductCode('not-json', 'US'), 'Malformed mapping returns null');
    }

    @isTest
    static void testGetConfig() {
        Test.startTest();
        StripeInvoicePreview.StripeConfig cfg = StripeInvoicePreview.getConfig();
        Test.stopTest();

        // Custom metadata may or may not exist in the org; just ensure no exception and an object is returned.
        System.assertNotEquals(null, cfg, 'getConfig should always return a config object');
    }
}