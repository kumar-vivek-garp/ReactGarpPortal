/**
 * Thin controller for the garpEventSignup LWC.
 *
 * The LWC reads Event__c / Event_Rate__c data directly through the Lightning
 * GraphQL wire adapter (lightning/uiGraphQLApi), which is read-only. This class
 * exists only to persist the registration, since GraphQL cannot mutate records.
 *
 * It deliberately does NOT replicate the full GARP_BC_Registration flow
 * (eligibility, products, study materials, Stripe, promo/team codes). It links
 * the registration to an existing Contact when one matches the email, otherwise
 * the registration is stored against the email only.
 */
public with sharing class GARP_EventSignupController {

    public class RegistrationRequest {
        @AuraEnabled public String eventId;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String email;
        @AuraEnabled public String company;
        @AuraEnabled public String jobTitle;
        @AuraEnabled public String attendanceMethod;
        @AuraEnabled public String dietaryRestrictions;
        @AuraEnabled public String eventQuestionResponse;
        @AuraEnabled public Boolean privacyPolicyAttestation;
    }

    public class RegistrationResult {
        @AuraEnabled public String status;          // 'Success' | 'Error'
        @AuraEnabled public String message;
        @AuraEnabled public String registrationId;
    }

    @AuraEnabled
    public static RegistrationResult submitRegistration(RegistrationRequest request) {
        RegistrationResult result = new RegistrationResult();

        try {
            // --- Validate input -------------------------------------------------
            if (request == null || String.isBlank(request.eventId)) {
                return error(result, 'Missing event reference.');
            }
            if (String.isBlank(request.firstName) || String.isBlank(request.lastName) || String.isBlank(request.email)) {
                return error(result, 'First name, last name and email are required.');
            }
            if (request.privacyPolicyAttestation != true) {
                return error(result, 'You must accept the privacy policy to register.');
            }

            // --- Validate event is open ----------------------------------------
            List<Event__c> events = [
                SELECT Id, Title__c, Max_Capacity_Met__c, Last_Date_For_Registration__c,
                       Is_Pay_For_Event__c, Invite_Only__c
                FROM Event__c
                WHERE Id = :request.eventId AND Status__c = 'Active'
                LIMIT 1
            ];
            if (events.isEmpty()) {
                return error(result, 'Event not found or not currently active.');
            }
            Event__c evt = events[0];

            if (evt.Max_Capacity_Met__c == true) {
                return error(result, 'This event has reached capacity.');
            }
            if (evt.Last_Date_For_Registration__c != null && evt.Last_Date_For_Registration__c < Date.today()) {
                return error(result, 'Registration for this event has closed.');
            }

            // --- Light Contact match by email ----------------------------------
            Id contactId;
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :request.email LIMIT 1];
            if (!contacts.isEmpty()) {
                contactId = contacts[0].Id;
            }

            // --- Upsert registration keyed by (event, email) -------------------
            List<Event_Registration__c> existing = [
                SELECT Id FROM Event_Registration__c
                WHERE Event__c = :request.eventId AND Member_Email__c = :request.email
                LIMIT 1
            ];
            Event_Registration__c reg = existing.isEmpty()
                ? new Event_Registration__c(Event__c = request.eventId)
                : existing[0];

            reg.Contact__c = contactId;
            reg.Member_Email__c = request.email;
            reg.Attendee_Type__c = 'Participant';
            reg.Event_Registration_Date__c = DateTime.now();

            if (String.isNotBlank(request.attendanceMethod)) {
                reg.Attendance_Method__c = request.attendanceMethod;
            }
            if (String.isNotBlank(request.dietaryRestrictions)) {
                reg.Dietary_Restriction__c = true;
                reg.Dietary_Restriction_Description__c = request.dietaryRestrictions;
            }
            if (String.isNotBlank(request.eventQuestionResponse)) {
                reg.Event_Question_Response__c = request.eventQuestionResponse;
            }
            reg.Privacy_Policy_Attestation__c = System.now();

            // Status mirrors GARP_BC_Events.createEventRegistrations for the
            // non-payment path; pay-for events are left unset for downstream order flow.
            if (evt.Invite_Only__c == true) {
                reg.Status__c = 'RSVP Accept';
            } else if (evt.Is_Pay_For_Event__c != true) {
                reg.Status__c = 'Registered';
            }

            upsert reg;

            result.status = 'Success';
            result.message = 'You are registered for ' + evt.Title__c + '.';
            result.registrationId = reg.Id;

        } catch (Exception e) {
            return error(result, 'Unable to complete registration: ' + e.getMessage());
        }

        return result;
    }

    private static RegistrationResult error(RegistrationResult result, String message) {
        result.status = 'Error';
        result.message = message;
        return result;
    }
}