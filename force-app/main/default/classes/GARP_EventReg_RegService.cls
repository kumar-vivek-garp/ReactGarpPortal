/**
 * Standalone registration engine for the EVENT flow — the self-contained
 * replacement for the GARP_BC_Registration delegations in GARP_EventReg_Gateway.
 *
 * Owns: verify-customer, fee calculation (member/non-member event rate + promo +
 * tax), order creation (Account/Contact/Opportunity/OpportunityLineItem +
 * Event_Registration__c), payment (via GARP_EventReg_Stripe), payment-status
 * polling, and rollback. NO dependency on GARP_BC_* / GARP_StripeClass.
 *
 * Method signatures mirror the gateway's (JSON string in/out, same field names)
 * so garpEventRegModernFull works unchanged once the gateway is repointed here.
 *
 * Scope: EVENT registrations (Event__c). Exams/courses/memberships/study
 * materials/team/checkout are later phases.
 *
 * NOTE: record creation targets the org's Account 'Individual' / Contact 'Member'
 * / Opportunity 'Automated' record types and the standard event product codes
 * (CRTM/CRTNM/MEMI/MEMC). Validate against sandbox data before production — org
 * validation rules can require fields this reimplementation doesn't yet set.
 */
public without sharing class GARP_EventReg_RegService {

    private final GARP_EventReg_Selector selector = new GARP_EventReg_Selector();

    private static final String MEMBER_CODE     = 'CRTM';
    private static final String NONMEMBER_CODE  = 'CRTNM';
    private static final String MEMBERSHIP_CODE = 'MEMI';
    private static final String MEMBERSHIP_CERT = 'MEMC';
    private static final String NJ_TAX_CODE     = 'SLSTX';
    private static final String TRANSFER_FEE_CODE = 'PRFEE';

    public class RegServiceException extends Exception {}

    /* ===================== verifyExistingCustomer ===================== */

    public String verifyExistingCustomer(String requestJson) {
        GARP_EventReg_Dto.VerifyCustomerRequest req =
            (GARP_EventReg_Dto.VerifyCustomerRequest) JSON.deserialize(requestJson, GARP_EventReg_Dto.VerifyCustomerRequest.class);

        GARP_EventReg_Dto.VerifyCustomerResult res = new GARP_EventReg_Dto.VerifyCustomerResult();
        res.status = 'Success';

        List<Contact> contacts = selector.getContactsByEmail(req.email);
        res.isCustomer = false;
        if (!contacts.isEmpty()) {
            Contact c = contacts[0];
            res.contactId = c.Id;
            res.accountId = c.AccountId;
            // "Customer" = an existing MEMBER, matching legacy exactly
            // (GARP_BC_Registration.verifyExistingCustomer sets isCustomer = isMember): a
            // Member-record-type contact whose account holds a Membership contract in
            // Activated / Auto-Renew / Expired status. This is deliberately NOT "a User record
            // exists for the email" — a bare login/lead must not trigger the sign-in gate, so a
            // non-member (e.g. testdataevetn@test.com) sees no "you already have a GARP account"
            // prompt, just like legacy.
            if (c.AccountId != null && c.RecordTypeId == rt(Contact.SObjectType, 'Member')) {
                for (Contract ct : selector.getActiveMembershipContracts(c.AccountId)) {
                    if (ct.RecordType != null && ct.RecordType.Name == 'Membership') { res.isCustomer = true; break; }
                }
            }
        }

        // Persist a lightweight form session so the order step can be correlated.
        Form__c form = selector.getFormByName(req.formKey);
        if (form != null) {
            // Field set mirrors legacy GARP_BC_Registration.setFormSession (the verify path):
            // Form, Email, First/Last name, Status, UTM_*, Track_CTA, and Contact when known.
            // NOTE: legacy setFormSession does NOT set Company__c here (only the unrelated
            // manageFormData path did, with a first+first bug), so we leave it unset to match.
            Form_Data__c fd = new Form_Data__c(
                Form__c = form.Id,
                Email__c = req.email,
                First_Name__c = req.firstName,
                Last_Name__c = req.lastName,
                Status__c = 'Abandoned',
                UTM_Campaign__c = req.utm_campaign,
                UTM_Content__c = req.utm_content,
                UTM_Medium__c = req.utm_medium,
                UTM_Source__c = req.utm_source,
                UTM_Term__c = req.utm_term,
                Track_CTA__c = req.track_cta
            );
            if (res.contactId != null) { fd.Contact__c = res.contactId; }
            insert fd;
            res.sessionId = fd.Id;
        }
        return JSON.serialize(res, true);
    }

    /* ===================== getRegistrationFees ===================== */

    public String getRegistrationFees(String requestJson) {
        GARP_EventReg_Dto.RegRequest req =
            (GARP_EventReg_Dto.RegRequest) JSON.deserialize(requestJson, GARP_EventReg_Dto.RegRequest.class);
        return JSON.serialize(computeFees(req).result, true);
    }

    /** Fee context: the result plus the pricebook entries needed to build line items. */
    private class FeesContext {
        GARP_EventReg_Dto.FeesResult result = new GARP_EventReg_Dto.FeesResult();
        Map<String, PricebookEntry> pbes = new Map<String, PricebookEntry>();
        Id pricebookId;
        Event__c event;
    }

    private FeesContext computeFees(GARP_EventReg_Dto.RegRequest req) {
        FeesContext ctx = new FeesContext();
        GARP_EventReg_Dto.FeesResult r = ctx.result;
        r.promoCodes = req.promoCodes == null ? new List<GARP_EventReg_Dto.PromoCode>() : req.promoCodes;

        String eventId = req.programRegistrationInfo == null ? null : req.programRegistrationInfo.eventId;
        if (String.isBlank(eventId)) { r.status = 'Failed'; r.message = 'No event specified.'; return ctx; }

        ctx.event = selector.getEvent(eventId);
        String currencyIso = (ctx.event != null && String.isNotBlank(ctx.event.CurrencyIsoCode))
            ? ctx.event.CurrencyIsoCode : 'USD';
        r.currencyIsoCode = currencyIso;
        List<Event_Rate__c> rates = selector.getEventRates(eventId);
        Boolean isMember = req.membershipOptions != null && req.membershipOptions.hasSelectedMembership == true;
        Boolean isBundle = req.isEventBundleSelected == true;

        // Resolve which product/amount applies (member vs non-member, bundle vs single).
        String mainCode; String mainGl; Decimal mainAmount; String vatCode;
        if (!rates.isEmpty()) {
            Event_Rate__c rate = rates[0];
            vatCode = rate.Event__r != null ? rate.Event__r.VAT_Product_Code__c : null;
            if (isBundle && isMember && rate.Product_Bundle_Member__r != null) {
                mainCode = rate.Product_Bundle_Member__r.ProductCode;
                mainGl = rate.Product_Bundle_Member__r.GL_Code__c;
                mainAmount = rate.Bundle_Member_Rate__c;
            } else if (isBundle && rate.Product_Bundle_Non_Member__r != null) {
                mainCode = rate.Product_Bundle_Non_Member__r.ProductCode;
                mainGl = rate.Product_Bundle_Non_Member__r.GL_Code__c;
                mainAmount = rate.Bundle_Non_Member_Rate__c;
            } else if (isMember && rate.Product_Member_Code__r != null) {
                mainCode = rate.Product_Member_Code__r.ProductCode;
                mainGl = rate.Product_Member_Code__r.GL_Code__c;
                mainAmount = rate.Member_Rate__c;
            } else if (rate.Product_Non_Member_Code__r != null) {
                mainCode = rate.Product_Non_Member_Code__r.ProductCode;
                mainGl = rate.Product_Non_Member_Code__r.GL_Code__c;
                mainAmount = rate.Non_Member_Rate__c;
            }
        }

        // A free event may still bill an optional membership upsell, so we do NOT
        // bail out when there's no paid event rate — we price membership too.

        // Price-book lookups for every code we might bill.
        Set<String> codes = new Set<String>{ MEMBERSHIP_CODE, MEMBERSHIP_CERT, NJ_TAX_CODE, TRANSFER_FEE_CODE };
        if (String.isNotBlank(mainCode)) { codes.add(mainCode); }
        if (String.isNotBlank(vatCode)) { codes.add(vatCode); }
        ctx.pbes = selector.getPricebookEntriesByCodes(codes, currencyIso);

        Decimal mainLineAmount = 0;

        // Main event line (only when there's a paid rate).
        if (mainCode != null && mainAmount != null) {
            PricebookEntry mainPbe = ctx.pbes.get(mainCode + ':' + mainGl);
            if (mainPbe == null) {
                for (PricebookEntry p : ctx.pbes.values()) { if (p.Product2.ProductCode == mainCode) { mainPbe = p; break; } }
            }
            if (mainPbe == null) { r.status = 'Failed'; r.message = 'Product not found: ' + mainCode; return ctx; }
            ctx.pricebookId = mainPbe.Pricebook2Id;
            GARP_EventReg_Dto.FeeLine main = lineFromPbe(mainPbe, mainAmount);
            main.isMainProduct = true;
            r.feeProducts.add(main);
            mainLineAmount = main.amount;
        }

        // Membership upsell line (applies even to a free event).
        if (isMember) {
            PricebookEntry memPbe = firstPbe(ctx.pbes, MEMBERSHIP_CODE);
            if (memPbe != null) {
                if (ctx.pricebookId == null) { ctx.pricebookId = memPbe.Pricebook2Id; }
                r.feeProducts.add(lineFromPbe(memPbe, memPbe.UnitPrice));
            }
        }

        // Nothing selected on a free event -> no billing.
        if (r.feeProducts.isEmpty()) {
            r.hasBilling = false;
            r.feeProductsForDisplay = r.feeProducts.clone();
            return ctx;
        }

        // Promo code -> discount line (only when there's a main product to discount).
        if (mainCode != null) { applyPromo(req, eventId, mainCode, r); }

        // Wire/Check/ACH processing fee (legacy PRFEE) — flat fee added only when the
        // running charge is positive and the selected payment method is a bank transfer.
        Boolean isTransfer = req.paymentType == 'Wire Transfer' || req.paymentType == 'Check' || req.paymentType == 'ACH';
        if (isTransfer) {
            Decimal running = 0;
            for (GARP_EventReg_Dto.FeeLine l : r.feeProducts) { running += (l.amount == null ? 0 : l.amount); }
            if (running > 0) {
                PricebookEntry prfeePbe = firstPbe(ctx.pbes, TRANSFER_FEE_CODE);
                if (prfeePbe != null) { r.feeProducts.add(lineFromPbe(prfeePbe, prfeePbe.UnitPrice)); }
            }
        }

        // Subtotal (pre-tax).
        Decimal subtotal = 0;
        for (GARP_EventReg_Dto.FeeLine l : r.feeProducts) { subtotal += (l.amount == null ? 0 : l.amount); }

        // Tax (skipped when Stripe Tax is on — Stripe computes it at checkout).
        if (!GARP_EventReg_Stripe.isTaxEnabled()) {
            applyTax(req, subtotal, mainLineAmount, vatCode, ctx);
        }

        // Totals.
        Decimal total = 0;
        for (GARP_EventReg_Dto.FeeLine l : r.feeProducts) { total += (l.amount == null ? 0 : l.amount); }
        r.subTotal = subtotal;
        r.total = total;
        r.hasBilling = total > 0;
        r.hasSubtotal = total != subtotal;
        r.needsShipping = false;
        r.feeProductsForDisplay = r.feeProducts.clone();
        return ctx;
    }

    private void applyPromo(GARP_EventReg_Dto.RegRequest req, String eventId, String mainCode, GARP_EventReg_Dto.FeesResult r) {
        if (req.promoCodes == null || req.promoCodes.isEmpty()) { return; }

        // Mirror legacy GARP_BC_Events.getEventMainProduct: start every entered code as
        // invalid ("This code is not applicable"), then flip to valid only when it matches
        // an active discount that actually reduces the main line. r.promoCodes points at
        // req.promoCodes, so mutating these DTOs is what surfaces the message in the UI.
        Map<String, GARP_EventReg_Dto.PromoCode> byCode = new Map<String, GARP_EventReg_Dto.PromoCode>();
        for (GARP_EventReg_Dto.PromoCode pc : req.promoCodes) {
            if (pc.promoCode == null) { continue; }
            pc.isValid = false;
            pc.message = 'This code is not applicable';
            byCode.put(pc.promoCode.toUpperCase(), pc);
        }
        if (byCode.isEmpty()) { return; }

        // Only discount the main product line.
        GARP_EventReg_Dto.FeeLine mainLine;
        for (GARP_EventReg_Dto.FeeLine l : r.feeProducts) { if (l.isMainProduct) { mainLine = l; break; } }

        for (Event_Discount__c disc : selector.getEventDiscounts(eventId)) {
            if (disc.Discount_Code__c == null) { continue; }
            GARP_EventReg_Dto.PromoCode pc = byCode.get(disc.Discount_Code__c.toUpperCase());
            if (pc == null) { continue; }
            if (disc.Start_Date__c != null && Date.today() < disc.Start_Date__c) { continue; }
            if (disc.End_Date__c != null && Date.today() > disc.End_Date__c) { continue; }
            if (mainLine == null) { continue; }

            Decimal discountAmt = 0;
            if (disc.Discount_To_Fixed_Price__c != null && disc.Discount_To_Fixed_Price__c > 0) {
                discountAmt = mainLine.amount - disc.Discount_To_Fixed_Price__c;
            } else if (disc.Fixed_Amount_Discount__c != null && disc.Fixed_Amount_Discount__c > 0) {
                discountAmt = disc.Fixed_Amount_Discount__c;
            } else if (disc.Fixed_Percentage_Discount__c != null && disc.Fixed_Percentage_Discount__c > 0) {
                discountAmt = (mainLine.amount * disc.Fixed_Percentage_Discount__c / 100).setScale(2);
            }
            if (discountAmt > 0) {
                GARP_EventReg_Dto.FeeLine d = new GARP_EventReg_Dto.FeeLine();
                d.productCode = 'EVTDSC';
                d.productName = 'Discount (' + disc.Discount_Code__c + ')';
                d.amount = -discountAmt;
                r.feeProducts.add(d);
                pc.isValid = true;
                pc.message = 'This code is applicable';
            }
        }
    }

    private void applyTax(GARP_EventReg_Dto.RegRequest req, Decimal subtotal, Decimal mainAmount, String vatCode, FeesContext ctx) {
        GARP_EventReg_Dto.Address bill = req.addressInfo == null ? null : req.addressInfo.billingAddress;
        if (bill == null) { return; }
        Map<String, Country_Code__c> countries = selector.getCountryCodesMap();
        Country_Code__c cc = countries.get(bill.country);

        // NJ sales tax (US / New Jersey), on the taxable subtotal.
        if (cc != null && cc.LetterCode__c == 'US' &&
            (bill.province == 'NJ' || bill.province == 'New Jersey')) {
            PricebookEntry njPbe = firstPbe(ctx.pbes, NJ_TAX_CODE);
            if (njPbe != null && njPbe.Product2.Tax_Rate__c != null) {
                Decimal njTax = (subtotal * njPbe.Product2.Tax_Rate__c / 100).setScale(2);
                if (njTax > 0) {
                    ctx.result.njSalesTax = njTax;
                    GARP_EventReg_Dto.FeeLine t = lineFromPbe(njPbe, njTax);
                    t.isNJSalesTax = true;
                    ctx.result.feeProducts.add(t);
                }
            }
        }

        // Event VAT (percentage of the event ticket price).
        if (cc != null && cc.VAT__c != null && cc.VAT__c > 0 && String.isNotBlank(vatCode)) {
            PricebookEntry vatPbe = firstPbe(ctx.pbes, vatCode);
            Decimal vatAmt = (mainAmount * cc.VAT__c / 100).setScale(2);
            if (vatAmt > 0) {
                GARP_EventReg_Dto.FeeLine v = vatPbe != null ? lineFromPbe(vatPbe, vatAmt) : new GARP_EventReg_Dto.FeeLine();
                v.productCode = vatCode;
                v.productName = 'VAT';
                v.amount = vatAmt;
                v.isVATTax = true;
                ctx.result.vatSalesTax = v;
                ctx.result.feeProducts.add(v);
            }
        }
    }

    /* ===================== setRegistration ===================== */

    public String setRegistration(String requestJson) {
        GARP_EventReg_Dto.RegRequest req =
            (GARP_EventReg_Dto.RegRequest) JSON.deserialize(requestJson, GARP_EventReg_Dto.RegRequest.class);
        GARP_EventReg_Dto.RegResult res = new GARP_EventReg_Dto.RegResult();

        try {
            FeesContext ctx = computeFees(req);
            if (ctx.result.status != 'Success') { res.status = 'Failed'; res.message = ctx.result.message; return JSON.serialize(res, true); }

            GARP_EventReg_Dto.CustomerInfo ci = req.customerInfo;
            String payType = (req.paymentInfo == null) ? req.paymentType : req.paymentInfo.paymentType;

            // Resolve or create the customer.
            Id contactId = String.isNotBlank(ci.contactId) ? (Id) ci.contactId : null;
            Id accountId = String.isNotBlank(ci.accountId) ? (Id) ci.accountId : null;
            Boolean createdNewContact = false;
            if (contactId == null) {
                List<Contact> existing = selector.getContactsByEmail(ci.email);
                if (!existing.isEmpty()) { contactId = existing[0].Id; accountId = existing[0].AccountId; }
            }
            if (contactId == null) {
                Account acct = new Account(
                    Name = trimName(ci.firstName, ci.lastName),
                    Member_First_Name__c = ci.firstName,
                    Member_Last_Name__c = ci.lastName,
                    Member_Email__c = ci.email,
                    Type = 'Customer',
                    RecordTypeId = rt(Account.SObjectType, 'Individual')
                );
                insert acct;
                accountId = acct.Id;
                Contact con = new Contact(
                    FirstName = ci.firstName, LastName = ci.lastName, Email = ci.email,
                    AccountId = accountId, RecordTypeId = rt(Contact.SObjectType, 'Member'),
                    // Legacy parity (GARP_BC_Orders.setOrder): suppress Contact automation
                    // (portal-user enablement, etc.) while the order is only pending. It is
                    // re-enabled ONLY after payment succeeds — by the Stripe webhook for paid
                    // orders (GARP_StripeClass.processWebhook sets DO_NOT_FIRE__c = false), or
                    // below for free registrations. So a cancelled/abandoned checkout never
                    // enables a portal user, exactly like legacy.
                    DO_NOT_FIRE__c = true
                );
                applyContactDetails(con, req);   // phone/company/professional details on the new contact
                insert con;
                contactId = con.Id;
                createdNewContact = true;
            } else {
                // Existing contact — enrich with the details the form collected (legacy parity:
                // GARP_BC_Orders updates the contact). Only non-blank values are written so a
                // partially-filled form never wipes existing CRM data.
                updateExistingContactDetails(contactId, req);
            }

            // Create the order (Opportunity).
            Opportunity opp = new Opportunity(
                Name = 'GARP Order',
                AccountId = accountId,
                StageName = 'New Lead',
                CloseDate = Date.today(),
                RecordTypeId = rt(Opportunity.SObjectType, 'Automated'),
                Alternate_Method_of_Payment__c = mapPayType(req.paymentInfo == null ? req.paymentType : req.paymentInfo.paymentType),
                Billing_First_Name__c = ci.firstName,
                Billing_Last_Name__c = ci.lastName,
                Billing_Email__c = ci.email,
                Billing_Phone__c = ci.phone
            );
            // Auto-renew opt-in (legacy Opportunity.Auto_Renew__c parity) — the downstream
            // OpportunityHandler sets up the recurring charge on order close.
            if (req.membershipOptions != null && req.membershipOptions.autoRenew == true) {
                opp.Auto_Renew__c = true;
            }
            // Attribution: carry the campaign CTA onto the order (legacy Order_Summary_CTA__c).
            if (ci.track_cta != null) { opp.Order_Summary_CTA__c = ci.track_cta; }
            // Match the order to the event currency so its price book and line items
            // (all sourced from the same-currency GARP price book) stay consistent.
            if (ctx.event != null && String.isNotBlank(ctx.event.CurrencyIsoCode)) {
                opp.put('CurrencyIsoCode', ctx.event.CurrencyIsoCode);
            }
            if (ctx.pricebookId != null) { opp.Pricebook2Id = ctx.pricebookId; }
            applyBillingAddress(opp, req);
            insert opp;

            // Line items.
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
            for (GARP_EventReg_Dto.FeeLine l : ctx.result.feeProducts) {
                if (String.isBlank(l.priceId)) { continue; } // discounts/taxes without a PBE are folded into totals only
                olis.add(new OpportunityLineItem(
                    OpportunityId = opp.Id,
                    PricebookEntryId = l.priceId,
                    Quantity = 1,
                    UnitPrice = l.amount == null ? 0 : l.amount,
                    Product_Family__c = l.productFamily
                ));
            }
            if (!olis.isEmpty()) { insert olis; }

            // Opportunity contact role (legacy GARP_BC_Orders.setOrder parity).
            if (contactId != null) {
                try {
                    insert new OpportunityContactRole(
                        OpportunityId = opp.Id, ContactId = contactId, Role = 'Decision Maker'
                    );
                } catch (Exception roleEx) {
                    System.debug('GARP_EventReg_RegService.setRegistration contact role failed: ' + roleEx.getMessage());
                }
            }

            // Event registration record.
            Id regId = createEventRegistration(req, ctx, contactId, opp.Id, payType);

            // Free registration has no payment step, so it is complete now — enable the
            // Contact automation the way legacy payOrder does on a $0/success order (so the
            // member's portal user is provisioned). Paid orders stay suppressed until the
            // payment webhook (Stripe) or finance re-enables them. Only the contact we just
            // created is touched, to avoid re-firing automation on an existing member.
            Boolean isPaidReg = ctx.result.total != null && ctx.result.total > 0;
            if (!isPaidReg && createdNewContact && contactId != null) {
                try {
                    update new Contact(Id = contactId, DO_NOT_FIRE__c = false);
                } catch (Exception e) {
                    System.debug('GARP_EventReg_RegService free-reg contact enable failed: ' + e.getMessage());
                }
            }

            // Form_Data close/migrate — legacy parity (GARP_BC_Orders.setOrder ->
            // migrateFormDataToContact, then closeFormData). The Form_Data record was created
            // 'Abandoned' by verifyExistingCustomer (its Id rides back as customerInfo.sessionId).
            // Link it to the new Contact + Opportunity, and mark it 'Completed' now for every
            // payment type EXCEPT Stripe: Wire/ACH/free finalize at submit (legacy payOrder ->
            // closeFormData), while Stripe stays 'Abandoned' until GARP_StripeClass.processWebhook
            // fires closeFormData(NULL, opp) on payment success — which can only find it because
            // we set Opportunity__c here. Marking Status='Completed' triggers formDataTrigger ->
            // formDataTriggerHelper, which maps the form data onto the Contact/Lead.
            String formDataId = (ci == null) ? null : ci.sessionId;
            if (String.isNotBlank(formDataId)) {
                try {
                    // Legacy parity (migrateFormDataToContact + closeFormData): link the
                    // Form_Data to the Contact + Opportunity and mark it Completed. Legacy sets
                    // BOTH the Opportunity lookup and the OpportunityId__c text mirror.
                    Form_Data__c fd = new Form_Data__c(
                        Id = (Id) formDataId,
                        Contact__c = contactId,
                        Opportunity__c = opp.Id,
                        OpportunityId__c = opp.Id,
                        Status__c = (payType == 'Stripe') ? 'Abandoned' : 'Completed'
                    );
                    update fd;
                } catch (Exception fdEx) {
                    // Never fail the registration because form-data housekeeping failed.
                    System.debug('GARP_EventReg_RegService.setRegistration Form_Data close failed: ' + fdEx.getMessage());
                }
            }

            // ON24 attendee push for FREE events (legacy GARP_BC_Events.createRegistrations:
            // free/non-paid events register the attendee inline; paid events are pushed by the
            // shared Opp-close automation after payment). Best-effort — never fails registration.
            Boolean isPaidOrder = ctx.result.total != null && ctx.result.total > 0;
            if (!isPaidOrder && ctx.event != null && String.isNotBlank(ctx.event.ON24_Event_Id__c) && contactId != null) {
                pushOn24Registration(contactId, ctx.event.ON24_Event_Id__c, ctx.event.ON24_API_Key__c, regId);
            }

            // Fire Member Profile Summary Update (legacy GARP_BC_Registration.payOrder parity).
            if (contactId != null) {
                try {
                    EventBus.publish(new Member_Profile_Update__e(Contact_ID__c = contactId));
                } catch (Exception evtEx) {
                    System.debug('GARP_EventReg_RegService.setRegistration profile event failed: ' + evtEx.getMessage());
                }
            }

            // Return.
            Opportunity saved = [SELECT Id, Amount, Display_Invoice_Number__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            res.status = 'Success';
            res.message = 'Registration created';
            res.contactId = contactId;
            res.accountId = accountId;
            res.orderId = opp.Id;
            res.registrationId = regId;
            res.orderNumber = saved.Display_Invoice_Number__c;
            res.total = saved.Amount;
        } catch (Exception e) {
            res.status = 'Failed';
            res.message = e.getMessage();
        }
        return JSON.serialize(res, true);
    }

    private Id createEventRegistration(GARP_EventReg_Dto.RegRequest req, FeesContext ctx, Id contactId, Id orderId, String payType) {
        Boolean inviteOnly = ctx.event != null && ctx.event.Invite_Only__c == true;
        Boolean isPaid = ctx.result.total != null && ctx.result.total > 0;

        Event_Registration__c reg = new Event_Registration__c(
            Event__c = req.programRegistrationInfo.eventId,
            Contact__c = contactId,
            Member_Email__c = req.customerInfo.email,
            Opportunity__c = orderId,
            Event_Registration_Date__c = DateTime.now(),
            Attendee_Type__c = 'Participant',
            Event_Bundle_Registration__c = req.isEventBundleSelected == true
        );
        // Status parity with legacy payOrderSuccessComplete: invite-only -> 'RSVP Accept';
        // Stripe stays null until the payment webhook finalizes it; every other path
        // (free, Wire, ACH, Check) is confirmed 'Registered' at submit — so the
        // registration-email flows fire and B2B seat counts advance without waiting on Stripe.
        Boolean pendingStripe = isPaid && payType == 'Stripe';
        reg.Status__c = inviteOnly ? 'RSVP Accept' : (pendingStripe ? null : 'Registered');

        if (req.eventOptions != null) {
            reg.Attendance_Method__c = req.eventOptions.attendanceMethod;
            reg.RSVP_Activity_Attending__c = req.eventOptions.willAttendRSVPActivity == true;
            if (String.isNotBlank(req.eventOptions.dietaryRestrictionDetails)) {
                reg.Dietary_Restriction__c = true;
                reg.Dietary_Restriction_Description__c = req.eventOptions.dietaryRestrictionDetails;
            }
            reg.RSVP_Activity_Question_Response__c = req.eventOptions.activityQuestionResponse;
            reg.Event_Question_Response__c = req.eventOptions.eventQuestionResponse;
        }
        if (req.consentInfo != null) {
            if (req.consentInfo.privacyPolicyAttestation == true) { reg.Privacy_Policy_Attestation__c = System.now(); }
            if (req.consentInfo.sponsorContentAttestation == true) { reg.Sponsor_Information_Exchange_Attestation__c = System.now(); }
            if (req.consentInfo.valuableContentAttestation == true) { reg.GARP_Information_Exchange_Attestation__c = System.now(); }
        }
        if (req.promoCodes != null && !req.promoCodes.isEmpty()) {
            reg.Discount_Code_Used__c = req.promoCodes[0].promoCode;
        }
        insert reg;
        return reg.Id;
    }

    /* ===================== payOrder ===================== */

    public String payOrder(String requestJson) {
        GARP_EventReg_Dto.RegRequest req =
            (GARP_EventReg_Dto.RegRequest) JSON.deserialize(requestJson, GARP_EventReg_Dto.RegRequest.class);
        GARP_EventReg_Dto.RegResult res = new GARP_EventReg_Dto.RegResult();

        String payType = req.paymentInfo == null ? req.paymentType : req.paymentInfo.paymentType;
        res.orderId = req.paymentInfo == null ? null : req.paymentInfo.existingOrderId;

        // Stripe: the Checkout Session is created by garpStripeCheckout / GARP_EventReg_Stripe,
        // and the order is marked paid by the webhook. Here we just acknowledge.
        // Wire/ACH/Check: order stays pending until finance processes it.
        res.status = 'Success';
        res.message = (payType == 'Stripe') ? 'Proceed to Stripe checkout' : 'Order submitted';
        return JSON.serialize(res, true);
    }

    /* ===================== checkRegistrationPaymentStatus ===================== */

    public String checkRegistrationPaymentStatus(String orderId) {
        GARP_EventReg_Dto.PaymentStatusResult res = new GARP_EventReg_Dto.PaymentStatusResult();
        Opportunity opp = selector.getOrderForStatus(orderId);
        if (opp == null) { return JSON.serialize(res, true); }

        res.isOrderFound = true;
        res.paymentType = opp.Alternate_Method_of_Payment__c;
        res.isOrderRolledback = opp.StageName == 'Closed Lost' && opp.Rollback_Reason__c != null;

        List<SObject> txns = opp.getSObjects('Transactions__r');
        if (txns != null && !txns.isEmpty()) {
            res.isPaymentFound = true;
            res.isPaymentSuccess = (String) txns[0].get('ChargentOrders__Response_Status__c') != 'Failure';
        }
        return JSON.serialize(res, true);
    }

    /* ===================== Stripe checkout session ===================== */

    /**
     * Creates a hosted Stripe Checkout Session for a pending order — the
     * standalone replacement for GARP_StripeCheckoutCtrl.getCheckoutSession.
     * Emits the same metadata[orderid] + payment_intent_data[description] the
     * existing Stripe webhook (GARP_StripeClass.processWebhook) relies on to mark
     * the order paid, so no webhook change is needed. Uses customer_email rather
     * than a pre-created Stripe customer (fine for one-time event payment).
     */
    public String getCheckoutSession(String requestJson) {
        Map<String, Object> req = (Map<String, Object>) JSON.deserializeUntyped(requestJson);
        String orderId = (String) req.get('orderId');
        String cancelUrl = (String) req.get('cancelUrl');
        String successUrl = (String) req.get('successUrl');

        Map<String, Object> res = new Map<String, Object>{ 'isError' => false };
        Opportunity opp = selector.getOrderForCheckout(orderId);
        if (opp == null) { res.put('isError', true); res.put('msg', 'Order Not Found'); return JSON.serialize(res); }

        res.put('orderId', opp.Id);
        res.put('orderName', opp.Name);
        res.put('orderNumber', opp.Display_Invoice_Number__c);
        res.put('accountId', opp.AccountId);

        if (opp.StageName != 'New Lead') { res.put('isError', true); res.put('msg', 'Order is already paid'); return JSON.serialize(res); }

        try {
            Map<String, Object> session = GARP_EventReg_Stripe.createCheckoutSession(buildCheckoutParams(opp, cancelUrl, successUrl));
            Object url = session.get('url');
            if (url == null) { res.put('isError', true); res.put('msg', 'Session failed to create'); }
            else { res.put('checkoutUrl', (String) url); }
        } catch (Exception e) {
            res.put('isError', true);
            res.put('msg', e.getMessage());
        }
        return JSON.serialize(res);
    }

    /**
     * Creates an EMBEDDED Stripe Checkout Session (ui_mode=embedded) for a pending
     * order and returns its client_secret + publishable key so the LWC can mount
     * Stripe's on-page Embedded Checkout (stripe.initEmbeddedCheckout) — the
     * embedded equivalent of getCheckoutSession, matching the legacy VF
     * stripe_checkout screen. Emits the SAME metadata[orderid] +
     * payment_intent_data[description] the existing Stripe webhook relies on, so
     * finalization is unchanged. `returnUrl` is where Stripe redirects the page
     * once payment completes inside the embedded form.
     */
    public String getEmbeddedCheckoutSession(String requestJson) {
        Map<String, Object> req = (Map<String, Object>) JSON.deserializeUntyped(requestJson);
        String orderId = (String) req.get('orderId');
        String returnUrl = (String) req.get('returnUrl');

        Map<String, Object> res = new Map<String, Object>{ 'isError' => false };
        Opportunity opp = selector.getOrderForCheckout(orderId);
        if (opp == null) { res.put('isError', true); res.put('msg', 'Order Not Found'); return JSON.serialize(res); }

        res.put('orderId', opp.Id);
        res.put('orderName', opp.Name);
        res.put('orderNumber', opp.Display_Invoice_Number__c);
        res.put('accountId', opp.AccountId);

        // Order details for the checkout page's order-summary panel (legacy parity:
        // the VF stripe_checkout screen shows order info alongside the payment).
        res.put('total', opp.Amount);
        res.put('currencyIso', opp.CurrencyIsoCode);
        List<Map<String, Object>> items = new List<Map<String, Object>>();
        if (opp.OpportunityLineItems != null) {
            for (OpportunityLineItem ol : opp.OpportunityLineItems) {
                items.add(new Map<String, Object>{
                    'name' => (ol.Product2 != null && ol.Product2.Name != null) ? ol.Product2.Name : 'Item',
                    'amount' => ol.TotalPrice,
                    'quantity' => ol.Quantity
                });
            }
        }
        res.put('items', items);

        if (opp.StageName != 'New Lead') { res.put('isError', true); res.put('msg', 'Order is already paid'); return JSON.serialize(res); }

        try {
            Map<String, Object> session = GARP_EventReg_Stripe.createCheckoutSession(buildEmbeddedCheckoutParams(opp, returnUrl));
            Object clientSecret = session.get('client_secret');
            if (clientSecret == null) { res.put('isError', true); res.put('msg', 'Session failed to create'); }
            else {
                res.put('clientSecret', (String) clientSecret);
                res.put('publishableKey', GARP_EventReg_Stripe.publishableKey());
            }
        } catch (Exception e) {
            res.put('isError', true);
            res.put('msg', e.getMessage());
        }
        return JSON.serialize(res);
    }

    private Map<String, String> buildCheckoutParams(Opportunity opp, String cancelUrl, String successUrl) {
        Map<String, String> p = new Map<String, String>();
        String completeURL = String.isNotBlank(successUrl) ? successUrl : 'stripe_checkout_complete';
        completeURL += (completeURL.contains('?') ? '&' : '?') + 'session_id={CHECKOUT_SESSION_ID}';
        p.put('success_url', completeURL);
        if (String.isNotBlank(cancelUrl)) { p.put('cancel_url', cancelUrl); }
        p.put('ui_mode', 'hosted');
        addCheckoutCommonParams(p, opp);
        return p;
    }

    private Map<String, String> buildEmbeddedCheckoutParams(Opportunity opp, String returnUrl) {
        Map<String, String> p = new Map<String, String>();
        // Embedded Checkout requires a return_url carrying the {CHECKOUT_SESSION_ID}
        // placeholder (no success_url/cancel_url — those are the hosted-mode params).
        String completeURL = String.isNotBlank(returnUrl) ? returnUrl : 'stripe_checkout_complete';
        completeURL += (completeURL.contains('?') ? '&' : '?') + 'session_id={CHECKOUT_SESSION_ID}';
        p.put('return_url', completeURL);
        p.put('ui_mode', 'embedded');
        addCheckoutCommonParams(p, opp);
        return p;
    }

    /**
     * Shared Checkout-Session params (metadata, description, mode, customer, and the
     * line-items / Stripe-Tax block) used by BOTH the hosted and embedded builders,
     * so the two flows stay in lock-step. Only ui_mode + the completion URL differ,
     * and those are set by the callers above.
     */
    private void addCheckoutCommonParams(Map<String, String> p, Opportunity opp) {
        String orderNumber = opp.Display_Invoice_Number__c;
        String orderName = opp.Name;
        String garpId = (opp.Account != null && opp.Account.GARP_ID__c != null) ? opp.Account.GARP_ID__c : '';
        // Stripe expects a lowercase ISO currency; bill in the order's own currency.
        String stripeCurrency = (String.isBlank(opp.CurrencyIsoCode) ? 'USD' : opp.CurrencyIsoCode).toLowerCase();

        p.put('metadata[orderid]', orderNumber);
        p.put('metadata[formname]', 'registration');
        p.put('payment_intent_data[description]', orderNumber + ';' + garpId + ';' + orderName);
        p.put('mode', 'payment');
        if (String.isNotBlank(opp.Billing_Email__c)) { p.put('customer_email', opp.Billing_Email__c); }

        if (!GARP_EventReg_Stripe.isTaxEnabled()) {
            GARP_StripeSettings__c s = GARP_EventReg_Stripe.settings();
            p.put('line_items[0][price_data][unit_amount]', String.valueOf(Integer.valueOf((opp.Amount == null ? 0 : opp.Amount) * 100)));
            p.put('line_items[0][price_data][currency]', stripeCurrency);
            p.put('line_items[0][price_data][product]', s == null ? null : s.Default_Product_ID__c);
            p.put('line_items[0][quantity]', '1');
        } else {
            p.put('automatic_tax[enabled]', 'true');
            Integer i = 0;
            for (OpportunityLineItem ol : opp.OpportunityLineItems) {
                if (ol.TotalPrice == 0) { continue; }
                String productName = ol.Product2.Name == null ? 'Item' : ol.Product2.Name.replace(' (Complimentary)', '');
                p.put('line_items[' + i + '][quantity]', '1');
                p.put('line_items[' + i + '][price_data][currency]', stripeCurrency);
                p.put('line_items[' + i + '][price_data][unit_amount]', String.valueOf(Integer.valueOf(ol.TotalPrice * 100)));
                p.put('line_items[' + i + '][price_data][tax_behavior]', 'exclusive');
                p.put('line_items[' + i + '][price_data][product_data][name]', productName);
                if (ol.Product2.Stripe_Tax_Code__c != null) {
                    p.put('line_items[' + i + '][price_data][product_data][tax_code]', ol.Product2.Stripe_Tax_Code__c);
                }
                i++;
            }
            p.put('billing_address_collection', 'required');
            // NOTE: no customer_update — that param requires a `customer` id, and we
            // use customer_email (Stripe auto-creates the customer). Adding it 400s.
        }
    }

    /* ===================== rollback ===================== */

    public Boolean rollbackSetRegistration(String leadId, String accountId, String email, String orderId) {
        if (String.isBlank(orderId)) { return false; }
        List<Opportunity> opps = [SELECT Id, StageName, Rollback_Reason__c FROM Opportunity WHERE Id = :orderId LIMIT 1];
        if (opps.isEmpty()) { return false; }
        Opportunity opp = opps[0];
        opp.StageName = 'Closed Lost';
        opp.Rollback_Reason__c = 'Cancel Registration';
        update opp;
        return true;
    }

    /* ===================== helpers ===================== */

    private GARP_EventReg_Dto.FeeLine lineFromPbe(PricebookEntry pbe, Decimal amount) {
        GARP_EventReg_Dto.FeeLine l = new GARP_EventReg_Dto.FeeLine();
        l.priceId = pbe.Id;
        l.productCode = pbe.Product2.ProductCode;
        l.glCode = pbe.Product2.GL_Code__c;
        l.productName = pbe.Product2.Name;
        l.productFamily = pbe.Product2.Family;
        l.amount = amount;
        return l;
    }

    private PricebookEntry firstPbe(Map<String, PricebookEntry> pbes, String code) {
        for (PricebookEntry p : pbes.values()) { if (p.Product2.ProductCode == code) { return p; } }
        return null;
    }

    private void applyBillingAddress(Opportunity opp, GARP_EventReg_Dto.RegRequest req) {
        GARP_EventReg_Dto.Address a = req.paymentInfo != null ? req.paymentInfo.billingAddress : null;
        if (a == null && req.addressInfo != null) { a = req.addressInfo.billingAddress; }
        if (a == null) { return; }
        opp.Billing_Company__c = a.company;
        opp.Billing_City__c = a.city;
        opp.Billing_State_Text__c = a.province;
        opp.Billing_Zip_Postal__c = a.postalCode;
        opp.Billing_Country__c = a.country;
    }

    private static String mapPayType(String uiType) {
        if (uiType == null) { return null; }
        switch on uiType {
            when 'Credit Card' { return 'cc'; }
            when 'Wire Transfer' { return 'wire'; }
            when 'Check' { return 'check'; }
            when 'ACH' { return 'ach'; }
            when 'Stripe' { return 'stripe'; }
            when else { return uiType.toLowerCase(); }
        }
    }

    private static String trimName(String first, String last) {
        return ((first == null ? '' : first) + ' ' + (last == null ? '' : last)).trim();
    }

    private static Id rt(SObjectType t, String label) {
        Schema.RecordTypeInfo info = t.getDescribe().getRecordTypeInfosByName().get(label);
        return info == null ? null : info.getRecordTypeId();
    }

    /**
     * Populate a Contact from the form's customer + professional details (legacy parity:
     * the details the registration form collects are written back to the Contact).
     * Only non-blank values are set so a partially-filled form never wipes CRM data.
     * Returns true when at least one field was assigned.
     */
    private static Boolean applyContactDetails(Contact con, GARP_EventReg_Dto.RegRequest req) {
        Boolean touched = false;
        GARP_EventReg_Dto.CustomerInfo ci = req.customerInfo;
        GARP_EventReg_Dto.PersonalInfo pi = req.personalInfo;
        if (ci != null) {
            if (String.isNotBlank(ci.mobilePhone)) { con.MobilePhone = ci.mobilePhone; touched = true; }
            if (String.isNotBlank(ci.mobilePhoneCode)) { con.Mobile_Phone_Code__c = ci.mobilePhoneCode; touched = true; }
            if (String.isNotBlank(ci.phone)) { con.Phone = ci.phone; touched = true; }
            if (ci.smsPromotionalUpdates != null) { con.SMS_Promotional_Updates__c = ci.smsPromotionalUpdates; touched = true; }
        }
        String company = (pi != null && String.isNotBlank(pi.company)) ? pi.company : (ci == null ? null : ci.company);
        String title   = (pi != null && String.isNotBlank(pi.title))   ? pi.title   : (ci == null ? null : ci.title);
        if (String.isNotBlank(company)) { con.Company__c = company; touched = true; }
        if (String.isNotBlank(title))   { con.Title = title; touched = true; }
        if (pi != null) {
            if (String.isNotBlank(pi.businessEmail))     { con.Business_Contact_Email__c = pi.businessEmail; touched = true; }
            if (String.isNotBlank(pi.professionalLevel)) { con.Corporate_Title__c = pi.professionalLevel; touched = true; }
            if (String.isNotBlank(pi.jobFunction))       { con.Job_Function__c = pi.jobFunction; touched = true; }
            if (String.isNotBlank(pi.riskSpecialty))     { con.Risk_Specialty__c = pi.riskSpecialty; touched = true; }
        }
        // Mailing address from the billing address (legacy parity:
        // GARP_BC_Membership.updateNonMembershipContact maps the order's billing address
        // onto the Contact's Mailing address when a country is present).
        GARP_EventReg_Dto.Address addr = (req.paymentInfo != null && req.paymentInfo.billingAddress != null)
            ? req.paymentInfo.billingAddress
            : (req.addressInfo == null ? null : req.addressInfo.billingAddress);
        if (addr != null && String.isNotBlank(addr.country)) {
            if (String.isNotBlank(addr.city))       { con.MailingCity = addr.city; touched = true; }
            con.MailingCountry = addr.country; touched = true;
            if (String.isNotBlank(addr.postalCode)) { con.MailingPostalCode = addr.postalCode; touched = true; }
            if (String.isNotBlank(addr.province))   { con.MailingState = addr.province; touched = true; }
            String street = joinStreet(addr.street1, addr.street2, addr.street3);
            if (String.isNotBlank(street))          { con.MailingStreet = street; touched = true; }
        }
        return touched;
    }

    /** Combine up to three street lines into a single MailingStreet text-area value. */
    private static String joinStreet(String s1, String s2, String s3) {
        List<String> parts = new List<String>();
        if (String.isNotBlank(s1)) { parts.add(s1); }
        if (String.isNotBlank(s2)) { parts.add(s2); }
        if (String.isNotBlank(s3)) { parts.add(s3); }
        return parts.isEmpty() ? null : String.join(parts, '\n');
    }

    /** Enrich an already-existing Contact with the form details (see applyContactDetails). */
    private void updateExistingContactDetails(Id contactId, GARP_EventReg_Dto.RegRequest req) {
        Contact con = new Contact(Id = contactId);
        if (applyContactDetails(con, req)) {
            try {
                update con;
            } catch (Exception e) {
                // Never fail the registration because contact enrichment failed.
                System.debug('GARP_EventReg_RegService contact enrichment failed: ' + e.getMessage());
            }
        }
    }

    /**
     * ON24 attendee registration for FREE events — self-contained replication of the
     * legacy on24API contract (utilApp/r endpoint, form-encoded attendee params, an
     * API_Transaction__c audit row). @future(callout=true) so it runs after the
     * registration DML commits. Paid events are pushed by the shared post-payment
     * automation, so this fires only for the free/non-paid path.
     */
    @future(callout=true)
    private static void pushOn24Registration(Id contactId, String on24EventId, String apiKey, Id eventRegistrationId) {
        if (contactId == null || String.isBlank(on24EventId)) { return; }
        List<Contact> cs = [
            SELECT Id, FirstName, LastName, Company__c, Email, Title, MailingStreet, MailingCity,
                   MailingState, MailingPostalCode, MailingCountry, KPI_FRM_Certified__c,
                   KPI_ERP_Certified__c, Area_of_Concentration__c
            FROM Contact WHERE Id = :contactId LIMIT 1
        ];
        if (cs.isEmpty()) { return; }
        Contact c = cs[0];

        List<String> params = new List<String>();
        if (c.Area_of_Concentration__c != null) { params.add('companyType=' + c.Area_of_Concentration__c); }
        if (c.KPI_ERP_Certified__c != null)     { params.add('std3=' + c.KPI_ERP_Certified__c); }
        if (c.KPI_FRM_Certified__c != null)      { params.add('std2=' + c.KPI_FRM_Certified__c); }
        if (c.FirstName != null)                 { params.add('firstname=' + c.FirstName); }
        if (c.LastName != null)                  { params.add('lastname=' + c.LastName); }
        if (c.Email != null)                     { params.add('email=' + c.Email); }
        if (c.Company__c != null)                { params.add('company=' + c.Company__c); }
        if (c.Title != null)                     { params.add('job_title=' + c.Title); }
        if (c.MailingStreet != null)             { params.add('address_street1=' + c.MailingStreet); }
        if (c.MailingCity != null)               { params.add('city=' + c.MailingCity); }
        if (c.MailingState != null)              { params.add('state=' + c.MailingState); }
        if (c.MailingPostalCode != null)         { params.add('zip=' + c.MailingPostalCode); }
        if (c.MailingCountry != null)            { params.add('country=' + c.MailingCountry); }
        String body = String.join(params, '&');

        String urlParams = ('eventid=' + on24EventId + '&sessionid=1&key=' + apiKey).replaceAll('[+]', '%20');
        String callURL = 'https://event.on24.com/utilApp/r?' + urlParams;

        API_Transaction__c trans = new API_Transaction__c(
            Type__c = 'on24',
            Contact__c = contactId,
            Event_Registration__c = eventRegistrationId,
            Request__c = callURL.length() > 255 ? callURL.substring(0, 255) : callURL,
            Body__c = body
        );
        if (!Test.isRunningTest()) {
            try {
                HttpRequest hreq = new HttpRequest();
                hreq.setEndpoint(callURL);
                hreq.setMethod('POST');
                hreq.setHeader('content-type', 'application/x-www-form-urlencoded');
                hreq.setBody(body);
                HttpResponse res = new Http().send(hreq);
                trans.Response_Code__c = String.valueOf(res.getStatusCode());
                String rb = res.getBody();
                if (rb != null && rb.length() > 255) { rb = rb.substring(0, 254); }
                trans.Response__c = rb;
            } catch (Exception e) {
                String err = e.getMessage();
                trans.Error__c = (err != null && err.length() > 255) ? err.substring(0, 255) : err;
            }
        }
        try { insert trans; } catch (Exception e) { System.debug('ON24 API_Transaction insert failed: ' + e.getMessage()); }
    }
}