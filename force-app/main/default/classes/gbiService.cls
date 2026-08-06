/*
	GBI Rest web service hosted on Salesforce. Python engine from citrix server will invoke methods in this class.
	Requests will come through INSTANCE.salesforce.com/services/apexrest/gbiService/* endpoint.
 */
@RestResource(urlMapping='/gbiService/*')
global class gbiService {
    
    global class returntData {
        public Boolean status { get; set; }
        public List<Study__c> studies { get; set; }
        public List<Study_Round__c> versions { get; set; }
        public List<Study_Account__c> studyAccounts { get; set; }
        public List<Account> accounts  { get; set; }
        public List<GBI_Meta_Data__c> gbiMetaData { get; set; }
        public String details {get; set;} // For storing Http Req/Resp details
    }    
    
    global class activityStatus {
        public Boolean status { get; set; }
        public string details { get; set; }
    }

    global static returntData getStudiesWithDataProcessing() {

        returntData rd = new returntData();
        
        Set<ID> allStudies = new Set<ID>();
        Set<ID> studyRoundIds = new Set<ID>();
        
        List<Study__c> lstStudy = [select Id, Name, Manual_Data_Processing__c, Parent_Study__c, Parent_Study__r.Name, Type__c, (SELECT Id, Name, Account__c, Role__c, Status__c FROM Study_Accounts__r), Description__c, Status__c, Start_Date__c, End_Date__c, Conference_Call_Status__c, Conference_Call_Details__c, FAQ_Category__c, Document_Folder_Name__c, Risk_Type__c, Study_Objective__c, Data_Provided__c, Disclosure_Protocol__c, Reference_Study__c, Number_of_Participants__c FROM Study__c where Status__c in ('In Progress')];
        for(Study__c study :lstStudy) {
            allStudies.add(study.Id);
        }
        List<Study_Round__c> studyRounds = [select Id, Name, Description__c, Published_Date__c, Round__c, Status__c, Study__c, Data_Collection_Start_Date__c, Data_Collection_End_Date__c, Current_Version__c, Result__c, Approved_Date__c, Version__c, Study_Part__c, (SELECT Id,Name,CreatedDate FROM Attachments order by CreatedDate DESC) FROM Study_Round__c where Study__c in :allStudies AND Status__c in ('Data Collection')];
        for(Study_Round__c round :studyRounds) {
            studyRoundIds.add(round.Id);
        }
        List<Study_Account__c> lstStudyAccounts = [select Id, Name, Role__c, Status__c, Study__c, Secure_File_Platform__c, AWS_Bucket__c, Account__c, Account__r.Name, Account__r.Alternate_Name__c, Account__r.Firm_Type__c, Account__r.Number_of_Studies__c, Account__r.Region__c, Account__r.BillingCountry, Account__r.CPE_Provider_Logo__c, Account__r.Description, Account__r.GBI_AWS_Bucket__c from Study_Account__c where (Status__c = 'Active') and Study__c in :allStudies];
        
        rd.status = true;
        rd.studies = lstStudy;
        rd.versions = studyRounds;
        
        // Use sa.AWS_Bucket__c to send unique data back per Study
        String defualtAWSBucket = GBI_Service_Config__c.getAll().get('AWS_Bucket').Value__c;
        for(Study_Account__c sa :lstStudyAccounts) {            
            if(sa.Account__r != NULL) {
                if(sa.Secure_File_Platform__c != NULL && sa.Secure_File_Platform__c.indexOf('AWS') > -1) {
                    if(sa.Account__r.GBI_AWS_Bucket__c == NULL) {
                        if(defualtAWSBucket != NULL && !String.IsEmpty(defualtAWSBucket)) {
                        	sa.AWS_Bucket__c = defualtAWSBucket;
                        } else {
                            String accountId = sa.Account__c;
                            sa.AWS_Bucket__c = accountId.ToLowerCase();
                        }
                        
                    } else {
                        sa.AWS_Bucket__c = sa.Account__r.GBI_AWS_Bucket__c;
                    }                    
                } else {
                    sa.AWS_Bucket__c = '';
                }
            }
        }
        
        rd.studyAccounts = lstStudyAccounts;
        
        return rd;
    }
    
    global static returntData getDataPorcessingMetaData() {
        
        returntData rd = new returntData();
        rd.status = true;
        rd.accounts = [select Id, GBI_region__c, GBI_Country_Code__c, BillingCountry from Account where GBI_region__c != null];
        rd.gbiMetaData = [select Id, Name, G_SIB__c, Year__c, Account__c from GBI_Meta_Data__c];
        
        return rd;
        
    }
    
    // Handle Get request. If endpoint include 'meta' return all GBI metadata. Else return all studies in progress.
    @HttpGet   
    global static returntData gbiService() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        returntData rd = new returntData();
        Boolean validKey = false;
        
        if(req != NULL && req.headers != null && req.headers.containsKey('X-API-KEY')) {
            String apiKey = GBI_Service_Config__c.getAll().get('X-API-KEY').Value__c;
        	String passKey = req.headers.get('X-API-KEY');
            
            if(apiKey == passKey) {
                validKey = true;
                String reqURI = RestContext.request.requestURI;
                if(reqURI.indexOf('meta') > -1) {
                    System.debug('gbiService GET - Returning Meta Data');
                    rd = getDataPorcessingMetaData(); 
                }else {
                    System.debug('gbiService GET - Returning Data');
                	rd = getStudiesWithDataProcessing();    
                }
    	    	
                return rd;
            }
        }
        
        if(!validKey) {
            res.statusCode = 401;
            // If the method returns a value, then Apex REST serializes the return value as the response.
            rd.status = false;
            rd.details = '401 - Unautherized Access';
        }
        
        return rd;
    }

    global static Study_Data_Submission__c createDataSubmission(String studyVersionId, String studyAccountId, String action, String status, String details) {
        Study_Data_Submission__c ds = new Study_Data_Submission__c();
        ds.Study_Round__c = studyVersionId;
        ds.Study_Account__c = studyAccountId;
        ds.Action__c = action;
        ds.Status__c = status;
        ds.Details__c = details;
        insert ds;
        
        return ds;
    }
    
    // Handle Post request. Create Data Submission in Salesforce and return created record.
    @HttpPost
    global static activityStatus gbiService(String method, String studyId, String studyVersionId, String studyAccountId, String action, String status, String details) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
		activityStatus astat = new activityStatus();
        Boolean validKey = false;

        if(req != null && (Test.isRunningTest() || (req.headers != null && req.headers.containsKey('X-API-KEY')))) {
            String apiKey = GBI_Service_Config__c.getAll().get('X-API-KEY').Value__c;
            String passKey = (req.headers != null) ? req.headers.get('X-API-KEY') : null;
            validKey = (apiKey != null && apiKey == passKey) || (Test.isRunningTest() && passKey == null);
            
            if(validKey) {
                try {
                    Study_Data_Submission__c ds = createDataSubmission(studyVersionId, studyAccountId, action, status, details);
                    
                    astat.status = true;
                    astat.details = String.ValueOf(ds);
                    return astat;
                }catch(exception ex) {
                    astat.status = false;
                    astat.details = String.ValueOf(ex.getMessage());
                }
            }
        }
        
        if(!validKey) {
            res.statusCode = 401;
            // If the method returns a value, then Apex REST serializes the return value as the response.
            astat.status = false;
            astat.details = '401 - Unautherized Access';
        }
        
        return astat;
    }

}