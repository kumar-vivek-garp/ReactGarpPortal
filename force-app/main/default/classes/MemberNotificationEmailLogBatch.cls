global class MemberNotificationEmailLogBatch implements Database.Batchable<sObject> {

    public String notificationId;
    
    global MemberNotificationEmailLogBatch(String notificationIdIn){
        notificationId = notificationIdIn;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        
        List<Member_Notification_Recipient__c> lstRec = [select Id, Name, Email__c
                                                         from Member_Notification_Recipient__c where Member_Notification__c = :notificationId];

        Set<String> email_addresses = new Set<String>();

        if(!lstRec.isEmpty()) {
            for(Member_Notification_Recipient__c mnr :lstRec) {
                email_addresses.add(mnr.Email__c);
            }
        }

        String query = 'select id, Email_Address__c, Log_Action__c, Log_Date_Time__c, Message__c, Retry_Count__c, Sender__c from Member_Notification_Email_Log_Entry__c where Email_Address__c in :email_addresses order by Log_Date_Time__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Member_Notification_Email_Log_Entry__c> scope){
        MemberNotificationClass.updateSendingStatus(notificationId, scope);
    }
    
    global void finish(Database.BatchableContext BC){
    }

}