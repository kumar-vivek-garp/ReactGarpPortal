@isTest
public class GARP_Events_test {

    public static Account account;
    public static Contact contact;
    public static User user;
    
    public static void runTestPublicEventReg() {
        GARP_TestFactory.createCountryCodes();
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getEventRegistrationSettings(NULL, NULL);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        List<String> getProds = new List<String>{'CRTM','CRTNM'};
        Map<String,PricebookEntry> prodMap = GARP_TestFactory.getPriceBooksEntries(getProds);
        PricebookEntry peMem = prodMap.get('CRTM:4040');
        PricebookEntry peNonMem = prodMap.get('CRTNM:4040');
        String eventId = GARP_TestFactory.createEvent(peMem.Product2.Id, peNonMem.Product2.Id, FALSE);
        test.startTest();
        GARP_MS_Events.getEventRegistrationInfo(eventId, NULL);
        programRegistrationInfo = GARP_BC_Events.getEventRegistrationSettings(eventId, NULL);
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        regInfo = GARP_BC_Events.updateEventRegInfo(programRegistrationInfo, regInfo);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        setRegistrationInfo.eventOptions.attendanceMethod = 'In-Person';
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        test.stopTest();
    }

    @isTest
    public static void runTestAuthEventReg() {

        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;

        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getEventRegistrationSettings(NULL, NULL);

        List<String> prods = new List<String>();
        prods.addAll(GARP_TestFactory.createProductList('CRTM'));
        prods.addAll(GARP_TestFactory.createProductList('CRTNM'));
        prods.addAll(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode));
        prods.addAll(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode));
        Map<String, Product2> mapProducts = GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});

        Product2 prodCRTM = mapProducts.get(programRegistrationInfo.mainMemberProductCode);
        Product2 prodCRTNM = mapProducts.get(programRegistrationInfo.mainNonMemberProductCode);
        String eventId = GARP_TestFactory.createEvent(prodCRTM.Id, prodCRTNM.Id, FALSE);

        test.startTest();
        System.runAs(user) {
            programRegistrationInfo = GARP_BC_Events.getEventRegistrationSettings(eventId, NULL);
            GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
            System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            regInfo = GARP_BC_Events.updateEventRegInfo(programRegistrationInfo, regInfo);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
            GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
            setRegistrationInfo.eventOptions.attendanceMethod = 'In-Person';
            GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
            System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        }
        test.stopTest();
    }

    @isTest
    public static void testAuthEventReg() { runTestAuthEventReg(); }

    public static void runTestPublicEventInviteOnlyReg() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.createUnmatchedBusinessAccount();
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getEventRegistrationSettings(NULL, NULL);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        List<String> getProds = new List<String>{'CRTM','CRTNM'};
        Map<String,PricebookEntry> prodMap = GARP_TestFactory.getPriceBooksEntries(getProds);
        PricebookEntry peMem = prodMap.get('CRTM:4040');
        PricebookEntry peNonMem = prodMap.get('CRTNM:4040');
        String eventId = GARP_TestFactory.createEvent(peMem.Product2.Id, peNonMem.Product2.Id, TRUE);
        test.startTest();
        GARP_MS_Events.getEventRegistrationInfo(eventId, NULL);
        programRegistrationInfo = GARP_BC_Events.getEventRegistrationSettings(eventId, NULL);
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        regInfo = GARP_BC_Events.updateEventRegInfo(programRegistrationInfo, regInfo);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        setRegistrationInfo.eventOptions.attendanceMethod = 'In-Person';
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        GARP_MS_Events.setRSVPInviteOnlyDecline(eventId, 'garpqa.test@garp.com');
        test.stopTest();
    }

    @isTest
    public static void testPublicEventInviteOnlyReg() { runTestPublicEventInviteOnlyReg(); }

    public static void runTestPublicEventDiscountCodesReg() {
        GARP_TestFactory.createCountryCodes();
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getEventRegistrationSettings(NULL, NULL);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        List<String> getProds = new List<String>{'CRTM','CRTNM'};
        Map<String,PricebookEntry> prodMap = GARP_TestFactory.getPriceBooksEntries(getProds);
        PricebookEntry peMem = prodMap.get('CRTM:4040');
        PricebookEntry peNonMem = prodMap.get('CRTNM:4040');
        String eventId = GARP_TestFactory.createEvent(peMem.Product2.Id, peNonMem.Product2.Id, FALSE);
        test.startTest();
        GARP_MS_Events.getEventRegistrationInfo(eventId, NULL);
        programRegistrationInfo = GARP_BC_Events.getEventRegistrationSettings(eventId, NULL);
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        regInfo = GARP_BC_Events.updateEventRegInfo(programRegistrationInfo, regInfo);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        getRegistrationFeesInfo.promoCodes = new List<GARP_BC_Registration.promoCodeVerify>();
        GARP_BC_Registration.promoCodeVerify promo = new GARP_BC_Registration.promoCodeVerify();
        promo.promoCode = 'DISCOUNTCODE';
        promo.isValid = true;
        promo.message = '';
        getRegistrationFeesInfo.promoCodes.add(promo);
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        setRegistrationInfo.eventOptions.attendanceMethod = 'In-Person';
        setRegistrationInfo.promoCodes = getRegistrationFeesInfo.promoCodes;
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        test.stopTest();
    }

    @isTest
    public static void testPublicEventDiscountCodesReg() { runTestPublicEventDiscountCodesReg(); }

    public static void runTestPublicWebcastReg() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.createUnmatchedBusinessAccount();
        String eventId = GARP_TestFactory.createWebcast();
        test.startTest();
        GARP_MS_Events.getWebcastRegistrationInfo(eventId);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getWebcastRegistrationSettings(eventId);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        regInfo = GARP_BC_Events.updateEventRegInfo(programRegistrationInfo, regInfo);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        setRegistrationInfo.eventOptions.attendanceMethod = 'Virtual';
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        test.stopTest();
    }

    @isTest
    public static void testPublicWebcastReg() { runTestPublicWebcastReg(); }

    public static void runTestAuthWebcastReg() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.createUnmatchedBusinessAccount();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        String eventId = GARP_TestFactory.createWebcast();
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getWebcastRegistrationSettings(eventId);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        test.startTest();
        GARP_MS_Events.getWebcastRegistrationInfo(eventId);
        System.runAs(user) {
            GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
            System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            regInfo = GARP_BC_Events.updateEventRegInfo(programRegistrationInfo, regInfo);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
            GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
            setRegistrationInfo.eventOptions.attendanceMethod = 'Virtual';
            GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
            System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        }
        test.stopTest();
    }

    @isTest
    public static void testAuthWebcastReg() { runTestAuthWebcastReg(); }

    public static void runTestPublicChapterReg() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getChapterMeetingRegistrationSettings(NULL);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        List<String> getProds = new List<String>{'CRTM','CRTNM'};
        Map<String,PricebookEntry> prodMap = GARP_TestFactory.getPriceBooksEntries(getProds);
        PricebookEntry peMem = prodMap.get('CRTM:4040');
        PricebookEntry peNonMem = prodMap.get('CRTNM:4040');
        String eventId = GARP_TestFactory.createChapterMeeting(peMem.Product2.Id, peNonMem.Product2.Id);
        GARP_MS_Events.getChapterMeetingRegistrationInfo(eventId);
        programRegistrationInfo = GARP_BC_Events.getChapterMeetingRegistrationSettings(eventId);
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        regInfo = GARP_BC_Events.updateChapterMeetingRegInfo(programRegistrationInfo, regInfo);
        test.startTest();
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        setRegistrationInfo.eventOptions.attendanceMethod = 'In-Person';
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        GARP_BC_Events.createOnDemandAuthenticatedUserChapterMeetingRegistration(eventId);
        GARP_BC_Events.getChapterMeetingDiscounts(eventId);
        test.stopTest();
    }

    @isTest
    public static void testPublicChapterReg() { runTestPublicChapterReg(); }

    public static void runTesAuthChapterReg() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getChapterMeetingRegistrationSettings(NULL);
        List<String> prods = new List<String>();
        prods.addAll(GARP_TestFactory.createProductList('CRTM'));
        prods.addAll(GARP_TestFactory.createProductList('CRTNM'));
        prods.addAll(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode));
        prods.addAll(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode));
        Map<String, Product2> mapProducts = GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        Product2 prodCRTM = mapProducts.get(programRegistrationInfo.mainMemberProductCode);
        Product2 prodCRTNM = mapProducts.get(programRegistrationInfo.mainNonMemberProductCode);
        String eventId = GARP_TestFactory.createChapterMeeting(prodCRTM.Id, prodCRTNM.Id);
        test.startTest();
        System.runAs(user) {
            programRegistrationInfo = GARP_BC_Events.getChapterMeetingRegistrationSettings(eventId);
            GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
            System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            regInfo = GARP_BC_Events.updateChapterMeetingRegInfo(programRegistrationInfo, regInfo);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
            GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
            //setRegistrationInfo.eventOptions.attendanceMethod = 'In-Person';
            //GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
            //System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        }
        test.stopTest();
    }

    @isTest
    public static void tesAuthChapterReg() { runTesAuthChapterReg(); }

    @isTest
    public static void testV2PortalCalls() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.createUnmatchedBusinessAccount();
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getEventRegistrationSettings(NULL, NULL);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        List<String> getProds = new List<String>{'CRTM','CRTNM'};
        Map<String,PricebookEntry> prodMap = GARP_TestFactory.getPriceBooksEntries(getProds);
        PricebookEntry peMem = prodMap.get('CRTM:4040');
        PricebookEntry peNonMem = prodMap.get('CRTNM:4040');
        String webcastId = GARP_TestFactory.createWebcast();
        String chapterMeetingId = GARP_TestFactory.createChapterMeeting(peMem.Product2.Id, peNonMem.Product2.Id);
        String eventId = GARP_TestFactory.createEvent(peMem.Product2.Id, peNonMem.Product2.Id, FALSE);
        GARP_TestFactory.createUser();
        GARP_TestFactory.createMember();
        List<Contact> lstCont = [SELECT Id, AccountId, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c, KPI_Primary_Chapter_Name__c, KPI_Secondary_Chapter_Name__c FROM Contact];
        Contact contact = lstCont[0];
        GARP_TestFactory.Chp_Evt_Web_Registrations(chapterMeetingId, eventId, webcastId, contact.Id);
        test.startTest();
        List<GARP_BC_Events.memberEventInfo> registeredEvents = GARP_BC_Events.getMemberEventRegistrationsSummary(contact.Id, False);
        Set<String> alreadyRegisteredIds = new Set<String>();
        if (!registeredEvents.isEmpty()) {
            for (GARP_BC_Events.memberEventInfo evi : registeredEvents) {
                alreadyRegisteredIds.add(evi.eventId);
            }
        }
        Date tdy = Date.today();
        List<Chapter_Meeting__c> lstChapterMeeting = [SELECT Id, Chapter_Meeting_Name__c, Chapter__r.Name, Start_Date__c, Vanity_URL__c FROM Chapter_Meeting__c WHERE Status__c = 'Active' AND Start__c >= :tdy ORDER BY Start__c];
        List<GARP_BC_Events.memberEventInfo> upcomingChapterMeetings = GARP_BC_Events.getMemberUpcomingChapterMeetings(contact, lstChapterMeeting, alreadyRegisteredIds);
        Set<String> upcomingChapterMeetingEventIds = new Set<String>();
        if (!upcomingChapterMeetings.isEmpty()) {
            for (GARP_BC_Events.memberEventInfo evi : upcomingChapterMeetings) {
                upcomingChapterMeetingEventIds.add(evi.eventId);
            }
        }
        Map<String,Contract> mapContracts = new Map<String,Contract>();
        GARP_BC_Events.getMemberUpcomingOtherEvents(contact, lstChapterMeeting, alreadyRegisteredIds, upcomingChapterMeetingEventIds, mapContracts);
        test.stopTest();
    }
}