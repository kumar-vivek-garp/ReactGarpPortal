public class PSIGetResponseParserClass {
    
    public class Candidate {
        @AuraEnabled
        public String country;
        public String home_phone;
        public String school_code;
        public String address2;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String address1;
        @AuraEnabled
        public String province_state;
        @AuraEnabled
        public String last_name;
        public String suffix;
        public String middle_name;
        public List<Special_accommodations> special_accommodations;
        @AuraEnabled
        public String candidate_id;
        public String office_phone;
        @AuraEnabled
        public String postal_code;
        @AuraEnabled
        public String first_name;
        @AuraEnabled
        public String email;
        public List<Special_accommodations> additional_attributes;
    }
    @AuraEnabled
    public String eligibility_end_date;
    @AuraEnabled
    public Candidate candidate;
    public List<String> portion_codes;
    @AuraEnabled
    public Boolean eligible_to_schedule;
    @AuraEnabled
    public String eligibility_status_message;
    public String schedule_start_date;
    @AuraEnabled
    public String test_code;
    @AuraEnabled
    public String psi_eligiblity_id;
    @AuraEnabled
    public String created_datetime;
    @AuraEnabled
    public String client_eligibility_id;
    @AuraEnabled
    public String status;
    
    public class Special_accommodations {
    }
    
    
    public static List<PSIGetResponseParserClass> parse(String json) {
        return (List<PSIGetResponseParserClass>) System.JSON.deserialize(json, List<PSIGetResponseParserClass>.class);
    }
}