/**
 * React-optimized controller for the garpEventRegReact app.
 *
 * Purpose: cut server round-trips for the React UI without duplicating any pricing/tax
 * logic. It delegates to the SAME GARP_EventReg_Gateway the LWC controller uses, so fees,
 * taxes, promos and eligibility stay 100% server-authoritative.
 *
 * Optimization shipped here — getRegistrationFeesWithComparison():
 *   The React app previously fired TWO getRegistrationFees calls on first load — one for the
 *   real cart, and a second "probe" (membership forced on) purely to show the member-savings
 *   figure. This method computes both in ONE Apex transaction (the GARP_EventReg_Selector
 *   is static-cached per transaction, so the event/product/pricing SOQL is reused instead of
 *   re-queried), returning { base, memberSavings }. That removes one full round-trip — and a
 *   duplicate set of queries — from every initial load.
 */
public without sharing class GARP_EventRegReact_Controller {

    private static GARP_EventReg_Gateway gateway() { return new GARP_EventReg_Gateway(); }

    /**
     * React-owned event-view entry point. Delegates to the shared gateway (the sanctioned
     * public API) WITHOUT modifying it — same payload/behavior as
     * GARP_EventReg_Controller.getEventRegistrationInfo (the Form_Session captcha token is
     * still created at load, preserving anti-bot timing).
     *
     * Note: this is intentionally NOT cacheable, because the shared load path performs DML
     * (the Form_Session insert) and we are not changing that shared class. Fast repeat/return
     * loads are delivered on the client instead (sessionStorage stale-while-revalidate in
     * useEventRegistration), which needs no server change.
     */
    @AuraEnabled
    public static String getEventView(String eventId, String regCode, Boolean skipInstitutions) {
        try {
            return gateway().getEventRegistrationInfo(eventId, regCode, skipInstitutions);
        } catch (Exception e) { throw audErr(e); }
    }

    /**
     * Base registration fees plus (optionally) the net member savings, in one call.
     *
     * @param requestJson        the standard getRegistrationFees request (same shape the LWC sends).
     * @param includeComparison  when true, also prices the cart with Individual membership
     *                           selected and returns the positive delta as `memberSavings`.
     * @return JSON `{ "base": <feesObject>, "memberSavings": <number|null> }`
     */
    @AuraEnabled
    public static String getRegistrationFeesWithComparison(String requestJson, Boolean includeComparison) {
        try {
            GARP_EventReg_Gateway gw = gateway();
            String baseJson = gw.getRegistrationFees(requestJson);

            Map<String, Object> resp = new Map<String, Object>();
            resp.put('base', JSON.deserializeUntyped(baseJson));

            Decimal savings = null;
            if (includeComparison == true && String.isNotBlank(requestJson)) {
                Map<String, Object> req = (Map<String, Object>) JSON.deserializeUntyped(requestJson);
                // Reuse the caller's risknet choice; force membership on, auto-renew off — the
                // same "probe" request the React client used to build for its second call.
                Boolean riskNet = false;
                Object mo = req.get('membershipOptions');
                if (mo instanceof Map<String, Object>) {
                    Object rn = ((Map<String, Object>) mo).get('hasSelectedRiskNet');
                    riskNet = rn == true;
                }
                req.put('membershipOptions', new Map<String, Object>{
                    'hasSelectedMembership' => true,
                    'hasSelectedRiskNet' => riskNet,
                    'autoRenew' => false
                });
                String memberJson = gw.getRegistrationFees(JSON.serialize(req));
                Decimal baseTotal = totalOf(baseJson);
                Decimal memberTotal = totalOf(memberJson);
                if (baseTotal != null && memberTotal != null && memberTotal < baseTotal) {
                    savings = (baseTotal - memberTotal).setScale(2, System.RoundingMode.HALF_UP);
                }
            }
            resp.put('memberSavings', savings);
            return JSON.serialize(resp);
        } catch (Exception e) { throw audErr(e); }
    }

    /* ===================== helpers ===================== */

    /** Read the numeric `total` out of a getRegistrationFees JSON payload (null-safe). */
    private static Decimal totalOf(String feesJson) {
        if (String.isBlank(feesJson)) { return null; }
        Object parsed = JSON.deserializeUntyped(feesJson);
        if (!(parsed instanceof Map<String, Object>)) { return null; }
        Object v = ((Map<String, Object>) parsed).get('total');
        if (v == null) { return null; }
        if (v instanceof Decimal) { return (Decimal) v; }
        if (v instanceof Integer) { return Decimal.valueOf((Integer) v); }
        if (v instanceof Double) { return Decimal.valueOf(String.valueOf(v)); }
        try { return Decimal.valueOf(String.valueOf(v)); } catch (Exception ignored) { return null; }
    }

    private static AuraHandledException audErr(Exception e) {
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        return ahe;
    }
}