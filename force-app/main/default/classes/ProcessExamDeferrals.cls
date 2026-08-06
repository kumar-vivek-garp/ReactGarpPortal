public class ProcessExamDeferrals {
    @AuraEnabled
    public static string processDeferrals(string recordId){
        String returnMessage;
        Admin_Exam_Deferral__c aed = [Select Id,Process_Complete__c,Parent_Admin_Exam_Deferral__c 
                                        from Admin_Exam_Deferral__c
                                        where Id=: recordId];
        if(aed.Parent_Admin_Exam_Deferral__c != null){
            returnMessage = 'Deferrals can only be processed from Parent Exam Admin Deferrals';
        }else if(aed.Process_Complete__c == true){
            returnMessage = 'Exam Admin Deferral is already processed';
        }else{
            try{
                updateExamRegModification_Batch ermBatch = new updateExamRegModification_Batch(recordId);
                database.executeBatch(ermBatch, 1);
                //aed.Process_Complete__c = true;
                //update aed;
                returnMessage = 'Exam Admin Deferral is queued for processing';
            }catch(exception e){
                returnMessage = 'Failed to process, please contact Admin';
            }
        }
        return returnMessage;
    } 
}