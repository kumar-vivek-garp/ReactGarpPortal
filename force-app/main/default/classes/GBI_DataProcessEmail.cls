/* Apex Class to Handle GBI Email Notification whenever a Data Process happened from GBI Python Engine
 * Invoked by Process Builder GBI_Data_Processing_Email upon Data Submission creation
 * 01/08/2019 Xiang - Switched to Email Distribution List (DL) address
 */
public without sharing class GBI_DataProcessEmail {
    
    @InvocableMethod(label='GBI_DataProcessEmail' description='Email GBI Distribution List upon data processing happened.')
    public static void dataProcessEmail(List<Id> dataSubIds) {
        System.debug('GBI_DataProcessEmail.dataProcessEmail() - dataSubIds: ' + dataSubIds);
        
        if(dataSubIds.size() > 0) {
            // No longer need GBI Groups - Use Email Distribution List Instead
            /* Map<Id, User> usersInGBIOps = new Map<Id, User>([
                SELECT Id FROM User WHERE IsActive = true AND Id IN 
                (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'GBI_Tech_Ops')
            ]); */
            Set<String> emailToAdd = new Set<String>();
            for(String oneToAdd : Label.GBI_Email_To_Address.split(';')) {
                emailToAdd.add(oneToAdd);
            }
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            List<Study_Data_Submission__c> dataSubs = [SELECT Id, Study_Round__r.Study__r.OwnerId, CreatedDate, Details__c, 
                                                       Study_Account__c, Study_Round__r.Study__c, Study_Account__r.Name, Action__c, Status__c
                                                       FROM Study_Data_Submission__c WHERE Id IN :dataSubIds];
            
            for(Integer i=0; i<dataSubs.size(); i++) {
                Study_Data_Submission__c dataSub = dataSubs[i];
                Id studyOwnerId = dataSub.Study_Round__r.Study__r.OwnerId;
                
                // Gather all related User Ids - Switched to Email DL address
                /* Set<Id> allRecipantIds = new Set<Id>();
                allRecipantIds.add(studyOwnerId);
                allRecipantIds.addAll(usersInGBIOps.keySet());
                System.debug('allRecipantIds: ' + allRecipantIds); */
                
                // Construct Email - With Guest User VF Template gives a Java exception, set body directly instead
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                Datetime creDate = dataSub.CreatedDate;
                String details = dataSub.Details__c;
                String htmlBody = '<style>p{margin-bottom:1em;font-family:Arial,sans-serif}li{margin-bottom:1em;font-family:Arial,sans-serif}.ticket-divide-line{height:3px;background-color:#00a2dd;margin:10px}.header{color:#3997c1;font-family:Arial,sans-serif;font-size:x-large;font-weight:700}.footer{font-family:Arial,sans-serif;margin:20px;text-align:center;font-size:x-small}</style><div style=margin:20px><p style=text-align:center><img src=http://www.garp.org/www/newmedia/gbi-logo.png><p>A GBI processing activity was completed on ' + String.valueof(creDate) + '. ';
                htmlBody += 'Please check below details:<br><br><b>' + details + '</b><p>Kind regards,<br>GARP Benchmarking Initiative</div>';
                email.setHtmlBody(htmlBody);
                
                String subject;
                if(null != dataSub.Study_Account__c) {
                    subject = dataSub.Study_Round__r.Study__c + ' - ' + dataSub.Study_Account__r.Name + ' - ' + dataSub.Action__c + ' - ' + dataSub.Status__c;
                }else {
                    subject = dataSub.Study_Round__r.Study__c + ' - ' + dataSub.Action__c + ' - ' + dataSub.Status__c;                
                }
                email.setSubject(subject);
                
                // Setup Email Config
                email.setTargetObjectId(studyOwnerId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setSaveAsActivity(false);
                email.setToAddresses(new List<String>(emailToAdd));
                email.setSenderDisplayName('GBI Processing Automation');
                
                emailList.add(email);
            }
            
            System.debug('Emails size: ' + emailList.size());
            if(emailList.size() > 0) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList, false);
                System.debug('SendEmailResult: ' + results);
            }
        }
    }
    
}