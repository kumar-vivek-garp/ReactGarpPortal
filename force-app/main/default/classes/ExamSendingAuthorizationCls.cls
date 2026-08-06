public class ExamSendingAuthorizationCls {

    @AuraEnabled(cacheable=true)
    public Static List<Exam_Attempt__c> getExamRegistrations(String garpId) {
        List<Exam_Attempt__c> examList = new List<Exam_Attempt__c>();
        for(Exam_Attempt__c ex:[Select Id,Name,Attending_Exam_Name__c,Exam_Administration__c,Section__c,Exam_Administration__r.Name,RPT_Exam_Program__c,RPT_Exam_Provider__c From Exam_Attempt__c Where Garp_Id__c =:garpId AND Opportunity__r.StageName = 'Closed' AND Result__c != null AND Cancelled__c = false AND Defered__c != 'Pending'  AND RPT_Exam_Program__c = 'FRM' AND RPT_Exam_Provider__c  = 'PSI']){
            examList.add(ex);
        }
        return examList;
    }

    @AuraEnabled
    public Static String sendForAuthorization(String recordId) {
        String retval = ''; 
        try{
            Exam_Attempt__c ex = new Exam_Attempt__c();
            ex.Id = recordId;
            ex.Outbound_Type__c = 'PSI';
            ex.Integration_Type__c = 'Eligibility Lifecycle';
            update ex;
            retval = 'Success';
        }catch(Exception ex){
            retval = 'Error:'+ex.getMessage();
        }
        return retval;
    }
}