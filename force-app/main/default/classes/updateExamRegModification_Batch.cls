global class updateExamRegModification_Batch implements Database.Batchable<sObject>{
    private string parentDeferralId;
    private string recordId;
    public updateExamRegModification_Batch(string inputId){
        parentDeferralId = inputId;
    }
    public updateExamRegModification_Batch(string inputId,string inputRecordId){
        parentDeferralId = inputId;
        recordId = inputRecordId;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        if(!Test.isRunningTest()){
            if(String.isNotBlank(recordId)){
                return Database.getQueryLocator([Select Id,From_Exam_Administration__c,From_Exam_Group__c,From_Exam_Part__c,From_Exam_Site__c,Deferral_Subtype__c,
                                                        Parent_Admin_Exam_Deferral__c,Requested_Part__c,To_Exam_Administration__c,Move_Selected_Members__c,
                                                        To_Exam_Group__c,To_Exam_Part__c,To_Exam_Site__c,Submitted_By_user__c,Exam_Group_Registration_Deferral__c
                                                from Admin_Exam_Deferral__c 
                                                where Process_Complete__c = False AND To_Exam_Site__c != null AND Id =: recordId ORDER BY Requested_Part__c]);
            }else{
                return Database.getQueryLocator([Select Id,From_Exam_Administration__c,From_Exam_Group__c,From_Exam_Part__c,From_Exam_Site__c,Deferral_Subtype__c,
                                                    Parent_Admin_Exam_Deferral__c,Requested_Part__c,To_Exam_Administration__c,Move_Selected_Members__c,
                                                    To_Exam_Group__c,To_Exam_Part__c,To_Exam_Site__c,Submitted_By_user__c,Exam_Group_Registration_Deferral__c
                                                from Admin_Exam_Deferral__c 
                                                where Process_Complete__c = False AND To_Exam_Site__c != null AND (Parent_Admin_Exam_Deferral__c =: parentDeferralId OR Id =: parentDeferralId) ORDER BY Requested_Part__c]);
            
            }
        }else{
            return Database.getQueryLocator([Select Id,From_Exam_Administration__c,From_Exam_Group__c,From_Exam_Part__c,From_Exam_Site__c,Deferral_Subtype__c,
                                                    Parent_Admin_Exam_Deferral__c,Requested_Part__c,To_Exam_Administration__c,Move_Selected_Members__c,
                                                    To_Exam_Group__c,To_Exam_Part__c,To_Exam_Site__c,Submitted_By_user__c,Exam_Group_Registration_Deferral__c
                                            from Admin_Exam_Deferral__c 
                                            where Process_Complete__c = False AND Id =: parentDeferralId]);
        }
        
    }
    
    global void execute(Database.BatchableContext bc, List<Admin_Exam_Deferral__c> scope){
        String oppstatus = 'closed';
        List<Admin_Exam_Deferral__c> deferralList = new List<Admin_Exam_Deferral__c>();
        Set<Id> registrationsIdSet = new Set<Id>();
        Map<String,String> examRegToModificationsMap = new Map<String,String>();
        List<Opportunity> opptyList = new List<Opportunity>();
        List<Exam_Registration_Modification__c> part1ModificationsToInsert = new List<Exam_Registration_Modification__c>();
        List<Exam_Registration_Modification__c> part2ModificationsToUpsert = new List<Exam_Registration_Modification__c>();
        for(Admin_Exam_Deferral__c aed : scope){
            date previousDate = date.newInstance(2020, 5, 16);
            Exam_Sites__c es = [Select Id,Exam_Date__c from Exam_Sites__c where Id =: aed.From_Exam_Site__c Limit 1];
            if(es != null && es.Exam_Date__c != null && es.Exam_Date__c.isSameDay(previousDate)){
                es.Exam_Date__c = date.newInstance(2020, 10, 24);
            }
            List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
            boolean moveSelectedRegs;
            if(aed.Move_Selected_Members__c == true){
                moveSelectedRegs = true;
            }else if(aed.Move_Selected_Members__c == false){
                moveSelectedRegs = false;
            }
            String reqPart = aed.Requested_Part__c;
            if(reqPart == 'FRM Part 1' || reqPart == 'ERP Exam Part I' || reqPart == 'SCR' || reqPart == 'RiskAI' || reqPart == 'RAIJ'){//Chinnapa
                //system.debug('Check this method');
                if(String.isNotBlank(aed.From_Exam_Administration__c)){
                    examAttemptList = [Select Id,Section__c,Member__c,Defered__c,Select_To_Move__c
                                       from Exam_Attempt__c
                                       where Section__c =: reqPart AND
                                       Exam_Administration__c =: aed.From_Exam_Administration__c AND
                                       Exam_Part__c =: aed.From_Exam_Part__c AND
                                       Exam_Site__c =: aed.From_Exam_Site__c AND
                                       Cancelled__c != true AND
                                       Opportunity_StageName__c =: oppstatus AND
                                       Select_To_Move__c =: moveSelectedRegs AND
                                       Candidate_Commitment__r.status like 'Activated%'];
                   // system.debug('Check this method list'+examAttemptList);
                }else{
                    examAttemptList = [Select Id,Section__c,Member__c,Defered__c,Select_To_Move__c
                                       from Exam_Attempt__c
                                       where Section__c =: reqPart AND
                                       Exam_Date__c =: es.Exam_Date__c AND
                                       Exam_Site__c =: aed.From_Exam_Site__c AND
                                       Cancelled__c != true AND
                                       Opportunity_StageName__c =: oppstatus AND
                                       Select_To_Move__c =: moveSelectedRegs AND
                                       Candidate_Commitment__r.status like 'Activated%'];
                  //  system.debug('Check this method list 2'+examAttemptList);
                }
                
                for(Exam_Attempt__c ea : examAttemptList){
                    registrationsIdSet.add(ea.id);
                }
                opptyList = [Select Id,Exam_Registration_Modification__c,Ea_Id__c,Late_Ea_Id__c from Opportunity where Ea_Id__c IN:registrationsIdSet OR Late_EA_Id__c IN: registrationsIdSet];
                
                for(Opportunity opp : opptyList){
                    if(opp.Exam_Registration_Modification__c != null){
                        if(String.isNotBlank(opp.EA_Id__c)){
                    		examRegToModificationsMap.put(opp.EA_Id__c,opp.Exam_Registration_Modification__c);
                        }else if(String.isNotBlank(opp.EA_Id__c)){
                            examRegToModificationsMap.put(opp.Late_EA_Id__c,opp.Exam_Registration_Modification__c);
                        }
                    }
                }
                
                for(Exam_Attempt__c ea : examAttemptList){
                    if((aed.Exam_Group_Registration_Deferral__c == false && ea.Defered__c != 'Pending') || (aed.Exam_Group_Registration_Deferral__c == true && ea.Defered__c == 'Pending')){
                        Exam_Registration_Modification__c erm = new Exam_Registration_Modification__c();
                        erm.Part_I_Exam_Registration__c = ea.id;
                        erm.Part_I_Exam_Admin_From__c = aed.From_Exam_Administration__c;
                        erm.Part_I_Exam_Admin_To__c = aed.To_Exam_Administration__c;
                        erm.Part_I_Exam_Group_From__c = aed.From_Exam_Group__c;
                        erm.Part_I_Exam_Group_To__c = aed.To_Exam_Group__c;
                        erm.Part_I_Exam_Part_From__c = aed.From_Exam_Part__c;
                        erm.Part_I_Exam_Part_To__c = aed.To_Exam_Part__c;
                        erm.Part_I_Exam_Site_From__c = aed.From_Exam_Site__c;
                        erm.Part_I_Exam_Site_To__c = aed.To_Exam_Site__c;
                        erm.Used_To_Move_to_New_Exam_Group__c = true;
                        erm.Deferral_SubType__c = aed.Deferral_SubType__c;
                        if(aed.Exam_Group_Registration_Deferral__c == true && examRegToModificationsMap.containsKey(ea.Id)){
                            erm.Status__c = 'Opportunity Created';
                            erm.Id = examRegToModificationsMap.get(ea.Id);
                        }else if(aed.Exam_Group_Registration_Deferral__c){
                            erm.Status__c = 'Opportunity Created';
                        }else{
                            erm.Bulk_Site_Deferral__c = true;
                            erm.Status__c = 'Pending Bulk Modification';
                        }
                        part1ModificationsToInsert.add(erm);
                    }
                }
            }
            
            if(!part1ModificationsToInsert.isEmpty()){
                upsert part1ModificationsToInsert;
            }
            
            if(reqPart == 'FRM Part 2' || reqPart == 'ERP Exam Part II'){
                Set<Id> memberIds = new Set<Id>();
                
                if(String.isNotBlank(aed.From_Exam_Administration__c)){
                    examAttemptList = [Select Id,Section__c,Member__c,Defered__c,Select_To_Move__c
                                       from Exam_Attempt__c
                                       where Section__c =: reqPart AND
                                       Exam_Administration__c =: aed.From_Exam_Administration__c AND
                                       Exam_Part__c =: aed.From_Exam_Part__c AND
                                       Exam_Site__c =: aed.From_Exam_Site__c AND
                                       Cancelled__c != true AND
                                       Opportunity_StageName__c =: oppstatus AND
                                       Select_To_Move__c =: moveSelectedRegs AND
                                       Candidate_Commitment__r.status like 'Activated%'];
                }else{
                    examAttemptList = [Select Id,Section__c,Member__c,Defered__c,Select_To_Move__c 
                                       from Exam_Attempt__c
                                       where Section__c =: reqPart AND
                                       Exam_Date__c =: es.Exam_Date__c AND
                                       Exam_Site__c =: aed.From_Exam_Site__c AND
                                       Cancelled__c != true AND
                                       Opportunity_StageName__c =: oppstatus AND
                                       Select_To_Move__c =: moveSelectedRegs AND
                                       Candidate_Commitment__r.status like 'Activated%'];
                }
                
                for(Exam_Attempt__c ea : examAttemptList){
                    registrationsIdSet.add(ea.id);
                    if(ea.Member__c != null){
                        memberIds.add(ea.Member__c);
                    }
                }
                
                List<Exam_Registration_Modification__c> partIList = [Select Id,Part_I_Exam_Registration__c,Part_I_Exam_Registration__r.Section__c,
                                                                            Part_I_Exam_Registration__r.Member__c,
                                                                            Part_I_Exam_Admin_From__c,Part_I_Exam_Group_From__c,
                                                                            Part_I_Exam_Part_From__c,Part_I_Exam_Site_From__c
                                                                     from Exam_Registration_Modification__c
                                                                     where Part_I_Exam_Registration__r.Member__c IN: memberIds AND
                                                                           (Status__c = 'Pending Bulk Modification' OR Status__c = 'Opportunity Created') AND
                                                                           (Part_I_Exam_Registration__r.Section__c = 'FRM Part 1' OR Part_I_Exam_Registration__r.Section__c = 'ERP Exam Part I')];
                //system.debug('Check the list'+partIList.size());
                Map<String,Exam_Registration_Modification__c> ermMap = new Map<String,Exam_Registration_Modification__c>();
                for(Exam_Registration_Modification__c erm : partIList){
                    registrationsIdSet.add(erm.Part_I_Exam_Registration__c);
                    String matchingKey = erm.Part_I_Exam_Registration__r.Member__c+erm.Part_I_Exam_Registration__r.Section__c;
                    ermMap.put(matchingKey,erm);
                    //system.debug('Check This Map'+matchingkey);
                }
                
				opptyList = [Select Id,Exam_Registration_Modification__c,Ea_Id__c,Late_Ea_Id__c from Opportunity where Ea_Id__c IN:registrationsIdSet OR Late_EA_Id__c IN: registrationsIdSet];
				
                for(Opportunity opp : opptyList){
                    if(opp.Exam_Registration_Modification__c != null){
                        if(String.isNotBlank(opp.EA_Id__c)){
                    		examRegToModificationsMap.put(opp.EA_Id__c,opp.Exam_Registration_Modification__c);
                        }else if(String.isNotBlank(opp.EA_Id__c)){
                            examRegToModificationsMap.put(opp.Late_EA_Id__c,opp.Exam_Registration_Modification__c);
                        }
                    }
                }
                
                for(Exam_Attempt__c ea : examAttemptList){
                    if((aed.Exam_Group_Registration_Deferral__c == false && ea.Defered__c != 'Pending') || (aed.Exam_Group_Registration_Deferral__c == true && ea.Defered__c == 'Pending')){
                        Exam_Registration_Modification__c erm = new Exam_Registration_Modification__c();
                        erm.Part_II_Exam_Registration__c = ea.id;
                        erm.Part_II_Exam_Admin_From__c = aed.From_Exam_Administration__c;
                        erm.Part_II_Exam_Admin_To__c = aed.To_Exam_Administration__c;
                        erm.Part_II_Exam_Group_From__c = aed.From_Exam_Group__c;
                        erm.Part_II_Exam_Group_To__c = aed.To_Exam_Group__c;
                        erm.Part_II_Exam_Part_From__c = aed.From_Exam_Part__c;
                        erm.Part_II_Exam_Part_To__c = aed.To_Exam_Part__c;
                        erm.Part_II_Exam_Site_From__c = aed.From_Exam_Site__c;
                        erm.Part_II_Exam_Site_To__c = aed.To_Exam_Site__c;
                        erm.Used_To_Move_to_New_Exam_Group__c = true;
                        erm.Deferral_SubType__c = aed.Deferral_SubType__c;
                        if(aed.Exam_Group_Registration_Deferral__c == true && examRegToModificationsMap.containsKey(ea.Id)){
                            erm.Status__c = 'Opportunity Created';
                        	erm.Id = examRegToModificationsMap.get(ea.Id);
                        }else if(aed.Exam_Group_Registration_Deferral__c == true){
                            if(ea.Section__c == 'FRM Part 2' && ermMap.containskey(ea.Member__c+'FRM Part 1')){
                                //system.debug('Check this if');
                                if(examRegToModificationsMap.containskey(ermMap.get(ea.Member__c+'FRM Part 1').Part_I_Exam_Registration__c)){
                                    erm.Status__c = 'Opportunity Created';
                                    erm.id = examRegToModificationsMap.get(ermMap.get(ea.Member__c+'FRM Part 1').Part_I_Exam_Registration__c);
                                }else{
                                    erm.id = ermMap.get(ea.Member__c+'FRM Part 1').id;
                                    erm.Status__c = 'Opportunity Created';
                                }
                            }else if(ea.Section__c == 'ERP Exam Part II' && ermMap.containskey(ea.Member__c+'ERP Exam Part I')){
                                //system.debug('Check this else');
                                if(examRegToModificationsMap.containskey(ermMap.get(ea.Member__c+'ERP Exam Part I').Part_I_Exam_Registration__c)){
                                    erm.Status__c = 'Opportunity Created';
                                    erm.id = examRegToModificationsMap.get(ermMap.get(ea.Member__c+'ERP Exam Part I').Part_I_Exam_Registration__c);
                            	}else{
                                    erm.id = ermMap.get(ea.Member__c+'ERP Exam Part I').id;
                                    erm.Status__c = 'Opportunity Created';
                                }
                            }else{
                                erm.Status__c = 'Opportunity Created';
                            }
                        }else{
                            if(ea.Section__c == 'FRM Part 2' && ermMap.containskey(ea.Member__c+'FRM Part 1')){
                                //system.debug('Check this if');
                                erm.id = ermMap.get(ea.Member__c+'FRM Part 1').id;
                            }else if(ea.Section__c == 'ERP Exam Part II' && ermMap.containskey(ea.Member__c+'ERP Exam Part I')){
                                //system.debug('Check this else');
                                erm.id = ermMap.get(ea.Member__c+'ERP Exam Part I').id;
                            }
                            erm.Bulk_Site_Deferral__c = true;
                            erm.Status__c = 'Pending Bulk Modification';
                        }
                        part2ModificationsToUpsert.add(erm);
                    }
                }
                if(!part2ModificationsToUpsert.isEmpty()){
                    upsert part2ModificationsToUpsert;
                }
            }
            aed.Process_Complete__c = true;
            deferralList.add(aed);
        }
        update deferralList;
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}