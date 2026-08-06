public class GARP_MS_Membership {

    // Methods
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getMembershipRegistrationInfo(String regCode) {
        return GARP_BC_Membership.getMembershipRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getAffiliateMembershipRegistrationInfo() {
        return GARP_BC_Membership.getAffiliateMembershipRegistrationInfo();
    }
    
    //@RemoteAction
    //public static boolean sendDirectoryMessage(String templateName, String text, String recptContactId){
    //    return GARP_BC_Membership.sendDirectoryMessage(templateName, text, recptContactId);
    //}
    
    //@RemoteAction
    //public static GARP_BC_Membership.searchResults searchMembers(Boolean FRMOnly, Boolean ERPOnly, Boolean SCROnly, String searchText, String industries, String jobFunctions, String riskSpecialties, String corporateTitles, String company, String sortField, String sortOrder, Integer pageSize, Integer pageCurrent) {
    //    return GARP_BC_Membership.searchMembers(FRMOnly, ERPOnly, SCROnly, searchText, industries, jobFunctions, riskSpecialties, corporateTitles, company, sortField, sortOrder, pageSize, pageCurrent);
    //}
    
    public GARP_MS_Membership(sfdcAppRemoter ctrl){}
}