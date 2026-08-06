@RestResource(urlMapping='/awsappflow/*')

global class GARP_AWSAppFlow_Webhook {
    
    public class awsEventDetail {
        public String flowname;
        public String status;
        public String numofrecordfailures;
    }
    
    public class awsEvent {
        public String id;
        public String detailtype;
        public awsEventDetail detail;
    }
    
    @HttpPost
    global static void webhook() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
                
        String rawJson;
        if(Test.isRunningTest()){
            rawJson = '{"version":"0","id":"f41d5b03-8825-1e44-1aac-b73915113b3f","detail-type":"AppFlow End Flow Run Report","source":"aws.appflow","account":"024791684851","time":"2023-10-05T23:35:51Z","region":"us-east-1","resources":["73d474d921557322ea58e8810463ab3c"],"detail":{"flow-name":"HubSpotContactDataSync","created-by":"arn:aws:iam::024791684851:user/ChintanPatel","flow-arn":"arn:aws:appflow:us-east-1:024791684851:flow/HubSpotContactDataSync","source":"CUSTOMCONNECTOR/Hubspot","destination":"S3","source-object":"contact","destination-object":"s3://garphubspottosnowflake","trigger-type":"ONDEMAND","num-of-records-processed":"1486339","execution-id":"b0b87c9c-d330-4ff2-81b3-89f6f517677c","num-of-records-filtered":"0","start-time":"2023-10-05T20:59:16.378Z[UTC]","num-of-documents-processed":"0","end-time":"2023-10-05T23:35:51.204Z[UTC]","num-of-record-failures":"0","data-processed":"3056989160","status":"Execution Successful"}}';
            res = new RestResponse();
        } else {
            rawJson = req.requestBody.toString();
        }
        GARP_Common.debugLog('GARP_AWSAppFlow_Webhook','webhook','rawJson',rawJson);
        
        Integration_Log__c il = new Integration_Log__c(
            New_Record__c = rawJson,
            Integration_Type__c = 'AWS'
        );
        GARP_Common.debugLog('GARP_AWSAppFlow_Webhook','webhook','insert log',il);
        
        
        // Format JSON
        rawJson = rawJson.replace('detail-type','detailtype');
        rawJson = rawJson.replace('flow-name','flowname');
        rawJson = rawJson.replace('num-of-record-failures','numofrecordfailures');
        
        awsEvent awsEvent = (awsEvent)JSON.deserialize(rawJson, awsEvent.class);
        GARP_Common.debugLog('GARP_AWSAppFlow_Webhook','webhook','awsEvent',awsEvent);        
        
        if(awsEvent != NULL && awsEvent.detail != NULL && awsEvent.detail.flowname != NULL) {
            Map<String, GARP_AWSAppFlow_To_Rivers__c> settings = GARP_AWSAppFlow_To_Rivers__c.getAll();
            GARP_Common.debugLog('GARP_AWSAppFlow_Webhook','webhook','settings',settings);
            
            if(!settings.IsEmpty()) {
                GARP_AWSAppFlow_To_Rivers__c awsFlowSetting = settings.get(awsEvent.detail.flowname);
                GARP_Common.debugLog('GARP_AWSAppFlow_Webhook','webhook','awsFlowSetting',awsFlowSetting);
                
                if(awsFlowSetting != NULL && awsFlowSetting.RiverID__c != NULL) {
                    GARP_Common.apiReturnInfo ret = GARP_RiveryClass.runRiver(awsFlowSetting.RiverID__c);
                    GARP_Common.debugLog('GARP_AWSAppFlow_Webhook','webhook','runRiver',ret);
                }   
            }
        }
        insert il;
    }
}