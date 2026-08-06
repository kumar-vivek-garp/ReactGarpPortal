public class PSI_CandidatedataWrapper { 
    
    public class Candidate {
        public List<Additional_attributes> additional_attributes;
        public String address1;
        public String address2;
        public String candidate_id;
        public String city;
        public String country;
        public String email;
        public String first_name;
        public String home_phone;
        public String last_name;
        public String middle_name;
        public String office_phone;
        public String postal_code;
        public String province_state;
        public String school_code;
        public List<String> special_accommodations;
        public String suffix;
    }

    public Candidate candidate;
    public String client_eligibility_id;
    public String eligibility_end_date;
    public List<String> portion_codes;
    public String schedule_start_date;
    public String test_code;

    public class Additional_attributes {
        public String key;
        public String value;
    } 
}