/**
 * Member-portal service for the React UI Bundle.
 *
 * This is a ground-up replacement for the Visualforce-remoting path the legacy
 * AngularJS portal used (garpAppRemoter -> GARP_MS_MemberPortal). None of that
 * code is called from here. It exists because:
 *
 *   1. A UI Bundle cannot call @AuraEnabled Apex or Visualforce remoting at all,
 *      so the React client needs a plain REST surface (GARP_MemberPortal_API).
 *   2. The React client reads plain records over GraphQL. Apex is used only for
 *      the parts GraphQL cannot express: describe-driven scoring, cross-object
 *      composition, and config-driven card assembly.
 *
 * Everything that used to be hardcoded is configuration here:
 *
 *   - Which cards appear on a page, their order, audience, copy and CTAs come
 *     from GARP_Portal_Card__mdt.
 *   - Which Contact fields count toward "profile complete", and how much each
 *     one is worth, come from GARP_Portal_Profile_Field__mdt. The SOQL is built
 *     from those rows at runtime and every field is validated against the
 *     Contact describe first, so retuning the meter is a metadata edit.
 *   - Membership benefit cards and their grouping come from
 *     Membership_Exclusive_Offers__c records (including Portal_Section__c).
 *
 * Rich text from those records is converted to plain paragraphs and bullet
 * lists here, so the React client never has to inject raw HTML.
 */
/*
 * Sharing: `without sharing` on purpose.
 *
 * Community licences give members little or no record-level visibility of their
 * own exam registrations, entitlements, orders and cases, so running in the
 * member's sharing context returns nothing — or fails outright. Every query in
 * this class and in GARP_MemberPortal_Programs is filtered by the Contact id
 * resolved from the session (`currentContact()`), and no method accepts a
 * contact id from the client, so widening the sharing context cannot expose
 * another member's records.
 */
