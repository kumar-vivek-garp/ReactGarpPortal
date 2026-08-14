public class garpAppRemoter {

    public garpAppRemoter() {
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.navBarInfo getNavBarInfo() {
        // system.assert(false, 'BOOM!');
        return GARP_MS_MemberPortal.getNavBarInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetStudyMaterialListing getStudyMaterialListing() {
        return GARP_MS_MemberPortal.getStudyMaterialListing();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetMyEBooksInfo getMyEBooksInfo() {
        return GARP_MS_MemberPortal.getMyEBooksInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEBookAccessURLs getEBookAccessURLs(List<GARP_BC_StudyMaterials.eBookItem> eBookItems) {
        return GARP_MS_MemberPortal.getEBookAccessURLs(eBookItems);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEBookAccessURL getEBookAccessURL(String vendorId) {
        return GARP_MS_MemberPortal.getEBookAccessURL(vendorId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetErrataFormInfo getErrataFormInfo(String programType) {
        return GARP_MS_MemberPortal.getErrataFormInfo(programType);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSubmitErrataFormInfo submitErrataForm(GARP_BC_StudyMaterials.errataFormSubmissionInfo errataFormSubmissionInfo) {
        return GARP_MS_MemberPortal.submitErrataForm(errataFormSubmissionInfo);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnAttachFileErrataSubmission attachFileErrataSubmission(String errataId, String fileName, String filetext, String fileId) {
        return GARP_MS_MemberPortal.attachFileErrataSubmission(errataId, fileName, filetext, fileId);
    }

    @RemoteAction
    public static String getAccountRecordId() {
        // Replace with your actual implementation
        // For example, you might fetch the account record Id for the current user
        return 'Account record Id for current user';
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnDashboardInfo getDashboardInfo(String loadKey) {
        return GARP_MS_MemberPortal.getDashboardInfo(loadKey);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnAdInfo getComponentAdInfo() {
        return GARP_MS_MemberPortal.getComponentAdInfo();
    }

    // Member Profile

    @RemoteAction
    public static GARP_BC_MemberPortal.returnComponentUpdateProfileInfo getComponentUpdateProfileInfo() {
        return GARP_MS_MemberPortal.getComponentUpdateProfileInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProfileDemographicsFormInfo getProfileDemographicsFormInfo() {
        return GARP_MS_MemberPortal.getProfileDemographicsFormInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetProfileDemographicsFormInfo setProfileDemographicsFormInfo(GARP_BC_MemberProfile.demographicsContactInfo updateProfileDemographicsContactInfo) {
        return GARP_MS_MemberPortal.setProfileDemographicsFormInfo(updateProfileDemographicsContactInfo);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetProfilePersonalFormInfo getProfilePersonalFormInfo() {
        return GARP_MS_MemberPortal.getProfilePersonalFormInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetProfilePersonalInfo setProfilePersonalInfo(GARP_BC_MemberProfile.personalInfo personalInfo) {
        return GARP_MS_MemberPortal.setProfilePersonalInfo(personalInfo);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnRemoveMemberPhoto removeMemberPhoto() {
        return GARP_MS_MemberPortal.removeMemberPhoto();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnUploadMemberPhoto uploadMemberPhoto(String attachmentId, String fileText, String fileName) {
        return GARP_MS_MemberPortal.uploadMemberPhoto(attachmentId, fileText, fileName);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetMemberPhoto setMemberPhoto(String attachmentId) {
        return GARP_MS_MemberPortal.setMemberPhoto(attachmentId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetEmailPreferenceUpdate setEmailPreferenceUpdate() {
        return GARP_MS_MemberPortal.setEmailPreferenceUpdate();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetSMSPreferenceUpdate setSMSPreferenceUpdate(Boolean smsPromotional, Boolean smsRegistration) {
        return GARP_MS_MemberPortal.setSMSPreferenceUpdate(smsPromotional, smsRegistration);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetProfileMembershipInfo getProfileMembershipInfo() {
        return GARP_MS_MemberPortal.getProfileMembershipInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnMuteProfileComponent muteProfileComponent(Boolean mute) {
        return GARP_MS_MemberPortal.muteProfileComponent(mute);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetMembershipAutorenew setAutorenewMembershipOff() {
        return GARP_MS_MemberPortal.setAutorenewMembershipOff();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEnableAutoRenew enableAutoRenew() {
        return GARP_MS_MemberPortal.enableAutoRenew();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetProfileChaptersInfo getProfileChaptersInfo() {
        return GARP_MS_MemberPortal.getProfileChaptersInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetProfileChaptersInfo setProfileChaptersInfo(String chapterPrimary, String chapterSecondary) {
        return GARP_MS_MemberPortal.setProfileChaptersInfo(chapterPrimary, chapterSecondary);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetProfileExpertiseInfo getProfileExpertiseInfo() {
        return GARP_MS_MemberPortal.getProfileExpertiseInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetProfileExpertiseInfo setProfileExpertiseInfo(GARP_BC_MemberProfile.expertiseInfo expertiseInfo) {
        return GARP_MS_MemberPortal.setProfileExpertiseInfo(expertiseInfo);
    }

    // Notifications

    @RemoteAction
    public static GARP_BC_MemberPortal.returnComponentNewNotificationsInfo getComponentNewNotificationsInfo() {
        return GARP_MS_MemberPortal.getComponentNewNotificationsInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetAllNotificationsInfo getAllNotifications() {
        return GARP_MS_MemberPortal.getAllNotifications();
    }

    // CPD Methods

    @RemoteAction
    public static GARP_BC_MemberPortal.returnComponentCPDInfo getComponentCPDInfo(String loadKey) {
        return GARP_MS_MemberPortal.getComponentCPDInfo(loadKey);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCPDListingInfo getCPDListingInfo() {
        return GARP_MS_MemberPortal.getCPDListingInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetCPDClaimFormInfo getCPDClaimFormInfo() {
        return GARP_MS_MemberPortal.getCPDClaimFormInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetCPDClaimInfo setCPDClaimInfo(GARP_BC_CPD.cpdClaim cpdClaim) {
        return GARP_MS_MemberPortal.setCPDClaimInfo(cpdClaim);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnDeleteCPDClaimInfo deleteCPDClaim(String claimId) {
        return GARP_MS_MemberPortal.deleteCPDClaim(claimId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetCPDAttestationInfo setCPDAttestation(String attestationId) {
        return GARP_MS_MemberPortal.setCPDAttestation(attestationId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCPDActivitiesBrowseFormInfo getCPDActivitiesBrowseFormInfo(GARP_BC_CPD.cpdActivitiesFilters cpdActivitiesFilters, String activityId) {
        return GARP_MS_MemberPortal.getCPDActivitiesBrowseFormInfo(cpdActivitiesFilters, activityId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetCPDClaimInfo setCPDActivityAsClaim(GARP_BC_CPD.cpdActivity cpdActivity) {
        return GARP_MS_MemberPortal.setCPDActivityAsClaim(cpdActivity);
    }

    // FRM CV Methods

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCVPageInfo getCVPageInfo(String programType) {
        return GARP_MS_MemberPortal.getCVPageInfo(programType);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetWorkExperienceInfo getWorkExperienceInfo(String programType, String experienceId) {
        return GARP_MS_MemberPortal.getWorkExperienceInfo(programType, experienceId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetWorkExperienceInfo setWorkExperienceInfo(String programType, String experienceId, GARP_BC_MyPrograms.workExperience workExperience) {
        return GARP_MS_MemberPortal.setWorkExperienceInfo(programType, experienceId, workExperience);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnDeleteWorkExperienceInfo deleteWorkExperienceInfo(String programType, String experienceId) {
        return GARP_MS_MemberPortal.deleteWorkExperienceInfo(programType, experienceId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetCVAddressInfo setCVAddressInfo(String programType, GARP_Common.Address mailingAddress, GARP_Common.Address OSTAaddress, String OSTArecipient) {
        return GARP_MS_MemberPortal.setCVAddressInfo(programType, mailingAddress, OSTAaddress, OSTArecipient);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSubmitCVInfo submitCVInfo(String programType) {
        return GARP_MS_MemberPortal.submitCVInfo(programType);
    }

    // My Programs

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEnrolledProgramsInfo getComponentEnrolledProgramsInfo() {
        return GARP_MS_MemberPortal.getComponentEnrolledProgramsInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnUpcomingEventsInfo getComponentUpcomingEventsInfo() {
        return GARP_MS_MemberPortal.getComponentUpcomingEventsInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnAlertBarInfo getAlertBarInfo(String loadKey) {
        return GARP_MS_MemberPortal.getAlertBarInfo(loadKey);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsListingInfo getProgramsListingInfo(String loadKey) {
        system.debug('getProgramsListingInfo Check ');
        return GARP_MS_MemberPortal.getProgramsListingInfo(loadKey);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetDirectorySearchFormInfo getDirectorySearchFormInfo() {
        return GARP_MS_MemberPortal.getDirectorySearchFormInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSearchDirectoryInfo searchMemberDirectory(GARP_BC_Membership.searchParams searchParams) {
        return GARP_MS_MemberPortal.searchMemberDirectory(searchParams);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetMemberDirectorySettingsFormInfo getMemberDirectorySettingsFormInfo() {
        return GARP_MS_MemberPortal.getMemberDirectorySettingsFormInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetMemberDirectorySettingsFormInfo setMemberDirectorySettingsFormInfo(GARP_BC_MemberProfile.memberDirectorySettings directorySettings) {
        return GARP_MS_MemberPortal.setMemberDirectorySettingsFormInfo(directorySettings);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSendMemberDirectoryMessageInfo sendMemberDirectoryMessage(GARP_BC_Membership.sendMemberMessageInfo sendMemberMessageInfo) {
        return GARP_MS_MemberPortal.sendMemberDirectoryMessage(sendMemberMessageInfo);
    }


    // My Programs

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsDetailInfo getFRMProgramDetailInfo(String loadKey) {
        return GARP_MS_MemberPortal.getFRMProgramDetailInfo(loadKey);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsDetailInfo getERPProgramDetailInfo(String loadKey) {
        return GARP_MS_MemberPortal.getERPProgramDetailInfo(loadKey);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsDetailInfo getSCRProgramDetailInfo(String loadKey) {
        return GARP_MS_MemberPortal.getSCRProgramDetailInfo(loadKey);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsDetailInfo getRAIProgramDetailInfo(String loadKey) {
        return GARP_MS_MemberPortal.getRAIProgramDetailInfo(loadKey);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsDetailInfo getRAIJProgramDetailInfo(String loadKey) {
        System.debug('getRAIJProgramDetailInfo:' + loadKey);
        return GARP_MS_MemberPortal.getRAIJProgramDetailInfo(loadKey);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCourseInfo getFRRProgramDetailInfo() {
        return GARP_MS_MemberPortal.getFRRProgramDetailInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCourseInfo getFRR25ProgramDetailInfo() {
        return GARP_MS_MemberPortal.getFRR25ProgramDetailInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCourseInfo getMicroCourseProgramDetailInfo(String courseType) {
        return GARP_MS_MemberPortal.getMicroCourseProgramDetailInfo(courseType);
    }



    @RemoteAction
    public static GARP_BC_MemberPortal.returnCourseInfo getFFRProgramDetailInfo() {
        return GARP_MS_MemberPortal.getFFRProgramDetailInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnExamResultsListingInfo getExamResultsListing(String loadKey) {
        return GARP_MS_MemberPortal.getExamResultsListing(loadKey);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetExamResultLastViewDate setExamResultLastViewDate(String examAttemptId) {
        return GARP_MS_MemberPortal.setExamResultLastViewDate(examAttemptId);
    }

    @RemoteAction
    public static GARP_BC_MyPrograms.returnGetExamSetupFormInfo getExamSetupFormInfo(String examType) {
        return GARP_MS_MemberPortal.getExamSetupFormInfo(examType);
    }

    @RemoteAction
    public static GARP_BC_MyPrograms.returnGetExamSetupExamSelectionInfo getExamSetupExamSelectionInfo(String examType, GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        return GARP_MS_MemberPortal.getExamSetupExamSelectionInfo(examType, examSetupExamSelectionsInfo);
    }

    @RemoteAction
    public static GARP_BC_MyPrograms.returnGetExamSetupIDInfo getExamSetupIDInfo(String examType, GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        return GARP_MS_MemberPortal.getExamSetupIDInfo(examType, examSetupExamSelectionsInfo);
    }

    @RemoteAction
    public static GARP_BC_MyPrograms.returnSetExamSetupIDInfo setExamSetupIDInfo(String examType, GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo, GARP_BC_MyPrograms.setIdCandidateInfo idCandidateInfo) {
        return GARP_MS_MemberPortal.setExamSetupIDInfo(examType, examSetupExamSelectionsInfo, idCandidateInfo);
    }

    @RemoteAction
    public static GARP_BC_MyPrograms.returnExamSetupAuthorizeRegistrations examSetupAuthorizeRegistrations(String examType, Boolean isRetry) {
        return GARP_MS_MemberPortal.examSetupAuthorizeRegistrations(examType, isRetry);
    }


    @RemoteAction
    public static GARP_BC_MemberPortal.returnEPPOptInInfo EPPOptIn(String examType, Boolean optIn) {
        return GARP_MS_MemberPortal.EPPOptIn(examType, optIn);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEventsListingInfo getEventsListingInfo() {
        return GARP_MS_MemberPortal.getEventsListingInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnBenchPrepLinks getBenchPrepLinks() {
        return GARP_MS_MemberPortal.getBenchPrepLinks();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnPurchaseHistoryInfo getPurchaseHistoryInfo() {
        return GARP_MS_MemberPortal.getPurchaseHistoryInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetOrderInfo getOrderInfo(String orderNumber) {
        return GARP_MS_MemberPortal.getOrderInfo(orderNumber);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCancelUnpaidOrder cancelUnpaidOrder(String orderId) {
        return GARP_MS_MemberPortal.cancelUnpaidOrder(orderId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnPayPendingOrder payPendingOrder(String orderId) {
        return GARP_MS_MemberPortal.payPendingOrder(orderId);
    }
    
    // Membership Benefits

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetMembershipPageInfo getMembershipPageInfo() {
        return GARP_MS_MemberPortal.getMembershipPageInfo();
    }

    // Help Center

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSubmitCustomerCase submitCustomerCase(String title, String description) {
        return GARP_MS_MemberPortal.submitCustomerCase(title, description);
    }

    // OSTA ID Info

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetOSTAIDInfo getOSTAIDInfo() {
        return GARP_MS_MemberPortal.getOSTAIDInfo();
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetOSTAIDInfo setOSTAIDInfo(GARP_BC_MyPrograms.OSTAIDInfo OSTAIDInfo) {
        return GARP_MS_MemberPortal.setOSTAIDInfo(OSTAIDInfo);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo uploadWorkExperienceAttachment(Id workExperienceId, String fileName, String base64Data) {
        return GARP_MS_MemberPortal.uploadWorkExperienceAttachment(workExperienceId, fileName, base64Data);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo deleteWorkExperienceAttachment(Id attachmentId) {
        return GARP_MS_MemberPortal.deleteWorkExperienceAttachment(attachmentId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo getWorkExperienceAttachments(Id workExperienceId) {
        return GARP_MS_MemberPortal.getWorkExperienceAttachments(workExperienceId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo downloadWorkExperienceAttachment(Id attachmentId) {
        return GARP_MS_MemberPortal.downloadWorkExperienceAttachment(attachmentId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnDocumentRequirementInfo isContactRequiredToHaveDocuments(Map<String, Object> formData, String institutionType) {
        return GARP_MS_MemberPortal.isContactRequiredToHaveDocuments(formData, institutionType);
    }

    // Registration Methods
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getFRMRegistrationInfo(String regCode) {
        return GARP_MS_Exams.getFRMRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getSCRRegistrationInfo(String regCode) {
        return GARP_MS_Courses.getSCRRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getRiskAIRegistrationInfo(String regCode) {
        return GARP_MS_Courses.getRiskAIRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getRAIJRegistrationInfo(String regCode) {
        return GARP_MS_Courses.getRAIJRegistrationInfo(regCode);
    }

    // US-63665: FFR B2B Registration
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getFFRRegistrationInfo(String regCode) {
        return GARP_MS_Courses.getFFRRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getFRRRegistrationInfo(String regCode) {
        return GARP_MS_Courses.getFRRRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getMembershipRegistrationInfo(String regCode) {
        return GARP_MS_Membership.getMembershipRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getAffiliateMembershipRegistrationInfo() {
        return GARP_MS_Membership.getAffiliateMembershipRegistrationInfo();
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getWebcastRegistrationInfo(String regCode) {
        return GARP_MS_Events.getWebcastRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getChapterMeetingRegistrationInfo(String regCode) {
        return GARP_MS_Events.getChapterMeetingRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getEventRegistrationInfo(String regCode) {
        return GARP_MS_Events.getEventRegistrationInfo(regCode, regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.registrationFees getRegistrationFees(GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfoReq) {
        return GARP_MS_Registration.getRegistrationFees(getRegistrationFeesInfoReq);
    }
    
    @RemoteAction
    public static GARP_BC_Shipping.retVerifyAddress verifyAddress(GARP_BC_Shipping.verifyAddressInfo verifyAddressInfo) {
        return GARP_BC_Shipping.verifyAddress(verifyAddressInfo);
    }

    @RemoteAction
    public static GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomer(GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo) {
        return GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
    }
    
    @RemoteAction
    public static GARP_BC_Registration.setRegistrationReturnInfo setRegistration(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo) {
        return GARP_BC_Registration.setRegistration(setRegistrationInfo);
    }
        
    @RemoteAction    
    public static GARP_BC_Orders.setOrderReturnInfo payOrder(GARP_BC_Registration.createOrderInfo setCourseOrderInfo) {
        return GARP_BC_Registration.payOrder(setCourseOrderInfo);
    }
    
    @RemoteAction
    public static GARP_BC_Registration.paymentStatus checkRegistrationPaymentStatus(String orderId) {
        return GARP_BC_Registration.checkRegistrationPaymentStatus(orderId);
    }    
    
    @RemoteAction
    public static Boolean rollbackSetRegistration(String leadId, String accountId, String email, String orderId) {
      return GARP_BC_Registration.rollbackSetRegistration(leadId, accountId, email, orderId, 'Cancel Registration');
    }    
    
    @RemoteAction    
    public static String getSessionState(String sessionToken) {
        return GARP_BC_Registration.getSessionState(sessionToken);
    }
    
    @RemoteAction
    public static void blockSessionUser(String token, String email) {            
        Utilities.blockSessionUser(token, email);
    }

    @RemoteAction
    public static GARP_MS_MemberProfile.memberProfileEdit getMemberProfileForEdit(String contactId) {            
        return GARP_MS_MemberProfile.getMemberProfileForEdit(contactId);
    }
    
    @RemoteAction
    public static Boolean setMemberProfile(GARP_MS_MemberProfile.memberProfileUpdate profileUpdate){        
        return GARP_BC_MemberProfile.setMemberProfile(profileUpdate);
    }
    
    public class programInformation {
        public String programCode { get; set; }
        public String abbrevName { get; set; }
        public String formalName { get; set; }
        public String informalName { get; set; }
        public String examPolicyURL { get; set; }
        public String logoURL { get; set; }
    }
}