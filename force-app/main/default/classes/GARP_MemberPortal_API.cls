/**
 * REST surface for the React member portal (Dashboard, My Account, Membership
 * Benefits) in the GarpAppv1 UI Bundle.
 *
 * Written for the React client rather than adapted from the legacy Visualforce
 * remoting API: one action per screen returning exactly the composed view the
 * screen renders, a single `{ ok, data }` / `{ ok, error }` envelope, and real
 * HTTP status codes. It holds no business logic — every action delegates to
 * GARP_MemberPortal_Service.
 *
 * Base endpoint: /services/apexrest/memberportal/<action>
 *
 *   GET  /memberportal/me              signed-in member identity + membership summary
 *   GET  /memberportal/dashboard       identity, completeness meter and dynamic cards
 *   GET  /memberportal/account         My Account sections and addresses
 *   GET  /memberportal/membership      benefits grouped into sections, with gating
 *   GET  /memberportal/options         picklist + chapter options for the edit forms
 *   GET  /memberportal/examWindow      current/next exam registration window
 *   GET  /memberportal/examResults     exam registrations, results and quartiles
 *   GET  /memberportal/studyMaterials  eBook entitlements and access links
 *   GET  /memberportal/events          registered events + open upcoming events
 *   GET  /memberportal/orders          purchase history
 *   GET  /memberportal/cases           support cases the member has raised
 *
 *   POST /memberportal/profile      { "values": { "<Contact field>": <value> } }
 *   POST /memberportal/dismissCard  { "key": "<GARP_Portal_Card__mdt DeveloperName>" }
 *   POST /memberportal/submitCase   { "subject": "...", "description": "..." }
 *
 * The Guest User profile does NOT need access to this class — every action
 * requires a Contact-linked user. The community member profile (or a permission
 * set assigned to it) must be granted Apex Class Access to GARP_MemberPortal_API,
 * otherwise these endpoints return 403.
 */
@RestResource(urlMapping='/memberportal/*')
global without sharing class GARP_MemberPortal_API {

    @HttpGet
    global static void doGet() {
        String action = actionOf(RestContext.request);
        try {
            if (action == 'me') {
                respond(GARP_MemberPortal_Service.buildIdentity(
                    GARP_MemberPortal_Service.currentContact()));
            } else if (action == 'dashboard') {
                respond(GARP_MemberPortal_Service.buildDashboard());
            } else if (action == 'account') {
                respond(GARP_MemberPortal_Service.buildAccount());
            } else if (action == 'membership') {
                respond(GARP_MemberPortal_Service.buildMembership());
            } else if (action == 'options') {
                respond(GARP_MemberPortal_Service.buildOptions());
            } else if (action == 'examWindow') {
                respond(GARP_MemberPortal_Service.nextExamWindow(
                    GARP_MemberPortal_Service.currentContact().Id));
            } else if (action == 'examResults') {
                respond(GARP_MemberPortal_Programs.examResults());
            } else if (action == 'studyMaterials') {
                respond(GARP_MemberPortal_Programs.studyMaterials());
            } else if (action == 'events') {
                respond(GARP_MemberPortal_Programs.events());
            } else if (action == 'orders') {
                respond(GARP_MemberPortal_Programs.orders());
            } else if (action == 'cases') {
                respond(GARP_MemberPortal_Programs.cases());
            } else {
                fail(404, 'Unknown GET action: ' + action);
            }
        } catch (GARP_MemberPortal_Service.PortalException e) {
            fail(403, e.getMessage());
        } catch (Exception e) {
            failWithTrace(e);
        }
    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        String action = actionOf(req);
        String rawBody = req.requestBody == null ? '' : req.requestBody.toString();
        try {
            Map<String, Object> body = parse(rawBody);
            if (action == 'profile') {
                Object values = body.get('values');
                if (!(values instanceof Map<String, Object>)) {
                    fail(400, 'Expected a "values" object of Contact field/value pairs.');
                    return;
                }
                respond(GARP_MemberPortal_Service.saveProfile((Map<String, Object>) values));
            } else if (action == 'dismissCard') {
                String key = body.get('key') == null ? null : String.valueOf(body.get('key'));
                if (String.isBlank(key)) {
                    fail(400, 'Expected a card "key".');
                    return;
                }
                respond(GARP_MemberPortal_Service.dismissCard(key));
            } else if (action == 'submitCase') {
                respond(GARP_MemberPortal_Programs.submitCase(
                    body.get('subject') == null ? null : String.valueOf(body.get('subject')),
                    body.get('description') == null ? null : String.valueOf(body.get('description'))));
            } else {
                fail(404, 'Unknown POST action: ' + action);
            }
        } catch (GARP_MemberPortal_Service.PortalException e) {
            fail(403, e.getMessage());
        } catch (Exception e) {
            failWithTrace(e);
        }
    }

    // ------------------------------------------------------------------
    // Plumbing
    // ------------------------------------------------------------------

    /** The first non-blank path segment after /memberportal/ is the action name. */
    @TestVisible
    private static String actionOf(RestRequest req) {
        String uri = req == null || req.requestURI == null ? '' : req.requestURI;
        List<String> parts = uri.split('/');

        Integer baseIndex = -1;
        for (Integer i = 0; i < parts.size(); i++) {
            if (parts[i] == 'memberportal') {
                baseIndex = i;
                break;
            }
        }
        // Scan forward from the base segment, so a bare /memberportal/ resolves
        // to no action instead of picking up "apexrest" from the prefix.
        if (baseIndex >= 0) {
            for (Integer i = baseIndex + 1; i < parts.size(); i++) {
                if (String.isNotBlank(parts[i])) {
                    return parts[i];
                }
            }
            return '';
        }

        for (Integer i = parts.size() - 1; i >= 0; i--) {
            if (String.isNotBlank(parts[i])) {
                return parts[i];
            }
        }
        return '';
    }

    private static Map<String, Object> parse(String body) {
        if (String.isBlank(body)) {
            return new Map<String, Object>();
        }
        Object parsed = JSON.deserializeUntyped(body);
        if (parsed instanceof Map<String, Object>) {
            return (Map<String, Object>) parsed;
        }
        return new Map<String, Object>();
    }

    private static void respond(Object payload) {
        write(200, new Map<String, Object>{ 'ok' => true, 'data' => payload });
    }

    private static void fail(Integer status, String message) {
        write(status, new Map<String, Object>{ 'ok' => false, 'error' => message });
    }

    /**
     * Unexpected failures include the Apex type, line and stack trace.
     *
     * Community-user failures are otherwise near-impossible to diagnose: the
     * message alone (for example "Variable does not exist: tmpVar1", which Apex
     * raises for a bound query against an object the profile cannot read) does
     * not say which query threw. The trace names no member data, only class and
     * line numbers.
     */
    private static void failWithTrace(Exception e) {
        write(500, new Map<String, Object>{
            'ok' => false,
            'error' => e.getMessage(),
            'type' => e.getTypeName(),
            'line' => e.getLineNumber(),
            'stack' => e.getStackTraceString()
        });
    }

    private static void write(Integer status, Map<String, Object> envelope) {
        RestResponse res = RestContext.response;
        if (res == null) {
            return;
        }
        res.statusCode = status;
        res.addHeader('Content-Type', 'application/json; charset=UTF-8');
        res.responseBody = Blob.valueOf(JSON.serialize(envelope, true));
    }
}