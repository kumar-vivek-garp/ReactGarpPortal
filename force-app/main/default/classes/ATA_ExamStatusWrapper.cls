public class ATA_ExamStatusWrapper {

	public class Biz_content {
		public String cert_id;
		public String exam_cert_no;
		public String exam_status;
		public String subject_code;
	}

	public String app_id;
	public List<Biz_content> biz_content;
	public String resp_msg;
	public String resp_status;
	public String sign;
	public String sign_type;
	public String timestamp;

	
	public static ATA_ExamStatusWrapper parse(String json) {
		return (ATA_ExamStatusWrapper) System.JSON.deserialize(json, ATA_ExamStatusWrapper.class);
	}
}