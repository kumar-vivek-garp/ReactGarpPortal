public class ATA_SchedulingInterfaceClass {
    public static String algorithmName = 'RSA';
    public static String signtype = 'SHA1'; 
    public static String todaytimestamp = system.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
    public static Integer status = 2; 
    
    @future(callout=true) 
    public static void ATASchedulingIntegration(Set<Id> intDataId){ 
        ATASchedulingIntegrationCallOut(intDataId);
    }
     
    public static void ATASchedulingIntegrationCallOut(Set<Id> intDataId){
        try{ 
           ATA_Scheduling_Interface__mdt ATASetup = ATAPSIUtilClass.getATASchedulingInterface_mdt(); 
            // Decode the key from base64 to binary
            Blob privateKey = EncodingUtil.base64Decode(ATASetup.Private_Key__c.trim());
            List<Api_Transaction__c> apirspList = new List<Api_Transaction__c>();
            Map<Id,Exam_Attempt__c> UpdateexamattemptMap = new Map<Id,Exam_Attempt__c>();
            List<Integration_Data__c> integrationDataList = [Select Id,Name,Exam_Registrations__r.ATA_Name_as_it_appears_on_ID__c,Exam_Registrations__r.ATA_Cert_type__c,Exam_Registrations__r.ATA_Cert_id__c,ATA_Name_as_it_appears_on_ID__c,Email__c,Garp_Id__c,Exam_Registrations__c,ATA_Batch_Code__c,Exam_Registrations__r.Integration_Type__c,Exam_Registrations__r.Member__c,Exam_Registrations__r.Section__c,Exam_Registrations__r.Exam_Date__c,Integration_Type__c,ATA_Cert_id__c,ATA_Cert_type__c,Gender__c,First_Name__c,Last_Name__c,
                                                             ATA_Inbound_Reg_Code__c,Outbound_Event_Types__c,ATA_reg_time__c,ATA_region_code__c,ATA_region_name__c,
                                                             ATA_subject_code__c,ATA_subject_name__c,Exam_Registrations__r.ATA_subject_code__c,Exam_Registrations__r.Exam_Part__r.ATA_Batch_Code__c From Integration_Data__c Where Id In:intDataId and ATA_Name_as_it_appears_on_ID__c != null and ATA_Cert_type__c != null And ATA_Cert_id__c != null ];
            Set<Id> memberId = new Set<Id>();
            //system.debug(integrationDataList);
            Set<String> exabatchNumber = new Set<String>();
 			Map<String,ATA_Cert_Type_List__c> ATACertTypeMap = ATAPSIUtilClass.getATACertTypeList();	
            
            for(Integration_Data__c intData:integrationDataList){
                String reqendpoint = ATASetup.EndPoint__c;   
                String resStatus;
                Api_Transaction__c  apirsp = new Api_Transaction__c(); 
                ATArequestResponse reqs = new ATArequestResponse();
                ATA_RequestClass requestbody = new ATA_RequestClass();
                requestbody.app_id = ATASetup.App_Id__c;
                requestbody.sign_type = signtype;
                requestbody.timestamp = todaytimestamp;
                ATA_RequestClass.Biz_content bizcontent = new ATA_RequestClass.Biz_content();
                bizcontent.batch_no =  intData.ATA_Batch_Code__c; //ATASetup.Batch_No__c;
                bizcontent.cert_id = intData.Garp_Id__c;//intData.ATA_Cert_id__c;
                bizcontent.cert_type = '5';
                bizcontent.reg_code = intData.ATA_Inbound_Reg_Code__c;
                if(intData.Integration_Type__c == 'Import Registration New' || intData.Integration_Type__c == 'Update Import Registration New' || intdata.Integration_Type__c == 'PSI To ATA'){ 
                    bizcontent.gender = intData.Gender__c;
                    bizcontent.name = intData.First_Name__c +' '+ intData.Last_Name__c;
                    bizcontent.pay_status = 2;  
                    bizcontent.reg_time = intData.ATA_reg_time__c;
                    bizcontent.status = 2;
                    ATA_RequestClass.Extend bxExtend = new ATA_RequestClass.Extend();
                    if(intData.Exam_Registrations__r.ATA_Cert_id__c !=null)
                    bxExtend.id_number = intData.Exam_Registrations__r.ATA_Cert_id__c.right(5); // last five
                    if(ATACertTypeMap.containsKey( intData.Exam_Registrations__r.ATA_Cert_type__c))
                    bxExtend.id_type = ATACertTypeMap.get(intData.Exam_Registrations__r.ATA_Cert_type__c).Conversion_Id__c;
                    bxExtend.c_name = intData.Exam_Registrations__r.ATA_Name_as_it_appears_on_ID__c;
                    bxExtend.email = intData.Email__c;
                    bizcontent.extend = bxExtend; 
                    List<ATA_RequestClass.Region_subject> RegionList = new List<ATA_RequestClass.Region_subject>();
                    ATA_RequestClass.Region_subject region = new ATA_RequestClass.Region_subject(); 
                    region.region_code = intData.ATA_region_code__c;
                    region.region_name = intData.ATA_region_name__c;
                    region.subject_code = intData.ATA_subject_code__c;
                    region.subject_name = intData.ATA_subject_name__c;
                    RegionList.add(region); 
                    bizcontent.region_subject = RegionList; 
 
                    reqendpoint += 'ImportRegistrationNew';
                    //system.debug('ImportRegistrationNew'+reqendpoint);
                }else if(intData.Integration_Type__c == 'Delete Registration' || intdata.Integration_Type__c == 'ATA To PSI'){
                    bizcontent.subject_code = intData.ATA_subject_code__c;
                    reqendpoint += 'DeleteRegistration';
                    //system.debug('DeleteRegistration'+reqendpoint);
                }else if(intData.Integration_Type__c == 'Query Exam Cert'){ 
                    reqendpoint += 'QueryExamCert';
                }
                //system.debug(reqendpoint); 
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
                system.debug(body);
                
                try{
                    reqs = httpCallout(reqendpoint, body,'POST');
                    if(intData.Integration_Type__c == 'Query Exam Cert'){ 
                        intData = getATARequestIntegrattion(intData,reqs.Response.getBody()); 
                    }
                    resStatus = ATAPSIUtilClass.getATAstatus(reqs.Response.getBody()); 
                    if(intdata.Integration_Type__c == 'PSI To ATA'){
                        apirsp.Name = 'Import Registration New';
                    }else if(intdata.Integration_Type__c == 'ATA To PSI'){
                        apirsp.Name = 'Delete Registration';
                    }else{
                        apirsp.Name = intdata.Integration_Type__c;
                    }
                    if(resStatus == 'SUCCESS'){
                        apirsp.Response_Code__c = reqs.Response.getStatusCode()+''; 
                    }else{
                        apirsp.Response_Code__c = '502';
                        apirsp.Error__c = 'ATA Error';
                    }
                    apirsp.Request_Body__c = reqs.Request.getBody(); 
                    apirsp.Body__c = reqs.Response.getBody(); 
                    apirsp.Integration_Data__c = intData.Id;  
                    if(intdata.Name.contains('OSTA Information') && resStatus == 'SUCCESS'){
                        bizcontent = new ATA_RequestClass.Biz_content(); 
                        bizcontent.cert_id = intData.Garp_Id__c; 
                        bizcontent.cert_type = '5';
                        bizcontent.reg_code = intData.ATA_Inbound_Reg_Code__c;
                        intData.ATA_Batch_Code__c = intData.Exam_Registrations__r.Exam_Part__r.ATA_Batch_Code__c;
                        intData.ATA_subject_code__c = intData.Exam_Registrations__r.ATA_subject_code__c;
                        bizcontent.batch_no =  intData.ATA_Batch_Code__c;
                        bizcontent.gender = intData.Gender__c;
                        bizcontent.name = intData.First_Name__c +' '+ intData.Last_Name__c;
                        bizcontent.pay_status = 2;  
                        bizcontent.reg_time = intData.ATA_reg_time__c;
                        bizcontent.status = 2;
                        ATA_RequestClass.Extend bxExtend1 = new ATA_RequestClass.Extend();
                        bxExtend1.id_number = intData.ATA_Cert_id__c; // last five
                        bxExtend1.id_type = intData.ATA_Cert_type__c;
                        bxExtend1.c_name = intData.ATA_Name_as_it_appears_on_ID__c;
                        bxExtend1.email = intData.Email__c;
                        bizcontent.extend = bxExtend1; 
                        List<ATA_RequestClass.Region_subject> RegionList1 = new List<ATA_RequestClass.Region_subject>();
                        ATA_RequestClass.Region_subject region1 = new ATA_RequestClass.Region_subject(); 
                        region1.region_code = intData.ATA_region_code__c;
                        region1.region_name = intData.ATA_region_name__c;
                        region1.subject_code = intData.ATA_subject_code__c;
                        region1.subject_name = intData.ATA_subject_name__c;
                        RegionList1.add(region1);
                         
                        bizcontent.region_subject = RegionList1; 
                        requestbody.biz_content = JSON.serialize(bizcontent);
                        eventdata ='';
                        datareq ='';
                        eventdata =  requestbody.biz_content;
                        eventdata = eventdata.replace('\\"', '"');
                        eventdata = eventdata.replace('"{', '{');
                        eventdata = eventdata.replace('}"', '}');
                        datareq = 'app_id='+requestbody.app_id;
                        datareq += '&biz_content='+eventdata;
                        datareq += '&sign_type='+requestbody.sign_type;
                        datareq += '&timestamp='+requestbody.timestamp;                        
                        Blob input1 = Blob.valueOf(datareq);
                        Blob signatureBlob1 = Crypto.sign(algorithmName, input1, privateKey);
                        String signature1 =  EncodingUtil.base64Encode(signatureBlob1);
                        requestbody.sign = signature1;
                        String body1 = JSON.serialize(requestbody);
                        reqendpoint = ATASetup.EndPoint__c+'ImportRegistrationNew';
                        reqs = httpCallout(reqendpoint, body1,'POST');
                        resStatus = ATAPSIUtilClass.getATAstatus(reqs.Response.getBody());
                        Api_Transaction__c apirsp1 = new Api_Transaction__c(); 
                        if(resStatus == 'SUCCESS'){       
                            apirsp1.Response_Code__c = reqs.Response.getStatusCode()+'';
                        }else{
                            apirsp1.Error__c = 'ATA Error'; 
                            apirsp1.Response_Code__c = '502'; 
                        }
                        apirsp1.Name = 'Import Registration New';
                        apirsp1.Integration_Data__c = intdata.Id;
                        apirsp1.Request_Body__c = reqs.Request.getBody(); 
                        apirsp1.Body__c = reqs.Response.getBody(); 
                        apirspList.add(apirsp1);    
                    } 
                    
                }catch(Exception e){
                    apirsp.Name += ' Exception';
                    apirsp.Integration_Data__c = intData.Id;  
                    apirsp.Error__c = e.getMessage(); 
                    apirsp.Response_Code__c = '502';
                } 
                apirspList.add(apirsp); 
                if(resStatus == 'SUCCESS'){
                    intData.Call_out_Status__c = 'Processed';
                    intData.Is_Active__c = true; 
                }else{
                    intData.Call_out_Status__c = 'Error';  
                    intData.Is_Active__c = false; 
                }
                
                intData.ATA_Outbound_Batch_Code__c = intData.ATA_Batch_Code__c;
                if( intData.Exam_Registrations__r.ATA_Cert_id__c != null)
                intdata.ATA_Cert_id__c = intData.Exam_Registrations__r.ATA_Cert_id__c.right(5);
                if(ATACertTypeMap.containsKey(intData.Exam_Registrations__r.ATA_Cert_Type__c))
                    intdata.ATA_Cert_type__c = ATACertTypeMap.get(intData.Exam_Registrations__r.ATA_Cert_Type__c).Conversion_Id__c;
                 intdata.ATA_Name_as_it_appears_on_ID__c = intData.Exam_Registrations__r.ATA_Name_as_it_appears_on_ID__c;
                if(intData.Integration_Type__c == 'Delete Registration'  || intData.Integration_Type__c == 'ATA To PSI'){ 
                    intData.ATA_Exam_end_time__c = null; 
                    intData.ATA_Test_center_address__c = null;
                    intData.ATA_Test_center_name__c = null;
                    intData.ATA_Test_room_address__c = null;
                    intData.ATA_Test_room_name__c = null;
                    intData.ATA_Time_of_cancelation__c = null;
                    intData.ATA_Inbound_Batch_Code__c = null;
                    intData.ATA_Inbound_Reg_Code__c = null;
                    intData.ATA_Inbound_Region_code__c = null;
                    intData.ATA_Inbound_Region_name__c = null;
                    intData.ATA_Inbound_Subject_code__c = null;
                    intData.ATA_Inbound_Subject_name__c = null;
                    intData.Scheduled_Date_Time__c = null;
                    intData.PSI_Booking_Local_Time__c = null;
                    intdata.ATA_Exam_start_time__c =null;
                    intdata.ATA_Booking_Local_Time__c = null;
                }
               
                if(intData.Integration_Type__c != 'ATA To PSI'){ 
                    intData.PSI_booking_on__c = null;
                    intData.PSI_change_reason__c = null;
                    intData.PSI_client_eligibility_id__c = null;
                    intData.PSI_created_datetime__c = null;
                    intData.PSI_delivery_mode__c = null;
                    intData.PSI_eligibility_end_date__c = null;
                    intData.PSI_eligibility_status_message__c = null;
                    intData.PSI_eligible_to_schedule__c = null;
                    intData.PSI_location_address__c = null;
                    intData.PSI_location_code__c = null;
                    intData.PSI_location_name__c = null;
                    intData.PSI_location_timezone__c = null;
                    intData.PSI_schedule_start_date__c = null;
                    intData.Scheduled_Date_Time__c = null;
                    intData.PSI_Booking_Local_Time__c = null;
                }
                intData.ATA_event_type__c = null;
                if(intData.Exam_Registrations__c != null){
                    Exam_Attempt__c ex =  new Exam_Attempt__c();
                    ex.Id = intData.Exam_Registrations__c;
                    ex.Outbound_Status__c = intData.Call_out_Status__c;
                    if(intData.Is_Active__c ==  true)
                        ex.Active_Integration_Data__c = intData.Id;
                    ex.Outbound_Type__c = null;
                    ex.Integration_Type__c = null;
                    ex.ATA_PSI_Is_Override__c = false;
                    UpdateexamattemptMap.put(ex.Id,ex);
                }
            }
            
            if(apirspList.size()>0){
                insert apirspList;
            }
            
            if(!integrationDataList.isEmpty()){  
                UPDATE integrationDataList; 
                Set<Id> activerecId = new Set<Id>();
                Set<Id> examrecId = new Set<Id>(); 
                for(Integration_Data__c indata:integrationDataList){ 
                    if(indata.Is_Active__c == true && indata.Integration_Type__c != 'ATA To PSI'){ 
                        activerecId.add(indata.Id);
                    }
                    examrecId.add(indata.Exam_Registrations__c);
                     
                }
                if(!activerecId.isEmpty()){
                    List<Integration_Data__c> UpdateintegrationDataList = new  List<Integration_Data__c>(); 
                    UpdateintegrationDataList = ATAPSIUtilClass.updateActiveRecords(activerecId,examrecId); 
                    if(!UpdateintegrationDataList.isEmpty()){
                        UPDATE UpdateintegrationDataList;  
                        //system.debug(UpdateintegrationDataList);
                    }  
                }
            }
            
            if(!UpdateexamattemptMap.isEmpty()){
                UPDATE UpdateexamattemptMap.Values();
            }
        }catch(Exception ex){
            system.debug('Error :'+ex.getMessage()+' '+ex.getLineNumber()); 
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
            string JsonString = '{"timestamp":"2020-10-13T11:59:55-04:00","sign_type":"SHA1","sign":"w5go0a5V0DEjvc2bnn4Adrx960cI0O1WFzrNhlfQLcEkhzfWTg8HYiBvEGoxIoLhhFcSSkuUW/Pd0ffWRDgnCMWb9tygyrQuP22Q==","biz_content":[{"status":2,"region_subject":[{"subject_name":"FRM Exam Part I","subject_code":"FRM01","region_name":"China, Beijing","region_code":"086001"}],"reg_time":"2020-10-13T11:59:52-04:00","reg_code":"1496386","pay_status":2,"name":"testuser","gender":null,"cert_type":"5","cert_id":"1496386","batch_no":"202009071"}],"app_id":"96e23938ab9611ea87080242ac110002","resp_msg": "SUCCESS"}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JsonString);
            res.setStatusCode(200);
        }
        //System.debug(res.getBody());
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
    
    
    
   
   
    public Static Integration_Data__c getATARequestIntegrattion(Integration_Data__c intdata,String resBody){
        try{            
            ATAGetResponseParserClass ataparse = ATAGetResponseParserClass.parse(resBody);  
            String jsonbizres = ataparse.biz_content; 
            if(jsonbizres != null && jsonbizres != ''){
                jsonbizres = jsonbizres.replace('\\"', '"');
                jsonbizres = jsonbizres.replace('"{', '{');
                jsonbizres = jsonbizres.replace('}"', '}');
                List<ATAGetResponseParserClass.Biz_content> parseBiz_contentList  = (List<ATAGetResponseParserClass.Biz_content>)System.JSON.deserialize(jsonbizres,List<ATAGetResponseParserClass.Biz_content>.class);
                for(ATAGetResponseParserClass.Biz_content bz:parseBiz_contentList){ 
                    intdata.ATA_Exam_start_time__c = bz.start_time;
                    intdata.ATA_Exam_end_time__c= bz.end_time;
                    intdata.ATA_Test_center_name__c = bz.org_name;
                    intdata.ATA_Test_room_name__c = bz.room_name;
                    intdata.ATA_Test_center_address__c = bz.org_address;
                    intdata.ATA_Test_room_address__c = bz.room_address;
                    intdata.ATA_Admission_Ticket_Number__c = bz.exam_cert_no;
                    intdata.ATA_Cert_type__c = bz.cert_type;
                    intdata.ATA_Cert_id__c = bz.cert_id;
                    intdata.ATA_Inbound_Region_code__c = bz.region_code;
                    intdata.ATA_Inbound_Region_name__c = bz.region_name;
                    intdata.ATA_Inbound_Subject_code__c= bz.subject_code;
                    intdata.ATA_Inbound_Subject_name__c = bz.subject_name;
                    intdata.ATA_Seat_number__c = bz.client_id;
                } 
            }
        }catch(Exception ex){
            system.debug(ex.getMessage()+' '+ex.getLinenumber()); 
        }
        return intdata;
    }
   
}