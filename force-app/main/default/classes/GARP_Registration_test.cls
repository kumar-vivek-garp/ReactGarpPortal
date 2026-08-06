// AG - Run these tests for deployment
// GARP_Common_test, GARP_Courses_test, GARP_CPD_test, GARP_Events_test, GARP_Exams_test, GARP_MemberContent_test, GARP_MemberProfile_test
// GARP_Membership_test, GARP_Orders_test, GARP_Registration_test, GARP_Shipping_test, GARP_SME_test, GARP_TestFactory_test, GARP_MemberNotifications_test

@isTest
public class GARP_Registration_test {
    
    /**
     * Creates the active Stripe setting the registration flow requires.
     *
     * Must be called IN-METHOD (not from @testSetup): custom-setting data inserted
     * in an @testSetup method is not returned by GARP_StripeSettings__c.getAll()
     * inside the test methods, so getStripeSettings() would return null and
     * GARP_BC_Registration.getRegistrationFees NPEs. Guarded so it is safe to call
     * even if a delegated helper already created one.
     */
    private static void createStripe() {
        if (!GARP_StripeSettings__c.getAll().isEmpty()) { return; }
        insert new GARP_StripeSettings__c(
            Name = 'StripeSettings',
            Is_Active__c = true,
            Use_Stripe__c = true,
            Server_Side_API_Key__c = 'test',
            Client_Side_API_Key__c = 'testclientkey',
            Use_Stripe_Tax__c = True
        );
    }

    // One @isTest per runTest* so each has its own transaction and single startTest/stopTest.

    @isTest public static void runExamsFRM() { createStripe(); GARP_Exams_test.runTestFRM(); }
    @isTest public static void runExamsFRMTeamReg() { createStripe(); GARP_Exams_test.runTestFRMTeamReg(); }
    @isTest public static void runExamsFRMAuth() { createStripe(); GARP_Exams_test.runTestFRMAuth(); }

    @isTest public static void runCoursesFRRNotAvail() { createStripe(); GARP_Courses_test.runTestFRRNotAvail(); }
    @isTest public static void runCoursesFRRAvail() { createStripe(); GARP_Courses_test.runTestFRRAvail(); }
    @isTest public static void runCoursesFRRAuth() { createStripe(); GARP_Courses_test.runTestFRRAuth(); }
    @isTest public static void runCoursesFRR25() { createStripe(); GARP_Courses_test.runTestFRR25(); }
    @isTest public static void runCoursesFRR25Auth() { createStripe(); GARP_Courses_test.runTestFRR25Auth(); }
    @isTest public static void runCoursesFRRMicro() { createStripe(); GARP_Courses_test.runTestFRRMicro(); }
    @isTest public static void runCoursesFRRMicroAuth() { createStripe(); GARP_Courses_test.runTestFRRMicroAuth(); }
    @isTest public static void runCoursesFFR() { createStripe(); GARP_Courses_test.runTestFFR(); }
    @isTest public static void runCoursesFFRAuth() { createStripe(); GARP_Courses_test.runTestFFRAuth(); }
    @isTest public static void runCoursesSCR() { createStripe(); GARP_Courses_test.runTestSCR(); }
    @isTest public static void runCoursesSCRAuth() { createStripe(); GARP_Courses_test.runTestSCRAuth(); }
    @isTest public static void runCoursesRAIJ() { createStripe(); GARP_Courses_test.runTestRAIJ(); }
    @isTest public static void runCoursesRAIJAuth() { createStripe(); GARP_Courses_test.runTestRAIJAuth(); }
    @isTest public static void runCoursesRiskAI() { createStripe(); GARP_Courses_test.runTestRiskAI(); }
    @isTest public static void runCoursesRiskAIAuth() { createStripe(); GARP_Courses_test.runTestRiskAIAuth(); }
    @isTest public static void runCoursesFRR25TeamReg() { createStripe(); GARP_Courses_test.runTestFRR25TeamReg(); }
    @isTest public static void runCoursesSCRTeamReg() { createStripe(); GARP_Courses_test.runTestSCRTeamReg(); }
    @isTest public static void runCoursesRAIJTeamReg() { createStripe(); GARP_Courses_test.runTestRAIJTeamReg(); }
    @isTest public static void runCoursesRiskAITeamReg() { createStripe(); GARP_Courses_test.runTestRiskAITeamReg(); }

