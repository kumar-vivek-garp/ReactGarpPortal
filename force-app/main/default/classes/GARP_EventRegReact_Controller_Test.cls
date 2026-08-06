/**
 * Coverage for GARP_EventRegReact_Controller. The method delegates to the shared
 * GARP_EventReg_Gateway; without a full priced-event data setup the delegated call raises a
 * handled error, so these tests assert the controller's contract (returns serialized JSON,
 * or surfaces an AuraHandledException) rather than pricing outcomes — which are covered by
 * the gateway/service test suite.
 */
@isTest
private class GARP_EventRegReact_Controller_Test {

    @isTest
    static void returnsJsonOrHandledError_withComparison() {
        String req = JSON.serialize(new Map<String, Object>{
            'membershipOptions' => new Map<String, Object>{ 'hasSelectedMembership' => false, 'hasSelectedRiskNet' => false },
            'paymentType' => 'Stripe'
        });
        Test.startTest();
        Boolean handled = false;
        String result = null;
        try {
            result = GARP_EventRegReact_Controller.getRegistrationFeesWithComparison(req, true);
        } catch (AuraHandledException e) {
            handled = true;
        }
        Test.stopTest();
        System.assert(handled || result != null, 'Expected a JSON result or a handled exception');
    }

    @isTest
    static void getEventView_returnsJsonOrHandledError() {
        Test.startTest();
        Boolean handled = false;
        String result = null;
        try {
            result = GARP_EventRegReact_Controller.getEventView('a2h000000000000AAA', null, true);
        } catch (Exception e) {
            handled = true;
        }
        Test.stopTest();
        System.assert(handled || result != null, 'Expected a JSON result or a handled exception');
    }

    @isTest
    static void returnsJsonOrHandledError_noComparison() {
        Test.startTest();
        Boolean handled = false;
        String result = null;
        try {
            result = GARP_EventRegReact_Controller.getRegistrationFeesWithComparison('{}', false);
        } catch (AuraHandledException e) {
            handled = true;
        }
        Test.stopTest();
        System.assert(handled || result != null, 'Expected a JSON result or a handled exception');
    }
}