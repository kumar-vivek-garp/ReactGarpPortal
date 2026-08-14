public class GARP_BC_StudyMaterials {

    // Wrapper Classes
    
    // An eBook which was purchased
    // Each user can have many
    public class eBook {
        public Integer year;
        public String title;
        public String provider;
        public String productCode;
        public String accountingId;
        public List<eBookItem> eBookItems;
        
        public String key; // for FFR and FRR
        public String keyStatus;
        public Date expireDate;
        public Boolean isAPI;
        
        public String type; // FRM, SCR, RAIJ, FRR, FFR
        public String part; // I, II (for FRM only)
    }
    
    // An eBook which was purchased as part of a set
    public class eBookItem {
        public String title;
        public Integer vendorId; // mobius product Id
    }
    
    // Study Materials for Sale
    public class studyMaterial {
        
        public String materialType; // Download, Book, eBook, GARP Learning -- NEW
        
        public String title;
        public String description; // use in gallery
        public String shortDescription; // use in detail view
        public String imageURL;
        public Decimal displayOrder;
        
        // Owned
        public Boolean isOwned;
        public Boolean wasOrderedWithReg; // Bought with Reg
        public Date registrationDate;
        public Boolean wasPurchased; // Bought without Reg
        public Date orderedDate;
        public String orderId; // The Opp ID where this material was purchased
        public Boolean isUnPaidOrder; // Show View Order using ID below
        
        // Access
        public Boolean isComingSoon;  // Can be used for any type, if true do not show download, access, or purchase
        public Date comingSoonDate;
        public String leadGenURL;
        
        // Download
        public String downloadURL;  // For downloads
        
        // eBook
        public eBook eBook; // See this for access info
        
        // Book
        
        // Purcahsing
        public Boolean canPurchase; // Is available for purchase
        public Boolean isOutOfStock;
        public Decimal price;
        public Boolean isPreOrder;  // For Books only with shipping
        public Date preOrderShipDate;
        
        // GARP Learning
        public String GARPLearningAccessURL; // new
        
        // GARP Learning Add-on
        public Boolean hasGARPLearningAddOn; // Does this materila have an addon section? renamed hasBenchPrepPracticeExamAddOn
        
        // Add-on Purchase
        public Decimal GARPLearningAddOnPuchasePrice; // renamed benchPrepPracticeExamAddOnPrice
        public String GARPLearningAddOnPuchaseProductCode; // renamed benchPrepPracticeExamAddOnProductCode
        public String GARPLearningAddOnPuchaseHeading;
        public String GARPLearningAddOnPuchaseDescription;
        
        // Add-on Access
        public Boolean isGARPLearningAddOnOwned; // Already puchased Add-On
        public Date GARPLearningAddOnPurchasedDate;
        public String GARPLearningAddOnAccessHeading;
        public String GARPLearningAddOnAccessDescription;
        public String GARPLearningAddOnPuchasePendingOrder; // If has pending order
        
        // Old Stuff
        public String year; // For eBooks
        public String accessUrl;
        
        // Purcahsing Info
        public Boolean isAvailable;
        
        public Boolean isCompWithReg;   // Is Comp with Reg
        public Boolean isShippable;
        public Boolean isElectronicDelivery;
        public Boolean showInRegStudyMatSelection;
        public String productId;
        public String productCode;
        public String glCode;
        public String accountingId;
        public String relatedPart;
        public String sortCode;
        public Boolean selected;
        
        
        // Info for BenchPrep Practice Exam Add-On
        public Boolean hasBenchPrepPracticeExamAddOn;
        public Decimal benchPrepPracticeExamAddOnPrice;
        public String benchPrepPracticeExamAddOnProductCode;
       
        // Download Only Study Materials
        public studyMaterial(Content__c content) {
            materialType = 'Download';
            
            title = content.Content_Name__c;
            description = content.Story__c;
            shortDescription = content.Description__c;
            imageURL = content.Image__c;
            
            isOwned = False;
            
            wasOrderedWithReg = False;
            registrationDate = NULL;
            wasPurchased = False;
            orderedDate = NULL;
            
            isUnPaidOrder = False;
            orderId = NULL;
            
            isComingSoon = False;
            comingSoonDate = NULL;
            leadGenURL = NULL;
            
            downloadURL = content.Third_Party_URL__c;
            
            eBook = NULL;
            
            canPurchase = False;
            isOutOfStock = False;
            price = NULL;
            isPreOrder = False;
            preOrderShipDate = NULL;
            
            GARPLearningAccessURL = NULL;
            hasGARPLearningAddOn = False;
            
            // Add-on Purchase
            GARPLearningAddOnPuchasePrice = NULL;
            GARPLearningAddOnPuchaseProductCode = NULL;
            GARPLearningAddOnPuchaseHeading = NULL;
            GARPLearningAddOnPuchaseDescription = NULL;
            
            // Add-on Access
            isGARPLearningAddOnOwned = False;
            GARPLearningAddOnPurchasedDate = NULL;
            GARPLearningAddOnAccessHeading = NULL;
            GARPLearningAddOnAccessDescription = NULL;
            GARPLearningAddOnPuchasePendingOrder = NULL;
            
            // Old Stuff
            isAvailable = True;
            
            isCompWithReg = False;
            isShippable= False;
            isElectronicDelivery = True;            
            showInRegStudyMatSelection = False;
            productId = NULL;
            productCode = NULL;
            glCode = NULL;
            accountingId = NULL;
            relatedPart = null;
            sortCode = null;
            selected = False;
            wasOrderedWithReg = False;
        }
        
        // Can Purchase Study Materials
        // studyMatProd -- Current PriceBook Entry record to set properties
        public studyMaterial(PricebookEntry studyMatProd) {
            
            if(studyMatProd != NULL) {
                if(studyMatProd.Product2.Content__r != NULL) {
                    
                    title = studyMatProd.Product2.Content__r.Content_Name__c;
                    
                    materialType = 'Download';
                    if(title.IndexOf('eBook') > -1) {
                        materialType = 'eBook';
                    } else if(title.IndexOf('Book') > -1 || studyMatProd.Product2.ProductCode == 'RAIJH') {
                        materialType = 'Book';
                    } else if(title.IndexOf('GARP Learning') > -1 || studyMatProd.Product2.ProductCode == 'RAIJBP') {
                        materialType = 'GARP Learning';
                    }
                    
                    description = studyMatProd.Product2.Content__r.Story__c;
                    shortDescription = studyMatProd.Product2.Content__r.Description__c;
                    imageURL = studyMatProd.Product2.Content__r.Image__c;
                    if(title.toLowerCase().IndexOf('practice exam') == -1) {
                        showInRegStudyMatSelection = True;      
                    } else {
                        showInRegStudyMatSelection = False;        
                    }
                } else {
                    showInRegStudyMatSelection = False;        
                }
                
                isOwned = False;
            
                wasOrderedWithReg = False;
                registrationDate = NULL;
                wasPurchased = False;
                orderedDate = NULL;
                
                isUnPaidOrder = False;
                orderId = NULL;
                
                isComingSoon = False;
                comingSoonDate = NULL;
                leadGenURL = NULL;
                
                if(materialType == 'Download') {
                    downloadURL = studyMatProd.Product2.Content__r.Third_Party_URL__c;                
                } else {
                    downloadURL = NULL;
                }
                
                eBook = NULL;
                
                canPurchase = False;
                isOutOfStock = False;
                price = NULL;
                isPreOrder = False;
                preOrderShipDate = NULL;
                
                GARPLearningAccessURL = NULL;
                hasGARPLearningAddOn = False;
                
                // Add-on Purchase
                GARPLearningAddOnPuchasePrice = NULL;
                GARPLearningAddOnPuchaseProductCode = NULL;
                GARPLearningAddOnPuchaseHeading = NULL;
                GARPLearningAddOnPuchaseDescription = NULL;
                
                // Add-on Access
                isGARPLearningAddOnOwned = False;
                GARPLearningAddOnPurchasedDate = NULL;
                GARPLearningAddOnAccessHeading = NULL;
                GARPLearningAddOnAccessDescription = NULL;
                GARPLearningAddOnPuchasePendingOrder = NULL;
                
                // Old Stuff
                isCompWithReg = studyMatProd.Product2.Is_Comped_Registration__c;
                isShippable= studyMatProd.Product2.Is_Shippable__c;
                isElectronicDelivery= studyMatProd.Product2.Electronic_Delivery__c;
                productId = studyMatProd.Product2.Id;
                productCode = studyMatProd.Product2.ProductCode;
                glCode = studyMatProd.Product2.GL_Code__c;
                accountingId = studyMatProd.Product2.Product_ID__c;
                price = studyMatProd.UnitPrice;
                                
                Date tdy = Date.today();
                DateTime now = DateTime.now();
                
                isAvailable = False;
                isComingSoon = False;
                isPreOrder = False;
                if(studyMatProd.Product2.Pre_Order_Date__c != NULL) {
                    isPreOrder = True;
                    preOrderShipDate = studyMatProd.Product2.Pre_Order_Shipping_Date__c;
                    if(tdy > studyMatProd.Product2.Pre_Order_Date__c) {
                        isAvailable = True;
                        canPurchase = True;
                    } else {
                        isComingSoon = True;
                        comingSoonDate = studyMatProd.Product2.Pre_Order_Date__c;
                        leadGenURL = studyMatProd.Product2.Content__r.Lead_Gen_URL__c;
                    }
                } else if(studyMatProd.Product2.Content__r.Start_Date__c != NULL) {
                    if(now >= studyMatProd.Product2.Content__r.Start_Date__c) {
                        isAvailable = True;
                        canPurchase = True;
                    } else {
                        isComingSoon = True;
                        DateTime dt = studyMatProd.Product2.Content__r.Start_Date__c;
                        comingSoonDate = Date.NewInstance(dt.Year(), dt.Month(), dt.Day());
                        leadGenURL = studyMatProd.Product2.Content__r.Lead_Gen_URL__c;
                    }
                } else {
                    isAvailable = True;
                    canPurchase = True;
                }
                
                if(studyMatProd.Product2.Inventory__c != NULL && studyMatProd.Product2.Inventory__c <= 0) {
                    isOutOfStock = True;
                    isAvailable = False;
                    canPurchase = False;
                }
                
                // relatedPart
                relatedPart=null;
                sortCode=null;
                
                String sortInfo = getStudyMaterialSortInfo(productCode);                
                List<String> parts = sortInfo.split(':');
                if(parts.size() > 1) {
                    relatedPart = parts[0];
                    sortCode = parts[1];
                }
            }
        }
    }
    
    public static String getStudyMaterialSortInfo(String productCode) {
        String relatedPart;
        String sortCode;
        
        if(productCode == 'FRM1H') {
            relatedPart = 'Part 1';
            sortCode = '1A';
        } else if(productCode == 'FRM1BPPE') {
            relatedPart = 'Part 1';
            sortCode = '1B';
        } else if(productCode == 'FRM2H') { // Part II Book
            relatedPart = 'Part 2';
            sortCode = '2A';
        } else if(productCode == 'FRMBP2') { // Pay Part II GARP Learning
            relatedPart = 'Part 2';
            sortCode = '2A';
        } else if(productCode == 'FRMBP') { // Comp Part I GARP Learning
            relatedPart = 'Part 1';
            sortCode = '1A';
        } else if(productCode == 'FRMC2') { // Comp Part II Practice Exam
            relatedPart = 'Part 2';
            sortCode = '1B';
        } else {
            relatedPart = NULL;
            sortCode = '1A';
        }
        
        return relatedPart+':'+sortCode;
    }
    
    public static Boolean hasBenchPrepAccess(Exam_Attempt__c examAttempt) {
        GARP_Common.debugLog('GARP_BC_StudyMaterials','hasBenchPrepAccess','examAttempt',examAttempt);
        
        if(examAttempt == NULL) {
            return False;
        }
        
        Boolean hasBenchPrepAccess = False;
        Date tdy = Date.Today();
        
        Boolean awaitingSchedulingToOpen = False;   
        Boolean schedulingIsOpen = False;
        Boolean beforeLastTestingDate = False;
        GARP_BC_MyPrograms.examDatesInfo examDatesInfo = GARP_BC_MyPrograms.getExamDateInfo(examAttempt);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','hasBenchPrepAccess','examDatesInfo',examDatesInfo);
        if(examDatesInfo.examDate != NULL) {            
            if(tdy < examAttempt.Exam_Administration__r.Exam_Scheduling_Start_Date__c) {
                awaitingSchedulingToOpen = True;
            } else if(tdy >= examAttempt.Exam_Administration__r.Exam_Scheduling_Start_Date__c && (tdy <= examDatesInfo.schedulingCutoffDate || examAttempt.Allow_Scheduling_Override__c)) {
                schedulingIsOpen = True;
            } else if(tdy < examDatesInfo.lastTestingDate.addDays(1)) {
                beforeLastTestingDate = True;
            }
        }
            
        GARP_Common.debugLog('GARP_BC_StudyMaterials','hasBenchPrepAccess','awaitingSchedulingToOpen',awaitingSchedulingToOpen);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','hasBenchPrepAccess','schedulingIsOpen',schedulingIsOpen);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','hasBenchPrepAccess','beforeLastTestingDate',beforeLastTestingDate);
        
        if(examAttempt.Deferral_Status__c == 'Deferred Out' || awaitingSchedulingToOpen || schedulingIsOpen || beforeLastTestingDate) {
            
            if(examAttempt.RPT_Exam_Program__c == 'FRM' && examAttempt.RPT_Exam_Part__c == 'II') {
                hasBenchPrepAccess = True; 
            } else {
            	hasBenchPrepAccess = True;    
            }
        }        
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','hasBenchPrepAccess','final',hasBenchPrepAccess);
        return hasBenchPrepAccess;
    }
    
    public static Decimal getBookRegistrantPrice(String regType, Decimal currentPrice) {
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getBookRegistrantPrice','regType',regType);
        
        if(regType == 'scr' || regType == 'riskai' || regType == 'raij') {
            return 100;
        }
        
        return currentPrice;
    }
    
    public static Decimal getBookRegistrantPrice(Exam_Attempt__c examAttempt) {
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getBookRegistrantPrice','examAttempt',examAttempt);
        
        if(examAttempt == NULL || examAttempt.Opportunity__c == NULL || examAttempt.Opportunity__r.StageName != 'Closed') {
            return Null;
        }
        
        Decimal getBookRegistrantPrice = Null;
        Date tdy = Date.Today();
        
        Boolean awaitingSchedulingToOpen = False;   
        Boolean schedulingIsOpen = False;
        Boolean beforeLastTestingDate = False;
        GARP_BC_MyPrograms.examDatesInfo examDatesInfo = GARP_BC_MyPrograms.getExamDateInfo(examAttempt);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getBookRegistrantPrice','examDatesInfo',examDatesInfo);
        if(examDatesInfo.examDate != NULL) {            
            if(tdy < examAttempt.Exam_Administration__r.Exam_Scheduling_Start_Date__c) {
                awaitingSchedulingToOpen = True;
            } else if(tdy >= examAttempt.Exam_Administration__r.Exam_Scheduling_Start_Date__c && (tdy <= examDatesInfo.schedulingCutoffDate || examAttempt.Allow_Scheduling_Override__c)) {
                schedulingIsOpen = True;
            } else if(tdy < examDatesInfo.lastTestingDate.addDays(1)) {
                beforeLastTestingDate = True;
            }
        }
            
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getBookRegistrantPrice','awaitingSchedulingToOpen',awaitingSchedulingToOpen);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getBookRegistrantPrice','schedulingIsOpen',schedulingIsOpen);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getBookRegistrantPrice','beforeLastTestingDate',beforeLastTestingDate);
        
        if(examAttempt.Deferral_Status__c == 'Deferred Out' || awaitingSchedulingToOpen || schedulingIsOpen || beforeLastTestingDate) {
            
            if(examAttempt.RPT_Exam_Program__c == 'FRM' && examAttempt.RPT_Exam_Part__c == 'II') {
                getBookRegistrantPrice = 100; 
            } else {
              getBookRegistrantPrice = 100;    
            }
        }        
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getBookRegistrantPrice','final',getBookRegistrantPrice);
        return getBookRegistrantPrice;
    }
    
    public class studyMaterialsInfo {
        public List<studyMaterial> frmStudyMaterials;
        public List<studyMaterial> scrStudyMaterials;
        public List<studyMaterial> raiStudyMaterials;
        public List<studyMaterial> raijStudyMaterials;
        public List<studyMaterial> frrStudyMaterials;
    }

    public class getStudyMaterialsResult {
        public String status;
        public String message;
        public studyMaterialsInfo studyMaterialsInfo;
    }
    
    // Get all Study Materials for Sale
    public static getStudyMaterialsResult getStudyMaterials(string accountId, string contactId, MAP<String,Contract> mapContracts, MAP<String,GARP_BC_MyPrograms.enrolledProgramInfo> microCoursesMap, GARP_BC_Courses.microCourseConfig microCourseConfig) {
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','mapContracts',mapContracts);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','microCoursesMap',microCoursesMap);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','microCourseConfig',microCourseConfig);
        
        getStudyMaterialsResult result = new getStudyMaterialsResult();
        result.studyMaterialsInfo = new studyMaterialsInfo();
        studyMaterialsInfo studyMaterialsInfo = result.studyMaterialsInfo;
        studyMaterialsInfo.frmStudyMaterials = new List<studyMaterial>();
        studyMaterialsInfo.scrStudyMaterials = new List<studyMaterial>();
        studyMaterialsInfo.raiStudyMaterials = new List<studyMaterial>();
        studyMaterialsInfo.raijStudyMaterials = new List<studyMaterial>();
        studyMaterialsInfo.frrStudyMaterials = new List<studyMaterial>();
        
        GARP_BC_Registration.programRegistrationInfo frmSettings = GARP_BC_Exams.getFRMRegistrationSettings(null);
        GARP_BC_Registration.programRegistrationInfo scrSettings = GARP_BC_Courses.getSCRRegistrationSettings(null);
        GARP_BC_Registration.programRegistrationInfo raiSettings = GARP_BC_Courses.getRiskAIRegistrationSettings(null);
        GARP_BC_Registration.programRegistrationInfo raijSettings = GARP_BC_Courses.getRAIJRegistrationSettings(null);
        GARP_BC_Registration.programRegistrationInfo frrSettings = GARP_BC_Courses.getFRRRegistrationSettings(null);
        GARP_BC_Registration.programRegistrationInfo frr25Settings = GARP_BC_Courses.getFRR25RegistrationSettings(null);
        GARP_BC_Registration.programRegistrationInfo ffrSettings = GARP_BC_Courses.getFFRRegistrationSettings(null); // US-63665: FFR B2B Registration
        
        List<String> frmStudyMatProductCodes = frmSettings.studyMatProductCodes;
        List<String> scrStudyMatProductCodes = scrSettings.studyMatProductCodes;
        List<String> raiStudyMatProductCodes = raiSettings.studyMatProductCodes;
        List<String> raijStudyMatProductCodes = raijSettings.studyMatProductCodes;
        List<String> frrStudyMatProductCodes = frrSettings.studyMatProductCodes;
        List<String> frr25StudyMatProductCodes = frr25Settings.studyMatProductCodes;

        // Get Main Exam Codes to check if opp has a registration
        Set<String> frmRegProductCodes = new Set<String>();
        frmRegProductCodes.AddAll(frmSettings.mainProductCodes);
        frmRegProductCodes.AddAll(frmSettings.teamProductCodes);

        Set<String> scrRegProductCodes = new Set<String>();
        scrRegProductCodes.AddAll(scrSettings.mainProductCodes);
        scrRegProductCodes.AddAll(scrSettings.teamProductCodes);

        Set<String> raiRegProductCodes = new Set<String>();
        raiRegProductCodes.AddAll(raiSettings.mainProductCodes);
        raiRegProductCodes.AddAll(raiSettings.teamProductCodes);

        Set<String> raijRegProductCodes = new Set<String>();
        raijRegProductCodes.AddAll(raijSettings.mainProductCodes);
        raijRegProductCodes.AddAll(raijSettings.teamProductCodes);        
        
        Set<String> frrRegProductCodes = new Set<String>();
        frrRegProductCodes.add(frrSettings.mainMemberProductCode);
        frrRegProductCodes.add(frrSettings.mainNonMemberProductCode);
        frrRegProductCodes.add(frrSettings.retakeProductCode);
        frrRegProductCodes.AddAll(frrSettings.teamProductCodes);

        Set<String> frr25RegProductCodes = new Set<String>();
        frr25RegProductCodes.add(frr25Settings.mainMemberProductCode);
        frr25RegProductCodes.add(frr25Settings.mainNonMemberProductCode);
        frr25RegProductCodes.add(frr25Settings.retakeProductCode);
        frr25RegProductCodes.AddAll(frr25Settings.teamProductCodes);
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','frmRegProductCodes',frmRegProductCodes);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','scrRegProductCodes',scrRegProductCodes);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','raiRegProductCodes',raiRegProductCodes);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','raijRegProductCodes',raijRegProductCodes);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','frrRegProductCodes',frrRegProductCodes);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','frr25RegProductCodes',frr25RegProductCodes);
        
        // Micro Course
        Set<String> microCoursesRegProductCode = new Set<String>();
        Set<String> microCoursesStudyMatProductCode = new Set<String>();
        
        if(microCourseConfig != NULL && microCourseConfig.mapMicroCourseByCode != NULL) {
            for(GARP_BC_Courses.microCourseInfo mci :microCourseConfig.mapMicroCourseByCode.Values()) {
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','microCouse',mci.courseCode);
                
                microCoursesRegProductCode.add(mci.nonMemberProductCode);
                microCoursesRegProductCode.add(mci.memberProductCode);
                microCoursesRegProductCode.add(mci.certifiedProductCode);
                microCoursesRegProductCode.add(mci.retakeProductCode);
                
                for(String studyMatProdCode: mci.studyMaterialProductCodes){ 
                    microCoursesStudyMatProductCode.add(studyMatProdCode);
                }
            }
        }
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','microCoursesRegProductCode',microCoursesRegProductCode);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','microCoursesStudyMatProductCode',microCoursesStudyMatProductCode);
        
        GARP_BC_MyPrograms.returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contactId);
        MAP<String,Exam_Attempt__c> mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;
        
        Boolean hasFRMBenchPrepAccess = False;
        Exam_Attempt__c frm1ExamAttempt = mapLatestExamAttempts.get('FRMI');
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','frm1ExamAttempt',frm1ExamAttempt);
        
        if(frm1ExamAttempt != NULL) {
            hasFRMBenchPrepAccess = hasBenchPrepAccess(frm1ExamAttempt);
        }
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','hasFRMBenchPrepAccess',hasFRMBenchPrepAccess);
        
        Boolean hasFRMBenchPrep2Access = False;
        Exam_Attempt__c frm2ExamAttempt = mapLatestExamAttempts.get('FRMII');
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','frm2ExamAttempt',frm2ExamAttempt);
        
        if(frm2ExamAttempt != NULL) {
            hasFRMBenchPrep2Access = hasBenchPrepAccess(frm2ExamAttempt);
        }
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','hasFRMBenchPrep2Access',hasFRMBenchPrep2Access);
        
        
        Boolean hasSCRBenchPrepAccess = False;
        Decimal scrRegistrantPrice;

        Exam_Attempt__c scrExamAttempt = mapLatestExamAttempts.get('SCRFull');
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','scrExamAttempt',scrExamAttempt);
        
        if(scrExamAttempt != NULL) {
            hasSCRBenchPrepAccess = hasBenchPrepAccess(scrExamAttempt);
            scrRegistrantPrice = getBookRegistrantPrice(scrExamAttempt);
        }
        
        Boolean hasRAIBenchPrepAccess = False;
        Decimal raiRegistrantPrice;        
        Exam_Attempt__c raiExamAttempt = mapLatestExamAttempts.get('RiskAIFull');
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','raiExamAttempt',raiExamAttempt);
        
        if(raiExamAttempt != NULL) {
            hasRAIBenchPrepAccess = hasBenchPrepAccess(raiExamAttempt);
            raiRegistrantPrice = getBookRegistrantPrice(raiExamAttempt);
        }
        
        Boolean hasRAIJBenchPrepAccess = False;
        Decimal raijRegistrantPrice;
        Exam_Attempt__c raijExamAttempt = mapLatestExamAttempts.get('RAIJFull');
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','raijExamAttempt',raijExamAttempt);
        
        if(raijExamAttempt != NULL) {
            hasRAIJBenchPrepAccess = hasBenchPrepAccess(raijExamAttempt);
            raijRegistrantPrice = getBookRegistrantPrice(raijExamAttempt);
        }
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','hasFRMBenchPrepAccess',hasFRMBenchPrepAccess);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','hasSCRBenchPrepAccess',hasSCRBenchPrepAccess);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','hasRAIBenchPrepAccess',hasRAIBenchPrepAccess);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','hasRAIJBenchPrepAccess',hasRAIJBenchPrepAccess);
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','scrRegistrantPrice',scrRegistrantPrice);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','raiRegistrantPrice',raiRegistrantPrice);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','raijRegistrantPrice',raijRegistrantPrice);
        
        Boolean hasFRR25BenchPrepAccess = False;
        Boolean hasFRR25HardBookAccess = False;
        MAP<String,GARP_BC_Courses.microCourseInfo> microCoursesBenchPrepAccess = new MAP<String,GARP_BC_Courses.microCourseInfo>();
        MAP<String,GARP_BC_Courses.microCourseInfo> microCoursesHardBookAccess = new MAP<String,GARP_BC_Courses.microCourseInfo>();
        MAP<String,GARP_BC_Courses.microCourseInfo> microCoursesStudyMaterials = new MAP<String,GARP_BC_Courses.microCourseInfo>();

        Contract frr25Contract = mapContracts.get('FRR25_Program');
        if(frr25Contract != NULL && (frr25Contract.Status == 'Activated' || frr25Contract.Status == 'Activated ( Auto-Renew )')) {
            hasFRR25BenchPrepAccess = True;
            hasFRR25HardBookAccess = True;
        }
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','hasFRR25BenchPrepAccess',hasFRR25BenchPrepAccess);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','hasFRR25HardBookAccess',hasFRR25HardBookAccess);
        
        // Micro Course
        if(microCourseConfig != NULL && microCourseConfig.mapMicroCourseByCode != NULL) {            
            for(GARP_BC_Courses.microCourseInfo mci :microCourseConfig.mapMicroCourseByCode.Values()) {
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','microCouse',mci.courseCode);
                
                for(String studyMatProdCode: mci.studyMaterialProductCodes) {                    
                    microCoursesStudyMaterials.put(studyMatProdCode, mci);
                } 
                
                Contract mcContract = mapContracts.get(mci.programRecordTypeAPIName);
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','mcContract',mcContract);                               
                
                if(mcContract != NULL && (mcContract.Status == 'Activated' || mcContract.Status == 'Activated ( Auto-Renew )')) {
                    for(String studyMatProdCode: mci.studyMaterialProductCodes) {
                        if(studyMatProdCode.indexOf('BP') > -1) {
                            microCoursesBenchPrepAccess.put(studyMatProdCode, mci);    
                        } else {
                            microCoursesHardBookAccess.put(studyMatProdCode, mci);    
                        }
                    }
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','microCoursesBenchPrepAccess',microCoursesBenchPrepAccess);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','microCoursesHardBookAccess',microCoursesHardBookAccess);
        
        // Get Study Materials Products
        List<String> productCodes = new List<String>();
        productCodes.addAll(frmStudyMatProductCodes);
        productCodes.addAll(scrStudyMatProductCodes);
        productCodes.addAll(raiStudyMatProductCodes);
        productCodes.addAll(raijStudyMatProductCodes);
        productCodes.addAll(frrStudyMatProductCodes);
        productCodes.addAll(frr25StudyMatProductCodes);
        productCodes.addAll(microCoursesStudyMatProductCode);
        MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(productCodes, null); 
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','mapProdByCodes',mapProdByCodes);
        
        // Get Study Material Content
        List<Exam_Group__c> lstExamGroups = [select Id, Active__c, FRR_Study_Materials_Folder__c, FRM_Study_Materials_Folder__c, 
                                             SCR_Study_Materials_Folder__c, RiskAI_Study_Materials_Folder__c, Recordtype.Developername 
                                             from Exam_Group__c
                                             where Active__c = True OR SCR_Active__c = True OR Name = 'ICBRR'];
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','lstExamGroups',lstExamGroups);
        
        List<String> folderIds = new List<String>();
        String frrFolderID;
        String frmFolderID;
        String scrFolderID;
        String raiFolderID;
        String raijFolderID;
        
        Boolean isICBRRActive = False;
        
        for(Exam_Group__c eg :lstExamGroups) {
            String rtName = eg.Recordtype.Developername;
            if(rtName == 'ICBRR') {
                isICBRRActive = eg.Active__c;
                if(eg.FRR_Study_Materials_Folder__c != NULL) {
                    folderIds.add(eg.FRR_Study_Materials_Folder__c);
                    frrFolderID = eg.FRR_Study_Materials_Folder__c;
                }
            } else if(rtName == 'FRM_ERP') {
                if(eg.FRM_Study_Materials_Folder__c != NULL) {
                    folderIds.add(eg.FRM_Study_Materials_Folder__c);
                    frmFolderID = eg.FRM_Study_Materials_Folder__c;
                }
            } else if(rtName == 'SCR') {
                if(eg.SCR_Study_Materials_Folder__c != NULL) {
                    folderIds.add(eg.SCR_Study_Materials_Folder__c);
                    scrFolderID = eg.SCR_Study_Materials_Folder__c;
                }
            } else if(rtName == 'RiskAI') {
                if(eg.RiskAI_Study_Materials_Folder__c != NULL) {
                    folderIds.add(eg.RiskAI_Study_Materials_Folder__c);
                    raiFolderID = eg.RiskAI_Study_Materials_Folder__c;
                }
            } else if(rtName == 'RAIJ' && raijExamAttempt != NULL) {
                if(eg.RiskAI_Study_Materials_Folder__c != NULL) {
                    folderIds.add(eg.RiskAI_Study_Materials_Folder__c);
                    raijFolderID = eg.RiskAI_Study_Materials_Folder__c;
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','folderIds',folderIds);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','frrFolderID',frrFolderID);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','frmFolderID',frmFolderID);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','scrFolderID',scrFolderID);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','raiFolderID',raiFolderID);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','raijFolderID',raijFolderID);
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','isICBRRActive',isICBRRActive);
        
        
        List<Content__c> lstDocs = [SELECT Id, Name, Content_Name__c, Story__c, Image__c, Third_Party_URL__c, 
                                    Description__c, Lead_Gen_URL__c,
                                    (select id, Folder__c from Content_Folders__r),
                                    (select id, Name, ProductCode, GL_Code__c from Products__r)
                                    FROM Content__c 
                                    WHERE Status__c = 'Active' AND Id in (SELECT Content__c FROM Content_Folders__c WHERE Folder__c = :folderIds) ORDER BY Display_Sort_Order__c];
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','lstDocs',lstDocs);
        
        List<Opportunity> lstOpportunity = [
            SELECT Id, Name, StageName, Amount, CloseDate,
            (
                SELECT Id, ProductCode, Product2.ProductCode, Description, PricebookEntryId, Quantity,
                UnitPrice, SortOrder, TotalPrice, Product_ID__c, Cancel_Refunded__c 
                FROM OpportunityLineItems
            ) 
            FROM Opportunity 
            WHERE AccountId = :accountId AND ((StageName = 'Closed' AND ia_crm__Intacct_Transaction__c in ('Salesforce - Sales Invoice','Salesforce - Bulk Order')) OR (StageName = 'New Lead'))
        ];
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','lstOpportunity',lstOpportunity);
        
        MAP<String,Opportunity> mapOppsByProductId = new MAP<String,Opportunity>();
        MAP<String,Integer> mapOppCountByProductId = new MAP<String,Integer>();
        SET<String> oppsWithReg = new SET<String>();
        SET<String> benchPrepPracticeExamAddOnPurchasedProductIds = new SET<String>();
        Opportunity benchPrepPracticeExamAddOnPurchasedOrder;
        
        if(!lstOpportunity.IsEmpty()) {
            for(Opportunity opp :lstOpportunity) {
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Loop Opp',opp);
                
                if(opp.OpportunityLineItems != NULL) {
                    for(OpportunityLineItem line :opp.OpportunityLineItems) {
                        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Loop LineItem',line);
                        
                        // Check for Reg Product
                        if(frmRegProductCodes.Contains(line.Product2.ProductCode) || scrRegProductCodes.Contains(line.Product2.ProductCode) ||
                            raiRegProductCodes.Contains(line.Product2.ProductCode) || raijRegProductCodes.Contains(line.Product2.ProductCode) || 
                            frrRegProductCodes.Contains(line.Product2.ProductCode) || 
                            frr25RegProductCodes.Contains(line.Product2.ProductCode) || microCoursesRegProductCode.Contains(line.Product2.ProductCode) ) {
                                
                            oppsWithReg.add(opp.Id);
                        }
                        
                        // Add to List of benchPrepPracticeExamAddOns
                        if(line.Product2.ProductCode == 'FRM1BPPE') {
                            benchPrepPracticeExamAddOnPurchasedProductIds.add(line.Product_ID__c);
                            benchPrepPracticeExamAddOnPurchasedOrder = opp;
                        }
                        
                        if(line.Product_ID__c != NULL) {
                            mapOppsByProductId.put(line.Product_ID__c, opp);        
                            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add LineItem',line);
                            
                            Integer cnt = mapOppCountByProductId.get(line.Product_ID__c);
                            if(cnt != NULL) {
                                cnt++;
                            } else {
                                cnt=1;
                            }
                            mapOppCountByProductId.put(line.Product_ID__c, cnt);
                            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add Opp Cnt',cnt);
                        }
                    }
                }
                
            }
        }
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','oppsWithReg',oppsWithReg);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','mapOppCountByProductId',mapOppCountByProductId);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','benchPrepPracticeExamAddOnPurchasedProductIds',benchPrepPracticeExamAddOnPurchasedProductIds);
        
        List<Product_Refunds__c> refundData = [
            SELECT Id, Product_ID__c, Refund_amount__c, Opportunity__c, Opportunity__r.AccountId, Product__r.ProductCode, Product__r.Product_ID__c 
            FROM Product_Refunds__c 
            WHERE Status__c = 'Completed' AND Opportunity__c IN :lstOpportunity
        ];
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','refundData',refundData);
        
        MAP<String,Integer> mapRefundCountByProductId = new MAP<String,Integer>();
        if(!refundData.IsEmpty()) {
            for(Product_Refunds__c pr :refundData) {
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Loop Product_Refunds__c',pr);
                
                Integer cnt = mapRefundCountByProductId.get(pr.Product_ID__c);
                if(cnt != NULL) {
                    cnt++;
                } else {
                    cnt=1;
                }
                mapRefundCountByProductId.put(pr.Product_ID__c, cnt);
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add Refund Cnt',cnt);
            }
        }
        
        List<eBook> eBooks = getMyEBooks(accountId, lstOpportunity);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','eBooks',eBooks);
        
        MAP<string,eBook> mapEBooks = new MAP<string,eBook>();
        if(!eBooks.IsEmpty()) {
            for(eBook eb :eBooks) {
                if(eb.accountingId != NULL) {
                    mapEBooks.put(eb.accountingId, eb);    
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','mapEBooks',mapEBooks);
        
        Boolean hasBenchPrepPracticeExamAddOn = False;
        
        PricebookEntry benchPrepPracticeExamAddOnPbe;
        Date tdy = Date.Today();
        
        for(Content__c doc :lstDocs) {
            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Loop Content__c',doc);
            
            String folderId;
            Product2 materialProduct;
                
            if(doc.Content_Folders__r != NULL) {
                for(Content_Folders__c cf :doc.Content_Folders__r) {
                    if(cf.Folder__c != NULL) {
                    	folderId = cf.Folder__c;    
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','folderId',folderId);
           
            Integer prodCnt = 0;        
            Boolean hasProducts = False;
            if(doc.Products__r != NULL && !doc.Products__r.IsEmpty()) {
                prodCnt = doc.Products__r.Size() - 1;
                hasProducts = True;
            }
            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','prodCnt',prodCnt);
            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','hasProducts',hasProducts);
            
            Integer productIdx = 0;
            while(productIdx <= prodCnt) {
            
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','productIdx',productIdx);
                                
                if(hasProducts) {
                    materialProduct = doc.Products__r[productIdx];
                } else {
                    materialProduct = Null;
                }
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','materialProduct',materialProduct);

                
                if(folderId != NULL) {
                    studyMaterial studyMat;
                    if(materialProduct != NULL && materialProduct.ProductCode != NULL && materialProduct.GL_Code__c != NULL) {
                        
                        PricebookEntry pbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, materialProduct.ProductCode, materialProduct.GL_Code__c);
                        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','find pbe',pbe);
                        
                        if(pbe == NULL) {
                            result.status = 'Failed';
                            result.message = 'Product not found';
                            return result;
                        }
                        studyMat = new studyMaterial(pbe);
                        
                        // Save info about BenchPrep Practice Exam 3
                        if(materialProduct.ProductCode == 'FRM1BPPE') {
                            benchPrepPracticeExamAddOnPbe = pbe;
                        }
                    
                    } else {
                        studyMat = new studyMaterial(doc);
                    }
                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','studyMat',studyMat);
                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','benchPrepPracticeExamAddOnPbe',benchPrepPracticeExamAddOnPbe);
                    
                    // If Pay For Study Materials
                    if(studyMat != NULL) {
                        if(studyMat.accountingId != NULL) {
                            
                            // Add Order Info
                            Opportunity fndOpp = mapOppsByProductId.get(studyMat.accountingId);
                            Integer oppCnt = mapOppCountByProductId.get(studyMat.accountingId);
                            Integer refundCnt = mapRefundCountByProductId.get(studyMat.accountingId);
                            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','fndOpp',fndOpp);
                            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','oppCnt',oppCnt);
                            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','refundCnt',refundCnt);
                            
                            if(fndOpp != NULL && fndOpp.StageName == 'Closed' && oppCnt != NULL && (refundCnt == NULL || oppCnt > refundCnt)) {
                                studyMat.isOwned = True;
                                studyMat.orderId = fndOpp.Id;
                                
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add Order info 1',studyMat);
                                
                                if(oppsWithReg.Contains(fndOpp.Id)) {
                                    studyMat.wasOrderedWithReg = True;
                                    studyMat.registrationDate = fndOpp.CloseDate;
                                } else {
                                    studyMat.wasPurchased = True;
                                    studyMat.orderedDate = fndOpp.CloseDate;
                                }
                                
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','wasOrderedWithReg',studyMat.wasOrderedWithReg);
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','registrationDate',studyMat.registrationDate);
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','wasPurchased',studyMat.wasPurchased);
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','orderedDate',studyMat.orderedDate);
                                
                                
                                if(benchPrepPracticeExamAddOnPbe != NULL && benchPrepPracticeExamAddOnPurchasedProductIds.contains(benchPrepPracticeExamAddOnPbe.Product2.Product_ID__c)) {
                                    hasBenchPrepPracticeExamAddOn = True;
                                }
                                
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add Order info 3',studyMat);
                                
                            } else if(fndOpp != NULL && fndOpp.StageName == 'New Lead') {
                                studyMat.isOwned = False;
                                studyMat.isUnPaidOrder = True;
                                studyMat.orderId = fndOpp.Id;
                                
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add UnPaid Order info',studyMat);
                            }
                            
                            // Add eBook Info
                            eBook fndEBook = mapEBooks.get(studyMat.accountingId);
                            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','fndEBook',fndEBook);
                            
                            if(fndEBook != NULL) {
                                studyMat.eBook = fndEBook;
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add eBook info',studyMat);
                            }
                        }
                        
                        
                        
                        if(folderId == frmFolderID) {
                            
                            // Special Rules for Practice Exam Access
                            if(studyMat.productCode == 'FRM1BPPE') {
                                
                                // Skip the BenchPrep Practice Exam Add-On
                                
                            } else if(studyMat.productCode == 'FRMBP') {
                                if(hasFRMBenchPrepAccess) {
                                    studyMat.GARPLearningAccessURL = getBenchPrepSSOLink(contactId,'FRM','1');
                                    studyMaterialsInfo.frmStudyMaterials.add(studyMat);
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add frmStudyMaterials',studyMat);
                                }
                            } else if(studyMat.productCode == 'FRMBP2') {
                                if(hasFRMBenchPrep2Access) {
                                    studyMat.GARPLearningAccessURL = getBenchPrepSSOLink(contactId,'FRM','2');
                                    studyMaterialsInfo.frmStudyMaterials.add(studyMat);
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add frmStudyMaterials',studyMat);
                                }
                            } else if(studyMat.productCode == 'FRMC2') {
                                if(frm2ExamAttempt != NULL && frm2ExamAttempt.Result__c == Null && hasFRMBenchPrep2Access) {
                                    studyMaterialsInfo.frmStudyMaterials.add(studyMat);    
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add Practice Exam II frmStudyMaterials',studyMat);
                                }
                            } else {
                                studyMaterialsInfo.frmStudyMaterials.add(studyMat);    
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add frmStudyMaterials',studyMat);
                            }
                            
                            
                        } else if(folderId == scrFolderID) {
                            
                            if(studyMat.productCode == 'SCRBP') {
                                if(hasSCRBenchPrepAccess) {
                                    studyMat.GARPLearningAccessURL = getBenchPrepSSOLink(contactId,'SCR','Full');
                                    studyMaterialsInfo.scrStudyMaterials.add(studyMat);
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add scrStudyMaterials',studyMat);
                                }
                                
                            } else if(studyMat.productCode == 'SCRH' ) {
                                studyMaterialsInfo.scrStudyMaterials.add(studyMat);
                                if(scrRegistrantPrice != NULL) {
                                    studyMat.price = scrRegistrantPrice;
	                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add SCR Book Discount',studyMat);
                                }
                            } else {
                                studyMaterialsInfo.scrStudyMaterials.add(studyMat);
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add scrStudyMaterials',studyMat);
                            }
                            
                        } else if(folderId == raiFolderID) {
                            
                            if(studyMat.productCode == 'RAIBP') {
                                if(hasRAIBenchPrepAccess) {
                                    studyMat.GARPLearningAccessURL = getBenchPrepSSOLink(contactId,'RAI','Full');
                                    studyMaterialsInfo.raiStudyMaterials.add(studyMat);
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add raiStudyMaterials',studyMat);
                                }
                            } else if(studyMat.productCode == 'RAIH' ) {
                                studyMaterialsInfo.raiStudyMaterials.add(studyMat);
                                if(raiRegistrantPrice != NULL) {
                                    studyMat.price = raiRegistrantPrice;
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add RAI Book Discount',studyMat);
                                }                   
                            } else {
                                studyMaterialsInfo.raiStudyMaterials.add(studyMat);
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add raiStudyMaterials',studyMat);
                            }
                            
                        } else if(folderId == raijFolderID) {
                            
                            if(studyMat.productCode == 'RAIJBP') {
                                if(hasRAIJBenchPrepAccess) {
                                    studyMat.GARPLearningAccessURL = getBenchPrepSSOLink(contactId,'RAIJ','Full');
                                    studyMaterialsInfo.raijStudyMaterials.add(studyMat);
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add raijStudyMaterials',studyMat);
                                }
                            } else if(studyMat.productCode == 'RAIJH' || studyMat.productCode == 'RAIJHC') {
                                studyMaterialsInfo.raijStudyMaterials.add(studyMat);
                                if(raijRegistrantPrice != NULL) {
                                    studyMat.price = raijRegistrantPrice;
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add RAIJ Book Discount',studyMat);
                                }
                            } else {
                                studyMaterialsInfo.raijStudyMaterials.add(studyMat);
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add raijStudyMaterials',studyMat);
                            }
                            
                        } else if(folderId == frrFolderID) {
                            
                            GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','frrFolderID',folderId);
                            
                            if(studyMat.productCode == 'CBRX') {
                                                            
                                if(studyMat.materialType == 'eBook') {
                                    // Set accessUrl for eBook
                                    GARP_BC_StudyMaterials.eBook myEBook = GARP_BC_StudyMaterials.getMostRecentEBook(NULL, 'FRR', NULL, eBooks);
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','FRR myEBook',myEBook);
                                    
                                    if(myEBook != NULL) {
                                        studyMat.accessUrl = System.Label.GARP_Glose_FRR_Access_URL + myEBook.key;
                                    }
                                }
                                
                                if(isICBRRActive || (!isICBRRActive && studyMat.accessUrl != NULL)) {
                                    studyMaterialsInfo.frrStudyMaterials.add(studyMat);                        
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add frrStudyMaterials',studyMat);                                
                                }
    
                            } else if(studyMat.productCode == 'CBRHB') {
                                if(isICBRRActive) {
                                    studyMaterialsInfo.frrStudyMaterials.add(studyMat);  
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Other FRR Material',studyMat);         
                                }
                                
                            } else if(studyMat.productCode == 'FRRSBP') {
                                
                                // Only add if has access, no one can buy
                                if(hasFRR25BenchPrepAccess) {
                                    studyMat.GARPLearningAccessURL = getBenchPrepSSOLink(contactId,'FRR25','Full');
                                    studyMaterialsInfo.frrStudyMaterials.add(studyMat);
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add frr25 benchprep',studyMat);
                                }
                                
                            } else if(studyMat.productCode == 'FRRSHB') {
                                
                                if(hasFRR25HardBookAccess) {
                                    studyMaterialsInfo.frrStudyMaterials.add(studyMat);  
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add frr25 hard book',studyMat);                                
                                }                            
                                
                            } else if(microCoursesStudyMaterials.get(studyMat.productCode) != NULL) {
                                
                                // Micro Course
                                GARP_BC_Courses.microCourseInfo mcBPExam = microCoursesBenchPrepAccess.get(studyMat.productCode);
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','mcBPExam',mcBPExam);
                                
                                if(mcBPExam != NULL) {
                                    studyMat.GARPLearningAccessURL = getBenchPrepSSOLink(contactId,mcBPExam.courseCode,'Full');
                                    studyMaterialsInfo.frrStudyMaterials.add(studyMat);
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add mc benchprep',studyMat);
                                }
                                
                                GARP_BC_Courses.microCourseInfo mcHBExam = microCoursesHardBookAccess.get(studyMat.productCode);
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','mcHBExam',mcHBExam);
                                
                                if(mcHBExam != NULL) {
                                    studyMaterialsInfo.frrStudyMaterials.add(studyMat);
                                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Add mc benchprep',studyMat);
                                }                            
                            } else {
                                studyMaterialsInfo.frrStudyMaterials.add(studyMat);  
                                GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','Other FRR Material',studyMat);                                
                            }					
                        }
                    }
                }
                productIdx++;
            }
        }
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterials','hasBenchPrepPracticeExamAddOn',hasBenchPrepPracticeExamAddOn);
        
        // Update info for BenchPrep Practice Exam 3 Add-On
        if(!studyMaterialsInfo.frmStudyMaterials.IsEmpty()) {
            for(studyMaterial sm :studyMaterialsInfo.frmStudyMaterials) {
                if(sm.productCode == 'FRMBP') {
                    sm.hasGARPLearningAddOn = TRUE;
                    if(!hasBenchPrepPracticeExamAddOn && benchPrepPracticeExamAddOnPbe != NULL) {
                        sm.isGARPLearningAddOnOwned = False;
                        sm.GARPLearningAddOnPuchasePrice = benchPrepPracticeExamAddOnPbe.UnitPrice;
                        sm.GARPLearningAddOnPuchaseProductCode = 'FRM1BPPE';
                        sm.GARPLearningAddOnPuchaseHeading = 'Upgrade for Additional Content';
                        sm.GARPLearningAddOnPuchaseDescription = 'Looking for additional prep questions? Purchase a third full-length practice exam for the FRM Part I.';
                        if(benchPrepPracticeExamAddOnPurchasedOrder != NULL && benchPrepPracticeExamAddOnPurchasedOrder.StageName == 'New Lead') {
                            sm.GARPLearningAddOnPuchasePendingOrder = benchPrepPracticeExamAddOnPurchasedOrder.Id;
                        }
                    } else {
                        sm.isGARPLearningAddOnOwned = True;
                        sm.GARPLearningAddOnPurchasedDate = benchPrepPracticeExamAddOnPurchasedOrder.CloseDate;
                        sm.GARPLearningAddOnAccessHeading = 'Add-On Content';
                        sm.GARPLearningAddOnAccessDescription = 'Access your third full-length practice exam for the FRM Part I.';
                        
                    }
                    
                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getStudyMaterial','update BenchPrep Practice Exam 3',sm);
                }
            }    
        }


        result.status = 'Success';
        return result;
    }
    
    public static List<eBook> getMyElectronicStudyMaterials(String accountId, List<Opportunity> lstOpportunity) {
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyElectronicStudyMaterials','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyElectronicStudyMaterials','lstOpportunity',lstOpportunity);
        
        List<eBook> eMaterials = new List<eBook>();
        
        List<GARP_BC_StudyMaterials.eBook> eBooks = getMyEBooks(accountId, lstOpportunity);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyElectronicStudyMaterials','eBooks',eBooks);
                
        if(!eBooks.IsEmpty()) {
            for(GARP_BC_StudyMaterials.eBook eb :eBooks) {
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyElectronicStudyMaterials','Loop eBooks',eb);
                
                eMaterials.add(eb);
                
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyElectronicStudyMaterials','Add eBooks',eMaterials);
                
                // Expand eBook to Practice Exam
                // So later if we exclude eBook, cause they already have it we also exclude Practice Exam
                if(eb.productCode == 'FRM1X') {
                    // Convert 23FRM1X into 23FRM1PE
                    String newAccountingId;
                    if(eb.accountingId != NULL) {
                        newAccountingId = eb.accountingId.Left(6) + 'PE';                        
                    } else if(eb.year != NULL) {                        
                        newAccountingId = string.valueof(eb.year).right(2) + 'FRM1PE'; 
                    }
                    GARP_BC_StudyMaterials.eBook newEBook = new GARP_BC_StudyMaterials.eBook();
                    newEBook.title = eb.title + ' Practice Exam';
                    newEBook.provider = eb.provider;
                    newEBook.productCode = eb.productCode + 'PE';
                    newEBook.accountingId = newAccountingId;
                    newEBook.type = eb.type;
                    newEBook.part = eb.part;
                    newEBook.expireDate = eb.expireDate;
                    newEBook.isAPI = eb.isAPI;
                    
                    eMaterials.add(newEBook);
                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyElectronicStudyMaterials','Add newEBook',newEBook);
                    
                } else if(eb.productCode == 'SCRX') {
                    
                    String newAccountingId;
                    if(eb.accountingId != NULL) {
                        newAccountingId = eb.accountingId.Left(6) + 'PE';
                    } else if(eb.year != NULL) {                        
                        newAccountingId = string.valueof(eb.year).right(2) + 'SCRPE'; 
                    }  
                    GARP_BC_StudyMaterials.eBook newEBook = new GARP_BC_StudyMaterials.eBook();
                    newEBook.title = eb.title + ' Practice Exam';
                    newEBook.provider = eb.provider;
                    newEBook.productCode = eb.productCode + 'PE';
                    newEBook.accountingId = newAccountingId;
                    newEBook.type = eb.type;
                    newEBook.part = eb.part;
                    newEBook.expireDate = eb.expireDate;
                    newEBook.isAPI = eb.isAPI;
                    
                    eMaterials.add(newEBook);
                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyElectronicStudyMaterials','Add newEBook',newEBook);
                }
            }
        }
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyElectronicStudyMaterials','final eMaterials',eMaterials);
        return eMaterials;
    }
    
    public static List<eBook> getMyEBooks(string accountId, List<Opportunity> lstOpportunity) {
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','lstOpportunity',lstOpportunity);
        
        List<eBook> eBooks = new List<eBook>();
        
        if(lstOpportunity == NULL) {
            lstOpportunity = [SELECT Id FROM Opportunity 
                              WHERE AccountId = :accountId AND StageName = 'Closed'];            
        }
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','lstOpportunity',lstOpportunity);
                
        MAP<string,string> mapSlugs = GARP_BC_Membership.getMemberBenefitsSlugs();
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','mapSlugs',mapSlugs);
        
        List<String> slugs = mapSlugs.Values();
        
        List<eBook_Key__c> eBookList = [
                        SELECT Name, Cancelled__c, Product_ID__c, Member_EMail__c, Key__c, Is_API__c, Type__c, 
                        Status__c, Taken_Date__c, 
                        Access_Expiration_Date__c, Expiration_Date__c, Opportunity__c 
                        FROM eBook_Key__c 
                        WHERE Opportunity__c IN :lstOpportunity AND Cancelled__c = FALSE AND Access_Revoked__c = False AND Access_Expiration_Date__c > TODAY AND
            			Product_ID__c not in :slugs
                        ORDER BY Taken_Date__c DESC
                    ];
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','eBookList',eBookList);
        
        if(!eBookList.IsEmpty()) {
            
            // Setup Mobius Config Maps
            Map<String,Mobius_Products__c> mobiusProductConfig = Mobius_Products__c.getall();
            GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','mobiusProductConfig',mobiusProductConfig);
            
            Map<String,List<Mobius_Products__c>> mapEBookToMobiusConfig = new Map<String,List<Mobius_Products__c>>();
            for(Mobius_Products__c mp :mobiusProductConfig.values()) {
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','Loop mapEBookToMobiusConfig mp',mp);
                
                if(mp.Product_Id__c != NULL && mp.Year__c != NULL) {
                    String yearPart = String.valueOf(mp.Year__c).Right(2);
                    String key = yearPart + mp.Salesforce_Product_Code__c;
                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','add mapEBookToMobiusConfig key',key);
                    
                    List<Mobius_Products__c> fndMobiusProducts = mapEBookToMobiusConfig.get(key);
                    if(fndMobiusProducts == NULL) {
                        fndMobiusProducts = new List<Mobius_Products__c>();
                    }
                    fndMobiusProducts.add(mp);
                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','add fndMobiusProducts',mp);
                    
                    mapEBookToMobiusConfig.put(key, fndMobiusProducts);
                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','add mapEBookToMobiusConfig',fndMobiusProducts);
                }
            }
            GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','mapEBookToMobiusConfig',mapEBookToMobiusConfig);

            // Create eBook result
            for(eBook_Key__c ebook :eBookList) {
                
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','Loop eBook_Key__c',ebook);
                
                // FRM, SCR eBooks
                eBook eBookRecord = new eBook();
                eBookRecord.key = ebook.Key__c;
                eBookRecord.keyStatus = ebook.Status__c;
                eBookRecord.expireDate = ebook.Access_Expiration_Date__c;
                eBookRecord.isAPI = ebook.Is_API__c;
                    
                if(ebook.Product_ID__c != NULL) {
                    eBookRecord.accountingId = ebook.Product_ID__c;
                    String yearPart = ebook.Product_ID__c.Left(2);
                    eBookRecord.year = Integer.valueOf('20'+yearPart);
                } else if(ebook.Taken_Date__c != NULL) {
                    eBookRecord.year = ebook.Taken_Date__c.year();
                }
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','eBookRecord 1',eBookRecord);
                
                if(ebook.Type__c == 'FRM Exam Part I') {
                    eBookRecord.title = 'FRM Exam Part I eBooks';
                    eBookRecord.provider = 'Pearson';
                    eBookRecord.productCode = 'FRM1X';
                    eBookRecord.type = 'FRM';
                    eBookRecord.part = 'I';
                } else if(ebook.Type__c == 'FRM Exam Part II') {
                    eBookRecord.title = 'FRM Exam Part II eBooks';
                    eBookRecord.provider = 'Pearson';
                    eBookRecord.productCode = 'FRM2X';
                    eBookRecord.type = 'FRM';
                    eBookRecord.part = 'II';
                } else if(ebook.Type__c == 'SCR') {
                    eBookRecord.title = 'Sustainability and Climate Risk eBook';
                    eBookRecord.provider = 'Pearson';
                    eBookRecord.productCode = 'SCRX';
                    eBookRecord.type = 'SCR';
                } else if(ebook.Type__c == 'RAIJ') {
                    eBookRecord.title = 'Risk and Artificial Intelligence in Java eBook';
                    eBookRecord.provider = 'Pearson';
                    eBookRecord.productCode = 'RAIJX';
                    eBookRecord.type = 'RAIJ';
                } else if(ebook.Type__c == 'FRR') {
                    eBookRecord.title = 'Financial Risk and Regulation eBook';
                    eBookRecord.provider = 'We Know Training (WKT)';
                    eBookRecord.productCode = 'CBRX';
                    eBookRecord.type = 'FRR';
                } else if(ebook.Type__c == 'FFR') {
                    eBookRecord.title = 'Foundations of Financial Risk eBook';
                    eBookRecord.provider = 'We Know Training (WKT)';
                    eBookRecord.productCode = 'FFRXF';
                    eBookRecord.type = 'FFR';
                }
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','eBookRecord 2',eBookRecord);
                
                if(eBookRecord.year != NULL) {
                    String fndEBookKey = String.ValueOf(eBookRecord.year).Right(2)+eBookRecord.productCode;
                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','fndEBookKey',fndEBookKey);
                    
                    List<Mobius_Products__c> fndMobiusProducts = mapEBookToMobiusConfig.get(fndEBookKey);    
                    GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','fndMobiusProducts',fndMobiusProducts);
                    
                    if(fndMobiusProducts != NULL) {
                        eBookRecord.eBookItems = new List<eBookItem>();
                        for(Mobius_Products__c mp :fndMobiusProducts) {
                            GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','Loop Mobius_Products__c',mp);
                            
                            eBookItem eBookItem = new eBookItem();
                            eBookItem.title = mp.Title__c;
                            eBookItem.vendorId = Integer.valueOf(mp.Product_Id__c);
                            eBookRecord.eBookItems.add(eBookItem);
                            
                            GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','Add eBookItem',eBookItem);   
                        }
                    }
                }
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','eBookRecord 3',eBookRecord);
                
                eBooks.add(eBookRecord);
            }
        }
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMyEBooks','return eBooks',eBooks);
        return eBooks;
    }
    
    // Verify Access and Return SSO Link
    public static String getBenchPrepSSOLink(String contactId, String program, String part) {
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getBenchPrepSSOLink','contactIds',contactId);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getBenchPrepSSOLink','program',program);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getBenchPrepSSOLink','part',part);
        
        // Part = I, II, Full
        if(part != NULL) {
        	return '/BenchPrepSSO?prog=' + program + '&part=' + part;    
        } else {
            return '/BenchPrepSSO?prog=' + program;
        }
        
    }
    
    public static mobiusAPI.mUserLoginResp getEBookAccessURL(Contact contact, String productId) {
        mobiusAPI.mobiusRespWrapper wResp = mobiusAPI.mUserLogin(mobiusAPI.apiVersionGlobal,contact.Email, Integer.valueOf(productId), 0);
        System.debug('mUserLogin:' + wResp);
        mobiusAPI.mUserLoginResp mULResp = (mobiusAPI.mUserLoginResp)JSON.deserialize(wResp.response, mobiusAPI.mUserLoginResp.class);
        System.debug('mULResp:' + mULResp);
        return mULResp;
    }
    
    public static Id getAccountRecordId(String contactId) {
        Contact contactRecord = [SELECT AccountId FROM Contact WHERE Id = :contactId];
        return contactRecord.AccountId;
    }
    
    // V2 Portal
    
    public static eBook getMostRecentEBook(Contact contact, String programType, String part, List<eBook> myEBooks) {
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMostRecentEBook','contact',contact);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMostRecentEBook','programType',programType);
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMostRecentEBook','myEBooks',myEBooks);
        
        eBook recentEBook;
        Integer lastYear = 1970;
        for(eBook eBook :myEBooks) {
            if(eBook.type == programType && (part == NULL || part == eBook.part)) {
                if(eBook.year > lastYear) {
                    recentEBook = eBook;
                    lastYear = eBook.year;
                }
            }
        }
        
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getMostRecentEBook','recentEBook',recentEBook);
        
        return recentEBook;
        
    }
    
    public static MAP<String,List<String>> getErrataPicklistOption(String programType) {
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getErrataPicklistOption','programType',programType);
       
        MAP<String,List<String>> errataBooks = new MAP<String,List<String>>();
        
        Map<Object,List<String>> depPickLists = GARP_Common.getDependentPicklistValues( Errata__c.Section__c, Errata__c.Book_Practice_Exam__c );
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getErrataPicklistOption','depPickLists',depPickLists);
        
        String searchTerm = programType;
        if(programType == 'RAIJ') {
            searchTerm = 'Japanese';
        } else if(programType == 'RISKAI') {
            searchTerm = 'RAI Exam';
        }

        for(Object obj :depPickLists.keyset()) {
            GARP_Common.debugLog('GARP_BC_StudyMaterials','getErrataPicklistOption','Loop depPickLists',obj);
            String listVal = String.ValueOf(obj);
            
            GARP_Common.debugLog('GARP_BC_StudyMaterials','getErrataBooks','listVal',listVal);
            if(listVal.toLowerCase().IndexOf(searchTerm.toLowerCase()) > -1) {
                List<String> vals = depPickLists.get(obj);
                GARP_Common.debugLog('GARP_BC_StudyMaterials','getErrataPicklistOption','vals',vals);   
                
                errataBooks.put(listVal, vals);
            }
        }
        GARP_Common.debugLog('GARP_BC_StudyMaterials','getErrataPicklistOption','errataBooks',errataBooks);   
        return errataBooks;
    }
    
    public class errataFormSubmissionInfo {
        public String programType;
        public String studyMaterial;
        public String book;
        public String pageNumber;
        public String errorDescription;
        public String correction;
        public String fileAttachmentId;
    }
    
    public static String addErrataSubmission(String ContactId, errataFormSubmissionInfo errataFormSubmissionInfo) {
        
        if(errataFormSubmissionInfo.programType == 'RISKAI') {
            errataFormSubmissionInfo.programType = 'RAI';
        }
        
        Errata__c erata = new Errata__c(Category__c=errataFormSubmissionInfo.programType.ToUpperCase(), 
                                        Study_Material__c=errataFormSubmissionInfo.studyMaterial + ' ' + errataFormSubmissionInfo.book, 
                                        Message__c=errataFormSubmissionInfo.errorDescription, 
                                        Book__c=errataFormSubmissionInfo.studyMaterial + ' ' + errataFormSubmissionInfo.book, 
                                        Book_Practice_Exam__c=errataFormSubmissionInfo.studyMaterial, 
                                        Section__c=errataFormSubmissionInfo.book, 
                                        Solution__c=errataFormSubmissionInfo.correction, 
                                        Page_Number__c=errataFormSubmissionInfo.pageNumber, 
                                        Contact__c=ContactId);
        insert erata;
        
        return erata.Id;
    }
    
}