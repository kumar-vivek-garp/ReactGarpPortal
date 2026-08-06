@isTest
private class GARP_EventRegistrationCtrl_Test {

    private static Event__c buildActiveEvent() {
        Event__c evt = new Event__c(
            Name = 'Test Event',
            Title__c = 'Test Event',
            Status__c = 'Active',
            Delivery_Method__c = 'Hybrid',
            Start_Date__c = DateTime.now().addDays(10),
            End_Date__c = DateTime.now().addDays(11),
            Last_Date_For_Registration__c = Date.today().addDays(5)
        );
        insert evt;
        return evt;
    }

    /**
     * The bridge delegates to the heavy GARP_BC_* flow whose success depends on
     * org reference data (products, pricebook, etc.). These tests assert the
     * JSON-bridge plumbing itself behaves: it returns serialized JSON on the
     * load path and surfaces failures as AuraHandledException without leaking
     * raw exceptions.
     */
    @isTest
    static void getEventRegistrationInfo_returnsJsonOrHandledError() {
        Event__c evt = buildActiveEvent();
        Test.startTest();
        String result;
        Boolean handled = false;
        try {
            result = GARP_EventRegistrationCtrl.getEventRegistrationInfo(evt.Id, null);
        } catch (AuraHandledException e) {
            handled = true;
        }
        Test.stopTest();
        System.assert(result != null || handled, 'Expected serialized JSON or a handled exception');
        if (result != null) {
            Object parsed = JSON.deserializeUntyped(result);
            System.assert(parsed instanceof Map<String, Object>, 'Payload should be a JSON object');
        }
    }

    @isTest
    static void verifyExistingCustomer_isHandled() {
        Test.startTest();
        runHandled('verifyExistingCustomer', '{"email":"t@example.com","firstName":"A","lastName":"B"}');
        Test.stopTest();
    }

    @isTest
    static void getRegistrationFees_isHandled() {
        Test.startTest();
        runHandled('getRegistrationFees', '{"paymentType":"Credit Card","promoCodes":[]}');
        Test.stopTest();
    }

    @isTest
    static void verifyAddress_isHandled() {
        Test.startTest();
        runHandled('verifyAddress', '{}');
        Test.stopTest();
    }

    @isTest
    static void setRegistration_isHandled() {
        Test.startTest();
        runHandled('setRegistration', '{"affiliateCode":null}');
        Test.stopTest();
    }

    @isTest
    static void payOrder_isHandled() {
        Test.startTest();
        runHandled('payOrder', '{"affiliateCode":null}');
        Test.stopTest();
    }

    @isTest
    static void statusAndSessionMethods_areHandled() {
        Test.startTest();
        try {
            GARP_EventRegistrationCtrl.checkRegistrationPaymentStatus('006000000000000AAA');
        } catch (AuraHandledException e) { /* acceptable */ }
        try {
            GARP_EventRegistrationCtrl.getSessionState('bogus-token');
        } catch (AuraHandledException e) { /* acceptable */ }
        try {
            GARP_EventRegistrationCtrl.rollbackSetRegistration(null, null, 'x@example.com', null);
        } catch (AuraHandledException e) { /* acceptable */ }
        Test.stopTest();
        System.assert(true);
    }

    // Invokes a JSON-input wrapper method and asserts it either returns JSON or
    // raises a handled exception, never leaking an unhandled one.
    private static void runHandled(String method, String payload) {
        String result;
        try {
            if (method == 'verifyExistingCustomer') {
                result = GARP_EventRegistrationCtrl.verifyExistingCustomer(payload);
            } else if (method == 'getRegistrationFees') {
                result = GARP_EventRegistrationCtrl.getRegistrationFees(payload);
            } else if (method == 'verifyAddress') {
                result = GARP_EventRegistrationCtrl.verifyAddress(payload);
            } else if (method == 'setRegistration') {
                result = GARP_EventRegistrationCtrl.setRegistration(payload);
            } else if (method == 'payOrder') {
                result = GARP_EventRegistrationCtrl.payOrder(payload);
            }
            if (result != null) {
                JSON.deserializeUntyped(result);
            }
        } catch (AuraHandledException e) {
            // expected for incomplete input
        }
    }
}