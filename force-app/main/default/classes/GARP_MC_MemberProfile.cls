public without sharing class GARP_MC_MemberProfile {
    
    @AuraEnabled(cacheable = false)
    public static GARP_MS_MemberProfile.memberProfileEdit getMemberProfileForEdit(String contactId){
        return GARP_MS_MemberProfile.getMemberProfileForEdit(contactId);
    }

    @AuraEnabled(cacheable = false)
    public static Boolean setMemberProfile(GARP_MS_MemberProfile.memberProfileUpdate profileUpdate){
        
        Boolean ret=false;
        
        System.debug('profileUpdate: ' + profileUpdate);
        if(profileUpdate.ContactId != NULL && profileUpdate.AccountId != NULL) {             
            return GARP_MS_MemberProfile.setMemberProfile(profileUpdate);
        }
        return ret;
        
    }
    
    @AuraEnabled(cacheable = false)
    public static Boolean setMemberEmail(GARP_MS_MemberProfile.memberProfileUpdate profileUpdate){
        
        Boolean ret=false;
        
        System.debug('profileUpdate: ' + profileUpdate);
        if(profileUpdate.ContactId != NULL && profileUpdate.AccountId != NULL) {             
            return GARP_MS_MemberProfile.setMemberEmail(profileUpdate);
        }
        return ret;
        
    }
    


}