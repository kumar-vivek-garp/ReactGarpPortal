@isTest
public class ExamRegistrationTestDataFactory {
    
    @TestVisible private static Id pricebookId = null;
    
    @TestVisible private static void setupCaptcha(){
        
        CAPTCHA_Configuration__c captchaConfigurations = new CAPTCHA_Configuration__c(
            Name = 'Exam Registration',
            Enabled__c = true,
            Submission_Speed_Threshold__c = 0
        );
        
        INSERT captchaConfigurations;
        
    }
    
    
    //CHARGENT
    @TestVisible private static void setupChargent(){
        ChargentBase__Gateway__c chargentGateway = new ChargentBase__Gateway__c(
            Name = 'Test',
            //ChargentBase__Merchant_ID__c = 'dasghjtru548709-4',
            ChargentBase__Active__c = true,
            ChargentBase__Available_Payment_Methods__c = 'Credit Card'
        );
        
        INSERT chargentGateway;
        INSERT new UpdateIds__c(Name = 'GARP', Record_Id__c = chargentGateway.Id);
        
    }
    
    @TestVisible private static void setupAccountOwner(){
        
        //ACCOUNT OWNER
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX'); 
        
    }
    
    @TestVisible private static void setupActivePricebook(){
        
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;
        
        pricebookId = activePricebook.Id;
        
    }
    
