public class GBIStudyInvoicesClass implements Queueable, Database.AllowsCallouts {
    
    public List<Study_Disclose_Protocol_Submission__c> SdpsListIds;
    
    
    public GBIStudyInvoicesClass(List<Study_Disclose_Protocol_Submission__c> SdpsListIds){
        this.SdpsListIds = SdpsListIds ;
    }
    
    public void execute(QueueableContext context) {
        
        for(Study_Disclose_Protocol_Submission__c StudyDiscProtocolId : SdpsListIds){
            
            Blob bodyData;
            Study_Disclose_Protocol_Submission__c sdps = [Select Id,Name,Study__c,Study_Account__c 
                                                          from Study_Disclose_Protocol_Submission__c where Id =: StudyDiscProtocolId.id];
            
            PageReference mypdf  = new PageReference('/apex/GBIStudyPaymentReceipt?id='+StudyDiscProtocolId.ID);
            mypdf .getParameters().put('studyId',sdps.Study__c);
            mypdf .getParameters().put('submissionId',sdps.Id);
            mypdf .getParameters().put('studyAccountId',sdps.Study_Account__c);
            mypdf .setRedirect(true);
            System.debug('Study Disclose Name' + sdps.Name);
            if(Test.isRunningTest())
                bodyData=blob.valueOf('Unit Test');
            
            else{
                try {   
                    bodyData = mypdf.getContentaspdf();
                    
                } catch (VisualforceException e) {
                    
                    bodyData = blob.valueOf('Exception : '+e.getMessage());
                    
                }
            }
            
            //String fileName = ''+sdps.Name;
            //System.debug('File Number' + fileName);
            
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce.
            cVersion.PathOnClient = 'GBIStudyPaymentReceipt' +'.pdf';//File name with extention
            cVersion.Title = 'GBIStudyPaymentReceipt';//Name of the file
            cVersion.VersionData = bodyData ;//File content
            Insert cVersion;
            
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = sdps.id;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;
        } 
    }
}