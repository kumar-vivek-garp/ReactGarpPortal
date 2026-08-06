global class processExamRegModificationToPndngBatch implements Database.Batchable<sObject>{
    private String recordId;
    public processExamRegModificationToPndngBatch() {
        
    }
    public processExamRegModificationToPndngBatch(string inputRecordId) {
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
                                            	   Bulk_Site_Deferral__c
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
                                                    Bulk_Site_Deferral__c
                                            from Exam_Registration_Modification__c 
                                            where Status__c = 'Opportunity Created']);
        }
        
    }
    
    global void execute(Database.BatchableContext bc, List<Exam_Registration_Modification__c> scope){
        Set<Id> modIds = new Set<Id>();
        Set<Id> regIds = new Set<Id>();
        List<Exam_Attempt__c> regToUpdate = new List<Exam_Attempt__c>();
        List<Exam_Registration_Modification__c> deferralsToUpdate = new List<Exam_Registration_Modification__c>();
        for(Exam_Registration_Modification__c erm : scope){
            modIds.add(erm.id);
            erm.Status__c = 'Pending';
            erm.Part_I_Exam_Site_To__c = null;
            erm.Part_II_Exam_Site_To__c = null;
            erm.Free_Deferral__c = true;
            erm.Not_Applicable_to_One_Time_Def__c = true;
            deferralsToUpdate.add(erm);
            
            if(erm.Part_I_Exam_Registration__c != null){
                regIds.add(erm.Part_I_Exam_Registration__c);
            }
            if(erm.Part_II_Exam_Registration__c != null){
                regIds.add(erm.Part_II_Exam_Registration__c);
            }
        }
        
        if(!deferralsToUpdate.isEmpty())
        	update deferralsToUpdate;
        
        if(!modIds.isEmpty() && !test.isRunningTest())
            ExamManagementController.processExamRegMods(modIds);
        
        List<Exam_Attempt__c> examRegs = [Select Id,Select_To_Move__c from Exam_Attempt__c where Id IN: regIds];
        
        for(Exam_Attempt__c ea : examRegs){
            if(ea.Select_To_Move__c == true){
                ea.Select_To_Move__c = false;
                ea.Marked_For_Free_Covid_Deferral__c = true;
                regToUpdate.add(ea);
            }
        }
        
        if(!regToUpdate.isEmpty()){
            update regToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}