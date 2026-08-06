public class ATA_NotificationBodyCls {
   public string event_id;
   public string event_type;
   public string sign;
   public string event_created_at;
   public string event_data;
   
   //Event data for reservation
   public string batch_no;
   public string name;
   public string cert_type;
   public string cert_id;
   public string exam_cert_no;
   public string start_time;
   public string end_time;
   public string subject_code;
   public string subject_name;
   public string org_name;
   public string room_name;
   public string org_address;
   public string room_address;
   public integer client_id;
   public string reservation_at;
   
   //Event data for cancel reservation
	public string cancel_reservation_at;
}