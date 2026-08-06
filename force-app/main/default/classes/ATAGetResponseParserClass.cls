public class ATAGetResponseParserClass {
    
    public String app_id;
    public List<Biz_content> biz_contentList;
    public String biz_content;
    public String resp_msg;
    public String resp_status;
    public String sign;
    public String sign_type;
    public String timestamp; 
    public class Biz_content {
        @AuraEnabled
        public String batch_name;
        @AuraEnabled
        public String cert_id;
        @AuraEnabled
        public String cert_type;
        @AuraEnabled
        public String client_id;
        @AuraEnabled
        public Extend extend;
        public String gender;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Integer pay_status;
        @AuraEnabled
        public String reasons;
        @AuraEnabled
        public String reg_code;
        @AuraEnabled
        public String reg_time;
        @AuraEnabled
        public String end_time;
        @AuraEnabled
        public String exam_cert_no;
        @AuraEnabled
        public String org_address;
        @AuraEnabled
        public String org_name;
        @AuraEnabled
        public String region_code;
        @AuraEnabled
        public String room_address;
        @AuraEnabled
        public String room_name;
        @AuraEnabled
        public String start_time;
        @AuraEnabled
        public String subject_code;
        @AuraEnabled
        public String subject_name;
        public List<Region_subject> region_subject;
        @AuraEnabled
        public Integer status;
        @AuraEnabled
        public String region_name;
    }
    
    public class Extend {
        @AuraEnabled
        public String c_name;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String id_number;
        @AuraEnabled
        public String id_type;
    }
    public class Region_subject {
        public String region_code;
        public String region_name;
        public String subject_code;
        public String subject_name;
    }
    
    
    public static ATAGetResponseParserClass parse(String json) {
        return (ATAGetResponseParserClass) System.JSON.deserialize(json, ATAGetResponseParserClass.class);
    }
}