@isTest
public class garpAppRemoter_test {

    static testMethod void unitTest1(){
        test.startTest();
        
        garpAppRemoter.getNavBarInfo();
        garpAppRemoter.getStudyMaterialListing();
        garpAppRemoter.getDashboardInfo('');
        garpAppRemoter.getComponentAdInfo();
        garpAppRemoter.getComponentUpdateProfileInfo();
        garpAppRemoter.getProfileDemographicsFormInfo();
        garpAppRemoter.setProfileDemographicsFormInfo(NULL);
        garpAppRemoter.muteProfileComponent(True);
        garpAppRemoter.getComponentNewNotificationsInfo();
        garpAppRemoter.getComponentCPDInfo('');
        garpAppRemoter.getComponentEnrolledProgramsInfo();
        garpAppRemoter.getComponentUpcomingEventsInfo();
        garpAppRemoter.getAlertBarInfo('');
        
        garpAppRemoter.getProgramsListingInfo('');
        garpAppRemoter.getDirectorySearchFormInfo();
        garpAppRemoter.searchMemberDirectory(NULL);
        garpAppRemoter.getFRMProgramDetailInfo('');
        garpAppRemoter.getSCRProgramDetailInfo('');
        garpAppRemoter.getFRRProgramDetailInfo();
        
        garpAppRemoter.getFFRProgramDetailInfo();
        garpAppRemoter.getExamResultsListing(NULL);
        garpAppRemoter.setExamResultLastViewDate(NULL);
        garpAppRemoter.EPPOptIn('frm',True);
        garpAppRemoter.getEventsListingInfo();
        garpAppRemoter.getAllNotifications();
        garpAppRemoter.getERPProgramDetailInfo(NULL); 
        
        garpAppRemoter.getERPProgramDetailInfo(NULL);
        garpAppRemoter.getFRR25ProgramDetailInfo();
        garpAppRemoter.getMicroCourseProgramDetailInfo(NULL);
        garpAppRemoter.setExamSetupIDInfo(NULL,NULL,NULL);
        garpAppRemoter.examSetupAuthorizeRegistrations(NULL, FALSE);
        garpAppRemoter.cancelUnpaidOrder(NULL);
        garpAppRemoter.submitCustomerCase(NULL,NULL);
        garpAppRemoter.getOSTAIDInfo();
        garpAppRemoter.setOSTAIDInfo(NULL);
        garpAppRemoter.deleteWorkExperienceAttachment(NULL);
        garpAppRemoter.getWorkExperienceAttachments(NULL);
        
        garpAppRemoter.downloadWorkExperienceAttachment(NULL);
        garpAppRemoter.isContactRequiredToHaveDocuments(NULL,NULL);
        garpAppRemoter.getFRMRegistrationInfo(NULL);
        garpAppRemoter.getSCRRegistrationInfo(NULL);
        garpAppRemoter.getRiskAIRegistrationInfo(NULL);
        garpAppRemoter.getFFRRegistrationInfo(NULL);
        garpAppRemoter.getFRRRegistrationInfo(NULL);
        garpAppRemoter.getMembershipRegistrationInfo(NULL);
        garpAppRemoter.getAffiliateMembershipRegistrationInfo();
        //garpAppRemoter.getWebcastRegistrationInfo(NULL);
        //garpAppRemoter.getChapterMeetingRegistrationInfo(NULL);
        //garpAppRemoter.getEventRegistrationInfo(NULL);
        //garpAppRemoter.getRegistrationFees(NULL);        
        
        test.stopTest();
        
    }
    
    static testMethod void unitTest2(){
        test.startTest();
        
        garpAppRemoter.getMyEBooksInfo();
        
        List<GARP_BC_StudyMaterials.eBookItem> eBookItems = new List<GARP_BC_StudyMaterials.eBookItem>();
        garpAppRemoter.getEBookAccessURLs(eBookItems);
        
        garpAppRemoter.getEBookAccessURL('test');
        garpAppRemoter.getErrataFormInfo('test');
        
        GARP_BC_StudyMaterials.errataFormSubmissionInfo errataFormSubmissionInfo = new GARP_BC_StudyMaterials.errataFormSubmissionInfo();
        garpAppRemoter.submitErrataForm(errataFormSubmissionInfo);
        
        garpAppRemoter.getAccountRecordId();
        
        GARP_BC_MemberProfile.personalInfo personalInfo = new GARP_BC_MemberProfile.personalInfo();
        garpAppRemoter.setProfilePersonalInfo(personalInfo);
        
        garpAppRemoter.getProfileMembershipInfo();
        garpAppRemoter.setAutorenewMembershipOff();
        
        garpAppRemoter.enableAutoRenew();
        
        garpAppRemoter.getProfileChaptersInfo();
        garpAppRemoter.setProfileChaptersInfo('test','test');
        garpAppRemoter.getProfileExpertiseInfo();
        
        GARP_BC_MemberProfile.expertiseInfo ei = new GARP_BC_MemberProfile.expertiseInfo();
        garpAppRemoter.setProfileExpertiseInfo(ei);
        
        garpAppRemoter.getCPDListingInfo();
        //garpAppRemoter.getMembershipOffersInfo();
        //garpAppRemoter.getRiskNetFormInfo();
        //garpAppRemoter.getON24SSOInfo();
        garpAppRemoter.getMembershipPageInfo();
        garpAppRemoter.getMembershipPageInfo();
        garpAppRemoter.getOrderInfo('test');
        garpAppRemoter.getPurchaseHistoryInfo();
        garpAppRemoter.getExamSetupFormInfo('test');
        garpAppRemoter.getRAIProgramDetailInfo('');
        garpAppRemoter.getMemberDirectorySettingsFormInfo();
        garpAppRemoter.setCPDAttestation('test');
        garpAppRemoter.getProfilePersonalFormInfo();
        garpAppRemoter.deleteCPDClaim('test');
        
        GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo = new GARP_BC_MyPrograms.examSetupExamSelectionsInfo();
        garpAppRemoter.getExamSetupExamSelectionInfo('test',examSetupExamSelectionsInfo);
        //garpAppRemoter.setExamSetupExamSelectionsChanges('test', examSetupExamSelectionsInfo);
        garpAppRemoter.getExamSetupIDInfo('test', examSetupExamSelectionsInfo);
        garpAppRemoter.getCPDClaimFormInfo();
        
        garpAppRemoter.removeMemberPhoto();
        garpAppRemoter.uploadMemberPhoto(null, null, null); 
        garpAppRemoter.setMemberPhoto(null);
        garpAppRemoter.setEmailPreferenceUpdate();
        garpAppRemoter.setCPDClaimInfo(null);
        garpAppRemoter.getCPDActivitiesBrowseFormInfo(null, null);
        garpAppRemoter.setCPDActivityAsClaim(null);
        garpAppRemoter.getCVPageInfo('FRM');
        garpAppRemoter.getWorkExperienceInfo('FRM',null);
        garpAppRemoter.setWorkExperienceInfo('FRM',null,null);
        garpAppRemoter.deleteWorkExperienceInfo('FRM',null);
        garpAppRemoter.setCVAddressInfo('FRM',null,null,null);
        garpAppRemoter.submitCVInfo('FRM');
        garpAppRemoter.setMemberDirectorySettingsFormInfo(null);
        garpAppRemoter.sendMemberDirectoryMessage(null);
        
        test.stopTest();
        
    }

}