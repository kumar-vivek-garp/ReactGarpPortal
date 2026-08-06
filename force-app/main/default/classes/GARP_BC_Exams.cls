public class GARP_BC_Exams {

    /** Wrapper for getFRMMainProducts: status, message, and list of main products. */
    public class getFRMMainProductsReturnInfo {
        public String status;
        public String message;
        public List<String> messages;
        public List<PricebookEntry> products;
    }

    // Service Calls
    public static GARP_BC_Registration.programRegistrationInfo getFRMRegistrationSettings(String regCode) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'frm';
        programRegistrationInfo.mainMemberProductCode = null;
        programRegistrationInfo.mainNonMemberProductCode = null;
        programRegistrationInfo.retakeProductCode  = null;
        programRegistrationInfo.mainProductCodes = new List<String>{'FRM1E','FRM1S','FRM2E','FRM2S'};
        programRegistrationInfo.feesProductCodes = new List<String>{'FRM1','CHNDF','CHLF'};
        programRegistrationInfo.studyMatProductCodes = new List<String>{'FRM1H','FRM2H','FRMC2','FRMBP','FRM1BPPE','FRMBP2'};
        programRegistrationInfo.addOnsProductCodes  = new List<String>{};
        programRegistrationInfo.teamProductCodes  = new List<String>{'FRM1TE','FRM2TE','FRM1TS','FRM2TS','SAFRM1E','SAFRM2E','SAFRM1S','SAFRM2S','SAFRMSED'};

        // If regCode is closeKey
        if(!GARP_BC_MyPrograms.isLoadingResults(True, regCode)) {
            programRegistrationInfo.loadKey = regCode;
        } else {
            programRegistrationInfo.regCode = regCode;
        }

        programRegistrationInfo.formName = 'exam-registration-frm';
        programRegistrationInfo.contractRecTypeName = 'FRM Program';
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;

        // Add program information
        programRegistrationInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('frm',NULL);

        return programRegistrationInfo;
    }

    public static GARP_BC_Registration.getRegistrationInfo getFRMRegistrationInfo(String regCode) {
        return GARP_BC_Registration.getRegistrationInfo(getFRMRegistrationSettings(regCode));
    }

    // Helpers
    public static getFRMMainProductsReturnInfo getFRMMainProducts(MAP<String,PricebookEntry> mapProdByCodes, GARP_BC_Membership.membershipInfo membershipInfo, GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo, GARP_BC_Registration.teamRegInfo teamRegInfo, returnFRMEnrollmentInfo frmEnrollmentInfo) {
        getFRMMainProductsReturnInfo result = new getFRMMainProductsReturnInfo();
        result.status = 'Success';
        result.messages = new List<String>();
        result.products = new List<PricebookEntry>();
        List<PricebookEntry> retProds = result.products;

        GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','mapProdByCodes',mapProdByCodes);
        GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','membershipInfo',membershipInfo);
        GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','getRegistrationFeesInfo',getRegistrationFeesInfo);

        GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','part1SelectedAdminId',getRegistrationFeesInfo.examSelectionInfo.part1Info.selectedAdminId);

        Set<String> selPartIds = new Set<String>();
        if(getRegistrationFeesInfo.examSelectionInfo.part1Info.selectedAdminId != NULL &&
            (getRegistrationFeesInfo.examSelectionInfo.partSelected == 'FRM Exam Part I' ||
             getRegistrationFeesInfo.examSelectionInfo.partSelected == 'FRM Exam Part I and FRM Exam Part II')) {
            selPartIds.add(getRegistrationFeesInfo.examSelectionInfo.part1Info.selectedPartId);
        }
        if(getRegistrationFeesInfo.examSelectionInfo.part2Info.selectedAdminId != NULL &&
            (getRegistrationFeesInfo.examSelectionInfo.partSelected == 'FRM Exam Part II' ||
             getRegistrationFeesInfo.examSelectionInfo.partSelected == 'FRM Exam Part I and FRM Exam Part II')) {
            selPartIds.add(getRegistrationFeesInfo.examSelectionInfo.part2Info.selectedPartId);
        }
        GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','selPartIds',selPartIds);

        List<Exam_Rate__c> ratesByWindow = [select id, Name, Exam_Part__c, Exam_Part__r.Exam_Part_Number__c,
                                            Product__r.ProductCode, Product__r.GL_Code__c,
                                            Team_Product__r.ProductCode, Team_Product__r.GL_Code__c,
                                            Team_Scholarship_Product__r.ProductCode, Team_Scholarship_Product__r.GL_Code__c,
                                            Team_Scholarship_Enrollment_Product__r.ProductCode, Team_Scholarship_Enrollment_Product__r.GL_Code__c,
                                            Exam_Registration_Window__r.Exam_Registration_Window_Open__c,
                                            Exam_Registration_Window__r.Exam_Registration_Window_Close__c
                                            from Exam_Rate__c
                                            where Exam_Part__c IN :selPartIds
                                            //AND
                                            //Exam_Registration_Window__r.Exam_Registration_Window_Open__c <= TODAY AND
                                            //Exam_Registration_Window__r.Exam_Registration_Window_Close__c > TODAY
                                           ];
        GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','ratesByWindow',ratesByWindow);

        if(!ratesByWindow.IsEmpty()) {

            // Compute Eligibility
            GARP_BC_Registration.RegistrationEligibility regElig = GARP_BC_Exams.isEligibleFRM(membershipInfo, getRegistrationFeesInfo.programRegistrationInfo.loadKey);
            GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','regElig',regElig);

            if(!regElig.isEligible) {
                GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','not eligible for exam','');
                result.status = 'Failed';
                result.message = 'Not eligible for exam';
                result.messages.add(result.message);
                return result;
            }

            Boolean availPart1 = false;
            Boolean availPart2 = false;
            for(String ee :regElig.eligibleExams) {
                if(ee == 'FRM Part 1') {
                    availPart1 = True;
                } else if(ee == 'FRM Part 2') {
                    availPart2 = True;
                }
            }
            GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','availPart1',availPart1);
            GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','availPart2',availPart2);

            // Override exam rates using exam rate offers
            List<Exam_Rate__c> rates = getExamRates(ratesByWindow, membershipInfo, True, availPart1, availPart2);
            GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','final rates',rates);

            if(rates.IsEmpty()) {
                GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','no rates found','');
                result.status = 'Failed';
                result.message = 'No exam rates found';
                result.messages.add(result.message);
                return result;
            }

            // Save Scholarship Enrollment Product
            Product2 teamScholarshipEnrollmentProduct;
            for(Exam_Rate__c frmRate :rates) {
                GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','loop rates',frmRate);

                PricebookEntry fndPbe;

                GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','teamRegCode',getRegistrationFeesInfo.teamRegCode);

                // Get Normal exam rate
                fndPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, frmRate.Product__r.ProductCode, frmRate.Product__r.GL_Code__c);
                GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','fndPbe',fndPbe);

                if(fndPbe == NULL) {
                    result.status = 'Failed';
                    result.message = 'Exam product not found in product map';
                    result.messages.add(result.message);
                    return result;
                }

                // Team Registration
                if(getRegistrationFeesInfo.teamRegCode != NULL && !String.IsEmpty(getRegistrationFeesInfo.teamRegCode)) {
                    GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','teamRegInfo',teamRegInfo);

                    if(frmRate.Team_Product__r == NULL) {
                        result.status = 'Failed';
                        result.message = 'Team registration products not configured for this exam rate';
                        result.messages.add(result.message);
                        return result;
                    }
                    GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','frmRate.Team_Product__r',frmRate.Team_Product__r.ProductCode + ':' + frmRate.Team_Product__r.GL_Code__c);
                    GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','frmRate.Team_Scholarship_Enrollment_Product__r',frmRate.Team_Scholarship_Enrollment_Product__r.ProductCode+':'+frmRate.Team_Scholarship_Enrollment_Product__r.GL_Code__c);

                    if(!teamRegInfo.isScholarship) {
                        fndPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, frmRate.Team_Product__r.ProductCode, frmRate.Team_Product__r.GL_Code__c);
                        if(fndPbe == NULL) {
                            result.status = 'Failed';
                            result.message = 'Team registration product not found in product map';
                            result.messages.add(result.message);
                            return result;
                        }
                    } else {
                        // Scholarship - Add negative amount
                        PricebookEntry fndScholarshipPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, frmRate.Team_Scholarship_Product__r.ProductCode, frmRate.Team_Scholarship_Product__r.GL_Code__c);

                        // Save Scholarship Enrollment Product
                        teamScholarshipEnrollmentProduct = frmRate.Team_Scholarship_Enrollment_Product__r;

                        // Add discount product
                        if(fndScholarshipPbe != NULL) {
                            fndScholarshipPbe.UnitPrice = (fndPbe.UnitPrice * -1);
                            retProds.add(fndScholarshipPbe);
                            GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','Add scholarship pbe',fndScholarshipPbe);
                        } else {
                            result.status = 'Failed';
                            result.message = 'Scholarship product not found';
                            result.messages.add(result.message);
                            return result;
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','Team fndPbe',fndPbe);
                }

                if(selPartIds.Contains(frmRate.Exam_Part__c) && fndPbe != NULL) {
                    retProds.add(fndPbe);
                }
            }
            GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','teamScholarshipEnrollmentProduct',teamScholarshipEnrollmentProduct);

            // Add Team Registration Scholarship Enrollment Discount
            if(frmEnrollmentInfo.isEnrollmentRequired && getRegistrationFeesInfo.teamRegCode != NULL && !String.IsEmpty(getRegistrationFeesInfo.teamRegCode) &&
               teamRegInfo.isScholarshipEnrollmentComplimentary && teamScholarshipEnrollmentProduct != NULL) {

                   PricebookEntry fndScholarshipEnrollmentPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, teamScholarshipEnrollmentProduct.ProductCode, teamScholarshipEnrollmentProduct.GL_Code__c);
                   GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','Find scholarship enrollment pbe',fndScholarshipEnrollmentPbe);

                   if(fndScholarshipEnrollmentPbe != NULL) {
                       fndScholarshipEnrollmentPbe.UnitPrice = (frmEnrollmentInfo.enrollmentPbe.UnitPrice * -1);
                       retProds.add(fndScholarshipEnrollmentPbe);
                       GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','Add scholarship enrollment pbe',fndScholarshipEnrollmentPbe);
                   } else {
                        result.status = 'Failed';
                        result.message = 'Scholarship enrollment product not found in product map';
                        result.messages.add(result.message);
                        return result;
                   }
               }
        } else {
            result.status = 'Failed';
            result.message = 'No exam rates found';
            result.messages.add(result.message);
            return result;
        }
        GARP_Common.debugLog('GARP_BC_Exams','getFRMMainProducts','Final prods',retProds);
        return result;
    }

    public class returnFRMEnrollmentInfo {
        public Boolean isEnrollmentRequired;
        public PricebookEntry enrollmentPbe;
    }

    public static returnFRMEnrollmentInfo getFRMEnrollmentInfo(MAP<String,PricebookEntry> mapProdByCodes, GARP_BC_Membership.membershipInfo membershipInfo, GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo) {
        GARP_Common.debugLog('GARP_BC_Exams','getFRMEnrollmentInfo','mapProdByCodes', mapProdByCodes);
        GARP_Common.debugLog('GARP_BC_Exams','getFRMEnrollmentInfo','membershipInfo', membershipInfo);
        GARP_Common.debugLog('GARP_BC_Exams','getFRMEnrollmentInfo','getRegistrationFeesInfo', getRegistrationFeesInfo);

        returnFRMEnrollmentInfo ret = new returnFRMEnrollmentInfo();

        // Enrollment
        ret.isEnrollmentRequired = true;
        if(membershipInfo != NULL) {
            Contract cont = getExamContract(membershipInfo.accountRecord.Id);
            if(cont != NULL && cont.Status != 'Expired') {
               ret.isEnrollmentRequired = False;
            }
        }
        GARP_Common.debugLog('GARP_BC_Exams','getFRMEnrollmentInfo','isEnrollmentRequired',ret.isEnrollmentRequired);

        ret.enrollmentPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, 'FRM1', '4010');
        GARP_Common.debugLog('GARP_BC_Exams','getFRMEnrollmentInfo','enrollmentPbe',ret.enrollmentPbe);

        return ret;
    }

    public static GARP_BC_Registration.examSelectionInfo getExamSelectionInfo(MAP<String,PricebookEntry> mapProdByCodes, GARP_BC_Membership.membershipInfo membershipInfo, Boolean hasSelectedMembership, GARP_BC_Registration.teamRegInfo teamRegInfo, String loadKey) {

        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','mapProdByCodes',mapProdByCodes);
        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','membershipInfo',membershipInfo);
        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','hasSelectedMembership',hasSelectedMembership);
        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','teamRegInfo',teamRegInfo);

        GARP_BC_Registration.examSelectionInfo examSelectionInfo = new GARP_BC_Registration.examSelectionInfo();
        examSelectionInfo.partsAvailable = new List<String>();
        examSelectionInfo.part1Info = new GARP_BC_Registration.partInfo();
        examSelectionInfo.part1Info.examAdmins = new List<GARP_BC_Registration.examAdminInfo>();
        examSelectionInfo.part2Info = new GARP_BC_Registration.partInfo();
        examSelectionInfo.part2Info.examAdmins = new List<GARP_BC_Registration.examAdminInfo>();

        // Compute Eligibility
        GARP_BC_Registration.RegistrationEligibility regElig = GARP_BC_Exams.isEligibleFRM(membershipInfo, loadKey);
        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','regElig',regElig);

        Boolean availPart1 = false;
        Boolean availPart2 = false;
        for(String ee :regElig.eligibleExams) {
            if(ee == 'FRM Part 1') {
                availPart1 = True;
            } else if(ee == 'FRM Part 2') {
                availPart2 = True;
            }
        }
        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','availPart1',availPart1);
        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','availPart2',availPart2);

        // Get Existing Part I exam date, to force other parts to be equal or greater
        Date part1ActiveAdminExamDate = Date.newInstance(1970, 1, 1);
        if(regElig.part1RegisteredInActiveAdmin != NULL) {
            part1ActiveAdminExamDate = (regElig.part1RegisteredInActiveAdmin.Exam_Part__r.Exam_Date__c != NULL) ? regElig.part1RegisteredInActiveAdmin.Exam_Date__c : regElig.part1RegisteredInActiveAdmin.Exam_Part__r.Exam_Start_Date__c;
        }
        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','part1ActiveAdminExamDate',part1ActiveAdminExamDate);

        Boolean hasPart1 = false;
        Boolean hasPart2 = false;
        String examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRM/ERP');

        // Get Rates By Window
        List<Exam_Rate__c> ratesByWindow = [select id, Name, Product__c, Product__r.ProductCode, Product__r.GL_Code__c,
                                    Exam_Part__c, Exam_Part__r.Exam_Part_Number__c,
                                    Exam_Administration__c, Exam_Administration__r.Name,
                                    Exam_Registration_Window__c, Exam_Registration_Window__r.Type__c,
                                    Exam_Registration_Window__r.Exam_Registration_Window_Open__c,
                                    Exam_Registration_Window__r.Exam_Registration_Window_Close__c
                                    from Exam_Rate__c where
                                    Exam_Administration__r.Exam_Group__r.RecordTypeId = :examGroupRecordTypeId AND
                                    // Limit Rates By Available Exam Part and Date
                                    Exam_Part__r.Exam__r.Exam__c in :regElig.eligibleExams AND
                                    ((Exam_Part__r.Exam_Date__c != NULL AND Exam_Part__r.Exam_Date__c >= :part1ActiveAdminExamDate) OR (Exam_Part__r.Exam_Start_Date__c != NULL AND Exam_Part__r.Exam_Start_Date__c >= :part1ActiveAdminExamDate)) AND
                                    (Exam_Registration_Window__r.Exam_Registration_Window_Open__c <= TODAY AND
                                     Exam_Registration_Window__r.Exam_Registration_Window_Close__c >= TODAY)
                                    Order By Exam_Registration_Window__r.Exam_Administration__r.Registration_Start_Date__c ASC];
        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','ratesByWindow',ratesByWindow);

        // Override and expand exam rates using exam rate offers
        List<Exam_Rate__c> rates = getExamRates(ratesByWindow, membershipInfo, True, availPart1, availPart2);
        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','final rates',rates);

        // Pre-Select Admin
        String firstPart1AdminId;
        String firstPart1PartId;
        String firstPart2AdminId;
        String firstPart2PartId;

        if(!rates.IsEmpty()) {
            Set<String> adminIds = new Set<String>();
            Set<String> siteIds = new Set<String>();

            // Collect All Posiable Admins
            for(Exam_Rate__c er :rates) {
                adminIds.add(er.Exam_Administration__c);
            }
            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','adminIds',adminIds);

            // Collect Parts, limited to logged in user, if applicable
            List<Exam_Part__c> parts = [select id, Exam_Part_Number__c, Exam_Administration__c, Exam_Date__c, Exam_Start_Date__c,
                                        Exam_End_Date__c
                                        from Exam_Part__c where
                                        Exam_Administration__c in :adminIds AND
                                        // Exam Part Date must be equal or greater than existing exam reg
                                        ((Exam_Date__c != NULL AND Exam_Date__c >= :part1ActiveAdminExamDate) OR (Exam_Start_Date__c != NULL AND Exam_Start_Date__c >= :part1ActiveAdminExamDate))
                                       ];
            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','parts',parts);
            Set<String> partIds = new Set<String>();
            for(Exam_Part__c ep :parts) {
                partIds.add(ep.Id);
            }
            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','partIds',partIds);

            List<Exam_Sites__c> examSites;
            if(teamRegInfo != NULL && teamRegInfo.isOSTAFeePaidByInstitution) {
                examSites = [select id, Country__c, Exam_Part__c, Site__c, Exam_Provider__r.Name
                             from Exam_Sites__c
                             where Exam_Part__c in :partIds AND Site__r.Is_OSTA_Information_Required__c = True
                             Order By Country__c];
            } else {
                examSites = [select id, Country__c, Exam_Part__c, Site__c, Exam_Provider__r.Name
                             from Exam_Sites__c
                             where Exam_Part__c in :partIds Order By Country__c];
            }
            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','examSites',examSites);

            for(Exam_Sites__c es :examSites) {
                siteIds.add(es.Site__c);
            }
            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','siteIds',siteIds);

            List<Site__c> sites = [select id, Is_OSTA_Information_Required__c, Is_VAT__c from Site__c where Id in :siteIds];
            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','sites',sites);

            MAP<String,Exam_Part__c> mapExamParts = new MAP<String,Exam_Part__c>();
            if(!parts.isEmpty()) {
                for(Exam_Part__c ep :parts) {
                    mapExamParts.put(ep.Id, ep);
                }
            }
            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','mapExamParts',mapExamParts);

            MAP<String,Exam_Sites__c> mapExamSitesByPart = new MAP<String,Exam_Sites__c>();
            MAP<String,Exam_Sites__c> mapExamSitesBySite = new MAP<String,Exam_Sites__c>();
            if(!examSites.isEmpty()) {
                for(Exam_Sites__c es :examSites) {
                    mapExamSitesByPart.put(es.Exam_Part__c, es);
                    mapExamSitesBySite.put(es.Site__c, es);
                }
            }
            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','mapExamSitesByPart',mapExamSitesByPart);
            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','mapExamSitesBySite',mapExamSitesBySite);

            MAP<String,Site__c> mapTestSites = new MAP<String,Site__c>();
            if(!sites.isEmpty()) {
                for(Site__c ts :sites) {
                    mapTestSites.put(ts.Id, ts);
                }
            }
            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','mapTestSites',mapTestSites);

            // Create Return Obj
            for(Exam_Rate__c er :rates) {

                GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','Loop er',er);

                GARP_BC_Registration.examAdminInfo examAdmin = new GARP_BC_Registration.examAdminInfo();
                if(firstPart1AdminId == NULL && er.Exam_Part__r.Exam_Part_Number__c == 1) {
                    firstPart1AdminId = er.Exam_Administration__c;
                    firstPart1PartId = er.Exam_Part__c;
                    GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','firstPart1AdminId',firstPart1AdminId);

                } else if(firstPart2AdminId == NULL && er.Exam_Part__r.Exam_Part_Number__c == 2) {
                    firstPart2AdminId = er.Exam_Administration__c;
                    firstPart2PartId = er.Exam_Part__c;
                    GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','firstPart2AdminId',firstPart2AdminId);
                }

                examAdmin.name = er.Exam_Administration__r.Name;
                examAdmin.id = er.Exam_Administration__c;

                examAdmin.window = er.Exam_Registration_Window__r.Type__c;
                examAdmin.name = er.Exam_Administration__r.Name;

                GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','examAdmin1',examAdmin);

                PricebookEntry fndPbe = GARP_BC_Orders.getPricebookEntryByCode(mapProdByCodes, er.Product__r.ProductCode, er.Product__r.GL_Code__c);
                GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','fndPbe',fndPbe);

                if(fndPbe != NULL) {
                    examAdmin.amount = fndPbe.UnitPrice;
                }
                Exam_Part__c fndPart = mapExamParts.get(er.Exam_Part__c);
                GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','fndPart',fndPart);

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
                    GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','examAdmin2',examAdmin);

                    examAdmin.examSites = new List<GARP_BC_Registration.examSiteInfo>();
                    for(Exam_Sites__c es :examSites) {

                        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','Loop es',es);

                        if(es.Exam_Part__c == fndPart.Id) {
                            GARP_BC_Registration.examSiteInfo examSite = new GARP_BC_Registration.examSiteInfo();
                            examSite.name = es.Country__c;
                            examSite.id = es.Id;
                            examSite.provider = es.Exam_Provider__r.Name;
                            examSite.isOSTA = False;
                            examSite.isVAT = False;

                            Site__c fndTestSite = mapTestSites.get(es.Site__c);
                            if(fndTestSite != NULL) {
                                examSite.isOSTA = fndTestSite.Is_OSTA_Information_Required__c;
                                examSite.isVAT = fndTestSite.Is_VAT__c;
                            }
                            GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','Add examSite',examSite);
                            examAdmin.examSites.add(examSite);
                        }
                    }

                    if(fndPart.Exam_Part_Number__c == 1) {
                        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','Add part1',examAdmin);
                        examSelectionInfo.part1Info.examAdmins.add(examAdmin);
                    } else if(fndPart.Exam_Part_Number__c == 2) {
                        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','Add part2',examAdmin);
                        examSelectionInfo.part2Info.examAdmins.add(examAdmin);
                    }
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','examSelectionInfo.part1Info',examSelectionInfo.part1Info);
        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','examSelectionInfo.part2Info',examSelectionInfo.part2Info);

        // Set Exam Parts and Default values
        examSelectionInfo.part1Info.title = 'FRM Exam Part I';
        examSelectionInfo.part2Info.title = 'FRM Exam Part II';
        if(availPart1) {
            if(teamRegInfo == NULL || teamRegInfo.examType == 'FRM I' || teamRegInfo.examType == 'FRM I & II') {
                examSelectionInfo.partsAvailable.add('FRM Exam Part I');
                examSelectionInfo.part1Info.selectedAdminId = firstPart1AdminId;
                examSelectionInfo.part1Info.selectedPartId = firstPart1PartId;

                // Select Exam Site if Only 1
                for(GARP_BC_Registration.examAdminInfo ea :examSelectionInfo.part1Info.examAdmins) {
                    if(ea.id == examSelectionInfo.part1Info.selectedAdminId) {
                        if(ea.examSites.size() == 1) {
                            examSelectionInfo.part1Info.selectedSiteId = ea.examSites[0].id;
                        }
                    }
                }

            }
            if(availPart2 && (teamRegInfo == NULL || teamRegInfo.examType == 'FRM I & II')) {
                examSelectionInfo.partsAvailable.add('FRM Exam Part I and FRM Exam Part II');
                examSelectionInfo.part2Info.selectedAdminId = firstPart2AdminId;
                examSelectionInfo.part2Info.selectedPartId = firstPart2PartId;

                // Select Exam Site if Only 1
                for(GARP_BC_Registration.examAdminInfo ea :examSelectionInfo.part2Info.examAdmins) {
                    if(ea.id == examSelectionInfo.part2Info.selectedAdminId) {
                        if(ea.examSites.size() == 1) {
                            examSelectionInfo.part2Info.selectedSiteId = ea.examSites[0].id;
                        }
                    }
                }
            }
        } else if(availPart2 && (teamRegInfo == NULL || teamRegInfo.examType == 'FRM II')) {
            examSelectionInfo.partsAvailable.add('FRM Exam Part II');
            examSelectionInfo.part2Info.selectedAdminId = firstPart2AdminId;
            examSelectionInfo.part2Info.selectedPartId = firstPart2PartId;

                // Select Exam Site if Only 1
                for(GARP_BC_Registration.examAdminInfo ea :examSelectionInfo.part2Info.examAdmins) {
                    if(ea.id == examSelectionInfo.part2Info.selectedAdminId) {
                        if(ea.examSites.size() == 1) {
                            examSelectionInfo.part2Info.selectedSiteId = ea.examSites[0].id;
                        }
                    }
                }
        }

        GARP_Common.debugLog('GARP_BC_Exams','getExamSelectionInfo','Final examSelectionInfo',examSelectionInfo);

        return examSelectionInfo;
    }

    public class returnCreateFRMContract {
        public Boolean isNew;
        public Contract frmContract;
    }

    public static returnCreateFRMContract createFRMContract(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, GARP_BC_Membership.membershipInfo membershipInfo) {
        String frmRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program');
        returnCreateFRMContract ret = new returnCreateFRMContract();
        Contract frmContract;

        List<Contract> lstCont = [select Id, AccountId, Opportunity__c, CustomerSignedId, StartDate, ContractTerm, recordTypeID, Member_Email__c,
                                  Pearson_Member_First_Name__c, Pearson_Member_Last_Name__c, Pearson_Phone_No__c, BillingStreet, BillingCity,
                                  BillingState, BillingPostalCode
                                  from Contract
                                  where recordTypeID = :frmRecordTypeId AND
                                  AccountId = :setRegistrationReturnInfo.accountId AND
                                 Status Like 'Activated%'];
        GARP_Common.debugLog('GARP_BC_Exams','createFRMContract','lstCont',lstCont);

        if(!lstCont.IsEmpty()) {
            frmContract = lstCont[0];
            frmContract.Opportunity__c = setRegistrationReturnInfo.orderId;
            GARP_Common.debugLog('GARP_BC_Exams','createFRMContract','update frmContract',frmContract);
            ret.isNew = False;

            update frmContract;

        } else {
            ret.isNew = True;
            frmContract = new Contract(
                AccountId = setRegistrationReturnInfo.accountId,
                Opportunity__c = setRegistrationReturnInfo.orderId,
                CustomerSignedId = setRegistrationReturnInfo.contactId,
                StartDate = System.Today(),
                ContractTerm = 48,
                recordTypeID = frmRecordTypeId,
                Member_Email__c = setRegistrationInfo.customerInfo.email,
                //Pearson_Member_First_Name__c = setRegistrationInfo.customerInfo.firstName,
                //Pearson_Member_Last_Name__c = setRegistrationInfo.customerInfo.lastName,
                //Pearson_Phone_No__c = setRegistrationInfo.customerInfo.phone,
                BillingStreet = GARP_Common.formatAddressTextArea(setRegistrationInfo.paymentInfo.billingAddress.street1, setRegistrationInfo.paymentInfo.billingAddress.street2, setRegistrationInfo.paymentInfo.billingAddress.street3),
                BillingCity = setRegistrationInfo.paymentInfo.billingAddress.city,
                BillingCountry = setRegistrationInfo.paymentInfo.billingAddress.country,
                BillingState = setRegistrationInfo.paymentInfo.billingAddress.province,
                BillingPostalCode = setRegistrationInfo.paymentInfo.billingAddress.postalCode
            );

        }
        GARP_Common.debugLog('GARP_BC_Exams','createFRMContract','frmContract',frmContract);
        ret.frmContract = frmContract;
        GARP_Common.debugLog('GARP_BC_Exams','createFRMContract','ret',ret);
        return ret;
    }

    public static List<Candidate_Requirement__c> createFRMProgramRequirements(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, String ContractId) {
        String examCandidateReqRecordTypeId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c', 'Exam');
        String jobCandidateReqRecordTypeId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c', 'Job Experience');

        List<Candidate_Requirement__c> newReqs = new List<Candidate_Requirement__c>();

        Candidate_Requirement__c pass1req = new Candidate_Requirement__c(
            Name = 'Pass FRM1',
            Status__c = 'Initial',
            Exam__c = 'FRM Part I',
            Candidate_Email__c = setRegistrationInfo.customerInfo.email,
            RecordTypeId = examCandidateReqRecordTypeId,
            Candidate_Commitment__c = ContractId
        );
        GARP_Common.debugLog('GARP_BC_Exams','createFRMProgramRequirements','pass1req',pass1req);
        insert pass1req;

        Candidate_Requirement__c pass2req = new Candidate_Requirement__c(
            Name = 'Pass FRM2',
            Status__c = 'Initial',
            Exam__c = 'FRM Part II',
            Candidate_Email__c = setRegistrationInfo.customerInfo.email,
            RecordTypeId = examCandidateReqRecordTypeId,
            Candidate_Commitment__c = ContractId
        );
        GARP_Common.debugLog('GARP_BC_Exams','createFRMProgramRequirements','pass2req',pass2req);
        insert pass2req;

        Candidate_Requirement__c jobreq = new Candidate_Requirement__c(
            Name = 'Job Requirement',
            Status__c = 'Initial',
            Candidate_Email__c = setRegistrationInfo.customerInfo.email,
            RecordTypeId = jobCandidateReqRecordTypeId,
            Candidate_Commitment__c = ContractId,
            Prerequisite__c = pass2req.Id
        );
        GARP_Common.debugLog('GARP_BC_Exams','createFRMProgramRequirements','jobreq',jobreq);
        insert jobreq;

        return newReqs;
    }

    public static Contract createOSTAContract(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, GARP_BC_Membership.membershipInfo membershipInfo) {
        String ostaRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'OSTA Program');

        Contract ostaContract = new Contract(
            AccountId = setRegistrationReturnInfo.accountId,
            Opportunity__c = setRegistrationReturnInfo.orderId,
            CustomerSignedId = setRegistrationReturnInfo.contactId,
            StartDate = System.Today(),
            ContractTerm = 9999,
            recordTypeID = ostaRecordTypeId,
            Member_Email__c = membershipInfo.contactRecord.Email,
            //Pearson_Member_First_Name__c = membershipInfo.contactRecord.FirstName,
            //Pearson_Member_Last_Name__c = membershipInfo.contactRecord.LastName,
            //Pearson_Phone_No__c = membershipInfo.contactRecord.HomePhone,
            BillingStreet = membershipInfo.accountRecord.BillingStreet,
            BillingCity = membershipInfo.accountRecord.BillingCity,
            BillingCountry = membershipInfo.accountRecord.BillingCountry,
            BillingState = membershipInfo.accountRecord.BillingState,
            BillingPostalCode = membershipInfo.accountRecord.BillingPostalCode
        );
        GARP_Common.debugLog('GARP_BC_Exams','createOSTAContract','ostaContract',ostaContract);
        return ostaContract;
    }

    public static List<Exam_Attempt__c> createFRMExamRegistrations(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, List<Candidate_Requirement__c> contractRequirements) {

        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegistration','setRegistrationInfo',setRegistrationInfo);
        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegistration','setRegistrationReturnInfo',setRegistrationReturnInfo);
        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegistration','contractRequirements',contractRequirements);

        String examCandidateReq1Id;
        String examCandidateReq2Id;
        for(Candidate_Requirement__c contreq :contractRequirements) {
            if(contreq.Exam__c == 'FRM Part I') {
                examCandidateReq1Id = contreq.Id;
            } else if(contreq.Exam__c == 'FRM Part II') {
                examCandidateReq2Id = contreq.Id;
            }
        }
        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegistration','examCandidateReq1Id',examCandidateReq1Id);
        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegistration','examCandidateReq2Id',examCandidateReq2Id);

        List<Exam_Attempt__c> newExamAttempts = new List<Exam_Attempt__c>();
        Exam_Attempt__c newExamAttempt1;
        Exam_Attempt__c newExamAttempt2;

        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegistration','examSelectionInfo',setRegistrationInfo.examSelectionInfo);

        if(setRegistrationInfo.examSelectionInfo.partSelected == 'FRM Exam Part I' || setRegistrationInfo.examSelectionInfo.partSelected == 'FRM Exam Part I and FRM Exam Part II') {
            newExamAttempt1 = createFRMExamRegByPart(setRegistrationInfo.examSelectionInfo.part1Info, setRegistrationInfo, setRegistrationReturnInfo, examCandidateReq1Id);
            if(newExamAttempt1 != NULL) {
                GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegistration','newExamAttempt1',newExamAttempt1);
                newExamAttempts.add(newExamAttempt1);
            }
        }
        if(setRegistrationInfo.examSelectionInfo.partSelected == 'FRM Exam Part II' || setRegistrationInfo.examSelectionInfo.partSelected == 'FRM Exam Part I and FRM Exam Part II') {
            newExamAttempt2 = createFRMExamRegByPart(setRegistrationInfo.examSelectionInfo.part2Info, setRegistrationInfo, setRegistrationReturnInfo, examCandidateReq2Id);
            if(newExamAttempt2 != NULL) {
                GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegistration','newExamAttempt2',newExamAttempt2);
                newExamAttempts.add(newExamAttempt2);
            }
        }

        return newExamAttempts;
    }

    public static Boolean isStudyMaterialRelatedToSelection(GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo, GARP_BC_Orders.productInfo productInfo) {

        GARP_Common.debugLog('GARP_BC_Exams','isStudyMaterialRelatedToSelection','partSelected',getRegistrationFeesInfo.examSelectionInfo.partSelected);
        GARP_Common.debugLog('GARP_BC_Exams','isStudyMaterialRelatedToSelection','productInfo',productInfo);

        String partInfo = GARP_BC_StudyMaterials.getStudyMaterialSortInfo(productInfo.productCode);
        GARP_Common.debugLog('GARP_BC_Exams','isStudyMaterialRelatedToSelection','partInfo',partInfo);

        String relatedPart;
        if(!String.isEmpty(partInfo)) {
            List<String> parts = partInfo.split(':');
            if(parts.size() > 1) {
                relatedPart = parts[0];
            }
        }

        if(((getRegistrationFeesInfo.examSelectionInfo.partSelected == 'FRM Exam Part I' || getRegistrationFeesInfo.examSelectionInfo.partSelected == 'FRM Exam Part I and FRM Exam Part II') && relatedPart == 'Part 1') ||
           ((getRegistrationFeesInfo.examSelectionInfo.partSelected == 'FRM Exam Part II' || getRegistrationFeesInfo.examSelectionInfo.partSelected == 'FRM Exam Part I and FRM Exam Part II') && relatedPart == 'Part 2')
          ) {
            return True;
        }
        return False;
    }

    public static Exam_Attempt__c createFRMExamRegByPart(GARP_BC_Registration.partInfo partInfo, GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, String contractRequirementId) {

        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegByPart','partInfo',partInfo);

        String frmExamAttemptRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Attempt__c', 'FRM');

        Exam_Sites__c es = [select Id, Name, Country__c from Exam_Sites__c where id = :partInfo.selectedSiteId];

        Exam_Attempt__c newExamAttempt = new Exam_Attempt__c(
            Member__c = setRegistrationReturnInfo.contactId,
            Exam_Site__c = partInfo.selectedSiteId,
            Original_Exam_Site__c = es.Country__c,
            Exam_Administration__c = partInfo.selectedAdminId,
            Original_Exam_Administration__c = partInfo.selectedAdminId,
            Exam_Part__c = partInfo.selectedPartId,
            Candidate_Commitment__c = setRegistrationReturnInfo.programId,
            Candidate_Requirement__c = contractRequirementId,
            Opportunity__c = setRegistrationReturnInfo.orderId,
            //Pearson_Member_First_Name__c = setRegistrationInfo.customerInfo.firstName,
            //Pearson_Member_Last_Name__c = setRegistrationInfo.customerInfo.lastName,
            RecordTypeId = frmExamAttemptRecordTypeId
        );

        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegByPart','newExamAttempt',newExamAttempt);

        // Is OSTA?
        Boolean isOSTA = False;
        GARP_BC_Registration.examSiteInfo selectedExamSite = getSelectedExamSite(partInfo);

        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegByPart','selectedExamSite',selectedExamSite);

        if(selectedExamSite != NULL && selectedExamSite.isOSTA) {
            if(setRegistrationInfo.consentInfo.OSTAConsent) {
                newExamAttempt.OSTA_Consent__c = DateTime.now();
            }
        }
        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegByPart','newExamAttempt2',newExamAttempt);

        DateTime now = DateTime.now();

        // Consent
        if(setRegistrationInfo.consentInfo != NULL) {
            if(setRegistrationInfo.consentInfo.privacyPolicyAttestation != NULL && setRegistrationInfo.consentInfo.privacyPolicyAttestation == True) {
                newExamAttempt.Privacy_Policy_Attestation__c = now;
            }
            if(setRegistrationInfo.consentInfo.examPolicyAttestation != NULL && setRegistrationInfo.consentInfo.examPolicyAttestation == True) {
                newExamAttempt.Exam_Policy_Attestation__c = now;
            }
            if(setRegistrationInfo.consentInfo.eppOutreachConsent != NULL) {
                newExamAttempt.EPP_Opt_In__c = now;
            }
            // Case 00888108: Check consentInfo (preferred) or teamRegInfo (legacy frontend)
            if(setRegistrationInfo.consentInfo.consentReleaseExamResults != NULL && setRegistrationInfo.consentInfo.consentReleaseExamResults == True) {
                newExamAttempt.Consent_Release_Exam_Results__c = now;
            }
        }
        // Case 00888108: Also check teamRegInfo for backwards compatibility with frontend
        if(newExamAttempt.Consent_Release_Exam_Results__c == null && setRegistrationInfo.teamRegInfo != NULL && setRegistrationInfo.teamRegInfo.consentReleaseExamResults != NULL && setRegistrationInfo.teamRegInfo.consentReleaseExamResults == True) {
            newExamAttempt.Consent_Release_Exam_Results__c = now;
        }
        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegByPart','newExamAttempt3',newExamAttempt);
        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegByPart','newExamAttempt4',newExamAttempt);

        if(selectedExamSite != NULL && selectedExamSite.provider == 'ATA') {
            //newExamAttempt.ATA_Name_as_it_appears_on_ID__c = contact.Name_as_it_Appears_on_ID__c;
            // if(contact.ID_Type__c.indexOf('Driver') > -1) {
            //      examAttempt.ATA_Cert_Type__c = 'Driver\'s License';
            //  } else {
            //      examAttempt.ATA_Cert_Type__c = contact.ID_Type__c;
            //  }
            //  examAttempt.ATA_Cert_id__c = contact.ID_Number__c;
        }
        GARP_Common.debugLog('GARP_BC_Exams','createFRMExamRegByPart','Final newExamAttempt',newExamAttempt);

        // EPP Consent
        if(setRegistrationInfo.consentInfo.eppOutreachConsent != null && setRegistrationInfo.consentInfo.eppOutreachConsent){
            // Need to update Contact
            List<Contact> lstContact = [select id, Exam_Prep_Provider_Outreach__c from Contact where Id = :setRegistrationReturnInfo.contactId];
            if(!lstContact.isEmpty()) {
                lstContact[0].Exam_Prep_Provider_Outreach__c = True;
            }
            update lstContact;
        }

        return newExamAttempt;

    }

    public static GARP_BC_Registration.RegistrationEligibility isEligibleFRM(GARP_BC_Membership.membershipInfo membershipInfo, String loadKey) {
        GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','membershipInfo',membershipInfo);

        GARP_BC_Registration.RegistrationEligibility reObj = new GARP_BC_Registration.RegistrationEligibility();
        reObj.isEligible = False;

        Set<String> eligibleExams = new Set<String>();

        Boolean isInProgram = False;
        Boolean isRegistrationOpen = False;
        Boolean isPaymentBlocked = False;

        Exam_Attempt__c part1ERP;
        Exam_Attempt__c part2ERP;

        Boolean isOpenOrder = False;

        Boolean isPart1Passed = False;
        Boolean isPart1Offered = False;
        Boolean isPart1RegisteredInActiveAdmin = False;
        Exam_Attempt__c part1RegisteredInActiveAdmin;
        Boolean isPart1RegisteredAwaitingResults = False;  // When Part 1 is registered and Registration Window is Closed and No Results Yet
        Boolean isPart1IsScheduledComplete = False;
        Boolean isPart1IsScheduledOpen = False;
        Boolean isPart1IsScheduledExpired = False;
        Boolean isPart1HaveResult = False;
        Boolean isPart1Deferred = False;
        Boolean isPart1Registered = False;

        Exam_Attempt__c part1EA;
        Exam_Attempt__c part2EA;

        Boolean isPart2Passed = False;
        Boolean isPart2Offered = False;
        Boolean isPart2RegisteredInActiveAdmin = False;
        Exam_Attempt__c part2RegisteredInActiveAdmin;
        Boolean isPart2RegisteredAwaitingResults = False;
        Boolean isPart2HaveResult = False;
        Boolean isPart2Deferred = False;
        Boolean isPart2Registered = False;
        Boolean isNetNew = False;

        reObj.isNetNew = False;

        List<Exam_Administration__c> lstAdmins = [select Id, Name, Registration_Start_Date__c, Registration_End_Date__c
                                                  from Exam_Administration__c
                                                  where Exam_Type__c = 'FRM' AND Registration_Start_Date__c <= TODAY AND Registration_End_Date__c >= TODAY];
        GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','lstAdmins',lstAdmins);

        // Exam Admins where reg is open
        Map<String,Exam_Administration__c> mapActiveExamAdmins = new Map<String,Exam_Administration__c>();
        if(!lstAdmins.isEmpty()) {
            isRegistrationOpen = true;
            for(Exam_Administration__c ea :lstAdmins) {
                mapActiveExamAdmins.put(ea.id, ea);
            }
        }
        GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','mapActiveExamAdmins',mapActiveExamAdmins);
        GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isRegistrationOpen',isRegistrationOpen);

        // AG - 10/17/2022 - Updated for Exams 2023
        //List<Exam_Group__c> lstExamGroup = [select Id, Name, Registration_Start_Date__c, Last_Date_For_Late_Registration__c from Exam_Group__c where Active__c = True];
        //if(lstExamGroup != NULL && lstExamGroup.size() > 0) {
        //    Exam_Group__c eg = lstExamGroup[0];
        //    Date tdy = Date.today();
        //    if(tdy >= eg.Registration_Start_Date__c && tdy <= eg.Last_Date_For_Late_Registration__c) {
        //        isRegistrationOpen = true;
        //    }
        //}

        Date tdy = Date.today();
        reObj.eligibleExams = new Set<String>();

        if(!isRegistrationOpen) {
            return reObj;
        } else {

            if(membershipInfo == NULL || membershipInfo.contactRecord == NULL) {
                reObj.eligibleExams.add('FRM Part 1');
                reObj.eligibleExams.add('FRM Part 2');
                GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','membershipInfo == NULL',reObj.eligibleExams);
                reObj.isNetNew = True;
                reObj.isEligible = True;
                return reObj;
            }

            String contactId = membershipInfo.contactRecord.Id;

            Contract cont = getExamContract(membershipInfo.accountRecord.Id);
            if(cont != NULL && cont.Status != 'Expired') {
                isInProgram = True;
                if(cont.Status == 'Completed') {
                    isPart1Passed = True;
                    isPart2Passed = True;
                } else if(cont.Candidate_Requirements__r != NULL) {
                    for(Candidate_Requirement__c cr :cont.Candidate_Requirements__r) {
                        if(cr.RecordType.Name == 'Exam' && cr.Exam__c == 'FRM Part I' && cr.Status__c == 'Completed') {
                            isPart1Passed = True;
                        } else if(cr.RecordType.Name == 'Exam' && cr.Exam__c == 'FRM Part II' && cr.Status__c == 'Completed') {
                            isPart2Passed = True;
                        }
                    }
                }
            } else {
                // Expired FRM, counts as Net New
                isNetNew = True;
            }

            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isInProgram',isInProgram);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart1Passed',isPart1Passed);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart2Passed',isPart2Passed);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isNetNew',isNetNew);

            List<Account> lstAcct = [select Id, Block_Purchases_All_Types__c from Account where id = :membershipInfo.accountRecord.Id];
            if(!lstAcct.isEmpty()) {
                isPaymentBlocked = lstAcct[0].Block_Purchases_All_Types__c;
            }

            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPaymentBlocked',isPaymentBlocked);

            // AG - 10/17/2022 - Updated for Exams 2023
            List<Exam_Part__c> parts = [select Id, Name, Exam_Part_Number__c, Exam__r.Exam__c,
                                        Exam_Administration__c, Exam_Date__c, Exam_Start_Date__c
                                        from Exam_Part__c where Exam_Administration__c in :mapActiveExamAdmins.keyset() AND
                                        Exam__r.Exam__c in ('FRM Part 1','FRM Part 2')
                                       ];
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','parts',parts);

            MAP<String,Exam_Part__c> mapParts = new MAP<String,Exam_Part__c>();
            for(Exam_Part__c p :parts) {
                String key = p.Exam_Administration__c + ':' + p.Exam_Part_Number__c;
                mapParts.put(key,p);

                if(p.Exam__r.Exam__c == 'FRM Part 1') {
                    isPart1Offered = True;
                } else if(p.Exam__r.Exam__c == 'FRM Part 2') {
                    isPart2Offered = True;
                }
            }

            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','mapParts',mapParts);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart1Offered',isPart1Offered);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart2Offered',isPart2Offered);

            // AG - 10/17/2022 - Updated for Exams 2023
            List<Exam_Attempt__c> examRegistrations = [
                SELECT Id, Candidate_Commitment__r.EndDate, Candidate_Commitment__r.Last_Exam_Registration_Date__c,
                Candidate_Commitment__r.RecordType.Name, Contract_End_Date__c, Defered__c,
                Allow_Scheduling_Override__c,
                Active_Integration_Data__c,
                Integration_Data_Exam_Location__c,
                Integration_Data_Exam_Scheduled_Date__c,
                Exam_Administration__c,
                Exam_Administration__r.Exam_Results_Loading__c,
                Exam_Administration__r.Exam_Scheduling_Start_Date__c,
                Exam_Administration__r.Exam_Scheduling_End_Date__c,
                Exam_Site__r.Exam__r.Exam__c,
                Exam_Part__c, Exam_Part__r.Exam_Part_Number__c, Exam_Part__r.Exam_Date__c, Exam_Part__r.Exam_Start_Date__c,
                Opportunity_StageName__c, Member__c, Exam_Date__c, Exam_Site__c,
                Exam_Site__r.site__c, Section__c, Result__c, Candidate_Commitment__c,
                Candidate_Commitment__r.Status
                FROM Exam_Attempt__c
                WHERE
                (Candidate_Commitment__r.Status LIKE '%Activated%' OR Candidate_Commitment__r.Status = : 'Completed' OR Candidate_Commitment__r.Status = : 'Draft') AND
                Member__c = :contactId AND
                (Opportunity_StageName__c = 'Closed' OR Opportunity_StageName__c = 'New Lead') AND
                Candidate_Commitment__r.RecordType.Name in ('FRM Program') AND
                Cancelled__c != true
                ORDER BY Exam_Date__c DESC
            ];

            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','examRegistrations',examRegistrations);

            Integer cntDeferred=0;
            Integer cntActive=0;

            for (Exam_Attempt__c objFRMEA: examRegistrations) {

                GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','objFRMEA',objFRMEA);

                if(objFRMEA.Candidate_Commitment__r.Status == 'Draft' || objFRMEA.Opportunity_StageName__c == 'New Lead')  {
                    isOpenOrder = True;

                } else if(objFRMEA.Candidate_Commitment__r.Status != 'Completed')  {

                    GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','part1EA',part1EA);
                    GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','part1EA.Exam__c',objFRMEA.Exam_Site__r.Exam__r.Exam__c);

                    if(part1EA==Null && objFRMEA.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 1') {

                        part1EA = objFRMEA;

                        isPart1Registered = True;
                        isPart1IsScheduledOpen = (tdy >= objFRMEA.Exam_Administration__r.Exam_Scheduling_Start_Date__c && tdy <= objFRMEA.Exam_Administration__r.Exam_Scheduling_End_Date__c);
                        isPart1IsScheduledComplete = GARP_BC_MyPrograms.isProviderSchedulingComplete(objFRMEA);
                        isPart1HaveResult = (objFRMEA.Result__c != NULL);
                        isPart1IsScheduledExpired = (!isPart1IsScheduledOpen && !isPart1IsScheduledComplete && !isPart1HaveResult);

                        GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart1IsScheduledOpen',isPart1IsScheduledOpen);
                        GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart1IsScheduledComplete',isPart1IsScheduledComplete);
                        GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart1HaveResult',isPart1HaveResult);
                        GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart1IsScheduledExpired',isPart1IsScheduledExpired);

                        if(mapActiveExamAdmins.get(objFRMEA.Exam_Administration__c) != NULL) {
                            isPart1RegisteredInActiveAdmin = True;
                            part1RegisteredInActiveAdmin = objFRMEA;
                            isPart1RegisteredAwaitingResults = False;
                        } else { // Not in active admin
                            isPart1RegisteredInActiveAdmin = False;

                            if((objFRMEA.Defered__c == NULL || objFRMEA.Defered__c != 'Pending') &&
                               (objFRMEA.Result__c == null || objFRMEA.Result__c == '' || (objFRMEA.Result__c != NULL && GARP_BC_MyPrograms.isLoadingResults(objFRMEA.Exam_Administration__r.Exam_Results_Loading__c,loadKey)))) {
                                   isPart1RegisteredAwaitingResults = True;
                               }
                        }
                        if(objFRMEA.Defered__c == 'Pending') {
                            isPart1Deferred = True;
                            part1EA = objFRMEA;
                        }
                    }

                    if(part2EA==Null && objFRMEA.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 2') {

                        part2EA = objFRMEA;

                        isPart2Registered = True;
                        isPart2HaveResult = (objFRMEA.Result__c != NULL);

                        if(mapActiveExamAdmins.get(objFRMEA.Exam_Administration__c) != NULL) {
                            isPart2RegisteredInActiveAdmin = True;
                            part2RegisteredInActiveAdmin = objFRMEA;
                            isPart2RegisteredAwaitingResults = False;
                        } else { // Not in active admin
                            isPart2RegisteredInActiveAdmin = False;
                            if((objFRMEA.Defered__c == NULL || objFRMEA.Defered__c != 'Pending') &&
                               (objFRMEA.Result__c == null || objFRMEA.Result__c == '' || (objFRMEA.Result__c != NULL && GARP_BC_MyPrograms.isLoadingResults(objFRMEA.Exam_Administration__r.Exam_Results_Loading__c,loadKey)))) {
                                   isPart2RegisteredAwaitingResults = True;
                               }
                        }
                        if(objFRMEA.Defered__c == 'Pending') {
                            isPart2Deferred = True;
                            part2EA = objFRMEA;
                        }
                    }
                }
            }

            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart1RegisteredInActiveAdmin',isPart1RegisteredInActiveAdmin);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart1RegisteredAwaitingResults',isPart1RegisteredAwaitingResults);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart2RegisteredInActiveAdmin',isPart2RegisteredInActiveAdmin);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart2RegisteredAwaitingResults',isPart2RegisteredAwaitingResults);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart1Deferred',isPart1Deferred);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isPart2Deferred',isPart2Deferred);
            GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','isOpenOrder',isOpenOrder);


            // 7/3/2025 - Aug 2025 Part I not scheduled, Aug Reg is closed / not in "Active" Admin, will allow to reg - remove !isPart1RegisteredAwaitingResults && !isPart1RegisteredAwaitingResults
            //          - Added new check, if part 1 not registered OR if it is has a result
            if(!isOpenOrder && !isPaymentBlocked) {
                if(!isPart1Passed && isPart1Offered && !isPart1RegisteredInActiveAdmin && (!isPart1Registered || isPart1HaveResult) && !isPart1Deferred && !isPart2Deferred) {
                    eligibleExams.add('FRM Part 1');
                }

                if(!isPart2Passed && isPart2Offered && !isPart2RegisteredInActiveAdmin && (!isPart2Registered || isPart2HaveResult) && !isPart1IsScheduledExpired && !isPart1Deferred && !isPart2Deferred) {

                    // If already registered for Part I is Part II available in the same Admin on of after Part I
                    if(part1EA != NULL && isPart1RegisteredInActiveAdmin) {
                        String key1 = part1EA.Exam_Administration__c + ':' + part1EA.Exam_Part__r.Exam_Part_Number__c;
                        Exam_Part__c fndPart1 = mapParts.get(key1);
                        System.debug('fndPart1:' + fndPart1);
                        if(fndPart1 != NULL) {
                            for(String key :mapParts.keySet()) {

                                System.debug('key:' + key);

                                // If Part 2
                                if(key.indexOf(':2') > -1) {
                                    Exam_Part__c fndPart2 = mapParts.get(key);

                                    System.debug('fndPart2:' + fndPart2);

                                    if(fndPart2 != NULL) {
                                        if(fndPart2.Exam_Administration__c == fndPart1.Exam_Administration__c) {
                                            eligibleExams.add('FRM Part 2');
                                        } else {
                                            Date p1 = (fndPart1.Exam_Date__c != NULL) ? fndPart1.Exam_Date__c : fndPart1.Exam_Start_Date__c;
                                            Date p2 = (fndPart2.Exam_Date__c != NULL) ? fndPart2.Exam_Date__c : fndPart2.Exam_Start_Date__c;

                                            System.debug('p1:' + p1);
                                            System.debug('p2:' + p2);

                                            if(p1 != NULL && p1 != NULL && p2 >= p1) {
                                                eligibleExams.add('FRM Part 2');
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        eligibleExams.add('FRM Part 2');
                    }

                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','eligibleExams',eligibleExams);

        reObj.eligibleExams = eligibleExams;
        reObj.isRegistrationOpen = isRegistrationOpen;
        reObj.isPaymentBlocked = isPaymentBlocked;
        reObj.isInProgram = isInProgram;
        reObj.isOpenOrder = isOpenOrder;

        reObj.isPart1Passed = isPart1Passed;
        reObj.isPart1Offered = isPart1Offered;
        reObj.isPart1RegisteredInActiveAdmin = isPart1RegisteredInActiveAdmin;
        reObj.part1RegisteredInActiveAdmin = part1RegisteredInActiveAdmin;
        reObj.isPart1RegisteredAwaitingResults = isPart1RegisteredAwaitingResults;
        reObj.isPart1Deferred = isPart1Deferred;

        reObj.isPart2Passed = isPart2Passed;
        reObj.isPart2Offered = isPart2Offered;
        reObj.isPart2RegisteredInActiveAdmin = isPart2RegisteredInActiveAdmin;
        reObj.part2RegisteredInActiveAdmin = part2RegisteredInActiveAdmin;
        reObj.isPart2RegisteredAwaitingResults = isPart2RegisteredAwaitingResults;
        reObj.isPart2Deferred = isPart2Deferred;

        reObj.isNetNew = isNetNew;

        //return reObj;
        reObj.isEligible = True;

        if(eligibleExams.IsEmpty()) {
            if(!isRegistrationOpen) {
                reObj.eligibleError = 'Registration is not currently open';
                reObj.isEligible = False;
            } else if(isPaymentBlocked) {
                reObj.eligibleError = 'Your account is currently prohibited from registering';
                reObj.isEligible = False;
            } else if(isOpenOrder) {
                reObj.eligibleError = 'You already have a pending order for this program';
                reObj.isEligible = False;
            } else {
                reObj.eligibleError = 'You are already enrolled in this program';
                reObj.isEligible = False;
            }
        } else {
            reObj.eligibleError = null;
            reObj.isEligible = True;
        }


        GARP_Common.debugLog('GARP_BC_Exams','isEligibleFRM','final reObj',reObj);
        return reObj;
    }

    public static GARP_BC_Registration.examSiteInfo getSelectedExamSite(GARP_BC_Registration.partInfo partInfo) {
        GARP_BC_Registration.examSiteInfo selectedExamSite;
        for(GARP_BC_Registration.examAdminInfo ai :partInfo.examAdmins) {
            if(ai.id == partInfo.selectedAdminId) {
                for(GARP_BC_Registration.examSiteInfo es :ai.examSites) {
                    if(es.id == partInfo.selectedSiteId) {
                        selectedExamSite = es;
                        break;
                    }
                }
            }
        }
        return selectedExamSite;
    }

    public static Contract getOSTAContract(Id accountId){

        List<Contract> ostaPrograms = [
            SELECT Id, RecordType.Name, Status
            FROM Contract
            WHERE
            AccountId = :accountId AND
            RecordType.Name = 'OSTA Program' AND
            Status LIKE 'Activated%'
        ];

        Contract contract = (ostaPrograms.isEmpty()) ? null : ostaPrograms[0];

        return contract;
    }

    public static Contract getExamContract(Id accountId){

        List<Contract> contracts = [
            SELECT Id, Name, RecordTypeId, Status,
            (
                SELECT Id, Name, Status__c, Exam__c, RecordType.Name
                FROM Candidate_Requirements__r
            )
            FROM Contract
            WHERE
            AccountId = :accountId AND
            RecordType.Name = 'FRM Program' AND
            (Status LIKE 'Activated%' OR Status = 'Completed' OR Status = 'Expired')
            order by StartDate DESC
            LIMIT 1
        ];

        Contract contract = (contracts.isEmpty()) ? null : contracts[0];

        return contract;

    }

    // Override and expand exam rates using exam rate offers
    public static List<Exam_Rate__c> getExamRates(List<Exam_Rate__c> ratesByWindow, GARP_BC_Membership.membershipInfo membershipInfo, Boolean expand, Boolean availPart1, Boolean availPart2) {
        GARP_Common.debugLog('GARP_BC_Exams','getExamRates','ratesByWindow',ratesByWindow);
        GARP_Common.debugLog('GARP_BC_Exams','getExamRates','membershipInfo',membershipInfo);
        GARP_Common.debugLog('GARP_BC_Exams','getExamRates','availPart1',availPart1);
        GARP_Common.debugLog('GARP_BC_Exams','getExamRates','availPart2',availPart2);

        // Map Exam Part ID to Exam Rate
        MAP<String, Exam_Rate__c> mapReturnRates = new MAP<String, Exam_Rate__c>();

        Map<Id, Exam_Rate_Offering__c> examRateOfferingByExamPart = new Map<Id, Exam_Rate_Offering__c>();
        if(membershipInfo != NULL && membershipInfo.contactRecord != NULL && membershipInfo.contactRecord.Id != NULL) {
            examRateOfferingByExamPart = getExamRateOfferings(membershipInfo.contactRecord.Id);
        }
        //else {
        //    return ratesByWindow;
        //}
        GARP_Common.debugLog('GARP_BC_Exams','getExamRates','examRateOfferingByExamPart',examRateOfferingByExamPart);

        // Compute Final Exam Rates
        //List<Exam_Rate__c> rates = new List<Exam_Rate__c>();
        Set<String> ratesByWindowParts = new Set<String>();
        Date tdy = Date.Today();

        // Collect current window rates and overrides
        for(Exam_Rate__c er :ratesByWindow) {
            GARP_Common.debugLog('GARP_BC_Exams','getExamRates','Loop rates',er);

            // Collect all Rate Parts in current window
            ratesByWindowParts.add(er.Exam_Part__c);

            // Check for Exam Offer Override
            Exam_Rate_Offering__c examRateOffer;
            if(examRateOfferingByExamPart.size() > 0) {
                examRateOffer = examRateOfferingByExamPart.get(er.Exam_Part__c);
                GARP_Common.debugLog('GARP_BC_Exams','getExamRates','examRateOffer',examRateOffer);
            }

            if(examRateOffer != NULL) {

                GARP_Common.debugLog('GARP_BC_Exams','getExamRates','examRateOffer Part',examRateOffer.Exam_Rate__r.Exam_Part__r.Exam_Part_Number__c);

                if((examRateOffer.Exam_Rate__r.Exam_Part__r.Exam_Part_Number__c == 1 && availPart1) || (examRateOffer.Exam_Rate__r.Exam_Part__r.Exam_Part_Number__c == 2 && availPart2)) {
                    mapReturnRates.put(examRateOffer.Exam_Rate__r.Exam_Part__c, examRateOffer.Exam_Rate__r);
                }

                //rates.add(examRateOffer.Exam_Rate__r);
            } else {
                if(tdy >= er.Exam_Registration_Window__r.Exam_Registration_Window_Open__c &&
                   tdy <= er.Exam_Registration_Window__r.Exam_Registration_Window_Close__c
                  ) {
                    //rates.add(er);
                    mapReturnRates.put(er.Exam_Part__c, er);
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Exams','getExamRates','mapReturnRates',mapReturnRates);
        GARP_Common.debugLog('GARP_BC_Exams','getExamRates','ratesByWindowParts',ratesByWindowParts);

        if(expand) {
            // Look for additional windows via Exam Rate Offerings
            for(Exam_Rate_Offering__c ero :examRateOfferingByExamPart.values()) {
                GARP_Common.debugLog('GARP_BC_Exams','getExamRates','Loop rate offers',ero);

                if((ero.Exam_Rate__r.Exam_Part__r.Exam_Part_Number__c == 1 && availPart1) || (ero.Exam_Rate__r.Exam_Part__r.Exam_Part_Number__c == 2 && availPart2)) {

                    // If Offer's Part is not in current windows, add this rate
                    if(!ratesByWindowParts.contains(ero.Exam_Rate__r.Exam_Part__c)) {
                        //rates.add(ero.Exam_Rate__r);
                        mapReturnRates.put(ero.Exam_Rate__r.Exam_Part__c, ero.Exam_Rate__r);
                        GARP_Common.debugLog('GARP_BC_Exams','getExamRates','Add new rate',ero.Exam_Rate__r);
                    }
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Exams','getExamRates','final rates',mapReturnRates);

        return mapReturnRates.values();
    }

    public static Map<Id, Exam_Rate_Offering__c> getExamRateOfferings(String contactId) {
        Map<Id, Exam_Rate_Offering__c> examRateOfferingByExamPart = new Map<Id, Exam_Rate_Offering__c>();
        if(contactId != NULL) {
            List<Exam_Rate_Offering__c> examRateOfferings = [
                SELECT Id, Contact__c, Start_Date__c, End_Date__c, Offering_Part__c,
                Exam_Rate__c, Exam_Rate__r.Name,

                Exam_Rate__r.Product__c, Exam_Rate__r.Product__r.ProductCode, Exam_Rate__r.Product__r.GL_Code__c,
                Exam_Rate__r.Exam_Part__c, Exam_Rate__r.Exam_Part__r.Exam_Part_Number__c,
                Exam_Rate__r.Exam_Administration__c, Exam_Rate__r.Exam_Administration__r.Name,
                Exam_Rate__r.Exam_Registration_Window__c, Exam_Rate__r.Exam_Registration_Window__r.Type__c,

                Exam_Rate__r.Team_Product__r.ProductCode, Exam_Rate__r.Team_Product__r.GL_Code__c,
                Exam_Rate__r.Team_Scholarship_Product__r.ProductCode, Exam_Rate__r.Team_Scholarship_Product__r.GL_Code__c

                FROM Exam_Rate_Offering__c
                WHERE
                Contact__c = :contactId AND
                Start_Date__c <= TODAY AND
                End_Date__c >= TODAY
            ];
            GARP_Common.debugLog('GARP_BC_Exams','getExamRateOfferings','examRateOfferings',examRateOfferings);

            if(!examRateOfferings.isEmpty()){
                for(Exam_Rate_Offering__c ero: examRateOfferings){
                    examRateOfferingByExamPart.put(ero.Exam_Rate__r.Exam_Part__c, ero);
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Exams','getExamRateOfferings','examRateOfferingByExamPart',examRateOfferingByExamPart);

        return examRateOfferingByExamPart;
    }

    public class examNotificationInfo {
        public String notificationTitle;
        public String notificationDetails;
        public Date notificationDate;
    }

    public static List<examNotificationInfo> getExamMemberNotifications(String contactId, String programType) {

        MAP<String,examNotificationInfo> notifications = new MAP<String,examNotificationInfo>();

        List<Member_Notification_Recipient__c> lstNotifications = [select Id, Name, Email__c, GARP_ID__c, Sending_Status__c, Sent_Date_Time__c, Sent_Message__c, Is_Viewed_In_Portal__c, Member_Notification__c,
                                                         Member_Notification__r.Subject__c from Member_Notification_Recipient__c where
                                                         Sending_Status__c = 'Sent' AND
                                                         Member_Notification__r.Show_In_Portal__c = TRUE AND
                                                         Member_Notification__r.Expire_Date__c > TODAY AND
                                                         Contact__c = :contactId AND Member_Notification__r.Type__c = 'Exam' AND
                                                         Member_Notification__r.Status__c = 'Sent' ORDER BY Sent_Date_Time__c DESC];
        GARP_Common.debugLog('GARP_BC_Exams','getExamMemberNotifications','lstNotifications',lstNotifications);

        for(Member_Notification_Recipient__c mnr :lstNotifications) {
            examNotificationInfo examNotificationInfo = new examNotificationInfo();
            examNotificationInfo.notificationTitle = mnr.Member_Notification__r.Subject__c;
            examNotificationInfo.notificationDetails = mnr.Sent_Message__c;
            examNotificationInfo.notificationDate = Date.NewInstance(mnr.Sent_Date_Time__c.year(), mnr.Sent_Date_Time__c.month(), mnr.Sent_Date_Time__c.day());
            notifications.put(mnr.Member_Notification__c, examNotificationInfo);
        }

        // Get Exam Site Notifications
        GARP_BC_MyPrograms.returnLatestExamAttempts retAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contactId);

        Set<String> exmSiteIDs = new Set<String>();
        for(Exam_Attempt__c ea :retAttempts.mapLatestExamAttempts.Values()) {
            exmSiteIDs.add(ea.Exam_Site__c);
        }

        if(!exmSiteIDs.IsEmpty()) {
            List<Member_Notification_Exam_Site__c> memnoteexamsites = [select Id, Member_Notification__c, Member_Notification__r.Subject__c, Member_Notification__r.Custom_Message__c, Member_Notification__r.Sent_Date_Time__c,
                                                                       Exam_Sites__c, Exam_Sites__r.Exam__r.Exam__c
                                                                       from Member_Notification_Exam_Site__c
                                                                       where Exam_Sites__c in :exmSiteIDs AND
                                                                       Member_Notification__r.Expire_Date__c > TODAY AND
                                                                       Member_Notification__r.Show_In_Portal__c = TRUE AND
                                                                       Member_Notification__r.Status__c NOT IN ('Draft','Cancelled','Error','Preparing to Send')];

            for(Member_Notification_Exam_Site__c mnes :memnoteexamsites) {

                if(programType == NULL || (mnes.Exam_Sites__r.Exam__r.Exam__c.IndexOf(programType) > -1)) {
                    examNotificationInfo examNotificationInfo = new examNotificationInfo();
                    examNotificationInfo.notificationTitle = mnes.Member_Notification__r.Subject__c;
                    examNotificationInfo.notificationDetails = mnes.Member_Notification__r.Custom_Message__c;
                    examNotificationInfo.notificationDate = Date.NewInstance(mnes.Member_Notification__r.Sent_Date_Time__c.year(), mnes.Member_Notification__r.Sent_Date_Time__c.month(), mnes.Member_Notification__r.Sent_Date_Time__c.day());
                    notifications.put(mnes.Member_Notification__c, examNotificationInfo);
                }

            }
        }

        return notifications.Values();
    }
}