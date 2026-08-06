/**
 * REST facade for the event-registration React UI Bundle.
 *
 * The bundle cannot call @AuraEnabled Apex directly, so this @RestResource
 * exposes the existing GARP_EventReg_Controller / GARP_EventRegFast_Controller
 * methods over HTTP. It is a thin router: it reads the trailing path segment as
 * the action, delegates to the matching controller method, and writes that
 * method's JSON straight to the response (no business logic duplicated here).
 *
 * Base endpoint: /services/apexrest/eventreg/<action>
 *
 *   GET  /eventreg/info?eventId=..&regCode=..&skipInstitutions=true
 *   GET  /eventreg/countries        GET /eventreg/companies
 *   GET  /eventreg/options          GET /eventreg/stripe
 *   POST /eventreg/fees             POST /eventreg/verifyCustomer
 *   POST /eventreg/verifyAddress    POST /eventreg/setRegistration
 *   POST /eventreg/paymentStatus    POST /eventreg/rollback
 *   POST /eventreg/rsvpDecline      POST /eventreg/checkoutSession
 *   POST /eventreg/completeFreeOrder
 */
@RestResource(urlMapping='/eventreg/*')
global with sharing class GARP_EventReg_REST {

    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        String action = actionOf(req);
        try {
            Map<String, String> p = req.params;
            if (action == 'info') {
                Boolean skip = 'true'.equalsIgnoreCase(p.get('skipInstitutions'));
                respond(GARP_EventReg_Controller.getEventRegistrationInfo(
                    p.get('eventId'), p.get('regCode'), skip));
            } else if (action == 'countries') {
                respond(JSON.serialize(GARP_EventRegFast_Controller.getCountries()));
            } else if (action == 'companies') {
                respond(JSON.serialize(GARP_EventRegFast_Controller.getCompanies()));
            } else if (action == 'options') {
                respond(JSON.serialize(new Map<String, Object>{
                    'professionalLevels' => GARP_EventRegFast_Controller.getProfessionalLevels(),
                    'jobFunctions' => GARP_EventRegFast_Controller.getJobFunctions(),
                    'riskSpecialties' => GARP_EventRegFast_Controller.getRiskSpecialties()
                }));
            } else if (action == 'stripe') {
                respond(JSON.serialize(GARP_EventRegFast_Controller.getStripeSettings()));
            } else {
                respondError(404, 'Unknown GET action: ' + action);
            }
        } catch (Exception e) {
            respondError(500, e.getMessage());
        }
    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        String action = actionOf(req);
        String body = req.requestBody != null ? req.requestBody.toString() : '';
        try {
            if (action == 'fees') {
                respond(GARP_EventReg_Controller.getRegistrationFees(body));
            } else if (action == 'verifyCustomer') {
                respond(GARP_EventReg_Controller.verifyExistingCustomer(body));
            } else if (action == 'verifyAddress') {
                respond(GARP_EventReg_Controller.verifyAddress(body));
            } else if (action == 'setRegistration') {
                respond(GARP_EventReg_Controller.setRegistration(body));
            } else if (action == 'checkoutSession') {
                respond(GARP_EventReg_Controller.getEmbeddedCheckoutSession(body));
            } else if (action == 'hostedCheckout') {
                respond(GARP_EventReg_Controller.getCheckoutSession(body));
            } else if (action == 'paymentStatus') {
                Map<String, Object> m = parse(body);
                respond(GARP_EventReg_Controller.checkRegistrationPaymentStatus(str(m, 'orderId')));
            } else if (action == 'rollback') {
                Map<String, Object> m = parse(body);
                Boolean ok = GARP_EventReg_Controller.rollbackSetRegistration(
                    str(m, 'leadId'), str(m, 'accountId'), str(m, 'email'), str(m, 'orderId'));
                respond(JSON.serialize(new Map<String, Object>{ 'success' => ok }));
            } else if (action == 'rsvpDecline') {
                Map<String, Object> m = parse(body);
                respond(GARP_EventReg_Controller.setRSVPInviteOnlyDecline(
                    str(m, 'eventId'), str(m, 'userEmail')));
            } else if (action == 'completeFreeOrder') {
                Map<String, Object> m = parse(body);
                GARP_EventRegFast_Controller.completeFreeOrderAsync(str(m, 'orderId'), str(m, 'contactId'));
                respond(JSON.serialize(new Map<String, Object>{ 'success' => true }));
            } else {
                respondError(404, 'Unknown POST action: ' + action);
            }
        } catch (Exception e) {
            respondError(500, e.getMessage());
        }
    }

    // --- helpers -----------------------------------------------------------

    /** Trailing path segment after /eventreg/, minus any query string. */
    private static String actionOf(RestRequest req) {
        String uri = req.requestURI;
        Integer q = uri.indexOf('?');
        if (q >= 0) { uri = uri.substring(0, q); }
        Integer slash = uri.lastIndexOf('/');
        return slash >= 0 ? uri.substring(slash + 1) : uri;
    }

    private static Map<String, Object> parse(String body) {
        if (String.isBlank(body)) { return new Map<String, Object>(); }
        return (Map<String, Object>) JSON.deserializeUntyped(body);
    }

    private static String str(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v == null ? null : String.valueOf(v);
    }

    private static void respond(String json) {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(String.isBlank(json) ? 'null' : json);
        res.statusCode = 200;
    }

    private static void respondError(Integer code, String message) {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{ 'error' => message }));
        res.statusCode = code;
    }
}