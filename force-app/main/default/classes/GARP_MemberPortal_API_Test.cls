/**
 * Tests for the React member-portal API and service.
 *
 * These deliberately avoid creating a Community user: provisioning one depends
 * on portal licences and profile names that vary per org, which would make the
 * suite fail for environmental reasons rather than code reasons. Instead they
 * cover the logic directly (identity mapping, the metadata-driven completeness
 * engine, rich-text conversion, routing) plus the "not a member" path that every
 * action funnels through when the running user has no linked Contact.
 */
@IsTest
private class GARP_MemberPortal_API_Test {

    private static Contact sampleContact() {
        return new Contact(
            FirstName = 'QA',
            LastName = 'Member',
            Email = 'qa.member@example.invalid',
            GARP_Member_ID__c = '9900001',
            Membership_Type__c = 'Affiliate',
            // MPS_Membership_Status__c is a formula field and cannot be seeded.
            KPI_Membership_Expiration_Date__c = Date.newInstance(2026, 9, 24),
            Company__c = 'PRAG TECH',
            Corporate_Title__c = 'Senior Manager',
            Job_Function__c = 'Procurement/Supply Chain Management',
            MailingStreet = 'GARP DRIVE',
            MailingCity = 'TESTING',
            MailingCountry = 'Ghana'
        );
    }

    @IsTest
    static void identityMapsMemberFacingGarpIdAndAudience() {
        Contact c = sampleContact();

        Test.startTest();
        GARP_MemberPortal_Service.Identity id = GARP_MemberPortal_Service.buildIdentity(c);
        Test.stopTest();

        // The portal shows GARP_Member_ID__c, not the internal GARP_ID__c autonumber.
        System.assertEquals('9900001', id.garpId, 'Should surface the member-facing GARP ID');
        System.assertEquals('Affiliate', id.membershipType, 'Membership type should pass through');
        System.assertEquals(
            Date.newInstance(2026, 9, 24),
            id.membershipExpiration,
            'Expiry should fall back through the date chain to KPI_Membership_Expiration_Date__c'
        );
        System.assertEquals(true, id.isAffiliateMember, 'Affiliate flag should be set');
        System.assertEquals(false, id.isIndividualMember, 'Individual flag should not be set');
        System.assertEquals(true, id.isMember, 'An affiliate is still a member');
        System.assertEquals('Affiliate', id.audience, 'Audience key drives card gating');
    }

    @IsTest
    static void identityForNonMemberResolvesNonMemberAudience() {
        Contact c = new Contact(FirstName = 'No', LastName = 'Membership');

        GARP_MemberPortal_Service.Identity id = GARP_MemberPortal_Service.buildIdentity(c);

        System.assertEquals(false, id.isMember, 'Blank membership type is not a member');
        System.assertEquals('NonMember', id.audience, 'Audience should be NonMember');
        System.assertEquals(null, id.membershipExpiration, 'No expiry date is expected');
    }

    @IsTest
    static void completenessScoresConfiguredFieldsAndListsWhatIsMissing() {
        Contact c = sampleContact();

        Test.startTest();
        GARP_MemberPortal_Service.Completeness score = GARP_MemberPortal_Service.scoreProfile(c);
        Test.stopTest();

        System.assert(score.totalWeight > 0, 'GARP_Portal_Profile_Field__mdt rows should be configured');
        System.assert(score.earnedWeight > 0, 'Populated fields should earn weight');
        System.assert(
            score.earnedWeight < score.totalWeight,
            'This fixture leaves academic and expertise fields blank, so it cannot be complete'
        );
        System.assert(
            score.percentComplete > 0 && score.percentComplete < 100,
            'Percentage should land strictly between 0 and 100, got ' + score.percentComplete
        );
        System.assertEquals(false, score.isComplete, 'Profile is not complete');
        System.assert(!score.missing.isEmpty(), 'Missing labels should be reported to the member');
        System.assert(
            !score.missingBySection.isEmpty(),
            'Missing counts should be grouped by My Account section for deep-linking'
        );
        System.assertEquals(false, score.muted, 'Card is not muted when the mute date is null');
    }

    @IsTest
    static void completenessTreatsMuteDateAsMuted() {
        Contact c = sampleContact();
        c.Date_Mute_Updated_Profile_GARP_Member__c = Date.today();

        GARP_MemberPortal_Service.Completeness score = GARP_MemberPortal_Service.scoreProfile(c);

        System.assertEquals(true, score.muted, 'A mute date should suppress the dashboard card');
    }

    @IsTest
    static void completenessCountsCheckboxOnlyWhenTrue() {
        Contact unchecked = sampleContact();
        Contact checked = sampleContact();
        checked.GARP_Directory_Opt_In__c = true;

        GARP_MemberPortal_Service.Completeness before = GARP_MemberPortal_Service.scoreProfile(unchecked);
        GARP_MemberPortal_Service.Completeness after = GARP_MemberPortal_Service.scoreProfile(checked);

        System.assert(
            after.earnedWeight > before.earnedWeight,
            'Ticking a configured checkbox field should increase the earned weight'
        );
    }

