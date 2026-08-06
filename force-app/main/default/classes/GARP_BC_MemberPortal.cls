public class GARP_BC_MemberPortal {

    // Utilties

    // Get Contact
    public static Contact getContact(String contactId) {
        List<Contact> lstContacts = [SELECT Id, AccountId, Account.recordType.DeveloperName, FirstName, LastName, Email, GARP_Member_ID__c, Last_Day_of_Login__c, Photo_URL__c, Stripe_Customer_ID__c,
                                     GBI_Participant__c, GBI_Analytics_Participant__c, EPP_Data_Manager__c, BenchPrep_Viewer__c,
                                     Currently_Working_Status__c, Area_of_Concentration__c, Industry_Working_Year__c,
                                     Company__c, Corporate_Title__c, Job_Function__c, Risk_Specialty__c, Risk_Management_Working_Year__c,
                                     School_Name__c, Highest_Degree__c, Expected_Graduation_Date__c, Expected_Graduation_Month__c,
                                     Date_Educational_Info_LastUpdated_Member__c, Date_Employment_LastUpdated_GARP_Member__c, Date_Mute_Updated_Profile_GARP_Member__c,
                                     ID_Number__c, ID_Type__c, OSTA_ID_Location__c, ID_Expiration_Date__c, OSTA_Full_ID__c,
                                     Gender__c, Full_Name_in_Chinese__c, Birthdate, HomePhone, OtherPhone, Phone, Currently_in_School_Status__c, Degree_Program_Name__c, Name_as_it_Appears_on_ID__c,
                                     Professional_Designation_ACCA__c, Professional_Designation_CA__c, Professional_Designation_CAIA__c, Professional_Designation_CFA__c,
                                     Professional_Designation_CFP__c, Professional_Designation_CIA__c, Professional_Designation_CMA__c, Professional_Designation_CMT__c,
                                     Professional_Designation_CPA__c, Professional_Designation_CQF__c, Professional_Designation_PMP__c, Professional_Designation_Other__c, Other_Qualifications__c,
                                     First_Name_as_it_Appears_on_ID__c,Middle_Name_as_it_Appears_on_ID__c, Last_Name_as_it_Appears_on_ID__c,
                                     Mobile_Phone_Code__c, MobilePhone, Last_Email_Pref_Update_Date__c,
                                     SMS_Promotional_Updates__c, SMS_Registration_Updates__c,
                                     KPI_Primary_Chapter_Name__c, KPI_Secondary_Chapter_Name__c,
                                     GARP_Directory_Opt_In__c, GARP_Directory_Connect_Feature__c, GARP_Dir_Privacy_Prof_Background__c,
                                     GARP_Dir_Privacy_Job_Information__c, GARP_Dir_Privacy_Additional_Detail__c,
                                     MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Mailing_Address_Company__c,
                                     OSTA_ProvinceTerritory__c, OSTA_City__c, OSTA_District_Country__c, OSTA_Street__c, OSTA_Building_Village__c, OSTA_Recipient_Name__c, OSTA_Phone_Number__c, OSTA_Collect_Info__c,
                                     Account.Billing_Address_Company__c, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingStreet,
                                     KPI_CPE_Current_Cycle__c, KPI_CPE_Last_Completed_Cycle__c, Exam_Prep_Provider_Outreach__c,
                                     GARP_Directory_Connect_Send_Count__c, GARP_Directory_Connect_Recieve_Count__c
                                     FROM Contact
                                     WHERE id = :contactId];
        GARP_Common.debugLog('GARP_BC_MemberPortal','getContact','lstContacts',lstContacts);

        if(!lstContacts.IsEmpty()) {
            return lstContacts[0];
        } else {
            return NULL;
        }
    }

    // Security Check
    public class verifyPortalAccessInfo {
        Public String statusMessage;
        Public Integer statusCode;
        public Date originalMembershipStartDate;
        public MAP<String,Contract> mapContracts;
        public MAP<String,Contract> mapNonDraftContracts;
    }

    public static verifyPortalAccessInfo verifyMemberPortalAccess(String contactId, String accountId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','verifyMemberPortalAccess','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','verifyMemberPortalAccess','accountId',accountId);

        verifyPortalAccessInfo ret = new verifyPortalAccessInfo();

        List<Contract> lstContracts = [SELECT Id, AccountId, Status, StartDate, EndDate, recordType.DeveloperName, Opportunity__c, Opportunity__r.StageName, Membership_Type__c,
                                       All_Requirements_Completed_Date__c, OSTA_Last_Upload_Date__c, Last_Exam_Deferral_Date__c,
                                       (SELECT Id, Name, Status__c, Date_of_Completion__c, Exam__c, Approved_Credits_Total__c, CPE_Credit_Requirement__c, recordType.DeveloperName FROM Candidate_Requirements__r)
                                       FROM Contract
                                       WHERE status in ('Activated','Activated ( Auto-Renew )','Expired','Draft','Completed') AND
                                       AccountId = :accountId
                                       ORDER BY recordType.DeveloperName, StartDate DESC];
        GARP_Common.debugLog('GARP_BC_MemberPortal','verifyMemberPortalAccess','lstContracts',lstContracts);

        if(!lstContracts.IsEmpty()) {
            ret.mapContracts = new MAP<String,Contract>();
            ret.mapNonDraftContracts = new MAP<String,Contract>();
            ret.originalMembershipStartDate = NULL;

            for(Contract con :lstContracts) {

                // Skip Closed Lost Contracts
                //if(con.recordType.DeveloperName == 'Membership' && con.Membership_Type__c == 'Affiliate') {
                    // Allow
                //} else if(con.Opportunity__c == NULL || con.Opportunity__r.StageName == 'Closed Lost') {
                //    continue;
                //}

                Contract findCont = ret.mapContracts.get(con.recordType.DeveloperName);
                if(findCont == NULL) {
                    ret.mapContracts.put(con.recordType.DeveloperName,con);
                }

                if(con.Status != 'Draft') {
                    Contract findNonDraftCont = ret.mapNonDraftContracts.get(con.recordType.DeveloperName);
                    if(findNonDraftCont == NULL) {
                        ret.mapNonDraftContracts.put(con.recordType.DeveloperName,con);
                        if(ret.originalMembershipStartDate == NULL && con.recordType.DeveloperName == 'Membership') {
                            ret.originalMembershipStartDate = con.StartDate;
                        }
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','verifyMemberPortalAccess','mapContracts',ret.mapContracts);
            GARP_Common.debugLog('GARP_BC_MemberPortal','verifyMemberPortalAccess','mapNonDraftContracts',ret.mapNonDraftContracts);

            Contract membershipContract = ret.mapNonDraftContracts.get('Membership');
            GARP_Common.debugLog('GARP_BC_MemberPortal','verifyMemberPortalAccess','membershipContract',membershipContract);

            if(membershipContract != NULL) {
                ret.statusMessage = 'Membership Found';
                ret.statusCode = 200;
            } else {
                ret.statusMessage = 'No Membership Found';
                ret.statusCode = 403;
            }

        } else {
            ret.statusMessage = 'No Contracts Found';
            ret.statusCode = 401;
        }

        GARP_Common.debugLog('GARP_BC_MemberPortal','verifyMemberPortalAccess','final ret',ret);
        return ret;
    }

    // Component Calls

    // Navigation

    public class navBarInfo {
        public String statusMessage;
        public Integer statusCode;
        public String firstName;
        public String lastName;
        public String garpId;
        public String avatarPhotoURL;
        public Boolean OSTAInfoCollection;
        public Boolean isIndividualMember;
        public Boolean isMemberInGoodStanding;        
    }

    public static navBarInfo getNavBarInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getNavBarInfo','contactId',contactId);

        navBarInfo navBarInfo = new navBarInfo();

        Contact contact = getContact(contactId);
        if(contact.GBI_Participant__c && contact.Account.recordType.DeveloperName != 'Individual') {
            navBarInfo.statusMessage = 'Portal Access Denied, GBI Only';
            navBarInfo.statusCode = 403;
            return navBarInfo;
        }

        verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
        if(accessInfo.statusCode != 200) {
            navBarInfo.statusMessage = 'Portal Access Denied';
            navBarInfo.statusCode = accessInfo.statusCode;
            return navBarInfo;
        }

        navBarInfo.firstName = contact.FirstName;
        navBarInfo.lastName = contact.LastName;
        navBarInfo.garpId = contact.GARP_Member_ID__c;
        navBarInfo.avatarPhotoURL = contact.Photo_URL__c;
        
        Contract osatContract = accessInfo.mapNonDraftContracts.get('OSTA_Program');
        navBarInfo.OSTAInfoCollection = False;
        if(contact.OSTA_Collect_Info__c == True || (osatContract != NULL && (osatContract.Status == 'Activated' || osatContract.Status == 'Activated ( Auto-Renew )') && !GARP_BC_MyPrograms.validateIDFormat(contact.OSTA_Full_ID__c, contact.OSTA_ID_Location__c, contact.ID_Type__c))) {
            navBarInfo.OSTAInfoCollection = True;
        }
        
        Contract membershipContract = accessInfo.mapNonDraftContracts.get('Membership');
        navBarInfo.isMemberInGoodStanding = False;
        navBarInfo.isIndividualMember = False;
        if(membershipContract != NULL) {
            if(membershipContract.Membership_Type__c == 'Individual') {
                navBarInfo.isIndividualMember = TRUE;   
                if(membershipContract.Status == 'Activated' || membershipContract.Status == 'Activated ( Auto-Renew )') {
                    navBarInfo.isMemberInGoodStanding = True;
                }
            }
        }
        navBarInfo.statusMessage = 'Success';
        navBarInfo.statusCode = 200;

        if(!GARP_Common.isAdminImpersonating()) {
            contact.Last_Day_of_Login__c = DateTime.Now();
            update contact;
        }
        
        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getNavBarInfo','navBarInfo',navBarInfo);
        return navBarInfo;
    }

    // Dashboard

    // Dashboard Cards: Enrolled Programs, Member Profile, Notifications, CPD, Ad, Directory, My Events
    public class dashboardComponent {
        Public String name;
        Public Integer rankOrder;
    }

    public class returnDashboardInfo {
        public String statusMessage;
        public Integer statusCode;
        public List<dashboardComponent> dashboardComponents;
    }

    public static returnDashboardInfo getDashboardInfo(String contactId, String loadKey){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','contactId',contactId);

        returnDashboardInfo returnDashboardInfo = new returnDashboardInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnDashboardInfo.statusMessage = 'Portal Access Denied';
                returnDashboardInfo.statusCode = accessInfo.statusCode;
                return returnDashboardInfo;
            }

            // Compute dashboard
            returnDashboardInfo.dashboardComponents = new List<dashboardComponent>();

            // Does the member have learning programs?
            GARP_BC_MyPrograms.enrolledPrograms enrolledPrograms = GARP_BC_MyPrograms.getEnrolledPrograms(contactId, accessInfo.mapContracts, loadKey);

            Boolean hasMicroProgam = False;
            if(!enrolledPrograms.microCoursesMap.Values().IsEmpty()) {
                hasMicroProgam = True;
            }

            if(enrolledPrograms.frmProgram != NULL || enrolledPrograms.scrProgram != NULL ||
               enrolledPrograms.frrProgram != NULL || enrolledPrograms.ffrProgram != NULL ||
               enrolledPrograms.frr25Program != NULL || enrolledPrograms.riskaiProgram != NULL || enrolledPrograms.raijProgram != NULL || hasMicroProgam) {
                   dashboardComponent progCard = new dashboardComponent();
                   progCard.name = 'Enrolled Programs';
                   progCard.rankOrder = 1;

                   GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','add learning program',progCard);
                   returnDashboardInfo.dashboardComponents.add(progCard);

                   // Are there any Exam Notifications
                   List<GARP_BC_Exams.examNotificationInfo> lstNotifications = GARP_BC_Exams.getExamMemberNotifications(contactId, NULL);
                   if(!lstNotifications.IsEmpty()) {
                       dashboardComponent examNotificationsCard = new dashboardComponent();
                       examNotificationsCard.name = 'Exam Notifications';
                       examNotificationsCard.rankOrder = 3;

                       GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','add exam notifications card',progCard);
                       returnDashboardInfo.dashboardComponents.add(examNotificationsCard);
                   }
               }

            // CPD Card

            Exam_Attempt__c frmExamAttempt1 = enrolledPrograms.mapLatestExamAttempts.get('FRMI');
            Exam_Attempt__c frmExamAttempt2 = enrolledPrograms.mapLatestExamAttempts.get('FRMII');
            Exam_Attempt__c scrExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('SCRFull');
            Exam_Attempt__c raiExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('RiskAIFull');
            Exam_Attempt__c raijExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('RAIJFull');

            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','frmExamAttempt1',frmExamAttempt1);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','frmExamAttempt2',frmExamAttempt2);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','scrExamAttempt',scrExamAttempt);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','raiExamAttempt',raiExamAttempt);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','raijExamAttempt',raijExamAttempt);

            Contract frmContract = accessInfo.mapContracts.get('FRM_Program');
            Contract erpContract = accessInfo.mapContracts.get('ERP_Program');
            Contract scrContract = accessInfo.mapContracts.get('SCR_Program');
            Contract raiContract = accessInfo.mapContracts.get('Risk_AI_Program');
            Contract raijContract = accessInfo.mapContracts.get('RAIJ_Program');

            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','frmContract',frmContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','erpContract',erpContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','scrContract',scrContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','raiContract',raiContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','raijContract',raijContract);

            Boolean frmLoadingPart1 = False;
            Boolean frmLoadingPart2 = False;
            Boolean scrLoadingPart = False;
            Boolean raiLoadingPart = False;
            Boolean raijLoadingPart = False;

            if(frmExamAttempt1 != NULL) {
                frmLoadingPart1 = GARP_BC_MyPrograms.isLoadingResults(frmExamAttempt1.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            }
            if(frmExamAttempt2 != NULL) {
                frmLoadingPart2 = GARP_BC_MyPrograms.isLoadingResults(frmExamAttempt2.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            }
            if(scrExamAttempt != NULL) {
                scrLoadingPart = GARP_BC_MyPrograms.isLoadingResults(scrExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            }
            if(raiExamAttempt != NULL) {
                raiLoadingPart = GARP_BC_MyPrograms.isLoadingResults(raiExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            }
            if(raijExamAttempt != NULL) {
                raijLoadingPart = GARP_BC_MyPrograms.isLoadingResults(raijExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','frmLoadingPart1',frmLoadingPart1);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','frmLoadingPart2',frmLoadingPart2);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','scrLoadingPart',scrLoadingPart);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','raiLoadingPart',raiLoadingPart);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','raijLoadingPart',raijLoadingPart);

            Integer completedContractCount = 0;
            if(frmContract != NULL && frmContract.Status == 'Completed' && !frmLoadingPart1 && !frmLoadingPart2) {
                completedContractCount++;
            }
            if(scrContract != NULL && scrContract.Status == 'Completed' && !scrLoadingPart) {
                completedContractCount++;
            }
            if(raiContract != NULL && raiContract.Status == 'Completed' && !raiLoadingPart) {
                completedContractCount++;
            }
            if(raijContract != NULL && raijContract.Status == 'Completed' && !raijLoadingPart) {
                completedContractCount++;
            }
            if(erpContract != NULL && erpContract.Status == 'Completed') {
                completedContractCount++;
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','completedContractCount',completedContractCount);

            Contract cpdContract = accessInfo.mapContracts.get('CPE');
            String cpdStatus = (cpdContract != NULL) ? cpdContract.Status : NULL;

            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','cpdContract',cpdContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','cpdStatus',cpdStatus);

            if(cpdStatus != NULL && cpdStatus != 'Cancelled' && cpdStatus != 'Draft' && completedContractCount > 0) {
                dashboardComponent cpdCard = new dashboardComponent();
                cpdCard.name = 'CPD';
                cpdCard.rankOrder = 5;

                GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','add cpd card',cpdCard);
                returnDashboardInfo.dashboardComponents.add(cpdCard);
            }

            Decimal percentComplete = GARP_BC_MemberProfile.computeProfilePercentComplete(contact);

            Boolean isProfileOutDated = isProfileOutDated(contact);
            Boolean isProfileComponentMuted = isProfileComponentMuted(contact);

            if(!isProfileComponentMuted && (percentComplete < 100 || isProfileOutDated)) {
                dashboardComponent profileCard = new dashboardComponent();
                profileCard.name = 'Member Profile';
                profileCard.rankOrder = 8;

                GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','add member profile card',profileCard);
                returnDashboardInfo.dashboardComponents.add(profileCard);
            }

            // Advert Card
            String adType = computeAdType(contactId, accessInfo);
            if(adType != NULL) {
                dashboardComponent adCard = new dashboardComponent();
                adCard.name = 'Advertisement';
                adCard.rankOrder = 10;
                GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','add advert card',adCard);
                returnDashboardInfo.dashboardComponents.add(adCard);
            }

            // Events Card
            List<GARP_BC_Events.memberEventInfo> memberRegistrations = GARP_BC_Events.getMemberEventRegistrationsSummary(contactId, TRUE);
            if(!memberRegistrations.IsEmpty()) {
                dashboardComponent eventsCard = new dashboardComponent();
                eventsCard.name = 'Events';
                eventsCard.rankOrder = 20;
                GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','add events card',eventsCard);
                returnDashboardInfo.dashboardComponents.add(eventsCard);
            }

            // Member Directory Card
            dashboardComponent dirCard = new dashboardComponent();
            dirCard.name = 'Member Directory';
            dirCard.rankOrder = 30;
            GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','add member directory card',dirCard);
            returnDashboardInfo.dashboardComponents.add(dirCard);

            // GBI Portal
            if(contact.GBI_Participant__c) {
                dashboardComponent gbiCard = new dashboardComponent();
                gbiCard.name = 'GBI Portal';
                gbiCard.rankOrder = 40;
                GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','add gbi card',gbiCard);
                returnDashboardInfo.dashboardComponents.add(gbiCard);
            }

            // EPP Portal
            if(contact.EPP_Data_Manager__c) {
                dashboardComponent eppCard = new dashboardComponent();
                eppCard.name = 'EPP Portal';
                eppCard.rankOrder = 50;
                GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','add epp card',eppCard);
                returnDashboardInfo.dashboardComponents.add(eppCard);
            }
            
            // BenchPrep Viewer Card
            if(contact.BenchPrep_Viewer__c) {
                dashboardComponent benchprepCard = new dashboardComponent();
                benchprepCard.name = 'BenchPrep Viewer';
                benchprepCard.rankOrder = 60;
                GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','add benchprepCard card',benchprepCard);
                returnDashboardInfo.dashboardComponents.add(benchprepCard);                
            }

            returnDashboardInfo.statusMessage = 'Success';
            returnDashboardInfo.statusCode = 200;

        


        GARP_Common.debugLog('GARP_BC_MemberPortal','getDashboardInfo','returnDashboardInfo',returnDashboardInfo);

        return returnDashboardInfo;
    }


    // Member Profile Methods

    public class returnComponentUpdateProfileInfo {
        public String statusMessage;
        public Integer statusCode;
        public Boolean isProfileOutDated;
        public Decimal percentComplete;
    }

    public static returnComponentUpdateProfileInfo getComponentUpdateProfileInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentUpdateProfileInfo','contactId',contactId);

        returnComponentUpdateProfileInfo returnComponentUpdateProfileInfo = new returnComponentUpdateProfileInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnComponentUpdateProfileInfo.statusMessage = 'Portal Access Denied';
                returnComponentUpdateProfileInfo.statusCode = accessInfo.statusCode;
                return returnComponentUpdateProfileInfo;
            }

            // Member Profile
            returnComponentUpdateProfileInfo.percentComplete = GARP_BC_MemberProfile.computeProfilePercentComplete(contact);
            returnComponentUpdateProfileInfo.isProfileOutDated = False;
            if(returnComponentUpdateProfileInfo.percentComplete == 100) {
                returnComponentUpdateProfileInfo.isProfileOutDated = isProfileOutDated(contact);
            }

            GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentUpdateProfileInfo','isProfileOutDated',returnComponentUpdateProfileInfo.isProfileOutDated);

            returnComponentUpdateProfileInfo.statusMessage = 'Success';
            returnComponentUpdateProfileInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentUpdateProfileInfo','returnComponentUpdateProfileInfo',returnComponentUpdateProfileInfo);

        return returnComponentUpdateProfileInfo;
    }

    public static Boolean isProfileComponentMuted(Contact contact) {
        Integer daysSinceLastMute=365;
        if(contact.Date_Mute_Updated_Profile_GARP_Member__c != NULL) {
            daysSinceLastMute = contact.Date_Mute_Updated_Profile_GARP_Member__c.daysBetween(Date.Today());
        }
        if(daysSinceLastMute <= 60) {
            return True;
        }
        return False;
    }

    public static Boolean isProfileOutDated(Contact contact) {

        Boolean isProfileOutDated = FALSE;

        Integer daysSinceLastUpdate=0;
        Date lastUpdatedDate = Date.NewInstance(1,1,1970);

        if(contact.Date_Educational_Info_LastUpdated_Member__c != NULL && contact.Date_Educational_Info_LastUpdated_Member__c > lastUpdatedDate) {
            lastUpdatedDate = contact.Date_Educational_Info_LastUpdated_Member__c;
        }
        if(contact.Date_Employment_LastUpdated_GARP_Member__c != NULL && contact.Date_Employment_LastUpdated_GARP_Member__c > lastUpdatedDate) {
            lastUpdatedDate = contact.Date_Employment_LastUpdated_GARP_Member__c;
        }
        daysSinceLastUpdate =  lastUpdatedDate.daysBetween(Date.Today());

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentUpdateProfileInfo','daysSinceLastUpdate',daysSinceLastUpdate);

        if(daysSinceLastUpdate > 365) {
            isProfileOutDated = TRUE;
        }

        return isProfileOutDated;
    }

    public class profileDemographicsFormInfo {
        public Contact contact;
        public List<GARP_Common.Country> countries;
        public List<GARP_Common.Institution> institutions;
        public List<String> industries;
        public List<String> professionalLevels;
        public List<String> jobFunctions;
        public List<String> riskSpecialties;
        public List<String> graduationMonths;
        public List<String> howDidYouHearOptions;
        public List<String> degrees;
        public List<String> workingStatus;
        public List<String> workingYears;
    }

    public class returnProfileDemographicsFormInfo {
        public String statusMessage;
        public Integer statusCode;
        public profileDemographicsFormInfo profileDemographicsFormInfo;
        public GARP_BC_MemberProfile.demographicsContactInfo profileDemographicsContactInfo;
    }

    public static returnProfileDemographicsFormInfo getProfileDemographicsFormInfo(String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getUpdateProfileFormInfo','contactId',contactId);

        returnProfileDemographicsFormInfo returnProfileDemographicsFormInfo = new returnProfileDemographicsFormInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnProfileDemographicsFormInfo.statusMessage = 'Portal Access Denied';
                returnProfileDemographicsFormInfo.statusCode = accessInfo.statusCode;
                return returnProfileDemographicsFormInfo;
            }

            returnProfileDemographicsFormInfo.profileDemographicsFormInfo = new profileDemographicsFormInfo();

            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.countries = GARP_Common.getCountries();
            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.institutions = GARP_Common.getInstitutions();
            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.industries = GARP_Common.getPickListValues('Contact','Area_of_Concentration__c');
            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.professionalLevels = GARP_Common.getPickListValues('Contact','Corporate_Title__c');
            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.jobFunctions = GARP_Common.getPickListValues('Contact','Job_Function__c');
            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.riskSpecialties = GARP_Common.getPickListValues('Contact','Risk_Specialty__c');
            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.graduationMonths = GARP_Common.getPickListValues('Contact','Expected_Graduation_Month__c');
            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.howDidYouHearOptions = GARP_Common.getPickListValues('Contact','How_Did_You_Hear_About_Us__c');
            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.degrees = GARP_Common.getPickListValues('Contact','Highest_Degree__c');
            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.workingStatus = GARP_Common.getPickListValues('Contact','Currently_Working_Status__c');

            returnProfileDemographicsFormInfo.profileDemographicsFormInfo.workingYears = new List<String>();
            Date tdy = Date.today();
            for(Integer i=1990; i<=tdy.year()+10; i++) {
                returnProfileDemographicsFormInfo.profileDemographicsFormInfo.workingYears.add(String.valueOf(i));
            }

            returnProfileDemographicsFormInfo.profileDemographicsContactInfo = GARP_BC_MemberProfile.getDemographicsContactInfo(contact);

            returnProfileDemographicsFormInfo.statusMessage = 'Success';
            returnProfileDemographicsFormInfo.statusCode = 200;

        


        GARP_Common.debugLog('GARP_BC_MemberPortal','getUpdateProfileFormInfo','returnProfileDemographicsFormInfo', returnProfileDemographicsFormInfo);

        return returnProfileDemographicsFormInfo;
    }

    public class returnSetProfileDemographicsFormInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSetProfileDemographicsFormInfo setProfileDemographicsFormInfo(String contactId, GARP_BC_MemberProfile.demographicsContactInfo updateProfileDemographicsContactInfo) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfileDemographicsFormInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfileDemographicsFormInfo','updateProfileDemographicsContactInfo',updateProfileDemographicsContactInfo);

        returnSetProfileDemographicsFormInfo returnSetProfileDemographicsFormInfo = new returnSetProfileDemographicsFormInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetProfileDemographicsFormInfo.statusMessage = 'Portal Access Denied';
                returnSetProfileDemographicsFormInfo.statusCode = accessInfo.statusCode;
                return returnSetProfileDemographicsFormInfo;
            }

            GARP_BC_MemberProfile.setDemographicsContactInfo(contact, updateProfileDemographicsContactInfo);

            returnSetProfileDemographicsFormInfo.statusMessage = 'Success';
            returnSetProfileDemographicsFormInfo.statusCode = 200;

        


        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfileDemographicsFormInfo','returnSetProfileDemographicsFormInfo',returnSetProfileDemographicsFormInfo);

        return returnSetProfileDemographicsFormInfo;
    }

    public class returnMuteProfileComponent {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnMuteProfileComponent muteProfileComponent(String contactId, Boolean mute) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','muteProfileComponent','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','muteProfileComponent','mute',mute);

        returnMuteProfileComponent returnMuteProfileComponent = new returnMuteProfileComponent();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnMuteProfileComponent.statusMessage = 'Portal Access Denied';
                returnMuteProfileComponent.statusCode = accessInfo.statusCode;
                return returnMuteProfileComponent;
            }

            if(mute) {
                contact.Date_Mute_Updated_Profile_GARP_Member__c = system.today();
            } else {
                contact.Date_Mute_Updated_Profile_GARP_Member__c = NULL;
            }
            update contact;

            returnMuteProfileComponent.statusMessage = 'Component Mute Updated';
            returnMuteProfileComponent.statusCode = 200;

        

        return returnMuteProfileComponent;
    }

    public class returnGetProfilePersonalFormInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_MemberProfile.personalInfo personalInfo;
        public profilePersonalFormInfo profilePersonalFormInfo;
    }

    public class profilePersonalFormInfo {
        public List<GARP_Common.MobilePhoneLocations> mobilePhoneLocations;
        public List<GARP_Common.Country> countryOptions;
    }

    public static returnGetProfilePersonalFormInfo getProfilePersonalFormInfo(User user, String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProfilePersonalFormInfo','user',user);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProfilePersonalFormInfo','contactId',contactId);

        returnGetProfilePersonalFormInfo returnGetProfilePersonalFormInfo = new returnGetProfilePersonalFormInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetProfilePersonalFormInfo.statusMessage = 'Portal Access Denied';
                returnGetProfilePersonalFormInfo.statusCode = accessInfo.statusCode;
                return returnGetProfilePersonalFormInfo;
            }
            returnGetProfilePersonalFormInfo.personalInfo = GARP_BC_MemberProfile.getPersonalInfo(user, contact);

            // Return Form Info
            returnGetProfilePersonalFormInfo.profilePersonalFormInfo = new profilePersonalFormInfo();
            List<GARP_Common.Country> countryOptions = GARP_Common.getCountries();
            returnGetProfilePersonalFormInfo.profilePersonalFormInfo.countryOptions = countryOptions;
            returnGetProfilePersonalFormInfo.profilePersonalFormInfo.mobilePhoneLocations = GARP_Common.getMobilePhoneLocations(countryOptions);

            returnGetProfilePersonalFormInfo.statusMessage = 'Personal Information returned';
            returnGetProfilePersonalFormInfo.statusCode = 200;

        

        return returnGetProfilePersonalFormInfo;
    }

    public class returnSetProfilePersonalInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSetProfilePersonalInfo setProfilePersonalInfo(User user, GARP_BC_MemberProfile.personalInfo personalInfo) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfilePersonalInfo','user',user);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfilePersonalInfo','personalInfo',personalInfo);

        returnSetProfilePersonalInfo returnSetProfilePersonalInfo = new returnSetProfilePersonalInfo();

        Contact contact = getContact(user.ContactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetProfilePersonalInfo.statusMessage = 'Portal Access Denied';
                returnSetProfilePersonalInfo.statusCode = accessInfo.statusCode;
                return returnSetProfilePersonalInfo;
            }

            GARP_Common.returnInfo ret = GARP_BC_MemberProfile.setPersonalInfo(contact, personalInfo);

            if(ret.status == 'Success') {
                returnSetProfilePersonalInfo.statusMessage = 'Personal Information returned';
                returnSetProfilePersonalInfo.statusCode = 200;
            } else {
                returnSetProfilePersonalInfo.statusMessage = ret.msg;
                returnSetProfilePersonalInfo.statusCode = ret.errorCode;
            }

        

        return returnSetProfilePersonalInfo;
    }

    public class returnUploadMemberPhoto {
        public String statusMessage;
        public Integer statusCode;
        public String attachmentId;
    }

    public static returnUploadMemberPhoto uploadMemberPhoto(String contactId, String attachmentId, String fileText, String fileName) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfilePersonalInfo','contactId',contactId);

        returnUploadMemberPhoto returnUploadMemberPhoto = new returnUploadMemberPhoto();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnUploadMemberPhoto.statusMessage = 'Portal Access Denied';
                returnUploadMemberPhoto.statusCode = accessInfo.statusCode;
                return returnUploadMemberPhoto;
            }

            GARP_Common.returnInfo ret = GARP_BC_MemberProfile.uploadMemberPhoto(contact, attachmentId, fileText, fileName);


            if(ret.status == 'Success') {
                returnUploadMemberPhoto.attachmentId = ret.msg;
                returnUploadMemberPhoto.statusMessage = 'Succsefully attached';
                returnUploadMemberPhoto.statusCode = 200;
            } else {
                returnUploadMemberPhoto.statusMessage = ret.msg;
                returnUploadMemberPhoto.statusCode = ret.errorCode;
            }

        

        return returnUploadMemberPhoto;
    }

    public class returnSetMemberPhoto {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSetMemberPhoto setMemberPhoto(User user, String contactId, String attachmentId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfilePersonalInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfilePersonalInfo','attachmentId',attachmentId);

        returnSetMemberPhoto returnSetMemberPhoto = new returnSetMemberPhoto();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetMemberPhoto.statusMessage = 'Portal Access Denied';
                returnSetMemberPhoto.statusCode = accessInfo.statusCode;
                return returnSetMemberPhoto;
            }

            GARP_Common.returnInfo ret = GARP_BC_MemberProfile.setMemberPhoto(contact, user.Id, attachmentId);


            if(ret.status == 'Success') {
                returnSetMemberPhoto.statusMessage = ret.msg;
                returnSetMemberPhoto.statusCode = 200;
            } else {
                returnSetMemberPhoto.statusMessage = ret.msg;
                returnSetMemberPhoto.statusCode = ret.errorCode;
            }

        

        return returnSetMemberPhoto;
    }


    public class returnRemoveMemberPhoto {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnRemoveMemberPhoto removeMemberPhoto(String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfilePersonalInfo','contactId',contactId);

        returnRemoveMemberPhoto returnRemoveMemberPhoto = new returnRemoveMemberPhoto();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnRemoveMemberPhoto.statusMessage = 'Portal Access Denied';
                returnRemoveMemberPhoto.statusCode = accessInfo.statusCode;
                return returnRemoveMemberPhoto;
            }

            GARP_Common.returnInfo ret = GARP_BC_MemberProfile.removeMemberPhoto(contact);


            if(ret.status == 'Success') {
                returnRemoveMemberPhoto.statusMessage = 'Personal Information returned';
                returnRemoveMemberPhoto.statusCode = 200;
            } else {
                returnRemoveMemberPhoto.statusMessage = ret.msg;
                returnRemoveMemberPhoto.statusCode = ret.errorCode;
            }

        

        return returnRemoveMemberPhoto;
    }

    public class returnSetEmailPreferenceUpdate {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSetEmailPreferenceUpdate setEmailPreferenceUpdate(String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setEmailPreferenceUpdate','contactId',contactId);

        returnSetEmailPreferenceUpdate returnSetEmailPreferenceUpdate = new returnSetEmailPreferenceUpdate();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetEmailPreferenceUpdate.statusMessage = 'Portal Access Denied';
                returnSetEmailPreferenceUpdate.statusCode = accessInfo.statusCode;
                return returnSetEmailPreferenceUpdate;
            }

            returnSetEmailPreferenceUpdate.statusMessage = 'Email Pref Date Updated';
            returnSetEmailPreferenceUpdate.statusCode = 200;

            contact.Last_Email_Pref_Update_Date__c = DateTime.now();
            update contact;

        

        return returnSetEmailPreferenceUpdate;

    }

    public class returnSetSMSPreferenceUpdate {
        public String statusMessage;
        public Integer statusCode;
        public Boolean smsPromotionalUpdates;
        public Boolean smsRegistrationUpdates;
    }

    public static returnSetSMSPreferenceUpdate setSMSPreferenceUpdate(String contactId, Boolean smsPromotional, Boolean smsRegistration) {
        returnSetSMSPreferenceUpdate returnSetSMSPreferenceUpdate = new returnSetSMSPreferenceUpdate();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetSMSPreferenceUpdate.statusMessage = 'Portal Access Denied';
                returnSetSMSPreferenceUpdate.statusCode = accessInfo.statusCode;
                return returnSetSMSPreferenceUpdate;
            }

            // Set the values
            contact.SMS_Promotional_Updates__c = smsPromotional;
            contact.SMS_Registration_Updates__c = smsRegistration;

            // Update the contact
            update contact;

            // Query back to verify the save worked
            Contact updatedContact = getContact(contactId);
            // Return the saved values
            returnSetSMSPreferenceUpdate.smsPromotionalUpdates = updatedContact.SMS_Promotional_Updates__c;
            returnSetSMSPreferenceUpdate.smsRegistrationUpdates = updatedContact.SMS_Registration_Updates__c;
            returnSetSMSPreferenceUpdate.statusMessage = 'SMS Preferences Updated';
            returnSetSMSPreferenceUpdate.statusCode = 200;

        

        return returnSetSMSPreferenceUpdate;

    }

    public class returnGetProfileMembershipInfo {
        public String statusMessage;
        public Integer statusCode;
        public String GARPId;
        public String memberType;
        public String memberStatus;
        public Date dateJoined;
        public Date membershipExpireDate;
        public String pendingOrderId;
        public Boolean isAutoRenewEnabled;
        public Boolean isCertHolder;
    }

    public static returnGetProfileMembershipInfo getProfileMembershipInfo(String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProfileMembershipInfo','contactId',contactId);

        returnGetProfileMembershipInfo returnGetProfileMembershipInfo = new returnGetProfileMembershipInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetProfileMembershipInfo.statusMessage = 'Portal Access Denied';
                returnGetProfileMembershipInfo.statusCode = accessInfo.statusCode;
                return returnGetProfileMembershipInfo;
            }

            Contract membershipContract = accessInfo.mapNonDraftContracts.get('Membership');
            Contract frmContract = accessInfo.mapNonDraftContracts.get('FRM_Program');
            Contract scrContract = accessInfo.mapNonDraftContracts.get('SCR_Program');
            Contract raiContract = accessInfo.mapNonDraftContracts.get('Risk_AI_Program');
            Contract raijContract = accessInfo.mapNonDraftContracts.get('RAIJ_Program');

            GARP_Common.debugLog('GARP_BC_MemberPortal','getProfileMembershipInfo','membershipContract',membershipContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProfileMembershipInfo','frmContract',frmContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProfileMembershipInfo','scrContract',scrContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProfileMembershipInfo','raiContract',raiContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProfileMembershipInfo','raijContract',raijContract);

            returnGetProfileMembershipInfo.GARPId = contact.GARP_Member_ID__c;
            returnGetProfileMembershipInfo.memberType = membershipContract.Membership_Type__c;
            returnGetProfileMembershipInfo.memberStatus = membershipContract.Status;
            returnGetProfileMembershipInfo.dateJoined = accessInfo.originalMembershipStartDate;
            returnGetProfileMembershipInfo.membershipExpireDate = membershipContract.EndDate;
            returnGetProfileMembershipInfo.isAutoRenewEnabled = False;

            returnGetProfileMembershipInfo.isCertHolder = False;
            if((frmContract != NULL && frmContract.Status == 'Completed') || (scrContract != NULL && scrContract.Status == 'Completed') || (raiContract != NULL && raiContract.Status == 'Completed') || (raijContract != NULL && raijContract.Status == 'Completed')) {
                returnGetProfileMembershipInfo.isCertHolder = True;
            }

            // Find open order for Membership
            Set<String> productCodes = new Set<String>{'MEMI','MEMC'};
            Opportunity latestOpenOpp = GARP_BC_Orders.getLatestOppWithGivenProducts(contact.accountID, productCodes, 'New Lead', NULL);
            if(latestOpenOpp != NULL) {
                returnGetProfileMembershipInfo.pendingOrderId = latestOpenOpp.Id;
            }

            if(membershipContract != NULL && membershipContract.Status == 'Activated ( Auto-Renew )') {
                returnGetProfileMembershipInfo.isAutoRenewEnabled = True;
            }


            returnGetProfileMembershipInfo.statusMessage = 'Membership Information returned';
            returnGetProfileMembershipInfo.statusCode = 200;

        

        return returnGetProfileMembershipInfo;
    }

    public class returnSetMembershipAutorenew {
        public String statusMessage;
        public Integer statusCode;
        public String orderId;
    }

    public static returnSetMembershipAutorenew setAutorenewMembershipOff(String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProfileMembershipInfo','contactId',contactId);

        returnSetMembershipAutorenew returnSetMembershipAutorenew = new returnSetMembershipAutorenew();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetMembershipAutorenew.statusMessage = 'Portal Access Denied';
                returnSetMembershipAutorenew.statusCode = accessInfo.statusCode;
                return returnSetMembershipAutorenew;
            }

            Contract membershipContract = accessInfo.mapContracts.get('Membership');

            GARP_Common.returnInfo ret = GARP_BC_Membership.turnOffAutoRenewal(contact.AccountId, membershipContract);
            if(ret.status != 'Success') {
                returnSetMembershipAutorenew.statusMessage = ret.msg;
                returnSetMembershipAutorenew.statusCode = ret.errorCode;
            }

            returnSetMembershipAutorenew.statusMessage = 'Membership Information returned';
            returnSetMembershipAutorenew.statusCode = 200;

        

        return returnSetMembershipAutorenew;
    }

    
    public class returnEnableAutoRenew {
        public String statusMessage;
        public Integer statusCode;
        public Boolean needPaymentInfo;
    }
        
    public static returnEnableAutoRenew enableAutoRenew(User user, String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','enableAutoRenew','contactId',contactId);
        
        returnEnableAutoRenew returnEnableAutoRenew = new returnEnableAutoRenew();
        
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnEnableAutoRenew.statusMessage = 'Portal Access Denied';
                returnEnableAutoRenew.statusCode = accessInfo.statusCode;
                return returnEnableAutoRenew;
            }

            Contract frmContract = accessInfo.mapContracts.get('FRM_Program');
            Contract scrContract = accessInfo.mapContracts.get('SCR_Program');
            Contract raiContract = accessInfo.mapContracts.get('Risk_AI_Program');
            Contract raijContract = accessInfo.mapContracts.get('RAIJ_Program');

            GARP_Common.debugLog('GARP_BC_MemberPortal','enableAutoRenew','frmContract',frmContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','enableAutoRenew','scrContract',scrContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','enableAutoRenew','raiContract',raiContract);
            GARP_Common.debugLog('GARP_BC_MemberPortal','enableAutoRenew','raijContract',raijContract);

            Boolean isCertHolder = False;
            if((frmContract != NULL && frmContract.Status == 'Completed') || (scrContract != NULL && scrContract.Status == 'Completed') || (raiContract != NULL && raiContract.Status == 'Completed') || (raijContract != NULL && raijContract.Status == 'Completed')) {
                isCertHolder = True;
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','enableAutoRenew','isCertHolder',isCertHolder);
            
            Contract membershipContract = accessInfo.mapContracts.get('Membership');
            GARP_Common.debugLog('GARP_BC_MemberPortal','enableAutoRenew','membershipContract',membershipContract);

            if(membershipContract == NULL || membershipContract.status != 'Activated' ) {
                returnEnableAutoRenew.statusMessage = 'Active Membership contract not found';
                returnEnableAutoRenew.statusCode = 401;
                return returnEnableAutoRenew;
            }

            if(membershipContract != NULL && membershipContract.status == 'Activated ( Auto-Renew )' ) {
                returnEnableAutoRenew.statusMessage = 'Membership auto renewal is already activated';
                returnEnableAutoRenew.statusCode = 501;
                return returnEnableAutoRenew;
            }
            
            GARP_BC_Membership.returnEnableAutoRenew retEnable = GARP_BC_Membership.enableAutoRenew(user, contact, membershipContract, isCertHolder);
            if(retEnable.status != 'Success') {
                returnEnableAutoRenew.statusMessage = retEnable.message;
                returnEnableAutoRenew.statusCode = 500;
                return returnEnableAutoRenew;
            }

            returnEnableAutoRenew.needPaymentInfo = retEnable.needPaymentInfo;
            returnEnableAutoRenew.statusMessage = 'Call Succuess';
            returnEnableAutoRenew.statusCode = 200;

        

        return returnEnableAutoRenew;
    }
    
    public class returnGetProfileChaptersInfo {
        public String statusMessage;
        public Integer statusCode;
        public String chapterPrimary;
        public String chapterSecondary;
        public List<String> chapters;
    }

    public static returnGetProfileChaptersInfo getProfileChaptersInfo(String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProfileChaptersInfo','contactId',contactId);

        returnGetProfileChaptersInfo returnGetProfileChaptersInfo = new returnGetProfileChaptersInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetProfileChaptersInfo.statusMessage = 'Portal Access Denied';
                returnGetProfileChaptersInfo.statusCode = accessInfo.statusCode;
                return returnGetProfileChaptersInfo;
            }

            Contract membershipContract = accessInfo.mapContracts.get('Membership');

            returnGetProfileChaptersInfo.chapterPrimary = contact.KPI_Primary_Chapter_Name__c;
            returnGetProfileChaptersInfo.chapterSecondary = contact.KPI_Secondary_Chapter_Name__c;

            returnGetProfileChaptersInfo.chapters = new List<String>();

            List<Chapter__c> lstChapters = [select Id, Name from Chapter__c where Status__c = 'Active' Order By Name];
            for(Chapter__c c :lstChapters) {
                returnGetProfileChaptersInfo.chapters.add(c.Name);
            }

            returnGetProfileChaptersInfo.statusMessage = 'Membership Information returned';
            returnGetProfileChaptersInfo.statusCode = 200;

        

        return returnGetProfileChaptersInfo;
    }

    public class returnSetProfileChaptersInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSetProfileChaptersInfo setProfileChaptersInfo(String contactId, String chapterPrimary, String chapterSecondary) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfileChaptersInfo','contactId',contactId);

        returnSetProfileChaptersInfo returnSetProfileChaptersInfo = new returnSetProfileChaptersInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetProfileChaptersInfo.statusMessage = 'Portal Access Denied';
                returnSetProfileChaptersInfo.statusCode = accessInfo.statusCode;
                return returnSetProfileChaptersInfo;
            }

            Contract membershipContract = accessInfo.mapContracts.get('Membership');

            contact.KPI_Primary_Chapter_Name__c = chapterPrimary;
            contact.KPI_Secondary_Chapter_Name__c = chapterSecondary;
            update contact;

            returnSetProfileChaptersInfo.statusMessage = 'Chapter Information updated';
            returnSetProfileChaptersInfo.statusCode = 200;

        

        return returnSetProfileChaptersInfo;
    }

    public class returnGetProfileExpertiseInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_MemberProfile.expertiseInfo memberExpertiseInfo;
        List<String> areaOfExpertiseSelectOptions;
        List<String> publishingExperienceSelectOptions;
        List<String> teachingExperienceSelectOptions;
        List<String> expertParticipationSelectOptions;
    }

    public static returnGetProfileExpertiseInfo getProfileExpertiseInfo(String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProfileExpertiseInfo','contactId',contactId);

        returnGetProfileExpertiseInfo returnGetProfileExpertiseInfo = new returnGetProfileExpertiseInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetProfileExpertiseInfo.statusMessage = 'Portal Access Denied';
                returnGetProfileExpertiseInfo.statusCode = accessInfo.statusCode;
                return returnGetProfileExpertiseInfo;
            }

            returnGetProfileExpertiseInfo.memberExpertiseInfo = GARP_BC_MemberProfile.getExpertiseInfo(contact);

            returnGetProfileExpertiseInfo.areaOfExpertiseSelectOptions = GARP_Common.getPickListValues('SME_Registration__c', 'Self_Identification_Topic_Tags__c');
            returnGetProfileExpertiseInfo.publishingExperienceSelectOptions = GARP_Common.getPickListValues('SME_Registration__c', 'Publishing_Experience__c');
            returnGetProfileExpertiseInfo.teachingExperienceSelectOptions = GARP_Common.getPickListValues('SME_Registration__c', 'Teaching_Experience__c');
            returnGetProfileExpertiseInfo.expertParticipationSelectOptions = GARP_Common.getPickListValues('SME_Registration__c', 'Expert_Participation__c');

            returnGetProfileExpertiseInfo.statusMessage = 'Expertise Information returned';
            returnGetProfileExpertiseInfo.statusCode = 200;

        

        return returnGetProfileExpertiseInfo;
    }

    public class returnSetProfileExpertiseInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSetProfileExpertiseInfo setProfileExpertiseInfo(String contactId, GARP_BC_MemberProfile.expertiseInfo expertiseInfo) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfileChaptersInfo','contactId', contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setProfileChaptersInfo','expertiseInfo', expertiseInfo);

        returnSetProfileExpertiseInfo returnSetProfileExpertiseInfo = new returnSetProfileExpertiseInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetProfileExpertiseInfo.statusMessage = 'Portal Access Denied';
                returnSetProfileExpertiseInfo.statusCode = accessInfo.statusCode;
                return returnSetProfileExpertiseInfo;
            }

            GARP_Common.returnInfo ret = GARP_BC_MemberProfile.setExpertiseInfo(contact, expertiseInfo);
            if(ret.status != 'Success') {
                returnSetProfileExpertiseInfo.statusMessage = ret.msg;
                returnSetProfileExpertiseInfo.statusCode = ret.errorCode;
            } else {
                returnSetProfileExpertiseInfo.statusMessage = 'Expertise Information updated';
                returnSetProfileExpertiseInfo.statusCode = 200;
            }

        

        return returnSetProfileExpertiseInfo;
    }

    // Notifications

    public class returnComponentNewNotificationsInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_Exams.examNotificationInfo newNotification;
    }

    public static returnComponentNewNotificationsInfo getComponentNewNotificationsInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentNewNotificationsInfo','contactId',contactId);

        returnComponentNewNotificationsInfo returnComponentNewNotificationsInfo = new returnComponentNewNotificationsInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnComponentNewNotificationsInfo.statusMessage = 'Portal Access Denied';
                returnComponentNewNotificationsInfo.statusCode = accessInfo.statusCode;
                return returnComponentNewNotificationsInfo;
            }

            List<GARP_BC_Exams.examNotificationInfo> lstExamNotifications = GARP_BC_Exams.getExamMemberNotifications(contactId, NULL);
            if(!lstExamNotifications.IsEmpty()) {
                returnComponentNewNotificationsInfo.newNotification = lstExamNotifications[0];
            }

            returnComponentNewNotificationsInfo.statusMessage = 'Success';
            returnComponentNewNotificationsInfo.statusCode = 200;

        


        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentNewNotificationsInfo','returnComponentNewNotificationsInfo',returnComponentNewNotificationsInfo);

        return returnComponentNewNotificationsInfo;
    }

    public class returnGetAllNotificationsInfo {
        public String statusMessage;
        public Integer statusCode;
        public List<GARP_BC_Exams.examNotificationInfo> notifications;
    }

    public static returnGetAllNotificationsInfo getAllNotifications(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getAllNotifications','contactId',contactId);

        returnGetAllNotificationsInfo returnGetAllNotificationsInfo = new returnGetAllNotificationsInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetAllNotificationsInfo.statusMessage = 'Portal Access Denied';
                returnGetAllNotificationsInfo.statusCode = accessInfo.statusCode;
                return returnGetAllNotificationsInfo;
            }

            returnGetAllNotificationsInfo.notifications = GARP_BC_Exams.getExamMemberNotifications(contactId, NULL);

            returnGetAllNotificationsInfo.statusMessage = 'Success';
            returnGetAllNotificationsInfo.statusCode = 200;

        


        GARP_Common.debugLog('GARP_BC_MemberPortal','getAllNotifications','returnGetAllNotificationsInfo',returnGetAllNotificationsInfo);

        return returnGetAllNotificationsInfo;
    }

    // CPD Methods

    public class returnComponentCPDInfo {
        public String statusMessage;
        public Integer statusCode;
        public String cpdCycle;
        public Integer frmTotalNeeded;
        public Integer frmCompleted;
        public Integer erpTotalNeeded;
        public Integer erpCompleted;
        public Integer scrTotalNeeded;
        public Integer scrCompleted;
        public Integer raiTotalNeeded;
        public Integer raiCompleted;
        public Integer creditsRemaining;
    }

    public static returnComponentCPDInfo getComponentCPDInfo(String contactId, String loadKey){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentCPDInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentCPDInfo','loadKey',loadKey);

        returnComponentCPDInfo returnComponentCPDInfo = new returnComponentCPDInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnComponentCPDInfo.statusMessage = 'Portal Access Denied';
                returnComponentCPDInfo.statusCode = accessInfo.statusCode;
                return returnComponentCPDInfo;
            }

            Contract frmContract = accessInfo.mapContracts.get('FRM_Program');
            Contract erpContract = accessInfo.mapContracts.get('ERP_Program');
            Contract scrContract = accessInfo.mapContracts.get('SCR_Program');
            Contract raiContract = accessInfo.mapContracts.get('Risk_AI_Program');

            GARP_BC_MyPrograms.enrolledPrograms enrolledPrograms = GARP_BC_MyPrograms.getEnrolledPrograms(contactId, accessInfo.mapContracts, loadKey);

            Exam_Attempt__c frmExamAttempt1 = enrolledPrograms.mapLatestExamAttempts.get('FRMI');
            Exam_Attempt__c frmExamAttempt2 = enrolledPrograms.mapLatestExamAttempts.get('FRMII');
            Exam_Attempt__c scrExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('SCRFull');
            Exam_Attempt__c raiExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('RiskAIFull');

            Boolean frmLoadingPart1 = False;
            Boolean frmLoadingPart2 = False;
            Boolean scrLoadingPart = False;
            Boolean raiLoadingPart = False;

            if(frmExamAttempt1 != NULL) {
                frmLoadingPart1 = GARP_BC_MyPrograms.isLoadingResults(frmExamAttempt1.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            }
            if(frmExamAttempt2 != NULL) {
                frmLoadingPart2 = GARP_BC_MyPrograms.isLoadingResults(frmExamAttempt1.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            }
            if(scrExamAttempt != NULL) {
                scrLoadingPart = GARP_BC_MyPrograms.isLoadingResults(scrExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            }
            if(raiExamAttempt != NULL) {
                raiLoadingPart = GARP_BC_MyPrograms.isLoadingResults(raiExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
            }

            Contract cpdContract = accessInfo.mapContracts.get('CPE');
            if(cpdContract != NULL) {

                returnComponentCPDInfo.cpdCycle = cpdContract.StartDate.Year() + '/' + cpdContract.EndDate.Year();

                Integer creditsApproved = 0;
                for(Candidate_Requirement__c cr :cpdContract.Candidate_Requirements__r) {
                    if(cr.recordType.DeveloperName == 'CPE' && cr.Approved_Credits_Total__c != NULL) {
                        creditsApproved = Integer.ValueOf(cr.Approved_Credits_Total__c);
                    }
                }

                if(frmContract != NULL && frmContract.Status == 'Completed' && !frmLoadingPart1 && !frmLoadingPart2) {
                    returnComponentCPDInfo.frmTotalNeeded = 40;
                    returnComponentCPDInfo.frmCompleted = creditsApproved;
                    returnComponentCPDInfo.creditsRemaining = returnComponentCPDInfo.frmTotalNeeded - returnComponentCPDInfo.frmCompleted;
                }

                if(scrContract != NULL && scrContract.Status == 'Completed' && !scrLoadingPart) {
                    returnComponentCPDInfo.scrTotalNeeded = 20;
                    returnComponentCPDInfo.scrCompleted = creditsApproved;
                    returnComponentCPDInfo.creditsRemaining = returnComponentCPDInfo.scrTotalNeeded - returnComponentCPDInfo.scrCompleted;
                }

                if(raiContract != NULL && raiContract.Status == 'Completed' && !raiLoadingPart) {
                    returnComponentCPDInfo.raiTotalNeeded = 10;
                    returnComponentCPDInfo.raiCompleted = creditsApproved;
                    returnComponentCPDInfo.creditsRemaining = returnComponentCPDInfo.raiTotalNeeded - returnComponentCPDInfo.raiCompleted;
                }

                if(erpContract != NULL && erpContract.Status == 'Completed') {
                    returnComponentCPDInfo.erpTotalNeeded = 40;
                    returnComponentCPDInfo.erpCompleted = creditsApproved;
                    returnComponentCPDInfo.creditsRemaining = returnComponentCPDInfo.erpTotalNeeded - returnComponentCPDInfo.erpCompleted;
                }

                if(returnComponentCPDInfo.frmCompleted != NULL) {
                    returnComponentCPDInfo.creditsRemaining = returnComponentCPDInfo.frmTotalNeeded - returnComponentCPDInfo.frmCompleted;
                } else if(returnComponentCPDInfo.erpCompleted != NULL) {
                    returnComponentCPDInfo.creditsRemaining = returnComponentCPDInfo.erpTotalNeeded - returnComponentCPDInfo.erpCompleted;
                } else if(returnComponentCPDInfo.scrCompleted != NULL) {
                    returnComponentCPDInfo.creditsRemaining = returnComponentCPDInfo.scrTotalNeeded - returnComponentCPDInfo.scrCompleted;
                } else if(returnComponentCPDInfo.raiCompleted != NULL) {
                    returnComponentCPDInfo.creditsRemaining = returnComponentCPDInfo.raiTotalNeeded - returnComponentCPDInfo.raiCompleted;
                } else {
                    returnComponentCPDInfo.statusMessage = 'User has not completed FRM, ERP, SCR, RAI nor RAIJ program';
                    returnComponentCPDInfo.statusCode = 501;
                }

                returnComponentCPDInfo.statusMessage = 'Success';
                returnComponentCPDInfo.statusCode = 200;

            } else {
                returnComponentCPDInfo.statusMessage = 'CPD Contract not found';
                returnComponentCPDInfo.statusCode = 401;
            }

        


        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentCPDInfo','returnComponentCPDInfo',returnComponentCPDInfo);

        return returnComponentCPDInfo;
    }

    // CPD Listing Page Info
    public class returnCPDListingInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_CPD.cpdProgramInfo CPDProgramInfo;
        public List<GARP_BC_CPD.cpdActivity> featuredCPDActivities;
        public MAP<String, GARP_BC_CPD.cpdActivityFieldInfo> cpdActivityFieldInfo;
        public List<String> areasOfStudy;
        public String cpdHandbookURL;
    }

    public static returnCPDListingInfo getCPDListingInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getCPDListingInfo','contactId',contactId);

        returnCPDListingInfo returnCPDListingInfo = new returnCPDListingInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnCPDListingInfo.statusMessage = 'Portal Access Denied';
                returnCPDListingInfo.statusCode = accessInfo.statusCode;
                return returnCPDListingInfo;
            }

            returnCPDListingInfo.cpdActivityFieldInfo = GARP_BC_CPD.getCPDActivityFieldInfo();
            returnCPDListingInfo.areasOfStudy = GARP_Common.getPickListValues('CPE_Claim__c','Area_of_Study__c');

            returnCPDListingInfo.cpdHandbookURL = 'https://www.garp.org/hubfs/Portal/Assets/GARP_CPD_Brochure_v8.pdf';

            //returnCPDListingInfo.featuredCPDActivities = GARP_BC_CPD.getFeaturedCPDActivitiesInfo();

            GARP_BC_CPD.cpdProgramInfo cpdProgramInfo = GARP_BC_CPD.getCPDProgramInfo(contact, accessInfo.mapContracts);

            if(cpdProgramInfo != NULL) {
                if(cpdProgramInfo.cycles.IsEmpty()) {
                    returnCPDListingInfo.statusMessage = 'No CPD Cycles Found';
                    returnCPDListingInfo.statusCode = 401;
                } else {
                    returnCPDListingInfo.statusMessage = 'CPD Cycles Found';
                    returnCPDListingInfo.statusCode = 200;
                    returnCPDListingInfo.CPDProgramInfo = cpdProgramInfo;
                }
            }

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getCPDListingInfo','returnCPDListingInfo',returnCPDListingInfo);
        return returnCPDListingInfo;
    }

    public class returnGetCPDClaimFormInfo {
        public String statusMessage;
        public Integer statusCode;
        public MAP<String, GARP_BC_CPD.cpdActivityFieldInfo> cpdActivityFieldInfo;
        public List<String> areasOfStudy;
    }

    public static returnGetCPDClaimFormInfo getCPDClaimFormInfo(String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getCPDClaimFormInfo','contactId',contactId);

        returnGetCPDClaimFormInfo returnGetCPDClaimFormInfo = new returnGetCPDClaimFormInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetCPDClaimFormInfo.statusMessage = 'Portal Access Denied';
                returnGetCPDClaimFormInfo.statusCode = accessInfo.statusCode;
                return returnGetCPDClaimFormInfo;
            }

            returnGetCPDClaimFormInfo.cpdActivityFieldInfo = GARP_BC_CPD.getCPDActivityFieldInfo();
            returnGetCPDClaimFormInfo.areasOfStudy = GARP_Common.getPickListValues('CPE_Claim__c','Area_of_Study__c');


            returnGetCPDClaimFormInfo.statusMessage = 'CPD Claim Form Info returned';
            returnGetCPDClaimFormInfo.statusCode = 200;

        

        return returnGetCPDClaimFormInfo;
    }

    // CPD Listing Page Info
    public class returnSetCPDClaimInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSetCPDClaimInfo setCPDClaimInfo(String contactId, GARP_BC_CPD.cpdClaim cpdClaim) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setCPDClaimInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setCPDClaimInfo','cpdClaim',cpdClaim);

        returnSetCPDClaimInfo returnSetCPDClaimInfo = new returnSetCPDClaimInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetCPDClaimInfo.statusMessage = 'Portal Access Denied';
                returnSetCPDClaimInfo.statusCode = accessInfo.statusCode;
                return returnSetCPDClaimInfo;
            }

            GARP_Common.returnInfo ret = GARP_BC_CPD.setCPDClaim(contact.AccountId, contactId, cpdClaim);

            if(ret.status == 'Success') {

                returnSetCPDClaimInfo.statusMessage = 'CPD Claim Added/Updated';
                returnSetCPDClaimInfo.statusCode = 200;

            } else {
                returnSetCPDClaimInfo.statusMessage = ret.msg;
                returnSetCPDClaimInfo.statusCode = 501;
            }

        

        return returnSetCPDClaimInfo;
    }

    public class returnDeleteCPDClaimInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnDeleteCPDClaimInfo deleteCPDClaim(String contactId, String claimId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','deleteCPDClaim','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','deleteCPDClaim','claimID',claimId);

        returnDeleteCPDClaimInfo returnDeleteCPDClaimInfo = new returnDeleteCPDClaimInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnDeleteCPDClaimInfo.statusMessage = 'Portal Access Denied';
                returnDeleteCPDClaimInfo.statusCode = accessInfo.statusCode;
                return returnDeleteCPDClaimInfo;
            }

            GARP_Common.returnInfo ret = GARP_BC_CPD.deleteCPDClaim(claimId);

            if(ret.status == 'Success') {

                returnDeleteCPDClaimInfo.statusMessage = 'CPD Claim Deleted';
                returnDeleteCPDClaimInfo.statusCode = 200;

            } else {
                returnDeleteCPDClaimInfo.statusMessage = ret.msg;
                returnDeleteCPDClaimInfo.statusCode = 501;
            }

        

        return returnDeleteCPDClaimInfo;
    }

    public class returnSetCPDAttestationInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSetCPDAttestationInfo setCPDAttestation(String contactId, String attestationID) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setCPDAttestation','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setCPDAttestation','attestationID',attestationID);

        returnSetCPDAttestationInfo returnSetCPDAttestationInfo = new returnSetCPDAttestationInfo();

        Contact contact = getContact(contactId);

            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetCPDAttestationInfo.statusMessage = 'Portal Access Denied';
                returnSetCPDAttestationInfo.statusCode = accessInfo.statusCode;
                return returnSetCPDAttestationInfo;
            }

            GARP_Common.returnInfo ret = GARP_BC_CPD.setCPDAttestation(attestationID);
            if(ret.status != 'Success') {
                returnSetCPDAttestationInfo.statusMessage = ret.msg;
                returnSetCPDAttestationInfo.statusCode = 501;
            }

            returnSetCPDAttestationInfo.statusMessage = 'CPD Attestation Set';
            returnSetCPDAttestationInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','setCPDAttestation','returnSetCPDAttestationInfo',returnSetCPDAttestationInfo);
        return returnSetCPDAttestationInfo;
    }

    // CPD Activities

    public class returnCPDActivitiesBrowseFormInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_CPD.cpdActivityInfo cpdActivityInfo;
    }

    public static returnCPDActivitiesBrowseFormInfo getCPDActivitiesBrowseFormInfo(String contactId, GARP_BC_CPD.cpdActivitiesFilters cpdActivitiesFilters, String activityId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getCPDActivitiesBrowseFormInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getCPDActivitiesBrowseFormInfo','cpdActivitiesFilters',cpdActivitiesFilters);

        returnCPDActivitiesBrowseFormInfo returnCPDActivitiesBrowseFormInfo = new returnCPDActivitiesBrowseFormInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnCPDActivitiesBrowseFormInfo.statusMessage = 'Portal Access Denied';
                returnCPDActivitiesBrowseFormInfo.statusCode = accessInfo.statusCode;
                return returnCPDActivitiesBrowseFormInfo;
            }

            returnCPDActivitiesBrowseFormInfo.cpdActivityInfo = GARP_BC_CPD.getCPDActivitiesInfo(cpdActivitiesFilters, activityId);

            returnCPDActivitiesBrowseFormInfo.statusMessage = 'CPD Activities Returned';
            returnCPDActivitiesBrowseFormInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getCPDActivitiesBrowseFormInfo','returnCPDActivitiesBrowseFormInfo',returnCPDActivitiesBrowseFormInfo);

        return returnCPDActivitiesBrowseFormInfo;
    }

    public static returnSetCPDClaimInfo setCPDActivityAsClaim(String contactId, GARP_BC_CPD.cpdActivity cpdActivity) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setCPDActivityAsClaim','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setCPDActivityAsClaim','cpdActivity',cpdActivity);

        returnSetCPDClaimInfo returnSetCPDClaimInfo = new returnSetCPDClaimInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetCPDClaimInfo.statusMessage = 'Portal Access Denied';
                returnSetCPDClaimInfo.statusCode = accessInfo.statusCode;
                return returnSetCPDClaimInfo;
            }
            Contract frmContract = accessInfo.mapContracts.get('FRM_Program');
            Contract scrContract = accessInfo.mapContracts.get('SCR_Program');
            Contract raijContract = accessInfo.mapContracts.get('RAIJ_Program');

            GARP_BC_CPD.cpdClaim cpdClaim = new GARP_BC_CPD.cpdClaim(cpdActivity);
            cpdClaim.dateOfCompletion = system.today();

            if(frmContract != NULL && frmContract.Status == 'Completed') {
                cpdClaim.isFRM = TRUE;
            }
            if(scrContract != NULL && scrContract.Status == 'Completed') {
                cpdClaim.isSCR = TRUE;
            }
            // When GARP_BC_CPD.cpdClaim adds isRAIJ: if(raijContract != NULL && raijContract.Status == 'Completed') { cpdClaim.isRAIJ = TRUE; }

            GARP_Common.returnInfo ret = GARP_BC_CPD.setCPDClaim(contact.AccountId, contactId, cpdClaim);

            if(ret.status == 'Success') {
                returnSetCPDClaimInfo.statusMessage = 'CPD Claim Added/Updated';
                returnSetCPDClaimInfo.statusCode = 200;
            } else {
                returnSetCPDClaimInfo.statusMessage = ret.msg;
                returnSetCPDClaimInfo.statusCode = 501;
            }

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','setCPDActivityAsClaim','returnSetCPDClaimInfo',returnSetCPDClaimInfo);

        return returnSetCPDClaimInfo;
    }

    // FRM CV Methods

    public class returnCVPageInfo {
        public String statusMessage;
        public Integer statusCode;
        public List<GARP_Common.Country> countryOptions;
        public String status; // New, In Progress, Submitted, Denied
        public List<GARP_BC_MyPrograms.workExperience> workExperiences;
        public GARP_Common.Address address;
        public GARP_Common.Address OSTAaddress;
        public String OSTArecipient;
        public Decimal totalTimeAllotted;
        public Decimal timeRequired;
        public Boolean isOSTA;
        public Boolean isValidExperienceSubmission;
        public String submissionMessage;
    }


    public static returnCVPageInfo getCVPageInfo(String contactId, String programType) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getCVPageInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getCVPageInfo','programType',programType);

        returnCVPageInfo returnCVPageInfo = new returnCVPageInfo();
        returnCVPageInfo.isOSTA = false;
        returnCVPageInfo.isValidExperienceSubmission = true;
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnCVPageInfo.statusMessage = 'Portal Access Denied';
                returnCVPageInfo.statusCode = accessInfo.statusCode;
                return returnCVPageInfo;
            }

            Contract progContact;
            if(programType.ToUpperCase() == 'FRM') {
                progContact = accessInfo.mapContracts.get('FRM_Program');
            } else {
                progContact = accessInfo.mapContracts.get('ERP_Program');
            }

            if(progContact != NULL) {

                Candidate_Requirement__c cvReq;

                for(Candidate_Requirement__c cr :progContact.Candidate_Requirements__r) {
                    if(cr.recordType.DeveloperName == 'Job_Experience') {
                        cvReq = cr;
                        break;
                    }
                }

                if(cvReq != NULL) {

                    GARP_BC_MyPrograms.returnGetAllWorkExperiences retAllWork = GARP_BC_MyPrograms.getAllWorkExperiences(contactId, progContact.Id, progContact);

                    Decimal validMonths = 0;
                    for (GARP_BC_MyPrograms.workExperience we : retAllWork.workExperiences) {
                        if (we.isValidExperience == true && we.timeAllotted != null && we.timeAllotted > 0) {
                            validMonths += we.timeAllotted;
                        }
                    }

                    if (validMonths >= 24) {
                        returnCVPageInfo.submissionMessage = 'You have met the work experience requirement.';
                        returnCVPageInfo.isValidExperienceSubmission = true;
                    } else {
                        Boolean hasInvalid = false;
                        for (GARP_BC_MyPrograms.workExperience we : retAllWork.workExperiences) {
                            if (we.isValidExperience == false) {
                                hasInvalid = true;
                                break;
                            }
                        }
                        if (hasInvalid) {
                            returnCVPageInfo.submissionMessage = 'One or more work experiences are invalid. Please review your entries.';
                        } else {
                            returnCVPageInfo.submissionMessage = 'Work Experience must be 24 months or greater.';
                        }
                        returnCVPageInfo.isValidExperienceSubmission = false;
                    }

                    // Collect all Experience__c Ids from workExperiences
                    Set<Id> experienceIds = new Set<Id>();
                    for (GARP_BC_MyPrograms.workExperience we : retAllWork.workExperiences) {
                        if (we.id != null) {
                            experienceIds.add(we.id);
                        }
                    }

                    // Query all attachments for these experiences, grouped by ParentId
                    Map<Id, Integer> expIdToAttachmentCount = new Map<Id, Integer>();
                    if (!experienceIds.isEmpty()) {
                        for (AggregateResult ar : [
                            SELECT ParentId, COUNT(Id) cnt
                            FROM Attachment
                            WHERE ParentId IN :experienceIds
                            GROUP BY ParentId
                        ]) {
                            expIdToAttachmentCount.put((Id)ar.get('ParentId'), (Integer)ar.get('cnt'));
                        }
                    }

                    // Set attachmentCount on each workExperience
                    for (GARP_BC_MyPrograms.workExperience we : retAllWork.workExperiences) {
                        we.attachmentCount = expIdToAttachmentCount.containsKey(we.id) ? expIdToAttachmentCount.get(we.id) : 0;
                    }

                    returnCVPageInfo.workExperiences =  retAllWork.workExperiences;

                    returnCVPageInfo.timeRequired = 24;
                    returnCVPageInfo.totalTimeAllotted = retAllWork.totalTimeAllotted;

                    if(cvReq.Status__c == 'Initial' && returnCVPageInfo.workExperiences.IsEmpty()) {
                        returnCVPageInfo.status = 'New';
                    } else if(cvReq.Status__c == 'Initial' && !returnCVPageInfo.workExperiences.IsEmpty()) {
                        returnCVPageInfo.status = 'In Progress';
                    } else if(cvReq.Status__c == 'Ready For Review') {
                        returnCVPageInfo.status = 'Submitted';
                    } else if(cvReq.Status__c == 'Failed Review') {
                        returnCVPageInfo.status = 'Failed Review';
                    }

                    returnCVPageInfo.countryOptions = GARP_Common.getCountries();

                    returnCVPageInfo.address = new GARP_Common.Address();
                    returnCVPageInfo.address.city = Contact.MailingCity;
                    returnCVPageInfo.address.company = Contact.Mailing_Address_Company__c;
                    returnCVPageInfo.address.country = Contact.MailingCountry;
                    returnCVPageInfo.address.phone = Contact.HomePhone;
                    returnCVPageInfo.address.postalCode = Contact.MailingPostalCode;
                    returnCVPageInfo.address.province = Contact.MailingState;
                    GARP_Common.address streets = GARP_Common.parseMultiAddressLine(contact.MailingStreet);
                    returnCVPageInfo.address.street1 = streets.street1;
                    returnCVPageInfo.address.street2 = streets.street2;
                    returnCVPageInfo.address.street3 = streets.street3;

                    Contract osatContract = accessInfo.mapNonDraftContracts.get('OSTA_Program');

                    if(osatContract != NULL && (osatContract.Status == 'Activated' || osatContract.Status == 'Activated ( Auto-Renew )')) {
                        returnCVPageInfo.isOSTA = True;

                        returnCVPageInfo.OSTAaddress = new GARP_Common.Address();
                        returnCVPageInfo.OSTAaddress.city = Contact.OSTA_City__c;
                        returnCVPageInfo.OSTAaddress.country = 'China';
                        returnCVPageInfo.OSTAaddress.phone = Contact.OSTA_Phone_Number__c;
                        returnCVPageInfo.OSTAaddress.province = Contact.OSTA_ProvinceTerritory__c;
                        streets = GARP_Common.parseMultiAddressLine(contact.OSTA_Street__c);
                        returnCVPageInfo.OSTAaddress.street1 = streets.street1;
                        returnCVPageInfo.OSTAaddress.street2 = streets.street2;
                        returnCVPageInfo.OSTAaddress.street3 = streets.street3;

                        returnCVPageInfo.OSTAaddress.district = Contact.OSTA_District_Country__c;
                        returnCVPageInfo.OSTAaddress.town = Contact.OSTA_Building_Village__c;
                        returnCVPageInfo.OSTArecipient = Contact.OSTA_Recipient_Name__c;
                    }

                } else {
                    returnCVPageInfo.statusMessage = 'FRM CV Candidate Requirement not found';
                    returnCVPageInfo.statusCode = 401;
                    returnCVPageInfo.isValidExperienceSubmission = false;
                    return returnCVPageInfo;
                }

            } else {
                returnCVPageInfo.statusMessage = 'Program Contract not found';
                returnCVPageInfo.statusCode = 401;
                returnCVPageInfo.isValidExperienceSubmission = false;
                return returnCVPageInfo;
            }

            returnCVPageInfo.statusMessage = 'CV Info Returned';
            returnCVPageInfo.statusCode = 200;

        GARP_Common.debugLog('GARP_BC_MemberPortal','getCVPageInfo','returnCVPageInfo',returnCVPageInfo);

        return returnCVPageInfo;
    }

    public class returnGetWorkExperienceInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_MyPrograms.workExperience workExperience;

        public List<String> jobFunctions;
        public List<String> riskSpecialties;
        public List<String> jobTypes;
        public List<String> educationalRoles;
        public List<GARP_Common.Institution> institutions;

    }

    public static returnGetWorkExperienceInfo getWorkExperienceInfo(String contactId, String programType, String experienceId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getWorkExperienceInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getWorkExperienceInfo','experienceId',experienceId);

        returnGetWorkExperienceInfo returnGetWorkExperienceInfo = new returnGetWorkExperienceInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetWorkExperienceInfo.statusMessage = 'Portal Access Denied';
                returnGetWorkExperienceInfo.statusCode = accessInfo.statusCode;
                return returnGetWorkExperienceInfo;
            }

            returnGetWorkExperienceInfo.workExperience = GARP_BC_MyPrograms.getWorkExperience(contactId, experienceId);
            if(returnGetWorkExperienceInfo.workExperience == NULL) {
                returnGetWorkExperienceInfo.statusMessage = 'Work Experience not found';
                returnGetWorkExperienceInfo.statusCode = 401;
                return returnGetWorkExperienceInfo;
            }

            returnGetWorkExperienceInfo.jobFunctions = GARP_Common.getPickListValues('Experience__c','Job_Function__c');
            returnGetWorkExperienceInfo.riskSpecialties = GARP_Common.getPickListValues('Experience__c','Risk_Specialty__c');
            returnGetWorkExperienceInfo.jobTypes = GARP_Common.getPickListValues('Experience__c','Job_Type__c');
            returnGetWorkExperienceInfo.educationalRoles = GARP_Common.getPickListValues('Experience__c','Educational_Role__c');

            returnGetWorkExperienceInfo.institutions = GARP_Common.mergeInstitutionsLists();


            returnGetWorkExperienceInfo.statusMessage = 'Work Experience Returned';
            returnGetWorkExperienceInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getWorkExperienceInfo','returnGetWorkExperienceInfo',returnGetWorkExperienceInfo);

        return returnGetWorkExperienceInfo;
    }


    public class returnSetWorkExperienceInfo {
        public String statusMessage;
        public Integer statusCode;
        public Id newExperienceId;
    }

    public static returnSetWorkExperienceInfo setWorkExperienceInfo(String contactId, String programType, String experienceId, GARP_BC_MyPrograms.workExperience workExperiences) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getWorkExperienceInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getWorkExperienceInfo','programType',programType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getWorkExperienceInfo','experienceId',experienceId);

        returnSetWorkExperienceInfo returnSetWorkExperienceInfo = new returnSetWorkExperienceInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetWorkExperienceInfo.statusMessage = 'Portal Access Denied';
                returnSetWorkExperienceInfo.statusCode = accessInfo.statusCode;
                return returnSetWorkExperienceInfo;
            }

            Contract progContact;
            if(programType.ToUpperCase() == 'FRM') {
                progContact = accessInfo.mapContracts.get('FRM_Program');
            } else {
                progContact = accessInfo.mapContracts.get('ERP_Program');
            }

            if(progContact != NULL) {

                Candidate_Requirement__c cvReq;

                for(Candidate_Requirement__c cr :progContact.Candidate_Requirements__r) {
                    if(cr.recordType.DeveloperName == 'Job_Experience') {
                        cvReq = cr;
                        break;
                    }
                }

                if(cvReq != NULL) {
                    GARP_Common.returnInfo retInfo;

                    Experience__c setExp = new Experience__c();

                    if(!String.IsEmpty(workExperiences.Id)) {
                        List<Experience__c> lstExperience = [SELECT Id, Program_Requirement__c, Start_Date__c, Name, Company__c,Title__c,
                                                             Job_Type__c, Type_of_Experience__c,Job_Description__c,End_Date__c,Manager_Name__c
                                                             from Experience__c where Contact__c = :contactId AND Id = :experienceId];
                        GARP_Common.debugLog('GARP_BC_MyPrograms','getWorkExperienceInfo','lstExperience',lstExperience);

                        if(lstExperience.IsEmpty()) {
                            returnSetWorkExperienceInfo.statusMessage = 'Work Experience not found';
                            returnSetWorkExperienceInfo.statusCode = 401;
                            return returnSetWorkExperienceInfo;
                        } else {
                            setExp = lstExperience[0];
                        }
                        retInfo = GARP_BC_MyPrograms.setWorkExperience(contactId, cvReq.Id, setExp, workExperiences);
                    } else {
                        retInfo = GARP_BC_MyPrograms.setWorkExperience(contactId, cvReq.Id, setExp, workExperiences);
                        returnSetWorkExperienceInfo.newExperienceId = setExp.Id;
                    }

                    if(retInfo.status != 'Success') {
                        returnSetWorkExperienceInfo.statusMessage = 'Work Experience not saved';
                        returnSetWorkExperienceInfo.statusCode = 501;
                        return returnSetWorkExperienceInfo;
                    }

                    returnSetWorkExperienceInfo.statusMessage = 'Work Experience saved';
                    returnSetWorkExperienceInfo.statusCode = 200;

                } else {
                    returnSetWorkExperienceInfo.statusMessage = 'FRM CV Candidate Requirement not found';
                    returnSetWorkExperienceInfo.statusCode = 401;
                    return returnSetWorkExperienceInfo;
                }

            } else {
                returnSetWorkExperienceInfo.statusMessage = 'Program Contract not found';
                returnSetWorkExperienceInfo.statusCode = 401;
                return returnSetWorkExperienceInfo;
            }


        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getWorkExperienceInfo','returnSetWorkExperienceInfo',returnSetWorkExperienceInfo);

        return returnSetWorkExperienceInfo;
    }

    public class returnDeleteWorkExperienceInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnDeleteWorkExperienceInfo deleteWorkExperienceInfo(String contactId, String programType, String experienceId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','deleteWorkExperienceInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','deleteWorkExperienceInfo','programType',programType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','deleteWorkExperienceInfo','experienceId',experienceId);

        returnDeleteWorkExperienceInfo returnDeleteWorkExperienceInfo = new returnDeleteWorkExperienceInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnDeleteWorkExperienceInfo.statusMessage = 'Portal Access Denied';
                returnDeleteWorkExperienceInfo.statusCode = accessInfo.statusCode;
                return returnDeleteWorkExperienceInfo;
            }

            GARP_Common.returnInfo retInfo = GARP_BC_MyPrograms.deleteWorkExperience(contactId, experienceId);
             if(retInfo.status != 'Success') {
                returnDeleteWorkExperienceInfo.statusMessage = 'Work Experience not deleted';
                returnDeleteWorkExperienceInfo.statusCode = 401;
                return returnDeleteWorkExperienceInfo;
            }

            returnDeleteWorkExperienceInfo.statusMessage = 'Work Experience deleted';
            returnDeleteWorkExperienceInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','deleteWorkExperienceInfo','returnDeleteWorkExperienceInfo',returnDeleteWorkExperienceInfo);

        return returnDeleteWorkExperienceInfo;
    }

    public class returnSetCVAddressInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSetCVAddressInfo setCVAddressInfo(String contactId, String programType, GARP_Common.Address mailingAddress, GARP_Common.Address OSTAaddress, String OSTArecipient) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setCVAddressInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','deleteWorkExperienceInfo','programType',programType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setCVAddressInfo','mailingAddress',mailingAddress);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setCVAddressInfo','OSTAaddress',OSTAaddress);

        returnSetCVAddressInfo returnSetCVAddressInfo = new returnSetCVAddressInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetCVAddressInfo.statusMessage = 'Portal Access Denied';
                returnSetCVAddressInfo.statusCode = accessInfo.statusCode;
                return returnSetCVAddressInfo;
            }

            contact.MailingCity = mailingAddress.city;
            contact.Mailing_Address_Company__c = mailingAddress.company;
            contact.MailingCountry = mailingAddress.country;
            contact.HomePhone = mailingAddress.phone;
            contact.MailingPostalCode = mailingAddress.postalCode;
            contact.MailingState = mailingAddress.province;
            contact.MailingStreet = GARP_Common.formatAddressTextArea(mailingAddress.street1, mailingAddress.street2, mailingAddress.street3);

            if(OSTAaddress != NULL)  {
                contact.OSTA_City__c = OSTAaddress.city;
                contact.OSTA_Phone_Number__c = OSTAaddress.phone;
                contact.OSTA_ProvinceTerritory__c = OSTAaddress.province;
                contact.OSTA_Street__c = GARP_Common.formatAddressTextArea(OSTAaddress.street1, OSTAaddress.street2, OSTAaddress.street3);
                contact.OSTA_District_Country__c = OSTAaddress.district;
                contact.OSTA_Building_Village__c = OSTAaddress.town;
                contact.OSTA_Recipient_Name__c = OSTArecipient;
            }

            update Contact;

            returnSetCVAddressInfo.statusMessage = 'Address info updated';
            returnSetCVAddressInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getWorkExperienceInfo','returnSetCVAddressInfo',returnSetCVAddressInfo);

        return returnSetCVAddressInfo;
    }

    public class returnSubmitCVInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSubmitCVInfo submitCVInfo(String contactId, String programType) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','submitCVInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','submitCVInfo','programType',programType);

        returnSubmitCVInfo returnSubmitCVInfo = new returnSubmitCVInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSubmitCVInfo.statusMessage = 'Portal Access Denied';
                returnSubmitCVInfo.statusCode = accessInfo.statusCode;
                return returnSubmitCVInfo;
            }

            Contract progContact;
            if(programType.ToUpperCase() == 'FRM') {
                progContact = accessInfo.mapContracts.get('FRM_Program');
            } else {
                progContact = accessInfo.mapContracts.get('ERP_Program');
            }

            if(progContact != NULL) {

                GARP_BC_MyPrograms.returnGetAllWorkExperiences retAllWork = GARP_BC_MyPrograms.getAllWorkExperiences(contactId, progContact.Id, progContact);

                if(retAllWork.totalTimeAllotted < 24) {
                    returnSubmitCVInfo.statusMessage = 'Work Experience is not more than the required 24 months';
                    returnSubmitCVInfo.statusCode = 501;
                    return returnSubmitCVInfo;
                }

                Candidate_Requirement__c cvReq;

                for(Candidate_Requirement__c cr :progContact.Candidate_Requirements__r) {
                    if(cr.recordType.DeveloperName == 'Job_Experience') {
                        cvReq = cr;
                        break;
                    }
                }

                if(cvReq != NULL) {
                    cvReq.Status__c = 'Ready For Review';
                    update cvReq;

                    returnSubmitCVInfo.statusMessage = 'CV Submit Status Updated';
                    returnSubmitCVInfo.statusCode = 200;

                } else {
                    returnSubmitCVInfo.statusMessage = 'FRM CV Candidate Requirement not found';
                    returnSubmitCVInfo.statusCode = 401;
                    return returnSubmitCVInfo;
                }

            } else {
                returnSubmitCVInfo.statusMessage = 'Program Contract not found';
                returnSubmitCVInfo.statusCode = 401;
                return returnSubmitCVInfo;
            }
        

        GARP_Common.debugLog('GARP_BC_MemberPortal','submitCVInfo','returnSubmitCVInfo',returnSubmitCVInfo);

        return returnSubmitCVInfo;
    }

    // My Programs

    public class returnEnrolledProgramsInfo {
        public String statusMessage;
        public Integer statusCode;
        public List<GARP_BC_MyPrograms.enrolledProgramInfo> enrolledPrograms;
        public MAP<String,GARP_BC_Courses.microCourseInfo> microCourseConfig;
    }

    public static returnEnrolledProgramsInfo getComponentEnrolledProgramsInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentEnrolledProgramsInfo','contactId',contactId);

        returnEnrolledProgramsInfo returnEnrolledProgramsInfo = new returnEnrolledProgramsInfo();
        returnEnrolledProgramsInfo.enrolledPrograms = new List<GARP_BC_MyPrograms.enrolledProgramInfo>();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnEnrolledProgramsInfo.statusMessage = 'Portal Access Denied';
                returnEnrolledProgramsInfo.statusCode = accessInfo.statusCode;
                return returnEnrolledProgramsInfo;
            }

            GARP_BC_MyPrograms.enrolledPrograms enrolledPrograms = GARP_BC_MyPrograms.getEnrolledPrograms(contactId, accessInfo.mapContracts, '');
            returnEnrolledProgramsInfo.microCourseConfig = enrolledPrograms.microCourseConfig.mapMicroCourseByCode;

            Integer enrollmentCount = 0;

            if(!enrolledPrograms.mapLatestExamAttempts.IsEmpty()) {

                // mapLatestExamAttempts comes in Admin Date Order
                // So this will grab to two newest registrations
                Set<String> addedPrograms = new Set<String>();
                for(Exam_Attempt__c ea :enrolledPrograms.mapLatestExamAttempts.Values()) {
                    if(!addedPrograms.Contains('FRM') && ea.RPT_Exam_Program__c == 'FRM' && enrolledPrograms.frmProgram != NULL) {
                        returnEnrolledProgramsInfo.enrolledPrograms.add(enrolledPrograms.frmProgram);
                        enrollmentCount++;
                        addedPrograms.add('FRM');
                    }

                    if(!addedPrograms.Contains('SCR') && ea.RPT_Exam_Program__c == 'SCR' && enrolledPrograms.scrProgram != NULL) {
                        returnEnrolledProgramsInfo.enrolledPrograms.add(enrolledPrograms.scrProgram);
                        enrollmentCount++;
                        addedPrograms.add('SCR');
                    }

                    if(!addedPrograms.Contains('RiskAI') && ea.RPT_Exam_Program__c == 'RiskAI' && enrolledPrograms.riskaiProgram != NULL) {
                        returnEnrolledProgramsInfo.enrolledPrograms.add(enrolledPrograms.riskaiProgram);
                        enrollmentCount++;
                        addedPrograms.add('RiskAI');
                    }

                    if(!addedPrograms.Contains('RAIJ') && ea.RPT_Exam_Program__c == 'RAIJ' && enrolledPrograms.raijProgram != NULL) {
                        returnEnrolledProgramsInfo.enrolledPrograms.add(enrolledPrograms.raijProgram);
                        enrollmentCount++;
                        addedPrograms.add('RAIJ');
                    }

                }
            }

            if(enrolledPrograms.frrProgram != NULL && enrollmentCount < 2) {
                returnEnrolledProgramsInfo.enrolledPrograms.add(enrolledPrograms.frrProgram);
                enrollmentCount++;
            }

            if(enrolledPrograms.frr25Program != NULL && enrollmentCount < 2) {
                returnEnrolledProgramsInfo.enrolledPrograms.add(enrolledPrograms.frr25Program);
                enrollmentCount++;
            }

            // Micro Courses
            if(!enrolledPrograms.microCoursesMap.Values().IsEmpty()) {
                for(GARP_BC_MyPrograms.enrolledProgramInfo pi :enrolledPrograms.microCoursesMap.Values()) {
                    returnEnrolledProgramsInfo.enrolledPrograms.add(pi);
                    enrollmentCount++;
                }
            }

            if(enrolledPrograms.ffrProgram != NULL && enrollmentCount < 2) {
                returnEnrolledProgramsInfo.enrolledPrograms.add(enrolledPrograms.ffrProgram);
            }

            returnEnrolledProgramsInfo.statusMessage = 'Success';
            returnEnrolledProgramsInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentEnrolledProgramsInfo','returnEnrolledProgramsInfo',returnEnrolledProgramsInfo);

        return returnEnrolledProgramsInfo;
    }

    // My Programs Page

    public class otherProgramInfo {
        String programType;
        Boolean isRegistrationOpen;
        Date nextRegistrationOpenDate;
        String nextRegistrationOpenAdminName;
        Boolean isMicroCourse;
        GARP_BC_MyPrograms.programInformation programInformation;
    }

    public class completedProgramInfo {
        String programType;
        GARP_BC_MyPrograms.programInformation programInformation;
    }

    public class returnProgramsListingInfo {
        public String statusMessage;
        public Integer statusCode;
        public List<GARP_BC_MyPrograms.enrolledProgramInfo> enrolledPrograms;
        public List<completedProgramInfo> completedPrograms;
        public List<otherProgramInfo> otherPrograms;
        public Boolean hasCPDProgram;
        public Boolean hasExamResults;
        public MAP<String,GARP_BC_Courses.microCourseInfo> microCourseConfig;
    }

    public static returnProgramsListingInfo getProgramsListingInfo(String contactId, String loadKey) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','contactId',contactId);

        returnProgramsListingInfo returnProgramsListingInfo = new returnProgramsListingInfo();
        returnProgramsListingInfo.enrolledPrograms = new List<GARP_BC_MyPrograms.enrolledProgramInfo>();

        returnProgramsListingInfo.completedPrograms = new List<completedProgramInfo>();
        returnProgramsListingInfo.otherPrograms = new List<otherProgramInfo>();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnProgramsListingInfo.statusMessage = 'Portal Access Denied';
                returnProgramsListingInfo.statusCode = accessInfo.statusCode;
                return returnProgramsListingInfo;
            }

            GARP_BC_MyPrograms.enrolledPrograms enrolledPrograms = GARP_BC_MyPrograms.getEnrolledPrograms(contactId, accessInfo.mapContracts, loadKey);
            returnProgramsListingInfo.microCourseConfig = enrolledPrograms.microCourseConfig.mapMicroCourseByCode;

            Set<String> addedPrograms = new Set<String>();
            if(!enrolledPrograms.mapLatestExamAttempts.IsEmpty()) {

                // mapLatestExamAttempts comes in Admin Date Order
                // So this will order by newest registration

                for(Exam_Attempt__c ea :enrolledPrograms.mapLatestExamAttempts.Values()) {
                    if(!addedPrograms.Contains('FRM') && ea.RPT_Exam_Program__c == 'FRM' && enrolledPrograms.frmProgram != NULL) {
                        returnProgramsListingInfo.enrolledPrograms.add(enrolledPrograms.frmProgram);
                        addedPrograms.add('FRM');
                    }

                    if(!addedPrograms.Contains('ERP') && ea.RPT_Exam_Program__c == 'ERP' && enrolledPrograms.erpProgram != NULL) {
                        returnProgramsListingInfo.enrolledPrograms.add(enrolledPrograms.erpProgram);
                        addedPrograms.add('ERP');
                    }

                    if(!addedPrograms.Contains('SCR') && ea.RPT_Exam_Program__c == 'SCR' && enrolledPrograms.scrProgram != NULL) {
                        returnProgramsListingInfo.enrolledPrograms.add(enrolledPrograms.scrProgram);
                        addedPrograms.add('SCR');
                    }

                    if(!addedPrograms.Contains('RiskAI') && ea.RPT_Exam_Program__c == 'RiskAI' && enrolledPrograms.riskaiProgram != NULL) {
                        returnProgramsListingInfo.enrolledPrograms.add(enrolledPrograms.riskaiProgram);
                        addedPrograms.add('RiskAI');
                    }

                    if(!addedPrograms.Contains('RAIJ') && ea.RPT_Exam_Program__c == 'RAIJ' && enrolledPrograms.raijProgram != NULL) {
                        returnProgramsListingInfo.enrolledPrograms.add(enrolledPrograms.raijProgram);
                        addedPrograms.add('RAIJ');
                    }

                }

                GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','addedPrograms',addedPrograms);
                GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','enrolledPrograms',returnProgramsListingInfo.enrolledPrograms);

                returnProgramsListingInfo.hasExamResults = False;
                for(Exam_Attempt__c ea :enrolledPrograms.allExamAttempts) {
                    if(ea.Result__c != NULL && !GARP_BC_MyPrograms.isLoadingResults(ea.Exam_Administration__r.Exam_Results_Loading__c, loadKey) &&
                      (ea.RPT_Exam_Program__c == 'RiskAI' || ea.RPT_Exam_Program__c == 'SCR' || ea.RPT_Exam_Program__c == 'RAIJ' || ea.RPT_Exam_Program__c == 'FRM' || ea.RPT_Exam_Program__c == 'ERP')) {
                        returnProgramsListingInfo.hasExamResults = True;
                    }
                }
                GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','hasExamResults',returnProgramsListingInfo.hasExamResults);

            }

            Integer completedContracts = 0;

            Contract frmContract = accessInfo.mapContracts.get('FRM_Program');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','frmContract',frmContract);

            Exam_Attempt__c frmExamAttempt1 = enrolledPrograms.mapLatestExamAttempts.get('FRMFull');
            if(frmExamAttempt1 == NULL) {
                frmExamAttempt1 = enrolledPrograms.mapLatestExamAttempts.get('FRMI');
            }
            Exam_Attempt__c frmExamAttempt2 = enrolledPrograms.mapLatestExamAttempts.get('FRMII');

            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','frmExamAttempt1',frmExamAttempt1);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','frmExamAttempt2',frmExamAttempt2);

            if(frmContract != NULL && frmExamAttempt1 != NULL) {
                Boolean isLoadingPart1 = GARP_BC_MyPrograms.isLoadingResults(frmExamAttempt1.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
                Boolean isLoadingPart2 = False;
                if(frmExamAttempt2 != NULL) {
                    isLoadingPart2 = GARP_BC_MyPrograms.isLoadingResults(frmExamAttempt2.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
                }
                GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','isLoadingPart1',isLoadingPart1);
                GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','isLoadingPart2',isLoadingPart2);

                if(frmContract.Status == 'Completed' && !isLoadingPart1 && !isLoadingPart2) {
                    addedPrograms.add('FRM');

                    completedProgramInfo completedProgramInfo = new completedProgramInfo();
                    completedProgramInfo.programType = 'FRM';
                    completedProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('FRM',NULL);
                    returnProgramsListingInfo.completedPrograms.add(completedProgramInfo);

                    completedContracts++;
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','FRM completedPrograms',returnProgramsListingInfo.completedPrograms);
                }
            }

            Contract erpContract = accessInfo.mapContracts.get('ERP_Program');
            if(erpContract != NULL && erpContract.Status == 'Completed') {
                completedProgramInfo completedProgramInfo = new completedProgramInfo();
                completedProgramInfo.programType = 'ERP';
                completedProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('ERP',NULL);
                returnProgramsListingInfo.completedPrograms.add(completedProgramInfo);

                completedContracts++;
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','ERP completedPrograms',returnProgramsListingInfo.completedPrograms);

            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','addedPrograms',addedPrograms);

            if(!addedPrograms.Contains('FRM')) {
                otherProgramInfo otherProgramInfo = new otherProgramInfo();
                otherProgramInfo.programType = 'FRM';
                otherProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation(otherProgramInfo.programType, NULL);

                GARP_BC_MyPrograms.currentNextExamAdminRegInfo currentNextExamAdminRegInfo = GARP_BC_MyPrograms.getCurrentNextExamAdminRegInfo('FRM');
                if(currentNextExamAdminRegInfo != NULL) {
                    if(currentNextExamAdminRegInfo.isRegistrationOpen) {
                        otherProgramInfo.isRegistrationOpen = True;
                    } else {
                        otherProgramInfo.isRegistrationOpen = False;
                        otherProgramInfo.nextRegistrationOpenDate = currentNextExamAdminRegInfo.nextExamAdminRegistrationOpenDate;
                        otherProgramInfo.nextRegistrationOpenAdminName = currentNextExamAdminRegInfo.nextExamAdminName;
                    }
                    returnProgramsListingInfo.otherPrograms.add(otherProgramInfo);
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add FRM Other',otherProgramInfo);
                }
            }

            Contract scrContract = accessInfo.mapContracts.get('SCR_Program');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','scrContract',scrContract);

            Exam_Attempt__c scrExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('SCRFull');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','scrExamAttempt',scrExamAttempt);

            if(scrContract != NULL && scrExamAttempt != NULL) {
                Boolean isLoadingPart = GARP_BC_MyPrograms.isLoadingResults(scrExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
                if(scrContract.Status == 'Completed' && !isLoadingPart) {
                    addedPrograms.add('SCR');

                    completedProgramInfo completedProgramInfo = new completedProgramInfo();
                    completedProgramInfo.programType = 'SCR';
                    completedProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('SCR',NULL);
                    returnProgramsListingInfo.completedPrograms.add(completedProgramInfo);

                    completedContracts++;
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','SCR completedPrograms',returnProgramsListingInfo.completedPrograms);
                }
            }

            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','addedPrograms',addedPrograms);

            if(!addedPrograms.Contains('SCR')) {

                otherProgramInfo otherProgramInfo = new otherProgramInfo();
                otherProgramInfo.programType = 'SCR';
                otherProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation(otherProgramInfo.programType, NULL);

                GARP_BC_MyPrograms.currentNextExamAdminRegInfo currentNextExamAdminRegInfo = GARP_BC_MyPrograms.getCurrentNextExamAdminRegInfo('SCR');
                if(currentNextExamAdminRegInfo != NULL) {
                    if(currentNextExamAdminRegInfo.isRegistrationOpen) {
                        otherProgramInfo.isRegistrationOpen = True;
                    } else {
                        otherProgramInfo.isRegistrationOpen = False;
                        otherProgramInfo.nextRegistrationOpenDate = currentNextExamAdminRegInfo.nextExamAdminRegistrationOpenDate;
                        otherProgramInfo.nextRegistrationOpenAdminName = currentNextExamAdminRegInfo.nextExamAdminName;
                    }
                    returnProgramsListingInfo.otherPrograms.add(otherProgramInfo);
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add SCR Other',otherProgramInfo);
                }
            }

            
            Contract raijContract = accessInfo.mapContracts.get('RAIJ_Program');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','raijContract',raijContract);

            Exam_Attempt__c raijExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('RAIJFull');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','raijExamAttempt',raijExamAttempt);

            if(raijContract != NULL && raijExamAttempt != NULL) {
                Boolean isLoadingPart = GARP_BC_MyPrograms.isLoadingResults(raijExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
                if(raijContract.Status == 'Completed' && !isLoadingPart) {
                    addedPrograms.add('RAIJ');

                    completedProgramInfo completedProgramInfo = new completedProgramInfo();
                    completedProgramInfo.programType = 'RAIJ';
                    completedProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('RAIJ',NULL);
                    returnProgramsListingInfo.completedPrograms.add(completedProgramInfo);

                    completedContracts++;
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','RAIJ completedPrograms',returnProgramsListingInfo.completedPrograms);
                }
            }
            
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','addedPrograms',addedPrograms);
            
            
            if(!addedPrograms.Contains('RAIJ')) {

                otherProgramInfo otherProgramInfo = new otherProgramInfo();
                otherProgramInfo.programType = 'RAIJ';
                otherProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation(otherProgramInfo.programType, NULL);

                GARP_BC_MyPrograms.currentNextExamAdminRegInfo currentNextExamAdminRegInfo = GARP_BC_MyPrograms.getCurrentNextExamAdminRegInfo('RAIJ');
                if(currentNextExamAdminRegInfo != NULL) {
                    if(currentNextExamAdminRegInfo.isRegistrationOpen) {
                        otherProgramInfo.isRegistrationOpen = True;
                    } else {
                        otherProgramInfo.isRegistrationOpen = False;
                        otherProgramInfo.nextRegistrationOpenDate = currentNextExamAdminRegInfo.nextExamAdminRegistrationOpenDate;
                        otherProgramInfo.nextRegistrationOpenAdminName = currentNextExamAdminRegInfo.nextExamAdminName;
                    }
                    returnProgramsListingInfo.otherPrograms.add(otherProgramInfo);
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add RAIJ Other',otherProgramInfo);
                }
            }
             
            
            Contract riskaiContract = accessInfo.mapContracts.get('Risk_AI_Program');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','riskaiContract',riskaiContract);

            Exam_Attempt__c riskaiExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('RiskAIFull');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','riskaiExamAttempt',riskaiExamAttempt);

            if(riskaiContract != NULL && riskaiExamAttempt != NULL) {
                Boolean isLoadingPart = GARP_BC_MyPrograms.isLoadingResults(riskaiExamAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
                if(riskaiContract.Status == 'Completed' && !isLoadingPart) {
                    addedPrograms.add('RiskAI');
                    
                    completedProgramInfo completedProgramInfo = new completedProgramInfo();
                    completedProgramInfo.programType = 'RiskAI';
                    completedProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('RAI',NULL);
                    returnProgramsListingInfo.completedPrograms.add(completedProgramInfo);

                    completedContracts++;
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','RAI completedPrograms',returnProgramsListingInfo.completedPrograms);
                }
            }

            if(!addedPrograms.Contains('RiskAI') && raijContract == NULL) {

                otherProgramInfo otherProgramInfo = new otherProgramInfo();
                otherProgramInfo.programType = 'RiskAI';
                otherProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation(otherProgramInfo.programType, NULL);

                GARP_BC_MyPrograms.currentNextExamAdminRegInfo currentNextExamAdminRegInfo = GARP_BC_MyPrograms.getCurrentNextExamAdminRegInfo('RiskAI');
                if(currentNextExamAdminRegInfo != NULL) {
                    if(currentNextExamAdminRegInfo.isRegistrationOpen) {
                        otherProgramInfo.isRegistrationOpen = True;
                    } else {
                        otherProgramInfo.isRegistrationOpen = False;
                        otherProgramInfo.nextRegistrationOpenDate = currentNextExamAdminRegInfo.nextExamAdminRegistrationOpenDate;
                        otherProgramInfo.nextRegistrationOpenAdminName = currentNextExamAdminRegInfo.nextExamAdminName;
                    }
                    returnProgramsListingInfo.otherPrograms.add(otherProgramInfo);
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add RAI Other',otherProgramInfo);
                }
            }

            returnProgramsListingInfo.hasCPDProgram = False;
            Contract cpdContract = accessInfo.mapContracts.get('CPE');
            if(cpdContract != NULL && (cpdContract.Status == 'Activated' || cpdContract.Status == 'Activated ( Auto-Renew )') && completedContracts > 0) {
                returnProgramsListingInfo.hasCPDProgram = True;
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','hasCPDProgram',returnProgramsListingInfo.hasCPDProgram);
            
            // FRR Switch Over
            List<Exam_Group__c> examGroups = [select Id, Active__c, RecordType.Name from Exam_Group__c where RecordType.Name in ('MicroCourse','ICBRR','FRR25')];
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','examGroups',examGroups);
            
            Boolean icbrrActive = False;
            Boolean frr25Active = False;
            Boolean microcoursesActive = False;
            for(Exam_Group__c eg :examGroups) {
                if(eg.RecordType.Name == 'MicroCourse') {
                    microcoursesActive = eg.Active__c;
                } else if(eg.RecordType.Name == 'FRR25') {
                    frr25Active = eg.Active__c;
                } else if(eg.RecordType.Name == 'ICBRR') {
                    icbrrActive = eg.Active__c;
                }
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','microcoursesActive',microcoursesActive);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','frr25Active',frr25Active);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','frr25Active',frr25Active);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','icbrrActive',icbrrActive);
            
            if(enrolledPrograms.frrProgram != NULL) {
                returnProgramsListingInfo.enrolledPrograms.add(enrolledPrograms.frrProgram);
                GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add FRR Enrolled',returnProgramsListingInfo.enrolledPrograms);
            } else {
                Contract frrContract = accessInfo.mapContracts.get('ICBRR_Program');
                GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','frrContract',frrContract);

                if(frrContract != NULL && frrContract.Status == 'Completed') {
                    completedProgramInfo completedProgramInfo = new completedProgramInfo();
                    completedProgramInfo.programType = 'FRR';
                    completedProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('FRR',NULL);
                    returnProgramsListingInfo.completedPrograms.add(completedProgramInfo);

                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add FRR Completed',returnProgramsListingInfo.completedPrograms);
                } else {

                    /* Block FRR If Retake Only */
                    if(icbrrActive) {
                        otherProgramInfo otherProgramInfo = new otherProgramInfo();
                        otherProgramInfo.programType = 'FRR';
                        otherProgramInfo.isRegistrationOpen = True;
                        otherProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation(otherProgramInfo.programType, NULL);
    
                        returnProgramsListingInfo.otherPrograms.add(otherProgramInfo);
                        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add FRR Other',otherProgramInfo);
                    }
                }
            }
            
            if(frr25Active) {                
                if(enrolledPrograms.frr25Program != NULL) {
                    returnProgramsListingInfo.enrolledPrograms.add(enrolledPrograms.frr25Program);
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add FRR25 Enrolled',returnProgramsListingInfo.enrolledPrograms);
                } else {
                    Contract frr25Contract = accessInfo.mapContracts.get('FRR25_Program');
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','frr25Contract',frr25Contract);
                    
                    if(frr25Contract != NULL && frr25Contract.Status == 'Completed') {
                        completedProgramInfo completedProgramInfo = new completedProgramInfo();
                        completedProgramInfo.programType = 'FRR25';
                        completedProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('FRR25',NULL);
                        returnProgramsListingInfo.completedPrograms.add(completedProgramInfo);
                        
                        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add FRR25 Completed',returnProgramsListingInfo.completedPrograms);
                    } else {
                        
                        otherProgramInfo otherProgramInfo = new otherProgramInfo();
                        otherProgramInfo.programType = 'FRR25';
                        otherProgramInfo.isRegistrationOpen = True;
                        otherProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation(otherProgramInfo.programType, NULL);
                        
                        returnProgramsListingInfo.otherPrograms.add(otherProgramInfo);
                        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add FRR25 Other',otherProgramInfo);
                    }
                }
            }
            
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','microCourseConfig',enrolledPrograms.microCourseConfig);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','microCoursesMap',enrolledPrograms.microCoursesMap);

            // Micro Courses
            if(microcoursesActive) {
                if(!enrolledPrograms.microCourseConfig.mapMicroCourseByCode.Values().IsEmpty()) {
                    for(GARP_BC_Courses.microCourseInfo mci :enrolledPrograms.microCourseConfig.mapMicroCourseByCode.Values()) {
                        
                        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Loop micro',mci.courseCode);
                        
                        GARP_BC_MyPrograms.enrolledProgramInfo fndProg = enrolledPrograms.microCoursesMap.get(mci.courseCode);
                        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','fndProg',fndProg);
                        
                        if(enrolledPrograms.microCoursesMap.get(mci.courseCode) != NULL) {
                            returnProgramsListingInfo.enrolledPrograms.add(fndProg);
                            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add Micro Course Enrolled',returnProgramsListingInfo.enrolledPrograms);
                        } else {
                            Contract microContract = accessInfo.mapContracts.get(mci.programRecordTypeAPIName);
                            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','microContract',microContract);
                            
                            if(microContract != NULL && microContract.Status == 'Completed') {
                                
                                completedProgramInfo completedProgramInfo = new completedProgramInfo();
                                completedProgramInfo.programType = mci.courseCode;
                                completedProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation(mci.courseCode,mci);
                                returnProgramsListingInfo.completedPrograms.add(completedProgramInfo);
                                
                                GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add Micro Course Completed',returnProgramsListingInfo.completedPrograms);
                            } else {
                                
                                /* Not going to show them, B2B Only
                                otherProgramInfo otherProgramInfo = new otherProgramInfo();
                                otherProgramInfo.programType = mci.courseCode;
                                otherProgramInfo.isRegistrationOpen = True;
                                otherProgramInfo.isMicroCourse = True;
                                otherProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation(otherProgramInfo.programType, mci);
                                
                                returnProgramsListingInfo.otherPrograms.add(otherProgramInfo);
                                GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add Micro Course Other',otherProgramInfo);
                                */
                            }
                        }
                    }
                }
            }
            
            if(enrolledPrograms.ffrProgram != NULL) {
                returnProgramsListingInfo.enrolledPrograms.add(enrolledPrograms.ffrProgram);
                GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add FFR Enrolled',returnProgramsListingInfo.enrolledPrograms);
            } else {
                Contract ffrContract = accessInfo.mapContracts.get('FBR_Program');

                if(ffrContract != NULL && ffrContract.Status == 'Completed') {
                    completedProgramInfo completedProgramInfo = new completedProgramInfo();
                    completedProgramInfo.programType = 'FFR';
                    completedProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation('FFR',NULL);
                    returnProgramsListingInfo.completedPrograms.add(completedProgramInfo);

                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add FFR Completed',returnProgramsListingInfo.completedPrograms);
                } else {

                    otherProgramInfo otherProgramInfo = new otherProgramInfo();
                    otherProgramInfo.programType = 'FFR';
                    otherProgramInfo.isRegistrationOpen = True;
                    otherProgramInfo.programInformation = GARP_BC_MyPrograms.getProgramInformation(otherProgramInfo.programType, NULL);

                    returnProgramsListingInfo.otherPrograms.add(otherProgramInfo);
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','Add FFR Other',otherProgramInfo);

                }
            }

            returnProgramsListingInfo.statusMessage = 'Success';
            returnProgramsListingInfo.statusCode = 200;

        


        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramsListingInfo','returnProgramsListingInfo',returnProgramsListingInfo);

        return returnProgramsListingInfo;
    }

    // FRR, FFR Course Details

    public static GARP_BC_StudyMaterials.eBook getMostRecentEBook(Contact contact, String programType, List<GARP_BC_StudyMaterials.eBook> myEBooks) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getMostRecentEBook','contact',contact);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getMostRecentEBook','programType',programType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getMostRecentEBook','myEBooks',myEBooks);

        GARP_BC_StudyMaterials.eBook recentEBook;
        Integer lastYear = 1970;
        for(GARP_BC_StudyMaterials.eBook eBook :myEBooks) {
            if(eBook.type == programType) {
                if(eBook.year > lastYear) {
                    recentEBook = eBook;
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_MemberPortal','getMostRecentEBook','recentEBook',recentEBook);

        return recentEBook;

    }

    // programType = FRR / FFR

    public class returnCourseInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_MyPrograms.courseDetailInfo courseDetailInfo;
    }

    public static returnCourseInfo getFRRProgramDetailInfo(String contactId){
        returnCourseInfo returnCourseInfo = new returnCourseInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnCourseInfo.statusMessage = 'Portal Access Denied';
                returnCourseInfo.statusCode = accessInfo.statusCode;
                return returnCourseInfo;
            }

            GARP_BC_MyPrograms.returnCourseInfo retGetCourseInfo = GARP_BC_MyPrograms.getCourseProgramDetailInfo(contact, 'FRR', accessInfo.mapContracts);
            returnCourseInfo.statusMessage = retGetCourseInfo.statusMessage;
            returnCourseInfo.statusCode = retGetCourseInfo.statusCode;
            returnCourseInfo.courseDetailInfo = retGetCourseInfo.courseDetailInfo;

            returnCourseInfo.statusMessage = 'Program Information Returned';
            returnCourseInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getFRRProgramsDetailInfo','returnCourseInfo',returnCourseInfo);

        return returnCourseInfo;
    }

    public static returnCourseInfo getFRR25ProgramDetailInfo(String contactId){
        returnCourseInfo returnCourseInfo = new returnCourseInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnCourseInfo.statusMessage = 'Portal Access Denied';
                returnCourseInfo.statusCode = accessInfo.statusCode;
                return returnCourseInfo;
            }

            GARP_BC_MyPrograms.returnCourseInfo retGetCourseInfo = GARP_BC_MyPrograms.getCourseProgramDetailInfo(contact, 'FRR25', accessInfo.mapContracts);
            returnCourseInfo.statusMessage = retGetCourseInfo.statusMessage;
            returnCourseInfo.statusCode = retGetCourseInfo.statusCode;
            returnCourseInfo.courseDetailInfo = retGetCourseInfo.courseDetailInfo;

            returnCourseInfo.statusMessage = 'Program Information Returned';
            returnCourseInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getFRR25ProgramDetailInfo','returnCourseInfo',returnCourseInfo);

        return returnCourseInfo;
    }

    public static returnCourseInfo getMicroCourseProgramDetailInfo(String contactId, String courseType){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getMicroCourseProgramDetailInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getMicroCourseProgramDetailInfo','courseType',courseType);

        returnCourseInfo returnCourseInfo = new returnCourseInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnCourseInfo.statusMessage = 'Portal Access Denied';
                returnCourseInfo.statusCode = accessInfo.statusCode;
                return returnCourseInfo;
            }

            GARP_BC_MyPrograms.returnCourseInfo retGetCourseInfo = GARP_BC_MyPrograms.getCourseProgramDetailInfo(contact, courseType, accessInfo.mapContracts);
            returnCourseInfo.statusMessage = retGetCourseInfo.statusMessage;
            returnCourseInfo.statusCode = retGetCourseInfo.statusCode;
            returnCourseInfo.courseDetailInfo = retGetCourseInfo.courseDetailInfo;

            returnCourseInfo.statusMessage = 'Program Information Returned';
            returnCourseInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getMicroCourseProgramDetailInfo','returnCourseInfo',returnCourseInfo);

        return returnCourseInfo;
    }

    public static returnCourseInfo getFFRProgramDetailInfo(String contactId){
        returnCourseInfo returnCourseInfo = new returnCourseInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnCourseInfo.statusMessage = 'Portal Access Denied';
                returnCourseInfo.statusCode = accessInfo.statusCode;
                return returnCourseInfo;
            }

            GARP_BC_MyPrograms.returnCourseInfo retGetCourseInfo = GARP_BC_MyPrograms.getCourseProgramDetailInfo(contact, 'FFR', accessInfo.mapContracts);
            returnCourseInfo.statusMessage = retGetCourseInfo.statusMessage;
            returnCourseInfo.statusCode = retGetCourseInfo.statusCode;
            returnCourseInfo.courseDetailInfo = retGetCourseInfo.courseDetailInfo;

            returnCourseInfo.statusMessage = 'Program Information Returned';
            returnCourseInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getFFRProgramsDetailInfo','returnCourseInfo',returnCourseInfo);

        return returnCourseInfo;
    }

    // Get Program Details
    public class returnProgramsDetailInfo {
        public String statusMessage;
        public Integer statusCode;
        public String contactId;
        public GARP_BC_MyPrograms.programsDetailInfo programsDetailInfo;
        public GARP_BC_MyPrograms.frmProgramProgessInfo frmProgramProgessInfo;
    }

    public static returnProgramsDetailInfo getFRMProgramDetailInfo(String contactId, String loadKey){
        returnProgramsDetailInfo returnProgramsDetailInfo = new returnProgramsDetailInfo();

        returnProgramsDetailInfo.contactId = contactId;
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnProgramsDetailInfo.statusMessage = 'Portal Access Denied';
                returnProgramsDetailInfo.statusCode = accessInfo.statusCode;
                return returnProgramsDetailInfo;
            }

            GARP_BC_MyPrograms.returnProgramsDetailInfo retGetProgramInfo = GARP_BC_MyPrograms.getMyProgramsDetailInfo(contact, 'FRM', accessInfo.mapContracts, loadKey);
            returnProgramsDetailInfo.statusMessage = retGetProgramInfo.statusMessage;
            returnProgramsDetailInfo.statusCode = retGetProgramInfo.statusCode;
            returnProgramsDetailInfo.programsDetailInfo = retGetProgramInfo.programsDetailInfo;
            returnProgramsDetailInfo.frmProgramProgessInfo = retGetProgramInfo.frmProgramProgessInfo;

            returnProgramsDetailInfo.statusMessage = 'Program Information Returned';
            returnProgramsDetailInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getFRMProgramDetailInfo','returnProgramsDetailInfo',returnProgramsDetailInfo);

        return returnProgramsDetailInfo;
    }

    public static returnProgramsDetailInfo getERPProgramDetailInfo(String contactId, String loadKey){
        returnProgramsDetailInfo returnProgramsDetailInfo = new returnProgramsDetailInfo();

        returnProgramsDetailInfo.contactId = contactId;
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnProgramsDetailInfo.statusMessage = 'Portal Access Denied';
                returnProgramsDetailInfo.statusCode = accessInfo.statusCode;
                return returnProgramsDetailInfo;
            }

            GARP_BC_MyPrograms.returnProgramsDetailInfo retGetProgramInfo = GARP_BC_MyPrograms.getMyProgramsDetailInfo(contact, 'ERP', accessInfo.mapContracts, loadKey);
            returnProgramsDetailInfo.statusMessage = retGetProgramInfo.statusMessage;
            returnProgramsDetailInfo.statusCode = retGetProgramInfo.statusCode;
            returnProgramsDetailInfo.programsDetailInfo = retGetProgramInfo.programsDetailInfo;
            returnProgramsDetailInfo.frmProgramProgessInfo = retGetProgramInfo.frmProgramProgessInfo;

            returnProgramsDetailInfo.statusMessage = 'Program Information Returned';
            returnProgramsDetailInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getERPProgramDetailInfo','returnProgramsDetailInfo',returnProgramsDetailInfo);

        return returnProgramsDetailInfo;
    }

     public static returnProgramsDetailInfo getSCRProgramDetailInfo(String contactId, String loadKey){
        returnProgramsDetailInfo returnProgramsDetailInfo = new returnProgramsDetailInfo();

        returnProgramsDetailInfo.contactId = contactId;
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnProgramsDetailInfo.statusMessage = 'Portal Access Denied';
                returnProgramsDetailInfo.statusCode = accessInfo.statusCode;
                return returnProgramsDetailInfo;
            }

            GARP_BC_MyPrograms.returnProgramsDetailInfo retGetProgramInfo = GARP_BC_MyPrograms.getMyProgramsDetailInfo(contact, 'SCR', accessInfo.mapContracts, loadKey);
            returnProgramsDetailInfo.statusMessage = retGetProgramInfo.statusMessage;
            returnProgramsDetailInfo.statusCode = retGetProgramInfo.statusCode;
            returnProgramsDetailInfo.programsDetailInfo = retGetProgramInfo.programsDetailInfo;

            returnProgramsDetailInfo.programsDetailInfo.phoneCode = contact.Mobile_Phone_Code__c;
            returnProgramsDetailInfo.programsDetailInfo.phoneNumber = contact.MobilePhone;

            returnProgramsDetailInfo.statusMessage = 'Program Information Returned';
            returnProgramsDetailInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getSCRProgramDetailInfo','returnProgramsDetailInfo',returnProgramsDetailInfo);

        return returnProgramsDetailInfo;
    }

    public static returnProgramsDetailInfo getRAIProgramDetailInfo(String contactId, String loadKey){
        returnProgramsDetailInfo returnProgramsDetailInfo = new returnProgramsDetailInfo();

        returnProgramsDetailInfo.contactId = contactId;
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnProgramsDetailInfo.statusMessage = 'Portal Access Denied';
                returnProgramsDetailInfo.statusCode = accessInfo.statusCode;
                return returnProgramsDetailInfo;
            }

            GARP_BC_MyPrograms.returnProgramsDetailInfo retGetProgramInfo = GARP_BC_MyPrograms.getMyProgramsDetailInfo(contact, 'RiskAI', accessInfo.mapContracts, loadKey);
            returnProgramsDetailInfo.statusMessage = retGetProgramInfo.statusMessage;
            returnProgramsDetailInfo.statusCode = retGetProgramInfo.statusCode;
            returnProgramsDetailInfo.programsDetailInfo = retGetProgramInfo.programsDetailInfo;

            returnProgramsDetailInfo.programsDetailInfo.phoneCode = contact.Mobile_Phone_Code__c;
            returnProgramsDetailInfo.programsDetailInfo.phoneNumber = contact.MobilePhone;

            returnProgramsDetailInfo.statusMessage = 'Program Information Returned';
            returnProgramsDetailInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getRAIProgramDetailInfo','returnProgramsDetailInfo',returnProgramsDetailInfo);

        return returnProgramsDetailInfo;
    }

    public static returnProgramsDetailInfo getRAIJProgramDetailInfo(String contactId, String loadKey){
        returnProgramsDetailInfo returnProgramsDetailInfo = new returnProgramsDetailInfo();

        returnProgramsDetailInfo.contactId = contactId;
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnProgramsDetailInfo.statusMessage = 'Portal Access Denied';
                returnProgramsDetailInfo.statusCode = accessInfo.statusCode;
                return returnProgramsDetailInfo;
            }

            GARP_BC_MyPrograms.returnProgramsDetailInfo retGetProgramInfo = GARP_BC_MyPrograms.getMyProgramsDetailInfo(contact, 'RAIJ', accessInfo.mapContracts, loadKey);
            returnProgramsDetailInfo.statusMessage = retGetProgramInfo.statusMessage;
            returnProgramsDetailInfo.statusCode = retGetProgramInfo.statusCode;
            returnProgramsDetailInfo.programsDetailInfo = retGetProgramInfo.programsDetailInfo;

            returnProgramsDetailInfo.programsDetailInfo.phoneCode = contact.Mobile_Phone_Code__c;
            returnProgramsDetailInfo.programsDetailInfo.phoneNumber = contact.MobilePhone;

            returnProgramsDetailInfo.statusMessage = 'Program Information Returned';
            returnProgramsDetailInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getRAIJProgramDetailInfo','returnProgramsDetailInfo',returnProgramsDetailInfo);

        return returnProgramsDetailInfo;
    }

    // Has BenchPrep Access
    public static Boolean hasPracticeExamAccess(Contact contact, String programType, Contract programContract, Exam_Attempt__c examAttempt) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','hasPracticeExamAccess','contact',contact);
        GARP_Common.debugLog('GARP_BC_MemberPortal','hasPracticeExamAccess','programType',programType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','hasPracticeExamAccess','programContract',programContract);
        GARP_Common.debugLog('GARP_BC_MemberPortal','hasPracticeExamAccess','examAttempt',examAttempt);

        Boolean hasPracticeExamAccess = True;
        Date tdy = Date.Today();

        // Get Exam Dates
        GARP_BC_MyPrograms.examDatesInfo examDatesInfo = GARP_BC_MyPrograms.getExamDateInfo(examAttempt);

        if((programContract.Status != 'Activated' && programContract.Status != 'Activated ( Auto-Renew )') || programContract.Opportunity__r.StageName == 'New Lead') {
            hasPracticeExamAccess = False;
        } if(tdy > examDatesInfo.schedulingCutoffDate) {
            // Scheduling Cutoff is when the Exam is given
            // After the exam you lose access
            hasPracticeExamAccess = False;
        }

        GARP_Common.debugLog('GARP_BC_MemberPortal','hasPracticeExamAccess','hasPracticeExamAccess',hasPracticeExamAccess);

        return hasPracticeExamAccess;
    }

    // EPP OptIn
    public class returnEPPOptInInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnEPPOptInInfo EPPOptIn(String contactId, String examType, Boolean optIn) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','EPPOptIn','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','EPPOptIn','examType',examType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','EPPOptIn','optIn',optIn);

        returnEPPOptInInfo returnEPPOptInInfo = new returnEPPOptInInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnEPPOptInInfo.statusMessage = 'Portal Access Denied';
                returnEPPOptInInfo.statusCode = accessInfo.statusCode;
                return returnEPPOptInInfo;
            }

            MAP<String,Exam_Attempt__c> mapLatestExamAttempts;
            GARP_BC_MyPrograms.returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contactId);
            mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;
            
            Exam_Attempt__c examAttempt;
            if(examType == 'frm') {
                examAttempt = mapLatestExamAttempts.get('FRMI');
                if(examAttempt == NULL) {
                    examAttempt = mapLatestExamAttempts.get('FRMII');
                }
            } else if(examType == 'scr') {
                examAttempt = mapLatestExamAttempts.get('SCRFull');
            } else if(examType == 'riskai') {
                examAttempt = mapLatestExamAttempts.get('RiskAIFull');
            } else if(examType == 'raij') {
                examAttempt = mapLatestExamAttempts.get('RAIJFull');
            }
            
            if(examAttempt != NULL) {
                examAttempt.EPP_Opt_In__c = DateTime.Now();
                update examAttempt;
                
                contact.Exam_Prep_Provider_Outreach__c = optIn;
                update contact;

                returnEPPOptInInfo.statusMessage = 'EPP OptIn Updated';
                returnEPPOptInInfo.statusCode = 200;
            } else {
                returnEPPOptInInfo.statusMessage = 'Exam Attempt not found';
                returnEPPOptInInfo.statusCode = 401;
            }

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','EPPOptIn','returnEPPOptInInfo',returnEPPOptInInfo);

        return returnEPPOptInInfo;
    }

    // Exam Results

    public class returnExamResultsListingInfo {
        public String statusMessage;
        public Integer statusCode;
        public List<GARP_BC_MyPrograms.examResult> examResults;
    }

    public static returnExamResultsListingInfo getExamResultsListing(String contactId, String loadKey){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamResultsListing','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamResultsListing','loadKey',loadKey);

        returnExamResultsListingInfo returnExamResultsListingInfo = new returnExamResultsListingInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnExamResultsListingInfo.statusMessage = 'Portal Access Denied';
                returnExamResultsListingInfo.statusCode = accessInfo.statusCode;
                return returnExamResultsListingInfo;
            }

            returnExamResultsListingInfo.examResults = GARP_BC_MyPrograms.getExamResults(contact.Id, loadKey);
            returnExamResultsListingInfo.statusMessage = 'Results Returned';
            returnExamResultsListingInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamResultsListing','returnExamResultsListingInfo',returnExamResultsListingInfo);

        return returnExamResultsListingInfo;
    }

    public class returnSetExamResultLastViewDate {
        public String statusMessage;
        public Integer statusCode;
    }

    public static returnSetExamResultLastViewDate setExamResultLastViewDate(String contactId, String examAttemptId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamResultLastViewDate','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamResultLastViewDate','loadKey',examAttemptId);

        returnSetExamResultLastViewDate returnSetExamResultLastViewDate = new returnSetExamResultLastViewDate();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetExamResultLastViewDate.statusMessage = 'Portal Access Denied';
                returnSetExamResultLastViewDate.statusCode = accessInfo.statusCode;
                return returnSetExamResultLastViewDate;
            }

            GARP_Common.returnInfo ret = GARP_BC_MyPrograms.setExamResultLastViewDate(contact.Id, examAttemptId);

            if(ret.status == 'Success') {
                returnSetExamResultLastViewDate.statusMessage = 'Exam Attempt Results View Date Updated';
                returnSetExamResultLastViewDate.statusCode = 200;
            } else {
                returnSetExamResultLastViewDate.statusMessage = ret.msg;
                returnSetExamResultLastViewDate.statusCode = 401;
            }

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamResultLastViewDate','returnSetExamResultLastViewDate',returnSetExamResultLastViewDate);

        return returnSetExamResultLastViewDate;
    }

    // Exam Setup

    public static GARP_BC_MyPrograms.returnGetExamSetupFormInfo getExamSetupFormInfo(String userId, String contactId, String examType) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupFormInfo','userId',userId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupFormInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupFormInfo','examType',examType);

        GARP_BC_MyPrograms.returnGetExamSetupFormInfo returnGetExamSetupFormInfo = new GARP_BC_MyPrograms.returnGetExamSetupFormInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetExamSetupFormInfo.statusMessage = 'Portal Access Denied';
                returnGetExamSetupFormInfo.statusCode = accessInfo.statusCode;
                return returnGetExamSetupFormInfo;
            }

            returnGetExamSetupFormInfo = GARP_BC_MyPrograms.getExamSetupFormInfo(userId, contact, examType);

            returnGetExamSetupFormInfo.statusMessage = returnGetExamSetupFormInfo.statusMessage;
            returnGetExamSetupFormInfo.statusCode = returnGetExamSetupFormInfo.statusCode;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupFormInfo','returnGetExamSetupFormInfo',returnGetExamSetupFormInfo);

        return returnGetExamSetupFormInfo;
    }

    public static GARP_BC_MyPrograms.returnGetExamSetupExamSelectionInfo getExamSetupExamSelectionInfo(String contactId, String examType, GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupExamSelectionInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupExamSelectionInfo','examType',examType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupExamSelectionInfo','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);

        GARP_BC_MyPrograms.returnGetExamSetupExamSelectionInfo returnGetExamSetupExamSelectionInfo = new GARP_BC_MyPrograms.returnGetExamSetupExamSelectionInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetExamSetupExamSelectionInfo.statusMessage = 'Portal Access Denied';
                returnGetExamSetupExamSelectionInfo.statusCode = accessInfo.statusCode;
                return returnGetExamSetupExamSelectionInfo;
            }

            Contract cont;
            returnGetExamSetupExamSelectionInfo = GARP_BC_MyPrograms.getExamSetupExamSelectionInfo(contact, examType, accessInfo.mapContracts, examSetupExamSelectionsInfo);

            if(returnGetExamSetupExamSelectionInfo.statusCode == 200) {
                returnGetExamSetupExamSelectionInfo.hasError = False;
                returnGetExamSetupExamSelectionInfo.statusMessage = 'Exam Setup Selection Info Returned';
                returnGetExamSetupExamSelectionInfo.statusCode = 200;
            } else {
                returnGetExamSetupExamSelectionInfo.hasError = True;
                returnGetExamSetupExamSelectionInfo.statusMessage = returnGetExamSetupExamSelectionInfo.statusMessage;
                returnGetExamSetupExamSelectionInfo.statusCode = 200;
            }

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupExamSelectionInfo','returnGetExamSetupExamSelectionInfo',returnGetExamSetupExamSelectionInfo);

        return returnGetExamSetupExamSelectionInfo;
    }

    /* No longer called from outside
    public static GARP_BC_MyPrograms.returnSetExamSetupExamSelectionsChanges setExamSetupExamSelectionsChanges(String contactId, String examType, GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamSetupExamSelectionsChanges','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamSetupExamSelectionsChanges','examType',examType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamSetupExamSelectionsChanges','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);

        GARP_BC_MyPrograms.returnsetExamSetupExamSelectionsChanges returnsetExamSetupExamSelectionsChanges = new GARP_BC_MyPrograms.returnsetExamSetupExamSelectionsChanges();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnsetExamSetupExamSelectionsChanges.statusMessage = 'Portal Access Denied';
                returnsetExamSetupExamSelectionsChanges.statusCode = accessInfo.statusCode;
                return returnsetExamSetupExamSelectionsChanges;
            }

            //returnsetExamSetupExamSelectionsChanges = GARP_BC_MyPrograms.setExamSetupExamSelectionsChanges(contact, examType, accessInfo.mapContracts, examSetupExamSelectionsInfo);

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamSetupExamSelectionsChanges','returnsetExamSetupExamSelectionsChanges',returnsetExamSetupExamSelectionsChanges);

        return returnsetExamSetupExamSelectionsChanges;
    }
    */

    public static GARP_BC_MyPrograms.returnGetExamSetupFeesCheckoutInfo getExamSetupFeesCheckoutInfo(String contactId, String examRegistrationModificationId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupFeesCheckoutInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupFeesCheckoutInfo','examRegistrationModificationId',examRegistrationModificationId);

        GARP_BC_MyPrograms.returnGetExamSetupFeesCheckoutInfo returnGetExamSetupFeesCheckoutInfo = new GARP_BC_MyPrograms.returnGetExamSetupFeesCheckoutInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetExamSetupFeesCheckoutInfo.statusMessage = 'Portal Access Denied';
                returnGetExamSetupFeesCheckoutInfo.statusCode = accessInfo.statusCode;
                return returnGetExamSetupFeesCheckoutInfo;
            }

            returnGetExamSetupFeesCheckoutInfo = GARP_BC_MyPrograms.getExamSetupFeesCheckoutInfo(contact, accessInfo.mapContracts, examRegistrationModificationId);

            returnGetExamSetupFeesCheckoutInfo.statusMessage = 'Exam Setup Checkout Info Returned';
            returnGetExamSetupFeesCheckoutInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupFeesCheckoutInfo','returnGetExamSetupFeesCheckoutInfo',returnGetExamSetupFeesCheckoutInfo);

        return returnGetExamSetupFeesCheckoutInfo;
    }

    public static GARP_BC_MyPrograms.returnGetExamSetupIDInfo getExamSetupIDInfo(String contactId, String examType, GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupIDInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupIDInfo','examType',examType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupIDInfo','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);

        GARP_BC_MyPrograms.returnGetExamSetupIDInfo returnGetExamSetupIDInfo = new GARP_BC_MyPrograms.returnGetExamSetupIDInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetExamSetupIDInfo.statusMessage = 'Portal Access Denied';
                returnGetExamSetupIDInfo.statusCode = accessInfo.statusCode;
                return returnGetExamSetupIDInfo;
            }

            returnGetExamSetupIDInfo = GARP_BC_MyPrograms.getExamSetupIDInfo(contact, examType, examSetupExamSelectionsInfo);

            returnGetExamSetupIDInfo.statusMessage = 'Exam Setup ID Info Returned';
            returnGetExamSetupIDInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getExamSetupIDInfo','returnGetExamSetupIDInfo',returnGetExamSetupIDInfo);

        return returnGetExamSetupIDInfo;
    }

    public static GARP_BC_MyPrograms.returnSetExamSetupIDInfo setExamSetupIDInfo(String contactId, String examType, GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo, GARP_BC_MyPrograms.setIdCandidateInfo idCandidateInfo) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamSetupIDInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamSetupIDInfo','examType',examType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamSetupIDInfo','examSetupExamSelectionsInfo',examSetupExamSelectionsInfo);
        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamSetupIDInfo','idCandidateInfo',idCandidateInfo);

        GARP_BC_MyPrograms.returnSetExamSetupIDInfo returnSetExamSetupIDInfo = new GARP_BC_MyPrograms.returnSetExamSetupIDInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetExamSetupIDInfo.statusMessage = 'Portal Access Denied';
                returnSetExamSetupIDInfo.statusCode = accessInfo.statusCode;
                return returnSetExamSetupIDInfo;
            }

            returnSetExamSetupIDInfo = GARP_BC_MyPrograms.setExamSetupIDInfo(contact, examType, accessInfo.mapContracts, examSetupExamSelectionsInfo, idCandidateInfo);

            returnSetExamSetupIDInfo.statusMessage = 'Exam Setup ID Info Set';
            returnSetExamSetupIDInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','setExamSetupIDInfo','returnSetExamSetupIDInfo',returnSetExamSetupIDInfo);

        return returnSetExamSetupIDInfo;
    }

    public static GARP_BC_MyPrograms.returnExamSetupAuthorizeRegistrations examSetupAuthorizeRegistrations(String contactId, String examType, Boolean isRetry) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','examSetupAuthorizeRegistrations','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','examSetupAuthorizeRegistrations','examType',examType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','examSetupAuthorizeRegistrations','isRetry',isRetry);

        GARP_BC_MyPrograms.returnExamSetupAuthorizeRegistrations returnExamSetupAuthorizeRegistrations = new GARP_BC_MyPrograms.returnExamSetupAuthorizeRegistrations();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnExamSetupAuthorizeRegistrations.statusMessage = 'Portal Access Denied';
                returnExamSetupAuthorizeRegistrations.statusCode = accessInfo.statusCode;
                return returnExamSetupAuthorizeRegistrations;
            }

            returnExamSetupAuthorizeRegistrations = GARP_BC_MyPrograms.examSetupAuthorizeRegistrations(contact, examType, isRetry);

            //returnExamSetupAuthorizeRegistrations.statusCode = 200;
            //returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart1 = '/idp?id=u234iug2ig5gig23';
            //returnExamSetupAuthorizeRegistrations.examScheduleExamURLPart2 = '/idp?id=ig4ugfgueif';

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','examSetupAuthorizeRegistrations','returnExamSetupAuthorizeRegistrations',returnExamSetupAuthorizeRegistrations);

        return returnExamSetupAuthorizeRegistrations;
    }


    // Alert Bar
    public class returnAlertInfo {
        public String alertStatus; // Unpaid, Results Available, Scheduling Incomplete, Scheduling Expired, Enrollment Expiring Soon, CV Submission Expiring Soon, Enrollment Expired
        public Date deadline;
        public String orderId;
        public String route;
    }

    public static returnAlertInfo getProgramAlertStatus(Contact contact, String programType, Contract programContract, Exam_Attempt__c examAttempt, List<Opportunity> lstOpp, String loadKey) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','contact',contact);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','programType',programType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','programContract',programContract);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','examAttempt',examAttempt);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','lstOpp',lstOpp);

        returnAlertInfo returnAlertInfo = new returnAlertInfo();
        Date tdy = Date.Today();

        Boolean isLoadingPart = GARP_BC_MyPrograms.isLoadingResults(examAttempt.Exam_Administration__r.Exam_Results_Loading__c, loadKey);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','isLoadingPart',isLoadingPart);

        Date resultsReleaseDate = Date.NewInstance(2035,1,1);
        if(examAttempt.Exam_Part__r.Exam_Results_Release_Date__c != NULL) {
            resultsReleaseDate = Date.ValueOf(examAttempt.Exam_Part__r.Exam_Results_Release_Date__c);
        } else if(examAttempt.Exam_Administration__r.Exam_Results_Release_Date__c != NULL) {
            resultsReleaseDate = Date.ValueOf(examAttempt.Exam_Administration__r.Exam_Results_Release_Date__c);
        }

        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','resultsReleaseDate',resultsReleaseDate);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','Exam_Scheduling_End_Date__c',examAttempt.Exam_Administration__r.Exam_Scheduling_End_Date__c);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','Result__c',examAttempt.Result__c);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','Exam_Results_Loading__c',examAttempt.Exam_Administration__r.Exam_Results_Loading__c);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','Results_Viewed_Date__c',examAttempt.Results_Viewed_Date__c);

        //if(programType == 'FRM') {
            Boolean passPart1 = FALSE;
            Boolean passPart2 = FALSE;
            String cvStatus;
            for(Candidate_Requirement__c cr :programContract.Candidate_Requirements__r) {
                if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'FRM Part I' && cr.Status__c == 'Completed') {
                    passPart1 = TRUE;
                }
                if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'FRM Part II' && cr.Status__c == 'Completed') {
                    passPart2 = TRUE;
                }
                if(cr.recordType.DeveloperName == 'Job_Experience') {
                    cvStatus = cr.Status__c;
                }
            }
            GARP_Common.debugLog('GARP_BC_MyPrograms','getProgramAlertStatus','passPart1',passPart1);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getProgramAlertStatus','passPart2',passPart2);

            Long UntilExpire = tdy.daysBetween(programContract.EndDate);
            GARP_Common.debugLog('GARP_BC_MyPrograms','getProgramAlertStatus','UntilExpire',UntilExpire);

            // Enrollment expiring soon
            // Dont Show if awaiting results, or to take, or deferred

            Boolean dontShowEnrollmentExpiring = false;
            if(examAttempt.Deferral_Status__c == 'Deferred Out' || passPart1 == False) {
                dontShowEnrollmentExpiring = true;
            } else if(examAttempt.Result__c == NULL) {
                dontShowEnrollmentExpiring = true;
            }

            GARP_Common.debugLog('GARP_BC_MyPrograms','getProgramAlertStatus','dontShowEnrollmentExpiring',dontShowEnrollmentExpiring);

            Opportunity openExamOpp;
            Set<String> productExamCodes = new Set<String>{};
            if(programType == 'FRM') {
                productExamCodes = new Set<String>{'FRM1E','FRM2E','FRM1S','FRM2S'};
            } else if(programType == 'SCR') {
                productExamCodes = new Set<String>{'SCRNME','SCRNMS','SCRME','SCRMS','SCRCME','SCRCMS','SCR2A'};
            } else if(programType == 'RiskAI') {
                productExamCodes = new Set<String>{'RAINME','RAINMS','RAIME','RAIMS','RAICME','RAICMS','RAI2A'};
            } else if(programType == 'RAIJ') {
                productExamCodes = new Set<String>{'RAIJNME','RAIJNMS','RAIJME','RAIJMS','RAIJCME','RAIJCMS','RAIJ2A'};
            }
            openExamOpp = GARP_BC_Orders.getLatestOppWithGivenProducts(contact.accountID, productExamCodes, 'New Lead', lstOpp);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','openExamOpp',openExamOpp);

            // Get Current and Next Exam Admin Reg window Status
            GARP_BC_MyPrograms.currentNextExamAdminRegInfo currentNextExamAdminRegInfo = GARP_BC_MyPrograms.getCurrentNextExamAdminRegInfo(programType);
            if(currentNextExamAdminRegInfo != NULL) {
                if(openExamOpp != NULL) {
                    returnAlertInfo.alertStatus = 'Exam Unpaid';
                    returnAlertInfo.orderId = openExamOpp.Id;
                    returnAlertInfo.route = 'Complete Payment';
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','alertStatus unpaid',returnAlertInfo.alertStatus);
                } else if(programType == 'FRM' && !dontShowEnrollmentExpiring && UntilExpire < 90 && programContract.Status != 'Completed' && programContract.Status != 'Expired' && currentNextExamAdminRegInfo.isRegistrationOpen) {
                    returnAlertInfo.alertStatus = 'Enrollment Expiring Soon';
                    returnAlertInfo.deadline = currentNextExamAdminRegInfo.currentExamAdminRegCloseDate;
                    returnAlertInfo.route = 'Exam Registration';
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','alertStatus Enrollment Expiring Soon Part II',returnAlertInfo.alertStatus);
                } else if(programType == 'FRM' && passPart1 && passPart2 && programContract.Status != 'Completed' && cvStatus != 'Ready For Review' && UntilExpire < 90 && programContract.Status != 'Expired') {
                    returnAlertInfo.alertStatus = 'CV Submission Expiring Soon';
                    returnAlertInfo.deadline = programContract.EndDate;
                    returnAlertInfo.route = 'Submit CV';
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','alertStatus Enrollment Expiring Soon CV',returnAlertInfo.alertStatus);
                } else if(programType == 'FRM' && programContract.Status == 'Expired' && currentNextExamAdminRegInfo.isRegistrationOpen) {
                    returnAlertInfo.alertStatus = 'Enrollment Expired';
                    returnAlertInfo.route = 'Exam Registration';
                    GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','alertStatus Enrollment Expiring Soon',returnAlertInfo.alertStatus);
                }
            }
        //}

        // Get open Defer Order
        Opportunity openDeferOpp = GARP_BC_Orders.getLatestOppWithExamModification(contact.accountID, NULL, programType);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','openDeferOpp',openDeferOpp);

        // Get Exam Dates
        GARP_BC_MyPrograms.examDatesInfo examDatesInfo = GARP_BC_MyPrograms.getExamDateInfo(examAttempt);

        if(openDeferOpp != NULL) {
            returnAlertInfo.alertStatus = 'Modification Order Pending';
            returnAlertInfo.route = 'Complete Payment';
            returnAlertInfo.orderId = openDeferOpp.Id;
            if(tdy <= examDatesInfo.schedulingCutoffDate) {
                returnAlertInfo.deadline = examAttempt.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c;
            }
        }

        if(returnAlertInfo.alertStatus == NULL && examAttempt.Deferral_Status__c != 'Deferred Out') {

            String result;
            if(examAttempt.Result__c != NULL) {
                result = examAttempt.Result__c;
                if(examAttempt.hasViolation__c) {
                    result = 'Not Graded';
                }
            }

            if(result != NULL && (result == 'Pass' || result == 'Fail') && !isLoadingPart &&
               tdy > examAttempt.Exam_Administration__r.Exam_Scheduling_End_Date__c && examAttempt.Results_Viewed_Date__c == NULL && tdy <= resultsReleaseDate.addDays(30)) {

                   returnAlertInfo.alertStatus = 'Results Available';
                   returnAlertInfo.route = 'Exam Detail';
                   GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','alertStatus Results Available',returnAlertInfo.alertStatus);

               } else if(tdy >= examAttempt.Exam_Administration__r.Exam_Scheduling_Start_Date__c) {

                   GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','after scheduling open',examAttempt.Exam_Administration__r.Exam_Scheduling_Start_Date__c);

                   // Is OSTA?
                   Boolean isOSTA = examAttempt.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c;

                   // Get Name on ID
                   String idName = GARP_BC_MyPrograms.getNameOnID(contact, programType);

                   // Get Scheduling Status
                   Boolean isSchedulingComplete = GARP_BC_MyPrograms.isSchedulingComplete(contact, examAttempt, programType, idName, isOSTA);

                   GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','isSchedulingComplete',isSchedulingComplete);
                   GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','schedulingCutoffDate',examDatesInfo.schedulingCutoffDate);

                   if(currentNextExamAdminRegInfo != NULL) {
                       if(!isSchedulingComplete) {
                           if(tdy <= examDatesInfo.schedulingCutoffDate) {
                               returnAlertInfo.alertStatus = 'Scheduling Incomplete';
                               returnAlertInfo.deadline = examDatesInfo.schedulingCutoffDate;
                               returnAlertInfo.route = 'Exam Scheduling';
                               GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','alertStatus Scheduling Incomplete',returnAlertInfo.alertStatus);
                           } else if(tdy <= examDatesInfo.schedulingCutoffDate.addDays(30) && currentNextExamAdminRegInfo.isRegistrationOpen && examAttempt.Result__c != NULL) {
                               returnAlertInfo.alertStatus = 'Scheduling Expired';
                               returnAlertInfo.route = 'Exam Registration';
                               GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','alertStatus Scheduling Expired',returnAlertInfo.alertStatus);
                           }
                       }
                   }
               }
        }

        GARP_Common.debugLog('GARP_BC_MemberPortal','getProgramAlertStatus','final returnAlertInfo',returnAlertInfo);
        return returnAlertInfo;
    }

    // For now is only FRM, SCR and RAI warnings
    public class returnAlertBarInfo {
        public String statusMessage;
        public Integer statusCode;
        public String examType;
        public String examPart;
        public String alertStatus;
        public Date deadline;
        public String orderId;
        public String route; // where to take CTA
    }

    public static returnAlertBarInfo getAlertBarInfo(String contactId, String loadKey) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','contactId',contactId);

        returnAlertBarInfo returnAlertBarInfo = new returnAlertBarInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnAlertBarInfo.statusMessage = 'Portal Access Denied';
                returnAlertBarInfo.statusCode = accessInfo.statusCode;
                return returnAlertBarInfo;
            }

            GARP_BC_MyPrograms.enrolledPrograms enrolledPrograms = GARP_BC_MyPrograms.getEnrolledPrograms(contactId, accessInfo.mapContracts, loadKey);

            returnAlertInfo returnAlertInfo = new returnAlertInfo();

            List<Opportunity> lstOpp = GARP_BC_Orders.getAllOpps(contact.AccountId);

            Contract frmContract = accessInfo.mapContracts.get('FRM_Program');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','frmContract',frmContract);

            if(frmContract != NULL) {

                Exam_Attempt__c frmExamAttemptPartI = enrolledPrograms.mapLatestExamAttempts.get('FRMI');
                Exam_Attempt__c frmExamAttemptPartII = enrolledPrograms.mapLatestExamAttempts.get('FRMII');

                GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','frmExamAttemptPartI',frmExamAttemptPartI);
                GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','frmExamAttemptPartII',frmExamAttemptPartII);

                if(frmExamAttemptPartII != NULL) {
                    returnAlertInfo = getProgramAlertStatus(contact, 'FRM', frmContract, frmExamAttemptPartII, lstOpp, loadKey);
                    if(returnAlertInfo.alertStatus != NULL) {
                        returnAlertBarInfo.examType = 'FRM';
                        returnAlertBarInfo.examPart = 'II';
                    }
                } else if(returnAlertInfo.alertStatus == NULL && frmExamAttemptPartI != NULL) {
                    returnAlertInfo = getProgramAlertStatus(contact, 'FRM', frmContract, frmExamAttemptPartI, lstOpp, loadKey);
                    if(returnAlertInfo.alertStatus != NULL) {
                        returnAlertBarInfo.examType = 'FRM';
                        returnAlertBarInfo.examPart = 'I';
                    }
                }
            }

            Contract scrContract = accessInfo.mapContracts.get('SCR_Program');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','scrContract',scrContract);

            if(returnAlertInfo.alertStatus == NULL && scrContract != NULL) {

                Exam_Attempt__c scrExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('SCRFull');
                GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','scrExamAttempt',scrExamAttempt);

                if(scrExamAttempt != NULL) {
                    returnAlertInfo = getProgramAlertStatus(contact, 'SCR', scrContract, scrExamAttempt, lstOpp, loadKey);
                    if(returnAlertInfo.alertStatus != NULL) {
                        returnAlertBarInfo.examType = 'SCR';
                        returnAlertBarInfo.examPart = 'Full';
                    }
                }
            }

            Contract raijContract = accessInfo.mapContracts.get('RAIJ_Program');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','raijContract',raijContract);

            if(returnAlertInfo.alertStatus == NULL && raijContract != NULL) {

                Exam_Attempt__c raijExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('RAIJFull');
                GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','raijExamAttempt',raijExamAttempt);

                if(raijExamAttempt != NULL) {
                    returnAlertInfo = getProgramAlertStatus(contact, 'RAIJ', raijContract, raijExamAttempt, lstOpp, loadKey);
                    if(returnAlertInfo.alertStatus != NULL) {
                        returnAlertBarInfo.examType = 'RAIJ';
                        returnAlertBarInfo.examPart = 'Full';
                    }
                }
            }

            Contract riskaiContract = accessInfo.mapContracts.get('Risk_AI_Program');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','riskaiContract',riskaiContract);

            if(returnAlertInfo.alertStatus == NULL && riskaiContract != NULL) {

                Exam_Attempt__c riskaiExamAttempt = enrolledPrograms.mapLatestExamAttempts.get('RiskAIFull');
                GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','riskaiExamAttempt',riskaiExamAttempt);

                if(riskaiExamAttempt != NULL) {
                    returnAlertInfo = getProgramAlertStatus(contact, 'RiskAI', riskaiContract, riskaiExamAttempt, lstOpp, loadKey);
                    if(returnAlertInfo.alertStatus != NULL) {
                        returnAlertBarInfo.examType = 'RAI';
                        returnAlertBarInfo.examPart = 'Full';
                    }
                }
            }

            GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','returnAlertInfo',returnAlertInfo);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','returnAlertBarInfo',returnAlertBarInfo);

            if(returnAlertInfo.alertStatus != NULL) {
                returnAlertBarInfo.alertStatus = returnAlertInfo.alertStatus;
                returnAlertBarInfo.deadline = returnAlertInfo.deadline;
                returnAlertBarInfo.orderId = returnAlertInfo.orderId;
                returnAlertBarInfo.route = returnAlertInfo.route;
                returnAlertBarInfo.statusMessage = 'Success';
                returnAlertBarInfo.statusCode = 200;

            }  else {
                returnAlertBarInfo.statusMessage = 'No alerts found';
                returnAlertBarInfo.statusCode = 200;
            }

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getAlertBarInfo','returnAlertBarInfo final',returnAlertBarInfo);

        return returnAlertBarInfo;
    }

    // Events

    public class eventInfo {
        public String eventName;
        public Date eventStartDate;
        public String eventType;
        public String eventSlug;
        public String eventURL;
    }

    public class returnUpcomingEventsInfo {
        public String statusMessage;
        public Integer statusCode;
        public List<eventInfo> upcomingEvents;
    }

    public static returnUpcomingEventsInfo getComponentUpcomingEventsInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentUpcomingEventsInfo','contactId',contactId);

        returnUpcomingEventsInfo returnUpcomingEventsInfo = new returnUpcomingEventsInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnUpcomingEventsInfo.statusMessage = 'Portal Access Denied';
                returnUpcomingEventsInfo.statusCode = accessInfo.statusCode;
                return returnUpcomingEventsInfo;
            }
            List<GARP_BC_Events.memberEventInfo> memberRegistrations = GARP_BC_Events.getMemberEventRegistrationsSummary(contactId, TRUE);
            if(!memberRegistrations.IsEmpty()) {

                returnUpcomingEventsInfo.upcomingEvents = new List<eventInfo>();

                Integer eventCount = 0;

                for(GARP_BC_Events.memberEventInfo mri :memberRegistrations) {
                    eventInfo eventInfo = new eventInfo();
                    eventInfo.eventName = mri.eventName;
                    eventInfo.eventStartDate = mri.eventStartDate;
                    eventInfo.eventType = mri.eventType;
                    eventInfo.eventSlug = mri.eventSlug;
                    eventInfo.eventURL = mri.eventURL;
                    returnUpcomingEventsInfo.upcomingEvents.add(eventInfo);
                    eventCount++;
                    if(eventCount == 2) {
                        break;
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentUpcomingEventsInfo','upcomingEvents',returnUpcomingEventsInfo.upcomingEvents);

            returnUpcomingEventsInfo.statusMessage = 'Success';
            returnUpcomingEventsInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentUpcomingEventsInfo','returnUpcomingEventsInfo',returnUpcomingEventsInfo);

        return returnUpcomingEventsInfo;
    }

    public class returnEventsListingInfo {
        public String statusMessage;
        public Integer statusCode;
        public List<GARP_BC_Events.memberEventInfo> registeredEvents;
        public List<GARP_BC_Events.memberEventInfo> upcomingChapterMeetings;
        public List<GARP_BC_Events.memberEventInfo> upcomingOtherEvents;
    }

    public static returnEventsListingInfo getEventsListingInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getEventsListingInfo','contactId',contactId);

        returnEventsListingInfo returnEventsListingInfo = new returnEventsListingInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnEventsListingInfo.statusMessage = 'Portal Access Denied';
                returnEventsListingInfo.statusCode = accessInfo.statusCode;
                return returnEventsListingInfo;
            }

            returnEventsListingInfo.registeredEvents = GARP_BC_Events.getMemberEventRegistrationsSummary(contactId, TRUE);

            Set<String> alreadyRegisteredIds = new SET<String>();
            if(!returnEventsListingInfo.registeredEvents.IsEmpty()) {
                for(GARP_BC_Events.memberEventInfo evi :returnEventsListingInfo.registeredEvents) {
                    alreadyRegisteredIds.add(evi.eventId);
                }
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','getEventsListingInfo','alreadyRegisteredIds',alreadyRegisteredIds);

            Date tdy = Date.Today();

            // Chapter Meetings
            List<Chapter_Meeting__c> lstChapterMeeting = [SELECT Id, Chapter_Meeting_Name__c, Chapter__c, Chapter__r.Name, Start_Date__c , Vanity_URL__c
                                                          FROM Chapter_Meeting__c
                                                          WHERE Status__c = 'Active' AND Start__c >= :tdy Order by Start__c
                                                         ];
            GARP_Common.debugLog('GARP_BC_Events','getEventsListingInfo','lstChapterMeeting',lstChapterMeeting);

            List<Chapter_Member__c> lstChaptMembers = [select id, Chapter__c, Director__c, Can_Manage_Attendance__c from Chapter_Member__c where Contact__c = :contactId AND (Director__c = TRUE OR Can_Manage_Attendance__c = TRUE)];
            GARP_Common.debugLog('GARP_BC_Events','getEventsListingInfo','lstChaptMembers',lstChaptMembers);

            MAP<String, Chapter_Member__c> mapChaptMembers = new MAP<String, Chapter_Member__c>();
            if(!lstChaptMembers.IsEmpty()) {
                for(Chapter_Member__c cm :lstChaptMembers) {
                    mapChaptMembers.put(cm.Chapter__c, cm);
                }
            }
            GARP_Common.debugLog('GARP_BC_Events','getEventsListingInfo','mapChaptMembers',mapChaptMembers);

            // Update Registered Events with Chapter Attendance
            if(!returnEventsListingInfo.registeredEvents.IsEmpty()) {
                for(GARP_BC_Events.memberEventInfo mei :returnEventsListingInfo.registeredEvents) {
                    if(mei.eventType == 'Chapter Meeting') {
                        Chapter_Member__c findChaptMem = mapChaptMembers.get(mei.chapterId);
                        if(findChaptMem != NULL) {
                            mei.canManageAttendance = True;
                            GARP_Common.debugLog('GARP_BC_Events','getEventsListingInfo','can manage attendance',mei);
                        }
                    }
                }
            }

            returnEventsListingInfo.upcomingChapterMeetings = GARP_BC_Events.getMemberUpcomingChapterMeetings(contact, lstChapterMeeting, alreadyRegisteredIds);

            Set<String> upcomingChapterMeetingEventIds = new Set<String>();
            if(!returnEventsListingInfo.upcomingChapterMeetings.IsEmpty()) {
                for(GARP_BC_Events.memberEventInfo evi :returnEventsListingInfo.upcomingChapterMeetings) {

                    System.Debug('***evi:' + evi);

                    upcomingChapterMeetingEventIds.add(evi.eventId);

                    Chapter_Member__c findChaptMem = mapChaptMembers.get(evi.chapterId);
                    System.Debug('***findChaptMem:' + findChaptMem);

                    if(findChaptMem != NULL) {
                        evi.canManageAttendance = True;
                        GARP_Common.debugLog('GARP_BC_Events','getEventsListingInfo','can manage attendance',evi);
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','getEventsListingInfo','upcomingChapterMeetingEventIds',upcomingChapterMeetingEventIds);

            returnEventsListingInfo.upcomingOtherEvents = GARP_BC_Events.getMemberUpcomingOtherEvents(contact, lstChapterMeeting, alreadyRegisteredIds, upcomingChapterMeetingEventIds, accessInfo.mapContracts);

            // Update Other Events with Chapter Attendance
            if(!returnEventsListingInfo.upcomingOtherEvents.IsEmpty()) {
                for(GARP_BC_Events.memberEventInfo mei :returnEventsListingInfo.upcomingOtherEvents) {
                    if(mei.eventType == 'Chapter Meeting') {
                        Chapter_Member__c findChaptMem = mapChaptMembers.get(mei.chapterId);
                        if(findChaptMem != NULL) {
                            mei.canManageAttendance = True;
                        }
                    }
                }
            }

            returnEventsListingInfo.statusMessage = 'Success';
            returnEventsListingInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getEventsListingInfo','returnEventsListingInfo',returnEventsListingInfo);

        return returnEventsListingInfo;
    }

    // Ads

    // Returns FRM, SCR, or RAI
    public static String computeAdType(String contactId, verifyPortalAccessInfo accessInfo) {

        GARP_Common.debugLog('GARP_BC_MemberPortal','computeAdType','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','computeAdType','accessInfo',accessInfo);

        String ret;

        Boolean canShowFRM = FALSE;
        Boolean canShowSCR = FALSE;
        Boolean canShowRAI = FALSE;

        List<String> canShowPrograms = new List<String>();
        Integer programCnt = 0;

        MAP<String,Integer> monthsMap = GARP_Common.getMonthMap();
        Date tdy = Date.Today();

        Contract frmContract = accessInfo.mapContracts.get('FRM_Program');
        Contract scrContract = accessInfo.mapContracts.get('SCR_Program');
        Contract riskaiContract = accessInfo.mapContracts.get('Risk_AI_Program');

        MAP<String,Exam_Attempt__c> mapLatestExamAttempts = new MAP<String,Exam_Attempt__c>();
        //if(frmContract != NULL || scrContract != NULL) {
        GARP_BC_MyPrograms.returnLatestExamAttempts returnLatestExamAttempts = GARP_BC_MyPrograms.getLatestExamAttempts(contactId);
        mapLatestExamAttempts = returnLatestExamAttempts.mapLatestExamAttempts;
        //}

        Boolean isActiveExamAttempt = False;
        for(Exam_Attempt__c ea :mapLatestExamAttempts.values()) {
            if(ea.Result__c == NULL) {
                isActiveExamAttempt = TRUE;
            }
        }
        GARP_Common.debugLog('GARP_BC_MemberPortal','computeAdType','isActiveExamAttempt',isActiveExamAttempt);

        if(isActiveExamAttempt) {
            return NULL;
        }

        if(frmContract == NULL) {
            // Adding two to give FRM more weight
            canShowPrograms.add('FRM');
            canShowPrograms.add('FRM');
            programCnt=2;
        } else if(frmContract.Status == 'Expired') {
            canShowPrograms.add('FRM');
            canShowPrograms.add('FRM');
            programCnt=2;
        } else {
            // Get latest FRM Exam Attempt
            Exam_Attempt__c frmExamAttempt = mapLatestExamAttempts.get('FRMII');
            if(frmExamAttempt == NULL) {
                frmExamAttempt = mapLatestExamAttempts.get('FRMI');
            }
            GARP_Common.debugLog('GARP_BC_MemberPortal','computeAdType','frmExamAttempt',frmExamAttempt);

            if(frmExamAttempt != NULL && frmExamAttempt.RPT_Administration_Date__c != NULL) {
                Long frmdiff = tdy.daysBetween(frmExamAttempt.RPT_Administration_Date__c);
                GARP_Common.debugLog('GARP_BC_MemberPortal','computeAdType','frmdiff',frmdiff);

                if(frmdiff > 365) {
                    canShowPrograms.add('FRM');
                    canShowPrograms.add('FRM');
                    programCnt=2;
                }
            }
        }

        if(scrContract == NULL) {
            canShowPrograms.add('SCR');
            programCnt++;
        } else if(scrContract.Status == 'Expired') {
            canShowPrograms.add('SCR');
            programCnt++;
        } else {
            Exam_Attempt__c scrExamAttempt = mapLatestExamAttempts.get('SCRFull');
            if(scrExamAttempt != NULL && scrExamAttempt.RPT_Administration_Date__c != NULL) {
                Long scrdiff = tdy.daysBetween(scrExamAttempt.RPT_Administration_Date__c);
                GARP_Common.debugLog('GARP_BC_MemberPortal','computeAdType','scrdiff',scrdiff);

                if(scrdiff > 365) {
                    canShowPrograms.add('SCR');
                    programCnt++;
                }
            }
        }

        if(riskaiContract == NULL) {
            canShowPrograms.add('RAI');
            programCnt++;
        } else if(riskaiContract.Status == 'Expired') {
            canShowPrograms.add('RAI');
            programCnt++;
        } else {
            Exam_Attempt__c riskaiExamAttempt = mapLatestExamAttempts.get('RiskAIFull');
            if(riskaiExamAttempt != NULL && riskaiExamAttempt.RPT_Administration_Date__c != NULL) {
                Long riskaidiff = tdy.daysBetween(riskaiExamAttempt.RPT_Administration_Date__c);
                GARP_Common.debugLog('GARP_BC_MemberPortal','computeAdType','riskaidiff',riskaidiff);

                if(riskaidiff > 365) {
                    canShowPrograms.add('RAI');
                    programCnt++;
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_MemberPortal','computeAdType','canShowPrograms',canShowPrograms);

        if(programCnt > 0) {
            Integer randomNumber = Integer.valueof((Math.random() * programCnt));
            GARP_Common.debugLog('GARP_BC_MemberPortal','computeAdType','randomNumber',randomNumber);

            ret =  canShowPrograms[randomNumber];
        }

        GARP_Common.debugLog('GARP_BC_MemberPortal','computeAdType','ret',ret);

        return ret;
    }

    public class returnAdInfo {
        public String statusMessage;
        public Integer statusCode;
        public String adType;  // FRM, SCR
        public String adminName;
        public Boolean isRegistrationOpen;
        public Date nextAdminRegistrationOpenDate;
    }

    public static returnAdInfo getComponentAdInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentAdInfo','contactId',contactId);

        returnAdInfo returnAdInfo = new returnAdInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnAdInfo.statusMessage = 'Portal Access Denied';
                returnAdInfo.statusCode = accessInfo.statusCode;
                return returnAdInfo;
            }

            returnAdInfo.adType = computeAdType(contactId, accessInfo);

            // Get Admin Details

            // Get Active Exam Admin Info
            String programAbbrev = returnAdInfo.adType;
            if(programAbbrev == 'RAI') {
                programAbbrev = 'RiskAI';
            }
            GARP_BC_MyPrograms.currentNextExamAdminRegInfo currentNextExamAdminRegInfo = GARP_BC_MyPrograms.getCurrentNextExamAdminRegInfo(programAbbrev);
            if(currentNextExamAdminRegInfo != NULL) {
                returnAdInfo.isRegistrationOpen = currentNextExamAdminRegInfo.isRegistrationOpen;
                if(currentNextExamAdminRegInfo.currentExamAdminName != NULL) {
                    returnAdInfo.adminName = currentNextExamAdminRegInfo.currentExamAdminName;
                } else if(currentNextExamAdminRegInfo.nextExamAdminName != NULL) {
                    returnAdInfo.adminName = currentNextExamAdminRegInfo.nextExamAdminName;
                }
                if(!currentNextExamAdminRegInfo.isRegistrationOpen) {
                    returnAdInfo.nextAdminRegistrationOpenDate = currentNextExamAdminRegInfo.nextExamAdminRegistrationOpenDate;
                }
            }

            returnAdInfo.statusMessage = 'Success';
            returnAdInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentAdInfo','returnAdInfo',returnAdInfo);

        return returnAdInfo;
    }

    // Study Materials

    public class returnGetStudyMaterialListing {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_StudyMaterials.studyMaterialsInfo studyMaterialsInfo;
    }

    public static returnGetStudyMaterialListing getStudyMaterialListing(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getStudyMaterialListing','contactId',contactId);

        returnGetStudyMaterialListing returnGetStudyMaterialListing = new returnGetStudyMaterialListing();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetStudyMaterialListing.statusMessage = 'Portal Access Denied';
                returnGetStudyMaterialListing.statusCode = accessInfo.statusCode;
                return returnGetStudyMaterialListing;
            }

            // Compute if should FRM BenchPrep / Practice Exam Part I and Practice Exam Part II Access
            GARP_BC_MyPrograms.enrolledPrograms enrolledPrograms = GARP_BC_MyPrograms.getEnrolledPrograms(contactId, accessInfo.mapContracts, '');

            GARP_BC_StudyMaterials.getStudyMaterialsResult getResult = GARP_BC_StudyMaterials.getStudyMaterials(contact.AccountId, contact.Id, accessInfo.mapContracts, enrolledPrograms.microCoursesMap, enrolledPrograms.microCourseConfig);
            if(getResult.status == 'Failed') {
                returnGetStudyMaterialListing.statusMessage = getResult.message;
                returnGetStudyMaterialListing.statusCode = 404;
            } else {
                returnGetStudyMaterialListing.studyMaterialsInfo = getResult.studyMaterialsInfo;
                returnGetStudyMaterialListing.statusMessage = 'Success';
                returnGetStudyMaterialListing.statusCode = 200;
            }

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentAdInfo','returnGetStudyMaterialListing',returnGetStudyMaterialListing);

        return returnGetStudyMaterialListing;
    }

    public class returnGetMyEBooksInfo {
        public String statusMessage;
        public Integer statusCode;
        public MAP<Integer, List<GARP_BC_StudyMaterials.eBook>> eBooks;
    }

    public static returnGetMyEBooksInfo getMyEBooksInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getMyEBooksInfo','contactId',contactId);

        returnGetMyEBooksInfo returnGetMyEBooksInfo = new returnGetMyEBooksInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetMyEBooksInfo.statusMessage = 'Portal Access Denied';
                returnGetMyEBooksInfo.statusCode = accessInfo.statusCode;
                return returnGetMyEBooksInfo;
            }

            returnGetMyEBooksInfo.eBooks = new MAP<Integer, List<GARP_BC_StudyMaterials.eBook>>();

            List<GARP_BC_StudyMaterials.eBook> eBooks = GARP_BC_StudyMaterials.getMyElectronicStudyMaterials(contact.accountId, NULL);
            for(GARP_BC_StudyMaterials.eBook eBook :eBooks) {

                if(eBook.eBookItems != NULL) {
                    List<GARP_BC_StudyMaterials.eBook> fndEBookList = returnGetMyEBooksInfo.eBooks.get(eBook.year);
                    if(fndEBookList == NULL) {
                        fndEBookList = new List<GARP_BC_StudyMaterials.eBook>();
                    }
                    fndEBookList.add(eBook);
                    returnGetMyEBooksInfo.eBooks.put(eBook.year, fndEBookList);
                }
            }

            returnGetMyEBooksInfo.statusMessage = 'eBooks Returned';
            returnGetMyEBooksInfo.statusCode = 200;


        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getMyEBooksInfo','returnGetMyEBooksInfo',returnGetMyEBooksInfo);

        return returnGetMyEBooksInfo;
    }

    public class returnEBookAccessURLs {
        public String statusMessage;
        public Integer statusCode;
        public List<eBookAccessInfo> accessURLs;
    }

    public class eBookAccessInfo {
        public string title;
        public String accessURL;
        public String errorMessage;
    }

    public static returnEBookAccessURLs getEBookAccessURLs(String contactId, List<GARP_BC_StudyMaterials.eBookItem> eBookItems){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getEBookAccessURLs','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getEBookAccessURLs','eBookItems',eBookItems);

        returnEBookAccessURLs returnEBookAccessURLs = new returnEBookAccessURLs();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnEBookAccessURLs.statusMessage = 'Portal Access Denied';
                returnEBookAccessURLs.statusCode = accessInfo.statusCode;
                return returnEBookAccessURLs;
            }

            returnEBookAccessURLs.accessURLs = new List<eBookAccessInfo>();

            for(GARP_BC_StudyMaterials.eBookItem ei :eBookItems) {
                mobiusAPI.mUserLoginResp mULResp = GARP_BC_StudyMaterials.getEBookAccessURL(contact, String.ValueOf(ei.vendorId));
                GARP_Common.debugLog('GARP_BC_MemberPortal','getEBookAccessURLs','mULResp',mULResp);

                eBookAccessInfo eBookAccessInfo = new eBookAccessInfo();
                eBookAccessInfo.title = ei.title;
                if(mULResp != NULL && mULResp.link != NULL) {
                    eBookAccessInfo.accessURL = mULResp.link;
                } else {
                    eBookAccessInfo.errorMessage = 'Access link not available';
                }
                returnEBookAccessURLs.accessURLs.add(eBookAccessInfo);
            }

            returnEBookAccessURLs.statusMessage = 'Success';
            returnEBookAccessURLs.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getEBookAccessURLs','returnEBookAccessURLs',returnEBookAccessURLs);

        return returnEBookAccessURLs;
    }

    public class returnEBookAccessURL {
        public String statusMessage;
        public Integer statusCode;
        public String accessURL;
    }

    public static returnEBookAccessURL getEBookAccessURL(String contactId, String vendorId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getEBookAccessURL','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getEBookAccessURL','vendorId',vendorId);

        returnEBookAccessURL returnEBookAccessURL = new returnEBookAccessURL();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnEBookAccessURL.statusMessage = 'Portal Access Denied';
                returnEBookAccessURL.statusCode = accessInfo.statusCode;
                return returnEBookAccessURL;
            }

            mobiusAPI.mUserLoginResp mULResp = GARP_BC_StudyMaterials.getEBookAccessURL(contact, vendorId);
            GARP_Common.debugLog('GARP_BC_MemberPortal','getEBookAccessURL','mULResp',mULResp);

            if(mULResp != NULL && mULResp.link != NULL) {
                returnEBookAccessURL.statusMessage = 'Success';
                returnEBookAccessURL.statusCode = 200;
                returnEBookAccessURL.accessURL = mULResp.link;
            } else {
                returnEBookAccessURL.statusMessage = 'Access link not returned';
                returnEBookAccessURL.statusCode = 501;
            }

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getEBookAccessURL','returnEBookAccessURL',returnEBookAccessURL);

        return returnEBookAccessURL;
    }

    public class returnGetErrataFormInfo {
        public String statusMessage;
        public Integer statusCode;
        MAP<String,List<String>> errataPicklistOption;
    }

    public static returnGetErrataFormInfo getErrataFormInfo(String contactId, String programType){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getErrataFormInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getErrataFormInfo','programType',programType);

        returnGetErrataFormInfo returnGetErrataFormInfo = new returnGetErrataFormInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetErrataFormInfo.statusMessage = 'Portal Access Denied';
                returnGetErrataFormInfo.statusCode = accessInfo.statusCode;
                return returnGetErrataFormInfo;
            }

            Contract frmContract = accessInfo.mapContracts.get('FRM_Program');
            Contract scrContract = accessInfo.mapContracts.get('SCR_Program');
            Contract riskaiContract = accessInfo.mapContracts.get('Risk_AI_Program');
            Contract raijContract = accessInfo.mapContracts.get('RAIJ_Program');
            Contract frrContract = accessInfo.mapContracts.get('ICBRR_Program');

            Boolean hasAccess = FALSE;
            if((frmContract != NULL && frmContract.Status.IndexOf('Activated') > -1) ||
               (scrContract != NULL && scrContract.Status.IndexOf('Activated') > -1) ||
               (riskaiContract != NULL && riskaiContract.Status.IndexOf('Activated') > -1) ||
               (raijContract != NULL && raijContract.Status.IndexOf('Activated') > -1) ||
               (frrContract != NULL && frrContract.Status.IndexOf('Activated') > -1)) {
                   hasAccess = TRUE;
               }

            if(!hasAccess) {
                returnGetErrataFormInfo.statusMessage = 'Errata Access Denied';
                returnGetErrataFormInfo.statusCode = 403;
                return returnGetErrataFormInfo;
            }

            returnGetErrataFormInfo.errataPicklistOption = GARP_BC_StudyMaterials.getErrataPicklistOption(programType);

            returnGetErrataFormInfo.statusMessage = 'Success';
            returnGetErrataFormInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentAdInfo','returnGetErrataFormInfo',returnGetErrataFormInfo);

        return returnGetErrataFormInfo;
    }

    public class returnSubmitErrataFormInfo {
        public String statusMessage;
        public Integer statusCode;
        public String errataId;
    }

    public static returnSubmitErrataFormInfo submitErrataForm(String contactId, GARP_BC_StudyMaterials.errataFormSubmissionInfo errataFormSubmissionInfo){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getErrataFormInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getErrataFormInfo','errataFormSubmissionInfo',errataFormSubmissionInfo);

        returnSubmitErrataFormInfo returnSubmitErrataFormInfo = new returnSubmitErrataFormInfo();

        if(errataFormSubmissionInfo == NULL || errataFormSubmissionInfo.programType == NULL ||
           errataFormSubmissionInfo.studyMaterial == NULL || errataFormSubmissionInfo.book == NULL ||
           errataFormSubmissionInfo.pageNumber == NULL || errataFormSubmissionInfo.errorDescription == NULL
          ) {
              returnSubmitErrataFormInfo.statusMessage = 'Required information missing';
              returnSubmitErrataFormInfo.statusCode = 501;
              return returnSubmitErrataFormInfo;
          }

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSubmitErrataFormInfo.statusMessage = 'Portal Access Denied';
                returnSubmitErrataFormInfo.statusCode = accessInfo.statusCode;
                return returnSubmitErrataFormInfo;
            }

            String errataId = GARP_BC_StudyMaterials.addErrataSubmission(contactId, errataFormSubmissionInfo);

            returnSubmitErrataFormInfo.errataId = errataId;
            returnSubmitErrataFormInfo.statusMessage = 'Success';
            returnSubmitErrataFormInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentAdInfo','returnSubmitErrataFormInfo',returnSubmitErrataFormInfo);

        return returnSubmitErrataFormInfo;
    }

    public class returnAttachFileErrataSubmission {
        public String statusMessage;
        public Integer statusCode;
        public String fileId;
    }

    public static returnAttachFileErrataSubmission attachFileErrataSubmission(String ContactId, String errataId, String fileName, String filetext, String fileId) {
        returnAttachFileErrataSubmission ret = new returnAttachFileErrataSubmission();

        if(errataId == NULL || fileName == NULL || filetext == NULL) {
              ret.statusMessage = 'Required information missing';
              ret.statusCode = 501;
              return ret;
          }

        Contact contact = getContact(ContactId);
        verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
        if(accessInfo.statusCode != 200) {
            ret.statusMessage = 'Portal Access Denied';
            ret.statusCode = accessInfo.statusCode;
            return ret;
        }

        String newFileId = GARP_Common.uploadAttachmentToObject(fileId, filetext, fileName, errataId);
        if(newFileId != NULL) {
            ret.fileId = newFileId;
            ret.statusMessage = 'Succsefully attached';
            ret.statusCode = 200;
        } else {
            ret.statusMessage = 'There was an issue attaching the file';
            ret.statusCode = 501;
        }
        return ret;
    }


    // Member Directory

    public class returnGetDirectorySearchFormInfo {
        public String statusMessage;
        public Integer statusCode;
        public List<String> industries;
        public List<String> professionalLevels;
        public List<String> jobFunctions;
        public List<String> riskSpecialties;
        public Boolean hasAdvancedSearch;
        public String hasUpsellMembershipType; // Upgrade, Renew, NULL - is already a member
        public String pendingMembershipOrderId;
   }

    public static returnGetDirectorySearchFormInfo getDirectorySearchFormInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getDirectorySearchFormInfo','contactId',contactId);

        returnGetDirectorySearchFormInfo returnGetDirectorySearchFormInfo = new returnGetDirectorySearchFormInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetDirectorySearchFormInfo.statusMessage = 'Portal Access Denied';
                returnGetDirectorySearchFormInfo.statusCode = accessInfo.statusCode;
                return returnGetDirectorySearchFormInfo;
            }

            returnGetDirectorySearchFormInfo.industries = GARP_Common.getPickListValues('Contact','Area_of_Concentration__c');
            returnGetDirectorySearchFormInfo.professionalLevels = GARP_Common.getPickListValues('Contact','Corporate_Title__c');
            returnGetDirectorySearchFormInfo.jobFunctions = GARP_Common.getPickListValues('Contact','Job_Function__c');
            returnGetDirectorySearchFormInfo.riskSpecialties = GARP_Common.getPickListValues('Contact','Risk_Specialty__c');

            Contract membershipContract = accessInfo.mapContracts.get('Membership');
            if(membershipContract != NULL && membershipContract.Membership_Type__c == 'Individual' && (membershipContract.status == 'Activated' || membershipContract.status == 'Activated ( Auto-Renew )')) {
                returnGetDirectorySearchFormInfo.hasAdvancedSearch = True;
            } else {
                returnGetDirectorySearchFormInfo.hasAdvancedSearch = False;
                if(membershipContract != NULL && membershipContract.Membership_Type__c == 'Individual' && membershipContract.status == 'Expired') {
                    returnGetDirectorySearchFormInfo.hasUpsellMembershipType = 'Renew';
                } else {
                    returnGetDirectorySearchFormInfo.hasUpsellMembershipType = 'Upgrade';
                }
            }

            // Find open order for Membership
            Set<String> productCodes = new Set<String>{'MEMI','MEMC'};
                Opportunity latestOpenOpp = GARP_BC_Orders.getLatestOppWithGivenProducts(contact.accountID, productCodes, 'New Lead', NULL);
            if(latestOpenOpp != NULL) {
                returnGetDirectorySearchFormInfo.pendingMembershipOrderId = latestOpenOpp.Id;
            }

            returnGetDirectorySearchFormInfo.statusMessage = 'Success';
            returnGetDirectorySearchFormInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentAdInfo','returnGetDirectorySearchFormInfo',returnGetDirectorySearchFormInfo);

        return returnGetDirectorySearchFormInfo;
    }

    public class returnSearchDirectoryInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_Membership.searchResults searchResults;
    }

    public static returnSearchDirectoryInfo searchMemberDirectory(String contactId, GARP_BC_Membership.searchParams searchParams){
        GARP_Common.debugLog('GARP_BC_MemberPortal','searchMemberDirectory','contactId',contactId);

        returnSearchDirectoryInfo returnSearchDirectoryInfo = new returnSearchDirectoryInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSearchDirectoryInfo.statusMessage = 'Portal Access Denied';
                returnSearchDirectoryInfo.statusCode = accessInfo.statusCode;
                return returnSearchDirectoryInfo;
            }

            Boolean isMemberInGoodStanding = False;

            Contract membershipContract = accessInfo.mapContracts.get('Membership');
            if(membershipContract != NULL && membershipContract.Membership_Type__c == 'Individual' && (membershipContract.status == 'Activated' || membershipContract.status == 'Activated ( Auto-Renew )')) {
                isMemberInGoodStanding = True;
            }

            returnSearchDirectoryInfo.searchResults = GARP_BC_Membership.searchMembers(contactId, searchParams, isMemberInGoodStanding);

            returnSearchDirectoryInfo.statusMessage = 'Success';
            returnSearchDirectoryInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentAdInfo','returnSearchDirectoryInfo',returnSearchDirectoryInfo);

        return returnSearchDirectoryInfo;
    }

    public class returnGetMemberDirectorySettingsFormInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_MemberProfile.memberDirectorySettingsInfo memberDirectorySettingsInfo;
    }

    public static returnGetMemberDirectorySettingsFormInfo getMemberDirectorySettingsFormInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getMemberDirectorySettingsFormInfo','contactId',contactId);

        returnGetMemberDirectorySettingsFormInfo returnGetMemberDirectorySettingsFormInfo = new returnGetMemberDirectorySettingsFormInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetMemberDirectorySettingsFormInfo.statusMessage = 'Portal Access Denied';
                returnGetMemberDirectorySettingsFormInfo.statusCode = accessInfo.statusCode;
                return returnGetMemberDirectorySettingsFormInfo;
            }

            returnGetMemberDirectorySettingsFormInfo.memberDirectorySettingsInfo = GARP_BC_MemberProfile.getMemberDirectorySettingsInfo(contact, accessInfo.mapContracts);

            returnGetMemberDirectorySettingsFormInfo.statusMessage = 'Success';
            returnGetMemberDirectorySettingsFormInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentAdInfo','returnGetMemberDirectorySettingsFormInfo',returnGetMemberDirectorySettingsFormInfo);

        return returnGetMemberDirectorySettingsFormInfo;
    }

    public class returnSetMemberDirectorySettingsFormInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_MemberProfile.memberDirectorySettingsInfo memberDirectorySettingsInfo;
    }

    public static returnSetMemberDirectorySettingsFormInfo setMemberDirectorySettingsFormInfo(String contactId, GARP_BC_MemberProfile.memberDirectorySettings directorySettings){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getMemberDirectorySettingsFormInfo','contactId',contactId);

        returnSetMemberDirectorySettingsFormInfo returnSetMemberDirectorySettingsFormInfo = new returnSetMemberDirectorySettingsFormInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetMemberDirectorySettingsFormInfo.statusMessage = 'Portal Access Denied';
                returnSetMemberDirectorySettingsFormInfo.statusCode = accessInfo.statusCode;
                return returnSetMemberDirectorySettingsFormInfo;
            }

            GARP_BC_MemberProfile.setMemberDirectorySettingsInfo(contact, directorySettings);

            returnSetMemberDirectorySettingsFormInfo.statusMessage = 'Success';
            returnSetMemberDirectorySettingsFormInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentAdInfo','returnSetMemberDirectorySettingsFormInfo',returnSetMemberDirectorySettingsFormInfo);

        return returnSetMemberDirectorySettingsFormInfo;
    }

    public class returnSendMemberDirectoryMessageInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    // msgType can be Directory_Connect or Directory_Connect_Invite
    public static returnSendMemberDirectoryMessageInfo sendMemberDirectoryMessage(String contactId, GARP_BC_Membership.sendMemberMessageInfo sendMemberMessageInfo){
        GARP_Common.debugLog('GARP_BC_MemberPortal','sendMemberDirectoryMessage','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','sendMemberDirectoryMessage','sendMemberMessageInfo',sendMemberMessageInfo);

        returnSendMemberDirectoryMessageInfo returnSendMemberDirectoryMessageInfo = new returnSendMemberDirectoryMessageInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSendMemberDirectoryMessageInfo.statusMessage = 'Portal Access Denied';
                returnSendMemberDirectoryMessageInfo.statusCode = accessInfo.statusCode;
                return returnSendMemberDirectoryMessageInfo;
            }

            Boolean isMemberInGoodStanding = False;
            Contract membershipContract = accessInfo.mapContracts.get('Membership');
            if(membershipContract != NULL && membershipContract.Membership_Type__c == 'Individual' && (membershipContract.status == 'Activated' || membershipContract.status == 'Activated ( Auto-Renew )')) {
                isMemberInGoodStanding = True;
            }

            String retStatus = GARP_BC_Membership.sendDirectoryMessage(contact, isMemberInGoodStanding, sendMemberMessageInfo);
            if(retStatus != 'Success') {
                returnSendMemberDirectoryMessageInfo.statusMessage = retStatus;
                returnSendMemberDirectoryMessageInfo.statusCode = 501;
                return returnSendMemberDirectoryMessageInfo;
            }

            returnSendMemberDirectoryMessageInfo.statusMessage = 'Success';
            returnSendMemberDirectoryMessageInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getComponentAdInfo','returnSendMemberDirectoryMessageInfo',returnSendMemberDirectoryMessageInfo);

        return returnSendMemberDirectoryMessageInfo;
    }

    // Orders

    public class returnPurchaseHistoryInfo {
        public String statusMessage;
        public Integer statusCode;
        List<GARP_BC_Orders.orderInfo> unpaidOrders;
        List<GARP_BC_Orders.orderInfo> paidOrders;
    }

    public static returnPurchaseHistoryInfo getPurchaseHistoryInfo(String contactId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getPurchaseHistoryInfo','contactId',contactId);

        returnPurchaseHistoryInfo returnPurchaseHistoryInfo = new returnPurchaseHistoryInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnPurchaseHistoryInfo.statusMessage = 'Portal Access Denied';
                returnPurchaseHistoryInfo.statusCode = accessInfo.statusCode;
                return returnPurchaseHistoryInfo;
            }

            returnPurchaseHistoryInfo.unpaidOrders = new List<GARP_BC_Orders.orderInfo>();
            returnPurchaseHistoryInfo.paidOrders = new List<GARP_BC_Orders.orderInfo>();

            MAP<String, GARP_BC_Orders.orderInfo> orders = GARP_BC_Orders.getMemberOrders(contact.AccountId, NULL);
            for(GARP_BC_Orders.orderInfo oi :orders.values()) {
                if(oi.isClosed) {
                    returnPurchaseHistoryInfo.paidOrders.add(oi);
                } else {
                    returnPurchaseHistoryInfo.unpaidOrders.add(oi);
                }
            }

            returnPurchaseHistoryInfo.statusMessage = 'Success';
            returnPurchaseHistoryInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getPurchaseHistoryInfo','returnPurchaseHistoryInfo',returnPurchaseHistoryInfo);

        return returnPurchaseHistoryInfo;
    }

    public class returnGetOrderInfo {
        public String statusMessage;
        public Integer statusCode;
        GARP_BC_Orders.orderInfo orderInfo;
    }

    public static returnGetOrderInfo getOrderInfo(String contactId, String orderNumber){
        GARP_Common.debugLog('GARP_BC_MemberPortal','getOrderInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getOrderInfo','orderNumber',orderNumber);

        returnGetOrderInfo returnGetOrderInfo = new returnGetOrderInfo();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetOrderInfo.statusMessage = 'Portal Access Denied';
                returnGetOrderInfo.statusCode = accessInfo.statusCode;
                return returnGetOrderInfo;
            }

            MAP<String, GARP_BC_Orders.orderInfo> orders = GARP_BC_Orders.getMemberOrders(contact.AccountId, NULL);
            GARP_BC_Orders.orderInfo fndOrder = orders.get(orderNumber);
            if(fndOrder == NULL) {
                returnGetOrderInfo.statusMessage = 'Order not found';
                returnGetOrderInfo.statusCode = 404;
                return returnGetOrderInfo;
            }
            returnGetOrderInfo.orderInfo = fndOrder;
            returnGetOrderInfo.statusMessage = 'Success';
            returnGetOrderInfo.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getOrderInfo','returnGetOrderInfo',returnGetOrderInfo);

        return returnGetOrderInfo;
    }

    public class returnCancelUnpaidOrder {
        public String statusMessage;
        public Integer statusCode;
        GARP_BC_Orders.orderInfo orderInfo;
    }

    public static returnCancelUnpaidOrder cancelUnpaidOrder(String contactId, String orderId){
        GARP_Common.debugLog('GARP_BC_MemberPortal','cancelUnpaidOrder','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','cancelUnpaidOrder','orderNumber',orderId);

        returnCancelUnpaidOrder returnCancelUnpaidOrder = new returnCancelUnpaidOrder();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnCancelUnpaidOrder.statusMessage = 'Portal Access Denied';
                returnCancelUnpaidOrder.statusCode = accessInfo.statusCode;
                return returnCancelUnpaidOrder;
            }

            GARP_Common.returnInfo retInfo = GARP_BC_Orders.cancelUnpaidOrder(contact.accountId, orderId);
            if(retInfo.status != 'Success') {
                returnCancelUnpaidOrder.statusMessage = retInfo.msg;
                returnCancelUnpaidOrder.statusCode = 501;
                return returnCancelUnpaidOrder;
            }

            returnCancelUnpaidOrder.statusMessage = 'Success';
            returnCancelUnpaidOrder.statusCode = 200;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getOrderInfo','returnCancelUnpaidOrder',returnCancelUnpaidOrder);

        return returnCancelUnpaidOrder;
    }
    
    public class returnPayPendingOrder {
        public String statusMessage;
        public Integer statusCode;
        GARP_BC_Orders.orderInfo orderInfo;
    }

    public static returnPayPendingOrder payPendingOrder(String contactId, String orderId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','cancelUnpaidOrder','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','cancelUnpaidOrder','orderNumber',orderId);

        returnPayPendingOrder returnPayPendingOrder = new returnPayPendingOrder();

        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnPayPendingOrder.statusMessage = 'Portal Access Denied';
                returnPayPendingOrder.statusCode = accessInfo.statusCode;
                return returnPayPendingOrder;
            }

            GARP_Common.returnInfo retInfo = GARP_BC_Orders.payPendingOrder(contact.accountId, orderId);
            if(retInfo.status != 'Success') {
                returnPayPendingOrder.statusMessage = retInfo.msg;
                returnPayPendingOrder.statusCode = retInfo.errorCode;
                return returnPayPendingOrder;
            }

            returnPayPendingOrder.statusMessage = 'Success';
            returnPayPendingOrder.statusCode = retInfo.errorCode;

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getOrderInfo','returnPayPendingOrder',returnPayPendingOrder);

        return returnPayPendingOrder;
    }
    
    // Membership Benefits

    public class returnGetMembershipPageInfo {
        public String statusMessage;
        public Integer statusCode;

        public String firstName;
        public String lastName;
        public String garpId;
        public String photoURL;
        public String membershipType;
        public String membershipStatus; // Active / Lapsed
        public String pendingMembershipOrderId;

        public GARP_BC_Membership.memberBenefitsInfo memberBenefitsInfo;
    }

    public static  returnGetMembershipPageInfo getMembershipPageInfo(String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getMembershipPageInfo','contactId',contactId);

        returnGetMembershipPageInfo returnGetMembershipPageInfo = new returnGetMembershipPageInfo();
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetMembershipPageInfo.statusMessage = 'Portal Access Denied';
                returnGetMembershipPageInfo.statusCode = accessInfo.statusCode;
                return returnGetMembershipPageInfo;
            }

            returnGetMembershipPageInfo.firstName = contact.FirstName;
            returnGetMembershipPageInfo.lastName = contact.LastName;
            returnGetMembershipPageInfo.garpId = contact.GARP_Member_ID__c;
            returnGetMembershipPageInfo.photoURL = contact.Photo_URL__c;


            GARP_Common.debugLog('GARP_BC_MemberPortal','getMembershipPageInfo','returnGetMembershipPageInfo 1',returnGetMembershipPageInfo);

            Contract membershipContract = accessInfo.mapContracts.get('Membership');
            GARP_Common.debugLog('GARP_BC_MemberPortal','getMembershipPageInfo','membershipContract',membershipContract);

            if(membershipContract != NULL) {

                returnGetMembershipPageInfo.membershipType = membershipContract.Membership_Type__c;
                returnGetMembershipPageInfo.membershipStatus = (membershipContract.Status.IndexOf('Activated') > -1) ? 'Active' : 'Lapsed';

                GARP_Common.debugLog('GARP_BC_MemberPortal','getMembershipPageInfo','returnGetMembershipPageInfo 2',returnGetMembershipPageInfo);

                returnGetMembershipPageInfo.memberBenefitsInfo = GARP_BC_Membership.getMemberBenifitsInfo(contact, accessInfo.mapContracts);

                // Find open order for Membership
                Set<String> productCodes = new Set<String>{'MEMI','MEMC'};
                Opportunity latestOpenOpp = GARP_BC_Orders.getLatestOppWithGivenProducts(contact.accountID, productCodes, 'New Lead', NULL);
                if(latestOpenOpp != NULL) {
                    returnGetMembershipPageInfo.pendingMembershipOrderId = latestOpenOpp.Id;
                }

                returnGetMembershipPageInfo.statusMessage = 'Success';
                returnGetMembershipPageInfo.statusCode = 200;

            } else {
                returnGetMembershipPageInfo.statusMessage = 'Membership Contract not found';
                returnGetMembershipPageInfo.statusCode = 401;
                return returnGetMembershipPageInfo;
            }

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getMembershipPageInfo','returnGetMembershipPageInfo',returnGetMembershipPageInfo);

        return returnGetMembershipPageInfo;
    }

    // Help Center

    public class returnSubmitCustomerCase {
        public String statusMessage;
        public Integer statusCode;
    }

    public static  returnSubmitCustomerCase submitCustomerCase(String userId, String contactId, String title, String description) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','submitCustomerCase','contactId',contactId);

        returnSubmitCustomerCase returnSubmitCustomerCase = new returnSubmitCustomerCase();
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSubmitCustomerCase.statusMessage = 'Portal Access Denied';
                returnSubmitCustomerCase.statusCode = accessInfo.statusCode;
                return returnSubmitCustomerCase;
            }

            GARP_Common.returnInfo ret = GARP_BC_MemberProfile.submitCustomerCase(contact, userId, title, description);

            returnSubmitCustomerCase.statusMessage = 'Success';
            returnSubmitCustomerCase.statusCode = 200;


        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getPurchaseHistoryInfo','returnSubmitCustomerCase',returnSubmitCustomerCase);

        return returnSubmitCustomerCase;
    }

    public class returnGetOSTAIDInfo {
        public String statusMessage;
        public Integer statusCode;
        public GARP_BC_MyPrograms.OSTAIDInfo OSTAIDInfo;
    }

    public static  returnGetOSTAIDInfo getOSTAIDInfo(String contactId) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getOSTAIDInfo','contactId',contactId);

        returnGetOSTAIDInfo returnGetOSTAIDInfo = new returnGetOSTAIDInfo();
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnGetOSTAIDInfo.statusMessage = 'Portal Access Denied';
                returnGetOSTAIDInfo.statusCode = accessInfo.statusCode;
                return returnGetOSTAIDInfo;
            }

            returnGetOSTAIDInfo.OSTAIDInfo = GARP_BC_MyPrograms.getOSTAIDInfo(contact);

            returnGetOSTAIDInfo.statusMessage = 'Success';
            returnGetOSTAIDInfo.statusCode = 200;


        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getPurchaseHistoryInfo','returnGetOSTAIDInfo',returnGetOSTAIDInfo);

        return returnGetOSTAIDInfo;
    }

    public class returnSetOSTAIDInfo {
        public String statusMessage;
        public Integer statusCode;
    }

    public static  returnSetOSTAIDInfo setOSTAIDInfo(String contactId, GARP_BC_MyPrograms.OSTAIDInfo OSTAIDInfo) {
        GARP_Common.debugLog('GARP_BC_MemberPortal','getOSTAIDInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberPortal','getOSTAIDInfo','OSTAIDInfo',OSTAIDInfo);

        returnSetOSTAIDInfo returnSetOSTAIDInfo = new returnSetOSTAIDInfo();
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnSetOSTAIDInfo.statusMessage = 'Portal Access Denied';
                returnSetOSTAIDInfo.statusCode = accessInfo.statusCode;
                return returnSetOSTAIDInfo;
            }

            GARP_Common.returnInfo ret = GARP_BC_MyPrograms.setOSTAIDInfo(contact, OSTAIDInfo);
            if(ret.status == 'Success') {
                returnSetOSTAIDInfo.statusMessage = 'Success';
                returnSetOSTAIDInfo.statusCode = 200;
            } else {
                returnSetOSTAIDInfo.statusMessage = ret.msg;
                returnSetOSTAIDInfo.statusCode = 501;
            }

        

        GARP_Common.debugLog('GARP_BC_MemberPortal','getPurchaseHistoryInfo','returnSetOSTAIDInfo',returnSetOSTAIDInfo);

        return returnSetOSTAIDInfo;
    }
    
    // BenchPrep Viewer
    
    public class benchPrepAccessLink {
        public String name;
        public String url;
    }
    
    public class returnBenchPrepLinks {
        public String statusMessage;
        public Integer statusCode;
        public List<benchPrepAccessLink> benchPrepLinks;
    }
    
    public static returnBenchPrepLinks getBenchPrepLinks(String contactId) {
        
        returnBenchPrepLinks returnBenchPrepLinks = new returnBenchPrepLinks();
        
        GARP_Common.debugLog('GARP_BC_MemberPortal', 'getBenchPrepLinks', 'contactId', contactId);
        
        Contact contact = getContact(contactId);
            verifyPortalAccessInfo accessInfo = verifyMemberPortalAccess(contact.Id, contact.AccountId);
            if(accessInfo.statusCode != 200) {
                returnBenchPrepLinks.statusMessage = 'Portal Access Denied';
                returnBenchPrepLinks.statusCode = accessInfo.statusCode;
                return returnBenchPrepLinks;
            }
            
            List<eBook_Key__c> lstEBookKeys = [select id, Opp_Exam_Emails__c , Product_ID__c 
                                               from eBook_Key__c
                                               where Status__c  = 'Taken' AND Access_Expiration_Date__c  >= TODAY AND Access_Revoked__c = False AND
                                               Contact__c = :contact.Id];

            GARP_Common.debugLog('GARP_BC_MemberPortal', 'getBenchPrepLinks', 'lstEBookKeys', lstEBookKeys);
            
            returnBenchPrepLinks.benchPrepLinks = new List<benchPrepAccessLink>();
            for(eBook_Key__c ek :lstEBookKeys) {
                benchPrepAccessLink benchPrepAccessLink = new benchPrepAccessLink();
                benchPrepAccessLink.name = ek.Opp_Exam_Emails__c;
                if(ek.Opp_Exam_Emails__c == NULL) {
                    benchPrepAccessLink.name = ek.Product_ID__c;
                    if(ek.Product_ID__c.tolowercase().IndexOf('scr') > -1) {
                        benchPrepAccessLink.name = 'SCR';
                    } else if(ek.Product_ID__c.tolowercase().IndexOf('raij') > -1) {
                        benchPrepAccessLink.name = 'RAIJ';
                    } else if(ek.Product_ID__c.tolowercase().IndexOf('rai') > -1) {
                        benchPrepAccessLink.name = 'Risk & AI';
                    } else if(ek.Product_ID__c.tolowercase().IndexOf('frm') > -1) {
                        benchPrepAccessLink.name = 'FRM';
                    } else if(ek.Product_ID__c.tolowercase().IndexOf('frr') > -1) {
                        benchPrepAccessLink.name = 'FRR';
                    }
                    if(ek.Product_ID__c.right(1) == 'm') {
                        benchPrepAccessLink.name += ' Refresher';
                    }
                }
                benchPrepAccessLink.url = Label.BenchBrepSSOLink;
                
                returnBenchPrepLinks.benchPrepLinks.add(benchPrepAccessLink);
            }
            
            returnBenchPrepLinks.statusMessage = 'Links returned';
            returnBenchPrepLinks.statusCode = 200;
            
            
                
        
        GARP_Common.debugLog('GARP_BC_MemberPortal', 'getBenchPrepLinks', 'returnBenchPrepLinks', returnBenchPrepLinks);

        return returnBenchPrepLinks;
    }
    
    
    // Work Experience

    public class returnWorkExperienceAttachmentInfo {
        public String status;
        public String message;
        public Integer statusCode;
        public List<AttachmentInfo> attachments;
    }

    public class AttachmentInfo {
        public Id id;
        public String name;
        public String url;
    }

    @RemoteAction
    public static returnWorkExperienceAttachmentInfo uploadWorkExperienceAttachment(Id workExperienceId, String fileName, String base64Data) {
        returnWorkExperienceAttachmentInfo returnWorkExperienceAttachmentInfo = new returnWorkExperienceAttachmentInfo();
        GARP_Common.debugLog('GARP_BC_MemberPortal', 'uploadWorkExperienceAttachment', 'workExperienceId', workExperienceId);
        GARP_Common.debugLog('GARP_BC_MemberPortal', 'uploadWorkExperienceAttachment', 'fileName', fileName);
        GARP_Common.debugLog('GARP_BC_MemberPortal', 'uploadWorkExperienceAttachment', 'base64Data', base64Data);

        try {
            String attachmentId = GARP_Common.uploadAttachmentToObject(null, base64Data, fileName, workExperienceId);
            GARP_Common.debugLog('GARP_BC_MemberPortal', 'uploadWorkExperienceAttachment', 'attachmentId', attachmentId);

            if (attachmentId != null) {
                returnWorkExperienceAttachmentInfo.status = 'success';
                returnWorkExperienceAttachmentInfo.message = 'File uploaded successfully';
                returnWorkExperienceAttachmentInfo.statusCode = 200;
            } else {
                returnWorkExperienceAttachmentInfo.status = 'error';
                returnWorkExperienceAttachmentInfo.message = 'Error uploading file';
                returnWorkExperienceAttachmentInfo.statusCode = 500;
            }
        } catch (Exception e) {
            GARP_Common.debugLog('GARP_BC_MemberPortal', 'uploadWorkExperienceAttachment', 'Exception', e.getMessage());
            returnWorkExperienceAttachmentInfo.status = 'error';
            returnWorkExperienceAttachmentInfo.message = 'Error uploading file: ' + e.getMessage();
            returnWorkExperienceAttachmentInfo.statusCode = 500;
        }
        return returnWorkExperienceAttachmentInfo;
    }

    @RemoteAction
    public static returnWorkExperienceAttachmentInfo deleteWorkExperienceAttachment(Id attachmentId) {
        returnWorkExperienceAttachmentInfo returnWorkExperienceAttachmentInfo = new returnWorkExperienceAttachmentInfo();
        try {
            List<Attachment> attachments = [SELECT Id FROM Attachment WHERE Id = :attachmentId LIMIT 1];
            if (!attachments.isEmpty()) {
                delete attachments[0];
                returnWorkExperienceAttachmentInfo.status = 'success';
                returnWorkExperienceAttachmentInfo.message = 'File deleted successfully';
                returnWorkExperienceAttachmentInfo.statusCode = 200;
            } else {
                returnWorkExperienceAttachmentInfo.status = 'error';
                returnWorkExperienceAttachmentInfo.message = 'Attachment not found';
                returnWorkExperienceAttachmentInfo.statusCode = 404;
            }
        } catch (Exception e) {
            returnWorkExperienceAttachmentInfo.status = 'error';
            returnWorkExperienceAttachmentInfo.message = 'Error deleting file: ' + e.getMessage();
            returnWorkExperienceAttachmentInfo.statusCode = 500;
        }
        return returnWorkExperienceAttachmentInfo;
    }

    @RemoteAction
    public static returnWorkExperienceAttachmentInfo getWorkExperienceAttachments(Id workExperienceId) {
        returnWorkExperienceAttachmentInfo returnWorkExperienceAttachmentInfo = new returnWorkExperienceAttachmentInfo();
        returnWorkExperienceAttachmentInfo.attachments = new List<AttachmentInfo>();
        try {
            List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :workExperienceId];
            for (Attachment attachment : attachments) {
                AttachmentInfo docInfo = new AttachmentInfo();
                docInfo.id = attachment.Id;
                docInfo.name = attachment.Name;
                docInfo.url = '/servlet/servlet.FileDownload?file=' + attachment.Id;
                returnWorkExperienceAttachmentInfo.attachments.add(docInfo);
            }
            returnWorkExperienceAttachmentInfo.status = 'success';
            returnWorkExperienceAttachmentInfo.message = 'Attachments retrieved successfully';
            returnWorkExperienceAttachmentInfo.statusCode = 200;
        } catch (Exception e) {
            returnWorkExperienceAttachmentInfo.status = 'error';
            returnWorkExperienceAttachmentInfo.message = 'Error retrieving attachments: ' + e.getMessage();
            returnWorkExperienceAttachmentInfo.statusCode = 500;
        }
        return returnWorkExperienceAttachmentInfo;
    }

    @RemoteAction
    public static returnWorkExperienceAttachmentInfo downloadWorkExperienceAttachment(Id attachmentId) {
        returnWorkExperienceAttachmentInfo returnWorkExperienceAttachmentInfo = new returnWorkExperienceAttachmentInfo();
        try {
            Attachment attachment = [SELECT Id, Name, Body FROM Attachment WHERE Id = :attachmentId LIMIT 1];
            if (attachment != NULL) {
                AttachmentInfo docInfo = new AttachmentInfo();
                docInfo.id = attachment.Id;
                docInfo.name = attachment.Name;
                docInfo.url = '/servlet/servlet.FileDownload?file=' + attachment.Id;
                returnWorkExperienceAttachmentInfo.attachments = new List<AttachmentInfo>{docInfo};
                returnWorkExperienceAttachmentInfo.status = 'success';
                returnWorkExperienceAttachmentInfo.message = 'Attachment downloaded successfully';
                returnWorkExperienceAttachmentInfo.statusCode = 200;
            } else {
                returnWorkExperienceAttachmentInfo.status = 'error';
                returnWorkExperienceAttachmentInfo.message = 'Attachment not found';
                returnWorkExperienceAttachmentInfo.statusCode = 404;
            }
        } catch (Exception e) {
            returnWorkExperienceAttachmentInfo.status = 'error';
            returnWorkExperienceAttachmentInfo.message = 'Error downloading attachment: ' + e.getMessage();
            returnWorkExperienceAttachmentInfo.statusCode = 500;
        }
        return returnWorkExperienceAttachmentInfo;
    }

    public class returnDocumentRequirementInfo {
        public String status;
        public Integer statusCode;
        public String message;
        public Boolean required;
        public List<String> requiredDocuments;
        public String documentMessage;
        public Boolean hasAttachments;
        public Boolean isValidExperience;
        public String validationMessage;
    }

    @RemoteAction
    public static returnDocumentRequirementInfo isContactRequiredToHaveDocuments(Map<String, Object> formData, String institutionType) {
        returnDocumentRequirementInfo result = new returnDocumentRequirementInfo();
        result.status = 'success';
        result.statusCode = 200;
        result.message = 'Request processed successfully';
        result.required = false;
        result.requiredDocuments = new List<String>();
        result.documentMessage = 'No documentation required';
        result.hasAttachments = false;

        try {
            // Define FRM related specialties
            Set<String> frmRelatedSpecialties = new Set<String>{
                'Credit Risk',
                'Enterprise Risk',
                'Liquidity Risk',
                'Market Risk',
                'Model Risk/Model Validation'
            };

            // Check if institutionType is 'EPP'
            if (institutionType != null && institutionType.equalsIgnoreCase('EPP')) {
                // Check for riskSpecialty in formData
                String riskSpecialty = (formData != null && formData.containsKey('riskSpecialty') && formData.get('riskSpecialty') != null)
                    ? String.valueOf(formData.get('riskSpecialty'))
                    : null;

                if (riskSpecialty != null && frmRelatedSpecialties.contains(riskSpecialty)) {
                    result.required = false;
                    result.documentMessage = 'No documentation required for EPP institutions with FRM-related specialties.';
                    result.hasAttachments = false;
                } else {
                    result.required = true;
                    result.requiredDocuments = new List<String>{
                        'Documentation of your course offerings',
                        'Descriptions of each course'
                    };
                    result.documentMessage = 'Please provide the following:';
                    result.hasAttachments = false;
                }
                return result;
            }

            Id experienceId = formData.containsKey('experienceId') ? (Id)formData.get('experienceId') : null;
            if (experienceId != null) {
                Experience__c ex = [SELECT Id, Job_Function__c, Risk_Specialty__c, Educational_Role__c, Job_Type__c, Company__r.Name, CompanyOther__c FROM Experience__c WHERE Id = :experienceId LIMIT 1];
                GARP_BC_MyPrograms.ExperienceDocumentRequirementResult docReq = GARP_BC_MyPrograms.getExperienceDocumentRequirement(ex);
                result.required = docReq.required;
                result.hasAttachments = docReq.hasAttachments;
                result.isValidExperience = docReq.isValidExperience;
                result.validationMessage = docReq.validationMessage;
                result.documentMessage = docReq.documentMessage;
                result.requiredDocuments = docReq.requiredDocuments;
            } else {
                // fallback to formData logic if no experienceId (like for new Experiences)
                String jobFunction = (String) formData.get('jobFunction');
                String riskSpecialty = (String) formData.get('riskSpecialty');
                String educationalRole = (String) formData.get('educationalRole');
                String jobType = (String) formData.get('jobType');
                String company = (String) formData.get('company');

                // Create a temporary Experience__c object for logic reuse
                Experience__c tempEx = new Experience__c();
                tempEx.Job_Function__c = jobFunction;
                tempEx.Risk_Specialty__c = riskSpecialty;
                tempEx.Educational_Role__c = educationalRole;
                tempEx.Job_Type__c = jobType;
                if (company != null && company != '') {
                    tempEx.CompanyOther__c = company;
                }

                GARP_BC_MyPrograms.ExperienceDocumentRequirementResult docReq = GARP_BC_MyPrograms.getExperienceDocumentRequirement(tempEx);
                result.required = docReq.required;
                result.hasAttachments = false; // No attachments for new experience
                result.isValidExperience = docReq.isValidExperience;
                result.validationMessage = docReq.validationMessage;
                result.documentMessage = docReq.documentMessage;
                result.requiredDocuments = docReq.requiredDocuments;
            }
        } catch (Exception e) {
            GARP_Common.debugLog('GARP_BC_MemberPortal', 'isContactRequiredToHaveDocuments', 'Error', e.getMessage());
            result.status = 'error';
            result.statusCode = 500;
            result.message = 'Error processing request: ' + e.getMessage();
            result.documentMessage = 'An error occurred while determining document requirements. Please try again later.';
            result.hasAttachments = false;
        }

        return result;
    }
    
    public static List<Chapter_Meeting_Registration__c> fetchChapterMeetingRegister(String chapterMeetingId){ 
        List<Chapter_Meeting_Registration__c> lstChapterMeetingRegistrations;
        if(utilities.verifyChapterMeetingRights(chapterMeetingId, false, true, false)) {
            lstChapterMeetingRegistrations = [select Id, Name, Status__c, Attended__c, Contact__r.FirstName, Contact__r.LastName, 
                                              Contact__r.Corporate_Title__c, Contact__r.Company__c from Chapter_Meeting_Registration__c where Chapter_Meeting__c = :chapterMeetingId];
        }
        return lstChapterMeetingRegistrations;
    }
    
    public static List<Chapter_Meeting_Registration__c> toggelAttendance(String chapterMeetingId, String registrationId){        
        List<Chapter_Meeting_Registration__c> lstChapterMeetingRegistrations;
        
        if(utilities.verifyChapterMeetingRights(chapterMeetingId, false, true, false)) {
            lstChapterMeetingRegistrations = [select Id, Name, Status__c, Attended__c, Contact__r.Name from Chapter_Meeting_Registration__c where Id=:registrationId];
            if(lstChapterMeetingRegistrations != null && lstChapterMeetingRegistrations.size() > 0) {
                if(lstChapterMeetingRegistrations[0].Attended__c == false) {
                    lstChapterMeetingRegistrations[0].Attended__c=true;
                }else{
                    lstChapterMeetingRegistrations[0].Attended__c=false;
                }
                update lstChapterMeetingRegistrations;
            }
            lstChapterMeetingRegistrations = [select Id, Name, Status__c, Attended__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Corporate_Title__c, Contact__r.Company__c from Chapter_Meeting_Registration__c where Chapter_Meeting__c = :chapterMeetingId];
        }            
        return lstChapterMeetingRegistrations;
    }
}