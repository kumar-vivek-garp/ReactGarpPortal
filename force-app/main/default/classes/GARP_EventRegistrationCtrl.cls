/**
 * LWC bridge controller for the new garpEventRegistration component suite.
 *
 * The legacy AngularJS event-registration form (Visualforce page sfdcApp,
 * route #!/registration/event/<id>) drives the GARP_BC_Registration /
 * GARP_BC_Events / GARP_BC_Shipping business logic through @RemoteAction
 * methods (GARP_MS_Registration, GARP_MS_Events, GARP_MS_Shipping).
 *
 * LWC cannot call @RemoteAction, and the GARP_BC_* request/response classes
 * are plain-public (no @AuraEnabled), so they cannot cross the LWC Apex bridge
 * directly. Rather than annotate ~15 deeply nested classes across several
 * shared production files, this controller bridges with JSON:
 *   - inputs arrive as JSON strings and are deserialized into the existing
 *     GARP_BC_* request types,
 *   - the existing business logic runs unchanged,
 *   - results are serialized back to JSON for the LWC to parse.
 *
 * This keeps all new code isolated and reuses the exact same flow the Angular
 * form uses, so behaviour stays faithful.
 */
public without sharing class GARP_EventRegistrationCtrl {

    /**
     * Loads the full event-registration screen payload (event info, products,
     * pricing structure, eligibility, membership info, screen reference data,
     * captcha + stripe config). Mirrors GARP_MS_Events.getEventRegistrationInfo.
     */
    @AuraEnabled
    public static String getEventRegistrationInfo(String eventId, String regCode) {
        try {
            GARP_BC_Registration.getRegistrationInfo info =
                GARP_BC_Events.getEventRegistrationInfo(eventId, regCode);
            return JSON.serialize(info, true);
        } catch (Exception e) {
            throw audErr('getEventRegistrationInfo', e);
        }
    }

    /**
     * Checks whether the supplied email already exists as a customer and
     * establishes the session/form-data record. Mirrors verifyExistingCustomer.
     */
    @AuraEnabled
    public static String verifyExistingCustomer(String requestJson) {
        try {
            GARP_BC_Registration.verifyExistingCustomerInfo req =
                (GARP_BC_Registration.verifyExistingCustomerInfo) JSON.deserialize(
                    requestJson, GARP_BC_Registration.verifyExistingCustomerInfo.class);
            return JSON.serialize(GARP_BC_Registration.verifyExistingCustomer(req), true);
        } catch (Exception e) {
            throw audErr('verifyExistingCustomer', e);
        }
    }

    /**
     * Recalculates fees after a user selection change (country, membership,
     * promo code, bundle, address). Mirrors getRegistrationFees.
     */
    @AuraEnabled
    public static String getRegistrationFees(String requestJson) {
        try {
            GARP_BC_Registration.getRegistrationFeesInfo req =
                (GARP_BC_Registration.getRegistrationFeesInfo) JSON.deserialize(
                    requestJson, GARP_BC_Registration.getRegistrationFeesInfo.class);
            return JSON.serialize(GARP_BC_Registration.getRegistrationFees(req), true);
        } catch (Exception e) {
            throw audErr('getRegistrationFees', e);
        }
    }

    /**
     * Validates a billing/shipping address and returns shipping options.
     * Mirrors GARP_MS_Shipping.verifyAddress.
     */
    @AuraEnabled
    public static String verifyAddress(String requestJson) {
        try {
            GARP_BC_Shipping.verifyAddressInfo req =
                (GARP_BC_Shipping.verifyAddressInfo) JSON.deserialize(
                    requestJson, GARP_BC_Shipping.verifyAddressInfo.class);
            return JSON.serialize(GARP_BC_Shipping.verifyAddress(req), true);
        } catch (Exception e) {
            throw audErr('verifyAddress', e);
        }
    }

    /**
     * Creates the order/registration records (no payment processed yet).
     * Mirrors setRegistration.
     */
    @AuraEnabled
    public static String setRegistration(String requestJson) {
        try {
            GARP_BC_Registration.setRegistrationInfo req =
                (GARP_BC_Registration.setRegistrationInfo) JSON.deserialize(
                    requestJson, GARP_BC_Registration.setRegistrationInfo.class);
            return JSON.serialize(GARP_BC_Registration.setRegistration(req), true);
        } catch (Exception e) {
            throw audErr('setRegistration', e);
        }
    }

    /**
     * Processes payment / finalizes the order. For Stripe this saves session
     * state and returns early so the LWC can drive Stripe Elements client-side.
     * Mirrors payOrder.
     */
    @AuraEnabled
    public static String payOrder(String requestJson) {
        try {
            GARP_BC_Registration.createOrderInfo req =
                (GARP_BC_Registration.createOrderInfo) JSON.deserialize(
                    requestJson, GARP_BC_Registration.createOrderInfo.class);
            return JSON.serialize(GARP_BC_Registration.payOrder(req), true);
        } catch (Exception e) {
            throw audErr('payOrder', e);
        }
    }

    /**
     * Polls payment/order completion status (used after the Stripe popup).
     * Mirrors checkRegistrationPaymentStatus.
     */
    @AuraEnabled
    public static String checkRegistrationPaymentStatus(String orderId) {
        try {
            return JSON.serialize(
                GARP_BC_Registration.checkRegistrationPaymentStatus(orderId), true);
        } catch (Exception e) {
            throw audErr('checkRegistrationPaymentStatus', e);
        }
    }

    /**
     * Restores saved session/form state by token (used by the Stripe return
     * leg). Mirrors getSessionState.
     */
    @AuraEnabled
    public static String getSessionState(String sessionToken) {
        try {
            return GARP_BC_Registration.getSessionState(sessionToken);
        } catch (Exception e) {
            throw audErr('getSessionState', e);
        }
    }

    /**
     * Cancels an order after a failed/abandoned payment. Mirrors
     * rollbackSetRegistration (reason fixed to 'Cancel Registration' to match
     * GARP_MS_Registration.rollbackSetRegistration).
     */
    @AuraEnabled
    public static Boolean rollbackSetRegistration(String leadId, String accountId, String email, String orderId) {
        try {
            return GARP_BC_Registration.rollbackSetRegistration(
                leadId, accountId, email, orderId, 'Cancel Registration');
        } catch (Exception e) {
            throw audErr('rollbackSetRegistration', e);
        }
    }

    private static AuraHandledException audErr(String method, Exception e) {
        GARP_Common.debugLog('GARP_EventRegistrationCtrl', method, 'Exception', e.getMessage());
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        return ahe;
    }
}