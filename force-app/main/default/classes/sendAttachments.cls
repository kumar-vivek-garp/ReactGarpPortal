Global class sendAttachments {
 
    @InvocableMethod
    public static void sendEmailWithAttachements(List<id> RecordId){
        //Get the Team Reg record
        List<Team_Registration__c> Treg = [SELECT Id,BD_Rep_Email__c,Name,Contact__r.Email,Contact__c,Team_Registration_Link__c,End_Date__c,Manual_Invoice_Number__c FROM Team_Registration__c WHERE Id = :RecordId[0]];
        
       /* // Get Invoice attachments
        String fileName = Treg[0].Manual_Invoice_number__c + 'pdf';
        //String fileName = Treg[0].Manual_Invoice_number__c;
        List<Attachment> attList = [SELECT Name, Body, ContentType FROM Attachment WHERE parentId =:RecordId[0] AND Name=: fileName];
        //SELECT ContentDocumentId,ContentDocument.CreatedDate,LinkedEntityId, ContentDocument.Title FROM ContentDocumentLink where LinkedEntityId = Con];
        */
        //Get the Email Template
        List<EmailTemplate> listEmailTemplates = [SELECT Id, Body, Subject, HtmlValue  from EmailTemplate where DeveloperName = :'B2B_Payment_Received_Email'];
        
        //Set recipients
       // String[] ToAddress= new string[] {Treg[0].BD_Rep_Email__c,Treg[0].Contact__r.Email};
              String[] ToAddress= new string[] {Treg[0].Contact__r.Email};
            //String []ToAddress = new string[] {'divya.lankapothu@garp.com'};
            
            //Send notification
          //  sendEmailNotification(Treg, attList, listEmailTemplates,ToAddress);
        sendEmailNotification(Treg, listEmailTemplates,ToAddress);
    }
    
   /* webservice static void sendInvoiceEmailButton(String TeamRegId) {
        //Get the Team Reg record
        List<Team_Registration__c> Treg = [SELECT Id,BD_Rep_Email__c,Name,Contact__r.Email,Contact__c,Team_Registration_Link__c,End_Date__c,Manual_Invoice_Number__c FROM Team_Registration__c WHERE Id = :TeamRegId];
        
        //Get the invoice attachment
        String fileName = Treg[0].Manual_Invoice_number__c + '.pdf';
         //String fileName = Treg[0].Manual_Invoice_number__c;
        List<Attachment> attList = [SELECT Name, Body, ContentType FROM Attachment WHERE parentId =:TeamRegId AND Name=: fileName];
        
        //Get the Email Template
        List<EmailTemplate> listEmailTemplates = [SELECT Id, Body, Subject, HtmlValue  from EmailTemplate where DeveloperName = :'Send_Invoice_Attachment_by_Accounting_Email'];
        
        //Set recipients
        String[] ToAddress = new string[] {Treg[0].Contact__r.Email};
            // String []ToAddress = new string[] {'divya.lankapothu@garp.com'};
            
            //Send Notification
            sendEmailNotification(Treg, attList, listEmailTemplates,ToAddress);
    }
  */  
    //public static void sendEmailNotification(List<Team_Registration__c> Treg, List<Attachment> attList, List<EmailTemplate> listEmailTemplates, String[] ToAddress){
        public static void sendEmailNotification(List<Team_Registration__c> Treg,List<EmailTemplate> listEmailTemplates, String[] ToAddress){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        //Create attachment list
       // List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
        //string msg;
        // if(!listEmailTemplates.isEmpty()){
        //   List<String> bodies = new List<String>();
        // bodies.add(listEmailTemplates[0].HtmlValue);
        // List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(Treg[0].Contact__c, Treg[0].Id, bodies);
        // Messaging.SingleEmailMessage renderStoredEmailTemplate(String templateId, String whoId, String whatId)
        // msg = resList[0].getMergedBody();
        //}
        
       /* for(Attachment att:attList){
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(att.Name);
            efa.setBody(att.body);
            efa.setContentType(att.ContentType);
            efa.setInline(false);
            attachmentList.add(efa);
        }
        System.debug('attachment list is'+attachmentList);
        // public static Messaging.SingleEmailMessage renderStoredEmailTemplate(String templateId, String whoId, String whatId)
        */
        Messaging.SingleEmailMessage singlemail = new Messaging.SingleEmailMessage();
        singlemail= Messaging.renderStoredEmailTemplate(listEmailTemplates[0].Id,Treg[0].Contact__c,Treg[0].Id);
        singlemail.setToAddresses(ToAddress);
        // singlemail.toAddresses = new String[] { Treg[0].BD_Rep_Email__c,Treg[0].Contact__r.Email };
        //String []ccAddress = new string[] {Label.Accounting_Email_for_Team_Reg};
            String[] ccAddress = Label.Accounting_Email_for_Team_Reg.split(',');
            singlemail.setCcAddresses(ccAddress);
        //singlemail.setFileAttachments(attachmentList);        // Attach files to email instance
        /*singlemail.setHtmlBody(msg);
        singlemail.setSubject(listEmailTemplates[0].Subject);*/
        emails.add(singlemail);
        List<OrgWideEmailAddress> addresses = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'ar@garp.com'];
        if (!addresses.isEmpty()) {
            singlemail.setOrgWideEmailAddressId(addresses[0].Id);
        }
        
        //send the message
        if(!test.isRunningTest())
        	Messaging.sendEmail(emails);
    }
    
    
}