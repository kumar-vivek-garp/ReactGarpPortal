public class GBIPaymentRcptRdrctCntrlr {
    public Study_Disclose_Protocol_Submission__c stdCntrlr {get; set;}
    public GBIPaymentRcptRdrctCntrlr(ApexPages.StandardController controller){
        stdCntrlr = (Study_Disclose_Protocol_Submission__c)controller.getRecord();
    }
    
    public PageReference doRedirect(){
        Study_Disclose_Protocol_Submission__c submission = [Select Id,Study__c,Study_Account__c from Study_Disclose_Protocol_Submission__c where Id =: stdCntrlr.Id];
        PageReference pageRef = new PageReference('/apex/GBIStudyPaymentReceipt');
        pageRef.getParameters().put('studyId',submission.Study__c);
        pageRef.getParameters().put('submissionId',submission.Id);
        pageRef.getParameters().put('studyAccountId',submission.Study_Account__c);
        pageRef.setRedirect(true);
        return pageRef;
    }
}