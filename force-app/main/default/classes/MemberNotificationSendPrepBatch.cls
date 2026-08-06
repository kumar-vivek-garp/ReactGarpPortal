global class MemberNotificationSendPrepBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public String notificationId;  
    public String recipientId;  
    public String sendingMessage; 
    
    global MemberNotificationSendPrepBatch(String notificationId, String recipientId){
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
            lstNotif[0].Status__c = 'Preparing to Send';    
            lstNotif[0].Sending_Message__c = NULL;
        }
        update lstNotif;

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Member_Notification_Recipient__c> scope){
        
        list<Member_Notification__c> lstNotif = [select Id, Name, Custom_Message__c, Exam_New_Address__c, Exam_Requirement__c, Status__c, Template__c, Sent_Date_Time__c, 
                                                 Require_Portal_Login__c, Sending_Platform__c, Subject__c, From_Address__c, Message_Types__c 
                                                 from Member_Notification__c where id = :notificationId];

        if(!lstNotif.isEmpty()) {
            Member_Notification__c notification = lstNotif[0];
            
            for(Member_Notification_Recipient__c rec: scope) {  
                rec.Sending_Status__c = 'Pending';
                rec.Error_Message__c = '';
                
                rec.Custom_Message__c = notification.Custom_Message__c;
                rec.Notification_Exam_New_Address__c = notification.Exam_New_Address__c;
                rec.Notification_Exam_Requirement__c = notification.Exam_Requirement__c;
            }
            update scope;    
        }
        
    }
    
    global void finish(Database.BatchableContext BC){

        Database.executeBatch(new MemberNotificationSendBatch(notificationId, recipientId),20);
    }
}