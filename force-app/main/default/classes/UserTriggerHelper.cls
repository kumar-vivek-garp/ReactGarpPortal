/* Apex Class for handling UserTrigger
 * Covered by UserTriggerTest Class
 * 01/03/2019 Xiang - Created for [US-16772]. Locale field is not visible in Validation Rule.
 */
public without sharing class UserTriggerHelper {
    
    private static String localeErrMsg = Label.SiteUserLocaleMsg;
    
    public static void checkUserLocaleChange(List<User> newUsers, Map<Id, User> oldUsers) {
        for(User oneNew : newUsers) {
            // If active site member user
            if(oneNew.IsActive && oneNew.ContactId != null) {
                User oneOld = oldUsers.get(oneNew.Id);
                
                // If locale changed to non-US
                if(oneNew.LocaleSidKey != oneOld.LocaleSidKey && oneNew.LocaleSidKey != 'en_US') {
                    oneNew.addError(localeErrMsg);
                }
            }
        }
    }
    
    
    /**
     * @description updates the user's email in Mobius for non-bulkified User changes
     * @param newUserMap new values map of modified users
     * @param oldUserMap old values map of modified users
     */ 
    public static void updateUserEmail(Map<Id, User> newUserMap, Map<Id, User> oldUserMap){
        
        // Prevents the bulk update of Mobius emails as the outbound call cannot be bulkified
        if(newUserMap.keySet().size() == 1){
            for(Id id: newUserMap.keySet()){
                
                User newUser = newUserMap.get(id);
                User oldUser = oldUserMap.get(id);
                                
                if(newUser.Username != oldUser.Username && newUser.ContactId != null && newUser.AccountId != null){
                    
                    //Fetch all eBooks
                    List<OpportunityLineItem> opportunityLineItems = [
                        SELECT Product2.Product_ID__c, Opportunity.CloseDate
                        FROM OpportunityLineItem
                        WHERE 
                        Opportunity.AccountId = :newUser.AccountId AND 
                        Opportunity.StageName = 'Closed' AND 
                        Product2.Electronic_Delivery__c = TRUE
                    ];
                    
                    Contact contact = [SELECT Id, GARP_Member_ID__c FROM Contact WHERE Id = :newUser.ContactId];
                    
                    if(!opportunityLineItems.isEmpty()){
                        Integer garpMemberId = Integer.valueOf(contact.GARP_Member_ID__c);
                        mobiusAPI.updateUserEmailAsync(mobiusAPI.apiVersionGlobal, garpMemberId, newUser.ContactId, newUser.Username); 
                    }
                    
                    // AG 9/26/2025 - Update HubSpot
                    HubSpotClass.updateContactEmailAsync(newUser.ContactId, newUser.Username);
                               
                }
            }
        }
    }
    
}