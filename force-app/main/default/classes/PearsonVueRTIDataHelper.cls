public class PearsonVueRTIDataHelper {
    @future(callout=true) 
    public static void PearsonVueDatacallout(Set<Id> pearsonId){ 
        PearsonVueDate(pearsonId);
    } 
     public static Map<String,Pearson_Exam_Series_Configuration__mdt> PearsonExamTypeConfigMap = IntegrationsMtdUtil.getByExamTypeConfiguration();
    public Static void PearsonVueDate(Set<Id> pearsonId){
        try{
            Id SCRRecId = RecordTypeHelper.getRecordTypeIdFromSchema('Exam_Attempt__c','SCR');//Schema.SObjectType.Exam_Attempt__c.getRecordTypeInfosByDeveloperName().get('SCR').getRecordTypeId();
            Id RiskAIRecId = RecordTypeHelper.getRecordTypeIdFromSchema('Exam_Attempt__c','RiskAI');//Schema.SObjectType.Exam_Attempt__c.getRecordTypeInfosByDeveloperName().get('RiskAI').getRecordTypeId();  //Chinnapa  
            Id RAIJRecId = RecordTypeHelper.getRecordTypeIdFromSchema('Exam_Attempt__c','RAIJ');//Schema.SObjectType.Exam_Attempt__c.getRecordTypeInfosByDeveloperName().get('RAIJ').getRecordTypeId();         
            Map<Id,Exam_Attempt__c> UpdateExamAttempt = new Map<Id,Exam_Attempt__c>(); 
            List<Integration_Data__c> integrationDataList =[
                SELECT Id,Is_Active__c,Middle_Name__c,Exam_Registrations__r.RecordTypeId,
                Call_out_Status__c,Outbound_Event_Types__c,
                Contract__r.status, Name, Is_Canddiate_Info_Changed__c,Address_1__c, Address_2__c, Address_Type__c, Assesment_Type__c, Authorization_Type__c, 
                city__c, country__c, eligibilityApptDateFirst__c, eligibilityApptDateLast__c, Email__c, Exam_Registrations__c, Exam_Status__c, Exam_Type__c, 
                First_Name__c, Garp_Id__c,Exam_Registrations__r.Pearson_Accommodation_Type__c,Exam_Registrations__r.Pearson_Accommodation_Type_Status__c,Last_Name__c, 
                Last_updated_Time__c, Location_Address__c, Location_Name__c, 
                Pearson_Vue_Authorization_ID__c,
                Pearson_Vue_Candidate_ID__c,
                Phone_Country_Code__c,
                phone_Number__c,
                Postal_Code__c,Contract__r.EndDate,Contract__r.SCR_Computed_Expiration_Date__c,Contract__r.RecordTypeId,
                Contract__c,Exam_Registrations__r.Second_Attempt_Pearson__c,Re_Run__c, 
                Registration_Status__c,Results__c,Scheduled_Date_Time__c,state__c 
                FROM Integration_Data__c 
                WHERE Id IN: pearsonId
            ];
            
            Map<String,Pearson_vue__mdt> PearsonRealTimeImportMap = new Map<String,Pearson_vue__mdt>();
            for(Pearson_vue__mdt pearson:[Select Id,Client_Id__c,DeveloperName,Endpoint__c,Password__c,Username__c,Certificate__c from Pearson_vue__mdt]){
                PearsonRealTimeImportMap.put(pearson.DeveloperName,pearson);
            }
            List<Api_Transaction__c> apirspList = new List<Api_Transaction__c>();
            List<Contract> contractList = new List<Contract>(); 
            Set<Id> integrationId = new Set<Id>();
            for(Integration_Data__c integrationData: integrationDataList){
                requestResponse reqs = new requestResponse();
                Api_Transaction__c apirsp = new Api_Transaction__c();
                
                Map<String,String> returnmessage = new Map<String,String>();
                /*if(integrationData.Contract__r.SCR_End_Date__c != null && integrationData.Contract__r.SCR_Start_Date__c != null){
                    integrationData.eligibilityApptDateFirst__c = ScrContractTriggerHelper.datetimeformat(integrationData.Contract__r.SCR_Start_Date__c);  
                    integrationData.eligibilityApptDateLast__c = ScrContractTriggerHelper.datetimeformat(integrationData.Contract__r.SCR_End_Date__c);
                }*/
                if(integrationData.Authorization_Type__c == 'Add'){
                    integrationData.Pearson_Vue_Authorization_ID__c = null;
                }
                string XMLString =''; 
                if(integrationData.Pearson_Vue_Candidate_ID__c == null && integrationData.Authorization_Type__c == 'Add'){
                    reqs = httpCallout(PearsonRealTimeImportMap.get('pingdatabase'), integrationData);  
                    XMLString =reqs.Response.getBody(); 
                    returnmessage = getResponsemessage(XMLString,'pingdatabase');
                    apirsp = new Api_Transaction__c();
                    apirsp.Name = 'pingdatabase';
                    apirsp.Request_Body__c = reqs.Request.getBody(); 
                    apirsp.Body__c = reqs.Response.getBody();
                    apirsp.Response_Code__c = reqs.Response.getStatusCode()+'';  
                    apirsp.Error__c = returnmessage.get('isError'); 
                    apirsp.Integration_Data__c = integrationData.Id; 
                    apirspList.add(apirsp);
                    if(apirsp.Error__c != '' && apirsp.Error__c != null && returnmessage.get('isSuccess') != 'Accepted'){
                        integrationData.Call_out_Status__c = 'Error';
                    }else {
                        integrationData.Call_out_Status__c = 'Processed';
                        integrationData.Pearson_Operation_Type__c =null;
                        integrationData.Pearson_Event_Type__c=null;
                        integrationData.Pearson_Event_NotificationID__c=null;
                        integrationData.Pearson_Event_Time__c=null;
                        integrationData.Appointment_Duration__c=null;
                        integrationData.Pearson_Appointment_Source__c=null;
                        integrationData.Pearson_appointmentDisplayTimeZone__c=null;
                        integrationData.Pearson_AppointmenDisplayTimeZoneUtc__c=null;
                        integrationData.Pearson_CurrentUtcOffset__c=null;
                        integrationData.Pearson_vueOrderNo__c=null;
                        integrationData.ExamDelivered__c=false;
                        integrationData.Assesment_Type__c=null;
                        integrationData.Scheduled_Date_Time__c=null;
                        integrationData.Exam_Status__c=null;
                        integrationData.Location_Name__c=null;
                        integrationData.Pearson_vue_Test_CenterID__c=null;
                        integrationData.Location_Address__c=null;
                        integrationData.Exam_Location_Country__c=null;
                        integrationData.Exam_Location_City__c=null;
                        integrationData.Exam_Location_State__c=null;
                        integrationData.Exam_Location_Postal_Code__c=null;
                        
                    }
                } 
                if((returnmessage != null && returnmessage.get('isSuccess') == 'success' && integrationData.Pearson_Vue_Candidate_ID__c == null && integrationData.Authorization_Type__c == 'Add') || (integrationData.Is_Canddiate_Info_Changed__c == true || integrationData.Outbound_Event_Types__c.contains('CDD'))){
                    reqs = httpCallout(PearsonRealTimeImportMap.get('CDDservice'), integrationData);  
                    XMLString =reqs.Response.getBody(); 
                    returnmessage = getResponsemessage(XMLString,'CDDservice');
                    apirsp = new Api_Transaction__c();
                    apirsp.Name = 'CDDservice';
                    apirsp.Request_Body__c = reqs.Request.getBody(); 
                    apirsp.Body__c = reqs.Response.getBody();
                    apirsp.Response_Code__c = reqs.Response.getStatusCode()+'';  
                    apirsp.Error__c = returnmessage.get('isError');
                    apirsp.Integration_Data__c = integrationData.Id;
                    apirspList.add(apirsp);
                    if(apirsp.Error__c != '' && apirsp.Error__c != null && returnmessage.get('isSuccess') != 'Accepted'){
                        integrationData.Call_out_Status__c = 'Error';
                    }else{
                        integrationData.Call_out_Status__c = 'Processed';
                    }
                    integrationData.Pearson_Vue_Candidate_ID__c = returnmessage.get('candidateID');
                }      
                if(integrationData.Call_out_Status__c != 'Error' && integrationData.Outbound_Event_Types__c.contains('EAD') && (returnmessage.get('isSuccess') =='Accepted' || integrationData.Pearson_Vue_Candidate_ID__c != null || integrationData.Authorization_Type__c != 'Add')){
                    reqs = httpCallout(PearsonRealTimeImportMap.get('EADservice'), integrationData);  
                    XMLString =reqs.Response.getBody(); 
                    returnmessage = getResponsemessage(XMLString,'EADservice');
                    apirsp = new Api_Transaction__c();
                    apirsp.Name = 'EADservice';
                    apirsp.Request_Body__c = reqs.Request.getBody(); 
                    apirsp.Body__c = reqs.Response.getBody();
                    apirsp.Response_Code__c = reqs.Response.getStatusCode()+'';  
                    apirsp.Error__c = returnmessage.get('isError');
                    apirsp.Integration_Data__c = integrationData.Id;
                    apirspList.add(apirsp);
                    integrationData.Pearson_Vue_Authorization_ID__c  = returnmessage.get('authorizationID');
                    if(apirsp.Error__c != '' && apirsp.Error__c != null && returnmessage.get('isSuccess') != 'Accepted'){
                        integrationData.Call_out_Status__c = 'Error'; 
                    }else{
                        integrationData.Call_out_Status__c = 'Processed';
                    }
                } 
                integrationData.Is_Active__c = false;
                integrationData.Is_Canddiate_Info_Changed__c = false;
                integrationData.Re_Run__c = false;
                Exam_Attempt__c ea = new Exam_Attempt__c(); 
                if(integrationData.Call_out_Status__c == 'Processed'){
                    String prgstatus = integrationData.Contract__r.Status;
                    Id prrecid = integrationData.Contract__r.RecordTypeId;
                    integrationData.Is_Active__c = true; 
                    if(integrationData.Exam_Registrations__c != null){ 
                        ea.Active_Integration_Data__c = integrationData.Id; 
                    }
                    if(prgstatus == 'Activated') 
                        integrationData.Registration_Status__c = 'Active';
                    if(prgstatus == 'Expired')
                        integrationData.Registration_Status__c = 'Expired';
                    if(prgstatus == 'Canceled')
                        integrationData.Registration_Status__c = 'Canceled';
                    
                    
                    List<Exam_Registration_Window__c>  ExamRegistrationWindow = [Select id,Exam_Registration_Window_Close__c  From Exam_Registration_Window__c where Exam_Registration_Window_Open__c <=: integrationData.Contract__r.EndDate and Exam_Group__r.name like '%scr%' Order by Exam_Registration_Window_Close__c desc];
                    if(!ExamRegistrationWindow.isEmpty() || integrationData.Exam_Registrations__r.Second_Attempt_Pearson__c == true){
                        date dt;
                        if(ExamRegistrationWindow[0].Exam_Registration_Window_Close__c < integrationData.Contract__r.EndDate){
                            dt = ExamRegistrationWindow[0].Exam_Registration_Window_Close__c.addDays(-2);
                        }else{
                            dt = integrationData.Contract__r.EndDate.addDays(-2);
                        } 
                        Contract con = new Contract();
                        con.Id = integrationData.Contract__c;
                        con.Second_Attempt_FRR__c = false;
                        if(integrationData.Contract__r.SCR_Computed_Expiration_Date__c == null && (prrecid ==SCRRecId || prrecid == RiskAIRecId  || prrecid == RAIJRecId)) 
                            con.SCR_Computed_Expiration_Date__c = dt;
                        if(integrationData.Contract__r.SCR_Computed_Expiration_Date__c == null || integrationData.Exam_Registrations__r.Second_Attempt_Pearson__c == true)
                            contractList.add(con);
                    } 
                }else{
                    integrationId.add(integrationData.Contract__c);
                } 
                if(integrationData.Exam_Registrations__c != null){ 
                    ea.Id = integrationData.Exam_Registrations__c;
                    ea.Outbound_Type__c = '';
                    ea.Integration_Type__c = '';
                    ea.Second_Attempt_Pearson__c = false; 
                    ea.Outbound_Status__c = integrationData.Call_out_Status__c;
                    UpdateExamAttempt.put(ea.Id,ea);
                }
            }
            Map<Id,Integration_Data__c> OldAtiveDataList = new Map<Id,Integration_Data__c>();
            for(Integration_Data__c intgData:[Select Id,Is_Active__c,Contract__c from Integration_Data__c where Call_out_Status__c ='Processed' AND Contract__c In:integrationId Order By CreatedDate Desc]){
                if(!OldAtiveDataList.containsKey(intgData.Contract__c)){
                    intgData.Is_Active__c = true;
                    OldAtiveDataList.put(intgData.Contract__c,intgData);
                }   
            }
            if(!apirspList.isEmpty()){
                INSERT apirspList; 
            }
            
            if(!integrationDataList.isEmpty()){
                UPDATE integrationDataList; 
            }
            
            if(!UpdateExamAttempt.isEmpty()){
                UPDATE UpdateExamAttempt.values();
            }
            
            if(!OldAtiveDataList.isEmpty()){
                UPDATE OldAtiveDataList.values();
            }
            
            if(!contractList.isEmpty()){
                UPDATE contractList;
            }
        }catch(Exception ex){
            system.debug(ex.getMessage() +'&&&& >> '+ ex.getlinenumber());
        }
    }
    public static requestResponse httpCallout(Pearson_vue__mdt cusMtd, Integration_Data__c integrationData){
        requestResponse reqs = new requestResponse();
        String reqBody='';
        PearsonRTIRequest Pearsonrequest = new PearsonRTIRequest();
        PearsonRTIRequest.requestWrapper reqwrap= new PearsonRTIRequest.requestWrapper();
        reqwrap.integrationData = integrationData;
        reqwrap.Username = cusMtd.Username__c;
        reqwrap.Password = cusMtd.Password__c;
        if(integrationData.Exam_registrations__r.Pearson_Accommodation_Type__c != null && integrationData.Exam_registrations__r.Pearson_Accommodation_Type_Status__c == 'Approved' && cusMtd.DeveloperName == 'EADservice'){
            reqwrap.accommodationCode = getaccommodationCode(integrationData.Exam_registrations__r.Pearson_Accommodation_Type__c);
        }
        if(integrationData.Pearson_Vue_Authorization_ID__c != null)
            reqwrap.authorizationID = integer.valueof(integrationData.Pearson_Vue_Authorization_ID__c);
        if(cusMtd.Client_Id__c != null)
            reqwrap.clientID = integer.ValueOf(cusMtd.Client_Id__c);
        /*if(integrationData.Exam_Type__c =='SCR'){
            reqwrap.examSeriesCode = 'SCR'; 
        }else if(integrationData.Exam_Type__c =='GARPRandAI'){
            reqwrap.examSeriesCode = 'GARPRandAI'; 
        }else if(integrationData.Exam_Type__c =='FRR'){
            reqwrap.examSeriesCode = '2016-FRR'; 
        }*/
        
        if(PearsonExamTypeConfigMap.containsKey(integrationData.Exam_Type__c)){
             reqwrap.examSeriesCode = PearsonExamTypeConfigMap.get(integrationData.Exam_Type__c).Exam_Series_Code__c; 
        } 
        if(cusMtd.DeveloperName == 'pingdatabase'){
            reqBody = Pearsonrequest.pingdatabaseRequestXML(reqwrap); 
        }else if(cusMtd.DeveloperName == 'CDDservice'){
            reqBody = Pearsonrequest.CDDserviceRequestXML(reqwrap); 
        }else if(cusMtd.DeveloperName == 'EADservice'){
            reqBody = Pearsonrequest.EADserviceRequestXML(reqwrap); 
        }
        //system.debug(reqBody);
        reqBody = reqBody.replace('null','');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(cusMtd.Endpoint__c);
        req.setClientCertificateName(cusMtd.Certificate__c);
        req.setHeader('Content-Type','application/xml');
        req.setMethod('POST');
        req.setBody(reqBody);
       // system.debug(req);
        Http http = new Http();
        //system.debug('123');
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        reqs.Request = req;
        reqs.Response = res;
        return reqs;
    } 
    
    public class requestResponse{
        public HttpRequest Request;
        public HTTPResponse Response;
        public requestResponse(){
            Request = new HttpRequest();
            Response = new HTTPResponse();
        }
    }
    
    public static String getaccommodationCode(String accommodationType){
        String codeShort;
        List<Pearson_Accomodation_List__c> accomodationList = [Select TypeCodeShort__c,Name From Pearson_Accomodation_List__c where Name =:accommodationType];
        if(!accomodationList.isEmpty()){
            CodeShort = accomodationList[0].TypeCodeShort__c;
        }
        return CodeShort;
        
    }
    
    public static Map<String,String> getResponsemessage(String XMLString,String responseType){
        Map<String,String> returnmessage =new Map<String,String>(); 
        returnmessage.put('isSuccess','');
        returnmessage.put('isError','');
        returnmessage.put('candidateID',''); 
        returnmessage.put('clientCandidateID','');
        returnmessage.put('authorizationID','');
        try{
            
            String jsonsres = PearsonXmlParser.xmlToJson(XMLString); 
            
            JSONParser parser = JSON.createParser(jsonsres);
            Map<String,String> successErrorMap = new Map<String,String>();
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    if(parser.getText() == 'status'){
                        parser.nextToken(); 
                        returnmessage.put('isSuccess',parser.getText());
                        if(parser.getText() == 'Error'  || parser.getText() == 'Accepted'){
                            parser.nextToken(); 
                            if(parser.getText() == 'message'){
                                parser.nextToken(); 
                                returnmessage.put('isError',parser.getText()); 
                            }
                        } 
                    }else if(parser.getText()  == 'faultstring'){ 
                        parser.nextToken(); 
                        returnmessage.put('isError',parser.getText()); 
                    }else if(parser.getText()  == 'candidateID'){ 
                        parser.nextToken(); 
                        returnmessage.put('candidateID',parser.getText());  
                    }else if(parser.getText()  == 'clientCandidateID'){ 
                        parser.nextToken(); 
                        returnmessage.put('clientCandidateID',parser.getText());  
                    }else if(parser.getText() =='Text'){
                        parser.nextToken(); 
                        returnmessage.put('isError',parser.getText());
                    }else if(parser.getText() =='authorizationID'){
                        parser.nextToken(); 
                        returnmessage.put('authorizationID',parser.getText());
                    } 
                }
            }  
        }catch(Exception ex){
            system.debug(ex.getMessage()); 
            returnmessage.put('isError',ex.getMessage());
        }
        return returnmessage;
    }
    
    
}