public class GARP_MS_Events {

    // Registration Methods
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getEventRegistrationInfo(String eventId, String regCode) {
        return GARP_BC_Events.getEventRegistrationInfo(eventId, regCode);
    }
    
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getChapterMeetingRegistrationInfo(String eventId) {
        return GARP_BC_Events.getChapterMeetingRegistrationInfo(eventId);
    }
    
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getWebcastRegistrationInfo(String eventId) {
        return GARP_BC_Events.getWebcastRegistrationInfo(eventId);
    }

    @RemoteAction
    public static Event_Registration__c setRSVPInviteOnlyDecline(String eventId, String userEmail) {
        return GARP_BC_Events.setRSVPInviteOnlyDecline(eventId, userEmail);
    }
    
    // Portal V1 Methods
    /*
    @RemoteAction
    public static List<GARP_BC_Events.eventInfo> getMemberEventRegistrations(Boolean isUpcoming){
        Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_Events.getMemberEventRegistrations(users[0].ContactId, isUpcoming);
        }
        return null;  
    }
    
    @RemoteAction
    public static List<GARP_BC_Events.eventInfo> getEventListing(Boolean isUpcoming){
        Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_Events.getEventListing(isUpcoming);
        }
        return null;  
    }
 	*/   
    public GARP_MS_Events(sfdcAppRemoter ctrl){}
}