/**
 * Single LWC controller for the garpEventRegistration component suite.
 *
 * Every event-registration endpoint the LWC calls lives here (consolidated in
 * one class), and each one is a thin JSON bridge over the SAME shared business
 * logic the legacy AngularJS form used (GARP_BC_Events / GARP_BC_Registration /
 * GARP_BC_Shipping). Inputs arrive as JSON, the existing logic runs unchanged,
 * results are serialized back — so behaviour is byte-for-byte the legacy flow
 * (membership, pricing, addresses, products, screen data all included).
 *
 * Note: an earlier version reimplemented the load payload standalone; that was
 * reverted to a delegation because the reimplementation kept diverging from the
 * legacy field-set (companies, Country__c, membership, …). Delegating guarantees
 * parity.
 */
public without sharing class GARP_EventRegistrationCtrlV2 {

    /** Full event-registration screen payload (event, products, pricing,
     *  eligibility, membership, screen data, captcha, stripe). */
    @AuraEnabled
    public static String getEventRegistrationInfo(String eventId, String regCode) {
        try {
            return JSON.serialize(GARP_BC_Events.getEventRegistrationInfo(eventId, regCode), true);
        } catch (Exception e) {
            throw audErr(e);
        }
    }

    /** Checks whether the supplied email already exists as a customer. */
    @AuraEnabled
    public static String verifyExistingCustomer(String requestJson) {
        try {
            GARP_BC_Registration.verifyExistingCustomerInfo req =
                (GARP_BC_Registration.verifyExistingCustomerInfo) JSON.deserialize(
                    requestJson, GARP_BC_Registration.verifyExistingCustomerInfo.class);
            return JSON.serialize(GARP_BC_Registration.verifyExistingCustomer(req), true);
        } catch (Exception e) {
            throw audErr(e);
        }
    }

    /** Recalculates fees after a user selection change. */
    @AuraEnabled
    public static String getRegistrationFees(String requestJson) {
        try {
            GARP_BC_Registration.getRegistrationFeesInfo req =
                (GARP_BC_Registration.getRegistrationFeesInfo) JSON.deserialize(
                    requestJson, GARP_BC_Registration.getRegistrationFeesInfo.class);
            return JSON.serialize(GARP_BC_Registration.getRegistrationFees(req), true);
        } catch (Exception e) {
            throw audErr(e);
        }
    }

    /** Validates a billing/shipping address and returns shipping options. */
    @AuraEnabled
    public static String verifyAddress(String requestJson) {
        try {
            GARP_BC_Shipping.verifyAddressInfo req =
                (GARP_BC_Shipping.verifyAddressInfo) JSON.deserialize(
                    requestJson, GARP_BC_Shipping.verifyAddressInfo.class);
            return JSON.serialize(GARP_BC_Shipping.verifyAddress(req), true);
        } catch (Exception e) {
            throw audErr(e);
        }
    }

    /** Creates the order/registration records (no payment processed yet). */
    @AuraEnabled
    public static String setRegistration(String requestJson) {
        try {
            GARP_BC_Registration.setRegistrationInfo req =
                (GARP_BC_Registration.setRegistrationInfo) JSON.deserialize(
                    requestJson, GARP_BC_Registration.setRegistrationInfo.class);
            return JSON.serialize(GARP_BC_Registration.setRegistration(req), true);
        } catch (Exception e) {
            throw audErr(e);
        }
    }

    /** Processes payment / finalizes the order (Stripe path saves session state). */
    @AuraEnabled
    public static String payOrder(String requestJson) {
        try {
            GARP_BC_Registration.createOrderInfo req =
                (GARP_BC_Registration.createOrderInfo) JSON.deserialize(
                    requestJson, GARP_BC_Registration.createOrderInfo.class);
            return JSON.serialize(GARP_BC_Registration.payOrder(req), true);
        } catch (Exception e) {
            throw audErr(e);
        }
    }

    /** Polls payment/order completion status (used after the Stripe leg). */
    @AuraEnabled
    public static String checkRegistrationPaymentStatus(String orderId) {
        try {
            return JSON.serialize(
                GARP_BC_Registration.checkRegistrationPaymentStatus(orderId), true);
        } catch (Exception e) {
            throw audErr(e);
        }
    }

    /**
     * Cancels a pending (unpaid) order when the user returns/abandons checkout
     * (mirrors the legacy redirect_status=cancel rollback). Reason fixed to
     * 'Cancel Registration' to match GARP_MS_Registration.rollbackSetRegistration.
     */
    @AuraEnabled
    public static Boolean rollbackSetRegistration(String leadId, String accountId, String email, String orderId) {
        try {
            return GARP_BC_Registration.rollbackSetRegistration(leadId, accountId, email, orderId, 'Cancel Registration');
        } catch (Exception e) {
            throw audErr(e);
        }
    }

    /**
     * Event details for the post-payment confirmation page (garpRegistrationSuccess):
     * title, date/time, location, delivery mode, on-demand + add-to-calendar data.
     * Returns the same eventRegistrationInfo the legacy completed form rendered.
     */
    @AuraEnabled(cacheable=true)
    public static String getEventInfoForCompletion(String eventId) {
        try {
            return JSON.serialize(GARP_BC_Events.getEventInfo(eventId, 'event'), true);
        } catch (Exception e) {
            throw audErr(e);
        }
    }

    private static AuraHandledException audErr(Exception e) {
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        return ahe;
    }
}