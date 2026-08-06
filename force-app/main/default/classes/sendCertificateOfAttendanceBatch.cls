global class sendCertificateOfAttendanceBatch implements Database.Batchable<sObject>, Database.Stateful {
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Contact_Name__c,GARP_ID__c,Certificate_Sent__c FROM Certificate_of_Attendance__c where Certificate_Sent__c = false';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Certificate_of_Attendance__c> scope)
    {
        List<Messaging.SingleEmailMessage> emailList =new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'cpd@garp.com'];
        string templateId;
        if(!test.isRunningTest()){
        	templateId = system.label.Certificate_of_Attendance_Email_Template_Id;
        }else{
            templateId = [Select Id from EmailTemplate limit 1].id;
        }
        for(Certificate_of_Attendance__c ca : scope){
            PageReference pdf =  Page.CPDConventionCert2022;
            pdf.getParameters().put('id',ca.Id);
            blob pdfBlob;
            if(!test.isRunningTest()){
            	pdfBlob = pdf.getContentAsPDF();
            }else if(test.isRunningTest()){
                pdfBlob = blob.valueOf('GARP Convention Certificate');
            }
            
            Messaging.EmailFileAttachment pdfAttch = new Messaging.EmailFileAttachment();
            pdfAttch.setContentType('application/pdf');
            pdfAttch.setFileName('Certificate Of Attandance.pdf');
            pdfAttch.setInline(false);
            pdfAttch.setBody(pdfBlob);
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, ca.Contact_Name__c, ca.Id);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{pdfAttch});
            email.setOrgWideEmailAddressId(owea.get(0).Id);
            emailList.add(email);
            ca.Certificate_Sent__c = true;
        }
        
        if(!emailList.isEmpty()){
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emailList);
            update scope;
        }
        
    }
    global void finish(Database.BatchableContext BC)
    {
    }
}