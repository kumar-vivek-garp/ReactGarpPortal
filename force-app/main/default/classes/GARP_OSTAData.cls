public class GARP_OSTAData { 
    
    public class RequestWrapper { 
        
        @InvocableVariable(label='reqtype' description='Quarterly/Exam batch parameter')
        public String reqtype;
        
        @InvocableVariable(label='exammonth' description='exammonth batch parameter')
        public String exammonth;
        
        @InvocableVariable(label='examyear' description='examyear batch parameter')
        public String examyear;
    }
    
    @InvocableMethod(label='Call Osta Exam Registration' description='Call Osta Exam Registration Data Batch.')
    public static List<ResponseWrapper> CallOstaExamRegistration(List<RequestWrapper> requestList) { 
        ResponseWrapper response = new ResponseWrapper();
        RequestWrapper input = requestList[0]; 
         List<AsyncApexJob> jobs = [
            SELECT Id, Status
            FROM AsyncApexJob
            WHERE JobType = 'BatchApex'
              AND ApexClass.Name = 'OstaExamRegistrationDataBatch'
              AND Status IN ('Processing','Preparing','Queued','Holding')
            LIMIT 1
        ];
        if(!jobs.isEmpty()){
            response.resmessage = 'Batch is already Processing, we will notify you once job is completed';
            return new List<ResponseWrapper>{ response };
        }
        
        Boolean allEmpty =  String.isBlank(input.reqtype) && String.isBlank(input.exammonth) &&  String.isBlank(input.examyear);
        if(allEmpty){
            response.resmessage = 'Please Select Options';
        }else{
            if(input.reqtype == 'quarterly'){
                input.exammonth = null;
                input.examyear = null;   
            }
            OstaExamRegistrationDataBatch batchJob = new OstaExamRegistrationDataBatch(input.reqtype,input.exammonth,input.examyear,'0015d00003kwFhJAAU');
            Id batchJobId = Database.executeBatch(batchJob, 200);
            String Exammsg = input.reqtype =='exam'?'Pre/Post Exam':input.reqtype;
            response.resmessage = 'Batch is Processing for '+Exammsg+ ' data. We will notify you by sending an email.' ;
        }
        return new List<ResponseWrapper>{ response };
    }
    
     public class ResponseWrapper {
        @InvocableVariable(label='resmessage')
        public String resmessage;
    }
}