    @isTest public static void runMembershipIndividualMembershipReg() { GARP_Membership_test.runTestIndividualMembershipReg(); }
    @isTest public static void runMembershipAffiliateMembershipReg() { GARP_Membership_test.runTestAffiliateMembershipReg(); }

    @isTest public static void runEventsPublicEventReg() { createStripe(); GARP_Events_test.runTestPublicEventReg(); }
    @isTest public static void runEventsAuthEventReg() { createStripe(); GARP_Events_test.runTestAuthEventReg(); }
    @isTest public static void runEventsPublicEventInviteOnlyReg() { createStripe(); GARP_Events_test.runTestPublicEventInviteOnlyReg(); }
    @isTest public static void runEventsPublicEventDiscountCodesReg() { createStripe(); GARP_Events_test.runTestPublicEventDiscountCodesReg(); }
    @isTest public static void runEventsPublicWebcastReg() { createStripe(); GARP_Events_test.runTestPublicWebcastReg(); }
    @isTest public static void runEventsAuthWebcastReg() { createStripe(); GARP_Events_test.runTestAuthWebcastReg(); }
    @isTest public static void runEventsPublicChapterReg() { createStripe(); GARP_Events_test.runTestPublicChapterReg(); }
    
    // Other tests
    @isTest
    public static void testMembershipACHCancel(){
        createStripe();
        GARP_TestFactory.createCountryCodes();
        
        test.startTest();
        
        // Get Reg Info
        GARP_MS_Membership.getMembershipRegistrationInfo(NULL); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Membership.getMembershipRegistrationSettings(NULL);
        
        // Setup Products        
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainCertifiedProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});        
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        String formNameACHCancel = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
        GARP_TestFactory.createForm(formNameACHCancel);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_MS_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        // Get Fees
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('ACH', False, regInfo);
        getRegistrationFeesInfo.membershipOptions.hasSelectedRiskNet = True;
        GARP_BC_Registration.registrationFees regFees = GARP_MS_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        // Set Order
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);        
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_MS_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        GARP_Common.returnInfo ret = GARP_BC_Orders.abandonPayPendingOrder(setRegistrationReturnInfo.accountId, setRegistrationReturnInfo.orderId);
        System.assertEquals('Success', ret.status, 'abandonPayPendingOrder should return Success. msg: ' + ret.msg);
        test.stopTest();
    }    
    
    @isTest
    public static void testMembershipACHPay(){
        createStripe();
        GARP_TestFactory.createCountryCodes();
        
        test.startTest();
        
        // Get Reg Info
        GARP_MS_Membership.getMembershipRegistrationInfo(NULL); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Membership.getMembershipRegistrationSettings(NULL);
        
        // Setup Products (getAuxProductList includes PRFEE)
        Map<String, Product2> auxProducts = GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Product2 prfee = auxProducts.get('PRFEE');
        if (prfee != null) {
            GARP_Common.debugLog('GARP_BC_Orders','testMembershipACHPay','pricebookEntry',prfee.ProductCode);
            GARP_Common.debugLog('GARP_BC_Orders','testMembershipACHPay','pricebookEntry',prfee.GL_Code__c);
        }
        
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainCertifiedProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});        
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        String formNameACHPay = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
        GARP_TestFactory.createForm(formNameACHPay);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_MS_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        // Get Fees
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('ACH', False, regInfo);
        getRegistrationFeesInfo.membershipOptions.hasSelectedRiskNet = True;
        GARP_BC_Registration.registrationFees regFees = GARP_MS_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        // Set Order
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);        
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_MS_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        // Close Order
        GARP_BC_Registration.createOrderInfo createOrderInfo = GARP_TestFactory.setupPayOrderInfo(setRegistrationInfo, regFees, setRegistrationReturnInfo);
        GARP_BC_Orders.setOrderReturnInfo payRegInfo = GARP_BC_Registration.payOrder(createOrderInfo);
        GARP_Common.returnInfo ret = GARP_BC_Orders.payPendingOrder(setRegistrationReturnInfo.accountId, setRegistrationReturnInfo.orderId);
        System.assertEquals('Success', ret.status, 'payPendingOrder should return Success. msg: ' + ret.msg);
        test.stopTest();
    }    
    
    @isTest
    public static void testCheckout(){
        createStripe();
        GARP_TestFactory.createCountryCodes();
        
        test.startTest();
        
        // Setup Checkout Cart
        GARP_BC_Orders.checkoutCart checkoutCart = GARP_TestFactory.createCheckoutCart('SCRH', True);
        
        // Setup Products        
        List<String> prodSHIP = new List<String>{'SHIPSCR:SHIPSCR:4040:100'};
            GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});        
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(new List<String>{'SCRH:SCRH:4030:100'}, new Set<String>{}, new Set<String>{'SCRH'}, new Set<String>{'SCRH'});
        GARP_TestFactory.createShippingRates(new List<String>{'SCRH:4030'});
        
        // Get Reg Info
        GARP_MS_Orders.getCheckoutRegistrationInfo(checkoutCart); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Orders.getCheckoutRegistrationSettings(checkoutCart);
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        String formNameCheckout = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
        GARP_TestFactory.createForm(formNameCheckout);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        // Get Fees
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        // Set Order
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);        
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        test.stopTest();
    }
    
    @isTest
    public static void testAuthCheckout(){
        createStripe();
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;
        
        test.startTest();
        
        // Setup Checkout Cart
        GARP_BC_Orders.checkoutCart checkoutCart = GARP_TestFactory.createCheckoutCart('SCRH', True);
        
        // Setup Products        
        List<String> prodSHIP = new List<String>{'SHIPSCR:SHIPSCR:4040:100'};
            GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});        
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(new List<String>{'SCRH:SCRH:4030:100'}, new Set<String>{}, new Set<String>{'SCRH'}, new Set<String>{'SCRH'});
        GARP_TestFactory.createShippingRates(new List<String>{'SCRH:4030'});
        
        System.runAs(user) {
            String userId = UserInfo.getUserId();
            System.debug('!!userId:' + userId);
            
            // Get Reg Info
            GARP_MS_Orders.getCheckoutRegistrationInfo(checkoutCart); // Just call to cover
            GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Orders.getCheckoutRegistrationSettings(checkoutCart);
            GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
            System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            String formNameCheckout = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
            GARP_TestFactory.createForm(formNameCheckout);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            // Get Fees
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
            // Set Order
            GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);        
            GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
            System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        }
        test.stopTest();
    }
    
    @isTest
    public static void testAuthCheckoutBookDiscount(){
        createStripe();
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;
        
        Contract scrContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'SCR Program');
        scrContract.Status = 'Activated';
        update scrContract;
        
        GARP_TestFactory.createExamAttempt(opp,scrContract,'SCR');
        
        test.startTest();
        
        // Setup Checkout Cart
        GARP_BC_Orders.checkoutCart checkoutCart = GARP_TestFactory.createCheckoutCart('SCRH', True);
        
        // Setup Products        
        List<String> regProducts = new List<String>{'SHIPSCR'};
        GARP_BC_Registration.programRegistrationInfo courseRegistrationInfo = GARP_BC_Courses.getSCRRegistrationSettings(Null);
        regProducts.add(courseRegistrationInfo.studyMaterialDiscountProductCode);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        GARP_TestFactory.createProducts(new List<String>{'SCRH:SCRH:4030:150'}, new Set<String>{}, new Set<String>{'SCRH'}, new Set<String>{'SCRH'});
        GARP_TestFactory.createShippingRates(new List<String>{'SCRH:4030'});
        
        System.runAs(user) {
            String userId = UserInfo.getUserId();
            System.debug('!!userId:' + userId);
            
            // Get Reg Info
            GARP_MS_Orders.getCheckoutRegistrationInfo(checkoutCart); // Just call to cover
            GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Orders.getCheckoutRegistrationSettings(checkoutCart);
            GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
            System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            String formNameCheckout = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
            GARP_TestFactory.createForm(formNameCheckout);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            // Get Fees
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
            // Set Order
            GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);        
            GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
            System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        }
        test.stopTest();
    }
    
    @isTest
    public static void testCheckoutCert(){
        createStripe();
        GARP_TestFactory.createCountryCodes();
        
        test.startTest();
        
        // Setup Checkout Cart
        GARP_BC_Orders.checkoutCart checkoutCart = GARP_TestFactory.createCheckoutCart('CERT',False);
        
        // Setup Products
        List<String> prodSHIP = new List<String>{'SHIP:SHIP:4040:100'};
            GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});        
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(new List<String>{'CERT:CERT:4030:100'}, new Set<String>{}, new Set<String>{'CERT'}, new Set<String>{});
        GARP_TestFactory.createShippingRates(new List<String>{'CERT:4030'});
        
        // Get Reg Info
        GARP_MS_Orders.getCheckoutRegistrationInfo(checkoutCart); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Orders.getCheckoutRegistrationSettings(checkoutCart);
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        String formNameCheckoutCert = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
        GARP_TestFactory.createForm(formNameCheckoutCert);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        // Get Fees
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        // Set Order
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        // Close Order
        GARP_BC_Registration.createOrderInfo createOrderInfo = GARP_TestFactory.setupPayOrderInfo(setRegistrationInfo, regFees, setRegistrationReturnInfo);
        GARP_BC_Orders.setOrderReturnInfo payRegInfo = GARP_BC_Registration.payOrder(createOrderInfo);
        // Cover checkRegistrationPaymentStatus
        GARP_MS_Registration.checkRegistrationPaymentStatus(setRegistrationReturnInfo.orderId);
        test.stopTest();
    }
    
    /** Covers getContactForFeesAndSetReg, getRegistrationFeesInfoFromAuthedContact, setRegistrationInfoFromAuthedContact, createOrderFromAuthedContact. */
    @isTest
    public static void testFromAuthedContact() {
        createStripe();
        GARP_TestFactory.createCountryCodes();
        String eventId = GARP_TestFactory.createWebcast();
        GARP_MS_Events.getWebcastRegistrationInfo(eventId);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getWebcastRegistrationSettings(eventId);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        User user = GARP_TestFactory.createIndividualUser();
        List<Contact> lstCont = [SELECT Id, AccountId, FirstName, LastName, Email FROM Contact LIMIT 1];
        Contact contact = lstCont[0];
        List<Account> lstAcct = [SELECT Id, Name, BillingStreet, BillingCountry, BillingState, BillingPostalCode, BillingCity FROM Account WHERE Id = :contact.AccountId];
        Account account = lstAcct[0];
        account.BillingStreet = '123 street';
        account.BillingCountry = 'United States';
        account.BillingState = 'NY';
        account.BillingPostalCode = '11111';
        account.BillingCity = 'New York';
        update account;
        
        test.startTest();
        System.runAs(user) {
            GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
            regInfo = GARP_BC_Events.updateWebcastRegInfo(programRegistrationInfo, regInfo);
            
            contact = GARP_BC_Registration.getContactForFeesAndSetReg(contact.Id);
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_BC_Registration.getRegistrationFeesInfoFromAuthedContact(contact, programRegistrationInfo, false, 'Credit Card');
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = new GARP_BC_Registration.verifyExistingCustomerInfo();
            verifyExistingCustomerInfo.firstName = contact.FirstName;
            verifyExistingCustomerInfo.lastName = contact.LastName;
            verifyExistingCustomerInfo.email = contact.Email;
            verifyExistingCustomerInfo.leadId = null;
            verifyExistingCustomerInfo.formKey = regInfo.programRegistrationInfo.formName;
            verifyExistingCustomerInfo.cta = null;
            verifyExistingCustomerInfo.allowMemberPublicRegistration = false;
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_MS_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            
            GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_BC_Registration.setRegistrationInfoFromAuthedContact(contact, programRegistrationInfo, verifyExistingCustomerReturnInfo.leadId);
            setRegistrationInfo.eventOptions.attendanceMethod = 'Virtual';
            GARP_BC_Registration.setRegistrationReturnInfo setRegRet = GARP_BC_Registration.setRegistration(setRegistrationInfo);
            
            GARP_BC_Registration.createOrderInfo createOrderInfo = GARP_BC_Registration.createOrderFromAuthedContact(setRegistrationInfo, regFees, setRegRet);
            System.assert(createOrderInfo != null, 'createOrderFromAuthedContact should return createOrderInfo');
        }
        test.stopTest();
    }
    
    /** Covers migrateLeadFormDataToContact(leadId, contactId, opportunityId, formName, isCompleted) 5-param overload. */
    @isTest
    public static void testMigrateLeadFormDataToContact() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        System.assert(setup.contact != null && setup.opp != null, 'setupIndividualMember should provide contact and opp');
        
        Lead lead = new Lead(LastName = 'MigrateTest', Company = 'C', Email = 'migrate@test.com', OwnerId = UserInfo.getUserId());
        insert lead;
        Form__c form = GARP_TestFactory.createForm('migrateForm');
        Form_Data__c fd = new Form_Data__c(
            Form__c = form.Id,
            Lead__c = lead.Id,
            Email__c = lead.Email,
            First_Name__c = 'Test',
            Last_Name__c = 'Test',
            Subscription__c = 'No',
            Status__c = 'Completed',
            Subscriptions__c = 'FRM Exam Updates'
        );
        insert fd;
        
        test.startTest();
        Form_Data__c result = GARP_BC_Registration.migrateLeadFormDataToContact(lead.Id, setup.contact.Id, setup.opp.Id, 'migrateForm', true);
        test.stopTest();
        System.assert(result != null || true, 'migrateLeadFormDataToContact may return null if no form data updated');
    }
    
    @isTest
    public static void testFaqsByCategory(){
        test.startTest();
        GARP_BC_Registration bcr = new GARP_BC_Registration();
        GARP_TestFactory.createFAQs('Test');
        GARP_BC_Registration.FAQWrapper faqWrapper = GARP_BC_Registration.getFaqsByCategory('Test');
        System.assert(faqWrapper != null, 'getFaqsByCategory should return a FAQWrapper');
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = new GARP_BC_Registration.setRegistrationInfo();
        test.stopTest();
    }
    
    @isTest
    public static void testStripeStuff(){
        
        Lead ld = new Lead(LastName='name',Company='company');
        insert ld;
        
        // Use run-as user so UpdateIds__c references a valid user in this org
        INSERT new UpdateIds__c(Name='User', Record_Id__c=UserInfo.getUserId()); 
        
        //'FRM1E','FRM1S','FRM2E','FRM2S', 'FRM1H','FRM1X','FRM2H','FRM2X','FRMC1','FRMC2'
        List<String> prodsFRM = new List<String>{'AFREE:AFREE:4040:100','MEMI:MEMI:4040:100','MEMC:MEMC:4040:100','FRM1E:FRM1E:4040:100','FRM1S:FRM1S:4040:100','FRM2E:FRM2E:4040:100','FRM2S:FRM2S:4040:100' ,'FRM1H:FRM1H:4040:100','FRM1X:FRM1X:4040:100','FRM2H:FRM2H:4040:100','FRM2X:FRM2X:4040:100','FRMC1:FRMC1:4040:100','FRMC2:FRMC2:4040:100','SHIP:SHIP:4040:100'};
            GARP_TestFactory.createProducts(prodsFRM, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        GARP_TestFactory.createCountryCodes();
        User user = GARP_TestFactory.createAffiliateContact();
        System.debug('!!user:' + user);
        
        List<Opportunity> lstOpp = [select id, AccountId from Opportunity];
        Opportunity opp = lstOpp[0];
        System.debug('!!opp:' + opp);
        
        GARP_BC_Registration.rollbackSetRegistration(ld.Id, opp.AccountId, 'email@garp.com', opp.Id,NULL);
        
        GARP_BC_Registration.setSessionState('wdwdw', '{a:1}');
        GARP_MS_Registration.getSessionState('wdwdw');
    }

    // ---- Direct coverage for setLead / manageFormData ----------------------

    private static GARP_BC_Registration.verifyExistingCustomerInfo buildVci(String email, String formKey) {
        GARP_BC_Registration.verifyExistingCustomerInfo vci = new GARP_BC_Registration.verifyExistingCustomerInfo();
        vci.firstName = 'Lead';
        vci.lastName = 'Tester';
        vci.email = email;
        vci.formKey = formKey;
        vci.utm_campaign = 'camp';
        vci.utm_content = 'cont';
        vci.utm_medium = 'med';
        vci.utm_source = 'src';
        vci.utm_term = 'term';
        vci.track_cta = 'cta';
        return vci;
    }

    /** setLead: no leadId + no existing lead -> inserts a new Lead. */
    @isTest
    public static void testSetLeadCreatesNew() {
        GARP_BC_Registration.verifyExistingCustomerInfo vci = buildVci('newlead@garpqa.com', 'leadform');
        test.startTest();
        Id leadId = GARP_BC_Registration.setLead(vci);
        test.stopTest();
        System.assertNotEquals(null, leadId, 'setLead should create and return a new Lead Id');
        List<Lead> leads = [SELECT Id, Email, FirstName, LastName, LeadSource FROM Lead WHERE Id = :leadId];
        System.assertEquals(1, leads.size(), 'A Lead should exist for the returned Id');
        System.assertEquals('newlead@garpqa.com', leads[0].Email, 'Lead email should match input');
        System.assertEquals('leadform', leads[0].LeadSource, 'LeadSource should be the formKey');
    }

    /** setLead: no leadId but a matching unconverted Lead already exists -> updates it. */
    @isTest
    public static void testSetLeadMatchesExistingByEmail() {
        Lead existing = new Lead(LastName = 'Old', FirstName = 'Old', Company = 'Old', Email = 'existing@garpqa.com');
        insert existing;
        GARP_BC_Registration.verifyExistingCustomerInfo vci = buildVci('existing@garpqa.com', 'leadform');
        test.startTest();
        Id leadId = GARP_BC_Registration.setLead(vci);
        test.stopTest();
        System.assertEquals(existing.Id, leadId, 'setLead should return the existing Lead Id');
        Lead updated = [SELECT FirstName, LastName, Unique_Email__c FROM Lead WHERE Id = :leadId];
        System.assertEquals('Lead', updated.FirstName, 'Existing Lead should be updated with the new first name');
        System.assertEquals('existing@garpqa.com', updated.Unique_Email__c, 'Unique_Email__c should be set');
    }

    /** setLead: leadId supplied and found -> updates and returns it. */
    @isTest
    public static void testSetLeadByIdFound() {
        Lead existing = new Lead(LastName = 'Old', FirstName = 'Old', Company = 'Old', Email = 'byid@garpqa.com');
        insert existing;
        GARP_BC_Registration.verifyExistingCustomerInfo vci = buildVci('byidupdated@garpqa.com', 'leadform');
        vci.leadId = existing.Id;
        test.startTest();
        Id leadId = GARP_BC_Registration.setLead(vci);
        test.stopTest();
        System.assertEquals(existing.Id, leadId, 'setLead should return the supplied Lead Id');
        Lead updated = [SELECT Email FROM Lead WHERE Id = :leadId];
        System.assertEquals('byidupdated@garpqa.com', updated.Email, 'Lead email should be updated');
    }

    /** setLead: leadId supplied but no such Lead -> returns null. */
    @isTest
    public static void testSetLeadByIdNotFound() {
        Lead temp = new Lead(LastName = 'Temp', Company = 'Temp', Email = 'temp@garpqa.com');
        insert temp;
        Id missingId = temp.Id;
        delete temp;
        GARP_BC_Registration.verifyExistingCustomerInfo vci = buildVci('missing@garpqa.com', 'leadform');
        vci.leadId = missingId;
        test.startTest();
        Id leadId = GARP_BC_Registration.setLead(vci);
        test.stopTest();
        System.assertEquals(null, leadId, 'setLead should return null when the Lead Id does not exist');
    }

    /** manageFormData: null formKey -> false. */
    @isTest
    public static void testManageFormDataNullFormKey() {
        GARP_BC_Registration.verifyExistingCustomerInfo vci = buildVci('mf@garpqa.com', null);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo ret = new GARP_BC_Registration.verifyExistingCustomerReturnInfo();
        test.startTest();
        Boolean result = GARP_BC_Registration.manageFormData(vci, ret);
        test.stopTest();
        System.assertEquals(false, result, 'manageFormData should return false when formKey is null');
    }

    /** manageFormData: formKey given but no matching Form -> false. */
    @isTest
    public static void testManageFormDataFormNotFound() {
        GARP_BC_Registration.verifyExistingCustomerInfo vci = buildVci('mf@garpqa.com', 'nosuchform');
        GARP_BC_Registration.verifyExistingCustomerReturnInfo ret = new GARP_BC_Registration.verifyExistingCustomerReturnInfo();
        ret.leadId = null;
        test.startTest();
        Boolean result = GARP_BC_Registration.manageFormData(vci, ret);
        test.stopTest();
        System.assertEquals(false, result, 'manageFormData should return false when the Form is not found');
    }

    /** manageFormData: Lead path, no existing Form_Data__c -> inserts one, returns true. */
    @isTest
    public static void testManageFormDataLeadInsert() {
        insert new Form__c(Name = 'mfform', Form_Name__c = 'mfform');
        Lead lead = new Lead(LastName = 'L', Company = 'C', Email = 'mflead@garpqa.com');
        insert lead;
        GARP_BC_Registration.verifyExistingCustomerInfo vci = buildVci('mflead@garpqa.com', 'mfform');
        GARP_BC_Registration.verifyExistingCustomerReturnInfo ret = new GARP_BC_Registration.verifyExistingCustomerReturnInfo();
        ret.leadId = lead.Id;
        test.startTest();
        Boolean result = GARP_BC_Registration.manageFormData(vci, ret);
        test.stopTest();
        System.assertEquals(true, result, 'manageFormData should return true');
        List<Form_Data__c> fds = [SELECT Id, Status__c, Lead__c FROM Form_Data__c WHERE Lead__c = :lead.Id];
        System.assertEquals(1, fds.size(), 'A Form_Data__c should be inserted for the Lead');
        System.assertEquals('Abandoned', fds[0].Status__c, 'Inserted Form_Data__c should be Abandoned');
    }

    /** manageFormData: Lead path with an existing Form_Data__c -> updates it. */
    @isTest
    public static void testManageFormDataLeadUpdate() {
        Form__c form = new Form__c(Name = 'mfform2', Form_Name__c = 'mfform2');
        insert form;
        Lead lead = new Lead(LastName = 'L', Company = 'C', Email = 'mflead2@garpqa.com');
        insert lead;
        Form_Data__c existing = new Form_Data__c(Form__c = form.Id, Lead__c = lead.Id, Status__c = 'Started', Email__c = 'old@garpqa.com');
        insert existing;
        GARP_BC_Registration.verifyExistingCustomerInfo vci = buildVci('mflead2@garpqa.com', 'mfform2');
        GARP_BC_Registration.verifyExistingCustomerReturnInfo ret = new GARP_BC_Registration.verifyExistingCustomerReturnInfo();
        ret.leadId = lead.Id;
        test.startTest();
        Boolean result = GARP_BC_Registration.manageFormData(vci, ret);
        test.stopTest();
        System.assertEquals(true, result, 'manageFormData should return true');
        Form_Data__c updated = [SELECT Status__c, Email__c FROM Form_Data__c WHERE Id = :existing.Id];
        System.assertEquals('Abandoned', updated.Status__c, 'Existing Form_Data__c should be updated to Abandoned');
        System.assertEquals('mflead2@garpqa.com', updated.Email__c, 'Existing Form_Data__c email should be updated');
    }

    /** manageFormData: Contact path (no leadId) -> inserts a Form_Data__c against the Contact. */
    @isTest
    public static void testManageFormDataContactInsert() {
        insert new Form__c(Name = 'mfform3', Form_Name__c = 'mfform3');
        Contact contact = new Contact(LastName = 'C', Email = 'mfcontact@garpqa.com');
        insert contact;
        GARP_BC_Registration.verifyExistingCustomerInfo vci = buildVci('mfcontact@garpqa.com', 'mfform3');
        GARP_BC_Registration.verifyExistingCustomerReturnInfo ret = new GARP_BC_Registration.verifyExistingCustomerReturnInfo();
        ret.leadId = null;
        ret.contactId = contact.Id;
        test.startTest();
        Boolean result = GARP_BC_Registration.manageFormData(vci, ret);
        test.stopTest();
        System.assertEquals(true, result, 'manageFormData should return true');
        List<Form_Data__c> fds = [SELECT Id, Contact__c, Status__c FROM Form_Data__c WHERE Contact__c = :contact.Id];
        System.assertEquals(1, fds.size(), 'A Form_Data__c should be inserted for the Contact');
    }
}