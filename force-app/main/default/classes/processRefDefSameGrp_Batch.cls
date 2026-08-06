global class processRefDefSameGrp_Batch implements Database.Batchable<sObject>{
	private String recordId; 
    public processRefDefSameGrp_Batch() {
        
    }
    public processRefDefSameGrp_Batch(string inputRecordId) {
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
                                            	   Bulk_Site_Deferral__c,Deferral_Subtype__c
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
                                                    Bulk_Site_Deferral__c,Deferral_Subtype__c
                                            from Exam_Registration_Modification__c 
                                            where Status__c = 'Opportunity Created']);
        }
        
    }
    
    global void execute(Database.BatchableContext bc, List<Exam_Registration_Modification__c> scope){
        Map<Id,Exam_Registration_Modification__c> examAttemptToDeferralMap = new Map<Id,Exam_Registration_Modification__c>();
        List<Exam_Attempt__c> oldAttemptsList = new List<Exam_Attempt__c>();
        List<Exam_Attempt__c> oldAttemptsListToUpdate = new List<Exam_Attempt__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id,Opportunity> modToOppMap = new Map<Id,Opportunity>();
        Set<Id> modIds = new Set<Id>();
        Set<Exam_Registration_Modification__c> deferralsToUpdateSet = new Set<Exam_Registration_Modification__c>();
        List<Exam_Registration_Modification__c> deferralsToUpdate = new List<Exam_Registration_Modification__c>();
        DescribeSObjectResult describeResult = Exam_Attempt__c.getSObjectType().getDescribe();  
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        Set<String> sectionp1lst = new Set<String>{
            'FRM Part 1',
            'ERP Exam Part I',
            'SCR',
            'RiskAI',
            'RAIJ'
        }; 
        for(Exam_Registration_Modification__c erm : scope){
            modIds.add(erm.id);
            if(erm.Part_I_Exam_Registration__c != null){
                if(erm.Part_I_Exam_Group_From__c != null && erm.Part_I_Exam_Group_To__c != null && erm.Part_I_Exam_Group_From__c == erm.Part_I_Exam_Group_To__c)
                	examAttemptToDeferralMap.put(erm.Part_I_Exam_Registration__c,erm);
            }
            if(erm.Part_II_Exam_Registration__c != null){
                if(erm.Part_II_Exam_Group_From__c != null && erm.Part_II_Exam_Group_To__c != null && erm.Part_II_Exam_Group_From__c == erm.Part_II_Exam_Group_To__c)
                	examAttemptToDeferralMap.put(erm.Part_II_Exam_Registration__c,erm);
            }
        }
        oppList = [Select Id,StageName,Free_Deferral__c,Exam_Registration_Modification__c From Opportunity where Exam_Registration_Modification__c IN: modIds];
        for(Opportunity opp : oppList){
            modToOppMap.put(opp.Exam_Registration_Modification__c,opp);
        }
        Set<Id> attemptsId = examAttemptToDeferralMap.keyset();
        String query = 'SELECT ' +String.join( fieldNames, ',' ) +' FROM Exam_Attempt__c'+' WHERE id IN: attemptsId';
        oldAttemptsList = Database.query(query);
        
        for(Exam_Attempt__c ea : oldAttemptsList){
            Exam_Registration_Modification__c erm = examAttemptToDeferralMap.containskey(ea.id) ? examAttemptToDeferralMap.get(ea.id) : null;
            if(erm != null && ((modToOppMap.containskey(erm.Id) && modToOppMap.get(erm.Id).StageName == 'Closed') || !modToOppMap.containskey(erm.Id))){
                erm.Status__c = 'Completed';
            	deferralsToUpdateSet.add(erm);
                ea.Deferral_SubType__c = erm.Deferral_SubType__c;
                ea.Select_To_Move__c = false;
                if((modToOppMap.containskey(erm.Id) && modToOppMap.get(erm.Id).Free_Deferral__c)){
                	ea.Free_Deferral__c = true;
                }else{
                    ea.Free_Deferral__c = false;
                }
                if(erm.Bulk_Site_Deferral__c){
                    ea.Allow_Future_Deferral__c = true;
                }else{
                    ea.Allow_Future_Deferral__c = false;
                }
                
                if(ea.Section__c != null && sectionp1lst.contains(ea.Section__c)){ //Chinnapa
                    if(examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Site_To__c != null)
                        ea.Exam_Site__c = examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Site_To__c;
                    if(examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Admin_To__c != null)
                        ea.Exam_Administration__c = examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Admin_To__c;
                    if(examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Part_To__c != null)
                        ea.Exam_Part__c = examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Part_To__c;
                }else if(ea.Section__c == 'FRM Part 2' || ea.Section__c == 'ERP Exam Part II'){
                    if(examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Site_To__c != null)
                        ea.Exam_Site__c = examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Site_To__c;
                    if(examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Admin_To__c != null)
                        ea.Exam_Administration__c = examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Admin_To__c;
                    if(examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Part_To__c != null)
                        ea.Exam_Part__c = examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Part_To__c;
                }
                
                oldAttemptsListToUpdate.add(ea);
            }
                
        }
        
        if(!oldAttemptsListToUpdate.isEmpty()){
            update oldAttemptsListToUpdate;
        }
        deferralsToUpdate.addAll(deferralsToUpdateSet);
        if(!deferralsToUpdate.isEmpty()){
            update deferralsToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}