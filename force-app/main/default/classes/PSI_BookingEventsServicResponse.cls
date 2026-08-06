public class PSI_BookingEventsServicResponse{
    
    public String booking_code;
    public String candidate_id;
    public String change_reason;
    public String client_eligibility_id;
    public String eligibility_date;
    public String event_date_time;
    public String exam_code;
    public String expiration_date;
    public String location_address;
    public String address_1;
    public String address_2;
    public String address_3;
    public string city;
    public string state;
    public string country;
    public string postal_code;
    public String location_code;
    public String location_name;
    public String location_timezone;
    public String payment_mode;
    public String result;
    public String test_scheduled_date;
    
    public class Exam_portions {
        public String portion_code;
        public String portion_name;
    }
     
    public String booking_on;
    public String candidate_fname; 
    public String candidate_lname;
    public String candidate_mname;  
    public String delivery_mode;
    public String effective_date;    
    public List<Exam_portions> exam_portions;
    
    
    
    public static PSI_BookingEventsServicResponse parse(String json) {
        return (PSI_BookingEventsServicResponse) System.JSON.deserialize(json, PSI_BookingEventsServicResponse.class);
    }
}