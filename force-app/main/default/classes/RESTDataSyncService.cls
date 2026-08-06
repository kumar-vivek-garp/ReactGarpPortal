@RestResource(urlMapping='/datasync/*')
global with sharing class RESTDataSyncService {

    global class teamRegistrationData {
        public String firstName   { get; set; }
        public String lastName    { get; set; }
        public String email       { get; set; }
        public String location    { get; set; }
        public String phone       { get; set; }
        public String company     { get; set; }        
        public String interest          { get; set; }        
        public String numberOfMembers   { get; set; }        
        public String message           { get; set; }                
        public String submittedAt     { get; set; }
        public String title           { get; set; }
        public String industry        { get; set; }       
        public String professionalLevel  { get; set; } 
        public String jobfunction     { get; set; }         
    }
    
    public static Boolean setTeamRegistration(teamRegistrationData data){
        Boolean ret;
        
        DateTime dt = DateTime.now();
        if(data.submittedAt != NULL) {
            Long l =Long.valueOf(data.submittedAt);
            dt = DateTime.newInstance(l);
            System.debug('dt:' + dt);
        }
        
        Team_Registration__c tr = new Team_Registration__c(
            Form_Email__c = data.email,
            Form_Company__c = data.company,
            Form_Name__c = 'Team Registration',
            Form_Submission_Date__c = dt,
            Form_Message__c = data.message,
            Form_First_Name__c = data.firstName,
            Form_Last_Name__c = data.lastName,
            Form_Location__c = data.location,
            Form_Phone__c = data.phone,
            Form_Product__c = data.interest,
            Form_Number_of_Employees__c = data.numberOfMembers,
            Form_Title__c = data.title,
            Form_Professional_Level__c = data.professionalLevel,
            Form_Industry__c = data.industry,
            Form_Job_Function__c = data.jobfunction,
            RecordTypeId = recordtypehelper.getrecordtypeidfromschema('Team_Registration__c','Team_Registration_Prospect')
        );
        insert tr;
        
        return ret;
    }
    
    @HttpPost
    global static void dataSync(string objectName, teamRegistrationData data) {
        if(objectName == 'Team Registration') {
            setTeamRegistration(data);
        }
    }
    
}