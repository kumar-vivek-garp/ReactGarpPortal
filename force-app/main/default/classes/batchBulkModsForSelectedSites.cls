global class batchBulkModsForSelectedSites implements Database.Batchable<sObject>{
    private string siteId;
    private string adminExamId;
    public batchBulkModsForSelectedSites(string inputSiteId,string adminId){
        siteId = inputSiteId;
        adminExamId = adminId;
    }
	global Database.QueryLocator start(Database.BatchableContext bc){
        string section = 'FRM Part 1';
        string oppStatus = 'Closed';
        return Database.getQueryLocator([Select Id,Section__c,Member__c,Defered__c,Select_To_Move__c
                                         from Exam_Attempt__c
                                         where Section__c =: section AND
                                         Exam_Site__c =: siteId AND
                                         Cancelled__c != true AND
                                         Opportunity_StageName__c =: oppstatus AND
                                         Candidate_Commitment__r.status like 'Activated%']);
    }
    
    global void execute(Database.BatchableContext bc, List<Exam_Attempt__c> scope){
        List<Exam_Registration_Modification__c> part1ModificationsToInsert = new List<Exam_Registration_Modification__c>();
        Admin_Exam_Deferral__c aed = [Select Id,From_Exam_Administration__c,From_Exam_Group__c,From_Exam_Part__c,From_Exam_Site__c,
                                     Parent_Admin_Exam_Deferral__c,Requested_Part__c,To_Exam_Administration__c,Move_Selected_Members__c,
                                     To_Exam_Group__c,To_Exam_Part__c,To_Exam_Site__c,Submitted_By_user__c,Exam_Group_Registration_Deferral__c
                                     from Admin_Exam_Deferral__c 
                                     where Process_Complete__c = False AND To_Exam_Site__c != null AND Id =: adminExamId Limit 1];
                
        for(Exam_Attempt__c ea : scope){
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
                erm.Bulk_Site_Deferral__c = true;
                erm.Status__c = 'Pending Bulk Modification';
                part1ModificationsToInsert.add(erm);
            }
        }
            
        if(!part1ModificationsToInsert.isEmpty()){
            upsert part1ModificationsToInsert;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        Admin_Exam_Deferral__c aed = [Select Id,Process_Complete__c
                                      from Admin_Exam_Deferral__c 
                                      where Id =: adminExamId Limit 1];
        aed.Process_Complete__c = true;
        update aed;
    }
}