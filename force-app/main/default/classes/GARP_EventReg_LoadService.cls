/**
 * Standalone builder for the event-registration screen-load payload — the
 * self-contained replacement for GARP_BC_Events.getEventRegistrationInfo (the
 * last legacy dependency in the module).
 *
 * Produces the same JSON structure garpEventRegModernFull consumes:
 * { eventRegistrationInfo{ eventInfo{...}, ... }, screenInfo{...}, membershipInfo,
 *   products[], programRegistrationInfo{...}, stripeInfo{...}, captchaInfo{...},
 *   teamRegInfo, affiliateCode, isEligible, notEligibleErrorMessage, status }.
 *
 * Sources (no GARP_BC_* / GARP_StripeClass):
 *  - event + rates + promos, countries, institutions  → GARP_EventReg_Selector
 *  - profession/job/risk dropdowns                     → picklist describe (labels)
 *  - stripe flags/keys                                 → GARP_EventReg_Stripe (GARP_StripeSettings__c)
 *  - captcha token                                     → new Form_Session__c
 *
 * Scope: EVENT (Event__c). Webcast/chapter-meeting variants can be added the
 * same way. Authenticated member context is populated at a basic level
 * (good-standing + name); deep membership nuance remains a later refinement.
 */
public without sharing class GARP_EventReg_LoadService {

    private final GARP_EventReg_Selector selector = new GARP_EventReg_Selector();

    public String getEventRegistrationInfo(String eventId, String regCode) {
        return getEventRegistrationInfo(eventId, regCode, false);
    }

    /**
     * @param skipInstitutions "lite payload" flag. When true, the large screenInfo lists are
     *        omitted (and their SOQL skipped): the company/school typeahead lists AND the
     *        country `locations` list (247 countries + their provinces, ~132KB). Callers that
     *        pass true must load those on demand — companies via
     *        GARP_EventRegFast_Controller.getCompanies (on company-field focus) and countries
     *        via the cacheable GARP_EventRegFast_Controller.getCountries (in parallel on load).
     *        Defaults to false so every existing caller keeps the full payload — legacy parity.
     */
    public String getEventRegistrationInfo(String eventId, String regCode, Boolean skipInstitutions) {
        Boolean skipInst = skipInstitutions == true;
        Map<String, Object> reg = new Map<String, Object>();
        reg.put('status', 'Success');
        reg.put('statusMessage', 'Data retieved successfully'); // preserve legacy spelling

        Event__c ev = selector.getEventForLoad(eventId);
        if (ev == null) {
            reg.put('status', 'Error');
            reg.put('statusMessage', 'Event not found');
            return JSON.serialize(reg, true);
        }

        // ---- Authenticated user / membership context ----------------------
        User u = selector.getRunningUser();
        Boolean isAuthenticated = u != null && u.Profile != null && u.Profile.Name == 'Customer Community';
        Map<String, Object> membershipInfo = isAuthenticated ? buildMembershipInfo(u) : null;

        // ---- Event registration info + nested event info ------------------
        Map<String, Object> eventInfo = buildEventInfo(ev);
        Map<String, Object> eventReg = buildEventReg(ev, eventInfo);

        // ---- Screen info --------------------------------------------------
        Map<String, Object> screenInfo = new Map<String, Object>{
            'isAuthenticated'    => isAuthenticated,
            'locations'          => skipInst ? new List<Country_Code__c>() : selector.getCountryCodesMap().values(),
            'companies'          => skipInst ? new List<Institution__c>() : selector.getInstitutions(rt(Institution__c.SObjectType, 'Organization')),
            'schools'            => skipInst ? new List<Institution__c>() : selector.getInstitutions(rt(Institution__c.SObjectType, 'Academic')),
            'professionalLevels' => picklistLabels('Contact', 'Corporate_Title__c'),
            'jobFunctions'       => picklistLabels('Contact', 'Job_Function__c'),
            'riskSpecialties'    => picklistLabels('Contact', 'Risk_Specialty__c'),
            'FAQInfo'            => null
        };

        // ---- Stripe / captcha --------------------------------------------
        GARP_StripeSettings__c s = GARP_EventReg_Stripe.settings();
        Map<String, Object> stripeInfo = new Map<String, Object>{
            'useStripe'         => s != null && s.Use_Stripe__c == true,
            'useStripeTax'      => s != null && s.Use_Stripe_Tax__c == true,
            'clientSideAPIKey'  => s == null ? null : s.Client_Side_API_Key__c
        };

        Form_Session__c fs = new Form_Session__c();
        insert fs;
        Map<String, Object> captchaInfo = new Map<String, Object>{ 'sessionToken' => fs.Id };

        // ---- Program registration info -----------------------------------
        Boolean inviteOnly = ev.Invite_Only__c == true;
        Map<String, Object> programRegistrationInfo = new Map<String, Object>{
            'registrationType'             => 'event',
            'eventType'                    => 'event',
            'eventId'                      => ev.Id,
            'formName'                     => eventReg.get('formKey'),
            'mainMemberProductCode'        => 'CRTM',
            'mainNonMemberProductCode'     => 'CRTNM',
            'eventDiscountProductCode'     => 'EVTDSC',
            'allowMemberPublicRegistration'=> inviteOnly,          // invite-only allows member public reg
            'addressVerificationDisabled'  => inviteOnly,
            'membershipType'               => null
        };

        // ---- Products (membership add-on) --------------------------------
        List<Object> products = buildProducts(membershipInfo, ev.CurrencyIsoCode);

        // ---- Eligibility --------------------------------------------------
        Id authContactId = (isAuthenticated && u != null) ? u.ContactId : null;
        Map<String, Object> elig = computeEligibility(ev, eventReg, authContactId);

        reg.put('eventRegistrationInfo', eventReg);
        reg.put('screenInfo', screenInfo);
        reg.put('membershipInfo', membershipInfo);
        reg.put('products', products);
        reg.put('programRegistrationInfo', programRegistrationInfo);
        reg.put('stripeInfo', stripeInfo);
        reg.put('captchaInfo', captchaInfo);
        // Registration code -> affiliate program (preferred) or team-registration deal.
        Map<String, Object> teamRegInfo = null;
        String affiliateCode = null;
        if (String.isNotBlank(regCode)) {
            Affiliate_Program__c aff = selector.getAffiliateProgram(regCode);
            if (aff != null) {
                affiliateCode = aff.Affiliate_Code__c;
            } else {
                B2B_Deal_Item__c deal = selector.getTeamDealByCode(regCode);
                if (deal != null) {
                    Boolean seatsLeft = deal.Seats_Allowed__c == null
                        || deal.Opportunities__r == null
                        || deal.Opportunities__r.size() < deal.Seats_Allowed__c;
                    teamRegInfo = new Map<String, Object>{
                        'teamRegCode' => deal.Access_Code__c,
                        'teamRegId' => deal.Id,
                        'isComplimentary' => false,
                        'isBundle' => false,
                        'authenticationRequired' => false,
                        'seatsAvailable' => seatsLeft
                    };
                }
            }
        }
        reg.put('teamRegInfo', teamRegInfo);
        reg.put('affiliateCode', affiliateCode);
        reg.put('examSelectionInfo', null);
        reg.put('isEligible', elig.get('isEligible'));
        reg.put('notEligibleErrorMessage', elig.get('message'));
        return JSON.serialize(reg, true);
    }

    /* ===================== eventInfo ===================== */

    private Map<String, Object> buildEventInfo(Event__c ev) {
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

        Map<String, Object> ei = new Map<String, Object>{
            'eventId'                 => ev.Id,
            'eventType'               => 'event',
            'currencyIsoCode'         => String.isNotBlank(ev.CurrencyIsoCode) ? ev.CurrencyIsoCode : 'USD',
            'title'                   => ev.Title__c,
            'description'             => ev.Description__c,
            'chapterName'             => null,
            'deliveryMode'            => deliveryMode,
            'deliveryModeDescription' => formatDeliveryMode(deliveryMode),
            'startDateTime'           => ev.Start_Date__c,
            'endDateTime'             => ev.End_Date__c,
            'lastDateToRegister'      => ev.Last_Date_For_Registration__c,
            'timeZone'                => ev.Time_Zone__r != null ? ev.Time_Zone__r.Name : null,
            'locationDescription'     => location,
            'venueName'               => ev.VenueName__c,
            'isOnDemand'              => isOnDemand,
            'onlineMeetingURL'        => ev.Online_Meeting_URL__c,
            'ON24APIKey'              => ev.ON24_API_Key__c,
            'ON24URL'                 => ev.ON24_URL__c,
            'ON24Id'                  => ev.ON24_Event_Id__c,
            'sponsorName'             => ev.Event_Sponsor__c,
            'sponsorPolicyURL'        => ev.Event_Sponsor_Policy_URL__c,
            'isSponsored'             => ev.Is_Sponsored_Event__c == true,
            'isInviteOnly'            => ev.Invite_Only__c == true,
            'Max_Capacity_Met__c'     => ev.Max_Capacity_Met__c == true
        };

        // Formatted dates + add-to-calendar.
        if (ev.Start_Date__c != null && ev.End_Date__c != null) {
            String startDate = ev.Start_Date__c.format('MMMM d, yyyy');
            String endDate = ev.End_Date__c.format('MMMM d, yyyy');
            String startTime = ev.Start_Date__c.format('h:mm a');
            String endTime = ev.End_Date__c.format('h:mm a');
            ei.put('startDate', startDate);
            ei.put('startTime', startTime);
            ei.put('endDate', endDate);
            ei.put('endTime', endTime);
            ei.put('addToCalStartDateTime', ev.Start_Date__c.format('yyyy-MM-dd h:mm a'));
            ei.put('addToCalEndDateTime', ev.End_Date__c.format('yyyy-MM-dd h:mm a'));
            if (startDate == endDate) {
                ei.put('dateDescription', startDate);
                ei.put('timeDescription', startTime + ' - ' + endTime);
            } else {
                ei.put('dateDescription', ev.Start_Date__c.format('MMMM d') + ', ' + startTime + ' - ' +
                                          ev.End_Date__c.format('MMMM d') + ', ' + endTime);
                ei.put('timeDescription', '');
            }
        }

        // Add-to-calendar description.
        String addToCalDescription = '';
        if (ev.Description__c != null) {
            addToCalDescription = ev.Description__c;
            if (ev.ON24_URL__c != null) { addToCalDescription += '<br/>' + ev.ON24_URL__c; }
        } else if (ev.ON24_URL__c != null) {
            addToCalDescription = ev.Title__c;
        }
        ei.put('addToCalDescription', addToCalDescription);

        // RSVP activity ("Pre Event Dinner") detail block.
        ei.put('rsvpActivityName', ev.RSVP_Activity_Name__c);
        ei.put('rsvpActivityDetail', ev.RSVP_Activity_Details__c);
        ei.put('rsvpActivityStartDateTime', ev.RSVP_Activity_Start_Date_Time__c);
        ei.put('rsvpActivityEndDateTime', ev.RSVP_Activity_End_Date_Time__c);
        ei.put('rsvpActivityLocation', ev.RSVP_Activity_Location__c);
        ei.put('rsvpActivityMeetingURL', ev.RSVP_Activity_Online_Meeting_URL__c);

        String actMode;
        Boolean hasLoc = ev.RSVP_Activity_Location__c != null;
        Boolean hasUrl = ev.RSVP_Activity_Online_Meeting_URL__c != null;
        if (hasLoc && !hasUrl) { actMode = 'In-Person'; }
        else if (!hasLoc && hasUrl) { actMode = 'Online'; }
        else if (hasLoc && hasUrl) { actMode = 'Hybrid'; }
        ei.put('rsvpActivityMode', actMode);

        String actCalDesc = ev.RSVP_Activity_Details__c;
        if (hasUrl) {
            actCalDesc = actCalDesc == null ? ev.RSVP_Activity_Online_Meeting_URL__c
                                            : actCalDesc + '<br/>' + ev.RSVP_Activity_Online_Meeting_URL__c;
        }
        ei.put('rsvpActivityAddToCalDescription', actCalDesc);

        if (ev.RSVP_Activity_Start_Date_Time__c != null && ev.RSVP_Activity_End_Date_Time__c != null) {
            ei.put('rsvpActivityDateDescription', ev.RSVP_Activity_Start_Date_Time__c.format('MMMM d, yyyy'));
            ei.put('rsvpActivityTimeDescription',
                ev.RSVP_Activity_Start_Date_Time__c.format('h:mm a') + ' - ' + ev.RSVP_Activity_End_Date_Time__c.format('h:mm a'));
            ei.put('rsvpActivityAddToCalStartDateTime', ev.RSVP_Activity_Start_Date_Time__c.format('yyyy-MM-dd h:mm a'));
            ei.put('rsvpActivityAddToCalEndDateTime', ev.RSVP_Activity_End_Date_Time__c.format('yyyy-MM-dd h:mm a'));
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

    private Map<String, Object> buildEventReg(Event__c ev, Map<String, Object> eventInfo) {
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

        // Load the bundled event's info so the Event Bundle section can render.
        Map<String, Object> bundledRegInfo = null;
        Boolean bundledEligible = false;
        if (isBundled && bundledEventId != null) {
            Event__c bev = selector.getEventForLoad(bundledEventId);
            if (bev != null) {
                bundledRegInfo = new Map<String, Object>{ 'eventId' => bev.Id, 'eventInfo' => buildEventInfo(bev) };
                bundledEligible = true;
            }
        }

        // Promo codes available for this event (drives the PROMO CODE section).
        List<Object> eventPromos = new List<Object>();
        for (Event_Discount__c d : selector.getEventDiscounts(ev.Id)) {
            eventPromos.add(new Map<String, Object>{
                'discountCode' => d.Discount_Code__c,
                'startDate' => d.Start_Date__c,
                'endDate' => d.End_Date__c
            });
        }
        Boolean hasPromoCodes = !eventPromos.isEmpty();

        // RSVP activity flags: legacy leaves them null when there is no activity.
        Boolean hasActivity = ev.RSVP_Activity_Name__c != null || ev.RSVP_Activity_Ask_Diet_Restrictions__c == true;
        Object actAsk = hasActivity ? (Object) true : null;
        Object actDiet = hasActivity ? (Object) (ev.RSVP_Activity_Ask_Diet_Restrictions__c == true) : null;
        Object actQuestion = hasActivity ? (Object) (ev.RSVP_Activity_Question__c != null) : null;

        return new Map<String, Object>{
            'eventInfo'                        => eventInfo,
            'eventId'                          => ev.Id,
            'formKey'                          => eventInfo.get('formKey') != null ? eventInfo.get('formKey')
                                                   : (ev.Content__r != null && ev.Content__r.Form__r != null ? ev.Content__r.Form__r.Form_Name__c : null),
            'isPayForEvent'                    => isPayForEvent,
            'foundRates'                       => foundRates,
            'hasPromoCodes'                    => hasPromoCodes,
            'eventPromos'                      => eventPromos,
            'maxCapacityMet'                   => maxCapacityMet,
            'wireAllowed'                      => wireAllowed,
            'rsvpCopy'                         => ev.RSVP_Copy__c,
            'rsvpWaitingListCopy'              => ev.RSVP_Waitlist_Copy__c,
            'rsvpActivityAsk'                  => actAsk,
            'rsvpActivityName'                 => ev.RSVP_Activity_Name__c,
            'rsvpActivityAskDiet'             => actDiet,
            'rsvpActivityAskQuestion'          => actQuestion,
            'rsvpActivityQuestion'             => ev.RSVP_Activity_Question__c,
            'eventQuestionTitle'               => ev.Event_Question_Title__c,
            'eventQuestionDetail'              => ev.Event_Question_Detail__c,
            'vatProductCode'                   => ev.VAT_Product_Code__c,
            'isProfessionDetailsTitleRequested'=> ev.Professional_Details_Request_Title__c == true,
            'isProfessionDetailsRequired'      => ev.Professional_Details_Required__c == true,
            'isBundledEvent'                   => isBundled,
            'bundledEventId'                   => bundledEventId,
            'bundledEventRegistrationInfo'     => bundledRegInfo,
            'isBundledEventEligible'           => bundledEligible,
            'isMembersOnly'                    => false,
            'isSCRHolderRequired'              => false,
            'isRAIHolderRequired'              => false,
            'isFRMCertifiedRequired'           => false,
            'isERPCertifiedRequired'           => false,
            'isMembershipPurchaseRequired'     => false,
            'isAuthenticationRequired'         => false
        };
    }

    /* ===================== membershipInfo (authenticated) ===================== */

    private Map<String, Object> buildMembershipInfo(User u) {
        Map<String, Object> mi = new Map<String, Object>();

        // Full contact record so the LWC can pre-populate Individual + Professional Details.
        Contact con = selector.getContactForPrefill(u.ContactId);
        Map<String, Object> contactRecord = new Map<String, Object>{
            'FirstName' => con != null ? con.FirstName : (u.Contact != null ? u.Contact.FirstName : null),
            'LastName'  => con != null ? con.LastName : (u.Contact != null ? u.Contact.LastName : null),
            'Email' => con != null ? con.Email : null,
            'Phone' => con != null ? con.Phone : null,
            'MobilePhone' => con != null ? con.MobilePhone : null,
            'Mobile_Phone_Code__c' => con != null ? con.Mobile_Phone_Code__c : null,
            'SMS_Registration_Updates__c' => con != null ? con.SMS_Registration_Updates__c : null,
            'SMS_Promotional_Updates__c' => con != null ? con.SMS_Promotional_Updates__c : null,
            'Title' => con != null ? con.Title : null,
            'Company__c' => con != null ? con.Company__c : null,
            'Business_Contact_Email__c' => con != null ? con.Business_Contact_Email__c : null,
            'Corporate_Title__c' => con != null ? con.Corporate_Title__c : null,
            'Job_Function__c' => con != null ? con.Job_Function__c : null,
            'Risk_Specialty__c' => con != null ? con.Risk_Specialty__c : null,
            'MailingStreet' => con != null ? con.MailingStreet : null,
            'MailingCity' => con != null ? con.MailingCity : null,
            'MailingState' => con != null ? con.MailingState : null,
            'MailingPostalCode' => con != null ? con.MailingPostalCode : null,
            'MailingCountry' => con != null ? con.MailingCountry : null,
            'Mailing_Address_Company__c' => con != null ? con.Mailing_Address_Company__c : null
        };
        mi.put('contactRecord', contactRecord);

        Boolean isMember = false;
        Boolean inGoodStanding = false;
        Boolean autoRenew = false;
        String currentMemberType;
        for (Contract c : selector.getActiveMembershipContracts(u.AccountId)) {
            if (c.RecordType != null && c.RecordType.Name == 'Membership') {
                isMember = true;
                currentMemberType = c.Membership_Type__c;
                // Good standing + auto-renew only for an active Individual membership (legacy rule).
                if (c.Membership_Type__c == 'Individual' && (c.Status == 'Activated' || c.Status == 'Activated ( Auto-Renew )')) {
                    inGoodStanding = true;
                    if (c.Status == 'Activated ( Auto-Renew )') { autoRenew = true; }
                }
            }
        }
        mi.put('isMember', isMember);
        mi.put('currentMemberType', currentMemberType);
        mi.put('isInGoodStanding', inGoodStanding);
        mi.put('isAutoRenewMembershipEnabled', autoRenew);
        // Certified professional (FRM/ERP) -> the certified membership rate (MEMC) is offered
        // instead of the standard rate (MEMI). Legacy parity: cert holders join at the MEMC price.
        Boolean isCertified = con != null &&
            (con.KPI_FRM_Certified__c == true || con.KPI_ERP_Certified__c == true);
        mi.put('isCertified', isCertified);
        return mi;
    }

    /* ===================== products (membership add-on) ===================== */

    private List<Object> buildProducts(Map<String, Object> membershipInfo, String currencyIso) {
        List<Object> products = new List<Object>();
        Boolean certified = membershipInfo != null && membershipInfo.get('isCertified') == true;
        String code = certified ? 'MEMC' : 'MEMI';
        // Price the membership upsell in the event currency so the displayed amount
        // matches what getRegistrationFees would actually bill for this event.
        Map<String, PricebookEntry> pbes = selector.getPricebookEntriesByCodes(new Set<String>{ 'MEMI', 'MEMC' }, currencyIso);
        for (PricebookEntry p : pbes.values()) {
            if (p.Product2.ProductCode == code) {
                products.add(new Map<String, Object>{
                    'productCode'         => p.Product2.ProductCode,
                    'productName'         => p.Product2.Name,
                    'priceId'             => p.Id,
                    'amount'              => p.UnitPrice,
                    'isMembershipProduct' => true
                });
            }
        }
        return products;
    }

    /* ===================== eligibility ===================== */

    private Map<String, Object> computeEligibility(Event__c ev, Map<String, Object> eventReg, Id authContactId) {
        Boolean isOnDemand = (Boolean) ((Map<String, Object>) eventReg.get('eventInfo')).get('isOnDemand');
        if (isOnDemand == true) { return eligible(); }

        Boolean isPayForEvent = (Boolean) eventReg.get('isPayForEvent');
        Boolean foundRates = (Boolean) eventReg.get('foundRates');
        if ((isPayForEvent && !foundRates) ||
            (ev.Last_Date_For_Registration__c != null && Date.today() > ev.Last_Date_For_Registration__c)) {
            return notEligible('Registration is currently not available');
        }
        if ((Boolean) eventReg.get('maxCapacityMet') == true) {
            return notEligible('Maximum capacity has been met');
        }
        // Authenticated user who already paid for this event cannot re-register.
        if (isPayForEvent && authContactId != null && selector.hasPaidRegistration(ev.Id, authContactId)) {
            return notEligible('Already registered and paid for this event');
        }
        return eligible();
    }

    private Map<String, Object> eligible() {
        return new Map<String, Object>{ 'isEligible' => true, 'message' => null };
    }
    private Map<String, Object> notEligible(String msg) {
        return new Map<String, Object>{ 'isEligible' => false, 'message' => msg };
    }

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