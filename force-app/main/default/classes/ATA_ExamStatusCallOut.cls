public class ATA_ExamStatusCallOut implements Queueable,Database.AllowsCallouts {
    public static String algorithmName = 'RSA';
    public static String signtype = 'SHA1'; 
    public static String todaytimestamp = system.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
    public static Integer status = 2; 
    public String BatchCode;
    
    public ATA_ExamStatusCallOut(String BCode){ 
        this.BatchCode = BCode;
    }
    
    public void execute(QueueableContext context){
        try{ 
            system.debug('BatchCode ::>>   '+BatchCode);
            ATA_Scheduling_Interface__mdt ATASetup = ATAPSIUtilClass.getATASchedulingInterface_mdt(); 
            // Decode the key from base64 to binary
            Blob privateKey = EncodingUtil.base64Decode(ATASetup.Private_Key__c.trim());
            String reqendpoint = ATASetup.EndPoint__c;   
            String resStatus;
            Api_Transaction__c  apirsp = new Api_Transaction__c(); 
            ATArequestResponse reqs = new ATArequestResponse();
            ATA_RequestClass requestbody = new ATA_RequestClass();
            requestbody.app_id = ATASetup.App_Id__c;
            requestbody.sign_type = signtype;
            requestbody.timestamp = todaytimestamp;
            ATA_RequestClass.Biz_content bizcontent = new ATA_RequestClass.Biz_content();
            bizcontent.batch_no =  BatchCode;
            system.debug(reqendpoint); 
            requestbody.biz_content = JSON.serialize(bizcontent);
            String  eventdata =  requestbody.biz_content;
            eventdata = eventdata.replace('\\"', '"');
            eventdata = eventdata.replace('"{', '{');
            eventdata = eventdata.replace('}"', '}');
            String datareq = 'app_id='+requestbody.app_id;
            datareq += '&biz_content='+eventdata;
            datareq += '&sign_type='+requestbody.sign_type;
            datareq += '&timestamp='+requestbody.timestamp;
            String body = '';
            Blob input = Blob.valueOf(datareq);
            Blob signatureBlob = Crypto.sign(algorithmName, input, privateKey);
            String signature =  EncodingUtil.base64Encode(signatureBlob);              
            requestbody.sign = signature;
            body = JSON.serialize(requestbody);
            system.debug('body  ::>>    '+body);
            
            try{
                reqs = httpCallout(reqendpoint, body,'POST');
                resStatus = ATAPSIUtilClass.getATAstatus(reqs.Response.getBody()); 
            	system.debug('resStatus  ::>>    '+resStatus);
                ATA_ExamStatusWrapper esw = ATA_ExamStatusWrapper.parse(reqs.Response.getBody());
            	system.debug('esw  ::>>    '+esw);
                publishPlatformEvent(esw,BatchCode);
            }catch(Exception e){
                apirsp.Name += ' Exception';
                apirsp.Integration_Data__c = 'BatchCode';  
                apirsp.Error__c = e.getMessage(); 
                apirsp.Response_Code__c = '502';
            } 
            
            
        }catch(Exception ex){
            system.debug('Error :'+ex.getMessage());
            system.debug('Error :'+ex.getLineNumber());
        }
    }
    
    public static void publishPlatformEvent(ATA_ExamStatusWrapper esw, String BatchNo){
        system.debug('esw  ::>>    '+esw);
        system.debug('BatchNo  ::>>    '+BatchNo);
        List<ATA_Exam_Status__e> platformEventList = new List<ATA_Exam_Status__e>();
        for(ATA_ExamStatusWrapper.Biz_content bc : esw.biz_content){
            system.debug('esw  ::>>    '+esw);
            ATA_Exam_Status__e evt = new ATA_Exam_Status__e();
            evt.cert_id__c = bc.cert_id;
            evt.exam_cert_no__c = bc.exam_cert_no;
            evt.exam_status__c = bc.exam_status;
            evt.subject_code__c = bc.subject_code;
            evt.batch_no__c = BatchNo;
            platformEventList.add(evt);
        }
        system.debug('platformEventList  ::>>    '+platformEventList);
        if(!platformEventList.isEmpty()){
            EventBus.publish(platformEventList);
        }
    }
    
    public static ATArequestResponse httpCallout(String Endpoint,String reqBody,String reqType){
        ATArequestResponse reqs = new ATArequestResponse(); 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint); 
        req.setheader('content-type','application/json');
        req.setMethod(reqType);
        req.setBody(reqBody);
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        if(!test.isRunningTest()){
            res = http.send(req);
        }else{
            String JsonString = '{\"app_id\":\"51451438f33311eaab9b0242ac110005\",\"biz_content\":[{\"cert_id\":\"2285696\",\"exam_cert_no\":\"2285696\",\"exam_status\":\"miss\",\"subject_code\":\"FRM01\"}],\"resp_msg\":\"SUCCESS\",\"resp_status\":\"0000\",\"sign\":\"B54IumfdKy92qPYoxZfHIP8PdJA\",\"sign_type\":\"SHA1\",\"timestamp\":\"2023-08-22T09:28:23+08:00\"}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JsonString);
            res.setStatusCode(200);
        }
        System.debug(res.getBody());
        reqs.Request = req;
        reqs.Response = res;
        return reqs;
    } 
    
    public class ATArequestResponse{
        public HttpRequest Request;
        public HTTPResponse Response;
        public ATArequestResponse(){
            Request = new HttpRequest();
            Response = new HTTPResponse();
        }
    }
    
}