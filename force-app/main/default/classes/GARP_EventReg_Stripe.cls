/**
 * Standalone Stripe wrapper for the optimized registration module.
 *
 * Phase 1 of the fully self-contained rewrite: this class owns all Stripe HTTP
 * traffic (Checkout Sessions, Tax calculations, payment status) with NO
 * dependency on GARP_StripeClass or any GARP_BC_* class. The only external touch
 * point is the GARP_StripeSettings__c custom setting (configuration DATA, not a
 * class) for the API keys and feature flags — the same record the legacy
 * integration reads, so it targets the same Stripe account.
 *
 * Faithful to the existing integration: POST https://api.stripe.com/v1/...,
 * Content-Type application/x-www-form-urlencoded, Authorization: Bearer <secret>.
 *
 * Hardening note: the secret key is read from a custom setting to match the
 * current integration. Moving it behind a Named Credential is recommended and
 * would only change buildRequest().
 */
public without sharing class GARP_EventReg_Stripe {

    private static final String BASE_URL = 'https://api.stripe.com/v1';

    public class StripeException extends Exception {}

    /* ===================== Configuration (data, not a class) ===================== */

    private static GARP_StripeSettings__c cachedSetting;
    private static Boolean settingLoaded = false;

    /** The active Stripe setting, or null if none is configured/active. */
    public static GARP_StripeSettings__c settings() {
        if (settingLoaded) { return cachedSetting; }
        settingLoaded = true;
        for (GARP_StripeSettings__c s : GARP_StripeSettings__c.getAll().values()) {
            if (s.Is_Active__c == true) { cachedSetting = s; break; }
        }
        return cachedSetting;
    }

    public static Boolean isEnabled() {
        GARP_StripeSettings__c s = settings();
        return s != null && s.Use_Stripe__c == true;
    }

    /** When true, Stripe Tax computes tax and local NJ/VAT calculation is skipped. */
    public static Boolean isTaxEnabled() {
        GARP_StripeSettings__c s = settings();
        return s != null && s.Use_Stripe_Tax__c == true;
    }

    public static String publishableKey() {
        GARP_StripeSettings__c s = settings();
        return s == null ? null : s.Client_Side_API_Key__c;
    }

    /* ===================== High-level operations ===================== */

    /**
     * Creates a Stripe Checkout Session. Pass already-flattened Stripe form params
     * (e.g. 'mode' => 'payment', 'line_items[0][price]' => 'price_x',
     * 'line_items[0][quantity]' => '1', 'success_url' => ..., 'cancel_url' => ...).
     * Returns the parsed JSON (contains 'id', 'url', 'payment_status', ...).
     */
    public static Map<String, Object> createCheckoutSession(Map<String, String> params) {
        HttpResponse res = send('POST', '/checkout/sessions', params);
        return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    }

    /** Retrieves a Checkout Session by id (status / payment_status / amounts). */
    public static Map<String, Object> retrieveCheckoutSession(String sessionId) {
        HttpResponse res = send('GET', '/checkout/sessions/' + sessionId, null);
        return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    }

    /** Calls Stripe Tax to compute tax for a set of line amounts + address params. */
    public static Map<String, Object> calculateTax(Map<String, String> params) {
        HttpResponse res = send('POST', '/tax/calculations', params);
        return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    }

    /** Convenience: is a retrieved Checkout Session paid? */
    public static Boolean isSessionPaid(Map<String, Object> session) {
        return session != null && 'paid'.equalsIgnoreCase(String.valueOf(session.get('payment_status')));
    }

    /* ===================== Low-level HTTP ===================== */

    private static HttpResponse send(String method, String path, Map<String, String> form) {
        GARP_StripeSettings__c s = settings();
        if (s == null || String.isBlank(s.Server_Side_API_Key__c)) {
            throw new StripeException('Stripe is not configured (no active GARP_StripeSettings__c with a secret key).');
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + path);
        req.setMethod(method);
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('authorization', 'Bearer ' + s.Server_Side_API_Key__c);
        if (form != null && !form.isEmpty()) {
            req.setBody(encodeForm(form));
        }
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() >= 300) {
            throw new StripeException('Stripe API error ' + res.getStatusCode() + ': ' + res.getBody());
        }
        return res;
    }

    /** x-www-form-urlencoded body from a flat param map. */
    @TestVisible
    private static String encodeForm(Map<String, String> form) {
        List<String> parts = new List<String>();
        for (String key : form.keySet()) {
            String val = form.get(key);
            parts.add(EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(val == null ? '' : val, 'UTF-8'));
        }
        return String.join(parts, '&');
    }
}