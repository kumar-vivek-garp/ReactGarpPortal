public class GARP_BC_Courses {

    /** Wrapper for getExamMainProduct: status, message, and list of main products. */
    public class getExamMainProductReturnInfo {
        public String status;
        public String message;
        public List<String> messages;
        public List<PricebookEntry> products;
    }

    /** Wrapper for isEligibleCourse: isEligible and message (when not eligible). */
    public class isEligibleCourseReturnInfo {
        public Boolean isEligible;
        public String message;
    }

    // Wrapper Classes

    // Service Calls
    public static GARP_BC_Registration.programRegistrationInfo getSCRRegistrationSettings(String regCode) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'scr';
        programRegistrationInfo.mainMemberProductCode = NULL;
        programRegistrationInfo.mainNonMemberProductCode = NULL;
        programRegistrationInfo.retakeProductCode  = 'SCR2A';
        // Add discount for Oct 2024 Team Reg
        programRegistrationInfo.teamRegDiscountProductCode = 'SCRD';
        programRegistrationInfo.studyMaterialDiscountProductCode = 'SCRCANDISC';
        programRegistrationInfo.mainProductCodes = new List<String>{'SCRCME','SCRCMS','SCRME','SCRMS','SCRNME','SCRNMS'};
        programRegistrationInfo.studyMatProductCodes = new List<String>{'SCRH','SCRBP'};
        programRegistrationInfo.addOnsProductCodes  = new List<String>{'MEMI','MEMC'};
        programRegistrationInfo.teamProductCodes  = new List<String>{'SCRTCME','SCRTME','SCRTNME','SCRTR','SCRTCMS','SCRTMS','SCRTNMS','SASCRCES','SASCRMES','SASCRNMES','SASCRRES','SASCRCSS','SASCRMSS','SASCRNMSS','SASCRRSS'};

        // If regCode is closeKey
        if(!GARP_BC_MyPrograms.isLoadingResults(True, regCode)) {
            programRegistrationInfo.loadKey = regCode;
        } else {
            programRegistrationInfo.regCode = regCode;
        }

        programRegistrationInfo.formName = 'exam-registration-scr';
        programRegistrationInfo.contractRecTypeName = 'SCR Program';
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;

        // Add program information
        programRegistrationInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('scr', NULL);

        return programRegistrationInfo;
    }

    public static GARP_BC_Registration.getRegistrationInfo getSCRRegistrationInfo(String regCode) {
        return GARP_BC_Registration.getRegistrationInfo(getSCRRegistrationSettings(regCode));
    }

    public static GARP_BC_Registration.programRegistrationInfo getRAIJRegistrationSettings(String regCode) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'raij';
        programRegistrationInfo.mainMemberProductCode = NULL;
        programRegistrationInfo.mainNonMemberProductCode = NULL;
        programRegistrationInfo.retakeProductCode  = 'RAIJ2A';
        programRegistrationInfo.teamRegDiscountProductCode = 'RAIJD';
        programRegistrationInfo.studyMaterialDiscountProductCode = 'RAIJCANDISC';
        programRegistrationInfo.mainProductCodes = new List<String>{'RAIJCME','RAIJCMS','RAIJME','RAIJMS','RAIJNME','RAIJNMS'};
        programRegistrationInfo.studyMatProductCodes = new List<String>{'RAIJH','RAIJBP'};
        programRegistrationInfo.addOnsProductCodes  = new List<String>{'MEMI','MEMC'};
        programRegistrationInfo.teamProductCodes  = new List<String>{'RAIJTCME','RAIJTME','RAIJTNME','RAIJTR','RAIJTCMS','RAIJTMS','RAIJTNMS','SARAIJCES','SARAIJMES','SARAIJNMES','SARAIJRES','SARAIJCSS','SARAIJMSS','SARAIJNMSS','SARAIJRSS'};

        if(!GARP_BC_MyPrograms.isLoadingResults(True, regCode)) {
            programRegistrationInfo.loadKey = regCode;
        } else {
            programRegistrationInfo.regCode = regCode;
        }

        programRegistrationInfo.formName = 'exam-registration-raij';
        programRegistrationInfo.contractRecTypeName = 'RAIJ Program';
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;

        programRegistrationInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('raij', NULL);

        return programRegistrationInfo;
    }

    public static GARP_BC_Registration.getRegistrationInfo getRAIJRegistrationInfo(String regCode) {
        return GARP_BC_Registration.getRegistrationInfo(getRAIJRegistrationSettings(regCode));
    }

    public static GARP_BC_Registration.programRegistrationInfo getRiskAIRegistrationSettings(String regCode) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'riskai';
        programRegistrationInfo.mainMemberProductCode = NULL;
        programRegistrationInfo.mainNonMemberProductCode = NULL;
        programRegistrationInfo.retakeProductCode  = 'RAI2A';
        programRegistrationInfo.teamRegDiscountProductCode = 'RAIDISC';
        programRegistrationInfo.studyMaterialDiscountProductCode = 'RAICANDISC';
        programRegistrationInfo.mainProductCodes = new List<String>{'RAICME','RAIME','RAINME','RAICMS','RAIMS','RAINMS'};
        programRegistrationInfo.studyMatProductCodes = new List<String>{'RAIH','RAIBP'};
        programRegistrationInfo.addOnsProductCodes  = new List<String>{'MEMI','MEMC'};
        programRegistrationInfo.teamProductCodes  = new List<String>{'RAITNME','RAITME','RAIT2A','RAISNME','RAIS2A','RAISME','RAICES','RAISNMS','RAICSS'};

        // If regCode is closeKey
        if(!GARP_BC_MyPrograms.isLoadingResults(True, regCode)) {
          programRegistrationInfo.loadKey = regCode;
        } else {
          programRegistrationInfo.regCode = regCode;
        }

        programRegistrationInfo.formName = 'exam-registration-riskai';
        programRegistrationInfo.contractRecTypeName = 'Risk AI Program';
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;

        // Add program information
        programRegistrationInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('rai',NULL);

        return programRegistrationInfo;
    }

    public static GARP_BC_Registration.getRegistrationInfo getRiskAIRegistrationInfo(String regCode) {
        return GARP_BC_Registration.getRegistrationInfo(getRiskAIRegistrationSettings(regCode));
    }

    public static GARP_BC_Registration.programRegistrationInfo getFRRRegistrationSettings(String regCode) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'frr';
        programRegistrationInfo.mainMemberProductCode = 'CBR';
        programRegistrationInfo.mainNonMemberProductCode = 'CBRNM';
        programRegistrationInfo.retakeProductCode  = 'CBR2A';
        programRegistrationInfo.teamRegDiscountProductCode = 'CBRD';
        programRegistrationInfo.studyMatProductCodes = new List<String>{'CBRHB','CBRX'};
        programRegistrationInfo.addOnsProductCodes  = new List<String>{'MEMI','MEMC'};
        programRegistrationInfo.teamProductCodes  = new List<String>{'SCRTCME'};
        programRegistrationInfo.regCode = regCode;
        programRegistrationInfo.formName = 'course-icbrr';
        programRegistrationInfo.contractRecTypeName = 'ICBRR Program';
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;

        // Add program information
        programRegistrationInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('frr',NULL);

        return programRegistrationInfo;
    }

    public static GARP_BC_Registration.getRegistrationInfo getFRRRegistrationInfo(String regCode) {
        return GARP_BC_Registration.getRegistrationInfo(getFRRRegistrationSettings(regCode));
    }

    public static GARP_BC_Registration.programRegistrationInfo getFFRRegistrationSettings() {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'ffr';
        programRegistrationInfo.mainMemberProductCode = 'FCBR';
        programRegistrationInfo.mainNonMemberProductCode = 'FBRNM';
        programRegistrationInfo.retakeProductCode  = NULL;
        programRegistrationInfo.studyMatProductCodes = new List<String>{'FFRXF'};
        programRegistrationInfo.addOnsProductCodes  = new List<String>{'MEMI','MEMC'};
        programRegistrationInfo.formName = 'course-fbr';
        programRegistrationInfo.contractRecTypeName = 'FBR Program';
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;

        // Add program information
        programRegistrationInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('ffr',NULL);

        return programRegistrationInfo;
    }

    public static GARP_BC_Registration.getRegistrationInfo GetFFRRegistrationInfo() {
        return GARP_BC_Registration.getRegistrationInfo(getFFRRegistrationSettings());
    }

    public static GARP_BC_Registration.programRegistrationInfo getFRR25RegistrationSettings(String regCode) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();

        programRegistrationInfo.registrationType = 'frr25';
        programRegistrationInfo.mainMemberProductCode = 'FRRSM';
        programRegistrationInfo.mainNonMemberProductCode = 'FRRSNM';
        programRegistrationInfo.mainCertifiedProductCode = 'FRRSC';
        programRegistrationInfo.retakeProductCode  = 'FRRS2A';
        programRegistrationInfo.teamRegDiscountProductCode = 'FRRSD';
        programRegistrationInfo.studyMatProductCodes = new List<String>{'FRRSHB','FRRSBP'};
        programRegistrationInfo.addOnsProductCodes  = new List<String>{'MEMI','MEMC'};
        programRegistrationInfo.teamProductCodes  = new List<String>{};
        programRegistrationInfo.regCode = regCode;
        programRegistrationInfo.formName = 'course-frr25';
        programRegistrationInfo.contractRecTypeName = 'FRR25 Program';
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;

        // Add program information
        programRegistrationInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('frr25',NULL);

        return programRegistrationInfo;
    }

    public static GARP_BC_Registration.getRegistrationInfo getMicroCourseRegistrationInfo(String courseCode, String regCode) {
        return GARP_BC_Registration.getRegistrationInfo(getMicroCourseRegistrationSettings(courseCode, regCode));
    }

    public static GARP_BC_Registration.programRegistrationInfo getMicroCourseRegistrationSettings(String courseCode, String regCode) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'micro';
        programRegistrationInfo.mainMemberProductCode = NULL;
        programRegistrationInfo.mainNonMemberProductCode = NULL;
        programRegistrationInfo.mainCertifiedProductCode = NULL;
        programRegistrationInfo.retakeProductCode  = NULL;
        programRegistrationInfo.teamRegDiscountProductCode = 'MCD';
        programRegistrationInfo.studyMatProductCodes = new List<String>();
        programRegistrationInfo.addOnsProductCodes  = new List<String>{'MEMI','MEMC'};
        programRegistrationInfo.teamProductCodes  = new List<String>{};
        programRegistrationInfo.regCode = regCode;
        programRegistrationInfo.formName = NULL;
        programRegistrationInfo.contractRecTypeName = NULL;
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;
        programRegistrationInfo.microCourseInfo = getMicroCourseInfo(courseCode);

        if(programRegistrationInfo.microCourseInfo.name != NULL) {

            programRegistrationInfo.formName = programRegistrationInfo.microCourseInfo.formKey;
            programRegistrationInfo.contractRecTypeName = programRegistrationInfo.microCourseInfo.programType;

            programRegistrationInfo.mainMemberProductCode = programRegistrationInfo.microCourseInfo.memberProductCode;
            programRegistrationInfo.mainNonMemberProductCode = programRegistrationInfo.microCourseInfo.nonMemberProductCode;
            programRegistrationInfo.mainCertifiedProductCode = programRegistrationInfo.microCourseInfo.certifiedProductCode;
            programRegistrationInfo.retakeProductCode = programRegistrationInfo.microCourseInfo.retakeProductCode;

            if(programRegistrationInfo.microCourseInfo.studyMaterialProductCodes != NULL) {
                for(String studyMatProdCode: programRegistrationInfo.microCourseInfo.studyMaterialProductCodes){
                    programRegistrationInfo.studyMatProductCodes.add(studyMatProdCode);
                }
            }
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','formName',programRegistrationInfo.formName);
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','contractRecTypeName',programRegistrationInfo.contractRecTypeName);
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','studyMatProductCodes',programRegistrationInfo.studyMatProductCodes);

        }

        // Add program information
        programRegistrationInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation(courseCode,programRegistrationInfo.microCourseInfo);


        return programRegistrationInfo;
    }

    public static GARP_BC_Registration.getRegistrationInfo getFRR25RegistrationInfo(String regCode) {
        return GARP_BC_Registration.getRegistrationInfo(getFRR25RegistrationSettings(regCode));
    }

    public class microCourseInfo {
        public String name;
        public String description;
        public String myProgramsLogoURL;
        public String courseCode;
        public String formKey;
        public String accountingId;
        public String nonMemberProductCode;
        public String memberProductCode;
        public String certifiedProductCode;
        public String retakeProductCode;
        public String programType;
        public String programRecordTypeAPIName;
        public List<String> studyMaterialProductCodes;

        public String abbrevName;
        public String formalName;
        public String policyURL;
        public String registrationLogoURL;
    }

    public static microCourseInfo getMicroCourseInfo(String courseCode) {
        GARP_Common.debugLog('GARP_BC_Courses','getMicroCourseInfo','courseCode',courseCode);

        microCourseInfo microCourseInfo = new microCourseInfo();

        List<Exam__c> lstExam = [select id, Name, MC_Course_Name__c, MC_Course_Description__c, MC_Course_Form_Key__c, MC_Course_Study_Materials_Product_Codes__c,
                                 MC_Course_Program_Record_Type__c, MC_Course_Program_Record_Type_API_Name__c,
                                 MC_Course_Member_Product_Code__c, MC_Course_Non_Member_Product_Code__c,
                                 MC_Course_Certified_Product_Code__c, MC_Course_Retake_Product_Code__c,
                                 MC_Course_Abbreviation__c, MC_Course_Formal_Name__c, MC_Course_Policy_URL__c,
                                 MC_Course_Registration_Logo_URL__c, MC_Course_MyPrograms_Logo_URL__c
                                 from Exam__c where Exam__c = :courseCode];
        GARP_Common.debugLog('GARP_BC_Courses','getMicroCourseInfo','lstExam',lstExam);

        if(!lstExam.IsEmpty()) {
            Exam__c exam = lstExam[0];

            microCourseInfo.courseCode = courseCode.ToUpperCase();
            microCourseInfo.name = exam.MC_Course_Name__c;
            microCourseInfo.description = exam.MC_Course_Description__c;
            microCourseInfo.myProgramsLogoURL = exam.MC_Course_MyPrograms_Logo_URL__c;
            microCourseInfo.formKey = exam.MC_Course_Form_Key__c;
            microCourseInfo.nonMemberProductCode = exam.MC_Course_Non_Member_Product_Code__c;
            microCourseInfo.memberProductCode = exam.MC_Course_Member_Product_Code__c;
            microCourseInfo.certifiedProductCode = exam.MC_Course_Certified_Product_Code__c;
            microCourseInfo.retakeProductCode = exam.MC_Course_Retake_Product_Code__c;
            microCourseInfo.programType = exam.MC_Course_Program_Record_Type__c;
            microCourseInfo.programRecordTypeAPIName = exam.MC_Course_Program_Record_Type_API_Name__c;

            microCourseInfo.abbrevName = exam.MC_Course_Abbreviation__c;
            microCourseInfo.formalName = exam.MC_Course_Formal_Name__c;
            microCourseInfo.policyURL = exam.MC_Course_Policy_URL__c;
            microCourseInfo.registrationLogoURL = exam.MC_Course_Registration_Logo_URL__c;

            microCourseInfo.studyMaterialProductCodes = new List<String>();
            if(exam.MC_Course_Study_Materials_Product_Codes__c != NULL) {
                for(String studyMatProdCode :exam.MC_Course_Study_Materials_Product_Codes__c.split(',')){
                    microCourseInfo.studyMaterialProductCodes.add(studyMatProdCode);
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_Courses','getMicroCourseInfo','microCourseInfo',microCourseInfo);

        return microCourseInfo;
    }

    public class microCourseConfig {
        public MAP<String,microCourseInfo> mapMicroCourseByCode;
    }

    public static microCourseConfig getMicroCourseConfig() {

        microCourseConfig microCourseConfig = new microCourseConfig();

        List<Exam__c> lstExam = [select id, Name, MC_Course_Name__c, MC_Course_Description__c, MC_Course_Form_Key__c, MC_Course_Study_Materials_Product_Codes__c,
                                 MC_Course_Program_Record_Type__c, MC_Course_Program_Record_Type_API_Name__c,
                                 MC_Course_Member_Product_Code__c, MC_Course_Non_Member_Product_Code__c,
                                 MC_Course_Certified_Product_Code__c, MC_Course_Retake_Product_Code__c,
                                 MC_Course_Abbreviation__c, MC_Course_Formal_Name__c, MC_Course_Policy_URL__c,
                                 MC_Course_Registration_Logo_URL__c, MC_Course_MyPrograms_Logo_URL__c
                                 from Exam__c
                                 where Exam_Group__r.RecordType.Name = 'MicroCourse'
                                 ORDER BY MC_Course_Rank_Order__c];
        GARP_Common.debugLog('GARP_BC_Courses','getMicroCourseConfig','lstExam',lstExam);

        microCourseConfig.mapMicroCourseByCode = new MAP<String,microCourseInfo>();

        for(Exam__c exam :lstExam) {
            microCourseInfo microCourseInfo = new microCourseInfo();

            microCourseInfo.name = exam.MC_Course_Name__c;
            microCourseInfo.courseCode = exam.Name;
            microCourseInfo.description = exam.MC_Course_Description__c;
            microCourseInfo.myProgramsLogoURL = exam.MC_Course_MyPrograms_Logo_URL__c;
            microCourseInfo.formKey = exam.MC_Course_Form_Key__c;
            microCourseInfo.nonMemberProductCode = exam.MC_Course_Non_Member_Product_Code__c;
            microCourseInfo.memberProductCode = exam.MC_Course_Member_Product_Code__c;
            microCourseInfo.certifiedProductCode = exam.MC_Course_Certified_Product_Code__c;
            microCourseInfo.retakeProductCode = exam.MC_Course_Retake_Product_Code__c;
            microCourseInfo.programType = exam.MC_Course_Program_Record_Type__c;
            microCourseInfo.programRecordTypeAPIName = exam.MC_Course_Program_Record_Type_API_Name__c;

            microCourseInfo.abbrevName = exam.MC_Course_Abbreviation__c;
            microCourseInfo.formalName = exam.MC_Course_Formal_Name__c;
            microCourseInfo.policyURL = exam.MC_Course_Policy_URL__c;
            microCourseInfo.registrationLogoURL = exam.MC_Course_Registration_Logo_URL__c;

            microCourseInfo.studyMaterialProductCodes = new List<String>();
            if(exam.MC_Course_Study_Materials_Product_Codes__c != NULL) {
                microCourseInfo.studyMaterialProductCodes = new List<String>();
                for(String pc :exam.MC_Course_Study_Materials_Product_Codes__c.split(',')) {
                    microCourseInfo.studyMaterialProductCodes.add(pc);
                }
            }
            microCourseConfig.mapMicroCourseByCode.put(exam.Name, microCourseInfo);
        }

        GARP_Common.debugLog('GARP_BC_Courses','getMicroCourseConfig','microCourseConfig',microCourseConfig);
        return microCourseConfig;
    }

    // Helpers
    /**
     * Exam selection (SCR, RAIJ, Risk AI). Replaces getSCRExamSelectionInfo, getRAIJExamSelectionInfo, getRiskAIExamSelectionInfo.
     * @param programType 'scr', 'raij', or 'riskai'
     */
    public static GARP_BC_Registration.examSelectionInfo getExamSelectionInfo(MAP<String,PricebookEntry> mapProdByCodes, GARP_BC_Membership.membershipInfo membershipInfo, Boolean hasSelectedMembership, String programType) {
        String examType;
        String partsLabel;
        String examTitle;
        if (programType == 'scr') {
            examType = 'SCR';
            partsLabel = 'SCR Exam Part I';
            examTitle = 'SCR Exam';
        } else if (programType == 'raij') {
            examType = 'RAIJ';
            partsLabel = 'RAIJ Exam Part I';
            examTitle = 'RAIJ Exam';
        } else if (programType == 'riskai') {
            examType = 'RiskAI';
            partsLabel = 'Risk AI Exam Part I';
            examTitle = 'Risk AI Exam';
        } else {
            return new GARP_BC_Registration.examSelectionInfo();
        }
        GARP_Common.debugLog('GARP_BC_Courses', 'getExamSelectionInfo', 'programType', programType);

        GARP_BC_Registration.examSelectionInfo examSelectionInfo = new GARP_BC_Registration.examSelectionInfo();
        examSelectionInfo.partsAvailable = new List<String>();
        examSelectionInfo.part1Info = new GARP_BC_Registration.partInfo();
        examSelectionInfo.part1Info.examAdmins = new List<GARP_BC_Registration.examAdminInfo>();
        Boolean hasPart1 = false;
        Boolean hasPart2 = false;

        String rateType = 'Non-Member';
        if (membershipInfo != null) {
            Boolean isRetake = isExamRetake(membershipInfo, programType);
            if (isRetake) {
                rateType = 'Retake';
            } else if (membershipInfo.isFRMCertified || membershipInfo.isERPCertified || membershipInfo.isCertified || membershipInfo.isSCRHolder || membershipInfo.isRAIHolder || membershipInfo.isRAIJHolder) {
                rateType = 'Certified';
            } else if (membershipInfo.isInGoodStanding) {
                rateType = 'Member';
            }
        } else if (hasSelectedMembership) {
            rateType = 'Member';
        }

        List<Exam_Rate__c> rates = [SELECT Id, Product__c, Product__r.ProductCode, Product__r.GL_Code__c,
                                    Exam_Part__c, Exam_Part__r.Exam_Start_Date__c, Exam_Part__r.Exam_End_Date__c, Exam_Part__r.Exam_Date__c,
                                    Exam_Administration__c, Exam_Administration__r.Name,
                                    Exam_Registration_Window__c, Exam_Registration_Window__r.Type__c
                                    FROM Exam_Rate__c
                                    WHERE Exam_Registration_Window__r.Exam_Registration_Window_Open__c <= TODAY
                                      AND Exam_Registration_Window__r.Exam_Registration_Window_Close__c >= TODAY
                                      AND Rate_Type__c = :rateType
                                      AND Exam_Administration__r.Exam_Type__c = :examType
                                    ORDER BY Exam_Registration_Window__r.Exam_Registration_Window_Open__c DESC];

        // Pre-Select Admin
        String firstAdminId;
        String firstPartId;

        if(!rates.IsEmpty()) {
            Set<String> adminIds = new Set<String>();
            Set<String> siteIds = new Set<String>();

            for(Exam_Rate__c er :rates) {
                adminIds.add(er.Exam_Administration__c);
            }
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','adminIds',adminIds);

            List<Exam_Part__c> parts = [select id, Exam_Part_Number__c, Exam_Administration__c, Exam_Date__c, Exam_Start_Date__c, Exam_End_Date__c from Exam_Part__c where Exam_Administration__c in :adminIds];
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','parts',parts);

            List<Exam_Sites__c> examSites = [select id, Country__c, Exam_Part__c, Site__c from Exam_Sites__c where Exam_Part__r.Exam_Administration__c in :adminIds Order By Country__c];
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','examSites',examSites);

            for(Exam_Sites__c es :examSites) {
                siteIds.add(es.Site__c);
            }
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','siteIds',siteIds);

            List<Site__c> sites = [select id, Is_OSTA_Information_Required__c, Is_VAT__c from Site__c where Id in :siteIds];
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','sites',sites);

            MAP<String,Exam_Part__c> mapExamParts = new MAP<String,Exam_Part__c>();
            if(!parts.isEmpty()) {
                for(Exam_Part__c ep :parts) {
                    mapExamParts.put(ep.Exam_Administration__c, ep);
                }
            }
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','mapExamParts',mapExamParts);

            MAP<String,Exam_Sites__c> mapExamSitesByPart = new MAP<String,Exam_Sites__c>();
            MAP<String,Exam_Sites__c> mapExamSitesBySite = new MAP<String,Exam_Sites__c>();
            if(!examSites.isEmpty()) {
                for(Exam_Sites__c es :examSites) {
                    mapExamSitesByPart.put(es.Exam_Part__c, es);
                    mapExamSitesBySite.put(es.Site__c, es);
                }
            }
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','mapExamSitesByPart',mapExamSitesByPart);
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','mapExamSitesBySite',mapExamSitesBySite);

            MAP<String,Site__c> mapTestSites = new MAP<String,Site__c>();
            if(!sites.isEmpty()) {
                for(Site__c ts :sites) {
                    mapTestSites.put(ts.Id, ts);
                }
            }
            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','mapTestSites',mapTestSites);

            // Create Return Obj
            for(Exam_Rate__c er :rates) {

                GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','Loop er',er);

                GARP_BC_Registration.examAdminInfo examAdmin = new GARP_BC_Registration.examAdminInfo();
                if(firstAdminId == Null) {
                    firstAdminId = er.Exam_Administration__c;
                    firstPartId = er.Exam_Part__c;
                }

                examAdmin.name = er.Exam_Administration__r.Name;
                examAdmin.id = er.Exam_Administration__c;

                examAdmin.window = er.Exam_Registration_Window__r.Type__c;
                examAdmin.name = er.Exam_Administration__r.Name;

                GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','examAdmin1',examAdmin);

                PricebookEntry fndPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, er.Product__r.ProductCode, er.Product__r.GL_Code__c);
                GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','fndPbe',fndPbe);

                if(fndPbe != NULL) {
                    examAdmin.amount = fndPbe.UnitPrice;
                }
                Exam_Part__c fndPart = mapExamParts.get(er.Exam_Administration__c);
                GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','fndPart',fndPart);

                if(fndPart != NULL) {
                    examAdmin.partName = 'Part ' + fndPart.Exam_Part_Number__c;
                    if(fndPart.Exam_Part_Number__c == 1) {
                        hasPart1 = true;
                    } else {
                        hasPart2 = true;
                    }
                    examAdmin.partId = fndPart.Id;
                    if(fndPart.Exam_Date__c != NULL) {
                        DateTime dt = DateTime.newInstance(fndPart.Exam_Date__c.year(), fndPart.Exam_Date__c.month(), fndPart.Exam_Date__c.day());
                        examAdmin.examDates = dt.format('MMMM dd, yyyy');
                        examAdmin.examStartDateEpoch = dt.getTime();
                    } else {
                        DateTime sdt = DateTime.newInstance(fndPart.Exam_Start_Date__c.year(), fndPart.Exam_Start_Date__c.month(), fndPart.Exam_Start_Date__c.day());
                        DateTime edt = DateTime.newInstance(fndPart.Exam_End_Date__c.year(), fndPart.Exam_End_Date__c.month(), fndPart.Exam_End_Date__c.day());
                        if(fndPart.Exam_Start_Date__c.month() == fndPart.Exam_End_Date__c.month()) {
                            examAdmin.examDates = sdt.format('MMMM dd') + ' - ' + edt.format('dd, yyyy');
                        } else {
                            examAdmin.examDates = sdt.format('MMMM dd') + ' - ' + edt.format('MMMM dd, yyyy');
                        }
                        examAdmin.examStartDateEpoch = sdt.getTime();
                    }
                    GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','examAdmin2',examAdmin);

                    examAdmin.examSites = new List<GARP_BC_Registration.examSiteInfo>();
                    for(Exam_Sites__c es :examSites) {

                        GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','Loop es',es);

                        if(es.Exam_Part__c == fndPart.Id) {
                            GARP_BC_Registration.examSiteInfo examSite = new GARP_BC_Registration.examSiteInfo();
                            examSite.name = es.Country__c;
                            examSite.id = es.Id;
                            examSite.isOSTA = False;
                            examSite.isVAT = False;

                            Site__c fndTestSite = mapTestSites.get(es.Site__c);
                            if(fndTestSite != NULL) {
                                examSite.isOSTA = fndTestSite.Is_OSTA_Information_Required__c;
                                examSite.isVAT = fndTestSite.Is_VAT__c;
                            }
                            GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','Add examSite',examSite);
                            examAdmin.examSites.add(examSite);
                        }
                    }
                }
                GARP_Common.debugLog('GARP_BC_Courses','getExamSelectionInfo','Add part1',examAdmin);
                examSelectionInfo.part1Info.examAdmins.add(examAdmin);
            }
        }
        examSelectionInfo.partsAvailable.add(partsLabel);
        examSelectionInfo.part1Info.title = examTitle;
        examSelectionInfo.part1Info.selectedAdminId = firstAdminId;
        examSelectionInfo.part1Info.selectedPartId = firstPartId;
        GARP_Common.debugLog('GARP_BC_Courses', 'getExamSelectionInfo', 'Final examSelectionInfo', examSelectionInfo);
        return examSelectionInfo;
    }

    /**
     * Exam main product (SCR, RAIJ, Risk AI). Replaces getSCRMainProduct, getRAIJMainProduct, getRiskAIMainProduct.
     * @param programType 'scr', 'raij', or 'riskai'
     */
    public static getExamMainProductReturnInfo getExamMainProduct(MAP<String,PricebookEntry> mapProdByCodes, GARP_BC_Membership.membershipInfo membershipInfo, GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo, GARP_BC_Registration.teamRegInfo teamRegInfo, Boolean hasSelectedMembership, String programType) {
        getExamMainProductReturnInfo result = new getExamMainProductReturnInfo();
        result.status = 'Success';
        result.message = null;
        result.messages = new List<String>();
        result.products = new List<PricebookEntry>();
        List<PricebookEntry> retProds = result.products;
        String examType = (programType == 'scr') ? 'SCR' : (programType == 'raij') ? 'RAIJ' : (programType == 'riskai') ? 'RiskAI' : null;
        if (examType == null) {
            result.status = 'Failed';
            result.message = 'Invalid program type';
            result.messages.add(result.message);
            return result;
        }
        GARP_Common.debugLog('GARP_BC_Courses', 'getExamMainProduct', 'programType', programType);
        GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','membershipInfo',membershipInfo);
        GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','getRegistrationFeesInfo',getRegistrationFeesInfo);
        GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','teamRegInfo',teamRegInfo);
        GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','hasSelectedMembership',hasSelectedMembership);

        if(getRegistrationFeesInfo.examSelectionInfo.part1Info.selectedAdminId != NULL) {

            GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','part1Info.selectedAdminId',getRegistrationFeesInfo.examSelectionInfo.part1Info.selectedAdminId);

            // Find Rate Type
            String rateType = 'Non-Member';
            if(membershipInfo != NULL) {
                Boolean isRetake = isExamRetake(membershipInfo, programType);
                GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','isRetake',isRetake);

                if(isRetake) {
                    rateType = 'Retake';
                } else if(membershipInfo.isFRMCertified || membershipInfo.isERPCertified || membershipInfo.isCertified || membershipInfo.isSCRHolder || membershipInfo.isRAIHolder || membershipInfo.isRAIJHolder) {
                    rateType = 'Certified';
                } else if(membershipInfo.isInGoodStanding || hasSelectedMembership) {
                    rateType = 'Member';
                }
            }
            else if(hasSelectedMembership) {
                rateType = 'Member';
            }
            GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','rateType',rateType);

            List<Exam_Rate__c> rates = [select id, Product__r.ProductCode, Product__r.GL_Code__c,
                                        Team_Product__r.ProductCode, Team_Product__r.GL_Code__c,
                                        Team_Product_Member__r.ProductCode, Team_Product_Member__r.GL_Code__c,
                                        Team_Scholarship_Product__r.ProductCode, Team_Scholarship_Product__r.GL_Code__c
                                        from Exam_Rate__c
                                        where Exam_Administration__c = :getRegistrationFeesInfo.examSelectionInfo.part1Info.selectedAdminId AND
                                        Exam_Registration_Window__r.Exam_Registration_Window_Open__c <= TODAY AND
                                        Exam_Registration_Window__r.Exam_Registration_Window_Close__c >= TODAY AND
                                        Rate_Type__c = :rateType AND Exam_Administration__r.Exam_Type__c = :examType];
            GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','rates',rates);
            if(!rates.IsEmpty()) {
                Exam_Rate__c scrRate = rates[0];

                if(scrRate.Product__r.ProductCode == NULL || scrRate.Product__r.GL_Code__c == NULL) {
                    result.status = 'Failed';
                    result.message = 'Exam product not configured';
                    result.messages.add(result.message);
                    return result;
                }

                PricebookEntry pbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, scrRate.Product__r.ProductCode, scrRate.Product__r.GL_Code__c);
                GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','pbe',pbe);

                if(pbe == NULL) {
                    result.status = 'Failed';
                    result.message = 'Exam product not found in product map';
                    result.messages.add(result.message);
                    return result;
                }

                // Team Registration
                if(getRegistrationFeesInfo.teamRegCode != NULL && !String.IsEmpty(getRegistrationFeesInfo.teamRegCode)) {
                    if(scrRate.Team_Product__r == NULL || scrRate.Team_Product__r.ProductCode == NULL || scrRate.Team_Product__r.GL_Code__c == NULL) {
                        result.status = 'Failed';
                        result.message = 'Team registration products not configured for this exam rate';
                        result.messages.add(result.message);
                        return result;
                    }

                    if(!teamRegInfo.isScholarship) {

                        // AG - Grab correct rate type of Team Product now
                        if((teamRegInfo.rateType == NULL || teamRegInfo.rateType == 'Non-Member') && scrRate.Team_Product__r != NULL) {
                            pbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, scrRate.Team_Product__r.ProductCode, scrRate.Team_Product__r.GL_Code__c);
                        } else if(teamRegInfo.rateType != NULL && teamRegInfo.rateType == 'Member' && scrRate.Team_Product_Member__r != NULL) {
                            pbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, scrRate.Team_Product_Member__r.ProductCode, scrRate.Team_Product_Member__r.GL_Code__c);
                        }

                    } else {
                        // Scholarship - Add negative amount
                        PricebookEntry fndScholarshipPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, scrRate.Team_Scholarship_Product__r.ProductCode, scrRate.Team_Scholarship_Product__r.GL_Code__c);
                        if(fndScholarshipPbe != NULL) {
                            fndScholarshipPbe.UnitPrice = (pbe.UnitPrice * -1);
                            retProds.add(fndScholarshipPbe);
                            GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','Add scholarship pbe',fndScholarshipPbe);
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','Team pbe',pbe);
                }

                if(pbe != NULL) {
                    retProds.add(pbe);
                } else {
                    result.status = 'Failed';
                    result.message = 'Team registration product not found in product map';
                    result.messages.add(result.message);
                    return result;
                }
            } else {
                result.status = 'Failed';
                result.message = 'No exam rates found';
                result.messages.add(result.message);
                return result;
            }
        }
        GARP_Common.debugLog('GARP_BC_Courses','getExamMainProduct','Final retProds',retProds);
        return result;
    }

    /**
     * Main program eligibility (SCR, RAIJ, Risk AI). Replaces isEligibleSCR, isEligibleRAIJ, isEligibleRiskAI.
     * @param programType 'scr', 'raij', or 'riskai'
     */
    public static GARP_BC_Registration.RegistrationEligibility isEligibleExam(GARP_BC_Membership.membershipInfo membershipInfo, String loadKey, String programType) {
        String examTypeAdmin;
        String contractType;
        String recordTypeName;
        String examCode;

        GARP_BC_Registration.RegistrationEligibility retObj = new GARP_BC_Registration.RegistrationEligibility();
        retObj.isEligible = False;

        if (programType == 'scr') {
            examTypeAdmin = 'SCR';
            contractType = 'scr';
            recordTypeName = 'SCR Program';
            examCode = 'SCR';
        } else if (programType == 'raij') {
            examTypeAdmin = 'RAIJ';
            contractType = 'raij';
            recordTypeName = 'RAIJ Program';
            examCode = 'RAIJ';
        } else if (programType == 'riskai') {
            examTypeAdmin = 'RiskAI';
            contractType = 'riskai';
            recordTypeName = 'Risk AI Program';
            examCode = 'RiskAI';
        } else {
            return retObj;
        }
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'programType', programType);


        Set<String> eligibleExams = new Set<String>();
        Boolean isInProgram = false;
        Boolean isOpenOrder = false;
        Boolean isPart1Passed = false;
        Boolean isPart1RegisteredInActiveAdmin = false;
        Boolean isPart1RegisteredAwaitingResults = false;
        Boolean isPart1Deferred = false;
        Boolean isRegistrationOpen = false;
        Boolean isPaymentBlocked = false;
        Boolean isNetNew = false;
        retObj.isNetNew = false;
        Exam_Attempt__c part1EA;

        List<Exam_Administration__c> lstAdmins = [SELECT Id, Name, Registration_Start_Date__c, Registration_End_Date__c FROM Exam_Administration__c WHERE Exam_Type__c = :examTypeAdmin AND Registration_Start_Date__c <= TODAY AND Registration_End_Date__c >= TODAY];
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'lstAdmins', lstAdmins);

        Map<String, Exam_Administration__c> mapActiveExamAdmins = new Map<String, Exam_Administration__c>();
        if (!lstAdmins.isEmpty()) {
            isRegistrationOpen = true;
            for (Exam_Administration__c ea : lstAdmins) {
                mapActiveExamAdmins.put(ea.Id, ea);
            }
        }
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'mapActiveExamAdmins', mapActiveExamAdmins);

        retObj.eligibleExams = new Set<String>();
        if (!isRegistrationOpen) {
            return retObj;
        }
        if (membershipInfo == null || membershipInfo.contactRecord == null) {
            retObj.eligibleExams.add(examCode);
            retObj.isNetNew = true;
            retObj.isEligible = true;
            GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'No MembershipInfo retObj', retObj);
            return retObj;
        }
        String contactId = membershipInfo.contactRecord.Id;
        Contract cont = getExamContractByType(membershipInfo.accountRecord.Id, contractType);
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'cont', cont);

            if (cont != null) {
            if (cont.Status.indexOf('Activated') > -1) {
                isInProgram = true;
            } else if (cont.Status == 'Completed') {
                isPart1Passed = true;
            }
        } else {
            isNetNew = true;
        }
        List<Account> lstAcct = [SELECT Id, Block_Purchases_All_Types__c FROM Account WHERE Id = :membershipInfo.accountRecord.Id];
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'lstAcct', lstAcct);

        if (!lstAcct.isEmpty()) {
            isPaymentBlocked = lstAcct[0].Block_Purchases_All_Types__c;
        }
        List<String> rtList = new List<String>{ recordTypeName };
        List<Exam_Attempt__c> examRegistrations = [
            SELECT Id, Candidate_Commitment__r.RecordType.Name, Defered__c, Exam_Administration__c, Exam_Administration__r.Exam_Results_Loading__c,
                   Exam_Site__r.Exam__r.Exam__c, Opportunity_StageName__c, Result__c, Candidate_Commitment__r.Status
            FROM Exam_Attempt__c
            WHERE (Candidate_Commitment__r.Status LIKE '%Activated%' OR Candidate_Commitment__r.Status = 'Completed' OR Candidate_Commitment__r.Status = 'Draft')
              AND Member__c = :contactId
              AND (Opportunity_StageName__c = 'Closed' OR Opportunity_StageName__c = 'New Lead')
              AND Candidate_Commitment__r.RecordType.Name IN :rtList
              AND Cancelled__c != true
            ORDER BY Exam_Date__c DESC
        ];
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'examRegistrations', examRegistrations);

        for (Exam_Attempt__c objFRMEA : examRegistrations) {
            if (objFRMEA.Candidate_Commitment__r.RecordType.Name == recordTypeName) {
                if (objFRMEA.Candidate_Commitment__r.Status == 'Draft' || objFRMEA.Opportunity_StageName__c == 'New Lead') {
                    isOpenOrder = true;
                } else if (objFRMEA.Candidate_Commitment__r.Status != 'Completed') {
                    if (part1EA == null && objFRMEA.Exam_Site__r.Exam__r.Exam__c == examCode) {
                        if (mapActiveExamAdmins.get(objFRMEA.Exam_Administration__c) != null) {
                            isPart1RegisteredInActiveAdmin = true;
                            isPart1RegisteredAwaitingResults = false;
                            part1EA = objFRMEA;
                        }
                        if (objFRMEA.Defered__c == 'Pending') {
                            isPart1Deferred = true;
                            part1EA = objFRMEA;
                        }
                    }
                    if (part1EA == null && objFRMEA.Exam_Site__r.Exam__r.Exam__c == examCode && mapActiveExamAdmins.get(objFRMEA.Exam_Administration__c) == null &&
                        (objFRMEA.Defered__c == null || objFRMEA.Defered__c != 'Pending') &&
                        (objFRMEA.Result__c == null || objFRMEA.Result__c == '' || GARP_Common.isLoadingResults(objFRMEA.Exam_Administration__r.Exam_Results_Loading__c, loadKey))) {
                        isPart1RegisteredAwaitingResults = true;
                        part1EA = objFRMEA;
                    }
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'isOpenOrder', isOpenOrder);
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'isPaymentBlocked', isPaymentBlocked);
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'isPart1Passed', isPart1Passed);
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'isPart1RegisteredInActiveAdmin', isPart1RegisteredInActiveAdmin);
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'isPart1RegisteredAwaitingResults', isPart1RegisteredAwaitingResults);
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'isPart1Deferred', isPart1Deferred);

        if (!isOpenOrder && !isPaymentBlocked) {
            if (!isPart1Passed && !isPart1RegisteredInActiveAdmin && !isPart1RegisteredAwaitingResults && !isPart1Deferred) {
                eligibleExams.add(examCode);
            }
        }
        retObj.eligibleExams = eligibleExams;
        retObj.isRegistrationOpen = isRegistrationOpen;
        retObj.isPaymentBlocked = isPaymentBlocked;
        retObj.isInProgram = isInProgram;
        retObj.isOpenOrder = isOpenOrder;
        retObj.isPart1Passed = isPart1Passed;
        retObj.isPart1RegisteredInActiveAdmin = isPart1RegisteredInActiveAdmin;
        retObj.isPart1RegisteredAwaitingResults = isPart1RegisteredAwaitingResults;
        retObj.isPart1Deferred = isPart1Deferred;
        retObj.isNetNew = isNetNew;
        retObj.isEligible = true;
        if (!isRegistrationOpen) {
            retObj.eligibleError = 'Registration is not currently open';
            retObj.isEligible = false;
        } else if (isPaymentBlocked) {
            retObj.eligibleError = 'Your account is currently prohibited from registering';
            retObj.isEligible = false;
        } else if (isOpenOrder) {
            retObj.eligibleError = 'You already have a pending order for this program';
            retObj.isEligible = false;
        } else if (isPart1Passed || isPart1RegisteredInActiveAdmin || isPart1RegisteredAwaitingResults || isPart1Deferred) {
            retObj.eligibleError = 'You are already enrolled in this program';
            retObj.isEligible = false;
        }
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'retObj', retObj);

        if(retObj.isEligible && programType == 'raij') {
            List<Contract> lstContracts = [select id from Contract where AccountId = :membershipInfo.accountRecord.Id AND recordType.DeveloperName = 'Risk_AI_Program' AND status in ('Activated','Activated ( Auto-Renew )','Expired')];
            GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'lstContracts', lstContracts);
            if(!lstContracts.IsEmpty()) {
                eligibleExams = new Set<String>();
                retObj.eligibleError = 'You are already enrolled in the RAI program';
                retObj.isEligible = false;
            }
        } else if(retObj.isEligible && programType == 'riskai') {
            List<Contract> lstContracts = [select id from Contract where AccountId = :membershipInfo.accountRecord.Id AND recordType.DeveloperName = 'RAIJ_Program' AND status in ('Activated','Activated ( Auto-Renew )','Expired')];
            GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'lstContracts', lstContracts);

            if(!lstContracts.IsEmpty()) {
                eligibleExams = new Set<String>();
                retObj.eligibleError = 'You are already enrolled in the RAIJ program';
                retObj.isEligible = false;
            }
        }

        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleExam', 'retObj final', retObj);
        return retObj;
    }

    /**
     * Main program retake (SCR, RAIJ, Risk AI). Replaces isSCRRetake, isRAIJRetake, isRAIRetake.
     * @param programType 'scr', 'raij', or 'riskai'
     */
    public static Boolean isExamRetake(GARP_BC_Membership.membershipInfo membershipInfo, String programType) {
        if (membershipInfo == null || membershipInfo.accountRecord == null) {
            return false;
        }
        String recordTypeName;
        if (programType == 'scr') {
            recordTypeName = 'SCR Program';
        } else if (programType == 'raij') {
            recordTypeName = 'RAIJ Program';
        } else if (programType == 'riskai') {
            recordTypeName = 'Risk AI Program';
        } else {
            return false;
        }
        List<Contract> lstCont = [SELECT Id, Eligible_For_Scr_Discount__c, Eligible_For_Scr_Discount_Date__c
                                  FROM Contract
                                  WHERE AccountId = :membershipInfo.accountRecord.Id
                                    AND RecordType.Name = :recordTypeName
                                    AND Status = 'Expired'
                                  ORDER BY StartDate DESC];
        if (!lstCont.isEmpty()) {
            Contract objCon = lstCont[0];
            if (objCon.Eligible_For_Scr_Discount__c && objCon.Eligible_For_Scr_Discount_Date__c != null && System.today() <= objCon.Eligible_For_Scr_Discount_Date__c) {
                return true;
            }
        }
        return false;
    }

    /**
     * Course eligibility (FFR, FRR, FRR25, Micro). Replaces isEligibleFFR, isEligibleFRR, isEligibleFRR25, isEligibleMicroCourse.
     * @param courseType 'ffr', 'frr', 'frr25', or 'micro'. For 'micro', teamRegInfo and microCourseInfo are used.
     */
    public static isEligibleCourseReturnInfo isEligibleCourse(GARP_BC_Membership.membershipInfo membershipInfo, String courseType, GARP_BC_Registration.teamRegInfo teamRegInfo, microCourseInfo microCourseInfo) {
        isEligibleCourseReturnInfo retIsEligible = new isEligibleCourseReturnInfo();
        retIsEligible.isEligible = false;
        retIsEligible.message = null;
        GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleCourse', 'courseType', courseType);
        if (courseType != 'ffr' && courseType != 'frr' && courseType != 'frr25' && courseType != 'micro') {
            retIsEligible.message = 'Invalid course type';
            return retIsEligible;
        }
        if (courseType == 'micro' && microCourseInfo == null) {
            retIsEligible.message = 'Micro course information is required';
            return retIsEligible;
        }
        if (courseType == 'ffr') {
            if (membershipInfo == null || membershipInfo.accountRecord == null) {
                retIsEligible.isEligible = true;
                return retIsEligible;
            }
            Id recId = RecordTypeHelper.GetRecordTypeId('Contract', 'FBR Program');
            List<Contract> lstContract = [SELECT Id, RecordTypeId, Membership_Type__c, EndDate, Status FROM Contract WHERE AccountId = :membershipInfo.accountRecord.Id AND RecordTypeId = :recId AND Status != 'Canceled' ORDER BY StartDate];
            if (!lstContract.isEmpty()) {
                Contract c = lstContract[0];
                if (c.Status == 'Completed') {
                    retIsEligible.message = 'You have already completed this program';
                    return retIsEligible;
                }
                if (c.Status == 'Activated' || c.Status == 'Activated ( Auto-Renew )') {
                    retIsEligible.message = 'You are already enrolled in this program';
                    return retIsEligible;
                }
            }
            retIsEligible.isEligible = true;
            GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleCourse', 'eligible', true);
            return retIsEligible;
        }
        if (courseType == 'frr') {
            List<Exam_Group__c> examGroups = [SELECT Id FROM Exam_Group__c WHERE Active__c = true AND RecordType.Name = 'ICBRR'];
            Boolean examGroupActive = !examGroups.isEmpty();
            Boolean isRetake = isCourseRetake(membershipInfo, 'frr', null);
            if (!examGroupActive && !isRetake) {
                retIsEligible.message = 'This program is not currently available';
                return retIsEligible;
            }
            if (examGroupActive && (membershipInfo == null || membershipInfo.accountRecord == null)) {
                retIsEligible.isEligible = true;
                return retIsEligible;
            }
            Id recId = RecordTypeHelper.GetRecordTypeId('Contract', 'ICBRR Program');
            List<Contract> lstContract = [SELECT Id, RecordTypeId, Membership_Type__c, EndDate, Status FROM Contract WHERE AccountId = :membershipInfo.accountRecord.Id AND RecordTypeId = :recId AND Status != 'Canceled' AND Status != 'Draft' ORDER BY StartDate];
            if (!lstContract.isEmpty()) {
                Contract c = lstContract[0];
                if (c.Status == 'Expired' || c.Status == 'Activated') {
                    Id attemptRecId = RecordTypeHelper.GetRecordTypeId('Exam_Attempt__c', 'ICBRR');
                    List<Exam_Attempt__c> attempts = [SELECT Id, Icbrr_Exam_Date__c, Result__c FROM Exam_Attempt__c WHERE Member__c = :membershipInfo.contactRecord.Id AND Cancelled__c = false AND RecordTypeId = :attemptRecId ORDER BY Registered_On__c];
                    if (!attempts.isEmpty() && attempts[0].Result__c == 'Fail') {
                        Integer daysBetween = attempts[0].Icbrr_Exam_Date__c.daysBetween(Date.today());
                        if (daysBetween < 30) {
                            retIsEligible.message = 'You must wait 30 days to take this assessment again';
                            return retIsEligible;
                        }
                    }
                    if (c.Status == 'Activated' && !attempts.isEmpty() && attempts[0].Result__c == null) {
                        retIsEligible.message = 'You are already enrolled in this program';
                        return retIsEligible;
                    }
                } else if (c.Status == 'Completed') {
                    retIsEligible.message = 'You have already completed this program';
                    return retIsEligible;
                }
            }
            retIsEligible.isEligible = true;
            GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleCourse', 'eligible', true);
            return retIsEligible;
        }
        if (courseType == 'frr25') {
            List<Exam_Group__c> examGroups = [SELECT Id FROM Exam_Group__c WHERE Active__c = true AND RecordType.Name = 'FRR25'];
            if (examGroups.isEmpty()) {
                retIsEligible.message = 'This program is not currently available';
                return retIsEligible;
            }
            if (membershipInfo == null || membershipInfo.accountRecord == null) {
                retIsEligible.isEligible = true;
                return retIsEligible;
            }
            Id recId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRR25 Program');
            List<Contract> lstContract = [SELECT Id, RecordTypeId, Membership_Type__c, EndDate, Status FROM Contract WHERE AccountId = :membershipInfo.accountRecord.Id AND RecordTypeId = :recId AND Status != 'Canceled' AND Status != 'Draft' ORDER BY StartDate];
            if (!lstContract.isEmpty()) {
                Contract c = lstContract[0];
                if (c.Status == 'Expired' || c.Status == 'Activated') {
                    Id attemptRecId = RecordTypeHelper.GetRecordTypeId('Exam_Attempt__c', 'FRR25');
                    List<Exam_Attempt__c> attempts = [SELECT Id, Icbrr_Exam_Date__c, Result__c FROM Exam_Attempt__c WHERE Member__c = :membershipInfo.contactRecord.Id AND Cancelled__c = false AND RecordTypeId = :attemptRecId ORDER BY Registered_On__c];
                    if (c.Status == 'Activated' && !attempts.isEmpty() && attempts[0].Result__c == null) {
                        retIsEligible.message = 'You are already enrolled in this program';
                        return retIsEligible;
                    }
                } else if (c.Status == 'Completed') {
                    retIsEligible.message = 'You have already completed this program';
                    return retIsEligible;
                }
            }
            retIsEligible.isEligible = true;
            GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleCourse', 'eligible', true);
            return retIsEligible;
        }
        if (courseType == 'micro') {
            if (membershipInfo != null && membershipInfo.accountRecord != null) {
                Id recId = RecordTypeHelper.GetRecordTypeId('Contract', microCourseInfo.programType);
                List<Contract> lstContract = [SELECT Id, RecordTypeId, Membership_Type__c, EndDate, Status FROM Contract WHERE AccountId = :membershipInfo.accountRecord.Id AND RecordTypeId = :recId AND Status != 'Canceled' AND Status != 'Draft' ORDER BY StartDate];
                if (!lstContract.isEmpty()) {
                    Contract c = lstContract[0];
                    if (c.Status == 'Expired' || c.Status == 'Activated') {
                        Id attemptRecId = RecordTypeHelper.GetRecordTypeId('Exam_Attempt__c', microCourseInfo.courseCode);
                        List<Exam_Attempt__c> attempts = [SELECT Id, Result__c FROM Exam_Attempt__c WHERE Member__c = :membershipInfo.contactRecord.Id AND Cancelled__c = false AND RecordTypeId = :attemptRecId ORDER BY Registered_On__c];
                        if (c.Status == 'Activated' && !attempts.isEmpty() && attempts[0].Result__c == null) {
                            retIsEligible.message = 'You are already enrolled in this program';
                            return retIsEligible;
                        }
                    } else if (c.Status == 'Completed') {
                        retIsEligible.message = 'You have already completed this program';
                        return retIsEligible;
                    }
                }
            }
            Boolean isRetake = isCourseRetake(membershipInfo, 'micro', microCourseInfo);
            if (teamRegInfo == null && !isRetake) {
                retIsEligible.message = 'Micro Courses are only available via B2B Deals';
                return retIsEligible;
            }
            retIsEligible.isEligible = true;
            GARP_Common.debugLog('GARP_BC_Courses', 'isEligibleCourse', 'eligible', true);
            return retIsEligible;
        }
        return retIsEligible;
    }

    /**
     * Course retake check for FRR, FRR25, or Micro. Replaces isFRRRetake, isFRR25Retake, isMicroCourseRetake.
     * @param courseType 'frr', 'frr25', or 'micro'. For 'micro', microCourseInfo is required.
     */
    public static Boolean isCourseRetake(GARP_BC_Membership.membershipInfo membershipInfo, String courseType, microCourseInfo microCourseInfo) {
        GARP_Common.debugLog('GARP_BC_Courses', 'isCourseRetake', 'courseType', courseType);
        if (membershipInfo == null || membershipInfo.accountRecord == null) {
            GARP_Common.debugLog('GARP_BC_Courses', 'isCourseRetake', 'no membershipInfo, False', '');
            return false;
        }
        String contractRecordTypeName;
        String examCode;
        Boolean requireThirtyDays;
        Boolean retakeIfNotPass;
        if (courseType == 'frr') {
            contractRecordTypeName = 'ICBRR Program';
            examCode = 'ICBRR';
            requireThirtyDays = true;
            retakeIfNotPass = false;
        } else if (courseType == 'frr25') {
            contractRecordTypeName = 'FRR25 Program';
            examCode = 'FRR25';
            requireThirtyDays = false;
            retakeIfNotPass = true;
        } else if (courseType == 'micro' && microCourseInfo != null) {
            contractRecordTypeName = microCourseInfo.programType;
            examCode = microCourseInfo.courseCode;
            requireThirtyDays = false;
            retakeIfNotPass = false;
        } else {
            return false;
        }
        Id recId = RecordTypeHelper.GetRecordTypeId('Contract', contractRecordTypeName);
        List<Contract> lstContract = [SELECT Id, RecordTypeId, Membership_Type__c, EndDate, Status
                                      FROM Contract
                                      WHERE AccountId = :membershipInfo.accountRecord.Id AND RecordTypeId = :recId AND Status = 'Activated'
                                      ORDER BY StartDate];
        GARP_Common.debugLog('GARP_BC_Courses', 'isCourseRetake', 'lstContract', lstContract);
        if (lstContract.isEmpty()) {
            return false;
        }
        List<Exam_Attempt__c> lstExamAttempts = [SELECT Id, Icbrr_Exam_Date__c, Result__c
                                                 FROM Exam_Attempt__c
                                                 WHERE Member__c = :membershipInfo.contactRecord.Id
                                                   AND Exam_Site__r.Exam__r.Exam__c = :examCode
                                                   AND Cancelled__c = false
                                                 ORDER BY Registered_On__c DESC];
        GARP_Common.debugLog('GARP_BC_Courses', 'isCourseRetake', 'lstExamAttempts', lstExamAttempts);
        if (lstExamAttempts.isEmpty()) {
            return false;
        }
        Exam_Attempt__c latest = lstExamAttempts[0];
        if (retakeIfNotPass && latest.Result__c != 'Pass') {
            return true;
        }
        if (latest.Result__c == 'Fail') {
            if (requireThirtyDays && latest.Icbrr_Exam_Date__c != null) {
                Integer daysBetween = latest.Icbrr_Exam_Date__c.daysBetween(Date.today());
                return daysBetween >= 30;
            }
            if (!requireThirtyDays) {
                return true;
            }
        }
        return false;
    }

    /**
     * Creates a main programs contract (SCR, RAIJ, or Risk AI). Replaces createSCRContract, createRAIJContract, createRiskAIContract.
     * @param programType 'scr', 'raij', or 'riskai'. Maps to record types 'SCR Program', 'RAIJ Program', 'Risk AI Program'.
     */
    public static Contract createExamContract(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, GARP_BC_Membership.membershipInfo membershipInfo, String programType) {
        String recordTypeName;
        if (programType == 'scr') {
            recordTypeName = 'SCR Program';
        } else if (programType == 'raij') {
            recordTypeName = 'RAIJ Program';
        } else if (programType == 'riskai') {
            recordTypeName = 'Risk AI Program';
        }

        Id recordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', recordTypeName);

        List<Exam_Part__c> lstExamPart = [SELECT Id, Exam_Date__c, Exam_Start_Date__c, Exam_End_Date__c FROM Exam_Part__c WHERE Id = :setRegistrationInfo.examSelectionInfo.part1Info.selectedPartId];
        GARP_Common.debugLog('GARP_BC_Courses', 'createExamContract', 'lstExamPart', lstExamPart);

        Date startDate;
        Date endDate;
        if (!lstExamPart.isEmpty()) {
            Exam_Part__c examPart = lstExamPart[0];
            if (examPart.Exam_Date__c != null) {
                startDate = examPart.Exam_Date__c;
                endDate = examPart.Exam_Date__c;
            } else if (examPart.Exam_Start_Date__c != null) {
                startDate = examPart.Exam_Start_Date__c;
                endDate = examPart.Exam_End_Date__c;
            }
        }
        GARP_Common.debugLog('GARP_BC_Courses', 'createExamContract', 'startDate', startDate);
        GARP_Common.debugLog('GARP_BC_Courses', 'createExamContract', 'endDate', endDate);

        Contract mainContract = new Contract(
            AccountId = setRegistrationReturnInfo.accountId,
            Opportunity__c = setRegistrationReturnInfo.orderId,
            CustomerSignedId = setRegistrationReturnInfo.contactId,
            StartDate = System.today(),
            ContractTerm = 9,
            recordTypeID = recordTypeId,
            Member_Email__c = setRegistrationInfo.customerInfo.email,
            BillingStreet = GARP_Common.formatAddressTextArea(setRegistrationInfo.paymentInfo.billingAddress.street1, setRegistrationInfo.paymentInfo.billingAddress.street2, setRegistrationInfo.paymentInfo.billingAddress.street3),
            BillingCity = setRegistrationInfo.paymentInfo.billingAddress.city,
            BillingCountry = setRegistrationInfo.paymentInfo.billingAddress.country,
            BillingState = setRegistrationInfo.paymentInfo.billingAddress.province,
            BillingPostalCode = setRegistrationInfo.paymentInfo.billingAddress.postalCode,
            SCR_Start_Date__c = startDate,
            SCR_End_Date__c = endDate
        );

        GARP_Common.debugLog('GARP_BC_Courses', 'createExamContract', 'mainContract', mainContract);
        return mainContract;
    }

    /**
     * Return type for createCourseContract. isNew true = new contract (caller must insert); false = existing contract updated.
     */
    public class returnCreateCourseContract {
        public Boolean isNew;
        public Contract frrContract;
    }

    /**
     * Creates or reuses a course contract (FRR/ICBRR, FRR25, FFR, or MicroCourse) by course type.
     * Replaces createFRRContract, createFRR25Contract, createFFRContract, createMicroCourseContract.
     * @param courseType 'frr', 'frr25', 'ffr', or 'micro'. Micro uses programType/courseCode from setRegistrationInfo.programRegistrationInfo.microCourseInfo.
     * @return returnCreateCourseContract (isNew and frrContract). For 'ffr' always isNew=true; for others isNew reflects whether an existing contract was found.
     */
    public static returnCreateCourseContract createCourseContract(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, GARP_BC_Membership.membershipInfo membershipInfo, String courseType) {
        GARP_Common.debugLog('GARP_BC_Courses', 'createCourseContract', 'courseType', courseType);
        returnCreateCourseContract ret = new returnCreateCourseContract();
        Contract courseContract;
        String recordTypeName;
        String contractName;
        Integer contractTerm;

        if (courseType == 'ffr') {
            recordTypeName = 'FBR Program';
            contractName = null;
            contractTerm = 6;
        } else if (courseType == 'frr') {
            recordTypeName = 'ICBRR Program';
            contractName = 'FRR';
            contractTerm = 9;
        } else if (courseType == 'frr25') {
            recordTypeName = 'FRR25 Program';
            contractName = 'FRR25';
            contractTerm = 9;
        } else if (courseType == 'micro') {
            if (setRegistrationInfo == null || setRegistrationInfo.programRegistrationInfo == null || setRegistrationInfo.programRegistrationInfo.microCourseInfo == null) {
                return null;
            }
            recordTypeName = setRegistrationInfo.programRegistrationInfo.microCourseInfo.programType;
            contractName = setRegistrationInfo.programRegistrationInfo.microCourseInfo.courseCode;
            contractTerm = 3;
        } else {
            return null;
        }

        Id recordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', recordTypeName);

        List<Contract> lstCont = [
                SELECT Id, AccountId, Opportunity__c, CustomerSignedId, StartDate, ContractTerm, recordTypeID, Member_Email__c,
                       Pearson_Member_First_Name__c, Pearson_Member_Last_Name__c, Pearson_Phone_No__c, BillingStreet, BillingCity,
                       BillingState, BillingPostalCode
                FROM Contract
                WHERE recordTypeID = :recordTypeId
                  AND AccountId = :setRegistrationReturnInfo.accountId
                  AND Status LIKE 'Activated%'
            ];
        GARP_Common.debugLog('GARP_BC_Courses', 'createCourseContract', 'lstCont', lstCont);
        if (!lstCont.isEmpty()) {
            courseContract = lstCont[0];
            courseContract.Opportunity__c = setRegistrationReturnInfo.orderId;
            update courseContract;
            ret.isNew = false;
        }

        if (courseContract == null) {
            ret.isNew = true;
            courseContract = new Contract(
                accountId = setRegistrationReturnInfo.accountId,
                CustomerSignedId = setRegistrationReturnInfo.contactId,
                Opportunity__c = setRegistrationReturnInfo.orderId,
                StartDate = System.today(),
                ContractTerm = contractTerm,
                recordTypeID = recordTypeId,
                Member_Email__c = setRegistrationInfo.customerInfo.email,
                BillingStreet = GARP_Common.formatAddressTextArea(setRegistrationInfo.paymentInfo.billingAddress.street1, setRegistrationInfo.paymentInfo.billingAddress.street2, setRegistrationInfo.paymentInfo.billingAddress.street3),
                BillingCity = setRegistrationInfo.paymentInfo.billingAddress.city,
                BillingCountry = setRegistrationInfo.paymentInfo.billingAddress.country,
                BillingState = setRegistrationInfo.paymentInfo.billingAddress.province,
                BillingPostalCode = setRegistrationInfo.paymentInfo.billingAddress.postalCode
            );
            if (String.isNotBlank(contractName)) {
                courseContract.Name = contractName;
            }
            GARP_Common.debugLog('GARP_BC_Courses', 'createCourseContract', 'courseContract', courseContract);
        }

        ret.frrContract = courseContract;
        return ret;
    }

    /**
     * Creates a course program requirement (Candidate_Requirement__c, Exam record type) by course type.
     * Call this instead of createFRRProgramRequirement, createFRR25ProgramRequirement, createMicroCourseProgramRequirement, createFFRProgramRequirement.
     * @param courseType 'FRR', 'FRR25', 'MicroCourse', or 'FFR'. MicroCourse uses courseCode from setRegistrationInfo.programRegistrationInfo.microCourseInfo.
     * @return New Candidate_Requirement__c (not inserted), or null if courseType invalid or MicroCourse and microCourseInfo missing.
     */
    public static Candidate_Requirement__c createCourseProgramRequirement(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, String ContractId, String courseType) {
        String nameLabel;
        String examCode;
        if (courseType == 'FRR') {
            nameLabel = 'Pass FRR';
            examCode = 'ICBRR';
        } else if (courseType == 'FRR25') {
            nameLabel = 'Pass FRR25';
            examCode = 'FRR25';
        } else if (courseType == 'FFR') {
            nameLabel = 'Pass FFR';
            examCode = 'FBR';
        } else if (courseType == 'MicroCourse') {
            if (setRegistrationInfo == null || setRegistrationInfo.programRegistrationInfo == null || setRegistrationInfo.programRegistrationInfo.microCourseInfo == null
                || String.isBlank(setRegistrationInfo.programRegistrationInfo.microCourseInfo.courseCode)) {
                return null;
            }
            examCode = setRegistrationInfo.programRegistrationInfo.microCourseInfo.courseCode;
            nameLabel = 'Pass ' + examCode;
        } else {
            return null;
        }
        Id examCandidateReqRecordTypeId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c', 'Exam');
        Candidate_Requirement__c canreq = new Candidate_Requirement__c(
            Name = nameLabel,
            Status__c = 'Initial',
            Exam__c = examCode,
            Candidate_Email__c = setRegistrationInfo.customerInfo.email,
            RecordTypeId = examCandidateReqRecordTypeId,
            Candidate_Commitment__c = ContractId
        );
        GARP_Common.debugLog('GARP_BC_Courses', 'createCourseProgramRequirement', 'canreq', canreq);
        return canreq;
    }

    /**
     * Main programs (SCR, Risk AI, RAIJ): creates exam registration (Exam_Attempt__c) using part1Info and consent/EPP.
     * Replaces createSCRExamRegistration, createRiskAIExamRegistration, createRAIJExamRegistration.
     * @param registrationType 'scr', 'raij', or 'riskai'
     * @return New Exam_Attempt__c (not inserted), or null if registrationType invalid
     */
    public static Exam_Attempt__c createExamRegistrationByType(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, List<Candidate_Requirement__c> contractRequirements, String registrationType) {
        GARP_Common.debugLog('GARP_BC_Courses', 'createExamRegistrationByType', 'registrationType', registrationType);
        String attemptRecordType;
        if (registrationType == 'scr') attemptRecordType = 'SCR';
        else if (registrationType == 'riskai') attemptRecordType = 'RiskAI';
        else if (registrationType == 'raij') attemptRecordType = 'RAIJ';
        else return null;
        Id examAttemptRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Attempt__c', attemptRecordType);
        Exam_Sites__c es = [SELECT Id, Name, Country__c, Exam_Part__c FROM Exam_Sites__c WHERE Id = :setRegistrationInfo.examSelectionInfo.part1Info.selectedSiteId];
        Exam_Attempt__c newExamAttempt = new Exam_Attempt__c(
            Member__c = setRegistrationReturnInfo.contactId,
            Exam_Site__c = setRegistrationInfo.examSelectionInfo.part1Info.selectedSiteId,
            Original_Exam_Site__c = es.Country__c,
            Exam_Administration__c = setRegistrationInfo.examSelectionInfo.part1Info.selectedAdminId,
            Original_Exam_Administration__c = setRegistrationInfo.examSelectionInfo.part1Info.selectedAdminId,
            Exam_Part__c = setRegistrationInfo.examSelectionInfo.part1Info.selectedPartId,
            Candidate_Commitment__c = setRegistrationReturnInfo.programId,
            Opportunity__c = setRegistrationReturnInfo.orderId,
            Pearson_Member_First_Name__c = setRegistrationInfo.customerInfo.firstName,
            Pearson_Member_Last_Name__c = setRegistrationInfo.customerInfo.lastName,
            RecordTypeId = examAttemptRecordTypeId
        );
        if (setRegistrationInfo.consentInfo != NULL) {
            if (setRegistrationInfo.consentInfo.privacyPolicyAttestation != NULL && setRegistrationInfo.consentInfo.privacyPolicyAttestation == True) {
                newExamAttempt.Privacy_Policy_Attestation__c = DateTime.now();
            }
            if (setRegistrationInfo.consentInfo.examPolicyAttestation != NULL && setRegistrationInfo.consentInfo.examPolicyAttestation == True) {
                newExamAttempt.Exam_Policy_Attestation__c = DateTime.now();
            }
            if (setRegistrationInfo.consentInfo.eppOutreachConsent != NULL) {
                newExamAttempt.EPP_Opt_In__c = DateTime.now();
            }
            // Case 00888108: Check consentInfo (preferred) or teamRegInfo (legacy frontend)
            if (setRegistrationInfo.consentInfo.consentReleaseExamResults != NULL && setRegistrationInfo.consentInfo.consentReleaseExamResults == True) {
                newExamAttempt.Consent_Release_Exam_Results__c = DateTime.now();
            }
        }
        // Case 00888108: Also check teamRegInfo for backwards compatibility with frontend
        if (newExamAttempt.Consent_Release_Exam_Results__c == null && setRegistrationInfo.teamRegInfo != NULL && setRegistrationInfo.teamRegInfo.consentReleaseExamResults != NULL && setRegistrationInfo.teamRegInfo.consentReleaseExamResults == True) {
            newExamAttempt.Consent_Release_Exam_Results__c = DateTime.now();
        }
        GARP_Common.debugLog('GARP_BC_Courses', 'createExamRegistrationByType', 'newExamAttempt', newExamAttempt);
        if (setRegistrationInfo.consentInfo != null && setRegistrationInfo.consentInfo.eppOutreachConsent != null && setRegistrationInfo.consentInfo.eppOutreachConsent) {
            List<Contact> lstContact = [SELECT Id, Exam_Prep_Provider_Outreach__c FROM Contact WHERE Id = :setRegistrationReturnInfo.contactId];
            if (!lstContact.isEmpty()) {
                lstContact[0].Exam_Prep_Provider_Outreach__c = True;
                update lstContact;
            }
        }
        return newExamAttempt;
    }

    /**
     * Course exams (FRR/ICBRR, FRR25, MicroCourse): creates exam registration (Exam_Attempt__c) from contract requirements and exam site.
     * Replaces createFRRExamRegistration, createFRR25ExamRegistration, createMicroCourseExamRegistration.
     * @param registrationType 'frr', 'frr25', or 'micro' (micro uses programType/courseCode from setRegistrationInfo.programRegistrationInfo.microCourseInfo)
     * @return New Exam_Attempt__c (not inserted), or null if registrationType invalid or requirement/site not found
     */
    public static Exam_Attempt__c createCourseExamRegistrationByType(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, List<Candidate_Requirement__c> contractRequirements, String registrationType) {
        GARP_Common.debugLog('GARP_BC_Courses', 'createCourseExamRegistrationByType', 'registrationType', registrationType);
        if (registrationType != 'frr' && registrationType != 'frr25' && registrationType != 'micro') return null;
        String contractRecordTypeName;
        String attemptRecordTypeName;
        String examCodeForSite;
        if (registrationType == 'micro') {
            if (setRegistrationInfo == null || setRegistrationInfo.programRegistrationInfo == null || setRegistrationInfo.programRegistrationInfo.microCourseInfo == null) return null;
            contractRecordTypeName = setRegistrationInfo.programRegistrationInfo.microCourseInfo.programType;
            attemptRecordTypeName = setRegistrationInfo.programRegistrationInfo.microCourseInfo.courseCode;
            examCodeForSite = setRegistrationInfo.programRegistrationInfo.microCourseInfo.courseCode;
        } else {
            contractRecordTypeName = (registrationType == 'frr') ? 'ICBRR Program' : 'FRR25 Program';
            attemptRecordTypeName = (registrationType == 'frr') ? 'ICBRR' : 'FRR25';
            examCodeForSite = (registrationType == 'frr') ? null : 'FRR25';
        }
        if (String.isBlank(contractRecordTypeName) || String.isBlank(attemptRecordTypeName)) return null;
        Id frrContractRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', contractRecordTypeName);
        Id examCandidateReqRecordTypeId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c', 'Exam');
        Id frrExamAttemptRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Attempt__c', attemptRecordTypeName);
        Id examCandidateReqId;
        for (Candidate_Requirement__c contreq : contractRequirements) {
            if (contreq.RecordTypeId == examCandidateReqRecordTypeId && contreq.Candidate_Commitment__r.RecordTypeId == frrContractRecordTypeId) {
                examCandidateReqId = contreq.Id;
                break;
            }
        }
        GARP_Common.debugLog('GARP_BC_Courses', 'createCourseExamRegistrationByType', 'examCandidateReqId', examCandidateReqId);
        if (examCandidateReqId == null) return null;
        Exam_Attempt__c newExamAttempt;
        if (registrationType == 'frr') {
            newExamAttempt = new Exam_Attempt__c(
                Member__c = setRegistrationReturnInfo.contactId,
                Exam_Site__c = Label.GARP_ICBRR_Exam_Site_Id,
                Original_Exam_Site__c = Label.GARP_ICBRR_Exam_Site_Id,
                Candidate_Commitment__c = setRegistrationReturnInfo.programId,
                Opportunity__c = setRegistrationReturnInfo.orderId,
                Pearson_Member_First_Name__c = setRegistrationInfo.customerInfo.firstName,
                Pearson_Member_Last_Name__c = setRegistrationInfo.customerInfo.lastName,
                Candidate_Requirement__c = examCandidateReqId,
                RecordTypeId = frrExamAttemptRecordTypeId
            );
        } else {
            List<Exam_Sites__c> lstExamSite = [SELECT Id FROM Exam_Sites__c WHERE Exam__r.Exam__c = :examCodeForSite];
            GARP_Common.debugLog('GARP_BC_Courses', 'createCourseExamRegistrationByType', 'lstExamSite', lstExamSite);
            if (lstExamSite.isEmpty()) return null;
            newExamAttempt = new Exam_Attempt__c(
                Member__c = setRegistrationReturnInfo.contactId,
                Exam_Site__c = lstExamSite[0].Id,
                Original_Exam_Site__c = lstExamSite[0].Id,
                Candidate_Commitment__c = setRegistrationReturnInfo.programId,
                Opportunity__c = setRegistrationReturnInfo.orderId,
                Pearson_Member_First_Name__c = setRegistrationInfo.customerInfo.firstName,
                Pearson_Member_Last_Name__c = setRegistrationInfo.customerInfo.lastName,
                Candidate_Requirement__c = examCandidateReqId,
                RecordTypeId = frrExamAttemptRecordTypeId
            );
        }
        GARP_Common.debugLog('GARP_BC_Courses', 'createCourseExamRegistrationByType', 'newExamAttempt', newExamAttempt);
        return newExamAttempt;
    }

    /**
     * Returns the most recent exam contract for the account and registration type.
     * Use this for main programs (SCR, RAIJ, Risk AI) instead of getExamContract, getRAIJExamContract, getRiskAIExamContract.
     * @param accountId Account Id
     * @param registrationType 'scr', 'raij', or 'riskai' (maps to RecordType 'SCR Program', 'RAIJ Program', 'Risk AI Program')
     * @return Contract or null
     */
    public static Contract getExamContractByType(Id accountId, String registrationType) {
        if (accountId == null || String.isBlank(registrationType)) {
            return null;
        }
        String recordTypeName;
        if (registrationType == 'scr') {
            recordTypeName = 'SCR Program';
        } else if (registrationType == 'raij') {
            recordTypeName = 'RAIJ Program';
        } else if (registrationType == 'riskai') {
            recordTypeName = 'Risk AI Program';
        } else {
            recordTypeName = registrationType;
        }
        List<Contract> contracts = [
            SELECT Id, Name, RecordTypeId, Status,
            (
                SELECT Id, Name, Status__c, Exam__c, RecordType.Name
                FROM Candidate_Requirements__r
            )
            FROM Contract
            WHERE
            AccountId = :accountId AND
            RecordType.Name = :recordTypeName AND
            (Status LIKE 'Activated%' OR Status = 'Completed' OR Status = 'Expired')
            ORDER BY StartDate DESC
            LIMIT 1
        ];
        return contracts.isEmpty() ? null : contracts[0];
    }

}