global class MemberNotificationRemoveAudienceBatch implements Database.Batchable<sObject>{

    public String notificationId;    
    
    global MemberNotificationRemoveAudienceBatch(String inNotificationId) {
        notificationId = inNotificationId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        String query = 'SELECT Id from Member_Notification_Recipient__c where Member_Notification__c = :notificationId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Member_Notification_Recipient__c> scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}