@isTest
public class GARP_Exams_test {

    @isTest
    public static void testMS(){
        sfdcAppRemoter ctrl = new sfdcAppRemoter();
        GARP_MS_Exams gmsexams = new GARP_MS_Exams(ctrl);
    }
    
    public static void runTestFRM() {
        GARP_TestFactory.createCountryCodes();
        System.debug('Setup Exam!!');
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();
        System.debug('Start Test!!');
        test.startTest();
        GARP_MS_Exams.getFRMRegistrationInfo(NULL);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Exams.getFRMRegistrationSettings(NULL);
        List<String> prodSpecial = new List<String>{'SHIPFRM:SHIPFRM:4040:100','FRM1:FRM1:4010:100'};
        GARP_TestFactory.createProducts(prodSpecial, new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.feesProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Map<String, Product2> mapMain = GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        ExamRegistrationTestDataFactory.setupExamRegistrationDependencyObjects(mapMain.get('FRM1S'), mapMain.get('FRM2S'), programRegistrationInfo);
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'FRM1X'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'FRM1H:4030'});
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
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
        GARP_TestFactory.assertRegistrationCreatedProgramContract(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRM Program');
        GARP_TestFactory.assertRegistrationCreatedCandidateRequirementExamCode(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRM Program', 'FRM Part I');
        test.stopTest();
    }

    @isTest
    public static void testFRM() { runTestFRM(); }

    public static void runTestFRMTeamReg() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.createUnmatchedBusinessAccount();
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();
        Team_Registration__c teamReg = GARP_TestFactory.createTeamReg('FRM I', 100, False, False, False);
        String teamRegCode = (teamReg != null && teamReg.Access_Code__c != null) ? teamReg.Access_Code__c : '123';
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Exams.getFRMRegistrationSettings(teamRegCode);
        List<String> prodSpecial = new List<String>{'SHIPFRM:SHIPFRM:4040:100','FRM1:FRM1:4010:100'};
        GARP_TestFactory.createProducts(prodSpecial, new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.feesProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Map<String, Product2> mapMain = GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        ExamRegistrationTestDataFactory.setupExamRegistrationDependencyObjects(mapMain.get('FRM1S'), mapMain.get('FRM2S'), programRegistrationInfo);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.teamProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'FRM1X'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'FRM1H:4030'});
        test.startTest();
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
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
        System.assertNotEquals(null, setRegistrationReturnInfo.accountId, 'Registration should return account');
        GARP_TestFactory.assertRegistrationCreatedProgramContract(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRM Program');
        GARP_TestFactory.assertRegistrationCreatedCandidateRequirementExamCode(Id.valueOf(setRegistrationReturnInfo.accountId), 'FRM Program', 'FRM Part I');
        System.assertNotEquals(null, regInfo.teamRegInfo, 'Team reg info should be set');
        System.assertNotEquals(null, regInfo.teamRegInfo.teamRegId, 'Team reg deal item Id should be set');
        List<Opportunity> opps = [SELECT Id, B2B_Deal_Item__c FROM Opportunity WHERE Id = :setRegistrationReturnInfo.orderId];
        System.assert(!opps.isEmpty(), 'Opportunity should exist');
        System.assertEquals(Id.valueOf(regInfo.teamRegInfo.teamRegId), opps[0].B2B_Deal_Item__c, 'Opportunity.B2B_Deal_Item__c should point to the B2B Deal Item from team reg');
        test.stopTest();
    }

    @isTest
    public static void testFRMTeamReg() { runTestFRMTeamReg(); }

    public static void runTestFRMAuth() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;
        Contract programContract = new Contract(
            Name = 'FRM',
            Status='Draft',
            AccountId = contact.AccountId,
            Opportunity__c = opp.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today().AddDays(-365),
            ContractTerm = 12,
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program')
        );
        INSERT programContract;
        programContract.Status = 'Expired';
        UPDATE programContract;
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();
        GARP_MS_Exams.getFRMRegistrationInfo(NULL);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Exams.getFRMRegistrationSettings(NULL);
        List<String> prodSHIP = new List<String>{'SHIPFRM:SHIPFRM:4040:100'};
        GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.feesProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Map<String, Product2> mapMain = GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainProductCodes), new Set<String>{}, new Set<String>{}, new Set<String>{});
        ExamRegistrationTestDataFactory.setupExamRegistrationDependencyObjects(mapMain.get('FRM1S'), mapMain.get('FRM2S'), programRegistrationInfo);
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'FRM1X'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'FRM1H:4030'});
        test.startTest();
        System.runAs(user) {
            GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
            System.assertEquals('Success', regInfo.status, 'getRegistrationInfo should return Success. statusMessage: ' + regInfo.statusMessage);
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
    public static void testFRMAuth() { runTestFRMAuth(); }    

    // Other Tests
    
    @isTest
    public static void testOtherMethods() { 
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Contact contact = GARP_TestFactory.createMember('GARPQA.TEST@garpqa.com', False);
        test.startTest();
        Member_Notification__c memberNotification = new Member_Notification__c(
            Name = 'Notify',
            Subject__c = 'Notify',
            Show_In_Portal__c = TRUE,
            Expire_Date__c = System.Today().AddDays(30),
            Type__c = 'Exam',
            Status__c = 'Sent'
        );
        insert memberNotification;
        Member_Notification_Recipient__c memRecpt = new Member_Notification_Recipient__c(
            Name = 'MemRecpt',
            Member_Notification__c = memberNotification.Id,
            Contact__c = contact.Id,
            Email__c = 'GARPQA.TEST@garpqa.com',
            GARP_ID__c = '1234',
            Sending_Status__c = 'Sent',
            Sent_Date_Time__c = DateTime.Now(),
            Sent_Message__c = 'msg...'
        );
        insert memRecpt;
        GARP_BC_Exams.getExamMemberNotifications(contact.Id, null);
        test.stopTest();
    }
}