    @IsTest
    static void richTextBecomesPlainParagraphs() {
        String html = '<p>One Hub. Three Resources.</p><p>Exclusive Add-On &ndash; USD 100</p>';

        List<String> paragraphs = GARP_MemberPortal_Service.toParagraphs(html);

        System.assertEquals(2, paragraphs.size(), 'Each <p> should become one paragraph: ' + paragraphs);
        System.assertEquals('One Hub. Three Resources.', paragraphs[0], 'Tags should be stripped');
        System.assert(
            !paragraphs[1].contains('<'),
            'No markup should survive into the React payload: ' + paragraphs[1]
        );
    }

    @IsTest
    static void richTextListBecomesBullets() {
        String html = '<ul><li>80+ books from Risk Books</li><li>9 Risk Journals</li></ul>';

        List<String> bullets = GARP_MemberPortal_Service.toBullets(html);

        System.assertEquals(2, bullets.size(), 'Each <li> should become one bullet: ' + bullets);
        System.assertEquals('80+ books from Risk Books', bullets[0], 'Bullet text should be plain');
        System.assertEquals('9 Risk Journals', bullets[1], 'Bullet text should be plain');
    }

    @IsTest
    static void blankRichTextYieldsEmptyLists() {
        System.assertEquals(0, GARP_MemberPortal_Service.toParagraphs(null).size(), 'Null is safe');
        System.assertEquals(0, GARP_MemberPortal_Service.toBullets('   ').size(), 'Blank is safe');
    }

    @IsTest
    static void optionsExposePicklistsAndActiveChapters() {
        Test.startTest();
        GARP_MemberPortal_Service.OptionsView options = GARP_MemberPortal_Service.buildOptions();
        Test.stopTest();

        System.assertNotEquals(null, options.picklists, 'Picklist map should be built');
        System.assert(
            options.picklists.containsKey('Job_Function__c'),
            'Job function options drive the Career form: ' + options.picklists.keySet()
        );
        System.assert(
            !options.picklists.get('Job_Function__c').isEmpty(),
            'Job function should expose active picklist entries'
        );
        System.assertNotEquals(null, options.chapters, 'Chapter list should be present (may be empty in a scratch org)');
    }

    // ------------------------------------------------------------------
    // REST routing
    // ------------------------------------------------------------------

    private static RestResponse callGet(String action) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/memberportal/' + action;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        GARP_MemberPortal_API.doGet();
        return RestContext.response;
    }

    private static RestResponse callPost(String action, String body) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/memberportal/' + action;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        GARP_MemberPortal_API.doPost();
        return RestContext.response;
    }

    private static Map<String, Object> envelopeOf(RestResponse res) {
        return (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
    }

    @IsTest
    static void unknownGetActionReturns404() {
        Test.startTest();
        RestResponse res = callGet('doesNotExist');
        Test.stopTest();

        System.assertEquals(404, res.statusCode, 'Unrecognised actions should 404');
        Map<String, Object> body = envelopeOf(res);
        System.assertEquals(false, body.get('ok'), 'Envelope should report failure');
        System.assert(
            String.valueOf(body.get('error')).contains('doesNotExist'),
            'Error should name the bad action: ' + body.get('error')
        );
    }

    @IsTest
    static void unknownPostActionReturns404() {
        RestResponse res = callPost('nope', '{}');

        System.assertEquals(404, res.statusCode, 'Unrecognised actions should 404');
        System.assertEquals(false, envelopeOf(res).get('ok'), 'Envelope should report failure');
    }

    @IsTest
    static void memberActionsReturn403ForUsersWithoutAContact() {
        // The running test user is an internal user with no ContactId, which is
        // the same situation as a guest hitting a member-only endpoint.
        Test.startTest();
        RestResponse me = callGet('me');
        RestResponse dashboard = callGet('dashboard');
        RestResponse account = callGet('account');
        RestResponse membership = callGet('membership');
        Test.stopTest();

        for (RestResponse res : new List<RestResponse>{ me, dashboard, account, membership }) {
            System.assertEquals(403, res.statusCode, 'Member endpoints require a linked Contact');
            System.assertEquals(false, envelopeOf(res).get('ok'), 'Envelope should report failure');
        }
    }

    @IsTest
    static void profilePostRejectsMalformedBody() {
        RestResponse res = callPost('profile', '{"nope":true}');

        System.assertEquals(400, res.statusCode, 'A missing "values" object is a bad request');
        System.assert(
            String.valueOf(envelopeOf(res).get('error')).contains('values'),
            'Error should explain the expected shape'
        );
    }

    @IsTest
    static void dismissCardPostRequiresAKey() {
        RestResponse res = callPost('dismissCard', '{}');

        System.assertEquals(400, res.statusCode, 'A missing card key is a bad request');
    }

    @IsTest
    static void actionParsingIgnoresTrailingSlashesAndBasePath() {
        RestRequest withSlash = new RestRequest();
        withSlash.requestURI = '/services/apexrest/memberportal/dashboard/';

        System.assertEquals(
            'dashboard',
            GARP_MemberPortal_API.actionOf(withSlash),
            'A trailing slash should not change the action'
        );

        RestRequest bare = new RestRequest();
        bare.requestURI = '/services/apexrest/memberportal/';
        System.assertEquals(
            '',
            GARP_MemberPortal_API.actionOf(bare),
            'No action segment should resolve to an empty action'
        );
    }
}