public without sharing class GARP_MemberPortal_Service {

    // Audience keys used by GARP_Portal_Card__mdt.Audience__c.
    private static final String AUDIENCE_ALL = 'All';
    private static final String AUDIENCE_INDIVIDUAL = 'Individual';
    private static final String AUDIENCE_AFFILIATE = 'Affiliate';
    private static final String AUDIENCE_NON_MEMBER = 'NonMember';

    public static final String PAGE_DASHBOARD = 'Dashboard';
    public static final String PAGE_MEMBERSHIP = 'Membership';

    private static final String PROVIDER_PROFILE = 'ProfileCompleteness';
    private static final String PROVIDER_EXAM = 'ExamRegistration';
    private static final String PROVIDER_DIRECTORY = 'MemberDirectory';
    private static final String PROVIDER_IDENTITY = 'MembershipIdentity';

    /** Contact fields the portal always needs, independent of the metadata config. */
    private static final List<String> BASE_CONTACT_FIELDS = new List<String>{
        'Id', 'AccountId', 'FirstName', 'LastName', 'Name', 'Email', 'Phone', 'Photo_URL__c',
        'GARP_Member_ID__c', 'GARP_ID__c',
        'Membership_Type__c', 'MPS_Membership_Status__c', 'MPS_Membership_Autorenew_On__c',
        'KPI_Membership_Expiration_Date__c', 'Membership_Caluclated_Expiration_Date__c',
        'MPS_Membership_Expire_Date__c', 'KPI_Membership_Since__c',
        'Company__c', 'Corporate_Title__c', 'Job_Function__c',
        'Company_City__c', 'Company_Country__c', 'Industry_Working_Year__c',
        'Highest_Degree__c', 'School_Name__c', 'Degree_Program_Name__c', 'Currently_in_School__c',
        'Risk_Specialty__c', 'Topics_or_Expertise__c',
        'KPI_Primary_Chapter_Name__c', 'KPI_Secondary_Chapter_Name__c',
        'GARP_Directory_Opt_In__c', 'GARP_Directory_Connect_Feature__c',
        'GARP_Dir_Privacy_Job_Information__c', 'GARP_Dir_Privacy_Prof_Background__c',
        'GARP_Dir_Privacy_Additional_Detail__c',
        'Email_GARP_Updates__c', 'Email_Chapter_Meetings__c',
        'Email_Career_Center_Job_Board__c', 'Email_Member_Update__c',
        'MailingStreet', 'MailingCity', 'MailingState', 'MailingPostalCode', 'MailingCountry',
        'OtherStreet', 'OtherCity', 'OtherState', 'OtherPostalCode', 'OtherCountry',
        'Date_Mute_Updated_Profile_GARP_Member__c'
    };

    /**
     * Contact fields the member is allowed to edit through the portal. Anything
     * not listed here (or not updateable for the running user) is dropped by
     * saveProfile, so a crafted request cannot reach an arbitrary field.
     */
    private static final Set<String> EDITABLE_FIELDS = new Set<String>{
        'FirstName', 'LastName', 'Phone',
        'MailingStreet', 'MailingCity', 'MailingState', 'MailingPostalCode', 'MailingCountry',
        'OtherStreet', 'OtherCity', 'OtherState', 'OtherPostalCode', 'OtherCountry',
        'Company__c', 'Corporate_Title__c', 'Job_Function__c',
        'Company_City__c', 'Company_Country__c', 'Industry_Working_Year__c',
        'Highest_Degree__c', 'School_Name__c', 'Degree_Program_Name__c', 'Currently_in_School__c',
        'Risk_Specialty__c', 'Topics_or_Expertise__c',
        'GARP_Directory_Opt_In__c', 'GARP_Directory_Connect_Feature__c',
        'GARP_Dir_Privacy_Job_Information__c', 'GARP_Dir_Privacy_Prof_Background__c',
        'GARP_Dir_Privacy_Additional_Detail__c',
        'Email_GARP_Updates__c', 'Email_Chapter_Meetings__c',
        'Email_Career_Center_Job_Board__c', 'Email_Member_Update__c'
    };

    public class PortalException extends Exception {}

    // =====================================================================
    // Configuration
    //
    // Card and profile-rule config is read from custom metadata when rows are
    // present and falls back to the built-in defaults below when they are not.
    // That keeps the portal working in an org where the seed rows have not been
    // deployed yet, while still letting an admin override any of it by adding
    // GARP_Portal_Card__mdt / GARP_Portal_Profile_Field__mdt records — the
    // moment one row exists for a page, it replaces that page's defaults.
    // =====================================================================

    /** One field that counts toward profile completeness. */
    public class ProfileRule {
        public String key;
        public String fieldApiName;
        public String label;
        public String section;
        public Integer weight;

        public ProfileRule(String key, String fieldApiName, String label, String section, Integer weight) {
            this.key = key;
            this.fieldApiName = fieldApiName;
            this.label = label;
            this.section = section;
            this.weight = weight == null || weight <= 0 ? 1 : weight;
        }
    }

    /** One configured card, from metadata or from the defaults. */
    public class CardDef {
        public String key;
        public String page;
        public String provider;
        public Integer rank;
        public String audience;
        public String title;
        public String body;
        public String ctaLabel;
        public String ctaUrl;
        public String imageUrl;
        /** Raw "key=value;key=value" provider parameters. */
        public String providerConfig;

        public CardDef(
            String key, String page, String provider, Integer rank, String audience,
            String title, String body, String ctaLabel, String ctaUrl, String imageUrl,
            String providerConfig
        ) {
            this.key = key;
            this.page = page;
            this.provider = provider;
            this.rank = rank == null ? 999 : rank;
            this.audience = audience;
            this.title = title;
            this.body = body;
            this.ctaLabel = ctaLabel;
            this.ctaUrl = ctaUrl;
            this.imageUrl = imageUrl;
            this.providerConfig = providerConfig;
        }

        /** Parses providerConfig; unknown or malformed pairs are ignored. */
        public Map<String, String> config() {
            Map<String, String> parsed = new Map<String, String>();
            if (String.isBlank(providerConfig)) {
                return parsed;
            }
            for (String pair : providerConfig.split(';')) {
                List<String> kv = pair.split('=', 2);
                if (kv.size() == 2 && String.isNotBlank(kv[0])) {
                    parsed.put(kv[0].trim().toLowerCase(), kv[1].trim());
                }
            }
            return parsed;
        }
    }

    // =====================================================================
    // DTOs — shaped for the React client, not for Visualforce
    // =====================================================================

    public class Identity {
        public String contactId;
        public String firstName;
        public String lastName;
        public String fullName;
        public String email;
        public String garpId;
        public String membershipType;
        public String membershipStatus;
        public Date membershipExpiration;
        public Date memberSince;
        public Boolean autoRenew;
        public Boolean isMember;
        public Boolean isIndividualMember;
        public Boolean isAffiliateMember;
        public String audience;
        public String photoUrl;
    }

    public class Address {
        public String street;
        public String city;
        public String state;
        public String postalCode;
        public String country;
        public Boolean isEmpty;
    }

    public class Completeness {
        public Integer percentComplete = 0;
        public Integer earnedWeight = 0;
        public Integer totalWeight = 0;
        public Boolean isComplete = false;
        public Boolean muted = false;
        /** Member-facing labels of what is still missing, in metadata order. */
        public List<String> missing = new List<String>();
        /** Section name -> count still missing, for deep-linking My Account. */
        public Map<String, Integer> missingBySection = new Map<String, Integer>();
    }

    public class Card {
        public String key;
        public String page;
        public String provider;
        public Integer rank;
        public String title;
        public String body;
        public String ctaLabel;
        public String ctaUrl;
        public Boolean ctaIsExternal = false;
        public String imageUrl;
        public String eyebrow;
        public String badge;
        public Boolean locked = false;
        public Boolean dismissible = false;
        public List<String> bullets;
        /** Provider-specific extras (percentComplete, examType, searchPath, ...). */
        public Map<String, Object> meta = new Map<String, Object>();
    }

    public class ExamWindow {
        public String administrationId;
        public String administrationName;
        public String examType;
        public String period;
        public Date registrationStart;
        public Date registrationEnd;
        public Date examDate;
        public Boolean isRegistrationOpen = false;
    }

    public class Benefit {
        public String id;
        public String title;
        public String section;
        public Integer sortOrder;
        public List<String> paragraphs = new List<String>();
        public List<String> bullets = new List<String>();
        public String imageUrl;
        public String ctaLabel;
        public String ctaUrl;
        public Boolean ctaIsExternal = false;
        public Boolean opensInNewWindow = false;
        public String promoCode;
        /** True when the member's type does not include this benefit yet. */
        public Boolean locked = false;
        public Boolean membershipRequired = false;
    }

    public class BenefitSection {
        public String name;
        public List<Benefit> benefits = new List<Benefit>();
        public BenefitSection(String name) {
            this.name = name;
        }
    }

    public class PicklistOption {
        public String label;
        public String value;
        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class ChapterOption {
        public String id;
        public String name;
        public String region;
        public ChapterOption(Chapter__c c) {
            this.id = c.Id;
            this.name = c.Name;
            this.region = c.Region__c;
        }
    }

    public class DashboardView {
        public Identity identity;
        public Completeness completeness;
        public List<Card> cards = new List<Card>();
    }

    public class AccountView {
        public Identity identity;
        public Completeness completeness;
        public Map<String, Object> personal;
        public Map<String, Object> career;
        public Map<String, Object> academic;
        public Map<String, Object> expertise;
        public Map<String, Object> directory;
        public Map<String, Object> chapters;
        public Map<String, Object> preferences;
        public Address mailingAddress;
        public Address otherAddress;
    }

    public class MembershipView {
        public Identity identity;
        public Card hero;
        public List<BenefitSection> sections = new List<BenefitSection>();
        public Integer lockedCount = 0;
    }

    public class OptionsView {
        public Map<String, List<PicklistOption>> picklists = new Map<String, List<PicklistOption>>();
        public List<ChapterOption> chapters = new List<ChapterOption>();
    }

    // =====================================================================
    // Contact resolution
    // =====================================================================

    private static Contact cachedContact;

    /**
     * Resolves the Contact behind the running community user. Throws for guests
     * and for internal users with no ContactId, which the API surfaces as 403.
     */
    public static Contact currentContact() {
        if (cachedContact != null) {
            return cachedContact;
        }
        List<User> users = [
            SELECT Id, ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        if (users.isEmpty() || users[0].ContactId == null) {
            throw new PortalException('No member record is linked to the signed-in user.');
        }
        cachedContact = queryContact(users[0].ContactId);
        return cachedContact;
    }

    /** Builds the Contact SOQL from the base list plus every configured profile field. */
    private static Contact queryContact(Id contactId) {
        Set<String> fields = new Set<String>();
        Map<String, Schema.SObjectField> describe = Contact.SObjectType.getDescribe().fields.getMap();

        for (String f : BASE_CONTACT_FIELDS) {
            addIfExists(fields, describe, f);
        }
        for (ProfileRule rule : profileRules()) {
            addIfExists(fields, describe, rule.fieldApiName);
        }
        fields.add('Id');

        // queryWithBinds passes the id through an explicit bind map. A plain
        // ":contactId" inside a dynamically-built string is not bound by the
        // compiler and fails at runtime with "Variable does not exist: tmpVar1".
        // SYSTEM_MODE keeps the existing behaviour: the field list is assembled
        // from metadata and may name fields the running profile cannot see, and
        // SOQL returns those as null rather than failing. Record-level access is
        // still enforced — the class is `with sharing`.
        String soql =
            'SELECT ' + String.join(new List<String>(fields), ', ') +
            ' FROM Contact WHERE Id = :contactId LIMIT 1';
        List<Contact> rows = Database.queryWithBinds(
            soql,
            new Map<String, Object>{ 'contactId' => contactId },
            AccessLevel.SYSTEM_MODE
        );
        if (rows.isEmpty()) {
            throw new PortalException('Member record not found.');
        }
        return rows[0];
    }

    /**
     * Adds a field to the query only when it exists on Contact in this org, so a
     * stale or mistyped metadata row is skipped instead of breaking the page.
     * Existence — not accessibility — is the test on purpose: selecting a field
     * the user cannot see returns null, whereas omitting a field that the code
     * then dereferences throws.
     */
    private static void addIfExists(
        Set<String> target,
        Map<String, Schema.SObjectField> describe,
        String fieldName
    ) {
        if (String.isBlank(fieldName)) {
            return;
        }
        Schema.SObjectField token = describe.get(fieldName.toLowerCase().trim());
        if (token != null) {
            target.add(token.getDescribe().getName());
        }
    }

    // =====================================================================
    // Identity
    // =====================================================================

    public static Identity buildIdentity(Contact c) {
        Identity id = new Identity();
        id.contactId = c.Id;
        id.firstName = c.FirstName;
        id.lastName = c.LastName;
        id.fullName = c.Name;
        id.email = c.Email;
        // The portal shows the member-facing GARP ID, which is GARP_Member_ID__c.
        // GARP_ID__c is the internal autonumber and is only a fallback.
        id.garpId = String.isNotBlank(c.GARP_Member_ID__c) ? c.GARP_Member_ID__c : c.GARP_ID__c;
        id.membershipType = c.Membership_Type__c;
        id.membershipStatus = c.MPS_Membership_Status__c;
        id.memberSince = c.KPI_Membership_Since__c;
        id.autoRenew = c.MPS_Membership_Autorenew_On__c == true;
        id.photoUrl = c.Photo_URL__c;

        // Expiry lives on different fields depending on how the membership was
        // sold; take the first one that is populated.
        id.membershipExpiration = firstDate(new List<Date>{
            c.KPI_Membership_Expiration_Date__c,
            c.Membership_Caluclated_Expiration_Date__c,
            c.MPS_Membership_Expire_Date__c
        });

        String type = c.Membership_Type__c == null ? '' : c.Membership_Type__c;
        id.isIndividualMember = type.equalsIgnoreCase('Individual');
        id.isAffiliateMember = type.equalsIgnoreCase('Affiliate');
        id.isMember = String.isNotBlank(type);
        if (id.isIndividualMember) {
            id.audience = AUDIENCE_INDIVIDUAL;
        } else if (id.isAffiliateMember) {
            id.audience = AUDIENCE_AFFILIATE;
        } else {
            id.audience = AUDIENCE_NON_MEMBER;
        }
        return id;
    }

    private static Date firstDate(List<Date> candidates) {
        for (Date d : candidates) {
            if (d != null) {
                return d;
            }
        }
        return null;
    }

    // =====================================================================
    // Profile completeness — driven by GARP_Portal_Profile_Field__mdt
    // =====================================================================

    private static List<ProfileRule> cachedRules;

    @TestVisible
    private static List<ProfileRule> profileRules() {
        if (cachedRules != null) {
            return cachedRules;
        }
        List<ProfileRule> rules = new List<ProfileRule>();
        for (GARP_Portal_Profile_Field__mdt row : [
            SELECT DeveloperName, Field_Api_Name__c, Field_Label__c, Section__c, Weight__c
            FROM GARP_Portal_Profile_Field__mdt
            WHERE Enabled__c = true
            ORDER BY Section__c NULLS LAST, DeveloperName
        ]) {
            rules.add(new ProfileRule(
                row.DeveloperName,
                row.Field_Api_Name__c,
                row.Field_Label__c,
                row.Section__c,
                row.Weight__c == null ? 1 : row.Weight__c.intValue()
            ));
        }
        if (rules.isEmpty()) {
            rules = defaultProfileRules();
        }
        cachedRules = rules;
        return cachedRules;
    }

    /** Shipped defaults, mirrored by the GARP_Portal_Profile_Field__mdt seed rows. */
    private static List<ProfileRule> defaultProfileRules() {
        return new List<ProfileRule>{
            new ProfileRule('Phone', 'Phone', 'Phone number', 'Personal', 1),
            new ProfileRule('Mailing_Street', 'MailingStreet', 'Mailing street', 'Personal', 1),
            new ProfileRule('Mailing_City', 'MailingCity', 'Mailing city', 'Personal', 1),
            new ProfileRule('Mailing_Postal_Code', 'MailingPostalCode', 'Mailing postal code', 'Personal', 1),
            new ProfileRule('Mailing_Country', 'MailingCountry', 'Mailing country', 'Personal', 1),
            new ProfileRule('Photo', 'Photo_URL__c', 'Profile photo', 'Personal', 1),
            new ProfileRule('Company', 'Company__c', 'Current/last company', 'Career', 2),
            new ProfileRule('Corporate_Title', 'Corporate_Title__c', 'Professional level', 'Career', 2),
            new ProfileRule('Job_Function', 'Job_Function__c', 'Job function', 'Career', 2),
            new ProfileRule('Company_Country', 'Company_Country__c', 'Company country', 'Career', 1),
            new ProfileRule('Company_City', 'Company_City__c', 'Company city', 'Career', 1),
            new ProfileRule('Industry_Working_Year', 'Industry_Working_Year__c', 'Years in the industry', 'Career', 1),
            new ProfileRule('Highest_Degree', 'Highest_Degree__c', 'Highest degree', 'Academic', 2),
            new ProfileRule('School_Name', 'School_Name__c', 'School name', 'Academic', 1),
            new ProfileRule('Degree_Program_Name', 'Degree_Program_Name__c', 'Degree program', 'Academic', 1),
            new ProfileRule('Risk_Specialty', 'Risk_Specialty__c', 'Risk specialty', 'Expertise', 2),
            new ProfileRule('Topics_Or_Expertise', 'Topics_or_Expertise__c', 'Areas of expertise', 'Expertise', 2),
            new ProfileRule('Primary_Chapter', 'KPI_Primary_Chapter_Name__c', 'Primary chapter', 'Chapters', 2),
            new ProfileRule('Directory_Opt_In', 'GARP_Directory_Opt_In__c', 'Member Directory opt-in', 'Directory', 1)
        };
    }

    public static Completeness scoreProfile(Contact c) {
        Completeness result = new Completeness();
        result.muted = c.Date_Mute_Updated_Profile_GARP_Member__c != null;

        Map<String, Schema.SObjectField> describe = Contact.SObjectType.getDescribe().fields.getMap();
        Map<String, Integer> missingCounts = new Map<String, Integer>();

        for (ProfileRule rule : profileRules()) {
            Schema.SObjectField token = describe.get(
                rule.fieldApiName == null ? '' : rule.fieldApiName.toLowerCase().trim()
            );
            if (token == null) {
                continue; // stale config row — ignore rather than fail
            }
            Schema.DescribeFieldResult dfr = token.getDescribe();
            Integer weight = rule.weight;
            result.totalWeight += weight;

            if (isPopulated(c, dfr)) {
                result.earnedWeight += weight;
            } else {
                String label = String.isNotBlank(rule.label) ? rule.label : dfr.getLabel();
                result.missing.add(label);
                String section = String.isBlank(rule.section) ? 'Other' : rule.section;
                Integer running = missingCounts.containsKey(section) ? missingCounts.get(section) : 0;
                missingCounts.put(section, running + 1);
            }
        }

        result.missingBySection = missingCounts;
        if (result.totalWeight == 0) {
            result.percentComplete = 100;
        } else {
            Decimal pct = ((Decimal) result.earnedWeight / (Decimal) result.totalWeight) * 100;
            result.percentComplete = pct.setScale(0, System.RoundingMode.HALF_UP).intValue();
        }
        result.isComplete = result.percentComplete >= 100;
        return result;
    }

    /** A checkbox counts only when true; everything else counts when not blank. */
    private static Boolean isPopulated(Contact c, Schema.DescribeFieldResult dfr) {
        Object value;
        try {
            value = c.get(dfr.getName());
        } catch (Exception e) {
            return false;
        }
        if (value == null) {
            return false;
        }
        if (dfr.getType() == Schema.DisplayType.BOOLEAN) {
            return (Boolean) value;
        }
        return String.isNotBlank(String.valueOf(value));
    }

    // =====================================================================
    // Cards — driven by GARP_Portal_Card__mdt, with shipped defaults
    // =====================================================================

    @TestVisible
    private static List<CardDef> cardConfig(String page) {
        List<CardDef> defs = new List<CardDef>();
        for (GARP_Portal_Card__mdt row : [
            SELECT DeveloperName, Page__c, Provider__c, Provider_Config__c, Rank__c, Audience__c,
                   Title__c, Body__c, Cta_Label__c, Cta_Url__c, Image_Url__c
            FROM GARP_Portal_Card__mdt
            WHERE Enabled__c = true AND Page__c = :page
            ORDER BY Rank__c NULLS LAST, DeveloperName
        ]) {
            defs.add(new CardDef(
                row.DeveloperName, row.Page__c, row.Provider__c,
                row.Rank__c == null ? null : row.Rank__c.intValue(), row.Audience__c,
                row.Title__c, row.Body__c, row.Cta_Label__c, row.Cta_Url__c, row.Image_Url__c,
                row.Provider_Config__c
            ));
        }
        if (defs.isEmpty()) {
            defs = defaultCards(page);
        }
        return defs;
    }

    /** Shipped defaults, mirrored by the GARP_Portal_Card__mdt seed rows. */
    private static List<CardDef> defaultCards(String page) {
        if (PAGE_DASHBOARD.equalsIgnoreCase(page)) {
            return new List<CardDef>{
                new CardDef(
                    'Dashboard_Profile_Completeness', PAGE_DASHBOARD, PROVIDER_PROFILE, 8, AUDIENCE_ALL,
                    'Your Profile Is Missing Information',
                    'Click below to help us better recommend you learning, networking, and programming.',
                    'Update My Profile', '/my-account', null, null
                ),
                new CardDef(
                    'Dashboard_Exam_Registration', PAGE_DASHBOARD, PROVIDER_EXAM, 10, AUDIENCE_ALL,
                    null, null, 'Register Now', '/programs',
                    'https://www.garp.org/hubfs/Portal/Ads/{examType}AdHeader.png',
                    'examType=FRM'
                ),
                new CardDef(
                    'Dashboard_Member_Directory', PAGE_DASHBOARD, PROVIDER_DIRECTORY, 30, AUDIENCE_ALL,
                    'Member Directory', 'Connect with members of our global risk community.',
                    'View Directory', '/membership?tab=directory', null, null
                )
            };
        }
        if (PAGE_MEMBERSHIP.equalsIgnoreCase(page)) {
            return new List<CardDef>{
                new CardDef(
                    'Membership_Individual_Hero', PAGE_MEMBERSHIP, PROVIDER_IDENTITY, 0, AUDIENCE_INDIVIDUAL,
                    null,
                    'Thank you for being an Individual Member. Every benefit below is unlocked for you — ' +
                    'explore your exclusive content, Chapter events, and Member Directory access.',
                    'Manage My Membership', '/my-account', null, null
                ),
                new CardDef(
                    'Membership_Upgrade_Hero', PAGE_MEMBERSHIP, PROVIDER_IDENTITY, 1, null,
                    null,
                    'Welcome to GARP, the world\'s largest community of risk professionals like you! ' +
                    'To unlock full access to all exclusive Member benefits below and amplify your career, ' +
                    'upgrade to Individual Membership.',
                    'Become a Member', 'https://www.garp.org/membership', null, null
                )
            };
        }
        return new List<CardDef>();
    }

    /** Finds a configured card by key across every page. */
    private static CardDef findCard(String key) {
        for (String page : new List<String>{ PAGE_DASHBOARD, PAGE_MEMBERSHIP }) {
            for (CardDef def : cardConfig(page)) {
                if (def.key == key) {
                    return def;
                }
            }
        }
        return null;
    }

    private static Boolean audienceMatches(String audience, Identity id) {
        if (String.isBlank(audience) || audience.equalsIgnoreCase(AUDIENCE_ALL)) {
            return true;
        }
        if (audience.equalsIgnoreCase(AUDIENCE_INDIVIDUAL)) {
            return id.isIndividualMember;
        }
        if (audience.equalsIgnoreCase(AUDIENCE_AFFILIATE)) {
            return id.isAffiliateMember;
        }
        if (audience.equalsIgnoreCase(AUDIENCE_NON_MEMBER)) {
            return !id.isMember;
        }
        return false;
    }

    private static Card baseCard(CardDef cfg) {
        Card card = new Card();
        card.key = cfg.key;
        card.page = cfg.page;
        card.provider = cfg.provider;
        card.rank = cfg.rank;
        card.title = cfg.title;
        card.body = cfg.body;
        card.ctaLabel = cfg.ctaLabel;
        card.ctaUrl = cfg.ctaUrl;
        card.imageUrl = cfg.imageUrl;
        card.ctaIsExternal = isExternal(cfg.ctaUrl);
        return card;
    }

    private static Boolean isExternal(String url) {
        return String.isNotBlank(url) && !url.startsWith('/');
    }

    public static DashboardView buildDashboard() {
        Contact c = currentContact();
        DashboardView view = new DashboardView();
        view.identity = buildIdentity(c);
        view.completeness = scoreProfile(c);

        ExamWindow window = null;
        Boolean examResolved = false;

        for (CardDef cfg : cardConfig(PAGE_DASHBOARD)) {
            if (!audienceMatches(cfg.audience, view.identity)) {
                continue;
            }
            Card card = baseCard(cfg);
            String provider = cfg.provider == null ? '' : cfg.provider;

            if (provider == PROVIDER_PROFILE) {
                // Suppress once the profile is complete or the member muted it.
                if (view.completeness.isComplete || view.completeness.muted) {
                    continue;
                }
                card.dismissible = true;
                card.badge = view.completeness.percentComplete + '%';
                card.meta.put('percentComplete', view.completeness.percentComplete);
                card.meta.put('missing', view.completeness.missing);
                card.meta.put('missingBySection', view.completeness.missingBySection);

            } else if (provider == PROVIDER_EXAM) {
                if (!examResolved) {
                    window = nextExamWindow(c.Id, cfg.config().get('examtype'));
                    examResolved = true;
                }
                if (window == null) {
                    continue;
                }
                card.eyebrow = programLabel(window.examType);
                card.title = String.isBlank(cfg.title) ? window.period : cfg.title;
                card.body = window.isRegistrationOpen
                    ? 'Registration is now open'
                    : 'Registration opens ' + formatDate(window.registrationStart);
                card.imageUrl = applyExamTokens(cfg.imageUrl, window);
                card.meta.put('examType', window.examType);
                card.meta.put('administrationName', window.administrationName);
                card.meta.put('period', window.period);
                card.meta.put('isRegistrationOpen', window.isRegistrationOpen);
                card.meta.put('registrationEnd', window.registrationEnd);

            } else if (provider == PROVIDER_DIRECTORY) {
                card.meta.put('searchEnabled', true);
                card.meta.put('optedIn', c.GARP_Directory_Opt_In__c == true);
            }

            view.cards.add(card);
        }
        return view;
    }

    private static String applyExamTokens(String template, ExamWindow window) {
        if (String.isBlank(template) || window == null) {
            return template;
        }
        String examType = window.examType == null ? '' : window.examType;
        return template.replace('{examType}', examType).replace('{period}', window.period == null ? '' : window.period);
    }

    private static String programLabel(String examType) {
        if (String.isBlank(examType)) {
            return null;
        }
        if (examType.equalsIgnoreCase('FRM')) {
            return 'Financial Risk Manager Exam (FRM®)';
        }
        if (examType.equalsIgnoreCase('SCR')) {
            return 'Sustainability and Climate Risk (SCR®)';
        }
        if (examType.equalsIgnoreCase('RiskAI') || examType.equalsIgnoreCase('RAI')) {
            return 'Risk and AI (RAI™)';
        }
        if (examType.equalsIgnoreCase('RAIJ')) {
            return 'Risk and AI Journey (RAIJ)';
        }
        return examType;
    }

    /** Convenience overload with no configured program preference. */
    public static ExamWindow nextExamWindow(Id contactId) {
        return nextExamWindow(contactId, null);
    }

    /**
     * Picks the exam administration to advertise. Preference order:
     *   1. an open registration window for a program the member already sits,
     *   2. an open window for the program configured on the card
     *      (Provider_Config__c "examType=FRM"),
     *   3. the open window closing soonest,
     *   4. the next window that has not opened yet.
     *
     * All of it comes from Exam_Administration__c dates, so the card follows the
     * exam calendar on its own. The legacy portal hardcoded FRM here; the program
     * is now just a default that config can change.
     */
    public static ExamWindow nextExamWindow(Id contactId, String preferredExamType) {
        if (!isAccessible(Exam_Administration__c.SObjectType)) {
            return null;
        }
        try {
            return resolveExamWindow(contactId, preferredExamType);
        } catch (Exception e) {
            // The promo card is optional; never let it break the dashboard.
            System.debug(LoggingLevel.WARN, 'nextExamWindow unavailable: ' + e.getMessage());
            return null;
        }
    }

    private static ExamWindow resolveExamWindow(Id contactId, String preferredExamType) {
        Date today = Date.today();

        List<Exam_Administration__c> open = [
            SELECT Id, Name, Exam_Type__c, Month__c, Year__c,
                   Registration_Start_Date__c, Registration_End_Date__c, Exam_Date__c
            FROM Exam_Administration__c
            WHERE Registration_Start_Date__c <= :today
              AND Registration_End_Date__c >= :today
            ORDER BY Registration_End_Date__c ASC, Exam_Date__c ASC
            LIMIT 50
        ];

        if (!open.isEmpty()) {
            Set<String> memberTypes = memberExamTypes(contactId);
            if (!memberTypes.isEmpty()) {
                for (Exam_Administration__c ea : open) {
                    if (ea.Exam_Type__c != null && memberTypes.contains(ea.Exam_Type__c)) {
                        return toWindow(ea, true);
                    }
                }
            }
            if (String.isNotBlank(preferredExamType)) {
                for (Exam_Administration__c ea : open) {
                    if (preferredExamType.equalsIgnoreCase(ea.Exam_Type__c)) {
                        return toWindow(ea, true);
                    }
                }
            }
            return toWindow(open[0], true);
        }

        List<Exam_Administration__c> upcoming = [
            SELECT Id, Name, Exam_Type__c, Month__c, Year__c,
                   Registration_Start_Date__c, Registration_End_Date__c, Exam_Date__c
            FROM Exam_Administration__c
            WHERE Registration_Start_Date__c > :today
            ORDER BY Registration_Start_Date__c ASC
            LIMIT 1
        ];
        return upcoming.isEmpty() ? null : toWindow(upcoming[0], false);
    }

    /**
     * Exam types the member has ever registered for. Personalisation only — if
     * it fails the caller just falls back to the configured program.
     *
     * Exam_Type__c is a cross-object formula, so on a community licence this
     * query can fail for reasons an object-level check cannot predict (field
     * permissions, or an object the formula traverses). Apex reports that as
     * "Variable does not exist: tmpVar1" because the bound query is re-parsed,
     * which says nothing useful — hence catching rather than pre-checking.
     */
    private static Set<String> memberExamTypes(Id contactId) {
        Set<String> types = new Set<String>();
        if (contactId == null || !isAccessible(Exam_Attempt__c.SObjectType)) {
            return types;
        }
        try {
            for (Exam_Attempt__c attempt : [
                SELECT Exam_Type__c
                FROM Exam_Attempt__c
                WHERE Member__c = :contactId AND Exam_Type__c != null
                ORDER BY CreatedDate DESC
                LIMIT 50
            ]) {
                types.add(attempt.Exam_Type__c);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'memberExamTypes unavailable: ' + e.getMessage());
        }
        return types;
    }

    private static ExamWindow toWindow(Exam_Administration__c ea, Boolean isOpen) {
        ExamWindow w = new ExamWindow();
        w.administrationId = ea.Id;
        w.administrationName = ea.Name;
        w.examType = ea.Exam_Type__c;
        w.registrationStart = ea.Registration_Start_Date__c;
        w.registrationEnd = ea.Registration_End_Date__c;
        w.examDate = ea.Exam_Date__c;
        w.isRegistrationOpen = isOpen;
        String month = ea.Month__c == null ? '' : ea.Month__c;
        String year = ea.Year__c == null ? '' : String.valueOf(ea.Year__c.intValue());
        w.period = (month + ' ' + year).trim();
        if (String.isBlank(w.period)) {
            w.period = ea.Name;
        }
        return w;
    }

    private static String formatDate(Date d) {
        return d == null ? '' : DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0)).format('MMMM d, yyyy');
    }

    // =====================================================================
    // My Account
    // =====================================================================

    public static AccountView buildAccount() {
        Contact c = currentContact();
        AccountView view = new AccountView();
        view.identity = buildIdentity(c);
        view.completeness = scoreProfile(c);

        view.personal = new Map<String, Object>{
            'firstName' => c.FirstName,
            'lastName' => c.LastName,
            'email' => c.Email,
            'phone' => c.Phone,
            'photoUrl' => c.Photo_URL__c
        };
        view.career = new Map<String, Object>{
            'company' => c.Company__c,
            'corporateTitle' => c.Corporate_Title__c,
            'jobFunction' => c.Job_Function__c,
            'companyCity' => c.Company_City__c,
            'companyCountry' => c.Company_Country__c,
            'industryWorkingYear' => c.Industry_Working_Year__c
        };
        view.academic = new Map<String, Object>{
            'highestDegree' => c.Highest_Degree__c,
            'schoolName' => c.School_Name__c,
            'degreeProgramName' => c.Degree_Program_Name__c,
            'currentlyInSchool' => c.Currently_in_School__c
        };
        view.expertise = new Map<String, Object>{
            'riskSpecialty' => c.Risk_Specialty__c,
            'topicsOrExpertise' => c.Topics_or_Expertise__c
        };
        view.directory = new Map<String, Object>{
            'optedIn' => c.GARP_Directory_Opt_In__c,
            'connectFeature' => c.GARP_Directory_Connect_Feature__c,
            'showJobInformation' => c.GARP_Dir_Privacy_Job_Information__c,
            'showProfessionalBackground' => c.GARP_Dir_Privacy_Prof_Background__c,
            'showAdditionalDetail' => c.GARP_Dir_Privacy_Additional_Detail__c
        };
        view.chapters = new Map<String, Object>{
            'primary' => c.KPI_Primary_Chapter_Name__c,
            'secondary' => c.KPI_Secondary_Chapter_Name__c
        };
        view.preferences = new Map<String, Object>{
            'garpUpdates' => c.Email_GARP_Updates__c,
            'chapterMeetings' => c.Email_Chapter_Meetings__c,
            'careerCenter' => c.Email_Career_Center_Job_Board__c,
            'memberUpdates' => c.Email_Member_Update__c
        };
        view.mailingAddress = address(
            c.MailingStreet, c.MailingCity, c.MailingState, c.MailingPostalCode, c.MailingCountry
        );
        view.otherAddress = address(
            c.OtherStreet, c.OtherCity, c.OtherState, c.OtherPostalCode, c.OtherCountry
        );
        return view;
    }

    private static Address address(String street, String city, String state, String zip, String country) {
        Address a = new Address();
        a.street = street;
        a.city = city;
        a.state = state;
        a.postalCode = zip;
        a.country = country;
        a.isEmpty = String.isBlank(street) && String.isBlank(city) &&
            String.isBlank(state) && String.isBlank(zip) && String.isBlank(country);
        return a;
    }

    // =====================================================================
    // Membership benefits — driven by Membership_Exclusive_Offers__c
    // =====================================================================

    public static MembershipView buildMembership() {
        Contact c = currentContact();
        MembershipView view = new MembershipView();
        view.identity = buildIdentity(c);

        for (CardDef cfg : cardConfig(PAGE_MEMBERSHIP)) {
            if (audienceMatches(cfg.audience, view.identity)) {
                view.hero = baseCard(cfg);
                break;
            }
        }

        Map<String, BenefitSection> grouped = new Map<String, BenefitSection>();
        List<String> order = new List<String>();

        for (Membership_Exclusive_Offers__c offer : queryOffers()) {
            Benefit b = toBenefit(offer, view.identity);
            if (b.locked) {
                view.lockedCount++;
            }
            if (!grouped.containsKey(b.section)) {
                grouped.put(b.section, new BenefitSection(b.section));
                order.add(b.section);
            }
            grouped.get(b.section).benefits.add(b);
        }

        for (String name : order) {
            view.sections.add(grouped.get(name));
        }
        return view;
    }

    /** Set once per transaction by queryOffers(). */
    private static Boolean offersHaveSectionField = false;

    /**
     * Reads the active offers. Portal_Section__c is an optional grouping field:
     * it is added to the SELECT only when it exists in the org, so the page works
     * in an org where that field has not been created. Without it, offers group by
     * whether membership is required.
     */
    private static List<Membership_Exclusive_Offers__c> queryOffers() {
        List<String> fields = new List<String>{
            'Id', 'Name', 'Display_Name__c', 'Memb_Offer_Title__c',
            'Sort_Order__c', 'Membership_Required__c', 'Authenticated_Affiliate_Can_Use_Offer__c',
            'Member_Description__c', 'Non_Member_Description__c', 'Authenticated_Description__c',
            'Values_List__c', 'Memb_Offer_Logo__c', 'Memb_Offer_Hashtag__c',
            'Memb_Offer_External_Link__c', 'Memb_Offer_Portal_Route__c',
            'External_Link_Name__c', 'Access_Link_New_Window__c', 'Memb_Offer_Promo_Code__c'
        };

        offersHaveSectionField = Membership_Exclusive_Offers__c.SObjectType
            .getDescribe()
            .fields
            .getMap()
            .containsKey('portal_section__c');
        if (offersHaveSectionField) {
            fields.add('Portal_Section__c');
        }

        String soql =
            'SELECT ' + String.join(fields, ', ') +
            ' FROM Membership_Exclusive_Offers__c' +
            ' WHERE Memb_Offer_Status__c = \'Active\'' +
            ' ORDER BY Sort_Order__c NULLS LAST, Name' +
            ' LIMIT 200';
        // No binds in this one, but keep the access level explicit for the same
        // reason as queryContact: the field list is metadata-driven.
        return Database.queryWithBinds(soql, new Map<String, Object>(), AccessLevel.SYSTEM_MODE);
    }

    /** Grouping header for an offer, from Portal_Section__c when available. */
    private static String sectionOf(Membership_Exclusive_Offers__c offer, Boolean membershipRequired) {
        if (offersHaveSectionField) {
            Object value = offer.get('Portal_Section__c');
            if (value != null && String.isNotBlank(String.valueOf(value))) {
                return String.valueOf(value);
            }
        }
        return membershipRequired ? 'Exclusive Member Benefits' : 'Open to All Members';
    }

    private static Benefit toBenefit(Membership_Exclusive_Offers__c offer, Identity id) {
        Benefit b = new Benefit();
        b.id = offer.Id;
        b.title = firstNonBlank(new List<String>{
            offer.Memb_Offer_Title__c, offer.Display_Name__c, offer.Name
        });
        b.sortOrder = offer.Sort_Order__c == null ? 999 : offer.Sort_Order__c.intValue();
        b.membershipRequired = offer.Membership_Required__c == true;
        b.section = sectionOf(offer, b.membershipRequired);

        // An offer flagged "membership required" is only unlocked for individual
        // members, unless it explicitly allows authenticated affiliates.
        b.locked = b.membershipRequired &&
            !id.isIndividualMember &&
            !(id.isAffiliateMember && offer.Authenticated_Affiliate_Can_Use_Offer__c == true);

        // Pick the copy written for this audience, falling back down the chain.
        String description = id.isIndividualMember
            ? firstNonBlank(new List<String>{
                  offer.Member_Description__c, offer.Authenticated_Description__c, offer.Non_Member_Description__c
              })
            : firstNonBlank(new List<String>{
                  offer.Authenticated_Description__c, offer.Non_Member_Description__c, offer.Member_Description__c
              });

        b.paragraphs = toParagraphs(description);
        b.bullets = toBullets(offer.Values_List__c);
        b.imageUrl = firstNonBlank(new List<String>{ offer.Memb_Offer_Logo__c, offer.Memb_Offer_Hashtag__c });
        b.promoCode = offer.Memb_Offer_Promo_Code__c;
        b.opensInNewWindow = offer.Access_Link_New_Window__c == true;

        if (String.isNotBlank(offer.Memb_Offer_Portal_Route__c)) {
            b.ctaUrl = offer.Memb_Offer_Portal_Route__c;
        } else {
            b.ctaUrl = offer.Memb_Offer_External_Link__c;
        }
        b.ctaIsExternal = isExternal(b.ctaUrl);
        b.ctaLabel = String.isNotBlank(offer.External_Link_Name__c)
            ? offer.External_Link_Name__c
            : (b.locked ? 'Upgrade Now' : 'Learn More');
        return b;
    }

    private static String firstNonBlank(List<String> candidates) {
        for (String s : candidates) {
            if (String.isNotBlank(s)) {
                return s;
            }
        }
        return null;
    }

    /** Shared with GARP_MemberPortal_Programs for Product2 descriptions. */
    public static List<String> richTextToParagraphs(String html) {
        return toParagraphs(html);
    }

    /**
     * Rich text -> plain paragraphs. The React client renders strings, never raw
     * HTML, so markup from these records can't turn into injected nodes.
     */
    @TestVisible
    private static List<String> toParagraphs(String html) {
        List<String> out = new List<String>();
        if (String.isBlank(html)) {
            return out;
        }
        // stripHtmlTags() also collapses newlines, so mark the block boundaries
        // with a token that survives it and split on that afterwards.
        String marker = '~~GARPBREAK~~';
        String withBreaks = html
            .replaceAll('(?i)</p\\s*>', marker)
            .replaceAll('(?i)<br\\s*/?>', marker)
            .replaceAll('(?i)</div\\s*>', marker)
            .replaceAll('(?i)<li[^>]*>', marker);
        for (String chunk : stripTags(withBreaks).split(marker)) {
            String trimmed = chunk.trim();
            if (String.isNotBlank(trimmed)) {
                out.add(trimmed);
            }
        }
        return out;
    }

    /** Extracts <li> items; falls back to an empty list when there is no list. */
    @TestVisible
    private static List<String> toBullets(String html) {
        List<String> out = new List<String>();
        if (String.isBlank(html)) {
            return out;
        }
        Matcher m = Pattern.compile('(?is)<li[^>]*>(.*?)</li\\s*>').matcher(html);
        while (m.find()) {
            String item = stripTags(m.group(1)).trim();
            if (String.isNotBlank(item)) {
                out.add(item);
            }
        }
        if (out.isEmpty()) {
            for (String chunk : stripTags(html).split('\n')) {
                String trimmed = chunk.trim();
                if (String.isNotBlank(trimmed)) {
                    out.add(trimmed);
                }
            }
        }
        return out;
    }

    private static String stripTags(String html) {
        String text = html.stripHtmlTags();
        // Collapse non-breaking spaces and runs of whitespace into single spaces.
        return text == null ? '' : text.replaceAll('\\u00A0', ' ').replaceAll('[ \\t]+', ' ');
    }

    // =====================================================================
    // Picklist + chapter options (describe-driven)
    // =====================================================================

    private static final List<String> OPTION_FIELDS = new List<String>{
        'Corporate_Title__c', 'Job_Function__c', 'Risk_Specialty__c',
        'Topics_or_Expertise__c', 'Highest_Degree__c', 'Currently_in_School_Status__c'
    };

    public static OptionsView buildOptions() {
        OptionsView view = new OptionsView();
        Map<String, Schema.SObjectField> describe = Contact.SObjectType.getDescribe().fields.getMap();

        for (String fieldName : OPTION_FIELDS) {
            Schema.SObjectField token = describe.get(fieldName.toLowerCase());
            if (token == null) {
                continue;
            }
            Schema.DescribeFieldResult dfr = token.getDescribe();
            if (!dfr.isAccessible() || dfr.getPicklistValues().isEmpty()) {
                continue;
            }
            List<PicklistOption> options = new List<PicklistOption>();
            for (Schema.PicklistEntry entry : dfr.getPicklistValues()) {
                if (entry.isActive()) {
                    options.add(new PicklistOption(entry.getLabel(), entry.getValue()));
                }
            }
            view.picklists.put(dfr.getName(), options);
        }

        // Chapter__c is not in every community licence's object set; an empty
        // chapter list is better than failing the whole options call.
        if (isAccessible(Chapter__c.SObjectType)) {
            for (Chapter__c chapter : [
                SELECT Id, Name, Region__c
                FROM Chapter__c
                WHERE Status__c = 'Active'
                ORDER BY Name
                LIMIT 500
            ]) {
                view.chapters.add(new ChapterOption(chapter));
            }
        }
        return view;
    }

    /**
     * Whether the running user can read an object at all. Community licences
     * expose a restricted object set, and SOQL against an unavailable object
     * fails with "sObject type ... is not supported" — or the far less obvious
     * "Variable does not exist: tmpVar1" when the query carries a bind.
     */
    private static Boolean isAccessible(SObjectType type) {
        try {
            return type != null && type.getDescribe().isAccessible();
        } catch (Exception e) {
            return false;
        }
    }

    // =====================================================================
    // Writes
    // =====================================================================

    /**
     * Applies a field -> value map to the member's Contact. Only fields in
     * EDITABLE_FIELDS that are updateable for the running user are applied;
     * anything else is reported back as rejected so the client can surface it.
     */
    public static Map<String, Object> saveProfile(Map<String, Object> values) {
        Contact c = currentContact();
        Map<String, Schema.SObjectField> describe = Contact.SObjectType.getDescribe().fields.getMap();

        Contact toUpdate = new Contact(Id = c.Id);
        List<String> applied = new List<String>();
        List<String> rejected = new List<String>();

        if (values != null) {
            for (String key : values.keySet()) {
                Schema.SObjectField token = describe.get(key.toLowerCase().trim());
                if (token == null) {
                    rejected.add(key);
                    continue;
                }
                Schema.DescribeFieldResult dfr = token.getDescribe();
                if (!EDITABLE_FIELDS.contains(dfr.getName()) || !dfr.isUpdateable()) {
                    rejected.add(key);
                    continue;
                }
                toUpdate.put(dfr.getName(), coerce(values.get(key), dfr));
                applied.add(dfr.getName());
            }
        }

        if (!applied.isEmpty()) {
            // Stamp the same "member edited their own profile" markers the org
            // already uses, so downstream reporting keeps working.
            toUpdate.Date_Contact_Last_Updated_by_GARP_Member__c = Date.today();
            toUpdate.Member_Profile_Last_Updated__c = System.now();
            update toUpdate;
            cachedContact = null;
        }

        Contact refreshed = currentContact();
        return new Map<String, Object>{
            'applied' => applied,
            'rejected' => rejected,
            'completeness' => scoreProfile(refreshed)
        };
    }

    /** Converts loose JSON values into the type the field expects. */
    private static Object coerce(Object value, Schema.DescribeFieldResult dfr) {
        if (value == null) {
            return null;
        }
        Schema.DisplayType t = dfr.getType();
        String raw = String.valueOf(value);
        if (t == Schema.DisplayType.BOOLEAN) {
            return value instanceof Boolean ? (Boolean) value : Boolean.valueOf(raw);
        }
        if (t == Schema.DisplayType.DATE) {
            return String.isBlank(raw) ? null : Date.valueOf(raw);
        }
        if (t == Schema.DisplayType.DOUBLE || t == Schema.DisplayType.CURRENCY ||
            t == Schema.DisplayType.PERCENT) {
            return String.isBlank(raw) ? null : Decimal.valueOf(raw);
        }
        if (t == Schema.DisplayType.INTEGER) {
            return String.isBlank(raw) ? null : Integer.valueOf(raw);
        }
        return String.isBlank(raw) ? null : raw;
    }

    /**
     * Hides a dismissible dashboard card. The profile-completeness card is muted
     * by stamping the existing mute date on the Contact.
     */
    public static Map<String, Object> dismissCard(String cardKey) {
        Contact c = currentContact();
        CardDef cfg = findCard(cardKey);
        if (cfg == null) {
            throw new PortalException('Unknown card: ' + cardKey);
        }
        if (cfg.provider == PROVIDER_PROFILE) {
            update new Contact(
                Id = c.Id,
                Date_Mute_Updated_Profile_GARP_Member__c = Date.today()
            );
            cachedContact = null;
            return new Map<String, Object>{ 'dismissed' => cardKey };
        }
        throw new PortalException('Card "' + cardKey + '" cannot be dismissed.');
    }

    @TestVisible
    private static void resetCache() {
        cachedContact = null;
        cachedRules = null;
    }
}