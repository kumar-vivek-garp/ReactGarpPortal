@Restresource(urlmapping='/BookingEventsService/notifications/*')
global class PSI_BookingEventsServiceNotification{
    
    @httpPut
    global static void eligibilityNotifications(){ 
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            string jsonString = '';
            if(Test.isRunningTest()) {
                     jsonString = '{"candidate_id":"1495704","candidate_fname":"vivek","candidate_lname":"kathi",'+
                         '"candidate_mname":"","client_eligibility_id":"PSI-00000004","exam_code":"ERP1",'+
                         '"booking_code":"HRN4RQN7","location_code":"BMY5N38X","location_name":"QA GARP Test Center",'+
                         '"location_address":"280 Grove St, , Jersey City, New Jersey, USA",'+
                         '"location_timezone":"America/Chicago","booking_on":"2020-08-20T12:30:00.000Z",'+
                         '"effective_date":"2020-08-17T18:59:18.850Z","delivery_mode":"SITE_PROCTORED",'+
                         '"change_reason":"BOOKING_RESCHEDULED"}';
            } else {
                    jsonString = req.requestBody.tostring();
            }
            PSI_BookingEventsServicResponse psires = PSI_BookingEventsServicResponse.parse(jsonString);
            system.debug(psires);  
            Id PSIRecordTypeId = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('PSI').getRecordTypeId();
            system.debug('psires.client_eligibility_id=====>'+psires.client_eligibility_id);
            system.debug('PSIRecordTypeId==================>'+PSIRecordTypeId);
            List<Integration_Data__c> integrationdataList = [Select Id from Integration_Data__c where client_eligibility_id__c =: psires.client_eligibility_id And Is_Active__c =true and RecordTypeId =:PSIRecordTypeId order by createddate desc limit 1];
            System.debug('integrationdataList============>'+integrationdataList);
            if(!integrationdataList.isEmpty()){
                Integration_Data__c intdata = new Integration_Data__c();
                Set<Id> intdataId = new Set<Id>();
                for(Integration_Data__c indata:integrationdataList){
                    intdataId.add(indata.Id);
                } 
                List<Integration_Data__c> activeintegrationdataList = ATAPSIUtilClass.cloneActiveIntegrationData(intdataId);
                intdata = activeintegrationdataList[0]; 
                Map<Id,Decimal> integrationdatavertionMap = ATAPSIUtilClass.getLatestVersionIntegritaion(intdata.Exam_Registrations__c);
                if(integrationdatavertionMap.containsKey(intdata.Exam_Registrations__c))
                   intdata.Version_Number__c = integrationdatavertionMap.get(intdata.Exam_Registrations__c)+1;
                
                intdata.Name = 'PSI Booking Events Service' + intdata.Version_Number__c;
                intdata.PSI_booking_code__c = psires.booking_code;
                intdata.PSI_change_reason__c = psires.change_reason; 
               // intdata.PSI_client_eligibility_id__c = psires.client_eligibility_id;
                
                    intdata.PSI_location_address__c = psires.location_address;
                    intdata.PSI_location_code__c = psires.location_code;
                    intdata.PSI_location_name__c = psires.location_name;
                    intdata.PSI_Address_1__c = psires.address_1;
                    intdata.PSI_Address_2__c = psires.address_2;
                    intdata.PSI_Address_3__c = psires.address_3;
                    intdata.PSI_city__c    = psires.city;
                    intdata.PSI_state__c   = psires.state;
                    intdata.PSI_country__c   = psires.country;
                    intdata.PSI_postal_code__c   = psires.postal_code;
                    intdata.PSI_location_timezone__c = psires.location_timezone;
                    
                    
                    if(intdata.PSI_change_reason__c == 'BOOKING_CANCELLED'){
                    
                    intdata.PSI_location_address__c = null;
                    intdata.PSI_location_code__c = null;
                    intdata.PSI_location_name__c = null;
                    intdata.PSI_Address_1__c = null;
                    intdata.PSI_Address_2__c = null;
                    intdata.PSI_Address_3__c = null;
                    intdata.PSI_city__c    =null;
                    intdata.PSI_state__c   = null;
                    intdata.PSI_country__c   = null;
                    intdata.PSI_postal_code__c   = null;
                    intdata.PSI_location_timezone__c = null;
                    intData.Scheduled_Date_Time__c = null;
                    intData.PSI_Booking_Local_Time__c = null;
                }
                
                intdata.PSI_booking_on__c = psires.booking_on;
                intdata.PSI_delivery_mode__c = psires.delivery_mode;  
                intdata.Call_out_Type__c = 'In-bound'; 
                if(intdata.PSI_booking_on__c != null && intdata.PSI_location_timezone__c != null){ 
                    intdata.PSI_Booking_Local_Time__c = getdatetimezoneconvert(intdata.PSI_booking_on__c,intdata.PSI_location_timezone__c); 
                }
                
                insert intdata;
                Api_Transaction__c  apirsp = new Api_Transaction__c(); 
                apirsp.Name = 'PSI Booking Events Service';
                //irsp.Request_Body__c = ; 
                apirsp.Body__c = jsonString;
                //arsp.Response_Code__c = reqs.Response.getStatusCode()+'';
                apirsp.Error__c = ''; 
                apirsp.Integration_Data__c = intdata.Id; 
                insert apirsp;
                if(intdata.Exam_Registrations__c != null){
                    Exam_Attempt__c ex =  new Exam_Attempt__c();
                    ex.Id = intdata.Exam_Registrations__c;
                    if(intdata.Is_Active__c ==  true)
                        ex.Active_Integration_Data__c = intdata.Id;
                    
                    Update ex;
                }
                intdata = new Integration_Data__c();
                intdata.Id = integrationdataList[0].Id;
                intdata.Is_Active__c = false;
                update intdata;
                system.debug('=========BEFORE============');
                res.responseBody = Blob.valueOf('{"booking_code":'+psires.booking_code+'}'); 
                res.statusCode = 200; 
                system.debug('+psires.booking_code=====>'+psires.booking_code);
            }
            else {  
                
                res.statusCode = 400; 
                res.responseBody = Blob.valueOf('{"error": "string", "error_description": "client_eligibility_id Not Found"}');
            }
        }catch(Exception ex){ 
            system.debug('=========CATCH=========>'+ex.getMessage());
            res.statusCode = 500; 
            system.debug('+psires.booking_code=====>'+ex.getMessage());
            res.responseBody = Blob.valueOf('{"error": "string", "error_description": "'+ex.getMessage()+'"}');
        }
    }
    
    public Static Datetime getdatetimezoneconvert(String datetimezone,String timezone){ 
        try{
            if(datetimezone != null && timezone != null){
                //datetimezone = '2021-05-11T02:30:00.000Z'; 
                list<String> dt = datetimezone.split('-');
                list<integer> timeComponent = new list<integer>(); 
                timeComponent.add(Integer.valueOf(dt[0].left(4)));
                timeComponent.add(Integer.valueOf(dt[1]));
                timeComponent.add(Integer.valueOf(dt[2].left(2))); 
                String t = dt[2].substringBetween('T','.'); 
                list<String> time1 = t.split(':');
                timeComponent.add(Integer.valueOf(time1[0]));
                timeComponent.add(Integer.valueOf(time1[1]));
                timeComponent.add(Integer.valueOf(time1[2])); 
                String myDate = DateTime.newInstanceGMT(timeComponent[0], timeComponent[1], timeComponent[2], timeComponent[3], timeComponent[4], timeComponent[5]).format('yyyy-MM-dd HH:mm:ss a Z',timezone);
                DateTime dta = datetime.valueOf(myDate);
                return dta;
            }
        }catch(Exception e){}
        return null; 
    }
    
}