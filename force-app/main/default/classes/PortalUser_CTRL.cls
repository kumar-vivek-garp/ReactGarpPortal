public with sharing class PortalUser_CTRL {
 
    public static String m_portalId = ''; // needed to log in as
    public static String m_profileId = ''; // needed to create portal user

    @AuraEnabled
    public static PortalUserData getPortalUserData(Id recordId) {

        system.debug('\n\n\n\ngetPortalUserData from recordId: ' + recordId + '\n\n\n\n');

        PortalUserData newData = new PortalUserData();

        // set the data to return to the lightning component
        newData.contactId = recordId;
        newData.portalId = m_portalId;

        // now get the user id according to the contact id
        User user = getUserByContactId(newData.contactId);
        if (user == null) {
            newData.hasPortalUser = false;
        }
        else {
            newData.hasPortalUser = true;
            newData.userId = user.Id;
        }
        // get the ogId - needed for the login url
        newData.orgId = UserInfo.getOrganizationId();

        system.debug('\n\n\n\ngetPortalUserData before getting user: recordId: ' + recordId + ', portalId: ' + newData.portalId + ', orgId: ' + newData.orgId + ', contactId: ' + newData.contactId + '\n\n\n\n');

        return newData;
    }

  

    // Return user by contactId and isActive
    @TestVisible private static User getUserByContactId(String contactId) {

        List<User> users = [
                SELECT Id
                FROM User
                WHERE ContactId = :contactId
                AND isActive = true
        ];

        if(users == null || users.isEmpty()) {
            return null;
        }
        else {
            return users[0];
        }
    }


    // return user enabled contacts
     @TestVisible private static Contact getContact(Id contactId) {
        List<Contact> contacts = [
                      SELECT Id,
                              Name,
                              FirstName,
                              LastName,
                              Email
                      FROM Contact
                      WHERE Id = :contactId ];
        if (contacts.isEmpty())
            return null;
        else
            return contacts[0];
    }


    // sub-class for representing all the data to return to the client controller
    public class PortalUserData {

        @AuraEnabled public String orgId;
        @AuraEnabled public string portalId;
        @AuraEnabled public string userId;
        @AuraEnabled public string contactId;
        @AuraEnabled public Boolean hasPortalUser;
        @AuraEnabled public Boolean hasError = false;
        @AuraEnabled public String errorMessage;

        public PortalUserData(){}

    }
}