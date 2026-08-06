@isTest
private class GARP_EventSignupController_Test {

    // Is_Pay_For_Event__c is a read-only formula, so it cannot be set here;
    // these tests cover the non-pay-for path (Status 'Registered'/'RSVP Accept').
    private static Event__c buildActiveEvent(Boolean inviteOnly) {
        Event__c evt = new Event__c(
            Name = 'Test Event',
            Title__c = 'Test Event',
            Status__c = 'Active',
            Delivery_Method__c = 'Hybrid',
            Start_Date__c = DateTime.now().addDays(10),
            End_Date__c = DateTime.now().addDays(11),
            Last_Date_For_Registration__c = Date.today().addDays(5),
            Invite_Only__c = inviteOnly
        );
        insert evt;
        return evt;
    }

    private static GARP_EventSignupController.RegistrationRequest buildRequest(Id eventId, String email) {
        GARP_EventSignupController.RegistrationRequest req = new GARP_EventSignupController.RegistrationRequest();
        req.eventId = eventId;
        req.firstName = 'Ada';
        req.lastName = 'Lovelace';
        req.email = email;
        req.company = 'GARP';
        req.jobTitle = 'Analyst';
        req.attendanceMethod = 'Virtual';
        req.dietaryRestrictions = 'Vegetarian';
        req.eventQuestionResponse = 'Looking forward to it';
        req.privacyPolicyAttestation = true;
        return req;
    }

    @isTest
    static void newRegistration_succeedsAndLinksContact() {
        Event__c evt = buildActiveEvent(false);
        Contact c = new Contact(LastName = 'Lovelace', Email = 'ada@example.com');
        insert c;

        Test.startTest();
        GARP_EventSignupController.RegistrationResult res =
            GARP_EventSignupController.submitRegistration(buildRequest(evt.Id, 'ada@example.com'));
        Test.stopTest();

        System.assertEquals('Success', res.status, res.message);
        System.assertNotEquals(null, res.registrationId);

        Event_Registration__c reg = [
            SELECT Contact__c, Member_Email__c, Status__c, Attendance_Method__c,
                   Dietary_Restriction__c, Dietary_Restriction_Description__c,
                   Event_Question_Response__c, Privacy_Policy_Attestation__c
            FROM Event_Registration__c WHERE Id = :res.registrationId
        ];
        System.assertEquals(c.Id, reg.Contact__c, 'Should link matched Contact');
        System.assertEquals('Registered', reg.Status__c);
        System.assertEquals('Virtual', reg.Attendance_Method__c);
        System.assertEquals(true, reg.Dietary_Restriction__c);
        System.assertNotEquals(null, reg.Privacy_Policy_Attestation__c);
    }

    @isTest
    static void duplicateRegistration_upsertsSameRecord() {
        Event__c evt = buildActiveEvent(false);

        Test.startTest();
        GARP_EventSignupController.RegistrationResult first =
            GARP_EventSignupController.submitRegistration(buildRequest(evt.Id, 'dup@example.com'));
        GARP_EventSignupController.RegistrationResult second =
            GARP_EventSignupController.submitRegistration(buildRequest(evt.Id, 'dup@example.com'));
        Test.stopTest();

        System.assertEquals('Success', first.status);
        System.assertEquals('Success', second.status);
        System.assertEquals(first.registrationId, second.registrationId, 'Should reuse the existing registration');
        System.assertEquals(1, [SELECT COUNT() FROM Event_Registration__c WHERE Event__c = :evt.Id]);
    }

    @isTest
    static void inviteOnlyEvent_setsRsvpAccept() {
        Event__c evt = buildActiveEvent(true);

        Test.startTest();
        GARP_EventSignupController.RegistrationResult res =
            GARP_EventSignupController.submitRegistration(buildRequest(evt.Id, 'invite@example.com'));
        Test.stopTest();

        System.assertEquals('Success', res.status, res.message);
        Event_Registration__c reg = [SELECT Status__c FROM Event_Registration__c WHERE Id = :res.registrationId];
        System.assertEquals('RSVP Accept', reg.Status__c);
    }

    @isTest
    static void missingRequiredFields_returnsError() {
        Event__c evt = buildActiveEvent(false);
        GARP_EventSignupController.RegistrationRequest req = buildRequest(evt.Id, '');

        Test.startTest();
        GARP_EventSignupController.RegistrationResult res =
            GARP_EventSignupController.submitRegistration(req);
        Test.stopTest();

        System.assertEquals('Error', res.status);
        System.assertEquals(0, [SELECT COUNT() FROM Event_Registration__c WHERE Event__c = :evt.Id]);
    }

    @isTest
    static void privacyNotAccepted_returnsError() {
        Event__c evt = buildActiveEvent(false);
        GARP_EventSignupController.RegistrationRequest req = buildRequest(evt.Id, 'noprivacy@example.com');
        req.privacyPolicyAttestation = false;

        Test.startTest();
        GARP_EventSignupController.RegistrationResult res =
            GARP_EventSignupController.submitRegistration(req);
        Test.stopTest();

        System.assertEquals('Error', res.status);
    }

    @isTest
    static void closedRegistration_returnsError() {
        Event__c evt = buildActiveEvent(false);
        evt.Last_Date_For_Registration__c = Date.today().addDays(-1);
        update evt;

        Test.startTest();
        GARP_EventSignupController.RegistrationResult res =
            GARP_EventSignupController.submitRegistration(buildRequest(evt.Id, 'late@example.com'));
        Test.stopTest();

        System.assertEquals('Error', res.status);
    }

    @isTest
    static void missingEvent_returnsError() {
        Test.startTest();
        GARP_EventSignupController.RegistrationResult res =
            GARP_EventSignupController.submitRegistration(buildRequest(null, 'x@example.com'));
        Test.stopTest();

        System.assertEquals('Error', res.status);
    }
}