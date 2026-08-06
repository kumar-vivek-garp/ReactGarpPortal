@RestResource(urlMapping='/api/pearsonvue')
global with sharing class PearsonPingRestResource {
    @HttpPost 
    global static void doPost() {
        
        PearsonInboundRequestJsonHelper.ResponseBase  CustomeResponse = new PearsonInboundRequestJsonHelper.ResponseBase(); 
        List<Integration_Data__c> PearsonActiveCloneList = new List<Integration_Data__c>();
        RestResponse standardResp =new RestResponse();
        standardResp  = RestContext.response;
        RestRequest req = RestContext.request;
        String XMLString ='';
        try{
            String result = RestContext.request.requestBody.toString(); 
            XMLString =RestContext.request.requestBody.toString();          
            String jsonsres = PearsonXmlParser.xmlToJson(XMLString); 
            PearsonInboundRequestJsonParser RequestJson = PearsonInboundRequestJsonParser.parse(jsonsres);
            Pearson_Ping_Setting__c  pingsetting = Pearson_Ping_Setting__c.getInstance();
            
            //validate UsernameToken
            String userName = pingsetting.User_Name__c;
            String Password = pingsetting.Password__c;
            String requestUserName = RequestJson.Envelope.Header.Security.UsernameToken.Username;
            String requestPassword = RequestJson.Envelope.Header.Security.UsernameToken.Password.ele_text; 
            
            
            if(userName != requestUserName || Password != requestPassword){
                CustomeResponse.Success = false;
                CustomeResponse.Status = 'Failure';
                CustomeResponse.Message = 'Incorrect username/password.'; 
            }else{   
                String CandidateID;
                String AppointmentID ;
                String examSeriesCode; 
                Date ExamStartDate;
                if(RequestJson.Envelope.Body.ModifyAppointmentRequest != null){
                    CandidateID =  RequestJson.Envelope.Body.ModifyAppointmentRequest.clientCandidateID; 
                    examSeriesCode = RequestJson.Envelope.Body.ModifyAppointmentRequest.exams.exam.examSeriesCode;  
                    DateTime dt = getDatetimeformat(RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentStartDateTime,RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentDisplayTimeZoneUtcOffset); 
                    ExamStartDate = date.newinstance(dT.year(), dT.month(), dT.day()); 
                    CustomeResponse.eventType = 'ModifyAppointmentRequest';
                }
                
                if(RequestJson.Envelope.Body.ResultNotificationRequest != null){ 
                    CandidateID =  RequestJson.Envelope.Body.ResultNotificationRequest.clientCandidateID; 
                    examSeriesCode = RequestJson.Envelope.Body.ResultNotificationRequest.exams.exam.examDefinition.examSeriesCode; 
                    CustomeResponse.eventType = 'ResultNotificationRequest';
                }
                
                if(RequestJson.Envelope.Body.cancelAppointmentRequest != null){
                    AppointmentID = RequestJson.Envelope.Body.cancelAppointmentRequest.vueAppointmentID;
                    CustomeResponse.eventType = 'cancelAppointmentRequest';
                }
                
                if(examSeriesCode == '2016-FRR')
                    examSeriesCode = 'FRR';
                
                List<Integration_Data__c> IntegrationDataList = new List<Integration_Data__c>();
                List<Exam_Attempt__c> UpdateExamAttempt = new List<Exam_Attempt__c>();
                IntegrationDataList = [SELECT Id,Is_Active__c,Contract__r.ContractNumber FROM Integration_Data__c WHERE ((Garp_Id__c =: CandidateID And Exam_Type__c=:examSeriesCode) OR (Pearson_Vue_Appointment_ID__c =:AppointmentID AND Pearson_Vue_Appointment_ID__c != null)) And Is_Active__c = true and Version_Number__c !=null AND Contract__c != null AND Contract__r.Status ='Activated' Order By Version_Number__c,CreatedDate Desc];
                
                if(IntegrationDataList.size()>0){  
                    set<Id> activePearsonIds = new set<Id>();
                    activePearsonIds.add(IntegrationDataList[0].Id); 
                    PearsonActiveCloneList = ScrContractTriggerHelper.cloneActiveRecord(activePearsonIds);
                    for(Integration_Data__c ps: PearsonActiveCloneList){
                        if(CandidateID != null && examSeriesCode != null){
                            if(CustomeResponse.eventType =='ResultNotificationRequest'){
                                ps = getresultNotificationIntegrationData(RequestJson,ps);
                            }else{
                                ps = getModifyAppointmentRequest(RequestJson,ps);
                            }                           
                        }
                        if(CustomeResponse.eventType == 'cancelAppointmentRequest'){
                           ps = getcancelAppointmentRequest(RequestJson,ps);
                        }
                        
                      
                        if(ps.Pearson_Event_Type__c == 'NoShow' || ps.Pearson_Event_Type__c =='ExamDelivered')
                            ps.ExamDelivered__c = true;
                        if(ps.Pearson_Event_Type__c == 'NoShow')
                            ps.Results__c = 'No-show';
                        if(ps.Version_Number__c != null)
                            ps.Version_Number__c = ps.Version_Number__c+1;
                        ps.Name = IntegrationDataList[0].Contract__r.ContractNumber +' - '+ ps.Version_Number__c; 
                        ps.Call_out_Type__c = 'In-bound';
                        ps.Pearson_Operation_Type__c = CustomeResponse.eventType;
                        ps.Created_From__c = null;
                        ps.Call_out_Status__c = null;
                        ps.Outbound_Event_Types__c = null;
                        ps.Authorization_Type__c = null; 
                        ps.ownerid =System.Label.IntegrationDataOwner; 
                    }
                    try{
                        if(!PearsonActiveCloneList.isEmpty()){ 
                            insert PearsonActiveCloneList; 
                            /* List<Exam_Registration_Window__c> ExamRegistrationWindow = new List<Exam_Registration_Window__c> ();  
                            List<Exam_Sites__c> ExamSites = new List<Exam_Sites__c>(); 
                            if(PearsonActiveCloneList[0].Exam_Location_Country__c != null)
                            ExamSites = [Select id from Exam_Sites__c where ISO_Country_Code__c =:PearsonActiveCloneList[0].Exam_Location_Country__c];
                            if(ExamStartDate!= null)
                                ExamRegistrationWindow = [Select id From Exam_Registration_Window__c where Exam_Registration_Window_Open__c <=: ExamStartDate AND Exam_Registration_Window_Close__c >=: ExamStartDate and Exam_Group__r.name like '%scr%' Order by createddate desc];
                           */
                            if(PearsonActiveCloneList[0].Exam_Registrations__c != null){
                                Exam_Attempt__c ea = new Exam_Attempt__c();
                                ea.Id = PearsonActiveCloneList[0].Exam_Registrations__c;
                                ea.Active_Integration_Data__c = PearsonActiveCloneList[0].Id;
                                
                                if(PearsonActiveCloneList[0].Results__c != null && (examSeriesCode == 'FRR' || examSeriesCode == 'FRR_Series')){
                                    ea.Result__c = PearsonActiveCloneList[0].Results__c;
                                    ea.Icbrr_Exam_Date__c = system.today();
                                }
                               /* 
                                if(ExamSites.size()>0 && examSeriesCode != 'FRR')
                                ea.Exam_Site__c =ExamSites[0].Id;
								if(ExamRegistrationWindow.size()>0){
                                     ea.Exam_Registration_Window__c =ExamRegistrationWindow[0].Id; 
                                }else{
                                    ea.Exam_Registration_Window__c = null;  
                                }  */
                                UpdateExamAttempt.add(ea);
                            }
                            IntegrationDataList[0].Is_Active__c = false; 
                            Update IntegrationDataList;
                                                       
                            
                            if(UpdateExamAttempt.size()>0)
                                Update UpdateExamAttempt;
                            
                            CustomeResponse.Success = true;
                            CustomeResponse.Status = 'Success';  
                            CustomeResponse.Message = 'Updated Successfully';
                        }
                    }catch(Exception ex){
                        system.debug(ex.getMessage());
                        system.debug(ex.getLinenumber());
                        system.debug(ex.getStackTraceString());
                        CustomeResponse.Success = true;
                         CustomeResponse.Status = 'Success';
                         CustomeResponse.Message = 'Updated Successfully';
                       // CustomeResponse.Status = 'Failure';
                       // CustomeResponse.Message = ex.getMessage();
                    }  
                }else{ 
                       CustomeResponse.Status = 'Success';
                       CustomeResponse.Status = 'Success';
                         CustomeResponse.Message = 'Updated Successfully';
                  
                   // CustomeResponse.Success = false;
                   // CustomeResponse.Status = 'Failure';
                  //  CustomeResponse.Message = 'Invalid exam series code.';
                } 
            } 
        }Catch(Exception ex){
              CustomeResponse.Status = 'Success';
                       CustomeResponse.Status = 'Success';
                         CustomeResponse.Message = 'Updated Successfully';
          //  CustomeResponse.Success = false;
           // CustomeResponse.Status = 'Failure';
           // CustomeResponse.Message = 'Invalid exam series code.'; 
            system.debug(ex.getMessage());
            system.debug(ex.getLinenumber());
            system.debug(ex.getStackTraceString());
        }
        standardResp.responseBody =  PearsonInboundRequestJsonHelper.formatResponsedata(CustomeResponse); 
        //if(PearsonActiveCloneList.size()>0){
            Api_Transaction__c apirsp = new Api_Transaction__c();
            apirsp.Name = CustomeResponse.eventType;
            apirsp.Request_Body__c = XMLString; 
            apirsp.Body__c = standardResp.responseBody.toString(); 
            apirsp.Error__c = CustomeResponse.Message; 
            if(PearsonActiveCloneList.size()>0){
                apirsp.Integration_Data__c = PearsonActiveCloneList[0].Id;
            }
            insert apirsp;
      //  }
    }
    
    public Static Integration_Data__c getModifyAppointmentRequest(PearsonInboundRequestJsonParser RequestJson,Integration_Data__c integrationData){
        //integrationData.Pearson_Operation_Type__c ===sch:modifyAppointmentRequest
        integrationData.Pearson_Event_Type__c =RequestJson.Envelope.Body.ModifyAppointmentRequest.eventType;
        integrationData.Pearson_Event_NotificationID__c=RequestJson.Envelope.Body.ModifyAppointmentRequest.eventNotificationID;
        
        integrationData.Pearson_Event_Time__c = geteventDatetimeformat(RequestJson.Envelope.Body.ModifyAppointmentRequest.eventTime);
        integrationData.Appointment_Duration__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentDuration;
        integrationData.Pearson_Appointment_Source__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentSource;
        integrationData.Pearson_appointmentDisplayTimeZone__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentDisplayTimeZone;
        integrationData.Pearson_AppointmenDisplayTimeZoneUtc__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentDisplayTimeZoneUtcOffset;
        integrationData.Pearson_CurrentUtcOffset__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.testCenter.testCenterAddress.currentUtcOffset;
        integrationData.Pearson_vueOrderNo__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.vueOrderNo;
        
        if(RequestJson.Envelope.Body.ModifyAppointmentRequest.exams.exam.deliveryModel == 'Online Proctored')
        integrationData.Assesment_Type__c = 'Remote';
        
        if(RequestJson.Envelope.Body.ModifyAppointmentRequest.exams.exam.deliveryModel == 'Standard Test Center')
        integrationData.Assesment_Type__c = 'CBT';
        
        integrationData.Scheduled_Date_Time__c = getDatetimeformat(RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentStartDateTime,RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentDisplayTimeZoneUtcOffset);
        integrationData.Location_Name__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.testCenter.testCenterName;
        integrationData.Pearson_vue_Test_CenterID__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.testCenter.vueTestCenterID;
        integrationData.Location_Address__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.testCenter.testCenterAddress.address1;
        integrationData.Exam_Location_Country__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.testCenter.testCenterAddress.country;
        integrationData.Exam_Location_City__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.testCenter.testCenterAddress.city;
        integrationData.Exam_Location_State__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.testCenter.testCenterAddress.state;
        integrationData.Exam_Location_Postal_Code__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.testCenter.testCenterAddress.postalCode;
        integrationData.Pearson_Vue_Appointment_ID__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.vueAppointmentID;
        integrationData.Registration_Status__c = 'Active';
        return integrationData;
    }
    
    public Static Integration_Data__c getresultNotificationIntegrationData(PearsonInboundRequestJsonParser RequestJson,Integration_Data__c integrationData){ 
        integrationData.Pearson_Event_Type__c =RequestJson.Envelope.Body.resultNotificationRequest.eventType;
        integrationData.Pearson_Event_NotificationID__c=RequestJson.Envelope.Body.resultNotificationRequest.eventNotificationID;
        
        integrationData.Pearson_Event_Time__c = geteventDatetimeformat(RequestJson.Envelope.Body.resultNotificationRequest.eventTime);
        //integrationData.Appointment_Duration__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentDuration;
        //integrationData.Pearson_Appointment_Source__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentSource;
        //integrationData.Pearson_appointmentDisplayTimeZone__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentDisplayTimeZone;
        //integrationData.Pearson_AppointmenDisplayTimeZoneUtc__c = RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentDisplayTimeZoneUtcOffset;
        integrationData.Pearson_CurrentUtcOffset__c = RequestJson.Envelope.Body.resultNotificationRequest.testCenter.testCenterAddress.currentUtcOffset;
        integrationData.Pearson_vueOrderNo__c = RequestJson.Envelope.Body.resultNotificationRequest.vueOrderNo;
        //integrationData.Assesment_Type__c
        //integrationData.Scheduled_Date_Time__c = getDatetimeformat(RequestJson.Envelope.Body.ModifyAppointmentRequest.appointmentStartDateTime);
        integrationData.Location_Name__c = RequestJson.Envelope.Body.resultNotificationRequest.testCenter.testCenterName;
        integrationData.Pearson_vue_Test_CenterID__c = RequestJson.Envelope.Body.resultNotificationRequest.testCenter.vueTestCenterID;
        integrationData.Location_Address__c = RequestJson.Envelope.Body.resultNotificationRequest.testCenter.testCenterAddress.address1;
        integrationData.Exam_Location_Country__c = RequestJson.Envelope.Body.resultNotificationRequest.testCenter.testCenterAddress.country;
        integrationData.Exam_Location_City__c = RequestJson.Envelope.Body.resultNotificationRequest.testCenter.testCenterAddress.city;
        integrationData.Exam_Location_State__c = RequestJson.Envelope.Body.resultNotificationRequest.testCenter.testCenterAddress.state;
        integrationData.Exam_Location_Postal_Code__c = RequestJson.Envelope.Body.resultNotificationRequest.testCenter.testCenterAddress.postalCode;
        integrationData.Pearson_Vue_Appointment_ID__c = RequestJson.Envelope.Body.resultNotificationRequest.vueAppointmentID;
        integrationData.Results__c = RequestJson.Envelope.Body.resultNotificationRequest.exams.exam.examResult.grade;
        integrationData.Registration_Status__c = 'Active';
        return integrationData;
    }

    public Static Integration_Data__c getcancelAppointmentRequest(PearsonInboundRequestJsonParser RequestJson,Integration_Data__c integrationData){
        integrationData.Pearson_Event_Time__c = geteventDatetimeformat(RequestJson.Envelope.Body.CancelAppointmentRequest.eventTime);        
        integrationData.Pearson_Vue_Appointment_ID__c =RequestJson.Envelope.Body.CancelAppointmentRequest.vueAppointmentID; 
        integrationData.Pearson_Event_Type__c ='Cancel Appointment'; 
        integrationData.Pearson_Event_NotificationID__c=RequestJson.Envelope.Body.CancelAppointmentRequest.eventNotificationID;
        integrationData.Registration_Status__c = 'Canceled'; 
        integrationData.Scheduled_Date_Time__c =null;
        integrationData.Location_Address__c =null;
        integrationData.Exam_Location_City__c =null;
        integrationData.Exam_Location_Postal_Code__c =null;
        integrationData.Exam_Location_State__c =null;
        integrationData.Location_Name__c =null;
        integrationData.Pearson_vue_Test_CenterID__c =null;
        integrationData.Exam_Location_Country__c =null;
        

        return integrationData;
    }
    
    public Static DateTime getDatetimeformat(String dttime,String offset){
        DateTime dt = system.now();
        if(dttime != null && offset != null){ 
        String offset1 = dttime.substring(20,22); 
            string addremovemin = offset.substring(0,1);
            string addremovemin1 = offset.substring(3,5);
        integer min = integer.valueOf(addremovemin+''+addremovemin1);
        integer hours = integer.valueof(offset.substring(0,3)) + integer.valueOf(offset1); 
        dt = DateTime.Valueof(dttime.replace('T', ' ')).addhours(hours); 
             
          dt =  dt.addminutes(min);
        } 
        return dt;
    }
    public Static DateTime geteventDatetimeformat(String dttime){
        DateTime dt = system.now();
        if(dttime != null){ 
            dt = DateTime.ValueofGMT(dttime.replace('T', ' ')); 
        } 
        return dt;
    }
    
    
   
}