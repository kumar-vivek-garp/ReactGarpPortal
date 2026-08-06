/**
 * Optimized LWC controller for the event-registration component suite — a clean,
 * layered alternative to GARP_EventRegistrationCtrlV2 (which is left untouched).
 *
 * Responsibilities are split so each class does one job:
 *   - Controller (this) : the @AuraEnabled surface + uniform error handling.
 *   - GARP_EventReg_Service  : reimplemented safe logic (confirmation, address, RSVP).
 *   - GARP_EventReg_Selector : all SOQL (one query per object, static-cached).
 *   - GARP_EventReg_Gateway  : the ONLY dependency on the legacy GARP_BC_* classes,
 *                              funnelling the high-risk load/fees/order/payment paths.
 *
 * Method signatures mirror the legacy controller (JSON in/out) so the LWC can be
 * migrated as a near drop-in. Delegated methods keep the legacy JSON contract;
 * reimplemented methods (verifyAddress, getEventInfoForCompletion,
 * setRSVPInviteOnlyDecline) return typed results serialized to JSON.
 */
public without sharing class GARP_EventReg_Controller {

    private static GARP_EventReg_Gateway gateway() { return new GARP_EventReg_Gateway(); }
    private static GARP_EventReg_Service service() { return new GARP_EventReg_Service(); }

    /* ============ Delegated (parity-critical) — GARP_EventReg_Gateway ============ */

    /** Full event-registration screen payload (event, products, pricing, membership…). */
    @AuraEnabled
    public static String getEventRegistrationInfo(String eventId, String regCode, Boolean skipInstitutions) {
        try {
            return gateway().getEventRegistrationInfo(eventId, regCode, skipInstitutions);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Checks whether the supplied email already exists as a customer. */
    @AuraEnabled
    public static String verifyExistingCustomer(String requestJson) {
        try {
            return gateway().verifyExistingCustomer(requestJson);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Recalculates fees after a user selection change. */
    @AuraEnabled
    public static String getRegistrationFees(String requestJson) {
        try {
            return gateway().getRegistrationFees(requestJson);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Creates the order/registration records (no payment processed yet). */
    @AuraEnabled
    public static String setRegistration(String requestJson) {
        try {
            return gateway().setRegistration(requestJson);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Processes payment / finalizes the order (Stripe path saves session state). */
    @AuraEnabled
    public static String payOrder(String requestJson) {
        try {
            return gateway().payOrder(requestJson);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Polls payment/order completion status (used after the Stripe leg). */
    @AuraEnabled
    public static String checkRegistrationPaymentStatus(String orderId) {
        try {
            return gateway().checkRegistrationPaymentStatus(orderId);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Cancels a pending (unpaid) order when the user abandons checkout. */
    @AuraEnabled
    public static Boolean rollbackSetRegistration(String leadId, String accountId, String email, String orderId) {
        try {
            return gateway().rollbackSetRegistration(leadId, accountId, email, orderId);
        } catch (Exception e) { throw audErr(e); }
    }

    /* ============ Reimplemented (standalone) — GARP_EventReg_Service ============ */

    /**
     * Validates a billing/shipping address and returns per-country payment/shipping
     * eligibility. `requestJson` is a GARP_EventReg_Dto.VerifyAddressRequest
     * (compatible field names with the legacy verifyAddressInfo).
     */
    @AuraEnabled
    public static String verifyAddress(String requestJson) {
        try {
            GARP_EventReg_Dto.VerifyAddressRequest req =
                (GARP_EventReg_Dto.VerifyAddressRequest) JSON.deserialize(
                    requestJson, GARP_EventReg_Dto.VerifyAddressRequest.class);
            return JSON.serialize(service().verifyAddress(req), true);
        } catch (Exception e) { throw audErr(e); }
    }

    /**
     * Event detail for the post-payment confirmation page. `eventType` defaults to
     * 'event'; pass 'chaptermeeting' or 'webcast' for those flows.
     */
    @AuraEnabled(cacheable=true)
    public static String getEventInfoForCompletion(String eventId, String eventType) {
        try {
            return JSON.serialize(service().getEventCompletionInfo(eventId, eventType), true);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Records an invite-only RSVP decline. */
    @AuraEnabled
    public static String setRSVPInviteOnlyDecline(String eventId, String userEmail) {
        try {
            return JSON.serialize(service().setRSVPInviteOnlyDecline(eventId, userEmail), true);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Standalone Stripe hosted-checkout session (replaces GARP_StripeCheckoutCtrl.getCheckoutSession). */
    @AuraEnabled
    public static String getCheckoutSession(String requestJson) {
        try {
            return gateway().getCheckoutSession(requestJson);
        } catch (Exception e) { throw audErr(e); }
    }

    /**
     * Standalone Stripe EMBEDDED-checkout session — returns a client_secret +
     * publishable key so the LWC can mount Stripe's on-page Embedded Checkout
     * (the embedded equivalent of the legacy VF stripe_checkout screen).
     */
    @AuraEnabled
    public static String getEmbeddedCheckoutSession(String requestJson) {
        try {
            return gateway().getEmbeddedCheckoutSession(requestJson);
        } catch (Exception e) { throw audErr(e); }
    }

    /* ===================== error handling ===================== */

    private static AuraHandledException audErr(Exception e) {
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        return ahe;
    }
}