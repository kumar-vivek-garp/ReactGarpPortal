@isTest
public class GARP_StudyMaterials_test {

    /** GL code used by GARP_TestFactory.createProductList (must match for PBE map lookup). */
    private static final String STUDYMAT_GL_CODE = '4040';

    /**
     * For each program (FRR, FRM, SCR, RiskAI, RAIJ): creates a Content__c, a Folder__c, a Content_Folders__c
     * junction (Content__c + Folder__c), and an Exam_Group__c with that program's study-materials folder set.
     * Uses programToProductCode so content-linked products use the same ProductCode:GL_Code as the PBE map
     * built by getStudyMaterials (from getPriceBooksEntries), avoiding "Product not found".
     */
    private static void setupStudyMaterialsContentAndExamGroups(Map<String, String> programToProductCode) {
        List<String> programs = new List<String>{ 'FRR', 'FRM', 'SCR', 'RiskAI', 'RAIJ' };
        List<String> folderPrograms = new List<String>{ 'FRR', 'FRM', 'SCR', 'RiskAI' };
        Map<String, Folder__c> folderByProgram = new Map<String, Folder__c>();
        Map<String, Content__c> contentByProgram = new Map<String, Content__c>();

        for (String program : folderPrograms) {
            Folder__c folder = new Folder__c(Name = program + ' StudyMats');
            folderByProgram.put(program, folder);
        }
        insert folderByProgram.values();
        System.debug('setupStudyMaterialsContentAndExamGroups: inserted folderByProgram=' + folderByProgram);

        List<Content__c> contents = new List<Content__c>();
        for (String program : programs) {
            contents.add(new Content__c(
                Name = program + ' Book',
                Content_Name__c = program + ' Book',
                Description__c = 'Test',
                Story__c = 'Test',
                Image__c = 'http://test',
                Status__c = 'Active',
                Display_Sort_Order__c = 1
            ));
        }
        insert contents;
        System.debug('setupStudyMaterialsContentAndExamGroups: inserted contents=' + contents);
        for (Integer i = 0; i < programs.size(); i++) {
            contentByProgram.put(programs[i], contents[i]);
        }
        System.debug('setupStudyMaterialsContentAndExamGroups: contentByProgram map=' + contentByProgram);

        List<Content_Folders__c> contentFolders = new List<Content_Folders__c>();
        for (String program : programs) {
            Id folderId = program == 'RAIJ' ? folderByProgram.get('RiskAI').Id : folderByProgram.get(program).Id;
            contentFolders.add(new Content_Folders__c(
                Content__c = contentByProgram.get(program).Id,
                Folder__c = folderId,
                Name = program + ' Book'
            ));
        }
        insert contentFolders;
        System.debug('setupStudyMaterialsContentAndExamGroups: inserted contentFolders=' + contentFolders);

        List<Product2> products = new List<Product2>();
        for (String program : programs) {
            String productCode = programToProductCode != null && programToProductCode.containsKey(program)
                ? programToProductCode.get(program)
                : (program + 'H');
            products.add(new Product2(
                Name = program + ' Book',
                IsActive = true,
                Company__c = 'GARP',
                GL_Code__c = STUDYMAT_GL_CODE,
                ProductCode = productCode,
                Product_ID__c = '26' + productCode,
                Content__c = contentByProgram.get(program).Id,
                Invoice_Name__c = program + ' Study Material'
            ));
        }
        insert products;

        Date regStart = Date.today().addDays(4);
        Date earlyEnd = Date.today().addDays(1);
        Date standardEnd = Date.today().addDays(9);
        Date lateEnd = Date.today().addDays(10);

        Id rtICBRR = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'ICBRR');
        Id rtFRMERP = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRM/ERP');
        Id rtSCR = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'SCR');
        Id rtRiskAI = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'RiskAI');
        Id rtRAIJ = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'RAIJ');

        List<Exam_Group__c> examGroups = new List<Exam_Group__c>();
        examGroups.add(new Exam_Group__c(RecordTypeId = rtICBRR, Active__c = true, FRR_Study_Materials_Folder__c = folderByProgram.get('FRR').Id, Registration_Start_Date__c = regStart, Last_Date_For_Early_Registration__c = earlyEnd, Last_Date_For_Standard_Registration__c = standardEnd, Last_Date_For_Late_Registration__c = lateEnd));
        examGroups.add(new Exam_Group__c(RecordTypeId = rtFRMERP, Active__c = true, FRM_Study_Materials_Folder__c = folderByProgram.get('FRM').Id, Registration_Start_Date__c = regStart, Last_Date_For_Early_Registration__c = earlyEnd, Last_Date_For_Standard_Registration__c = standardEnd, Last_Date_For_Late_Registration__c = lateEnd));
        examGroups.add(new Exam_Group__c(RecordTypeId = rtSCR, Active__c = true, SCR_Study_Materials_Folder__c = folderByProgram.get('SCR').Id, Registration_Start_Date__c = regStart, Last_Date_For_Early_Registration__c = earlyEnd, Last_Date_For_Standard_Registration__c = standardEnd, Last_Date_For_Late_Registration__c = lateEnd));
        examGroups.add(new Exam_Group__c(RecordTypeId = rtRiskAI, Active__c = true, RiskAI_Study_Materials_Folder__c = folderByProgram.get('RiskAI').Id, Registration_Start_Date__c = regStart, Last_Date_For_Early_Registration__c = earlyEnd, Last_Date_For_Standard_Registration__c = standardEnd, Last_Date_For_Late_Registration__c = lateEnd));
        examGroups.add(new Exam_Group__c(RecordTypeId = rtRAIJ, Active__c = true, RiskAI_Study_Materials_Folder__c = folderByProgram.get('RiskAI').Id, Registration_Start_Date__c = regStart, Last_Date_For_Early_Registration__c = earlyEnd, Last_Date_For_Standard_Registration__c = standardEnd, Last_Date_For_Late_Registration__c = lateEnd));
        insert examGroups;
    }

    /**
     * getStudyMaterialListing: portal study materials listing for an authenticated member.
     * Builds the same productCodes list getStudyMaterials uses so the PBE map contains entries for
     * every content-linked product; content products use matching ProductCode and GL 4040 so lookup succeeds.
     */
    public static void runTestGetStudyMaterialListing() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;

        GARP_MS_Exams.getFRMRegistrationInfo(NULL);
        GARP_BC_Registration.programRegistrationInfo frmSettings = GARP_BC_Exams.getFRMRegistrationSettings(NULL);
        GARP_BC_Registration.programRegistrationInfo scrSettings = GARP_BC_Courses.getSCRRegistrationSettings(NULL);
        GARP_BC_Registration.programRegistrationInfo raiSettings = GARP_BC_Courses.getRiskAIRegistrationSettings(NULL);
        GARP_BC_Registration.programRegistrationInfo raijSettings = GARP_BC_Courses.getRAIJRegistrationSettings(NULL);
        GARP_BC_Registration.programRegistrationInfo frrSettings = GARP_BC_Courses.getFRRRegistrationSettings(NULL);
        GARP_BC_Registration.programRegistrationInfo frr25Settings = GARP_BC_Courses.getFRR25RegistrationSettings(null);

        List<String> allStudyMatCodes = new List<String>();
        allStudyMatCodes.addAll(frmSettings.studyMatProductCodes);
        allStudyMatCodes.addAll(scrSettings.studyMatProductCodes);
        allStudyMatCodes.addAll(raiSettings.studyMatProductCodes);
        allStudyMatCodes.addAll(raijSettings.studyMatProductCodes);
        allStudyMatCodes.addAll(frrSettings.studyMatProductCodes);
        allStudyMatCodes.addAll(frr25Settings.studyMatProductCodes);
        Set<String> studyMats = new Set<String>(allStudyMatCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(allStudyMatCodes), new Set<String>{}, new Set<String>{}, studyMats);

        Map<String, String> programToProductCode = new Map<String, String>();
        programToProductCode.put('FRM', frmSettings.studyMatProductCodes.isEmpty() ? 'FRM1H' : frmSettings.studyMatProductCodes[0]);
        programToProductCode.put('SCR', scrSettings.studyMatProductCodes.isEmpty() ? 'SCRH' : scrSettings.studyMatProductCodes[0]);
        programToProductCode.put('RiskAI', raiSettings.studyMatProductCodes.isEmpty() ? 'RAIH' : raiSettings.studyMatProductCodes[0]);
        programToProductCode.put('RAIJ', raijSettings.studyMatProductCodes.isEmpty() ? 'RAIJH' : raijSettings.studyMatProductCodes[0]);
        programToProductCode.put('FRR', frrSettings.studyMatProductCodes.isEmpty() ? 'CBRX' : frrSettings.studyMatProductCodes[0]);
        setupStudyMaterialsContentAndExamGroups(programToProductCode);

        List<eBook_Key__c> eBookList = GARP_TestFactory.createEbookKey(opp);
        insert eBookList;

        Remote_Sites__c setting = new Remote_Sites__c(Name = 'Mobius', Site_URL__c = 'http://preprod.garp.org:8081');
        insert setting;

        test.startTest();
        GARP_BC_MemberPortal.returnGetStudyMaterialListing result;
        System.runAs(user) {
            result = GARP_MS_MemberPortal.getStudyMaterialListing();
        }
        test.stopTest();

        System.assertNotEquals(null, result, 'getStudyMaterialListing should return a result');
        System.assertEquals(200, result.statusCode, 'getStudyMaterialListing should return statusCode 200. statusMessage: ' + result.statusMessage);
        System.assertEquals('Success', result.statusMessage, 'getStudyMaterialListing should return Success');
    }

    @isTest
    public static void testGetStudyMaterialListing() {
        runTestGetStudyMaterialListing();
    }

    /**
     * Study materials in context of FRM registration flow (runs full FRM reg test).
     */
    public static void runTestStudyMaterialsFRMReg() {
        GARP_Exams_test.runTestFRM();
    }

    @isTest
    public static void testStudyMaterialsFRMReg() {
        runTestStudyMaterialsFRMReg();
    }

    /**
     * Errata form: get form info, submit errata, attach file. Guided by GARP_MemberPortal_Test.unitTest_StudyMats.
     */
    public static void runTestErrata() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;

        test.startTest();
        System.runAs(user) {
            GARP_MS_MemberPortal.getErrataFormInfo('frm');

            GARP_BC_StudyMaterials.errataFormSubmissionInfo efs = new GARP_BC_StudyMaterials.errataFormSubmissionInfo();
            efs.programType = 'frm';
            efs.studyMaterial = '2024 FRM Exam Part I';
            efs.book = 'Foundations of Risk Management';
            efs.pageNumber = '12';
            efs.errorDescription = 'error';
            GARP_BC_MemberPortal.returnSubmitErrataFormInfo retsf = GARP_MS_MemberPortal.submitErrataForm(efs);

            GARP_BC_MemberPortal.returnAttachFileErrataSubmission retatt = GARP_BC_MemberPortal.attachFileErrataSubmission(contact.Id, retsf.errataId, 'fileName', 'filetext', NULL);
        }
        test.stopTest();
    }

    @isTest
    public static void testErrata() {
        runTestErrata();
    }

    /**
     * StudyMatPortalCalls: create individual user, runAs, then call all Member Portal methods that use GARP_BC_StudyMaterials.
     */
    public static void runTestStudyMatPortalCalls() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        User user = setup.user;
        Contact contact = setup.contact;
        Opportunity opp = setup.opp;

        GARP_MS_Exams.getFRMRegistrationInfo(NULL);
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Exams.getFRMRegistrationSettings(NULL);
        Set<String> studyMats = new Set<String>();
        studyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{}, new Set<String>{}, studyMats);

        List<Folder__c> lstFolder = [SELECT Id FROM Folder__c LIMIT 1];
        if (!lstFolder.isEmpty()) {
            GARP_TestFactory.createExamGroupForStudyMats(lstFolder[0].Id);
        }

        List<eBook_Key__c> eBookList = GARP_TestFactory.createEbookKey(opp);
        insert eBookList;

        Remote_Sites__c setting = new Remote_Sites__c(Name = 'Mobius', Site_URL__c = 'http://preprod.garp.org:8081');
        insert setting;

        test.startTest();
        System.runAs(user) {
            GARP_MS_MemberPortal.getStudyMaterialListing();
            GARP_MS_MemberPortal.getMyEBooksInfo();
            GARP_MS_MemberPortal.getEBookAccessURL('123');

            List<GARP_BC_StudyMaterials.eBookItem> eBookItems = new List<GARP_BC_StudyMaterials.eBookItem>();
            GARP_BC_StudyMaterials.eBookItem ei = new GARP_BC_StudyMaterials.eBookItem();
            ei.title = 'Book';
            ei.vendorId = 123;
            eBookItems.add(ei);
            GARP_MS_MemberPortal.getEBookAccessURLs(eBookItems);

            GARP_MS_MemberPortal.getErrataFormInfo('frm');

            GARP_BC_StudyMaterials.errataFormSubmissionInfo efs = new GARP_BC_StudyMaterials.errataFormSubmissionInfo();
            efs.programType = 'frm';
            efs.studyMaterial = '2024 FRM Exam Part I';
            efs.book = 'Foundations of Risk Management';
            efs.pageNumber = '12';
            efs.errorDescription = 'error';
            GARP_BC_MemberPortal.returnSubmitErrataFormInfo retsf = GARP_MS_MemberPortal.submitErrataForm(efs);
            if (retsf != null && retsf.errataId != null) {
                GARP_MS_MemberPortal.attachFileErrataSubmission(retsf.errataId, 'fileName', 'filetext', NULL);
            }

            List<Opportunity> opplist = new List<Opportunity>{ opp };
            List<GARP_BC_StudyMaterials.eBook> myEBooks = GARP_BC_StudyMaterials.getMyEBooks(contact.AccountId, opplist);
            GARP_BC_MemberPortal.getMostRecentEBook(contact, 'RiskAI', myEBooks);
        }
        test.stopTest();
    }

    @isTest
    public static void testStudyMatPortalCalls() {
        runTestStudyMatPortalCalls();
    }

    /**
     * Call uncovered GARP_BC_StudyMaterials methods one-off to improve coverage.
     */
    public static void runTestUncoveredStudyMaterialsMethods() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember();
        Contact contact = setup.contact;

        Content__c content = new Content__c(
            Name = 'TestBook',
            Content_Name__c = 'book',
            Description__c = 'd',
            Story__c = 's',
            Image__c = 'http://test',
            Status__c = 'Active'
        );
        insert content;

        test.startTest();

        GARP_BC_StudyMaterials.getBenchPrepSSOLink(contact.Id, 'FRM', 'I');
        GARP_BC_StudyMaterials.getBenchPrepSSOLink(contact.Id, 'SCR', null);

        new GARP_BC_StudyMaterials.studyMaterial(content);

        GARP_BC_StudyMaterials.hasBenchPrepAccess(null);
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.AccountId, 'FRM Program');
        Exam_Attempt__c examAttempt = GARP_TestFactory.createExamAttempt(setup.opp, frmContract, 'frm');
        Exam_Attempt__c attemptWithRelations = [
            SELECT Id, Deferral_Status__c, Allow_Scheduling_Override__c, RPT_Exam_Program__c, RPT_Exam_Part__c, Opportunity__c, Opportunity__r.StageName,
                   Exam_Administration__c, Exam_Administration__r.Exam_Scheduling_Start_Date__c, Exam_Administration__r.Exam_Scheduling_End_Date__c,
                   Exam_Part__c, Exam_Part__r.Exam_Date__c, Exam_Part__r.Exam_End_Date__c,
                   Integration_Data_Exam_Scheduled_Date__c
            FROM Exam_Attempt__c WHERE Id = :examAttempt.Id
        ];
        System.assertEquals(true, GARP_BC_StudyMaterials.hasBenchPrepAccess(attemptWithRelations), 'hasBenchPrepAccess should return true for attempt with scheduling open');
        System.assertEquals(100, GARP_BC_StudyMaterials.getBookRegistrantPrice(attemptWithRelations), 'getBookRegistrantPrice(Exam_Attempt__c) should return 100 for valid attempt');
        GARP_BC_StudyMaterials.getBookRegistrantPrice('scr', 100);
        GARP_BC_StudyMaterials.getBookRegistrantPrice('riskai', 200);
        GARP_BC_StudyMaterials.getBookRegistrantPrice('raij', 100);
        GARP_BC_StudyMaterials.getBookRegistrantPrice('frm', 50);  // return currentPrice branch
        GARP_BC_StudyMaterials.getBookRegistrantPrice(null);

        GARP_BC_StudyMaterials.getMyElectronicStudyMaterials(contact.AccountId, new List<Opportunity>{ setup.opp });
        GARP_BC_StudyMaterials.getErrataPicklistOption('FRM');
        GARP_BC_StudyMaterials.getErrataPicklistOption('RISKAI');   // covers RAI remap
        List<GARP_BC_StudyMaterials.eBook> emptyEBooks = new List<GARP_BC_StudyMaterials.eBook>();
        GARP_BC_StudyMaterials.getMostRecentEBook(contact, 'FRM', 'I', emptyEBooks);
        GARP_BC_StudyMaterials.getMostRecentEBook(contact, 'FRM', null, emptyEBooks);

        try {
            GARP_BC_StudyMaterials.getEBookAccessURL(contact, '123');
        } catch (Exception e) {
            // Mobius not available in test; method was still invoked for coverage
        }
        GARP_BC_StudyMaterials.getAccountRecordId(contact.Id);

        test.stopTest();
    }

    /** Counter for unique ProductCode in createPbeWithContent. */
    private static Integer pbeContentCounter = 0;

    /**
     * Creates Content__c + Product2 + PricebookEntry (no optional dates/inventory). Delegates to full overload.
     */
    private static PricebookEntry createPbeWithContent(String contentName, Boolean linkContent) {
        return createPbeWithContent(contentName, linkContent, null, null, null, null);
    }

    /**
     * Overload with optional Product2/Content fields to cover studyMaterial(PBE) branches: pre-order coming soon (276-278),
     * Content Start_Date past/future (279-288), else available (289-291), out of stock (294-298).
     * Pass null for any unused option.
     */
    private static PricebookEntry createPbeWithContent(String contentName, Boolean linkContent, Date preOrderDate, DateTime contentStartDate, String leadGenUrl, Integer inventory) {
        pbeContentCounter++;
        String uniqueCode = 'PBEC' + String.valueOf(pbeContentCounter);
        Content__c c = new Content__c(
            Name = contentName,
            Content_Name__c = contentName,
            Description__c = 'd',
            Story__c = 's',
            Image__c = 'http://test',
            Status__c = 'Active'
        );
        if (contentStartDate != null) {
            c.Start_Date__c = contentStartDate;
        }
        if (leadGenUrl != null) {
            c.Lead_Gen_URL__c = leadGenUrl;
        }
        insert c;
        Product2 p = new Product2(
            Name = contentName,
            IsActive = true,
            ProductCode = uniqueCode,
            GL_Code__c = STUDYMAT_GL_CODE,
            Product_ID__c = '26' + uniqueCode,
            Is_Comped_Registration__c = false,
            Is_Shippable__c = false,
            Electronic_Delivery__c = true
        );
        if (linkContent) {
            p.Content__c = c.Id;
        }
        if (preOrderDate != null) {
            p.Pre_Order_Date__c = preOrderDate;
            p.Pre_Order_Shipping_Date__c = preOrderDate.addDays(7);
        }
        if (inventory != null) {
            p.Inventory__c = inventory;
        }
        insert p;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = p.Id,
            UnitPrice = 99,
            IsActive = true
        );
        insert pbe;
        return [SELECT Id, Product2Id, Product2.Id, Product2.ProductCode, Product2.GL_Code__c, Product2.Product_ID__c,
                Product2.Is_Comped_Registration__c, Product2.Is_Shippable__c, Product2.Electronic_Delivery__c,
                Product2.Content__c, Product2.Pre_Order_Date__c, Product2.Pre_Order_Shipping_Date__c, Product2.Inventory__c,
                Product2.Content__r.Content_Name__c, Product2.Content__r.Story__c, Product2.Content__r.Description__c,
                Product2.Content__r.Image__c, Product2.Content__r.Start_Date__c, Product2.Content__r.Lead_Gen_URL__c,
                Product2.Content__r.Third_Party_URL__c, UnitPrice
                FROM PricebookEntry WHERE Id = :pbe.Id];
    }

    /**
     * Covers studyMaterial(PricebookEntry) constructor branches: materialType eBook/Book/GARP Learning,
     * showInRegStudyMatSelection = false (practice exam), and Content__r = null (line 206).
     */
    public static void runTestStudyMaterialPricebookEntryBranches() {
        GARP_TestFactory.createCountryCodes();
        GARP_TestFactory.setupIndividualMember();

        test.startTest();

        PricebookEntry pbeEbook = createPbeWithContent('FRM eBook 2024', true);
        new GARP_BC_StudyMaterials.studyMaterial(pbeEbook);  // materialType = 'eBook' (line 190)

        PricebookEntry pbeBook = createPbeWithContent('Hard Book', true);
        new GARP_BC_StudyMaterials.studyMaterial(pbeBook);   // materialType = 'Book' (line 192)

        PricebookEntry pbeGarp = createPbeWithContent('GARP Learning', true);
        new GARP_BC_StudyMaterials.studyMaterial(pbeGarp);   // materialType = 'GARP Learning' (line 194)

        PricebookEntry pbePractice = createPbeWithContent('FRM Practice Exam', true);
        new GARP_BC_StudyMaterials.studyMaterial(pbePractice);  // showInRegStudyMatSelection = false (line 203)

        PricebookEntry pbeNoContent = createPbeWithContent('NoContent', false);
        new GARP_BC_StudyMaterials.studyMaterial(pbeNoContent);  // Content__r = null (line 206)

        // Pre-order date in future -> isComingSoon, comingSoonDate, leadGenURL (276-278)
        PricebookEntry pbePreOrderSoon = createPbeWithContent('PreOrder Soon', true, Date.today().addDays(10), null, 'http://leadgen', null);
        new GARP_BC_StudyMaterials.studyMaterial(pbePreOrderSoon);

        // Content Start_Date in past -> isAvailable, canPurchase (280-282)
        PricebookEntry pbeStartPast = createPbeWithContent('Start Past', true, null, DateTime.now().addDays(-1), null, null);
        new GARP_BC_StudyMaterials.studyMaterial(pbeStartPast);

        // Content Start_Date in future -> isComingSoon (284-287)
        PricebookEntry pbeStartFuture = createPbeWithContent('Start Future', true, null, DateTime.now().addDays(5), null, null);
        new GARP_BC_StudyMaterials.studyMaterial(pbeStartFuture);

        // Out of stock -> isOutOfStock, isAvailable=false, canPurchase=false (296-298)
        PricebookEntry pbeOutOfStock = createPbeWithContent('Out Of Stock', true, null, null, null, 0);
        new GARP_BC_StudyMaterials.studyMaterial(pbeOutOfStock);

        test.stopTest();
    }

    @isTest
    public static void testStudyMaterialPricebookEntryBranches() {
        runTestStudyMaterialPricebookEntryBranches();
    }

    @isTest
    public static void testUncoveredStudyMaterialsMethods() {
        runTestUncoveredStudyMaterialsMethods();
    }
}