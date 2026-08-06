/**
 * Business logic for the optimized event-registration module.
 *
 * Holds the paths that are REIMPLEMENTED standalone (no dependency on the legacy
 * GARP_BC_* classes):
 *   - getEventCompletionInfo : confirmation-page event detail
 *   - verifyAddress          : country-rule / structural address validation
 *   - setRSVPInviteOnlyDecline : invite-only decline record
 *
 * All SOQL is delegated to GARP_EventReg_Selector. The only outside touchpoint
 * is GARP_EventReg_Gateway.isStripeTaxEnabled() (the address-validation kill
 * switch), which keeps GARP_StripeClass out of this class.
 */
public without sharing class GARP_EventReg_Service {

    private static final Integer ADDRESS_FIELD_MAX = 32;
    private static final String  RSVP_DECLINE_STATUS = 'RSVP Decline';

    private final GARP_EventReg_Selector selector;
    private final GARP_EventReg_Gateway  gateway;

    public GARP_EventReg_Service() {
        this.selector = new GARP_EventReg_Selector();
        this.gateway  = new GARP_EventReg_Gateway();
    }

    @TestVisible
    private GARP_EventReg_Service(GARP_EventReg_Selector sel, GARP_EventReg_Gateway gw) {
        this.selector = sel;
        this.gateway  = gw;
    }

    /* ===================== Confirmation-page event detail ===================== */

    /**
     * Builds the confirmation payload for a completed registration. `eventType`
     * is one of 'event' (default), 'chaptermeeting', or 'webcast'.
     */
    public GARP_EventReg_Dto.EventCompletionInfo getEventCompletionInfo(String eventId, String eventType) {
        GARP_EventReg_Dto.EventCompletionInfo info = new GARP_EventReg_Dto.EventCompletionInfo();
        info.eventId = eventId;
        String type = String.isBlank(eventType) ? 'event' : eventType.toLowerCase();
        info.eventType = type;

        if (type == 'chaptermeeting') {
            Chapter_Meeting__c cm = selector.getChapterMeeting(eventId);
            if (cm == null) return info;
            info.found = true;
            info.title = cm.Chapter_Meeting_Name__c;
            info.description = cm.Synopsis__c;
            info.chapterName = cm.Chapter__r != null ? cm.Chapter__r.Name : null;
            info.deliveryMode = cm.Delivery_Method__c;
            info.startDateTime = cm.Start__c;
            info.endDateTime = cm.End__c;
            info.timeZone = cm.Time_Zone__r != null ? cm.Time_Zone__r.Name : null;
            info.locationDescription = cm.Chapter_Meeting_Location__r != null
                ? cm.Chapter_Meeting_Location__r.Name : (cm.Content__r != null ? cm.Content__r.Location__c : null);
            info.onlineMeetingURL = cm.Virtual_Meeting_URL__c;
            info.on24Url = cm.ON24_URL__c;
            info.on24Id = cm.ON24_Event_Id__c;
            info.on24ApiKey = cm.ON24_API_Key__c;
            info.isSponsored = cm.Is_Sponsored__c == true;
            info.sponsorName = cm.Sponsor_Name__c;
            info.formKey = (cm.Content__r != null && cm.Content__r.Form__r != null)
                ? cm.Content__r.Form__r.Form_Name__c : null;
        } else if (type == 'webcast') {
            Webcast__c wc = selector.getWebcast(eventId);
            if (wc == null) return info;
            info.found = true;
            info.title = wc.Title__c;
            info.description = String.isNotBlank(wc.Description__c) ? wc.Description__c : wc.Short_Description__c;
            info.startDateTime = wc.Start_Date__c;
            info.endDateTime = wc.End_Date__c;
            info.timeZone = wc.Time_Zone__r != null ? wc.Time_Zone__r.Name : null;
            info.isOnDemand = String.isNotBlank(wc.On_Demand_URL__c);
            info.onlineMeetingURL = wc.On_Demand_URL__c;
            info.on24ApiKey = wc.X0n24_API_Key__c;
            info.isSponsored = wc.Is_Sponsored__c == true;
            info.sponsorName = wc.Sponsor_Name__c;
            info.sponsorPolicyURL = wc.Sponsor_Policy_URL__c;
            info.formKey = (wc.Content__r != null && wc.Content__r.Form__r != null)
                ? wc.Content__r.Form__r.Form_Name__c : null;
        } else {
            Event__c ev = selector.getEvent(eventId);
            if (ev == null) return info;
            info.found = true;
            info.title = ev.Title__c;
            info.description = ev.Description__c;
            info.deliveryMode = ev.Delivery_Method__c;
            info.startDateTime = ev.Start_Date__c;
            info.endDateTime = ev.End_Date__c;
            info.timeZone = ev.Time_Zone__r != null ? ev.Time_Zone__r.Name : null;
            info.locationDescription = firstNonBlank(new List<String>{
                ev.VenueName__c, ev.Custom_Location__c, ev.Address__c });
            info.onlineMeetingURL = ev.Online_Meeting_URL__c;
            info.on24Url = ev.ON24_URL__c;
            info.on24Id = ev.ON24_Event_Id__c;
            info.on24ApiKey = ev.ON24_API_Key__c;
            info.isInviteOnly = ev.Invite_Only__c == true;
            info.isSponsored = ev.Is_Sponsored_Event__c == true;
            info.sponsorName = ev.Event_Sponsor__c;
            info.sponsorPolicyURL = ev.Event_Sponsor_Policy_URL__c;
            info.formKey = (ev.Content__r != null && ev.Content__r.Form__r != null)
                ? ev.Content__r.Form__r.Form_Name__c : null;
        }
        return info;
    }

    /* ===================== Address verification ===================== */

    /**
     * Validates billing (and optionally shipping) address structure and returns
     * per-country payment/shipping eligibility. Mirrors the legacy
     * GARP_BC_Shipping.verifyAddress rules; when Stripe Tax is enabled, field
     * validation is skipped (the tax API validates instead) and only the
     * country-level flags are returned.
     */
    public GARP_EventReg_Dto.VerifyAddressResult verifyAddress(GARP_EventReg_Dto.VerifyAddressRequest req) {
        GARP_EventReg_Dto.VerifyAddressResult res = new GARP_EventReg_Dto.VerifyAddressResult();
        if (req == null || req.billingAddress == null) {
            res.isBillingAddressValid = false;
            res.billingAddressErrors = 'Billing address is required.';
            return res;
        }

        Map<String, Country_Code__c> countries = selector.getCountryCodesMap();
        Boolean separateShipping = req.hasShipping == true && req.billingSameAsShipping == false;

        // Billing country flags.
        Country_Code__c billingCountry = countries.get(req.billingAddress.country);
        if (billingCountry != null) {
            res.isBillingAllowed        = billingCountry.Is_Billing_Allowed__c == true;
            res.isCreditCardAllowed     = billingCountry.Is_Credit_Card_Allowed__c == true;
            res.isWireAllowed           = billingCountry.Is_Wire_Allowed__c == true;
            res.isCheckAllowed          = billingCountry.Is_Check_Allowed__c == true;
            res.postalCodeBillingRequired = billingCountry.Postal_Code_Required__c == true;
            res.provinceBillingRequired = billingCountry.Provence_Required__c == true;
        }

        Country_Code__c shippingCountry = separateShipping
            ? countries.get(req.shippingAddress.country) : billingCountry;
        if (shippingCountry != null) {
            res.isShippingAllowed         = shippingCountry.Is_Shipping_Allowed__c == true;
            res.postalCodeShippingRequired = shippingCountry.Postal_Code_Required__c == true;
            res.provinceShippingRequired  = shippingCountry.Provence_Required__c == true;
        }

        // Stripe Tax kill switch: skip structural validation entirely.
        if (gateway.isStripeTaxEnabled()) {
            return res;
        }

        List<String> billingErrors = validateAddressFields(req.billingAddress, billingCountry);
        res.isBillingAddressValid = billingErrors.isEmpty();
        res.billingAddressErrors  = String.join(billingErrors, ', ');

        if (separateShipping) {
            List<String> shipErrors = validateAddressFields(req.shippingAddress, shippingCountry);
            res.isShippingAddressValid = shipErrors.isEmpty();
            res.shippingAddressErrors  = String.join(shipErrors, ', ');
        }
        return res;
    }

    private List<String> validateAddressFields(GARP_EventReg_Dto.Address addr, Country_Code__c country) {
        List<String> errors = new List<String>();
        if (addr == null) {
            errors.add('Address is required.');
            return errors;
        }
        // Street 1 (required).
        checkField(errors, 'Address Line 1', addr.street1, true);
        // Street 2 / 3 (optional; cannot duplicate a prior line).
        checkField(errors, 'Address Line 2', addr.street2, false);
        if (String.isNotBlank(addr.street2) && addr.street2 == addr.street1) {
            errors.add('Address Line 2 cannot match Address Line 1.');
        }
        checkField(errors, 'Address Line 3', addr.street3, false);
        if (String.isNotBlank(addr.street3) && (addr.street3 == addr.street1 || addr.street3 == addr.street2)) {
            errors.add('Address Line 3 cannot match another address line.');
        }
        // City (required).
        checkField(errors, 'City', addr.city, true);
        // Postal / province per country config.
        if (country != null && country.Postal_Code_Required__c == true && String.isBlank(addr.postalCode)) {
            errors.add('Postal Code is required.');
        }
        if (country != null && country.Provence_Required__c == true && String.isBlank(addr.province)) {
            errors.add('State/Province is required.');
        }
        return errors;
    }

    private void checkField(List<String> errors, String label, String value, Boolean required) {
        if (String.isBlank(value)) {
            if (required) errors.add(label + ' is required.');
            return;
        }
        if (value.length() > ADDRESS_FIELD_MAX) {
            errors.add(label + ' must be ' + ADDRESS_FIELD_MAX + ' characters or fewer.');
        }
        if (hasNonWesternChars(value)) {
            errors.add(label + ' must use Western characters only.');
        }
    }

    /** Matches legacy behaviour: reject any character above the ASCII range. */
    private Boolean hasNonWesternChars(String value) {
        if (String.isBlank(value)) return false;
        for (Integer i = 0; i < value.length(); i++) {
            if (value.substring(i, i + 1).charAt(0) > 127) return true;
        }
        return false;
    }

    /* ===================== RSVP invite-only decline ===================== */

    /**
     * Records an invite-only decline: inserts a new Event_Registration__c (or
     * updates the existing one) with status 'RSVP Decline'. Returns null when the
     * event does not exist or is not invite-only (matches legacy).
     */
    public Event_Registration__c setRSVPInviteOnlyDecline(String eventId, String userEmail) {
        Event__c ev = selector.getEventForRsvp(eventId);
        if (ev == null || ev.Invite_Only__c != true) return null;

        Event_Registration__c reg = selector.getRegistrationByEmail(ev.Id, userEmail);
        if (reg == null) {
            reg = new Event_Registration__c(
                Event__c = ev.Id,
                Member_Email__c = userEmail,
                Status__c = RSVP_DECLINE_STATUS
            );
            insert reg;
        } else {
            reg.Status__c = RSVP_DECLINE_STATUS;
            update reg;
        }
        return reg;
    }

    /* ===================== helpers ===================== */

    private static String firstNonBlank(List<String> values) {
        for (String v : values) {
            if (String.isNotBlank(v)) return v;
        }
        return null;
    }
}