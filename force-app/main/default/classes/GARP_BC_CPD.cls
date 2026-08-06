public class GARP_BC_CPD {

    // Service Wrappers
    public class cpdCycleInfo {
        public String programId;
        public String cycleName;
        public Integer startYear;
        public Integer endYear;
        public String status; // completed, expired, active
        public Boolean isAttested;
        public String attestationID; // Send to attestCPD call

        public Boolean isFRMActive;
        public Boolean isERPActive;
        public Boolean isSCRActive;
        public Boolean isRAIActive;

        public Boolean isFRMCompleted;
        public Boolean isERPCompleted;
        public Boolean isSCRCompleted;
        public Boolean isRAICompleted;

        public String completedFRMCertURL;
        public String completedERPCertURL;
        public String completedSCRCertURL;
        public String completedRAICertURL;

        public Decimal creditsSubmitted;
        public Decimal creditsApproved;
        public Decimal creditsRequired;

        public Decimal creditsRequiredFRM;
        public Decimal creditsRequiredERP;
        public Decimal creditsRequiredSCR;
        public Decimal creditsRequiredRAI;

        public List<cpdClaim> approvedClaims;
        public List<cpdClaim> pendingClaims;
    }

    public class cpdClaim {
        public String claimId;
        public String activityType;
        public String activityTypeName;
        public Date dateOfCompletion;
        public String dateOfCompletionString;
        public Decimal credits;
        public String areaOfStudy;
        public String comments;
        public String URL;
        public String provider;
        public String providerOther;
        public String title;
        public String organizationName;
        public String contactEmail;
        public String publication;
        public String approvalComments;
        public Boolean isFRM;
        public Boolean isERP;
        public Boolean isSCR;
        public Boolean isRAI;

        public cpdClaim(CPE_Claim__c claim) {
            claimId = claim.Id;
            activityType = claim.CPE_Activity_Type__c;
            activityTypeName = claim.CPE_Activity_Type__r.Name;
            dateOfCompletion = claim.Date_of_Completion__c;
            credits = claim.Credits_Earned__c;
            areaOfStudy = claim.Area_of_Study__c;
            comments = claim.Comment__c;
            URL = claim.URL__c;
            provider = claim.Provider__c;
            if(claim.Provider_Other__c == NULL) {
                providerOther = claim.Provider__r.Name;
            } else {
            	providerOther = claim.Provider_Other__c;
            }
            title = claim.EventTitle__c;
            organizationName = claim.OrganizationName__c;
            contactEmail = claim.Contact_Email__c;
            publication = claim.Publication__c;
            approvalComments = claim.ApprovalComments__c;
            isFRM = claim.FRM__c;
            isERP = claim.ERP__c;
            isSCR = claim.SCR__c;
            isRAI = claim.RAI__c;
            if(title == NULL) {
                title = claim.CPE_Activity_Type__r.Name;
            }
        }

        public cpdClaim(cpdActivity cpdActivity) {
            activityType = cpdActivity.activityTypeId;
            credits = cpdActivity.credits;
            areaOfStudy = cpdActivity.areasOfStudy;
            URL = cpdActivity.URL;
            provider = cpdActivity.providerId;
            title = cpdActivity.title;
            organizationName = cpdActivity.organization;
            publication = cpdActivity.publication;
            isFRM = FALSE;
            isERP = FALSE;
            isSCR = FALSE;
            isRAI = FALSE;
        }

    }

    public class cpdProgramInfo {
        public String currentCycle; // Current Cycle show by default
        public List<cpdCycleInfo> cycles;
    }

    // Service Methods
    public static cpdProgramInfo getCPDProgramInfo(contact contact, MAP<String,Contract> mapContracts) {
        cpdProgramInfo cpdProgramInfo = new cpdProgramInfo();

        //GARP_BC_Membership.membershipInfo membershipInfo = GARP_BC_Membership.getMembershipInfo(ContactId);
        //GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','membershipInfo',membershipInfo);

        Contract frmContract = mapContracts.get('FRM_Program');
        Contract erpContract = mapContracts.get('ERP_Program');
        Contract scrContract = mapContracts.get('SCR_Program');
        Contract raiContract = mapContracts.get('Risk_AI_Program');

        GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','raiContract',raiContract);

        cpdProgramInfo.cycles = new List<cpdCycleInfo>();

        if(contact != NULL) {
            String accountId = contact.accountId;

            String cpdRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'CPE');
            List<Contract> lstContract = [select id, Status, StartDate, EndDate, SCR_Computed_Expiration_Date__c, ContractTerm,
                                          All_Requirements_Completed__c, All_Requirements_Completed_Date__c,
                                          (SELECT Id, Name, Status__c, Date_of_Completion__c, RecordTypeId FROM Candidate_Requirements__r)
                                          FROM Contract
                                          WHERE AccountId = :accountId AND RecordTypeId = :cpdRecordTypeId AND status in ('Activated ( Auto-Renew )','Activated','Completed','Expired')
                                         ORDER BY StartDate DESC];
            GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','lstContract',lstContract);

            if(lstContract.isEmpty()) {
                return cpdProgramInfo;
            }
            cpdProgramInfo.currentCycle = lstContract[0].StartDate.Year() + '/' + lstContract[0].EndDate.Year();
            GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','currentCycle',cpdProgramInfo.currentCycle);


            List<CPE_Claim__c> lstClaims = [Select id, Name, EventTitle__c, Approved__c, Description__c, Credits_Earned__c, Publication__c,FRM__c, ERP__c, SCR__c, RAI__c,
                                            CPE_Activity_Type__c,
                                            CPE_Activity_Type__r.Name,
                                            CPE_Activity_Type__r.Organization_Label_Text__c,
                                            CPE_Activity_Type__r.Provider_Label_Text__c,
                                            CPE_Activity_Type__r.Publication_Label_Text__c,
                                            CPE_Activity_Type__r.Title_Label_Text__c,
                                            CPE_Activity_Type__r.Contact_Email_Label_Text__c,
                                            Area_of_Study__c, Comment__c,URL__c,
                                            Provider__c, Provider__r.Name,
                                            Provider_Other__c, OrganizationName__c,Contact_Email__c,
                                            Date_of_Completion__c, ApprovedCredits__c, ApprovalComments__c, Candidate_Requirement__r.Candidate_Commitment__c,
                                            Candidate_Requirement__r.Name, Candidate_Requirement__r.Candidate_Commitment__r.AccountId,
                                            Candidate_Requirement__r.Candidate_Commitment__r.StartDate, Candidate_Requirement__r.Candidate_Commitment__r.EndDate
                                            from CPE_Claim__c where Candidate_Requirement__r.Candidate_Commitment__r.AccountId=:accountId];
            GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','lstClaims',lstClaims);

            MAP<String,cpdCycleInfo> mapCPDClaims = new MAP<String,cpdCycleInfo>();
            if(!lstClaims.isEmpty()) {

                for(CPE_Claim__c claim :lstClaims) {
                    GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','Loop CPE_Claim__c',claim);

                    cpdCycleInfo fndCycleInfo = mapCPDClaims.get(claim.Candidate_Requirement__r.Candidate_Commitment__c);
                    GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','fndCycleInfo',fndCycleInfo);

                    cpdClaim cpdClaim = new cpdClaim(claim);

                    if(fndCycleInfo == NULL) {
                        fndCycleInfo = new cpdCycleInfo();
                        fndCycleInfo.approvedClaims = new List<cpdClaim>();
                        fndCycleInfo.pendingClaims = new List<cpdClaim>();
                        fndCycleInfo.creditsApproved=0;
                        fndCycleInfo.creditsSubmitted=0;

                        fndCycleInfo.isFRMActive = False;
                        fndCycleInfo.isERPActive = False;
                        fndCycleInfo.isSCRActive = False;
                        fndCycleInfo.isRAIActive = False;

                        fndCycleInfo.isFRMCompleted = False;
                        fndCycleInfo.isERPCompleted = False;
                        fndCycleInfo.isSCRCompleted = False;
                        fndCycleInfo.isRAICompleted = False;
                    }

                    if(claim.Approved__c) {
                        fndCycleInfo.creditsApproved+=claim.ApprovedCredits__c;
                        fndCycleInfo.approvedClaims.add(cpdClaim);

                        if(fndCycleInfo.creditsApproved >= 20) {
                            fndCycleInfo.isRAICompleted = TRUE;
                        }
                        if(fndCycleInfo.creditsApproved >= 20) {
                            fndCycleInfo.isSCRCompleted = TRUE;
                        }
                        if(fndCycleInfo.creditsApproved >= 40) {
                            fndCycleInfo.isFRMCompleted = TRUE;
                        }
                        if(fndCycleInfo.creditsApproved >= 40) {
                            fndCycleInfo.isERPCompleted = TRUE;
                        }

                    } else {
                        // Only add pending to the current cycle
                        String cycleName = claim.Candidate_Requirement__r.Candidate_Commitment__r.StartDate.Year() + '/' + claim.Candidate_Requirement__r.Candidate_Commitment__r.EndDate.Year();
                        GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','cycleName',cycleName);

                        if(cycleName == cpdProgramInfo.currentCycle) {
                            fndCycleInfo.pendingClaims.add(cpdClaim);
                        }

                    }
                    fndCycleInfo.creditsSubmitted+=claim.Credits_Earned__c;

                    GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','update fndCycleInfo',fndCycleInfo);
                    mapCPDClaims.put(claim.Candidate_Requirement__r.Candidate_Commitment__c, fndCycleInfo);
                }
            }


            if(!lstContract.isEmpty()) {

                for(Contract cont :lstContract) {
                    GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','Loop contract',cont);

                    String contractStatus = cont.Status.toLowerCase();
                    if(contractStatus == 'activated ( auto-renew )') {
                        contractStatus = 'active';
                    }
                    GARP_Common.debugLog('GARP_BC_CPD','getMemberProfileInfo','contractStatus',contractStatus);

                    cpdCycleInfo cpdCycleInfo = new cpdCycleInfo();
                    cpdCycleInfo.programId = cont.Id;
                    cpdCycleInfo.cycleName = String.valueOf(cont.StartDate.Year()) + '/' + String.valueOf(cont.EndDate.Year());
                    cpdCycleInfo.startYear = cont.StartDate.Year();
                    cpdCycleInfo.endYear = cont.EndDate.Year();
                    cpdCycleInfo.status = contractStatus;

                    GARP_Common.debugLog('GARP_BC_CPD','getMemberProfileInfo','basic info',cpdCycleInfo);

                    // Find Attestation
                    cpdCycleInfo.isAttested = False;
                    String attestRecTypeId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Attest');
                    if(!cont.Candidate_Requirements__r.IsEmpty()) {
                        for(Candidate_Requirement__c canReq :cont.Candidate_Requirements__r) {
                            if(canReq.RecordTypeId == attestRecTypeId) {
                                cpdCycleInfo.attestationID = canReq.Id;
                                if(canReq.Status__c == 'Completed') {
                                    cpdCycleInfo.isAttested = True;
                                }
                            }
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_CPD','getMemberProfileInfo','isAttested',cpdCycleInfo.isAttested);

                    // Calc Credits
                    cpdCycleInfo fndCycleInfo = mapCPDClaims.get(cont.Id);
                    GARP_Common.debugLog('GARP_BC_CPD','getMemberProfileInfo','fndCycleInfo',fndCycleInfo);

                    cpdCycleInfo.approvedClaims = new List<cpdClaim>();
                    cpdCycleInfo.pendingClaims = new List<cpdClaim>();

                    cpdCycleInfo.creditsRequiredFRM = 40;
                    cpdCycleInfo.creditsRequiredERP = 40;
                    cpdCycleInfo.creditsRequiredSCR = 20;
                    cpdCycleInfo.creditsRequiredRAI = 20;

                    cpdCycleInfo.isFRMActive = False;
                    cpdCycleInfo.isERPActive = False;
                    cpdCycleInfo.isSCRActive = False;
                    cpdCycleInfo.isRAIActive = False;

                    cpdCycleInfo.isFRMCompleted = False;
                    cpdCycleInfo.isERPCompleted = False;
                    cpdCycleInfo.isSCRCompleted = False;
                    cpdCycleInfo.isRAICompleted = False;

                    Boolean isFRMCertified = False;
                    Boolean isERPCertified = False;
                    Boolean isSCRHolder = False;
                    Boolean isRAIHolder = False;


                    GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','cont.StartDate',cont.StartDate);

                    if(frmContract != NULL && frmContract.Status == 'Completed' && frmContract.All_Requirements_Completed_Date__c < cont.EndDate) {
                        isFRMCertified = True;
                    }
                    if(erpContract != NULL && erpContract.Status == 'Completed' && erpContract.All_Requirements_Completed_Date__c < cont.EndDate) {
                        isERPCertified = True;
                    }
                    if(scrContract != NULL && scrContract.Status == 'Completed' && scrContract.All_Requirements_Completed_Date__c < cont.EndDate) {
                        isSCRHolder = True;
                    }
                    if(raiContract != NULL && raiContract.Status == 'Completed' && raiContract.All_Requirements_Completed_Date__c < cont.EndDate) {
                        isRAIHolder = True;
                    }


                    GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','isFRMCertified',isFRMCertified);
                    GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','isERPCertified',isERPCertified);
                    GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','isSCRHolder',isSCRHolder);
                    GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','isRAIHolder',isRAIHolder);


                    if(isFRMCertified || isERPCertified) {
                        cpdCycleInfo.creditsRequired = 40;
                    } else if(isSCRHolder)  {
                        cpdCycleInfo.creditsRequired = 20;
                    } else if(isRAIHolder) {
                        cpdCycleInfo.creditsRequired = 20;
                    }

                    if(isFRMCertified) {
                        cpdCycleInfo.isFRMActive = True;
                    }
                    if(isERPCertified) {
                        cpdCycleInfo.isERPActive = True;
                    }
                    if(isSCRHolder) {
                        cpdCycleInfo.isSCRActive = True;
                    }
                    if(isRAIHolder) {
                        cpdCycleInfo.isRAIActive = True;
                    }


                    if(fndCycleInfo != NULL) {
                        cpdCycleInfo.creditsApproved = fndCycleInfo.creditsApproved;
                        cpdCycleInfo.creditsSubmitted = fndCycleInfo.creditsSubmitted;
                        cpdCycleInfo.approvedClaims.addAll(fndCycleInfo.approvedClaims);
                        cpdCycleInfo.pendingClaims.addAll(fndCycleInfo.pendingClaims);

                        if(cpdCycleInfo.isFRMActive) {
                            cpdCycleInfo.isFRMCompleted = fndCycleInfo.isFRMCompleted;
                        }

                        if(cpdCycleInfo.isERPActive) {
                            cpdCycleInfo.isERPCompleted = fndCycleInfo.isERPCompleted;
                        }

                        if(cpdCycleInfo.isSCRActive) {
                            cpdCycleInfo.isSCRCompleted = fndCycleInfo.isSCRCompleted;
                        }

                        if(cpdCycleInfo.isRAIActive) {
                            cpdCycleInfo.isRAICompleted = fndCycleInfo.isRAICompleted;
                        }

                        if(cpdCycleInfo.isFRMCompleted && !cpdCycleInfo.isERPCompleted) {
                            cpdCycleInfo.completedFRMCertURL = '/apex/CPDCertificate_FRM?id=' + cpdCycleInfo.programId;
                        } else if(cpdCycleInfo.isFRMCompleted && cpdCycleInfo.isERPCompleted) {
                            cpdCycleInfo.completedFRMCertURL = '/apex/CPDCertificate_FRM_ERP?id=' + cpdCycleInfo.programId;
                            cpdCycleInfo.completedERPCertURL = '/apex/CPDCertificate_FRM_ERP?id=' + cpdCycleInfo.programId;
                        } else if(cpdCycleInfo.isERPCompleted) {
                            cpdCycleInfo.completedERPCertURL = '/apex/CPDCertificate_ERP?id=' + cpdCycleInfo.programId;
                        }

                        if(cpdCycleInfo.isSCRCompleted) {
                            cpdCycleInfo.completedSCRCertURL = '/apex/CPDCertificate_SCR?id=' + cpdCycleInfo.programId;
                        }
                        if(cpdCycleInfo.isRAICompleted) {
                            cpdCycleInfo.completedRAICertURL = '/apex/CPDCertificate_RAI?id=' + cpdCycleInfo.programId;
                        }

                    } else {
                        cpdCycleInfo.creditsApproved = 0;
                        cpdCycleInfo.creditsSubmitted = 0;
                        cpdCycleInfo.isFRMCompleted = False;
                        cpdCycleInfo.isERPCompleted = False;
                        cpdCycleInfo.isSCRCompleted = False;
                        cpdCycleInfo.isRAICompleted = False;
                    }


                    GARP_Common.debugLog('GARP_BC_CPD','getCPDProgramInfo','final cycle info',cpdCycleInfo);
                    cpdProgramInfo.cycles.add(cpdCycleInfo);
                }
            }
        }

        return cpdProgramInfo;
    }

    public static GARP_Common.returnInfo setCPDAttestation(String attestationId) {
        GARP_Common.debugLog('GARP_BC_CPD','setCPDAttestation','attestationID',attestationId);

        GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();

        if(attestationID == NULL) {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'Missing required parameters';
            return returnInfo;
        }

        List<Candidate_Requirement__c> lstCanReqs = [select Id, Status__c from Candidate_Requirement__c where id = :attestationId];
        GARP_Common.debugLog('GARP_BC_CPD','setCPDAttestation','lstCanReqs',lstCanReqs);

        if(lstCanReqs.IsEmpty()) {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'Candidate Requirement not found';
        }

        Candidate_Requirement__c canReq = lstCanReqs[0];
        canReq.Status__c = 'Completed';
        update canReq;

        returnInfo.status = 'Success';

        GARP_Common.debugLog('GARP_BC_CPD','setCPDAttestation','returnInfo',returnInfo);
        return returnInfo;
    }

    public static GARP_Common.returnInfo setCPDClaim(String accountId, String contactId, cpdClaim cpdClaim) {
        GARP_Common.debugLog('GARP_BC_CPD','setCPDClaim','cpdClaim',cpdClaim);

        GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();

        if(accountId == NULL || cpdClaim == NULL || cpdClaim.credits == NULL || cpdClaim.dateOfCompletionString == NULL) {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'Missing required parameters';
            return returnInfo;
        }

        String cpdRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'CPE');
        List<Contract> lstContract = [select id, Status, StartDate, EndDate, SCR_Computed_Expiration_Date__c, ContractTerm,
                                      All_Requirements_Completed__c, All_Requirements_Completed_Date__c,
                                      (SELECT Id, Name, Status__c, Date_of_Completion__c, RecordTypeId FROM Candidate_Requirements__r)
                                      FROM Contract
                                      WHERE AccountId = :accountId AND RecordTypeId = :cpdRecordTypeId AND status like 'Activat%'
                                      ORDER BY StartDate DESC];
        GARP_Common.debugLog('GARP_BC_CPD','setCPDClaim','lstContract',lstContract);

        if(!lstContract.IsEmpty()) {
            Contract cpdContract = lstContract[0];
            String canReqId;
            String cpdCanReqRecordTypeId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c', 'CPE');
            if(!cpdContract.Candidate_Requirements__r.IsEmpty()) {
                for(Candidate_Requirement__c canReq :cpdContract.Candidate_Requirements__r) {
                    if(canReq.RecordTypeId == cpdCanReqRecordTypeId) {
                        canReqId = canReq.Id;
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_CPD','setCPDClaim','canReqId',canReqId);

            if(canReqId != NULL) {

                CPE_Claim__c claim = new CPE_Claim__c();
                if(cpdClaim.claimId != NULL) {
                    List<CPE_Claim__c> lstClaims = [select Id, Member__c, Credits_Earned__c, Candidate_Requirement__c, CPE_Activity_Type__c, CPE_Activity_Type__r.Name, Date_of_Completion__c,
                                                    Area_of_Study__c, Comment__c, URL__c, Provider__c, Provider_Other__c, EventTitle__c, OrganizationName__c,
                                                    Contact_Email__c, Publication__c, ApprovalComments__c, FRM__c, ERP__c, SCR__c, RAI__c
                                                    From CPE_Claim__c where id = :cpdClaim.claimId];
                    GARP_Common.debugLog('GARP_BC_CPD','setCPDClaim','lstClaims',lstClaims);

                    if(!lstClaims.IsEmpty()) {
                        claim = lstClaims[0];
                    } else {
                        returnInfo.status = 'Failed';
                        returnInfo.msg = 'Claim not found';
                        return returnInfo;
                    }

                }

                claim.Member__c = contactId;
                claim.Credits_Earned__c=cpdClaim.credits;
                claim.Candidate_Requirement__c = canReqId;
                claim.CPE_Activity_Type__c = cpdClaim.activityType;
                claim.Date_of_Completion__c = Date.Parse(cpdClaim.dateOfCompletionString);
                claim.Area_of_Study__c = cpdClaim.areaOfStudy;
                claim.Comment__c = cpdClaim.comments;
                claim.URL__c = cpdClaim.URL;
                //claim.Provider__c = cpdClaim.provider;
                claim.Provider_Other__c = cpdClaim.provider;
                claim.EventTitle__c = cpdClaim.title;
                claim.OrganizationName__c = cpdClaim.organizationName;
                claim.Contact_Email__c = cpdClaim.contactEmail;
                claim.Publication__c = cpdClaim.publication;
                claim.ApprovalComments__c = cpdClaim.approvalComments;
                //claim.FRM__c = cpdClaim.isFRM;
                //claim.ERP__c = cpdClaim.isERP;
                //claim.SCR__c = cpdClaim.isSCR;
                //claim.RAI__c = cpdClaim.isRAI;
                GARP_Common.debugLog('GARP_BC_CPD','setCPDClaim','upsert claim',claim);

                upsert claim;
                returnInfo.status = 'Success';
            } else {
                returnInfo.status = 'Failed';
                returnInfo.msg = 'Candidate Requirement not found';
            }
        } else {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'Contract not found';
        }

        GARP_Common.debugLog('GARP_BC_CPD','setCPDClaim','returnInfo',returnInfo);
        return returnInfo;
    }

    public static GARP_Common.returnInfo deleteCPDClaim(String claimId) {
        GARP_Common.debugLog('GARP_BC_CPD','deleteCPDClaim','claimID',claimId);

        GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();

        if(claimID == NULL) {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'Missing required parameters';
            return returnInfo;
        }

        List<CPE_Claim__c> lstClaims = [select id from CPE_Claim__c where id = :claimId];
        GARP_Common.debugLog('GARP_BC_CPD','setCPDAttestation','lstClaims',lstClaims);

        if(lstClaims.IsEmpty()) {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'CPD Claim not found';
            return returnInfo;
        }

        CPE_Claim__c claim = lstClaims[0];
        delete claim;

        returnInfo.status = 'Success';

        GARP_Common.debugLog('GARP_BC_CPD','deleteCPDClaim','returnInfo',returnInfo);
        return returnInfo;
    }

    // CPD Activities

    public class cpdActivityFieldInfo {
        public String name;
        public String organizationLabel;
        public String providerLabel;
        public String publicationLabel;
        public String titleLabel;
        public String contactEmailLabel;
    }

    public static MAP<String,cpdActivityFieldInfo> getCPDActivityFieldInfo() {

        MAP<String,cpdActivityFieldInfo> mapCPDActivities = new MAP<String,cpdActivityFieldInfo>();

        List<CPE_Activity_Type__c> lstCPDActivities = [select id, Name, Organization_Label_Text__c, Provider_Label_Text__c, Publication_Label_Text__c,
                                                       Title_Label_Text__c, Contact_Email_Label_Text__c
                                                       from CPE_Activity_Type__c
                                                       where Active__c = True];
        for(CPE_Activity_Type__c cat :lstCPDActivities) {
            cpdActivityFieldInfo cpdActivityFieldInfo = new cpdActivityFieldInfo();
            cpdActivityFieldInfo.name = cat.Name;
            cpdActivityFieldInfo.organizationLabel = cat.Organization_Label_Text__c;
            cpdActivityFieldInfo.providerLabel = cat.Provider_Label_Text__c;
            cpdActivityFieldInfo.publicationLabel = cat.Publication_Label_Text__c;
            cpdActivityFieldInfo.titleLabel = cat.Title_Label_Text__c;
            cpdActivityFieldInfo.contactEmailLabel = cat.Contact_Email_Label_Text__c;
            mapCPDActivities.put(cat.Id, cpdActivityFieldInfo);
        }

        return mapCPDActivities;
    }

    public class cpdActivityInfo {
        public List<String> sortOptions;
        public List<String> activityTypes;
        public List<String> areasOfStudy;
        public List<String> providers;
        public List<cpdActivity> cpdActivities;
        public Integer totalCount;
    }

    public class cpdActivity {
        public String id;
        public String title;
        public String description;
        public String location;
        public Date sortDate;
        public String activityDate;
        public String activityType;
        public String activityTypeId;
        public String areasOfStudy;
        public Decimal credits;
        public String organization;
        public String provider;
        public String providerId;
        public String publication;
        public String url;
    }

    public class cpdActivitiesFilters {
        public String activityTypes;  // delimited by ;
        public String areasOfStudy;
        public String providers;
        public String sortOrder;
        public Integer pageSize;
        public Integer pageCurrent;
    }

    public static cpdActivityInfo getCPDActivitiesInfo(cpdActivitiesFilters cpdActivitiesFilters, String activityId) {
        GARP_Common.debugLog('GARP_BC_CPD','setCPDClaim','cpdActivitiesFilters',cpdActivitiesFilters);
        GARP_Common.debugLog('GARP_BC_CPD','setCPDClaim','activityId',activityId);

        cpdActivityInfo cpdActivityInfo = new cpdActivityInfo();

        cpdActivityInfo.sortOptions = new List<String>{'Credits Low to High','Credits High to Low','Date most recent to oldest','Date oldest to most recent'};

        String activityTypeClause='';
        String areasOfStudyClause='';
        String providersClause='';
        if(cpdActivitiesFilters != NULL) {
            if(!String.isBlank(cpdActivitiesFilters.activityTypes)) {
                List<String> activityTypes = cpdActivitiesFilters.activityTypes.split(';');
                for(String s :activityTypes) {
                    if(activityTypeClause == '') {
                        activityTypeClause = '\'' + s + '\'';
                    } else {
                        activityTypeClause = activityTypeClause + ',' + '\'' + s + '\'';
                    }
                }
            }

            if(!String.isBlank(cpdActivitiesFilters.areasOfStudy)) {
                List<String> areasOfStudy = cpdActivitiesFilters.areasOfStudy.split(';');
                for(String s :areasOfStudy) {
                    if(areasOfStudyClause == '') {
                        areasOfStudyClause = '\'' + s + '\'';
                    } else {
                        areasOfStudyClause = areasOfStudyClause + ',' + '\'' + s + '\'';
                    }
                }
            }

            if(!String.isBlank(cpdActivitiesFilters.providers)) {
                List<String> providers = cpdActivitiesFilters.providers.split(';');
                for(String s :providers) {
                    if(providersClause == '') {
                        providersClause = '\'' + s + '\'';
                    } else {
                        providersClause = providersClause + ',' + '\'' + s + '\'';
                    }
                }
            }
        }

        String querySelect = 'SELECT Id, Name, Title__c, Description__c, Status__c, Location__c, Sort_Date__c, Start_Date__c, End_Date__c, CPE_Activity_Type__r.Name, Area_of_Study__c, Credit__c, Activity_Date__c, Date_Description__c, Organization__c, Provider__c, Account__c, Publication__c, URL__c';
        String queryFrom = 'FROM CPE_Activity__c';
        String queryWhere = 'WHERE Status__c = \'Active\'';
        String queryOrderBy = 'ORDER BY Sort_Date__c DESC';

        String querystr;

        if(activityId != NULL) {
            queryWhere += ' AND Id = \'' + activityId + '\'';

            querystr = querySelect + ' ' + queryFrom + ' ' + queryWhere;

        } else {

            if(activityTypeClause != '') {
                queryWhere += ' AND CPE_Activity_Type__r.Name in (' + activityTypeClause + ')';
            }
            if(areasOfStudyClause != '') {
                queryWhere += ' AND Area_of_Study__c in (' + areasOfStudyClause + ')';
            }
            if(providersClause != '') {
                queryWhere += ' AND Provider__c in (' + providersClause + ')';
            }

            //'Credits Low to High','Credits High to Low','Date: Ascending','Date: Descending'

            if(cpdActivitiesFilters.sortOrder != NULL) {
                if(cpdActivitiesFilters.sortOrder == 'Credits Low to High') {
                    queryOrderBy = 'ORDER BY Credit__c ASC';
                } else if(cpdActivitiesFilters.sortOrder == 'Credits High to Low') {
                    queryOrderBy = 'ORDER BY Credit__c DESC';
                } else if(cpdActivitiesFilters.sortOrder == 'Date most recent to oldest') {
                    queryOrderBy = 'ORDER BY Sort_Date__c DESC';
                } else if(cpdActivitiesFilters.sortOrder == 'Date oldest to most recent') {
                    queryOrderBy = 'ORDER BY Sort_Date__c ASC';
                }
            }

            String queryPage = 'LIMIT ' + cpdActivitiesFilters.pageSize + ' offset ' + (cpdActivitiesFilters.pageCurrent-1)*cpdActivitiesFilters.pageSize;

            querystr = querySelect + ' ' + queryFrom + ' ' + queryWhere + ' ' + queryOrderBy + ' ' + queryPage;
        }

        GARP_Common.debugLog('GARP_BC_CPD','setCPDClaim','querystr',querystr);

        List<CPE_Activity__c> lstCPDActivities = database.query(querystr);

        String cntQuery = 'SELECT Count() FROM CPE_Activity__c ' + queryWhere;

        cpdActivityInfo.totalCount = database.countQuery(cntQuery);

        cpdActivityInfo.activityTypes = new List<String>();
        cpdActivityInfo.areasOfStudy = new List<String>();
        cpdActivityInfo.providers = new List<String>();

        SET<String> activityTypes = new SET<String>();
        SET<String> areasOfStudy = new SET<String>();
        SET<String> providers = new SET<String>();

        cpdActivityInfo.cpdActivities = new List<cpdActivity>();

        Integer cnt=0;
        for(CPE_Activity__c ca :lstCPDActivities) {
            activityTypes.add(ca.CPE_Activity_Type__r.Name);
            areasOfStudy.add(ca.Area_of_Study__c);
            providers.add(ca.Provider__c);

            cpdActivity cpdActivity = new cpdActivity();
            cpdActivity.id = ca.id;
            cpdActivity.title = ca.Title__c;
            cpdActivity.description = ca.Description__c;
            cpdActivity.location = ca.Location__c;
            cpdActivity.sortDate = ca.Sort_Date__c;
            cpdActivity.activityDate = ca.Date_Description__c;
            cpdActivity.activityTypeId = ca.CPE_Activity_Type__c;
            cpdActivity.activityType = ca.CPE_Activity_Type__r.Name;
            cpdActivity.areasOfStudy = ca.Area_of_Study__c;
            cpdActivity.credits = ca.Credit__c;
            cpdActivity.organization = ca.Organization__c;
            cpdActivity.provider = ca.Provider__c;
            cpdActivity.publication = ca.Publication__c;
            cpdActivity.url = ca.URL__c;

            cpdActivityInfo.cpdActivities.add(cpdActivity);
            cnt++;
        }
        cpdActivityInfo.activityTypes.AddAll(activityTypes);
        cpdActivityInfo.areasOfStudy.AddAll(areasOfStudy);
        cpdActivityInfo.providers.AddAll(providers);


        return cpdActivityInfo;
    }

    public class returnGetFeaturedCPDActivities {
        public List<cpdActivity> cpdActivities;
    }

    public static List<cpdActivity> getFeaturedCPDActivitiesInfo() {
        List<cpdActivity> cpdActivities = new List<cpdActivity>();


        List<CPE_Activity__c> lstCPDActs = [SELECT Id, Name, Title__c, Description__c, Status__c, Location__c, Sort_Date__c, Start_Date__c, End_Date__c, CPE_Activity_Type__r.Name,
                                            Area_of_Study__c, Credit__c, Activity_Date__c, Date_Description__c, Organization__c, Provider__c, Account__c, Publication__c, URL__c
                                            FROM CPE_Activity__c
                                            WHERE Status__c = 'Active'
                                            ORDER BY Sort_Date__c DESC Limit 5];

        if(!lstCPDActs.IsEmpty()) {
            for(CPE_Activity__c ca :lstCPDActs) {
                cpdActivity cpdActivity = new cpdActivity();
                cpdActivity.id = ca.id;
                cpdActivity.title = ca.Title__c;
                cpdActivity.description = ca.Description__c;
                cpdActivity.location = ca.Location__c;
                cpdActivity.sortDate = ca.Sort_Date__c;
                cpdActivity.activityDate = ca.Date_Description__c;
                cpdActivity.activityType = ca.CPE_Activity_Type__r.Name;
                cpdActivity.areasOfStudy = ca.Area_of_Study__c;
                cpdActivity.credits = ca.Credit__c;
                cpdActivity.organization = ca.Organization__c;
                cpdActivity.provider = ca.Provider__c;
                cpdActivity.publication = ca.Publication__c;
                cpdActivity.url = ca.URL__c;

                cpdActivities.add(cpdActivity);
            }
        }
        return cpdActivities;
    }
}