/**
 * "Fast load" controller for garpEventRegModernFullV3.
 *
 * SIMPLE + FLAT: one @AuraEnabled method per object. Each method runs a single query
 * (via GARP_EventReg_Selector) and returns the RAW object/list DIRECTLY — no Map
 * bundling, no JSON, no flags, no date/eligibility/product logic. The LWC fires these
 * concurrently and maps the raw records into its view model in ./util.
 *
 * Static reference lookups are cacheable=true (served from the client cache on repeat
 * loads); event/user/session methods are not.
 */
public without sharing class GARP_EventRegFast_Controller {

    private static GARP_EventReg_Selector selector() { return new GARP_EventReg_Selector(); }

    /* ===================== Event ===================== */

    /** One raw Event__c (with its rate + child-event subqueries) by Id or Vanity URL.
     *  Used for the main event AND — called again by the LWC — for the bundled event. */
    @AuraEnabled
    public static Event__c getEvent(String eventId) {
        try {
            return selector().getEventForLoad(eventId);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Raw promo/discount rows for an event. */
    @AuraEnabled
    public static List<Event_Discount__c> getEventDiscounts(String eventId) {
        try {
            Event__c ev = selector().getEventForLoad(eventId);
            return ev == null ? new List<Event_Discount__c>() : selector().getEventDiscounts(ev.Id);
        } catch (Exception e) { throw audErr(e); }
    }

    /* ===================== Reference data (cacheable) ===================== */

    /** Raw country config (with the Provinces__r subquery). */
    @AuraEnabled(cacheable=true)
    public static List<Country_Code__c> getCountries() {
        try {
            return selector().getCountryCodesMap().values();
        } catch (Exception e) { throw audErr(e); }
    }

    /** Raw company institutions (Organization record type) for the typeahead. */
    @AuraEnabled(cacheable=true)
    public static List<Institution__c> getCompanies() {
        try {
            return selector().getInstitutions(rt(Institution__c.SObjectType, 'Organization'));
        } catch (Exception e) { throw audErr(e); }
    }

    /** Active picklist labels for Contact.Corporate_Title__c. */
    @AuraEnabled(cacheable=true)
    public static List<String> getProfessionalLevels() {
        return picklistLabels('Contact', 'Corporate_Title__c');
    }

    /** Active picklist labels for Contact.Job_Function__c. */
    @AuraEnabled(cacheable=true)
    public static List<String> getJobFunctions() {
        return picklistLabels('Contact', 'Job_Function__c');
    }

    /** Active picklist labels for Contact.Risk_Specialty__c. */
    @AuraEnabled(cacheable=true)
    public static List<String> getRiskSpecialties() {
        return picklistLabels('Contact', 'Risk_Specialty__c');
    }

    /** The active Stripe settings record. */
    @AuraEnabled(cacheable=true)
    public static GARP_StripeSettings__c getStripeSettings() {
        try {
            return GARP_EventReg_Stripe.settings();
        } catch (Exception e) { throw audErr(e); }
    }

    /** Raw membership PricebookEntry rows (MEMI/MEMC) for USD/EUR/GBP — the LWC filters
     *  to the event currency and chooses MEMI vs MEMC (certified). */
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getMembershipPrices() {
        try {
            GARP_EventReg_Selector sel = selector();
            List<PricebookEntry> prices = new List<PricebookEntry>();
            prices.addAll(sel.getPricebookEntriesByCodes(new Set<String>{ 'MEMI', 'MEMC' }, null).values());
            for (String iso : new List<String>{ 'EUR', 'GBP' }) {
                prices.addAll(sel.getPricebookEntriesByCodes(new Set<String>{ 'MEMI', 'MEMC' }, iso).values());
            }
            return prices;
        } catch (Exception e) { throw audErr(e); }
    }

    /* ===================== User context ===================== */

    /** The raw running User (with Profile) — the LWC derives auth from Profile.Name. */
    @AuraEnabled
    public static User getRunningUser() {
        try {
            return selector().getRunningUser();
        } catch (Exception e) { throw audErr(e); }
    }

    /** The running user's Contact for prefill (null for guests). Self-contained. */
    @AuraEnabled
    public static Contact getContact() {
        try {
            User u = selector().getRunningUser();
            return selector().getContactForPrefill(u == null ? null : u.ContactId);
        } catch (Exception e) { throw audErr(e); }
    }

    /** The running user's active membership Contracts (empty for guests). Self-contained. */
    @AuraEnabled
    public static List<Contract> getContracts() {
        try {
            User u = selector().getRunningUser();
            return selector().getActiveMembershipContracts(u == null ? null : u.AccountId);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Whether the running user already has a paid registration for this event. Self-contained. */
    @AuraEnabled
    public static Boolean getHasPaidRegistration(String eventId) {
        try {
            GARP_EventReg_Selector sel = selector();
            User u = sel.getRunningUser();
            Id contactId = u == null ? null : u.ContactId;
            if (contactId == null || String.isBlank(eventId)) { return false; }
            Id evRecId = resolveEventRecId(sel, eventId);
            return evRecId == null ? false : sel.hasPaidRegistration(evRecId, contactId);
        } catch (Exception e) { throw audErr(e); }
    }

    /* ===================== Session + reg code ===================== */

    /** Insert and return a Form_Session__c — the LWC reads its Id as the captcha token. */
    @AuraEnabled
    public static Form_Session__c createFormSession() {
        try {
            Form_Session__c fs = new Form_Session__c();
            insert fs;
            return fs;
        } catch (Exception e) { throw audErr(e); }
    }

    /** Raw Affiliate_Program__c for a registration code (null when none). */
    @AuraEnabled
    public static Affiliate_Program__c getAffiliateProgram(String regCode) {
        try {
            return String.isBlank(regCode) ? null : selector().getAffiliateProgram(regCode);
        } catch (Exception e) { throw audErr(e); }
    }

    /** Raw B2B_Deal_Item__c (with its Opportunities subquery for seat counting), or null. */
    @AuraEnabled
    public static B2B_Deal_Item__c getTeamDeal(String regCode) {
        try {
            return String.isBlank(regCode) ? null : selector().getTeamDealByCode(regCode);
        } catch (Exception e) { throw audErr(e); }
    }

    /* ===================== Member profile survey (information page) =====================
     * Self-contained load/save for the garpEventRegInformation "Complete Your Profile"
     * survey. Kept in this LWC controller (no dependency on the legacy GARP_*_MemberProfile
     * classes): plain SOQL for the Contact + picklist/institution options, and a single
     * Contact update on save.
     * =================================================================================== */

    /** Raw Contact survey fields for the information page (null when blank/not found). */
    @AuraEnabled
    public static Contact getContactProfile(String contactId) {
        try {
            if (String.isBlank(contactId)) { return null; }
            List<Contact> cons = [
                SELECT Id, AccountId, FirstName, LastName,
                       Currently_Working_Status__c, Area_of_Concentration__c, Industry_Working_Year__c, Company__c,
                       Corporate_Title__c, Job_Function__c, Risk_Specialty__c, Risk_Management_Working_Year__c,
                       Professional_Designation_ACCA__c, Professional_Designation_CA__c, Professional_Designation_CAIA__c,
                       Professional_Designation_CFA__c, Professional_Designation_CFP__c, Professional_Designation_CIA__c,
                       Professional_Designation_CMA__c, Professional_Designation_CMT__c, Professional_Designation_CPA__c,
                       Professional_Designation_CQF__c, Professional_Designation_PMP__c, Professional_Designation_Other__c,
                       Other_Qualifications__c, School_Name__c, Highest_Degree__c, Expected_Graduation_Date__c, Expected_Graduation_Month__c
                FROM Contact WHERE Id = :contactId LIMIT 1
            ];
            return cons.isEmpty() ? null : cons[0];
        } catch (Exception e) { throw audErr(e); }
    }

    /** All institutions (Organization + Academic) — the LWC filters by RecordType.Name. */
    @AuraEnabled(cacheable=true)
    public static List<Institution__c> getInstitutions() {
        try {
            return [SELECT Id, Institution_Name__c, RecordType.Name FROM Institution__c ORDER BY Institution_Name__c];
        } catch (Exception e) { throw audErr(e); }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getWorkingStatuses() { return picklistLabels('Contact', 'Currently_Working_Status__c'); }
    @AuraEnabled(cacheable=true)
    public static List<String> getIndustries() { return picklistLabels('Contact', 'Area_of_Concentration__c'); }
    @AuraEnabled(cacheable=true)
    public static List<String> getDegrees() { return picklistLabels('Contact', 'Highest_Degree__c'); }
    @AuraEnabled(cacheable=true)
    public static List<String> getGraduationMonths() { return picklistLabels('Contact', 'Expected_Graduation_Month__c'); }

    /** Save the "Complete Your Profile" survey onto the Contact. */
    @AuraEnabled
    public static Boolean saveContactProfile(ProfileInput input) {
        try {
            if (input == null || String.isBlank(input.contactId)) { return false; }
            Contact c = new Contact(Id = (Id) input.contactId);
            c.Currently_Working_Status__c = input.workingStatus;
            c.Area_of_Concentration__c = input.industry;
            c.Industry_Working_Year__c = input.industryYear;
            c.Company__c = input.company;
            c.Corporate_Title__c = input.professionalLevel;
            c.Job_Function__c = input.jobFunction;
            c.Risk_Specialty__c = input.riskSpecialty;
            c.Risk_Management_Working_Year__c = input.riskYear;
            c.Professional_Designation_ACCA__c = input.acca == true;
            c.Professional_Designation_CA__c = input.ca == true;
            c.Professional_Designation_CAIA__c = input.caia == true;
            c.Professional_Designation_CFA__c = input.cfa == true;
            c.Professional_Designation_CFP__c = input.cfp == true;
            c.Professional_Designation_CIA__c = input.cia == true;
            c.Professional_Designation_CMA__c = input.cma == true;
            c.Professional_Designation_CMT__c = input.cmt == true;
            c.Professional_Designation_CPA__c = input.cpa == true;
            c.Professional_Designation_CQF__c = input.cqf == true;
            c.Professional_Designation_PMP__c = input.pmp == true;
            c.Professional_Designation_Other__c = input.otherDes == true;
            c.Other_Qualifications__c = input.other;
            c.School_Name__c = input.school;
            c.Highest_Degree__c = input.degree;
            c.Expected_Graduation_Date__c = input.gradYear;
            c.Expected_Graduation_Month__c = input.gradMonth;
            update c;
            return true;
        } catch (Exception e) { throw audErr(e); }
    }

    /** Survey payload from garpEventRegInformation (keys match the LWC form model). */
    public class ProfileInput {
        @AuraEnabled public String contactId { get; set; }
        @AuraEnabled public String workingStatus { get; set; }
        @AuraEnabled public String industry { get; set; }
        @AuraEnabled public String industryYear { get; set; }
        @AuraEnabled public String company { get; set; }
        @AuraEnabled public String professionalLevel { get; set; }
        @AuraEnabled public String jobFunction { get; set; }
        @AuraEnabled public String riskSpecialty { get; set; }
        @AuraEnabled public String riskYear { get; set; }
        @AuraEnabled public String other { get; set; }
        @AuraEnabled public String school { get; set; }
        @AuraEnabled public String degree { get; set; }
        @AuraEnabled public String gradYear { get; set; }
        @AuraEnabled public String gradMonth { get; set; }
        @AuraEnabled public Boolean acca { get; set; }
        @AuraEnabled public Boolean ca { get; set; }
        @AuraEnabled public Boolean caia { get; set; }
        @AuraEnabled public Boolean cfa { get; set; }
        @AuraEnabled public Boolean cfp { get; set; }
        @AuraEnabled public Boolean cia { get; set; }
        @AuraEnabled public Boolean cma { get; set; }
        @AuraEnabled public Boolean cmt { get; set; }
        @AuraEnabled public Boolean cpa { get; set; }
        @AuraEnabled public Boolean cqf { get; set; }
        @AuraEnabled public Boolean pmp { get; set; }
        @AuraEnabled public Boolean otherDes { get; set; }
    }

    /* ===================== Free-order completion (information page) =====================
     * A $0 registration (free event, no membership) has no payment step, so — mirroring
     * legacy GARP_BC_Orders.payOrder (StageName -> 'Closed') + payOrderSuccessComplete
     * (Event_Registration -> 'Registered') — the order is closed here from the LWC after
     * setRegistration. Only a still-open $0 order is touched, so paid / Wire / ACH orders
     * (which stay 'New Lead' until payment) are never affected.
     * =================================================================================== */
    @AuraEnabled
    public static Boolean completeFreeOrder(String orderId, String contactId) {
        try {
            return finalizeFreeOrder(orderId, contactId);
        } catch (Exception e) { throw audErr(e); }
    }

    /**
     * Async entry point: enqueue the $0-order finalization so the shopper is not blocked
     * ~4s on the Opportunity close-stage trigger cascade at Register. The order + event
     * registration already exist (setRegistration); this only adds the free line items,
     * closes the order and grants the Affiliate membership. Runs in its own transaction
     * (Queueable) exactly like the synchronous completeFreeOrder would, so the Chargent
     * order it needs is already committed by the time it runs.
     */
    @AuraEnabled
    public static void completeFreeOrderAsync(String orderId, String contactId) {
        try {
            System.enqueueJob(new GARP_EventRegFreeOrderQueueable(orderId, contactId));
        } catch (Exception e) { throw audErr(e); }
    }

    /** Core $0-order finalization (legacy GARP_BC_Orders.payOrder $0 + payOrderSuccessComplete
     *  parity). Throws the original exception on failure — callers wrap it for their context
     *  (AuraHandledException for the LWC; logged-and-swallowed for the async Queueable). */
    public static Boolean finalizeFreeOrder(String orderId, String contactId) {
        try {
            if (String.isBlank(orderId)) { return false; }
            List<Opportunity> opps = [
                SELECT Id, StageName, Amount, AccountId, CurrencyIsoCode, Pricebook2Id,
                       Billing_Email__c, Billing_City__c, Billing_State_Text__c, Billing_Zip_Postal__c, Billing_Country__c
                FROM Opportunity WHERE Id = :orderId LIMIT 1
            ];
            if (opps.isEmpty()) { return false; }
            Opportunity opp = opps[0];
            // Guard: only complete a $0 order that is still open.
            if (opp.StageName != 'New Lead' || (opp.Amount != null && opp.Amount > 0)) { return false; }

            GARP_EventReg_Selector sel = selector();

            // Membership standing (legacy):
            //   - in good standing (Individual, Activated) -> member main product (CRTM);
            //   - any membership at all suppresses the free-affiliate add (AFREE).
            Boolean inGoodStanding = false;
            Boolean hasAnyMembership = false;
            for (Contract c : sel.getActiveMembershipContracts(opp.AccountId)) {
                if (c.RecordType != null && c.RecordType.Name == 'Membership') {
                    hasAnyMembership = true;
                    if (c.Membership_Type__c == 'Individual'
                        && (c.Status == 'Activated' || c.Status == 'Activated ( Auto-Renew )')) {
                        inGoodStanding = true;
                    }
                }
            }

            // Legacy line items for a rate-less free event (GARP_BC_Registration.getRegistrationFees
            // fallback to mainMember/NonMemberProductCode + GARP_BC_Orders.setOrder AFREE add):
            //   main = CRTM (member) / CRTNM (non-member "GARP Events Non-Member"); a registrant
            //   with no membership also gets AFREE ("Affiliate FREE"). Both priced at $0.
            String mainCode = inGoodStanding ? 'CRTM' : 'CRTNM';
            Boolean addAffiliate = !hasAnyMembership;
            Set<String> codes = new Set<String>{ mainCode };
            if (addAffiliate) { codes.add('AFREE'); }

            // Find the products in the ORDER's own currency, then pick a SINGLE price book that
            // carries them: the one with the most of the needed codes, and it MUST include the
            // main product. This works for ANY price book / currency (no dependency on book
            // names) and never mixes books (line items must share the order's price book). The
            // opp currency is never mutated — if a currency has no matching book, no line item
            // is added rather than forcing a currency change (which fails validation/automation).
            List<PricebookEntry> avail = [
                SELECT Id, UnitPrice, Pricebook2Id, Product2.ProductCode, Product2.Family
                FROM PricebookEntry
                WHERE Product2.ProductCode IN :codes AND IsActive = true AND Product2.IsActive = true
                  AND CurrencyIsoCode = :opp.CurrencyIsoCode
            ];
            Map<Id, List<PricebookEntry>> byBook = new Map<Id, List<PricebookEntry>>();
            for (PricebookEntry p : avail) {
                if (!byBook.containsKey(p.Pricebook2Id)) { byBook.put(p.Pricebook2Id, new List<PricebookEntry>()); }
                byBook.get(p.Pricebook2Id).add(p);
            }
            List<PricebookEntry> chosen = new List<PricebookEntry>();
            Integer bestScore = 0;
            for (Id bookId : byBook.keySet()) {
                Map<String, PricebookEntry> byCode = new Map<String, PricebookEntry>();
                for (PricebookEntry p : byBook.get(bookId)) {
                    if (!byCode.containsKey(p.Product2.ProductCode)) { byCode.put(p.Product2.ProductCode, p); }
                }
                if (!byCode.containsKey(mainCode)) { continue; } // the main product must be in this book
                if (byCode.size() > bestScore) { bestScore = byCode.size(); chosen = byCode.values(); }
            }

            // The order needs a price book before line items can be added. When we also
            // grant the free Affiliate membership (AFREE), flag the order
            // Eligible_for_Membership_Extension__c — legacy parity (GARP_BC_Orders.setOrder,
            // where !doNotCreateAffiliateMember sets this same flag). Without it, closing an
            // order that carries an AFREE line makes the OpportunityHandler close-stage
            // membership logic look the order up in `renewOpps` (populated only from this
            // flag / Auto_Renew / Renew_Membership) and NullPointerException when it's absent
            // (opportunityTriggerUtils_New.getNewMemberContract) — which rolls back the whole
            // completion, leaving the opp stuck at 'New Lead' with no line items.
            Boolean oppNeedsUpdate = false;
            if (opp.Pricebook2Id == null && !chosen.isEmpty()) {
                opp.Pricebook2Id = chosen[0].Pricebook2Id;
                oppNeedsUpdate = true;
            }
            if (addAffiliate) {
                opp.Eligible_for_Membership_Extension__c = true;
                oppNeedsUpdate = true;
            }
            if (oppNeedsUpdate) { update opp; }

            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
            for (PricebookEntry pbe : chosen) {
                olis.add(new OpportunityLineItem(
                    OpportunityId = opp.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = pbe.UnitPrice == null ? 0 : pbe.UnitPrice,
                    Product_Family__c = pbe.Product2.Family
                ));
            }
            if (!olis.isEmpty()) { insert olis; }

            // Free affiliate membership contract (legacy GARP_BC_Registration.createContracts ->
            // GARP_BC_Membership.createMembershipContract for the AFREE product): a registrant
            // with no membership is granted a free Affiliate membership.
            if (addAffiliate && String.isNotBlank(contactId)) {
                insert new Contract(
                    AccountId = opp.AccountId,
                    CustomerSignedId = (Id) contactId,
                    Opportunity__c = opp.Id,
                    StartDate = Date.today(),
                    Name = 'Membership',
                    ContractTerm = 12,
                    RecordTypeId = rt(Contract.SObjectType, 'Membership'),
                    Member_Email__c = opp.Billing_Email__c,
                    Membership_Type__c = 'Affiliate',
                    BillingCity = opp.Billing_City__c,
                    BillingState = opp.Billing_State_Text__c,
                    BillingPostalCode = opp.Billing_Zip_Postal__c,
                    BillingCountry = opp.Billing_Country__c
                );
            }

            // Legacy parity (GARP_BC_Orders.payOrder $0 branch): insert an Approved $0 "Free"
            // Charge transaction against the order's ChargentOrder. The
            // ChargentOrderTransactionTriggerHandler then closes the Opportunity
            // (StageName -> 'Closed') — the exact path a legacy free order takes.
            List<ChargentOrders__ChargentOrder__c> orders = [
                SELECT Id FROM ChargentOrders__ChargentOrder__c WHERE Opportunity__c = :orderId LIMIT 1
            ];
            if (!orders.isEmpty()) {
                insert new ChargentOrders__Transaction__c(
                    Opportunity__c = opp.Id,
                    ChargentOrders__Order__c = orders[0].Id,
                    ChargentOrders__Amount__c = 0.00,
                    ChargentOrders__Response_Message__c = 'Approved',
                    ChargentOrders__Response_Status__c = 'Approved',
                    ChargentOrders__Type__c = 'Charge',
                    ChargentOrders__Gateway_Date__c = System.now(),
                    ChargentOrders__Payment_Method__c = 'Free'
                );
            } else {
                // No ChargentOrder to attach the transaction to — close the opp directly.
                opp.StageName = 'Closed';
                update opp;
            }

            // Mark the event registration(s) Registered (legacy payOrderSuccessComplete parity).
            List<Event_Registration__c> regs = [
                SELECT Id, Status__c FROM Event_Registration__c WHERE Opportunity__c = :orderId
            ];
            List<Event_Registration__c> toUpdate = new List<Event_Registration__c>();
            for (Event_Registration__c er : regs) {
                if (er.Status__c == null) { er.Status__c = 'Registered'; toUpdate.add(er); }
            }
            if (!toUpdate.isEmpty()) { update toUpdate; }
            return true;
        } catch (Exception e) { throw e; }
    }

    /* ===================== helpers ===================== */

    /** Resolve an event record Id from an Id-or-VanityURL string (for the paid check). */
    private static Id resolveEventRecId(GARP_EventReg_Selector sel, String eventId) {
        try {
            Id idVal = (Id) eventId;
            if (idVal.getSObjectType() == Event__c.SObjectType) { return idVal; }
        } catch (Exception ignored) { /* not an Id — resolve via the event below */ }
        Event__c ev = sel.getEventForLoad(eventId);
        return ev == null ? null : ev.Id;
    }

    private static List<String> picklistLabels(String sobjectName, String fieldName) {
        List<String> labels = new List<String>();
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sobjectName);
        if (t == null) { return labels; }
        Schema.SObjectField f = t.getDescribe().fields.getMap().get(fieldName);
        if (f == null) { return labels; }
        for (Schema.PicklistEntry pe : f.getDescribe().getPicklistValues()) {
            if (pe.isActive()) { labels.add(pe.getLabel()); }
        }
        return labels;
    }

    private static Id rt(SObjectType t, String label) {
        Schema.RecordTypeInfo info = t.getDescribe().getRecordTypeInfosByName().get(label);
        return info == null ? null : info.getRecordTypeId();
    }

    private static AuraHandledException audErr(Exception e) {
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        return ahe;
    }
}