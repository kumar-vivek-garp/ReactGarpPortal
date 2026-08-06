global class processRegistrationDeferral_Batch implements Database.Batchable<sObject>,Schedulable{
    private String recordId;
    public processRegistrationDeferral_Batch() {
        
    }
    public processRegistrationDeferral_Batch(string inputRecordId) {
        recordId = inputRecordId;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        if(String.isNotBlank(recordId)){
            return Database.getQueryLocator([Select Id,Part_I_Exam_Registration__c,Part_II_Exam_Registration__c,
                                             Status__c,Part_I_Exam_Group_From__c,Part_II_Exam_Group_From__c,
                                             Part_I_Exam_Group_To__c,Part_II_Exam_Group_To__c,
                                             Part_I_Exam_Admin_From__c,Part_II_Exam_Admin_From__c,
                                             Part_I_Exam_Admin_To__c,Part_II_Exam_Admin_To__c,
                                             Part_I_Exam_Part_From__c,Part_II_Exam_Part_From__c,
                                             Part_I_Exam_Part_To__c,Part_II_Exam_Part_To__c,
                                             Part_I_Exam_Site_From__c,Part_II_Exam_Site_From__c,
                                             Part_I_Exam_Site_To__c,Part_II_Exam_Site_To__c,
                                             Bulk_Site_Deferral__c,Deferral_Subtype__c,
                                             Part_I_Exam_Site_From__r.Site_Code__c,
                                             Part_II_Exam_Site_From__r.Site_Code__c
                                             from Exam_Registration_Modification__c 
                                             where Status__c = 'Opportunity Created' AND Id =: recordId]);
        }else{
            return Database.getQueryLocator([Select Id,Part_I_Exam_Registration__c,Part_II_Exam_Registration__c,
                                             Status__c,Part_I_Exam_Group_From__c,Part_II_Exam_Group_From__c,
                                             Part_I_Exam_Group_To__c,Part_II_Exam_Group_To__c,
                                             Part_I_Exam_Admin_From__c,Part_II_Exam_Admin_From__c,
                                             Part_I_Exam_Admin_To__c,Part_II_Exam_Admin_To__c,
                                             Part_I_Exam_Part_From__c,Part_II_Exam_Part_From__c,
                                             Part_I_Exam_Part_To__c,Part_II_Exam_Part_To__c,
                                             Part_I_Exam_Site_From__c,Part_II_Exam_Site_From__c,
                                             Part_I_Exam_Site_To__c,Part_II_Exam_Site_To__c,
                                             Bulk_Site_Deferral__c,Deferral_Subtype__c,
                                             Part_I_Exam_Site_From__r.Site_Code__c,
                                             Part_II_Exam_Site_From__r.Site_Code__c
                                             from Exam_Registration_Modification__c 
                                             where Status__c = 'Opportunity Created']);
        }
        
    }
    
    global void execute(Database.BatchableContext bc, List<Exam_Registration_Modification__c> scope){
        Map<Id,Exam_Registration_Modification__c> examAttemptToDeferralMap = new Map<Id,Exam_Registration_Modification__c>();
        List<Exam_Attempt__c> oldAttemptsList = new List<Exam_Attempt__c>();
        List<Exam_Attempt__c> oldAttemptsListToUpdate = new List<Exam_Attempt__c>();
        List<Exam_Attempt__c> newAttemptsList = new List<Exam_Attempt__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id,Opportunity> modToOppMap = new Map<Id,Opportunity>();
        Set<Id> modIds = new Set<Id>();
        Set<Id> programIds = new Set<Id>();
        Set<Id> adminIds = new Set<Id>();
        Set<Exam_Registration_Modification__c> deferralsToUpdateSet = new Set<Exam_Registration_Modification__c>();
        List<Exam_Registration_Modification__c> deferralsToUpdate = new List<Exam_Registration_Modification__c>();
        DescribeSObjectResult describeResult = Exam_Attempt__c.getSObjectType().getDescribe();  
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        for(Exam_Registration_Modification__c erm : scope){
            modIds.add(erm.id);
            if(erm.Part_I_Exam_Registration__c != null){
                if(erm.Part_I_Exam_Admin_From__c != null && erm.Part_I_Exam_Admin_To__c != null && erm.Part_I_Exam_Admin_From__c != erm.Part_I_Exam_Admin_To__c){
                	examAttemptToDeferralMap.put(erm.Part_I_Exam_Registration__c,erm);
                    adminIds.add(erm.Part_I_Exam_Admin_To__c);
                }
            }
            if(erm.Part_II_Exam_Registration__c != null){
                if(erm.Part_II_Exam_Admin_From__c != null && erm.Part_II_Exam_Admin_To__c != null && erm.Part_II_Exam_Admin_From__c != erm.Part_II_Exam_Admin_To__c){
                	examAttemptToDeferralMap.put(erm.Part_II_Exam_Registration__c,erm);
                    adminIds.add(erm.Part_II_Exam_Admin_To__c);
                }
            }
        }
        
        Map<Id,Exam_Part__c> examPartsMap = new Map<Id,Exam_Part__c>([Select Id,name,Exam__r.Exam__c,Exam_Administration__c from Exam_Part__c where Exam_Administration__c IN: adminIds]);
        
        Map<Id,Exam_Part__c> part1Map = new Map<Id,Exam_Part__c>();
        Map<Id,Exam_Part__c> part2Map = new Map<Id,Exam_Part__c>();
        for(Exam_Part__c ep : examPartsMap.values()){
            if(ep.Exam__r.Exam__c == 'FRM Part 1' || ep.Exam__r.Exam__c == 'SCR' || ep.Exam__r.Exam__c == 'RiskAI' || ep.Exam__r.Exam__c == 'RAIJ'){
                part1Map.put(ep.Exam_Administration__c,ep);
            }else if(ep.Exam__r.Exam__c == 'FRM Part 2'){
                part2Map.put(ep.Exam_Administration__c,ep);
            }
        }
        
        List<Exam_Sites__c> examSiteList = [Select Id,Name,Exam_Date__c,Site__r.Active__c,Site__r.Non_Selectable__c,Site_Code__c,Exam_Part__c
                                            from Exam_Sites__c 
                                            where Site__r.Active__c = TRUE AND Site__r.Non_Selectable__c = FALSE AND Exam_Part__c IN: examPartsMap.keyset() Order By Name];
        
        Map<String,Exam_Sites__c> examSiteMap = new Map<String,Exam_Sites__c>();
        for(Exam_Sites__c es : examSiteList){
            examSiteMap.put(es.Exam_Part__c+es.Site_code__c,es);
        }
        
        oppList = [Select Id,StageName,Free_Deferral__c,ia_crm__Intacct_Transaction__c,Exam_Registration_Modification__c From Opportunity where Exam_Registration_Modification__c IN: modIds];
        for(Opportunity opp : oppList){
            modToOppMap.put(opp.Exam_Registration_Modification__c,opp);
        }
        Set<Id> attemptsId = examAttemptToDeferralMap.keyset();
        String query = 'SELECT ' +String.join( fieldNames, ',' ) +' FROM Exam_Attempt__c'+' WHERE id IN: attemptsId';
        oldAttemptsList = Database.query(query);
        
        for(Exam_Attempt__c ea : oldAttemptsList){
            Exam_Attempt__c clonedRec = ea.clone(false,true,false,false);
            Exam_Registration_Modification__c erm = examAttemptToDeferralMap.containskey(ea.id) ? examAttemptToDeferralMap.get(ea.id) : null;
            if(erm != null && ((modToOppMap.containskey(erm.Id) && modToOppMap.get(erm.Id).StageName == 'Closed') || !modToOppMap.containskey(erm.Id))){
                erm.Status__c = 'Completed';
            	deferralsToUpdateSet.add(erm);
                if((modToOppMap.containskey(erm.Id) && modToOppMap.get(erm.Id).Free_Deferral__c) || ea.Future_Free_Deferral__c){
                	clonedRec.Free_Deferral__c = true;
                }else{
                    clonedRec.Free_Deferral__c = false;
                }
                if(ea.Selected_To_Allow_Future_Deferral__c || erm.Bulk_Site_Deferral__c){
                    clonedRec.Allow_Future_Deferral__c = true;
                }else{
                    clonedRec.Allow_Future_Deferral__c = false;
                }
                if(ea.Defered__c == 'Pending' && ea.Marked_For_Free_Covid_Deferral__c == true){
                    clonedRec.Marked_For_Free_Covid_Deferral__c = false;
                    clonedRec.Free_Covid_Deferral__c = true;
                }else if(ea.Defered__c != 'Pending'){
                    clonedRec.Marked_For_Free_Covid_Deferral__c = false;
                    clonedRec.Free_Covid_Deferral__c = true;
                    //Setting flag on deferring out record also
                    ea.Marked_For_Free_Covid_Deferral__c = true;
                }
                if(ea.Section__c == 'FRM Part 1' || ea.Section__c == 'SCR' || ea.Section__c == 'RiskAI' || ea.Section__c == 'RAIJ'){ //Chinnapa
                    if(examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Admin_To__c != null){
                        clonedRec.Exam_Administration__c = examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Admin_To__c;
                    }
                    if(examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Part_To__c != null){
                        clonedRec.Exam_Part__c = examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Part_To__c;
                    }else if(part1Map.containsKey(clonedRec.Exam_Administration__c)){
                        clonedRec.Exam_Part__c = part1Map.get(clonedRec.Exam_Administration__c).Id;
                    }
                    if(examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Site_To__c != null){
                        clonedRec.Exam_Site__c = examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Site_To__c;
                    }else if(clonedRec.Exam_Part__c != null){
                        string key = clonedRec.Exam_Part__c+erm.Part_I_Exam_Site_From__r.Site_Code__c;
                        if(examSiteMap.containskey(key)){
                            clonedRec.Exam_Site__c = examSiteMap.get(key).Id;
                        }
                    }
                }else if(ea.Section__c == 'FRM Part 2'){
                    if(examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Admin_To__c != null){
                        clonedRec.Exam_Administration__c = examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Admin_To__c;
                    }
                    if(examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Part_To__c != null){
                        clonedRec.Exam_Part__c = examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Part_To__c;
                    }else if(part2Map.containsKey(clonedRec.Exam_Administration__c)){
                        clonedRec.Exam_Part__c = part2Map.get(clonedRec.Exam_Administration__c).Id;
                    }
                    if(examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Site_To__c != null){
                        clonedRec.Exam_Site__c = examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Site_To__c;
                    }else if(clonedRec.Exam_Part__c != null){
                        string key = clonedRec.Exam_Part__c+erm.Part_II_Exam_Site_From__r.Site_Code__c;
                        if(examSiteMap.containskey(key)){
                            clonedRec.Exam_Site__c = examSiteMap.get(key).Id;
                        }
                    }
                }
                if(ea.Result__c != null){
                    if((ea.Section__c == 'SCR' || ea.Section__c == 'RiskAI' || ea.Section__c == 'RAIJ') && ea.Result__c == 'No-Show'){
                        programIds.add(ea.Candidate_Commitment__c);
                    }
                    clonedRec.Result__c = null;
                    ea.Result__c = null;
                }
                //clonedRec.Deferred_From_Exam_Registration__c = ea.Id;
                clonedRec.Future_Free_Deferral__c = false;
                clonedRec.Selected_To_Allow_Future_Deferral__c = false;
                clonedRec.Defered__c = 'Approved';
                clonedRec.Deferral_Status__c = 'Deferred In';
                clonedRec.Cloned_From__c = ea.id;
                clonedRec.Other_Exam_Registrations__c = null;
                clonedRec.Cancelled__c = false;
                clonedRec.Seat_No__c = '';
                clonedRec.Room__c = null;
                clonedRec.Candidate_ID__c = null;
                clonedRec.Deferred_Exam_Administration__c = null;
                clonedRec.ATA_Cert_id__c = null;
                clonedRec.ATA_Cert_Type__c = null;
                clonedRec.Outbound_Status__c = null;
                clonedRec.ATA_Name_as_it_appears_on_ID__c = null;
                clonedRec.Updated_to_FRM_1__c = false;
                clonedRec.Name = '';
                clonedRec.Active_Integration_Data__c = null;
                clonedRec.Category_1__c = '';
                clonedRec.Category_2__c = ''; 
                clonedRec.Category_3__c = ''; 
                clonedRec.Category_4__c = ''; 
                clonedRec.Category_5__c = ''; 
                clonedRec.Category_6__c = ''; 
                clonedRec.Category_7__c = ''; 
                clonedRec.Category_8__c = ''; 
                clonedRec.Category_9__c = '';
                clonedRec.Quartile_1__c = null;
                clonedRec.Quartile_2__c = null;
                clonedRec.Quartile_3__c = null;
                clonedRec.Quartile_4__c = null;
                clonedRec.Quartile_5__c = null;
                clonedRec.Quartile_6__c = null;
                clonedRec.Quartile_7__c = null;
                clonedRec.Quartile_8__c = null;
                clonedRec.Quartile_8__c = null;
                clonedRec.Select_To_Move__c = false;
                clonedRec.Outbound_Type__c = null;
            	clonedRec.Integration_Type__c = null;
                clonedRec.EBooks_Created__c = false;
                clonedRec.Late_Deferral__c = null;
                clonedRec.Exam_Violation_Commets__c = '';
                clonedRec.Exam_Violation_Type__c = null;
                clonedRec.hasViolation__c = false;
                clonedRec.Hide_Exam_Result__c = false;
                clonedRec.ID_Exception__c = false;
                clonedRec.Accepted_ID_Type__c = '';
                clonedRec.Original_Exam_Administration__c = clonedRec.Exam_Administration__c;
                if(modToOppMap.containskey(erm.Id) && modToOppMap.get(erm.Id).ia_crm__Intacct_Transaction__c == 'Salesforce - Postponed')
                clonedRec.Previous_Deferral_Type__c = 'Postponed'; 
                ea.Defered__c = 'Approved';
                ea.Cancelled__c =true;
                ea.Cancel_Reason__c ='Deferral';
                ea.Deferral_Status__c ='Deferred Out';
                ea.Select_To_Move__c = false;
                if(erm.Deferral_SubType__c != null)
                    ea.Deferral_SubType__c = erm.Deferral_SubType__c;
                       
                oldAttemptsListToUpdate.add(ea);
                newAttemptsList.add(clonedRec);
            }
        }
        
        if(programIds != null){
            List<Contract> programList = [Select Id,Status,Eligible_For_Scr_Discount__c,Eligible_For_Scr_Discount_Date__c,SCR_Start_Date__c,SCR_End_Date__c
                                          from Contract where Id IN: programIds];
            for(Contract prg : programList){
                prg.Status = 'Activated';
                prg.Eligible_For_Scr_Discount__c = false;
                prg.Eligible_For_Scr_Discount_Date__c = null;
                prg.SCR_Start_Date__c = null;
                prg.SCR_End_Date__c = null;
            }
            
            update programList;
        }
        
        if(!oldAttemptsListToUpdate.isEmpty()){
            update oldAttemptsListToUpdate;
        }
        if(!newAttemptsList.isEmpty()){
            insert newAttemptsList;
        }
        deferralsToUpdate.addAll(deferralsToUpdateSet);
        if(!deferralsToUpdate.isEmpty()){
            update deferralsToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    public void execute(SchedulableContext context){
        Id batchInstanceId = Database.executeBatch(new processRegistrationDeferral_Batch(),1);
    }

}