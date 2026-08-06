public class GBI_MS_Pillar3 {

    public class pillar3Country {
        public String country;
        public String region;
    }
    
    public class pillar3Filters {
        public List<String> lstCurrencies;
        public List<Pillar_3_Institution__c> lstInstitutions;
        public Pillar_3_Dates__c dates;
        public List<String> institutionTypeList;
        public List<pillar3Country> countryList;
    }

    // public class PillarReport{
    //     @AuraEnabled public String Id;
    //     @AuraEnabled public String Name;
    //     @AuraEnabled public List<MainMenu> mainMenuList;
    // }
    
    // public class MainMenu{
    //     @AuraEnabled public String Id;
    //     @AuraEnabled public String Name;
    //     @AuraEnabled public List<SubMenu> subMenuList;
    // }
    
    // public class SubMenu{
    //     @AuraEnabled public String Id;
    //     @AuraEnabled public String Name;
    // }
    
    @RemoteAction
    public static List<Pillar_3_Notification__c> getPillar3Notifications() {
        return GBI_BC_Pillar3.getPillar3Notifications();
    }
    
    @RemoteAction
    public static pillar3Filters getPillar3Filters() {
        return GBI_BC_Pillar3.getPillar3Filters();
    }
    
    @RemoteAction
    public static List<Pillar_3_Report__c> getPillar3Menu() {
        return GBI_BC_Pillar3.getPillar3Menu();
    }
    /*
    @RemoteAction
    public static Boolean submitPillar3Attestation() {
        return GBI_BC_Pillar3.submitPillar3Attestation();
    }
    */
    public GBI_MS_Pillar3(GBI_MS_Studies ctrl){}
}