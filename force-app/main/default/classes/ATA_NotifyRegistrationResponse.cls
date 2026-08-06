public class ATA_NotifyRegistrationResponse {
    public String event_id;
    public String event_type;
    public String sign;
    public String event_created_at;
    public String event_data;
    
    
    public class reservation{
        public String batch_no;
        public String reg_code;
        public String name;
        public String cert_type;
        public String cert_id;
        public String exam_cert_no;
        public String start_time;
        public String end_time;
        public String region_code;
        public String region_name;
        public String subject_code;
        public String subject_name;
        public String org_name;
        public String room_name;
        public String org_address;
        public String room_address;
        public String client_id;
        public String reservation_at;
        public string exam_language;
    }
    
    public class cancelreservation{
        public String batch_no;
        public String reg_code;
        public String name;
        public String cert_type;
        public String cert_id;
        public String exam_cert_no;  
        public String subject_code;
        public String subject_name;  
        public String cancel_reservation_at;
    }
    
    
    public static ATA_NotifyRegistrationResponse parse(String json) {
        return (ATA_NotifyRegistrationResponse) System.JSON.deserialize(json, ATA_NotifyRegistrationResponse.class);
    }
}