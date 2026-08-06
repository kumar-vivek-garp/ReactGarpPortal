@Restresource(urlmapping='/ATANotifyRegistration/*')
global class ATA_NotifyRegistrationClass {
    @httpPost
    global static void ATA_NotifyRegistrationPost(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        try{
            string jsonString = req.requestBody.tostring();  
            ATA_NotifyRegistrationResponse ataevent = ATA_NotifyRegistrationResponse.parse(jsonString); 
            String body = JSON.serialize(jsonString);
            Blob input = Blob.valueOf(body);
           boolean isvalidSign = verifySignature(ataevent);
            if(isvalidSign == true || Test.isRunningTest()){
                Integration_Data__c intdata = new Integration_Data__c(); 
                Id ATARecordTypeId = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('ATA').getRecordTypeId();
                List<Integration_Data__c> integrationdataList = new List<Integration_Data__c>();
                
                Set<Id> intdataId = new Set<Id>(); 
                String eventdata = ataevent.event_data; 
                if(ataevent.event_type == 'reservation'){
                    ATA_NotifyRegistrationResponse.reservation reg = (ATA_NotifyRegistrationResponse.reservation)JSON.deserialize(eventdata, ATA_NotifyRegistrationResponse.reservation.class);
                    //system.debug(reg.batch_no);
                    integrationdataList = [Select Id,Exam_Registrations__r.Cancelled__c from Integration_Data__c  where Garp_Id__c =: reg.reg_code and ATA_Outbound_Batch_Code__c =:reg.batch_no and ATA_subject_code__c =:reg.subject_code and Is_Active__c =true and RecordTypeId =:ATARecordTypeId and Exam_Registrations__r.Cancelled__c = false];
                    
                    if(!integrationdataList.isEmpty()){
                        for(Integration_Data__c indata:integrationdataList){
                            intdataId.add(indata.Id);
                        } 
                        List<Integration_Data__c> activeintegrationdataList = ATAPSIUtilClass.cloneActiveIntegrationData(intdataId);
                        intdata = activeintegrationdataList[0];
                        Map<Id,Decimal> integrationdatavertionMap = ATAPSIUtilClass.getLatestVersionIntegritaion(intdata.Exam_Registrations__c);
                        if(integrationdatavertionMap.containsKey(intdata.Exam_Registrations__c))
                            intdata.Version_Number__c = integrationdatavertionMap.get(intdata.Exam_Registrations__c)+1;
                        
                        intdata.Name = 'ATA Notify Registration' + intdata.Version_Number__c;
                        intdata.ATA_event_id__c = ataevent.event_id;
                        intdata.ATA_event_type__c = ataevent.event_type;
                        intdata.ATA_Inbound_Reg_Code__c = reg.reg_code;
                        //intdata.ATA_Cert_type__c = reg.cert_type;  
                       // intdata.ATA_Cert_id__c = reg.cert_id;
                        intdata.ATA_Exam_start_time__c = reg.start_time;
                        intdata.ATA_Exam_end_time__c = reg.end_time;
                        intdata.ATA_Inbound_Region_code__c = reg.region_code;
                        intdata.ATA_Inbound_Region_name__c = reg.region_name;
                        intdata.ATA_Inbound_Subject_code__c = reg.subject_code;
                        intdata.ATA_Inbound_Subject_name__c = reg.subject_name;
                        intdata.ATA_Inbound_Batch_Code__c = reg.batch_no;
                        intdata.ATA_Test_center_name__c = reg.org_name;
                        intdata.ATA_Test_center_address__c = reg.org_address;
                        intdata.ATA_Test_room_name__c = reg.room_name;
                        intData.ATA_Exam_Language__c  = reg.exam_language;
                        intdata.ATA_Reservation_time__c = reg.reservation_at;
                        intdata.ATA_Seat_number__c = reg.client_id;
                        intdata.Call_out_Type__c = 'In-bound';
                        if(reg.start_time != null){
                            intdata.ATA_Booking_Local_Time__c = ataDateTimeConverter(reg.start_time);
                        }
                    }
                }else if(ataevent.event_type == 'cancel_reservation'){
                    ATA_NotifyRegistrationResponse.cancelreservation cancelreg = (ATA_NotifyRegistrationResponse.cancelreservation)JSON.deserialize(eventdata, ATA_NotifyRegistrationResponse.cancelreservation.class);
                    //system.debug(cancelreg.batch_no);
                    integrationdataList = [Select Id,Exam_Registrations__r.Cancelled__c from Integration_Data__c  where Garp_Id__c =: cancelreg.reg_code and ATA_Outbound_Batch_Code__c =:cancelreg.batch_no  and Is_Active__c =true and RecordTypeId =:ATARecordTypeId and Exam_Registrations__r.Cancelled__c = false and ATA_subject_code__c =:cancelreg.subject_code];
                    if(!integrationdataList.isEmpty()){
                        for(Integration_Data__c indata:integrationdataList){
                            intdataId.add(indata.Id);
                        } 
                        List<Integration_Data__c> activeintegrationdataList = ATAPSIUtilClass.cloneActiveIntegrationData(intdataId);
                        intdata = activeintegrationdataList[0];
                        Map<Id,Decimal> integrationdatavertionMap = ATAPSIUtilClass.getLatestVersionIntegritaion(intdata.Exam_Registrations__c);
                        if(integrationdatavertionMap.containsKey(intdata.Exam_Registrations__c))
                            intdata.Version_Number__c = integrationdatavertionMap.get(intdata.Exam_Registrations__c)+1;
                        
                        intdata.Name = 'ATA Notify Registration' + intdata.Version_Number__c;
                        intdata.ATA_event_id__c = ataevent.event_id;
                        intdata.ATA_event_type__c = ataevent.event_type;
                        intdata.ATA_Inbound_Reg_Code__c = cancelreg.reg_code;
                        //intdata.ATA_Cert_type__c = cancelreg.cert_type;  
                       // intdata.ATA_Cert_id__c = cancelreg.cert_id;    
                        intdata.ATA_Inbound_Subject_code__c = cancelreg.subject_code;
                        intdata.ATA_Inbound_Subject_name__c = cancelreg.subject_name;
                        intdata.ATA_Inbound_Batch_Code__c = cancelreg.batch_no;
                        intdata.ATA_Time_of_cancelation__c = cancelreg.cancel_reservation_at;
                        intdata.ATA_Admission_Ticket_Number__c = cancelreg.exam_cert_no;
                        intdata.Call_out_Type__c = 'In-bound';
                        intdata.ATA_Booking_Local_Time__c = null;
                        intdata.ATA_Seat_number__c = null;
                        intdata.ATA_reg_time__c = null;
                        intdata.ATA_Reservation_time__c = null;
                        intdata.ATA_Exam_start_time__c= null;
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
                    }
                } 
                
                if(intdata != null){
                    insert intdata;
                    Api_Transaction__c  apirsp = new Api_Transaction__c(); 
                    apirsp.Name = 'ATA Notify Registration ' + ataevent.event_type;
                    //irsp.Request_Body__c = ; 
                    apirsp.Body__c = jsonString;
                    //arsp.Response_Code__c = reqs.Response.getStatusCode()+'';
                    apirsp.Error__c = ''; 
                    apirsp.Integration_Data__c = intdata.Id; 
                    insert apirsp;
                    if(intdata.Exam_Registrations__c != null){
                        Exam_Attempt__c ex =  new Exam_Attempt__c();
                        ex.Id = intData.Exam_Registrations__c;
                        if(intdata.Is_Active__c ==  true)
                            ex.Active_Integration_Data__c = intdata.Id;
                        
                        Update ex;
                    }
                    intdata = new Integration_Data__c();
                    intdata.Id = integrationdataList[0].Id;
                    intdata.Is_Active__c = false;
                    update intdata;
                }
            }else{
                res.statusCode = 400; 
                res.responseBody = Blob.valueOf('{"error": "string", "error_description": "Invalid Signature"}');
           } 
        }catch(Exception ex){
            res.statusCode = 400; 
            res.responseBody = Blob.valueOf('{"error": "string", "error_description": "Invalid Signature"'+ex.getmessage()+'}');
            system.debug(ex.getMessage());
        }
    }
    
    public static boolean verifySignature(ATA_NotifyRegistrationResponse ataevent){
        String eventdata = JSON.serialize(ataevent.event_data); 
        eventdata = eventdata.replace('\\"', '"');
        eventdata = eventdata.replace('"{', '{');
        eventdata = eventdata.replace('}"', '}');
        //System.debug(eventdata);
        String payload ='event_created_at='+ataevent.event_created_at;
        payload += '&event_data='+eventdata;
        payload += '&event_id='+ataevent.event_id;
        payload += '&event_type='+ataevent.event_type; 
      
    
        //system.debug(payload);
        Boolean isVerified =false;
        List<ATA_Scheduling_Interface__mdt> ataMtd = [Select Id,Public_Key__c from ATA_Scheduling_Interface__mdt where DeveloperName ='ATA_Scheduling_Interface_Setting'];
        if(!ataMtd.isEmpty()){ 
            string realpukey =ataMtd[0].Public_key__c.trim();
            blob realpublicKey = EncodingUtil.base64Decode(realpukey);
            
        blob sign = EncodingUtil.base64Decode(ataevent.sign);
           
         isVerified = Crypto.verify('RSA-SHA1', Blob.valueOf(payload), sign, realpublicKey);
        }
        return isVerified;
    }
    
   public static datetime ataDateTimeConverter(String datetimezone){
        DateTime dta;
        //datetimezone = '2021-11-17T08:00:00+07:00';
        try{ 
            list<String> dt = datetimezone.split('-');
            list<integer> timeComponent = new list<integer>(); 
            timeComponent.add(Integer.valueOf(dt[0].left(4)));
            timeComponent.add(Integer.valueOf(dt[1]));
            timeComponent.add(Integer.valueOf(dt[2].left(2))); 
            String t = dt[2].substringAfterLast('T');  
            list<String> time1 = t.split(':'); 
            timeComponent.add(Integer.valueOf(time1[0]));
            timeComponent.add(Integer.valueOf(time1[1]));
            timeComponent.add(Integer.valueOf(time1[2].left(2))); 
            String timezone = datetimezone.right(6);
            datetime diret;
            String TimeZones = '';
            //system.debug(timezone);
            List<PicklistEntry> entries = Schema.SObjectType.User.fields.TimeZoneSidKey.picklistValues;
            for(PicklistEntry p:entries){
                if(p.getLabel().contains(timezone)) {
                    TimeZones = p.getLabel();
                    break;
                }
            } 
            List<String> lststrsplit = TimeZones.substring(12,TimeZones.length()).split('\\(',2);
            string strTimeZone = lststrsplit[1].substring(0,lststrsplit[1].length()-1); 
            String myDate = DateTime.newInstance(timeComponent[0], timeComponent[1], timeComponent[2], timeComponent[3], timeComponent[4], timeComponent[5]).format('YYYY-MM-dd HH:mm:ss a');
            dta = datetime.valueOf(myDate);
        }catch(exception e){
            system.debug(e.getMessage() +''+ e.getLineNumber());
        }
        return dta;
    }
    
    
}