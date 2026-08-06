public class GARP_BC_MyPrograms {
    // Portal V2

    // Exam Setup

    // Helper
    // Get FRM & SCR Exam Attempts
    // Key is Exam Type (FRM,SCR,RiskAI) + Part (For FRM = I or II, for others is Full)
    public class returnLatestExamAttempts {
        public MAP<String,Exam_Attempt__c> mapLatestExamAttempts;
        public List<Exam_Attempt__c> allExamAttempts;
    }

    public static returnLatestExamAttempts getLatestExamAttempts(String contactId) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getLatestExamAttempts','contactId',contactId);

        returnLatestExamAttempts returnLatestExamAttempts = new returnLatestExamAttempts();

        returnLatestExamAttempts.mapLatestExamAttempts = new MAP<String,Exam_Attempt__c>();

        returnLatestExamAttempts.allExamAttempts = [SELECT Id, RPT_Exam_Program__c, RPT_Administration_Date__c, RPT_Administration_Year__c, RPT_Administration_Month__c, RPT_Exam_Part__c, RPT_Exam_Mode__c,
                                             Results_Viewed_Date__c, Integration_Data_Exam_Location__c, Deferral_Status__c,
                                             Integration_Data_Exam_Scheduled_Date__c, Integration_Data_Exam_Scheduled_TimeZone__c, Integration_Data_Exam_Mode__c,RPT_Exam_Delivered__c,
                                             Result__c, hasViolation__c, Hide_Exam_Result__c, Allow_Scheduling_Override__c, Allow_Future_Deferral__c, Active_Integration_Data__c, Icbrr_Exam_Date__c, Opportunity__c, Opportunity__r.StageName,
                                             Defered__c,
                                             Exam_Site__c,
                                             Exam_Site__r.Exam_Provider__r.Name,
                                             Exam_Site__r.Site__r.Is_OSTA_Information_Required__c,

                                             Exam_Site__r.Exam__c,
                                             Exam_Site__r.Exam__r.Exam__c,
                                             Exam_Site__r.Exam__r.Exam_Group__r.RecordType.Name,

                                             Deferred_Exam_Administration__c,
                                             Deferred_Exam_Administration__r.Month__c, Deferred_Exam_Administration__r.Year__c,
                                             Deferred_Exam_Administration__r.Exam_Scheduling_Start_Date__c, Integration_Data_Status__c,

                                             Exam_Part__c,
                                             Exam_Part__r.Exam_Part_Number__c,
                                             Exam_Part__r.Exam_Administration__c,
                                             Exam_Part__r.Exam__r.Exam__c,

                                             Exam_Part__r.Exam_Results_Release_Date__c,
                                             Exam_Part__r.Exam_Results_Available_Statement__c,
                                             Exam_Part__r.Exam_Date__c,
                                             Exam_Part__r.Exam_Start_Date__c,
                                             Exam_Part__r.Exam_End_Date__c,

                                             Exam_Site__r.Exam_Part__c,
                                             Exam_Site__r.Exam_Part__r.Exam_Part_Number__c,
                                             Exam_Site__r.Exam_Part__r.Exam_Administration__c,
                                             Exam_Site__r.Exam_Part__r.Exam__r.Exam__c,

                                             Exam_Site__r.Exam_Part__r.Exam_Results_Release_Date__c,
                                             Exam_Site__r.Exam_Part__r.Exam_Results_Available_Statement__c,
                                             Exam_Site__r.Exam_Part__r.Exam_Date__c,
                                             Exam_Site__r.Exam_Part__r.Exam_Start_Date__c,
                                             Exam_Site__r.Exam_Part__r.Exam_End_Date__c,

                                             Exam_Administration__c,
                                             Exam_Administration__r.Exam_Group__c,
                                             Exam_Administration__r.Exam_Scheduling_Start_Date__c,
                                             Exam_Administration__r.Exam_Scheduling_End_Date__c,
                                             Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c,
                                             Exam_Administration__r.Exam_Admin_Modifications_End_Date__c,
                                             Exam_Administration__r.Exam_Results_Release_Date__c,
                                             Exam_Administration__r.Exam_Results_Available_Statement__c,
                                             Exam_Administration__r.Exam_Results_Loading__c,
                                             Exam_Administration__r.Last_Date_For_ADA__c,
                                             Exam_Administration__r.Is_Scheduling_Open__c,
                                             Exam_Administration__r.Is_Modification_Open__c,
                                             Exam_Administration__r.Registration_Start_Date__c,
                                             Exam_Administration__r.Registration_End_Date__c,

                                             Original_Exam_Administration__c,
                                             Original_Exam_Administration__r.Is_Scheduling_Open__c,
                                             Original_Exam_Administration__r.Is_Modification_Open__c,

                                             Deferred_From_Exam_Registration__c,
                                             Deferred_From_Exam_Registration__r.Exam_Administration__r.Is_Modification_Open__c

                                             FROM Exam_Attempt__c
                                             WHERE RPT_Exam_Program__c in ('FRM','ERP','SCR','RiskAI','RAIJ','FRR','FRR25','FRRMC1','FRRMC2','FRRMC3','FRRMC4') AND Member__c = :contactId AND
                                             Cancelled__c = FALSE AND Opportunity_StageName__c in ('New Lead','Closed')
                                             ORDER BY RPT_Administration_Date__c DESC];
        GARP_Common.debugLog('GARP_BC_MyPrograms','getLatestExamAttempts','allExamAttempts',returnLatestExamAttempts.allExamAttempts);

        if(!returnLatestExamAttempts.allExamAttempts.IsEmpty()) {

            for(Exam_Attempt__c ea :returnLatestExamAttempts.allExamAttempts) {


                String partKey = ea.RPT_Exam_Program__c+ea.RPT_Exam_Part__c;
                if(ea.RPT_Exam_Program__c == 'FRM') {
                    if(ea.RPT_Exam_Part__c == 'Full') {
                        partKey = 'FRMI';
                    }
                } else if(ea.RPT_Exam_Program__c == 'ERP') {
                    if(ea.RPT_Exam_Part__c == 'Full') {
                        partKey = 'ERPI';
                    }
                }

                Exam_Attempt__c frmExamAttempt = returnLatestExamAttempts.mapLatestExamAttempts.get(partKey);
                if(frmExamAttempt == NULL && ea.RPT_Exam_Program__c == 'FRM') {
                    returnLatestExamAttempts.mapLatestExamAttempts.put(partKey, ea);
                }

                Exam_Attempt__c erpExamAttempt = returnLatestExamAttempts.mapLatestExamAttempts.get(partKey);
                if(erpExamAttempt == NULL && ea.RPT_Exam_Program__c == 'ERP') {
                    returnLatestExamAttempts.mapLatestExamAttempts.put(partKey, ea);
                }

                Exam_Attempt__c scrExamAttempt = returnLatestExamAttempts.mapLatestExamAttempts.get('SCR'+ea.RPT_Exam_Part__c);
                if(scrExamAttempt == NULL && ea.RPT_Exam_Program__c == 'SCR') {
                    returnLatestExamAttempts.mapLatestExamAttempts.put('SCR'+ea.RPT_Exam_Part__c, ea);
                }

                Exam_Attempt__c raijExamAttempt = returnLatestExamAttempts.mapLatestExamAttempts.get('RAIJ'+ea.RPT_Exam_Part__c);
                if(raijExamAttempt == NULL && ea.RPT_Exam_Program__c == 'RAIJ') {
                    returnLatestExamAttempts.mapLatestExamAttempts.put('RAIJ'+ea.RPT_Exam_Part__c, ea);
                }

                Exam_Attempt__c riskaiExamAttempt = returnLatestExamAttempts.mapLatestExamAttempts.get('RiskAI'+ea.RPT_Exam_Part__c);
                if(riskaiExamAttempt == NULL && ea.RPT_Exam_Program__c == 'RiskAI') {
                    returnLatestExamAttempts.mapLatestExamAttempts.put('RiskAI'+ea.RPT_Exam_Part__c, ea);
                }

                Exam_Attempt__c frrExamAttempt = returnLatestExamAttempts.mapLatestExamAttempts.get('FRR'+ea.RPT_Exam_Part__c);
                if(frrExamAttempt == NULL && ea.RPT_Exam_Program__c == 'FRR') {
                    returnLatestExamAttempts.mapLatestExamAttempts.put('FRR'+ea.RPT_Exam_Part__c, ea);
                }

                Exam_Attempt__c frr25ExamAttempt = returnLatestExamAttempts.mapLatestExamAttempts.get('FRR25'+ea.RPT_Exam_Part__c);
                if(frr25ExamAttempt == NULL && ea.RPT_Exam_Program__c == 'FRR25') {
                    returnLatestExamAttempts.mapLatestExamAttempts.put('FRR25'+ea.RPT_Exam_Part__c, ea);
                }

                // Micro Course
                if(ea.Exam_Site__r.Exam__r.Exam_Group__r.RecordType.Name == 'MicroCourse') {
                    Exam_Attempt__c microExamAttempt = returnLatestExamAttempts.mapLatestExamAttempts.get(ea.Exam_Site__r.Exam__r.Exam__c+ea.RPT_Exam_Part__c);
                    if(microExamAttempt == NULL && ea.RPT_Exam_Program__c == ea.Exam_Site__r.Exam__r.Exam__c) {
                        returnLatestExamAttempts.mapLatestExamAttempts.put(ea.Exam_Site__r.Exam__r.Exam__c+ea.RPT_Exam_Part__c, ea);
                    }
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getLatestExamAttempts','mapLatestExamAttempts',returnLatestExamAttempts.mapLatestExamAttempts);

        return returnLatestExamAttempts;
    }

    public class returnGetLatestExamAttemptsByType {
        public Exam_Attempt__c examAttemptPart1;
        public Exam_Attempt__c examAttemptPart2;
    }

    public static returnGetLatestExamAttemptsByType getLatestExamAttemptsByType(String examType, MAP<String,Exam_Attempt__c> mapLatestExamAttempts) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getLatestExamAttemptsByType','examType',examType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getLatestExamAttemptsByType','mapLatestExamAttempts',mapLatestExamAttempts);

        returnGetLatestExamAttemptsByType returnGetLatestExamAttemptsByType = new returnGetLatestExamAttemptsByType();

        String examProgramType = examType;
        if(examType == 'rai') {
            examProgramType = 'RiskAI';
        } else if(examType == 'raij') {
            examProgramType = 'RAIJ';
        }

        for(Exam_Attempt__c ea :mapLatestExamAttempts.Values()) {
            if(ea.RPT_Exam_Program__c != NULL && ea.RPT_Exam_Program__c.ToUpperCase() == examProgramType.ToUpperCase()) {
                if(ea.RPT_Exam_Part__c == 'I' || ea.RPT_Exam_Part__c == 'Full') {
                    returnGetLatestExamAttemptsByType.examAttemptPart1 = ea;
                } else if(ea.RPT_Exam_Part__c == 'II') {
                    returnGetLatestExamAttemptsByType.examAttemptPart2 = ea;
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','getLatestExamAttemptsByType','examAttemptPart1',returnGetLatestExamAttemptsByType.examAttemptPart1);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getLatestExamAttemptsByType','examAttemptPart2',returnGetLatestExamAttemptsByType.examAttemptPart2);

        return returnGetLatestExamAttemptsByType;
    }

    public static List<Exam_Sites__c> getRelatedExamSites(examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getRelatedExamSites','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);

        List<Exam_Sites__c> lstSites;

        List<String> siteIDs = new List<String>();
        if(examSetupExamSelectionsInfo != NULL && examSetupExamSelectionsInfo.selectedSitePart1 != NULL) {
            siteIDs.add(examSetupExamSelectionsInfo.selectedSitePart1);
        }
        if(examSetupExamSelectionsInfo != NULL && examSetupExamSelectionsInfo.selectedSitePart2 != NULL) {
            siteIDs.add(examSetupExamSelectionsInfo.selectedSitePart2);
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','getRelatedExamSites','siteIDs',siteIDs);

        if(!siteIDs.IsEmpty()) {
            lstSites = [select id, Site__c, Site__r.Is_OSTA_Information_Required__c, Exam__r.Exam__c,
                        Exam_Part__r.Exam_Administration__r.Exam_Scheduling_Start_Date__c, Exam_Part__r.Exam_Administration__r.Exam_Scheduling_End_Date__c
                        from Exam_Sites__c where id in :siteIDs];
            GARP_Common.debugLog('GARP_BC_MyPrograms','getRelatedExamSites','lstSites',lstSites);
        }
        return lstSites;
    }

    public class examSetupSelectionData {
        public List<Exam_Administration__c> examAdmins;
        public List<Exam_Part__c> examParts;
        public List<Exam_Sites__c> examSites;

        public Boolean allowSchedulingPart1;
        public Boolean allowAdminModPart1;
        public Boolean isAdminScheduledPart1;
        public Boolean isAdminDeferredPart1;
        public Exam_Attempt__c examRegPart1;

        public Boolean allowSchedulingPart2;
        public Boolean allowAdminModPart2;
        public Boolean isAdminScheduledPart2;
        public Boolean isAdminDeferredPart2;
        public Exam_Attempt__c examRegPart2;

        public Exam_Administration__c currentExamAdmin1;
        public Exam_Administration__c currentExamAdmin2;
        public Exam_Part__c currentExamPart1;
        public Exam_Part__c currentExamPart2;
        public Exam_Sites__c currentExamSite1;
        public Exam_Sites__c currentExamSite2;

        public String currentExamSiteId1;
        public String currentExamSiteId2;

        public Exam_Administration__c selectedExamAdmin1;
        public Exam_Administration__c selectedExamAdmin2;
        public Exam_Part__c selectedExamPart1;
        public Exam_Part__c selectedExamPart2;
        public Exam_Sites__c selectedExamSite1;
        public Exam_Sites__c selectedExamSite2;

        public String selectedExamSiteId1;
        public String selectedExamSiteId2;

        MAP<String, Exam_Administration__c> mapExamAdminByID;
        MAP<String, Exam_Part__c> mapExamPart1ByExamAdmin;
        MAP<String, Exam_Part__c> mapExamPart2ByExamAdmin;
        MAP<String, Exam_Sites__c> mapExamSiteByID;
    }

    public static examSetupSelectionData getExamSetupSelectionData(String examType, returnGetLatestExamAttemptsByType examAttempts, examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examType',examType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examAttempts',examAttempts);

        examSetupSelectionData examSetupSelectionData = new examSetupSelectionData();

        examSetupSelectionData.allowSchedulingPart1 = FALSE;
        examSetupSelectionData.allowAdminModPart1 = FALSE;
        examSetupSelectionData.isAdminScheduledPart1 = FALSE;
        examSetupSelectionData.isAdminDeferredPart1 = False;
        examSetupSelectionData.allowSchedulingPart2 = FALSE;
        examSetupSelectionData.allowAdminModPart2 = FALSE;
        examSetupSelectionData.isAdminScheduledPart2 = FALSE;
        examSetupSelectionData.isAdminDeferredPart2 = False;

        Date tdy = Date.Today();

        Set<String> examPartNames;
        Set<String> examAdminTypeNames;
        Integer maxExamAdminsIntoTheFuture;
        if(examType == 'frm') {
            examPartNames = new Set<String>{'FRM Part 1', 'FRM Part 2'};
            examAdminTypeNames = new Set<String>{'FRM','FRM/ERP'};
            maxExamAdminsIntoTheFuture = 2;
        } else if(examType == 'erp') {
            examPartNames = new Set<String>{'ERP Exam Part I', 'ERP Exam Part II'};
            examAdminTypeNames = new Set<String>{'ERP','FRM/ERP'};
            maxExamAdminsIntoTheFuture = 2;
        } else if(examType == 'scr') {
            examPartNames = new Set<String>{'SCR'};
            examAdminTypeNames = new Set<String>{'SCR','SCR'};
            maxExamAdminsIntoTheFuture = 1;
        } else if(examType == 'raij') {
            examPartNames = new Set<String>{'RAIJ'};
            examAdminTypeNames = new Set<String>{'RAIJ','RAIJ'};
            maxExamAdminsIntoTheFuture = 1;
        } else {
            examPartNames = new Set<String>{'RiskAI'};
            examAdminTypeNames = new Set<String>{'RiskAI','RiskAI'};
            maxExamAdminsIntoTheFuture = 1;
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examPartNames',examPartNames);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examAdminTypeNames',examAdminTypeNames);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','maxExamAdminsIntoTheFuture',maxExamAdminsIntoTheFuture);

        Set<String> examGroupIds = new Set<String>();
        Set<String> examAdminIds = new Set<String>();
        Set<String> currentSiteIds = new Set<String>();

        Boolean isPart1PastScheduledDate = False;

        if(examAttempts.examAttemptPart1 != NULL && examAttempts.examAttemptPart1.Opportunity__r.StageName == 'Closed') {
            examSetupSelectionData.examRegPart1 = examAttempts.examAttemptPart1;
            examSetupSelectionData.isAdminDeferredPart1 = (examAttempts.examAttemptPart1.Deferred_Exam_Administration__c != NULL);
            examSetupSelectionData.isAdminScheduledPart1 = (examAttempts.examAttemptPart1.Integration_Data_Exam_Scheduled_Date__c != NULL);

            if(examSetupSelectionData.isAdminScheduledPart1) {
                if(tdy >= examAttempts.examAttemptPart1.Integration_Data_Exam_Scheduled_Date__c) {
                    isPart1PastScheduledDate = True;
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','isAdminDeferredPart1',examSetupSelectionData.isAdminDeferredPart1);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','isAdminScheduledPart1',examSetupSelectionData.isAdminScheduledPart1);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','isPart1PastScheduledDate',isPart1PastScheduledDate);

        if(examAttempts.examAttemptPart1 != NULL && examAttempts.examAttemptPart1.Opportunity__r.StageName == 'Closed' && !isPart1PastScheduledDate &&
           (examAttempts.examAttemptPart1.Exam_Administration__r.Is_Scheduling_Open__c || examAttempts.examAttemptPart1.Allow_Scheduling_Override__c)) {

               examSetupSelectionData.allowSchedulingPart1 = True;

               if(examAttempts.examAttemptPart1.Exam_Administration__r.Is_Modification_Open__c) {
                   examSetupSelectionData.allowAdminModPart1 = True;
               }

                examGroupIds.add(examAttempts.examAttemptPart1.Exam_Administration__r.Exam_Group__c);
                examAdminIds.add(examAttempts.examAttemptPart1.Exam_Administration__c);
                /*
                if(examAttempts.examAttemptPart1.Original_Exam_Administration__c != NULL && examAttempts.examAttemptPart1.Original_Exam_Administration__r.Is_Modification_Open__c) {
                    examAdminIds.add(examAttempts.examAttemptPart1.Original_Exam_Administration__c);
                }
                if(examAttempts.examAttemptPart1.Deferred_Exam_Administration__c != NULL) {
                    examAdminIds.add(examAttempts.examAttemptPart1.Deferred_Exam_Administration__c);
                }
                */
                currentSiteIds.add(examAttempts.examAttemptPart1.Exam_Site__c);
            }

        Boolean isPart2PastScheduledDate = False;

        if(examAttempts.examAttemptPart2 != NULL && examAttempts.examAttemptPart2.Opportunity__r.StageName == 'Closed') {
            examSetupSelectionData.examRegPart2 = examAttempts.examAttemptPart2;
            examSetupSelectionData.isAdminDeferredPart2 = (examAttempts.examAttemptPart2.Deferred_Exam_Administration__c != NULL);
            examSetupSelectionData.isAdminScheduledPart2 = (examAttempts.examAttemptPart2.Integration_Data_Exam_Scheduled_Date__c != NULL);

            if(examSetupSelectionData.isAdminScheduledPart2) {
                if(tdy >= examAttempts.examAttemptPart2.Integration_Data_Exam_Scheduled_Date__c) {
                    isPart2PastScheduledDate = True;
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','isAdminDeferredPart2',examSetupSelectionData.isAdminDeferredPart2);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','isAdminScheduledPart2',examSetupSelectionData.isAdminScheduledPart2);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','isPart2PastScheduledDate',isPart2PastScheduledDate);

        if(examAttempts.examAttemptPart2 != NULL && examAttempts.examAttemptPart2.Opportunity__r.StageName == 'Closed' && !isPart2PastScheduledDate &&
           (examAttempts.examAttemptPart2.Exam_Administration__r.Is_Scheduling_Open__c || examAttempts.examAttemptPart2.Allow_Scheduling_Override__c)) {
            //(examAttempts.examAttemptPart2.Original_Exam_Administration__c != NULL && examAttempts.examAttemptPart2.Original_Exam_Administration__r.Is_Scheduling_Open__c))) {

                examSetupSelectionData.allowSchedulingPart2 = True;

                //if((examAttempts.examAttemptPart2.Original_Exam_Administration__c != NULL && examAttempts.examAttemptPart2.Original_Exam_Administration__r.Is_Modification_Open__c) ||
                //   (examAttempts.examAttemptPart2.Original_Exam_Administration__c != NULL && examAttempts.examAttemptPart2.Original_Exam_Administration__r.Is_Modification_Open__c)) {
                //       examSetupSelectionData.allowAdminModPart2 = True;
                //   }

                if(examAttempts.examAttemptPart2.Exam_Administration__r.Is_Modification_Open__c) {
                   examSetupSelectionData.allowAdminModPart2 = True;
               }


               examGroupIds.add(examAttempts.examAttemptPart2.Exam_Administration__r.Exam_Group__c);
               examAdminIds.add(examAttempts.examAttemptPart2.Exam_Administration__c);

               /*
                if(examAttempts.examAttemptPart2.Original_Exam_Administration__c != NULL) {
                examAdminIds.add(examAttempts.examAttemptPart2.Original_Exam_Administration__c);
                }
                if(examAttempts.examAttemptPart2.Deferred_Exam_Administration__c != NULL) {
                examAdminIds.add(examAttempts.examAttemptPart2.Deferred_Exam_Administration__c);
                }
                */
               currentSiteIds.add(examAttempts.examAttemptPart2.Exam_Site__c);
            }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examSetupSelectionData.examRegPart1',examSetupSelectionData.examRegPart1);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examSetupSelectionData.examRegPart2',examSetupSelectionData.examRegPart2);

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','allowSchedulingPart1',examSetupSelectionData.allowSchedulingPart1);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','allowAdminModPart1',examSetupSelectionData.allowAdminModPart1);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','allowSchedulingPart2',examSetupSelectionData.allowSchedulingPart2);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','allowAdminModPart2',examSetupSelectionData.allowAdminModPart2);

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examGroupIds',examGroupIds);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examAdminIds',examAdminIds);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','currentSiteIds',currentSiteIds);

        List<Exam_Group__c> lstExamGroups = [select Id, Name, Next_Exam_Group__c
                                             from Exam_Group__c where ID = :examGroupIds];
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','lstExamGroups',lstExamGroups);

        if(lstExamGroups != NULL && lstExamGroups.size() > 0) {
            for(Exam_Group__c eg :lstExamGroups) {
                if(eg.Next_Exam_Group__c != NULL) {
                    examGroupIds.add(eg.Next_Exam_Group__c );
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','final examGroupIds',examGroupIds);

        examSetupSelectionData.examAdmins = new List<Exam_Administration__c>();

        List<Exam_Administration__c> lstExamAdmins = [select Id, Name, Exam_Group__c, Exam_Type__c, Month__c, Year__c,
                                                   Registration_Start_Date__c, Registration_End_Date__c,
                                                   Exam_Admin_Modifications_Start_Date__c, Exam_Admin_Modifications_End_Date__c,
                                                   Exam_Scheduling_Start_Date__c, Exam_Scheduling_End_Date__c, Contingency_Administration__c,
                                                   Is_Scheduling_Open__c, Is_Modification_Open__c
                                                   from Exam_Administration__c
                                                   where Exam_Group__c in :examGroupIds AND
                                                   Exam_Type__c in :examAdminTypeNames AND
                                                   (Registration_End_Date__c >= TODAY OR Id in :examAdminIds) AND
                                                   (Contingency_Administration__c = False OR Id in :examAdminIds)
                                                   ORDER BY Registration_Start_Date__c];
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','lstExamAdmins',lstExamAdmins);

        // Only grab so many into the future
        Integer cnt = 0;
        for(Exam_Administration__c ea :lstExamAdmins) {
            examSetupSelectionData.examAdmins.add(ea);
            cnt++;
            if(cnt > maxExamAdminsIntoTheFuture) {
                break;
            }
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examAdmins',examSetupSelectionData.examAdmins);

        examSetupSelectionData.examParts = [select Id, Name, Exam__c, Exam_Administration__c, Exam_Part_Number__c,
                                                  Exam_Date__c, Exam_Start_Date__c, Exam_End_Date__c
                                                  from
                                                  Exam_Part__c where
                                                  Exam_Administration__c in :examSetupSelectionData.examAdmins AND Exam__r.Exam__c in :examPartNames];
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examParts', examSetupSelectionData.examParts);

        examSetupSelectionData.examSites = [
            SELECT
            Id,
            Name,
            Country__c,
            Exam_Part__c,
            Exam_Part__r.Exam_Administration__c,
            Exam_Part__r.Exam__r.Exam__c,
            Exam_Part__r.Exam_Part_Number__c,
            Exam_Provider__c,
            Exam_Provider__r.Name,
            Exam__c,
            Exam__r.Exam__c,
            Exam__r.Exam_Group__c,
            Site__c,
            Site__r.Name,
            Site__r.Is_OSTA_Information_Required__c,
            Site__r.Is_VAT__c,
            Site__r.Is_Gender_Required__c,
            Site__r.AM_Exam_Capacity_Available__c,
            Site__r.PM_Exam_Capacity_Available__c
            FROM Exam_Sites__c
            WHERE
            Exam_Part__c in :examSetupSelectionData.examParts AND
            (Site__r.Active__c = TRUE OR id in :currentSiteIds) AND
            Site__r.Non_Selectable__c = FALSE AND
            Site__r.Name != 'SCR' AND Site__r.Name != 'RAIJ' AND
            // Add exam admin open check
            Exam_Part__r.Exam_Administration__r.Exam_Scheduling_Start_Date__c <= TODAY AND Exam_Part__r.Exam_Administration__r.Exam_Scheduling_End_Date__c >= TODAY
            ORDER BY Site__r.Name ASC
        ];
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','examSites',examSetupSelectionData.examSites);

        examSetupSelectionData.mapExamSiteByID = new MAP<String, Exam_Sites__c>();
        for(Exam_Sites__c es :examSetupSelectionData.examSites) {
            examSetupSelectionData.mapExamSiteByID.put(es.id, es);
        }

        examSetupSelectionData.mapExamAdminByID = new MAP<String, Exam_Administration__c>();
        for(Exam_Administration__c ea :examSetupSelectionData.examAdmins) {
            examSetupSelectionData.mapExamAdminByID.put(ea.id, ea);
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','mapExamAdminByID',examSetupSelectionData.mapExamAdminByID);

        examSetupSelectionData.mapExamPart1ByExamAdmin = new MAP<String, Exam_Part__c>();
        examSetupSelectionData.mapExamPart2ByExamAdmin = new MAP<String, Exam_Part__c>();

        for(Exam_Part__c ep :examSetupSelectionData.examParts) {
            if(ep.Exam_Part_Number__c == 1) {
                examSetupSelectionData.mapExamPart1ByExamAdmin.put(ep.Exam_Administration__c, ep);
            } else {
                examSetupSelectionData.mapExamPart2ByExamAdmin.put(ep.Exam_Administration__c, ep);
            }
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','mapExamPart1ByExamAdmin',examSetupSelectionData.mapExamPart1ByExamAdmin);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','mapExamPart2ByExamAdmin',examSetupSelectionData.mapExamPart2ByExamAdmin);

        if(examSetupExamSelectionsInfo != NULL) {

            if(examSetupSelectionData.examRegPart1 != NULL) {

                // If Deferred Out Pending
                if(examAttempts.examAttemptPart1.Deferred_Exam_Administration__c != NULL) {
                    examSetupSelectionData.currentExamAdmin1 = examSetupSelectionData.mapExamAdminByID.get(examSetupSelectionData.examRegPart1.Deferred_Exam_Administration__c);
                } else {
                    examSetupSelectionData.currentExamAdmin1 = examSetupSelectionData.mapExamAdminByID.get(examSetupSelectionData.examRegPart1.Exam_Administration__c);
                }

                if(examSetupSelectionData.currentExamAdmin1 != NULL) {
                    examSetupSelectionData.currentExamPart1 = examSetupSelectionData.mapExamPart1ByExamAdmin.get(examSetupSelectionData.currentExamAdmin1.Id);
                    examSetupSelectionData.currentExamSiteId1 = NULL;

                    // If Deferred Out Pending
                    if(examAttempts.examAttemptPart1.Deferred_Exam_Administration__c != NULL) {
                        examSetupSelectionData.currentExamSite1 = NULL;
                    } else {
                        examSetupSelectionData.currentExamSite1 = examSetupSelectionData.mapExamSiteByID.get(examSetupSelectionData.examRegPart1.Exam_Site__c);
                        if(examSetupSelectionData.currentExamSite1 != NULL) {
                            examSetupSelectionData.currentExamSiteId1 = examSetupSelectionData.currentExamSite1.Id;
                        }
                    }

                    examSetupSelectionData.selectedExamSiteId1 = NULL;

                    examSetupSelectionData.selectedExamAdmin1 = examSetupSelectionData.mapExamAdminByID.get(examSetupExamSelectionsInfo.selectedAdminPart1);
                    examSetupSelectionData.selectedExamPart1 = examSetupSelectionData.mapExamPart1ByExamAdmin.get(examSetupExamSelectionsInfo.selectedAdminPart1);
                    examSetupSelectionData.selectedExamSite1 = examSetupSelectionData.mapExamSiteByID.get(examSetupExamSelectionsInfo.selectedSitePart1);
                    if(examSetupSelectionData.selectedExamSite1 != NULL) {
                        examSetupSelectionData.selectedExamSiteId1 = examSetupSelectionData.selectedExamSite1.Id;
                    }
                }
            }

            if(examSetupSelectionData.examRegPart2 != NULL) {

                // If Deferred Out Pending
                if(examAttempts.examAttemptPart2.Deferred_Exam_Administration__c != NULL) {
                    System.debug('***Deferred_Exam_Administration__c:' + examSetupSelectionData.examRegPart2.Deferred_Exam_Administration__c);
                    examSetupSelectionData.currentExamAdmin2 = examSetupSelectionData.mapExamAdminByID.get(examSetupSelectionData.examRegPart2.Deferred_Exam_Administration__c);
                } else {
                    System.debug('***Exam_Administration__c:' + examSetupSelectionData.examRegPart2.Exam_Administration__c);
                    examSetupSelectionData.currentExamAdmin2 = examSetupSelectionData.mapExamAdminByID.get(examSetupSelectionData.examRegPart2.Exam_Administration__c);
                }

                System.debug('***currentExamAdmin2:' + examSetupSelectionData.currentExamAdmin2);

                if(examSetupSelectionData.currentExamAdmin2 != NULL) {

                    examSetupSelectionData.currentExamPart2 = examSetupSelectionData.mapExamPart2ByExamAdmin.get(examSetupSelectionData.currentExamAdmin2.Id);

                    examSetupSelectionData.currentExamSiteId2 = NULL;

                    // If Deferred Out Pending
                    if(examAttempts.examAttemptPart2.Deferred_Exam_Administration__c != NULL) {
                        examSetupSelectionData.currentExamSite2 = NULL;
                    } else {
                        examSetupSelectionData.currentExamSite2 = examSetupSelectionData.mapExamSiteByID.get(examSetupSelectionData.examRegPart2.Exam_Site__c);
                        if(examSetupSelectionData.currentExamSite2 != NULL) {
                            examSetupSelectionData.currentExamSiteId2 = examSetupSelectionData.currentExamSite2.Id;
                        }
                    }

                    examSetupSelectionData.selectedExamSiteId2 = NULL;

                    examSetupSelectionData.selectedExamAdmin2 = examSetupSelectionData.mapExamAdminByID.get(examSetupExamSelectionsInfo.selectedAdminPart2);
                    examSetupSelectionData.selectedExamPart2 = examSetupSelectionData.mapExamPart2ByExamAdmin.get(examSetupExamSelectionsInfo.selectedAdminPart2);
                    examSetupSelectionData.selectedExamSite2 = examSetupSelectionData.mapExamSiteByID.get(examSetupExamSelectionsInfo.selectedSitePart2);
                    if(examSetupSelectionData.selectedExamSite2 != NULL) {
                        examSetupSelectionData.selectedExamSiteId2 = examSetupSelectionData.selectedExamSite2.Id;
                    }
                }
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','currentExamAdmin1',examSetupSelectionData.currentExamAdmin1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','currentExamSite1',examSetupSelectionData.currentExamSite1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','selectedExamAdmin1',examSetupSelectionData.selectedExamAdmin1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','selectedExamPart1',examSetupSelectionData.selectedExamPart1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','selectedExamSite1',examSetupSelectionData.selectedExamSite1);

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','currentExamAdmin2',examSetupSelectionData.currentExamAdmin2);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','currentExamSite2',examSetupSelectionData.currentExamSite2);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','selectedExamAdmin2',examSetupSelectionData.selectedExamAdmin2);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','selectedExamPart2',examSetupSelectionData.selectedExamPart2);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionData','selectedExamSite2',examSetupSelectionData.selectedExamSite2);
        }
        return examSetupSelectionData;
    }

    public static String makeFeeName(String examType, Exam_Administration__c currentAdminPart1, Exam_Administration__c selectedAdminPart1, Exam_Administration__c currentAdminPart2, Exam_Administration__c selectedAdminPart2) {
        // Make description
        String descrtipion;

        MAP<String,String> mapMonths = new MAP<String,String>();
        mapMonths.put('January','Jan');
        mapMonths.put('February','Feb');
        mapMonths.put('March','Mar');
        mapMonths.put('April','Apr');
        mapMonths.put('May','May');
        mapMonths.put('June','June');
        mapMonths.put('July','July');
        mapMonths.put('August','Aug');
        mapMonths.put('September','Sept');
        mapMonths.put('October','Oct');
        mapMonths.put('November','Nov');
        mapMonths.put('December','Dec');

        if(examType == 'frm' && currentAdminPart1 != NULL && currentAdminPart1.Id != selectedAdminPart1.Id) {
            descrtipion = 'FRM Part I from ' + mapMonths.get(currentAdminPart1.Month__c) + ' ' + currentAdminPart1.Year__c + ' to ' + mapMonths.get(selectedAdminPart1.Month__c) + ' ' + selectedAdminPart1.Year__c;
            if(currentAdminPart2 != NULL && currentAdminPart2.Id != selectedAdminPart2.Id) {
                descrtipion += ' and FRM Part II from ' + mapMonths.get(currentAdminPart2.Month__c) + ' ' + currentAdminPart2.Year__c + ' to ' + mapMonths.get(selectedAdminPart2.Month__c) + ' ' + selectedAdminPart2.Year__c;
            }
        } else if(examType == 'frm' && currentAdminPart2 != NULL && currentAdminPart2.Id != selectedAdminPart2.Id) {
            descrtipion = 'FRM Part II from ' + mapMonths.get(currentAdminPart2.Month__c) + ' ' + currentAdminPart2.Year__c + ' to ' + mapMonths.get(selectedAdminPart2.Month__c) + ' ' + selectedAdminPart2.Year__c;
        }

        if(examType == 'erp' && currentAdminPart1 != NULL && currentAdminPart1.Id != selectedAdminPart1.Id) {
            descrtipion = 'of ERP Part I from ' +mapMonths.get(currentAdminPart1.Month__c) + ' ' + currentAdminPart1.Year__c + ' to ' + mapMonths.get(selectedAdminPart1.Month__c) + ' ' + selectedAdminPart1.Year__c;

            if(currentAdminPart2 != NULL && currentAdminPart2.Id != selectedAdminPart2.Id) {
                descrtipion += ' and ERP Part II from ' + mapMonths.get(currentAdminPart2.Month__c) + ' ' + currentAdminPart2.Year__c + ' to ' + mapMonths.get(selectedAdminPart2.Month__c) + ' ' + selectedAdminPart2.Year__c;
            }
        } else if(examType == 'erp' && currentAdminPart2 != NULL && currentAdminPart2.Id != selectedAdminPart2.Id) {
            descrtipion = 'ERP Part II from ' + mapMonths.get(currentAdminPart2.Month__c) + ' ' + currentAdminPart2.Year__c + ' to ' + mapMonths.get(selectedAdminPart2.Month__c) + ' ' + selectedAdminPart2.Year__c;
        }

        if(examType == 'scr' && currentAdminPart1 != NULL && currentAdminPart1.Id != selectedAdminPart1.Id) {
            descrtipion = 'SCR from ' + mapMonths.get(currentAdminPart1.Month__c) + ' ' + currentAdminPart1.Year__c + ' to ' + mapMonths.get(selectedAdminPart1.Month__c) + ' ' + selectedAdminPart1.Year__c;
        }

        if(examType == 'raij' && currentAdminPart1 != NULL && currentAdminPart1.Id != selectedAdminPart1.Id) {
            descrtipion = 'RAIJ from ' + mapMonths.get(currentAdminPart1.Month__c) + ' ' + currentAdminPart1.Year__c + ' to ' + mapMonths.get(selectedAdminPart1.Month__c) + ' ' + selectedAdminPart1.Year__c;
        }

        if(examType == 'rai' && currentAdminPart1 != NULL && currentAdminPart1.Id != selectedAdminPart1.Id) {
            descrtipion = 'RAI from ' + mapMonths.get(currentAdminPart1.Month__c) + ' ' + currentAdminPart1.Year__c + ' to ' + mapMonths.get(selectedAdminPart1.Month__c) + ' ' + selectedAdminPart1.Year__c;
        }

        return descrtipion;
    }

    public class ostaMaps {
        public MAP<String,Exam_Part__c> mapCurrentPartOSTA { get; set; }
        public MAP<String,Exam_Part__c> mapSelectedPartOSTA  { get; set; }
    }

    static public ostaMaps computeOSTAProgramMoves(examSetupSelectionData examSetupSelectionData) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','computeOSTAProgramMoves','examSetupSelectionData',examSetupSelectionData);

        ostaMaps om = new ostaMaps();

        om.mapCurrentPartOSTA = new MAP<String,Exam_Part__c>();
        om.mapSelectedPartOSTA = new MAP<String,Exam_Part__c>();

        if(examSetupSelectionData.currentExamSite1 != NULL && examSetupSelectionData.currentExamSite1.Site__r.Is_OSTA_Information_Required__c) {
            om.mapCurrentPartOSTA.put(examSetupSelectionData.currentExamSite1.Exam_Part__c, examSetupSelectionData.currentExamSite1.Exam_Part__r);
        }
        if(examSetupSelectionData.currentExamSite2 != NULL && examSetupSelectionData.currentExamSite2.Site__r.Is_OSTA_Information_Required__c) {
            om.mapCurrentPartOSTA.put(examSetupSelectionData.currentExamSite2.Exam_Part__c, examSetupSelectionData.currentExamSite2.Exam_Part__r);
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','computeOSTAProgramMoves current','mapCurrentPartOSTA',om.mapCurrentPartOSTA);

        // If Part was deferred out and current site is OSTA, assume they are going to an OSTA site
        if(examSetupSelectionData.currentExamSite1 == NULL && examSetupSelectionData.selectedExamAdmin1 != NULL && examSetupSelectionData.examRegPart1 != NULL && examSetupSelectionData.examRegPart1.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c) {
            om.mapCurrentPartOSTA.put(examSetupSelectionData.examRegPart1.Exam_Site__r.Exam_Part__c, examSetupSelectionData.examRegPart1.Exam_Site__r.Exam_Part__r);
        }
        if(examSetupSelectionData.currentExamSite2 == NULL && examSetupSelectionData.selectedExamAdmin2 != NULL && examSetupSelectionData.examRegPart2 != NULL && examSetupSelectionData.examRegPart2.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c) {
            om.mapCurrentPartOSTA.put(examSetupSelectionData.examRegPart2.Exam_Site__r.Exam_Part__c, examSetupSelectionData.examRegPart2.Exam_Site__r.Exam_Part__r);
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','computeOSTAProgramMoves deferred','mapCurrentPartOSTA',om.mapCurrentPartOSTA);

        if(examSetupSelectionData.selectedExamSite1 != NULL && examSetupSelectionData.selectedExamSite1.Site__r.Is_OSTA_Information_Required__c) {
            om.mapSelectedPartOSTA.put(examSetupSelectionData.selectedExamSite1.Exam_Part__c, examSetupSelectionData.selectedExamSite1.Exam_Part__r);
        }
        if(examSetupSelectionData.selectedExamSite2 != NULL && examSetupSelectionData.selectedExamSite2.Site__r.Is_OSTA_Information_Required__c) {
            om.mapSelectedPartOSTA.put(examSetupSelectionData.selectedExamSite2.Exam_Part__c, examSetupSelectionData.selectedExamSite2.Exam_Part__r);
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','computeOSTAProgramMoves selected','mapCurrentPartOSTA',om.mapCurrentPartOSTA);

        // If Part was deferred out and current site is OSTA, assume they are going to an OSTA site
        if(examSetupSelectionData.selectedExamSite1 == NULL && examSetupSelectionData.selectedExamAdmin1 != NULL && examSetupSelectionData.examRegPart1 != NULL && examSetupSelectionData.examRegPart1.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c) {
            om.mapSelectedPartOSTA.put(examSetupSelectionData.examRegPart1.Exam_Site__r.Exam_Part__c, examSetupSelectionData.examRegPart1.Exam_Site__r.Exam_Part__r);
        }
        if(examSetupSelectionData.selectedExamSite2 == NULL && examSetupSelectionData.selectedExamAdmin2 != NULL && examSetupSelectionData.examRegPart2 != NULL && examSetupSelectionData.examRegPart2.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c) {
            om.mapSelectedPartOSTA.put(examSetupSelectionData.examRegPart2.Exam_Site__r.Exam_Part__c, examSetupSelectionData.examRegPart2.Exam_Site__r.Exam_Part__r);
        }

        System.debug('mapCurrentPartOSTA:' + om.mapCurrentPartOSTA);
        System.debug('mapSelectedPartOSTA:' + om.mapSelectedPartOSTA);

        return om;
    }

    public class examSetupSelectionFees {
        public List<feeInfo> fees;
    }

    public static examSetupSelectionFees getExamSetupSelectionFees(String examType, examSetupSelectionData examSetupSelectionData, examSetupExamSelectionsInfo examSetupExamSelectionsInfo, MAP<String,Contract> mapContracts) {

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','examType',examType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','examSetupSelectionData',examSetupSelectionData);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','mapContracts',mapContracts);

        examSetupSelectionFees examSetupSelectionFees = new examSetupSelectionFees();
        examSetupSelectionFees.fees = new List<feeInfo>();

        // No changes
        if((examSetupSelectionData.examRegPart1 == NULL || examSetupSelectionData.currentExamAdmin1 == NULL || (examSetupSelectionData.currentExamAdmin1.Id == examSetupExamSelectionsInfo.selectedAdminPart1 &&
           ((examSetupSelectionData.currentExamSite1 != NULL && examSetupSelectionData.currentExamSite1.Id == examSetupExamSelectionsInfo.selectedSitePart1) ||
            (examSetupSelectionData.currentExamSite1 == NULL && examSetupExamSelectionsInfo.selectedSitePart1 == NULL)))) &&

           (examSetupSelectionData.examRegPart2 == NULL || examSetupSelectionData.currentExamAdmin2 == NULL || (examSetupSelectionData.currentExamAdmin2.Id == examSetupExamSelectionsInfo.selectedAdminPart2 &&
           ((examSetupSelectionData.currentExamSite2 != NULL && examSetupSelectionData.currentExamSite2.Id == examSetupExamSelectionsInfo.selectedSitePart2) ||
            (examSetupSelectionData.currentExamSite2 == NULL && examSetupExamSelectionsInfo.selectedSitePart2 == NULL))))
          ) {
               GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','No changes','');
               return examSetupSelectionFees;
           }

        // Product Setup
        MAP<String,feeInfo> mapDeferProducts = new MAP<String,feeInfo>();
        feeInfo feeInfo = new feeInfo();
        feeInfo.type = 'fee';
        feeInfo.productCode = 'FRM1';
        feeInfo.amount = 250;
        mapDeferProducts.put('FRM1',feeInfo);
        feeInfo = new feeInfo();
        feeInfo.type = 'fee';
        feeInfo.productCode = 'SCR';
        feeInfo.amount = 150;
        mapDeferProducts.put('SCR1',feeInfo);
        feeInfo = new feeInfo();
        feeInfo.type = 'fee';
        feeInfo.productCode = 'RAIJ';
        feeInfo.amount = 150;
        mapDeferProducts.put('RAIJ1',feeInfo);
        feeInfo = new feeInfo();
        feeInfo.type = 'fee';
        feeInfo.productCode = 'RAI';
        feeInfo.amount = 150;
        mapDeferProducts.put('RAI1',feeInfo);

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','mapDeferProducts',mapDeferProducts);

        // Admin Switch Fee
        if((examSetupSelectionData.currentExamAdmin1 != NULL && examSetupSelectionData.currentExamAdmin1.Id != examSetupExamSelectionsInfo.selectedAdminPart1) ||
           (examSetupSelectionData.currentExamAdmin2 != NULL && examSetupSelectionData.currentExamAdmin2.Id != examSetupExamSelectionsInfo.selectedAdminPart2)) {
            if(examType == 'riskai') {
                feeInfo = mapDeferProducts.get('RAI1');
            } else if(examType == 'raij') {
                feeInfo = mapDeferProducts.get('RAIJ1');
            } else {
                feeInfo = mapDeferProducts.get(examType.ToUpperCase()+'1');
            }

            feeInfo.name = makeFeeName(examType, examSetupSelectionData.currentExamAdmin1, examSetupSelectionData.selectedExamAdmin1, examSetupSelectionData.currentExamAdmin2, examSetupSelectionData.selectedExamAdmin2);
            feeInfo.glCode = '4040';
            feeInfo.description = 'Standard exam administration change fee';
            feeInfo.examSiteId = examSetupSelectionData.selectedExamAdmin1 != NULL ? examSetupExamSelectionsInfo.selectedSitePart1 : examSetupExamSelectionsInfo.selectedSitePart1;
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','Admin Switch Fee',feeInfo);
            examSetupSelectionFees.fees.add(feeInfo);
        }

        // OSTA Fees
        Contract ostaContract = mapContracts.get('OSTA_Program');
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','ostaContract',ostaContract);

        // Product Setup
        MAP<String,feeInfo> mapOSTAProducts = new MAP<String,feeInfo>();
        feeInfo = new feeInfo();
        feeInfo.productCode = 'CHLF';
        feeInfo.type = 'fee';
        feeInfo.name = 'OSTA Location Fee';
        feeInfo.glCode = '2008';
        feeInfo.amount = 40;
        feeInfo.description = 'There is an additional fee for candidates who sit for the Exam in Mainland China. This additional fee is for administrative purposes.';
        Decimal ostaLocationFee = 40;
        mapOSTAProducts.put('CHLF',feeInfo);
        feeInfo = new feeInfo();
        feeInfo.productCode = 'CHNDF';
        feeInfo.type = 'fee';
        feeInfo.name = 'OSTA Data Fee';
        feeInfo.glCode = '2008';
        feeInfo.amount = 10;
        feeInfo.description = 'This is a one-time fee for GARP to manage candidate data allowing status to be verified in China.';
        Decimal ostaDataFee = 10;
        mapOSTAProducts.put('CHNDF',feeInfo);

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','mapOSTAProducts',mapOSTAProducts);

        ostaMaps om = computeOSTAProgramMoves(examSetupSelectionData);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','computeOSTAProgramMoves',om);

        Decimal totalFee = 0;
        Integer totalCurrentPartWithOSTA = om.mapCurrentPartOSTA.size();
        Integer totalSelectedPartWithOSTA = om.mapSelectedPartOSTA.size();

        // Net fee is diff between current distinct admins with OSTA v. selected distinct Admins with OSTA
        totalFee = totalFee + (ostaLocationFee * (totalSelectedPartWithOSTA - totalCurrentPartWithOSTA));

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','OSTA totalFee',totalFee);

        // Find Exam Reg to relate to Fee
        Set<Decimal> partsInvolved = new Set<Decimal>();
        Exam_Attempt__c eaFee;
        for(String selkey :om.mapSelectedPartOSTA.keySet()) {

            Exam_Part__c curVal = om.mapCurrentPartOSTA.get(selkey);
            Exam_Part__c selVal = om.mapSelectedPartOSTA.get(selkey);

            if(selVal != NULL && curVal == NULL) {
                partsInvolved.add(selVal.Exam_Part_Number__c);
            }
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','partsInvolved',partsInvolved);

        if(partsInvolved.contains(1)) {
            eaFee = examSetupSelectionData.examRegPart1;
        } else if(partsInvolved.contains(2)) {
            eaFee = examSetupSelectionData.examRegPart2;
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','eaFee',eaFee);

        // Find Opp Line Items Exam Part Accounting IDs
        String part1AccountingId;
        String part2AccountingId;

        // If any fees add them
        if(totalFee != 0) {

            Set<String> oppIds = new Set<String>();
            String oppPart1Id;
            String oppPart2Id;
            if(partsInvolved.contains(1)) {
                oppIds.add(examSetupSelectionData.examRegPart1.Opportunity__c);
                oppPart1Id = examSetupSelectionData.examRegPart1.Opportunity__c;
            }
            if(partsInvolved.contains(2)) {
                oppIds.add(examSetupSelectionData.examRegPart2.Opportunity__c);
                oppPart2Id = examSetupSelectionData.examRegPart2.Opportunity__c;
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','oppIds',oppIds);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','oppPart1Id',oppPart1Id);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','oppPart2Id',oppPart2Id);

            List<OpportunityLineItem> lstOppLineItems = [SELECT Id, OpportunityId, Product_ID__c, Product2.Product_ID__c, Product2.ProductCode FROM OpportunityLineItem where OpportunityId in :oppIds];
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','lstOppLineItems',lstOppLineItems);

            if(!lstOppLineItems.IsEmpty()) {
                for(OpportunityLineItem li :lstOppLineItems) {
                    //System.debug('Loop Opp Lines:' + li);

                    if((li.Product2.ProductCode == 'FRM1E' || li.Product2.ProductCode == 'FRM1S') && li.OpportunityId == oppPart1Id)  {
                        part1AccountingId = li.Product_ID__c;
                    }
                    if((li.Product2.ProductCode == 'FRM2E' || li.Product2.ProductCode == 'FRM2S') && li.OpportunityId == oppPart2Id)  {
                        part2AccountingId = li.Product_ID__c;
                    }
                }
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','part1AccountingId',part1AccountingId);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','part2AccountingId',part2AccountingId);

            if(partsInvolved.size() > 0) {
                feeInfo = mapOSTAProducts.get('CHLF');
                feeInfo.accountingCode = (part1AccountingId != NULL) ? part1AccountingId : part2AccountingId;
                examSetupSelectionFees.fees.add(feeInfo);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','Add Location Fee',feeInfo);
            }
            if(partsInvolved.size() > 1) {
                feeInfo = mapOSTAProducts.get('CHLF');
                feeInfo.accountingCode = part2AccountingId;
                examSetupSelectionFees.fees.add(feeInfo);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','Add Location Fee',feeInfo);
            }

            // If have any OSTA Admins
            if(totalSelectedPartWithOSTA > 0) {

                // If no OSTA program exists charge to put them into it
                if(ostaContract == NULL) {
                    feeInfo = mapOSTAProducts.get('CHNDF');
                    feeInfo.accountingCode = (part1AccountingId != NULL) ? part1AccountingId : part2AccountingId;
                    examSetupSelectionFees.fees.add(feeInfo);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','Add Data Fee',feeInfo);
                }
            }

            // If any Refunds add them
            // Find Exam Reg to relate to Fee
            partsInvolved = new Set<Decimal>();
            eaFee=NULL;
            for(String curkey :om.mapCurrentPartOSTA.keySet()) {

                Exam_Part__c curVal = om.mapCurrentPartOSTA.get(curkey);
                Exam_Part__c selVal = om.mapSelectedPartOSTA.get(curkey);

                //System.debug('curVal:' + curVal);
                //System.debug('selVal:' + selVal);

                if(selVal == NULL && curVal != NULL) {
                    if(curVal.Exam_Part_Number__c != NULL) {
                        partsInvolved.add(curVal.Exam_Part_Number__c);
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','Refund partsInvolved',partsInvolved);

            if(partsInvolved.contains(1)) {
                eaFee = examSetupSelectionData.examRegPart1;
            } else if(partsInvolved.contains(2)) {
                eaFee = examSetupSelectionData.examRegPart2;
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','Refund eaFee',eaFee);

            if(totalFee < 0) {
                if(partsInvolved.size() > 0) {
                    feeInfo = mapOSTAProducts.get('CHLF');
                    feeInfo.type = 'refund';
                    feeInfo.name = 'OSTA Location fee Refund';
                    feeInfo.description = 'Due to your new Exam location, you will be refunded this fee.';
                    feeInfo.amount = ostaLocationFee * -1;
                    feeInfo.examRegId = eaFee.Id;
                    examSetupSelectionFees.fees.add(feeInfo);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','Add Location Refund',feeInfo);
                }
                if(partsInvolved.size() > 1) {
                    feeInfo = mapOSTAProducts.get('CHLF');
                    feeInfo.type = 'refund';
                    feeInfo.name = 'OSTA Location fee Refund';
                    feeInfo.description = 'Due to your new Exam location, you will be refunded this fee.';
                    feeInfo.amount = ostaLocationFee * -1;
                    feeInfo.examRegId = eaFee.Id;
                    examSetupSelectionFees.fees.add(feeInfo);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','Add Location Refund',feeInfo);
                }
            }

            // If no Part with OSTA left
            if(totalSelectedPartWithOSTA == 0) {

                // If have OSTA Program but never uploaded data then refund
                if(ostaContract != NULL && ostaContract.OSTA_Last_Upload_Date__c == NULL) {
                    feeInfo = mapOSTAProducts.get('CHNDF');
                    feeInfo.type = 'refund';
                    feeInfo.description = 'OSTA Data fee Refund';
                    feeInfo.amount = ostaDataFee * -1;
                    feeInfo.examRegId = eaFee.Id;
                    examSetupSelectionFees.fees.add(feeInfo);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','Add Data Refund',feeInfo);
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupSelectionFees','Final examSetupSelectionFees',examSetupSelectionFees);
        return examSetupSelectionFees;
    }

    public static String getProviderURL(String providerType, String examRegID) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getProviderURL','providerType',providerType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getProviderURL','examRegID',examRegID);

        if(providerType == 'ATA') {
            return System.Label.GARP_ATA_SSO_URL + examRegID;
        } else if(providerType == 'PSI') {
            return System.Label.GARP_PSI_SSO_URL;
        } else if(providerType == 'Pearson') {
            return System.Label.GARP_PEARSON_SSO_URL + examRegID;
        }
        return NULL;
    }

    // Main Methods

    public class returnGetExamSetupFormInfo {
        public String statusMessage;
        public Integer statusCode;

        public Boolean allowAdminModPart1;
        public Boolean allowAdminModPart2;
        public List<examAdmin> examPart1SelectionInfo;
        public List<examAdmin> examPart2SelectionInfo;
    }

    public class examAdmin {
        public String id;
        public String name;
        public Boolean isSelected;
        public List<examSite> examSites;
    }

    public class examSite {
        public String id;
        public String name;
        public Boolean isSelected;
    }

    public static returnGetExamSetupFormInfo getExamSetupFormInfo(String userId, Contact contact, String examType) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','examType',examType);

        returnGetExamSetupFormInfo returnGetExamSetupFormInfo = new returnGetExamSetupFormInfo();

        returnGetExamSetupFormInfo.examPart1SelectionInfo = new List<examAdmin>();
        returnGetExamSetupFormInfo.examPart2SelectionInfo = new List<examAdmin>();

        returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contact.Id);
        MAP<String,Exam_Attempt__c> mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;

        returnGetLatestExamAttemptsByType retExamRegs = getLatestExamAttemptsByType(examType, mapLatestExamAttempts);
        examSetupExamSelectionsInfo examSetupExamSelectionsInfo = new examSetupExamSelectionsInfo();

        examSetupSelectionData examSetupSelectionData = getExamSetupSelectionData(examType, retExamRegs, examSetupExamSelectionsInfo);
        if(examSetupSelectionData != NULL) {

            // Find open order for Exams
            Set<String> productCodes = new Set<String>{'FRM1:4020','FRM2:4020','SCR:4020','RAIJ:4020','RISKAI:4020'};
            Opportunity latestOpenOpp = GARP_BC_Orders.getLatestOppWithGivenProductAndGLCodes(contact.accountID, productCodes, 'New Lead', NULL);
            if(latestOpenOpp != NULL) {
                returnGetExamSetupFormInfo.statusMessage = 'Pending Exam Reschedule already exists';
                returnGetExamSetupFormInfo.statusCode = 502;
                return returnGetExamSetupFormInfo;
            }

            Exam_Attempt__c examAttemptPart1 = examSetupSelectionData.examRegPart1;
            Exam_Attempt__c examAttemptPart2 = examSetupSelectionData.examRegPart2;

            returnGetExamSetupFormInfo.allowAdminModPart1 = examSetupSelectionData.allowAdminModPart1;
            returnGetExamSetupFormInfo.allowAdminModPart2 = examSetupSelectionData.allowAdminModPart2;

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','allowAdminModPart1',returnGetExamSetupFormInfo.allowAdminModPart1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','allowAdminModPart2',returnGetExamSetupFormInfo.allowAdminModPart2);

            MAP<Integer,String> mapMonthsByNumber = GARP_Common.getMonthMapByNumber();

            // Setup Exam Admins
            for(Exam_Administration__c ea :examSetupSelectionData.examAdmins) {

                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','Loop ea',ea);

                Exam_Part__c examPart1 = examSetupSelectionData.mapExamPart1ByExamAdmin.get(ea.Id);
                Exam_Part__c examPart2 = examSetupSelectionData.mapExamPart2ByExamAdmin.get(ea.Id);

                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','examPart1',examPart1);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','examPart2',examPart2);

                if(examPart1 != NULL && examSetupSelectionData.currentExamAdmin1 != NULL) {
                    examAdmin examAdmin = new examAdmin();
                    examAdmin.id = ea.Id;
                    examAdmin.isSelected = False;
                    if(examPart1.Exam_Date__c != NULL) {
                        String monthName = mapMonthsByNumber.get(examPart1.Exam_Date__c.Month());
                        examAdmin.name = monthName + ' ' + examPart1.Exam_Date__c.Day() + ', ' + examPart1.Exam_Date__c.Year();
                    } else {
                        String monthName = mapMonthsByNumber.get(examPart1.Exam_Start_Date__c.Month());
                        examAdmin.name = monthName + ' ' + examPart1.Exam_Start_Date__c.Day() + '-' + examPart1.Exam_End_Date__c.Day() + ', ' + examPart1.Exam_Start_Date__c.Year();
                    }

                    if(examAttemptPart1 != NULL) {
                        if(examAttemptPart1.Deferred_Exam_Administration__c != NULL && examAttemptPart1.Deferred_Exam_Administration__c == ea.Id) {
                            examAdmin.isSelected = True;
                        } else if(examAttemptPart1.Deferred_Exam_Administration__c == NULL && examAttemptPart1.Exam_Administration__c == ea.Id) {
                            examAdmin.isSelected = True;
                        }
                    }
                    returnGetExamSetupFormInfo.examPart1SelectionInfo.add(examAdmin);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','add examPart1SelectionInfo',examAdmin);
                }

                if(examPart2 != NULL && examSetupSelectionData.currentExamAdmin2 != NULL) {
                    examAdmin examAdmin = new examAdmin();
                    examAdmin.id = ea.Id;
                    examAdmin.isSelected = False;
                    if(examPart2.Exam_Date__c != NULL) {
                        String monthName = mapMonthsByNumber.get(examPart2.Exam_Date__c.Month());
                        examAdmin.name = monthName + ' ' + examPart2.Exam_Date__c.Day() + ', ' + examPart2.Exam_Date__c.Year();
                    } else {
                        String monthName = mapMonthsByNumber.get(examPart2.Exam_Start_Date__c.Month());
                        examAdmin.name = monthName + ' ' + examPart2.Exam_Start_Date__c.Day() + '-' + examPart2.Exam_End_Date__c.Day() + ', ' + examPart2.Exam_Start_Date__c.Year();
                    }

                    if(examAttemptPart2 != NULL) {
                        if(examAttemptPart2.Deferred_Exam_Administration__c != NULL && examAttemptPart2.Deferred_Exam_Administration__c == ea.Id) {
                            examAdmin.isSelected = True;
                        } else if(examAttemptPart2.Deferred_Exam_Administration__c == NULL && examAttemptPart2.Exam_Administration__c == ea.Id) {
                            examAdmin.isSelected = True;
                        }
                    }
                    returnGetExamSetupFormInfo.examPart2SelectionInfo.add(examAdmin);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','add examPart2SelectionInfo',examAdmin);
                }

            }

            // ExamAdminId -> List of examsites
            MAP<String, List<examSite>> mapExamAdminSitesPart1 = new MAP<String, List<examSite>>();
            MAP<String, List<examSite>> mapExamAdminSitesPart2 = new MAP<String, List<examSite>>();
            for(Exam_Sites__c es :examSetupSelectionData.examSites) {
                String examAdminId = es.Exam_Part__r.Exam_Administration__c;

                List<examSite> fndExamSiteList;

                examSite examSite = new examSite();
                examSite.id = es.Id;
                examSite.name = es.Country__c;
                examSite.isSelected = False;
                if(es.Exam_Part__r.Exam_Part_Number__c == 1) {
                    fndExamSiteList = mapExamAdminSitesPart1.get(examAdminId);
                    if(examAttemptPart1 != NULL && examAttemptPart1.Exam_Site__c == es.Id) {
                        examSite.isSelected = True;
                    }
                } else {
                    fndExamSiteList = mapExamAdminSitesPart2.get(examAdminId);
                    if(examAttemptPart2 != NULL && examAttemptPart2.Exam_Site__c == es.Id) {
                        examSite.isSelected = True;
                    }
                }

                if(fndExamSiteList == NULL) {
                    fndExamSiteList = new List<examSite>();
                }
                fndExamSiteList.add(examSite);

                if(es.Exam_Part__r.Exam_Part_Number__c == 1) {
                    fndExamSiteList = mapExamAdminSitesPart1.put(examAdminId, fndExamSiteList);
                } else {
                    fndExamSiteList = mapExamAdminSitesPart2.put(examAdminId, fndExamSiteList);
                }
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','mapExamAdminSitesPart1',mapExamAdminSitesPart1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','mapExamAdminSitesPart2',mapExamAdminSitesPart2);

            for(examAdmin ea :returnGetExamSetupFormInfo.examPart1SelectionInfo) {
                ea.examSites = mapExamAdminSitesPart1.get(ea.Id);
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','examPart1SelectionInfo final',returnGetExamSetupFormInfo.examPart1SelectionInfo);

            for(examAdmin ea :returnGetExamSetupFormInfo.examPart2SelectionInfo) {
                ea.examSites = mapExamAdminSitesPart2.get(ea.Id);
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFormInfo','examPart1SelectionInfo final',returnGetExamSetupFormInfo.examPart2SelectionInfo);

            if(retExamRegs.examAttemptPart1 == NULL) {
                returnGetExamSetupFormInfo.examPart1SelectionInfo = NULL;
            }
            if(retExamRegs.examAttemptPart2 == NULL) {
                returnGetExamSetupFormInfo.examPart2SelectionInfo = NULL;
            }

            if(returnGetExamSetupFormInfo.examPart1SelectionInfo != NULL && returnGetExamSetupFormInfo.examPart1SelectionInfo.IsEmpty()) {
                returnGetExamSetupFormInfo.examPart1SelectionInfo = NULL;
            }

            if(returnGetExamSetupFormInfo.examPart2SelectionInfo != NULL && returnGetExamSetupFormInfo.examPart2SelectionInfo.IsEmpty()) {
                returnGetExamSetupFormInfo.examPart2SelectionInfo = NULL;
            }

        } else {
            returnGetExamSetupFormInfo.statusMessage = 'Scheduling data not returned';
            returnGetExamSetupFormInfo.statusCode = 501;
            return returnGetExamSetupFormInfo;
        }

        returnGetExamSetupFormInfo.statusMessage = 'Scheduling information returned';
        returnGetExamSetupFormInfo.statusCode = 200;

        return returnGetExamSetupFormInfo;
    }

    // Get Fess and Change Info

    public class examSetupExamSelectionsInfo {
        public String selectedAdminPart1;
        public String selectedSitePart1;
        public String selectedAdminPart2;
        public String selectedSitePart2;
    }

    public class returnGetExamSetupExamSelectionInfo {
        public String statusMessage;
        public Integer statusCode;

        public List<feeInfo> fees;
        public Decimal totalFees;
        public Boolean hasError;
        public Boolean hasChanges;
        public Boolean hasFees;
        public Boolean schedulingRequired;
    }

    public class feeInfo {
        public String name;
        public String type; // fee | refund
        public Decimal amount;
        public String description;
        public String productCode;
        public String glCode;
        public String accountingCode;
        public String examRegId;
        public String examSiteId;
    }

    public static returnGetExamSetupExamSelectionInfo getExamSetupExamSelectionInfo(Contact contact, String examType, MAP<String,Contract> mapContracts, examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','examType',examType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);

        returnGetExamSetupExamSelectionInfo returnGetExamSetupExamSelectionInfo = new returnGetExamSetupExamSelectionInfo();

        Contract examProgram;
        if(examType.ToUpperCase() == 'FRM') {
            examProgram = mapContracts.get('FRM_Program');
        } else if(examType.ToUpperCase() == 'SCR') {
            examProgram = mapContracts.get('SCR_Program');
        } else if(examType.ToUpperCase() == 'RAIJ') {
            examProgram = mapContracts.get('RAIJ_Program');
        } else if(examType.ToUpperCase() == 'RAI') {
            examProgram = mapContracts.get('Risk_AI_Program');
        }

        returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contact.Id);
        MAP<String,Exam_Attempt__c> mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;

        returnGetLatestExamAttemptsByType retExamRegs = getLatestExamAttemptsByType(examType, mapLatestExamAttempts);

        examSetupSelectionData examSetupSelectionData = getExamSetupSelectionData(examType, retExamRegs, examSetupExamSelectionsInfo);
        if(examSetupSelectionData != NULL) {

            Date selectedExamDatePart1;
            Date selectedExamDatePart2;
            if(examSetupSelectionData.examRegPart1 != NULL) {
                selectedExamDatePart1 = examSetupSelectionData.selectedExamPart1.Exam_Date__c != NULL ? examSetupSelectionData.selectedExamPart1.Exam_Date__c : examSetupSelectionData.selectedExamPart1.Exam_Start_Date__c;
            }
            if(examSetupSelectionData.examRegPart2 != NULL) {
                selectedExamDatePart2 = examSetupSelectionData.selectedExamPart2.Exam_Date__c != NULL ? examSetupSelectionData.selectedExamPart2.Exam_Date__c : examSetupSelectionData.selectedExamPart2.Exam_Start_Date__c;
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','selectedExamDatePart1',selectedExamDatePart1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','selectedExamDatePart2',selectedExamDatePart2);

            // Validations
            if((examSetupExamSelectionsInfo.selectedAdminPart1 != NULL && !String.IsEmpty(examSetupExamSelectionsInfo.selectedAdminPart1) && examSetupSelectionData.examRegPart1 == NULL) ||
               (examSetupExamSelectionsInfo.selectedAdminPart2 != NULL && !String.IsEmpty(examSetupExamSelectionsInfo.selectedAdminPart2) && examSetupSelectionData.examRegPart2 == NULL)) {
                   returnGetExamSetupExamSelectionInfo.statusMessage = 'Exam Selection data given is missing';
                   returnGetExamSetupExamSelectionInfo.statusCode = 501;
                   return returnGetExamSetupExamSelectionInfo;
            }

            // Part Admin Moved but Not Allowed
            if((examSetupSelectionData.examRegPart1 != NULL && examSetupSelectionData.currentExamAdmin1 != NULL && examSetupSelectionData.currentExamAdmin1.Id != examSetupExamSelectionsInfo.selectedAdminPart1 && examSetupSelectionData.allowAdminModPart1 == FALSE) ||
               (examSetupSelectionData.examRegPart2 != NULL && examSetupSelectionData.currentExamAdmin2 != NULL && examSetupSelectionData.currentExamAdmin2.Id != examSetupExamSelectionsInfo.selectedAdminPart2 && examSetupSelectionData.allowAdminModPart2 == FALSE)) {
                   returnGetExamSetupExamSelectionInfo.statusMessage = 'Exam changes are currently not allowed';
                   returnGetExamSetupExamSelectionInfo.statusCode = 501;
                   return returnGetExamSetupExamSelectionInfo;
            }

            // Cannot defer twice
            if(examSetupSelectionData.examRegPart1 != NULL && examSetupSelectionData.currentExamAdmin1 != NULL && examSetupSelectionData.currentExamAdmin1.Id != examSetupExamSelectionsInfo.selectedAdminPart1 &&
               examSetupSelectionData.examRegPart1.Defered__c == 'Approved' && examSetupSelectionData.examRegPart1.Allow_Future_Deferral__c == False &&
                (examSetupSelectionData.examRegPart1.Deferred_From_Exam_Registration__c == NULL || examSetupSelectionData.examRegPart1.Deferred_From_Exam_Registration__r.Exam_Administration__r.Is_Modification_Open__c == False)) {
                   returnGetExamSetupExamSelectionInfo.statusMessage = 'You cannot defer Part I because it was deferred in from a previous exam administration. You can only defer your exam registration once.';
                   returnGetExamSetupExamSelectionInfo.statusCode = 501;
                   return returnGetExamSetupExamSelectionInfo;
                }

            if(examSetupSelectionData.examRegPart2 != NULL && examSetupSelectionData.currentExamAdmin2 != NULL && examSetupSelectionData.currentExamAdmin2.Id != examSetupExamSelectionsInfo.selectedAdminPart2 &&
               examSetupSelectionData.examRegPart2.Defered__c == 'Approved' && examSetupSelectionData.examRegPart2.Allow_Future_Deferral__c == False &&
                (examSetupSelectionData.examRegPart2.Deferred_From_Exam_Registration__c == NULL || examSetupSelectionData.examRegPart2.Deferred_From_Exam_Registration__r.Exam_Administration__r.Is_Modification_Open__c == False)) {
                   returnGetExamSetupExamSelectionInfo.statusMessage = 'You cannot defer Part II because it was deferred in from a previous exam administration. You can only defer your exam registration once.';
                   returnGetExamSetupExamSelectionInfo.statusCode = 501;
                   return returnGetExamSetupExamSelectionInfo;
                }

            // You must Cancel Pearson before deferring
            if(examSetupSelectionData.currentExamAdmin1 != NULL && examSetupSelectionData.currentExamAdmin1.Id != examSetupExamSelectionsInfo.selectedAdminPart1 &&
               (examType.ToUpperCase() == 'SCR' || examType.ToUpperCase() == 'RAIJ' || examType.ToUpperCase() == 'RISKAI') &&
               (examSetupSelectionData.examRegPart1.Integration_Data_Exam_Scheduled_Date__c != NULL ||
                examSetupSelectionData.examRegPart1.Integration_Data_Exam_Scheduled_Date__c != NULL)) {

                    returnGetExamSetupExamSelectionInfo.statusMessage = 'To complete your Exam deferral, please go to Pearson and cancel your existing exam appointment. Then, return here to select to your new date.';
                    returnGetExamSetupExamSelectionInfo.statusCode = 501;
                    return returnGetExamSetupExamSelectionInfo;

            }

            // You cant defer beyond the end of your contract
            if(examType.ToUpperCase() == 'FRM') {
                if(examSetupSelectionData.selectedExamPart1 != NULL) {
                    if(selectedExamDatePart1 > examProgram.Last_Exam_Deferral_Date__c) {
                        returnGetExamSetupExamSelectionInfo.statusMessage = 'Cannot defer Part I beyond the end of your Program';
                        returnGetExamSetupExamSelectionInfo.statusCode = 505;
                        return returnGetExamSetupExamSelectionInfo;
                    }
                }
                if(examSetupSelectionData.selectedExamPart2 != NULL) {
                    if(selectedExamDatePart2 > examProgram.Last_Exam_Deferral_Date__c) {
                        returnGetExamSetupExamSelectionInfo.statusMessage = 'Cannot defer Part II beyond the end of your Program';
                        returnGetExamSetupExamSelectionInfo.statusCode = 505;
                        return returnGetExamSetupExamSelectionInfo;
                    }
                }
            }

            // Cannot move Part II before Part I
            if(selectedExamDatePart1 != NULL && selectedExamDatePart2 != NULL && selectedExamDatePart2 < selectedExamDatePart1) {
                returnGetExamSetupExamSelectionInfo.statusMessage = 'Part II cannot be taken before Part I';
                returnGetExamSetupExamSelectionInfo.statusCode = 505;
                return returnGetExamSetupExamSelectionInfo;
            }

            returnGetExamSetupExamSelectionInfo.hasFees = False;
            returnGetExamSetupExamSelectionInfo.hasChanges = False;
            returnGetExamSetupExamSelectionInfo.schedulingRequired = False;

            // Current State schedulingRequired
            if((examSetupSelectionData.examRegPart1 != NULL && !examSetupSelectionData.isAdminScheduledPart1 && !examSetupSelectionData.isAdminDeferredPart1) ||
               (examSetupSelectionData.examRegPart2 != NULL && !examSetupSelectionData.isAdminScheduledPart2 && !examSetupSelectionData.isAdminDeferredPart2)) {
                returnGetExamSetupExamSelectionInfo.schedulingRequired = True;
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','schedulingRequired1',returnGetExamSetupExamSelectionInfo.schedulingRequired);

            Date tdy = Date.Today();
            //if((examSetupSelectionData.selectedExamAdmin1 != NULL && tdy >= examSetupSelectionData.selectedExamAdmin1.Exam_Scheduling_Start_Date__c && tdy <= examSetupSelectionData.selectedExamAdmin1.Exam_Scheduling_End_Date__c) ||
            //   (examSetupSelectionData.selectedExamAdmin2 != NULL && tdy >= examSetupSelectionData.selectedExamAdmin2.Exam_Scheduling_Start_Date__c && tdy <= examSetupSelectionData.selectedExamAdmin2.Exam_Scheduling_End_Date__c)) {
            //    returnGetExamSetupExamSelectionInfo.schedulingRequired = True;
            //}

            // Admin Moved and Scheduling is open
            // If moved must be allowed, see Validations above
            if((examSetupSelectionData.examRegPart1 != NULL && examSetupSelectionData.currentExamAdmin1 != NULL && examSetupSelectionData.currentExamAdmin1.Id != examSetupExamSelectionsInfo.selectedAdminPart1 && tdy >= examSetupSelectionData.selectedExamAdmin1.Exam_Scheduling_Start_Date__c && tdy <= examSetupSelectionData.selectedExamAdmin1.Exam_Scheduling_End_Date__c) ||
               (examSetupSelectionData.examRegPart2 != NULL && examSetupSelectionData.currentExamAdmin2 != NULL && examSetupSelectionData.currentExamAdmin2.Id != examSetupExamSelectionsInfo.selectedAdminPart2 && tdy >= examSetupSelectionData.selectedExamAdmin2.Exam_Scheduling_Start_Date__c && tdy <= examSetupSelectionData.selectedExamAdmin2.Exam_Scheduling_End_Date__c)) {

               returnGetExamSetupExamSelectionInfo.schedulingRequired = True;
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','schedulingRequired2',returnGetExamSetupExamSelectionInfo.schedulingRequired);

            // Site moved, not deferred, and Scheduling is open, AND changed providers!!!

            String currentExamProvider1='xxx';
            if(examSetupSelectionData.currentExamSiteId1 != NULL) {
               currentExamProvider1 = examSetupSelectionData.currentExamSite1.Exam_Provider__r.Name;
            }
            String currentExamProvider2='xxx';
            if(examSetupSelectionData.currentExamSiteId2 != NULL) {
               currentExamProvider2 = examSetupSelectionData.currentExamSite1.Exam_Provider__r.Name;
            }
            String selectedExamProvider1='xxx';
            if(examSetupSelectionData.currentExamSiteId1 != NULL) {
               selectedExamProvider1 = examSetupSelectionData.selectedExamSite1.Exam_Provider__r.Name;
            }
            String selectedExamProvider2='xxx';
            if(examSetupSelectionData.currentExamSiteId2 != NULL) {
               selectedExamProvider2 = examSetupSelectionData.selectedExamSite2.Exam_Provider__r.Name;
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','currentExamProvider1',currentExamProvider1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','currentExamProvider2',currentExamProvider1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','selectedExamProvider1',selectedExamProvider1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','selectedExamProvider2',selectedExamProvider2);


            if((examSetupSelectionData.examRegPart1 != NULL && examSetupSelectionData.currentExamSiteId1 != examSetupExamSelectionsInfo.selectedSitePart1 && examSetupSelectionData.selectedExamSite1 != NULL && currentExamProvider1 != selectedExamProvider1 && tdy >= examSetupSelectionData.selectedExamAdmin1.Exam_Scheduling_Start_Date__c && tdy <= examSetupSelectionData.selectedExamAdmin1.Exam_Scheduling_End_Date__c) ||
               (examSetupSelectionData.examRegPart2 != NULL && examSetupSelectionData.currentExamSiteId2 != examSetupExamSelectionsInfo.selectedSitePart2 && examSetupSelectionData.selectedExamSite2 != NULL && currentExamProvider1 != selectedExamProvider1 && tdy >= examSetupSelectionData.selectedExamAdmin2.Exam_Scheduling_Start_Date__c && tdy <= examSetupSelectionData.selectedExamAdmin2.Exam_Scheduling_End_Date__c)) {

               returnGetExamSetupExamSelectionInfo.schedulingRequired = True;
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','schedulingRequired3',returnGetExamSetupExamSelectionInfo.schedulingRequired);


            Exam_Attempt__c examAttemptPart1 = examSetupSelectionData.examRegPart1;
            Exam_Attempt__c examAttemptPart2 = examSetupSelectionData.examRegPart2;

            if((examAttemptPart1 != NULL && examSetupSelectionData.currentExamAdmin1 != NULL && (examSetupExamSelectionsInfo.selectedAdminPart1 != examSetupSelectionData.currentExamAdmin1.Id || examSetupExamSelectionsInfo.selectedSitePart1 != examSetupSelectionData.currentExamSiteId1)) ||
               (examAttemptPart2 != NULL && examSetupSelectionData.currentExamAdmin2 != NULL && (examSetupExamSelectionsInfo.selectedAdminPart2 != examSetupSelectionData.currentExamAdmin2.Id || examSetupExamSelectionsInfo.selectedSitePart2 != examSetupSelectionData.currentExamSiteId2))) {
                   returnGetExamSetupExamSelectionInfo.hasChanges = True;
               }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','hasChanges',returnGetExamSetupExamSelectionInfo.hasChanges);

            returnGetExamSetupExamSelectionInfo.fees = new List<feeInfo>();
            returnGetExamSetupExamSelectionInfo.hasFees = False;
            returnGetExamSetupExamSelectionInfo.totalFees = 0;

            if(returnGetExamSetupExamSelectionInfo.hasChanges) {
                // Compute Fees
                examSetupSelectionFees examSetupSelectionFees = getExamSetupSelectionFees(examType, examSetupSelectionData, examSetupExamSelectionsInfo, mapContracts);
                returnGetExamSetupExamSelectionInfo.fees = new List<feeInfo>();
                if(!examSetupSelectionFees.fees.IsEmpty()) {
                    returnGetExamSetupExamSelectionInfo.fees = examSetupSelectionFees.fees;
                    returnGetExamSetupExamSelectionInfo.hasFees = True;
                    returnGetExamSetupExamSelectionInfo.totalFees = 0;
                    for(feeInfo fee :examSetupSelectionFees.fees) {
                        returnGetExamSetupExamSelectionInfo.totalFees += fee.amount;
                    }
                }
            }

        } else {
            returnGetExamSetupExamSelectionInfo.statusMessage = 'Exam selection data not returned';
            returnGetExamSetupExamSelectionInfo.statusCode = 501;
            return returnGetExamSetupExamSelectionInfo;
        }

        returnGetExamSetupExamSelectionInfo.statusMessage = 'Exam Changes information returned';
        returnGetExamSetupExamSelectionInfo.statusCode = 200;

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupExamSelectionInfo','final returnGetExamSetupExamSelectionInfo',returnGetExamSetupExamSelectionInfo);

        return returnGetExamSetupExamSelectionInfo;
    }

    public class returnSetExamSetupExamSelectionsChanges {
        public String statusMessage;
        public Integer statusCode;
        public String examModificationId;
        public Boolean paymentNeeded;
    }

    public static returnSetExamSetupExamSelectionsChanges setExamSetupExamSelectionsChanges(Contact contact, String examType, MAP<String,Contract> mapContracts, examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupExamSelectionsChanges','contact',contact);
        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupExamSelectionsChanges','examType',examType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupExamSelectionsChanges','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);

        returnSetExamSetupExamSelectionsChanges returnSetExamSetupExamSelectionsChanges = new returnSetExamSetupExamSelectionsChanges();

        returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contact.Id);
        MAP<String,Exam_Attempt__c> mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;

        returnGetLatestExamAttemptsByType retExamRegs = getLatestExamAttemptsByType(examType, mapLatestExamAttempts);

        examSetupSelectionData examSetupSelectionData = getExamSetupSelectionData(examType, retExamRegs, examSetupExamSelectionsInfo);
        if(examSetupSelectionData != NULL) {

            Boolean hasFees = False;
            Boolean hasChanges = False;

            Exam_Attempt__c examAttemptPart1 = examSetupSelectionData.examRegPart1;
            Exam_Attempt__c examAttemptPart2 = examSetupSelectionData.examRegPart2;

            GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupExamSelectionsChanges','examAttemptPart1',examAttemptPart1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupExamSelectionsChanges','examAttemptPart2',examAttemptPart2);

            Exam_Registration_Modification__c examRegMod = new Exam_Registration_Modification__c();

            examSetupSelectionFees examSetupSelectionFees;

            if((examAttemptPart1 != NULL && examSetupSelectionData.currentExamAdmin1 != NULL && (examSetupExamSelectionsInfo.selectedAdminPart1 != examSetupSelectionData.currentExamAdmin1.Id || examSetupExamSelectionsInfo.selectedSitePart1 != examSetupSelectionData.currentExamSiteId1)) ||
               (examAttemptPart2 != NULL && examSetupSelectionData.currentExamAdmin2 != NULL && (examSetupExamSelectionsInfo.selectedAdminPart2 != examSetupSelectionData.currentExamAdmin2.Id || examSetupExamSelectionsInfo.selectedSitePart2 != examSetupSelectionData.currentExamSiteId2))) {
                   hasChanges = True;

                   // Set examMod Record
                   String userId = UserInfo.getUserId();
                   examRegMod.User__c = userId;
                   examRegMod.Status__c = 'Pending';
                   examRegMod.Created_from_MS_Tool__c = false;
                   examRegMod.Deferral_Subtype__c = 'Deferral Standard';
                   examRegMod.Free_Deferral__c = False;
                   examRegMod.Not_Applicable_to_One_Time_Def__c = False;

                   if(examAttemptPart1 != NULL && examSetupSelectionData.currentExamAdmin1 != NULL) {
                       examRegMod.Part_I_Exam_Registration__c = examAttemptPart1.Id;
                       examRegMod.Part_I_Exam_Admin_From__c = examSetupSelectionData.currentExamAdmin1.Id;
                       examRegMod.Part_I_Exam_Group_From__c = examSetupSelectionData.currentExamAdmin1.Exam_Group__c;
                       examRegMod.Part_I_Exam_Part_From__c = examSetupSelectionData.currentExamPart1.Id;
                       examRegMod.Part_I_Exam_Site_From__c = examSetupSelectionData.currentExamSiteId1;

                       examRegMod.Part_I_Exam_Admin_To__c = examSetupSelectionData.selectedExamAdmin1.Id;
                       examRegMod.Part_I_Exam_Group_To__c = examSetupSelectionData.selectedExamAdmin1.Exam_Group__c;
                       examRegMod.Part_I_Exam_Part_To__c = examSetupSelectionData.selectedExamPart1.Id;
                       examRegMod.Part_I_Exam_Site_To__c = examSetupSelectionData.selectedExamSiteId1;
                   }

                   if(examAttemptPart2 != NULL && examSetupSelectionData.currentExamAdmin2 != NULL) {
                       examRegMod.Part_II_Exam_Registration__c = examAttemptPart2.Id;
                       examRegMod.Part_II_Exam_Admin_From__c = examSetupSelectionData.currentExamAdmin2.Id;
                       examRegMod.Part_II_Exam_Group_From__c = examSetupSelectionData.currentExamAdmin2.Exam_Group__c;
                       examRegMod.Part_II_Exam_Part_From__c = examSetupSelectionData.currentExamPart2.Id;
                       examRegMod.Part_II_Exam_Site_From__c = examSetupSelectionData.currentExamSiteId2;

                       examRegMod.Part_II_Exam_Admin_To__c = examSetupSelectionData.selectedExamAdmin2.Id;
                       examRegMod.Part_II_Exam_Group_To__c = examSetupSelectionData.selectedExamAdmin2.Exam_Group__c;
                       examRegMod.Part_II_Exam_Part_To__c = examSetupSelectionData.selectedExamPart2.Id;
                       examRegMod.Part_II_Exam_Site_To__c = examSetupSelectionData.selectedExamSiteId2;

                   }
                   insert examRegMod;
                   returnSetExamSetupExamSelectionsChanges.examModificationId = examRegMod.Id;

                   // Compute Fees
                   examSetupSelectionFees = getExamSetupSelectionFees(examType, examSetupSelectionData, examSetupExamSelectionsInfo, mapContracts);

               }

            if(examSetupSelectionFees != NULL && !examSetupSelectionFees.fees.IsEmpty()) {
                Decimal totalFees = 0;
                for(feeInfo fee :examSetupSelectionFees.fees) {
                    totalFees+=fee.amount;
                }
                if(totalFees > 0) {
                    hasFees = True;
                }
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupExamSelectionsChanges','hasChanges',hasChanges);
            GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupExamSelectionsChanges','hasFees',hasFees);

            // Process changes if no fees
            if(!hasChanges && !hasFees) {
                returnSetExamSetupExamSelectionsChanges.paymentNeeded = False;
                returnSetExamSetupExamSelectionsChanges.statusMessage = 'No Exam Reg Mod needed';
                returnSetExamSetupExamSelectionsChanges.statusCode = 200;
            } else if(hasChanges && !hasFees) {
                Set<Id> setExamRegMods = new Set<Id>();
                setExamRegMods.add(returnSetExamSetupExamSelectionsChanges.examModificationId);

                ExamManagementController.processExamRegMods(setExamRegMods);
                GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupExamSelectionsChanges','processExamRegMods',returnSetExamSetupExamSelectionsChanges.examModificationId);

                returnSetExamSetupExamSelectionsChanges.paymentNeeded = False;
                returnSetExamSetupExamSelectionsChanges.statusMessage = 'Exam Reg Mod processed';
                returnSetExamSetupExamSelectionsChanges.statusCode = 200;
            } else {
                returnSetExamSetupExamSelectionsChanges.paymentNeeded = True;
                returnSetExamSetupExamSelectionsChanges.statusMessage = 'Exam Reg Mod Returned, Paymet Needed';
                returnSetExamSetupExamSelectionsChanges.statusCode = 200;
            }

        } else {
            returnSetExamSetupExamSelectionsChanges.statusMessage = 'Exam Changes data not returned';
            returnSetExamSetupExamSelectionsChanges.statusCode = 501;
            return returnSetExamSetupExamSelectionsChanges;
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupExamSelectionsChanges','returnSetExamSetupExamSelectionsChanges',returnSetExamSetupExamSelectionsChanges);

        return returnSetExamSetupExamSelectionsChanges;
    }

    // Pay Fees

    public class returnGetExamSetupFeesCheckoutInfo {
        public String statusMessage;
        public Integer statusCode;

        public String examType;
        public List<feeInfo> fees;
        public String targetExamAttemptId;
        public String examEmailParts;
        public String deferralSubType;
        public String transactionType;
    }

    public static returnGetExamSetupFeesCheckoutInfo getExamSetupFeesCheckoutInfo(Contact contact, MAP<String,Contract> mapContracts, String examRegistrationModificationId) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFeesCheckoutInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFeesCheckoutInfo','examRegistrationModificationId',examRegistrationModificationId);

        returnGetExamSetupFeesCheckoutInfo returnGetExamSetupFeesCheckoutInfo = new returnGetExamSetupFeesCheckoutInfo();

        // Get Exam Reg Mod Info
        List<Exam_Registration_Modification__c> lstExamRegMods = [select Id, RPT_Exam_Program__c,
                                                                  Part_I_Exam_Registration__c, Part_I_Exam_Admin_From__c, Part_I_Exam_Admin_To__c, Part_I_Exam_Site_From__c, Part_I_Exam_Site_To__c,
                                                                  Part_II_Exam_Registration__c, Part_II_Exam_Admin_From__c, Part_II_Exam_Admin_To__c, Part_II_Exam_Site_From__c, Part_II_Exam_Site_To__c
                                                                  FROM Exam_Registration_Modification__c where id = :examRegistrationModificationId];
        if(!lstExamRegMods.IsEmpty()) {
            Exam_Registration_Modification__c examMod = lstExamRegMods[0];
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFeesCheckoutInfo','examMod',examMod);

            String examType = examMod.RPT_Exam_Program__c.ToLowerCase();
            returnGetExamSetupFeesCheckoutInfo.examType = examMod.RPT_Exam_Program__c.ToLowerCase();
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFeesCheckoutInfo','examType',returnGetExamSetupFeesCheckoutInfo.examType);

            // Get Fee Data
            examSetupExamSelectionsInfo examSetupExamSelectionsInfo = new examSetupExamSelectionsInfo();
            if(examMod.Part_I_Exam_Registration__c != NULL) {
                examSetupExamSelectionsInfo.selectedAdminPart1 = examMod.Part_I_Exam_Admin_To__c;
                examSetupExamSelectionsInfo.selectedSitePart1 = examMod.Part_I_Exam_Site_To__c;
            }
            if(examMod.Part_II_Exam_Registration__c != NULL) {
                examSetupExamSelectionsInfo.selectedAdminPart2 = examMod.Part_II_Exam_Admin_To__c;
                examSetupExamSelectionsInfo.selectedSitePart2 = examMod.Part_II_Exam_Site_To__c;
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFeesCheckoutInfo','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);

            returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contact.Id);
            MAP<String,Exam_Attempt__c> mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;

            returnGetLatestExamAttemptsByType retExamRegs = getLatestExamAttemptsByType(examType, mapLatestExamAttempts);

            examSetupSelectionData examSetupSelectionData = getExamSetupSelectionData(examType, retExamRegs, examSetupExamSelectionsInfo);
            if(examSetupSelectionData != NULL) {

                examSetupSelectionFees examSetupSelectionFees = getExamSetupSelectionFees(examType, examSetupSelectionData, examSetupExamSelectionsInfo, mapContracts);
                returnGetExamSetupFeesCheckoutInfo.fees = examSetupSelectionFees.fees;

                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFeesCheckoutInfo','fees',returnGetExamSetupFeesCheckoutInfo.fees);

                // Compute rest of info needed
                Boolean partIMoved = False;
                Boolean partIIMoved = False;

                if(examMod.Part_I_Exam_Registration__c != NULL && examMod.Part_I_Exam_Admin_From__c != examMod.Part_I_Exam_Admin_To__c) {
                    partIMoved = True;
                }
                if(examMod.Part_II_Exam_Registration__c != NULL && examMod.Part_II_Exam_Admin_From__c != examMod.Part_II_Exam_Admin_To__c) {
                    partIIMoved = True;
                }

                String examParts;
                if(examType == 'frm') {
                    if(partIMoved && partIIMoved) {
                        examParts = 'FRM Exam Part I & FRM Exam Part II';
                    } else if(partIMoved) {
                        examParts = 'FRM Exam Part I';
                    } else if(partIIMoved) {
                        examParts = 'FRM Exam Part II';
                    }
                } else if(examType == 'scr') {
                    examParts = 'SCR';
                } else if(examType == 'raij') {
                    examParts = 'RAIJ';
                } else {
                    examParts = 'RiskAI';
                }

                returnGetExamSetupFeesCheckoutInfo.examEmailParts = examParts;
                returnGetExamSetupFeesCheckoutInfo.deferralSubType = 'Deferral Standard';
                if(partIMoved || partIIMoved){
                returnGetExamSetupFeesCheckoutInfo.transactionType = 'Salesforce - Deferral';
                }else{
                    returnGetExamSetupFeesCheckoutInfo.transactionType = 'Salesforce - Sales Invoice';
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFeesCheckoutInfo','examEmailParts',returnGetExamSetupFeesCheckoutInfo.examEmailParts);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFeesCheckoutInfo','deferralSubType',returnGetExamSetupFeesCheckoutInfo.deferralSubType);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupFeesCheckoutInfo','transactionType',returnGetExamSetupFeesCheckoutInfo.transactionType);

                returnGetExamSetupFeesCheckoutInfo.statusMessage = 'Exam Reg Mod Info Returned';
                returnGetExamSetupFeesCheckoutInfo.statusCode = 200;
            } else {
                returnGetExamSetupFeesCheckoutInfo.statusMessage = 'getExamSetupSelectionData failed';
                returnGetExamSetupFeesCheckoutInfo.statusCode = 501;
            }

        } else {
            returnGetExamSetupFeesCheckoutInfo.statusMessage = 'Exam Reg Mod not found';
            returnGetExamSetupFeesCheckoutInfo.statusCode = 401;
        }

        return returnGetExamSetupFeesCheckoutInfo;
    }

    // Authorization

    public class returnExamSetupAuthorizeRegistrations {
        public String statusMessage;
        public Integer statusCode;
        public Boolean schedulingRequired;
        public Boolean isAuthorized;
        public String examScheduleExamURLPart1;
        public String examScheduleExamURLPart2;
    }

    public static returnExamSetupAuthorizeRegistrations examSetupAuthorizeRegistrations(Contact contact, String examType, Boolean isRetry) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','contact',contact);
        GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','examType',examType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','isRetry',isRetry);

        returnExamSetupAuthorizeRegistrations returnExamSetupAuthorizeRegistrations = new returnExamSetupAuthorizeRegistrations();
        returnExamSetupAuthorizeRegistrations.schedulingRequired = False;

        returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contact.Id);
        MAP<String,Exam_Attempt__c> mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;

        returnGetLatestExamAttemptsByType retExamRegs = getLatestExamAttemptsByType(examType, mapLatestExamAttempts);

        Exam_Attempt__c examAttemptPart1;
        Exam_Attempt__c examAttemptPart2;

        String examProgramType = examType;
        if(examType == 'rai') {
            examProgramType = 'RiskAI';
        } else if(examType == 'raij') {
            examProgramType = 'RAIJ';
        }

        if(examProgramType != NULL) {
            for(Exam_Attempt__c ea :mapLatestExamAttempts.Values()) {
                if(ea.Opportunity__r.StageName == 'Closed') {
                    if(ea.RPT_Exam_Program__c == examProgramType) {
                        if(ea.RPT_Exam_Part__c == 'I' || ea.RPT_Exam_Part__c == 'Full') {
                            examAttemptPart1 = ea;
                        } else if(ea.RPT_Exam_Part__c == 'II') {
                            examAttemptPart2 = ea;
                        }
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','examAttemptPart1',examAttemptPart1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','examAttemptPart2',examAttemptPart2);

            Date tdy = Date.Today();

            String part1Provider;
            String part2Provider;

            // Verify Authorizations for all parts

            // Get Providers
            if(examAttemptPart1 != NULL && examAttemptPart1.Deferred_Exam_Administration__c == NULL &&
               tdy >= examAttemptPart1.Exam_Administration__r.Exam_Scheduling_Start_Date__c &&
               tdy <= examAttemptPart1.Exam_Administration__r.Exam_Scheduling_End_Date__c) {
                   part1Provider = examAttemptPart1.Exam_Site__r.Exam_Provider__r.Name;
               }

            if(examAttemptPart2 != NULL && examAttemptPart2.Deferred_Exam_Administration__c == NULL &&
               tdy >= examAttemptPart2.Exam_Administration__r.Exam_Scheduling_Start_Date__c &&
               tdy <= examAttemptPart2.Exam_Administration__r.Exam_Scheduling_End_Date__c) {
                   part2Provider = examAttemptPart2.Exam_Site__r.Exam_Provider__r.Name;
               }

            GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','part1Provider',part1Provider);
            GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','part2Provider',part2Provider);

            if(part1Provider == NULL && part2Provider == NULL) {
                returnExamSetupAuthorizeRegistrations.statusMessage = 'No scheduling is available';
                returnExamSetupAuthorizeRegistrations.statusCode = 501;
                return returnExamSetupAuthorizeRegistrations;
            }

            // If Auth is required
            returnExamSetupAuthorizeRegistrations.isAuthorized = False;
            String examStatus1;
            String examStatus2;
            if(part1Provider != NULL || part2Provider != NULL) {
                returnExamSetupAuthorizeRegistrations.schedulingRequired = True;

                if(part1Provider != NULL) {
                    examStatus1 = ExamRegistrationsStatusCls.updateRegistration(examAttemptPart1.Id,isRetry);
                }

                if(part2Provider != NULL) {
                    examStatus2 = ExamRegistrationsStatusCls.updateRegistration(examAttemptPart2.Id,isRetry);
                }
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','examStatus1',examStatus1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','examStatus2',examStatus2);

            if((examStatus1 != NULL && examStatus2 == NULL && examStatus1 == 'Processed') ||
               (examStatus2 != NULL && examStatus1 == NULL && examStatus2 == 'Processed') ||
               (examStatus1 != NULL && examStatus2 != NULL && examStatus1 == 'Processed' && examStatus2 == 'Processed' )) {
                   returnExamSetupAuthorizeRegistrations.isAuthorized = True;

                   if(examStatus1 != NULL && examStatus2 == NULL && examStatus1 == 'Processed') {
                       returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart1 = getProviderURL(part1Provider, examAttemptPart1.Id);
                   } else if(examStatus1 == NULL && examStatus2 != NULL && examStatus2 == 'Processed') {
                       returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart1 = getProviderURL(part2Provider, examAttemptPart2.Id);
                   } else if(examStatus1 != NULL && examStatus2 != NULL) {

                       // PSI does not pass exam ID
                       if(part2Provider == part1Provider && part1Provider == 'PSI' && (examStatus1 == 'Processed' || examStatus2 == 'Processed')) {
                           returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart1 = getProviderURL(part1Provider, examAttemptPart1.Id);
                       } else {
                           if(examStatus1 == 'Processed' && examStatus2 != 'Processed') {
                               returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart1 = getProviderURL(part1Provider, examAttemptPart1.Id);
                           } else if(examStatus2 == 'Processed' && examStatus1 != 'Processed') {
                               returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart2 = getProviderURL(part2Provider, examAttemptPart2.Id);
                           } else {
                               returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart1 = getProviderURL(part1Provider, examAttemptPart1.Id);
                               returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart2 = getProviderURL(part2Provider, examAttemptPart2.Id);
                           }
                       }
                   }
               }

            GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','isAuthorized',returnExamSetupAuthorizeRegistrations.isAuthorized);

            GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','examScheduleExamURLPart1',returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','examScheduleExamURLPart1',returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart2);


            if(!returnExamSetupAuthorizeRegistrations.isAuthorized) {
                returnExamSetupAuthorizeRegistrations.statusMessage = 'Authorization not completed';
                returnExamSetupAuthorizeRegistrations.statusCode = 200;
            } else {
                returnExamSetupAuthorizeRegistrations.statusMessage = 'Authorization completed';
                returnExamSetupAuthorizeRegistrations.statusCode = 200;
            }


        } else {
            returnExamSetupAuthorizeRegistrations.statusMessage = 'Exam Reg not found';
            returnExamSetupAuthorizeRegistrations.statusCode = 404;
            return returnExamSetupAuthorizeRegistrations;
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','examSetupAuthorizeRegistrations','returnExamSetupAuthorizeRegistrations',returnExamSetupAuthorizeRegistrations);

        return returnExamSetupAuthorizeRegistrations;
    }


    // ID Methods

    public class returnGetExamSetupIDInfo {
        public String statusMessage;
        public Integer statusCode;

        public Boolean isOSTA;
        public Boolean isIDRequired;
        public idFormInfo idFormInfo;
        public idCandidateInfo idCandidateInfo;
    }

    public class idFormInfo {
        public List<String> idTypes;
        public List<String> idLocations;

        public List<monthOption> idExpireMonths;
        public List<Integer> idExpireDays; // Need to validate date after selection
        public List<Integer> idExpireYears; // this year - 10 out

        public List<monthOption> dateOfBirthMonths;
        public List<Integer> dateOfBirthDays; // Need to validate date after selection
        public List<Integer> dateOfBirthYears; // 1950 - (this year - 16)

        public List<String> workStatusOptions;
        public List<String> schoolStatusOptions;
        public List<String> genderOptions;
        public List<GARP_Common.MobilePhoneLocations> mobilePhoneLocations;
        public List<GARP_Common.Institution> institutions;
    }

    public class monthOption {
        public String name;  // January, Feb...
        public Integer value; // 1, 2, ...
    }

    public class idCandidateInfo {
        public String idName;
        public String idNumber;
        public String idType;
        public String idExpireDate;
        public String mobilePhoneLocation;
        public String mobilePhoneNumber;

        public String ostaIDLocation;
        public String ostaGender;
        public String ostaFullNameInChinese;
        public String ostaDateOfBirth;
        public String ostaPhoneNumber;
        public String ostaCurrentWorkingStatus;
        public String ostaCompany;
        public String ostaCurrentSchoolStatus;
        public String ostaSchool;
        public String ostaDegreeProgramName;
    }

    public static returnGetExamSetupIDInfo getExamSetupIDInfo(Contact contact, String examType, examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupIDInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupIDInfo','examType',examType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupIDInfo','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);

        returnGetExamSetupIDInfo returnGetExamSetupIDInfo = new returnGetExamSetupIDInfo();
        returnGetExamSetupIDInfo.isOSTA = False;
        returnGetExamSetupIDInfo.isIDRequired = False;

        List<Exam_Sites__c> lstSites = getRelatedExamSites(examSetupExamSelectionsInfo);
        if(lstSites != NULL && !lstSites.IsEmpty()) {
            for(Exam_Sites__c es :lstSites) {
                if(es.Site__r.Is_OSTA_Information_Required__c) {
                    returnGetExamSetupIDInfo.isOSTA = True;
                }
                if(es.Exam__r.Exam__c.IndexOf('FRM') > -1) {
                    returnGetExamSetupIDInfo.isIDRequired = True;
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupIDInfo','isOSTA',returnGetExamSetupIDInfo.isOSTA);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamSetupIDInfo','isIDRequired',returnGetExamSetupIDInfo.isIDRequired);

        returnGetExamSetupIDInfo.idFormInfo = new idFormInfo();

        returnGetExamSetupIDInfo.idFormInfo.idTypes = new List<String>{'Passport','Driver\'s License'};
        returnGetExamSetupIDInfo.idFormInfo.idLocations = new List<String>{'China','Non-China'};
        returnGetExamSetupIDInfo.idFormInfo.genderOptions = new List<String>{'Male','Female','Other'};

        returnGetExamSetupIDInfo.idFormInfo.workStatusOptions = GARP_Common.getPickListValues('Contact','Currently_Working_Status__c');
        returnGetExamSetupIDInfo.idFormInfo.schoolStatusOptions = GARP_Common.getPickListValues('Contact','Currently_in_School_Status__c');

        List<GARP_Common.Country> countryOptions = GARP_Common.getCountries();
        returnGetExamSetupIDInfo.idFormInfo.mobilePhoneLocations = GARP_Common.getMobilePhoneLocations(countryOptions);

        returnGetExamSetupIDInfo.idFormInfo.idExpireMonths = new List<monthOption>();
        returnGetExamSetupIDInfo.idFormInfo.idExpireDays = new List<Integer>();
        returnGetExamSetupIDInfo.idFormInfo.idExpireYears = new List<Integer>();

        returnGetExamSetupIDInfo.idFormInfo.dateOfBirthMonths = new List<monthOption>();
        returnGetExamSetupIDInfo.idFormInfo.dateOfBirthDays = new List<Integer>();
        returnGetExamSetupIDInfo.idFormInfo.dateOfBirthYears = new List<Integer>();

        MAP<String,Integer> mapMonths = GARP_Common.getMonthMap();

        // ID Expire Date
        for(String month :mapMonths.keySet()) {
            monthOption monthOption = new monthOption();
            monthOption.name = month;
            monthOption.value = mapMonths.get(month);
            returnGetExamSetupIDInfo.idFormInfo.idExpireMonths.add(monthOption);
            returnGetExamSetupIDInfo.idFormInfo.dateOfBirthMonths.add(monthOption);
        }

        for(Integer i = 1; i <= 31; i++) {
            returnGetExamSetupIDInfo.idFormInfo.idExpireDays.add(i);
            returnGetExamSetupIDInfo.idFormInfo.dateOfBirthDays.add(i);
        }

        // Birthday
        Integer minYear = 1930;
        Integer maxYear = Date.Today().Year() - 16;
        for(Integer i = minYear; i <=maxYear ; i++) {
            returnGetExamSetupIDInfo.idFormInfo.dateOfBirthYears.add(i);
        }

        // ID Expire Date
        minYear = Date.Today().Year();
        maxYear = Date.Today().Year() + 10;
        for(Integer i = minYear; i <=maxYear ; i++) {
            returnGetExamSetupIDInfo.idFormInfo.idExpireYears.add(i);
        }

        returnGetExamSetupIDInfo.idFormInfo.institutions = GARP_Common.getInstitutions();

        returnGetExamSetupIDInfo.idCandidateInfo = new idCandidateInfo();

        String idName = getNameOnID(contact, examType);

        returnGetExamSetupIDInfo.idCandidateInfo.idName = idName;

        if(returnGetExamSetupIDInfo.isOSTA) {
            returnGetExamSetupIDInfo.idCandidateInfo.idNumber = contact.OSTA_Full_ID__c;
        } else {
            returnGetExamSetupIDInfo.idCandidateInfo.idNumber = contact.ID_Number__c;
        }


        returnGetExamSetupIDInfo.idCandidateInfo.idType = contact.ID_Type__c;
        if(returnGetExamSetupIDInfo.idCandidateInfo.idType != NULL && returnGetExamSetupIDInfo.idCandidateInfo.idType.IndexOf('Driver') > -1) {
            returnGetExamSetupIDInfo.idCandidateInfo.idType = 'Driver License';
        }

        if(contact.ID_Expiration_Date__c != NULL) {
            DateTime inptDt = DateTime.NewInstance(contact.ID_Expiration_Date__c.year(),contact.ID_Expiration_Date__c.month(),contact.ID_Expiration_Date__c.day());
            returnGetExamSetupIDInfo.idCandidateInfo.idExpireDate = inptDt.format('MM/dd/yyyy');
        }

        returnGetExamSetupIDInfo.idCandidateInfo.mobilePhoneLocation = contact.Mobile_Phone_Code__c;
        returnGetExamSetupIDInfo.idCandidateInfo.mobilePhoneNumber = contact.MobilePhone;

        returnGetExamSetupIDInfo.idCandidateInfo.ostaIDLocation = contact.OSTA_ID_Location__c;
        returnGetExamSetupIDInfo.idCandidateInfo.ostaGender = contact.Gender__c;
        returnGetExamSetupIDInfo.idCandidateInfo.ostaFullNameInChinese = contact.Full_Name_in_Chinese__c;

        if(contact.Birthdate != NULL) {
            DateTime inptDt = DateTime.NewInstance(contact.Birthdate.year(),contact.Birthdate.month(),contact.Birthdate.day());
            returnGetExamSetupIDInfo.idCandidateInfo.ostaDateOfBirth = inptDt.format('MM/dd/yyyy');
        }

        if(contact.HomePhone != NULL) {
            returnGetExamSetupIDInfo.idCandidateInfo.ostaPhoneNumber = contact.HomePhone;
        } else if(contact.OtherPhone != NULL) {
            returnGetExamSetupIDInfo.idCandidateInfo.ostaPhoneNumber = contact.OtherPhone;
        } else if(contact.Phone != NULL) {
            returnGetExamSetupIDInfo.idCandidateInfo.ostaPhoneNumber = contact.Phone;
        }

        returnGetExamSetupIDInfo.idCandidateInfo.ostaCurrentWorkingStatus = contact.Currently_Working_Status__c;
        returnGetExamSetupIDInfo.idCandidateInfo.ostaCompany = contact.Company__c;
        returnGetExamSetupIDInfo.idCandidateInfo.ostaCurrentSchoolStatus = contact.Currently_in_School_Status__c;
        returnGetExamSetupIDInfo.idCandidateInfo.ostaSchool = contact.School_Name__c;
        returnGetExamSetupIDInfo.idCandidateInfo.ostaDegreeProgramName = contact.Degree_Program_Name__c;


        return returnGetExamSetupIDInfo;
    }

    public class setIdCandidateInfo {
        public String idName;
        public String idNumber;
        public String idType;
        public String idExpireDate; // mm/dd/yyyy
        public String mobilePhoneLocation;
        public String mobilePhoneNumber;

        public String ostaIDLocation;
        public String ostaGender;
        public String ostaFullNameInChinese;
        public String ostaDateOfBirth; // mm/dd/yyyy
        public String ostaPhoneNumber;
        public String ostaCurrentWorkingStatus;
        public String ostaCompany;
        public String ostaCurrentSchoolStatus;
        public String ostaSchool;
        public String ostaDegreeProgramName;
    }

    public class returnSetExamSetupIDInfo {
        public String statusMessage;
        public Integer statusCode;

        public String nextScreen; // Setup Complete, Pay Fees, Check Authorization

        // Pay Fees
        public Boolean paymentRequired;
        public String examModificationId;

        // Schedule Exam
        public Boolean schedulingRequired;
    }

    public static returnSetExamSetupIDInfo setExamSetupIDInfo(Contact contact, String examType, MAP<String,Contract> mapContracts, examSetupExamSelectionsInfo examSetupExamSelectionsInfo, setIdCandidateInfo idCandidateInfo) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','examType',examType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);
        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','idCandidateInfo',idCandidateInfo);

        returnSetExamSetupIDInfo returnSetExamSetupIDInfo = new returnSetExamSetupIDInfo();
        if(idCandidateInfo.idName != NULL) {

            if(examType == 'frm') {
                contact.Name_as_it_Appears_on_ID__c = idCandidateInfo.idName;
            } else {
                contact.First_Name_as_it_Appears_on_ID__c = '';
                contact.Middle_Name_as_it_Appears_on_ID__c = '';
                contact.Last_Name_as_it_Appears_on_ID__c = '';
                for(String key: idCandidateInfo.idName.split(' ')){
                    if(contact.First_Name_as_it_Appears_on_ID__c == '') {
                        contact.First_Name_as_it_Appears_on_ID__c = key;
                    } else if(contact.Last_Name_as_it_Appears_on_ID__c == '') {
                        contact.Last_Name_as_it_Appears_on_ID__c = key;
                    } else {
                        contact.Last_Name_as_it_Appears_on_ID__c += ' ' + key;
                    }
                }

            }

        }

        if(idCandidateInfo.idNumber != NULL) {

            if(idCandidateInfo.idNumber.length() > 5) {
                contact.OSTA_Full_ID__c = idCandidateInfo.idNumber;
                contact.ID_Number__c = idCandidateInfo.idNumber.Right(5);
            } else {
                contact.ID_Number__c = idCandidateInfo.idNumber;
            }

            if(idCandidateInfo.idType != NULL && idCandidateInfo.idType.ToLowerCase().IndexOf('driver') > -1) {
                idCandidateInfo.idType = 'Driver\'s License';
            }

            contact.ID_Type__c = idCandidateInfo.idType;
            if(!String.IsEmpty(idCandidateInfo.idExpireDate)) {
                contact.ID_Expiration_Date__c = date.parse(idCandidateInfo.idExpireDate);
            }
        }

        if(idCandidateInfo.mobilePhoneLocation != NULL) {
            contact.Mobile_Phone_Code__c = idCandidateInfo.mobilePhoneLocation;
            contact.MobilePhone = idCandidateInfo.mobilePhoneNumber;
        }

        if(idCandidateInfo.ostaIDLocation != NULL) {
            contact.OSTA_ID_Location__c = idCandidateInfo.ostaIDLocation;
            contact.Gender__c = idCandidateInfo.ostaGender;
            contact.Full_Name_in_Chinese__c = idCandidateInfo.ostaFullNameInChinese;
            if(!String.IsEmpty(idCandidateInfo.ostaDateOfBirth)) {
                contact.Birthdate = date.parse(idCandidateInfo.ostaDateOfBirth);
            }
            contact.HomePhone = idCandidateInfo.ostaPhoneNumber;
            contact.Currently_Working_Status__c = idCandidateInfo.ostaCurrentWorkingStatus;
            contact.Company__c = idCandidateInfo.ostaCompany;
            contact.Currently_in_School_Status__c = idCandidateInfo.ostaCurrentSchoolStatus;
            contact.School_Name__c = idCandidateInfo.ostaSchool;
            contact.Degree_Program_Name__c = idCandidateInfo.ostaDegreeProgramName;
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','final contact',contact);

        update contact;

        // Condense Calls
        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','Call getExamSetupExamSelectionInfo',contact);

        returnSetExamSetupIDInfo.paymentRequired = False;
        returnSetExamSetupIDInfo.schedulingRequired = False;
        //returnSetExamSetupIDInfo.retryAuthorization = False;

        returnGetExamSetupExamSelectionInfo returnGetExamSetupExamSelectionInfo = getExamSetupExamSelectionInfo(contact, examType, mapContracts, examSetupExamSelectionsInfo);
        if(returnGetExamSetupExamSelectionInfo.statusCode == 200) {

            GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','GetExamSetupExamSelectionInfo completed successfully',contact);

            returnSetExamSetupIDInfo.schedulingRequired = returnGetExamSetupExamSelectionInfo.schedulingRequired;

            if(returnGetExamSetupExamSelectionInfo.hasChanges) {

                GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','Call setExamSetupExamSelectionsChanges',contact);

                returnSetExamSetupExamSelectionsChanges returnSetExamSetupExamSelectionsChanges = setExamSetupExamSelectionsChanges(contact, examType, mapContracts, examSetupExamSelectionsInfo);

                if(returnGetExamSetupExamSelectionInfo.statusCode == 200) {

                    returnSetExamSetupIDInfo.examModificationId = returnSetExamSetupExamSelectionsChanges.examModificationId;
                    GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','setExamSetupExamSelectionsChanges completed successfully',returnSetExamSetupIDInfo.examModificationId);

                } else {
                    returnSetExamSetupIDInfo.statusMessage = returnSetExamSetupExamSelectionsChanges.statusMessage;
                    returnSetExamSetupIDInfo.statusCode = returnSetExamSetupExamSelectionsChanges.statusCode;
                    return returnSetExamSetupIDInfo;
                }

            }

            if(returnGetExamSetupExamSelectionInfo.hasFees && returnGetExamSetupExamSelectionInfo.totalFees > 0) {

                returnSetExamSetupIDInfo.nextScreen = 'Pay Fees';
                returnSetExamSetupIDInfo.paymentRequired = True;
                GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','Final hasFees',returnSetExamSetupIDInfo.nextScreen);

            } else if(returnGetExamSetupExamSelectionInfo.schedulingRequired) {

                returnSetExamSetupIDInfo.nextScreen = 'Check Authorization';
                returnSetExamSetupIDInfo.schedulingRequired = True;

                GARP_Common.debugLog('GARP_BC_MyPrograms','setExamSetupIDInfo','schedulingRequired',contact);

            } else {
                returnSetExamSetupIDInfo.nextScreen = 'Setup Complete';
            }

        } else {
            returnSetExamSetupIDInfo.statusMessage = returnGetExamSetupExamSelectionInfo.statusMessage;
            returnSetExamSetupIDInfo.statusCode = returnGetExamSetupExamSelectionInfo.statusCode;
            return returnSetExamSetupIDInfo;
        }

        returnSetExamSetupIDInfo.statusMessage = 'ID Info Updated';
        returnSetExamSetupIDInfo.statusCode = 200;

        return returnSetExamSetupIDInfo;
    }

    // Get Current and Next Exam Admin Registration
    public class currentNextExamAdminRegInfo {
        public Boolean isRegistrationOpen;
        public String currentExamAdminName;
        public Date currentExamAdminRegCloseDate;
        public String nextExamAdminName;
        public Date nextExamAdminRegistrationOpenDate;
    }

    public static currentNextExamAdminRegInfo getCurrentNextExamAdminRegInfo(String examType) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getCurrentNextExamAdminRegInfo','examType',examType);

        currentNextExamAdminRegInfo currentNextExamAdminRegInfo = new currentNextExamAdminRegInfo();

        List<Exam_Administration__c> lstAdmins = [select Id, Name, Exam_Group__c, Registration_Start_Date__c, Registration_End_Date__c,
                                                  Exam_Admin_Modifications_Start_Date__c, Exam_Admin_Modifications_End_Date__c,
                                                  Exam_Scheduling_Start_Date__c, Exam_Scheduling_End_Date__c,
                                                  Exam_Type__c, Month__c, Year__c
                                                  from Exam_Administration__c
                                                  where Exam_Type__c = :examType AND
                                                  ((Registration_Start_Date__c <= TODAY AND
                                                    Registration_End_Date__c >= TODAY) OR Registration_Start_Date__c > TODAY) AND
                                                  Contingency_Administration__c = False
                                                  ORDER BY Registration_Start_Date__c
                                                 ];
        GARP_Common.debugLog('GARP_BC_MyPrograms','getCurrentNextExamAdminRegInfo','lstAdmins',lstAdmins);

        Date tdy = Date.Today();

        if(!lstAdmins.isEmpty()) {
            String currentMonth;
            String nextMonth;
            String firstNextAdminGroupId;
            currentNextExamAdminRegInfo.isRegistrationOpen = False;

            for(Exam_Administration__c ea :lstAdmins) {

                GARP_Common.debugLog('GARP_BC_MyPrograms','getCurrentNextExamAdminRegInfo','Loop ea',ea);

                if(ea.Registration_Start_Date__c <= tdy && ea.Registration_End_Date__c >= tdy) {
                    currentNextExamAdminRegInfo.isRegistrationOpen = True;

                    if(currentMonth != NULL) {
                        currentNextExamAdminRegInfo.currentExamAdminName = currentMonth + ' and ' + ea.Month__c + ' ' + String.valueOf(ea.Year__c);
                    } else {
                        currentNextExamAdminRegInfo.currentExamAdminName = ea.Month__c + ' ' + String.valueOf(ea.Year__c);
                    }
                    currentMonth = ea.Month__c;
                    currentNextExamAdminRegInfo.currentExamAdminRegCloseDate = ea.Registration_End_Date__c;

                    GARP_Common.debugLog('GARP_BC_MyPrograms','getCurrentNextExamAdminRegInfo','currentMonth',currentMonth);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getCurrentNextExamAdminRegInfo','currentExamAdminName',currentNextExamAdminRegInfo.currentExamAdminName);

                } else if(ea.Registration_Start_Date__c > tdy) {

                    // If first next admin, or in the same Exam Group
                    if(currentNextExamAdminRegInfo.nextExamAdminName == NULL) {
                        currentNextExamAdminRegInfo.nextExamAdminName = ea.Month__c + ' ' + String.valueOf(ea.Year__c);
                        currentNextExamAdminRegInfo.nextExamAdminRegistrationOpenDate = ea.Registration_Start_Date__c;
                    }
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getCurrentNextExamAdminRegInfo','nextExamAdminName',currentNextExamAdminRegInfo.nextExamAdminName);
                }
            }
        } else {
            return NULL;
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getCurrentNextExamAdminRegInfo','currentNextExamAdminRegInfo',currentNextExamAdminRegInfo);

        return currentNextExamAdminRegInfo;
    }

    // Exam Results
    static public Boolean isLoadingResults(Boolean isLoading, String loadKey) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','isLoadingResults','isLoading',isLoading);
        GARP_Common.debugLog('GARP_BC_MyPrograms','isLoadingResults','loadKey',loadKey);

        Boolean isLoad = False;
        if(isLoading && loadKey != 'kiujgh&^%Rrf7u') {
            isLoad = true;
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','isLoadingResults','isLoad',isLoad);
        return isLoad;
    }

    public class examResult {
        public String examAttemptId;
        public String programType; // FRM/ERP/SCR/Risk.Net
        public String examPart; // I, II, FULL
        public String adminName; // Month Year
        public Boolean hasViolation;
        public String result; // Pass, Fail, No-Show, Not-Graded
        public String downloadResultsLetterURL;
        public String downloadQuartilesURL;
        public Date releaseDate; 
        Public Date nextAdminOpenDate;  
        public List<quartileInfo> quartiles;
    }

    public class quartileInfo {
        public String name;
        public Decimal value;
    }

    public static List<examResult> getExamResults(String contactId, String loadKey) {
        List<examResult> examResults = new List<examResult>();

        List<Exam_Attempt__c > examRegs = [
            SELECT
            Id,
            Name,
            Cancelled__c,
            Opportunity__r.StageName,
            Attending_Exam_Name__c,
            Other_Exam_Registrations__r.hasViolation__c,
            Section__c,
            Section_Exam_Name__c,
            Result__c,
            Exam_Date__c,
            Category_1__c,
            hasViolation__c,
            Quartile_1__c,
            Category_2__c,
            Quartile_2__c,
            Category_3__c,
            Quartile_3__c,
            Category_4__c,
            Quartile_4__c,
            Category_5__c,
            Quartile_5__c,
            Category_6__c,
            Quartile_6__c,
            Category_7__c,
            Quartile_7__c,
            Category_8__c,
            Quartile_8__c,
            Category_9__c,
            Quartile_9__c,
            Category_10__c,
            Quartile_10__c,
            Re_score_Status__c,
            RPT_Exam_Mode__c,
            //Exam_Site__r.Exam__r.Exam_Group__r.Exam_Results_Available_Date__c,
            //Exam_Site__r.Exam__r.Exam_Group__r.Loading_Exam_Results__c,
            Exam_Administration__c,
            Exam_Administration__r.Exam_Results_Loading__c,
            Exam_Administration__r.Exam_Results_Release_Date__c,
            Exam_Part__r.Exam_Results_Release_Date__c,
            RPT_Administration_Month__c,
            RPT_Administration_Year__c,
            RPT_Exam_Program__c,
            RPT_Exam_Part__c,
            Hide_Exam_Result__c 
            FROM Exam_Attempt__c
            WHERE
            //Id = :examAttemptId AND
            Member__c = :contactId AND
            Hide_Exam_Result__c = False AND
            Result__c != null AND Cancelled__c != TRUE AND
            Section__c in ('SCR','RAIJ','ERP','ERP1','ERP2','FRM Part 1','FRM Part 2','FRM Full Program','ERP Exam Part I','ERP Exam Part II','RiskAI')
            Order by RPT_Administration_Date__c DESC
        ];
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamResults','examRegs',examRegs);

        DateTime tdy = DateTime.Now();

        for(Exam_Attempt__c ea :examRegs) {

            GARP_Common.debugLog('GARP_BC_MemberPortal','getExamResults','Loop ea',ea);

            // Get Exam Results Release Date
            DateTime examResultsReleaseDate = ea.Exam_Administration__r.Exam_Results_Release_Date__c;
            if(ea.Exam_Part__r.Exam_Results_Release_Date__c != NULL) {
                examResultsReleaseDate = ea.Exam_Part__r.Exam_Results_Release_Date__c;
            }

            if((ea.Exam_Administration__c != NULL && !isLoadingResults(ea.Exam_Administration__r.Exam_Results_Loading__c, loadKey) &&
               (examResultsReleaseDate == NULL || tdy >= examResultsReleaseDate)) ||
               ea.Exam_Administration__c == NULL
            ) {

                examResult examResult = new examResult();
                examResult.examAttemptId = ea.Id;
                examResult.programType = ea.RPT_Exam_Program__c;
                examResult.examPart = ea.RPT_Exam_Part__c;
                examResult.adminName = ea.RPT_Administration_Month__c + ' ' + ea.RPT_Administration_Year__c;
                examResult.hasViolation = ea.hasViolation__c; 
                examResult.result = ea.Result__c;
                if(examResult.hasViolation) {
                    examResult.result = 'Not Graded';
                }
 
                if(!examResult.hasViolation && (ea.Result__c == 'Pass' || ea.Result__c == 'Fail')) {
                    if(ea.Section__c == 'RiskAI') {
                        examResult.downloadResultsLetterURL = '/apex/Exam_Results_Letter_RAI_' + ea.RPT_Administration_Month__c + ea.RPT_Administration_Year__c + '?id=' + ea.Id;
                    } else if(ea.Section__c == 'RAIJ') {
                        examResult.downloadResultsLetterURL = '/apex/Exam_Results_Letter_RAIJ_' + ea.RPT_Administration_Month__c + ea.RPT_Administration_Year__c + '?id=' + ea.Id;
                    } else {

                        if(ea.RPT_Administration_Month__c == 'October' && ea.RPT_Administration_Year__c == '2020') {
                            examResult.downloadResultsLetterURL = '/apex/Exam_Results_Letter_' + ea.RPT_Exam_Program__c + '_' + ea.RPT_Administration_Month__c + ea.RPT_Administration_Year__c + '?id=' + ea.Id;
                        } else {
                            
                            Integer yr = Integer.ValueOf(ea.RPT_Administration_Year__c);
                            if(yr < 2015) {
                                examResult.downloadResultsLetterURL = '/apex/Exam_Results_Letter?id=' + ea.Id;
                            } else {
                            	examResult.downloadResultsLetterURL = '/apex/Exam_Results_Letter_' + ea.RPT_Administration_Month__c + ea.RPT_Administration_Year__c + '?id=' + ea.Id;    
                            }
                            
                            
                        }
                    }

                    examResult.downloadQuartilesURL = '/apex/PerformanceAnalysisAsPDF?id=' + ea.Id;
                    if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                        examResult.downloadQuartilesURL = '/apex/PerformanceAnalysisAsPDFMay2019?id=' + ea.Id;
                    }

                    // Quartiles
                    examResult.quartiles = new List<quartileInfo>();

                    if(ea.Category_1__c != NULL && ea.Quartile_1__c != NULL) {
                        quartileInfo quartileInfo = new quartileInfo();
                        quartileInfo.name = ea.Category_1__c;
                        quartileInfo.value = ea.Quartile_1__c;
                        if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                            quartileInfo.value = 5 - ea.Quartile_1__c;
                        }
                        examResult.quartiles.add(quartileInfo);
                    }
                    if(ea.Category_2__c != NULL && ea.Quartile_2__c != NULL) {
                        quartileInfo quartileInfo = new quartileInfo();
                        quartileInfo.name = ea.Category_2__c;
                        quartileInfo.value = ea.Quartile_2__c;
                        if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                            quartileInfo.value = 5 - ea.Quartile_2__c;
                        }                        
                        examResult.quartiles.add(quartileInfo);
                    }
                    if(ea.Category_3__c != NULL && ea.Quartile_3__c != NULL) {
                        quartileInfo quartileInfo = new quartileInfo();
                        quartileInfo.name = ea.Category_3__c;
                        quartileInfo.value = ea.Quartile_3__c;
                        if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                            quartileInfo.value = 5 - ea.Quartile_3__c;
                        }                                                
                        examResult.quartiles.add(quartileInfo);
                    }
                    if(ea.Category_4__c != NULL && ea.Quartile_4__c != NULL) {
                        quartileInfo quartileInfo = new quartileInfo();
                        quartileInfo.name = ea.Category_4__c;
                        quartileInfo.value = ea.Quartile_4__c;
                        if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                            quartileInfo.value = 5 - ea.Quartile_4__c;
                        }                                                                        
                        examResult.quartiles.add(quartileInfo);
                    }
                    if(ea.Category_5__c != NULL && ea.Quartile_5__c != NULL) {
                        quartileInfo quartileInfo = new quartileInfo();
                        quartileInfo.name = ea.Category_5__c;
                        quartileInfo.value = ea.Quartile_5__c;
                        if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                            quartileInfo.value = 5 - ea.Quartile_5__c;
                        }                                                                                                
                        examResult.quartiles.add(quartileInfo);
                    }
                    if(ea.Category_6__c != NULL && ea.Quartile_6__c != NULL) {
                        quartileInfo quartileInfo = new quartileInfo();
                        quartileInfo.name = ea.Category_6__c;
                        quartileInfo.value = ea.Quartile_6__c;
                        if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                            quartileInfo.value = 5 - ea.Quartile_6__c;
                        }                                                                                                                        
                        examResult.quartiles.add(quartileInfo);
                    }
                    if(ea.Category_7__c != NULL && ea.Quartile_7__c != NULL) {
                        quartileInfo quartileInfo = new quartileInfo();
                        quartileInfo.name = ea.Category_7__c;
                        quartileInfo.value = ea.Quartile_7__c;
                        if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                            quartileInfo.value = 5 - ea.Quartile_7__c;
                        }                                                                                                                        
                        examResult.quartiles.add(quartileInfo);
                    }
                    if(ea.Category_8__c != NULL && ea.Quartile_8__c != NULL) {
                        quartileInfo quartileInfo = new quartileInfo();
                        quartileInfo.name = ea.Category_8__c;
                        quartileInfo.value = ea.Quartile_8__c;
                        if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                            quartileInfo.value = 5 - ea.Quartile_8__c;
                        }                                                                                                                        
                        examResult.quartiles.add(quartileInfo);
                    }
                    if(ea.Category_9__c != NULL && ea.Quartile_9__c != NULL) {
                        quartileInfo quartileInfo = new quartileInfo();
                        quartileInfo.name = ea.Category_9__c;
                        quartileInfo.value = ea.Quartile_9__c;
                        if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                            quartileInfo.value = 5 - ea.Quartile_9__c;
                        }                                                                                                                        
                        examResult.quartiles.add(quartileInfo);
                    }
                    if(ea.Category_10__c != NULL && ea.Quartile_10__c != NULL) {
                        quartileInfo quartileInfo = new quartileInfo();
                        quartileInfo.name = ea.Category_10__c;
                        quartileInfo.value = ea.Quartile_10__c;
                        if(ea.RPT_Administration_Month__c == 'May' && ea.RPT_Administration_Year__c == '2019') {
                            quartileInfo.value = 5 - ea.Quartile_10__c;
                        }                                                                                                                        
                        examResult.quartiles.add(quartileInfo);
                    }
                }

                examResults.add(examResult);
            }
        }

        return examResults;
    }

    public static GARP_Common.returnInfo setExamResultLastViewDate(String contactId, String examAttemptId) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamResultLastViewDate','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MyPrograms','setExamResultLastViewDate','examAttemptId',examAttemptId);

        GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();

        List<Exam_Attempt__c> lstEA = [select Id, Results_Viewed_Date__c from Exam_Attempt__c where id = :examAttemptId];
        if(!lstEA.IsEmpty()) {
            lstEA[0].Results_Viewed_Date__c = DateTime.Now();
            update lstEA;

            returnInfo.status = 'Success';
            return returnInfo;

        } else {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'Exam Attempt Not Found';
            return returnInfo;
        }
    }

    // Get enrolled programs
    public class enrolledProgramInfo {
        public String programType;
        public String adminPartIName;
        public String adminPartIIName;
        public List<Exam_Attempt__c> examRegistrations;
        programInformation programInformation;
    }


    public class enrolledPrograms {
        public enrolledProgramInfo frmProgram;
        public enrolledProgramInfo erpProgram;
        public enrolledProgramInfo scrProgram;
        public enrolledProgramInfo raijProgram;
        public enrolledProgramInfo riskaiProgram;
        public enrolledProgramInfo frrProgram;
        public enrolledProgramInfo frr25Program;
        public enrolledProgramInfo ffrProgram;
        public MAP<String,enrolledProgramInfo> microCoursesMap;

        public MAP<String,Exam_Attempt__c> mapLatestExamAttempts;
        public List<Exam_Attempt__c> allExamAttempts;
        public GARP_BC_Courses.microCourseConfig microCourseConfig;
    }

    public static enrolledPrograms getEnrolledPrograms(String contactId, MAP<String,Contract> mapContracts, String loadKey) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','mapContracts',mapContracts);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','loadKey',loadKey);

        enrolledPrograms enrolledPrograms = new enrolledPrograms();

        enrolledPrograms.microCoursesMap = new MAP<String,enrolledProgramInfo>();

        Contract frmContract = mapContracts.get('FRM_Program');
        Contract erpContract = mapContracts.get('ERP_Program');
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','frmContract',frmContract);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','erpContract',erpContract);

        Contract scrContract = mapContracts.get('SCR_Program');
        Contract riskaiContract = mapContracts.get('Risk_AI_Program');
        Contract raijContract = mapContracts.get('RAIJ_Program');

        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','scrContract',scrContract);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','riskaiContract',riskaiContract);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','raijContract',raijContract);
        
        Contract frrContract = mapContracts.get('ICBRR_Program');
        Contract frr25Contract = mapContracts.get('FRR25_Program');
        Contract ffrContract = mapContracts.get('FBR_Program');
        
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','frrContract',frrContract);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','frr25Contract',frr25Contract);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','ffrContract',ffrContract);
        
        enrolledPrograms.mapLatestExamAttempts = new MAP<String,Exam_Attempt__c>();
        //if(frmContract != NULL || erpContract != NULL || scrContract != NULL || riskaiContract != NULL) {
            returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contactId);
            enrolledPrograms.mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;
            enrolledPrograms.allExamAttempts = returnLatestExamAttempts.allExamAttempts;
        //}

        MAP<String,Integer> monthsMap = GARP_Common.getMonthMap();

        // Get latest FRM Exam Attempt
        Exam_Attempt__c frmExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('FRMI');
		GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','frmExamAttempt',frmExamAttempt);
        
        if(frmContract != NULL && frmExamAttempt != NULL) {
            Boolean isLoadingPart = isLoadingResults(frmExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            if(frmContract.Status != 'Completed' || (frmContract.Status == 'Completed' && isLoadingPart)) {
                enrolledPrograms.frmProgram = new enrolledProgramInfo();
                enrolledPrograms.frmProgram.programType = 'FRM';
                enrolledPrograms.frmProgram.adminPartIName = 'Part ' + frmExamAttempt.RPT_Exam_Part__c + ' - ' + frmExamAttempt.RPT_Administration_Month__c + ' ' + frmExamAttempt.RPT_Administration_Year__c;

                Exam_Attempt__c frmExamAttemptPartII = enrolledPrograms.mapLatestExamAttempts.get('FRMII');
                if(frmExamAttemptPartII != NULL) {
                    enrolledPrograms.frmProgram.adminPartIIName = 'Part ' + frmExamAttemptPartII.RPT_Exam_Part__c + ' - ' + frmExamAttemptPartII.RPT_Administration_Month__c + ' ' + frmExamAttemptPartII.RPT_Administration_Year__c;
                }
                enrolledPrograms.frmProgram.programInformation = GARP_BC_MyPrograms.getProgramInformation('FRM', NULL);

                GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','frmProgram',enrolledPrograms.frmProgram);
            }
        }

        Exam_Attempt__c erpExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('ERPI');
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','erpExamAttempt',erpExamAttempt);

        if(erpContract != NULL && erpExamAttempt != NULL) {
            if(erpContract.Status != 'Completed') {
                Boolean passPart1 = FALSE;
                Boolean passPart2 = FALSE;
                for(Candidate_Requirement__c cr :erpContract.Candidate_Requirements__r) {
                    if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'ERP Part I' && cr.Status__c == 'Completed') {
                        passPart1 = TRUE;
                    }
                    if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'ERP Part II' && cr.Status__c == 'Completed') {
                        passPart2 = TRUE;
                    }
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','passPart1',passPart1);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','passPart2',passPart2);

                if(passPart1 && passPart2) {
                    enrolledPrograms.erpProgram = new enrolledProgramInfo();
                    enrolledPrograms.erpProgram.programType = 'ERP';
                    enrolledPrograms.erpProgram.adminPartIName = 'Part ' + erpExamAttempt.RPT_Exam_Part__c + ' - ' + erpExamAttempt.RPT_Administration_Month__c + ' ' + erpExamAttempt.RPT_Administration_Year__c;

                    GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','erpProgram',enrolledPrograms.erpProgram);

                    Exam_Attempt__c erpExamAttemptPartII = enrolledPrograms.mapLatestExamAttempts.get('ERPII');
                    if(erpExamAttemptPartII != NULL) {
                        enrolledPrograms.erpProgram.adminPartIIName = 'Part ' + erpExamAttemptPartII.RPT_Exam_Part__c + ' - ' + erpExamAttemptPartII.RPT_Administration_Month__c + ' ' + erpExamAttemptPartII.RPT_Administration_Year__c;
                    }
                    enrolledPrograms.erpProgram.programInformation = GARP_BC_MyPrograms.getProgramInformation('ERP', NULL);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','erpProgram',enrolledPrograms.erpProgram);
                }
            }
        }

        Exam_Attempt__c scrExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('SCRFull');
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','scrExamAttempt',scrExamAttempt);
        
        if(scrContract != NULL && scrExamAttempt != NULL) {
            Boolean isLoadingPart = isLoadingResults(scrExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            if(scrContract.Status != 'Completed' || (scrContract.Status == 'Completed' && isLoadingPart)) {
                enrolledPrograms.scrProgram = new enrolledProgramInfo();
                enrolledPrograms.scrProgram.programType = 'SCR';
                enrolledPrograms.scrProgram.adminPartIName = scrExamAttempt.RPT_Administration_Month__c + ' ' + scrExamAttempt.RPT_Administration_Year__c;
                GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','scrProgram',enrolledPrograms.scrProgram);
                enrolledPrograms.scrProgram.programInformation = GARP_BC_MyPrograms.getProgramInformation('SCR', NULL);
            }
        }
        
        Exam_Attempt__c riskaiExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('RiskAIFull');
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','riskaiExamAttempt',riskaiExamAttempt);
        
        if(riskaiContract != NULL && riskaiExamAttempt != NULL) {
            Boolean isLoadingPart = isLoadingResults(riskaiExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            if(riskaiContract.Status != 'Completed' || (riskaiContract.Status == 'Completed' && isLoadingPart)) {
                enrolledPrograms.riskaiProgram = new enrolledProgramInfo();
                enrolledPrograms.riskaiProgram.programType = 'RiskAI';
                enrolledPrograms.riskaiProgram.adminPartIName = riskaiExamAttempt.RPT_Administration_Month__c + ' ' + riskaiExamAttempt.RPT_Administration_Year__c;
                enrolledPrograms.riskaiProgram.programInformation = GARP_BC_MyPrograms.getProgramInformation('RAI', NULL);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','riskaiProgram',enrolledPrograms.riskaiProgram);
            }
        }

        Exam_Attempt__c raijExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('RAIJFull');
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','raijExamAttempt',raijExamAttempt);

        if(raijContract != NULL && raijExamAttempt != NULL) {
            Boolean isLoadingPart = isLoadingResults(raijExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            if(raijContract.Status != 'Completed' || (raijContract.Status == 'Completed' && isLoadingPart)) {
                enrolledPrograms.raijProgram = new enrolledProgramInfo();
                enrolledPrograms.raijProgram.programType = 'RAIJ';
                enrolledPrograms.raijProgram.adminPartIName = raijExamAttempt.RPT_Administration_Month__c + ' ' + raijExamAttempt.RPT_Administration_Year__c;
                GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','raijProgram',enrolledPrograms.raijProgram);
                enrolledPrograms.raijProgram.programInformation = GARP_BC_MyPrograms.getProgramInformation('RAIJ', NULL);
            }
        }        

        Exam_Attempt__c frrExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('FRRFull');
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','frrExamAttempt',frrExamAttempt);
        
        if(frrContract != NULL && frrContract.Status != 'Completed' && frrExamAttempt != NULL) {
            enrolledPrograms.frrProgram = new enrolledProgramInfo();
            enrolledPrograms.frrProgram.programType = 'FRR';
            enrolledPrograms.frrProgram.programInformation = GARP_BC_MyPrograms.getProgramInformation('FRR', NULL);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','frrProgram',enrolledPrograms.frrProgram);
        }

        Exam_Attempt__c frr25ExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('FRR25Full');
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','frr25ExamAttempt',frr25ExamAttempt);
        
        if(frr25Contract != NULL && frr25Contract.Status != 'Completed' && frr25ExamAttempt != NULL) {
            enrolledPrograms.frr25Program = new enrolledProgramInfo();
            enrolledPrograms.frr25Program.programType = 'FRR25';
            enrolledPrograms.frr25Program.programInformation = GARP_BC_MyPrograms.getProgramInformation('FRR25', NULL);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','frr25Program',enrolledPrograms.frr25Program);
        }

        if(ffrContract != NULL && ffrContract.Status != 'Completed') {
            enrolledPrograms.ffrProgram = new enrolledProgramInfo();
            enrolledPrograms.ffrProgram.programType = 'FFR';
            enrolledPrograms.ffrProgram.programInformation = GARP_BC_MyPrograms.getProgramInformation('FFR', NULL);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','ffrProgram',enrolledPrograms.ffrProgram);
        }

        // Micro Courses
        enrolledPrograms.microCourseConfig = GARP_BC_Courses.getMicroCourseConfig();
        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','microCourseConfig',enrolledPrograms.microCourseConfig);

        for(GARP_BC_Courses.microCourseInfo mci :enrolledPrograms.microCourseConfig.mapMicroCourseByCode.Values()) {
            GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','microCouse',mci.courseCode);

            Contract mcContract = mapContracts.get(mci.programRecordTypeAPIName);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','mcContract',mcContract);

            Exam_Attempt__c mcExamAttempt = enrolledPrograms.mapLatestExamAttempts.get(mci.courseCode + 'Full');
            GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','mcExamAttempt',mcExamAttempt);

            if(mcContract != NULL && mcContract.Status != 'Completed' && mcExamAttempt != NULL) {

                enrolledProgramInfo mcProgram = new enrolledProgramInfo();
                mcProgram.programType = mci.courseCode;
                mcProgram.programInformation = GARP_BC_MyPrograms.getProgramInformation(mci.courseCode, mci);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','add micro course',mcProgram);

                enrolledPrograms.microCoursesMap.put(mci.courseCode, mcProgram);
            }
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getEnrolledPrograms','enrolledPrograms',enrolledPrograms);

        return enrolledPrograms;
    }

    // FRR, FFR Course Details
    public class courseDetailInfo {
        public String programState; // Unpaid, Enrolled, AwaitingResults??, ResultsAvailable, Expired, Completed

        // General Info
        public String programType;
        public Date programRegisteredOnDate;
        public Date programExpireDate;
        public String examAttemptId;

        // Unpaid Info
        public String paymentStatus;
        public String unpaidOrderId;

        // Study Materials
        public String eBookKey;
        public String eBookAccessURL;
        public Date eBookExpireDate;

        public String eLearningPlatformName;
        public String eLearningPlatformAccessURL;
        public Date eLearningPlatformExpiresOnDate;

        // Exam Scheduling Info
        public String onlineExamProviderName;
        public String onlineExamSchedulingID;
        public String onlineExamSchedulingInformationPageURL;
        public String OnlineExamSchedulingAccessURL;
        public Date OnlineExamSchedulingExpiresOn;

        public String scheduledExamMode;
        public DateTime scheduledExamDateTime;
        public String scheduledExamDateTimeZone;
        public String scheduledExamLocation;
        public  Boolean showTakeExam;

        // Exam Result Info
        public Date examTakenDate;
        public String examResult;

        public Boolean examRetakeAvailable;
        public Date examRetakeAvailableDate;

        // Certificate Info
        public String downloadCertificateURL;

        // Micro Course Info
        public GARP_BC_Courses.microCourseInfo microCourseInfo;

        // Program Info
        public programInformation programInformation;
    }

    public class returnCourseInfo {
        public String statusMessage;
        public Integer statusCode;
        public courseDetailInfo courseDetailInfo;
    }

    public static returnCourseInfo getCourseProgramDetailInfo(Contact contact, String programType, MAP<String,Contract> mapContracts){
        GARP_Common.debugLog('GARP_BC_MyPrograms','getCourseProgramDetailInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getCourseProgramDetailInfo','programType',programType);

        returnCourseInfo returnCourseInfo = new returnCourseInfo();
        returnCourseInfo.courseDetailInfo = new courseDetailInfo();

        Date tdy = Date.Today();

        if(contact != NULL) {

            GARP_BC_Courses.microCourseConfig microCourseConfig = GARP_BC_Courses.getMicroCourseConfig();

            // Collect Program Info
            Contract programContract;
            String accessRootURL;

            GARP_BC_Courses.microCourseInfo microCourseInfo;

            if(programType == 'FRR') {
                programContract = mapContracts.get('ICBRR_Program');
                accessRootURL = System.Label.GARP_Glose_FRR_Access_URL;
            } else if(programType == 'FRR25') {
                programContract = mapContracts.get('FRR25_Program');
                accessRootURL = System.Label.GARP_Glose_FFR_Access_URL;
            } else if(programType == 'FFR') {
                programContract = mapContracts.get('FBR_Program');
                accessRootURL = System.Label.GARP_Glose_FFR_Access_URL;
            } else {

                // Micro Course
                for(GARP_BC_Courses.microCourseInfo mci :microCourseConfig.mapMicroCourseByCode.Values()) {
                    if(mci.courseCode == programType) {
                        microCourseInfo = mci;
                        programContract = mapContracts.get(mci.programRecordTypeAPIName);
                        returnCourseInfo.courseDetailInfo.microCourseInfo = mci;
                        break;
                    }
                }

                if(microCourseInfo == NULL) {
                    returnCourseInfo.statusMessage = 'Invalid Course Type';
                    returnCourseInfo.statusCode = 501;
                    return returnCourseInfo;
                }
            }

            if(programContract == NULL) {
                returnCourseInfo.statusMessage = 'Contract not found';
                returnCourseInfo.statusCode = 401;
                return returnCourseInfo;
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getCourseProgramDetailInfo','programContract',programContract);

            // Get General Info
            returnCourseInfo.courseDetailInfo.programType = programType;
            returnCourseInfo.courseDetailInfo.programRegisteredOnDate = programContract.StartDate;
            returnCourseInfo.courseDetailInfo.programExpireDate = programContract.EndDate;

            returnCourseInfo.courseDetailInfo.paymentStatus = 'Paid';
            returnCourseInfo.courseDetailInfo.showTakeExam = False;

            returnCourseInfo.courseDetailInfo.programInformation = getProgramInformation(programType, microCourseInfo);

            // Unpaid
            if(programContract.Status == 'Draft' && programContract.Opportunity__r.StageName == 'New Lead') {
                returnCourseInfo.courseDetailInfo.programState = 'Unpaid';
                returnCourseInfo.courseDetailInfo.unpaidOrderId = programContract.Opportunity__c;
                returnCourseInfo.courseDetailInfo.paymentStatus = 'Unpaid';

            } else if(programContract.Status == 'Completed' ) {
                returnCourseInfo.courseDetailInfo.programState = 'Completed';
                if(programType == 'FRR') {
                    returnCourseInfo.courseDetailInfo.downloadCertificateURL = '/FrrCertificate?id=' + contact.Id;
                } else if(programType == 'FRR25') {
                    returnCourseInfo.courseDetailInfo.downloadCertificateURL = '/Frr25Certificate?id=' + contact.Id;
                } else {
                    // Micro Course
                    for(GARP_BC_Courses.microCourseInfo mci :microCourseConfig.mapMicroCourseByCode.Values()) {
                        if(mci.courseCode == programType) {
                            returnCourseInfo.courseDetailInfo.downloadCertificateURL = '/MicroCourseCertificate?id=' + contact.Id + '&type=' + mci.courseCode;
                            break;
                        }
                    }
                }

            } else if(programContract.Status == 'Expired' ) {
                returnCourseInfo.courseDetailInfo.programState = 'Expired';

            } else {

                returnCourseInfo.courseDetailInfo.programState = 'Enrolled';

                // Study Materials

                // eBook
                List<GARP_BC_StudyMaterials.eBook> myEBooks = GARP_BC_StudyMaterials.getMyEBooks(contact.accountId, NULL);
                if(!myEBooks.IsEmpty()) {
                    GARP_BC_StudyMaterials.eBook myEBook = GARP_BC_StudyMaterials.getMostRecentEBook(contact, programType, NULL, myEBooks);
                    if(myEBook != NULL) {
                        returnCourseInfo.courseDetailInfo.eBookKey=myEBook.key;
                        returnCourseInfo.courseDetailInfo.eBookAccessURL=accessRootURL + myEBook.key;
                        returnCourseInfo.courseDetailInfo.eBookExpireDate=programContract.EndDate;
                    }
                }

                GARP_Common.debugLog('GARP_BC_MyPrograms','getCourseProgramDetailInfo','programType',programType);
                
                if(programType == 'FFR') {

                    // eLearning
                    returnCourseInfo.courseDetailInfo.eLearningPlatformName = 'We Know Training (WKT)';
                    returnCourseInfo.courseDetailInfo.eLearningPlatformAccessURL = '/idp/login?app=' + System.Label.GARP_WKT_FRRFFR_SSO_ID;
                    returnCourseInfo.courseDetailInfo.eLearningPlatformExpiresOnDate = programContract.EndDate;

                } else if(programType == 'FRR') {

                    // Get Exam Attempt
                    Exam_Attempt__c examAttempt;
                    returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contact.Id);
                    MAP<String,Exam_Attempt__c> latestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;

                    if(!latestExamAttempts.IsEmpty()) {
                        examAttempt = latestExamAttempts.get('FRRFull');
                    }

                    if(examAttempt != NULL) {
                        returnCourseInfo.courseDetailInfo.examAttemptId = examAttempt.Id;

                        // eLearning
                        returnCourseInfo.courseDetailInfo.eLearningPlatformName = 'We Know Training (WKT)';
                        returnCourseInfo.courseDetailInfo.eLearningPlatformAccessURL = '/idp/login?app=' + System.Label.GARP_WKT_FRRFFR_SSO_ID;
                        returnCourseInfo.courseDetailInfo.eLearningPlatformExpiresOnDate = programContract.EndDate;

                        // Exam Result
                        if(examAttempt.Result__c != NULL) {
                            returnCourseInfo.courseDetailInfo.programState = 'ResultsAvailable';
                            returnCourseInfo.courseDetailInfo.examResult = examAttempt.Result__c;
                            returnCourseInfo.courseDetailInfo.examTakenDate = examAttempt.Icbrr_Exam_Date__c;

                            // Retake
                            if(examAttempt.Result__c != 'Pass') {
                                returnCourseInfo.courseDetailInfo.examRetakeAvailableDate = examAttempt.Icbrr_Exam_Date__c.AddDays(30);
                                returnCourseInfo.courseDetailInfo.examRetakeAvailable = (tdy >= returnCourseInfo.courseDetailInfo.examRetakeAvailableDate);

                                // Find open order for Fail or Retake
                                Set<String> productCodes = new Set<String>{'CBR2A'};
                                Opportunity latestOpenOpp = GARP_BC_Orders.getLatestOppWithGivenProducts(contact.accountID, productCodes, 'New Lead', NULL);
                                if(latestOpenOpp != NULL) {
                                    returnCourseInfo.courseDetailInfo.unpaidOrderId = latestOpenOpp.Id;
                                }
                            }
                        } else {
                            returnCourseInfo.courseDetailInfo.onlineExamProviderName = 'Pearson';
                            returnCourseInfo.courseDetailInfo.onlineExamSchedulingID = contact.GARP_Member_ID__c;
                            returnCourseInfo.courseDetailInfo.onlineExamSchedulingInformationPageURL = '/FRR_Authorization_Letter?id=' + examAttempt.Id;
                            returnCourseInfo.courseDetailInfo.OnlineExamSchedulingAccessURL = '/PearsonVue_SSO?id=' + examAttempt.Id;
                            returnCourseInfo.courseDetailInfo.OnlineExamSchedulingExpiresOn = programContract.EndDate;

                            if(examAttempt.Integration_Data_Exam_Scheduled_Date__c != NULL) {
                                returnCourseInfo.courseDetailInfo.scheduledExamMode = examAttempt.Integration_Data_Exam_Mode__c;
                                returnCourseInfo.courseDetailInfo.scheduledExamDateTime = examAttempt.Integration_Data_Exam_Scheduled_Date__c;
                                returnCourseInfo.courseDetailInfo.scheduledExamDateTimeZone = examAttempt.Integration_Data_Exam_Scheduled_TimeZone__c;

                                if(examAttempt.Integration_Data_Exam_Mode__c == 'CBT') {
                                    returnCourseInfo.courseDetailInfo.scheduledExamLocation = examAttempt.Integration_Data_Exam_Location__c;
                                }
                            }

                            if(examAttempt.RPT_Exam_Delivered__c) {
                                returnCourseInfo.courseDetailInfo.programState = 'AwaitingResults';
                            }
                        }

                    } else {
                        returnCourseInfo.statusMessage = 'Exam Attempt not found';
                        returnCourseInfo.statusCode = 401;
                        return returnCourseInfo;
                    }

                } else if(programType == 'FRR25') {

                    // Get Exam Attempt
                    Exam_Attempt__c examAttempt;
                    returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contact.Id);
                    MAP<String,Exam_Attempt__c> latestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;

                    if(!latestExamAttempts.IsEmpty()) {
                        examAttempt = latestExamAttempts.get('FRR25Full');
                    }
                    
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getCourseProgramDetailInfo','examAttempt',examAttempt);

                    if(examAttempt != NULL) {
                        returnCourseInfo.courseDetailInfo.examAttemptId = examAttempt.Id;

                        // eLearning
                        returnCourseInfo.courseDetailInfo.eLearningPlatformName = 'BenchPrep';
                        returnCourseInfo.courseDetailInfo.eLearningPlatformAccessURL = GARP_BC_StudyMaterials.getBenchPrepSSOLink(contact.Id,'FRR25','Full');
                        returnCourseInfo.courseDetailInfo.eLearningPlatformExpiresOnDate = programContract.EndDate;

                        // Exam Result
                        if(examAttempt.Result__c != NULL) {
                            returnCourseInfo.courseDetailInfo.programState = 'ResultsAvailable';
                            returnCourseInfo.courseDetailInfo.examResult = examAttempt.Result__c;
                            returnCourseInfo.courseDetailInfo.examTakenDate = examAttempt.Icbrr_Exam_Date__c;

                            // Retake
                            if(examAttempt.Result__c != 'Pass') {
                                //returnCourseInfo.courseDetailInfo.examRetakeAvailableDate = examAttempt.Icbrr_Exam_Date__c.AddDays(30);
                                returnCourseInfo.courseDetailInfo.examRetakeAvailable = TRUE;

                                // Find open order for Fail or Retake
                                Set<String> productCodes = new Set<String>{'FRR252A'};
                                Opportunity latestOpenOpp = GARP_BC_Orders.getLatestOppWithGivenProducts(contact.accountID, productCodes, 'New Lead', NULL);
                                if(latestOpenOpp != NULL) {
                                    returnCourseInfo.courseDetailInfo.unpaidOrderId = latestOpenOpp.Id;
                                }
                            }
                        } else {
                            returnCourseInfo.courseDetailInfo.onlineExamProviderName = 'Pearson';
                            returnCourseInfo.courseDetailInfo.onlineExamSchedulingID = contact.GARP_Member_ID__c;
                            returnCourseInfo.courseDetailInfo.onlineExamSchedulingInformationPageURL = '/FRR25_Authorization_Letter?id=' + examAttempt.Id;
                            returnCourseInfo.courseDetailInfo.OnlineExamSchedulingAccessURL = '/PearsonVue_SSO?id=' + examAttempt.Id;
                            returnCourseInfo.courseDetailInfo.OnlineExamSchedulingExpiresOn = programContract.EndDate;

                            GARP_Common.debugLog('GARP_BC_MyPrograms','getCourseProgramDetailInfo','Integration_Data_Exam_Scheduled_Date__c',examAttempt.Integration_Data_Exam_Scheduled_Date__c);
                            
                            if(examAttempt.Integration_Data_Exam_Scheduled_Date__c != NULL) {
                                returnCourseInfo.courseDetailInfo.scheduledExamMode = examAttempt.Integration_Data_Exam_Mode__c;
                                returnCourseInfo.courseDetailInfo.scheduledExamDateTime = examAttempt.Integration_Data_Exam_Scheduled_Date__c;
                                returnCourseInfo.courseDetailInfo.scheduledExamDateTimeZone = examAttempt.Integration_Data_Exam_Scheduled_TimeZone__c;

                                if(examAttempt.Integration_Data_Exam_Mode__c == 'CBT') {
                                    returnCourseInfo.courseDetailInfo.scheduledExamLocation = examAttempt.Integration_Data_Exam_Location__c;
                                }
                                
                                GARP_Common.debugLog('GARP_BC_MyPrograms','getCourseProgramDetailInfo','tdy',tdy);
                                
                                if(examAttempt.Integration_Data_Exam_Mode__c == 'Remote' && tdy >= examAttempt.Integration_Data_Exam_Scheduled_Date__c.AddDays(-2) && tdy <= examAttempt.Integration_Data_Exam_Scheduled_Date__c.AddDays(2)) {
                                    returnCourseInfo.courseDetailInfo.showTakeExam = True;
                                }
                            }

                            if(examAttempt.RPT_Exam_Delivered__c) {
                                returnCourseInfo.courseDetailInfo.programState = 'AwaitingResults';
                            }

                        }

                    } else {
                        returnCourseInfo.statusMessage = 'Exam Attempt not found';
                        returnCourseInfo.statusCode = 401;
                        return returnCourseInfo;
                    }
                } else {
                    // Micro Courses
                    for(GARP_BC_Courses.microCourseInfo mci :microCourseConfig.mapMicroCourseByCode.Values()) {
                        if(mci.courseCode == programType) {

                            // Get Exam Attempt
                            Exam_Attempt__c examAttempt;
                            returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contact.Id);
                            MAP<String,Exam_Attempt__c> latestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;

                            if(!latestExamAttempts.IsEmpty()) {
                                examAttempt = latestExamAttempts.get(mci.courseCode + 'Full');
                            }

                            if(examAttempt != NULL) {
                                returnCourseInfo.courseDetailInfo.examAttemptId = examAttempt.Id;

                                // eLearning
                                returnCourseInfo.courseDetailInfo.eLearningPlatformName = 'BenchPrep';
                                returnCourseInfo.courseDetailInfo.eLearningPlatformAccessURL = System.Label.BenchBrepSSOLink;
                                returnCourseInfo.courseDetailInfo.eLearningPlatformExpiresOnDate = programContract.EndDate;

                                // Exam Result
                                if(examAttempt.Result__c != NULL) {
                                    returnCourseInfo.courseDetailInfo.programState = 'ResultsAvailable';
                                    returnCourseInfo.courseDetailInfo.examResult = examAttempt.Result__c;
                                    returnCourseInfo.courseDetailInfo.examTakenDate = examAttempt.Icbrr_Exam_Date__c;

                                    // Retake
                                    if(examAttempt.Result__c != 'Pass') {
                                        //returnCourseInfo.courseDetailInfo.examRetakeAvailableDate = examAttempt.Icbrr_Exam_Date__c.AddDays(30);
                                        returnCourseInfo.courseDetailInfo.examRetakeAvailable = TRUE;

                                        // Find open order for Fail or Retake
                                        Set<String> productCodes = new Set<String>();
                                        productCodes.add(mci.retakeProductCode);

                                        Opportunity latestOpenOpp = GARP_BC_Orders.getLatestOppWithGivenProducts(contact.accountID, productCodes, 'New Lead', NULL);
                                        if(latestOpenOpp != NULL) {
                                            returnCourseInfo.courseDetailInfo.unpaidOrderId = latestOpenOpp.Id;
                                        }
                                    }
                                } else {
                                    returnCourseInfo.courseDetailInfo.onlineExamProviderName = 'Pearson';
                                    returnCourseInfo.courseDetailInfo.onlineExamSchedulingID = contact.GARP_Member_ID__c;
                                    returnCourseInfo.courseDetailInfo.onlineExamSchedulingInformationPageURL = '/MicroCourse_Authorization_Letter?id=' + examAttempt.Id + '&type=' + mci.courseCode;
                                    returnCourseInfo.courseDetailInfo.OnlineExamSchedulingAccessURL = '/PearsonVue_SSO?id=' + examAttempt.Id;
                                    returnCourseInfo.courseDetailInfo.OnlineExamSchedulingExpiresOn = programContract.EndDate;

                                    if(examAttempt.Integration_Data_Exam_Scheduled_Date__c != NULL) {
                                        returnCourseInfo.courseDetailInfo.scheduledExamMode = examAttempt.Integration_Data_Exam_Mode__c;
                                        returnCourseInfo.courseDetailInfo.scheduledExamDateTime = examAttempt.Integration_Data_Exam_Scheduled_Date__c;
                                        returnCourseInfo.courseDetailInfo.scheduledExamDateTimeZone = examAttempt.Integration_Data_Exam_Scheduled_TimeZone__c;

                                        if(examAttempt.Integration_Data_Exam_Mode__c == 'CBT') {
                                            returnCourseInfo.courseDetailInfo.scheduledExamLocation = examAttempt.Integration_Data_Exam_Location__c;
                                        }
                                        
                                        if(examAttempt.Integration_Data_Exam_Mode__c == 'Remote' && tdy >= examAttempt.Integration_Data_Exam_Scheduled_Date__c.AddDays(-1) && tdy <= examAttempt.Integration_Data_Exam_Scheduled_Date__c.AddDays(1)) {
                                            returnCourseInfo.courseDetailInfo.showTakeExam = True;
                                        }
                                    }

                                    if(examAttempt.RPT_Exam_Delivered__c) {
                                        returnCourseInfo.courseDetailInfo.programState = 'AwaitingResults';
                                    }

                                }

                            } else {
                                returnCourseInfo.statusMessage = 'Exam Attempt not found';
                                returnCourseInfo.statusCode = 401;
                                return returnCourseInfo;
                            }
                            break;
                        }
                    }
                }
            }

        } else {
            returnCourseInfo.statusMessage = 'Contact not found';
            returnCourseInfo.statusCode = 401;
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getCourseProgramDetailInfo','returnCourseInfo',returnCourseInfo);

        return returnCourseInfo;
    }

    public class returnProgramsDetailInfo {
        public String statusMessage;
        public Integer statusCode;
        public programsDetailInfo programsDetailInfo;
        public frmProgramProgessInfo frmProgramProgessInfo;
    }

    // Each step can be opened, in progress, completed
    public class frmProgramProgessInfo {
        public String enrollment;
        public String partIExam;
        public String partIIExam;
        public String workExperience;
        public String certified;
    }

    public class programsDetailInfo {
        public String statusMessage;
        public Integer statusCode;

        public String programState; // EnrollmentExpired, CVSubmission, ExamAttempt (FRM can be the first two, ExamAttempt is used for FRM, SCR, and RiskAI), Completed

        // General Info
        public String programType;
        public Date programCompletedDate;
        public String certificateDownloadURL;
        public String digitalBadgheURL;

        public Boolean isAnyPartSchedulingOpen;
        public Boolean isAnyPartDeferalOpen;
        public Boolean isAnyPartDeferred;

        // Program Info
        public programInformation programInformation;

        // Exam Part Info
        public examPartInfo examPart1Info;
        public examPartInfo examPart2Info;

        // Current Registration Info
        public Boolean currentRegistrationIsOpen;
        public String currentRegistrationAdminName;
        public Boolean currentRegistrationCanRegPartI;
        public Boolean currentRegistrationCanAddPartII;
        public String nextRegistrationAdminName;
        public Date nextRegistrationOpenDate;

        // For CV Info will make a different call
        public String cvStatus;

        // ID Info
        public String IDName;
        public String IDType;
        public String IDNumber;
        public String IDLocation;
        public Date IDExpireDate;

        public String phoneCode;
        public String phoneNumber;

        // OSTA Info
        public Boolean isOSTACandidate;
        public String OSTANameInChinese;
        public Date OSTADateOfBirth;
        public String OSTAGender;
        public String OSTAPhoneNumber;
        public String OSTAWorkingStatus;
        public String OSTACompany;
        public String OSTAEducationalStatus;
        public String OSTAEducationalSchool;
        public String OSTAEducationalProgram;

        public examResources examResources;
        public List<examDeadline> examDeadlines;
        public List<GARP_BC_Exams.examNotificationInfo> examNotifications;

    }

    public class examResources {

        // Study Materials
        public List<GARP_BC_StudyMaterials.eBookItem> eBookItems;
        public Date eBookExpireDate;
        public String eBookProviderName;
        //public String eBookAccessURL; to access call getMobuisEBookAccessURL(eBookItem.vendorId) from the font-end

        // BenchPrep
        public String eLearningPlatformAccessURL;
        public String eLearningPlatformName;

        // Resources
        public String ADAFormAccessURL; // If available show 'Download ADA Form'
        public Boolean IsOptedIntoEPP; // If False show 'Need Help Studying?'
    }

    public class examDeadline {
        public String examMonth;
        public String examYear;
        public Date ADADeadline;
        public Date deferalDeadline;
        public Date schedulingDeadline;
    }

    public class examPartInfo {
        Public String examPartState; // Unpaid, Deferred, AwaitingSchedulingToOpen, SchedulingOpen, SchedulingClosedAwaitingToTakeExam, SchedulingClosedAwaitingResults, SchedulingClosedNeverScheduled, SchedulingClosedResultsAvailable

        // General Info
        public String examAttemptAdminName;
        public String examAttemptId;
        public Date lastDateforADA;

        public String examFormat;

        // Unpaid Info
        public String unpaidOrderId;
        public Date unpaidOrderPayByDate;

        // Deferred Info
        public String deferredAdminName;
        public Date deferredExamSetupOpenDate;
        public String unpaidDeferralOrderId;
        public Boolean isDeferralOpen;

        // Scheduling Not open Yet
        public Date schedulingAwaitingToOpenOpenDate;

        // Scheduling Open
        public Boolean schedulingIsComplete;

        // Scheduling Info
        public Boolean isSchedulingOpen;
        public Date schedulingDeadline;
        public DateTime schedulingExamDateTimeSelected;
        public String schedulingExamDateTimeZoneSelected;
        public String schedulingExamLocationSelected;

        public String schedulingExamProviderName;
        public String schedulingExamAccessURL;
        public Boolean showTakeExam;

        // Waiting Results Info
        public DateTime resultsAvailableDateTime;
        public String resultsAvailableStatement;

        // Results Available Info
        public String result; // Pass, Fail, No-Show, Not Graded
        public Boolean isResultStale; // After a while the result is no longer relevent, used to hide the Part Cards on the front end
        
        public String badgeURL;
        public String badgePageURL;
    }

    // programType = FRM,SCR,RiskAI
    public static returnProgramsDetailInfo getMyProgramsDetailInfo(Contact contact, String programType, MAP<String,Contract> mapContracts, String loadKey){

        GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','programType',programType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','mapContracts',mapContracts);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','loadKey',loadKey);

        returnProgramsDetailInfo returnProgramsDetailInfo = new returnProgramsDetailInfo();
        returnProgramsDetailInfo.programsDetailInfo = new programsDetailInfo();
        returnProgramsDetailInfo.frmProgramProgessInfo = new frmProgramProgessInfo();

        Date tdy = Date.Today();

        if(contact != NULL) {

            returnProgramsDetailInfo.programsDetailInfo.programInformation = getProgramInformation(programType, NULL);

            // Get Current and Next Exam Admin Reg window Status
            GARP_BC_MyPrograms.currentNextExamAdminRegInfo currentNextExamAdminRegInfo = GARP_BC_MyPrograms.getCurrentNextExamAdminRegInfo(programType);

            if(currentNextExamAdminRegInfo != NULL) {
                returnProgramsDetailInfo.programsDetailInfo.currentRegistrationIsOpen = currentNextExamAdminRegInfo.isRegistrationOpen;
                if(returnProgramsDetailInfo.programsDetailInfo.currentRegistrationIsOpen) {
                    returnProgramsDetailInfo.programsDetailInfo.currentRegistrationAdminName = currentNextExamAdminRegInfo.currentExamAdminName;
                } else {
                    returnProgramsDetailInfo.programsDetailInfo.nextRegistrationAdminName = currentNextExamAdminRegInfo.nextExamAdminName;
                    returnProgramsDetailInfo.programsDetailInfo.nextRegistrationOpenDate = currentNextExamAdminRegInfo.nextExamAdminRegistrationOpenDate;
                }
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','returnProgramsDetailInfo Step 1',returnProgramsDetailInfo);

            // Compute Exam Attempt info
            returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contact.Id);
            MAP<String,Exam_Attempt__c> mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;

            Contract programContract;
            Boolean currentRegistrationCanAddPartII;
            Boolean currentRegistrationCanRegPartI;

            // Collect Exam Attempt Info
            Exam_Attempt__c examAttemptPart1;
            Exam_Attempt__c examAttemptPart2;

            String examPart = 'Full';
            if(programType == 'FRM' || programType == 'ERP') {
                examPart = 'I';
            }
            examAttemptPart1 = mapLatestExamAttempts.get(programType + examPart);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','examAttemptPart1',examAttemptPart1);

            if(programType == 'FRM' || programType == 'ERP') {
                examAttemptPart2 = mapLatestExamAttempts.get('FRMII');
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','examAttemptPart2',examAttemptPart2);
            }

            GARP_Common.checkAuthentication checkAuth = GARP_Common.checkAuthentication();
            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','checkAuth',checkAuth);

            GARP_BC_Membership.membershipInfo membershipInfo;
            if(checkAuth.isAuthenticated) {
                membershipInfo = GARP_BC_Membership.getMembershipInfo(checkAuth.user.contactId);
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','membershipInfo',membershipInfo);

            GARP_BC_Registration.RegistrationEligibility regElig = GARP_BC_Exams.isEligibleFRM(membershipInfo, loadKey);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','regElig',regElig);

            // Collect Program Info
            if(programType == 'FRM') {
                Contract frmContract = mapContracts.get('FRM_Program');
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','frmContract',frmContract);

                if(frmContract != NULL) {
                    // Expired State
                    if(frmContract.Status == 'Expired') {
                        returnProgramsDetailInfo.programsDetailInfo.programState = 'EnrollmentExpired';
                    } else {
                        // CV State
                        if(!frmContract.Candidate_Requirements__r.IsEmpty()) {
                            Boolean passPart1 = FALSE;
                            Boolean passPart2 = FALSE;
                            for(Candidate_Requirement__c cr :frmContract.Candidate_Requirements__r) {
                                if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'FRM Part I' && cr.Status__c == 'Completed') {
                                    passPart1 = TRUE;
                                }
                                if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'FRM Part II' && cr.Status__c == 'Completed') {
                                    passPart2 = TRUE;
                                }
                                if(cr.recordType.DeveloperName == 'Job_Experience') {
                                    returnProgramsDetailInfo.programsDetailInfo.cvStatus = cr.Status__c;
                                }
                            }
                            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','passPart1',passPart1);
                            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','passPart2',passPart2);

                            // Get Exam Attempt for isLoading Check
                            Boolean isLoadingPart1 = False;
                            if(examAttemptPart1 != NULL) {
                                isLoadingPart1 = isLoadingResults(examAttemptPart1.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
                            }
                            Boolean isLoadingPart2 = False;
                            if(examAttemptPart2 != NULL) {
                                isLoadingPart2 = isLoadingResults(examAttemptPart2.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
                            }

                            if(passPart1 && passPart2 && !isLoadingPart1 && !isLoadingPart2) {
                            //if(passPart1 && passPart2) {
                                returnProgramsDetailInfo.programsDetailInfo.programState = 'CVSubmission';
                            }

                        } else {
                            returnProgramsDetailInfo.statusMessage = 'Program Requirements Missing';
                            returnProgramsDetailInfo.statusCode = 502;
                            return returnProgramsDetailInfo;
                        }
                    }

                } else {
                    returnProgramsDetailInfo.statusMessage = 'Contract not found';
                    returnProgramsDetailInfo.statusCode = 401;
                    return returnProgramsDetailInfo;
                }

                programContract = frmContract;

                returnProgramsDetailInfo.programsDetailInfo.programType = 'FRM';
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','FRM returnProgramsDetailInfo Step 2',returnProgramsDetailInfo);

                // Can Add Part II
                currentRegistrationCanAddPartII = False;
                currentRegistrationCanRegPartI = False;
                for(String eilgExam :regElig.eligibleExams) {
                    if(eilgExam == 'FRM Part 1') {
                        currentRegistrationCanRegPartI = True;
                    }
                    if(eilgExam == 'FRM Part 2') {
                        currentRegistrationCanAddPartII = True;
                    }
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','canRegPartI',currentRegistrationCanRegPartI);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','canAddPartII',currentRegistrationCanAddPartII);

            } else if(programType == 'ERP') {
                Contract erpContract = mapContracts.get('ERP_Program');
                if(erpContract != NULL) {
                    // Expired State
                    if(erpContract.Status == 'Expired') {
                        returnProgramsDetailInfo.programsDetailInfo.programState = 'EnrollmentExpired';
                    } else {
                        // CV State
                        if(!erpContract.Candidate_Requirements__r.IsEmpty()) {
                            Boolean passPart1 = FALSE;
                            Boolean passPart2 = FALSE;
                            for(Candidate_Requirement__c cr :erpContract.Candidate_Requirements__r) {
                                if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'ERP Part I' && cr.Status__c == 'Completed') {
                                    passPart1 = TRUE;
                                }
                                if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'ERP Part II' && cr.Status__c == 'Completed') {
                                    passPart2 = TRUE;
                                }
                                if(cr.recordType.DeveloperName == 'Job_Experience') {
                                    returnProgramsDetailInfo.programsDetailInfo.cvStatus = cr.Status__c;
                                }
                            }
                            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','passPart1',passPart1);
                            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','passPart2',passPart2);

                            if(passPart1 && passPart2) {
                                returnProgramsDetailInfo.programsDetailInfo.programState = 'CVSubmission';
                            }

                        } else {
                            returnProgramsDetailInfo.statusMessage = 'Program Requirements Missing';
                            returnProgramsDetailInfo.statusCode = 502;
                            return returnProgramsDetailInfo;
                        }
                    }

                    // Can Add Part II
                    currentRegistrationCanAddPartII = False;
                    currentRegistrationCanRegPartI = False;

                    programContract = erpContract;
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','ERP programContract',programContract);
                    returnProgramsDetailInfo.programsDetailInfo.programType = 'ERP';

                } else {
                    returnProgramsDetailInfo.statusMessage = 'Contract not found';
                    returnProgramsDetailInfo.statusCode = 401;
                    return returnProgramsDetailInfo;
                }

            } else if(programType == 'SCR') {
                programContract = mapContracts.get('SCR_Program');
                returnProgramsDetailInfo.programsDetailInfo.programType = 'SCR';

                if(isLoadingResults(examAttemptPart1.Exam_Administration__r.Exam_Results_Loading__c, loadKey) && programContract.Status == 'Completed') {
                    programContract.Status = 'Activated';
                }

                currentRegistrationCanRegPartI = False;
                for(String eilgExam :regElig.eligibleExams) {
                    if(eilgExam == 'SCR') {
                        currentRegistrationCanRegPartI = True;
                    }
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','canRegPartI',currentRegistrationCanRegPartI);

            } else if(programType == 'RAIJ') {
                programContract = mapContracts.get('RAIJ_Program');
                returnProgramsDetailInfo.programsDetailInfo.programType = 'RAIJ';

                if(isLoadingResults(examAttemptPart1.Exam_Administration__r.Exam_Results_Loading__c, loadKey) && programContract.Status == 'Completed') {
                    programContract.Status = 'Activated';
                }

                currentRegistrationCanRegPartI = False;
                for(String eilgExam :regElig.eligibleExams) {
                    if(eilgExam == 'RAIJ') {
                        currentRegistrationCanRegPartI = True;
                    }
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','canRegPartI',currentRegistrationCanRegPartI);

            } else if(programType == 'RiskAI') {
                programContract = mapContracts.get('Risk_AI_Program');
                returnProgramsDetailInfo.programsDetailInfo.programType = 'RiskAI';

                if(isLoadingResults(examAttemptPart1.Exam_Administration__r.Exam_Results_Loading__c, loadKey) && programContract.Status == 'Completed') {
                    programContract.Status = 'Activated';
                }

                currentRegistrationCanRegPartI = False;
                for(String eilgExam :regElig.eligibleExams) {
                    if(eilgExam == 'RiskAI') {
                        currentRegistrationCanRegPartI = True;
                    }
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','canRegPartI',currentRegistrationCanRegPartI);

            } else {
                returnProgramsDetailInfo.statusMessage = 'Invalid Program Type';
                returnProgramsDetailInfo.statusCode = 501;
                return returnProgramsDetailInfo;
            }

            if(programContract == NULL) {
                returnProgramsDetailInfo.statusMessage = 'Contract not found';
                returnProgramsDetailInfo.statusCode = 401;
                return returnProgramsDetailInfo;
            }

            if(programContract.Status == 'Completed') {
                returnProgramsDetailInfo.programsDetailInfo.programState = 'Completed';
                returnProgramsDetailInfo.programsDetailInfo.programCompletedDate = programContract.All_Requirements_Completed_Date__c;
                if(programType == 'FRM') {
                    returnProgramsDetailInfo.programsDetailInfo.digitalBadgheURL = 'https://my.garp.org/DigitalBadgeFRM?id=' + contact.Id;
                } else if(programType == 'ERP') {
                    returnProgramsDetailInfo.programsDetailInfo.digitalBadgheURL = 'https://my.garp.org/DigitalBadgeERP?id=' + contact.Id;
                } else if(programType == 'SCR') {
                    returnProgramsDetailInfo.programsDetailInfo.certificateDownloadURL = '/SCRCertificate?id=' + contact.Id;
                    returnProgramsDetailInfo.programsDetailInfo.digitalBadgheURL = 'https://my.garp.org/DigitalBadgeSCR?id=' + contact.Id;
                } else if(programType == 'RAIJ') {
                    returnProgramsDetailInfo.programsDetailInfo.certificateDownloadURL = '/RAIJCertificate?id=' + contact.Id;
                    returnProgramsDetailInfo.programsDetailInfo.digitalBadgheURL = 'https://my.garp.org/DigitalBadgeRAIJ?id=' + contact.Id;
                } else if(programType == 'RiskAI') {
                    returnProgramsDetailInfo.programsDetailInfo.certificateDownloadURL = '/RAICertificate?id=' + contact.Id;
                    returnProgramsDetailInfo.programsDetailInfo.digitalBadgheURL = 'https://my.garp.org/DigitalBadgeRAI?id=' + contact.Id;
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','returnProgramsDetailInfo',returnProgramsDetailInfo);
                return returnProgramsDetailInfo;
            }

            Boolean isOSTA = False;
            Boolean hasBenchPrepAccess = False;
            Boolean showADADownload = False;

            returnGetExamPartInfo retPartInfo1;
            returnGetExamPartInfo retPartInfo2;

            // Get any notifications
            returnProgramsDetailInfo.programsDetailInfo.examNotifications = GARP_BC_Exams.getExamMemberNotifications(contact.Id, programType);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','examNotifications',returnProgramsDetailInfo.programsDetailInfo.examNotifications);

            // Not FRM States (above)
            if(returnProgramsDetailInfo.programsDetailInfo.programState == NULL || returnProgramsDetailInfo.programsDetailInfo.programState != 'EnrollmentExpired') {

                if(returnProgramsDetailInfo.programsDetailInfo.programState == NULL) {
                    returnProgramsDetailInfo.programsDetailInfo.programState = 'ExamAttempt';
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','programState',returnProgramsDetailInfo.programsDetailInfo.programState);

                if(examAttemptPart1 != NULL) {
                    retPartInfo1 = getExamPartInfo(contact, programType, examPart, programContract, mapLatestExamAttempts, loadKey);
                    if(retPartInfo1.statusCode != 200) {
                        returnProgramsDetailInfo.statusMessage = retPartInfo1.statusMessage;
                        returnProgramsDetailInfo.statusCode = retPartInfo1.statusCode;
                        GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','retPartInfo1 error',retPartInfo1);
                        return returnProgramsDetailInfo;

                    } else {
                        returnProgramsDetailInfo.programsDetailInfo.examPart1Info = new examPartInfo();
                        returnProgramsDetailInfo.programsDetailInfo.examPart1Info = retPartInfo1.examPartInfo;

                        returnProgramsDetailInfo.programsDetailInfo.currentRegistrationCanRegPartI = currentRegistrationCanRegPartI;

                        if(retPartInfo1.examPartInfo.examPartState == 'AwaitingSchedulingToOpen' || retPartInfo1.examPartInfo.examPartState == 'SchedulingOpen' ||
                           retPartInfo1.examPartInfo.examPartState == 'SchedulingClosedAwaitingResults' || retPartInfo1.examPartInfo.examPartState == 'SchedulingClosedAwaitingToTakeExam' || retPartInfo1.examPartInfo.examPartState == 'SchedulingClosedResultsAvailable') {
                               isOSTA = examAttemptPart1.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c;
                           }

                        //if(retPartInfo1.examPartInfo.examPartState == 'Deferred' || retPartInfo1.examPartInfo.examPartState == 'AwaitingSchedulingToOpen' || retPartInfo1.examPartInfo.examPartState == 'SchedulingOpen' ||
                        //   retPartInfo1.examPartInfo.examPartState == 'SchedulingClosedAwaitingToTakeExam' || (retPartInfo1.examPartInfo.examPartState == 'SchedulingClosedAwaitingResults' && tdy <= retPartInfo1.examDatesInfo.lastTestingDate.addDays(1))) {
                        //    hasBenchPrepAccess = True;
                        //}
                        hasBenchPrepAccess = GARP_BC_StudyMaterials.hasBenchPrepAccess(examAttemptPart1);
                        GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','hasBenchPrepAccess',hasBenchPrepAccess);

                        if(retPartInfo1.examPartInfo.lastDateforADA != NULL && tdy <= retPartInfo1.examPartInfo.lastDateforADA) {
                            showADADownload = True;
                        }
                        GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','showADADownload',showADADownload);
                    }
                }

                if(programType == 'FRM') {
                    if(examAttemptPart2 != NULL) {
                        retPartInfo2 = getExamPartInfo(contact, programType, 'II', programContract, mapLatestExamAttempts, loadKey);
                        if(retPartInfo2.statusCode != 200) {
                            returnProgramsDetailInfo.statusMessage = retPartInfo2.statusMessage;
                            returnProgramsDetailInfo.statusCode = retPartInfo2.statusCode;
                            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','retPartInfo2 error',retPartInfo2);

                            return returnProgramsDetailInfo;
                        } else {
                            returnProgramsDetailInfo.programsDetailInfo.examPart2Info = new examPartInfo();
                            returnProgramsDetailInfo.programsDetailInfo.examPart2Info = retPartInfo2.examPartInfo;

                            // Hide Cards if needed
                            examPartInfo examPart1Info = returnProgramsDetailInfo.programsDetailInfo.examPart1Info;
                            examPartInfo examPart2Info = returnProgramsDetailInfo.programsDetailInfo.examPart2Info;

                            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','examPart1Info',examPart1Info);
                            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','examPart2Info',examPart2Info);

                            if(!isOSTA && (retPartInfo2.examPartInfo.examPartState == 'AwaitingSchedulingToOpen' || retPartInfo2.examPartInfo.examPartState == 'SchedulingOpen' ||
                                           retPartInfo2.examPartInfo.examPartState == 'SchedulingClosedAwaitingResults' || retPartInfo2.examPartInfo.examPartState == 'SchedulingClosedAwaitingToTakeExam' || retPartInfo2.examPartInfo.examPartState == 'SchedulingClosedResultsAvailable')) {
                                               isOSTA = examAttemptPart2.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c;
                                           }

                            //if(retPartInfo2.examPartInfo.examPartState == 'Deferred' || retPartInfo2.examPartInfo.examPartState == 'AwaitingSchedulingToOpen' || retPartInfo2.examPartInfo.examPartState == 'SchedulingOpen' ||
                            //   retPartInfo2.examPartInfo.examPartState == 'SchedulingClosedAwaitingToTakeExam' || (retPartInfo2.examPartInfo.examPartState == 'SchedulingClosedAwaitingResults' && tdy <= retPartInfo2.examDatesInfo.lastTestingDate.addDays(1))) {
                            //    hasBenchPrepAccess = True;
                            //}

                            // If already has Access no need to check, and dont want to take it away if part II does not have
                            if(hasBenchPrepAccess == False) {
                                hasBenchPrepAccess = GARP_BC_StudyMaterials.hasBenchPrepAccess(examAttemptPart2);
                                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','hasBenchPrepAccess',hasBenchPrepAccess);
                            }

                            if(retPartInfo2.examPartInfo.lastDateforADA != NULL && tdy <= retPartInfo2.examPartInfo.lastDateforADA) {
                                showADADownload = True;
                            }

                            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','examPartInfo final 2',retPartInfo2.examPartInfo);
                        }
                    } else {
                         retPartInfo1.examPartInfo.isResultStale = False;
                        returnProgramsDetailInfo.programsDetailInfo.examPart1Info = retPartInfo1.examPartInfo;
                    }

                    if(retPartInfo1 != NULL && retPartInfo1.examPartInfo != NULL) {
                        returnProgramsDetailInfo.programsDetailInfo.currentRegistrationCanAddPartII = False;
                        if((retPartInfo1.examPartInfo.examPartState == 'AwaitingSchedulingToOpen' || retPartInfo1.examPartInfo.examPartState == 'SchedulingOpen') && (retPartInfo2 == NULL || (retPartInfo2 != NULL && retPartInfo2.examPartInfo != NULL && retPartInfo2.examPartInfo.examPartState == 'SchedulingClosedResultsAvailable'))) {
                            returnProgramsDetailInfo.programsDetailInfo.currentRegistrationCanAddPartII = currentRegistrationCanAddPartII;
                        }
                    }
                }
            }

            // Get Name on ID
            String idName = getNameOnID(contact, programType);

            // Get ID Information
            returnProgramsDetailInfo.programsDetailInfo.IDName = idName;
            returnProgramsDetailInfo.programsDetailInfo.IDType = contact.ID_Type__c;
            returnProgramsDetailInfo.programsDetailInfo.IDNumber = contact.ID_Number__c;
            returnProgramsDetailInfo.programsDetailInfo.IDLocation = contact.OSTA_ID_Location__c;
            returnProgramsDetailInfo.programsDetailInfo.IDExpireDate = contact.ID_Expiration_Date__c;

            returnProgramsDetailInfo.programsDetailInfo.phoneCode = contact.Mobile_Phone_Code__c;
            returnProgramsDetailInfo.programsDetailInfo.phoneNumber = contact.MobilePhone;

            // Get OSTA Information
            returnProgramsDetailInfo.programsDetailInfo.isOSTACandidate = False;
            if(isOSTA) {
                returnProgramsDetailInfo.programsDetailInfo.isOSTACandidate = True;
                returnProgramsDetailInfo.programsDetailInfo.OSTANameInChinese = contact.Full_Name_in_Chinese__c;
                returnProgramsDetailInfo.programsDetailInfo.OSTADateOfBirth = contact.Birthdate;
                returnProgramsDetailInfo.programsDetailInfo.OSTAGender = contact.Gender__c;
                if(contact.HomePhone != NULL) {
                    returnProgramsDetailInfo.programsDetailInfo.OSTAPhoneNumber = contact.HomePhone;
                } else if(contact.OtherPhone != NULL) {
                    returnProgramsDetailInfo.programsDetailInfo.OSTAPhoneNumber = contact.OtherPhone;
                } else if(contact.Phone != NULL) {
                    returnProgramsDetailInfo.programsDetailInfo.OSTAPhoneNumber = contact.Phone;
                }
                returnProgramsDetailInfo.programsDetailInfo.OSTAWorkingStatus = contact.Currently_Working_Status__c;
                returnProgramsDetailInfo.programsDetailInfo.OSTACompany = contact.Company__c;
                returnProgramsDetailInfo.programsDetailInfo.OSTAEducationalStatus = contact.Currently_in_School_Status__c;
                returnProgramsDetailInfo.programsDetailInfo.OSTAEducationalSchool = contact.School_Name__c;
                returnProgramsDetailInfo.programsDetailInfo.OSTAEducationalProgram = contact.Degree_Program_Name__c;

                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','returnProgramsDetailInfo Add OSTA Info',returnProgramsDetailInfo);
            }

            // Deadlines
            returnProgramsDetailInfo.programsDetailInfo.examDeadlines = new List<examDeadline>();

            examDeadline examDeadline;
            if(retPartInfo1 != NULL && retPartInfo1.examPartInfo != NULL && examAttemptPart1 != NULL && retPartInfo1.examPartInfo.examPartState == 'SchedulingOpen') {

                examDeadline = new examDeadline();
                examDeadline.examMonth = examAttemptPart1.RPT_Administration_Month__c;
                examDeadline.examYear = examAttemptPart1.RPT_Administration_Year__c;

                examDeadline.ADADeadline = retPartInfo1.examPartInfo.lastDateforADA;
                examDeadline.deferalDeadline = examAttemptPart1.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c;
                examDeadline.schedulingDeadline = retPartInfo1.examPartInfo.schedulingDeadline;

                returnProgramsDetailInfo.programsDetailInfo.examDeadlines.add(examDeadline);

                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','Add examDeadline Part1',examDeadline);
            }

            if(retPartInfo2 != NULL && retPartInfo2.examPartInfo != NULL && examAttemptPart2 != NULL) {

                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','Has Part2',retPartInfo2);

                if(examDeadline == NULL || (examDeadline.examMonth != examAttemptPart2.RPT_Administration_Month__c || examDeadline.examYear != examAttemptPart2.RPT_Administration_Year__c) && retPartInfo2.examPartInfo.examPartState == 'SchedulingOpen') {


                    examDeadline = new examDeadline();

                    examDeadline.examMonth = examAttemptPart2.RPT_Administration_Month__c;
                    examDeadline.examYear = examAttemptPart2.RPT_Administration_Year__c;

                    examDeadline.ADADeadline = retPartInfo2.examPartInfo.lastDateforADA;
                    examDeadline.DeferalDeadline = examAttemptPart2.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c;
                    examDeadline.SchedulingDeadline = retPartInfo2.examPartInfo.schedulingDeadline;

                    returnProgramsDetailInfo.programsDetailInfo.examDeadlines.add(examDeadline);

                    GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','Add examDeadline Part2',examDeadline);
                }
            }

            // Cross Part Fields
            returnProgramsDetailInfo.programsDetailInfo.isAnyPartSchedulingOpen = False;
            if((retPartInfo1 != NULL && retPartInfo1.examPartInfo.examPartState == 'SchedulingOpen') || (retPartInfo2 != NULL && retPartInfo2.examPartInfo.examPartState == 'SchedulingOpen')) {
                returnProgramsDetailInfo.programsDetailInfo.isAnyPartSchedulingOpen = True;
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','isAnyPartSchedulingOpen',returnProgramsDetailInfo.programsDetailInfo.isAnyPartSchedulingOpen);

            returnProgramsDetailInfo.programsDetailInfo.isAnyPartDeferalOpen = False;
            if((retPartInfo1 != NULL && retPartInfo1.examPartInfo.isDeferralOpen) || (retPartInfo2 != NULL && retPartInfo2.examPartInfo.isDeferralOpen)) {
                returnProgramsDetailInfo.programsDetailInfo.isAnyPartDeferalOpen = True;
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','isAnyPartDeferalOpen',returnProgramsDetailInfo.programsDetailInfo.isAnyPartDeferalOpen);

            returnProgramsDetailInfo.programsDetailInfo.isAnyPartDeferred = False;
            if((retPartInfo1 != NULL && retPartInfo1.examPartInfo.examPartState == 'Deferred') || (retPartInfo2 != NULL && retPartInfo2.examPartInfo.examPartState == 'Deferred')) {
                returnProgramsDetailInfo.programsDetailInfo.isAnyPartDeferred = True;
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','isAnyPartDeferred',returnProgramsDetailInfo.programsDetailInfo.isAnyPartDeferred);

            // Resources & Study Materials
            Boolean showPart1Resources =  (programContract.Status == 'Activated' || programContract.Status == 'Activated ( Auto-Renew )') &&
                                           (retPartInfo1 != NULL && retPartInfo1.examPartInfo != NULL &&
                                           (retPartInfo1.examPartInfo.examPartState == 'Deferred' || retPartInfo1.examPartInfo.examPartState == 'AwaitingSchedulingToOpen' || retPartInfo1.examPartInfo.examPartState == 'SchedulingOpen' ||
                                            (retPartInfo1.examDatesInfo != NULL && retPartInfo1.examDatesInfo.lastTestingDate != NULL && tdy <= retPartInfo1.examDatesInfo.lastTestingDate.addDays(1))
                                           ));

            Boolean showPart2Resources =  (programContract.Status == 'Activated' || programContract.Status == 'Activated ( Auto-Renew )') &&
                                           (retPartInfo2 != NULL && retPartInfo2.examPartInfo != NULL &&
                                           (retPartInfo2.examPartInfo.examPartState == 'Deferred' || retPartInfo2.examPartInfo.examPartState == 'AwaitingSchedulingToOpen' || retPartInfo2.examPartInfo.examPartState == 'SchedulingOpen' ||
                                            (retPartInfo2.examDatesInfo != NULL && retPartInfo2.examDatesInfo.lastTestingDate != NULL && tdy <= retPartInfo2.examDatesInfo.lastTestingDate.addDays(1))
                                           ));

            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','showPart1Resources',showPart1Resources);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','showPart2Resources',showPart1Resources);


            if(showPart1Resources || showPart2Resources) {

                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','Show Resources','');

                returnProgramsDetailInfo.programsDetailInfo.examResources = new examResources();

                // Get BenchPrep
                String benchPrepPart1ProductId;
                String benchPrepPart2ProductId;

                Map<String,BenchPrep_Config__mdt> mapBPConfig = BenchPrepClass.getBenchPrepConfig();
                String partKey1 = 'Full';
                String partKey2 = NULL;
                if(programType == 'FRM') {
                    partKey1 = '1';
                    partKey2 = '2';
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','partKey1',partKey1);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','partKey2',partKey2);

                String keyType = programType;
                if(programType == 'RiskAI') {
                    keyType = 'RAI';
                }

                BenchPrep_Config__mdt p1Config = mapBPConfig.get(keyType+':'+partKey1);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','p1Config',p1Config);

                if(p1Config != NULL) {
                    benchPrepPart1ProductId = p1Config.Product_ID__c;
                }

                if(programType == 'FRM') {
                    BenchPrep_Config__mdt p2Config = mapBPConfig.get(programType+':'+partKey2);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','p2Config',p2Config);

                    if(p2Config != NULL) {
                        benchPrepPart2ProductId = p2Config.Product_ID__c;
                    }
                }

                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','benchPrepPart1ProductId',benchPrepPart1ProductId);
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','benchPrepPart2ProductId',benchPrepPart2ProductId);

                Boolean hasBenchPrep1 = False;
                Boolean hasBenchPrep2 = False;

                // eBook
                List<GARP_BC_StudyMaterials.eBook> myEBooks = GARP_BC_StudyMaterials.getMyEBooks(contact.accountId, NULL);
                if(!myEBooks.IsEmpty()) {

                    // Check for BenchPrep
                    // Now check if has bought Part II
                    for(GARP_BC_StudyMaterials.eBook eb :myEBooks) {
                        if(eb.accountingId == benchPrepPart1ProductId) {
                            hasBenchPrep1 = True;
                        } else if(eb.accountingId == benchPrepPart2ProductId) {
                            hasBenchPrep2 = True;
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','hasBenchPrep1',hasBenchPrep1);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','hasBenchPrep2',hasBenchPrep2);

                    String part;
                    GARP_BC_StudyMaterials.eBook myEBook1;
                    GARP_BC_StudyMaterials.eBook myEBook2;
					String programPart;
                    if(programType == 'FRM') {
                        if(showPart1Resources) {
                            myEBook1 = GARP_BC_StudyMaterials.getMostRecentEBook(contact, programType, 'I', myEBooks);
                        }
                        if(showPart2Resources) {
                            myEBook2 = GARP_BC_StudyMaterials.getMostRecentEBook(contact, programType, 'II', myEBooks);
                        }
                    } else {
                        myEBook1 = GARP_BC_StudyMaterials.getMostRecentEBook(contact, programType, NULL, myEBooks);
                        programPart = 'Full';
                    }


                    if(myEBook1 != NULL) {
                        returnProgramsDetailInfo.programsDetailInfo.examResources.eBookItems = myEBook1.eBookItems;
                        returnProgramsDetailInfo.programsDetailInfo.examResources.eBookExpireDate = myEBook1.expireDate;
                        returnProgramsDetailInfo.programsDetailInfo.examResources.eBookProviderName = 'Pearson';
                    }
                    if(myEBook2 != NULL) {
                        if(returnProgramsDetailInfo.programsDetailInfo.examResources.eBookItems != NULL) {
                            returnProgramsDetailInfo.programsDetailInfo.examResources.eBookItems.AddAll(myEBook2.eBookItems);
                        } else {
                            returnProgramsDetailInfo.programsDetailInfo.examResources.eBookItems = myEBook2.eBookItems;
                        }
                    }
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','eBooks',returnProgramsDetailInfo.programsDetailInfo.examResources.eBookItems);

                // Only return Study Materials when appropriate??
                //if(returnProgramsDetailInfo.examPartState == 'Deferred' || returnProgramsDetailInfo.examPartState == 'AwaitingSchedulingToOpen' || returnProgramsDetailInfo.examPartState == 'SchedulingOpen') {

                if(hasBenchPrepAccess && (hasBenchPrep1 || hasBenchPrep2)) {
                    // eLearning
                    returnProgramsDetailInfo.programsDetailInfo.examResources.eLearningPlatformAccessURL = GARP_BC_StudyMaterials.getBenchPrepSSOLink(contact.Id, programType, NULL);
                    returnProgramsDetailInfo.programsDetailInfo.examResources.eLearningPlatformName = 'BenchPrep';
                }
                GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','eLearningPlatformAccessURL',returnProgramsDetailInfo.programsDetailInfo.examResources.eLearningPlatformAccessURL);

                  // ADA
                  if(showADADownload) {
                      String docName = programType + ' ADA Application';
                      GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','docName',docName);

                      List<Document> lstDocs = [SELECT Id, Name, ContentType, Description, Url, LastModifiedDate, Keywords FROM Document WHERE Name = :docName];
                      GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','lstDocs',lstDocs);

                      if(!lstDocs.IsEmpty()) {
                          returnProgramsDetailInfo.programsDetailInfo.examResources.ADAFormAccessURL = '/servlet/servlet.FileDownload?file=' + lstDocs[0].Id;
                          GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','ADAFormAccessURL',returnProgramsDetailInfo.programsDetailInfo.examResources.ADAFormAccessURL);
                      }
                  }
                  returnProgramsDetailInfo.programsDetailInfo.examResources.isOptedIntoEPP = contact.Exam_Prep_Provider_Outreach__c;
                  GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','isOptedIntoEPP',returnProgramsDetailInfo.programsDetailInfo.examResources.isOptedIntoEPP);
            }

            // Progress Bar Info
            /*
            if(programType == 'FRM') {

                returnProgramsDetailInfo.frmProgramProgessInfo.enrollment = 'open';
                returnProgramsDetailInfo.frmProgramProgessInfo.partIExam = 'open';
                returnProgramsDetailInfo.frmProgramProgessInfo.partIIExam = 'open';
                returnProgramsDetailInfo.frmProgramProgessInfo.workExperience = 'open';
                returnProgramsDetailInfo.frmProgramProgessInfo.certified = 'open';

                if(programContract.Status == 'Completed') {
                    returnProgramsDetailInfo.frmProgramProgessInfo.enrollment = 'completed';
                    returnProgramsDetailInfo.frmProgramProgessInfo.partIExam = 'completed';
                    returnProgramsDetailInfo.frmProgramProgessInfo.partIIExam = 'completed';
                    returnProgramsDetailInfo.frmProgramProgessInfo.workExperience = 'completed';
                    returnProgramsDetailInfo.frmProgramProgessInfo.certified = 'completed';
                } else if(programContract.Status == 'Draft') {
                    returnProgramsDetailInfo.frmProgramProgessInfo.enrollment = 'in progress';
                } else if(returnProgramsDetailInfo.programsDetailInfo.programState == 'EnrollmentExpired') {
                    returnProgramsDetailInfo.frmProgramProgessInfo.enrollment = 'open';
                } else if(returnProgramsDetailInfo.programsDetailInfo.programState == 'CVSubmission') {
                    returnProgramsDetailInfo.frmProgramProgessInfo.enrollment = 'completed';
                    returnProgramsDetailInfo.frmProgramProgessInfo.partIExam = 'completed';
                    returnProgramsDetailInfo.frmProgramProgessInfo.partIIExam = 'completed';
                    returnProgramsDetailInfo.frmProgramProgessInfo.workExperience = 'in progress';
                } else if(returnProgramsDetailInfo.programsDetailInfo.programState == 'ExamAttempt') {
                    returnProgramsDetailInfo.frmProgramProgessInfo.enrollment = 'completed';

                    GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','enrollment',returnProgramsDetailInfo.frmProgramProgessInfo.enrollment);

                    Boolean part1Completed = False;
                    Boolean part2Completed = False;
                    for(Candidate_Requirement__c cr :programContract.Candidate_Requirements__r) {
                        if(cr.recordType.DeveloperName == 'EXAM' && cr.Exam__c == 'FRM Part I' && cr.Status__c == 'Completed') {
                            part1Completed = True;
                        } else if(cr.recordType.DeveloperName == 'EXAM' && cr.Exam__c == 'FRM Part II' && cr.Status__c == 'Completed') {
                            part2Completed = True;
                        }
                    }

                    GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','part1Completed',part1Completed);
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','part2Completed',part2Completed);

                    if(part1Completed) {
                        returnProgramsDetailInfo.frmProgramProgessInfo.partIExam = 'completed';
                    } else {
                        returnProgramsDetailInfo.frmProgramProgessInfo.partIExam = 'in progress';
                    }

                    GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','partIExam',returnProgramsDetailInfo.frmProgramProgessInfo.partIExam);

                    if(part2Completed) {
                        returnProgramsDetailInfo.frmProgramProgessInfo.partIIExam = 'completed';
                    } else if(returnProgramsDetailInfo.programsDetailInfo.examPart2Info != NULL && returnProgramsDetailInfo.programsDetailInfo.examPart2Info.examAttemptId != NULL) {
                        returnProgramsDetailInfo.frmProgramProgessInfo.partIIExam = 'in progress';
                    } else {
                        returnProgramsDetailInfo.frmProgramProgessInfo.partIIExam = 'open';
                    }

                    GARP_Common.debugLog('GARP_BC_MyPrograms','getMyProgramsDetailInfo','partIIExam',returnProgramsDetailInfo.frmProgramProgessInfo.partIIExam);

                }
            }
            */

        } else {
            returnProgramsDetailInfo.statusMessage = 'Contact not found';
            returnProgramsDetailInfo.statusCode = 401;
        }

        returnProgramsDetailInfo.statusMessage = 'Success';
        returnProgramsDetailInfo.statusCode = 200;

        GARP_Common.debugLog('GARP_BC_MyPrograms','getDashboardInfo','returnProgramsDetailInfo',returnProgramsDetailInfo);

        return returnProgramsDetailInfo;
    }

    public class returnGetExamPartInfo {
        public String statusMessage;
        public Integer statusCode;
        public examPartInfo examPartInfo;
        public examDatesInfo examDatesInfo;
    }

    // examPart = I, II, Full (for SCR and RiskAI)
    public static returnGetExamPartInfo getExamPartInfo(Contact contact, String programType, String examPart, Contract programContract, MAP<String,Exam_Attempt__c> mapLatestExamAttempts, String loadKey) {

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','examPart',examPart);

        returnGetExamPartInfo returnGetExamPartInfo = new returnGetExamPartInfo();
        returnGetExamPartInfo.examPartInfo = new examPartInfo();

        returnGetExamPartInfo.examPartInfo.isDeferralOpen = False;
        returnGetExamPartInfo.examPartInfo.schedulingIsComplete = False;
        returnGetExamPartInfo.examPartInfo.isSchedulingOpen = False;
        returnGetExamPartInfo.examPartInfo.isResultStale = False;
        returnGetExamPartInfo.examPartInfo.showTakeExam = False;

        Exam_Attempt__c examAttempt = mapLatestExamAttempts.get(programType + examPart);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','examAttempt',examAttempt);

        String examAccessURL;

        if(examAttempt != NULL) {
            returnGetExamPartInfo.examPartInfo.examAttemptId = examAttempt.Id;
            returnGetExamPartInfo.examPartInfo.lastDateforADA = examAttempt.Exam_Administration__r.Last_Date_For_ADA__c;
            returnGetExamPartInfo.examPartInfo.examFormat = examAttempt.Integration_Data_Exam_Mode__c;

            returnGetExamPartInfo.examPartInfo.examAttemptAdminName = examAttempt.RPT_Administration_Month__c + ' ' + examAttempt.RPT_Administration_Year__c;
            if(examAttempt.Exam_Site__r == NULL || examAttempt.Exam_Site__r.Exam_Provider__r.Name == NULL) {
                returnGetExamPartInfo.examPartInfo.schedulingExamProviderName = 'GARP';
            } else {
                returnGetExamPartInfo.examPartInfo.schedulingExamProviderName = examAttempt.Exam_Site__r.Exam_Provider__r.Name;
            }

            if(returnGetExamPartInfo.examPartInfo.schedulingExamProviderName == 'Pearson') {
                examAccessURL = System.Label.GARP_PEARSON_SSO_URL + examAttempt.Id;
            } else if(returnGetExamPartInfo.examPartInfo.schedulingExamProviderName == 'ATA') {
                examAccessURL = System.Label.GARP_ATA_SSO_URL + examAttempt.Id;
            } else if(returnGetExamPartInfo.examPartInfo.schedulingExamProviderName == 'PSI') {
                examAccessURL = System.Label.GARP_PSI_SSO_URL;
            }

        } else {
            returnGetExamPartInfo.statusMessage = 'Exam Attempt not found';
            returnGetExamPartInfo.statusCode = 401;
            return returnGetExamPartInfo;
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','examPartInfo Step 1',returnGetExamPartInfo.examPartInfo);

        // Is OSTA?
        Boolean isOSTA = examAttempt.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c;

        // Get Exam Dates
        returnGetExamPartInfo.examDatesInfo = getExamDateInfo(examAttempt);

        // Get Name on ID
        String idName = getNameOnID(contact, programType);

        // Get Scheduling Status
        Boolean isSchedulingComplete = isSchedulingComplete(contact, examAttempt, programType, idName, isOSTA);

        Date tdy = Date.Today();

        // Find open deferal order for Exams
        Opportunity latestOpenDeferOpp = GARP_BC_Orders.getLatestOppWithExamModification(contact.accountID, NULL, programType);

        // UnPaid
        if(examAttempt.Opportunity__r.StageName == 'New Lead') {

            returnGetExamPartInfo.examPartInfo.examPartState = 'Unpaid';
            returnGetExamPartInfo.examPartInfo.unpaidOrderId = examAttempt.Opportunity__c;
            returnGetExamPartInfo.examPartInfo.unpaidOrderPayByDate = examAttempt.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c;
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','returnGetExamPartInfo Unpaid',returnGetExamPartInfo.examPartInfo);

        } else if(examAttempt.Deferral_Status__c == 'Deferred Out') {

            // Deferred Out
            returnGetExamPartInfo.examPartInfo.examPartState = 'Deferred';
            returnGetExamPartInfo.examPartInfo.deferredAdminName = examAttempt.Deferred_Exam_Administration__r.Month__c + ' ' + examAttempt.Deferred_Exam_Administration__r.Year__c;
            returnGetExamPartInfo.examPartInfo.deferredExamSetupOpenDate = examAttempt.Deferred_Exam_Administration__r.Exam_Scheduling_Start_Date__c;

            returnGetExamPartInfo.examPartInfo.isSchedulingOpen = (tdy <= examAttempt.Exam_Administration__r.Exam_Scheduling_End_Date__c);
            if(returnGetExamPartInfo.examPartInfo.isSchedulingOpen) {
                returnGetExamPartInfo.examPartInfo.schedulingDeadline = examAttempt.Exam_Administration__r.Exam_Scheduling_End_Date__c;
            }

            returnGetExamPartInfo.examPartInfo.isDeferralOpen = (tdy <= examAttempt.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c && tdy >= examAttempt.Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c);

            if(latestOpenDeferOpp != NULL) {
                returnGetExamPartInfo.examPartInfo.unpaidDeferralOrderId = latestOpenDeferOpp.Id;
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','getExamPartInfo Deferred',returnGetExamPartInfo.examPartInfo);

        } else if(tdy < examAttempt.Exam_Administration__r.Exam_Scheduling_Start_Date__c) {

            // Scheduling Not Open Yet
            returnGetExamPartInfo.examPartInfo.examPartState = 'AwaitingSchedulingToOpen';
            returnGetExamPartInfo.examPartInfo.schedulingAwaitingToOpenOpenDate = examAttempt.Exam_Administration__r.Exam_Scheduling_Start_Date__c;

            if(latestOpenDeferOpp != NULL) {
                returnGetExamPartInfo.examPartInfo.unpaidDeferralOrderId = latestOpenDeferOpp.Id;
            }

            returnGetExamPartInfo.examPartInfo.isSchedulingOpen = False;
            returnGetExamPartInfo.examPartInfo.isDeferralOpen = (tdy <= examAttempt.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c && tdy >= examAttempt.Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c);

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','getExamPartInfo AwaitingSchedulingToOpen',returnGetExamPartInfo);

        } else { // Scheduling Is Open

            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','Scheduling Is Open',returnGetExamPartInfo.examDatesInfo.schedulingCutoffDate);

            returnGetExamPartInfo.examPartInfo.schedulingIsComplete = isSchedulingComplete;
            returnGetExamPartInfo.examPartInfo.isSchedulingOpen = True;
            returnGetExamPartInfo.examPartInfo.isDeferralOpen = (tdy <= examAttempt.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c);
            returnGetExamPartInfo.examPartInfo.schedulingDeadline = examAttempt.Exam_Administration__r.Exam_Scheduling_End_Date__c;
            returnGetExamPartInfo.examPartInfo.schedulingExamDateTimeSelected = examAttempt.Integration_Data_Exam_Scheduled_Date__c;
            returnGetExamPartInfo.examPartInfo.schedulingExamDateTimeZoneSelected = examAttempt.Integration_Data_Exam_Scheduled_TimeZone__c;
            returnGetExamPartInfo.examPartInfo.schedulingExamLocationSelected = examAttempt.Integration_Data_Exam_Location__c;
            returnGetExamPartInfo.examPartInfo.schedulingExamAccessURL = examAccessURL;

            Boolean isProviderSchedulingComplete = isProviderSchedulingComplete(examAttempt);

            // Before Scheduling Deadline
            if((tdy <= returnGetExamPartInfo.examDatesInfo.schedulingCutoffDate && tdy <= returnGetExamPartInfo.examDatesInfo.examDate) || examAttempt.Allow_Scheduling_Override__c) {

                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','Before Scheduling Cutoff Date','');

                returnGetExamPartInfo.examPartInfo.examPartState = 'SchedulingOpen';

                if(latestOpenDeferOpp != NULL) {
                    returnGetExamPartInfo.examPartInfo.unpaidDeferralOrderId = latestOpenDeferOpp.Id;
                }

                if(isProviderSchedulingComplete && examAttempt.Integration_Data_Exam_Mode__c == 'Remote' && tdy >= returnGetExamPartInfo.examDatesInfo.examDate.AddDays(-2) && tdy <= returnGetExamPartInfo.examDatesInfo.examDate.AddDays(2)) {
                    returnGetExamPartInfo.examPartInfo.showTakeExam = True;
                }

            } else { // After Scheduling Cutoff Date

                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','After Scheduling Cutoff Date','');

                returnGetExamPartInfo.examPartInfo.schedulingIsComplete = isSchedulingComplete;
                returnGetExamPartInfo.examPartInfo.isSchedulingOpen = False;

                if(!isProviderSchedulingComplete && examAttempt.Result__c == NULL) {
                    returnGetExamPartInfo.examPartInfo.examPartState = 'SchedulingClosedNeverScheduled';
                    GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','getExamPartInfo SchedulingClosedNeverScheduled',returnGetExamPartInfo.examPartInfo);

                } else {

                    if(examAttempt.Exam_Part__r.Exam_Results_Available_Statement__c != NULL || examAttempt.Exam_Part__r.Exam_Results_Release_Date__c != NULL) {
                        returnGetExamPartInfo.examPartInfo.resultsAvailableDateTime = examAttempt.Exam_Part__r.Exam_Results_Release_Date__c;
                        returnGetExamPartInfo.examPartInfo.resultsAvailableStatement = examAttempt.Exam_Part__r.Exam_Results_Available_Statement__c;
                    } else {
                        returnGetExamPartInfo.examPartInfo.resultsAvailableDateTime = examAttempt.Exam_Administration__r.Exam_Results_Release_Date__c;
                        returnGetExamPartInfo.examPartInfo.resultsAvailableStatement = examAttempt.Exam_Administration__r.Exam_Results_Available_Statement__c;
                    }

                    if(isProviderSchedulingComplete && examAttempt.Integration_Data_Exam_Mode__c == 'Remote' && tdy >= returnGetExamPartInfo.examDatesInfo.examDate.AddDays(-2) && tdy <= returnGetExamPartInfo.examDatesInfo.examDate.AddDays(2)) {
                        returnGetExamPartInfo.examPartInfo.showTakeExam = True;
                    }

                    // Awaiting To Take
                    if(tdy <= returnGetExamPartInfo.examDatesInfo.examDate) {

                        returnGetExamPartInfo.examPartInfo.examPartState = 'SchedulingClosedAwaitingToTakeExam';
                        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','getExamPartInfo SchedulingClosedAwaitingToTakeExam',returnGetExamPartInfo.examPartInfo);

                    } else if(examAttempt.Result__c == NULL || isLoadingResults(examAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey)) {

                        // Awaiting Results
                        returnGetExamPartInfo.examPartInfo.examPartState = 'SchedulingClosedAwaitingResults';
                        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','getExamPartInfo SchedulingClosedAwaitingResults',returnGetExamPartInfo.examPartInfo);

                    } else {

                        // Results Available
                        returnGetExamPartInfo.examPartInfo.examPartState = 'SchedulingClosedResultsAvailable';
                        if(examAttempt.hasViolation__c) {
                            returnGetExamPartInfo.examPartInfo.result = 'Not Graded';
                        } else if(examAttempt.Hide_Exam_Result__c) {
                            returnGetExamPartInfo.examPartInfo.result = 'Not Available';
                        } else {
                            returnGetExamPartInfo.examPartInfo.result = examAttempt.Result__c;
                        }

                        Integer numberOfDays=0;
                        if(returnGetExamPartInfo.examPartInfo.resultsAvailableDateTime != NULL) {
                            Date resultAvailableDate = Date.NewInstance(returnGetExamPartInfo.examPartInfo.resultsAvailableDateTime.year(), returnGetExamPartInfo.examPartInfo.resultsAvailableDateTime.month(), returnGetExamPartInfo.examPartInfo.resultsAvailableDateTime.day());
                            numberOfDays = resultAvailableDate.daysBetween(tdy);
                        }

                        if(numberOfDays > 90 && returnGetExamPartInfo.examPartInfo.result == 'Pass') {
                            returnGetExamPartInfo.examPartInfo.isResultStale = True;
                        }
                        
                        if(programType == 'FRM' && examPart == 'I' && returnGetExamPartInfo.examPartInfo.result == 'Pass') {
                            returnGetExamPartInfo.examPartInfo.badgeURL = 'https://www.garp.org/hubfs/Portal/Certificates/FRM1%20Badge.png';
                            returnGetExamPartInfo.examPartInfo.badgePageURL = 'https://my.garp.org/DigitalBadgeFRMI?id=' + contact.Id;
                        } else if(programType == 'FRM' && examPart == 'II' && returnGetExamPartInfo.examPartInfo.result == 'Pass') {
                            returnGetExamPartInfo.examPartInfo.badgeURL = 'https://www.garp.org/hubfs/Portal/Certificates/FRM2%20Badge.png';
                            returnGetExamPartInfo.examPartInfo.badgePageURL = 'https://my.garp.org/DigitalBadgeFRMII?id=' + contact.Id;
                        }

                        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','getExamPartInfo ResultsAvailable',returnGetExamPartInfo.examPartInfo);
                    }
                }
            }
        }

        returnGetExamPartInfo.statusMessage = 'Success';
        returnGetExamPartInfo.statusCode = 200;

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamPartInfo','returnGetExamPartInfo final',returnGetExamPartInfo);

        return returnGetExamPartInfo;
    }

    public static String getNameOnID(Contact contact, String programType) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getNameOnID','contact',contact);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getNameOnID','programType',programType);

        String idName;

        if(programType == 'scr' || programType == 'rai' || programType == 'raij' || programType == 'riskai') {
            if(contact.First_Name_as_it_Appears_on_ID__c != NULL) {
                idName = contact.First_Name_as_it_Appears_on_ID__c;
            }
            if(contact.Middle_Name_as_it_Appears_on_ID__c != NULL) {
                if(idName != NULL) {
                    idName = idName + ' ';
                }
                idName += contact.Middle_Name_as_it_Appears_on_ID__c;
            }
            if(contact.Last_Name_as_it_Appears_on_ID__c != NULL) {
                if(idName != NULL) {
                    idName = idName + ' ';
                }
                idName += contact.Last_Name_as_it_Appears_on_ID__c;
            }

        } else {
            idName = contact.Name_as_it_Appears_on_ID__c;
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getNameOnID','idName',idName);
        return idName;
    }

    public static Boolean isProviderSchedulingComplete(Exam_Attempt__c examAttempt) {

        GARP_Common.debugLog('GARP_BC_MyPrograms','isProviderSchedulingComplete','examAttempt',examAttempt);
        GARP_Common.debugLog('GARP_BC_MyPrograms','isProviderSchedulingComplete','Active_Integration_Data__c',examAttempt.Active_Integration_Data__c);
        GARP_Common.debugLog('GARP_BC_MyPrograms','isProviderSchedulingComplete','Integration_Data_Exam_Scheduled_Date__c',examAttempt.Integration_Data_Exam_Scheduled_Date__c);
        GARP_Common.debugLog('GARP_BC_MyPrograms','isProviderSchedulingComplete','Integration_Data_Exam_Location__c',examAttempt.Integration_Data_Exam_Location__c);

        Boolean isComplete = TRUE;
        if(examAttempt.Active_Integration_Data__c == NULL || examAttempt.Integration_Data_Exam_Scheduled_Date__c == NULL || examAttempt.Integration_Data_Exam_Location__c == NULL) {
            isComplete = FALSE;
        }
        GARP_Common.debugLog('GARP_BC_MyPrograms','isProviderSchedulingComplete','isComplete',isComplete);
        return isComplete;
    }

    public static Boolean isSchedulingComplete(Contact contact, Exam_Attempt__c examAttempt, String programType, String idName, Boolean isOSTA) {

        GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','contact',contact);
        GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','examAttempt',examAttempt);
        GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','programType',programType);
        GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','idName',idName);
        GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','isOSTA',isOSTA);

        Boolean isComplete = TRUE;

        GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','Allow_Scheduling_Override__c',examAttempt.Allow_Scheduling_Override__c);

        Boolean isProviderComplete = isProviderSchedulingComplete(examAttempt);

        if(isProviderComplete) {
            return True;
        }

        if(!examAttempt.Allow_Scheduling_Override__c) {

            if(programType == 'FRM') {
                if(idName == NULL || contact.ID_Number__c == NULL || contact.ID_Type__c == NULL) {
                    isComplete = False;
                    GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','FRM ID Incomplete',contact.ID_Number__c + '~' + contact.ID_Type__c);
                } else if(isOSTA && (contact.Full_Name_in_Chinese__c == NULL || contact.Birthdate == NULL || contact.Gender__c == NULL || (contact.HomePhone == NULL && contact.OtherPhone == NULL && contact.Phone == NULL) || contact.Currently_Working_Status__c == NULL || contact.Company__c == NULL || contact.Currently_in_School_Status__c == NULL || contact.School_Name__c == NULL || contact.Degree_Program_Name__c == NULL)) {
                    isComplete = FALSE;
                    GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','OSTA Incomplete',contact.Full_Name_in_Chinese__c + '~' + contact.Birthdate);
                } else if(!isProviderComplete) {
                    isComplete = False;
                    GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','isProviderComplete',isProviderComplete);
                }
            } else if(contact.First_Name_as_it_Appears_on_ID__c == NULL && contact.Middle_Name_as_it_Appears_on_ID__c == NULL && contact.Last_Name_as_it_Appears_on_ID__c == NULL) {
                isComplete = False;
                GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','SCR/RAI ID Incomplete',contact.First_Name_as_it_Appears_on_ID__c + '~' + contact.Middle_Name_as_it_Appears_on_ID__c + '~' + contact.Last_Name_as_it_Appears_on_ID__c);
            } else if(!isProviderComplete) {
                isComplete = False;
                GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','isProviderComplete',isProviderComplete);
            }
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','isSchedulingComplete','isComplete',isComplete);
        return isComplete;
    }

    public class examDatesInfo {
        public Date schedulingCutoffDate; // Exam Scheduled End Date
        public Date examDate; // Either Exam Day / Last Exam Date OR Exam Scheduled date
        public Date lastTestingDate; // Either Exam Day / Last Exam Date OR Exam Scheduled date
    }

    public static examDatesInfo getExamDateInfo(Exam_Attempt__c examAttempt) {

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamDateInfo','examAttempt',examAttempt);

        examDatesInfo examDatesInfo = new examDatesInfo();

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamDateInfo','Exam_Scheduling_End_Date__c',examAttempt.Exam_Administration__r.Exam_Scheduling_End_Date__c);

        DateTime dt;
        Date examEndDate;
        if(examAttempt.Exam_Administration__c != NULL && examAttempt.Exam_Part__r.Exam_Date__c != NULL) {
            GARP_Common.debugLog('GARP_BC_MyPrograms','getExamDateInfo','Exam_Date__c',examAttempt.Exam_Part__r.Exam_Date__c);

            examDatesInfo.schedulingCutoffDate = examAttempt.Exam_Administration__r.Exam_Scheduling_End_Date__c;
            examDatesInfo.examDate = examAttempt.Exam_Part__r.Exam_Date__c;
            examDatesInfo.lastTestingDate = examAttempt.Exam_Part__r.Exam_Date__c;
            if(examAttempt.Integration_Data_Exam_Scheduled_Date__c != NULL) {
                examDatesInfo.examDate = Date.newInstance(examAttempt.Integration_Data_Exam_Scheduled_Date__c.year(),examAttempt.Integration_Data_Exam_Scheduled_Date__c.month(), examAttempt.Integration_Data_Exam_Scheduled_Date__c.day());
                //examDatesInfo.examDate = examDatesInfo.schedulingCutoffDate;
                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamDateInfo','Integration_Data_Exam_Scheduled_Date__c1',examAttempt.Integration_Data_Exam_Scheduled_Date__c);
            }

        } else if(examAttempt.Exam_Administration__c != NULL) {

            examDatesInfo.schedulingCutoffDate = examAttempt.Exam_Administration__r.Exam_Scheduling_End_Date__c;
            examDatesInfo.examDate = examAttempt.Exam_Part__r.Exam_End_Date__c;
            examDatesInfo.lastTestingDate = examAttempt.Exam_Part__r.Exam_End_Date__c;

            if(examAttempt.Integration_Data_Exam_Scheduled_Date__c != NULL) {
                examDatesInfo.examDate = Date.newInstance(examAttempt.Integration_Data_Exam_Scheduled_Date__c.year(), examAttempt.Integration_Data_Exam_Scheduled_Date__c.month(), examAttempt.Integration_Data_Exam_Scheduled_Date__c.day());
                //examDatesInfo.examDate = examDatesInfo.schedulingCutoffDate;
                GARP_Common.debugLog('GARP_BC_MyPrograms','getExamDateInfo','Integration_Data_Exam_Scheduled_Date__c2',examAttempt.Integration_Data_Exam_Scheduled_Date__c);
            }
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getExamDateInfo','examDatesInfo',examDatesInfo);

        return examDatesInfo;
    }

    public class OverlapWarning {
        public String message;
        public String company;
    }

    public class workExperience {
        public String id;
        public String programRequirement;
        public String startDate;
        public String endDate;

        public Integer startDateMonth;
        public Integer startDateYear;
        
        public Integer endDateMonth;
        public Integer endDateYear;
        
        public Boolean isCurrentPosition;
        public String company;
        public String title;
        public String type;
        public String description;
        public String manager;

        public String attachmentName;
        public String attachmentURL;
        public String attachemnt;
        public Integer attachmentCount;

        public String jobFunction;
        public String riskSpecialty;
        public String jobType;
        public String educationalRole;

        public Decimal timeAllotted;

        public String validationMessage;
        public Boolean isValidExperience;

        public OverlapWarning overlapWarning;
        public Boolean hasAttachments;
        public Boolean isExperienceAttachmentRequired;
    }

    // Methods
    public class returnGetAllWorkExperiences {
        public Decimal totalTimeAllotted;
        public List<workExperience> workExperiences;
    }

    public class ValidationResult {
        public Boolean isValid;
        public String errorMessage;

        public ValidationResult(Boolean isValid, String errorMessage) {
            this.isValid = isValid;
            this.errorMessage = errorMessage;
        }
    }

    public class ExperienceDocumentRequirementResult {
        public Boolean required;
        public Boolean hasAttachments;
        public Boolean isValidExperience;
        public String validationMessage;
        public String documentMessage;
        public List<String> requiredDocuments;
    }

    public static ExperienceDocumentRequirementResult getExperienceDocumentRequirement(Experience__c ex) {
        ExperienceDocumentRequirementResult result = new ExperienceDocumentRequirementResult();
         result.hasAttachments = hasExperienceAttachments(ex.Id);
 
         Set<String> frmRelatedSpecialties = new Set<String>{
             'Credit Risk',
             'Enterprise Risk',
             'Liquidity Risk',
             'Market Risk',
             'Model Risk/Model Validation'
         };
 
         String jobFunction = ex.Job_Function__c;
         String riskSpecialty = ex.Risk_Specialty__c;
         String educationalRole = ex.Educational_Role__c;
         String jobType = ex.Job_Type__c;
         String company = ex.Company__r != null ? ex.Company__r.Name : ex.CompanyOther__c;
 
         // Document requirement logic
         if (jobType == 'Full Time' || jobType == 'Full Time Intern') {
             if (jobFunction == 'Risk Management') {
                 result.required = false;
                 result.documentMessage = 'No documentation required';
             } else if (jobFunction == 'Education/Training') {
                 if (educationalRole == 'Professor' || educationalRole == 'Assistant Professor' || educationalRole == 'Adjunct Professor') {
                     result.required = true;
                     result.requiredDocuments = new List<String>{
                         'A letter from your university describing your role and whether it is part-time or full-time',
                         'Syllabus from each of the class(es) you teach',
                         'A copy of your resume'
                     };
                     result.documentMessage = 'Please provide the following documents:';
                 } else if (educationalRole == 'Exam Preparation' && company == 'Eligible EPP') {
                     if (frmRelatedSpecialties.contains(riskSpecialty)) {
                         result.required = false;
                         result.documentMessage = 'No documentation required';
                     } else {
                         result.required = true;
                         result.requiredDocuments = new List<String>{
                             'Documentation of your course offerings and descriptions of each course'
                         };
                         result.documentMessage = 'Please provide documentation of your course offerings and descriptions of each course';
                     }
                     } else {
                         result.required = true;
                         result.requiredDocuments = new List<String>{
                             'Class roster',
                             'Legal status of company, including website link',
                             'Course offerings and descriptions'
                         };
                         result.documentMessage = 'Please provide documentation of the following:';
                     }
                 } else if (jobFunction == 'Research') {
                     result.required = true;
                     result.documentMessage = 'Please provide a program description from your university indicating you had full-time work experience during your studies';
                 } else if (jobType == 'Full Time Intern') {
                     result.required = true;
                     result.documentMessage = 'Please upload a workplace-provided job description with details about your role and responsibilities';
                 } else {
                     result.required = true;
                     result.documentMessage = 'Please upload a workplace-provided job description with details about your role and responsibilities';
                 }
             } else {
                 result.required = false;
                 result.documentMessage = 'No documentation required';
             }
 
             if (result.required && !result.hasAttachments) {
                 result.isValidExperience = false;
                 result.validationMessage = 'This experience requires documentation. Be sure to upload the required attachments before final submission.';
             } else {
                 result.isValidExperience = true;
                 result.validationMessage = '';
             }
             return result;
         }
 
     public static Boolean isExperienceAttachmentRequired(Experience__c ex) {
         Set<String> frmRelatedSpecialties = new Set<String>{
             'Credit Risk',
             'Enterprise Risk',
             'Liquidity Risk',
             'Market Risk',
             'Model Risk/Model Validation'
         };
 
         String jobFunction = ex.Job_Function__c;
         String riskSpecialty = ex.Risk_Specialty__c;
         String educationalRole = ex.Educational_Role__c;
         String jobType = ex.Job_Type__c;
         String company = ex.Company__r != null ? ex.Company__r.Name : ex.CompanyOther__c;
 
         if (jobType == 'Full Time' || jobType == 'Full Time Intern') {
             if (jobFunction == 'Risk Management') {
                 if (frmRelatedSpecialties.contains(riskSpecialty)) {
                     return false;
                 } else {
                     return true;
                 }
             } else if (jobFunction == 'Education/Training') {
                 if (educationalRole == 'Professor' || educationalRole == 'Assistant Professor' || educationalRole == 'Adjunct Professor') {
                     return true;
                 } else if (educationalRole == 'Exam Preparation' && company == 'Eligible EPP') {
                     if (frmRelatedSpecialties.contains(riskSpecialty)) {
                         return false;
                     } else {
                         return true;
                     }
                 } else {
                     return true;
                 }
             } else if (jobFunction == 'Research') {
                 return true;
             } else {
                 return true;
             }
         } else {
             return false;
         }
     }
 
     public static Boolean hasExperienceAttachments(Id experienceId) {
         Integer count = [SELECT COUNT() FROM Attachment WHERE ParentId = :experienceId];
         return count > 0;
     }
 
     public static ValidationResult validateWorkExperienceDateSubmissionCalculation(Date startDate, Date endDate, Date tenYearsBeforeCompletion, String jobType) {
         GARP_Common.debugLog('GARP_BC_MyPrograms', 'validateWorkExperienceDateSubmissionCalculation', 'startDate', startDate);
         GARP_Common.debugLog('GARP_BC_MyPrograms', 'validateWorkExperienceDateSubmissionCalculation', 'endDate', endDate);
         GARP_Common.debugLog('GARP_BC_MyPrograms', 'validateWorkExperienceDateSubmissionCalculation', 'tenYearsBeforeCompletion', tenYearsBeforeCompletion);
         GARP_Common.debugLog('GARP_BC_MyPrograms', 'validateWorkExperienceDateSubmissionCalculation', 'jobType', jobType);
 
         // Exclude part-time or intern jobs
         if (jobType != null && (
             jobType.equalsIgnoreCase('Part-Time') ||
             jobType.equalsIgnoreCase('Part Time') ||
             jobType.equalsIgnoreCase('Part Time Intern') ||
             jobType.toLowerCase().contains('part time') ||
             (jobType.toLowerCase().contains('intern') && !jobType.equalsIgnoreCase('Full Time Intern')) ||
             jobType.toLowerCase().contains('part time')
         )) {
         return new ValidationResult(true, 'Job type is part-time or part-time intern, which is not eligible for time calculation.');
         }
 
         // Exclude experiences more than 10 years before the cutoff
         if (endDate != null && endDate < tenYearsBeforeCompletion) {
             return new ValidationResult(false, 'Work experience ends before the 10-year cutoff date.');
         }
 
         // If the work experience starts after the cutoff, it is valid
         if (startDate != null && startDate >= tenYearsBeforeCompletion) {
             return new ValidationResult(true, 'Valid work experience.');
         }
 
         // If the work experience spans the cutoff, it is partially valid
         if (startDate != null && startDate < tenYearsBeforeCompletion && endDate != null && endDate >= tenYearsBeforeCompletion) {
             return new ValidationResult(true, 'Work experience spans the 10-year cutoff date and is valid.');
         }
 
         // Default case: invalid
         return new ValidationResult(false, 'Work experience dates are incomplete or invalid.');
     }
 
     public static returnGetAllWorkExperiences getAllWorkExperiences(String contactId, String programId, Contract progContact) {
         GARP_Common.debugLog('GARP_BC_MyPrograms', 'getAllWorkExperiences', 'contactId', contactId);
         GARP_Common.debugLog('GARP_BC_MyPrograms', 'getAllWorkExperiences', 'programId', programId);
 
         returnGetAllWorkExperiences returnGetAllWorkExperiences = new returnGetAllWorkExperiences();
         returnGetAllWorkExperiences.workExperiences = new List<workExperience>();
         returnGetAllWorkExperiences.totalTimeAllotted = 0;
 
         List<Experience__c> lstExperience = [SELECT Id, Program_Requirement__c, Start_Date__c, End_Date__c, Company__r.Name, CompanyOther__c, Title__c,
                                              Type_of_Experience__c, Job_Description__c, Manager_Name__c, Job_Function__c, Risk_Specialty__c, Job_Type__c, Educational_Role__c, Is_Currently_Employed__c, No_of_Months_F__c
                                              FROM Experience__c
                                              WHERE Contact__c = :contactId AND Status__c != 'To Be Deleted' AND Program_Requirement__r.Candidate_Commitment__c = :programId];
         GARP_Common.debugLog('GARP_BC_MyPrograms', 'getAllWorkExperiences', 'lstExperience', lstExperience);
 
         List<Map<String, Object>> validRanges = new List<Map<String, Object>>(); // Overlap Logic: Collect valid date ranges and halving info
 
         if (!lstExperience.isEmpty()) {
             Date tenYearsBeforeCompletion = Date.today().addYears(-10);
 
             for (Experience__c ex : lstExperience) {
                 workExperience workExperience = new workExperience();
                 workExperience.id = ex.Id;
                 workExperience.programRequirement = ex.Program_Requirement__c;
                 workExperience.startDate = GARP_Common.formatDate(ex.Start_Date__c, 'MM/dd/yyyy');
                 workExperience.endDate = GARP_Common.formatDate(ex.End_Date__c, 'MM/dd/yyyy');
                 workExperience.isCurrentPosition = ex.Is_Currently_Employed__c;
                 workExperience.hasAttachments = hasExperienceAttachments(ex.Id);
 
                 if (ex.Company__c != null) {
                     workExperience.company = ex.Company__r.Name;
                 } else {
                     workExperience.company = ex.CompanyOther__c;
                 }
 
                 workExperience.title = ex.Title__c;
                 workExperience.type = ex.Type_of_Experience__c;
                 workExperience.description = ex.Job_Description__c;
                 workExperience.manager = ex.Manager_Name__c;
 
                 workExperience.jobFunction = ex.Job_Function__c;
                 workExperience.riskSpecialty = ex.Risk_Specialty__c;
                 workExperience.jobType = ex.Job_Type__c;
                 workExperience.educationalRole = ex.Educational_Role__c;
                 workExperience.timeAllotted = 0;
 
                 ExperienceDocumentRequirementResult docReq = getExperienceDocumentRequirement(ex);
                 workExperience.isExperienceAttachmentRequired = docReq.required;
                 workExperience.hasAttachments = docReq.hasAttachments;
                 workExperience.isValidExperience = docReq.isValidExperience;
                 workExperience.validationMessage = docReq.validationMessage;
 
                 Boolean isPartTimeOrIntern = false;
                 if (ex.Job_Type__c != null && (
                     ex.Job_Type__c.equalsIgnoreCase('Part-Time') ||
                     ex.Job_Type__c.equalsIgnoreCase('Part Time') ||
                     ex.Job_Type__c.equalsIgnoreCase('Part Time Intern') ||
                     ex.Job_Type__c.toLowerCase().contains('part time') ||
                     (ex.Job_Type__c.toLowerCase().contains('intern') && !ex.Job_Type__c.equalsIgnoreCase('Full Time Intern'))
                 )) {
                     isPartTimeOrIntern = true;
                     workExperience.timeAllotted = 0;
                     workExperience.isValidExperience = true;
                     workExperience.validationMessage = '';
                 }
                 // Override timeAllotted if required and no attachments
                 else if (docReq.required && !docReq.hasAttachments && !Test.isRunningTest()) {
                     workExperience.timeAllotted = 0;
                 } else {
                     // For current positions, use today's date as the end date
                     Date effectiveEndDate = (ex.Is_Currently_Employed__c == true || ex.End_Date__c == null) ? Date.today() : ex.End_Date__c;
 
                     if (tenYearsBeforeCompletion != null && ex.Start_Date__c != null && effectiveEndDate != null) {
                         ValidationResult validationResult = validateWorkExperienceDateSubmissionCalculation(ex.Start_Date__c, effectiveEndDate, tenYearsBeforeCompletion, ex.Job_Type__c);
                         workExperience.isValidExperience = validationResult.isValid;
                         workExperience.validationMessage = validationResult.errorMessage;
 
                         if (validationResult.isValid) {
                             // Adjust the start date if it is before the cutoff
                             Date adjustedStartDate = ex.Start_Date__c < tenYearsBeforeCompletion ? tenYearsBeforeCompletion : ex.Start_Date__c;
                             Date adjustedEndDate = effectiveEndDate;
 
                             // Overlap Logic: Determine if this experience should be halved
                             // Use ex.Job_Type__c directly to ensure we're checking the actual field value
                             Boolean halve = (
                                 (workExperience.jobFunction != null && workExperience.jobFunction == 'Education/Training' &&
                                 workExperience.educationalRole != null && workExperience.educationalRole != 'Professor' &&
                                 workExperience.educationalRole != 'Assistant Professor' && workExperience.educationalRole != 'Adjunct Professor') ||
                                 (ex.Job_Type__c != null && ex.Job_Type__c.equalsIgnoreCase('Full Time Intern'))
                             );
                             // Overlap Logic: Store the range and halving info for overlap calculation
                             Integer workExpIdx = returnGetAllWorkExperiences.workExperiences.size();
                             Map<String, Object> rangeInfo = new Map<String, Object>{
                                 'start' => adjustedStartDate,
                                 'end' => adjustedEndDate,
                                 'halve' => halve,
                                 'company' => workExperience.company,
                                 'workExpIdx' => workExpIdx
                             };
 
                             validRanges.add(rangeInfo);
 
                             // Cut time in half for non-professor educators or full-time interns
                             // Use calendar month calculation to match the formula field: MONTH(End) - MONTH(Start) + 12 * (YEAR(End) - YEAR(Start)) + 1
                             // This counts calendar months inclusively (includes both start and end months)
                             Integer monthsCalc = adjustedEndDate.month() - adjustedStartDate.month() + 12 * (adjustedEndDate.year() - adjustedStartDate.year()) + 1;
                             Decimal timeCalc = Decimal.valueOf(monthsCalc);
                             timeCalc = timeCalc.setScale(1, RoundingMode.HALF_UP);
                             if (halve) {
                                 timeCalc = (timeCalc / 2).setScale(1, RoundingMode.HALF_UP);
                             }
                             workExperience.timeAllotted = Decimal.valueOf(Math.round(timeCalc));
 
                             // Debug logging to help troubleshoot
                             GARP_Common.debugLog('GARP_BC_MyPrograms', 'getAllWorkExperiences', 'Experience calculation',
                                 'Start: ' + adjustedStartDate + ', End: ' + adjustedEndDate + ', MonthsCalc: ' + monthsCalc +
                                 ', JobType: ' + ex.Job_Type__c + ', Halve: ' + halve + ', TimeCalc: ' + timeCalc +
                                 ', Final: ' + workExperience.timeAllotted);
                         }
                     } else {
                         workExperience.isValidExperience = false;
                         workExperience.validationMessage = 'Work experience dates are incomplete or invalid.';
                     }
                 }
 
                 GARP_Common.debugLog('GARP_BC_MyPrograms', 'getAllWorkExperiences', 'add workExperience', workExperience);
                 returnGetAllWorkExperiences.workExperiences.add(workExperience);
             }
 
             // Overlap Warning: Build a map of each day to the list of experiences covering it [added for overlap warning]
             Map<Date, List<Integer>> dayToExperienceIndexes = new Map<Date, List<Integer>>();
             for (Integer idx = 0; idx < validRanges.size(); idx++) {
                 Map<String, Object> rangeInfo = validRanges[idx];
                 Date start = (Date)rangeInfo.get('start');
                 Date endDate = (Date)rangeInfo.get('end');
                 for (Date d = start; d <= endDate; d = d.addDays(1)) {
                     if (!dayToExperienceIndexes.containsKey(d)) {
                         dayToExperienceIndexes.put(d, new List<Integer>());
                     }
                     dayToExperienceIndexes.get(d).add(idx);
                 }
             }
 
             // Overlap Warning: For each experience, count how many days are omitted due to overlap (i.e., days covered by more than one experience)
             Map<Integer, Set<Date>> omittedDaysByExperience = new Map<Integer, Set<Date>>();
             Map<Integer, Set<String>> overlappingCompaniesByExperience = new Map<Integer, Set<String>>();
             for (Date d : dayToExperienceIndexes.keySet()) {
                 List<Integer> indexes = dayToExperienceIndexes.get(d);
                 if (indexes.size() > 1) {
                     for (Integer idx : indexes) {
                         if (!omittedDaysByExperience.containsKey(idx)) {
                             omittedDaysByExperience.put(idx, new Set<Date>());
                         }
                         omittedDaysByExperience.get(idx).add(d);
 
                         // Collect companies for overlap
                         if (!overlappingCompaniesByExperience.containsKey(idx)) {
                             overlappingCompaniesByExperience.put(idx, new Set<String>());
                         }
                         for (Integer otherIdx : indexes) {
                             if (otherIdx != idx) {
                                 String otherCompany = (String)validRanges[otherIdx].get('company');
                                 if (!String.isBlank(otherCompany)) {
                                     overlappingCompaniesByExperience.get(idx).add(otherCompany);
                                 }
                             }
                         }
                     }
                 }
             }
 
             // Overlap Warning: Add overlapWarning to each workExperience if overlap detected
             for (Integer idx = 0; idx < validRanges.size(); idx++) {
                 Map<String, Object> rangeInfo = validRanges[idx];
                 Integer workExpIdx = (Integer)rangeInfo.get('workExpIdx');
                 Set<Date> omittedDays = omittedDaysByExperience.containsKey(idx) ? omittedDaysByExperience.get(idx) : new Set<Date>();
                 Set<String> overlappingCompanies = overlappingCompaniesByExperience.containsKey(idx) ? overlappingCompaniesByExperience.get(idx) : new Set<String>();
                 if (!omittedDays.isEmpty() && !overlappingCompanies.isEmpty()) {
                     OverlapWarning warning = new OverlapWarning();
                     warning.company = String.join(new List<String>(overlappingCompanies), ', ');
                     warning.message = 'Experience overlaps with another experience at ' + warning.company + '. Some or all months may be excluded.';
 
                     // Use workExpIdx to assign the warning to the correct workExperience
                     returnGetAllWorkExperiences.workExperiences[workExpIdx].overlapWarning = warning;
                 }
             }
 
             // Merge all ranges, tracking halving, and calculate unique days (should account for overlaps)
             Map<Date, Boolean> uniqueDays = new Map<Date, Boolean>();
             for (Map<String, Object> rangeInfo : validRanges) {
                 Date start = (Date)rangeInfo.get('start');
                 Date endDate = (Date)rangeInfo.get('end');
                 Boolean halve = (Boolean)rangeInfo.get('halve');
                 for (Date d = start; d <= endDate; d = d.addDays(1)) {
                     // If a day is covered by multiple experiences, if any are not halved, it should not be halved
                     if (!uniqueDays.containsKey(d)) {
                         uniqueDays.put(d, halve);
                     } else if (uniqueDays.get(d) && !halve) {
                         uniqueDays.put(d, false);
                     }
                 }
             }
 
             // Count days, separating halved and full days
             Integer fullDays = 0;
             Integer halfDays = 0;
             for (Boolean halve : uniqueDays.values()) {
                 if (halve) {
                     halfDays++;
                 } else {
                     fullDays++;
                 }
             }
 
             // Total (overlap-aware)
             Decimal totalMonths = (fullDays / 30.44) + ((halfDays / 30.44) / 2);
             returnGetAllWorkExperiences.totalTimeAllotted = Decimal.valueOf(Math.round(totalMonths));
         }
 
         return returnGetAllWorkExperiences;
     }
 
     public static workExperience getWorkExperience(String contactId, String experienceId){
 
         GARP_Common.debugLog('GARP_BC_MyPrograms','getWorkExperience','contactId',contactId);
         GARP_Common.debugLog('GARP_BC_MyPrograms','getWorkExperience','experienceId',experienceId);
 
         workExperience workExperience = new workExperience();
 
         List<Experience__c> lstExperience = [SELECT Id, Program_Requirement__c, Start_Date__c, End_Date__c, Company__r.Name, CompanyOther__c, Title__c,
                                              Type_of_Experience__c, Job_Description__c, Manager_Name__c, Job_Function__c, Risk_Specialty__c, Job_Type__c, Educational_Role__c, Is_Currently_Employed__c
                                              from Experience__c where Contact__c = :contactId AND Id = :experienceId];
         GARP_Common.debugLog('GARP_BC_MyPrograms','getWorkExperience','lstExperience',lstExperience);
 
         if(!lstExperience.isEmpty()) {
             for(Experience__c ex :lstExperience) {
                 workExperience.id = ex.Id;
                 workExperience.programRequirement = ex.Program_Requirement__c;
 
                 workExperience.startDate = GARP_Common.formatDate(ex.Start_Date__c,'MM/dd/yyyy');
                 workExperience.endDate = GARP_Common.formatDate(ex.End_Date__c,'MM/dd/yyyy');
 
                 workExperience.startDateMonth = ex.Start_Date__c.month();
                 workExperience.startDateyear = ex.Start_Date__c.year();
                 workExperience.endDateMonth = ex.End_Date__c.month();
                 workExperience.endDateyear = ex.End_Date__c.year();
 
                 workExperience.isCurrentPosition = ex.Is_Currently_Employed__c;
 
                 if(ex.Company__c != NULL) {
                     workExperience.company = ex.Company__r.Name;
                 } else {
                     workExperience.company = ex.CompanyOther__c;
                 }
                 workExperience.title = ex.Title__c;
                 workExperience.type = ex.Type_of_Experience__c;
                 workExperience.description = ex.Job_Description__c;
                 workExperience.manager = ex.Manager_Name__c;
 
                 workExperience.jobFunction = ex.Job_Function__c;
                 workExperience.riskSpecialty = ex.Risk_Specialty__c;
                 workExperience.jobType = ex.Job_Type__c;
                 workExperience.educationalRole = ex.Educational_Role__c;
 
                 GARP_Common.debugLog('GARP_BC_MyPrograms','getWorkExperience','add workExperience',workExperience);
             }
         }
 
         return workExperience;
     }
 
 
     public static GARP_Common.returnInfo setWorkExperience(String contactId, String canReqId, Experience__c setExp, workExperience workExperience) {
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','contactId',contactId);
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','canReqId',canReqId);
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','workExperience',workExperience);
 
         GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();
 
         if(contactId == NULL || canReqId == NULL || canReqId == NULL || workExperience == NULL) {
             returnInfo.status = 'Failed';
             returnInfo.msg = 'Missing required parameters';
             return returnInfo;
         }
 
         if(!String.IsEmpty(canReqId)) {
             setExp.Program_Requirement__c = canReqId;
         }
         setExp.Contact__c = contactId;
 
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','workExperience.startDate',workExperience.startDate);
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','workExperience.endDate',workExperience.endDate);
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','workExperience.startDateYear',workExperience.startDateYear);
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','workExperience.startDateMonth',workExperience.startDateMonth);
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','workExperience.startDateYear',workExperience.endDateYear);
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','workExperience.startDateMonth',workExperience.endDateMonth);
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','workExperience.isCurrentPosition',workExperience.isCurrentPosition);
 
         Date startDate;
         Date endDate;
         if(workExperience.startDate != NULL && !String.IsEmpty(workExperience.startDate)) {
             startDate = Date.parse(workExperience.startDate);
     } else {
       startDate = Date.NewInstance(workExperience.startDateYear, workExperience.startDateMonth, 1);
         }
 
         if (workExperience.isCurrentPosition != NULL && workExperience.isCurrentPosition) {
             setExp.Is_Currently_Employed__c = true;
             endDate = Date.Today();
         } else {
             setExp.Is_Currently_Employed__c = false;
 
             if(workExperience.startDate == NULL || String.IsEmpty(workExperience.startDate)) {
                 // Set to the end of the moth
                 endDate = Date.NewInstance(workExperience.endDateYear, workExperience.endDateMonth, 1);
                 endDate = endDate.addMonths(1);
                 endDate = endDate.addDays(-1);
             } else {
                 endDate = Date.parse(workExperience.endDate);
             }
         }
 
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','startDate',startDate);
         GARP_Common.debugLog('GARP_BC_MyPrograms','setWorkExperience','endDate',endDate);
 
         Date tenYearsBeforeCompletion = Date.today().addYears(-10);
         ValidationResult validationResult = validateWorkExperienceDateSubmissionCalculation(
             startDate, endDate, tenYearsBeforeCompletion, workExperience.jobType
         );
         if (!validationResult.isValid) {
             returnInfo.status = 'Failed';
             returnInfo.msg = validationResult.errorMessage;
             return returnInfo;
         }
 
     setExp.Start_Date__c = startDate;
         setExp.End_Date__c = endDate;
 
         setExp.Job_Type__c = workExperience.jobType;
         setExp.CompanyOther__c = workExperience.company;
         setExp.Title__c = workExperience.title;
         setExp.Type_of_Experience__c = workExperience.type;
         setExp.Job_Description__c = workExperience.description;
         setExp.Manager_Name__c = workExperience.manager;
 
         setExp.Job_Function__c = workExperience.jobFunction;
         setExp.Risk_Specialty__c = workExperience.riskSpecialty;
         setExp.Job_Type__c = workExperience.jobType;
         setExp.Educational_Role__c = workExperience.educationalRole;
 
         upsert setExp;
 
         returnInfo.status = 'Success';
         return returnInfo;
     }
 
     public static GARP_Common.returnInfo deleteWorkExperience(String contactId, String experienceId){
         GARP_Common.debugLog('GARP_BC_MyPrograms','deleteWorkExperience','contactId',contactId);
         GARP_Common.debugLog('GARP_BC_MyPrograms','deleteWorkExperience','experienceId',experienceId);
 
         GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();
 
         List<Experience__c> lstExperience = [SELECT Id, Program_Requirement__c, Start_Date__c, End_Date__c, Company__r.Name, CompanyOther__c, Title__c,
                                              Type_of_Experience__c, Job_Description__c, Manager_Name__c, Job_Function__c, Risk_Specialty__c, Job_Type__c, Educational_Role__c
                                              from Experience__c where Contact__c = :contactId AND Id = :experienceId];
         GARP_Common.debugLog('GARP_BC_MyPrograms','deleteWorkExperience','lstExperience',lstExperience);
 
         if(!lstExperience.isEmpty()) {
             delete lstExperience;
             returnInfo.status = 'Success';
         } else {
             returnInfo.status = 'Failed';
             returnInfo.msg = 'Work Experience not found';
         }
 
         return returnInfo;
     }

    // OSTA Pop-up
    public class OSTAIDInfo {
        public String IdType;
        public String IdLocation;
        public String IdNumber;
        public String IdExpireDate;
        public Boolean OSTAConsent;
    }

    public static OSTAIDInfo getOSTAIDInfo(Contact contact){
        GARP_Common.debugLog('GARP_BC_MyPrograms','getOSTAIDInfo','contact',contact);

        OSTAIDInfo OSTAIDInfo = new OSTAIDInfo();
        OSTAIDInfo.IdType = contact.ID_Type__c;
        OSTAIDInfo.IdLocation = contact.OSTA_ID_Location__c;
        OSTAIDInfo.IdNumber = contact.ID_Number__c;

        if(contact.ID_Expiration_Date__c != NULL) {
            DateTime inptDt = DateTime.NewInstance(contact.ID_Expiration_Date__c.year(),contact.ID_Expiration_Date__c.month(),contact.ID_Expiration_Date__c.day());
            OSTAIDInfo.IdExpireDate = inptDt.format('MM/dd/yyyy');
        }

        OSTAIDInfo.OSTAConsent = False;

        GARP_Common.debugLog('GARP_BC_MyPrograms','getOSTAIDInfo','OSTAIDInfo',OSTAIDInfo);

        return OSTAIDInfo;
    }

    public static GARP_Common.returnInfo setOSTAIDInfo(Contact contact, OSTAIDInfo OSTAIDInfo){
        GARP_Common.debugLog('GARP_BC_MyPrograms','setOSTAIDInfo','contact',contact);

        GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();

        if(OSTAIDInfo.IdType == NULL || String.IsEmpty(OSTAIDInfo.IdType) ||
           OSTAIDInfo.IdLocation == NULL || String.IsEmpty(OSTAIDInfo.IdLocation) ||
           OSTAIDInfo.IdNumber == NULL || String.IsEmpty(OSTAIDInfo.IdNumber) ||
           OSTAIDInfo.IdExpireDate == NULL ||
           OSTAIDInfo.OSTAConsent == False) {

            returnInfo.status = 'Failed';
            returnInfo.msg = 'Missing required information';
            return returnInfo;

           }

        contact.ID_Type__c = OSTAIDInfo.IdType;
        contact.OSTA_ID_Location__c = OSTAIDInfo.IdLocation;
        contact.ID_Number__c = OSTAIDInfo.IdNumber.Right(5);
        contact.OSTA_Full_ID__c = OSTAIDInfo.IdNumber;
        contact.ID_Expiration_Date__c = date.parse(OSTAIDInfo.IdExpireDate);
        contact.OSTA_Consent__c = DateTime.Now();
        contact.OSTA_Collect_Info__c = False;

        update contact;

        returnInfo.status = 'Success';
        returnInfo.msg = 'OSTA Information Updated';


        return returnInfo;
    }

    static public boolean validateIDFormat(String idNumber, String idLocation, String idType) {

        GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','idNumber',idNumber);
        GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','idLocation',idLocation);
        GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','idType',idType);

        if(idNumber == NULL || String.IsEmpty(idNumber) ||
           idLocation == NULL || String.IsEmpty(idLocation) ||
           idType == NULL || String.IsEmpty(idType)) {
               GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','Something empty','');
               return False;
           }

        String LettersAndNumbersRegex = '^[A-Za-z0-9]+$';
        Pattern PLettersAndNumbersRegex = Pattern.compile(LettersAndNumbersRegex);

        if(idLocation == 'China') {

            if(idType == 'Passport') {
                if(idNumber.length() != 9) {
                    GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','China-Passport Not 9 chars','');
                    return false;
                }

                Matcher MyMatcher = PLettersAndNumbersRegex.matcher(idNumber);
                Boolean result = MyMatcher.matches();
                if(!result) {
                    GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','China-Passport Not letter and numbers','');
                    return false;
                }

                if(idNumber.toUpperCase().indexOf('I') > -1 || idNumber.toUpperCase().indexOf('O') > -1) {
                    GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','China-Passport Contains I or O','');
                    return false;
                }

            } else {
                if(idNumber.length() != 18) {
                    GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','China-License not 18 chars','');
                    return false;
                }
            }

        } else {
            if(idType == 'Passport') {
                if(idNumber.length() < 5 || idNumber.length() > 10) {
                    GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','Non-China-Passport Not between 5 and 10 chars','');
                    return false;
                }

                Matcher MyMatcher = PLettersAndNumbersRegex.matcher(idNumber);
                Boolean result = MyMatcher.matches();
                if(!result) {
                    GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','Non-China-Passport Not letter and numbers','');
                    return false;
                }
            } else {
                if(idNumber.length() < 5 || idNumber.length() > 25) {
                    GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','Non-China-License Not between 5 and 25 chars','');
                    return false;
                }

                Matcher MyMatcher = PLettersAndNumbersRegex.matcher(idNumber);
                Boolean result = MyMatcher.matches();
                if(!result) {
                    GARP_Common.debugLog('GARP_BC_MyPrograms','validateIDFormat','Non-China-License Not letter and numbers','');
                    return false;
                }
            }
        }

        return true;
    }

    public class programInformation {
        public String programCode;
        public String abbrevName;
        public String formalName;
        public String informalName;
        public String policyURL;
        public String regLogoURL;
        public String myProgramsLogoURL;
        public String description;
        public String registrationPath;
    }

    public static programInformation getProgramInformation(String programCode, GARP_BC_Courses.microCourseInfo microCourseInfo) {
        GARP_Common.debugLog('GARP_BC_MyPrograms','getProgramInformation','programCode',programCode);
        GARP_Common.debugLog('GARP_BC_MyPrograms','getProgramInformation','microCourseInfo',microCourseInfo);

        programInformation progInfo = new programInformation();
        programCode = programCode.ToLowerCase();

        if(programCode == 'frm') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'FRM';
            progInfo.formalName = 'Financial Risk Manager (FRM<sup>&reg;</sup>)';
            progInfo.informalName = 'FRM Program';
            progInfo.policyURL = 'https://www.garp.org/frm/exam-policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP%20FRM%20Logo%20-%20Knockout.png';
            progInfo.myProgramsLogoURL = 'https://www.garp.org/hubfs/Portal/My%20Programs/FRM.png';
            progInfo.description = 'The globally recognized standard for those who manage financial risk. Be part of an elite network of 90,000 FRM-Certified Professionals that includes employees at the world’s top banks, asset management firms, consulting firms, and regulators.';
            progInfo.registrationPath = 'frm';
        } else if(programCode == 'erp') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'ERP';
            progInfo.formalName = 'Energy Risk Program (ERP<sup>&reg;</sup>)';
            progInfo.informalName = 'ERP Program';
            progInfo.policyURL = 'https://www.garp.org/erp/exam-policies';
            progInfo.regLogoURL = '';
            progInfo.myProgramsLogoURL = 'https://www.garp.org/hubfs/Portal/My%20Programs/ERP.webp';
            progInfo.description = '';
            progInfo.registrationPath = '';
        } else if(programCode == 'scr') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'SCR';
            progInfo.formalName = 'Sustainability and Climate Risk (SCR<sup>&reg;</sup>)';
            progInfo.informalName = 'SCR Program';
            progInfo.policyURL = 'https://www.garp.org/scr/exam-policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP%20SCR%20Logo%20-%20Knockout.png';
            progInfo.myProgramsLogoURL = 'https://www.garp.org/hubfs/Portal/My%20Programs/SCR.webp';
            progInfo.description = 'From entry-level to executive, across industries such as banking, fintech, hospitality, and more, SCR Certificate Holders are leading their companies with solutions to today’s top issues in climate change and sustainability.';
            progInfo.registrationPath = 'scr';
        } else if(programCode == 'raij') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'RAIJ';
            progInfo.formalName = 'Risk and AI in Japanese (RAI<sup>&trade;</sup>)';
            progInfo.informalName = 'RAIJ Program';
            progInfo.policyURL = 'https://www.garp.org/raij/exam-policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/RAI-short-knockout.png';
            progInfo.myProgramsLogoURL = 'https://www.garp.org/hubfs/Portal/My%20Programs/RAI.webp';
             progInfo.description = 'Risk and AI in Japanese (RAI) program.';
            progInfo.registrationPath = 'raij';
        } else if(programCode == 'rai' || programCode == 'riskai') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'RAI';
            progInfo.formalName = 'Risk and AI (RAI<sup>&trade;</sup>)';
            progInfo.informalName = 'Risk AI Program';
            progInfo.policyURL = 'https://www.garp.org/rai/exam-policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/RAI-short-knockout.png';
            progInfo.myProgramsLogoURL = 'https://www.garp.org/hubfs/Portal/My%20Programs/RAI.webp';
            progInfo.description = 'Your gateway to mastering AI-driven risks. Our new Risk and AI (RAI)™ Certificate offers the knowledge you need to harness the transformative power of AI and machine learning (ML) and ensure AI is deployed responsibly within your organization.';
            progInfo.registrationPath = 'rai';
        } else if(programCode == 'frr') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'FRR';
            progInfo.formalName = 'Financial Risk and Regulation (FRR)';
            progInfo.informalName = 'FRR Program';
            progInfo.policyURL = 'https://www.garp.org/frr/exam-policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP-Courses-Knockout.png';
            progInfo.myProgramsLogoURL = 'https://www.garp.org/hubfs/Portal/My%20Programs/FRR.webp';
            progInfo.description = 'Ideal for finance professionals in risk, auditing, accounting, consulting, compliance, IT, and insurance, the FRR Course illustrates how financial risk impacts assets, institutions and systems, and the global financial infrastructure.';
            progInfo.registrationPath = 'frr';
        } else if(programCode == 'frr25') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'FRR Series';
            progInfo.formalName = 'Financial Risk and Regulation (FRR)<sup>&reg;</sup> Series';
            progInfo.informalName = 'FRR Series Program';
            progInfo.policyURL = 'https://www.garp.org/frr25/exam-policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP-Courses-Knockout.png';
            progInfo.myProgramsLogoURL = 'https://www.garp.org/hubfs/Portal/My%20Programs/FRR.webp';
            progInfo.description = 'Ideal for finance professionals in risk, auditing, accounting, consulting, compliance, IT, and insurance, the FRR Series illustrates how financial risk impacts assets, institutions and systems, and the global financial infrastructure.';
            progInfo.registrationPath = 'frr25';
        } else if(programCode == 'ffr') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'FFR';
            progInfo.formalName = 'Foundations of Financial Risk (FFR)';
            progInfo.informalName = 'FFR Program';
            progInfo.policyURL = 'https://www.garp.org/ffr/exam-policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP-Courses-Knockout.png';
            progInfo.myProgramsLogoURL = 'https://www.garp.org/hubfs/GARP%20Member%20Portal%202.0/Development/Assets/my-programs-list-assets/FFR.jpg';
            progInfo.description = 'Learn the most essential risk topics with this comprehensive course designed for professionals who are new to the profession. The course gives a broad overview of key topics including credit, market, operational risk, insurance risk, and the Basel Accords.';
            progInfo.registrationPath = 'ffr';
        } else if(programCode == 'membership') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'GARP';
            progInfo.formalName = 'GARP Membership';
            progInfo.informalName = 'Membership';
            progInfo.policyURL = 'https://www.garp.org/membership/policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP-Membership-Knockout.png';
            progInfo.registrationPath = 'membership';
        } else if(programCode == 'affiliate') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'GARP';
            progInfo.formalName = 'GARP Affiliate Membership';
            progInfo.informalName = 'Affiliate Membership';
            progInfo.policyURL = 'https://www.garp.org/membership/affiliate-policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP-Membership-Knockout.png';
            progInfo.registrationPath = 'affiliate';
        } else if(programCode == 'webcast') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'GARP';
            progInfo.formalName = 'GARP Webcast';
            progInfo.informalName = 'Webcast';
            progInfo.policyURL = 'https://www.garp.org/events/webcast-policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP-Events-Logo-Knockout.png';
            progInfo.registrationPath = 'webcast';
        } else if(programCode == 'chaptermeeting') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'GARP';
            progInfo.formalName = 'GARP Chapter Meeting';
            progInfo.informalName = 'Chapter Meeting';
            progInfo.policyURL = 'https://www.garp.org/events/chapter-policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP-Events-Logo-Knockout.png';
            progInfo.registrationPath = 'chaptermeeting';
        } else if(programCode == 'event') {
            progInfo.programCode = programCode;
            progInfo.abbrevName = 'GARP';
            progInfo.formalName = 'GARP Event';
            progInfo.informalName = 'Event';
            progInfo.policyURL = 'https://www.garp.org/events/policies';
            progInfo.regLogoURL = 'https://www.garp.org/hubfs/Website/Logos/GARP-Events-Logo-Knockout.png';
            progInfo.registrationPath = 'event';
        } else if(microCourseInfo != NULL) {
            progInfo.programCode = programCode;
            progInfo.abbrevName = microCourseInfo.abbrevName;
            progInfo.formalName = microCourseInfo.formalName;
            progInfo.informalName = microCourseInfo.name;
            progInfo.policyURL = microCourseInfo.policyURL;
            progInfo.regLogoURL = microCourseInfo.registrationLogoURL;
            progInfo.myProgramsLogoURL = microCourseInfo.myProgramsLogoURL;
            progInfo.description = microCourseInfo.description;
            progInfo.registrationPath = 'micro/' + programCode;
        }

        GARP_Common.debugLog('GARP_BC_MyPrograms','getProgramInformation','progInfo',progInfo);
        return progInfo;
    }
}