@isTest
public class StripeRefundControllerTest {
    // Mock class for successful refund
    private class StripeRefundSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"id":"re_12345","object":"refund","amount":1500,"status":"succeeded"}');
            return res;
        }
    }
    
    // Mock class for error refund
    private class StripeRefundErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            res.setBody('{"error":{"type":"invalid_request_error","message":"Charge already refunded"}}');
            return res;
        }
    }
    
    @testSetup
    static void setupData() {
         

        // Insert Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = System.today(),
            Amount = 1000
        );
        insert opp;
		ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opp.id);
        insert order; 
        // Insert Transaction record
        ChargentOrders__Transaction__c txn = new ChargentOrders__Transaction__c(
            ChargentOrders__Amount__c = 100,
            ChargentOrders__Payment_Method__c = 'Card',
            ChargentOrders__Tokenization__c = 'tok_123',
            ChargentOrders__Order__c = order.Id,
            ChargentOrders__Gateway_ID__c = 'ch_123',
            Opportunity__c = opp.Id
        );
        insert txn;

        // Insert Approved Product Refund
        Product_Refunds__c pr = new Product_Refunds__c(
            Opportunity__c = opp.Id,
            Refund_amount__c = 50,
            Status__c = 'Approved'
        );
        insert pr;
    }
    
     @isTest
    static void testGetTransactionData() {
        ChargentOrders__Transaction__c txn = [SELECT Id FROM ChargentOrders__Transaction__c LIMIT 1];
        Test.startTest();
        StripeRefundController result = StripeRefundController.getTransactionData(txn.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.isApprovedPayment, 'Approved refund should be detected');
        System.assert(result.approvedAmount > 0, 'Approved amount should be set');
    }
    
     @isTest
    static void testProcessRefundSuccess() {
        ChargentOrders__Transaction__c txn = [SELECT Id, Opportunity__c, ChargentOrders__Gateway_ID__c, ChargentOrders__Payment_Method__c, ChargentOrders__Order__c, ChargentOrders__Tokenization__c FROM ChargentOrders__Transaction__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new StripeRefundSuccessMock());
        Test.startTest();
        Map<String, String> result = StripeRefundController.processRefund(txn.Id, 15, txn);
        Test.stopTest();

        System.assertEquals('success', result.get('status'));
        System.assertEquals('re_12345', result.get('refundId'));
        System.assertEquals('Refund processed successfully.', result.get('message'));

        // Verify new Transaction record created
        List<ChargentOrders__Transaction__c> txns = [
            SELECT Id, ChargentOrders__Type__c, ChargentOrders__Amount__c 
            FROM ChargentOrders__Transaction__c 
            WHERE ChargentOrders__Type__c = 'Refund'
        ];
        System.assert(!txns.isEmpty(), 'Refund transaction should be created');
    }

    @isTest
    static void testProcessRefundError() {
        ChargentOrders__Transaction__c txn = [SELECT Id, Opportunity__c, ChargentOrders__Gateway_ID__c, ChargentOrders__Payment_Method__c, ChargentOrders__Order__c, ChargentOrders__Tokenization__c FROM ChargentOrders__Transaction__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new StripeRefundErrorMock());
        Test.startTest();
        Map<String, String> result = StripeRefundController.processRefund(txn.Id, 15, txn);
        Test.stopTest();

        System.assertEquals('error', result.get('status'));
        System.assert(result.get('message').contains('Charge already refunded'), 'Error message should be returned');
    }

}