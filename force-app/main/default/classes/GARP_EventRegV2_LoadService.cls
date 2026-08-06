/**
 * Typed screen-load builder for garpEventRegModernFullV2.
 *
 * A clean, strongly-typed alternative to GARP_EventReg_LoadService's
 * Map<String,Object> assembly: every part of the payload is a named wrapper
 * class (below), so the mapping reads top-to-bottom with compile-time field
 * checking instead of dozens of loose put('key', value) calls. It also maps
 * ONLY the fields the V2 screen actually consumes, so the payload is leaner.
 *
 * Data sources are reused (they were never the confusing part):
 *   - event + rates + promos, countries, institutions → GARP_EventReg_Selector
 *   - profession/job/risk dropdowns                    → picklist describe
 *   - stripe flags/keys                                → GARP_EventReg_Stripe
 *   - captcha token                                    → new Form_Session__c
 *
 * SObject-derived collections (locations, companies) and the contact record are
 * kept as their queried SObjects — they already serialize to the exact field
 * names the form binds to, and re-mapping them would add churn, not clarity.
 */
public without sharing class GARP_EventRegV2_LoadService {

    private final GARP_EventReg_Selector selector = new GARP_EventReg_Selector();

    /* ============================ typed wrapper ============================ */

    public class RegLoad {
        public String status = 'Success';
        public String statusMessage = 'Data retieved successfully'; // preserve legacy spelling
        public EventReg eventRegistrationInfo;
        public ScreenInfo screenInfo;
        public MembershipInfo membershipInfo;
        public List<Product> products;
        public ProgramRegInfo programRegistrationInfo;
        public StripeInfo stripeInfo;
        public CaptchaInfo captchaInfo;
        public TeamRegInfo teamRegInfo;
        public String affiliateCode;
        public Object examSelectionInfo;
        public Boolean isEligible;
        public String notEligibleErrorMessage;
    }

    public class EventReg {
        public EventInfo eventInfo;
        public String eventId;
        public String formKey;
        public Boolean isPayForEvent;
        public Boolean hasPromoCodes;
        public Boolean maxCapacityMet;
        public Boolean wireAllowed;
        public String rsvpCopy;
        public String rsvpWaitingListCopy;
        public Boolean rsvpActivityAsk;
        public String rsvpActivityName;
        public Boolean rsvpActivityAskDiet;
        public Boolean rsvpActivityAskQuestion;
        public String rsvpActivityQuestion;
        public String eventQuestionTitle;
        public String eventQuestionDetail;
        public Boolean isProfessionDetailsTitleRequested;
        public Boolean isProfessionDetailsRequired;
        public Boolean isBundledEvent;
        public BundledReg bundledEventRegistrationInfo;
        public Boolean isBundledEventEligible;
        public Boolean isMembersOnly = false;
        public Boolean isMembershipPurchaseRequired = false;
    }

    public class BundledReg {
        public String eventId;
        public EventInfo eventInfo;
    }

    public class EventInfo {
        public String eventId;
        public String eventType = 'event';
        public String currencyIsoCode;
        public String title;
        public String description;
        public String deliveryMode;
        public String deliveryModeDescription;
        public Date lastDateToRegister;
        public String timeZone;
        public String locationDescription;
        public String venueName;
        public Boolean isOnDemand;
        public String sponsorName;
        public String sponsorPolicyURL;
        public Boolean isSponsored;
        public Boolean isInviteOnly;
        public Boolean maxCapacityMet;               // was Max_Capacity_Met__c in the legacy payload
        public String dateDescription;
        public String timeDescription;
        public String rsvpActivityName;
        public String rsvpActivityDetail;
        public String rsvpActivityLocation;
        public String rsvpActivityMode;
        public String rsvpActivityDateDescription;
        public String rsvpActivityTimeDescription;
    }

    public class ScreenInfo {
        public Boolean isAuthenticated;
        public Object locations;   // List<Country_Code__c> — serialized with SObject field names
        public Object companies;   // List<Institution__c>
        public List<String> professionalLevels;
        public List<String> jobFunctions;
        public List<String> riskSpecialties;
        public Object FAQInfo;
    }

    public class MembershipInfo {
        public Object contactRecord;   // Contact SObject
        public Boolean isInGoodStanding;
        public Boolean isAutoRenewMembershipEnabled;
        public String currentMemberType;
    }

    public class ProgramRegInfo {
        public String registrationType = 'event';
        public String eventType = 'event';
        public String eventId;
        public String formName;
        public String mainMemberProductCode = 'CRTM';
        public String mainNonMemberProductCode = 'CRTNM';
        public String eventDiscountProductCode = 'EVTDSC';
        public Boolean allowMemberPublicRegistration;
        public Boolean addressVerificationDisabled;
        public String membershipType;
    }

    public class StripeInfo {
        public Boolean useStripe;
        public Boolean useStripeTax;
        public String clientSideAPIKey;
    }

    public class CaptchaInfo {
        public String sessionToken;
    }

    public class TeamRegInfo {
        public String teamRegCode;
        public String teamRegId;
        public Boolean isComplimentary = false;
        public Boolean isBundle = false;
        public Boolean authenticationRequired = false;
        public Boolean seatsAvailable;
    }

    public class Product {
        public String productCode;
        public String productName;
        public String priceId;
        public Decimal amount;
        public Boolean isMembershipProduct = true;
    }

    /* ============================ builder ============================ */

    public RegLoad load(String eventId, String regCode) {
        RegLoad reg = new RegLoad();

        Event__c ev = selector.getEventForLoad(eventId);
        if (ev == null) {
            reg.status = 'Error';
            reg.statusMessage = 'Event not found';
            return reg;
        }

        // ---- Authenticated user / membership context ----------------------
        User u = selector.getRunningUser();
        Boolean isAuthenticated = u != null && u.Profile != null && u.Profile.Name == 'Customer Community';
        Contact con = isAuthenticated && u != null ? selector.getContactForPrefill(u.ContactId) : null;
        MembershipInfo membershipInfo = isAuthenticated ? buildMembershipInfo(u, con) : null;

        // ---- Event registration info + nested event info ------------------
        EventInfo eventInfo = buildEventInfo(ev);
        EventReg eventReg = buildEventReg(ev, eventInfo);

        // ---- Screen info --------------------------------------------------
        ScreenInfo screenInfo = new ScreenInfo();
        screenInfo.isAuthenticated = isAuthenticated;
        screenInfo.locations = selector.getCountryCodesMap().values();
        screenInfo.companies = selector.getInstitutions(rt(Institution__c.SObjectType, 'Organization'));
        screenInfo.professionalLevels = picklistLabels('Contact', 'Corporate_Title__c');
        screenInfo.jobFunctions = picklistLabels('Contact', 'Job_Function__c');
        screenInfo.riskSpecialties = picklistLabels('Contact', 'Risk_Specialty__c');
        screenInfo.FAQInfo = null;

        // ---- Stripe / captcha --------------------------------------------
        GARP_StripeSettings__c s = GARP_EventReg_Stripe.settings();
        StripeInfo stripeInfo = new StripeInfo();
        stripeInfo.useStripe = s != null && s.Use_Stripe__c == true;
        stripeInfo.useStripeTax = s != null && s.Use_Stripe_Tax__c == true;
        stripeInfo.clientSideAPIKey = s == null ? null : s.Client_Side_API_Key__c;

        Form_Session__c fs = new Form_Session__c();
        insert fs;
        CaptchaInfo captchaInfo = new CaptchaInfo();
        captchaInfo.sessionToken = fs.Id;

        // ---- Program registration info -----------------------------------
        Boolean inviteOnly = ev.Invite_Only__c == true;
        ProgramRegInfo programRegistrationInfo = new ProgramRegInfo();
        programRegistrationInfo.eventId = ev.Id;
        programRegistrationInfo.formName = eventReg.formKey;
        programRegistrationInfo.allowMemberPublicRegistration = inviteOnly; // invite-only allows member public reg
        programRegistrationInfo.addressVerificationDisabled = inviteOnly;

        // ---- Registration code -> affiliate program or team-registration deal --
        String affiliateCode = null;
        TeamRegInfo teamRegInfo = null;
        if (String.isNotBlank(regCode)) {
            Affiliate_Program__c aff = selector.getAffiliateProgram(regCode);
            if (aff != null) {
                affiliateCode = aff.Affiliate_Code__c;
            } else {
                B2B_Deal_Item__c deal = selector.getTeamDealByCode(regCode);
                if (deal != null) {
                    teamRegInfo = new TeamRegInfo();
                    teamRegInfo.teamRegCode = deal.Access_Code__c;
                    teamRegInfo.teamRegId = deal.Id;
                    teamRegInfo.seatsAvailable = deal.Seats_Allowed__c == null
                        || deal.Opportunities__r == null
                        || deal.Opportunities__r.size() < deal.Seats_Allowed__c;
                }
            }
        }

        // ---- Assemble -----------------------------------------------------
        reg.eventRegistrationInfo = eventReg;
        reg.screenInfo = screenInfo;
        reg.membershipInfo = membershipInfo;
        reg.products = buildProducts(con, ev.CurrencyIsoCode);
        reg.programRegistrationInfo = programRegistrationInfo;
        reg.stripeInfo = stripeInfo;
        reg.captchaInfo = captchaInfo;
        reg.teamRegInfo = teamRegInfo;
        reg.affiliateCode = affiliateCode;
        reg.examSelectionInfo = null;

        Id authContactId = (isAuthenticated && u != null) ? u.ContactId : null;
        applyEligibility(reg, ev, eventReg, authContactId);
        return reg;
    }

    /* ===================== eventInfo ===================== */

    private EventInfo buildEventInfo(Event__c ev) {
        Boolean isOnDemand = ev.End_Date__c != null && DateTime.now() > ev.End_Date__c && ev.ON24_Event_Id__c != null;
        String deliveryMode = isOnDemand ? 'Online Only' : ev.Delivery_Method__c;

        // Location (mirrors legacy: Custom_Location else VenueName [+ ', ' + Address]).
        String location;
        if (String.isNotBlank(ev.Custom_Location__c)) {
            location = ev.Custom_Location__c;
        } else {
            location = '';
            if (String.isNotBlank(ev.VenueName__c)) { location = ev.VenueName__c; }
            if (String.isNotBlank(ev.Address__c)) {
                if (location != '') { location += ', '; }
                location += ev.Address__c;
            }
        }

        EventInfo ei = new EventInfo();
        ei.eventId = ev.Id;
        ei.currencyIsoCode = String.isNotBlank(ev.CurrencyIsoCode) ? ev.CurrencyIsoCode : 'USD';
        ei.title = ev.Title__c;
        ei.description = ev.Description__c;
        ei.deliveryMode = deliveryMode;
        ei.deliveryModeDescription = formatDeliveryMode(deliveryMode);
        ei.lastDateToRegister = ev.Last_Date_For_Registration__c;
        ei.timeZone = ev.Time_Zone__r != null ? ev.Time_Zone__r.Name : null;
        ei.locationDescription = location;
        ei.venueName = ev.VenueName__c;
        ei.isOnDemand = isOnDemand;
        ei.sponsorName = ev.Event_Sponsor__c;
        ei.sponsorPolicyURL = ev.Event_Sponsor_Policy_URL__c;
        ei.isSponsored = ev.Is_Sponsored_Event__c == true;
        ei.isInviteOnly = ev.Invite_Only__c == true;
        ei.maxCapacityMet = ev.Max_Capacity_Met__c == true;

        // Formatted date / time descriptions.
        if (ev.Start_Date__c != null && ev.End_Date__c != null) {
            String startDate = ev.Start_Date__c.format('MMMM d, yyyy');
            String endDate = ev.End_Date__c.format('MMMM d, yyyy');
            String startTime = ev.Start_Date__c.format('h:mm a');
            String endTime = ev.End_Date__c.format('h:mm a');
            if (startDate == endDate) {
                ei.dateDescription = startDate;
                ei.timeDescription = startTime + ' - ' + endTime;
            } else {
                ei.dateDescription = ev.Start_Date__c.format('MMMM d') + ', ' + startTime + ' - ' +
                                     ev.End_Date__c.format('MMMM d') + ', ' + endTime;
                ei.timeDescription = '';
            }
        }

        // RSVP activity detail block.
        ei.rsvpActivityName = ev.RSVP_Activity_Name__c;
        ei.rsvpActivityDetail = ev.RSVP_Activity_Details__c;
        ei.rsvpActivityLocation = ev.RSVP_Activity_Location__c;

        Boolean hasLoc = ev.RSVP_Activity_Location__c != null;
        Boolean hasUrl = ev.RSVP_Activity_Online_Meeting_URL__c != null;
        if (hasLoc && !hasUrl) { ei.rsvpActivityMode = 'In-Person'; }
        else if (!hasLoc && hasUrl) { ei.rsvpActivityMode = 'Online'; }
        else if (hasLoc && hasUrl) { ei.rsvpActivityMode = 'Hybrid'; }

        if (ev.RSVP_Activity_Start_Date_Time__c != null && ev.RSVP_Activity_End_Date_Time__c != null) {
            ei.rsvpActivityDateDescription = ev.RSVP_Activity_Start_Date_Time__c.format('MMMM d, yyyy');
            ei.rsvpActivityTimeDescription =
                ev.RSVP_Activity_Start_Date_Time__c.format('h:mm a') + ' - ' + ev.RSVP_Activity_End_Date_Time__c.format('h:mm a');
        }
        return ei;
    }

    private static String formatDeliveryMode(String deliveryMode) {
        if (deliveryMode == null) { return 'Online'; }
        if (deliveryMode == 'Online Only') { return 'Online'; }
        if (deliveryMode == 'In-Person Only') { return 'In-Person'; }
        return deliveryMode;
    }

    /* ===================== eventRegistrationInfo ===================== */

    private EventReg buildEventReg(Event__c ev, EventInfo eventInfo) {
        List<Event_Rate__c> rates = ev.Event_Rates__r == null ? new List<Event_Rate__c>() : ev.Event_Rates__r;
        Boolean foundRates = !rates.isEmpty();
        Boolean isPayForEvent = false;
        for (Event_Rate__c r : rates) {
            if ((r.Member_Rate__c != null && r.Member_Rate__c > 0) || (r.Non_Member_Rate__c != null && r.Non_Member_Rate__c > 0)) {
                isPayForEvent = true;
            }
        }

        Boolean maxCapacityMet = ev.Max_Capacity_Met__c == true ||
            (ev.Maximum_number_of_Event_Registrations__c != null &&
             ev.Total_Event_Registration__c != null &&
             ev.Total_Event_Registration__c >= ev.Maximum_number_of_Event_Registrations__c);

        Boolean wireAllowed = true;
        if (ev.Can_Pay_By_wire__c == false) { wireAllowed = false; }
        if (ev.Last_Date_for_Wire_Check_Registration__c != null && Date.today() > ev.Last_Date_for_Wire_Check_Registration__c) {
            wireAllowed = false;
        }

        Boolean isBundled = ev.Parent_Event__c != null || (ev.Events__r != null && !ev.Events__r.isEmpty());
        Id bundledEventId = ev.Parent_Event__r != null ? ev.Parent_Event__r.Id
            : (ev.Events__r != null && !ev.Events__r.isEmpty() ? ev.Events__r[0].Id : null);

        BundledReg bundledRegInfo = null;
        Boolean bundledEligible = false;
        if (isBundled && bundledEventId != null) {
            Event__c bev = selector.getEventForLoad(bundledEventId);
            if (bev != null) {
                bundledRegInfo = new BundledReg();
                bundledRegInfo.eventId = bev.Id;
                bundledRegInfo.eventInfo = buildEventInfo(bev);
                bundledEligible = true;
            }
        }

        Boolean hasPromoCodes = !selector.getEventDiscounts(ev.Id).isEmpty();

        // RSVP activity flags: null when there is no activity (legacy parity).
        Boolean hasActivity = ev.RSVP_Activity_Name__c != null || ev.RSVP_Activity_Ask_Diet_Restrictions__c == true;

        EventReg er = new EventReg();
        er.eventInfo = eventInfo;
        er.eventId = ev.Id;
        er.formKey = (ev.Content__r != null && ev.Content__r.Form__r != null) ? ev.Content__r.Form__r.Form_Name__c : null;
        er.isPayForEvent = isPayForEvent;
        er.hasPromoCodes = hasPromoCodes;
        er.maxCapacityMet = maxCapacityMet;
        er.wireAllowed = wireAllowed;
        er.rsvpCopy = ev.RSVP_Copy__c;
        er.rsvpWaitingListCopy = ev.RSVP_Waitlist_Copy__c;
        er.rsvpActivityAsk = hasActivity ? true : null;
        er.rsvpActivityName = ev.RSVP_Activity_Name__c;
        er.rsvpActivityAskDiet = hasActivity ? (ev.RSVP_Activity_Ask_Diet_Restrictions__c == true) : null;
        er.rsvpActivityAskQuestion = hasActivity ? (ev.RSVP_Activity_Question__c != null) : null;
        er.rsvpActivityQuestion = ev.RSVP_Activity_Question__c;
        er.eventQuestionTitle = ev.Event_Question_Title__c;
        er.eventQuestionDetail = ev.Event_Question_Detail__c;
        er.isProfessionDetailsTitleRequested = ev.Professional_Details_Request_Title__c == true;
        er.isProfessionDetailsRequired = ev.Professional_Details_Required__c == true;
        er.isBundledEvent = isBundled;
        er.bundledEventRegistrationInfo = bundledRegInfo;
        er.isBundledEventEligible = bundledEligible;
        // foundRates is used only for eligibility below — returned via a field-free local.
        er.isMembersOnly = false;
        er.isMembershipPurchaseRequired = false;
        return er;
    }

    /* ===================== membershipInfo (authenticated) ===================== */

    private MembershipInfo buildMembershipInfo(User u, Contact con) {
        MembershipInfo mi = new MembershipInfo();
        mi.contactRecord = con; // Contact SObject serializes to the exact field names the form reads

        Boolean inGoodStanding = false;
        Boolean autoRenew = false;
        String currentMemberType;
        for (Contract c : selector.getActiveMembershipContracts(u.AccountId)) {
            if (c.RecordType != null && c.RecordType.Name == 'Membership') {
                currentMemberType = c.Membership_Type__c;
                if (c.Membership_Type__c == 'Individual' && (c.Status == 'Activated' || c.Status == 'Activated ( Auto-Renew )')) {
                    inGoodStanding = true;
                    if (c.Status == 'Activated ( Auto-Renew )') { autoRenew = true; }
                }
            }
        }
        mi.isInGoodStanding = inGoodStanding;
        mi.isAutoRenewMembershipEnabled = autoRenew;
        mi.currentMemberType = currentMemberType;
        return mi;
    }

    /* ===================== products (membership add-on) ===================== */

    private List<Product> buildProducts(Contact con, String currencyIso) {
        List<Product> products = new List<Product>();
        Boolean certified = con != null && (con.KPI_FRM_Certified__c == true || con.KPI_ERP_Certified__c == true);
        String code = certified ? 'MEMC' : 'MEMI';
        Map<String, PricebookEntry> pbes = selector.getPricebookEntriesByCodes(new Set<String>{ 'MEMI', 'MEMC' }, currencyIso);
        for (PricebookEntry p : pbes.values()) {
            if (p.Product2.ProductCode == code) {
                Product prod = new Product();
                prod.productCode = p.Product2.ProductCode;
                prod.productName = p.Product2.Name;
                prod.priceId = p.Id;
                prod.amount = p.UnitPrice;
                products.add(prod);
            }
        }
        return products;
    }

    /* ===================== eligibility ===================== */

    private void applyEligibility(RegLoad reg, Event__c ev, EventReg eventReg, Id authContactId) {
        if (eventReg.eventInfo.isOnDemand == true) { setEligible(reg); return; }

        Boolean foundRates = ev.Event_Rates__r != null && !ev.Event_Rates__r.isEmpty();
        if ((eventReg.isPayForEvent && !foundRates) ||
            (ev.Last_Date_For_Registration__c != null && Date.today() > ev.Last_Date_For_Registration__c)) {
            setNotEligible(reg, 'Registration is currently not available'); return;
        }
        if (eventReg.maxCapacityMet == true) {
            setNotEligible(reg, 'Maximum capacity has been met'); return;
        }
        if (eventReg.isPayForEvent && authContactId != null && selector.hasPaidRegistration(ev.Id, authContactId)) {
            setNotEligible(reg, 'Already registered and paid for this event'); return;
        }
        setEligible(reg);
    }

    private void setEligible(RegLoad reg) { reg.isEligible = true; reg.notEligibleErrorMessage = null; }
    private void setNotEligible(RegLoad reg, String msg) { reg.isEligible = false; reg.notEligibleErrorMessage = msg; }

    /* ===================== helpers ===================== */

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
}