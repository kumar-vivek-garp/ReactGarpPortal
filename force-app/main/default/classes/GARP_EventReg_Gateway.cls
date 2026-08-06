/**
 * Thin seam between the controller and the registration back-end.
 *
 * FULLY STANDALONE: every method is served by the GARP_EventReg_* module
 * (RegService / LoadService / Stripe) — no GARP_BC_* / GARP_StripeClass /
 * GARP_StripeCheckoutCtrl dependency remains.
 *
 * Methods return already-serialized JSON matching the legacy contract so the
 * controller and LWC stay unchanged.
 */
public without sharing class GARP_EventReg_Gateway {

    private static GARP_EventReg_RegService reg() { return new GARP_EventReg_RegService(); }
    private static GARP_EventReg_LoadService loader() { return new GARP_EventReg_LoadService(); }

    /* ===================== Load payload (standalone) ===================== */

    /** Full event-registration screen payload — standalone (GARP_EventReg_LoadService). */
    public String getEventRegistrationInfo(String eventId, String regCode, Boolean skipInstitutions) {
        return loader().getEventRegistrationInfo(eventId, regCode, skipInstitutions);
    }

    /* ===================== Write path (standalone) ===================== */

    public String verifyExistingCustomer(String requestJson) {
        return reg().verifyExistingCustomer(requestJson);
    }

    public String getRegistrationFees(String requestJson) {
        return reg().getRegistrationFees(requestJson);
    }

    public String setRegistration(String requestJson) {
        return reg().setRegistration(requestJson);
    }

    public String payOrder(String requestJson) {
        return reg().payOrder(requestJson);
    }

    public String checkRegistrationPaymentStatus(String orderId) {
        return reg().checkRegistrationPaymentStatus(orderId);
    }

    /** Cancels a pending (unpaid) order when the user abandons checkout. */
    public Boolean rollbackSetRegistration(String leadId, String accountId, String email, String orderId) {
        return reg().rollbackSetRegistration(leadId, accountId, email, orderId);
    }

    /** Standalone Stripe hosted-checkout session (replaces GARP_StripeCheckoutCtrl). */
    public String getCheckoutSession(String requestJson) {
        return reg().getCheckoutSession(requestJson);
    }

    /** Standalone Stripe EMBEDDED-checkout session (on-page Embedded Checkout). */
    public String getEmbeddedCheckoutSession(String requestJson) {
        return reg().getEmbeddedCheckoutSession(requestJson);
    }

    /* ===================== Config (standalone) ===================== */

    /** Stripe Tax kill-switch for the address validator — now via GARP_EventReg_Stripe. */
    public Boolean isStripeTaxEnabled() {
        try {
            return GARP_EventReg_Stripe.isTaxEnabled();
        } catch (Exception e) {
            return false;
        }
    }
}