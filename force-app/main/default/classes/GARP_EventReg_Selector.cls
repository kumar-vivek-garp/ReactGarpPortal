/**
 * Data-access layer for the optimized event-registration module.
 *
 * Every SOQL query the module's REIMPLEMENTED paths need lives here — one query
 * per object, no queries inside loops, and cross-call results memoized in static
 * maps (transaction scoped) so repeated calls in the same request never re-query.
 *
 * Sharing: `without sharing` intentionally matches the legacy GARP_BC_* classes.
 * Event registration runs for unauthenticated guest users, so tightening to
 * `with sharing`/user-mode here would break guest reads. Keep parity.
 */
public without sharing class GARP_EventReg_Selector {

    // Transaction-scoped cache for the (large, rarely-changing) country config.
    private static Map<String, Country_Code__c> countryCache;

    /* ===================== Event objects ===================== */

    /**
     * Loads an active Event__c by record Id OR Vanity URL — a single query with
     * the field set the confirmation page and registration need.
     */
    public Event__c getEvent(String eventId) {
        if (String.isBlank(eventId)) return null;
        List<Event__c> rows = [
            SELECT Id, Title__c, Description__c, Delivery_Method__c, CurrencyIsoCode,
                   Start_Date__c, End_Date__c, Time_Zone__r.Name,
                   VenueName__c, Address__c, Custom_Location__c, Online_Meeting_URL__c,
                   ON24_URL__c, ON24_Event_Id__c, ON24_API_Key__c,
                   Invite_Only__c, Is_Sponsored_Event__c, Event_Sponsor__c,
                   Event_Sponsor_Policy_URL__c, Vanity_URL__c, Status__c,
                   Content__r.Form__r.Form_Name__c
            FROM Event__c
            WHERE (Id = :eventId OR Vanity_URL__c = :eventId) AND Status__c = 'Active'
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /** Loads an active Chapter_Meeting__c by Id or Vanity URL. */
    public Chapter_Meeting__c getChapterMeeting(String eventId) {
        if (String.isBlank(eventId)) return null;
        List<Chapter_Meeting__c> rows = [
            SELECT Id, Chapter_Meeting_Name__c, Synopsis__c, Delivery_Method__c,
                   Start__c, End__c, Time_Zone__r.Name, Chapter__r.Name,
                   Is_Sponsored__c, Sponsor_Name__c, Vanity_URL__c, Status__c,
                   Virtual_Meeting_URL__c, ON24_URL__c, ON24_Event_Id__c, ON24_API_Key__c,
                   Content__r.Location__c, Content__r.Form__r.Form_Name__c,
                   Chapter_Meeting_Location__r.Name,
                   Chapter_Meeting_Location__r.Address_City__c,
                   Chapter_Meeting_Location__r.Address_Country__c
            FROM Chapter_Meeting__c
            WHERE (Id = :eventId OR Vanity_URL__c = :eventId) AND Status__c = 'Active'
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /** Loads an active Webcast__c by Id or Vanity URL. */
    public Webcast__c getWebcast(String eventId) {
        if (String.isBlank(eventId)) return null;
        List<Webcast__c> rows = [
            SELECT Id, Name, Title__c, Description__c, Short_Description__c,
                   Start_Date__c, End_Date__c, Start_Time__c, End_Time__c, Duration__c,
                   Time_Zone__r.Name, Time_Zone__r.Abbreviation__c,
                   On_Demand_URL__c, EventId__c, X0n24_API_Key__c,
                   Is_Sponsored__c, Sponsor_Name__c, Sponsor_Policy_URL__c,
                   Members_Only__c, Vanity_URL__c, Status__c,
                   Content__r.Form__r.Form_Name__c
            FROM Webcast__c
            WHERE (Id = :eventId OR Vanity_URL__c = :eventId) AND Status__c = 'Active'
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /* ===================== Event registration records ===================== */

    /** Existing registration for an email on an event (RSVP decline path). */
    public Event_Registration__c getRegistrationByEmail(String eventRecId, String userEmail) {
        if (String.isBlank(eventRecId) || String.isBlank(userEmail)) return null;
        List<Event_Registration__c> rows = [
            SELECT Id, Contact__c, Event__c, Member_Email__c, Status__c
            FROM Event_Registration__c
            WHERE Event__c = :eventRecId AND Member_Email__c = :userEmail
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /** Minimal event lookup used to confirm invite-only status before RSVP decline. */
    public Event__c getEventForRsvp(String eventId) {
        if (String.isBlank(eventId)) return null;
        List<Event__c> rows = [
            SELECT Id, Name, Invite_Only__c
            FROM Event__c
            WHERE Id = :eventId
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /* ===================== Country configuration ===================== */

    /**
     * All country configuration, keyed by Country_Code__c.Country__c (the value
     * the client sends as address.country). Memoized so multiple address checks
     * in one transaction issue a single query.
     */
    public Map<String, Country_Code__c> getCountryCodesMap() {
        if (countryCache != null) return countryCache;
        countryCache = new Map<String, Country_Code__c>();
        for (Country_Code__c c : [
            SELECT Id, Name, Country__c, LetterCode__c, VAT__c, VAT_Product_Code__c, Compliance__c,
                   Is_Billing_Allowed__c, Is_Shipping_Allowed__c,
                   Is_Credit_Card_Allowed__c, Is_Wire_Allowed__c, Is_Check_Allowed__c, Is_ACH_Allowed__c,
                   Postal_Code_Required__c, Provence_Required__c,
                   (SELECT Id, Name, Code__c FROM Provinces__r ORDER BY Name)
            FROM Country_Code__c
        ]) {
            if (String.isNotBlank(c.Country__c)) {
                countryCache.put(c.Country__c, c);
            }
        }
        return countryCache;
    }

    /* ===================== Customer / auth ===================== */

    /** Existing contacts for an email (used by verify-customer + order creation). */
    public List<Contact> getContactsByEmail(String email) {
        if (String.isBlank(email)) return new List<Contact>();
        return [
            SELECT Id, FirstName, LastName, Email, AccountId, RecordTypeId, GARP_ID_New__c, DO_NOT_FIRE__c
            FROM Contact
            WHERE Email = :email
        ];
    }

    /** Whether a portal User exists for this email. */
    public Boolean userExistsForEmail(String email) {
        if (String.isBlank(email)) return false;
        return ![SELECT Id FROM User WHERE Email = :email].isEmpty();
    }

    /* ===================== Forms / session ===================== */

    public Form__c getFormByName(String formName) {
        if (String.isBlank(formName)) return null;
        List<Form__c> rows = [SELECT Id, Name, Form_Name__c FROM Form__c WHERE Form_Name__c = :formName LIMIT 1];
        return rows.isEmpty() ? null : rows[0];
    }

    public Form_Data__c getFormData(String sessionId) {
        if (String.isBlank(sessionId)) return null;
        List<Form_Data__c> rows = [
            SELECT Id, Status__c, Email__c, First_Name__c, Last_Name__c, Company__c,
                   UTM_Campaign__c, UTM_Content__c, UTM_Medium__c, UTM_Source__c, UTM_Term__c, Track_CTA__c
            FROM Form_Data__c WHERE Id = :sessionId LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /* ===================== Event pricing ===================== */

    /** Active event rates (member/non-member/bundle) for an event, by date window. */
    public List<Event_Rate__c> getEventRates(String eventRecId) {
        if (String.isBlank(eventRecId)) return new List<Event_Rate__c>();
        return [
            SELECT Id, Name, Start_Date__c, End_Date__c,
                   Member_Rate__c, Non_Member_Rate__c,
                   Bundle_Member_Rate__c, Bundle_Non_Member_Rate__c,
                   Product_Member_Code__r.ProductCode, Product_Member_Code__r.GL_Code__c,
                   Product_Non_Member_Code__r.ProductCode, Product_Non_Member_Code__r.GL_Code__c,
                   Product_Bundle_Member__r.ProductCode, Product_Bundle_Member__r.GL_Code__c,
                   Product_Bundle_Non_Member__r.ProductCode, Product_Bundle_Non_Member__r.GL_Code__c,
                   Event__r.VAT_Product_Code__c
            FROM Event_Rate__c
            WHERE Event__c = :eventRecId AND Start_Date__c <= TODAY AND End_Date__c >= TODAY
        ];
    }

    /** Event promo/discount codes with their product scope. */
    public List<Event_Discount__c> getEventDiscounts(String eventRecId) {
        if (String.isBlank(eventRecId)) return new List<Event_Discount__c>();
        return [
            SELECT Id, Name, Discount_Code__c, Discount_To_Fixed_Price__c, Fixed_Amount_Discount__c,
                   Fixed_Percentage_Discount__c, Start_Date__c, End_Date__c, Max_Allowed_Usage__c,
                   (SELECT Id, Product__r.ProductCode FROM Product_Discounts__r)
            FROM Event_Discount__c
            WHERE Event__c = :eventRecId
        ];
    }

    /**
     * The GARP price book that holds prices for each supported event currency.
     * The default (USD) book carries no currency suffix for historical reasons.
     */
    private static final Map<String, String> CURRENCY_PRICEBOOK = new Map<String, String>{
        'USD' => 'GARP 2015/2016',
        'EUR' => 'GARP Price Book EUR',
        'GBP' => 'GARP Price Book GBP'
    };

    /** The GARP price-book name to use for a given event currency (USD default). */
    public static String pricebookNameForCurrency(String currencyIso) {
        String iso = String.isBlank(currencyIso) ? 'USD' : currencyIso.toUpperCase();
        return CURRENCY_PRICEBOOK.containsKey(iso) ? CURRENCY_PRICEBOOK.get(iso) : 'GARP 2015/2016';
    }

    /** Pricebook entries for the given product codes, keyed by 'CODE:GLCODE' (USD). */
    public Map<String, PricebookEntry> getPricebookEntriesByCodes(Set<String> codes) {
        return getPricebookEntriesByCodes(codes, null);
    }

    /**
     * Pricebook entries for the given product codes in the event's currency, keyed by
     * 'CODE:GLCODE'. Entries are restricted to the event currency so an Opportunity (and
     * its line items) stay single-currency, and the currency's designated GARP price book
     * is preferred over any other active entry in that currency (test/legacy context).
     */
    public Map<String, PricebookEntry> getPricebookEntriesByCodes(Set<String> codes, String currencyIso) {
        Map<String, PricebookEntry> result = new Map<String, PricebookEntry>();
        if (codes == null || codes.isEmpty()) return result;
        String iso = String.isBlank(currencyIso) ? 'USD' : currencyIso.toUpperCase();
        String targetBook = pricebookNameForCurrency(iso);
        for (PricebookEntry pbe : [
            SELECT Id, UnitPrice, Product2Id, Pricebook2.Name, CurrencyIsoCode,
                   Product2.ProductCode, Product2.GL_Code__c, Product2.Family, Product2.Name,
                   Product2.Tax_Rate__c, Product2.Is_VAT_Tax__c
            FROM PricebookEntry
            WHERE Product2.ProductCode IN :codes AND IsActive = true AND CurrencyIsoCode = :iso
        ]) {
            // Prefer the currency's GARP price book; fall back to any active entry
            // in the same currency (test context).
            String key = pbe.Product2.ProductCode + ':' + pbe.Product2.GL_Code__c;
            if (!result.containsKey(key) || pbe.Pricebook2.Name == targetBook) {
                result.put(key, pbe);
            }
        }
        return result;
    }

    /* ===================== Order / payment status ===================== */

    public Opportunity getOrderForStatus(String orderId) {
        if (String.isBlank(orderId)) return null;
        List<Opportunity> rows = [
            SELECT Id, AccountId, Amount, StageName, Alternate_Method_of_Payment__c, Rollback_Reason__c, CreatedDate,
                   (SELECT Id, ChargentOrders__Response_Status__c, ChargentOrders__Payment_Method__c
                    FROM Transactions__r ORDER BY CreatedDate DESC)
            FROM Opportunity WHERE Id = :orderId LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    public List<Event_Registration__c> getEventRegistrationsByOpp(String orderId) {
        if (String.isBlank(orderId)) return new List<Event_Registration__c>();
        return [
            SELECT Id, Status__c, Event__r.Is_Pay_For_Event__c, Opportunity__r.StageName
            FROM Event_Registration__c WHERE Opportunity__c = :orderId
        ];
    }

    /* ===================== Load payload ===================== */

    /** Full event record for the screen-load payload (by Id or Vanity URL). */
    public Event__c getEventForLoad(String eventId) {
        if (String.isBlank(eventId)) return null;
        List<Event__c> rows = [
            SELECT Id, CurrencyIsoCode, Delivery_Method__c, ON24_Event_Id__c, ON24_URL__c, ON24_API_Key__c, VenueName__c, Address__c,
                   Custom_Location__c, Invite_Only__c, Online_Meeting_URL__c, Professional_Details_Request_Title__c,
                   Professional_Details_Required__c, Start_Date__c, End_Date__c, Content__r.Form__r.Form_Name__c, Title__c,
                   Description__c, Is_Sponsored_Event__c, Event_Sponsor__c, Event_Sponsor_Policy_URL__c, Can_Pay_By_wire__c,
                   Last_Date_for_Wire_Check_Registration__c, Last_Date_For_Registration__c, RSVP_Copy__c, Max_Capacity_Met__c,
                   Maximum_number_of_Event_Registrations__c, Total_Event_Registration__c, RSVP_Waitlist_Copy__c,
                   Time_Zone__r.Name, VAT_Product_Code__c, RSVP_Activity_Ask_Diet_Restrictions__c, RSVP_Activity_Details__c,
                   RSVP_Activity_Name__c, RSVP_Activity_Question__c, RSVP_Activity_Start_Date_Time__c,
                   RSVP_Activity_End_Date_Time__c, RSVP_Activity_Location__c, RSVP_Activity_Online_Meeting_URL__c,
                   Event_Question_Title__c, Event_Question_Detail__c, Parent_Event__c, Parent_Event__r.Id,
                   (SELECT Id, Name, Start_Date__c, End_Date__c, Member_Rate__c, Non_Member_Rate__c
                    FROM Event_Rates__r WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY),
                   (SELECT Id FROM Events__r WHERE Status__c = 'Active')
            FROM Event__c
            WHERE (Id = :eventId OR Vanity_URL__c = :eventId) AND Status__c = 'Active'
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /** Running user (for isAuthenticated + authenticated member context). */
    public User getRunningUser() {
        List<User> rows = [
            SELECT Id, ContactId, Contact.FirstName, Contact.LastName, AccountId, Profile.Name
            FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /** Membership contracts for an account (isMember incl. Expired; good-standing check). */
    /** Full contact for pre-populating the Individual + Professional Details form. */
    public Contact getContactForPrefill(Id contactId) {
        if (contactId == null) return null;
        List<Contact> rows = [
            SELECT Id, FirstName, LastName, Email, Phone, MobilePhone, Mobile_Phone_Code__c,
                   SMS_Registration_Updates__c, SMS_Promotional_Updates__c,
                   Title, Company__c, Business_Contact_Email__c,
                   Corporate_Title__c, Job_Function__c, Risk_Specialty__c,
                   KPI_FRM_Certified__c, KPI_ERP_Certified__c,
                   MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                   Mailing_Address_Company__c
            FROM Contact WHERE Id = :contactId LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    public List<Contract> getActiveMembershipContracts(Id accountId) {
        if (accountId == null) return new List<Contract>();
        return [
            SELECT Id, Status, Membership_Type__c, RecordType.Name, EndDate
            FROM Contract
            WHERE AccountId = :accountId
              AND Status IN ('Expired', 'Activated', 'Activated ( Auto-Renew )')
            ORDER BY StartDate
        ];
    }

    /** Affiliate program by registration/affiliate code (latest). */
    public Affiliate_Program__c getAffiliateProgram(String code) {
        if (String.isBlank(code)) return null;
        List<Affiliate_Program__c> rows = [
            SELECT Id, Affiliate_Code__c, Start_Date__c, End_Date__c, Product__c, EPP_Deal__c,
                   EPP_Deal__r.Status__c, EPP_Deal__r.Start_Date__c, EPP_Deal__r.End_Date__c,
                   Account__r.EPP_Accounting_Code__c
            FROM Affiliate_Program__c
            WHERE Affiliate_Code__c = :code AND Affiliate_Code__c != null
            ORDER BY CreatedDate DESC LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /** B2B deal item (team registration) by access code, with seat usage. */
    public B2B_Deal_Item__c getTeamDealByCode(String teamRegCode) {
        if (String.isBlank(teamRegCode)) return null;
        List<B2B_Deal_Item__c> rows = [
            SELECT Id, Name, Access_Code__c, Seats_Allowed__c, Seats_Used__c,
                   (SELECT Id, StageName FROM Opportunities__r WHERE StageName != 'Closed lost')
            FROM B2B_Deal_Item__c WHERE Access_Code__c = :teamRegCode LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /** True if the contact already has a paid registration for the event. */
    public Boolean hasPaidRegistration(String eventRecId, Id contactId) {
        if (String.isBlank(eventRecId) || contactId == null) return false;
        return ![
            SELECT Id FROM Event_Registration__c
            WHERE Event__c = :eventRecId AND Contact__c = :contactId AND Status__c = 'Registered and Paid'
            LIMIT 1
        ].isEmpty();
    }

    /** Institutions (companies/schools) for the screen dropdowns, by record type. */
    public List<Institution__c> getInstitutions(Id recordTypeId) {
        if (recordTypeId == null) return new List<Institution__c>();
        return [
            SELECT Id, Institution_Name__c
            FROM Institution__c
            WHERE RecordTypeId = :recordTypeId
            ORDER BY Name
        ];
    }

    /** Order + line items for building a Stripe checkout session. */
    public Opportunity getOrderForCheckout(String orderId) {
        if (String.isBlank(orderId)) return null;
        List<Opportunity> rows = [
            SELECT Id, AccountId, Account.GARP_ID__c, Name, StageName, Display_Invoice_Number__c,
                   Amount, Billing_Email__c, CurrencyIsoCode,
                   (SELECT Id, TotalPrice, UnitPrice, Quantity,
                           Product2.Name, Product2.ProductCode, Product2.Stripe_Tax_Code__c
                    FROM OpportunityLineItems)
            FROM Opportunity WHERE Id = :orderId LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    @TestVisible
    private static void clearCache() {
        countryCache = null;
    }
}