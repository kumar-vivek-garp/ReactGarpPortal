global class MemberNotificationSendBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public String notificationId;  
    public String recipientId;  
    public String sendingMessage; 

    global MemberNotificationSendBatch(String notificationId, String recipientId){
        this.notificationId= notificationId;   
        this.recipientId = recipientId;
        this.sendingMessage = 'Success';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        
        String query = 'select Id, Name, Email__c, GARP_ID__c, Sending_Status__c, Sent_Date_Time__c, Error_Message__c, Sent_Message__c, Sent_SMS__c, Contact__c, Send_Email__c, Number_of_Sends__c, Member_Notification__r.Custom_Message__c, Member_Notification__r.Exam_New_Address__c, Member_Notification__r.Exam_Requirement__c from Member_Notification_Recipient__c where Member_Notification__c = :notificationId';    
        if(recipientId != NULL) {
            query = 'select Id, Name, Email__c, GARP_ID__c, Sending_Status__c, Sent_Date_Time__c, Error_Message__c, Sent_Message__c, Sent_SMS__c, Contact__c, Send_Email__c, Number_of_Sends__c, Member_Notification__r.Custom_Message__c, Member_Notification__r.Exam_New_Address__c, Member_Notification__r.Exam_Requirement__c from Member_Notification_Recipient__c where Member_Notification__c = :notificationId AND Id = :recipientId';
        }

        List<Member_Notification__c> lstNotif = [select Id, Name, Message_Types__c, Custom_Message__c, Status__c, Template__c, Sent_Date_Time__c, 
                                                 Require_Portal_Login__c, Sending_Platform__c, Subject__c 
                                                 from Member_Notification__c where id = :notificationId];
        if(!lstNotif.isEmpty()) {
            for(Member_Notification__c mn :lstNotif) {
                mn.Status__c = 'Sending'; 
                mn.Sending_Message__c = NULL;
                mn.Sent_Date_Time__c = DateTime.Now();
            }
        }
        update lstNotif;

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Member_Notification_Recipient__c> scope){
        
        list<Member_Notification__c> lstNotif = [select Id, Name, Custom_Message__c, Exam_New_Address__c, Exam_Requirement__c, Status__c, Template__c, Sent_Date_Time__c, 
                                                 Require_Portal_Login__c, Sending_Platform__c, Subject__c, From_Address__c, Message_Types__c 
                                                 from Member_Notification__c where id = :notificationId];

        Set<String> emailAddrs = new Set<String>();
        for(Member_Notification_Recipient__c mnr :scope) {
            emailAddrs.add(mnr.Email__c);
        }

        List<Contact> lstCont = [SELECT Id, Email, MailingCountry, Phone, MobilePhone, Mobile_Phone_Code__c from Contact where Email in :emailAddrs];

        MAP<String,Contact> mapContactByEmail = new MAP<String,Contact>();
        for(Contact c :lstCont) {
            mapContactByEmail.put(c.Email, c);
        }

        if(!lstNotif.isEmpty()) {
            Member_Notification__c notification = lstNotif[0];
            
            String findTemplateName = MemberNotificationClass.getTemplateName(notification.Template__c, notification.Require_Portal_Login__c);

            List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject, HtmlValue  from EmailTemplate where Name = :findTemplateName];

            if(!lstEmailTemplates.IsEmpty()) {
                
                List<API_Transaction__c> apiTrans = new List<API_Transaction__c>();
                List<Member_Notification_Recipient__c> recpts = new List<Member_Notification_Recipient__c>();
                
                for(Member_Notification_Recipient__c rec: scope) {
                    Contact fndContact = mapContactByEmail.get(rec.Email__c);

                    if(fndContact != NULL) {
                        MemberNotificationClass.retSendComm ret = MemberNotificationClass.sendCommunications(notification, rec, lstEmailTemplates[0], fndContact);
                        recpts.add(ret.memberNotificationRecipient);
                        if(!ret.apiTrans.IsEmpty()) {
                            apiTrans.addAll(ret.apiTrans);
                        }      
                    } else {
                        rec.Sending_Status__c =  'Error';
                        rec.Error_Message__c = 'Contact not found';
                        recpts.add(rec);
                    }
                }
                if(!recpts.IsEmpty()) {
                    update recpts;
                }

                if(!apiTrans.IsEmpty()) {
                    insert apiTrans;    
                }
                
            } else {
                lstNotif[0].Status__c = 'Error';
                lstNotif[0].Sending_Message__c = 'Email template not found [' + findTemplateName + ']';

                update lstNotif;
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){

        List<Member_Notification__c> lstNotif = [select Id, Name, Custom_Message__c, Status__c, Template__c, Sent_Date_Time__c, 
                                                 Require_Portal_Login__c, Sending_Platform__c, Subject__c 
                                                 from Member_Notification__c where id = :notificationId];

        if(!lstNotif.isEmpty()) {

            for(Member_Notification__c mn :lstNotif) {
                if(mn.Status__c != 'Error') {
                    mn.Status__c = 'Sent';
                    mn.Sending_Message__c = 'Sending Completed';
                    mn.Sent_Date_Time__c = DateTime.Now();
                }
            }
            update lstNotif;
        }
        MemberNotificationClass.notifyLoggedInUsers();
    }
}