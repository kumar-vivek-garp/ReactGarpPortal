public class RapidCourseJSON {
	public integer automation_script_id;
	public input input;	
    
    public class input{
        public integer course_id;
        public string idempotency_key;
    }
}