public class ScrContractTriggerHelper {
    // will have to come back on country code
    
    Static Id SCRRecId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');  
    Static Id RiskAIRecId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_AI_Program'); 
    Static Id RAIJRecId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','RAIJ_Program'); 
    Static Id ICBRRRecId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ICBRR_Program'); 
    Static Id PearsonrecId = RecordTypeHelper.getRecordTypeIdFromSchema('Integration_Data__c','Pearson'); 
     
   public static Map<String,Pearson_Exam_Series_Configuration__mdt> pearsonPrgConfigMap = IntegrationsMtdUtil.getByProgramTypeConfiguration();
    public static Boolean isFirstRun = true;
    
    public static void createPearsonVueData(List<Contract> Contracts,Map<Id,Contract> oldMapObject) {
        try{
            isFirstRun = false;
            set<Id> contractIds = new set<Id>();
            Map<ID,Contract> ContractMap = new Map<ID,Contract>();
            for(Contract con:Contracts){
                Contract oldcon = oldMapObject.get(con.Id);
                //system.debug(con);
                // system.debug( oldMapObject.get(con.Id));
                //if(con.RecordTypeId == SCRRecId || con.RecordTypeId == RiskAIRecId || con.RecordTypeId == ICBRRRecId){
                if(pearsonPrgConfigMap.containsKey(con.RecordTypeId)){
                    ContractMap.put(con.Id,con);
                    if(((con.Status =='Activated' && oldcon.Status !='Activated') || 
                        (con.Status =='Canceled' && oldcon.Status !='Canceled'))                   || 
                       ((con.Pearson_Phone_No__c != oldcon.Pearson_Phone_No__c                     || 
                         con.Pearson_Member_First_Name__c != oldcon.Pearson_Member_First_Name__c    || 
                         con.Pearson_Member_Last_Name__c != oldcon.Pearson_Member_Last_Name__c      ||
                         con.Pearson_Member_Middle_Name__c != oldcon.Pearson_Member_Middle_Name__c  ||
                         con.BillingStreet != oldcon.BillingStreet                                  ||
                         con.SCR_Deferred_Status__c != oldcon.SCR_Deferred_Status__c                ||
                         con.Billingpostalcode != oldcon.Billingpostalcode                          ||
                         con.Billingcountry != oldcon.Billingcountry                                ||
                         con.BillingState != oldcon.BillingState                                    ||
                         con.BillingCity != oldcon.BillingCity                                      || 
                         con.Member_Email__c != oldcon.Member_Email__c                              || 
                         con.SCR_Start_Date__c != oldcon.SCR_Start_Date__c                          ||
                         con.SCR_End_Date__c != oldcon.SCR_End_Date__c                              || 
                         con.ContractTerm != oldcon.ContractTerm                                    ||
                         ((con.Pearson_Accommodation_Type__c != oldcon.Pearson_Accommodation_Type__c && con.Pearson_Accommodation_Type_Status__c =='Approved') || 
                          (con.Pearson_Accommodation_Type__c !=null && con.Pearson_Accommodation_Type_Status__c =='Approved' && oldcon.Pearson_Accommodation_Type_Status__c !='Approved')) ||
                         (con.Second_Attempt_FRR__c == true && oldcon.Second_Attempt_FRR__c == false)) && oldcon.Status !='Canceled'))
                        contractIds.add(con.Id);
                       // system.debug('****:'+contractIds);
                }
            }
            Map<Id,Id> ExamRegistrationsMap = new  Map<Id,Id>();
            for(Exam_Attempt__c examreg:[Select Id,Candidate_Commitment__c,Opportunity_StageName__c,result__c,cancelled__c from Exam_Attempt__c where Candidate_Commitment__c In :ContractMap.keyset() and Opportunity_StageName__c ='closed' and result__c =null and cancelled__c =false Order by CreatedDate Desc]){
                if(!ExamRegistrationsMap.containskey(examreg.Candidate_Commitment__c))
                    ExamRegistrationsMap.put(examreg.Candidate_Commitment__c,examreg.Id); 
            }
            List<Integration_Data__c> PearsonVueDataList = new List<Integration_Data__c>();
            List<Integration_Data__c> OldPearsonVueDataList = new List<Integration_Data__c>();
            set<Id> activePearsonIds = new set<Id>();
            Map<Id,Id> oldContractMap = new Map<Id,Id>();
            if(contractIds.size()>0){
                for(Integration_Data__c ps:[
                    SELECT Id,Pearson_Vue_Candidate_ID__c, Version_Number__c,Is_Active__c, Contract__c, Registration_Status__c 
                    FROM Integration_Data__c 
                    WHERE Contract__c In:contractIds Order By Version_Number__c Desc]){  
                        if(!oldContractMap.containsKey(ps.Contract__c))
                            activePearsonIds.add(ps.Id);
                        
                        oldContractMap.put(ps.Contract__c, ps.Id);
                        if(ps.Is_Active__c == true){
                            ps.Registration_Status__c = 'Not-Valid'; 
                            ps.Is_Active__c = false;
                            OldPearsonVueDataList.add(ps);
                        }
                    }
            }
            List<Integration_Data__c> PearsonActiveCloneList = cloneActiveRecord(activePearsonIds);
           // system.debug(PearsonActiveCloneList.size());
            for(Integration_Data__c ps: PearsonActiveCloneList){
                if(ContractMap.containsKey(ps.Contract__c)){ 
                    Contract program = ContractMap.get(ps.Contract__c);
                     Contract oldcon = oldMapObject.get(ps.Contract__c);
                    Id rectypeid = program.RecordTypeId;
                    if(rectypeid == ICBRRRecId){ 
                        ps.eligibilityApptDateFirst__c = datetimeformat(program.StartDate); 
                        ps.eligibilityApptDateLast__c = datetimeformat(program.EndDate);  
                    }else if(rectypeid == SCRRecId || rectypeid == RiskAIRecId || rectypeid == RAIJRecId){
                        ps.eligibilityApptDateFirst__c = datetimeformat(program.SCR_Start_Date__c);  
                        ps.eligibilityApptDateLast__c = datetimeformat(program.SCR_End_Date__c);
                    }
                    ps.First_Name__c = program.Pearson_Member_First_Name__c; 
                    ps.Last_Name__c = program.Pearson_Member_Last_Name__c;
                    ps.Middle_Name__c = program.Pearson_Member_Middle_Name__c;
                    ps.Email__c = program.Member_Email__c; 
                      
                    if(program.Garp_Id__c != null){
                        ps.Garp_Id__c = program.Garp_Id__c.leftPad(8, '0');
                    }
                    if(ps.Version_Number__c != null)
                        ps.Version_Number__c = ps.Version_Number__c+1;
                    ps.Address_Type__c = 'Work'; 
                    ps.Call_out_Type__c = 'Out-bound';
                    ps.Created_From__c = 'Contract Change'; 
                    if(ExamRegistrationsMap.containsKey(ps.Contract__c))
                          ps.Exam_Registrations__c = ExamRegistrationsMap.get(ps.Contract__c);
                    
                    if(program.Second_Attempt_FRR__c == true && oldcon.Second_Attempt_FRR__c == false){
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
                    ps.Name = program.ContractNumber +' - '+ ps.Version_Number__c;  
                    ps.Registration_Status__c = 'Not-Valid'; 
                    ps.Last_updated_Time__c = system.now();
                    ps.Authorization_Type__c = 'Add'; 
                     if((ps.Is_Active__c == true && ps.Pearson_Vue_Candidate_ID__c != null && ps.Pearson_Vue_Candidate_ID__c !='') || 
                       (program.SCR_Start_Date__c != oldcon.SCR_Start_Date__c || 
                        program.SCR_End_Date__c != oldcon.SCR_End_Date__c ||
                        (program.Pearson_Accommodation_Type__c != null && program.Pearson_Accommodation_Type_Status__c == 'Approved'))){  
                            ps.Authorization_Type__c = 'Update';
                            ps.Outbound_Event_Types__c = 'EAD';
                        }
                    if(program.status == 'Canceled'|| program.SCR_Deferred_Status__c == 'Pending'){
                        ps.Authorization_Type__c = 'Delete'; 
                        ps.Outbound_Event_Types__c = 'EAD';
                        
                    }
                    if((program.Status == 'Activated' && oldcon.Status != 'Activated')||(program.SCR_Deferred_Status__c != 'Pending' && oldcon.SCR_Deferred_Status__c != program.SCR_Deferred_Status__c)|| (program.Second_Attempt_FRR__c == true && oldcon.Second_Attempt_FRR__c == false)){
                        ps.Pearson_Vue_Candidate_ID__c = null; 
                        if(program.Status == 'Activated' && oldcon.Status != 'Activated')
                            ps.Outbound_Event_Types__c  = 'Ping Database;CDD;EAD';
                        else
                            ps.Outbound_Event_Types__c  = 'EAD';   
                        ps.Authorization_Type__c = 'Add';  
                    }
                    if((program.Pearson_Phone_No__c != oldcon.Pearson_Phone_No__c                   || 
                        program.Pearson_Member_First_Name__c != oldcon.Pearson_Member_First_Name__c || 
                        program.Pearson_Member_Last_Name__c != oldcon.Pearson_Member_Last_Name__c   || 
                        program.Pearson_Member_Middle_Name__c != oldcon.Pearson_Member_Middle_Name__c   || 
                        program.Member_Email__c != oldcon.Member_Email__c                           || 
                        program.BillingStreet != oldcon.BillingStreet                               || 
                        program.Billingpostalcode != oldcon.Billingpostalcode                       || 
                        program.Billingcountry != oldcon.Billingcountry                             || 
                        program.BillingState != oldcon.BillingState                                 || 
                        program.BillingCity != oldcon.BillingCity)                                 
                      ){                   
                          ps.Outbound_Event_Types__c  = 'CDD';
                          ps.Is_Canddiate_Info_Changed__c  = true;
                          ps.Authorization_Type__c = 'Update';
                      }else{
                          ps.Is_Canddiate_Info_Changed__c  = false;
                      } 
                    ps.Call_out_Status__c = 'Initial';
                    // Mapping Address info
                    CountryCodes__c countryCodes = CountryCodes__c.getValues(program.Billingcountry);
                    ps.Country__c = countryCodes != null  ? countryCodes.ISOCode__c : 'USA';
                    PS.Phone_Country_Code__c = countryCodes != null ? countryCodes.PhoneCode__c : '1';
                    // ps.Country__c = 'USA'; 
                    //system.debug(ContractMap.get(ps.Contract__c).BillingState);
                    ps.State__c = (program.BillingState != null && program.BillingState.length() >50)? Utilities.replaceChars(program.BillingState).substring(0,50):Utilities.replaceChars(program.BillingState);
                    ps.Address_1__c = (program.BillingStreet != null && program.BillingStreet.length() > 40)?Utilities.replaceChars(program.BillingStreet).substring(0,40):Utilities.replaceChars(program.BillingStreet);
                    ps.Postal_Code__c = program.Billingpostalcode; 
                    ps.City__c = (program.BillingCity != null && program.BillingCity.length() > 32) ?Utilities.replaceChars(program.BillingCity).substring(0,32):Utilities.replaceChars(program.BillingCity);
                    if(program.Pearson_Phone_No__c != null){
                        if((ps.Country__c == 'USA' || ps.Country__c == 'CAN') && program.Pearson_Phone_No__c.startsWith('1')){
                            ps.phone_Number__c = program.Pearson_Phone_No__c.removeStart('1');
                        }else{
                            ps.phone_Number__c = program.Pearson_Phone_No__c;
                        }                       
                    }else{
                        ps.phone_Number__c = '2017197210';
                    } 
                    ps.RecordTypeId = PearsonrecId;
                    PearsonVueDataList.add(ps); 
                } 
            }
            //system.debug('PearsonVueDataList'+PearsonVueDataList.size());
            for(Contract con:Contracts){
               // if(con.RecordTypeId == SCRRecId || con.RecordTypeId == RiskAIRecId || con.RecordTypeId == ICBRRRecId){
                 if(pearsonPrgConfigMap.containsKey(con.RecordTypeId)){
                    if(((con.Status == 'Activated' && oldMapObject.get(con.Id).Status != 'Activated')&& !oldContractMap.containsKey(con.Id))){  
                        Integration_Data__c PearsonVueData = new Integration_Data__c();
                        PearsonVueData.RecordTypeId = PearsonrecId;
                        if(ExamRegistrationsMap.containsKey(con.Id))
                            PearsonVueData.Exam_Registrations__c = ExamRegistrationsMap.get(con.Id);
                        PearsonVueData.Registration_Status__c = 'Not-Valid';
                        PearsonVueData.Created_From__c = 'Contract Initial'; 
                        PearsonVueData.Call_out_Status__c = 'Initial';
                        PearsonVueData.Is_Canddiate_Info_Changed__c  = false;
                        PearsonVueData.Call_out_Type__c = 'Out-bound';
                        PearsonVueData.Authorization_Type__c = 'Add'; 
                        PearsonVueData.Contract__c = con.Id; 
                        PearsonVueData.Version_Number__c =1; 
                        PearsonVueData.Address_Type__c = 'Work';
                        PearsonVueData.Outbound_Event_Types__c  = 'Ping Database;CDD;EAD';
                        PearsonVueData.Last_updated_Time__c = system.now();
                        PearsonVueData.Name = con.ContractNumber + ' - ' + PearsonVueData.Version_Number__c;
                        if(con.Garp_Id__c != null){
                            PearsonVueData.Garp_Id__c = con.Garp_Id__c.leftPad(8, '0');
                        }
                        Id crecid = con.RecordTypeId;
                        if(con.StartDate != null && con.EndDate != null && crecid == ICBRRRecId){
                            PearsonVueData.eligibilityApptDateFirst__c = datetimeformat(con.StartDate);  
                            PearsonVueData.eligibilityApptDateLast__c = datetimeformat(con.EndDate); 
                        }else if(crecid == SCRRecId || crecid == RiskAIRecId || crecid == RAIJRecId){
                            PearsonVueData.eligibilityApptDateFirst__c = datetimeformat(con.SCR_Start_Date__c);  
                            PearsonVueData.eligibilityApptDateLast__c = datetimeformat(con.SCR_End_Date__c); 
                        }
                        
                        //Mapping candidate Info 
                        PearsonVueData.First_Name__c = con.Pearson_Member_First_Name__c; 
                        PearsonVueData.Last_Name__c = con.Pearson_Member_Last_Name__c;
                        PearsonVueData.Middle_Name__c = con.Pearson_Member_Middle_Name__c;
                        PearsonVueData.Email__c = con.Member_Email__c;
                        
                        //PearsonVueData.Phone_Country_Code__c = '1';
                        
                        Contract cnmap = ContractMap.get(PearsonVueData.Contract__c);
                        
                        // Mapping Address info
                        CountryCodes__c countryCodes = CountryCodes__c.getValues(cnmap.Billingcountry);
                        PearsonVueData.Country__c = countryCodes != null ? countryCodes.ISOCode__c : 'USA';
                        PearsonVueData.Phone_Country_Code__c = countryCodes != null ? countryCodes.PhoneCode__c : '1';
                        //PearsonVueData.Country__c = 'USA';
                        PearsonVueData.State__c = (con.BillingState != null && con.BillingState.length()>50)?Utilities.replaceChars(con.BillingState).substring(0,50):Utilities.replaceChars(con.BillingState);
                        PearsonVueData.Address_1__c = (con.BillingStreet != null && con.BillingStreet.length()>40)?Utilities.replaceChars(con.BillingStreet).substring(0,40):Utilities.replaceChars(con.BillingStreet); 
                        PearsonVueData.Postal_Code__c = con.Billingpostalcode;
                        PearsonVueData.City__c = (con.BillingCity != null && con.BillingCity.length()>32)?Utilities.replaceChars(con.BillingCity).substring(0,32):Utilities.replaceChars(con.BillingCity);
                        
                       /* if(con.RecordTypeId == SCRRecId){
                            PearsonVueData.Exam_Type__c = 'SCR';
                        }else if(con.RecordTypeId == RiskAIRecId){
                            PearsonVueData.Exam_Type__c = 'GARPRandAI';
                        }
                        if(con.RecordTypeId == ICBRRRecId){
                            PearsonVueData.Exam_Type__c = 'FRR';   
                        }*/
                        if(pearsonPrgConfigMap.containsKey(con.RecordTypeId)){
                              PearsonVueData.Exam_Type__c = pearsonPrgConfigMap.get(con.RecordTypeId).Exam_Type__c;   
                        }
                        if(cnmap.Pearson_Phone_No__c != null){
                            if((PearsonVueData.Country__c == 'USA' || PearsonVueData.Country__c == 'CAN') && cnmap.Pearson_Phone_No__c.startsWith('1')){
                                PearsonVueData.phone_Number__c = cnmap.Pearson_Phone_No__c.removeStart('1');
                            }else{
                                PearsonVueData.phone_Number__c = cnmap.Pearson_Phone_No__c;
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
            
        }catch(Exception ex){
            system.debug(ex.getMessage()+' '+ex.getLinenumber()+' '+ex.getStackTraceString()); 
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