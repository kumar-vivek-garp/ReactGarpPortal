/**
 * Controller for garpEventRegModernFullV2.
 *
 * Design: ONE aggregating load method that returns the whole screen (event +
 * initial fees) in a single call — that was the real pain point ("too many
 * onload calls"). Everything else is a small, direct write method that simply
 * hands its request to the proven registration services and returns the result.
 * No dispatcher switch, no request-body re-assembly, no duplicated DTOs — each
 * method does one obvious thing.
 *
 * The heavy domain logic (pricing, tax, order creation, Stripe, address rules)
 * stays in GARP_EventReg_LoadService / RegService / Service, which are not
 * modified. This controller is deliberately thin.
 */
public without sharing class GARP_EventRegV2_Controller {

    private static GARP_EventReg_RegService reg() { return new GARP_EventReg_RegService(); }
    private static GARP_EventReg_Service svc() { return new GARP_EventReg_Service(); }

    /* ===================== Load (one aggregated call) ===================== */

    /**
     * The whole registration screen in one shot: the full event/products/
     * membership/locations payload PLUS the initial fee calculation for the
     * freshly-loaded (empty) form. A fee-calc hiccup never fails the load — fees
     * come back null and the client recalculates on the first change.
     */
    @AuraEnabled
    public static String getRegistrationScreen(String eventId, String regCode) {
        try {
            GARP_EventRegV2_Wrapper.Screen screen = new GARP_EventRegV2_Wrapper.Screen();
            GARP_EventRegV2_LoadService.RegLoad regData = new GARP_EventRegV2_LoadService().load(eventId, regCode);
            screen.registration = regData;

            if (regData.status != 'Error' && regData.status != 'Failed') {
                try {
                    screen.fees = JSON.deserializeUntyped(reg().getRegistrationFees(initialFeesBody(regData, regCode)));
                } catch (Exception ignored) {
                    screen.fees = null; // client recalculates on first change
                }
            }
            return JSON.serialize(screen, true);
        } catch (Exception e) { throw audErr(e); }
    }

    /* ===================== Write actions (thin pass-through) ===================== */

    /** Recalculate fees after a user selection change. */
    @AuraEnabled
    public static String calcFees(String requestJson) {
        try { return reg().getRegistrationFees(requestJson); } catch (Exception e) { throw audErr(e); }
    }

    /** Check whether the supplied email already belongs to a customer. */
    @AuraEnabled
    public static String verifyCustomer(String requestJson) {
        try { return reg().verifyExistingCustomer(requestJson); } catch (Exception e) { throw audErr(e); }
    }

    /** Validate billing/shipping address + per-country eligibility. */
    @AuraEnabled
    public static String verifyAddress(String requestJson) {
        try {
            GARP_EventReg_Dto.VerifyAddressRequest req = (GARP_EventReg_Dto.VerifyAddressRequest)
                JSON.deserialize(requestJson, GARP_EventReg_Dto.VerifyAddressRequest.class);
            return JSON.serialize(svc().verifyAddress(req), true);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Create the order/registration records (payment handled separately by Stripe + webhook). */
    @AuraEnabled
    public static String submitRegistration(String requestJson) {
        try { return reg().setRegistration(requestJson); } catch (Exception e) { throw audErr(e); }
    }

    /** Poll payment/order completion status after the Stripe leg. */
    @AuraEnabled
    public static String paymentStatus(String orderId) {
        try { return reg().checkRegistrationPaymentStatus(orderId); } catch (Exception e) { throw audErr(e); }
    }

    /** Cancel a pending (unpaid) order when the user abandons checkout. */
    @AuraEnabled
    public static Boolean rollback(String leadId, String accountId, String email, String orderId) {
        try { return reg().rollbackSetRegistration(leadId, accountId, email, orderId); } catch (Exception e) { throw audErr(e); }
    }

    /** Record an invite-only RSVP decline. */
    @AuraEnabled
    public static String rsvpDecline(String eventId, String userEmail) {
        try { return JSON.serialize(svc().setRSVPInviteOnlyDecline(eventId, userEmail), true); } catch (Exception e) { throw audErr(e); }
    }

    /* ===================== helpers ===================== */

    /** The empty-form fee request assembled from the typed load payload (mirrors the client's first recalc). */
    private static String initialFeesBody(GARP_EventRegV2_LoadService.RegLoad r, String regCode) {
        Boolean isBundle = r.teamRegInfo != null && r.teamRegInfo.isBundle == true;
        return JSON.serialize(new Map<String, Object>{
            'customerInfo' => new Map<String, Object>(),
            'membershipOptions' => new Map<String, Object>{
                'hasSelectedMembership' => false, 'hasSelectedRiskNet' => false, 'autoRenew' => false
            },
            'paymentType' => '',
            'teamRegCode' => regCode,
            'affiliateCode' => r.affiliateCode,
            'addressInfo' => new Map<String, Object>{
                'billingAddress' => new Map<String, Object>(),
                'shippingAddress' => new Map<String, Object>(),
                'billingAndShippingSame' => true
            },
            'programRegistrationInfo' => r.programRegistrationInfo,
            'examSelectionInfo' => r.examSelectionInfo,
            'promoCodes' => new List<Object>(),
            'isEventBundleSelected' => isBundle
        }, true);
    }

    private static AuraHandledException audErr(Exception e) {
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        return ahe;
    }
}