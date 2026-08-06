public class ExamRegistrationHandlerClass {
    public static boolean isCreateRateRecursive = false;
    public static Id ATARecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Integration_Data__c','ATA');//Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('ATA').getRecordTypeId();
    public static Id PSIRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Integration_Data__c','PSI');//Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('PSI').getRecordTypeId(); 
    public static void ExamRegistration(List<Exam_Attempt__c> examRegList,Map<Id,Exam_Attempt__c> oldMap){  
        try{
        List<Integration_Data__c> intdataList = new List<Integration_Data__c>();  
        Set<Id> activeIds = new Set<Id>();  
        Map<Id,Exam_Part__c> ExamPartMap = new Map<Id,Exam_Part__c>();
        Set<Id> newExamattMap = new Set<Id>(); 
        Set<Id> ExamPartId = new Set<Id>();
        for(Exam_Attempt__c att : examRegList){
            if((att.Section__c == 'ERP Exam Part I' || att.Section__c == 'ERP Exam Part II' || att.Section__c == 'FRM Part 1' || att.Section__c == 'FRM Part 2') && att.Exam_Part__c != null && att.Opportunity_StageName__c =='closed'){
                ExamPartId.add(att.Exam_Part__c); 
                if(oldMap != null && oldMap.containsKey(att.Id)){  
                    ExamPartId.add(oldMap.get(att.Id).Exam_Part__c);
                }
                if(att.Active_Integration_Data__c != null){ 
                    activeIds.add(att.Active_Integration_Data__c); 
                    newExamattMap.add(att.Id);
                }
            } 
        }
        
        if(ExamPartId.size()>0){
            ExamPartMap = new  Map<Id,Exam_Part__c>([Select Id,Exam_Start_Date__c,ATA_Batch_Code__c,Exam_Date__c,Exam_End_Date__c,Delivery_Method__c from Exam_Part__c Where Id In:ExamPartId and Delivery_Method__c ='CBT']);
        }
        //Insert Exam Attempt
        if(oldMap == null && trigger.isInsert){    
            for(Exam_Attempt__c att : examRegList){
                if((att.Section__c == 'ERP Exam Part I' || att.Section__c == 'ERP Exam Part II' || att.Section__c == 'FRM Part 1' || att.Section__c == 'FRM Part 2') && oldMap == null && att.Exam_Part__c != null && att.Opportunity_StageName__c =='closed'){  
                    Integration_Data__c intdata = new Integration_Data__c();
                    intdata.Version_Number__c = 1;
                    intdata = getIntegrationData(att,intdata,ExamPartMap); 
                    if(intdata.Integration_Type__c == 'Import Registration New' || intdata.Integration_Type__c == 'Eligibility Lifecycle'){ 
                        intdataList.add(intdata);  
                    }
                }  
            }  
        }
        
        
        // Update Exam Attempt
        if(oldMap != null && trigger.isupdate){  
            Map<Id,Integration_Data__c> activeIntegrationDataMap = new Map<Id,Integration_Data__c>();
            Map<Id,Decimal> getVersionNumerMap = new Map<Id,Decimal>(); 
            if(activeIds.size()>0){
                List<Integration_Data__c> activeCloneList = cloneActiveIntegrationData(activeIds);
                for(Integration_Data__c intdata:activeCloneList){ 
                    intdata.Id = null;
                    intdata.Is_Active__c = false;
                    activeIntegrationDataMap.put(intdata.Exam_Registrations__c,intdata); 
                }
            }  
            
            
            for(AggregateResult inag:[Select Exam_Registrations__c,count(Id) intcount from Integration_Data__c 
                                      WHERE Exam_Registrations__c In:newExamattMap group by Exam_Registrations__c Limit 2000]){  
                                          Id exaId = (id) inag.get('Exam_Registrations__c'); 
                                          Integer intres = (Integer) inag.get('intcount');     
                                          getVersionNumerMap.put(exaId,intres); 
                                      }
            for(Exam_Attempt__c newatt : examRegList){
                if((newatt.Section__c == 'ERP Exam Part I' || newatt.Section__c == 'ERP Exam Part II' || newatt.Section__c == 'FRM Part 1' || newatt.Section__c == 'FRM Part 2') && oldMap != null && newatt.Exam_Part__c != null && newatt.Opportunity_StageName__c =='closed'){ 
                     Integration_Data__c intdata = new Integration_Data__c(); 
                    if(activeIntegrationDataMap.containsKey(newatt.Id)){ 
                        intdata = activeIntegrationDataMap.get(newatt.Id); 
                    } 
                    if(getVersionNumerMap.containsKey(newatt.Id)){
                        intdata.Version_Number__c = getVersionNumerMap.get(newatt.Id) +1;   
                    }else{
                        intdata.Version_Number__c = 1; 
                    }
                    intdata = getIntegrationData(newatt,intdata,ExamPartMap); 
                    intdata.Is_Active__c = false;
                    Exam_Attempt__c oldatt = oldMap.get(newatt.Id);
                    //system.debug(intdata.ATA_Batch_Code__c);
                    if(newatt.Exam_Site__c == oldatt.Exam_Site__c && newatt.Integration_Type__c != 'Query Exam Cert' && intdata.ATA_Batch_Code__c != null && newatt.ATA_region_code__c != null && newatt.ATA_region_name__c != null && newatt.ATA_Name_as_it_appears_on_ID__c != null && newatt.ATA_Cert_id__c != null && newatt.ATA_Cert_Type__c != null){ 
                       // system.debug('ATA'); 
                        if((newatt.Integration_Type__c == 'Import Registration New' && oldatt.Integration_Type__c != 'Import Registration New') || (newatt.Cancelled__c == false && oldatt.Cancelled__c == true) || (newatt.Defered__c != 'Pending' && oldatt.Defered__c == 'Pending' && newatt.Cancelled__c == false)){
                            intdata.Outbound_Event_Types__c = 'ATA';
                            intdata.Integration_Type__c = 'Import Registration New';
                            intdata.Name = intdata.Integration_Type__c+ ' ' +intdata.Version_Number__c; 
                            intdataList.add(intdata);
                        }else if(newatt.Integration_Type__c != oldatt.Integration_Type__c && newatt.Integration_Type__c  == 'Update Import Registration New' && newatt.Cancelled__c == false && newatt.Defered__c != 'Pending'){
                            intdata.Outbound_Event_Types__c = 'ATA';
                            intdata.Integration_Type__c = 'Update Import Registration New';
                            intdata.Name = intdata.Integration_Type__c + ' ' +intdata.Version_Number__c; 
                            intdataList.add(intdata);
                        }else if(newatt.Active_Integration_Data__c !=null && ((newatt.Integration_Type__c == 'Delete Registration' && oldatt.Integration_Type__c != 'Delete Registration') || (newatt.Cancelled__c == true && oldatt.Cancelled__c == false)  || (newatt.Defered__c == 'Pending' && oldatt.Defered__c != 'Pending' && newatt.Cancelled__c == false))){
                            intdata.Outbound_Event_Types__c = 'ATA';
                            intdata.Integration_Type__c = 'Delete Registration';
                            intdata.Name = intdata.Integration_Type__c+ ' ' +intdata.Version_Number__c; 
                            intdataList.add(intdata);
                        }else if(newatt.ATA_Cert_id__c != oldatt.ATA_Cert_id__c || newatt.ATA_Cert_Type__c != oldatt.ATA_Cert_Type__c || newatt.ATA_Name_as_it_appears_on_ID__c != oldatt.ATA_Name_as_it_appears_on_ID__c || newatt.Exam_Part__c != oldatt.Exam_Part__c){
                            intdata.Outbound_Event_Types__c = 'ATA';
                            intdata.Integration_Type__c = 'Update Import Registration New';
                            intdata.Name = intdata.Integration_Type__c+ ' ' +intdata.Version_Number__c; 
                            intdataList.add(intdata);
                        }
                    }    // PSI Integration            
                    else if(newatt.ATA_region_code__c == null  && newatt.ATA_region_name__c == null && newatt.Exam_Site__c == oldatt.Exam_Site__c && newatt.Integration_Type__c != 'Query Exam Cert'){ 
                        //system.debug('PSI'); 
                        if((newatt.Integration_Type__c == 'Eligibility Lifecycle') || (newatt.Cancelled__c == false && oldatt.Cancelled__c == true) || (newatt.Defered__c != 'Pending' && oldatt.Defered__c == 'Pending' && newatt.Cancelled__c == false)){ 
                            intdata.Outbound_Event_Types__c = 'PSI';
                            intdata.Integration_Type__c = 'Eligibility Lifecycle';
                            intdata.Name = intdata.Integration_Type__c+ ' ' +intdata.Version_Number__c;
                            intdata.Call_out_Status__c = 'Initial'; 
                            intdataList.add(intdata);
                        }else if(newatt.Integration_Type__c != oldatt.Integration_Type__c && newatt.Integration_Type__c == 'Update Eligibility Lifecycle' && newatt.Cancelled__c != true && newatt.Defered__c != 'Pending'){ 
                            intdata.Outbound_Event_Types__c = 'PSI';
                            intdata.Integration_Type__c = 'Update Eligibility Lifecycle';
                            intdata.Name = intdata.Integration_Type__c+ ' ' +intdata.Version_Number__c; 
                            intdataList.add(intdata);
                        }else if(newatt.Active_Integration_Data__c !=null && ((newatt.Integration_Type__c == 'Cancel Eligibility Lifecycle' && oldatt.Integration_Type__c != 'Cancel Eligibility Lifecycle') || (newatt.Cancelled__c == true && oldatt.Cancelled__c == false) || (newatt.Defered__c == 'Pending' && oldatt.Defered__c != 'Pending' && newatt.Cancelled__c == false))){  
                            intdata.Outbound_Event_Types__c = 'PSI';
                            intdata.Integration_Type__c = 'Cancel Eligibility Lifecycle';
                            intdata.Name = intdata.Integration_Type__c + ' ' +intdata.Version_Number__c; 
                            intdataList.add(intdata);
                        }else if(newatt.Active_Integration_Data__c !=null && (newatt.ATA_Name_as_it_appears_on_ID__c != oldatt.ATA_Name_as_it_appears_on_ID__c || newatt.Exam_Part__c != oldatt.Exam_Part__c)){ 
                            intdata.Outbound_Event_Types__c = 'PSI';
                            intdata.Integration_Type__c = 'Update Eligibility Lifecycle';
                            intdata.Name = intdata.Integration_Type__c+ ' ' +intdata.Version_Number__c; 
                            intdataList.add(intdata);
                        }
                    }else if(newatt.Exam_Site__c != oldatt.Exam_Site__c && newatt.Cancelled__c == false && newatt.Defered__c != 'Pending' && newatt.Active_Integration_Data__c != null){
                        if(newatt.ATA_region_code__c != null && oldatt.ATA_region_code__c != null){ 
                            if(newatt.Defered__c != 'Pending' && oldatt.Defered__c == 'Pending' && newatt.Cancelled__c == false){
                                intdata.Outbound_Event_Types__c = 'ATA';
                                intdata.Integration_Type__c = 'Import Registration New';
                                intdata.Name = intdata.Integration_Type__c + ' ' +intdata.Version_Number__c; 
                                intdataList.add(intdata);
                            }else if((newatt.ATA_region_code__c != oldatt.ATA_region_code__c) || (newatt.Is_OSTA_Information_Required__c != oldatt.Is_OSTA_Information_Required__c) || (newatt.Section__c != oldatt.Section__c) ||  (newatt.Exam_Part__c != oldatt.Exam_Part__c)){
                                intdata.Outbound_Event_Types__c = 'ATA';
                                intdata.Integration_Type__c = 'Delete Registration';
                                intdata.ATA_subject_code__c = oldatt.ATA_subject_code__c;
                                intdata.ATA_Batch_Code__c = ExamPartMap.get(oldatt.Exam_Part__c).ATA_Batch_Code__c;
                                intdata.Name = 'Import Registration New OSTA Information ' +intdata.Version_Number__c; 
                                intdataList.add(intdata);
                            }else{
                                intdata.Outbound_Event_Types__c = 'ATA';
                                intdata.Integration_Type__c = 'Update Import Registration New';
                                intdata.Name = intdata.Integration_Type__c + ' ' +intdata.Version_Number__c; 
                                intdataList.add(intdata);
                            }
                        }else if(newatt.ATA_region_code__c == null && oldatt.ATA_region_code__c == null && newatt.Defered__c != 'Pending' && oldatt.Defered__c == 'Pending'){
                            intdata.Outbound_Event_Types__c = 'PSI';
                            intdata.Integration_Type__c = 'Eligibility Lifecycle';
                            intdata.Name = intdata.Integration_Type__c+ ' ' +intdata.Version_Number__c;
                            intdata.Call_out_Status__c = 'Initial'; 
                            intdataList.add(intdata);
                        }else if(newatt.ATA_region_code__c == null && oldatt.ATA_region_code__c == null && (newatt.Section__c != oldatt.Section__c || newatt.Exam_Part__c != oldatt.Exam_Part__c)){
                            // if(newatt.Section__c != oldatt.Section__c){ 
                                intdata.Outbound_Event_Types__c = 'PSI';
                                intdata.Integration_Type__c = 'Cancel Eligibility Lifecycle';
                                intdata.Name = 'Eligibility Lifecycle Section Change ' +intdata.Version_Number__c;
                                intdataList.add(intdata);
                          /* }else{
                                intdata.Outbound_Event_Types__c = 'PSI';
                                intdata.Integration_Type__c = 'Update Eligibility Lifecycle';
                                intdata.Name = intdata.Integration_Type__c+ ' ' +intdata.Version_Number__c; 
                                intdataList.add(intdata);
                            } */
                        }else if(newatt.ATA_region_code__c == null && oldatt.ATA_region_code__c != null ){ 
                            intdata.Outbound_Event_Types__c = 'ATA To PSI';
                            intdata.Integration_Type__c = 'ATA To PSI';
                            intdata.ATA_subject_code__c = oldatt.ATA_subject_code__c;
                            intdata.ATA_Batch_Code__c = ExamPartMap.get(oldatt.Exam_Part__c).ATA_Batch_Code__c;
                            intdata.Name = 'ATA To PSI'+ ' ' +intdata.Version_Number__c; 
                            intdataList.add(intdata);
                        }else if(newatt.ATA_region_code__c != null && oldatt.ATA_region_code__c == null){ 
                            intdata.Outbound_Event_Types__c = 'PSI To ATA';
                            intdata.Integration_Type__c = 'PSI To ATA';
                            intdata.Name = 'PSI To ATA'+ ' ' +intdata.Version_Number__c; 
                            intdataList.add(intdata);
                        }
                    }else if(newatt.Integration_Type__c == 'Query Exam Cert' && newatt.Outbound_Type__c =='ATA' && newatt.ATA_PSI_Is_Override__c == true){
                        intdata.Outbound_Event_Types__c = 'Get ATA';
                        intdata.Integration_Type__c =  newatt.Integration_Type__c;
                        intdata.Name =  newatt.Integration_Type__c + ' ' +intdata.Version_Number__c; 
                        intdataList.add(intdata);
                    }
                    
                }
            }
        } 
        // system.debug('>>'+intdataList.size());
        if(!intdataList.isEmpty() && intdataList.size()>0){
            insert intdataList;
            ATAPSIUtilClass.examRegistrationTriggerRecursion =true;
            set<Id> ATAintegrationId = new set<Id>();
            set<Id> PSIintegrationId = new set<Id>(); 
            for(Integration_Data__c da:intdataList){
                if(da.Integration_Type__c == 'Query Exam Cert' || da.Integration_Type__c == 'Import Registration New' || da.Integration_Type__c == 'Update Import Registration New' || da.Integration_Type__c == 'Delete Registration' ||  da.Integration_Type__c == 'ATA To PSI' ||  da.Integration_Type__c == 'PSI To ATA'){// || da.Integration_Type__c == 'Cancel Eligibility Lifecycle'){
                    ATAintegrationId.add(da.Id);
                }
                if(da.Integration_Type__c == 'Eligibility Lifecycle' || da.Integration_Type__c == 'Update Eligibility Lifecycle' || da.Integration_Type__c == 'Cancel Eligibility Lifecycle' ||  da.Integration_Type__c == 'PSI To ATA' ||  da.Integration_Type__c == 'ATA To PSI'){ //|| da.Integration_Type__c == 'Delete Registration' ){
                    PSIintegrationId.add(da.Id);
                } 
            }
            
            if(!ATAintegrationId.isEmpty() && !Test.isRunningTest()){
                if(system.isBatch()){
                    ID jobID = System.enqueueJob(new ATACallOutQueueable(ATAintegrationId));
                 }else{
                     ATA_SchedulingInterfaceClass.ATASchedulingIntegration(ATAintegrationId);
                 }
            } 
            if(!PSIintegrationId.isEmpty() && !Test.isRunningTest()){
                if(system.isBatch()){
                    ID jobID = System.enqueueJob(new PSICallOutQueueable(PSIintegrationId));
                 }else{
                	PSI_EligibilityLifecycle.PSIEligibilityLifecycleCallout(PSIintegrationId);
                 }
            }
        }  
         //system.debug('>>');
        }catch(Exception ex){
             system.debug(ex.getMessage());            
        }
    }
    
    
    public static Integration_Data__c getIntegrationData(Exam_Attempt__c att,Integration_Data__c intdata,Map<Id,Exam_Part__c> ExamPartMap){
        if(ExamPartMap.containsKey(att.Exam_Part__c)){
            intdata.Address_1__c = att.Member_Street__c;//Member Street
            intdata.Garp_Id__c = att.Garp_Id__c;
            intdata.City__c = att.Member_City__c;
            if(att.RPT_Opp_Shipping_Country__c != null){
                try{
                    CountryCodes__c countryCodes = CountryCodes__c.getValues(att.RPT_Opp_Shipping_Country__c); 
                    intdata.Country__c = countryCodes.ISOCode__c;
                }catch(Exception e){
                    
                }
            }
            intdata.Email__c = att.Member_Email__c; 
            if(att.ATA_Name_as_it_appears_on_ID__c != null && att.ATA_Name_as_it_appears_on_ID__c != ''){ 
                if(att.ATA_Name_as_it_appears_on_ID__c.contains(' ')){
                    intdata.First_Name__c = att.ATA_Name_as_it_appears_on_ID__c.substring(0,att.ATA_Name_as_it_appears_on_ID__c.indexOf(' '));
                    intdata.Last_Name__c =att.ATA_Name_as_it_appears_on_ID__c.substring(att.ATA_Name_as_it_appears_on_ID__c.indexOf(' ')+1);
                }else{
                    intdata.First_Name__c = att.ATA_Name_as_it_appears_on_ID__c;
                    intdata.Last_Name__c ='.';
                }
            }else{
                intdata.First_Name__c = att.Member_First_Name__c;
                if(att.Member_Last_Name__c != null && att.Member_Last_Name__c != ''){
                    intdata.Last_Name__c = att.Member_Last_Name__c;
                }else{
                    intdata.Last_Name__c = '.';
                }
            }
            intdata.Phone_Number__c = att.Member_Phone__c;
            intdata.State__c = att.Member_State__c; 
            intdata.Postal_Code__c = att.RPT_Member_Zip_Code__c; 
            //intdata.Version_Number__c =versionnum;
            intdata.Exam_Registrations__c = att.Id;
            intdata.Call_out_Type__c = 'Out-bound';
            intdata.Call_out_Status__c = 'Initial'; 
            
            if(att.ATA_region_code__c != null && att.ATA_region_name__c != null && att.ATA_Name_as_it_appears_on_ID__c != null && att.ATA_Cert_id__c != null && att.ATA_Cert_Type__c != null){
                if(ExamPartMap.get(att.Exam_Part__c).ATA_Batch_Code__c != null){ 
                     Map<String,ATA_Cert_Type_List__c> ATACertTypeMap = ATAPSIUtilClass.getATACertTypeList();
                    intdata.RecordTypeId = ATARecordTypeId; 
                    intdata.Outbound_Event_Types__c = 'ATA'; 
                    intdata.ATA_Cert_id__c = att.ATA_Cert_id__c.right(5);
                    if(ATACertTypeMap.containsKey(att.ATA_Cert_Type__c))
                    intdata.ATA_Cert_type__c = ATACertTypeMap.get(att.ATA_Cert_Type__c).Conversion_Id__c;
                    intdata.ATA_region_code__c = att.ATA_region_code__c;
                    intdata.ATA_subject_code__c = att.ATA_subject_code__c;
                    intdata.ATA_subject_name__c = att.ATA_subject_name__c; 
                    intdata.ATA_region_name__c = att.ATA_region_name__c;
                    intdata.ATA_Inbound_Reg_Code__c =  att.Garp_Id__c;
                    intdata.ATA_Name_as_it_appears_on_ID__c = att.ATA_Name_as_it_appears_on_ID__c;
                    intdata.ATA_reg_time__c = system.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
                    intdata.Integration_Type__c = 'Import Registration New'; 
                    intdata.Name = 'Import Registration New' + ' ' +intdata.Version_Number__c; 
                    intdata.ATA_Batch_Code__c = ExamPartMap.get(att.Exam_Part__c).ATA_Batch_Code__c;
 
                }
            }else if(att.ATA_region_code__c == null && att.ATA_region_name__c == null){
                intdata.RecordTypeId = PSIRecordTypeId; 
                intdata.Outbound_Event_Types__c = 'PSI'; 
                intdata.Integration_Type__c = 'Eligibility Lifecycle';
                intdata.Name = 'Eligibility Lifecycle' + ' ' +intdata.Version_Number__c;
                intdata.client_eligibility_id__c = att.PSI_client_eligibility_id__c; 
                    Exam_Part__c epdate = ExamPartMap.get(att.Exam_Part__c);
                    Date StartDate;
                    Date EndDate;
                    if(epdate.Exam_Date__c != null){
                        StartDate = epdate.Exam_Date__c.adddays(-3); 
                        EndDate = epdate.Exam_Date__c.adddays(2); 
                    }else if (epdate.Exam_Start_Date__c != null && epdate.Exam_End_Date__c != null) {
                        StartDate = epdate.Exam_Start_Date__c.adddays(-3);
                        EndDate = epdate.Exam_End_Date__c.adddays(2);
                    }  
                    DateTime StartDatetm = Datetime.newInstance(StartDate.year(), StartDate.month(),StartDate.day()); 
                    DateTime  EndDatetm = Datetime.newInstance(EndDate.year(), EndDate.month(),EndDate.day()); 
                    String startdtString = StartDatetm.format('yyyy-MM-dd');
                    String enddtString = EndDatetm.format('yyyy-MM-dd');
                    intdata.PSI_schedule_start_date__c = startdtString; 
                    intdata.PSI_eligibility_end_date__c = enddtString; 
                
                if(att.Section__c =='ERP Exam Part I')   
                    intdata.PSI_Test_code__c = 'ERP1';
                if(att.Section__c =='ERP Exam Part II')
                    intdata.PSI_Test_code__c = 'ERP2';
                    
                if(att.Section__c =='FRM Part 1')   
                    intdata.PSI_Test_code__c = 'FRM1';
                if(att.Section__c =='FRM Part 2')
                    intdata.PSI_Test_code__c = 'FRM2'; 
                 
            }
        }
        return intdata;
    }
    
    public static List<Integration_Data__c> cloneActiveIntegrationData(Set<Id> IntegrationId){ 
        List<Integration_Data__c> IntegrationActierec = new List<Integration_Data__c>(); 
        if(IntegrationId.size()>0){
            List<String> fields = new List<String>();
            fields.addAll(Integration_Data__c.getsObjectType().getDescribe().fields.getMap().keySet());
            String soql = 'SELECT ' + String.join(fields, ',') +
                ' FROM Integration_Data__c WHERE Id IN: IntegrationId';
            IntegrationActierec = Database.query(soql).deepclone(false,false,false); 
        }
        return IntegrationActierec;
    }
    
    public static void createRateOffering(List<Exam_Attempt__c> newList,Map<Id,Exam_Attempt__c> oldMap){
        isCreateRateRecursive = true;
        Set<Id> ExamRegistrationIdSet = new Set<Id>();
        List<Exam_Rate_Offering__c> rateOfferingToCreate = new List<Exam_Rate_Offering__c>();
        Map<string,Rate_offering_config__mdt> rateConfigKeyMap = new Map<string,Rate_offering_config__mdt>();
        
        List<Rate_offering_config__mdt> rocList = [Select DeveloperName,Active__c,Exam_Date__c,Exam_Window_Id__c,Exam_Results_Administration__c,
                                                          Expiry_Date__c,Offering_part__c,Result_Type__c,Include_part_2__c,Part_2_Exam_Rate_Id__c
                                                     from Rate_offering_config__mdt
                                                     where Active__c = true];
        for(Rate_offering_config__mdt roc: rocList){
            String rocKey;
            if(String.isNotBlank(roc.Exam_Results_Administration__c)){
                rocKey = String.valueOf(roc.Exam_Results_Administration__c).substring(0, 15)+roc.Result_Type__c+roc.Offering_part__c;
                rateConfigKeyMap.put(rocKey,roc);
            }
            if(roc.Exam_Date__c != null){
                rocKey = roc.Exam_Date__c+roc.Result_Type__c+roc.Offering_part__c;
                rateConfigKeyMap.put(rocKey,roc);
            }
        }
        //system.debug(rateConfigKeyMap);
        for(Exam_Attempt__c ea: newList){
            string rocAdminKey;
            String rocDateKey;
            String part2section = (ea.Section__c != null && ea.Section__c.contains('FRM'))?'FRM Part 2':'ERP Exam Part II';
            if(ea.Result__c != oldMap.get(ea.Id).Result__c){
                ExamRegistrationIdSet.add(ea.Id);
                if(ea.Exam_Administration__c != null){
                    rocAdminKey = String.valueOf(ea.Exam_Administration__c).substring(0, 15)+ea.Result__c+ea.Section__c;
                }
                if(ea.Exam_Date__c != null){
                    rocDateKey = ea.Exam_Date__c+ea.Result__c+ea.Section__c;
                }
                //system.debug(rocAdminKey);
                //system.debug(rocAdminKey);
                Exam_Rate_Offering__c ero = new Exam_Rate_Offering__c();
                ero.Start_Date__c = system.today();
                ero.Exam_Registration__c = ea.Id;
                ero.Contact__c = ea.Member__c;
                if(ea.Section__c == 'FRM Part 1' && ea.Result__c == 'Pass'){
                    ero.Offering_Part__c = 'FRM Part 2';
                }else if(ea.Section__c == 'ERP Exam Part I' && ea.Result__c == 'Pass'){
                    ero.Offering_Part__c = 'ERP Exam Part II';
                }else{
                    ero.Offering_Part__c = ea.Section__c;
                }
                if(String.isNotBlank(rocAdminKey) && rateConfigKeyMap.containskey(rocAdminKey)){
                    ero.End_Date__c = rateConfigKeyMap.get(rocAdminKey).Expiry_Date__c;
                    ero.Exam_Rate__c = rateConfigKeyMap.get(rocAdminKey).Exam_Window_Id__c;
                    rateOfferingToCreate.add(ero);
                    if(rateConfigKeyMap.get(rocAdminKey).Include_part_2__c){
                        Exam_Rate_Offering__c ero2 = new Exam_Rate_Offering__c();
                        ero2.Start_Date__c = system.today();
                        ero2.Exam_Registration__c = ea.Id;
                        ero2.Contact__c = ea.Member__c;
                        ero2.Offering_Part__c = part2section;
                        ero2.End_Date__c = rateConfigKeyMap.get(rocAdminKey).Expiry_Date__c;
                        ero2.Exam_Rate__c = rateConfigKeyMap.get(rocAdminKey).Part_2_Exam_Rate_Id__c;
                        rateOfferingToCreate.add(ero2);
                    }
                }else if(String.isNotBlank(rocDateKey) && rateConfigKeyMap.containskey(rocDateKey)){
                    ero.End_Date__c = rateConfigKeyMap.get(rocDateKey).Expiry_Date__c;
                    ero.Exam_Rate__c = rateConfigKeyMap.get(rocDateKey).Exam_Window_Id__c;
                    rateOfferingToCreate.add(ero);
                    if(rateConfigKeyMap.get(rocDateKey).Include_part_2__c){
                        Exam_Rate_Offering__c ero2 = new Exam_Rate_Offering__c();
                        ero2.Start_Date__c = system.today();
                        ero2.Exam_Registration__c = ea.Id;
                        ero2.Contact__c = ea.Member__c;
                        ero2.Offering_Part__c = part2section;
                        ero2.End_Date__c = rateConfigKeyMap.get(rocDateKey).Expiry_Date__c;
                        ero2.Exam_Rate__c = rateConfigKeyMap.get(rocDateKey).Part_2_Exam_Rate_Id__c;
                        rateOfferingToCreate.add(ero2);
                    }
                }
            }
        }
        List<Exam_Rate_Offering__c> rateOfferingToDelete = [Select Id,Exam_Registration__c from Exam_Rate_Offering__c 
                                                                where Exam_Registration__c IN: ExamRegistrationIdSet];

        if(!rateOfferingToDelete.isEmpty()){
            delete rateOfferingToDelete;
        }
        if(!rateOfferingToCreate.isEmpty()){
            insert rateOfferingToCreate;
        }
    }
}