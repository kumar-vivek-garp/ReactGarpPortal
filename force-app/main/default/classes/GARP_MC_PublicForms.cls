public without sharing class GARP_MC_PublicForms {
	@AuraEnabled
    public static List<GARP_MS_MemberProfile.InstitutionSearchResult> searchInstitutions(String searchTerm, String institutionType) {
        return GARP_MS_MemberProfile.searchInstitutions(searchTerm, InstitutionType);
    }
}