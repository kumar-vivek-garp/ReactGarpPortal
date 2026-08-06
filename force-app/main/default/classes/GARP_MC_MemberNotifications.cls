public without sharing class GARP_MC_MemberNotifications {

    // GARP Member Controller - Member Notifications - Exam Alerts componenet
    // AG 3/30/2022 - Created
    
    @AuraEnabled(cacheable = false)
    public static List<Member_Notification_Recipient__c> getExamAlerts(){
        return GARP_MS_MemberNotifications.getExamAlerts();
    }
    
    @AuraEnabled(cacheable = false)
    public static Boolean setMemberNotificationAsViewed(string recNotId){
        return GARP_MS_MemberNotifications.setMemberNotificationAsViewed(recNotId);
    }
    
}