    @TestVisible private static void setupFeeProducts(){
        Id pbId = (pricebookId != null) ? pricebookId : Test.getStandardPricebookId();
        //FEES
        Product2 AFREE = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'AFREE', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 FRM1 = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'FRM1', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 ENC = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'ENC', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);        
        Product2 CHLF = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'CHLF', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 MEMF = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'MEMF', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 PRFEE = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'PRFEE', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 SLSTX = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'SLSTX', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 CDNTAX = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'CDNTAX', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 CHNDF = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'CHNDF', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);  
        Product2 SHIP = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'SHIP', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);        
        Product2 SAFRM1 = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'SAFRM1', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 SAFRM2 = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'SAFRM2', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 SAERP1 = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'SAERP1', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        Product2 SAERP2 = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'SAERP2', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);        
        Product2 SASCR = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'SASCR', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);        
        
        INSERT new List<Product2>{
            AFREE, 
                FRM1, 
                ENC, 
                CHLF, 
                MEMF, 
                PRFEE, 
                SLSTX, 
                CDNTAX, 
                CHNDF, 
                SHIP, 
                SAFRM1, 
                SAFRM2, 
                SAERP1, 
                SAERP2,
                SASCR
                };
                    
                    PricebookEntry AFREEPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = AFREE.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry FRM1PBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = FRM1.Id, UnitPrice = 400, IsActive = true);
        PricebookEntry ENCPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = ENC.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry CHLFPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = CHLF.Id, UnitPrice = 40, IsActive = true);
        PricebookEntry MEMFPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = MEMF.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry PRFEEPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = PRFEE.Id, UnitPrice = 50, IsActive = true);
        PricebookEntry SLSTXPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = SLSTX.Id, UnitPrice = 15.23, IsActive = true);
        PricebookEntry CDNTAXPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = CDNTAX.Id, UnitPrice = 22, IsActive = true);
        PricebookEntry CHNDFPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = CHNDF.Id, UnitPrice = 10, IsActive = true);
        PricebookEntry SHIPPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = SHIP.Id, UnitPrice = 21.34, IsActive = true);
        PricebookEntry SAFRM1PBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = SAFRM1.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry SAFRM2PBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = SAFRM2.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry SAERP1PBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = SAERP1.Id, UnitPrice = 0, IsActive = true);
        PricebookEntry SAERP2PBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = SAERP2.Id, UnitPrice = 0, IsActive = true);        
        PricebookEntry SASCRPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = SASCR.Id, UnitPrice = 0, IsActive = true);        
        
        INSERT new List<PricebookEntry>{
            AFREEPBE,
                FRM1PBE,
                ENCPBE,
                CHLFPBE,
                MEMFPBE,
                PRFEEPBE,
                SLSTXPBE,
                CDNTAXPBE,
                CHNDFPBE,
                SHIPPBE,        
                SAFRM1PBE,
                SAFRM2PBE,
                SAERP1PBE,
                SAERP2PBE,
                SASCRPBE
                };
                    
                    }
    
    @TestVisible private static void setupBookProducts(){
        Id pbId = (pricebookId != null) ? pricebookId : Test.getStandardPricebookId();
        //EBOOKS
        Product2 FRM1X = new Product2(Company__c = 'GARP', Taxable__c = true, Name = 'Laptop X200', productCode = 'FRM1X', GL_Code__c = '4999', Family = 'Books', isActive = true);
        Product2 FRM2X = new Product2(Company__c = 'GARP', Taxable__c = true, Name = 'Laptop X200', productCode = 'FRM2X', GL_Code__c = '4999', Family = 'Books', isActive = true);
        Product2 ERP1X = new Product2(Company__c = 'GARP', Taxable__c = true, Name = 'Laptop X200', productCode = 'ERP1X', GL_Code__c = '4999', Family = 'Books', isActive = true);
        Product2 ERP2X = new Product2(Company__c = 'GARP', Taxable__c = true, Name = 'Laptop X200', productCode = 'ERP2X', GL_Code__c = '4999', Family = 'Books', isActive = true);
        
        Product2 SCRX = new Product2(Company__c = 'GARP', Taxable__c = true, Name = 'Laptop X200', productCode = 'SCRX', GL_Code__c = '4999', Family = 'Books', isActive = true);
        
        
        //BOOKS
        Product2 FRM1H = new Product2(Company__c = 'GARP', Weight__c = 1.0, Taxable__c = true, Name = 'Laptop X200', productCode = 'FRM1H', GL_Code__c = '4999', Family = 'Books', isActive = true);
        
        INSERT new List<Product2>{ FRM1X, FRM2X, ERP1X, ERP2X, SCRX, FRM1H };
            
            //EBOOKS
            PricebookEntry FRM1XPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = FRM1X.Id, UnitPrice = 10000, IsActive = true);        
        PricebookEntry FRM2XPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = FRM2X.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry ERP1XPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = ERP1X.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry ERP2XPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = ERP2X.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry SCRXPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = SCRX.Id, UnitPrice = 10000, IsActive = true);
        
        //BOOKS
        PricebookEntry FRM1HPBE = new PricebookEntry(Pricebook2Id = pbId, Product2Id = FRM1H.Id, UnitPrice = 10000, IsActive = true);     
        
        INSERT new List<PricebookEntry>{ FRM1XPBE, FRM2XPBE, ERP1XPBE, ERP2XPBE, FRM1HPBE };
            
            }
    
    /**
     * No-arg overload for backward compatibility: creates FRM Part 1/2 products and PBEs, then calls the 2-arg version.
     */
    @TestVisible private static void setupExamRegistrationDependencyObjects(){
        Id pbId = (pricebookId != null) ? pricebookId : Test.getStandardPricebookId();
        Product2 frmPart1 = new Product2(Name = 'FRM PART 1 STANDARD REGISTRATION', Company__c = 'GARP', ProductCode = 'FRM1S', GL_Code__c = '4999', Family = 'Exams', isActive = true);
        INSERT frmPart1;
        INSERT new PricebookEntry(Pricebook2Id = pbId, Product2Id = frmPart1.Id, UnitPrice = 350, UseStandardPrice = false, IsActive = true);
        Product2 frmPart2 = new Product2(Name = 'FRM PART 2 STANDARD REGISTRATION', Company__c = 'GARP', ProductCode = 'FRM2S', GL_Code__c = '4999', Family = 'Exams', isActive = true);
        INSERT frmPart2;
        INSERT new PricebookEntry(Pricebook2Id = pbId, Product2Id = frmPart2.Id, UnitPrice = 350, UseStandardPrice = false, IsActive = true);
        setupExamRegistrationDependencyObjects(frmPart1, frmPart2);
    }

    /**
     * Sets up FRM exam dependency objects (sites, exam group, admin, exam parts, windows, exam rates).
     * When programRegistrationInfo is provided and has formName, creates Form__c so Form Data can be created.
     */
    @TestVisible private static void setupExamRegistrationDependencyObjects(Product2 frmPart1Product, Product2 frmPart2Product, GARP_BC_Registration.programRegistrationInfo programRegistrationInfo){
        if (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) {
            insert new Form__c(Name = programRegistrationInfo.formName, Form_Name__c = programRegistrationInfo.formName);
        }
        setupExamRegistrationDependencyObjects(frmPart1Product, frmPart2Product);
    }

    /**
     * Sets up FRM exam dependency objects (sites, exam group, admin, exam parts, windows, exam rates).
     * Uses the passed Product2 records for FRM Part 1 and Part 2 exam rates (caller creates products via createProducts).
     */
    @TestVisible private static void setupExamRegistrationDependencyObjects(Product2 frmPart1Product, Product2 frmPart2Product){
        
        //SITES AND EXAMS
        Site__c chinaHongKong = new Site__c(
            name = 'China, Hong Kong',
            Display_Address__c = 'China, Hong Kong',
            Active__c = true,
            Non_selectable__c = false,
            Is_OSTA_Information_Required__c = false,
            AM_Exam_Max_Capacity__c = 10,
            PM_Exam_Max_Capacity__c = 10
        );
        
        Site__c chinaNanjing = new Site__c(
            name = 'China, Nanjing',
            Display_Address__c = 'China, Nanjing',
            Active__c = true,
            Non_selectable__c = false,
            Is_OSTA_Information_Required__c = true,
            AM_Exam_Max_Capacity__c = 10,
            PM_Exam_Max_Capacity__c = 10
        );        
        
        INSERT new List<Site__c>{chinaHongKong, chinaNanjing};
        Id pbId = (pricebookId != null) ? pricebookId : Test.getStandardPricebookId();
            
            Exam_Group__c examGroup = new Exam_Group__c(
                Active__c = TRUE,
                RecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRM/ERP'),
                Exam_Date__c = System.today().addDays(60),
                Registration_Start_Date__c = System.today().addDays(-10),
                Last_Date_For_Early_Registration__c = System.today().addDays(10),
                Last_Date_For_Standard_Registration__c = System.today().addDays(20),
                Last_Date_For_Late_Registration__c = System.today().addDays(30)
            );
        INSERT examGroup;
        
        Exam_Administration__c examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = examGroup.id;
        //examAdmin.Exam_Date__c = System.today().addDays(45);
        examAdmin.Exam_Type__c = 'FRM';
        examAdmin.Month__c = 'May';
        examAdmin.Year__c = System.today().Year();
        examAdmin.Registration_Start_Date__c = System.today().addDays(-10);
        examAdmin.Registration_End_Date__c = System.today().addDays(30);
        examAdmin.Exam_Scheduling_Start_Date__c = System.today().addDays(-10);
        examAdmin.Exam_Scheduling_End_Date__c = System.today().addDays(30);
        insert examAdmin;
        
        System.Debug('setupExamRegistrationDependencyObjects:examAdmin' + examAdmin);
        
        Exam_Registration_Window__c examRegistrationWindow = new Exam_Registration_Window__c(
            Exam_Group__c = examGroup.Id,
            Exam_Administration__c = examAdmin.Id,
            Type__c = 'Early',
            Exam_Registration_Window_Open__c = system.today().addDays(-30), 
            Exam_Registration_Window_Close__c = system.today().addDays(30)        
        );
        INSERT examRegistrationWindow;
        
        //FRM
        Exam__c frmExamPart1 = new Exam__c(
            Exam_Group__c = examGroup.Id,
            Exam_Date__c = System.today().addDays(60),
            Exam__c = 'FRM Part 1',
            Name = 'FRM Exam Part I'
        );
        INSERT frmExamPart1;
        
        Id frmPart1ProductId = (frmPart1Product != null) ? frmPart1Product.Id : null;
        
        // Team Reg product (same shape as standard, for Team_Product__c / Team_Product_Member__c lookups)
        Product2 frmExamPart1TeamRegProduct = new Product2(
            Name = 'FRM PART 1 TEAM REG',
            Company__c = 'GARP',
            ProductCode = 'FRM1TE',
            GL_Code__c = '4999',
            Family = 'Exams',
            isActive = true
        );
        INSERT frmExamPart1TeamRegProduct;
        PricebookEntry frmExamPart1TeamRegPBE = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = frmExamPart1TeamRegProduct.Id,
            UnitPrice = 350,
            UseStandardPrice = FALSE,
            IsActive = true
        );
        INSERT frmExamPart1TeamRegPBE;
        
        Exam_Part__c examPart = new Exam_Part__c();
        examPart.Exam__c = frmExamPart1.id;
        examPart.Exam_Administration__c = examAdmin.id;
        examPart.Exam_Date__c = system.today();
        examPart.Delivery_Method__c = 'CBT';
        insert examPart;
        
        Exam_Rate__c frmExamPart1ExamRate = new Exam_Rate__c(
            Exam_Registration_Window__c = examRegistrationWindow.Id,
            Exam__c = frmExamPart1.Id,
            Product__c = frmPart1ProductId,
            Team_Product__c = frmExamPart1TeamRegProduct.Id,
            Team_Product_Member__c = frmExamPart1TeamRegProduct.Id,
            Exam_Administration__c = examAdmin.id,
            Exam_Part__c = examPart.Id
        );
        INSERT frmExamPart1ExamRate;
        
        Exam_Sites__c frmExamPart1SiteChinaHongKong = new Exam_Sites__c(
            Site__c = chinaHongKong.Id, 
            Country__c = 'Hong Kong',
            Exam__c = frmExamPart1.Id,
            Exam_Part__c = examPart.id
        );     
        
        Exam_Sites__c frmExamPart1SiteChinaNanjing = new Exam_Sites__c(
            Site__c = chinaNanjing.Id, 
            Country__c = 'China',
            Exam__c = frmExamPart1.Id,
            Exam_Part__c = examPart.id
        );        
        
        //INSERT new List<Exam_Sites__c>{frmExamPart1SiteChinaHongKong, frmExamPart1SiteChinaNanjing};
        
        Exam__c frmExamPart2 = new Exam__c(
            Exam_Group__c = examGroup.Id,
            Exam_Date__c = System.today().addDays(60),
            Exam__c = 'FRM Part 2',
            Name = 'FRM Exam Part II'
        );
        INSERT frmExamPart2;
        
        Id frmPart2ProductId = (frmPart2Product != null) ? frmPart2Product.Id : null;
        
        Exam_Part__c examPart2 = new Exam_Part__c();
        examPart2.Exam__c = frmExamPart2.id;
        examPart2.Exam_Administration__c = examAdmin.id;
        examPart2.Exam_Date__c = system.today();
        examPart2.Delivery_Method__c = 'CBT';
        insert examPart2;
        
        Exam_Rate__c frmExamPart2ExamRate = new Exam_Rate__c(
            Exam_Registration_Window__c = examRegistrationWindow.Id,
            Exam__c = frmExamPart2.Id,
            Product__c = frmPart2ProductId,
            Team_Product__c = frmExamPart1TeamRegProduct.Id,
            Team_Product_Member__c = frmExamPart1TeamRegProduct.Id,
            Exam_Administration__c = examAdmin.id,
            Exam_Part__c = examPart2.Id
        );
        INSERT frmExamPart2ExamRate;
        
        Exam_Sites__c frmExamPart2SiteChinaHongKong = new Exam_Sites__c(
            Site__c = chinaHongKong.Id, 
            Country__c = 'Hong Kong',
            Exam__c = frmExamPart2.Id,
            Exam_Part__c = examPart2.id
            
        );    
        
        Exam_Sites__c frmExamPart2SiteChinaNanjing = new Exam_Sites__c(
            Site__c = chinaNanjing.Id, 
            Country__c = 'China',
            Exam__c = frmExamPart2.Id,
            Exam_Part__c = examPart2.id
        );        
        
        //INSERT new List<Exam_Sites__c>{frmExamPart2SiteChinaHongKong, frmExamPart2SiteChinaNanjing};
        
        INSERT new List<Exam_Sites__c>{frmExamPart1SiteChinaHongKong, frmExamPart1SiteChinaNanjing, frmExamPart2SiteChinaHongKong, frmExamPart2SiteChinaNanjing};

    }
    
    
    @TestVisible private static void setupSCRExamRegistrationDependencyObjects(GARP_BC_Registration.programRegistrationInfo programRegistrationInfo){
        if (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) {
            insert new Form__c(Name = programRegistrationInfo.formName, Form_Name__c = programRegistrationInfo.formName);
        }
        Id pbId = (pricebookId != null) ? pricebookId : Test.getStandardPricebookId();
        //SITES AND EXAMS
        Site__c chinaHongKong = new Site__c(
            name = 'China, Hong Kong',
            Display_Address__c = 'China, Hong Kong',
            Active__c = true,
            Non_selectable__c = false,
            Is_OSTA_Information_Required__c = false,
            AM_Exam_Max_Capacity__c = 10,
            PM_Exam_Max_Capacity__c = 10
        );
        
        Site__c chinaNanjing = new Site__c(
            name = 'China, Nanjing',
            Display_Address__c = 'China, Nanjing',
            Active__c = true,
            Non_selectable__c = false,
            Is_OSTA_Information_Required__c = true,
            AM_Exam_Max_Capacity__c = 10,
            PM_Exam_Max_Capacity__c = 10
        );        
        
        
        // SCR
        Exam_Group__c examGroupSCR = new Exam_Group__c(
            SCR_Active__c = TRUE,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'SCR'),
            Exam_Date__c = System.today().addDays(60),
            Registration_Start_Date__c = System.today().addDays(-10),
            Last_Date_For_Early_Registration__c = System.today().addDays(10),
            Last_Date_For_Standard_Registration__c = System.today().addDays(20),
            Last_Date_For_Late_Registration__c = System.today().addDays(30)
        );
        INSERT examGroupSCR;
        
        Exam_Administration__c examAdminSCR = new Exam_Administration__c();
        examAdminSCR.Exam_Group__c = examGroupSCR.id;
        examAdminSCR.Exam_Date__c = system.today();
        examAdminSCR.Exam_Type__c = 'SCR';
        examAdminSCR.Registration_Start_Date__c = system.today().addDays(-30);
        examAdminSCR.Registration_End_Date__c = system.today().addDays(30);
        insert examAdminSCR;
        
        Exam__c scrExam = new Exam__c(
            Exam_Group__c = examGroupSCR.Id,
            Exam_Date__c = System.today().addDays(60),
            Exam__c = 'SCR',
            Name = 'SCR'
        );
        INSERT scrExam;
        
        Exam_Part__c examPartSCR = new Exam_Part__c();
        examPartSCR.Exam__c = scrExam.id;
        examPartSCR.Exam_Administration__c = examAdminSCR.id;
        examPartSCR.Exam_Date__c = system.today();
        examPartSCR.Delivery_Method__c = 'CBT';
        insert examPartSCR;
        
        Exam_Registration_Window__c examRegistrationWindowSCR = new Exam_Registration_Window__c(
            Exam_Group__c = examGroupSCR.Id,
            Type__c = 'Early',
            Exam_Registration_Window_Open__c = system.today().addDays(-30), 
            Exam_Registration_Window_Close__c = system.today().addDays(30)        
        );
        INSERT examRegistrationWindowSCR;
        
        Product2 scrExamStandardProduct = new Product2(
            Name = 'SCR STANDARD REGISTRATION',
            Company__c = 'GARP', 
            ProductCode = 'SCRNMS',
            GL_Code__c = '4005',
            Family = 'Exams',
            isActive = true
        );        
        INSERT scrExamStandardProduct; 
        
        PricebookEntry scrExamStandardPricebookEntry = new PricebookEntry(
            Pricebook2Id = pbId, 
            Product2Id = scrExamStandardProduct.Id, 
            UnitPrice = 350, 
            UseStandardPrice = FALSE,
            IsActive = true
        );
        INSERT scrExamStandardPricebookEntry;
        
        // Team Reg products for SCR: SCRTNME (team non-member early), SCRTME (team member early)
        Product2 scrExamTeamNonMemberProduct = new Product2(
            Name = 'SCR TEAM NON-MEMBER EARLY',
            Company__c = 'GARP',
            ProductCode = 'SCRTNME',
            GL_Code__c = '4999',
            Family = 'Exams',
            isActive = true
        );
        INSERT scrExamTeamNonMemberProduct;
        PricebookEntry scrExamTeamNonMemberPBE = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = scrExamTeamNonMemberProduct.Id,
            UnitPrice = 350,
            UseStandardPrice = FALSE,
            IsActive = true
        );
        INSERT scrExamTeamNonMemberPBE;
        Product2 scrExamTeamMemberProduct = new Product2(
            Name = 'SCR TEAM MEMBER EARLY',
            Company__c = 'GARP',
            ProductCode = 'SCRTME',
            GL_Code__c = '4999',
            Family = 'Exams',
            isActive = true
        );
        INSERT scrExamTeamMemberProduct;
        PricebookEntry scrExamTeamMemberPBE = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = scrExamTeamMemberProduct.Id,
            UnitPrice = 350,
            UseStandardPrice = FALSE,
            IsActive = true
        );
        INSERT scrExamTeamMemberPBE;
        
        Exam_Rate__c scrExamPartExamRate = new Exam_Rate__c(
            Exam_Registration_Window__c = examRegistrationWindowSCR.Id,
            Exam__c = scrExam.Id,
            Product__c = scrExamStandardProduct.Id,
            Team_Product__c = scrExamTeamNonMemberProduct.Id,
            Team_Product_Member__c = scrExamTeamMemberProduct.Id,
            Exam_Administration__c = examAdminSCR.id,
            Exam_Part__c = examPartSCR.Id,
            Rate_Type__c = 'Non-Member'
        );
        INSERT scrExamPartExamRate;
        
        Exam_Rate__c scrExamPartExamRateMember = new Exam_Rate__c(
            Exam_Registration_Window__c = examRegistrationWindowSCR.Id,
            Exam__c = scrExam.Id,
            Product__c = scrExamStandardProduct.Id,
            Team_Product__c = scrExamTeamNonMemberProduct.Id,
            Team_Product_Member__c = scrExamTeamMemberProduct.Id,
            Exam_Administration__c = examAdminSCR.id,
            Exam_Part__c = examPartSCR.Id,
            Rate_Type__c = 'Member'
        );
        INSERT scrExamPartExamRateMember;
        
        Exam_Sites__c scrExamPartSiteChinaHongKong = new Exam_Sites__c(
            Site__c = chinaHongKong.Id, 
            Exam__c = scrExam.Id,
            Exam_Part__c = examPartSCR.id
        );     
        
        Exam_Sites__c scrExamPartSiteChinaNanjing = new Exam_Sites__c(
            Site__c = chinaNanjing.Id, 
            Exam__c = scrExam.Id,
            Exam_Part__c = examPartSCR.id
        );                
        
        
        INSERT new List<Exam_Sites__c>{scrExamPartSiteChinaHongKong, scrExamPartSiteChinaNanjing};
            
            List<Team_Registration_Products__c> prodCodes = new List<Team_Registration_Products__c>();
        Team_Registration_Products__c prod1 = new Team_Registration_Products__c();
        prod1.Name = 'SCRNMS';
        prod1.Product_Code__c = 'SCRNMS';
        prod1.GL_Code__c = '4005';
        prod1.Replacement_Product_Id__c = scrExamStandardProduct.id;
        prod1.Replacement_Product_Price_Id__c = scrExamStandardPricebookEntry.id;
        prodCodes.add(prod1);
        insert prodCodes;
        
        
    }
    
    @TestVisible private static void setupRAIJExamRegistrationDependencyObjects(GARP_BC_Registration.programRegistrationInfo programRegistrationInfo){
        if (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) {
            insert new Form__c(Name = programRegistrationInfo.formName, Form_Name__c = programRegistrationInfo.formName);
        }
        Id pbId = (pricebookId != null) ? pricebookId : Test.getStandardPricebookId();
        //SITES AND EXAMS
        Site__c chinaHongKong = new Site__c(
            name = 'China, Hong Kong',
            Display_Address__c = 'China, Hong Kong',
            Active__c = true,
            Non_selectable__c = false,
            Is_OSTA_Information_Required__c = false,
            AM_Exam_Max_Capacity__c = 10,
            PM_Exam_Max_Capacity__c = 10
        );
        
        Site__c chinaNanjing = new Site__c(
            name = 'China, Nanjing',
            Display_Address__c = 'China, Nanjing',
            Active__c = true,
            Non_selectable__c = false,
            Is_OSTA_Information_Required__c = true,
            AM_Exam_Max_Capacity__c = 10,
            PM_Exam_Max_Capacity__c = 10
        );        
        
        INSERT new List<Site__c>{chinaHongKong, chinaNanjing};
        
        // RAIJ
        Exam_Group__c examGroupRAIJ = new Exam_Group__c(
            SCR_Active__c = TRUE,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'RAIJ'),
            Exam_Date__c = System.today().addDays(60),
            Registration_Start_Date__c = System.today().addDays(-10),
            Last_Date_For_Early_Registration__c = System.today().addDays(10),
            Last_Date_For_Standard_Registration__c = System.today().addDays(20),
            Last_Date_For_Late_Registration__c = System.today().addDays(30)
        );
        INSERT examGroupRAIJ;
        
        Exam_Administration__c examAdminRAIJ = new Exam_Administration__c();
        examAdminRAIJ.Exam_Group__c = examGroupRAIJ.id;
        examAdminRAIJ.Exam_Date__c = system.today();
        examAdminRAIJ.Exam_Type__c = 'RAIJ';
        examAdminRAIJ.Registration_Start_Date__c = system.today().addDays(-30);
        examAdminRAIJ.Registration_End_Date__c = system.today().addDays(30);
        insert examAdminRAIJ;
        
        Exam__c raijExam = new Exam__c(
            Exam_Group__c = examGroupRAIJ.Id,
            Exam_Date__c = System.today().addDays(60),
            Exam__c = 'RAIJ',
            Name = 'RAIJ'
        );
        INSERT raijExam;
        
        Exam_Part__c examPartRAIJ = new Exam_Part__c();
        examPartRAIJ.Exam__c = raijExam.id;
        examPartRAIJ.Exam_Administration__c = examAdminRAIJ.id;
        examPartRAIJ.Exam_Date__c = system.today();
        examPartRAIJ.Delivery_Method__c = 'CBT';
        insert examPartRAIJ;
        
        Exam_Registration_Window__c examRegistrationWindowRAIJ = new Exam_Registration_Window__c(
            Exam_Group__c = examGroupRAIJ.Id,
            Type__c = 'Early',
            Exam_Registration_Window_Open__c = system.today().addDays(-30), 
            Exam_Registration_Window_Close__c = system.today().addDays(30)        
        );
        INSERT examRegistrationWindowRAIJ;
        
        Product2 raijExamStandardProduct = new Product2(
            Name = 'RAIJ STANDARD REGISTRATION',
            Company__c = 'GARP', 
            ProductCode = 'RAIJNMS',
            GL_Code__c = '4005',
            Family = 'Exams',
            isActive = true
        );        
        INSERT raijExamStandardProduct; 
        
        PricebookEntry raijExamStandardPricebookEntry = new PricebookEntry(
            Pricebook2Id = pbId, 
            Product2Id = raijExamStandardProduct.Id, 
            UnitPrice = 350, 
            UseStandardPrice = FALSE,
            IsActive = true
        );
        INSERT raijExamStandardPricebookEntry;
        
        // Team Reg products for RAIJ: RAIJTNME (team non-member early), RAIJTME (team member early)
        Product2 raijExamTeamNonMemberProduct = new Product2(
            Name = 'RAIJ TEAM NON-MEMBER EARLY',
            Company__c = 'GARP',
            ProductCode = 'RAIJTNME',
            GL_Code__c = '4999',
            Family = 'Exams',
            isActive = true
        );
        INSERT raijExamTeamNonMemberProduct;
        PricebookEntry raijExamTeamNonMemberPBE = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = raijExamTeamNonMemberProduct.Id,
            UnitPrice = 350,
            UseStandardPrice = FALSE,
            IsActive = true
        );
        INSERT raijExamTeamNonMemberPBE;
        Product2 raijExamTeamMemberProduct = new Product2(
            Name = 'RAIJ TEAM MEMBER EARLY',
            Company__c = 'GARP',
            ProductCode = 'RAIJTME',
            GL_Code__c = '4999',
            Family = 'Exams',
            isActive = true
        );
        INSERT raijExamTeamMemberProduct;
        PricebookEntry raijExamTeamMemberPBE = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = raijExamTeamMemberProduct.Id,
            UnitPrice = 350,
            UseStandardPrice = FALSE,
            IsActive = true
        );
        INSERT raijExamTeamMemberPBE;
        
        Exam_Rate__c raijExamPartExamRate = new Exam_Rate__c(
            Exam_Registration_Window__c = examRegistrationWindowRAIJ.Id,
            Exam__c = raijExam.Id,
            Product__c = raijExamStandardProduct.Id,
            Team_Product__c = raijExamTeamNonMemberProduct.Id,
            Team_Product_Member__c = raijExamTeamMemberProduct.Id,
            Exam_Administration__c = examAdminRAIJ.id,
            Exam_Part__c = examPartRAIJ.Id,
            Rate_Type__c = 'Non-Member'
        );
        INSERT raijExamPartExamRate;
        
        Exam_Rate__c raijExamPartExamRateMember = new Exam_Rate__c(
            Exam_Registration_Window__c = examRegistrationWindowRAIJ.Id,
            Exam__c = raijExam.Id,
            Product__c = raijExamStandardProduct.Id,
            Team_Product__c = raijExamTeamNonMemberProduct.Id,
            Team_Product_Member__c = raijExamTeamMemberProduct.Id,
            Exam_Administration__c = examAdminRAIJ.id,
            Exam_Part__c = examPartRAIJ.Id,
            Rate_Type__c = 'Member'
        );
        INSERT raijExamPartExamRateMember;
        
        Exam_Sites__c raijExamPartSiteChinaHongKong = new Exam_Sites__c(
            Site__c = chinaHongKong.Id, 
            Exam__c = raijExam.Id,
            Exam_Part__c = examPartRAIJ.id
        );     
        
        Exam_Sites__c raijExamPartSiteChinaNanjing = new Exam_Sites__c(
            Site__c = chinaNanjing.Id, 
            Exam__c = raijExam.Id,
            Exam_Part__c = examPartRAIJ.id
        );                
        
        
        INSERT new List<Exam_Sites__c>{raijExamPartSiteChinaHongKong, raijExamPartSiteChinaNanjing};
            
        List<Team_Registration_Products__c> prodCodes = new List<Team_Registration_Products__c>();
        Team_Registration_Products__c prod1 = new Team_Registration_Products__c();
        prod1.Name = 'RAIJNMS';
        prod1.Product_Code__c = 'RAIJNMS';
        prod1.GL_Code__c = '4005';
        prod1.Replacement_Product_Id__c = raijExamStandardProduct.id;
        prod1.Replacement_Product_Price_Id__c = raijExamStandardPricebookEntry.id;
        prodCodes.add(prod1);
        insert prodCodes;
        
        
    }
    
    /**
     * Sets up Risk AI exam dependency objects (sites, exam group, admin, exam, part, window, exam rates).
     * Uses the passed Product2 for Exam_Rate__c (caller must create product and pricebook entry separately).
     */
    @TestVisible private static void setupRiskAIExamRegistrationDependencyObjects(Product2 riskAIExamProduct, GARP_BC_Registration.programRegistrationInfo programRegistrationInfo){
        if (programRegistrationInfo != null && String.isNotBlank(programRegistrationInfo.formName)) {
            insert new Form__c(Name = programRegistrationInfo.formName, Form_Name__c = programRegistrationInfo.formName);
        }
        //SITES AND EXAMS
        Site__c chinaHongKong = new Site__c(
            name = 'China, Hong Kong',
            Display_Address__c = 'China, Hong Kong',
            Active__c = true,
            Non_selectable__c = false,
            Is_OSTA_Information_Required__c = false,
            AM_Exam_Max_Capacity__c = 10,
            PM_Exam_Max_Capacity__c = 10
        );
        
        Site__c chinaNanjing = new Site__c(
            name = 'China, Nanjing',
            Display_Address__c = 'China, Nanjing',
            Active__c = true,
            Non_selectable__c = false,
            Is_OSTA_Information_Required__c = true,
            AM_Exam_Max_Capacity__c = 10,
            PM_Exam_Max_Capacity__c = 10
        );        
        
        INSERT new List<Site__c>{chinaHongKong, chinaNanjing}; 
        
    // RiskAI
        Exam_Group__c examGroupRiskAI = new Exam_Group__c(
            SCR_Active__c = TRUE,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'RiskAI'),
            Exam_Date__c = System.today().addDays(60),
            Registration_Start_Date__c = System.today().addDays(-10),
            Last_Date_For_Early_Registration__c = System.today().addDays(10),
            Last_Date_For_Standard_Registration__c = System.today().addDays(20),
            Last_Date_For_Late_Registration__c = System.today().addDays(30)
        );
        INSERT examGroupRiskAI;
        
        Exam_Administration__c examAdminRiskAI = new Exam_Administration__c();
        examAdminRiskAI.Exam_Group__c = examGroupRiskAI.id;
        examAdminRiskAI.Exam_Date__c = system.today();
        examAdminRiskAI.Exam_Type__c = 'RiskAI';
        examAdminRiskAI.Registration_Start_Date__c = System.today().addDays(-10);
        examAdminRiskAI.Registration_End_Date__c = System.today().addDays(10);
        insert examAdminRiskAI;

        Exam__c RiskAIExam = new Exam__c(
            Exam_Group__c = examGroupRiskAI.Id,
            Exam_Date__c = System.today().addDays(60),
            Exam__c = 'RiskAI',
            Name = 'RiskAI'
        );
        INSERT RiskAIExam;
        
        Exam_Part__c examPartRiskAI = new Exam_Part__c();
        examPartRiskAI.Exam__c = RiskAIExam.id;
        examPartRiskAI.Exam_Administration__c = examAdminRiskAI.id;
        examPartRiskAI.Exam_Date__c = system.today();
        examPartRiskAI.Delivery_Method__c = 'CBT';
        insert examPartRiskAI;
        
        Exam_Registration_Window__c examRegistrationWindowRiskAI = new Exam_Registration_Window__c(
            Exam_Group__c = examGroupRiskAI.Id,
            Exam_Administration__c = examAdminRiskAI.Id,
            Type__c = 'Early',
            Exam_Registration_Window_Open__c = system.today().addDays(-30), 
            Exam_Registration_Window_Close__c = system.today().addDays(30)        
        );
        INSERT examRegistrationWindowRiskAI;
        
        Id riskAIProductId = (riskAIExamProduct != null) ? riskAIExamProduct.Id : null;
        
        // Team Reg products for Risk AI: RAITNME (team non-member early), RAITME (team member early)
        Product2 riskAIExamTeamNonMemberProduct = new Product2(
            Name = 'RISK AI TEAM NON-MEMBER EARLY',
            Company__c = 'GARP',
            ProductCode = 'RAITNME',
            GL_Code__c = '4999',
            Family = 'Exams',
            isActive = true
        );
        INSERT riskAIExamTeamNonMemberProduct;
        Product2 riskAIExamTeamMemberProduct = new Product2(
            Name = 'RISK AI TEAM MEMBER EARLY',
            Company__c = 'GARP',
            ProductCode = 'RAITME',
            GL_Code__c = '4999',
            Family = 'Exams',
            isActive = true
        );
        INSERT riskAIExamTeamMemberProduct;
        Id riskAIPbId = (pricebookId != null) ? pricebookId : Test.getStandardPricebookId();
        PricebookEntry riskAIExamTeamNonMemberPBE = new PricebookEntry(
            Pricebook2Id = riskAIPbId,
            Product2Id = riskAIExamTeamNonMemberProduct.Id,
            UnitPrice = 350,
            UseStandardPrice = FALSE,
            IsActive = true
        );
        INSERT riskAIExamTeamNonMemberPBE;
        PricebookEntry riskAIExamTeamMemberPBE = new PricebookEntry(
            Pricebook2Id = riskAIPbId,
            Product2Id = riskAIExamTeamMemberProduct.Id,
            UnitPrice = 350,
            UseStandardPrice = FALSE,
            IsActive = true
        );
        INSERT riskAIExamTeamMemberPBE;
          
        Exam_Rate__c RiskAIExamPartExamRate = new Exam_Rate__c(
            Exam_Registration_Window__c = examRegistrationWindowRiskAI.Id,
            Exam__c = RiskAIExam.Id,
            Product__c = riskAIProductId,
            Team_Product__c = riskAIExamTeamNonMemberProduct.Id,
            Team_Product_Member__c = riskAIExamTeamMemberProduct.Id,
            Exam_Administration__c = examAdminRiskAI.id,
            Exam_Part__c = examPartRiskAI.Id,
            Rate_Type__c = 'Non-Member'
        );
        INSERT RiskAIExamPartExamRate;
        
        Exam_Rate__c RiskAIExamPartExamRateMember = new Exam_Rate__c(
            Exam_Registration_Window__c = examRegistrationWindowRiskAI.Id,
            Exam__c = RiskAIExam.Id,
            Product__c = riskAIProductId,
            Team_Product__c = riskAIExamTeamNonMemberProduct.Id,
            Team_Product_Member__c = riskAIExamTeamMemberProduct.Id,
            Exam_Administration__c = examAdminRiskAI.id,
            Exam_Part__c = examPartRiskAI.Id,
            Rate_Type__c = 'Member'
        );
        INSERT RiskAIExamPartExamRateMember;
        
        Exam_Sites__c RiskAIExamPartSiteChinaHongKong = new Exam_Sites__c(
            Site__c = chinaHongKong.Id, 
            Exam__c = RiskAIExam.Id,
            Exam_Part__c = examPartRiskAI.id
        );     
        
        Exam_Sites__c RiskAIExamPartSiteChinaNanjing = new Exam_Sites__c(
            Site__c = chinaNanjing.Id, 
            Exam__c = RiskAIExam.Id,
            Exam_Part__c = examPartRiskAI.id
        );                
                
        INSERT new List<Exam_Sites__c>{RiskAIExamPartSiteChinaHongKong, RiskAIExamPartSiteChinaNanjing};

    }
    
    @TestVisible private static User createAffiliateContact(){
        
        Account account = new Account();
        account.Name = 'TEST';
        account.OwnerId = [SELECT Id, Record_id__c FROM updateids__c WHERE name = 'User' LIMIT 1].Record_id__c;
        account.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Account', 'Individual');
        INSERT account;
        
        Opportunity opportunity = new Opportunity(
            Name = 'Affiliate Membership',
            AccountId = account.Id,
            Eligible_for_Membership_Extension__c = TRUE,
            CloseDate = Date.today(),
            StageName = 'New Lead',
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity', 'Automated')
        );
        
        INSERT opportunity;
        
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE ProductCode = 'AFREE' LIMIT 1];
        
        OpportunityLineItem affiliateMembershipOpportunityOli = new OpportunityLineItem( 
            OpportunityId       = opportunity.Id,                          
            PricebookEntryId    = pbe.Id,
            Product2Id          = pbe.Product2Id,
            UnitPrice           = 0,
            Quantity            = 1,
            Description         = 'Affiliate Membership'
        );
        
        INSERT affiliateMembershipOpportunityOli;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.Email = 'test.user.1234@garpqa.com';
        contact.FirstName = 'TEST';
        contact.LastName = 'TEST';
        contact.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contact', 'Member');
        INSERT contact;
        
        Contract membershipContract = new Contract(
            Name = 'Affiliate Membership',
            AccountId = account.Id,
            Opportunity__c = opportunity.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today(),
            ContractTerm = 12,
            Membership_Type__c = 'Affiliate',
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership')
        );
        
        INSERT membershipContract;
        
        opportunity.StageName = 'Closed';
        
        UPDATE opportunity;
        
        List<User> users =  [
            SELECT Id, ContactId, AccountId, Contact.GARP_Member_ID__c
            FROM User 
            WHERE ContactId = :contact.Id LIMIT 1
        ];
        
        System.debug(users);
        
        if(users.isEmpty()){
            return null;
        }else{
            return users[0];
        }
        
    }
    
}