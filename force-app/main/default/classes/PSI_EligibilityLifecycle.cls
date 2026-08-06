public class PSI_EligibilityLifecycle{ 
    
    @future(callout=true) 
    public static void PSIEligibilityLifecycleCallout(Set<Id> intDataId){ 
        PSIEligibilityLifecycleCalloutExt(intDataId);
    }

    public static void PSIEligibilityLifecycleCalloutExt(Set<Id> intDataId){
        try{
            PSI_Eligibility__mdt psimtd = ATAPSIUtilClass.getPSIEligibility_mdt();
            
            String accessToken;
            if(Test.isRunningTest()){
                accessToken = 'testAccessToken'; 
            } else {
                accessToken = ATAPSIUtilClass.getPSIaccesstoken(psimtd);
            } 
            String reqendpoint = '';
            String reqType ='';
            if(accessToken != null){ 
                List<Api_Transaction__c> apirspList = new List<Api_Transaction__c>();
                Map<Id,Exam_Attempt__c> UpdateexamattemptMap = new Map<Id,Exam_Attempt__c>();
                List<Integration_Data__c> integrationDataList = [Select Id,Name,Version_Number__c,Is_Active__c,PSI_Test_code__c,Exam_Registrations__r.Integration_Type__c,Integration_Type__c,Address_1__c,Address_2__c,Garp_Id__c,City__c,Country__c,
                                                                 Email__c,First_Name__c,Phone_Number__c,Last_Name__c,
                                                                 Postal_Code__c,State__c,client_eligibility_id__c,PSI_eligibility_end_date__c,PSI_schedule_start_date__c From Integration_Data__c Where Id In:intDataId];
                
                
                for(Integration_Data__c intdata:integrationDataList){
                    Api_Transaction__c  apirsp = new Api_Transaction__c();
                    PSIrequestResponse reqs = new PSIrequestResponse();
                    PSI_CandidatedataWrapper cdata  = new PSI_CandidatedataWrapper(); 
                    PSI_CandidatedataWrapper.Candidate cnobj = new PSI_CandidatedataWrapper.Candidate();
                    cnobj.address1 = intdata.Address_1__c;  
                    cnobj.address2  = intdata.Address_2__c; 
                    cnobj.candidate_id = intdata.Garp_Id__c;
                    cnobj.city =intdata.City__c;
                    cnobj.country =intdata.Country__c;
                    cnobj.email =intdata.Email__c;
                    cnobj.first_name =intdata.First_Name__c;
                    cnobj.home_phone =intdata.Phone_Number__c;
                    cnobj.last_name =intdata.Last_Name__c;
                    cnobj.middle_name ='';
                    cnobj.office_phone ='';
                    cnobj.postal_code =intdata.Postal_Code__c;
                    cnobj.province_state =intdata.State__c;
                    cnobj.school_code = '';
                    
                    List<PSI_CandidatedataWrapper.Additional_attributes> adattList = new List<PSI_CandidatedataWrapper.Additional_attributes>();
                    PSI_CandidatedataWrapper.Additional_attributes adat = new PSI_CandidatedataWrapper.Additional_attributes();
                    adat.key ='';
                    adat.value = '';
                    adattList.add(adat);
                    cnobj.additional_attributes = adattList;
                    cdata.candidate = cnobj;
                    cdata.client_eligibility_id = intdata.client_eligibility_id__c;
                    cdata.eligibility_end_date = intdata.PSI_eligibility_end_date__c;
                    cdata.test_code =intdata.PSI_Test_code__c;
                    cdata.schedule_start_date = intdata.PSI_schedule_start_date__c; 
                    if(intdata.Integration_Type__c == 'Eligibility Lifecycle' || intdata.Integration_Type__c == 'ATA To PSI'){
                        reqendpoint = psimtd.Add_Eligibility_URL__c; 
                        reqType = 'POST';
                    }else if(intdata.Integration_Type__c == 'Update Eligibility Lifecycle'){
                        reqendpoint =  psimtd.Update_Eligibility_URL__c;
                        reqendpoint = reqendpoint.replace('candidateId',intdata.Garp_Id__c);
                        if(intdata.PSI_Test_code__c !=null)
                            reqendpoint = reqendpoint.replace('testCode',intdata.PSI_Test_code__c); 
                        reqType = 'POST';
                    }else if(intdata.Integration_Type__c == 'Cancel Eligibility Lifecycle' || intdata.Integration_Type__c == 'PSI To ATA'){
                        reqendpoint =  psimtd.Cancel_Eligibility_URL__c;
                        reqendpoint = reqendpoint.replace('candidateId',intdata.Garp_Id__c);
                        if(intdata.PSI_Test_code__c !=null)
                            reqendpoint = reqendpoint.replace('testCode',intdata.PSI_Test_code__c); 
                        reqType = 'POST';
                    }
                    String body = JSON.serialize(cdata);
                    system.debug('reqendpoint'+reqendpoint);
                    reqs = httpCallout(reqendpoint,body,reqType,accessToken,psimtd.Client_Secret__c); 
                    String Error = '';
                    if(reqs.Response.getBody() != null && reqs.Response.getBody() != ''){
                        string jsonString = reqs.Response.getBody(); 
                        Map<String, Object> resmap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                        if(resmap.containsKey('psi_eligiblity_id')){
                            intdata.PSI_client_eligibility_id__c = resmap.get('psi_eligiblity_id').tostring();
                        }else if(resmap.containsKey('error_description')){
                            Error = resmap.get('error_description').tostring();
                            try{
                                if(Error.contains('Candidate can not be registered as an open registration record already exists for this candidate.')){
                                    reqendpoint = psimtd.Get_Eligibility_URL__c;
                                    reqendpoint = reqendpoint.replace('acctCode',psimtd.Account_Code__c); 
                                    reqendpoint = reqendpoint.replace('candidateId',intdata.Garp_Id__c);
                                    if(intdata.PSI_Test_code__c !=null)
                                        reqendpoint = reqendpoint.replace('testCode',intdata.PSI_Test_code__c); 
                                    reqs = httpCallout(reqendpoint,null,reqType,accessToken,psimtd.Client_Secret__c);
                                    List<PSIGetResponseParserClass> psiParser =  PSIGetResponseParserClass.parse(reqs.Response.getBody()); 
                                     for(PSIGetResponseParserClass ps:psiParser){ 
                                        if(ps.eligible_to_schedule == true){ 
                                            intdata.PSI_client_eligibility_id__c = ps.psi_eligiblity_id;
                                            Error = null;
                                            break;
                                        }else { 
                                            Error = 'Unable to process request, please try later';
                                            break; 
                                        }
                                    }  
                                } 
                            }catch(Exception ex){
                                system.debug(ex.getmessage());
                            }                            
                        } 
                    } 
                    if(intdata.Name.contains('Section Change') && (Error == '' || Error == null)){
                        reqendpoint = psimtd.Add_Eligibility_URL__c; 
                        reqType = 'POST';
                        reqs = httpCallout(reqendpoint,body,reqType,accessToken,psimtd.Client_Secret__c); 
                        if(reqs.Response.getBody() != null && reqs.Response.getBody() != ''){
                            string jsonString1 = reqs.Response.getBody(); 
                            Map<String, Object> resmap1 = (Map<String, Object>) JSON.deserializeUntyped(jsonString1);
                            if(resmap1.containsKey('psi_eligiblity_id')){
                                intdata.PSI_client_eligibility_id__c = resmap1.get('psi_eligiblity_id').tostring();
                            }else if(resmap1.containsKey('error_description')){
                                Error = resmap1.get('error_description').tostring();                            
                            }
                        }       
                        if(Error == '' || Error == null){ 
                            intdata.Name = 'Eligibility Lifecycle' +' Section Change' +intdata.Version_Number__c;
                            Api_Transaction__c apirsp1 = new Api_Transaction__c(); 
                            apirsp1.Name = 'Eligibility Lifecycle';
                            apirsp1.Request_Body__c = reqs.Request.getBody(); 
                            apirsp1.Body__c = reqs.Response.getBody();
                            apirsp1.Response_Code__c = reqs.Response.getStatusCode()+'';
                            apirsp1.Error__c = Error; 
                            apirsp1.Integration_Data__c = intdata.Id;  
                            apirspList.add(apirsp1);                          
                        }                       
                    }
                    
                    if(intdata.Integration_Type__c == 'PSI To ATA'){
                        apirsp.Name = 'Cancel Eligibility Lifecycle';
                    }else if(intdata.Integration_Type__c == 'ATA To PSI'){
                        apirsp.Name = 'Eligibility Lifecycle';
                    }else{
                        apirsp.Name = intdata.Integration_Type__c;
                    }                     
                    apirsp.Request_Body__c = reqs.Request.getBody(); 
                    apirsp.Body__c = reqs.Response.getBody();
                    apirsp.Response_Code__c = reqs.Response.getStatusCode()+'';
                    apirsp.Error__c = Error; 
                    apirsp.Integration_Data__c = intdata.Id;  
                    apirspList.add(apirsp);  
                    if(Error != '' && Error != null){
                        intdata.Is_Active__c = false; 
                        intdata.Call_out_Status__c = 'Error';  
                    }else{
                        intdata.Is_Active__c = true; 
                        intdata.Call_out_Status__c = 'Processed';  
                    }
                    
                    if(intData.Integration_Type__c == 'Cancel Eligibility Lifecycle' || intData.Integration_Type__c == 'PSI To ATA'){
                        if(!intdata.Name.contains('Section Change')){
                            intData.PSI_client_eligibility_id__c = null;
                        }
                        intData.PSI_booking_on__c = null;
                        intData.PSI_change_reason__c = null; 
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
                        intData.PSI_Address_1__c = null;
                        intData.PSI_Address_2__c = null; 
                        intData.PSI_Address_3__c = null;
                        intData.PSI_city__c = null;
                        intData.PSI_state__c = null;
                        intData.PSI_country__c = null;
                        intData.PSI_postal_code__c = null;
                    }               
                    
                    if(intData.Integration_Type__c != 'PSI To ATA'){
                        intData.ATA_Exam_end_time__c = null; 
                        intData.ATA_Reservation_time__c = null;
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
                        intdata.ATA_Exam_start_time__c =null;
                        intdata.ATA_Booking_Local_Time__c = null;
                    }
                    
                    if(intData.Exam_Registrations__c != null){
                        Exam_Attempt__c ex =  new Exam_Attempt__c();
                        ex.Id = intData.Exam_Registrations__c;
                        ex.Outbound_Status__c = intData.Call_out_Status__c;
                        if(intData.Is_Active__c ==  true)
                            ex.Active_Integration_Data__c = intData.Id;
                        ex.Outbound_Type__c = null;
                        ex.Integration_Type__c = null;
                        UpdateexamattemptMap.put(ex.Id,ex);
                    } 
                } 
                
                if(apirspList.size()>0){
                    insert apirspList;
                }
                system.debug(integrationDataList);
                if(!integrationDataList.isEmpty()){  
                    UPDATE integrationDataList; 
                    Set<Id> activerecId = new Set<Id>();
                    Set<Id> examrecId = new Set<Id>();
                    for(Integration_Data__c indata:integrationDataList){ 
                        if(indata.Is_Active__c == true){  
                            activerecId.add(indata.Id);
                        }
                        examrecId.add(indata.Exam_Registrations__c);
                    }
                    if(!activerecId.isEmpty()){
                        List<Integration_Data__c> UpdateintegrationDataList = new  List<Integration_Data__c>(); 
                        UpdateintegrationDataList = ATAPSIUtilClass.updateActiveRecords(activerecId,examrecId); 
                        if(!UpdateintegrationDataList.isEmpty()){
                            UPDATE UpdateintegrationDataList;  
                            system.debug(UpdateintegrationDataList);
                        }  
                    }
                }
                if(!UpdateexamattemptMap.isEmpty()){
                    UPDATE UpdateexamattemptMap.Values();
                }
            }
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
    } 
    
    
    public static PSIrequestResponse httpCallout(String Endpoint,String reqBody,String reqType,String accessToken,String ClientSecret){
        PSIrequestResponse reqs = new PSIrequestResponse(); 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint); 
        req.setHeader('Token',accessToken);
        req.setHeader('auth', ClientSecret);
        req.setheader('content-type','application/json');
        req.setMethod(reqType);  
        if(reqBody != null)
            req.setBody(reqBody); 
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        if(!test.isRunningTest()) {
            res = http.send(req);
        } else {
            string JsonString = '{"test_code":"ERP1","schedule_start_date":null,"portion_codes":null,"eligibility_end_date":"2020-11-23","client_eligibility_id":"PSI-00000004","candidate":{"suffix":null,"special_accommodations":null,"school_code":"","province_state":"NJ","postal_code":"07086-5305","office_phone":"","middle_name":"","last_name":"kathi","home_phone":null,"first_name":"vivek","email":"1@testing.comweqweq","country":null,"city":"WEEHAWKEN","candidate_id":"1495692","address2":null,"address1":"WEEHAWKEN","additional_attributes":[{"value":"","key":""}]}}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JsonString);
            res.setStatusCode(200);
        }
        System.debug(res.getBody());
        reqs.Request = req;
        reqs.Response = res;
        return reqs;
    } 
    
    public class PSIrequestResponse{
        public HttpRequest Request;
        public HTTPResponse Response;
        public PSIrequestResponse(){
            Request = new HttpRequest();
            Response = new HTTPResponse();
        }
    }
    
    
}