global class benchPrepAccess_Batch implements Database.Batchable<sobject>{
    
    private string recordId;
    private string examType;
    private string examProgramType;
	/*examSection: Need to send as benchPrep Product Code
	inputRecordId: inputrecord
	*/
    public benchPrepAccess_Batch(string examSection,string inputRecordId,String programType){
        this.recordId = inputRecordId;
        this.examType = examSection;
        this.examProgramType = programType;
    }

    /*examSection: Need to send as benchPrep Product Code*/
    /*programType: set only value for when Exam Parts not avalible*/
    public benchPrepAccess_Batch(string examSection,String programType){
        this.examType = examSection;
        this.examProgramType = programType;
    }
    
    global database.querylocator start(Database.BatchableContext bc){
        string query;
        string examPartId = Failed_Exams_Setup__mdt.getInstance('benchPrep').Exam_Admin_For_Query__c;
        if(Test.isrunningtest()){            
            query = 'Select Id,Member__r.AccountId,Section__c,Result__c,Opportunity__c,Integration_Data_Exam_Location_Country__c,Active_Integration_Data__r.Exam_Location_Country__c,Exam_Site__r.Name from Exam_Attempt__c where Result__c != null and cancelled__c != true';
        }else if(examProgramType != null && examProgramType != ''){
            query = 'Select Id,Member__r.AccountId,Section__c,Result__c,Opportunity__c,Garp_Id__c,Member__c from Exam_Attempt__c where Result__c != null and Candidate_Commitment__r.RecordType.Name =: examProgramType and cancelled__c != true';
        }else {
            query = 'Select Id,Member__r.AccountId,Section__c,Result__c,Opportunity__c,Garp_Id__c,Member__c from Exam_Attempt__c where Result__c != null and Exam_Part__c =: examPartId and cancelled__c != true';
        }
        if(recordId != null){
            query += ' and id =: recordId';
        }
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc,List<Exam_Attempt__c> scope){

        Set<Id> contactIds = new Set<Id>();
        List<User> usersToUpdate = new List<User>();
        
        for(Exam_Attempt__c ea : scope){
            if(ea.Member__c != null){
                contactIds.add(ea.Member__c);
            }
        }
        
        List<User> userList = [select Id, Bench_Prep_SSO_Attribute__c,ContactId,Community_Contact_GARP_ID__c from User where ContactId in :contactIds];
        for(User u :userList) {
            Map<String,BenchPrepClass.benchPrepAttr> courseList = new Map<String,BenchPrepClass.benchPrepAttr>();
            if(String.isNotBlank(u.Bench_Prep_SSO_Attribute__c)){
                /*if(examType == 'SCR'){
                    courseList = BenchPrepClass.removeAccess(u,new Set<String>{'SCRBP'});
                }else if(examType == 'FRM Part 1'){
                    courseList = BenchPrepClass.removeAccess(u,new Set<String>{'FRMBP'});
                }//chinnapa
                else if(examType == 'RAI'){
                    courseList = BenchPrepClass.removeAccess(u,new Set<String>{'RAIBP'});
                }*/
				if(examType != null){
                     courseList = BenchPrepClass.removeAccess(u,new Set<String>{examType});
                }
                
                if(!courseList.isEmpty()){
                    u.Bench_Prep_SSO_Attribute__c =  JSON.serialize(courseList.values());
                }else{
                    u.Bench_Prep_SSO_Attribute__c = '';
                }
                usersToUpdate.add(u);
            }
        }
        
        if(!Test.isRunningTest() && !usersToUpdate.isEmpty()){
            update usersToUpdate;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}