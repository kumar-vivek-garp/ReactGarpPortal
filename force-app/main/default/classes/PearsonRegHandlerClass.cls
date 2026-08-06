public class PearsonRegHandlerClass {
    
    Static Id PearsonrecId = RecordTypeHelper.getRecordTypeIdFromSchema('Integration_Data__c','Pearson');
    
    public static Boolean isFirstRun = true;
    public static Map<String,Pearson_Exam_Series_Configuration__mdt> PearsonSectionTypeConfigMap = IntegrationsMtdUtil.getBySectionConfiguration();
    public static void createPearsonVueRequests(List<Exam_Attempt__c> attempts,Map<Id,Exam_Attempt__c> oldMapObject) {
        try{
            isFirstRun = false;
            Set<Id> examRegIds = new Set<Id>();
            Map<ID,Exam_Attempt__c> attemptMap = new Map<ID,Exam_Attempt__c>();
            Map<Id,Exam_Attempt__c> examMap = new Map<Id,Exam_Attempt__c>();
            Map<String,String> stateMap = GARP_Common.getStateCodeMap();
            for(Exam_Attempt__c ea : attempts){ //Chinnapa
                //if(ea.Section__c == 'SCR' || ea.Section__c == 'RiskAI' || ea.Section__c == 'ICBRR'){
                if(ea.Section__c != null && PearsonSectionTypeConfigMap.containsKey(ea.Section__c)){
                    attemptMap.put(ea.id,ea);
                    Exam_Attempt__c oldea = oldMapObject.get(ea.Id);
                    if(ea.Pearson_Phone_No__c != oldea.Pearson_Phone_No__c                      ||
                       ea.Pearson_Member_First_Name__c != oldea.Pearson_Member_First_Name__c    ||
                       ea.Pearson_Member_Last_Name__c != oldea.Pearson_Member_Last_Name__c      ||
                       ea.Pearson_Member_Middle_Name__c != oldea.Pearson_Member_Middle_Name__c  ||
                       ea.Pearson_Email__c != oldea.Pearson_Email__c                            ||
                       ea.Billing_Street__c != oldea.Billing_Street__c                          ||
                       ea.Billing_State__c != oldea.Billing_State__c                            ||
                       ea.Billing_City__c != oldea.Billing_City__c                              ||
                       ea.Billing_Country__c != oldea.Billing_Country__c                          ||
                       ea.Billing_Postal_Code__c != oldea.Billing_Postal_Code__c                ||
                       ea.Cancelled__c != oldea.Cancelled__c                                    ||
                       ea.Defered__c != oldea.Defered__c                                        ||
                       (ea.Integration_Type__c != null && ea.Integration_Type__c != oldea.Integration_Type__c)                     ||
                       (ea.Pearson_Accommodation_Type__c != oldea.Pearson_Accommodation_Type__c && ea.Pearson_Accommodation_Type_Status__c == 'Approved')  ||
                       (ea.Pearson_Accommodation_Type__c != null && ea.Pearson_Accommodation_Type_Status__c == 'Approved' && oldea.Pearson_Accommodation_Type_Status__c !='Approved')  ||
                       (ea.Second_Attempt_Pearson__c == true && oldea.Second_Attempt_Pearson__c == false)
                      ){
                          examRegIds.add(ea.Id);
                      }
                }
            }
            List<Integration_Data__c> PearsonVueDataList = new List<Integration_Data__c>();
            List<Integration_Data__c> OldPearsonVueDataList = new List<Integration_Data__c>();
            set<Id> activePearsonIds = new set<Id>();
            Map<Id,Id> oldRegMap = new Map<Id,Id>();
            
            for(Exam_Attempt__c et : [Select Id,Candidate_Commitment__r.ContractNumber,Candidate_Commitment__r.StartDate,
                                      Candidate_Commitment__r.EndDate,Exam_Part__r.Exam_Start_Date__c,
                                      Exam_Part__r.Exam_End_Date__c from Exam_Attempt__c where Id IN: attemptMap.keyset()]){
                                          examMap.put(et.id,et);
                                      }
            if(examRegIds.size()>0){
                for(Integration_Data__c ps : [SELECT Id,Pearson_Vue_Candidate_ID__c, Version_Number__c,Is_Active__c, Exam_Registrations__c, Registration_Status__c 
                                              FROM Integration_Data__c 
                                              WHERE Exam_Registrations__c In:examRegIds and Is_Active__c = true Order By Version_Number__c Desc]){
                                                  if(!oldRegMap.containsKey(ps.Exam_Registrations__c))
                                                      activePearsonIds.add(ps.Id);
                                                  
                                                  oldRegMap.put(ps.Exam_Registrations__c, ps.Id);
                                                  if(ps.Is_Active__c == true){
                                                      ps.Registration_Status__c = 'Not-Valid'; 
                                                      ps.Is_Active__c = false;
                                                      OldPearsonVueDataList.add(ps);
                                                  }
                                              }
            }
            List<Integration_Data__c> PearsonActiveCloneList = cloneActiveRecord(activePearsonIds);
            for(Integration_Data__c ps: PearsonActiveCloneList){
                if(attemptMap.containsKey(ps.Exam_Registrations__c)){
                    Exam_Attempt__c ea = attemptMap.get(ps.Exam_Registrations__c);
                    Exam_Attempt__c oldea = oldMapObject.get(ps.Exam_Registrations__c);
                    if(ea.Section__c == 'SCR' || ea.Section__c == 'RiskAI' || ea.Section__c == 'RAIJ'){
                        ps.eligibilityApptDateFirst__c = datetimeformat(examMap.get(ps.Exam_Registrations__c).Exam_Part__r.Exam_Start_Date__c);  
                        ps.eligibilityApptDateLast__c = datetimeformat(examMap.get(ps.Exam_Registrations__c).Exam_Part__r.Exam_End_Date__c);
                    }else { 
                        ps.eligibilityApptDateFirst__c = datetimeformat(examMap.get(ps.Exam_Registrations__c).Candidate_Commitment__r.StartDate); 
                        ps.eligibilityApptDateLast__c = datetimeformat(examMap.get(ps.Exam_Registrations__c).Candidate_Commitment__r.EndDate);  
                    }
                    ps.First_Name__c = ea.Pearson_Member_First_Name__c; 
                    ps.Last_Name__c = ea.Pearson_Member_Last_Name__c != null?ea.Pearson_Member_Last_Name__c:'.';
                    ps.Middle_Name__c = ea.Pearson_Member_Middle_Name__c;
                    ps.Email__c = ea.Pearson_Email__c; 
                    if(ea.Garp_Id__c != null){
                        ps.Garp_Id__c = ea.Garp_Id__c.leftPad(8, '0');
                    }
                    if(ps.Version_Number__c != null)
                        ps.Version_Number__c = ps.Version_Number__c+1;
                    ps.Address_Type__c = 'Work'; 
                    ps.Call_out_Type__c = 'Out-bound';
                    ps.Created_From__c = 'Contract Change';
                    
                    if(ea.Second_Attempt_Pearson__c == true && oldea.Second_Attempt_Pearson__c == false){
                        ps.Pearson_Operation_Type__c= null;
                        ps.Pearson_Event_Type__c= null;
                        ps.Pearson_Event_NotificationID__c= null;
                        ps.Pearson_Event_Time__c= null;
                        ps.Appointment_Duration__c= null;
                        ps.Pearson_Appointment_Source__c= null;
                        ps.Pearson_appointmentDisplayTimeZone__c= null;
                        ps.Pearson_AppointmenDisplayTimeZoneUtc__c= null;
                        ps.Pearson_CurrentUtcOffset__c= null;
                        ps.Pearson_vueOrderNo__c= null;
                        ps.ExamDelivered__c= false;
                        ps.Assesment_Type__c= null;
                        ps.Scheduled_Date_Time__c= null;
                        ps.Exam_Status__c= null;
                        ps.Location_Name__c= null;
                        ps.Pearson_vue_Test_CenterID__c= null;
                        ps.Location_Address__c= null;
                        ps.Exam_Location_Country__c= null;
                        ps.Exam_Location_City__c= null;
                        ps.Exam_Location_State__c= null;
                        ps.Exam_Location_Postal_Code__c= null;
                        ps.Results__c= null;
                    }
                    ps.Name = examMap.get(ps.Exam_Registrations__c).Candidate_Commitment__r.ContractNumber +' - '+ ps.Version_Number__c;  
                    ps.Registration_Status__c = 'Not-Valid'; 
                    ps.Last_updated_Time__c = system.now();
                    ps.Authorization_Type__c = 'Add';
                    if((ps.Is_Active__c == true && ps.Pearson_Vue_Candidate_ID__c != null && ps.Pearson_Vue_Candidate_ID__c !='') || 
                       (ea.Pearson_Accommodation_Type__c != null && ea.Pearson_Accommodation_Type_Status__c == 'Approved')){  
                           ps.Authorization_Type__c = 'Update';
                           ps.Outbound_Event_Types__c = 'EAD';
                       }
                    if(ea.Cancelled__c == true|| ea.Defered__c == 'Pending'){
                        ps.Authorization_Type__c = 'Delete'; 
                        ps.Outbound_Event_Types__c = 'EAD';
                    }
                    
                    if((ea.Integration_Type__c == 'Ping Database;CDD;EAD' && oldea.Integration_Type__c != 'Ping Database;CDD;EAD')||(ea.Cancelled__c == false && ea.Defered__c != 'Pending' && oldea.defered__c != ea.defered__c)|| (ea.Second_Attempt_Pearson__c == true && oldea.Second_Attempt_Pearson__c == false)){
                        ps.Pearson_Vue_Candidate_ID__c = null; 
                        if(ea.Integration_Type__c == 'Ping Database;CDD;EAD' && oldea.Integration_Type__c != 'Ping Database;CDD;EAD')
                            ps.Outbound_Event_Types__c  = 'Ping Database;CDD;EAD';
                        	ps.Authorization_Type__c = 'Add';
                    }
                    
                    if(ea.Integration_Type__c == 'EAD' && oldea.Integration_Type__c != 'EAD'){
                        ps.Pearson_Vue_Candidate_ID__c = null;
                        ps.Outbound_Event_Types__c  = 'EAD';
                        ps.Authorization_Type__c = 'Add';
                    }
                    
                    if(ea.Integration_Type__c == 'Delete' && oldea.Integration_Type__c != 'Delete'){
                        ps.Outbound_Event_Types__c  = 'EAD';
                        ps.Authorization_Type__c = 'Delete';
                    }
                    
                    if(ea.Integration_Type__c == 'CDD' && oldea.Integration_Type__c != 'CDD'){
                        ps.Outbound_Event_Types__c  = 'CDD';
                        ps.Authorization_Type__c = 'Update';
                        ps.Is_Canddiate_Info_Changed__c  = false;
                    }
                    
                    if((ea.Pearson_Phone_No__c != oldea.Pearson_Phone_No__c                   || 
                        ea.Pearson_Member_First_Name__c != oldea.Pearson_Member_First_Name__c || 
                        ea.Pearson_Member_Last_Name__c != oldea.Pearson_Member_Last_Name__c   || 
                        ea.Pearson_Member_Middle_Name__c != oldea.Pearson_Member_Middle_Name__c   || 
                        ea.Pearson_Email__c != oldea.Pearson_Email__c                           || 
                        ea.Billing_Street__c != oldea.Billing_Street__c                       || 
                        ea.Billing_postal_code__c != oldea.Billing_postal_code__c             || 
                        ea.Billing_country__c != oldea.Billing_country__c                     || 
                        ea.Billing_State__c != oldea.Billing_State__c                         || 
                        ea.Billing_City__c != oldea.Billing_City__c)                                 
                      ){                   
                          ps.Outbound_Event_Types__c  = 'CDD';
                          ps.Is_Canddiate_Info_Changed__c  = true;
                          ps.Authorization_Type__c = 'Update';
                      }else{
                          ps.Is_Canddiate_Info_Changed__c  = false;
                      } 
                    ps.Call_out_Status__c = 'Initial';
                    // Mapping Address info
                    CountryCodes__c countryCodes = CountryCodes__c.getValues(ea.Billing_country__c);
                    ps.Country__c = countryCodes != null  ? countryCodes.ISOCode__c : 'USA';
                    PS.Phone_Country_Code__c = countryCodes != null ? countryCodes.PhoneCode__c : '1';
                    string stateName; 
                    if(ea.Billing_State__c != null){
                       stateName  = GARP_Common.convertLongStateToCode(stateMap, ea.Billing_State__c);
                    } 
                    ps.State__c = (stateName != null && stateName.length() >50)? Utilities.replaceChars(stateName).substring(0,50):Utilities.replaceChars(stateName);
                    ps.Address_1__c = (ea.Billing_Street__c != null && ea.Billing_Street__c.length() > 40)?Utilities.replaceChars(ea.Billing_Street__c).substring(0,40):Utilities.replaceChars(ea.Billing_Street__c);
                    ps.Postal_Code__c = ea.Billing_postal_code__c; 
                    ps.City__c = (ea.Billing_City__c != null && ea.Billing_City__c.length() > 32) ?Utilities.replaceChars(ea.Billing_City__c).substring(0,32):Utilities.replaceChars(ea.Billing_City__c);
                    if(ea.Pearson_Phone_No__c != null){
                        if((ps.Country__c == 'USA' || ps.Country__c == 'CAN') && ea.Pearson_Phone_No__c.startsWith('1')){
                            ps.phone_Number__c = ea.Pearson_Phone_No__c.removeStart('1');
                        }else{
                            ps.phone_Number__c = ea.Pearson_Phone_No__c;
                        }                       
                    }else{
                        ps.phone_Number__c = '2017197210';
                    } 
                    ps.RecordTypeId = PearsonrecId;
                    PearsonVueDataList.add(ps);
                }
            }
            
            Map<Id,Decimal> getVersionNumerMap = new Map<Id,Decimal>(); 
            for(AggregateResult inag:[Select Exam_Registrations__c,count(Id) intcount from Integration_Data__c 
                                      WHERE Exam_Registrations__c In:attemptMap.keyset() group by Exam_Registrations__c Limit 2000]){  
                                          Id exaId = (id) inag.get('Exam_Registrations__c'); 
                                          Integer intres = (Integer) inag.get('intcount');     
                                          getVersionNumerMap.put(exaId,intres); 
                                      }
            
            for(Exam_Attempt__c ea : attempts){
                //if(ea.Section__c == 'SCR' || ea.Section__c == 'RiskAI' || ea.Section__c == 'ICBRR'){
                if(PearsonSectionTypeConfigMap.containsKey(ea.Section__c)){
                   if(ea.Integration_Type__c == 'Ping Database;CDD;EAD' && oldMapObject.get(ea.Id).Integration_Type__c != 'Ping Database;CDD;EAD' && !oldRegMap.containskey(ea.Id)){
                        Integration_Data__c PearsonVueData = new Integration_Data__c();
                        PearsonVueData.RecordTypeId = PearsonrecId;
                        PearsonVueData.Exam_Registrations__c = ea.Id;
                        PearsonVueData.Contract__c = ea.Candidate_Commitment__c;
                        PearsonVueData.Registration_Status__c = 'Not-Valid';
                        PearsonVueData.Created_From__c = 'Contract Initial'; 
                        PearsonVueData.Call_out_Status__c = 'Initial';
                        PearsonVueData.Is_Canddiate_Info_Changed__c  = false;
                        PearsonVueData.Call_out_Type__c = 'Out-bound';
                        PearsonVueData.Authorization_Type__c = 'Add';  
                        if(getVersionNumerMap.containsKey(ea.Id)){
                            PearsonVueData.Version_Number__c = getVersionNumerMap.get(ea.Id) +1;   
                        }else{
                            PearsonVueData.Version_Number__c = 1; 
                        }
                        PearsonVueData.Address_Type__c = 'Work';
                        PearsonVueData.Outbound_Event_Types__c  = 'Ping Database;CDD;EAD';
                        PearsonVueData.Last_updated_Time__c = system.now();
                        PearsonVueData.Name = examMap.get(ea.id).Candidate_Commitment__r.ContractNumber + ' - ' + PearsonVueData.Version_Number__c;
                        if(ea.Garp_Id__c != null){
                            PearsonVueData.Garp_Id__c = ea.Garp_Id__c.leftPad(8, '0');
                        }
                         if(ea.Section__c == 'SCR' || ea.Section__c == 'RiskAI' || ea.Section__c == 'RAIJ'){
                            PearsonVueData.eligibilityApptDateFirst__c = datetimeformat(examMap.get(ea.id).Exam_Part__r.Exam_Start_Date__c);  
                            PearsonVueData.eligibilityApptDateLast__c = datetimeformat(examMap.get(ea.id).Exam_Part__r.Exam_End_Date__c); 
                        }else if(examMap.get(ea.id).Candidate_Commitment__r.StartDate != null && examMap.get(ea.id).Candidate_Commitment__r.EndDate != null){
                            PearsonVueData.eligibilityApptDateFirst__c = datetimeformat(examMap.get(ea.id).Candidate_Commitment__r.StartDate);  
                            PearsonVueData.eligibilityApptDateLast__c = datetimeformat(examMap.get(ea.id).Candidate_Commitment__r.EndDate); 
                        }
                        
                        //Mapping candidate Info 
                        PearsonVueData.First_Name__c = ea.Pearson_Member_First_Name__c; 
                        PearsonVueData.Last_Name__c = ea.Pearson_Member_Last_Name__c != null?ea.Pearson_Member_Last_Name__c:'.';
                        PearsonVueData.Middle_Name__c = ea.Pearson_Member_Middle_Name__c;
                        PearsonVueData.Email__c = ea.Pearson_Email__c;
                        
                        // Mapping Address info
                        CountryCodes__c countryCodes = CountryCodes__c.getValues(ea.Billing_Country__c);
                        PearsonVueData.Country__c = countryCodes != null ? countryCodes.ISOCode__c : 'USA';
                        PearsonVueData.Phone_Country_Code__c = countryCodes != null ? countryCodes.PhoneCode__c : '1';
                        //PearsonVueData.Country__c = 'USA';
                        string stateName;
                        if(ea != null){
                            stateName  = GARP_Common.convertLongStateToCode(stateMap, ea.Billing_State__c);
                        }
                        PearsonVueData.State__c = (stateName != null && stateName.length() >50)? Utilities.replaceChars(stateName).substring(0,50):Utilities.replaceChars(stateName);
                        PearsonVueData.Address_1__c = (ea.Billing_Street__c != null && ea.Billing_Street__c.length()>40)?Utilities.replaceChars(ea.Billing_Street__c).substring(0,40):Utilities.replaceChars(ea.Billing_Street__c); 
                        PearsonVueData.Postal_Code__c = ea.Billing_postal_code__c;
                        PearsonVueData.City__c = (ea.Billing_City__c != null && ea.Billing_City__c.length()>32)?Utilities.replaceChars(ea.Billing_City__c).substring(0,32):Utilities.replaceChars(ea.Billing_City__c);
                        
                        if(PearsonSectionTypeConfigMap.containsKey(ea.Section__c)){
                            PearsonVueData.Exam_Type__c = PearsonSectionTypeConfigMap.get(ea.Section__c).Exam_Type__c;
                        }                        
                        /*if(ea.Section__c == 'SCR'){
                            PearsonVueData.Exam_Type__c = 'SCR';
                        }
                        if(ea.Section__c == 'RiskAI'){
                            PearsonVueData.Exam_Type__c = 'GARPRandAI';
                        }
                        if(ea.Section__c == 'ICBRR'){
                            PearsonVueData.Exam_Type__c = 'FRR';  
                        }*/
                        
                        
                        if(ea.Pearson_Phone_No__c != null){
                            if((PearsonVueData.Country__c == 'USA' || PearsonVueData.Country__c == 'CAN') && ea.Pearson_Phone_No__c.startsWith('1')){
                                PearsonVueData.phone_Number__c = ea.Pearson_Phone_No__c.removeStart('1');
                            }else{
                                PearsonVueData.phone_Number__c = ea.Pearson_Phone_No__c;
                            }                       
                        }else{
                            PearsonVueData.phone_Number__c = '2017197210';
                        }
                        PearsonVueDataList.add(PearsonVueData);
                    }
                }
            }
            
            if(OldPearsonVueDataList.size()>0){
                upsert OldPearsonVueDataList;
            }
            if(PearsonVueDataList.size()>0){
                insert PearsonVueDataList;
            }
            
            //callout
            set<Id> PearsonId = new set<Id>();
            for(Integration_Data__c p:PearsonVueDataList){
                PearsonId.add(p.Id);
            }
            if(PearsonId.size()>0){
                if(system.isBatch()){
                    ID jobID = System.enqueueJob(new PearsonVueCallOutQueueable(PearsonId));
                }else{
                    PearsonVueRTIDataHelper.PearsonVueDatacallout(PearsonId);
                }
                /*List<Integration_Stream_Event__e> evts = TriggerUtilities.getIntgEvents(PearsonId, 'Contract', 'PearsonVue');
EventBus.publish(evts);*/
                
            }
            
        }catch(exception ex){
            
        }
    }
    
    public static string datetimeformat(Date dt){
        String dtformat;
        if(dt != null){
            Datetime dttime = datetime.newInstance(dt.year(), dt.month(),dt.day()); 
            dtformat = dttime.format('YYYY/MM/dd HH:mm:ss');
        }
        return dtformat;
    }
    
    public static List<Integration_Data__c> cloneActiveRecord(Set<Id> PearsonIds){ 
        List<Integration_Data__c> PearsonActierec = new List<Integration_Data__c>(); 
        if(PearsonIds.size()>0){
            List<String> fields = new List<String>();
            fields.addAll(Integration_Data__c.getsObjectType().getDescribe().fields.getMap().keySet());
            String soql = 'SELECT ' + String.join(fields, ',') +
                ' FROM Integration_Data__c WHERE Id IN: PearsonIds ';
            PearsonActierec = Database.query(soql).deepclone(false,false,false); 
        }
        return PearsonActierec;
    }
}