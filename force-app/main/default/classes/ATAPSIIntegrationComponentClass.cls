public class ATAPSIIntegrationComponentClass {
    @AuraEnabled
    public static Exam_Attempt__c getExamAttempt(String recId){
        Exam_Attempt__c examatt = new Exam_Attempt__c();
        List<Exam_Attempt__c> examattList = [Select Id,ATA_region_code__c,Exam_Part__r.ATA_Batch_Code__c,Outbound_Type__c,Integration_Type__c,ATA_region_name__c,ATA_Cert_type__c,Active_Integration_Data__r.ATA_Inbound_Reg_Code__c,ATA_Cert_id__c,Name,
                                             Exam_Site_Name__c,ATA_subject_code__c,Garp_Id__c,Section__c,Site_Code__c,Defered__c,Exam_Date__c,
                                             RecordType.Name from Exam_Attempt__c where RPT_Exam_Mode__c ='CBT' and Id =:recId];
        if(examattList.size()>0){
            examatt = examattList[0];
        }
        return examatt;
    }
    
    @AuraEnabled
    public static List<Exam_Attempt__c> getExamAttemptList(String recType){
        List<Exam_Attempt__c> examattList = new List<Exam_Attempt__c>();
        Id RecTypeId; 
        String query='Select Id,ATA_region_code__c,ATA_Cert_type__c,Active_Integration_Data__r.ATA_Inbound_Reg_Code__c,ATA_Cert_id__c,Name,Exam_Site_Name__c,ATA_subject_code__c,Garp_Id__c,Section__c,Site_Code__c,Defered__c,Exam_Date__c,RecordType.Name from Exam_Attempt__c where (Section__c =\'ERP Exam Part I\' OR Section__c =\'ERP Exam Part II\') and Cancelled__c = false AND Active_Integration_Data__c != null';
        if(recType == 'ATA'){
            query += ' AND ATA_region_code__c != null AND ATA_region_name__c != null AND ATA_Cert_type__c != null AND ATA_Cert_id__c != null';
        }else if(recType == 'PSI'){
            query += ' AND ATA_region_code__c = null AND ATA_region_name__c = null';
        } 
        query += ' Limit 10000';
        examattList = database.query(query);
        //system.debug(examattList.size());
        return examattList;
    }    
    
    
    @AuraEnabled
    public Static List<PSIGetResponseParserClass> getPSIeligiblitiesCandidateId(Exam_Attempt__c exaAttmt){
        List<PSIGetResponseParserClass> psiResponseParserList = new List<PSIGetResponseParserClass>();
        String retval='';
        String accessToken;
        String EndPoint;
        try{
            PSI_Eligibility__mdt psimtd = new PSI_Eligibility__mdt();
            List<PSI_Eligibility__mdt>  PSIEligibility = [Select id,Account_Code__c,Get_Eligibility_URL__c,Client_Secret__c,Add_Eligibility_URL__c,Update_Eligibility_URL__c,Cancel_Eligibility_URL__c,EndPoint__c,Password__c,PSI_Token_URL__c,User_Name__c From PSI_Eligibility__mdt where DeveloperName ='PSI_Eligibility_Setting'];
            if(!PSIEligibility.isEmpty()){
                psimtd = PSIEligibility[0];
                EndPoint = psimtd.Get_Eligibility_URL__c;
                //system.debug(EndPoint);
                EndPoint = EndPoint.replace('acctCode',psimtd.Account_Code__c); 
                EndPoint = EndPoint.replace('candidateId',exaAttmt.Garp_Id__c);
                String testcode;
                if(exaAttmt.Section__c =='ERP Exam Part I')  
                    testcode = 'ERP1';
                if(exaAttmt.Section__c =='ERP Exam Part II')
                    testcode = 'ERP2';
                if(exaAttmt.Section__c =='FRM Part 1')   
                    testcode = 'FRM1';
                if(exaAttmt.Section__c =='FRM Part 2')
                   testcode = 'FRM2'; 
                EndPoint = EndPoint.replace('testCode',testcode);
            }
            //system.debug('EndPoint: '+EndPoint);
            Httprequest req = new HttpRequest();    
            req.setMethod('POST');
            req.setHeader('auth',psimtd.Client_Secret__c);
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setBody('grant_type=password' +  
                        '&username=' + psimtd.User_Name__c +
                        '&password=' + psimtd.Password__c
                       );    
            req.setEndpoint(psimtd.PSI_Token_URL__c);        
            Http http = new Http();
            HttpResponse res= http.send(req);  
            //system.debug('req:'+req);            
            system.debug('body:'+res.getBody());        
            JSONParser parser = JSON.createParser(res.getBody());
            //system.debug('parser:'+parser);      
            while (parser.nextToken() != null) {
                //system.debug('parser:'+parser.nextToken());
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                    String fieldName = parser.getText();
                    parser.nextToken();
                    //System.debug('fieldName'+fieldName);
                    if (fieldName == 'access_token') {
                        accessToken = parser.getText();
                    }
                }
            }   
            if(accessToken != null){
                req = new HttpRequest();
                req.setEndpoint(EndPoint);
                req.setHeader('token',accessToken);
                req.setheader('content-type','application/json');
                req.setHeader('auth',psimtd.Client_Secret__c);
                req.setMethod('POST');  
                http = new Http();
                HTTPResponse res1 = http.send(req); 
                retval = res1.getBody(); 
                List<PSIGetResponseParserClass> psiParser =  PSIGetResponseParserClass.parse(retval); 
                psiResponseParserList =  psiParser;               
            } 
            return psiResponseParserList;
        }catch(Exception ex){
            system.debug(ex.getMessage()+' '+ex.getLineNumber()); 
            return null;
        } 
    }
    
    //QueryExamRegistation
    @AuraEnabled
    public Static List<ATAGetResponseParserClass.Biz_content> ATAQueryExamRegistation(Exam_Attempt__c exaAttmt,String SelIntegrationType){
        try{
            Map<String,ATA_Cert_Type_List__c> ATACertTypeMap = ATAPSIUtilClass.getATACertTypeList();
            List<ATAGetResponseParserClass.Biz_content> parseBiz_contentList = new  List<ATAGetResponseParserClass.Biz_content>();
            ATA_Scheduling_Interface__mdt atamtd = new ATA_Scheduling_Interface__mdt();
            List<ATA_Scheduling_Interface__mdt>  ATASetup = [Select Id,Batch_No__c,App_Id__c,EndPoint__c,Private_Key__c From ATA_Scheduling_Interface__mdt where DeveloperName ='ATA_Scheduling_Interface_Setting'];
            if(!ATASetup.isEmpty()){
                atamtd = ATASetup[0];  
            }
            Blob privateKey = EncodingUtil.base64Decode(atamtd.Private_Key__c.trim());
            ATA_RequestClass requestbody =new ATA_RequestClass();
            requestbody.app_id = atamtd.App_Id__c;
            requestbody.sign_type = 'SHA1';
            requestbody.timestamp = system.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
            ATA_RequestClass.Biz_content bizcontent = new ATA_RequestClass.Biz_content();
            bizcontent.batch_no = exaAttmt.Exam_Part__r.ATA_Batch_Code__c;
            bizcontent.cert_id = exaAttmt.Garp_Id__c;
            if(ATACertTypeMap.containsKey(exaAttmt.ATA_Cert_type__c))
           // bizcontent.cert_type = ATACertTypeMap.get(exaAttmt.ATA_Cert_type__c).Conversion_Id__c;
            bizcontent.cert_type = '5';
            bizcontent.reg_code = exaAttmt.Garp_Id__c;
            
            
            if(SelIntegrationType == 'CheckReservation'){
                bizcontent.subject_code = exaAttmt.ATA_subject_code__c;
            } 
            
            requestbody.biz_content =JSON.serialize(bizcontent);
            //system.debug(requestbody);
            String  eventdata =  requestbody.biz_content;
            eventdata = eventdata.replace('\\"', '"');
            eventdata = eventdata.replace('"{', '{');
            eventdata = eventdata.replace('}"', '}');
            String datareq = 'app_id='+requestbody.app_id;
            datareq += '&biz_content='+eventdata;
            datareq += '&sign_type='+requestbody.sign_type;
            datareq += '&timestamp='+requestbody.timestamp;
            Blob input = Blob.valueOf(datareq);
            Blob signatureBlob = Crypto.sign('RSA', input, privateKey);
            String signature =  EncodingUtil.base64Encode(signatureBlob);
            requestbody.sign = signature;
            String  body = JSON.serialize(requestbody); 
            String endpoint = atamtd.EndPoint__c+SelIntegrationType; 
            //system.debug(endpoint);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setheader('content-type','application/json');
            req.setMethod('POST'); 
            req.setbody(body);
            Http http = new Http();
            HTTPResponse response = http.send(req); 
            //system.debug(response.getBody());
            ATAGetResponseParserClass ataparse = ATAGetResponseParserClass.parse(response.getBody());
            String jsonbizres = ataparse.biz_content; 
            if(jsonbizres != null && jsonbizres != ''){
                jsonbizres = jsonbizres.replace('\\"', '"');
                jsonbizres = jsonbizres.replace('"{', '{');
                jsonbizres = jsonbizres.replace('}"', '}');
                parseBiz_contentList  = (List<ATAGetResponseParserClass.Biz_content>)System.JSON.deserialize(jsonbizres,List<ATAGetResponseParserClass.Biz_content>.class);
            }
            return  parseBiz_contentList; 
            
        }catch(Exception ex){
            system.debug(ex.getMessage()+' '+ex.getLinenumber());  
            
        }
        return null;
    }
    
    public static string stripJsonNulls(string JsonString)
    {
        
        if(JsonString != null)  
        {
            JsonString = JsonString.replaceAll('\"[^\"]*\":null',''); //basic removeal of null values
            JsonString = JsonString.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
            JsonString = JsonString.replace('{,', '{'); //prevent opening brace from having a comma after it
            JsonString = JsonString.replace(',}', '}'); //prevent closing brace from having a comma before it
            JsonString = JsonString.replace('[,', '['); //prevent opening bracket from having a comma after it
            JsonString = JsonString.replace(',]', ']'); //prevent closing bracket from having a comma before it
        }
        
        return JsonString;
    }
}