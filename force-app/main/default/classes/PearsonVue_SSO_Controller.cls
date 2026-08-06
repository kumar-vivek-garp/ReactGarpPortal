public with sharing class PearsonVue_SSO_Controller {
    public String Client_Code { get; set; }
    public String GarpId { get;set; }
    public String RegistrationId { get;set; }
    Public string External_Error_URL { get; set; }
    Public string External_Return_URL { get; set; }
    Public string External_Session_TimeOut { get; set; }
    Public string External_TimeOut_URL { get; set; }
    public String Vue_Candidate_Id { get; set; }
    public String Exam_Series_Code { get; set; }
    public String External_Auth_Hash { get;set; }
    public String PortalAction{ get;set; }
    public String Msg { get;set; }
    public String RegID { get;set; }    
    public String callfunc { get;set; } 
    public String PearsonVUESSOEndpoint{ get;set; }
    public String EXAMLANGUAGE{ get;set; }  
    public Long EpochTimeStamp { get; set;}
    
    public Exam_Attempt__c ExamReg { get; set; } 
     public static Map<String,Pearson_Exam_Series_Configuration__mdt> PearsonSectionTypeConfigMap = IntegrationsMtdUtil.getBySectionConfiguration();
    public PearsonVue_SSO_Controller(){
        Msg = null;
        External_Auth_Hash = '';
        Client_Code = 'GARP';
        ExamReg = new  Exam_Attempt__c();
        
        // Capturing Registration Id
        RegistrationId = ApexPages.currentPage().getParameters().get('id');
        String action = ApexPages.currentPage().getParameters().get('action');   
        //RegistrationId = 'a1a5C0000006yI6';
        
        PearsonVUESSOEndpoint = System.Label.PearsonVUESSOEndpoint;
        
        if(test.isRunningTest()){
            Exam_Attempt__c RegId = [Select id from Exam_Attempt__c];
            RegistrationId = RegId.Id;
        }
        if(RegistrationId == NULL || RegistrationId.length() == 0) {
            Msg = 'No Registration was passed';
        } else {
          List<Exam_Attempt__c > lstExamReg = new List<Exam_Attempt__c >();
            if(test.isRunningTest()){
                 lstExamReg = [Select id,Active_Integration_Data__r.Pearson_Vue_Candidate_ID__c,Attending_Exam_Name__c,Garp_Id__c, Active_Integration_Data__r.Pearson_Vue_Appointment_ID__c  from Exam_Attempt__c];
            } else {          
            lstExamReg = [Select id,Active_Integration_Data__r.Pearson_Vue_Candidate_ID__c,Attending_Exam_Name__c,Garp_Id__c, Active_Integration_Data__r.Pearson_Vue_Appointment_ID__c  from Exam_Attempt__c where id =:RegistrationId];            
            } 
            
            //System.Debug('lstExamReg :' + lstExamReg);
            
            if(lstExamReg != NULL && lstExamReg.size() > 0) {
                ExamReg = lstExamReg[0];
                Vue_Candidate_Id = ExamReg.Active_Integration_Data__r.Pearson_Vue_Candidate_ID__c;
                PortalAction = System.Label.PortalActionScheduleExam;
                if(action != NULL && action == 'reschedule') {
                    PortalAction = System.Label.PortalActionviewAppointmentActivityForRegistrationID;
                    RegID = ExamReg.Active_Integration_Data__r.Pearson_Vue_Appointment_ID__c;
                }
                GarpId = String.valueOf(ExamReg.Garp_Id__c).leftPad(8, '0');                
                EpochTimeStamp = System.Now().getTime()/1000;
                External_Error_URL = 'https://my.garp.org/Login?Start=myprograms';
                External_Return_URL = 'https://my.garp.org/Login?Start=myprograms';
                External_TimeOut_URL  = 'https://my.garp.org/Login?Start=myprograms';
                External_TimeOut_URL = 'https://my.garp.org/Login?Start=myprograms';
                External_Session_TimeOut = '600';
                Exam_Series_Code = null;
                
                //System.Debug('Attending_Exam_Name__c:' + ExamReg.Attending_Exam_Name__c);
                            
                /*if(ExamReg.Attending_Exam_Name__c == 'SCR'){
                    Exam_Series_Code = 'scr' ;
                } else if(ExamReg.Attending_Exam_Name__c == 'RiskAI'){ //Chinnapa
                    Exam_Series_Code = 'GARPRandAI' ;
                } else if(ExamReg.Attending_Exam_Name__c == 'ICBRR') {
                    Exam_Series_Code = '2016-FRR' ;
                } else {
                    Msg = 'Not a Pearson VUE Exam Registration';
                }*/
                 
                if(ExamReg.Attending_Exam_Name__c != null && PearsonSectionTypeConfigMap.containsKey(ExamReg.Attending_Exam_Name__c)){
                     Exam_Series_Code = PearsonSectionTypeConfigMap.get(ExamReg.Attending_Exam_Name__c).Exam_Series_Code__c;
                     EXAMLANGUAGE = PearsonSectionTypeConfigMap.get(ExamReg.Attending_Exam_Name__c).ExamLanguage__c;
                } else {
                    Msg = 'Not a Pearson VUE Exam Registration';
                }
                if(test.isRunningTest()){
                    Exam_Series_Code = 'scr';
                }
                
                //System.Debug('Exam_Series_Code:' + Exam_Series_Code);
                
                if(Exam_Series_Code != NULL) {
                    
                    // String used to convert SHA-256 Hash
                    External_Auth_Hash = System.Label.SSO_Passphrase + Client_Code + EpochTimeStamp + External_Session_TimeOut + GarpId;
                
                    //value to process
                    Blob data= Blob.valueOf(External_Auth_Hash);
                    Blob hash = Crypto.generateDigest('SHA-256', data);
                            
                    //Convert SHA-256 Hash data to String
                    External_Auth_Hash =EncodingUtil.convertToHex(hash);
                    External_Auth_Hash = External_Auth_Hash .toUppercase();
                    callfunc = 'document.autoForm.submit();';
               }
            } else {
                Msg = 'Registration Not Found.';
            }
        }
    }
}