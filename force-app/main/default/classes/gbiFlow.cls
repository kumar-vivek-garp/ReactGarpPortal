public without sharing class gbiFlow {
    
    @TestVisible public static Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    
    public static void sendMailGBI(String contactId, String voteId){
        
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress limit 1];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate where DeveloperName = 'GBI_Notify_Vote'];

        Contact c = [SELECT Id, Email FROM contact WHERE id = :contactId];
        
        email.setTemplateID(emailTemplate.Id); 
        email.setTargetObjectId(contactId);
        
        email.setWhatId(voteId);
        email.setSaveAsActivity(false);
        email.setSenderDisplayName('Test Org Account Team');
        
        emails.add(email);
        
        Messaging.sendEmail(emails, false); 
        
    }
    
    public static void throwError(String errorMsg) {
        System.assert(false, errorMsg);
    }
    
    @InvocableMethod(label='gbiFlow' description='Send email to GBI Voters.')
    public static void sendGBIVoteEMail(List<String> ids) {  

        if(!ids.isEmpty()){
            String[] arrText = ids[0].split('~'); 
            sendMailGBI(arrText[0], arrText[1]);            
        }
   
    }
    
}