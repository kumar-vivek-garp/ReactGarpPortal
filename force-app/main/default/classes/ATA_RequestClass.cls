public class ATA_RequestClass {
    
    public String sign;
    public String app_id;
    public String sign_type;
    public String timestamp; 
    public String biz_content; 
    public class Biz_content {
        public String batch_no;
        public String cert_id;
        public String cert_type;
        public Extend extend;
        public String gender;
        public String name;
        public Integer pay_status;
        public String reg_code;
        public String reg_time;
        public List<Region_subject> region_subject;
        public Integer status;
        public String subject_code;
    }
    
    public class Extend {
        public String id_type;
        public String email;
        public String c_name;
        public String id_number;
    }
    
    public class Region_subject {
        public String region_code;
        public String region_name;
        public String subject_code;
        public String subject_name;
    }
    

    
}