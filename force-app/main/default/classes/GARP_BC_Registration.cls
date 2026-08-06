public class GARP_BC_Registration {

    // Wrappers
    public class setRegistrationReturnInfo {
        public String status;
        public String message;
        public String contactId;
        public String accountId;
        public String orderId;
        public String programId;
        public String registrationId;
        public String orderNumber;
        public String company;
        public Decimal total;
        public Decimal tax;
        public Decimal shipping;
    }

    public class captchaInfo {
        public String cap;
        public String capip;
        public String sessionToken;
    }

    public class checkExistingContact {
        public User user;
        public Contact contact;
        public Boolean isBusinessContact;
        public Boolean isMember;
        public Boolean hasActiveContract;
        public Boolean hasPendingOrder;
        public Boolean hasClosedOrder;
        public String expiredOpenOrderId;
    }

    public class checkAuthentication {
        public User user;
        public String contactId;
        public Boolean isAuthenticated;
    }

    public class FAQWrapper {
        List<FAQ_Category__c> FAQ_Category;
        List<FAQ_Section__c> FAQ_Sections;
        List<FAQ_Subsection__c> FAQ_Subsections;
        List<Frequently_Asked_Questions__c> FAQs;

        public FAQWrapper(List<FAQ_Category__c> category, List<FAQ_Section__c> sections, List<FAQ_Subsection__c> subsections, List<Frequently_Asked_Questions__c> inFAQs) {
            FAQ_Category = category;
            FAQ_Sections = sections;
            FAQ_Subsections = subsections;
            FAQs = inFAQs;
        }
    }

    public class programRegistrationInfo {
        public String registrationType; // frm, scr, frr, ffr, membership, event, checkout
        public String mainMemberProductCode;
        public String mainNonMemberProductCode;
        public String mainCertifiedProductCode;
        public String retakeProductCode;
        public String teamRegDiscountProductCode;
        public String studyMaterialDiscountProductCode;
        public String regCode;
        public String formName;
        public String FAQCatName;
        public String contractRecTypeName;
        public String eventId;
        public String eventType; // chaptermeeting, event, webcast
        public String membershipType; // individual, affiliate
        public String eventDiscountProductCode;
        public Boolean allowMemberPublicRegistration; // Allow existing member to register non-authenticated
        public Boolean addressVerificationDisabled; // Do not require verfied address to register
        public List<String> mainProductCodes;
        public List<String> feesProductCodes;
        public List<String> studyMatProductCodes;
        public List<String> addOnsProductCodes;
        public List<String> teamProductCodes;
        public GARP_BC_Orders.checkoutCart checkoutCart; // Passing shopping cart of products to buy
        public string loadKey;
        public GARP_BC_Courses.microCourseInfo microCourseInfo;
        public GARP_BC_MyPrograms.programInformation programInformation;
        public Boolean skipTeamRegSeatLimitCheck;
    }

    public class examSelectionInfo {
        public List<String> partsAvailable; // List Part 1, Part 1 & Part 2, or Part 2
        public String partSelected;
        public partInfo part1Info;
        public partInfo part2Info;
    }

    public class partInfo {
        public String title;
        public String selectedAdminId;
        public String selectedPartId;
        public String selectedSiteId;
        public List<examAdminInfo> examAdmins;
    }

    public class examSiteInfo {
        public String name; // Country
        public String id;
        public Boolean isOSTA;
        public Boolean isVAT;
        public String provider;
    }

    public class examAdminInfo {
        public String name;
        public String id;
        public Decimal amount;
        public String partName;
        public String partId;
        public String window; // Early, Standard
        public String examDates; // April 15 - 23, 2023
        public Long examStartDateEpoch;
        public List<examSiteInfo> examSites;
    }

    public class getRegistrationInfo {
        public String status;
        public String statusMessage;
        public List<GARP_BC_Orders.productInfo> products;
        public List<GARP_BC_StudyMaterials.studyMaterial> studyMaterials;
        public screenInfo screenInfo;
        public GARP_BC_Membership.membershipInfo membershipInfo;
        public Boolean isEligible;
        public String notEligibleErrorMessage;
        public programRegistrationInfo programRegistrationInfo;
        public teamRegInfo teamRegInfo;
        public String affiliateCode;
        public examSelectionInfo examSelectionInfo;
        public captchaInfo captchaInfo;
        public GARP_BC_Events.eventRegistrationInfo eventRegistrationInfo;
        public stripeInfo stripeInfo;
    }

    public class stripeInfo {
        public GARP_StripeClass.stripeInfo stripeInfo;
        public Boolean useStripe;
        public Boolean useStripeTax;
        public String stripePaymentMethod;
        public String clientSideAPIKey;
    }

    public class membershipOptions {
        public Boolean hasSelectedMembership;
        public Boolean hasSelectedRiskNet;
        public Boolean autoRenew;
    }

    public class addressInfo {
        public GARP_Common.address shippingAddress;
        public GARP_Common.address billingAddress;
        public Boolean billingAndShippingSame;
    }

    public class promoCodeVerify {
        public String promoCode;
        public Boolean isValid;
        public String message;
    }

    public class getRegistrationFeesInfo {
        public orderCustomerInfo customerInfo;
        public membershipOptions membershipOptions;
        public String paymentType;
        public String teamRegCode;
        public String affiliateCode;
        public List<GARP_BC_StudyMaterials.studyMaterial> studyMaterials;
        public addressInfo addressInfo;
        public programRegistrationInfo programRegistrationInfo;
        public examSelectionInfo examSelectionInfo;
        public List<promoCodeVerify> promoCodes;
        public Boolean isEventBundleSelected;
    }

    public class teamRegInfo {
        public String teamRegParentId;
        public String teamRegId;
        public String teamRegCode;
        public String examType;
        public String accountName;
        public String consentMessage;
        public Boolean isAttestationRequired;
        public Boolean isComplimentary;
        public Boolean consentReleaseExamResults;
        public Boolean authenticationRequired;
        public Boolean isScholarship;
        public Boolean isScholarshipEnrollmentComplimentary;
        public Boolean isEvent;
        public Decimal eventDiscountPrice;
        public Decimal discountPrice;
        public Decimal discountPercent;
        public String discountProductCode;
        public String discountType;
        public Boolean complimentaryMembership;
        public Boolean isOSTAFeePaidByInstitution;
        public Boolean isGSTFeePaidByInstitution;
        public Boolean isRetakeOnly;
        public String eBookType;
        public String eBookProductCode;
        public String rateType;
        public Boolean addDiscountLineItem;
        public Decimal prePaidDiscountPercent;
        public Boolean isBundle;
        public String EPPDealId;
        public String includedStudyMaterials;
    }

    public class registrationFees {
        public String status;
        public String message;
        public List<GARP_BC_Orders.productInfo> feeProducts;
        public List<GARP_BC_Orders.productInfo> feeProductsForDisplay;

        public List<promoCodeVerify> promoCodes;

        // New Info from front-end
        public Boolean needsShipping; // Given reg case something needs to be shipped
        public Decimal njSalesTax;
        public GARP_BC_Orders.productInfo vatSalesTax;
        public Decimal total;
        public Decimal subTotal;
        public Boolean hasCompMembership;
        public Integer compMembershipTerm; // 6 or 12
        public Boolean hasBilling; // Will we charge / show charges
        public Boolean hasSubtotal; // VAT or NJ Salestax

        public GARP_StripeClass.orderTaxInfo orderTaxInfo;
    }

    public class screenInfo {
        public List<Country_Code__c> locations;
        public List<Institution__c> companies;
        public List<Institution__c> schools;
        public List<String> professionalLevels;
        public List<String> jobFunctions;
        public List<String> riskSpecialties;
        public FAQWrapper FAQInfo;
        public Boolean isAuthenticated;
    }

    public class verifyExistingCustomerInfo {
        public String firstName;
        public String lastName;
        public String email;
        public String leadId;
        public String sessionId;
        public String formKey;
        public String cta;
        public Boolean allowMemberPublicRegistration;
        public String utm_campaign;
        public String utm_content;
        public String utm_medium;
        public String utm_source;
        public String utm_term;
        public String track_cta;

    }

    public class verifyExistingCustomerReturnInfo {
        public String status;
        public String message;
        public Boolean isCustomer;
        public String leadId;
        public String accountId;
        public String contactId;
        public String sessionId;
    }

    public class orderCustomerInfo {
        public String firstName;
        public String lastName;
        public String email;
        public String leadId;
        public String sessionId;
        public String contactId;
        public String accountId;
        public String phone;
        public String mobilePhone;
        public String mobilePhoneCode;
        public Boolean smsRegistrationUpdates;
        public Boolean smsPromotionalUpdates;
        public String title;
        public String company;
    }

    public class orderPersonalInfo {
        public String gender;
        public String idType;
        public String idLocation;
        public String idNumber;
        public String nameOnID;
        public Boolean ostaConsent;
        public String fullNameInChinese;
        public String dateOfBirth;
        public String idExpireDate;
        public String phone;
        public String workStatus;
        public String company;
        public String schoolName;
        public String studentStatus;
        public String degreeName;
        public String businessEmail;
        public String professionalLevel;
        public String jobFunction;
        public String riskSpecialty;
    }

    public class createOrderInfo {
        public orderCustomerInfo customerInfo;
        public orderPersonalInfo personalInfo;
        public GARP_BC_Orders.orderPaymentInfo paymentInfo;
        public List<GARP_BC_StudyMaterials.studyMaterial> studyMaterials;
        public List<GARP_BC_Orders.productInfo> selectedProducts;
        public Boolean isEventBundleSelected;
        public membershipOptions membershipOptions;
        public GARP_BC_Events.eventOptions eventOptions;
        public captchaInfo captchaInfo;
        public programRegistrationInfo programRegistrationInfo;
        public addressInfo addressInfo;
        public teamRegInfo teamRegInfo;
        public String affiliateCode;
        public examSelectionInfo examSelectionInfo;
        public consentInfo consentInfo;
        public List<promoCodeVerify> promoCodes;
        public stripeInfo stripeInfo;
        public string sessionStateJSON;
    }

    public class consentInfo {
        public Boolean privacyPolicyAttestation;
        public Boolean examPolicyAttestation;
        public Boolean OSTAConsent;
        public Boolean valuableContentAttestation;
        public Boolean sponsorContentAttestation;
        public Boolean eppOutreachConsent;
        // Case 00888108
        public Boolean consentReleaseExamResults;
    }

    public class setRegistrationInfo {
        public orderCustomerInfo customerInfo;
        public orderPersonalInfo personalInfo;
        public GARP_BC_Orders.orderPaymentInfo paymentInfo;
        public List<GARP_BC_StudyMaterials.studyMaterial> studyMaterials;
        public membershipOptions membershipOptions;
        public GARP_BC_Events.eventOptions eventOptions;
        public captchaInfo captchaInfo;
        public programRegistrationInfo programRegistrationInfo;
        public addressInfo addressInfo;
        public teamRegInfo teamRegInfo;
        public String affiliateCode;
        public examSelectionInfo examSelectionInfo;
        public consentInfo consentInfo;
        public List<promoCodeVerify> promoCodes;
        public List<GARP_BC_Orders.productInfo> selectedProducts;
        public Boolean isEventBundleSelected;
    }

    public class RegistrationEligibility {

        public Boolean isEligible;
        public String eligibleError;

        public Set<String> eligibleExams { get; set; }

        public Boolean isInProgram { get; set; }
        public Boolean isRegistrationOpen { get; set; }
        public Boolean isPaymentBlocked { get; set; }
        public Boolean isOtherRegistered { get; set; }
        public Boolean isOtherPart1AwaitingResults { get; set; }
        public Boolean isOtherPart2AwaitingResults { get; set; }
        public Boolean isOtherOpenOrder { get; set; }
        public Boolean isOpenOrder { get; set; }

        public Boolean isPart1Passed { get; set; }
        public Boolean isPart1Offered { get; set; }
        public Boolean isPart1RegisteredInActiveAdmin { get; set; }
        public Exam_Attempt__c part1RegisteredInActiveAdmin { get; set; }
        public Boolean isPart1RegisteredAwaitingResults { get; set; }
        public Boolean isPart1Deferred { get; set; }

        public Boolean isPart2Passed { get; set; }
        public Boolean isPart2Offered { get; set; }
        public Boolean isPart2RegisteredInActiveAdmin { get; set; }
        public Exam_Attempt__c part2RegisteredInActiveAdmin { get; set; }
        public Boolean isPart2RegisteredAwaitingResults { get; set; }
        public Boolean isPart2Deferred { get; set; }

        public Boolean isNetNew { get; set; }
    }

    // Methods

    // Set isMainProduct and other properties in context
    public static GARP_BC_Orders.productInfo setProductInfo(GARP_BC_Orders.productInfo productInfo, programRegistrationInfo programRegistrationInfo, GARP_BC_Membership.membershipInfo membershipInfo, PricebookEntry pbe, Boolean isMainProduct) {

        GARP_Common.debugLog('GARP_BC_Registration','setProductInfo','productInfo',productInfo);
        GARP_Common.debugLog('GARP_BC_Registration','setProductInfo','programRegistrationInfo.mainMemberProductCode',programRegistrationInfo.mainMemberProductCode);
        GARP_Common.debugLog('GARP_BC_Registration','setProductInfo','programRegistrationInfo.mainNonMemberProductCode',programRegistrationInfo.mainNonMemberProductCode);
        GARP_Common.debugLog('GARP_BC_Registration','setProductInfo','programRegistrationInfo.mainProductCodes',programRegistrationInfo.mainProductCodes);

        // Reset isMainProduct if it was replaced by
        if(productInfo.productCode == programRegistrationInfo.mainMemberProductCode ||
           productInfo.productCode == programRegistrationInfo.mainNonMemberProductCode) {
               productInfo.isMainProduct = True;
           } else if(programRegistrationInfo.mainProductCodes != NULL) {
               Set<String> mainProds = new Set<String>(programRegistrationInfo.mainProductCodes);
               if(mainProds.contains(productInfo.productCode)) {
                   productInfo.isMainProduct = True;
               } else if(isMainProduct) {
                   productInfo.isMainProduct = True;
               }
           } else if(isMainProduct) {
               productInfo.isMainProduct = True;
           }

        GARP_Common.debugLog('GARP_BC_Registration','setProductInfo','isMainProduct',productInfo.isMainProduct);

        // Return total Risk.Net Amount
        if(productInfo.productCode == 'MEMR') {

            Integer monthsOfMembership = 0;
            if(membershipInfo != NULL && membershipInfo.monthsLeftInMembershipContract != NULL) {
                monthsOfMembership+=membershipInfo.monthsLeftInMembershipContract;
            }
            // If on Membership Reg, add 12 months
            if(programRegistrationInfo.registrationType == 'membership') {
                monthsOfMembership+=12;
            }

            if(monthsOfMembership > 0) {
                if(monthsOfMembership == 12) {
                    productInfo.amount = 100;
                } else {
                    productInfo.amount = monthsOfMembership * productInfo.amount;
                }
            } else {
                productInfo.amount = 100;
            }
        }
        // For now all products have a quantity of 1
        productInfo.quantity = 1;

        // If Complimentry
        if(pbe.Product2 != NULL && pbe.Product2.Is_Comped_Registration__c != NULL &&
           pbe.Product2.Is_Comped_Registration__c && programRegistrationInfo.registrationType != 'checkout') {
               productInfo.amount = 0;
           }

        // Is Study Material
        productInfo.isStudyMaterialProduct = False;
        Set<String> studyMatProd = new Set<String>(programRegistrationInfo.studyMatProductCodes);
        if(studyMatProd.contains(productInfo.productCode)) {
            productInfo.isStudyMaterialProduct = True;
            if(pbe.Product2.Is_Comped_Registration__c && programRegistrationInfo.registrationType != 'checkout') {
                productInfo.isCompWithRegistration = True;
            } else {
                productInfo.isCompWithRegistration = False;
            }
        }

        return productInfo;
    }

    // Get Registration Information for a given Program
    public static getRegistrationInfo getRegistrationInfo(programRegistrationInfo programRegistrationInfo) {

        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','mainMemberProductCode',programRegistrationInfo.mainMemberProductCode);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','mainNonMemberProductCode',programRegistrationInfo.mainNonMemberProductCode);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','studyMatProductCodes',programRegistrationInfo.studyMatProductCodes);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','FAQCatName',programRegistrationInfo.FAQCatName);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','registrationType',programRegistrationInfo.registrationType);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','regCode',programRegistrationInfo.regCode);

        getRegistrationInfo regInfo = new getRegistrationInfo();

        // Stripe Initialize
        GARP_StripeClass.retSetupStripe stripeInitInfo = GARP_StripeClass.isStripeEnabled();
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','isStripeEnabled stripeInitInfo',stripeInitInfo);

        if(stripeInitInfo != NULL) {
            regInfo.stripeInfo = new stripeInfo();
            if(stripeInitInfo.status == 'Success') {
                regInfo.stripeInfo.useStripe = stripeInitInfo.useStripe;
                regInfo.stripeInfo.useStripeTax = stripeInitInfo.useStripeTax;
                regInfo.stripeInfo.clientSideAPIKey = stripeInitInfo.stripeInfo.clientSideAPIKey;
            } else {
                regInfo.stripeInfo.useStripe = False;
                regInfo.stripeInfo.useStripeTax = False;
                regInfo.stripeInfo.clientSideAPIKey = NULL;
            }
        }

        regInfo.Products = new List<GARP_BC_Orders.productInfo>();
        regInfo.screenInfo = new screenInfo();
        regInfo.studyMaterials = new List<GARP_BC_StudyMaterials.studyMaterial>();
        regInfo.captchaInfo = new captchaInfo();

        regInfo.captchaInfo.sessionToken = Utilities.getFormSessionToken();

        regInfo.programRegistrationInfo = programRegistrationInfo;

        GARP_Common.checkAuthentication checkAuth = GARP_Common.checkAuthentication();
        regInfo.screenInfo.IsAuthenticated = checkAuth.isAuthenticated;

        String accountId;
        if(regInfo.screenInfo.IsAuthenticated) {
            regInfo.membershipInfo = GARP_BC_Membership.getMembershipInfo(checkAuth.user.contactId);
            accountId = regInfo.membershipInfo.contactRecord.AccountId;
        }

        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','checkAuth',checkAuth);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','membershipInfo',regInfo.membershipInfo);

        // Get Event Details
        if(!String.isEmpty(programRegistrationInfo.eventId)) {
            regInfo.eventRegistrationInfo = GARP_BC_Events.getEventInfo(programRegistrationInfo.eventId, programRegistrationInfo.eventType);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','eventRegistrationInfo',regInfo.eventRegistrationInfo);

            if(regInfo.eventRegistrationInfo == NULL || regInfo.eventRegistrationInfo.eventInfo.eventId == NULL) {
                regInfo.status = 'Error';
                regInfo.statusMessage = 'Event not found';
                return regInfo;
            }

            regInfo.screenInfo.professionalLevels = GARP_Common.getPickListValues('Contact','Corporate_Title__c');
            regInfo.screenInfo.jobFunctions = GARP_Common.getPickListValues('Contact','Job_Function__c');
            regInfo.screenInfo.riskSpecialties  = GARP_Common.getPickListValues('Contact','Risk_Specialty__c');

            if(regInfo.eventRegistrationInfo.bundledEventId != NULL) {
                regInfo.eventRegistrationInfo.bundledEventRegistrationInfo = GARP_BC_Events.getEventInfo(regInfo.eventRegistrationInfo.bundledEventId, programRegistrationInfo.eventType);
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','bundledEventRegistrationInfo',regInfo.eventRegistrationInfo.bundledEventRegistrationInfo);
            }
        }

        // Affiliate Program Info
        Affiliate_Program__c affiliateProgram;
        if(!String.isEmpty(programRegistrationInfo.regCode)) {
            affiliateProgram = getAffiliateProgramInfo(programRegistrationInfo.regCode);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','affiliateProgram',affiliateProgram);
            if(affiliateProgram != NULL) {
                Date tdy = Date.Today();
                // Check the Affiliate EPP Deal Date
                Boolean isInvalidDeal =
                    (affiliateProgram.EPP_Deal__r.Start_Date__c == null ||
                     tdy <= affiliateProgram.EPP_Deal__r.Start_Date__c) ||

                    (affiliateProgram.EPP_Deal__r.End_Date__c == null ||
                     tdy >= affiliateProgram.EPP_Deal__r.End_Date__c) ||

                    (affiliateProgram.Start_Date__c == null ||
                     tdy <= affiliateProgram.Start_Date__c) ||

                    (affiliateProgram.End_Date__c == null ||
                     tdy >= affiliateProgram.End_Date__c) || affiliateProgram.EPP_Deal__r.Status__c != 'Active';
                if (isInvalidDeal) {
                    regInfo.status = 'Failed';
                    regInfo.statusMessage = 'This Affiliate link is not currently valid.';
                    return regInfo;
                }

                regInfo.affiliateCode = affiliateProgram.Affiliate_Code__c;
            }
        }

        // Team Reg Get Info
        teamRegInfo teamRegInfo;
        if(!String.isEmpty(programRegistrationInfo.regCode) && regInfo.affiliateCode == NULL) {
            retGetTeamRegistrationInfo retTeamInfo = getTeamRegistrationInfo(programRegistrationInfo, accountId, False);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','retTeamInfo',retTeamInfo);

            if(retTeamInfo.status != 'Success') {
                regInfo.status = retTeamInfo.status;
                regInfo.statusMessage = retTeamInfo.statusMessage;
                return regInfo;
            } else {
                regInfo.teamRegInfo = retTeamInfo.teamRegInfo;
                teamRegInfo = retTeamInfo.teamRegInfo;
            }

            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','authenticationRequired',regInfo.teamRegInfo.authenticationRequired);
            if(!regInfo.screenInfo.IsAuthenticated && regInfo.teamRegInfo.authenticationRequired) {
                regInfo.status = 'Failed';
                regInfo.statusMessage = 'The Team Registration requires authentication';
                return regInfo;
            }
        }

        // If code was passed and not found throw an error
        if(!String.isEmpty(programRegistrationInfo.regCode) && teamRegInfo == NULL && affiliateProgram == NULL) {
            regInfo.status = 'Failed';
            regInfo.statusMessage = 'Registration Code not found';
            return regInfo;
        }

        // Is Eligible to Register?
        regInfo.isEligible = True;
        regInfo.notEligibleErrorMessage = Null;

        // Authenticated and Non-Events
        if(programRegistrationInfo.registrationType != 'event' && programRegistrationInfo.registrationType != 'checkout') {

            if(programRegistrationInfo.registrationType == 'ffr' || programRegistrationInfo.registrationType == 'frr' || programRegistrationInfo.registrationType == 'frr25') {
                GARP_BC_Courses.isEligibleCourseReturnInfo courseElig = GARP_BC_Courses.isEligibleCourse(regInfo.membershipInfo, programRegistrationInfo.registrationType, regInfo.teamRegInfo, null);
                regInfo.notEligibleErrorMessage = courseElig.message;
                regInfo.isEligible = courseElig.isEligible;
            } else if(programRegistrationInfo.registrationType == 'micro') {
                GARP_BC_Courses.isEligibleCourseReturnInfo courseElig = GARP_BC_Courses.isEligibleCourse(regInfo.membershipInfo, 'micro', regInfo.teamRegInfo, programRegistrationInfo.microCourseInfo);
                regInfo.notEligibleErrorMessage = courseElig.message;
                regInfo.isEligible = courseElig.isEligible;
            } else if(programRegistrationInfo.registrationType == 'scr' || programRegistrationInfo.registrationType == 'riskai' || programRegistrationInfo.registrationType == 'raij') {
                GARP_BC_Registration.RegistrationEligibility regElig = GARP_BC_Courses.isEligibleExam(regInfo.membershipInfo, programRegistrationInfo.loadKey, programRegistrationInfo.registrationType);
                regInfo.notEligibleErrorMessage = regElig.eligibleError;
                regInfo.isEligible = regElig.isEligible;
            } else if(programRegistrationInfo.registrationType == 'frm') {
                GARP_BC_Registration.RegistrationEligibility regElig = GARP_BC_Exams.isEligibleFRM(regInfo.membershipInfo, programRegistrationInfo.loadKey);
                regInfo.notEligibleErrorMessage = regElig.eligibleError;
                regInfo.isEligible = regElig.isEligible;
            } else if(programRegistrationInfo.registrationType == 'membership') {
                GARP_BC_Registration.RegistrationEligibility regElig = GARP_BC_Membership.isEligibleIndividualMembership(regInfo.membershipInfo);
                regInfo.notEligibleErrorMessage = regElig.eligibleError;
                regInfo.isEligible = regElig.isEligible;
            }
            if(!regInfo.isEligible) {
                return regInfo;
            }
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','isEligible',regInfo.isEligible);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','notEligibleErrorMessage',regInfo.notEligibleErrorMessage);
        }

        // Events
        if(programRegistrationInfo.registrationType == 'event') {

            RegistrationEligibility regElig = GARP_BC_Events.isEligibleEvent(programRegistrationInfo, regInfo.eventRegistrationInfo, regInfo.membershipInfo, checkAuth.isAuthenticated, teamRegInfo);
            regInfo.isEligible = regElig.isEligible;
            regInfo.notEligibleErrorMessage = regElig.eligibleError;
            if(!regInfo.isEligible) {
                return regInfo;
            }
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','isEligible',regInfo.isEligible);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','notEligibleErrorMessage',regInfo.notEligibleErrorMessage);

            // Check Bundled Event
            if(regInfo.eventRegistrationInfo.isBundledEvent) {
                RegistrationEligibility regBundledElig = GARP_BC_Events.isEligibleEvent(programRegistrationInfo, regInfo.eventRegistrationInfo.bundledEventRegistrationInfo, regInfo.membershipInfo, checkAuth.isAuthenticated, teamRegInfo);
                regInfo.eventRegistrationInfo.isBundledEventEligible = regBundledElig.isEligible;

                if(teamRegInfo != NULL && teamRegInfo.isBundle && !regInfo.eventRegistrationInfo.isBundledEventEligible) {
                    regInfo.isEligible = False;
                    regInfo.notEligibleErrorMessage = 'This Team Registration code is for a bundle but it is not available';
                    if(!regInfo.isEligible) {
                        return regInfo;
                    }
                }
            }
        }

        MAP<String, Country_Code__c> mapCountryCodes = GARP_BC_Shipping.getCountryCodesMap();
        Set<String> vatTaxProductCodes = new Set<String>();
        for(Country_Code__c cc :mapCountryCodes.values()) {
            if(cc.VAT__c != NULL) {
                vatTaxProductCodes.add(cc.VAT_Product_Code__c);
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','vatTaxProductCodes',vatTaxProductCodes);

        // Return all possible products
        List<String> productCodes = new List<String>();
        productCodes.addAll(new List<String>{});
        productCodes.addAll(vatTaxProductCodes);
        productCodes.add(programRegistrationInfo.mainMemberProductCode);
        productCodes.add(programRegistrationInfo.mainNonMemberProductCode);
        productCodes.add(programRegistrationInfo.mainCertifiedProductCode);
        productCodes.add(programRegistrationInfo.retakeProductCode);
        productCodes.add(programRegistrationInfo.teamRegDiscountProductCode);
        productCodes.add(programRegistrationInfo.eventDiscountProductCode);
        productCodes.add(programRegistrationInfo.studyMaterialDiscountProductCode);

        productCodes.addAll(GARP_Common.safeList(programRegistrationInfo.studyMatProductCodes));
        productCodes.addAll(GARP_Common.safeList(programRegistrationInfo.addOnsProductCodes));
        productCodes.addAll(GARP_Common.safeList(programRegistrationInfo.mainProductCodes));
        productCodes.addAll(GARP_Common.safeList(programRegistrationInfo.feesProductCodes));
        productCodes.addAll(GARP_Common.safeList(programRegistrationInfo.teamProductCodes));
        List<String> priceIds = new List<String>();
        MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(productCodes, priceIds);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','mapProdByCodes',mapProdByCodes);

        Set<String> setStudyMatProductCodes = new Set<String>(programRegistrationInfo.studyMatProductCodes);
        Set<String> setAddOnsProductCodes = new Set<String>(programRegistrationInfo.addOnsProductCodes);

        // Get Users eBooks & Practice Exams
        MAP<String,GARP_BC_StudyMaterials.eBook> mapEBooks = new MAP<String,GARP_BC_StudyMaterials.eBook>();
        if(regInfo.screenInfo.IsAuthenticated && setStudyMatProductCodes.size() > 0) {
            List<GARP_BC_StudyMaterials.eBook> eBooks = GARP_BC_StudyMaterials.getMyElectronicStudyMaterials(regInfo.membershipInfo.accountRecord.Id, NULL);
            if(!eBooks.IsEmpty()) {
                for(GARP_BC_StudyMaterials.eBook eb :eBooks) {
                    mapEBooks.put(eb.accountingId, eb);
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','mapEBooks',mapEBooks);

        MAP<String,Exam_Attempt__c> mapLatestExamAttempts;
        if(regInfo.screenInfo.IsAuthenticated) {
            GARP_BC_MyPrograms.returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(checkAuth.user.contactId);
            mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;
        }

        for(String getCode :mapProdByCodes.keySet()) {
            List<String> keyParts = getCode.split(':');
            PricebookEntry pbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, keyParts[0], keyParts.size() > 1 ? keyParts[1] : null);
            if (pbe == null) { continue; }

            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','Loop pbe',pbe.Product2.ProductCode+':'+pbe.Product2.GL_Code__c);

            //mapProdByCodes.put(pbe.Product2.ProductCode+':'+pbe.Product2.GL_Code__c, pbe);

            GARP_BC_Orders.productInfo prod = setProductInfo(new GARP_BC_Orders.productInfo(pbe), programRegistrationInfo, regInfo.membershipInfo, pbe, False);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','prod',prod);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','screenInfo',regInfo.screenInfo);

            if(setStudyMatProductCodes.contains(prod.productCode) ||
               setAddOnsProductCodes.contains(prod.productCode) || prod.isMembershipProduct) {

                   GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','Is Add-On',prod);

                   // Isolate StudyMaterials
                   if(setStudyMatProductCodes.contains(prod.productCode)) {

                       // Compute Registrant Price
                       //if(programRegistrationInfo.registrationType != 'checkout' && (prod.productCode == 'SCRH' || prod.productCode == 'RAIH')) {
                       //    continue;
                       //}

                       if(prod.productCode == 'SCRH' || prod.productCode == 'RAIH' || prod.productCode == 'RAIJH') {

                           if(programRegistrationInfo.registrationType == 'scr' || programRegistrationInfo.registrationType == 'riskai' || programRegistrationInfo.registrationType == 'raij') {
                               Decimal registrantPrice = GARP_BC_StudyMaterials.getBookRegistrantPrice(programRegistrationInfo.registrationType, prod.amount);
                               GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','registrantPrice',registrantPrice);

                               prod.amount = registrantPrice;
                               pbe.UnitPrice = prod.amount;

                               GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','discount study mat prod',prod.amount);
                               GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','discount study mat prod',pbe.UnitPrice);

                           }
                           /*
                           else if(regInfo.screenInfo.IsAuthenticated) {

                               Exam_Attempt__c examAttempt;
                               if(prod.productCode == 'SCRH') {
                                   examAttempt = mapLatestExamAttempts.get('SCRFull');
                               } else {
                                   examAttempt = mapLatestExamAttempts.get('RiskAIFull');
                               }
                               GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','examAttempt',examAttempt);

                               if(examAttempt != NULL) {
                                   Decimal registrantPrice = GARP_BC_StudyMaterials.getBookRegistrantPrice(examAttempt);
                                   GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','registrantPrice',registrantPrice);

                                   if(registrantPrice != NULL) {
                                       prod.amount = registrantPrice;
                                       pbe.UnitPrice = prod.amount;

                                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','discount study mat prod',prod.amount);
                                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','discount study mat prod',pbe.UnitPrice);
                                   }
                               }
                           }
                            */
                       }
                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','final prod',prod);

                       GARP_BC_StudyMaterials.studyMaterial sm = new GARP_BC_StudyMaterials.studyMaterial(pbe);
                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','final studyMaterial',sm);

                       // Does user already have this complimentry eBook?
                       if(sm.isCompWithReg) {
                           GARP_BC_StudyMaterials.eBook fndEBook = mapEBooks.get(pbe.Product2.Product_ID__c);
                           GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','fndEBook',fndEBook);
                           //if(fndEBook == NULL) {
                               regInfo.studyMaterials.add(sm);
                           //} else {
                           //    sm.isOwned = True;
                           //    sm.isCompWithReg = False;
                           //    regInfo.studyMaterials.add(sm);
                           //}
                       } else {
                           GARP_BC_StudyMaterials.eBook fndEBook = mapEBooks.get(pbe.Product2.Product_ID__c);
                           GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','fndEBook',fndEBook);
                           if(fndEBook == NULL) {
                               regInfo.studyMaterials.add(sm);
                           } else {
                               sm.isOwned = True;
                               regInfo.studyMaterials.add(sm);
                           }
                       }
                   }

                   if(prod.isMembershipProduct) {
                       // SCR Gets Discount Membership
                       //if(prod.productCode == 'MEMC' && regInfo.membershipInfo != NULL && (regInfo.membershipInfo.isCertified || regInfo.membershipInfo.isSCRHolder)) {
                       //    regInfo.Products.add(prod);
                       //} else if(prod.productCode == 'MEMI' && (regInfo.membershipInfo == NULL || (!regInfo.membershipInfo.isCertified && !regInfo.membershipInfo.isSCRHolder))) {
                       //    regInfo.Products.add(prod);
                       //}

                       if(regInfo.membershipInfo != NULL && (regInfo.membershipInfo.isCertified || regInfo.membershipInfo.isSCRHolder || regInfo.membershipInfo.isRAIHolder || regInfo.membershipInfo.isRAIJHolder)) {
                           if(prod.productCode == 'MEMC') {
                               regInfo.Products.add(prod);
                           }
                       } else if(prod.productCode == 'MEMI') {
                           regInfo.Products.add(prod);
                       }

                   } else {
                       // Only Return Add-Ons
                       regInfo.Products.add(prod);
                   }
               }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','regInfo.Products',regInfo.Products);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','regInfo',regInfo);

        regInfo.screenInfo.Locations = mapCountryCodes.values();
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','Locations',regInfo.screenInfo.Locations);

        String companyRecordTypeId = RecordTypeHelper.GetRecordTypeId('Institution__c', 'Organization');
        String schooolRecordTypeId = RecordTypeHelper.GetRecordTypeId('Institution__c', 'Academic');

        regInfo.screenInfo.companies = [select id, Institution_Name__c
                                        from Institution__c where recordTypeId = :companyRecordTypeId  Order By Name];
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','companies',regInfo.screenInfo.companies);

        regInfo.screenInfo.schools = [select id, Institution_Name__c
                                      from Institution__c where recordTypeId = :schooolRecordTypeId  Order By Name];
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','schools',regInfo.screenInfo.schools);

        if(programRegistrationInfo.FAQCatName != NULL) {
            regInfo.screenInfo.FAQInfo = getFaqsByCategory(programRegistrationInfo.FAQCatName);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','FAQInfo',regInfo.screenInfo.FAQInfo);
        }

        if(programRegistrationInfo.registrationType == 'scr' || programRegistrationInfo.registrationType == 'riskai' || programRegistrationInfo.registrationType == 'raij') {
            regInfo.examSelectionInfo = GARP_BC_Courses.getExamSelectionInfo(mapProdByCodes, regInfo.membershipInfo, false, programRegistrationInfo.registrationType);
            if((regInfo.examSelectionInfo.part1Info == NULL || regInfo.examSelectionInfo.part1Info.examAdmins == NULL || regInfo.examSelectionInfo.part1Info.examAdmins.IsEmpty())
               || regInfo.examSelectionInfo.partsAvailable.IsEmpty()) {
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','getExamSelectionInfo ' + programRegistrationInfo.registrationType + ' error 1',regInfo.examSelectionInfo);
                regInfo.status = 'Error';
                if(teamRegInfo == NULL) {
                    regInfo.statusMessage = 'Course registration is not currently available';
                } else {
                    regInfo.statusMessage = 'Team registration code is not aplicable';
                }
                return regInfo;
            }
        } else if(programRegistrationInfo.registrationType == 'frm') {
            regInfo.examSelectionInfo = GARP_BC_Exams.getExamSelectionInfo(mapProdByCodes, regInfo.membershipInfo, false, teamRegInfo, programRegistrationInfo.loadKey);
            if((regInfo.examSelectionInfo.part1Info.examAdmins.IsEmpty() && regInfo.examSelectionInfo.part2Info.examAdmins.IsEmpty())
               || regInfo.examSelectionInfo.partsAvailable.IsEmpty()) {

                   GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','getExamSelectionInfo error 1',regInfo.examSelectionInfo);

                   regInfo.status = 'Error';
                   if(teamRegInfo == NULL) {
                       regInfo.statusMessage = 'Exam registration not currently available';
                   } else {
                       regInfo.statusMessage = 'Team registration code is not aplicable';
                   }

                   return regInfo;
               }
        } else if(programRegistrationInfo.registrationType == 'checkout') {

            for(GARP_BC_Orders.checkoutProduct prod :programRegistrationInfo.checkoutCart.checkoutProducts) {

                // Does this user already have eBook?
                PricebookEntry fndpbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, prod.productCode, '4030');

                if(fndpbe != NULL) {
                    GARP_BC_Orders.productInfo fndProductCart = new GARP_BC_Orders.productInfo(fndpbe);
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','fndProductCart',fndProductCart);

                    if(fndProductCart != NULL) {
                        GARP_BC_StudyMaterials.eBook fndEBook = mapEBooks.get(fndProductCart.accountingId);
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','fndEBook',fndEBook);

                        if(fndEBook != NULL) {
                            regInfo.status = 'Failed';
                            regInfo.statusMessage = 'eBook was already purchased';
                            return regInfo;
                        }
                    }
                }
            }

        }

        if(programRegistrationInfo.registrationType == 'frm' || programRegistrationInfo.registrationType == 'scr' || programRegistrationInfo.registrationType == 'riskai' || programRegistrationInfo.registrationType == 'raij') {
            if(regInfo.examSelectionInfo.part1Info != NULL) {
                for(examAdminInfo ea :regInfo.examSelectionInfo.part1Info.examAdmins) {
                    if(ea.examSites.IsEmpty()) {

                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','getExamSelectionInfo error part1Info',ea);

                        regInfo.status = 'Error';
                        regInfo.statusMessage = 'Registration is not currently available';
                        return regInfo;
                    }
                }
            }
            if(regInfo.examSelectionInfo.part2Info != NULL) {
                for(examAdminInfo ea :regInfo.examSelectionInfo.part2Info.examAdmins) {
                    if(ea.examSites.IsEmpty()) {

                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','getExamSelectionInfo error part2Info',ea);

                        regInfo.status = 'Error';
                        regInfo.statusMessage = 'Registration is not currently available';
                        return regInfo;
                    }
                }
            }
        }

        regInfo.status = 'Success';
        regInfo.statusMessage = 'Data retieved successfully';

        return regInfo;
    }

    /** Return regFees with Failed status and message naming the missing product code (when mapProd.get returns null). */
    private static registrationFees returnProductNotFound(registrationFees regFees, String productCode) {
        regFees.status = 'Failed';
        regFees.message = 'Product not found in product map: ' + (productCode != null ? productCode : '');
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','returnProductNotFound',regFees);
        return regFees;
    }

    // Return selected products with updated pricing
    // Return all additional fees
    public static registrationFees getRegistrationFees(getRegistrationFeesInfo getRegistrationFeesInfo) {
        registrationFees regFees = new registrationFees();

        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','getRegistrationFeesInfo',getRegistrationFeesInfo);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','checkoutCart',getRegistrationFeesInfo.programRegistrationInfo.checkoutCart);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mainMemberProductCode',getRegistrationFeesInfo.programRegistrationInfo.mainMemberProductCode);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','teamRegCode',getRegistrationFeesInfo.teamRegCode);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','affiliateCode',getRegistrationFeesInfo.affiliateCode);

        Boolean isCheckoutCart = False;
        if(getRegistrationFeesInfo.programRegistrationInfo.checkoutCart != NULL && !getRegistrationFeesInfo.programRegistrationInfo.checkoutCart.checkoutProducts.IsEmpty()) {
            isCheckoutCart = True;
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','isCheckoutCart',isCheckoutCart);

        if((getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'frm' || getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'scr' || getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'riskai' || getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'raij') &&
           getRegistrationFeesInfo.examSelectionInfo == NULL) {
               regFees.status = 'Failed';
               regFees.message = 'Exam Selection information is missing';
               return regFees;
           }

        GARP_StripeSettings__c stripeSetting = GARP_StripeClass.getStripeSettings();

        GARP_Common.checkAuthentication checkAuth = GARP_Common.checkAuthentication();
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','checkAuth',checkAuth);

        GARP_BC_Membership.membershipInfo membershipInfo;
        String accountId;
        if(checkAuth.isAuthenticated) {
            membershipInfo = GARP_BC_Membership.getMembershipInfo(checkAuth.user.contactId);
            accountId = membershipInfo.contactRecord.AccountId;
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','membershipInfo',membershipInfo);

        MAP<String, Country_Code__c> mapCountryCodes = GARP_BC_Shipping.getCountryCodesMap();
        Set<Country_Code__c> VATCountryCodes = new Set<Country_Code__c>();
        Set<String> vatTaxProductCodes = new Set<String>();
        for(Country_Code__c cc :mapCountryCodes.values()) {
            if(cc.VAT__c != NULL) {
                VATCountryCodes.add(cc);
                vatTaxProductCodes.add(cc.VAT_Product_Code__c);
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','vatTaxProductCodes',vatTaxProductCodes);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','VATCountryCodes',VATCountryCodes);

        // Team Reg Get Info
        teamRegInfo teamRegInfo;
        if(!String.isEmpty(getRegistrationFeesInfo.teamRegCode) && String.isEmpty(getRegistrationFeesInfo.affiliateCode )) {
            retGetTeamRegistrationInfo retTeamInfo = getTeamRegistrationInfo(getRegistrationFeesInfo.programRegistrationInfo, accountId, False);
            if(retTeamInfo.status != 'Success') {
                regFees.status = retTeamInfo.status;
                regFees.message = retTeamInfo.statusMessage;
                return regFees;
            } else {
                teamRegInfo = retTeamInfo.teamRegInfo;

                // Set Discount Code is needed
                if(teamRegInfo.discountProductCode != NULL && getRegistrationFeesInfo.programRegistrationInfo.teamRegDiscountProductCode == NULL) {
                    getRegistrationFeesInfo.programRegistrationInfo.teamRegDiscountProductCode = teamRegInfo.discountProductCode;
                }
            }
        }

        // Events
        GARP_BC_Events.eventRegistrationInfo eventRegistrationInfo;
        if(getRegistrationFeesInfo.programRegistrationInfo.eventId != NULL) {
            eventRegistrationInfo = GARP_BC_Events.getEventInfo(getRegistrationFeesInfo.programRegistrationInfo.eventId, getRegistrationFeesInfo.programRegistrationInfo.eventType);

            if(eventRegistrationInfo.bundledEventId != NULL) {
                eventRegistrationInfo.bundledEventRegistrationInfo = GARP_BC_Events.getEventInfo(eventRegistrationInfo.bundledEventId, getRegistrationFeesInfo.programRegistrationInfo.eventType);
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','bundledEventRegistrationInfo',eventRegistrationInfo.bundledEventRegistrationInfo);
            }

        }

        // Event Rates
        MAP<String, GARP_BC_Events.eventRate> mapEventRates;
        MAP<String, GARP_BC_Events.eventDiscount> mapEventDiscounts;

        if(getRegistrationFeesInfo.programRegistrationInfo.eventType == 'event') {
            GARP_BC_Events.retEventRates retRates = GARP_BC_Events.getEventRates(getRegistrationFeesInfo.programRegistrationInfo.eventId);
            if(retRates != NULL && retRates.mapRates != NULL) {
                mapEventRates = retRates.mapRates;
            }
            mapEventDiscounts = GARP_BC_Events.getEventDiscounts(getRegistrationFeesInfo.programRegistrationInfo.eventId);

        } else if(getRegistrationFeesInfo.programRegistrationInfo.eventType == 'chaptermeeting') {
            GARP_BC_Events.retChapterMeetingRates retRates = GARP_BC_Events.getChapterMeetingRates(getRegistrationFeesInfo.programRegistrationInfo.eventId);
            if(retRates != NULL && retRates.mapRates != NULL) {
                mapEventRates = retRates.mapRates;
            }
            mapEventDiscounts = GARP_BC_Events.getChapterMeetingDiscounts(getRegistrationFeesInfo.programRegistrationInfo.eventId);
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mapEventRates',mapEventRates);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mapEventDiscounts',mapEventDiscounts);

        List<String> eventProductCodes = new List<String>();
        String eventVATProductCode;
        PricebookEntry eventVATPbe;
        Decimal eventVATAmount;
        Boolean hasEventRates = False;
        if(mapEventRates != NULL && !mapEventRates.IsEmpty()) {
            hasEventRates = True;
            for(GARP_BC_Events.eventRate er :mapEventRates.values()) {
                if(er.memberProductCode != NULL)
                    eventProductCodes.add(er.memberProductCode);
                if(er.nonMemberProductCode != NULL)
                    eventProductCodes.add(er.nonMemberProductCode);

                if(er.memberBundleProductCode != NULL)
                    eventProductCodes.add(er.memberBundleProductCode);
                if(er.nonMemberBundleProductCode != NULL)
                    eventProductCodes.add(er.nonMemberBundleProductCode);

                if(er.teamNonMemberProductCode != NULL)
                    eventProductCodes.add(er.teamNonMemberProductCode);

                if(er.teamMemberProductCode != NULL)
                    eventProductCodes.add(er.teamMemberProductCode);

                if(er.teamNonMemberBundleProductCode != NULL)
                    eventProductCodes.add(er.teamNonMemberBundleProductCode);
                if(er.teamMemberBundleProductCode != NULL)
                    eventProductCodes.add(er.teamMemberBundleProductCode);

                if(er.vatProductCode != NULL)
                    eventVATProductCode = er.vatProductCode;
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','hasEventRates',hasEventRates);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','eventProductCodes',eventProductCodes);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','eventVATProductCode',eventVATProductCode);

        // Get Users eBooks & Practice Exams
        MAP<String,GARP_BC_StudyMaterials.eBook> mapEBooks = new MAP<String,GARP_BC_StudyMaterials.eBook>();
        if(checkAuth.isAuthenticated && (getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'frm' || getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'scr')) {
            List<GARP_BC_StudyMaterials.eBook> eBooks = GARP_BC_StudyMaterials.getMyElectronicStudyMaterials(membershipInfo.accountRecord.Id, NULL);
            if(!eBooks.IsEmpty()) {
                for(GARP_BC_StudyMaterials.eBook eb :eBooks) {
                    mapEBooks.put(eb.accountingId, eb);
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mapEBooks',mapEBooks);


        // Add Book Discount Product Codes
        List<String> discountBookProductCodes = new List<String>();
        if(isCheckoutCart && !getRegistrationFeesInfo.programRegistrationInfo.mainProductCodes.IsEmpty()) {
            for(String prodCode :getRegistrationFeesInfo.programRegistrationInfo.mainProductCodes) {
                GARP_BC_Registration.programRegistrationInfo courseRegistrationInfo;
                if(prodCode == 'RAIH') {
                    courseRegistrationInfo = GARP_BC_Courses.getRiskAIRegistrationSettings(Null);
                } else if(prodCode == 'RAIJH') {
                    courseRegistrationInfo = GARP_BC_Courses.getRAIJRegistrationSettings(Null);
                } else if(prodCode == 'SCRH') {
                    courseRegistrationInfo = GARP_BC_Courses.getSCRRegistrationSettings(Null);
                }
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','courseRegistrationInfo',courseRegistrationInfo);
                if (courseRegistrationInfo != null) {
                    discountBookProductCodes.add(courseRegistrationInfo.studyMaterialDiscountProductCode);
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','discountBookProductCodes',discountBookProductCodes);

        List<String> productCodes = new List<String>();
        productCodes.addAll(new List<String>{'MEMF','MEMFX','MEMI','MEMC','SHIP','SHIPFRM1','SHIPFRM2','SHIPSCR','SHIPFFR','SHIPFRR','SHIPFRRS','SHIPMC','SHIPRAI','SHIPRAIJ','PRFEE','CDNTAX','SLSTX'});
        productCodes.addAll(vatTaxProductCodes);
        productCodes.add(getRegistrationFeesInfo.programRegistrationInfo.mainMemberProductCode);
        productCodes.add(getRegistrationFeesInfo.programRegistrationInfo.mainNonMemberProductCode);
        productCodes.add(getRegistrationFeesInfo.programRegistrationInfo.mainCertifiedProductCode);
        productCodes.add(getRegistrationFeesInfo.programRegistrationInfo.retakeProductCode);
        productCodes.add(getRegistrationFeesInfo.programRegistrationInfo.teamRegDiscountProductCode);
        productCodes.add(getRegistrationFeesInfo.programRegistrationInfo.eventDiscountProductCode);
        productCodes.add(getRegistrationFeesInfo.programRegistrationInfo.studyMaterialDiscountProductCode);

        productCodes.addAll(GARP_Common.safeList(discountBookProductCodes));
        productCodes.addAll(GARP_Common.safeList(getRegistrationFeesInfo.programRegistrationInfo.studyMatProductCodes));
        productCodes.addAll(GARP_Common.safeList(getRegistrationFeesInfo.programRegistrationInfo.addOnsProductCodes));
        productCodes.addAll(GARP_Common.safeList(getRegistrationFeesInfo.programRegistrationInfo.mainProductCodes));
        productCodes.addAll(GARP_Common.safeList(getRegistrationFeesInfo.programRegistrationInfo.feesProductCodes));
        productCodes.addAll(GARP_Common.safeList(getRegistrationFeesInfo.programRegistrationInfo.teamProductCodes));
        productCodes.addAll(eventProductCodes);
        if(eventVATProductCode != NULL) {
            productCodes.add(eventVATProductCode);
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','productCodes',productCodes);

        List<String> priceIds = new List<String>();
        MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(productCodes, priceIds);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mapProdByCodes',mapProdByCodes);

         MAP<String,Exam_Attempt__c> mapLatestExamAttempts;
        if(checkAuth.isAuthenticated) {
            GARP_BC_MyPrograms.returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(checkAuth.user.contactId);
            mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;
        }

        // Collect Selections
        regFees.feeProducts = new List<GARP_BC_Orders.productInfo>();
        regFees.feeProductsForDisplay = new List<GARP_BC_Orders.productInfo>();
        MAP<String,GARP_BC_Orders.productInfo> mapFeeProducts = new MAP<String,GARP_BC_Orders.productInfo>();
        MAP<String,PricebookEntry> mapProd = new MAP<String,PricebookEntry>();
        MAP<String,GARP_BC_Orders.productInfo> mapCompStudyMats = new MAP<String,GARP_BC_Orders.productInfo>();
        for(String getCode :mapProdByCodes.keySet()) {

            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','getCode',getCode);

            List<String> keyParts = getCode.split(':');
            PricebookEntry pbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, keyParts[0], keyParts.size() > 1 ? keyParts[1] : null);
            if (pbe == null) { continue; }
            //GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Find pbe',pbe);

            mapProd.put(pbe.Product2.ProductCode, pbe);

            // Find Comp Study Materials
            if(pbe.Product2.Is_Comped_Registration__c) {

                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','isComped',pbe.Product2);
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','registrationType',getRegistrationFeesInfo.programRegistrationInfo.registrationType);

                if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'scr') {
                    GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(pbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, pbe, False);
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','addProd',addProd);

                    // Should Comp eBook?
                    GARP_BC_StudyMaterials.eBook fndEBook = mapEBooks.get(pbe.Product2.Product_ID__c);
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndEBook',fndEBook);
                    if(fndEBook == NULL) {
                        mapCompStudyMats.put(addProd.productId, addProd);
                    }

                } else if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'frm') {
                    GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(pbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, pbe, False);
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','addProd',addProd);

                    if(GARP_BC_Exams.isStudyMaterialRelatedToSelection(getRegistrationFeesInfo, addProd)) {

                        // Should Comp eBook?
                        GARP_BC_StudyMaterials.eBook fndEBook = mapEBooks.get(pbe.Product2.Product_ID__c);
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndEBook',fndEBook);
                        if(fndEBook == NULL) {
                            mapCompStudyMats.put(addProd.productId, addProd);
                        }

                    }
                } else if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'frr' && pbe.Product2.ProductCode == 'CBRHB') {
                    // Skip, this needs to be selected

                } else {
                    GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(pbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, pbe, False);
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','addProd',addProd);
                    mapCompStudyMats.put(addProd.productId, addProd);
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mapProd',mapProd);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mapProdByCodes',mapProdByCodes);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mapCompStudyMats',mapCompStudyMats);

        getRegistrationFeesInfo.membershipOptions = setAllMembershipOptions(getRegistrationFeesInfo.membershipOptions);

        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','membershipOptions',getRegistrationFeesInfo.membershipOptions);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','membershipInfo',membershipInfo);

        // Find Main Products
        List<PricebookEntry> mainProds = new List<PricebookEntry>();

        // Get Enrollment
        GARP_BC_Exams.returnFRMEnrollmentInfo frmEnrollmentInfo = GARP_BC_Exams.getFRMEnrollmentInfo(mapProdByCodes, membershipInfo, getRegistrationFeesInfo);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','frmEnrollmentInfo',frmEnrollmentInfo);

        if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'frm' && frmEnrollmentInfo.isEnrollmentRequired && frmEnrollmentInfo.enrollmentPbe == NULL) {
            regFees.status = 'Failed';
            regFees.message = 'Enrollment Product not found';
            return regFees;
        }

        // Is ReTake?
        Boolean isRetake=False;
        if(membershipInfo != NULL && getRegistrationFeesInfo.programRegistrationInfo.retakeProductCode != NULL) {
            if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'frr' || getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'frr25') {
                isRetake = GARP_BC_Courses.isCourseRetake(membershipInfo, getRegistrationFeesInfo.programRegistrationInfo.registrationType, null);
            } else if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'micro') {
                isRetake = GARP_BC_Courses.isCourseRetake(membershipInfo, 'micro', getRegistrationFeesInfo.programRegistrationInfo.microCourseInfo);
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','isRetake',isRetake);

        if(isRetake) {
            PricebookEntry fndRetakePbe = mapProd.get(getRegistrationFeesInfo.programRegistrationInfo.retakeProductCode);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndRetakePbe',fndRetakePbe);
            if(fndRetakePbe == NULL) { return returnProductNotFound(regFees, getRegistrationFeesInfo.programRegistrationInfo.retakeProductCode); }
            mainProds.add(fndRetakePbe);
        } else {

            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mainMemberProductCode',getRegistrationFeesInfo.programRegistrationInfo.mainMemberProductCode);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mainNonMemberProductCode',getRegistrationFeesInfo.programRegistrationInfo.mainNonMemberProductCode);

            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','eventId',getRegistrationFeesInfo.programRegistrationInfo.eventId);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mapEventRates',mapEventRates);

            if((getRegistrationFeesInfo.programRegistrationInfo.mainMemberProductCode != NULL ||
                getRegistrationFeesInfo.programRegistrationInfo.mainNonMemberProductCode != NULL) &&
               (getRegistrationFeesInfo.programRegistrationInfo.eventId == NULL || !hasEventRates)) {

                   GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','In Mem/NonMem Products','');

                   // Select Member v Non-Member Main Product
                   PricebookEntry fndMainPbe;

                   // Get Product for non-Team Discount Orders
                   if(teamRegInfo == NULL || teamRegInfo.discountPrice != NULL) {

                       if((getRegistrationFeesInfo.membershipOptions != NULL && getRegistrationFeesInfo.membershipOptions.hasSelectedMembership != NULL &&
                           getRegistrationFeesInfo.membershipOptions.hasSelectedMembership) || (membershipInfo != NULL && membershipInfo.isInGoodStanding)) {
                               fndMainPbe = mapProd.get(getRegistrationFeesInfo.programRegistrationInfo.mainMemberProductCode);
                           } else {
                               fndMainPbe = mapProd.get(getRegistrationFeesInfo.programRegistrationInfo.mainNonMemberProductCode);
                           }

                       // Check Certified Rate if Any
                       // OR SCR Holder and Membership
                       if(getRegistrationFeesInfo.programRegistrationInfo.mainCertifiedProductCode != NULL && membershipInfo != NULL) {

                           // If reg info has mainCertifiedProductCode defined, give cert rate
                           GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','certPriceViaSCR', membershipInfo.isSCRHolder);
                           GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','certPriceViaRAI', membershipInfo.isRAIHolder);

                           if(membershipInfo.isCertified || membershipInfo.isSCRHolder || membershipInfo.isRAIHolder || membershipInfo.isRAIJHolder) {
                               fndMainPbe = mapProd.get(getRegistrationFeesInfo.programRegistrationInfo.mainCertifiedProductCode);
                           }
                       }

                       if(fndMainPbe != NULL) {
                           mainProds.add(fndMainPbe);
                       } else {
                           String mainCode = getRegistrationFeesInfo.programRegistrationInfo.mainMemberProductCode != null ? getRegistrationFeesInfo.programRegistrationInfo.mainMemberProductCode : getRegistrationFeesInfo.programRegistrationInfo.mainNonMemberProductCode;
                           if (mainCode == null) { mainCode = getRegistrationFeesInfo.programRegistrationInfo.mainCertifiedProductCode; }
                           return returnProductNotFound(regFees, mainCode != null ? mainCode : 'main product');
                       }
                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Get Standard Main Product',fndMainPbe);
                   }

                   // Team Reg Discounts
                   if(teamRegInfo != NULL && teamRegInfo.discountPrice != NULL) {
                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Team Discount',teamRegInfo.discountPrice);
                       PricebookEntry fndTeamRegDiscountPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProd, getRegistrationFeesInfo.programRegistrationInfo.teamRegDiscountProductCode);
                       if(fndTeamRegDiscountPbe != NULL) {
                           GARP_BC_Orders.productInfo addDiscountProd = setProductInfo(new GARP_BC_Orders.productInfo(fndTeamRegDiscountPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndTeamRegDiscountPbe, False);
                           addDiscountProd.amount = (fndMainPbe.UnitPrice - teamRegInfo.discountPrice) * -1;
                           GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Team Discount',addDiscountProd);
                           mapFeeProducts.put(addDiscountProd.productCode+':'+addDiscountProd.glCode,addDiscountProd);
                       } else { returnProductNotFound(regFees, getRegistrationFeesInfo.programRegistrationInfo.teamRegDiscountProductCode); }
                   } else if(teamRegInfo != NULL && teamRegInfo.isComplimentary) {
                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','discountPrice',teamRegInfo.discountPrice);
                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','rateType',teamRegInfo.rateType);

                       // If not rate type given user non-member
                       if(teamRegInfo.rateType == NULL || teamRegInfo.rateType == 'Non-Member') {
                           fndMainPbe = mapProd.get(getRegistrationFeesInfo.programRegistrationInfo.mainNonMemberProductCode);
                       } else if(teamRegInfo.rateType == 'Member') {
                           fndMainPbe = mapProd.get(getRegistrationFeesInfo.programRegistrationInfo.mainMemberProductCode);
                       } else if(teamRegInfo.rateType == 'Certified') {
                           fndMainPbe = mapProd.get(getRegistrationFeesInfo.programRegistrationInfo.mainCertifiedProductCode);
                       }
                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndMainPbe',fndMainPbe);

                       // New prepaid option to show Discount given on deal
                       if(teamRegInfo.prePaidDiscountPercent != NULL) {
                           PricebookEntry fndTeamRegDiscountPbe = mapProd.get(getRegistrationFeesInfo.programRegistrationInfo.teamRegDiscountProductCode);
                           if(fndTeamRegDiscountPbe != NULL) {
                               GARP_BC_Orders.productInfo addDiscountProd = setProductInfo(new GARP_BC_Orders.productInfo(fndTeamRegDiscountPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndTeamRegDiscountPbe, False);
                               addDiscountProd.amount = (fndMainPbe.UnitPrice * teamRegInfo.prePaidDiscountPercent) * -.01;
                               addDiscountProd.description = String.ValueOf(teamRegInfo.prePaidDiscountPercent) + '% Team Discount';
                               GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add PrePaid Discount',addDiscountProd);
                               mapFeeProducts.put(addDiscountProd.productCode+':'+addDiscountProd.glCode,addDiscountProd);
                           }
                       }

                       if(fndMainPbe != NULL) {
                           mainProds.add(fndMainPbe);
                       } else {
                           String mainCode = teamRegInfo.rateType == 'Certified' ? getRegistrationFeesInfo.programRegistrationInfo.mainCertifiedProductCode : (teamRegInfo.rateType == 'Member' ? getRegistrationFeesInfo.programRegistrationInfo.mainMemberProductCode : getRegistrationFeesInfo.programRegistrationInfo.mainNonMemberProductCode);
                           return returnProductNotFound(regFees, mainCode != null ? mainCode : 'main product');
                       }
                   }

               } else {  // Call BC Class to get main Product

                   GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','In Class Call Products','');

                   if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'scr' || getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'raij' || getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'riskai') {
                       String examProgramType = getRegistrationFeesInfo.programRegistrationInfo.registrationType;
                       GARP_BC_Courses.getExamMainProductReturnInfo retGetProducts = GARP_BC_Courses.getExamMainProduct(mapProdByCodes, membershipInfo, getRegistrationFeesInfo, teamRegInfo, getRegistrationFeesInfo.membershipOptions.hasSelectedMembership, examProgramType);
                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','retGetProducts',retGetProducts);
                       if(retGetProducts.status != 'Success') {
                           regFees.status = retGetProducts.status;
                           regFees.message = retGetProducts.message;
                           return regFees;
                       }

                       mainProds.AddAll(retGetProducts.products);
                       Boolean allowMembershipComp = True;
                       if(checkAuth.isAuthenticated) {
                           if(GARP_BC_Membership.hasCompedMembership(membershipInfo.accountRecord.Id)) {
                               allowMembershipComp = FALSE;
                           }
                       }
                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','allowMembershipComp',allowMembershipComp);
                       if(teamRegInfo != NULL && teamRegInfo.isRetakeOnly) {
                           Boolean isExamRetake = False;
                           if(membershipInfo != NULL) {
                               isExamRetake = GARP_BC_Courses.isExamRetake(membershipInfo, examProgramType);
                           }
                           if(!isExamRetake) {
                               regFees.status = 'Failed';
                               regFees.message = 'Team Registration only eligible for retake';
                               return regFees;
                           }
                       }
                       if(allowMembershipComp) {
                           PricebookEntry fndCompMemPbe = mapProd.get('MEMFX');
                           if (fndCompMemPbe == null) { return returnProductNotFound(regFees, 'MEMFX'); }
                           GARP_BC_Orders.productInfo productMem = new GARP_BC_Orders.productInfo(fndCompMemPbe);
                           mapFeeProducts.put(productMem.productCode+':'+productMem.glCode, productMem);
                       }
                   } else if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'frm') {

                       // Can have 2 products Part I and II so returns a list (FRM)
                       GARP_BC_Exams.getFRMMainProductsReturnInfo retGetProducts = GARP_BC_Exams.getFRMMainProducts(mapProdByCodes, membershipInfo, getRegistrationFeesInfo, teamRegInfo, frmEnrollmentInfo);
                       GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','retGetProducts',retGetProducts);
                       if(retGetProducts.status != 'Success') {
                           regFees.status = retGetProducts.status;
                           regFees.message = retGetProducts.message;
                           return regFees;
                       }
                       mainProds.AddAll(retGetProducts.products);

                       // Add Complimentry Membership if Enrolling
                       if(frmEnrollmentInfo.isEnrollmentRequired) {

                           // Check Retake Eligability
                           if(teamRegInfo != NULL && teamRegInfo.isRetakeOnly) {
                               regFees.status = 'Failed';
                               regFees.message = 'Team Registration only eligible for retake';
                               return regFees;
                           }

                           // Check if already recieved Membership Comp
                           Boolean allowMembershipComp = TRUE;
                           if(checkAuth.isAuthenticated) {
                               if(GARP_BC_Membership.hasCompedMembership(membershipInfo.accountRecord.Id)) {
                                    allowMembershipComp = FALSE;
                               }
                           }
                           GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','allowMembershipComp',allowMembershipComp);

                           if(allowMembershipComp) {
                               PricebookEntry fndCompMemPbe = mapProd.get('MEMF');
                               if (fndCompMemPbe == null) { return returnProductNotFound(regFees, 'MEMF'); }
                               GARP_BC_Orders.productInfo productMem = new GARP_BC_Orders.productInfo(fndCompMemPbe);
                               mapFeeProducts.put(productMem.productCode+':'+productMem.glCode, productMem);
                           }
                       }

                   } else if(getRegistrationFeesInfo.programRegistrationInfo.eventId != NULL) {

                       // Find Event Rate
                       GARP_BC_Events.eventMainProdInfo eventMainProdInfo = GARP_BC_Events.getEventMainProduct(mapProdByCodes, membershipInfo, mapEventRates, mapEventDiscounts, getRegistrationFeesInfo, teamRegInfo);

                       if(eventMainProdInfo.eventPbe != NULL) {
                           mainProds.add(eventMainProdInfo.eventPbe);
                       } else {
                           regFees.status = 'Failed';
                           regFees.message = 'Unable to locate fees for this event';
                           return regFees;
                       }
                       regFees.promoCodes = eventMainProdInfo.promoCodes;

                       // Add Event Discount Product
                       if(eventMainProdInfo.discountPbe != NULL) {
                           GARP_BC_Orders.productInfo productDiscount = new GARP_BC_Orders.productInfo(eventMainProdInfo.discountPbe);
                           mapFeeProducts.put(productDiscount.productCode+':'+productDiscount.glCode, productDiscount);
                       }

                       // Calc Event VAT
                       if(eventVATProductCode != NULL) {
                           eventVATPbe = mapProd.get(eventVATProductCode);
                           if (eventVATPbe == null) { return returnProductNotFound(regFees, eventVATProductCode); }
                           GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','eventVATPbe',eventVATPbe);
                           GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Tax Rate',eventVATPbe.Product2.Tax_Rate__c);

                           // AG UK TAX TODO -- May need to apply discount
                           eventVATAmount = eventMainProdInfo.eventPbe.UnitPrice * (eventVATPbe.Product2.Tax_Rate__c * .01);
                           GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Event VAT Tax',eventVATAmount);

                           eventVATAmount = eventVATAmount.setScale(2, RoundingMode.HALF_UP);
                           GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Event VAT Tax final',eventVATAmount);
                       }
                   }
               }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mainProds',mainProds);

        // Save FRM1 and FRM2 Accounting ID
        String frm1AccountingID;
        String frm2AccountingID;

        // Add Main Products to List
        if(!mainProds.isEmpty()) {

            for(PricebookEntry mainPbe :mainProds) {
                GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(mainPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, mainPbe, True);
                mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add mapFeeProducts',addProd);

                // Save FRM1 and FRM2 Accounting ID
                if(addProd.productCode == 'FRM1E' || addProd.productCode == 'FRM1S') {
                    frm1AccountingID = addProd.accountingId;
                }
                if(addProd.productCode == 'FRM2E' || addProd.productCode == 'FRM2S') {
                    frm2AccountingID = addProd.accountingId;
                }

            }
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Main mapFeeProducts', mapFeeProducts);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','frm1AccountingID', frm1AccountingID);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','frm2AccountingID', frm2AccountingID);

        } else if(isCheckoutCart) {

            // Add checkout products
            Decimal totalAmount = 0;
            for(GARP_BC_Orders.checkoutProduct prod :getRegistrationFeesInfo.programRegistrationInfo.checkoutCart.checkoutProducts) {
                PricebookEntry fndCheckoutPbe = mapProd.get(prod.productCode);
                if (fndCheckoutPbe == null) { return returnProductNotFound(regFees, prod.productCode); }
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Checkout fndCheckoutPbe',fndCheckoutPbe);

                GARP_BC_Orders.productInfo productCart = new GARP_BC_Orders.productInfo(fndCheckoutPbe, prod);
                productCart.isMainProduct = True;
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Checkout productCart',productCart);

                totalAmount+=fndCheckoutPbe.UnitPrice;
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','totalAmount',totalAmount);


                // B2B eBooks
                // Set to free if no Discount is configured
                if(teamRegInfo != NULL && teamRegInfo.eBookProductCode == productCart.productCode && teamRegInfo.discountProductCode == NULL) {
                    productCart.amount = 0;
                }
                mapFeeProducts.put(productCart.productCode+':'+productCart.glCode, productCart);

                if(fndCheckoutPbe.Product2.ProductCode == 'RAIH' || fndCheckoutPbe.Product2.ProductCode == 'SCRH' || fndCheckoutPbe.Product2.ProductCode == 'RAIJH') {

                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndCheckoutPbe is Candidate Book?',fndCheckoutPbe.Product2.ProductCode);

                    if(checkAuth.isAuthenticated) {

                        Exam_Attempt__c examAttempt;
                        GARP_BC_Registration.programRegistrationInfo courseRegistrationInfo;
                        if(fndCheckoutPbe.Product2.ProductCode == 'RAIH') {
                            examAttempt = mapLatestExamAttempts.get('RiskAIFull');
                            courseRegistrationInfo = GARP_BC_Courses.getRiskAIRegistrationSettings(Null);
                        } else if(fndCheckoutPbe.Product2.ProductCode == 'RAIJH') {
                            examAttempt = mapLatestExamAttempts.get('RAIJFull');
                            courseRegistrationInfo = GARP_BC_Courses.getRAIJRegistrationSettings(Null);
                        } else if(fndCheckoutPbe.Product2.ProductCode == 'SCRH') {
                            examAttempt = mapLatestExamAttempts.get('SCRFull');
                            courseRegistrationInfo = GARP_BC_Courses.getSCRRegistrationSettings(Null);
                        }
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','examAttempt',examAttempt);
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','courseRegistrationInfo',courseRegistrationInfo);

                        if(examAttempt != NULL) {
                            Decimal registrantPrice = GARP_BC_StudyMaterials.getBookRegistrantPrice(examAttempt);
                            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','registrantPrice',registrantPrice);
                            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndCheckoutPbe.unitPrice',fndCheckoutPbe.unitPrice);

                            if(registrantPrice != NULL && registrantPrice < fndCheckoutPbe.unitPrice) {
                                // Add discount
                                PricebookEntry fndStudyMatDiscountPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProd,courseRegistrationInfo.studyMaterialDiscountProductCode);
                                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndStudyMatDiscountPbe',fndStudyMatDiscountPbe);

                                if(fndStudyMatDiscountPbe != NULL) {
                                    GARP_BC_Orders.productInfo addDiscountProd = setProductInfo(new GARP_BC_Orders.productInfo(fndStudyMatDiscountPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndStudyMatDiscountPbe, False);
                                    addDiscountProd.amount = (fndCheckoutPbe.UnitPrice - registrantPrice) * -1;
                                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Candidate Book Discount',addDiscountProd);
                                    mapFeeProducts.put(addDiscountProd.productCode+':'+addDiscountProd.glCode,addDiscountProd);

                                    // Put discount amount for tax calc
                                    productCart.discountAmount = registrantPrice;
                                    mapFeeProducts.put(productCart.productCode+':'+productCart.glCode, productCart);
                                } else {
                                    regFees.status = 'Failed';
                                    regFees.message = 'Unable to locate fees for this book discount';
                                    return regFees;
                                }
                            }
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','final fndCheckoutPbe',fndCheckoutPbe);
                }
            }
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Checkout mapFeeProducts', mapFeeProducts);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','totalAmount', totalAmount);

            // Add discount line item if configured
            if(teamRegInfo != NULL && teamRegInfo.discountProductCode != NULL) {
                PricebookEntry fndTeamRegDiscountPbe = mapProd.get(teamRegInfo.discountProductCode);
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndTeamRegDiscountPbe', fndTeamRegDiscountPbe);

                if(fndTeamRegDiscountPbe != NULL) {
                    GARP_BC_Orders.productInfo addDiscountProd = setProductInfo(new GARP_BC_Orders.productInfo(fndTeamRegDiscountPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndTeamRegDiscountPbe, False);
                    Decimal discountAmount=0;
                    if(teamRegInfo.discountPercent != NULL) {
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','discountPercent', discountAmount);

                        discountAmount = (totalAmount * (teamRegInfo.discountPercent * .01)) * -1;
                    } else if(teamRegInfo.discountPrice != NULL) {
                        discountAmount = (totalAmount - teamRegInfo.discountPrice) * -1;
                    }
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','discountAmount', discountAmount);

                    addDiscountProd.amount = discountAmount;

                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Team Discount',addDiscountProd);
                    mapFeeProducts.put(addDiscountProd.productCode+':'+addDiscountProd.glCode,addDiscountProd);
                }
            }

            regFees.status = 'Success';
        } else if(getRegistrationFeesInfo.membershipOptions == NULL || getRegistrationFeesInfo.membershipOptions.hasSelectedRiskNet == NULL) {
            regFees.status = 'Failed';
            regFees.message = 'Unable to locate fees';
            return regFees;
        }

        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mapFeeProducts',mapFeeProducts);

        PricebookEntry fndPbe;

        // Add Membership
        if(getRegistrationFeesInfo.membershipOptions != NULL && getRegistrationFeesInfo.membershipOptions.hasSelectedMembership != NULL && getRegistrationFeesInfo.membershipOptions.hasSelectedMembership) {
            if(membershipInfo != NULL && membershipInfo.isMember && membershipInfo.isInGoodStanding) {
                regFees.status = 'Failed';
                regFees.message = 'Membership cannot be bought if already a member';
            } else {
                // May 1, 2024 Enhanced SCR
                // SCR Gets Discount Membership
                if(membershipInfo != NULL && (membershipInfo.isCertified || membershipInfo.isSCRHolder || membershipInfo.isRAIHolder || membershipInfo.isRAIJHolder)) {
                //if(membershipInfo != NULL && membershipInfo.isCertified) {
                    fndPbe = mapProd.get('MEMC');
                } else {
                    fndPbe = mapProd.get('MEMI');
                }
                if (fndPbe == null) { return returnProductNotFound(regFees, (membershipInfo != null && (membershipInfo.isCertified || membershipInfo.isSCRHolder || membershipInfo.isRAIHolder || membershipInfo.isRAIJHolder)) ? 'MEMC' : 'MEMI'); }
                GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
                mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','add membership',addProd);
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','regFees2',mapFeeProducts);

        // Risk.Net
        if(getRegistrationFeesInfo.membershipOptions != NULL && getRegistrationFeesInfo.membershipOptions.hasSelectedRiskNet != NULL && getRegistrationFeesInfo.membershipOptions.hasSelectedRiskNet) {
            fndPbe = mapProd.get('MEMR');
            if (fndPbe == null) { return returnProductNotFound(regFees, 'MEMR'); }
            GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
            mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','regFees3',mapFeeProducts);


        // Study Materials

        // Add Comped Study Mats to Fee Products
        for(GARP_BC_Orders.productInfo prod :mapCompStudyMats.Values()) {
            mapFeeProducts.put(prod.productCode+':'+prod.glCode,prod);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','add comp study mat Fees',prod);
        }

        // Purchased
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','studyMaterials',getRegistrationFeesInfo.studyMaterials);

        Integer studyMaterialsNeedShippingCount = 0;
        if(getRegistrationFeesInfo.studyMaterials != NULL) {
            for(GARP_BC_StudyMaterials.studyMaterial studyMat :getRegistrationFeesInfo.studyMaterials) {

                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Loop studyMaterials',studyMat.productCode);

                if(studyMat.selected == True || isCheckoutCart) {

                    fndPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProd, studyMat.productCode);
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndPbe',fndPbe);
                    if (fndPbe == null) { return returnProductNotFound(regFees, studyMat.productCode); }

                    GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);

                    if(teamRegInfo != NULL && teamRegInfo.eBookProductCode == addProd.productCode && teamRegInfo.discountProductCode == NULL) {
                        addProd.amount = 0;
                    }
                    mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);

                    if(fndPbe.Product2.ProductCode == 'RAIH' || fndPbe.Product2.ProductCode == 'SCRH' || fndPbe.Product2.ProductCode == 'RAIJH') {

                        if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'riskai' || getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'scr' || getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'raij') {
                            Decimal registrantPrice = GARP_BC_StudyMaterials.getBookRegistrantPrice(getRegistrationFeesInfo.programRegistrationInfo.registrationType, fndPbe.unitPrice);
                            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','registrantPrice',registrantPrice);

                            if(registrantPrice < fndPbe.unitPrice) {
                                // Add discount
                                PricebookEntry fndStudyMatDiscountPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProd, getRegistrationFeesInfo.programRegistrationInfo.studyMaterialDiscountProductCode);

                                if(fndStudyMatDiscountPbe != NULL) {
                                    GARP_BC_Orders.productInfo addDiscountProd = setProductInfo(new GARP_BC_Orders.productInfo(fndStudyMatDiscountPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndStudyMatDiscountPbe, False);
                                    addDiscountProd.amount = (fndPbe.UnitPrice - registrantPrice) * -1;
                                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Candidate Book Discount',addDiscountProd);
                                    mapFeeProducts.put(addDiscountProd.productCode+':'+addDiscountProd.glCode,addDiscountProd);

                                    // Put discount amount for tax calc
                                    addProd.discountAmount = registrantPrice;
                                    mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
                                }
                            }
                        } else if(checkAuth.isAuthenticated) {

                            Exam_Attempt__c examAttempt;
                            if(fndPbe.Product2.ProductCode == 'RAIH') {
                                examAttempt = mapLatestExamAttempts.get('RiskAIFull');
                            } else if(fndPbe.Product2.ProductCode == 'RAIJH') {
                                examAttempt = mapLatestExamAttempts.get('RAIJFull');
                            } else {
                                examAttempt = mapLatestExamAttempts.get('SCRFull');
                            }
                            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','examAttempt',examAttempt);

                            if(examAttempt != NULL) {
                                Decimal registrantPrice = GARP_BC_StudyMaterials.getBookRegistrantPrice(examAttempt);
                                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationInfo','registrantPrice',registrantPrice);

                                if(registrantPrice != NULL && registrantPrice < fndPbe.unitPrice) {
                                    // Add discount
                                    PricebookEntry fndStudyMatDiscountPbe = mapProd.get(getRegistrationFeesInfo.programRegistrationInfo.studyMaterialDiscountProductCode);
                                    if(fndStudyMatDiscountPbe != NULL) {
                                        GARP_BC_Orders.productInfo addDiscountProd = setProductInfo(new GARP_BC_Orders.productInfo(fndStudyMatDiscountPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndStudyMatDiscountPbe, False);
                                        addDiscountProd.amount = (fndPbe.UnitPrice - registrantPrice) * -1;
                                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Candidate Book Discount',addDiscountProd);
                                        mapFeeProducts.put(addDiscountProd.productCode+':'+addDiscountProd.glCode,addDiscountProd);

                                        // Put discount amount for tax calc
                                        addProd.discountAmount = registrantPrice;
                                        mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
                                    }
                                }
                            }
                        }
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','final fndPbe',fndPbe);
                    }

                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add studyMaterials prod',addProd);

                    if(fndPbe.Product2.Is_Shippable__c) {
                        studyMaterialsNeedShippingCount++;
                    }
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','regFees4',mapFeeProducts);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','studyMaterialsNeedShippingCount',studyMaterialsNeedShippingCount);

        // Setup Addresses
        GARP_Common.address billingAddress;
        GARP_Common.address shippingAddress;
        if(getRegistrationFeesInfo.addressInfo != NULL) {
            billingAddress = getRegistrationFeesInfo.addressInfo.billingAddress;
            if(getRegistrationFeesInfo.addressInfo.billingAndShippingSame != NULL && getRegistrationFeesInfo.addressInfo.billingAndShippingSame) {
                shippingAddress = getRegistrationFeesInfo.addressInfo.billingAddress;
            } else {
                shippingAddress = getRegistrationFeesInfo.addressInfo.shippingAddress;
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','billingAddress',billingAddress);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','shippingAddress',shippingAddress);

        // Get MicroCourse Hard Book Code
        String microCourseHB;
        if(getRegistrationFeesInfo.programRegistrationInfo.microCourseInfo != NULL && getRegistrationFeesInfo.programRegistrationInfo.microCourseInfo.studyMaterialProductCodes != NULL) {
            for(String book :getRegistrationFeesInfo.programRegistrationInfo.studyMatProductCodes) {
                if(book.IndexOf('HB') > -1) {
                    microCourseHB = book;
                }
            }
        }

        // Get Shipping Fee
        Shipping_Charge__c shipChrg;
        Boolean hasShippingCharge = False;
        if(shippingAddress != NULL) {
            shipChrg = GARP_BC_Shipping.getShippingRate(shippingAddress, mapFeeProducts.values(), mapCountryCodes);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','shipChrg',shipChrg);

            if(shipChrg != NULL && shipChrg.Shipping_Charge__c != NULL) {

                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','studyMaterials',getRegistrationFeesInfo.studyMaterials);

                if(getRegistrationFeesInfo.studyMaterials != NULL && !getRegistrationFeesInfo.studyMaterials.IsEmpty()) {

                    // Add Shipping product Line Item per Study Material
                    for(GARP_BC_StudyMaterials.studyMaterial studyMat :getRegistrationFeesInfo.studyMaterials) {
                        if(studyMat.selected == True || isCheckoutCart) {

                            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','ship study mat loop',studyMat);

                            PricebookEntry fndStudyMatPbe = mapProd.get(studyMat.productCode);
                            if (fndStudyMatPbe == null) { return returnProductNotFound(regFees, studyMat.productCode); }
                            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndStudyMatPbe',fndStudyMatPbe.Product2);

                            if(fndStudyMatPbe.Product2.Is_Shippable__c) {
                                String shipProdCode = 'SHIP';
                                if(fndStudyMatPbe.Product2.ProductCode == 'FRM1H') {
                                    shipProdCode = 'SHIPFRM1';
                                } else if(fndStudyMatPbe.Product2.ProductCode == 'FRM2H') {
                                    shipProdCode = 'SHIPFRM2';
                                } else if(fndStudyMatPbe.Product2.ProductCode == 'SCRH') {
                                    shipProdCode = 'SHIPSCR';
                                } else if(fndStudyMatPbe.Product2.ProductCode == 'RAIH') {
                                    shipProdCode = 'SHIPRAI';
                                } else if(fndStudyMatPbe.Product2.ProductCode == 'RAIJH') {
                                    shipProdCode = 'SHIPRAIJ';
                                } else if(fndStudyMatPbe.Product2.ProductCode == 'CBRHB') {
                                    shipProdCode = 'SHIPFRR';
                                    //} else if(fndStudyMatPbe.Product2.ProductCode == 'FRM2H') {
                                    //    shipProdCode = 'SHIPFFR';
                                } else if(fndStudyMatPbe.Product2.ProductCode == 'FRRSHB') {
                                    shipProdCode = 'SHIPFRRS';
                                } else if(microCourseHB != NULL && fndStudyMatPbe.Product2.ProductCode == microCourseHB) {
                                    shipProdCode = 'SHIPMC';
                                }

                                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','shipProdCode',shipProdCode);

                                PricebookEntry fndShipPbe = mapProd.get(shipProdCode);
                                if (fndShipPbe == null) { return returnProductNotFound(regFees, shipProdCode); }
                                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndShipPbe',fndShipPbe);

                                GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndShipPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndShipPbe, False);
                                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','addProd1',addProd);

                                addProd.amount = shipChrg.Shipping_Charge__c / (studyMaterialsNeedShippingCount);
                                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','addProd amount',addProd);

                                mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
                                hasShippingCharge = True;
                            }
                        }

                    }
                } else {
                    // Add shipping for non-study mats
                    PricebookEntry fndShipProdPbe = mapProd.get(shipChrg.Product_Code__c);
                    if (fndShipProdPbe == null) { return returnProductNotFound(regFees, shipChrg.Product_Code__c); }
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndShipProdPbe',fndShipProdPbe.Product2);
                    String shipProdCode = 'SHIP';

                    PricebookEntry fndShipPbe = mapProd.get(shipProdCode);
                    if (fndShipPbe == null) { return returnProductNotFound(regFees, shipProdCode); }
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndShipPbe',fndShipPbe);

                    GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndShipPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndShipPbe, False);
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','addProd1',addProd);

                    addProd.amount = shipChrg.Shipping_Charge__c;
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','addProd amount',addProd);

                    mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
                    hasShippingCharge = True;
                }


            }
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','regFees5',mapFeeProducts);

            // Canada Shipping Fee
            if(shipChrg != NULL && shippingAddress.country == 'Canada') {
                String cdnTaxProductId='CDNTAX';
                for(GARP_BC_StudyMaterials.studyMaterial studyMat :getRegistrationFeesInfo.studyMaterials) {
                    if(studyMat.productCode == 'FRM1H' || studyMat.productCode == 'FRM2H') {
                        cdnTaxProductId='CDNTAXFRM';
                    } else if(studyMat.productCode == 'SCRH') {
                        cdnTaxProductId='CDNTAXSCR';
                    } else if(studyMat.productCode == 'CBRHB') {
                        cdnTaxProductId='CDNTAXFRR';
                    } else if(studyMat.productCode == 'FRR25HB') {
                        cdnTaxProductId='CDNTAXFRR25';
                    } else if(microCourseHB != NULL && studyMat.productCode == microCourseHB) {
                        cdnTaxProductId='CDNTAXMC';
                    } else if(studyMat.productCode == 'RAIH') {
                        cdnTaxProductId='CDNTAXRAI';
                    } else if(studyMat.productCode == 'RAIJH') {
                        cdnTaxProductId='CDNTAXRAIJ';
                    }
                }
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','cdnTaxProductCode',cdnTaxProductId);

                fndPbe = mapProd.get('CDNTAX');
                if (fndPbe == null) { return returnProductNotFound(regFees, 'CDNTAX'); }
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndPbe',fndPbe);

                GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
                addProd.accountingId = cdnTaxProductId;
                mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
            }
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','regFees7',mapFeeProducts);
        }

        // FRM Fees
        GARP_BC_Registration.examSiteInfo selectedExamSitePart1;
        GARP_BC_Registration.examSiteInfo selectedExamSitePart2;

        if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'frm' && getRegistrationFeesInfo.examSelectionInfo == NULL) {
            regFees.status = 'Failed';
            regFees.message = 'Exam selection not available';
            return regFees;
        }

        if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'frm' && getRegistrationFeesInfo.examSelectionInfo != NULL) {

            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','compute FRM fees','');

            // Add Enrollment
            if(frmEnrollmentInfo.isEnrollmentRequired) {
                GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(frmEnrollmentInfo.enrollmentPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, frmEnrollmentInfo.enrollmentPbe, False);
                mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Enrollment Fee',addProd);
            }

            if(getRegistrationFeesInfo.examSelectionInfo.part1Info != NULL && getRegistrationFeesInfo.examSelectionInfo.partSelected.IndexOf('FRM Exam Part I') > -1) {
                selectedExamSitePart1= GARP_BC_Exams.getSelectedExamSite(getRegistrationFeesInfo.examSelectionInfo.part1Info);
            }
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','selectedExamSitePart1',selectedExamSitePart1);

            if(getRegistrationFeesInfo.examSelectionInfo.part2Info != NULL && getRegistrationFeesInfo.examSelectionInfo.partSelected.IndexOf('FRM Exam Part II') > -1) {
                selectedExamSitePart2 = GARP_BC_Exams.getSelectedExamSite(getRegistrationFeesInfo.examSelectionInfo.part2Info);
            }
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','selectedExamSitePart2',selectedExamSitePart2);

            if((selectedExamSitePart1 != NULL && selectedExamSitePart1.isOSTA) || (selectedExamSitePart2 != NULL && selectedExamSitePart2.isOSTA)) {
                Contract OSTAContract;
                if(membershipInfo != NUll && membershipInfo.accountRecord != NULL) {
                    OSTAContract = GARP_BC_Exams.getOSTAContract(membershipInfo.accountRecord.Id);
                }
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','OSTAContract',OSTAContract);

                // Should charge fees due to Team Reg?
                // For now leave on order
                //if(teamRegInfo == NULL || !teamRegInfo.isOSTAFeePaidByInstitution) {

                    if(OSTAContract == NULL) {

                        // Add Data Fee
                        fndPbe = mapProd.get('CHNDF');
                        if (fndPbe == null) { return returnProductNotFound(regFees, 'CHNDF'); }
                        GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
                        addProd.referenceId = (frm1AccountingID != NULL) ? frm1AccountingID : frm2AccountingID;

                        mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Data Fee',addProd);
                    }

                    // Add Location Fees
                    if(selectedExamSitePart1 != NULL && selectedExamSitePart1.isOSTA) {
                        fndPbe = mapProd.get('CHLF');
                        if (fndPbe == null) { return returnProductNotFound(regFees, 'CHLF'); }
                        GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);

                        addProd.productName += ' Part I';

                        // Save FRM1 and FRM2 Accounting ID
                        addProd.referenceId = frm1AccountingID;

                        mapFeeProducts.put(addProd.productCode+':'+addProd.glCode+'1',addProd);
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Part 1 Location Fee',addProd);
                    }
                    if(selectedExamSitePart2 != NULL && selectedExamSitePart2.isOSTA) {
                        fndPbe = mapProd.get('CHLF');
                        if (fndPbe == null) { return returnProductNotFound(regFees, 'CHLF'); }
                        GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);

                        addProd.productName += ' Part II';

                        // Save FRM1 and FRM2 Accounting ID
                        addProd.referenceId = frm2AccountingID;

                        mapFeeProducts.put(addProd.productCode+':'+addProd.glCode+'2',addProd);
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add Part 2 Location Fee',addProd);
                    }

                //}

            }
        } else if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'scr' && getRegistrationFeesInfo.examSelectionInfo != NULL) {
            if(getRegistrationFeesInfo.examSelectionInfo.part1Info != NULL) {
                selectedExamSitePart1 = GARP_BC_Exams.getSelectedExamSite(getRegistrationFeesInfo.examSelectionInfo.part1Info);
            }
        } else if(getRegistrationFeesInfo.programRegistrationInfo.registrationType == 'riskai' && getRegistrationFeesInfo.examSelectionInfo != NULL) {
            if(getRegistrationFeesInfo.examSelectionInfo.part1Info != NULL) {
                selectedExamSitePart1 = GARP_BC_Exams.getSelectedExamSite(getRegistrationFeesInfo.examSelectionInfo.part1Info);
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','selectedExamSitePart1',selectedExamSitePart1);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','selectedExamSitePart2',selectedExamSitePart2);

        // Wire / Check Fee
        Decimal totalAmount=0;
        for(GARP_BC_Orders.productInfo prod :mapFeeProducts.values()) {
            totalAmount+=prod.amount;
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','paymentType',getRegistrationFeesInfo.paymentType);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','totalAmount',totalAmount);

        if(totalAmount > 0) {
            if(getRegistrationFeesInfo.paymentType != NULL && (getRegistrationFeesInfo.paymentType == 'Wire Transfer' || getRegistrationFeesInfo.paymentType == 'Check' || getRegistrationFeesInfo.paymentType == 'ACH')) {
                fndPbe = mapProd.get('PRFEE');
                if (fndPbe == null) { return returnProductNotFound(regFees, 'PRFEE'); }
                GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
                mapFeeProducts.put(addProd.productCode+':'+addProd.glCode,addProd);
            }
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','regFees6',mapFeeProducts);
        }

        // Calc Totals
        Set<String> setStudyMatProductCodes = new Set<String>(getRegistrationFeesInfo.programRegistrationInfo.studyMatProductCodes);
        Set<String> setAddOnsProductCodes = new Set<String>(getRegistrationFeesInfo.programRegistrationInfo.addOnsProductCodes);

        Decimal totalVATAmount=0;
        Decimal totalAmountStudyMaterialsProductsSelected = 0;

        // Collect all Products
        // Fees calculates: Main Product, Membership, Taxes and Fees (not addons like Study Materials or Other services)
        for(GARP_BC_Orders.productInfo prod :mapFeeProducts.values()) {
            regFees.feeProducts.add(prod);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','add fees regFees',prod);
        }

        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','all regFees',regFees);

        regFees.hasCompMembership = False;
        regFees.needsShipping = False;
        regFees.hasBilling = False;
        Decimal vatSalesTaxAmount=0;
        regFees.njSalesTax=0;

        MAP<String,Decimal> vatTotalAmountByCountry = new MAP<String,Decimal>();

        for(GARP_BC_Orders.productInfo prod :regFees.feeProducts) {

            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Loop prod',prod);

            Decimal prodAmount;
            //if(prod.discountAmount != NULL) {
            //    prodAmount=prod.discountAmount;
            //} else {
                prodAmount = prod.amount;
            //}
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','prodAmount',prodAmount);

            // Loop over VAT Countries
            for(Country_Code__c cc :VATCountryCodes) {
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Loop VAT CC',cc);

                if(prod.doNotChargeVATCountries != NULL && prod.doNotChargeVATCountries.IndexOf(cc.ISOCode__c) > -1) {
                    // SKIP
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Do Not Charge VAT','');
                } else {
                    Decimal fndAmount = vatTotalAmountByCountry.get(cc.ISOCode__c);
                    if(fndAmount == NULL) {
                        fndAmount = prodAmount;
                    } else {
                        fndAmount += prodAmount;
                    }
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Add to VAT total',prodAmount);
                    vatTotalAmountByCountry.put(cc.ISOCode__c, fndAmount);
                }
            }

            //if(!prod.doNotChargeVAT) {
            //  totalVATAmount+=prodAmount;
            //}

            if((setStudyMatProductCodes.contains(prod.productCode) && prod.isTaxable) || prod.productCode == 'SCRCANDISC' || prod.productCode == 'RAICANDISC' || prod.productCode == 'RAIJCANDISC') {
                totalAmountStudyMaterialsProductsSelected+=prodAmount;
            }

            if(prod.productCode == 'MEMF') {
                regFees.hasCompMembership = True;
                regFees.compMembershipTerm = 12;
            } else if(prod.productCode == 'MEMFX') {
                regFees.hasCompMembership = True;
                regFees.compMembershipTerm = 6;
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','vatTotalAmountByCountry',vatTotalAmountByCountry);
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','totalAmountStudyMaterialsProductsSelected',totalAmountStudyMaterialsProductsSelected);

        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Use_Stripe_Tax__c',stripeSetting.Use_Stripe_Tax__c);


        if(!stripeSetting.Use_Stripe_Tax__c && shippingAddress != NULL && billingAddress != NULL) {
            Country_Code__c fndShipCC = mapCountryCodes.get(shippingAddress.country);
            Country_Code__c fndBillCC = mapCountryCodes.get(billingAddress.country);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndShipCC',fndShipCC);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','fndBillCC',fndBillCC);

            // NJ Shipping Sales Tax
            if(fndShipCC != NULL && fndShipCC.LetterCode__c == 'US' && shippingAddress.province != NULL && (shippingAddress.province == 'NJ' || shippingAddress.province == 'New Jersey')) {
                fndPbe = mapProd.get('SLSTX');
                if (fndPbe == null) { return returnProductNotFound(regFees, 'SLSTX'); }
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','get NJ Sales tax Product',fndPbe);

                GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
                if(fndPbe.Product2.Tax_Rate__c != NULL) {
                    Decimal taxRate = (fndPbe.Product2.Tax_Rate__c * .01);
                    Decimal totalMaterialAmount = totalAmountStudyMaterialsProductsSelected;
                    if(shipChrg != NULL) {
                        totalMaterialAmount += shipChrg.Shipping_Charge__c;
                    }
                    addProd.amount = totalMaterialAmount * taxRate;
                    addProd.amount = addProd.amount.setScale(2, RoundingMode.HALF_UP);

                    // Only add tax line item if any
                    if(addProd.amount > 0 && !stripeSetting.Use_Stripe_Tax__c) {
                        regFees.feeProducts.add(addProd);
                        regFees.njSalesTax = addProd.amount;
                    } else {
                        regFees.njSalesTax = 0;
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','regFees after tax',regFees);

            // VAT Tax

            // Should charge fees due to Team Reg?
            if(teamRegInfo == NULL || !teamRegInfo.isGSTFeePaidByInstitution) {

                // Calc Event VAT
                if(eventVATAmount != NULL && !stripeSetting.Use_Stripe_Tax__c) {
                    GARP_BC_Orders.productInfo prodEventUKVATProd = new GARP_BC_Orders.productInfo(eventVATPbe);
                    prodEventUKVATProd.amount = eventVATAmount;
                    //regFees.vatSalesTax = prodEventUKVATProd;
                    //regFees.subTotal = regFees.total - eventVATAmount;

                    regFees.feeProducts.add(prodEventUKVATProd);
                    vatSalesTaxAmount = prodEventUKVATProd.amount;
                    regFees.vatSalesTax = prodEventUKVATProd;
                } else {
                    // Calc GST
                    Integer matchCnt=0;
                    Decimal vatAmount;
                    String vatProducCode;
                    String vatISOCode;
                    String mobilePhoneCode;

                    if(getRegistrationFeesInfo.customerInfo != NULL && !String.IsEmpty(getRegistrationFeesInfo.customerInfo.mobilePhoneCode)) {
                        mobilePhoneCode = getRegistrationFeesInfo.customerInfo.mobilePhoneCode.replaceAll('[^0-9]', '');
                    }
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','mobilePhoneCode',mobilePhoneCode);

                    // Loop over VAT Countries
                    for(Country_Code__c cc :VATCountryCodes) {

                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Loop VAT Countries',cc);

                        // Need 2 Points to Match to Charge VAT
                        matchCnt=0;

                        if(mobilePhoneCode != NULL && mobilePhoneCode == cc.PhoneCode__c) {
                            matchCnt++;
                            vatAmount = cc.VAT__c;
                            vatProducCode = cc.VAT_Product_Code__c ;
                        }

                        if(fndShipCC != NULL && fndShipCC.VAT__c != NULL && fndShipCC.ISOCode__c == cc.ISOCode__c) {
                            matchCnt++;
                            vatAmount = cc.VAT__c;
                            vatProducCode = cc.VAT_Product_Code__c ;
                            vatISOCode = cc.ISOCode__c;
                        }
                        if(fndBillCC != NULL && fndBillCC.VAT__c != NULL && fndBillCC.ISOCode__c == cc.ISOCode__c) {
                            matchCnt++;
                            vatAmount = cc.VAT__c;
                            vatProducCode = cc.VAT_Product_Code__c;
                            vatISOCode = cc.ISOCode__c;
                        }

                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','VAT matchCnt',matchCnt);
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','vatAmount',vatAmount);
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','vatProducCode',vatProducCode);
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','vatISOCode',vatISOCode);

                        if(matchCnt >= 2) {
                            totalVATAmount = vatTotalAmountByCountry.get(vatISOCode);
                            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','totalVATAmount',totalVATAmount);
                            break;
                        }
                    }

                    if(matchCnt > 1 && vatAmount != NULL && vatAmount > 0 && totalVATAmount > 0 && !stripeSetting.Use_Stripe_Tax__c) {
                        fndPbe = mapProd.get(vatProducCode);
                        if (fndPbe == null) { return returnProductNotFound(regFees, vatProducCode); }
                        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','vat fndPbe',fndPbe);

                        GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
                        Decimal taxRate = fndPbe.Product2.Tax_Rate__c;
                        addProd.amount = totalVATAmount * (vatAmount * .01);
                        addProd.amount = addProd.amount.setScale(2, RoundingMode.HALF_UP);
                        regFees.feeProducts.add(addProd);
                        vatSalesTaxAmount = addProd.amount;
                        regFees.vatSalesTax = addProd;
                    }
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','regFees final',regFees);

        // ACH & Wire Stripe Tax Calc
        if(stripeSetting.Use_Stripe_Tax__c && (getRegistrationFeesInfo.paymentType == 'Wire Transfer' || getRegistrationFeesInfo.paymentType == 'ACH')) {
            GARP_StripeClass.retGetCheckoutTax retTax = GARP_StripeClass.sendGetCheckoutTax(regFees.feeProducts, getRegistrationFeesInfo.addressInfo);
            GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','retTax status',retTax.status);

            if(retTax.status == 'Success' && retTax.orderTaxInfo != NULL && retTax.orderTaxInfo.taxType != NULL) {
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','taxType',retTax.orderTaxInfo.taxType);
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','state',retTax.orderTaxInfo.state);

                regFees.orderTaxInfo = retTax.orderTaxInfo;

                // ===== Tax product resolution — DYNAMIC via custom metadata =====
                // The tax product code is resolved from the taxtype -> product-code mapping on
                // Stripe_Auth_Configuration__mdt.Stripe_Product_Code__c (reusing
                // StripeTaxCalUtil.getStripeAuthConfig + parseTaxTypeToProductCode), replacing the
                // hardcoded sales_tax/igst/gst branches. New tax countries = metadata change only.
                /* --- legacy hardcoded logic (retained for reference) ---
                if(retTax.orderTaxInfo.taxType == 'sales_tax' && retTax.orderTaxInfo.state == 'NJ') {
                    fndPbe = mapProd.get('SLSTX');
                    if (fndPbe == null) { return returnProductNotFound(regFees, 'SLSTX'); }
                    GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
                    addProd.amount = ((Decimal)retTax.orderTaxInfo.amount / 100).setScale(2);
                    regFees.feeProducts.add(addProd);
                    regFees.njSalesTax = addProd.amount;
                } else if(retTax.orderTaxInfo.taxType == 'igst') {
                    fndPbe = mapProd.get('IGSTTAX');
                    if (fndPbe == null) { return returnProductNotFound(regFees, 'IGSTTAX'); }
                    GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
                    addProd.amount = ((Decimal)retTax.orderTaxInfo.amount / 100).setScale(2);
                    regFees.feeProducts.add(addProd);
                    vatSalesTaxAmount = addProd.amount;
                    regFees.vatSalesTax = addProd;
                } else if(retTax.orderTaxInfo.taxType == 'gst') {
                    fndPbe = mapProd.get('GSTTAX');
                    if (fndPbe == null) { return returnProductNotFound(regFees, 'GSTTAX'); }
                    GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
                    addProd.amount = ((Decimal)retTax.orderTaxInfo.amount / 100).setScale(2);
                    regFees.feeProducts.add(addProd);
                    vatSalesTaxAmount = addProd.amount;
                    regFees.vatSalesTax = addProd;
                }
                --- end legacy hardcoded logic --- */

                Stripe_Auth_Configuration__mdt stripeCfg = StripeTaxCalUtil.getStripeAuthConfig();
                Map<String, String> taxTypeToProductCode = StripeTaxCalUtil.parseTaxTypeToProductCode(
                    stripeCfg == null ? null : stripeCfg.Stripe_Product_Code__c);

                String taxTypeKey = retTax.orderTaxInfo.taxType == null ? null : retTax.orderTaxInfo.taxType.toLowerCase();
                String taxPrCode = taxTypeKey == null ? null : taxTypeToProductCode.get(taxTypeKey);
                // Legacy parity: US sales tax is only applied for New Jersey.
                if(taxTypeKey == 'sales_tax' && retTax.orderTaxInfo.state != 'NJ') { taxPrCode = null; }

                if(String.isNotBlank(taxPrCode)) {
                    fndPbe = mapProd.get(taxPrCode);
                    if (fndPbe == null) { return returnProductNotFound(regFees, taxPrCode); }
                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','dynamic tax product',fndPbe);

                    GARP_BC_Orders.productInfo addProd = setProductInfo(new GARP_BC_Orders.productInfo(fndPbe), getRegistrationFeesInfo.programRegistrationInfo, membershipInfo, fndPbe, False);
                    addProd.amount = ((Decimal)retTax.orderTaxInfo.amount / 100).setScale(2);

                    GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','Final Tax Prod',addProd);
                    regFees.feeProducts.add(addProd);

                    // Preserve legacy field split: NJ sales tax -> njSalesTax; all others -> vatSalesTax.
                    if(taxTypeKey == 'sales_tax') {
                        regFees.njSalesTax = addProd.amount;
                    } else {
                        vatSalesTaxAmount = addProd.amount;
                        regFees.vatSalesTax = addProd;
                    }
                }
            }
        }


        // Calculate final return values
        if(teamRegInfo != NULL && teamRegInfo.teamRegId != NULL && teamRegInfo.isComplimentary) {
            regFees.needsShipping = False;
        } else {
            regFees.needsShipping = hasShippingCharge;
        }

        // Calc final totals
        // Setup feeProductsForDisplay
        regFees.total=0;
        Decimal totalShipping = 0;
        GARP_BC_Orders.productInfo prodShipping;

        for(GARP_BC_Orders.productInfo prod :regFees.feeProducts) {
            regFees.total += prod.amount;

            // Combine Shipping for display
            if(prod.productCode.indexOf('SHIP') == 0) {
                totalShipping+=prod.amount;
                prodShipping = new GARP_BC_Orders.productInfo(prod);
            } else {
                regFees.feeProductsForDisplay.add(prod);
            }
        }
        // Finish feeProductsForDisplay
        if(prodShipping != NULL) {
            prodShipping.amount = totalShipping;
            prodShipping.productName = 'Standard Shipping';
            regFees.feeProductsForDisplay.add(prodShipping);
        }

        // Compute Sub-Total
        regFees.subTotal = regFees.total - vatSalesTaxAmount - regFees.njSalesTax;

        // Has Billing is there are fess and is not Team Reg complimentry
        if(regFees.total > 0 && ((teamRegInfo == NULL || teamRegInfo.teamRegId == NULL) ||
                                 (teamRegInfo != NULL && teamRegInfo.teamRegId != NULL && !teamRegInfo.isComplimentary))) {
                                     regFees.hasBilling = True;
                                 }

        if(regFees.total == regFees.subTotal) {
            regFees.hasSubtotal = False;
        } else {
            regFees.hasSubtotal = True;
        }

        regFees.status = 'Success';
        regFees.message = 'Fees returned';
        return regFees;
    }

    // Create Order, Contracts, Account and Contact
    public static setRegistrationReturnInfo setRegistration(setRegistrationInfo setRegistrationInfo) {
        setRegistrationReturnInfo setRegistrationReturnInfo = new setRegistrationReturnInfo();

        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','registrationType',setRegistrationInfo.programRegistrationInfo.registrationType);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','customerInfo',setRegistrationInfo.customerInfo);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','paymentInfo',setRegistrationInfo.paymentInfo);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','membershipOptions',setRegistrationInfo.membershipOptions);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','eventOptions',setRegistrationInfo.eventOptions);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','checkoutCart',setRegistrationInfo.programRegistrationInfo.checkoutCart);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','affiliateCode',setRegistrationInfo.affiliateCode);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','teamRegInfo',setRegistrationInfo.teamRegInfo);

        // Validations
        if(setRegistrationInfo.customerInfo == NULL || setRegistrationInfo.customerInfo.email == NULL ||
           setRegistrationInfo.paymentInfo == NULL) {
               setRegistrationReturnInfo.message = 'Required Information Missing';
               setRegistrationReturnInfo.status = 'Failed';
               return setRegistrationReturnInfo;
           }

        if((setRegistrationInfo.programRegistrationInfo.registrationType == 'frm' || setRegistrationInfo.programRegistrationInfo.registrationType == 'scr' || setRegistrationInfo.programRegistrationInfo.registrationType == 'riskai' || setRegistrationInfo.programRegistrationInfo.registrationType == 'raij') && setRegistrationInfo.examSelectionInfo == NULL) {
            setRegistrationReturnInfo.message = 'Required Exam Selection Information Missing';
            setRegistrationReturnInfo.status = 'Failed';
            return setRegistrationReturnInfo;
        }

        checkExistingContact checkRet = GARP_BC_Registration.checkExistingContact(setRegistrationInfo.customerInfo.email);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','checkRet',checkRet);

        Contact contact = checkRet.contact;

        checkAuthentication checkAuth = GARP_BC_Registration.checkAuthentication();
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','checkAuth',checkAuth);

        Boolean isAuthenticated = checkAuth.isAuthenticated;

        if(!isAuthenticated && checkRet.isMember && !setRegistrationInfo.programRegistrationInfo.allowMemberPublicRegistration) {
            setRegistrationReturnInfo.message = 'Contact exists, must login';
            setRegistrationReturnInfo.status = 'Failed';
            return setRegistrationReturnInfo;
        }

        // AG 2/13/2026 -- Allow this now no Lead will be used
        //if(setRegistrationInfo.customerInfo.leadId == NULL && isAuthenticated == False) {
        //    setRegistrationReturnInfo.message = 'LeadId Missing from Unauthenticated';
        //    setRegistrationReturnInfo.status = 'Failed';
        //    return setRegistrationReturnInfo;
        //}

        GARP_BC_Membership.membershipInfo membershipInfo = GARP_BC_Membership.getMembershipInfo(checkAuth.user.contactId);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','membershipInfo',membershipInfo);

        // Authenticated and Non-Events
        String notEligibleErrorMessage = NULL;
        Boolean isEligible = True;
        Boolean isNetNew = False;

        teamRegInfo teamRegInfo;
        // Case 00888108: Save frontend consent release value before server-side overwrite
        Boolean frontendConsentRelease = (setRegistrationInfo.teamRegInfo != null)
            ? setRegistrationInfo.teamRegInfo.consentReleaseExamResults : null;
        retGetTeamRegistrationInfo retTeamInfo = getTeamRegistrationInfo(setRegistrationInfo.programRegistrationInfo, setRegistrationInfo.customerInfo.accountId, False);
        if(retTeamInfo.status == 'Success') {
           teamRegInfo = retTeamInfo.teamRegInfo;
        }
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','get teamRegInfo',teamRegInfo);
        setRegistrationInfo.teamRegInfo = teamRegInfo;
        // Case 00888108: Restore frontend consent release value after server-side overwrite
        if(setRegistrationInfo.teamRegInfo != null && frontendConsentRelease != null) {
            setRegistrationInfo.teamRegInfo.consentReleaseExamResults = frontendConsentRelease;
        }

        // Authenticated and Non-Events
        if(setRegistrationInfo.programRegistrationInfo.registrationType != 'event' && setRegistrationInfo.programRegistrationInfo.registrationType != 'checkout') {

            if(setRegistrationInfo.programRegistrationInfo.registrationType == 'ffr' || setRegistrationInfo.programRegistrationInfo.registrationType == 'frr' || setRegistrationInfo.programRegistrationInfo.registrationType == 'frr25') {
                GARP_BC_Courses.isEligibleCourseReturnInfo courseElig = GARP_BC_Courses.isEligibleCourse(membershipInfo, setRegistrationInfo.programRegistrationInfo.registrationType, teamRegInfo, null);
                notEligibleErrorMessage = courseElig.message;
                isEligible = courseElig.isEligible;
            } else if(setRegistrationInfo.programRegistrationInfo.registrationType == 'micro') {
                GARP_BC_Courses.isEligibleCourseReturnInfo courseElig = GARP_BC_Courses.isEligibleCourse(membershipInfo, 'micro', teamRegInfo, setRegistrationInfo.programRegistrationInfo.microCourseInfo);
                notEligibleErrorMessage = courseElig.message;
                isEligible = courseElig.isEligible;
            } else if(setRegistrationInfo.programRegistrationInfo.registrationType == 'scr' || setRegistrationInfo.programRegistrationInfo.registrationType == 'riskai' || setRegistrationInfo.programRegistrationInfo.registrationType == 'raij') {
                GARP_BC_Registration.RegistrationEligibility regElig = GARP_BC_Courses.isEligibleExam(membershipInfo, setRegistrationInfo.programRegistrationInfo.loadKey, setRegistrationInfo.programRegistrationInfo.registrationType);
                notEligibleErrorMessage = regElig.eligibleError;
                isNetNew = regElig.isNetNew;
                isEligible = (regElig.eligibleExams.size() > 0);

            } else if(setRegistrationInfo.programRegistrationInfo.registrationType == 'frm') {
                GARP_BC_Registration.RegistrationEligibility regElig = GARP_BC_Exams.isEligibleFRM(membershipInfo, setRegistrationInfo.programRegistrationInfo.loadKey);
                notEligibleErrorMessage = regElig.eligibleError;
                isNetNew = regElig.isNetNew;
                isEligible = (regElig.eligibleExams.size() > 0);

            } else if(setRegistrationInfo.programRegistrationInfo.registrationType == 'membership') {
                GARP_BC_Registration.RegistrationEligibility regElig = GARP_BC_Membership.isEligibleIndividualMembership(membershipInfo);
                notEligibleErrorMessage = regElig.eligibleError;
                isEligible = String.IsEmpty(notEligibleErrorMessage);

            }

            GARP_Common.debugLog('GARP_BC_Registration','setRegistration','isEligible',isEligible);
            GARP_Common.debugLog('GARP_BC_Registration','setRegistration','notEligibleErrorMessage',notEligibleErrorMessage);
            GARP_Common.debugLog('GARP_BC_Registration','setRegistration','isNetNew',isNetNew);
        }

        if(!isEligible) {
            setRegistrationReturnInfo.message = notEligibleErrorMessage;
            setRegistrationReturnInfo.status = 'Failed';
            return setRegistrationReturnInfo;
        }

        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','ExistingOrderId',setRegistrationInfo.PaymentInfo.ExistingOrderId);

        getRegistrationFeesInfo getRegFees = new getRegistrationFeesInfo();
        getRegFees.customerInfo = setRegistrationInfo.customerInfo;
        getRegFees.membershipOptions = setRegistrationInfo.membershipOptions;
        getRegFees.paymentType = setRegistrationInfo.paymentInfo.paymentType;
        getRegFees.studyMaterials = setRegistrationInfo.studyMaterials;
        getRegFees.addressInfo = setRegistrationInfo.addressInfo;
        getRegFees.programRegistrationInfo = setRegistrationInfo.programRegistrationInfo;

        if(teamRegInfo != NULL && !String.isEmpty(teamRegInfo.teamRegCode)) {
            getRegFees.teamRegCode = teamRegInfo.teamRegCode;
        }
        if(setRegistrationInfo.examSelectionInfo != NULL) {
            getRegFees.examSelectionInfo = setRegistrationInfo.examSelectionInfo;
        }
        if(setRegistrationInfo.promoCodes != NULL) {
            getRegFees.promoCodes = setRegistrationInfo.promoCodes;
        }
        getRegFees.isEventBundleSelected = setRegistrationInfo.isEventBundleSelected;
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','getRegFees',getRegFees);

        registrationFees regFees = getRegistrationFees(getRegFees);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','regFees',regFees);

        if(regFees.status != 'Success') {
            setRegistrationReturnInfo.message = regFees.message;
            setRegistrationReturnInfo.status = regFees.status;
            return setRegistrationReturnInfo;
        }

        // Captcha
        Utilities.updateFormSession(setRegistrationInfo.captchaInfo.sessionToken, setRegistrationInfo.customerInfo.email);
        Utilities.runCaptcha(setRegistrationInfo.captchaInfo.sessionToken);


        if(isAuthenticated && setRegistrationInfo.PaymentInfo.ExistingOrderId != NULL) {
            GARP_Common.debugLog('GARP_BC_Registration','setRegistration','removeOrder','');
            GARP_BC_Orders.removeOrder(setRegistrationInfo.PaymentInfo.ExistingOrderId);
        }

        // Create Order
        GARP_BC_Orders.setOrderInfo setOrderInfo = new GARP_BC_Orders.setOrderInfo();
        setOrderInfo.customerInfo = setRegistrationInfo.customerInfo;
        setOrderInfo.personalInfo = setRegistrationInfo.personalInfo;
        setOrderInfo.addressInfo = setRegistrationInfo.addressInfo;
        setOrderInfo.paymentInfo = setRegistrationInfo.paymentInfo;
        setOrderInfo.membershipOptions = setRegistrationInfo.membershipOptions;
        setOrderInfo.eventOptions = setRegistrationInfo.eventOptions;
        setOrderInfo.affiliateProgramInfo = getAffiliateProgramCredits(setRegistrationInfo, regFees.feeProducts);
        setOrderInfo.selectedProducts = regFees.feeProducts;
        setOrderInfo.hasBilling = regFees.hasBilling;
        setOrderInfo.formName = setRegistrationInfo.programRegistrationInfo.formName;
        setOrderInfo.allowMemberPublicRegistration = setRegistrationInfo.programRegistrationInfo.allowMemberPublicRegistration;
        setOrderInfo.checkoutCart = setRegistrationInfo.programRegistrationInfo.checkoutCart;
        setOrderInfo.isNetNew = isNetNew;
        setOrderInfo.teamRegInfo = teamRegInfo;
        setOrderInfo.orderTaxInfo = regFees.orderTaxInfo;

        // Compute doNotCreateAffiliateMember
        // AG - 2/28/2026 Dont get this!!
        //setOrderInfo.doNotCreateAffiliateMember = (teamRegInfo != null);
        setOrderInfo.doNotCreateAffiliateMember = False;

        // Event Information
        GARP_BC_Events.eventRegistrationInfo eventRegistrationInfo;
        if(setRegistrationInfo.programRegistrationInfo.eventId != NULL) {
            eventRegistrationInfo = GARP_BC_Events.getEventInfo(setRegistrationInfo.programRegistrationInfo.eventId, setRegistrationInfo.programRegistrationInfo.eventType);

            if(eventRegistrationInfo.bundledEventId != NULL) {
                eventRegistrationInfo.bundledEventRegistrationInfo = GARP_BC_Events.getEventInfo(eventRegistrationInfo.bundledEventId, setRegistrationInfo.programRegistrationInfo.eventType);
                GARP_Common.debugLog('GARP_BC_Registration','getRegistrationFees','bundledEventRegistrationInfo',eventRegistrationInfo.bundledEventRegistrationInfo);
            }

            // Set doNotCreateAffiliateMember
            if(setRegistrationInfo.programRegistrationInfo.eventType == 'event') {
                if(eventRegistrationInfo != NULL && eventRegistrationInfo.eventInfo != NULL && eventRegistrationInfo.eventInfo.isInviteOnly) {
                    setOrderInfo.doNotCreateAffiliateMember = True;
                }
            } else if(setRegistrationInfo.programRegistrationInfo.eventType == 'webcast' && !setRegistrationInfo.membershipOptions.hasSelectedMembership) {
                setOrderInfo.doNotCreateAffiliateMember = True;
            }
        }

        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','setOrderInfo',setOrderInfo);

        GARP_BC_Orders.setOrderReturnInfo retsetOrder = GARP_BC_Orders.setOrder(setOrderInfo);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','retsetOrder',retsetOrder);

        if(retsetOrder.status != 'Success') {
            setRegistrationReturnInfo.message = retsetOrder.message;
            setRegistrationReturnInfo.status = retsetOrder.status;
            return setRegistrationReturnInfo;
        }

        setRegistrationReturnInfo.message = retsetOrder.message;
        setRegistrationReturnInfo.status = retsetOrder.status;
        setRegistrationReturnInfo.contactId = retsetOrder.contactId;
        setRegistrationReturnInfo.accountId = retsetOrder.accountId;
        setRegistrationReturnInfo.OrderId = retsetOrder.orderId;

        setRegistrationReturnInfo.orderNumber = retsetOrder.orderNumber;
        setRegistrationReturnInfo.company = retsetOrder.company;
        setRegistrationReturnInfo.total = retsetOrder.total;
        setRegistrationReturnInfo.tax = retsetOrder.tax;
        setRegistrationReturnInfo.shipping = retsetOrder.shipping;

        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','setRegistrationReturnInfo',setRegistrationReturnInfo);

        if(retsetOrder.status != 'Success') {
            return setRegistrationReturnInfo;
        }

        createContractsReturnInfo contractRetInfo;
        if(!setOrderInfo.doNotCreateAffiliateMember) {

            // Update Account and Contact
            Contact updateContact = GARP_BC_Membership.updateMembershipContact(retsetOrder.contactId, checkAuth.user, setOrderInfo.customerInfo, setOrderInfo.personalInfo, setOrderInfo.paymentInfo.billingAddress);
            GARP_Common.debugLog('GARP_BC_Registration','setRegistration','updateContact',updateContact);

            if(updateContact != NULL) {
                //regInfo.contactRecord = updateContact;
                update updateContact;
            }

            Account updateAccount = GARP_BC_Membership.updateMembershipAccount(retsetOrder.accountId, null, updateContact, setOrderInfo.customerInfo, setOrderInfo.paymentInfo.billingAddress);
            GARP_Common.debugLog('GARP_BC_Registration','setRegistration','updateAccount',updateAccount);

            if(updateAccount != NULL) {
                //regInfo.accountRecord = updateAccount;
                update updateAccount;
            }

            // Contracts
            contractRetInfo = createContracts(setRegistrationInfo, setRegistrationReturnInfo, membershipInfo, regFees.feeProducts);
            GARP_Common.debugLog('GARP_BC_Registration','setRegistration','contractRetInfo',contractRetInfo);

            if(!contractRetInfo.candidateRequirements.isEmpty()) {
                String mainContarctRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', setRegistrationInfo.programRegistrationInfo.contractRecTypeName);
                GARP_Common.debugLog('GARP_BC_Registration','setRegistration','mainContarctRecordTypeId',mainContarctRecordTypeId);

                for(Candidate_Requirement__c contreq :contractRetInfo.candidateRequirements) {
                    GARP_Common.debugLog('GARP_BC_Registration','setRegistration','contreq',contreq);
                    GARP_Common.debugLog('GARP_BC_Registration','setRegistration','contract record Type',contreq.Candidate_Commitment__r.RecordTypeId);
                    GARP_Common.debugLog('GARP_BC_Registration','setRegistration','mainContarctRecordTypeId',mainContarctRecordTypeId);

                    if(contreq.Candidate_Commitment__r.RecordTypeId == mainContarctRecordTypeId) {
                        setRegistrationReturnInfo.programId = contreq.Candidate_Commitment__c;
                        break;
                    }
                }
            } else if(contractRetInfo.mainContract != NULL) {
                setRegistrationReturnInfo.programId = contractRetInfo.mainContract.Id;
            }
            GARP_Common.debugLog('GARP_BC_Registration','setRegistration','setRegistrationReturnInfo.programId',setRegistrationReturnInfo.programId);
        } else {
            // Update Non-Member Contact
            Contact updateContact = GARP_BC_Membership.updateNonMembershipContact(retsetOrder.contactId, checkAuth.user, setOrderInfo.customerInfo, setOrderInfo.personalInfo, setOrderInfo.addressInfo.billingAddress);
            GARP_Common.debugLog('GARP_BC_Registration','setRegistration','updateContact',updateContact);

            if(updateContact != NULL) {
                //regInfo.contactRecord = updateContact;
                update updateContact;
            }

        }

        // Registrations
        List<SObject> newRegistrations = createRegistrations(setRegistrationInfo, setRegistrationReturnInfo, contractRetInfo, eventRegistrationInfo);
        GARP_Common.debugLog('GARP_BC_Registration','setRegistration','newRegistrations',newRegistrations);
        if(!newRegistrations.IsEmpty()) {
            setRegistrationReturnInfo.registrationId = newRegistrations[0].Id;
        }

        // Clean up for Webcasts, and other which do not call pay order
        if(setRegistrationReturnInfo.orderId == NULL) {

            Form_Data__c formData = GARP_BC_Registration.closeFormData(retsetOrder.formDataId, NULL);
            GARP_Common.debugLog('GARP_BC_Registration','setRegistration','formData',formData);

        }
		setRegistrationReturnInfo.status = 'Success';
        setRegistrationReturnInfo.message = 'Set Registration Completed';
        return setRegistrationReturnInfo;
    }

    // Once payment is completed successfully
    // Do final processing
    public static void payOrderSuccessComplete(String orderId, String teamRegCode) {

        GARP_Common.debugLog('GARP_BC_Registration','payOrderSuccessComplete','orderId',orderId);
        GARP_Common.debugLog('GARP_BC_Registration','payOrderSuccessComplete','teamRegCode',teamRegCode);

        List<Event_Registration__c> existingEventRegistrations = [SELECT Id, Status__c, Event__r.Is_Pay_For_Event__c, Opportunity__r.StageName FROM Event_Registration__c WHERE Opportunity__c = :orderId];
        GARP_Common.debugLog('GARP_StripeClass','processWebhook','existingEventRegistrations', existingEventRegistrations);

        // Event Registartion Status
        if(!existingEventRegistrations.IsEmpty()) {
            List<Event_Registration__c> updateEventRegistrations = new List<Event_Registration__c>();
            for(Event_Registration__c er :existingEventRegistrations) {
                if(er.Status__c == NULL && (!er.Event__r.Is_Pay_For_Event__c || er.Opportunity__r.StageName != 'Closed')) {
                    er.Status__c = 'Registered';
                    updateEventRegistrations.add(er);
                    GARP_Common.debugLog('GARP_BC_Registration','payOrderSuccessComplete','update event reg',er);
                }
            }
            if(!updateEventRegistrations.IsEmpty()) {
                update updateEventRegistrations;
            }
        }

        // Team Registration Seats Used
        if(teamRegCode != NULL) {
            List<B2B_Deal_Item__c> dealItems = [select Id, Seats_Allowed__c, Seats_Used__c,
                                                (SELECT Id, AccountId, StageName FROM Opportunities__r where StageName != 'Closed lost')
                                                from B2B_Deal_Item__c
                                                where Access_Code__c = :teamRegCode];

            GARP_Common.debugLog('GARP_BC_Registration','payOrderSuccessComplete','dealItems',dealItems);

            if(!dealItems.IsEmpty()) {
                B2B_Deal_Item__c dealItem = dealItems[0];

                GARP_Common.debugLog('GARP_BC_Registration','payOrder','Opportunities__r',dealItem.Opportunities__r);

                // Is this B2B Deal Item using Seat config??
                if(dealItem.Seats_Allowed__c != NULL && dealItem.Opportunities__r != NULL && dealItem.Opportunities__r.size() > 0) {
                    dealItem.Seats_Used__c = dealItem.Opportunities__r.size();
                    update dealItems;
                }
            }
        }
    }

    public static GARP_BC_Orders.setOrderReturnInfo payOrder(createOrderInfo createOrderInfo) {
        // Use Stripe
        GARP_BC_Orders.setOrderReturnInfo ret = new GARP_BC_Orders.setOrderReturnInfo();

        GARP_Common.debugLog('GARP_BC_Registration','payOrder','createOrderInfo',createOrderInfo);

        // Captcha
        Utilities.runCaptcha(createOrderInfo.captchaInfo.sessionToken);

        GARP_Common.debugLog('GARP_BC_Registration','payOrder','paymentType',createOrderInfo.paymentInfo.paymentType);

        Opportunity purchaseOpp;
        List<Opportunity> lstOpp = [select Id, Amount, Email_Purchase_Complete__c, B2B_Deal_Item__c, B2B_Deal_Item__r.Access_Code__c, Order_Summary_CTA__c
                                    from Opportunity
                                    where Id = :createOrderInfo.paymentInfo.existingOrderId];
        GARP_Common.debugLog('GARP_BC_Registration','payOrder','lstOpp',lstOpp);


        teamRegInfo teamRegInfo;
        // Case 00888108: Save frontend consent release value before server-side overwrite
        Boolean frontendConsentRelease = (createOrderInfo.teamRegInfo != null)
            ? createOrderInfo.teamRegInfo.consentReleaseExamResults : null;
        retGetTeamRegistrationInfo retTeamInfo = getTeamRegistrationInfo(createOrderInfo.programRegistrationInfo, createOrderInfo.customerInfo.accountId, True);
        if(retTeamInfo.status == 'Success') {
           teamRegInfo = retTeamInfo.teamRegInfo;
        }
        GARP_Common.debugLog('GARP_BC_Registration','payOrder','teamRegInfo',teamRegInfo);
        createOrderInfo.teamRegInfo = teamRegInfo;
        // Case 00888108: Restore frontend consent release value after server-side overwrite
        if(createOrderInfo.teamRegInfo != null && frontendConsentRelease != null) {
            createOrderInfo.teamRegInfo.consentReleaseExamResults = frontendConsentRelease;
        }

        if(!lstOpp.IsEmpty()) {

            purchaseOpp = lstOpp[0];

            Boolean hasBilling = False;
            if(purchaseOpp.Amount > 0 && ((teamRegInfo == NULL || teamRegInfo.teamRegId == NULL) ||
                                     (teamRegInfo != NULL && teamRegInfo.teamRegId != NULL && !teamRegInfo.isComplimentary))) {
                                         hasBilling = True;
                                     }
            GARP_Common.debugLog('GARP_BC_Registration','payOrder','hasBilling',hasBilling);

            if(hasBilling && createOrderInfo.paymentInfo != NULL && createOrderInfo.paymentInfo.paymentType != NULL && createOrderInfo.paymentInfo.paymentType.toLowerCase() == 'stripe') {

                // Save Session
                Boolean saveStateRet = setSessionState(createOrderInfo.customerInfo.sessionId, createOrderInfo.sessionStateJSON);
                GARP_Common.debugLog('GARP_BC_Registration','payOrder','saveStateRet',saveStateRet);

                if(!saveStateRet) {
                    ret.status = 'Failed';
                    ret.message = 'Session state failed to save';
                } else {
                    ret.status = 'Success';
                    ret.message = 'PaymentIntent updated, Session state saved';
                }

            } else if(hasBilling && createOrderInfo.paymentInfo.paymentType == 'alipay' || createOrderInfo.paymentInfo.paymentType == 'wechat_pay') {


                ret.status = 'Failed';
                ret.message = 'Paymenbt method no longer supported';


            } else {

                ret = GARP_BC_Orders.payOrder(createOrderInfo.customerInfo, createOrderInfo.PaymentInfo, teamRegInfo, createOrderInfo.programRegistrationInfo, purchaseOpp);
                GARP_Common.debugLog('GARP_BC_Registration','payOrder','ret',ret);

                // If Success, do final actions
                if(ret.status == 'Success') {

                    String existingEventRegistrationId;
                    String teamRegCode;

                    if(createOrderInfo.paymentInfo.existingRegistrationId != NULL && createOrderInfo.programRegistrationInfo.eventType == 'event') {
                        existingEventRegistrationId = createOrderInfo.paymentInfo.existingRegistrationId;
                    }
                    if(teamRegInfo != NULL && teamRegInfo.teamRegCode != NULL) {
                        teamRegCode = teamRegInfo.teamRegCode;
                    }
                    payOrderSuccessComplete(createOrderInfo.paymentInfo.existingOrderId, teamRegCode);
                }
            }
        }

        // Fire Member Profile Summary Update
        List<Member_Profile_Update__e> events = new List<Member_Profile_Update__e>();
        events.add(new Member_Profile_Update__e(
            Contact_ID__c = createOrderInfo.customerInfo.contactId
        ));
        eventbus.publish(events);
        GARP_Common.debugLog('GARP_BC_Registration','payOrder','Fire event', events);

        return ret;
    }

    public class createContractsReturnInfo {
        Public List<Candidate_Requirement__c> candidateRequirements;
        Public Contract mainContract;
    }

    public static createContractsReturnInfo createContracts(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, GARP_BC_Membership.membershipInfo membershipInfo, List<GARP_BC_Orders.productInfo> feeProducts) {

        GARP_Common.debugLog('GARP_BC_Registration','createContracts','setRegistrationInfo',setRegistrationInfo);
        GARP_Common.debugLog('GARP_BC_Registration','createContracts','setRegistrationReturnInfo',setRegistrationReturnInfo);
        GARP_Common.debugLog('GARP_BC_Registration','createContracts','membershipInfo',membershipInfo);

        createContractsReturnInfo retInfo = new createContractsReturnInfo();

        List<Contract> newContracts = new List<Contract>();

        String ffrRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FBR Program');
        String frrRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'ICBRR Program');
        String frr25RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRR25 Program');
        String microCourseRecordTypeId;
        String scrRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'SCR Program');
        String riskAIRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Risk AI Program');
        String frmRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program');

        if(setRegistrationInfo.programRegistrationInfo.registrationType == 'micro') {
            microCourseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', setRegistrationInfo.programRegistrationInfo.microCourseInfo.programType);
        }

        // Create main programs
        String existingFRMContract;
        String existingFRRContract;
        String existingFRR25Contract;
        String existingMicroCoursesContract;

        if(setRegistrationInfo.programRegistrationInfo.registrationType == 'ffr') {
            GARP_BC_Courses.returnCreateCourseContract ret = GARP_BC_Courses.createCourseContract(setRegistrationInfo, setRegistrationReturnInfo, membershipInfo, 'ffr');
            newContracts.add(ret.frrContract);
            retInfo.mainContract = ret.frrContract;
        } else if(setRegistrationInfo.programRegistrationInfo.registrationType == 'frr' || setRegistrationInfo.programRegistrationInfo.registrationType == 'frr25') {
            String courseType = setRegistrationInfo.programRegistrationInfo.registrationType;
            GARP_BC_Courses.returnCreateCourseContract ret = GARP_BC_Courses.createCourseContract(setRegistrationInfo, setRegistrationReturnInfo, membershipInfo, courseType);
            if(ret.isNew) {
                newContracts.add(ret.frrContract);
            } else {
                if(courseType == 'frr') {
                    existingFRRContract = ret.frrContract.Id;
                } else {
                    existingFRR25Contract = ret.frrContract.Id;
                }
            }
            retInfo.mainContract = ret.frrContract;
        } else if(setRegistrationInfo.programRegistrationInfo.registrationType == 'micro') {
            if(setRegistrationInfo.programRegistrationInfo.microCourseInfo != NULL) {
                GARP_BC_Courses.returnCreateCourseContract ret = GARP_BC_Courses.createCourseContract(setRegistrationInfo, setRegistrationReturnInfo, membershipInfo, 'micro');
                if(ret != null) {
                    if(ret.isNew) {
                        newContracts.add(ret.frrContract);
                    } else {
                        existingMicroCoursesContract = ret.frrContract.Id;
                    }
                    retInfo.mainContract = ret.frrContract;
                }
            } else {
                // Error
            }
        } else if(setRegistrationInfo.programRegistrationInfo.registrationType == 'scr' || setRegistrationInfo.programRegistrationInfo.registrationType == 'raij' || setRegistrationInfo.programRegistrationInfo.registrationType == 'riskai') {
            Contract mainContract = GARP_BC_Courses.createExamContract(setRegistrationInfo, setRegistrationReturnInfo, membershipInfo, setRegistrationInfo.programRegistrationInfo.registrationType);
            newContracts.add(mainContract);
            retInfo.mainContract = mainContract;
        } else if(setRegistrationInfo.programRegistrationInfo.registrationType == 'frm') {
            GARP_BC_Exams.returnCreateFRMContract ret = GARP_BC_Exams.createFRMContract(setRegistrationInfo, setRegistrationReturnInfo, membershipInfo);
            if(ret.isNew) {
                newContracts.add(ret.frmContract);
            } else {
                existingFRMContract = ret.frmContract.Id;
            }
            retInfo.mainContract = ret.frmContract;
        }
        GARP_Common.debugLog('GARP_BC_Registration','createContracts','existingFRRContract',existingFRRContract);
        GARP_Common.debugLog('GARP_BC_Registration','createContracts','existingFRR25Contract',existingFRR25Contract);
        GARP_Common.debugLog('GARP_BC_Registration','createContracts','existingMicroCoursesContract',existingMicroCoursesContract);
        GARP_Common.debugLog('GARP_BC_Registration','createContracts','existingFRMContract',existingFRMContract);
        GARP_Common.debugLog('GARP_BC_Registration','createContracts','newContracts start',newContracts);

        // Create other programs
        for (GARP_BC_Orders.productInfo pi :feeProducts) {
            GARP_Common.debugLog('GARP_BC_Registration','createContracts','pi',pi);

            if(pi.productCode == 'AFREE') {
                Contract membershipContract = GARP_BC_Membership.createMembershipContract(setRegistrationInfo, setRegistrationReturnInfo, pi.productCode, membershipInfo);
                newContracts.add(membershipContract);
            } else if (pi.productCode == 'MEMI' || pi.productCode == 'MEMF' || pi.productCode == 'MEMFX' || pi.productCode == 'MEMC') {
                if(!membershipInfo.isMember) {
                    Contract membershipContract = GARP_BC_Membership.createMembershipContract(setRegistrationInfo, setRegistrationReturnInfo, pi.productCode, membershipInfo);
                    newContracts.add(membershipContract);
                }
            }

            // Risk.Net
            if(pi.productCode == 'MEMR') {
                // This happens in triggers
                // Contract membershipContract = GARP_BC_Membership.createRiskNetContract(setRegistrationInfo, setRegistrationReturnInfo, pi.productCode, membershipInfo);
                // newContracts.add(membershipContract);
            }

            // OSTA
            if(pi.productCode == 'CHNDF') {
                //Contract ostaContract = GARP_BC_Exams.createOSTAContract(setRegistrationInfo, setRegistrationReturnInfo, membershipInfo);
                //newContracts.add(ostaContract);
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','createContracts','newContracts final',newContracts);

        insert newContracts;

        // Setup Program Requirements
        List<Candidate_Requirement__c> addCanReqs = new List<Candidate_Requirement__c>();
        Set<String> contractIds = new Set<String>();

        for(Contract cont :newContracts) {
            GARP_Common.debugLog('GARP_BC_Registration','createContracts','cont',cont);

            if(cont.RecordTypeId == frrRecordTypeId) {
                Candidate_Requirement__c canreq = GARP_BC_Courses.createCourseProgramRequirement(setRegistrationInfo, setRegistrationReturnInfo, cont.Id, 'FRR');
                if (canreq != null) { addCanReqs.add(canreq); contractIds.add(cont.Id); }
            } else if(cont.RecordTypeId == frr25RecordTypeId) {
                Candidate_Requirement__c canreq = GARP_BC_Courses.createCourseProgramRequirement(setRegistrationInfo, setRegistrationReturnInfo, cont.Id, 'FRR25');
                if (canreq != null) { addCanReqs.add(canreq); contractIds.add(cont.Id); }
            } else if(microCourseRecordTypeId != NULL && cont.RecordTypeId == microCourseRecordTypeId) {
                Candidate_Requirement__c canreq = GARP_BC_Courses.createCourseProgramRequirement(setRegistrationInfo, setRegistrationReturnInfo, cont.Id, 'MicroCourse');
                if (canreq != null) { addCanReqs.add(canreq); contractIds.add(cont.Id); }
            } else if(cont.RecordTypeId == ffrRecordTypeId) {
                Candidate_Requirement__c canreq = GARP_BC_Courses.createCourseProgramRequirement(setRegistrationInfo, setRegistrationReturnInfo, cont.Id, 'FFR');
                if (canreq != null) { addCanReqs.add(canreq); contractIds.add(cont.Id); }
            } else if(cont.RecordTypeId == frmRecordTypeId) {
                GARP_BC_Exams.createFRMProgramRequirements(setRegistrationInfo, setRegistrationReturnInfo, cont.Id);
                contractIds.add(cont.Id);
            }
        }
        GARP_Common.debugLog('GARP_BC_Registration','createContracts','addCanReqs',addCanReqs);
        GARP_Common.debugLog('GARP_BC_Registration','createContracts','contractIds',contractIds);

        if(existingFRMContract != NULL) {
            contractIds.add(existingFRMContract);
        }
        if(existingFRRContract != NULL) {
            contractIds.add(existingFRRContract);
        }
        if(existingFRR25Contract != NULL) {
            contractIds.add(existingFRR25Contract);
        }
        if(existingMicroCoursesContract != NULL) {
            contractIds.add(existingMicroCoursesContract);
        }

        GARP_Common.debugLog('GARP_BC_Registration','createContracts','contractIds final',contractIds);

        if(addCanReqs != NULL) {
            insert addCanReqs;
        }

        List<Candidate_Requirement__c> lstCanReqs = [select Id, RecordTypeId, Exam__c, Candidate_Commitment__c, Candidate_Commitment__r.RecordTypeId from Candidate_Requirement__c where Candidate_Commitment__c in :contractIds];
        retInfo.candidateRequirements = lstCanReqs;

        return retInfo;
    }

    public static List<SObject> createRegistrations(setRegistrationInfo setRegistrationInfo, setRegistrationReturnInfo setRegistrationReturnInfo, createContractsReturnInfo contractRetInfo, GARP_BC_Events.eventRegistrationInfo eventRegistrationInfo) {

        GARP_Common.debugLog('GARP_BC_Registration','createRegistrations','setRegistrationInfo',setRegistrationInfo);
        GARP_Common.debugLog('GARP_BC_Registration','createRegistrations','setRegistrationReturnInfo',setRegistrationReturnInfo);
        GARP_Common.debugLog('GARP_BC_Registration','createRegistrations','contractRetInfo',contractRetInfo);
        GARP_Common.debugLog('GARP_BC_Registration','createRegistrations','eventRegistrationInfo',eventRegistrationInfo);

        List<Candidate_Requirement__c> contractRequirements = new List<Candidate_Requirement__c>();
        if(contractRetInfo != NULL && contractRetInfo.candidateRequirements != NULL) {
            contractRequirements = contractRetInfo.candidateRequirements;
        }

        List<SObject> newRegs = new List<SObject>();

        String registrationType = setRegistrationInfo.programRegistrationInfo.registrationType;
        if (registrationType == 'scr' || registrationType == 'raij' || registrationType == 'riskai') {
            Exam_Attempt__c newReg = GARP_BC_Courses.createExamRegistrationByType(setRegistrationInfo, setRegistrationReturnInfo, contractRequirements, registrationType);
            GARP_Common.debugLog('GARP_BC_Registration','createRegistrations','newReg',newReg);
            if (newReg != null) {
                insert newReg;
                newRegs.add(newReg);
            }
        } else if (registrationType == 'frr' || registrationType == 'frr25' || registrationType == 'micro') {
            Exam_Attempt__c newReg = GARP_BC_Courses.createCourseExamRegistrationByType(setRegistrationInfo, setRegistrationReturnInfo, contractRequirements, registrationType);
            GARP_Common.debugLog('GARP_BC_Registration','createRegistrations','newReg',newReg);
            if (newReg != null) {
                insert newReg;
                newRegs.add(newReg);
            }
        } else if (registrationType == 'frm') {
            List<Exam_Attempt__c> newFRMRegs = GARP_BC_Exams.createFRMExamRegistrations(setRegistrationInfo, setRegistrationReturnInfo, contractRequirements);
            GARP_Common.debugLog('GARP_BC_Registration','createRegistrations','newFRMRegs',newFRMRegs);
            newRegs = newFRMRegs;
            if(!newFRMRegs.IsEmpty()) {
                insert newFRMRegs;

                // Assign Other Exam Reg Fields
                if(newFRMRegs.size() > 1) {
                    newFRMRegs[0].Other_Exam_Registrations__c = newFRMRegs[1].Id;
                    newFRMRegs[1].Other_Exam_Registrations__c = newFRMRegs[0].Id;

                    GARP_Common.debugLog('GARP_BC_Registration','createRegistrations','Update Other Exam Reg',newFRMRegs);
                    update newFRMRegs;
                }
            }
        }
        // Events
        else if(setRegistrationInfo.programRegistrationInfo.registrationType == 'event' && !String.isEmpty(setRegistrationInfo.programRegistrationInfo.eventId)) {
            List<SObject> newEventRegs = GARP_BC_Events.createRegistrations(setRegistrationInfo, setRegistrationReturnInfo, eventRegistrationInfo);
            newRegs.addAll(newEventRegs);
        }
        return newRegs;
    }

    // AG 5/2/2024 Utilities to use GARP_BC_Registration to create orders from other classes (not reg screen)

    public static Contact getContactForFeesAndSetReg(String contactId) {
        List<Contact> lstContacts = [select id, accountId, FirstName, LastName, Email, HomePhone, Account.BillingStreet, Account.BillingCountry, Account.BillingState, Account.BillingPostalCode, Account.BillingCity
                                     FROM Contact where id = :contactId];
        if(!lstContacts.IsEmpty()) {

            return lstContacts[0];
        } else {
            return NULL;
        }

    }

    public static GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfoFromAuthedContact(Contact objContact, programRegistrationInfo programRegistrationInfo, Boolean hasSelectedMembership, String paymentType) {
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = new GARP_BC_Registration.getRegistrationFeesInfo();

        getRegistrationFeesInfo.programRegistrationInfo = programRegistrationInfo;
        getRegistrationFeesInfo.paymentType = paymentType;
        getRegistrationFeesInfo.teamRegCode = null;

        getRegistrationFeesInfo.membershipOptions = new GARP_BC_Registration.membershipOptions();
        getRegistrationFeesInfo.membershipOptions.hasSelectedMembership = hasSelectedMembership;

        getRegistrationFeesInfo.addressInfo = new GARP_BC_Registration.addressInfo();
        getRegistrationFeesInfo.addressInfo = new GARP_BC_Registration.addressInfo();
        getRegistrationFeesInfo.addressInfo.billingAddress = new GARP_Common.address();

        getRegistrationFeesInfo.addressInfo.billingAddress.country = objContact.Account.BillingCountry;
        getRegistrationFeesInfo.addressInfo.billingAddress.province = objContact.Account.BillingState;
        getRegistrationFeesInfo.addressInfo.billingAddress.postalCode = objContact.Account.BillingPostalCode;

        GARP_Common.address streets = GARP_Common.parseMultiAddressLine(objContact.Account.BillingStreet);
        getRegistrationFeesInfo.addressInfo.billingAddress.street1 = streets.street1;
        getRegistrationFeesInfo.addressInfo.billingAddress.street2 = streets.street2;
        getRegistrationFeesInfo.addressInfo.billingAddress.street3 = streets.street3;

        getRegistrationFeesInfo.addressInfo.billingAddress.city = objContact.Account.BillingCity;
        getRegistrationFeesInfo.addressInfo.billingAddress.phone = objContact.HomePhone;
        getRegistrationFeesInfo.addressInfo.billingAndShippingSame = true;

        return getRegistrationFeesInfo;
    }

    public static GARP_BC_Registration.setRegistrationInfo setRegistrationInfoFromAuthedContact(Contact objContact, programRegistrationInfo programRegistrationInfo, String leadId) {
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = new GARP_BC_Registration.setRegistrationInfo();

        setRegistrationInfo.customerInfo = new GARP_BC_Registration.orderCustomerInfo();
        setRegistrationInfo.customerInfo.FirstName = objContact.FirstName;
        setRegistrationInfo.customerInfo.LastName = objContact.LastName;
        setRegistrationInfo.customerInfo.Email = objContact.Email ;
        setRegistrationInfo.customerInfo.Phone = objContact.HomePhone;
        setRegistrationInfo.customerInfo.LeadId = leadId;
        setRegistrationInfo.customerInfo.ContactId = objContact.Id;
        setRegistrationInfo.customerInfo.AccountId = objContact.accountId;

        setRegistrationInfo.paymentInfo = new GARP_BC_Orders.orderPaymentInfo();
        setRegistrationInfo.paymentInfo.paymentType = 'Credit Card';
        setRegistrationInfo.paymentInfo.billingAddress = new GARP_Common.address();
        setRegistrationInfo.paymentInfo.billingAddress.country = objContact.Account.BillingCountry;
        setRegistrationInfo.paymentInfo.billingAddress.province = objContact.Account.BillingState;
        setRegistrationInfo.paymentInfo.billingAddress.postalCode = objContact.Account.BillingPostalCode;
        setRegistrationInfo.paymentInfo.billingAddress.phone = objContact.HomePhone;
        setRegistrationInfo.paymentInfo.billingAddress.city = objContact.Account.BillingCity;

        GARP_Common.address streets = GARP_Common.parseMultiAddressLine(objContact.Account.BillingStreet);
        setRegistrationInfo.paymentInfo.billingAddress.street1 = streets.street1;
        setRegistrationInfo.paymentInfo.billingAddress.street2 = streets.street2;
        setRegistrationInfo.paymentInfo.billingAddress.street2 = streets.street3;

        setRegistrationInfo.addressInfo = new GARP_BC_Registration.addressInfo();
        setRegistrationInfo.addressInfo.billingAddress = new GARP_Common.address();
        setRegistrationInfo.addressInfo.billingAddress.country = objContact.Account.BillingCountry;
        setRegistrationInfo.addressInfo.billingAddress.province = objContact.Account.BillingState;
        setRegistrationInfo.addressInfo.billingAddress.postalCode = objContact.Account.BillingPostalCode;

        setRegistrationInfo.addressInfo.billingAddress.street1 = streets.street1;
        setRegistrationInfo.addressInfo.billingAddress.street2 = streets.street2;
        setRegistrationInfo.addressInfo.billingAddress.street2 = streets.street3;

        setRegistrationInfo.addressInfo.billingAddress.city = objContact.Account.BillingCity;
        setRegistrationInfo.addressInfo.billingAddress.phone = objContact.HomePhone;
        setRegistrationInfo.addressInfo.billingAndShippingSame = true;

        setRegistrationInfo.captchaInfo = new GARP_BC_Registration.captchaInfo();
        setRegistrationInfo.membershipOptions = new GARP_BC_Registration.membershipOptions();
        setRegistrationInfo.personalInfo = new GARP_BC_Registration.orderPersonalInfo();

        setRegistrationInfo.programRegistrationInfo = programRegistrationInfo;

        setRegistrationInfo.teamRegInfo = null;
        setRegistrationInfo.consentInfo = new GARP_BC_Registration.consentInfo();

        setRegistrationInfo.membershipOptions.autoRenew = False;
        setRegistrationInfo.membershipOptions.hasSelectedMembership = False;
        setRegistrationInfo.membershipOptions.hasSelectedRiskNet = False;

        setRegistrationInfo.eventOptions = new GARP_BC_Events.eventOptions();

        return setRegistrationInfo;
    }

    public static GARP_BC_Registration.createOrderInfo createOrderFromAuthedContact(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.registrationFees regFees, GARP_BC_Registration.setRegistrationReturnInfo setRegRet) {
        GARP_BC_Registration.createOrderInfo createOrderInfo = new GARP_BC_Registration.createOrderInfo();
        createOrderInfo.customerInfo = setRegistrationInfo.customerInfo;
        createOrderInfo.personalInfo = setRegistrationInfo.personalInfo;
        createOrderInfo.studyMaterials = setRegistrationInfo.studyMaterials;
        createOrderInfo.selectedProducts = regFees.feeProducts;
        createOrderInfo.membershipOptions = setRegistrationInfo.membershipOptions;
        createOrderInfo.captchaInfo = setRegistrationInfo.captchaInfo;
        //createOrderInfo.hasSelectedMembership = setRegistrationInfo.hasSelectedMembership;
        createOrderInfo.programRegistrationInfo = setRegistrationInfo.programRegistrationInfo;
        createOrderInfo.addressInfo = setRegistrationInfo.addressInfo;
        createOrderInfo.teamRegInfo = setRegistrationInfo.teamRegInfo;
        createOrderInfo.examSelectionInfo = setRegistrationInfo.examSelectionInfo;
        createOrderInfo.consentInfo = setRegistrationInfo.consentInfo;

        createOrderInfo.paymentInfo = setRegistrationInfo.paymentInfo;
        createOrderInfo.paymentInfo.existingOrderId = setRegRet.orderId;
        createOrderInfo.customerInfo.accountId = setRegRet.accountId;
        createOrderInfo.customerInfo.contactId = setRegRet.contactId;

        return createOrderInfo;
    }

    public static verifyExistingCustomerReturnInfo verifyExistingCustomer(verifyExistingCustomerInfo verifyExistingCustomerInfo) {
        GARP_Common.debugLog('GARP_BC_Registration','verifyExistingCustomer','verifyExistingCustomerInfo',verifyExistingCustomerInfo);

        verifyExistingCustomerReturnInfo retInfo = new verifyExistingCustomerReturnInfo();

        checkAuthentication checkAuth = GARP_BC_Registration.checkAuthentication();
        GARP_Common.debugLog('GARP_BC_Registration','verifyExistingCustomer','checkAuth',checkAuth);

        checkExistingContact checkExistingContact = checkExistingContact(verifyExistingCustomerInfo.email);
        GARP_Common.debugLog('GARP_BC_Registration','verifyExistingCustomer','checkExistingContact',checkExistingContact);

        // If Contact already exists use it
        if(checkExistingContact.Contact != NULL) {
            retInfo.contactID = checkExistingContact.Contact.Id;
            retInfo.accountID = checkExistingContact.Contact.AccountId;
        }

        returnFormSession retFormSession = setFormSession(verifyExistingCustomerInfo, checkExistingContact);

        if(retFormSession.status == 'Failed') {
            retInfo.status = 'Failed';
            retInfo.message = 'Form Session could not be created';
            GARP_Common.debugLog('GARP_BC_Registration','verifyExistingCustomer','setFormSession failed','');
            return retInfo;
        }

        retInfo.sessionId = retFormSession.formData.Id;

        // Public Reg with Existing Membership
        if(!checkAuth.isAuthenticated && checkExistingContact.isMember) {

            // Fix User??
            if(checkExistingContact.contact.DO_NOT_FIRE__c = true) {
                checkExistingContact.contact.DO_NOT_FIRE__c = false;
                GARP_Common.debugLog('GARP_BC_Registration','verifyExistingCustomer','fix DO_NOT_FIRE__c',contact.DO_NOT_FIRE__c);
                update checkExistingContact.contact;
            } else if(checkExistingContact.user == NULL) {
                retInfo.status = 'Failed';
                retInfo.message = 'Member has no user, and cannot fix';
                GARP_Common.debugLog('GARP_BC_Registration','verifyExistingCustomer','Member has no user, and cannot fix','');
                return retInfo;
            }
        }

        // AG 2/16/2026 - Now Allowed - Member Contact, with no Active Program, Abanadoned Checkout -- No Active User
        // Individual Record Type Contact, but not a Member (no active or expire membership program)
        if(!checkAuth.isAuthenticated && checkExistingContact.Contact != NULL && !checkExistingContact.isBusinessContact && checkExistingContact.Contact.accountId != NULL && !checkExistingContact.isMember && checkExistingContact.hasActiveContract) {
            retInfo.status = 'Failed';
            retInfo.message = 'Contact membership program missing';
        }

		// Close Old Orders
        if(!checkAuth.isAuthenticated && !checkExistingContact.isMember && checkExistingContact.Contact.accountId != NULL) {
            Boolean hasOpenAliPayOrder = GARP_BC_Orders.removeOpenOrders(checkExistingContact.Contact.accountId);
            if(hasOpenAliPayOrder) {
                retInfo.status = 'Failed';
                retInfo.message = 'AliPay order is still pending';
            }
        }

        retInfo.isCustomer = checkExistingContact.isMember;
		retInfo.status = 'Success';
		retInfo.message = 'Verification Completed';        
        GARP_Common.debugLog('GARP_BC_Registration','verifyExistingCustomer','final retInfo',retInfo);
        return retInfo;
    }

    public class returnFormSession {
        public String status;
        public String message;
        public Form_Data__c formData;
    }

    public static returnFormSession setFormSession(verifyExistingCustomerInfo verifyExistingCustomerInfo, checkExistingContact checkExistingContact) {
        GARP_Common.debugLog('GARP_BC_Registration','setFormSession','verifyExistingCustomerInfo',verifyExistingCustomerInfo);
        GARP_Common.debugLog('GARP_BC_Registration','setFormSession','checkExistingContact',checkExistingContact);

        returnFormSession ret = new returnFormSession();

        // Find Form
        List< Form__c > forms = [
            SELECT id, Name, Form_Name__c
            FROM Form__c
            WHERE Form_Name__c = :verifyExistingCustomerInfo.formKey
        ];
        GARP_Common.debugLog('GARP_BC_Registration','manageFormData','forms',forms);

        if(forms.IsEmpty()) {
            ret.status = 'Failure';
            ret.message = 'Form is missing';
            return ret;
        }
        String formId = forms[0].Id;
        Form_Data__c formData;
        String contactId;

        if(verifyExistingCustomerInfo.sessionId != NULL) {
            List<Form_Data__c> lstFormData = [SELECT Id, CreatedDate, Status__c, Email__c, First_Name__c, Last_Name__c, Company__c,
                                              UTM_Campaign__c, UTM_Content__c, UTM_Medium__c, UTM_Source__c, UTM_Term__c, Track_CTA__c
                                              FROM Form_Data__c
                                              WHERE id = :verifyExistingCustomerInfo.sessionId];
            GARP_Common.debugLog('GARP_BC_Registration','manageFormData','lstFormData',lstFormData);
            if(!lstFormData.IsEmpty()) {
                formData = lstFormData[0];
            }
        }

        if(checkExistingContact.contact != NULL) {
            contactId = checkExistingContact.contact.Id;
        }

        if(formData != NULL) {
            formData.Contact__c = contactId;
            formData.Status__c = 'Abandoned';
            formData.Email__c = verifyExistingCustomerInfo.email;
            formData.First_Name__c = verifyExistingCustomerInfo.firstName;
            formData.Last_Name__c = verifyExistingCustomerInfo.lastName;
            formData.UTM_Campaign__c = verifyExistingCustomerInfo.utm_campaign;
            formData.UTM_Content__c = verifyExistingCustomerInfo.utm_content;
            formData.UTM_Medium__c = verifyExistingCustomerInfo.utm_medium;
            formData.UTM_Source__c = verifyExistingCustomerInfo.utm_source;
            formData.UTM_Term__c = verifyExistingCustomerInfo.utm_term;
            formData.Track_CTA__c = verifyExistingCustomerInfo.track_cta;
            GARP_Common.debugLog('GARP_BC_Registration','manageFormData','update formData',formData);

            update formData;

        } else { // Add Form Data
            formData = new Form_Data__c(
                Contact__c = contactId,
                Status__c = 'Abandoned',
                Email__c = verifyExistingCustomerInfo.email,
                First_Name__c = verifyExistingCustomerInfo.firstName,
                Last_Name__c = verifyExistingCustomerInfo.lastName,
                Form__c = formId,
                UTM_Campaign__c = verifyExistingCustomerInfo.utm_campaign,
                UTM_Content__c = verifyExistingCustomerInfo.utm_content,
                UTM_Medium__c = verifyExistingCustomerInfo.utm_medium,
                UTM_Source__c = verifyExistingCustomerInfo.utm_source,
                UTM_Term__c = verifyExistingCustomerInfo.utm_term,
                Track_CTA__c = verifyExistingCustomerInfo.track_cta
            );
            GARP_Common.debugLog('GARP_BC_Registration','manageFormData','insert formData',formData);
            insert formData;
        }

        ret.status = 'Success';
        ret.message = 'Form data created/updated';
        ret.formData = formData;

        return ret;
    }

    public static checkAuthentication CheckAuthentication() {
        checkAuthentication checkAuth = new checkAuthentication();
        checkAuth.isAuthenticated = False;

        String userId = UserInfo.getUserId();
        List<User> lstUser = [SELECT Id, ContactId, Name, profile.name FROM User WHERE Id = :userId];
        GARP_Common.debugLog('GARP_BC_Registration','checkAuthentication','lstUser',lstUser);

        if(!lstUser.isEmpty() && lstUser[0].profile.name == 'Customer Community') {
            checkAuth.user = lstUser[0];
            checkAuth.contactID = lstUser[0].ContactId;
            checkAuth.isAuthenticated = True;
        }
        return checkAuth;
    }

    public static checkExistingContact checkExistingContact(String Email) {

        GARP_Common.debugLog('GARP_BC_Registration','checkExistingContact','Email',Email);

        checkExistingContact checkRet = new checkExistingContact();
        checkRet.isMember = False;
        checkRet.isBusinessContact = False;
        checkRet.hasActiveContract = False;
        checkRet.hasClosedOrder = FALSE;
        checkRet.hasPendingOrder = FALSE;

        List<User> users = [select id from User where Email = :Email];
        if(!users.IsEmpty()) {
            checkRet.user = users[0];
        }

        Id memberRecId = RecordTypeHelper.GetRecordTypeId('Contact','Member');
        List<Contact> lstCont = [select Id, FirstName, LastName, Email, GARP_ID_New__c, AccountId, RecordTypeId, RecordType.Name, Account.RecordTypeId, Account.RecordType.Name, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c, DO_NOT_FIRE__c from Contact where Email = :Email];
        GARP_Common.debugLog('GARP_BC_Registration','checkExistingContact','lstCont',lstCont);

        if(!lstCont.isEmpty()) {
            checkRet.contact = lstCont[0];
            if(checkRet.contact.RecordTypeId == memberRecId) {

                Id memRecId = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
                List<Contract> lstContracts = [select Id, RecordTypeId from Contract where AccountId = :checkRet.contact.AccountId AND status in ('Activated','Activated ( Auto-Renew )','Expired')];
                GARP_Common.debugLog('GARP_BC_Registration','checkExistingContact','lstContracts',lstContracts);
                if(!lstContracts.IsEmpty()) {
                    checkRet.hasActiveContract = TRUE;

                    for(Contract con :lstContracts) {
                        if(con.RecordTypeId == memRecId) {
                            checkRet.isMember = TRUE;
                        }
                    }
                } else {
                    checkRet.isMember = FALSE;
                    checkRet.hasActiveContract = FALSE;
                }

                checkRet.hasClosedOrder = FALSE;
                checkRet.hasPendingOrder = FALSE;

                List<Opportunity> lstOpp = [select Id, AccountId, Amount, StageName, Alternate_Method_of_Payment__c, Rollback_Reason__c, CreatedDate, (SELECT Id, ChargentOrders__Response_Status__c, ChargentOrders__Payment_Method__c from Transactions__r ORDER BY CreatedDate DESC) from Opportunity where AccountId = :checkRet.contact.AccountId];
                GARP_Common.debugLog('GARP_BC_Registration','checkExistingContact','lstOpp',lstOpp);
                if(!lstOpp.IsEmpty()) {

                    for(Opportunity opp :lstOpp) {

                        GARP_Common.debugLog('GARP_BC_Registration','checkExistingContact','Loop opp',opp);

                        if(opp.StageName == 'Closed') {
                            checkRet.hasClosedOrder = TRUE;
                        } else if(opp.StageName == 'New Lead') {
                            checkRet.hasPendingOrder = TRUE;
                            checkRet.expiredOpenOrderId = opp.Id;
                        }
                        //else {
                        //Long hourDiff = (DateTime.now().getTime() - opp.CreatedDate.getTime()) /(1000*60*60);
                        //GARP_Common.debugLog('GARP_BC_Registration','checkExistingContact','hourDiff',hourDiff);
                        //GARP_Common.debugLog('GARP_BC_Registration','checkExistingContact','Transactions__r',opp.Transactions__r);

                        //if(opp.Alternate_Method_of_Payment__c == 'alipay' && opp.Transactions__r.IsEmpty() && hourDiff < 1) {
                        //    checkRet.hasPaidOpenOrder = TRUE;
                        //    break;
                        //} else if(opp.Alternate_Method_of_Payment__c == 'alipay' && opp.Transactions__r.IsEmpty() && hourDiff >= 1) {
                        //    checkRet.expiredOpenOrderId = opp.Id;
                        //}
                        //}
                    }
                    GARP_Common.debugLog('GARP_BC_Registration','checkExistingContact','hasClosedOrder', checkRet.hasClosedOrder);
                    GARP_Common.debugLog('GARP_BC_Registration','checkExistingContact','hasPendingOrder', checkRet.hasPendingOrder);
                    GARP_Common.debugLog('GARP_BC_Registration','checkExistingContact','expiredOpenOrderId',checkRet.expiredOpenOrderId );
                }
            } else {
                checkRet.isBusinessContact = True;
            }
        }
        return checkRet;
    }

    public static Id setLead(verifyExistingCustomerInfo verifyExistingCustomerInfo) {
        GARP_Common.debugLog('GARP_BC_Registration','setLead','verifyExistingCustomerInfo',verifyExistingCustomerInfo);

        Lead returnLead;
        Lead newLead;

         GARP_Common.debugLog('GARP_BC_Registration','setLead','verifyExistingCustomerInfo',verifyExistingCustomerInfo.leadId);

        // If Lead Id was given
        if(verifyExistingCustomerInfo.leadId != NULL) {
            List<Lead> leads = [SELECT Id, FirstName, LastName, Email, Unique_Email__c, IsConverted, ConvertedContactId
                     FROM Lead
                    WHERE Id = :verifyExistingCustomerInfo.leadId];
            GARP_Common.debugLog('GARP_BC_Registration','setLead','get leads by lead id',leads);

            if(!leads.IsEmpty()) {
                returnLead = leads[0];
            } else {
                return null;
            }
        } else { // make a new lead

            // Check if lead exists already throw error
            List<Lead> leads = [SELECT Id, FirstName, LastName, Email, Unique_Email__c, IsConverted, ConvertedContactId
                                FROM Lead
                                WHERE (Email = :verifyExistingCustomerInfo.email OR Unique_Email__c = :verifyExistingCustomerInfo.email) AND IsConverted = FALSE];
            GARP_Common.debugLog('GARP_BC_Registration','setLead','get leads by lead email',leads);

            if(!leads.IsEmpty()) {
                returnLead = leads[0];
            } else {
                // Make a new lead
                newLead = new Lead(
                    Email=verifyExistingCustomerInfo.email,
                    LeadSource=verifyExistingCustomerInfo.formKey,
                    LastName=verifyExistingCustomerInfo.lastName,
                    FirstName=verifyExistingCustomerInfo.firstName,
                    Company=verifyExistingCustomerInfo.firstName + ', ' + verifyExistingCustomerInfo.lastName
                );
                GARP_Common.debugLog('GARP_BC_Registration','setLead','insert lead',newLead);
                insert newLead;
            }
        }

        if(returnLead != NULL) {
            returnLead.Email = verifyExistingCustomerInfo.email;
            returnLead.Unique_Email__c = verifyExistingCustomerInfo.email;
            returnLead.LeadSource = verifyExistingCustomerInfo.formKey;
            returnLead.LastName = verifyExistingCustomerInfo.lastName;
            returnLead.FirstName = verifyExistingCustomerInfo.firstName;
            returnLead.Company = verifyExistingCustomerInfo.firstName + ', ' + verifyExistingCustomerInfo.lastName;

            GARP_Common.debugLog('GARP_BC_Registration','setLead','update lead',returnLead);
            update returnLead;
        } else {
            returnLead = newLead;
        }

        GARP_Common.debugLog('GARP_BC_Registration','setLead','final lead',returnLead);
        return returnLead.Id;
    }

    public static Boolean manageFormData(verifyExistingCustomerInfo verifyExistingCustomerInfo, verifyExistingCustomerReturnInfo retInfo) {
        GARP_Common.debugLog('GARP_BC_Registration','manageFormData','verifyExistingCustomerInfo',verifyExistingCustomerInfo);
        GARP_Common.debugLog('GARP_BC_Registration','manageFormData','retInfo',retInfo);

        Boolean ret = True;
        Form_Data__c formData;
        String formId;

        if(verifyExistingCustomerInfo.formKey == NULL) {
            return False;
        }

        verifyExistingCustomerInfo.formKey = verifyExistingCustomerInfo.formKey.toLowerCase();
        GARP_Common.debugLog('GARP_BC_Registration','manageFormData','formKey',verifyExistingCustomerInfo.formKey);

        // Find Form
        List< Form__c > forms = [
            SELECT id, Name, Form_Name__c
            FROM Form__c
            WHERE Form_Name__c = :verifyExistingCustomerInfo.formKey
        ];
        GARP_Common.debugLog('GARP_BC_Registration','manageFormData','forms',forms);

        if(!forms.IsEmpty()) {
            formId = forms[0].id;
        } else {
            return False; // Form not found, error
        }

        // If using Lead
        if(retInfo.leadId != NULL) {
            List<Form_Data__c> existingFormData = [
                SELECT Id, CreatedDate, Status__c, Email__c, First_Name__c, Last_Name__c, Company__c,
                       UTM_Campaign__c, UTM_Content__c, UTM_Medium__c, UTM_Source__c, UTM_Term__c, Track_CTA__c
                FROM Form_Data__c
                WHERE Lead__c = :retInfo.leadId AND Form__c = :formId order by CreatedDate DESC
            ];
            GARP_Common.debugLog('GARP_BC_Registration','manageFormData','fecth form data',ret);

            if(!existingFormData.IsEmpty()) {
                formData = existingFormData[0];
            }
        } else { // Use Contact
            List<Form_Data__c> existingFormData = [
                SELECT Id, CreatedDate, Status__c, Email__c, First_Name__c, Last_Name__c, Company__c,
                       UTM_Campaign__c, UTM_Content__c, UTM_Medium__c, UTM_Source__c, UTM_Term__c, Track_CTA__c
                FROM Form_Data__c
                WHERE Contact__c = :retInfo.contactID AND Form__c = :formId order by CreatedDate DESC
            ];
            GARP_Common.debugLog('GARP_BC_Registration','manageFormData','fecth form data',ret);

            if(!existingFormData.IsEmpty()) {
                formData = existingFormData[0];
            }
        }

        // If form data exists, update it
        if(formData != NULL) {
            formData.Status__c = 'Abandoned';
            formData.Email__c = verifyExistingCustomerInfo.email;
            formData.First_Name__c = verifyExistingCustomerInfo.firstName;
            formData.Last_Name__c = verifyExistingCustomerInfo.lastName;
            formData.Company__c = verifyExistingCustomerInfo.firstName + ' ' + verifyExistingCustomerInfo.lastName;
            formData.UTM_Campaign__c = verifyExistingCustomerInfo.utm_campaign;
            formData.UTM_Content__c = verifyExistingCustomerInfo.utm_content;
            formData.UTM_Medium__c = verifyExistingCustomerInfo.utm_medium;
            formData.UTM_Source__c = verifyExistingCustomerInfo.utm_source;
            formData.UTM_Term__c = verifyExistingCustomerInfo.utm_term;
            formData.Track_CTA__c = verifyExistingCustomerInfo.track_cta;
            GARP_Common.debugLog('GARP_BC_Registration','manageFormData','update formData',formData);

            update formData;
        } else { // Add Form Data
            formData = new Form_Data__c(
                Email__c = verifyExistingCustomerInfo.email,
                First_Name__c = verifyExistingCustomerInfo.firstName,
                Last_Name__c = verifyExistingCustomerInfo.lastName,
                Company__c = verifyExistingCustomerInfo.firstName + ' ' + verifyExistingCustomerInfo.lastName,
                Status__c = 'Abandoned',
                Form__c = formId,
                UTM_Campaign__c = verifyExistingCustomerInfo.utm_campaign,
                UTM_Content__c = verifyExistingCustomerInfo.utm_content,
                UTM_Medium__c = verifyExistingCustomerInfo.utm_medium,
                UTM_Source__c = verifyExistingCustomerInfo.utm_source,
                UTM_Term__c = verifyExistingCustomerInfo.utm_term,
                Track_CTA__c = verifyExistingCustomerInfo.track_cta
            );

            if(retInfo.leadId != NULL) {
                formData.Lead__c = retInfo.leadId;
            } else {
                formData.Contact__c = retInfo.contactID;
            }

            GARP_Common.debugLog('GARP_BC_Registration','manageFormData','add formData',formData);

            insert formData;
        }

        GARP_Common.debugLog('GARP_BC_Registration','manageFormData','final',ret);
        return ret;
    }

    public static FAQWrapper getFaqsByCategory(String category) {
        List<FAQ_Category__c> FAQ_Category = [SELECT Id, Name, FAQ_Category__c from FAQ_Category__c where Name = :category];
        List<FAQ_Section__c> FAQ_Sections = [select Id, Name, FAQ_Category__c, Section_Order_Number__c, FAQ_Category__r.name from FAQ_section__c where FAQ_Category__r.name = :category order by Section_Order_Number__c];
        List<FAQ_Subsection__c> FAQ_Subsections = [select Id, Name, FAQ_Category__c, FAQ_section__c, Subsection_Order_Number__c, FAQ_Category__r.name, Related_Section_Order_Number__c from FAQ_subsection__c where FAQ_Category__r.name = :category order by Subsection_Order_Number__c];
        List<Frequently_Asked_Questions__c> FAQs = [select Id, Name, GA_Label__c, FAQ_Category__r.name, FAQ_Rank__c, FAQ_Question__c, FAQ_Answer__c, FAQ_section__r.name, FAQ_subsection__r.name, Related_Subsection__c, LastModifiedDate from Frequently_Asked_Questions__c where FAQ_Category__r.name = :category order by Related_Subsection__c];

        FAQWrapper response = new FAQWrapper(FAQ_Category, FAQ_Sections, FAQ_Subsections, FAQs);
        return response;
    }

    public static membershipOptions setAllMembershipOptions(membershipOptions membershipOptions) {

        if(membershipOptions != NULL && membershipOptions.hasSelectedMembership != NULL && membershipOptions.hasSelectedMembership) {
            membershipOptions.hasSelectedMembership = True;
        } else {
            membershipOptions.hasSelectedMembership = False;
        }

        if(membershipOptions != NULL && membershipOptions.hasSelectedRiskNet != NULL && membershipOptions.hasSelectedRiskNet) {
            membershipOptions.hasSelectedRiskNet = True;
        } else {
            membershipOptions.hasSelectedRiskNet = False;
        }

        if(membershipOptions != NULL && membershipOptions.autoRenew != NULL && membershipOptions.autoRenew) {
            membershipOptions.autoRenew = True;
        } else {
            membershipOptions.autoRenew = False;
        }
        return membershipOptions;
    }

    public class retGetTeamRegistrationInfo {
        public String status;
        public String statusMessage;
        public teamRegInfo teamRegInfo;
    }

    public static retGetTeamRegistrationInfo getTeamRegistrationInfo(programRegistrationInfo programRegistrationInfo, String accountId, Boolean skipSeatLimitCheck) {

        GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','regCode',programRegistrationInfo.regCode);
        GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','skipSeatLimitCheck',skipSeatLimitCheck);

        retGetTeamRegistrationInfo retTeamInfo = new retGetTeamRegistrationInfo();
        retTeamInfo.teamRegInfo = new teamRegInfo();

        if(String.isEmpty(programRegistrationInfo.regCode)) {
            retTeamInfo.status = 'Failed';
            retTeamInfo.statusMessage = 'Team Registration code not provided';
        }

        List<String> teamExamTypes = new List<String>();
        String productLine;
        if(programRegistrationInfo.registrationType == 'frr25') {
            teamExamTypes.add('FRR25');
            productLine = 'FRR25';
        } else if(programRegistrationInfo.registrationType == 'micro') {
            teamExamTypes.add(programRegistrationInfo.microCourseInfo.courseCode);
            productLine = programRegistrationInfo.microCourseInfo.courseCode;
        } else if(programRegistrationInfo.registrationType == 'frr') {
            teamExamTypes.add('FRR');
            productLine = 'FRR';
        } else if(programRegistrationInfo.registrationType == 'scr') {
            teamExamTypes.add('SCR');
            productLine = 'SCR';
        } else if(programRegistrationInfo.registrationType == 'raij') {
            teamExamTypes.add('RAIJ');
            productLine = 'RAIJ';
        } else if(programRegistrationInfo.registrationType == 'riskai') {
            teamExamTypes.add('Risk & AI');
            productLine = 'RAI';
        } else if(programRegistrationInfo.registrationType == 'frm') {
            teamExamTypes.add('FRM I');
            teamExamTypes.add('FRM II');
            teamExamTypes.add('FRM I & II');
            productLine = 'FRM';
        } else if(programRegistrationInfo.registrationType == 'event') {
            // No team exam types
            //
        } else if(programRegistrationInfo.registrationType == 'membership') {
            // No team exam types

        } else if(programRegistrationInfo.registrationType == 'checkout') {
            // No team exam types

        } else {
            retTeamInfo.status = 'Failed';
            retTeamInfo.statusMessage = 'This program does not have Team Registration';
            return retTeamInfo;
        }
        GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','teamExamTypes',teamExamTypes);
        GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','productLine',productLine);

        Date tdy = Date.today();

        List<B2B_Deal_Item__c> teamRegItems;

        GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','registrationType',programRegistrationInfo.registrationType);
        GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','eventId',programRegistrationInfo.eventId);

        if(programRegistrationInfo.registrationType == 'event') {

            teamRegItems = [select id, B2B_Deal__c, B2B_Deal__r.Account__c, B2B_Deal__r.Account__r.Name, Access_Code__c, Is_Event_Prepaid__c, Is_Event_Bundle__c,
                            Event_Discounted_Price__c, Prepaid_Discount_Percent__c, Seats_Allowed__c, GST_Fee_Paid_by_Institution__c,Deal_Rate_Type__c,Add_Discount_Line_Item__c, EPP_Deal__c,
                            (SELECT Id, AccountId, StageName FROM Opportunities__r where StageName != 'Closed Lost')
                            from B2B_Deal_Item__c
                            where Access_Code__c = :programRegistrationInfo.regCode AND
                            ((Is_Event_Prepaid__c = True AND B2B_Deal__r.Payment_Status__c = 'Paid') OR (Is_Event_Prepaid__c = False AND B2B_Deal__r.Status__c = 'Approved')) AND
                            Start_Date__c <= :tdy AND End_Date__c >= :tdy AND Event__c = :programRegistrationInfo.eventId AND Seats_Remaining__c > 0];

        } else if(programRegistrationInfo.registrationType == 'checkout') {

            teamRegItems = [select id, B2B_Deal__c, B2B_Deal__r.Account__c, B2B_Deal__r.Account__r.Name, Access_Code__c, eBook_Type__c,
                            eBook_ProductCode__c, Seats_Allowed__c, GST_Fee_Paid_by_Institution__c, Deal_Rate_Type__c, Add_Discount_Line_Item__c,
                            Discount_Type__c, Discount_Percent__c, Discounted_Price__c, EPP_Deal__c,
                            (SELECT Id, AccountId, StageName FROM Opportunities__r where StageName != 'Closed Lost')
                            from B2B_Deal_Item__c
                            where Access_Code__c = :programRegistrationInfo.regCode AND (B2B_Deal__r.Payment_Status__c = 'Paid' OR B2B_Deal__r.Status__c = 'Approved') AND
                            Start_Date__c <= :tdy AND End_Date__c >= :tdy  AND Seats_Remaining__c > 0];

        } else if(programRegistrationInfo.registrationType == 'membership') {

            teamRegItems = [select id, B2B_Deal__c, B2B_Deal__r.Account__c, B2B_Deal__r.Account__r.Name, Access_Code__c,
                            Exam_Type__c, Is_Scholarship__c, Include_Enrollment_in_Scholarship__c, Free_Membership__c,
                            Attestation_Required__c, Attestation_Copy__c, Discounted_Price__c, Prepaid_Discount_Percent__c,
                            OSTA_Fee_Paid_by_Institution__c, GST_Fee_Paid_by_Institution__c, Seats_Allowed__c, Only_Allow_Retakes__c,
                            Deal_Rate_Type__c, Add_Discount_Line_Item__c, EPP_Deal__c,
                            (SELECT Id, AccountId, StageName FROM Opportunities__r where StageName != 'Closed Lost')
                            from B2B_Deal_Item__c
                            where Access_Code__c = :programRegistrationInfo.regCode AND
                            (B2B_Deal__r.Payment_Status__c = 'Paid' OR
                            ((Is_Scholarship__c = True OR Discounted_Price__c != NULL) AND B2B_Deal__r.Status__c = 'Approved')) AND
                            Start_Date__c <= :tdy AND End_Date__c >= :tdy AND Seats_Remaining__c > 0];

        } else {

            // Exams & Courses
            teamRegItems = [select id, B2B_Deal__c, B2B_Deal__r.Account__c, B2B_Deal__r.Account__r.Name, Access_Code__c,
                            Exam_Type__c, Is_Scholarship__c, Include_Enrollment_in_Scholarship__c, Free_Membership__c,
                            Attestation_Required__c, Attestation_Copy__c, Discounted_Price__c, Prepaid_Discount_Percent__c,
                            OSTA_Fee_Paid_by_Institution__c, GST_Fee_Paid_by_Institution__c, Seats_Allowed__c, Only_Allow_Retakes__c,
                            Deal_Rate_Type__c, Add_Discount_Line_Item__c, EPP_Deal__c, EPP_Deal__r.Exam_Year__c, EPP_Deal__r.Start_Date__c, EPP_Deal__r.End_Date__c,
                            Included_Study_Materials__c,
                            (SELECT Id, AccountId, StageName FROM Opportunities__r where StageName != 'Closed Lost')
                            from B2B_Deal_Item__c
                            where Access_Code__c = :programRegistrationInfo.regCode AND
                            (B2B_Deal__r.Payment_Status__c = 'Paid' OR
                            ((Is_Scholarship__c = True OR Discounted_Price__c != NULL) AND B2B_Deal__r.Status__c = 'Approved')) AND
                            Start_Date__c <= :tdy AND End_Date__c >= :tdy AND Exam_Type__c in :teamExamTypes AND Seats_Remaining__c > 0];
        }
        GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','teamRegItems',teamRegItems);

        if(!teamRegItems.isEmpty()) {
            B2B_Deal_Item__c teamRegItem = teamRegItems[0];

            // Double Check Seat Balance
            if(!skipSeatLimitCheck && !teamRegItem.Opportunities__r.IsEmpty()) {
                Integer countSeats= teamRegItem.Opportunities__r.size();
                GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','countSeats',countSeats);

                if(countSeats >= teamRegItem.Seats_Allowed__c) {
                    retTeamInfo.status = 'Failed';
                    retTeamInfo.statusMessage = 'The Team Registration code given is no longer valid';
                    GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','countSeats failed',retTeamInfo);
                    return retTeamInfo;
                } else if(accountId != NULL) {
                    for(Opportunity opp :teamRegItem.Opportunities__r) {
                        if(opp.AccountId == accountId) {
                            retTeamInfo.status = 'Failed';
                            retTeamInfo.statusMessage = 'The Team Registration code was already used';
                            GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','reuse key failed',retTeamInfo);
                            return retTeamInfo;
                        }
                    }
                }
            }

            // Check EPP Deal Exam Year
            if(teamRegItem.EPP_Deal__c != NULL && teamRegItem.EPP_Deal__r.Exam_Year__c != NULL) {
                Integer eppDealYear = Integer.ValueOf(teamRegItem.EPP_Deal__r.Exam_Year__c);
                if(tdy < Date.newInstance(eppDealYear-1, 12, 1) || tdy > Date.newInstance(eppDealYear, 11, 30) ||
                   (teamRegItem.EPP_Deal__r.Start_Date__c != NULL && tdy < teamRegItem.EPP_Deal__r.Start_Date__c) ||
                   (teamRegItem.EPP_Deal__r.End_Date__c != NULL && tdy > teamRegItem.EPP_Deal__r.End_Date__c)
                  ) {
                    retTeamInfo.status = 'Failed';
                    retTeamInfo.statusMessage = 'The Team Registration used outside of the EPP Deal date range';
                    GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','reuse key failed',retTeamInfo);
                    return retTeamInfo;
                }
            }

            retTeamInfo.teamRegInfo.teamRegId = teamRegItem.Id;
            retTeamInfo.teamRegInfo.teamRegParentId = teamRegItem.B2B_Deal__c;
            retTeamInfo.teamRegInfo.teamRegCode = programRegistrationInfo.regCode;
            retTeamInfo.teamRegInfo.authenticationRequired = False;
            retTeamInfo.teamRegInfo.isComplimentary = False;
            retTeamInfo.teamRegInfo.accountName = teamRegItem.B2B_Deal__r.Account__r.Name;
            retTeamInfo.teamRegInfo.isScholarship = False;
            retTeamInfo.teamRegInfo.isScholarshipEnrollmentComplimentary = False;
            retTeamInfo.teamRegInfo.isGSTFeePaidByInstitution = teamRegItem.GST_Fee_Paid_by_Institution__c;
            retTeamInfo.teamRegInfo.isOSTAFeePaidByInstitution = False;
            retTeamInfo.teamRegInfo.rateType = teamRegItem.Deal_Rate_Type__c;
            retTeamInfo.teamRegInfo.addDiscountLineItem = teamRegItem.Add_Discount_Line_Item__c;
            retTeamInfo.teamRegInfo.EPPDealId = teamRegItem.EPP_Deal__c;

            if(programRegistrationInfo.registrationType == 'event') {
                retTeamInfo.teamRegInfo.isEvent = True;
                retTeamInfo.teamRegInfo.isBundle = teamRegItem.Is_Event_Bundle__c;
                if(teamRegItem.Is_Event_Prepaid__c) {
                    retTeamInfo.teamRegInfo.isComplimentary = True;
                    retTeamInfo.teamRegInfo.prePaidDiscountPercent = teamRegItem.Prepaid_Discount_Percent__c;
                } else {
                    retTeamInfo.teamRegInfo.eventDiscountPrice = teamRegItem.Event_Discounted_Price__c;
                }
            } else if(programRegistrationInfo.registrationType == 'checkout') {
                retTeamInfo.teamRegInfo.authenticationRequired = True;

                retTeamInfo.teamRegInfo.eBookType = teamRegItem.eBook_Type__c;
                retTeamInfo.teamRegInfo.eBookProductCode = teamRegItem.eBook_ProductCode__c;

                retTeamInfo.teamRegInfo.discountPrice = teamRegItem.Discounted_Price__c;
                retTeamInfo.teamRegInfo.discountPercent = teamRegItem.Discount_Percent__c;
                retTeamInfo.teamRegInfo.discountType = teamRegItem.Discount_Type__c;

                // Compute Discount Product
                if(retTeamInfo.teamRegInfo.eBookType != NULL && teamRegItem.Discount_Type__c != NULL) {
                    if((retTeamInfo.teamRegInfo.eBookType == 'FRM Part I' || retTeamInfo.teamRegInfo.eBookType == 'FRM Part II') && teamRegItem.Discount_Type__c == 'EPP') {
                        retTeamInfo.teamRegInfo.discountProductCode = 'DISCFRMEPP';
                    } else if((retTeamInfo.teamRegInfo.eBookType == 'FRM Part I' || retTeamInfo.teamRegInfo.eBookType == 'FRM Part II') && teamRegItem.Discount_Type__c == 'Academic') {
                        retTeamInfo.teamRegInfo.discountProductCode = 'DISCFRMAP';
                    } else if(retTeamInfo.teamRegInfo.eBookType == 'SCR' && teamRegItem.Discount_Type__c == 'EPP') {
                        retTeamInfo.teamRegInfo.discountProductCode = 'DISCSCREPP';
                    } else if((retTeamInfo.teamRegInfo.eBookType == 'FRM Part I' || retTeamInfo.teamRegInfo.eBookType == 'FRM Part II') && teamRegItem.Discount_Type__c == 'Academic') {
                        retTeamInfo.teamRegInfo.discountProductCode = 'DISCSCRAP';
                    } else if(retTeamInfo.teamRegInfo.eBookType == 'RAIJ' && teamRegItem.Discount_Type__c == 'EPP') {
                        retTeamInfo.teamRegInfo.discountProductCode = 'DISCRAIJEPP';
                    } else if(retTeamInfo.teamRegInfo.eBookType == 'RAIJ' && teamRegItem.Discount_Type__c == 'Academic') {
                        retTeamInfo.teamRegInfo.discountProductCode = 'DISCRAIJAP';
                    }
                } else {
                    retTeamInfo.teamRegInfo.isComplimentary = True;
                }

            } else {

                retTeamInfo.teamRegInfo.isOSTAFeePaidByInstitution = teamRegItem.OSTA_Fee_Paid_by_Institution__c;
                retTeamInfo.teamRegInfo.isRetakeOnly = teamRegItem.Only_Allow_Retakes__c;
                if(retTeamInfo.teamRegInfo.isRetakeOnly) {
                    retTeamInfo.teamRegInfo.authenticationRequired = True;
                }
                retTeamInfo.teamRegInfo.examType = teamRegItem.Exam_Type__c;
                retTeamInfo.teamRegInfo.consentMessage = teamRegItem.Attestation_Copy__c;
                retTeamInfo.teamRegInfo.isAttestationRequired = teamRegItem.Attestation_Required__c;
                if(teamRegItem.Discounted_Price__c == NULL && teamRegItem.Is_Scholarship__c == FALSE ) {
                    retTeamInfo.teamRegInfo.isComplimentary = True;
                }
                if(retTeamInfo.teamRegInfo.examType == 'FRM II') {
                    retTeamInfo.teamRegInfo.authenticationRequired = True;
                }
                retTeamInfo.teamRegInfo.isScholarship = teamRegItem.Is_Scholarship__c;
                retTeamInfo.teamRegInfo.isScholarshipEnrollmentComplimentary = teamRegItem.Include_Enrollment_in_Scholarship__c;
                retTeamInfo.teamRegInfo.discountPrice = teamRegItem.Discounted_Price__c;
                retTeamInfo.teamRegInfo.complimentaryMembership = teamRegItem.Free_Membership__c;
                retTeamInfo.teamRegInfo.prePaidDiscountPercent = teamRegItem.Prepaid_Discount_Percent__c;
                retTeamInfo.teamRegInfo.includedStudyMaterials = teamRegItem.Included_Study_Materials__c;

                // Check Scholarship Reuse
                if(teamRegItem.Is_Scholarship__c) {
                    List<Opportunity> lstOpp = [select Id, Display_Invoice_Number__c, Amount,
                                                (SELECT Id, ProductCode, Product_ID__c, TotalPrice, Product2.Order_summary_Is_Scholarship__c, Product2.Order_Summary_Product_Line__c FROM OpportunityLineItems)
                                                from Opportunity where AccountId = :accountId AND StageName = 'Closed' Order By CreatedDate DESC];
                    GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','Reuse lstOpp',lstOpp);
                    if(!lstOpp.IsEmpty()) {
                        Set<String> mainProdCodes = new Set<String>();
                        //mainProdCodes.addAll(programRegistrationInfo.mainProductCodes);

                        for(Opportunity opp :lstOpp) {
                            if(!opp.OpportunityLineItems.IsEmpty()) {
                                for(OpportunityLineItem oli :opp.OpportunityLineItems) {
                                    if((programRegistrationInfo.microCourseInfo != NULL && (oli.ProductCode == programRegistrationInfo.microCourseInfo.memberProductCode || oli.ProductCode == programRegistrationInfo.microCourseInfo.nonMemberProductCode || oli.ProductCode == programRegistrationInfo.microCourseInfo.certifiedProductCode)) ||
                                       (oli.Product2.Order_Summary_Product_Line__c == productLine && oli.Product2.Order_summary_Is_Scholarship__c)) {
                                        retTeamInfo.status = 'Failed';
                                        retTeamInfo.statusMessage = 'Scholarship was already used for this program';
                                        return retTeamInfo;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_Registration','getTeamRegistrationInfo','teamRegInfo',retTeamInfo.teamRegInfo);

        } else {
            retTeamInfo.status = 'Failed';
            retTeamInfo.statusMessage = 'The Team Registration code given is not currently valid';
            return retTeamInfo;
        }

        retTeamInfo.status = 'Success';
        return retTeamInfo;
    }

    public static Affiliate_Program__c getAffiliateProgramInfo(String regCode) {

        GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramInfo','regCode',regCode);

        Date tdy = Date.Today();
        List<Affiliate_Program__c> lstAffProgs = [select id,EPP_Deal__r.Status__c,EPP_Deal__r.Start_Date__c,EPP_Deal__r.End_Date__c,Account__r.EPP_Accounting_Code__c, Affiliate_Code__c, Start_Date__c, End_Date__c, Product__c, EPP_Deal__c
                                                  from Affiliate_Program__c where Affiliate_Code__c = :regCode AND Affiliate_Code__c != null Order By CreatedDate Desc Limit 1];
        GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramInfo','lstAffProgs',lstAffProgs);

        if(!lstAffProgs.IsEmpty()) {
            return lstAffProgs[0];
        }

        return NULL;
    }

    public static GARP_BC_Orders.affiliateProgramInfo getAffiliateProgramCredits(setRegistrationInfo setRegistrationInfo, List<GARP_BC_Orders.productInfo> feeProducts) {

        Date tdy = Date.Today();

        Affiliate_Program__c affiliateProgram = getAffiliateProgramInfo(setRegistrationInfo.affiliateCode);
        GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramCredits','affiliateProgram',affiliateProgram);

        if(affiliateProgram != NULL) {

            GARP_BC_Orders.affiliateProgramInfo ret = new GARP_BC_Orders.affiliateProgramInfo();
            ret.affiliateCode = setRegistrationInfo.affiliateCode;
            ret.affiliateProgramId = affiliateProgram.Id;
            ret.affiliateVendorCode = affiliateProgram.Account__r.EPP_Accounting_Code__c;

            // Check the Date
            if((affiliateProgram.Start_Date__c == NULL || tdy <= affiliateProgram.Start_Date__c) ||
               (affiliateProgram.End_Date__c == NULL || tdy >= affiliateProgram.End_Date__c)) {
                   GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramCredits','Check Date Failed',null);
                   ret.affiliateEligable = false;
                   return ret;
            }
            // Check the products
            if(affiliateProgram.Product__c == 'FRM Exam') {

                // Is FRM Part not selected
                if(setRegistrationInfo.examSelectionInfo == NULL ||
                   setRegistrationInfo.examSelectionInfo.partSelected == NULL ||
                   (setRegistrationInfo.examSelectionInfo.partSelected.IndexOf('FRM Exam Part I') == -1 &&
                   setRegistrationInfo.examSelectionInfo.partSelected.IndexOf('FRM Exam Part II') == -1)
                  )
                {
                    GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramCredits','Check Exam Part Failed',setRegistrationInfo.examSelectionInfo);
                    ret.affiliateEligable = false;
                    return ret;
                } else {
                    ret.affiliateEligable = true;
                    ret.affiliateCredits = 0;
                    if(setRegistrationInfo.examSelectionInfo.partSelected.IndexOf('FRM Exam Part I') > -1)
                        ret.affiliateCredits++;
                    if(setRegistrationInfo.examSelectionInfo.partSelected.IndexOf('FRM Exam Part II') > -1)
                        ret.affiliateCredits++;
                }

            } else if(affiliateProgram.Product__c == 'SCR Exam') {
                if(setRegistrationInfo.examSelectionInfo == NULL ||
                   setRegistrationInfo.examSelectionInfo.partSelected == NULL) {
                       GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramCredits','Check Exam Part Failed',setRegistrationInfo.examSelectionInfo);
                       ret.affiliateEligable = false;
                       return ret;
                   }
                ret.affiliateEligable = true;
                ret.affiliateCredits = 1;
            } else if(affiliateProgram.Product__c == 'RAI Exam') {
                if(setRegistrationInfo.examSelectionInfo == NULL ||
                   setRegistrationInfo.examSelectionInfo.partSelected == NULL) {
                       GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramCredits','Check Exam Part Failed',setRegistrationInfo.examSelectionInfo);
                       ret.affiliateEligable = false;
                       return ret;
                   }
                ret.affiliateEligable = true;
                ret.affiliateCredits = 1;
            } else if(affiliateProgram.Product__c == 'RAIJ Exam') {
                if(setRegistrationInfo.examSelectionInfo == NULL ||
                   setRegistrationInfo.examSelectionInfo.partSelected == NULL) {
                       GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramCredits','Check Exam Part Failed',setRegistrationInfo.examSelectionInfo);
                       ret.affiliateEligable = false;
                       return ret;
                   }
                ret.affiliateEligable = true;
                ret.affiliateCredits = 1;
            }

            if(ret.affiliateEligable) {

                GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramCredits','affiliateProgram.EPP_Deal__c',affiliateProgram.EPP_Deal__c);
                if(affiliateProgram.EPP_Deal__c != NULL) {
                    ret.EPPDealId = affiliateProgram.EPP_Deal__c;
                }

                GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramCredits','final true',ret);
                return ret;

                // Is Enrollment purchased
                /*
                Boolean enrollmentFound = FALSE;
                for(GARP_BC_Orders.productInfo prod :feeProducts) {
                    if(prod.productCode == 'FRM1' && prod.glCode == '4010') {
                        enrollmentFound = TRUE;
                    }
                }
                GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramCredits','enrollmentFound',enrollmentFound);

                if(!enrollmentFound) {
                    return FALSE;
                }
                */
            }  else {
                ret.affiliateEligable = false;
                GARP_Common.debugLog('GARP_BC_Registration','getAffiliateProgramCredits','final false',ret);
                return ret;
            }
        } else {
            return NULL;
        }
    }

    public class paymentStatus {
        public Boolean isOrderFound;
        public Boolean isPaymentFound;
        public Boolean isPaymentSuccess;
        public Boolean isOrderRolledback;
        public String paymentType;
    }

    // Check Payment Status
    public static paymentStatus checkRegistrationPaymentStatus(String orderId) {
        GARP_Common.debugLog('GARP_BC_Registration','checkRegistrationPaymentStatus','orderId',orderId);

        paymentStatus paymentStatus = new paymentStatus();

        List<Opportunity> lstOpp = [select Id, AccountId, Amount, StageName, Alternate_Method_of_Payment__c, Rollback_Reason__c, CreatedDate, (SELECT Id, ChargentOrders__Response_Status__c, ChargentOrders__Payment_Method__c from Transactions__r ORDER BY CreatedDate DESC) from Opportunity where Id = :orderId];
        GARP_Common.debugLog('GARP_BC_Registration','checkRegistrationPaymentStatus','lstOpp',lstOpp);

        if(!lstOpp.IsEmpty()) {
            paymentStatus.isOrderFound = True;
            Opportunity opportunity = lstOpp[0];
            paymentStatus.paymentType = opportunity.Alternate_Method_of_Payment__c;

            if(opportunity.StageName == 'Closed Lost' && opportunity.Rollback_Reason__c != NULL) {
                paymentStatus.isOrderRolledback = TRUE;
            } else {
                paymentStatus.isOrderRolledback = FALSE;
            }
            GARP_Common.debugLog('GARP_BC_Registration','checkRegistrationPaymentStatus','isOrderRolledback',paymentStatus.isOrderRolledback);

            paymentStatus.isPaymentSuccess = FALSE;
            paymentStatus.isPaymentFound = FALSE;

            if(!opportunity.Transactions__r.IsEmpty()) {
                paymentStatus.isPaymentFound = TRUE;

                if(opportunity.Transactions__r[0].ChargentOrders__Response_Status__c != 'Failure') {
                    paymentStatus.isPaymentSuccess = TRUE;
                }
            }
            GARP_Common.debugLog('GARP_BC_Registration','checkRegistrationPaymentStatus','isPaymentFound',paymentStatus.isPaymentFound);
            GARP_Common.debugLog('GARP_BC_Registration','checkRegistrationPaymentStatus','isPaymentSuccess',paymentStatus.isPaymentSuccess);


        } else {
            paymentStatus.isOrderFound = FALSE;
        }

        return paymentStatus;
    }

    public static Boolean rollbackSetRegistration(String leadId, String accountId, String email, String orderId, String rollbackReason) {

        GARP_Common.debugLog('GARP_BC_Registration','rollbackSetRegistration','leadId',leadId);
        GARP_Common.debugLog('GARP_BC_Registration','rollbackSetRegistration','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_Registration','rollbackSetRegistration','email',email);
        GARP_Common.debugLog('GARP_BC_Registration','rollbackSetRegistration','orderId',orderId);
        GARP_Common.debugLog('GARP_BC_Registration','rollbackSetRegistration','rollbackReason',rollbackReason);

        Boolean ret = False;

        GARP_Common.checkAuthentication checkAuth = GARP_Common.checkAuthentication();
        GARP_Common.debugLog('GARP_BC_Registration','rollbackSetRegistration','checkAuth',checkAuth);
        Boolean IsAuthenticated = checkAuth.isAuthenticated;

        GARP_BC_Registration.orderCustomerInfo customerInfo = new GARP_BC_Registration.orderCustomerInfo();
        customerInfo.leadId = leadId;
        customerInfo.accountId = accountId;
        GARP_Common.debugLog('GARP_BC_Registration','rollbackSetRegistration','customerInfo',customerInfo);

        //GARP_BC_Registration.checkExistingContact checkRet = GARP_BC_Registration.checkExistingContact(email);
        //GARP_Common.debugLog('GARP_BC_Registration','rollbackSetRegistration','checkRet',checkRet);

        List<Opportunity> lstOpp = [select Id, Amount, B2B_Deal_Item__c, B2B_Deal_Item__r.Access_Code__c from Opportunity where Id = :orderId];
        GARP_Common.debugLog('GARP_BC_Registration','rollbackSetRegistration','lstOpp',lstOpp);

        List<Contact> lstCont = [select Id, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c from Contact where AccountId = :accountId];
        GARP_Common.debugLog('GARP_BC_Registration','rollbackSetRegistration','lstCont',lstCont);

        if(!lstOpp.IsEmpty() && !lstCont.IsEmpty()) {
            Opportunity purchaseOpp = lstOpp[0];
            Contact purchaeCont = lstCont[0];
            ret = GARP_BC_Orders.manualRollback(customerInfo, purchaeCont, purchaseOpp, isAuthenticated,rollbackReason);
        }

        return ret;
    }


    public static String getSessionState(String sessionToken) {
        List<Form_Data__c> lstSess = [select Id, Form_State__c from Form_Data__c where id = :sessionToken];
        GARP_Common.debugLog('GARP_BC_Registration','getSessionState','lstSess',lstSess);

        if(!lstSess.IsEmpty()) {
            return lstSess[0].Form_State__c;
        } else {
            return null;
        }
    }

    public static Boolean setSessionState(String sessionToken, String SessionStateJSON) {
        List<Form_Data__c> lstSess = [select Id, Form_State__c from Form_Data__c where id = :sessionToken];
        GARP_Common.debugLog('GARP_BC_Registration','setSessionState','lstSess',lstSess);

        if(!lstSess.IsEmpty()) {
            lstSess[0].Form_State__c = SessionStateJSON;
            update lstSess;
            return True;
        }
        return False;
    }

    public static Form_Data__c getFormData(String formDataId, Opportunity purchaseOpp) {
        GARP_Common.debugLog('GARP_BC_Registration','getFormData','formDataId',formDataId);
        GARP_Common.debugLog('GARP_BC_Registration','getFormData','purchaseOpp',purchaseOpp);

        List<Form_Data__c> formData;

        if(formDataId != NULL) {
            formData = [
            SELECT Id, Lead__c, Contact__c, Status__c, Form__r.Form_Name__c, Track_CTA__c
            FROM Form_Data__c
            WHERE Id = :formDataId
            ];
        } else if(purchaseOpp != NULL) {
            formData = [
                SELECT Id, Lead__c, Contact__c, Status__c, Form__r.Form_Name__c, Track_CTA__c
                FROM Form_Data__c
                WHERE Opportunity__c = :purchaseOpp.Id
            ];
        }

        GARP_Common.debugLog('GARP_BC_Registration','getFormData','formData',formData);

        Form_Data__c returnFormData;
        if(formData != NULL && !formData.IsEmpty()) {
            returnFormData = formData[0];
        }

        GARP_Common.debugLog('GARP_BC_Registration','getFormData','returnFormData',returnFormData);
        return returnFormData;
    }

    public static Form_Data__c closeFormData(String formDataId, Opportunity purchaseOpp) {
        GARP_Common.debugLog('GARP_BC_Registration','closeFormData','formDataId',formDataId);
        GARP_Common.debugLog('GARP_BC_Registration','closeFormData','purchaseOpp',purchaseOpp);

        List<Form_Data__c> formData;

        if(formDataId != NULL) {
            formData = [
            SELECT Id, Lead__c, Contact__c, Status__c, Form__r.Form_Name__c, Track_CTA__c
            FROM Form_Data__c
            WHERE Id = :formDataId
            ];
        } else if(purchaseOpp != NULL) {
            formData = [
                SELECT Id, Lead__c, Contact__c, Status__c, Form__r.Form_Name__c, Track_CTA__c
                FROM Form_Data__c
                WHERE Opportunity__c = :purchaseOpp.Id
            ];
        }

        GARP_Common.debugLog('GARP_BC_Registration','closeFormData','formData',formData);

        Form_Data__c returnFormData;
        if(formData != NULL && !formData.IsEmpty()) {
            returnFormData = formData[0];

            for(Form_Data__c fd :formData) {
                returnFormData.Status__c = 'Completed';
            }
            GARP_Common.debugLog('GARP_BC_Registration','closeFormData','update returnFormData',returnFormData);
            update formData;
        }

        GARP_Common.debugLog('GARP_BC_Registration','closeFormData','returnFormData',returnFormData);
        return returnFormData;
    }

    public static Form_Data__c migrateFormDataToContact(String sessionId, String email, String contactId, String opportunityId, String status) {
        List<Form_Data__c> lstFormData = [
            SELECT Id, Email__c, Contact__c, Opportunity__c, Status__c, Form__r.Form_Name__c, Track_CTA__c
            FROM Form_Data__c
            WHERE Id = :sessionId OR (Email__c = :email AND Contact__c = NULL)
        ];

        Form_Data__c formData;
        for(Form_Data__c fd :lstFormData) {

            if(fd.Id == sessionId) {
                formData = fd;
            }

            fd.Contact__c = contactId;
            fd.Opportunity__c = opportunityId;
            fd.Status__c = status;
        }
        update lstFormData;

        return formData;
    }

    public static Form_Data__c migrateLeadFormDataToContact(String leadId, String contactId, String opportunityId, String formName, Boolean isCompleted) {
        return migrateLeadFormDataToContact(leadId, contactId, opportunityId, formName);
    }

    public static Form_Data__c migrateLeadFormDataToContact(String leadId, String contactId, String opportunityId, String formName) {

        GARP_Common.debugLog('GARP_BC_Registration','migrateLeadFormDataToContact','leadId',leadId);
        GARP_Common.debugLog('GARP_BC_Registration','migrateLeadFormDataToContact','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_Registration','migrateLeadFormDataToContact','opportunityId',opportunityId);
        GARP_Common.debugLog('GARP_BC_Registration','migrateLeadFormDataToContact','formName',formName);

        Form_Data__c returnFormData;

        List<Form_Data__c> formData;
        if(leadId != NULL) {
            formData = [
                SELECT Id, Lead__c, Contact__c, Status__c, Form__r.Form_Name__c, Track_CTA__c
                FROM Form_Data__c
                WHERE Lead__c = :leadId AND Form__r.Form_Name__c = :formName
                ORDER BY CreatedDate DESC
            ];
        }
        GARP_Common.debugLog('GARP_BC_Registration','migrateLeadFormDataToContact','formData',formData);

        if(formData != NULL && !formData.isEmpty()){
            Form_Data__c fd = formData[0];
            returnFormData = fd;
            if(leadId != null) {
                fd.Lead__c = null;
                fd.Contact__c = contactId;
            }
            if(opportunityId != NULL) {
                fd.OpportunityId__c = opportunityId;
                fd.Opportunity__c = opportunityId;
            }
            GARP_Common.debugLog('GARP_BC_Registration','migrateLeadFormDataToContact','UPDATE formData',fd);
            UPDATE fd;
        } else if(contactId != NULL) {
            // Update Opp Id on Form Data on Contact
            formData = [
                SELECT Id, Lead__c, Contact__c, Status__c, Form__r.Form_Name__c, Track_CTA__c
                FROM Form_Data__c
                WHERE Contact__c = :contactId AND Form__r.Form_Name__c = :formName
                ORDER BY CreatedDate DESC
            ];
            if(formData != NULL && !formData.isEmpty()){
                Form_Data__c fd = formData[0];
                returnFormData = fd;
                if(opportunityId != NULL) {
                    fd.OpportunityId__c = opportunityId;
                    fd.Opportunity__c = opportunityId;
                }
                GARP_Common.debugLog('GARP_BC_Registration','migrateLeadFormDataToContact','UPDATE formData',fd);
                UPDATE fd;
            }


        }

        // AG 2/13/2026 -- No longer in use
        // Only do if Lead Id is given
        //if(leadId != null) {

            // Move Object_History__c
            //List<Object_History__c> lstObjHist = [select Id, Lead__c, Contact__c from Object_History__c where Lead__c = :leadId];
            //for(Object_History__c oh :lstObjHist) {
            //    oh.Contact__c = contactId;
            //}

            //GARP_Common.debugLog('GARP_BC_Registration','migrateLeadFormDataToContact','returnFormData', returnFormData);
        //}

        return returnFormData;
    }
}