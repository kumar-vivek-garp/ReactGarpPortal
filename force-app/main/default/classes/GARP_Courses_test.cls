@isTest
public class GARP_Courses_test {

    public static void runTestFRRNotAvail() {
        GARP_TestFactory.createCountryCodes();
        test.startTest();
        GARP_MS_Courses.getFRRRegistrationInfo(NULL);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getFRRRegistrationSettings(NULL);
        List<String> prodSHIP = new List<String>{'SHIPFRR:SHIPFRR:4040:100'};
        GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'CBRX'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'CBRHB:4030'});
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals(false, regInfo.isEligible, 'getRegistrationInfo should return not eligible when Exam Group is not active. statusMessage: ' + regInfo.statusMessage);
        System.assert(regInfo.notEligibleErrorMessage != null && regInfo.notEligibleErrorMessage.contains('not currently available'), 'getRegistrationInfo should return message that course is not currently available when Exam Group is not active. notEligibleErrorMessage: ' + regInfo.notEligibleErrorMessage);
        test.stopTest();
    }

    @isTest
    public static void testFRRNotAvail() { runTestFRRNotAvail(); }

    public static void runTestFRRAvail() {
        GARP_TestFactory.createCountryCodes();
        String examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'ICBRR');
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        objExamGrp.RecordTypeId = examGroupRecordTypeId;
        insert objExamGrp;
        test.startTest();
        GARP_MS_Courses.getFRRRegistrationInfo(NULL);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getFRRRegistrationSettings(NULL);
        List<String> prodSHIP = new List<String>{'SHIPFRR:SHIPFRR:4040:100'};
        GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'CBRX'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'CBRHB:4030'});
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success when Exam Group is active. statusMessage: ' + regInfo.statusMessage);
        String formNameFRRAvail = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
        GARP_TestFactory.createForm(formNameFRRAvail);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return accountId');
        test.stopTest();
    }

    @isTest
    public static void testFRRAvail() { runTestFRRAvail(); }

    public static void runTestFRRAuth() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;
        String examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'ICBRR');
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        objExamGrp.RecordTypeId = examGroupRecordTypeId;
        insert objExamGrp;
        test.startTest();
        Contract programContract = new Contract(
            Name = 'FRR',
            Status='Draft',
            AccountId = contact.AccountId,
            Opportunity__c = opp.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today().AddDays(-365),
            ContractTerm = 12,
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'ICBRR Program')
        );
        INSERT programContract;
        programContract.Status = 'Expired';
        UPDATE programContract;
        GARP_MS_Courses.getFRRRegistrationInfo(NULL);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getFRRRegistrationSettings(NULL);
        List<String> prodSHIP = new List<String>{'SHIPFRR:SHIPFRR:4040:100'};
        GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'CBRX'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'CBRHB:4030'});
        System.runAs(user) {
            GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
            System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            String formNameFRRAuth = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
            GARP_TestFactory.createForm(formNameFRRAuth);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        }
        test.stopTest();
    }

    @isTest
    public static void testFRRAuth() { runTestFRRAuth(); }

    public static void runTestFRR25() {
        GARP_TestFactory.createCountryCodes();
        String examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRR25');
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        objExamGrp.RecordTypeId = examGroupRecordTypeId;
        insert objExamGrp;
        Exam__c ex = new Exam__c(Name='FRR25',Exam__c='FRR25',Exam_Date__c=Date.Today(), Exam_Group__c = objExamGrp.id);
        Insert ex;
        Exam_Sites__c exmSite = new Exam_Sites__c(exam__c = ex.id);
        insert exmSite;
        test.startTest();
        GARP_MS_Courses.getFRR25RegistrationInfo(NULL);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getFRR25RegistrationSettings(NULL);
        List<String> prodSHIP = new List<String>{'SHIPFRR25:SHIPFRR25:4040:100'};
        GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'FRR25HB:4030'});
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        String formNameFRR25 = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
        GARP_TestFactory.createForm(formNameFRR25);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account');
        GARP_TestFactory.assertRegistrationCreatedProgramContract(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRR25 Program');
        GARP_TestFactory.assertRegistrationCreatedCandidateRequirementExamCode(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRR25 Program', 'FRR25');
        GARP_TestFactory.assertRegistrationCreatedExamAttemptProgram(Id.valueOf(setRegistrationReturnInfo.orderId), 'FRR25');
        GARP_TestFactory.assertRegistrationOpportunityHasMainProduct(Id.valueOf(setRegistrationReturnInfo.orderId), 'FRRSNM');
        test.stopTest();
    }

    @isTest
    public static void testFRR25() { runTestFRR25(); }

    public static void runTestFRR25TeamReg() {
        GARP_TestFactory.createCountryCodes();
        String examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRR25');
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        objExamGrp.RecordTypeId = examGroupRecordTypeId;
        insert objExamGrp;
        Exam__c ex = new Exam__c(Name='FRR25', Exam__c='FRR25', Exam_Date__c=Date.Today(), Exam_Group__c=objExamGrp.Id);
        insert ex;
        Exam_Sites__c exmSite = new Exam_Sites__c(Exam__c=ex.Id);
        insert exmSite;
        Team_Registration__c teamReg = GARP_TestFactory.createTeamReg('FRR25', 100, False, False, False);
        String teamRegCode = (teamReg != null && teamReg.Access_Code__c != null) ? teamReg.Access_Code__c : '123';
        test.startTest();
        GARP_MS_Courses.getFRR25RegistrationInfo(teamRegCode);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getFRR25RegistrationSettings(teamRegCode);

        List<String> regProducts = new List<String>{'SHIPFRR25'};
        if (String.isNotBlank(programRegistrationInfo.teamRegDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.teamRegDiscountProductCode);
        }
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});

        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        if (programRegistrationInfo.teamProductCodes != null && !programRegistrationInfo.teamProductCodes.isEmpty()) {
            GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.teamProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        }
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'FRR25HB:4030'});
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success.');
        String formNameFRR25TR = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
        GARP_TestFactory.createForm(formNameFRR25TR);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        getRegistrationFeesInfo.teamRegCode = teamRegCode;
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        setRegistrationInfo.teamRegInfo = regInfo.teamRegInfo;
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account.');
        test.stopTest();
    }

    @isTest
    public static void testFRR25TeamReg() { runTestFRR25TeamReg(); }

    public static void runTestFRR25Auth() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;

        String examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRR25');
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        objExamGrp.RecordTypeId = examGroupRecordTypeId;
        insert objExamGrp;

        Exam__c ex = new Exam__c(Name='FRR25',Exam__c='FRR25',Exam_Date__c=Date.Today(), Exam_Group__c = objExamGrp.id);
        Insert ex;
        Exam_Sites__c exmSite = new Exam_Sites__c(exam__c = ex.id);
        insert exmSite;
        test.startTest();

        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getFRR25RegistrationSettings(NULL);
        List<String> prods = new List<String>();
        prods.add('SHIPFRR25');
        prods.add(programRegistrationInfo.mainMemberProductCode);
        prods.add(programRegistrationInfo.mainNonMemberProductCode);
        List<String> prodList = GARP_TestFactory.createProductList(prods);
        GARP_TestFactory.createProducts(prodList, new Set<String>{}, new Set<String>{}, new Set<String>{});

        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'CBRX'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'FRR25HB:4030'});
        System.runAs(user) {
            GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
            System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            String formNameFRR25Auth = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
            GARP_TestFactory.createForm(formNameFRR25Auth);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
            GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
            GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
            System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
            System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account');
            GARP_TestFactory.assertRegistrationCreatedProgramContract(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRR25 Program');
            GARP_TestFactory.assertRegistrationCreatedCandidateRequirementExamCode(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRR25 Program', 'FRR25');
            GARP_TestFactory.assertRegistrationCreatedExamAttemptProgram(Id.valueOf(setRegistrationReturnInfo.orderId), 'FRR25');
            GARP_TestFactory.assertRegistrationOpportunityHasMainProduct(Id.valueOf(setRegistrationReturnInfo.orderId), 'FRRSM');
        }
        test.stopTest();
    }

    @isTest
    public static void testFRR25Auth() { runTestFRR25Auth(); }

    public static void runTestFRRMicro() {

        GARP_TestFactory.createCountryCodes();

        Exam__c ex = new Exam__c(Name='FRRMC1',Exam__c='FRRMC1',Exam_Date__c=Date.Today(),MC_Course_Name__c='FRR MC1',MC_Course_Form_Key__c='form-mc1',
                                 MC_Course_Study_Materials_Product_Codes__c='FRRMC1HB,FRRMC1BP',
                                 MC_Course_Program_Record_Type__c='FRR MC1 Program',MC_Course_Program_Record_Type_API_Name__c='FRR_MC1_Program',
                                 MC_Course_Member_Product_Code__c='MC1M',MC_Course_Non_Member_Product_Code__c='MC1NM',MC_Course_Certified_Product_Code__c='MC1C',
                                 MC_Course_Retake_Product_Code__c='MC12A');
        Insert ex;

		Exam_Sites__c exmSite = new Exam_Sites__c(exam__c = ex.id);
        insert exmSite;

        // Create Team Reg Info
        Team_Registration__c teamReg = GARP_TestFactory.createTeamReg('FRRMC1',100,False,False,False);
        System.debug('!!teamReg:' + teamReg);

        test.startTest();

        // Get Reg Info
        GARP_MS_Courses.getMicroCourseRegistrationInfo('FRRMC1','123'); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getMicroCourseRegistrationSettings('FRRMC1','123');

		// Setup Products
        List<String> prodSHIP = new List<String>{'SHIPMC:SHIPMC:4040:100'};
        GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});
    	GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'FRRMC1HB:4030'});

		GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        String formNameFRRMicro = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
        GARP_TestFactory.createForm(formNameFRRMicro);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account');
        GARP_TestFactory.assertRegistrationCreatedProgramContract(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRR MC1 Program');
        GARP_TestFactory.assertRegistrationCreatedCandidateRequirementExamCode(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRR MC1 Program', 'FRRMC1');
        test.stopTest();
    }

    @isTest
    public static void testFRRMicro() { runTestFRRMicro(); }

    public static void runTestFRRMicroAuth() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;

        // Create Expired Contract
        Contract programContract = new Contract(
            Name = 'MC1',
            Status='Draft',
            AccountId = contact.AccountId,
            Opportunity__c = opp.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today().AddDays(-365),
            ContractTerm = 12,
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'FRR MC1 Program')
        );
        INSERT programContract;
        programContract.Status = 'Expired';
        UPDATE programContract;

        Exam__c ex = new Exam__c(Name='FRRMC1',Exam__c='FRRMC1',Exam_Date__c=Date.Today(),MC_Course_Name__c='FRR MC1',MC_Course_Form_Key__c='form-mc1',
                                 MC_Course_Study_Materials_Product_Codes__c='FRRMC1HB,FRRMC1BP',
                                 MC_Course_Program_Record_Type__c='FRR MC1 Program',MC_Course_Program_Record_Type_API_Name__c='FRR_MC1_Program',
                                 MC_Course_Member_Product_Code__c='MC1M',MC_Course_Non_Member_Product_Code__c='MC1NM',MC_Course_Certified_Product_Code__c='MC1C',
                                 MC_Course_Retake_Product_Code__c='MC12A');
        insert ex;
        System.debug('!!exam:' + ex);

        Exam_Sites__c exmSite = new Exam_Sites__c(exam__c = ex.id);
        insert exmSite;

        // Create Team Reg Info
        Team_Registration__c teamReg = GARP_TestFactory.createTeamReg('FRRMC1',100,False,False,False);
        System.debug('!!teamReg:' + teamReg);

        // Get Reg Info
        GARP_MS_Courses.getMicroCourseRegistrationInfo('FRRMC1','123'); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getMicroCourseRegistrationSettings('FRRMC1','123');

        // Setup Products
        List<String> prodSHIP = new List<String>{'SHIPMC:SHIPMC:4040:100'};
        GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'CBRX'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'FRRMC1HB:4030'});

        test.startTest();


        System.runAs(user) {
            String userId = UserInfo.getUserId();
            System.debug('!!userId:' + userId);

		GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            GARP_TestFactory.createForm('form');
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = new GARP_BC_Registration.verifyExistingCustomerInfo();
            verifyExistingCustomerInfo.firstName = 'GARPQA';
            verifyExistingCustomerInfo.lastName = 'TEST';
            verifyExistingCustomerInfo.email = contact.email;
            verifyExistingCustomerInfo.leadId = NULL;
            verifyExistingCustomerInfo.formKey = 'form';
            verifyExistingCustomerInfo.cta = NULL;
            verifyExistingCustomerInfo.allowMemberPublicRegistration = TRUE;
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
            System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account');
            GARP_TestFactory.assertRegistrationCreatedProgramContract(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRR MC1 Program');
            GARP_TestFactory.assertRegistrationCreatedCandidateRequirementExamCode(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRR MC1 Program', 'FRRMC1');
        }
        test.stopTest();
    }

    @isTest
    public static void testFRRMicroAuth() { runTestFRRMicroAuth(); }

    public static void runTestFFR() {

        GARP_TestFactory.createCountryCodes();

        test.startTest();

        // Get Reg Info
        GARP_MS_Courses.getFFRRegistrationInfo(null); // US-63665: FFR B2B Registration
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getFFRRegistrationSettings(null); // US-63665: FFR B2B Registration

		// Setup Products
        List<String> prodSHIP = new List<String>{'SHIPFFR:SHIPFFR:4040:100'};
        GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});
    	GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'FFRXF'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'CBRHB:4030'});

		GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        String formNameFFR = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
        GARP_TestFactory.createForm(formNameFFR);
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
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account');
        GARP_TestFactory.assertRegistrationCreatedProgramContract(Id.valueOf(setRegistrationReturnInfo.accountId), 'FBR Program');
        GARP_TestFactory.assertRegistrationCreatedCandidateRequirementExamCode(Id.valueOf(setRegistrationReturnInfo.accountId), 'FBR Program', 'FBR');
        test.stopTest();
    }

    @isTest
    public static void testFFR() { runTestFFR(); }

    public static void runTestFFRAuth() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;

        test.startTest();

        // Create Expired Contract
        Contract programContract = new Contract(
            Name = 'FBR',
            Status='Draft',
            AccountId = contact.AccountId,
            Opportunity__c = opp.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today().AddDays(-365),
            ContractTerm = 12,
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'FBR Program')
        );
        INSERT programContract;
        programContract.Status = 'Expired';
        UPDATE programContract;

        // Get Reg Info
        GARP_MS_Courses.getFFRRegistrationInfo(null); // US-63665: FFR B2B Registration
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getFFRRegistrationSettings(null); // US-63665: FFR B2B Registration

		// Setup Products
        List<String> prodSHIP = new List<String>{'SHIPFFR:SHIPFFR:4040:100'};
        GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'FFRXF'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'CBRHB:4030'});

        System.runAs(user) {
            String userId = UserInfo.getUserId();
            System.debug('!!userId:' + userId);

		GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            String formNameFFRAuth = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
            GARP_TestFactory.createForm(formNameFFRAuth);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        }
        test.stopTest();
    }

    @isTest
    public static void testFFRAuth() { runTestFFRAuth(); }

    // US-63665: FFR B2B Registration
    public static void runTestFFRTeamReg() {
        GARP_TestFactory.createCountryCodes();
        Team_Registration__c teamReg = GARP_TestFactory.createTeamReg('FFR', NULL, False, False, False);
        String teamRegCode = (teamReg != null && teamReg.Access_Code__c != null) ? teamReg.Access_Code__c : '123';
        test.startTest();
        GARP_MS_Courses.getFFRRegistrationInfo(teamRegCode);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getFFRRegistrationSettings(teamRegCode);

        List<String> prodSHIP = new List<String>{'SHIPFFR:SHIPFFR:4040:100'};
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(prodSHIP), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'FFRXF'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'CBRHB:4030'});
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        String formNameFFRTR = (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) ? programRegistrationInfo.formName : 'form';
        GARP_TestFactory.createForm(formNameFFRTR);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        getRegistrationFeesInfo.teamRegCode = teamRegCode;
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        setRegistrationInfo.teamRegInfo = regInfo.teamRegInfo;
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account.');
        test.stopTest();
    }

    @isTest
    public static void testFFRTeamReg() { runTestFFRTeamReg(); }

    public static void runTestSCR() {
        GARP_TestFactory.createCountryCodes();

        System.debug('Setup Exam!!');
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();

        System.debug('Start Test!!');
        test.startTest();

        // Get Reg Info
        GARP_MS_Courses.getSCRRegistrationInfo(NULL); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getSCRRegistrationSettings(NULL);

		// Setup Products
        List<String> regProducts = new List<String>{'SHIPSCR'};
        if (String.isNotBlank(programRegistrationInfo.studyMaterialDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.studyMaterialDiscountProductCode);
        }
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});
    	GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes, 150), new Set<String>{'SCRX','SCRBP'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'SCRH:4030'});
        ExamRegistrationTestDataFactory.setupSCRExamRegistrationDependencyObjects(programRegistrationInfo);
		GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        // Get Fees – select book so RAIH/SCRH/RAIJH branch in getRegistrationFees is hit
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        if(regInfo.studyMaterials != NULL && regInfo.studyMaterials.size() > 0) {
            getRegistrationFeesInfo.studyMaterials = regInfo.studyMaterials;
            for(GARP_BC_StudyMaterials.studyMaterial sm : getRegistrationFeesInfo.studyMaterials) {
                if(sm.isCompWithReg == False) {
                    sm.selected = True;
                    break;
                }
            }
        }
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        // Set Order
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account');
        GARP_TestFactory.assertRegistrationCreatedProgramContract(Id.valueOf(setRegistrationReturnInfo.accountId), 'SCR Program');
        GARP_TestFactory.assertRegistrationCreatedExamAttemptProgram(Id.valueOf(setRegistrationReturnInfo.orderId), 'SCR');
        test.stopTest();
    }

    @isTest
    public static void testSCR() { runTestSCR(); }

    public static void runTestSCRTeamReg() {
        GARP_TestFactory.createCountryCodes();
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();
        Team_Registration__c teamReg = GARP_TestFactory.createTeamReg('SCR', 100, False, False, False);
        String teamRegCode = (teamReg != null && teamReg.Access_Code__c != null) ? teamReg.Access_Code__c : '123';
        test.startTest();
        GARP_MS_Courses.getSCRRegistrationInfo(teamRegCode);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getSCRRegistrationSettings(teamRegCode);
        List<String> regProducts = new List<String>{'SHIPSCR'};
        if (String.isNotBlank(programRegistrationInfo.studyMaterialDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.studyMaterialDiscountProductCode);
        }
        if (String.isNotBlank(programRegistrationInfo.teamRegDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.teamRegDiscountProductCode);
        }
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        if (programRegistrationInfo.teamProductCodes != null && !programRegistrationInfo.teamProductCodes.isEmpty()) {
            GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.teamProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        }
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes, 150), new Set<String>{'SCRX','SCRBP'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'SCRH:4030'});
        ExamRegistrationTestDataFactory.setupSCRExamRegistrationDependencyObjects(programRegistrationInfo);
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success.');
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        getRegistrationFeesInfo.teamRegCode = teamRegCode;
        if(regInfo.studyMaterials != NULL && regInfo.studyMaterials.size() > 0) {
            getRegistrationFeesInfo.studyMaterials = regInfo.studyMaterials;
            for(GARP_BC_StudyMaterials.studyMaterial sm : getRegistrationFeesInfo.studyMaterials) {
                if(sm.isCompWithReg == False) {
                    sm.selected = True;
                    break;
                }
            }
        }
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        setRegistrationInfo.teamRegInfo = regInfo.teamRegInfo;
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account.');
        test.stopTest();
    }

    @isTest
    public static void testSCRTeamReg() { runTestSCRTeamReg(); }

    public static void runTestSCRAuth() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;

        // Create Expired Contract
        Contract programContract = new Contract(
            Name = 'SCR',
            Status='Draft',
            AccountId = contact.AccountId,
            Opportunity__c = opp.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today().AddDays(-365),
            ContractTerm = 12,
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'SCR Program')
        );
        INSERT programContract;
        programContract.Status = 'Expired';
        UPDATE programContract;

        System.debug('Setup Exam!!');
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();

        System.debug('Start Test!!');
        test.startTest();

        // Get Reg Info
        GARP_MS_Courses.getSCRRegistrationInfo(NULL); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getSCRRegistrationSettings(NULL);

		// Setup Products
        List<String> regProducts = new List<String>{'SHIPSCR'};
        if (String.isNotBlank(programRegistrationInfo.studyMaterialDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.studyMaterialDiscountProductCode);
        }
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes, 150), new Set<String>{'SCRX','SCRBP'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'SCRH:4030'});
        ExamRegistrationTestDataFactory.setupSCRExamRegistrationDependencyObjects(programRegistrationInfo);

        System.runAs(user) {
            String userId = UserInfo.getUserId();
            System.debug('!!userId:' + userId);

		GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            if(regInfo.studyMaterials != NULL && regInfo.studyMaterials.size() > 0) {
                getRegistrationFeesInfo.studyMaterials = regInfo.studyMaterials;
                for(GARP_BC_StudyMaterials.studyMaterial sm : getRegistrationFeesInfo.studyMaterials) {
                    if(sm.isCompWithReg == False) {
                        sm.selected = True;
                        break;
                    }
                }
            }
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        }
        test.stopTest();
    }

    @isTest
    public static void testSCRAuth() { runTestSCRAuth(); }

    public static void runTestRAIJ() {
        GARP_TestFactory.createCountryCodes();

        System.debug('Setup Exam!!');
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();

        System.debug('Start Test!!');
        test.startTest();

        // Get Reg Info
        GARP_MS_Courses.getRAIJRegistrationInfo(NULL); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getRAIJRegistrationSettings(NULL);

		// Setup Products
        List<String> regProducts = new List<String>{'SHIPRAIJ'};
        if (String.isNotBlank(programRegistrationInfo.studyMaterialDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.studyMaterialDiscountProductCode);
        }
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});
    	GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes, 150), new Set<String>{'RAIJX','RAIJBP'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'RAIJH:4030'});
        ExamRegistrationTestDataFactory.setupRAIJExamRegistrationDependencyObjects(programRegistrationInfo);

		GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        // Get Fees – select book so RAIH/SCRH/RAIJH branch in getRegistrationFees is hit
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        if(regInfo.studyMaterials != NULL && regInfo.studyMaterials.size() > 0) {
            getRegistrationFeesInfo.studyMaterials = regInfo.studyMaterials;
            for(GARP_BC_StudyMaterials.studyMaterial sm : getRegistrationFeesInfo.studyMaterials) {
                if(sm.isCompWithReg == False) {
                    sm.selected = True;
                    break;
                }
            }
        }
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        // Set Order
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account');
        GARP_TestFactory.assertRegistrationCreatedProgramContract(Id.valueOf(setRegistrationReturnInfo.accountId), 'RAIJ Program');
        GARP_TestFactory.assertRegistrationCreatedExamAttemptProgram(Id.valueOf(setRegistrationReturnInfo.orderId), 'RAIJ');
        test.stopTest();
    }

    @isTest
    public static void testRAIJ() { runTestRAIJ(); }

    public static void runTestRAIJTeamReg() {
        GARP_TestFactory.createCountryCodes();
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();
        Team_Registration__c teamReg = GARP_TestFactory.createTeamReg('RAIJ', 100, False, False, False);
        String teamRegCode = (teamReg != null && teamReg.Access_Code__c != null) ? teamReg.Access_Code__c : '123';
        test.startTest();
        GARP_MS_Courses.getRAIJRegistrationInfo(teamRegCode);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getRAIJRegistrationSettings(teamRegCode);
        List<String> regProducts = new List<String>{'SHIPRAIJ'};
        if (String.isNotBlank(programRegistrationInfo.studyMaterialDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.studyMaterialDiscountProductCode);
        }
        if (String.isNotBlank(programRegistrationInfo.teamRegDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.teamRegDiscountProductCode);
        }
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        if (programRegistrationInfo.teamProductCodes != null && !programRegistrationInfo.teamProductCodes.isEmpty()) {
            GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.teamProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        }
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes, 150), new Set<String>{'RAIJX','RAIJBP'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'RAIJH:4030'});
        ExamRegistrationTestDataFactory.setupRAIJExamRegistrationDependencyObjects(programRegistrationInfo);
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success.');
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        getRegistrationFeesInfo.teamRegCode = teamRegCode;
        if(regInfo.studyMaterials != NULL && regInfo.studyMaterials.size() > 0) {
            getRegistrationFeesInfo.studyMaterials = regInfo.studyMaterials;
            for(GARP_BC_StudyMaterials.studyMaterial sm : getRegistrationFeesInfo.studyMaterials) {
                if(sm.isCompWithReg == False) {
                    sm.selected = True;
                    break;
                }
            }
        }
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        setRegistrationInfo.teamRegInfo = regInfo.teamRegInfo;
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account.');
        test.stopTest();
    }

    @isTest
    public static void testRAIJTeamReg() { runTestRAIJTeamReg(); }

    public static void runTestRAIJAuth() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;

        // Create Expired Contract
        Contract programContract = new Contract(
            Name = 'RAIJ',
            Status='Draft',
            AccountId = contact.AccountId,
            Opportunity__c = opp.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today().AddDays(-365),
            ContractTerm = 12,
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'RAIJ Program')
        );
        INSERT programContract;
        programContract.Status = 'Expired';
        UPDATE programContract;

        System.debug('Setup Exam!!');
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();

        System.debug('Start Test!!');
        test.startTest();

        // Get Reg Info
        GARP_MS_Courses.getRAIJRegistrationInfo(NULL); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getRAIJRegistrationSettings(NULL);

		// Setup Products
        List<String> regProducts = new List<String>{'SHIPRAIJ'};
        if (String.isNotBlank(programRegistrationInfo.studyMaterialDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.studyMaterialDiscountProductCode);
        }
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes, 150), new Set<String>{'RAIJX','RAIJBP'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'RAIJH:4030'});
        ExamRegistrationTestDataFactory.setupRAIJExamRegistrationDependencyObjects(programRegistrationInfo);

        System.runAs(user) {
            String userId = UserInfo.getUserId();
            System.debug('!!userId:' + userId);

		GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            if(regInfo.studyMaterials != NULL && regInfo.studyMaterials.size() > 0) {
                getRegistrationFeesInfo.studyMaterials = regInfo.studyMaterials;
                for(GARP_BC_StudyMaterials.studyMaterial sm : getRegistrationFeesInfo.studyMaterials) {
                    if(sm.isCompWithReg == False) {
                        sm.selected = True;
                        break;
                    }
                }
            }
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        }
        test.stopTest();
    }

    @isTest
    public static void testRAIJAuth() { runTestRAIJAuth(); }

    public static void runTestRiskAI() {
        GARP_TestFactory.createCountryCodes();

        System.debug('Setup Exam!!');
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();

        System.debug('Start Test!!');
        test.startTest();

        // Get Reg Info
        GARP_MS_Courses.getRiskAIRegistrationInfo(NULL); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getRiskAIRegistrationSettings(NULL);

		// Setup Products and collect maps
        List<String> regProducts = new List<String>{'SHIPRAI'};
        if (String.isNotBlank(programRegistrationInfo.studyMaterialDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.studyMaterialDiscountProductCode);
        }
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Map<String, Product2> mapAux = GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Map<String, Product2> mapMain = GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Product2 rainmeProduct = mapMain.get('RAINME');
        ExamRegistrationTestDataFactory.setupRiskAIExamRegistrationDependencyObjects(rainmeProduct, programRegistrationInfo);
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes, 150), new Set<String>{'RAIBP'}, new Set<String>{}, setStudyMats);

		GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        // Get Fees – select book so RAIH/SCRH/RAIJH branch in getRegistrationFees is hit
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        if(regInfo.studyMaterials != NULL && regInfo.studyMaterials.size() > 0) {
            getRegistrationFeesInfo.studyMaterials = regInfo.studyMaterials;
            for(GARP_BC_StudyMaterials.studyMaterial sm : getRegistrationFeesInfo.studyMaterials) {
                if(sm.isCompWithReg == False) {
                    sm.selected = True;
                    break;
                }
            }
        }
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        // Set Order
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account');
        GARP_TestFactory.assertRegistrationCreatedProgramContract(Id.valueOf(setRegistrationReturnInfo.accountId), 'Risk AI Program');
        GARP_TestFactory.assertRegistrationCreatedExamAttemptProgram(Id.valueOf(setRegistrationReturnInfo.orderId), 'RiskAI');
        test.stopTest();
    }

    @isTest
    public static void testRiskAI() { runTestRiskAI(); }

    public static void runTestRiskAITeamReg() {
        GARP_TestFactory.createCountryCodes();
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();
        Team_Registration__c teamReg = GARP_TestFactory.createTeamReg('Risk & AI', 100, False, False, False);
        String teamRegCode = (teamReg != null && teamReg.Access_Code__c != null) ? teamReg.Access_Code__c : '123';
        test.startTest();
        GARP_MS_Courses.getRiskAIRegistrationInfo(teamRegCode);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getRiskAIRegistrationSettings(teamRegCode);
        List<String> regProducts = new List<String>{'SHIPRAI'};
        if (String.isNotBlank(programRegistrationInfo.studyMaterialDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.studyMaterialDiscountProductCode);
        }
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Map<String, Product2> mapMain = GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Product2 rainmeProduct = mapMain.get('RAINME');
        ExamRegistrationTestDataFactory.setupRiskAIExamRegistrationDependencyObjects(rainmeProduct, programRegistrationInfo);
        if (programRegistrationInfo.teamProductCodes != null && !programRegistrationInfo.teamProductCodes.isEmpty()) {
            GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.teamProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        }
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes, 150), new Set<String>{'RAIBP'}, new Set<String>{}, setStudyMats);
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success.');
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
        GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
        System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
        getRegistrationFeesInfo.teamRegCode = teamRegCode;
        if(regInfo.studyMaterials != NULL && regInfo.studyMaterials.size() > 0) {
            getRegistrationFeesInfo.studyMaterials = regInfo.studyMaterials;
            for(GARP_BC_StudyMaterials.studyMaterial sm : getRegistrationFeesInfo.studyMaterials) {
                if(sm.isCompWithReg == False) {
                    sm.selected = True;
                    break;
                }
            }
        }
        GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
        System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_TestFactory.setupSetRegistrationInfo(verifyExistingCustomerReturnInfo, programRegistrationInfo, getRegistrationFeesInfo, regFees);
        setRegistrationInfo.teamRegInfo = regInfo.teamRegInfo;
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = GARP_BC_Registration.setRegistration(setRegistrationInfo);
        System.assertEquals('Success', setRegistrationReturnInfo.status, 'setRegistration should return Success. message: ' + setRegistrationReturnInfo.message);
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account.');
        test.stopTest();
    }

    @isTest
    public static void testRiskAITeamReg() { runTestRiskAITeamReg(); }

    public static void runTestRiskAIAuth() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;

        // Create Expired Contract
        Contract programContract = new Contract(
            Name = 'Risk AI',
            Status='Draft',
            AccountId = contact.AccountId,
            Opportunity__c = opp.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today().AddDays(-365),
            ContractTerm = 12,
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'Risk AI Program')
        );
        INSERT programContract;
        programContract.Status = 'Expired';
        UPDATE programContract;

        System.debug('Setup Exam!!');
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();

        System.debug('Start Test!!');
        test.startTest();

        // Get Reg Info
        GARP_MS_Courses.getRiskAIRegistrationInfo(NULL); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getRiskAIRegistrationSettings(NULL);

		// Setup Products and collect maps
        List<String> regProducts = new List<String>{'SHIPRAI'};
        if (String.isNotBlank(programRegistrationInfo.studyMaterialDiscountProductCode)) {
            regProducts.add(programRegistrationInfo.studyMaterialDiscountProductCode);
        }
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(regProducts), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Map<String, Product2> mapMain = GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Product2 rainmeProduct = mapMain.get('RAINME');
        ExamRegistrationTestDataFactory.setupRiskAIExamRegistrationDependencyObjects(rainmeProduct, programRegistrationInfo);
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes, 150), new Set<String>{'RAIBP'}, new Set<String>{}, setStudyMats);

        System.runAs(user) {
            String userId = UserInfo.getUserId();
            System.debug('!!userId:' + userId);

		GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
            GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = GARP_TestFactory.setupVerifyExistingCustomerInfo(programRegistrationInfo);
            GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
            System.assertEquals('Success', verifyExistingCustomerReturnInfo.status, 'verifyExistingCustomer should return Success. message: ' + verifyExistingCustomerReturnInfo.message);
            GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_TestFactory.setupGetFeesInfo('Stripe', False, regInfo);
            if(regInfo.studyMaterials != NULL && regInfo.studyMaterials.size() > 0) {
                getRegistrationFeesInfo.studyMaterials = regInfo.studyMaterials;
                for(GARP_BC_StudyMaterials.studyMaterial sm : getRegistrationFeesInfo.studyMaterials) {
                    if(sm.isCompWithReg == False) {
                        sm.selected = True;
                        break;
                    }
                }
            }
            GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
            System.assertEquals('Success', regFees.status, 'getRegistrationFees should return Success. message: ' + regFees.message);
        }
        test.stopTest();
    }

    @isTest
    public static void testRiskAIAuth() { runTestRiskAIAuth(); }
}