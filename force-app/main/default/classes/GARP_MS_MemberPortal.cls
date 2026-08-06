public class GARP_MS_MemberPortal {

    public class returnGetUser {
        public User user;
        public String statusMessage;
        public Integer statusCode;
    }

    private static returnGetUser getUser() {
        returnGetUser returnGetUser = new returnGetUser();
        Id userId = UserInfo.getUserId();
        List<User> users = [SELECT Id, ContactId, Contact.FirstName, AccountId, Profile.Name, Email, Username FROM User WHERE Id = :userId];
        //System.Debug('*** users:' + users[0].Profile.Name);
        if(users.isEmpty() || users[0].Profile.Name != 'Customer Community' || users[0].ContactId == NULL){
            returnGetUser.statusMessage = 'User not found';
            returnGetUser.statusCode = 403;
            return returnGetUser;
        }
        returnGetUser.user = users[0];
        return returnGetUser;
    }

    public static String handleExpection(String contactId, Exception e) {
        System.debug('API Error:'+ e.getMessage() + ':' + e.getStackTraceString());
        GARP_Common.logAppError(e.getMessage(), e.getStackTraceString(), contactId);
        return e.getMessage() + ':' + e.getStackTraceString();
    }

    // Navigation

    @RemoteAction
    public static GARP_BC_MemberPortal.navBarInfo getNavBarInfo() {
        GARP_BC_MemberPortal.navBarInfo ret = new GARP_BC_MemberPortal.navBarInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getNavBarInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Dashboard

    @RemoteAction
    public static GARP_BC_MemberPortal.returnDashboardInfo getDashboardInfo(String loadKey) {
        GARP_BC_MemberPortal.returnDashboardInfo ret = new GARP_BC_MemberPortal.returnDashboardInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getDashboardInfo(returnGetUser.user.ContactId, loadKey);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }
        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Member Profile Methods

    @RemoteAction
    public static GARP_BC_MemberPortal.returnComponentUpdateProfileInfo getComponentUpdateProfileInfo() {
        GARP_BC_MemberPortal.returnComponentUpdateProfileInfo ret = new GARP_BC_MemberPortal.returnComponentUpdateProfileInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getComponentUpdateProfileInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }
        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProfileDemographicsFormInfo getProfileDemographicsFormInfo() {
        GARP_BC_MemberPortal.returnProfileDemographicsFormInfo ret = new GARP_BC_MemberPortal.returnProfileDemographicsFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getProfileDemographicsFormInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetProfileDemographicsFormInfo setProfileDemographicsFormInfo(GARP_BC_MemberProfile.demographicsContactInfo updateProfileDemographicsContactInfo) {
        GARP_BC_MemberPortal.returnSetProfileDemographicsFormInfo ret = new GARP_BC_MemberPortal.returnSetProfileDemographicsFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setProfileDemographicsFormInfo(returnGetUser.user.ContactId, updateProfileDemographicsContactInfo);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnMuteProfileComponent muteProfileComponent(Boolean mute) {
        GARP_BC_MemberPortal.returnMuteProfileComponent ret = new GARP_BC_MemberPortal.returnMuteProfileComponent();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.muteProfileComponent(returnGetUser.user.ContactId, mute);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetProfilePersonalFormInfo getProfilePersonalFormInfo() {
        GARP_BC_MemberPortal.returnGetProfilePersonalFormInfo ret = new GARP_BC_MemberPortal.returnGetProfilePersonalFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getProfilePersonalFormInfo(returnGetUser.user, returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }
        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetProfilePersonalInfo setProfilePersonalInfo(GARP_BC_MemberProfile.personalInfo personalInfo) {
        GARP_BC_MemberPortal.returnSetProfilePersonalInfo ret = new GARP_BC_MemberPortal.returnSetProfilePersonalInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setProfilePersonalInfo(returnGetUser.user, personalInfo);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnUploadMemberPhoto uploadMemberPhoto(String attachmentId, String fileText, String fileName) {
        GARP_BC_MemberPortal.returnUploadMemberPhoto ret = new GARP_BC_MemberPortal.returnUploadMemberPhoto();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.uploadMemberPhoto(returnGetUser.user.ContactId, attachmentId, fileText, fileName);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetMemberPhoto setMemberPhoto(String attachmentId) {
        GARP_BC_MemberPortal.returnSetMemberPhoto ret = new GARP_BC_MemberPortal.returnSetMemberPhoto();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setMemberPhoto(returnGetUser.user, returnGetUser.user.ContactId, attachmentId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }


    @RemoteAction
    public static GARP_BC_MemberPortal.returnRemoveMemberPhoto removeMemberPhoto() {
        GARP_BC_MemberPortal.returnRemoveMemberPhoto ret = new GARP_BC_MemberPortal.returnRemoveMemberPhoto();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.removeMemberPhoto(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetEmailPreferenceUpdate setEmailPreferenceUpdate() {
        GARP_BC_MemberPortal.returnSetEmailPreferenceUpdate ret = new GARP_BC_MemberPortal.returnSetEmailPreferenceUpdate();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setEmailPreferenceUpdate(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetSMSPreferenceUpdate setSMSPreferenceUpdate(Boolean smsPromotional, Boolean smsRegistration) {
        GARP_BC_MemberPortal.returnSetSMSPreferenceUpdate ret = new GARP_BC_MemberPortal.returnSetSMSPreferenceUpdate();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setSMSPreferenceUpdate(returnGetUser.user.ContactId, smsPromotional, smsRegistration);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetProfileMembershipInfo getProfileMembershipInfo() {
        GARP_BC_MemberPortal.returnGetProfileMembershipInfo ret = new GARP_BC_MemberPortal.returnGetProfileMembershipInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getProfileMembershipInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetMembershipAutorenew setAutorenewMembershipOff() {
        GARP_BC_MemberPortal.returnSetMembershipAutorenew ret = new GARP_BC_MemberPortal.returnSetMembershipAutorenew();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setAutorenewMembershipOff(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEnableAutoRenew enableAutoRenew() {
        GARP_BC_MemberPortal.returnEnableAutoRenew ret = new GARP_BC_MemberPortal.returnEnableAutoRenew();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.enableAutoRenew(returnGetUser.user, returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }
    
    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetProfileChaptersInfo getProfileChaptersInfo() {
        GARP_BC_MemberPortal.returnGetProfileChaptersInfo ret = new GARP_BC_MemberPortal.returnGetProfileChaptersInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getProfileChaptersInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetProfileChaptersInfo setProfileChaptersInfo(String chapterPrimary, String chapterSecondary) {
        GARP_BC_MemberPortal.returnSetProfileChaptersInfo ret = new GARP_BC_MemberPortal.returnSetProfileChaptersInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setProfileChaptersInfo(returnGetUser.user.ContactId, chapterPrimary, chapterSecondary);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetProfileExpertiseInfo getProfileExpertiseInfo() {
        GARP_BC_MemberPortal.returnGetProfileExpertiseInfo ret = new GARP_BC_MemberPortal.returnGetProfileExpertiseInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getProfileExpertiseInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetProfileExpertiseInfo setProfileExpertiseInfo(GARP_BC_MemberProfile.expertiseInfo expertiseInfo) {
        GARP_BC_MemberPortal.returnSetProfileExpertiseInfo ret = new GARP_BC_MemberPortal.returnSetProfileExpertiseInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setProfileExpertiseInfo(returnGetUser.user.ContactId, expertiseInfo);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }
        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Notifications

    @RemoteAction
    public static GARP_BC_MemberPortal.returnComponentNewNotificationsInfo getComponentNewNotificationsInfo() {
        GARP_BC_MemberPortal.returnComponentNewNotificationsInfo ret = new GARP_BC_MemberPortal.returnComponentNewNotificationsInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getComponentNewNotificationsInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }
        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetAllNotificationsInfo getAllNotifications() {
        GARP_BC_MemberPortal.returnGetAllNotificationsInfo ret = new GARP_BC_MemberPortal.returnGetAllNotificationsInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getAllNotifications(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }
        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // CPD Methods

    @RemoteAction
    public static GARP_BC_MemberPortal.returnComponentCPDInfo getComponentCPDInfo(String loadKey) {
        GARP_BC_MemberPortal.returnComponentCPDInfo ret = new GARP_BC_MemberPortal.returnComponentCPDInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getComponentCPDInfo(returnGetUser.user.ContactId, loadKey);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCPDListingInfo getCPDListingInfo() {
        GARP_BC_MemberPortal.returnCPDListingInfo ret = new GARP_BC_MemberPortal.returnCPDListingInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getCPDListingInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }
        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetCPDClaimFormInfo getCPDClaimFormInfo() {
        GARP_BC_MemberPortal.returnGetCPDClaimFormInfo ret = new GARP_BC_MemberPortal.returnGetCPDClaimFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getCPDClaimFormInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }
        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetCPDClaimInfo setCPDClaimInfo(GARP_BC_CPD.cpdClaim cpdClaim) {
        GARP_BC_MemberPortal.returnSetCPDClaimInfo ret = new GARP_BC_MemberPortal.returnSetCPDClaimInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setCPDClaimInfo(returnGetUser.user.ContactId, cpdClaim);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnDeleteCPDClaimInfo deleteCPDClaim(String claimId) {
        GARP_BC_MemberPortal.returnDeleteCPDClaimInfo ret = new GARP_BC_MemberPortal.returnDeleteCPDClaimInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.deleteCPDClaim(returnGetUser.user.ContactId, claimId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetCPDAttestationInfo setCPDAttestation(String attestationId) {
        GARP_BC_MemberPortal.returnSetCPDAttestationInfo ret = new GARP_BC_MemberPortal.returnSetCPDAttestationInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setCPDAttestation(returnGetUser.user.ContactId, attestationId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCPDActivitiesBrowseFormInfo getCPDActivitiesBrowseFormInfo(GARP_BC_CPD.cpdActivitiesFilters cpdActivitiesFilters, String activityId) {
        GARP_BC_MemberPortal.returnCPDActivitiesBrowseFormInfo ret = new GARP_BC_MemberPortal.returnCPDActivitiesBrowseFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getCPDActivitiesBrowseFormInfo(returnGetUser.user.ContactId, cpdActivitiesFilters, activityId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetCPDClaimInfo setCPDActivityAsClaim(GARP_BC_CPD.cpdActivity cpdActivity) {
        GARP_BC_MemberPortal.returnSetCPDClaimInfo ret = new GARP_BC_MemberPortal.returnSetCPDClaimInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setCPDActivityAsClaim(returnGetUser.user.ContactId, cpdActivity);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = 'User not found';
            ret.statusCode = 403;
            return ret;
        }
    }

    // CV Methods

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCVPageInfo getCVPageInfo(String programType) {
        GARP_BC_MemberPortal.returnCVPageInfo ret = new GARP_BC_MemberPortal.returnCVPageInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getCVPageInfo(returnGetUser.user.ContactId, programType);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetWorkExperienceInfo getWorkExperienceInfo(String programType, String experienceId) {
        GARP_BC_MemberPortal.returnGetWorkExperienceInfo ret = new GARP_BC_MemberPortal.returnGetWorkExperienceInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getWorkExperienceInfo(returnGetUser.user.ContactId, programType, experienceId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }
        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetWorkExperienceInfo setWorkExperienceInfo(String programType, String experienceId, GARP_BC_MyPrograms.workExperience workExperience) {
        GARP_BC_MemberPortal.returnSetWorkExperienceInfo ret = new GARP_BC_MemberPortal.returnSetWorkExperienceInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setWorkExperienceInfo(returnGetUser.user.ContactId, programType, experienceId, workExperience);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnDeleteWorkExperienceInfo deleteWorkExperienceInfo(String programType, String experienceId) {
        GARP_BC_MemberPortal.returnDeleteWorkExperienceInfo ret = new GARP_BC_MemberPortal.returnDeleteWorkExperienceInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.deleteWorkExperienceInfo(returnGetUser.user.ContactId, programType, experienceId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetCVAddressInfo setCVAddressInfo(String programType, GARP_Common.Address mailingAddress, GARP_Common.Address OSTAaddress, String OSTArecipient) {
        GARP_BC_MemberPortal.returnSetCVAddressInfo ret = new GARP_BC_MemberPortal.returnSetCVAddressInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setCVAddressInfo(returnGetUser.user.ContactId, programType, mailingAddress, OSTAaddress, OSTArecipient);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSubmitCVInfo submitCVInfo(String programType) {
        GARP_BC_MemberPortal.returnSubmitCVInfo ret = new GARP_BC_MemberPortal.returnSubmitCVInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.submitCVInfo(returnGetUser.user.ContactId, programType);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // My Programs

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEnrolledProgramsInfo getComponentEnrolledProgramsInfo() {
        GARP_BC_MemberPortal.returnEnrolledProgramsInfo ret = new GARP_BC_MemberPortal.returnEnrolledProgramsInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getComponentEnrolledProgramsInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsListingInfo getProgramsListingInfo(String loadKey) {
        GARP_BC_MemberPortal.returnProgramsListingInfo ret = new GARP_BC_MemberPortal.returnProgramsListingInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getProgramsListingInfo(returnGetUser.user.ContactId, loadKey);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCourseInfo getFRRProgramDetailInfo() {
        GARP_BC_MemberPortal.returnCourseInfo ret = new GARP_BC_MemberPortal.returnCourseInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getFRRProgramDetailInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCourseInfo getFRR25ProgramDetailInfo() {
        GARP_BC_MemberPortal.returnCourseInfo ret = new GARP_BC_MemberPortal.returnCourseInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getFRR25ProgramDetailInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCourseInfo getMicroCourseProgramDetailInfo(String courseType) {
        GARP_BC_MemberPortal.returnCourseInfo ret = new GARP_BC_MemberPortal.returnCourseInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getMicroCourseProgramDetailInfo(returnGetUser.user.ContactId, courseType);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCourseInfo getFFRProgramDetailInfo() {
        GARP_BC_MemberPortal.returnCourseInfo ret = new GARP_BC_MemberPortal.returnCourseInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getFFRProgramDetailInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsDetailInfo getFRMProgramDetailInfo(String loadKey) {
        GARP_BC_MemberPortal.returnProgramsDetailInfo ret = new GARP_BC_MemberPortal.returnProgramsDetailInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getFRMProgramDetailInfo(returnGetUser.user.ContactId, loadKey);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsDetailInfo getERPProgramDetailInfo(String loadKey) {
        GARP_BC_MemberPortal.returnProgramsDetailInfo ret = new GARP_BC_MemberPortal.returnProgramsDetailInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getERPProgramDetailInfo(returnGetUser.user.ContactId, loadKey);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsDetailInfo getSCRProgramDetailInfo(String loadKey) {
        GARP_BC_MemberPortal.returnProgramsDetailInfo ret = new GARP_BC_MemberPortal.returnProgramsDetailInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getSCRProgramDetailInfo(returnGetUser.user.ContactId, loadKey);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnProgramsDetailInfo getRAIProgramDetailInfo(String loadKey) {
        GARP_BC_MemberPortal.returnProgramsDetailInfo ret = new GARP_BC_MemberPortal.returnProgramsDetailInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getRAIProgramDetailInfo(returnGetUser.user.ContactId, loadKey);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }
    
    public static GARP_BC_MemberPortal.returnProgramsDetailInfo getRAIJProgramDetailInfo(String loadKey) {
        GARP_BC_MemberPortal.returnProgramsDetailInfo ret = new GARP_BC_MemberPortal.returnProgramsDetailInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getRAIJProgramDetailInfo(returnGetUser.user.ContactId, loadKey);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEPPOptInInfo EPPOptIn(String examType, Boolean optIn) {
        GARP_BC_MemberPortal.returnEPPOptInInfo ret = new GARP_BC_MemberPortal.returnEPPOptInInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.EPPOptIn(returnGetUser.user.ContactId, examType, optIn);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnExamResultsListingInfo getExamResultsListing(String loadKey) {
        GARP_BC_MemberPortal.returnExamResultsListingInfo ret = new GARP_BC_MemberPortal.returnExamResultsListingInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getExamResultsListing(returnGetUser.user.ContactId, loadKey);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetExamResultLastViewDate setExamResultLastViewDate(String examAttemptId) {
        GARP_BC_MemberPortal.returnSetExamResultLastViewDate ret = new GARP_BC_MemberPortal.returnSetExamResultLastViewDate();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setExamResultLastViewDate(returnGetUser.user.ContactId, examAttemptId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Exam Setup

    @RemoteAction
    public static GARP_BC_MyPrograms.returnGetExamSetupFormInfo getExamSetupFormInfo(String examType) {
        GARP_BC_MyPrograms.returnGetExamSetupFormInfo ret = new GARP_BC_MyPrograms.returnGetExamSetupFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getExamSetupFormInfo(returnGetUser.user.Id, returnGetUser.user.ContactId, examType);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MyPrograms.returnGetExamSetupExamSelectionInfo getExamSetupExamSelectionInfo(String examType, GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        GARP_BC_MyPrograms.returnGetExamSetupExamSelectionInfo ret = new GARP_BC_MyPrograms.returnGetExamSetupExamSelectionInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getExamSetupExamSelectionInfo(returnGetUser.user.ContactId, examType, examSetupExamSelectionsInfo);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MyPrograms.returnGetExamSetupFeesCheckoutInfo getExamSetupFeesCheckoutInfo(String examRegistrationModificationId) {
        GARP_BC_MyPrograms.returnGetExamSetupFeesCheckoutInfo ret = new GARP_BC_MyPrograms.returnGetExamSetupFeesCheckoutInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getExamSetupFeesCheckoutInfo(returnGetUser.user.ContactId, examRegistrationModificationId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MyPrograms.returnGetExamSetupIDInfo getExamSetupIDInfo(String examType, GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo) {
        GARP_BC_MyPrograms.returnGetExamSetupIDInfo ret = new GARP_BC_MyPrograms.returnGetExamSetupIDInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getExamSetupIDInfo(returnGetUser.user.ContactId, examType, examSetupExamSelectionsInfo);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MyPrograms.returnSetExamSetupIDInfo setExamSetupIDInfo(String examType, GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo, GARP_BC_MyPrograms.setIdCandidateInfo idCandidateInfo) {
        GARP_BC_MyPrograms.returnSetExamSetupIDInfo ret = new GARP_BC_MyPrograms.returnSetExamSetupIDInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setExamSetupIDInfo(returnGetUser.user.ContactId, examType, examSetupExamSelectionsInfo, idCandidateInfo);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MyPrograms.returnExamSetupAuthorizeRegistrations examSetupAuthorizeRegistrations(String examType, Boolean isRetry) {
        GARP_BC_MyPrograms.returnExamSetupAuthorizeRegistrations ret = new GARP_BC_MyPrograms.returnExamSetupAuthorizeRegistrations();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.examSetupAuthorizeRegistrations(returnGetUser.user.ContactId, examType, isRetry);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Alert
    @RemoteAction
    public static GARP_BC_MemberPortal.returnAlertBarInfo getAlertBarInfo(String loadKey) {
        GARP_BC_MemberPortal.returnAlertBarInfo ret = new GARP_BC_MemberPortal.returnAlertBarInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getAlertBarInfo(returnGetUser.user.ContactId, loadKey);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Events

    @RemoteAction
    public static GARP_BC_MemberPortal.returnUpcomingEventsInfo getComponentUpcomingEventsInfo() {
        GARP_BC_MemberPortal.returnUpcomingEventsInfo ret = new GARP_BC_MemberPortal.returnUpcomingEventsInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getComponentUpcomingEventsInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEventsListingInfo getEventsListingInfo() {
        GARP_BC_MemberPortal.returnEventsListingInfo ret = new GARP_BC_MemberPortal.returnEventsListingInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getEventsListingInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    public static GARP_BC_MemberPortal.returnBenchPrepLinks getBenchPrepLinks() {
        GARP_BC_MemberPortal.returnBenchPrepLinks ret = new GARP_BC_MemberPortal.returnBenchPrepLinks();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getBenchPrepLinks(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Ads

    @RemoteAction
    public static GARP_BC_MemberPortal.returnAdInfo getComponentAdInfo() {
        GARP_BC_MemberPortal.returnAdInfo ret = new GARP_BC_MemberPortal.returnAdInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getComponentAdInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Study Materials

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetStudyMaterialListing getStudyMaterialListing() {
        GARP_BC_MemberPortal.returnGetStudyMaterialListing ret = new GARP_BC_MemberPortal.returnGetStudyMaterialListing();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getStudyMaterialListing(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetMyEBooksInfo getMyEBooksInfo() {
        GARP_BC_MemberPortal.returnGetMyEBooksInfo ret = new GARP_BC_MemberPortal.returnGetMyEBooksInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getMyEBooksInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEBookAccessURLs getEBookAccessURLs(List<GARP_BC_StudyMaterials.eBookItem> eBookItems) {
        GARP_BC_MemberPortal.returnEBookAccessURLs ret = new GARP_BC_MemberPortal.returnEBookAccessURLs();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getEBookAccessURLs(returnGetUser.user.ContactId, eBookItems);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnEBookAccessURL getEBookAccessURL(String vendorId) {
        GARP_BC_MemberPortal.returnEBookAccessURL ret = new GARP_BC_MemberPortal.returnEBookAccessURL();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getEBookAccessURL(returnGetUser.user.ContactId, vendorId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetErrataFormInfo getErrataFormInfo(String programType) {
        GARP_BC_MemberPortal.returnGetErrataFormInfo ret = new GARP_BC_MemberPortal.returnGetErrataFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getErrataFormInfo(returnGetUser.user.ContactId, programType);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSubmitErrataFormInfo submitErrataForm(GARP_BC_StudyMaterials.errataFormSubmissionInfo errataFormSubmissionInfo) {
        GARP_BC_MemberPortal.returnSubmitErrataFormInfo ret = new GARP_BC_MemberPortal.returnSubmitErrataFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.submitErrataForm(returnGetUser.user.ContactId, errataFormSubmissionInfo);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnAttachFileErrataSubmission attachFileErrataSubmission(String errataId, String fileName, String filetext, String fileId) {
        GARP_BC_MemberPortal.returnAttachFileErrataSubmission ret = new GARP_BC_MemberPortal.returnAttachFileErrataSubmission();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.attachFileErrataSubmission(returnGetUser.user.ContactId, errataId, fileName, filetext, fileId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Member Directory

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetDirectorySearchFormInfo getDirectorySearchFormInfo() {
        GARP_BC_MemberPortal.returnGetDirectorySearchFormInfo ret = new GARP_BC_MemberPortal.returnGetDirectorySearchFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getDirectorySearchFormInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSearchDirectoryInfo searchMemberDirectory(GARP_BC_Membership.searchParams searchParams) {
        GARP_BC_MemberPortal.returnSearchDirectoryInfo ret = new GARP_BC_MemberPortal.returnSearchDirectoryInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.searchMemberDirectory(returnGetUser.user.ContactId, searchParams);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetMemberDirectorySettingsFormInfo getMemberDirectorySettingsFormInfo() {
        GARP_BC_MemberPortal.returnGetMemberDirectorySettingsFormInfo ret = new GARP_BC_MemberPortal.returnGetMemberDirectorySettingsFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getMemberDirectorySettingsFormInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetMemberDirectorySettingsFormInfo setMemberDirectorySettingsFormInfo(GARP_BC_MemberProfile.memberDirectorySettings directorySettings) {
        GARP_BC_MemberPortal.returnSetMemberDirectorySettingsFormInfo ret = new GARP_BC_MemberPortal.returnSetMemberDirectorySettingsFormInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setMemberDirectorySettingsFormInfo(returnGetUser.user.ContactId, directorySettings);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSendMemberDirectoryMessageInfo sendMemberDirectoryMessage(GARP_BC_Membership.sendMemberMessageInfo sendMemberMessageInfo) {
        GARP_BC_MemberPortal.returnSendMemberDirectoryMessageInfo ret = new GARP_BC_MemberPortal.returnSendMemberDirectoryMessageInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.sendMemberDirectoryMessage(returnGetUser.user.ContactId, sendMemberMessageInfo);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Orders

    @RemoteAction
    public static GARP_BC_MemberPortal.returnPurchaseHistoryInfo getPurchaseHistoryInfo() {
        GARP_BC_MemberPortal.returnPurchaseHistoryInfo ret = new GARP_BC_MemberPortal.returnPurchaseHistoryInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getPurchaseHistoryInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetOrderInfo getOrderInfo(String orderNumber) {
        GARP_BC_MemberPortal.returnGetOrderInfo ret = new GARP_BC_MemberPortal.returnGetOrderInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getOrderInfo(returnGetUser.user.ContactId, orderNumber);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnCancelUnpaidOrder cancelUnpaidOrder(String orderId) {
        GARP_BC_MemberPortal.returnCancelUnpaidOrder ret = new GARP_BC_MemberPortal.returnCancelUnpaidOrder();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.cancelUnpaidOrder(returnGetUser.user.ContactId, orderId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnPayPendingOrder payPendingOrder(String orderId) {
        GARP_BC_MemberPortal.returnPayPendingOrder ret = new GARP_BC_MemberPortal.returnPayPendingOrder();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.payPendingOrder(returnGetUser.user.ContactId, orderId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Membership Benefits

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetMembershipPageInfo getMembershipPageInfo() {
        GARP_BC_MemberPortal.returnGetMembershipPageInfo ret = new GARP_BC_MemberPortal.returnGetMembershipPageInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getMembershipPageInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // Help Center

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSubmitCustomerCase submitCustomerCase(String title, String description) {
        GARP_BC_MemberPortal.returnSubmitCustomerCase ret = new GARP_BC_MemberPortal.returnSubmitCustomerCase();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.submitCustomerCase(returnGetUser.user.Id, returnGetUser.user.ContactId, title, description);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    // OSTA ID Info

    @RemoteAction
    public static GARP_BC_MemberPortal.returnGetOSTAIDInfo getOSTAIDInfo() {
        GARP_BC_MemberPortal.returnGetOSTAIDInfo ret = new GARP_BC_MemberPortal.returnGetOSTAIDInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.getOSTAIDInfo(returnGetUser.user.ContactId);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnSetOSTAIDInfo setOSTAIDInfo(GARP_BC_MyPrograms.OSTAIDInfo OSTAIDInfo) {
        GARP_BC_MemberPortal.returnSetOSTAIDInfo ret = new GARP_BC_MemberPortal.returnSetOSTAIDInfo();
        returnGetUser returnGetUser = getUser();
        if(returnGetUser.user != NULL) {
            try{
                if(test.isRunningTest() && returnGetUser.user.Contact.FirstName == 'Throw') {
                    Contact a; a.FirstName = 'Bob';
                }
                return GARP_BC_MemberPortal.setOSTAIDInfo(returnGetUser.user.ContactId, OSTAIDInfo);
            }catch(Exception e){
                ret.statusMessage = handleExpection(returnGetUser.user.ContactId, e);
                ret.statusCode =  500;
                return ret;
            }

        } else {
            ret.statusMessage = returnGetUser.statusMessage;
            ret.statusCode =  returnGetUser.statusCode;
            return ret;
        }
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo uploadWorkExperienceAttachment(Id workExperienceId, String fileName, String base64Data) {
        return GARP_BC_MemberPortal.uploadWorkExperienceAttachment(workExperienceId, fileName, base64Data);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo deleteWorkExperienceAttachment(Id attachmentId) {
        return GARP_BC_MemberPortal.deleteWorkExperienceAttachment(attachmentId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo getWorkExperienceAttachments(Id workExperienceId) {
        return GARP_BC_MemberPortal.getWorkExperienceAttachments(workExperienceId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo downloadWorkExperienceAttachment(Id attachmentId) {
        return GARP_BC_MemberPortal.downloadWorkExperienceAttachment(attachmentId);
    }

    @RemoteAction
    public static GARP_BC_MemberPortal.returnDocumentRequirementInfo isContactRequiredToHaveDocuments(Map<String, Object> formData, String institutionType) {
        return GARP_BC_MemberPortal.isContactRequiredToHaveDocuments(formData, institutionType);
    }

    public GARP_MS_MemberPortal(sfdcAppRemoter ctrl){}

}