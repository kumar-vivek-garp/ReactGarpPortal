public class SyncUserEmailFromContactQueueable implements Queueable {
    private Set<Id> contactIds;

    public SyncUserEmailFromContactQueueable(Set<Id> contactIds) {
        this.contactIds = contactIds;
    }

    public void execute(QueueableContext qc) {
        // Query Contacts (latest email)
        Map<Id, Contact> contacts = new Map<Id, Contact>([
            SELECT Id, Email
            FROM Contact
            WHERE Id IN :contactIds
        ]);

        // Query related Users
        List<User> usersToUpdate = new List<User>();
        for (User u : [
            SELECT Id, ContactId, Email, IsActive, UserType
            FROM User
            WHERE ContactId IN :contactIds
            AND IsActive = true
        ]) {
            String newEmail = contacts.get(u.ContactId).Email;
            if (newEmail != null && newEmail != u.Email) {
                u.Username = newEmail;  
                u.Email = newEmail;
                              
                usersToUpdate.add(u);
            }
        }

        if (!usersToUpdate.isEmpty()) {
            try {
                update usersToUpdate;
            } catch (Exception e) { 
               system.debug(e.getMessage());
            }
        }
    }
 
}