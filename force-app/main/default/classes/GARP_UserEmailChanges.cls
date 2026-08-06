/**
 * Batch class to identify Contacts with recordType = 'Member' who have email mismatches with their Community Users.
 * Categorizes contacts into 7 groups:
 * 1. Contacts without Community User
 * 2. Email different but username same
 * 3. Email same but username different
 * 4. Both email and username different
 * 5. Contacts with User Login, but no Membership Contracts (has user; primary account has NO contracts of type Membership at all)
 * 6. Contacts with User Login, but no Active Membership (has user; some Membership contracts but none are active)
 * 7. Contacts with no User, but has Active Membership Contracts (no Community User; primary account has at least one Membership contract with Status Active or Activated Auto-Renew)
 * Can be scheduled to run periodically.
 * 
 * Usage:
 * Database.executeBatch(new GARP_UserEmailChanges());
 * 
 * To test with a specific contact:
 * Database.executeBatch(new GARP_UserEmailChanges('003gP00000CaW5j'));
 * 
 * To schedule:
 * String cronExp = '0 0 2 ? * *'; // Daily at 2 AM
 * System.schedule('User Email Changes Report', cronExp, new GARP_UserEmailChanges());
 */
public without sharing class GARP_UserEmailChanges implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    
    // Environment URL - change this when deploying to different environments
    private static final String ENV_BASE_URL = 'https://garp--devjuly25a.sandbox.my.salesforce.com';
    
    // Email recipient
    private static final String RECIPIENT_EMAIL = 'alberto.garcia@garp.com';
    
    // ContactId parameter for testing
    public String contactId;
    
    // Lists to store categorized contacts
    private List<ContactInfo> noUserContacts = new List<ContactInfo>();
    private List<ContactInfo> contactAndUserEmailDifferentUsernameSame = new List<ContactInfo>();
    private List<ContactInfo> contactAndUserEmailSameUsernameDifferent = new List<ContactInfo>();
    private List<ContactInfo> contactAndUserEmailAndUsernameDifferent = new List<ContactInfo>();
    private List<ContactInfo> contactsWithUserNoMembershipContracts = new List<ContactInfo>();
    private List<ContactInfo> contactsWithUserNoActiveMembershipContracts = new List<ContactInfo>();
    private List<ContactInfo> contactsWithNoUserButActiveMembership = new List<ContactInfo>();
    
    // Counter for total records checked
    private Integer totalRecordsChecked = 0;
    
    // Default constructor for scheduling
    public GARP_UserEmailChanges() {
    }
    
    // Constructor with ContactId for testing
    public GARP_UserEmailChanges(String contactIdIn) {
        System.debug('contactIdIn:' + contactIdIn);
        this.contactId = contactIdIn;
    }
    
    // Wrapper class to store contact and user information
    public class ContactInfo {
        public String contactEmail { get; set; }
        public String contactLink { get; set; }
        public String userEmail { get; set; }
        public String userName { get; set; }
    }
    
    // Schedulable execute method
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new GARP_UserEmailChanges(), 200);
    }
    
    // Batch start method
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query Contacts with recordType = 'Member' (include AccountId for membership contract check)
        String query = 'SELECT Id, Email, AccountId, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName = \'Member\'';
        if (contactId != NULL) {
            // Use bind variable for safety
            query = 'SELECT Id, Email, AccountId, RecordType.DeveloperName FROM Contact WHERE Id = :contactId';
        }
        System.debug('query:' + query);
        return Database.getQueryLocator(query);
    }
    
    // Batch execute method
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Contact> contacts = (List<Contact>) scope;
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        
        // Collect contact IDs
        for (Contact c : contacts) {
            contactIds.add(c.Id);
            contactMap.put(c.Id, c);
        }
        
        // Query Users for these contacts
        Map<Id, User> contactToUserMap = new Map<Id, User>();
        for (User u : [SELECT Id, ContactId, Email, Username FROM User WHERE ContactId IN :contactIds AND IsActive = true]) {
            contactToUserMap.put(u.ContactId, u);
        }
        
        // Collect account IDs for contacts that have a user (for membership contract check)
        Set<Id> accountIdsWithUser = new Set<Id>();
        // Collect account IDs for contacts that have NO user (for "no user but active membership" check)
        Set<Id> accountIdsNoUser = new Set<Id>();
        for (Contact c : contacts) {
            if (contactToUserMap.get(c.Id) != null && c.AccountId != null) {
                accountIdsWithUser.add(c.AccountId);
            } else if (c.AccountId != null) {
                accountIdsNoUser.add(c.AccountId);
            }
        }
        // Accounts that have at least one Membership contract (any status)
        Set<Id> accountIdsWithAnyMembershipContract = new Set<Id>();
        // Accounts that have at least one Membership contract with Status 'Active' or 'Activated ( Auto-Renew )'
        Set<Id> accountIdsWithActiveMembershipContract = new Set<Id>();
        if (!accountIdsWithUser.isEmpty()) {
            for (Contract con : [SELECT AccountId, Status FROM Contract WHERE AccountId IN :accountIdsWithUser AND RecordType.DeveloperName = 'Membership']) {
                accountIdsWithAnyMembershipContract.add(con.AccountId);
                if (con.Status == 'Active' || con.Status == 'Activated ( Auto-Renew )') {
                    accountIdsWithActiveMembershipContract.add(con.AccountId);
                }
            }
        }
        // Accounts (for contacts with no user) that have at least one Membership contract with Status 'Active' or 'Activated ( Auto-Renew )'
        Set<Id> accountIdsNoUserWithActiveMembership = new Set<Id>();
        if (!accountIdsNoUser.isEmpty()) {
            for (Contract con : [SELECT AccountId FROM Contract WHERE AccountId IN :accountIdsNoUser AND RecordType.DeveloperName = 'Membership' AND (Status = 'Active' OR Status = 'Activated ( Auto-Renew )')]) {
                accountIdsNoUserWithActiveMembership.add(con.AccountId);
            }
        }
        
        // Categorize contacts
        for (Contact c : contacts) {
            totalRecordsChecked++;
            User relatedUser = contactToUserMap.get(c.Id);
            ContactInfo info = new ContactInfo();
            info.contactEmail = c.Email != null ? c.Email : '';
            info.contactLink = ENV_BASE_URL + '/' + c.Id;
            
            if (relatedUser == null) {
                // Group 1: No Community User
                info.userEmail = '';
                info.userName = '';
                noUserContacts.add(info);
                // Group 7: No User but primary account has Active Membership Contracts
                if (c.AccountId != null && accountIdsNoUserWithActiveMembership.contains(c.AccountId)) {
                    contactsWithNoUserButActiveMembership.add(info);
                }
            } else {
                String contactEmail = (c.Email != null ? c.Email.toLowerCase() : '');
                String userEmail = (relatedUser.Email != null ? relatedUser.Email.toLowerCase() : '');
                String userName = (relatedUser.Username != null ? relatedUser.Username.toLowerCase() : '');
                
                // Extract username without domain for comparison
                String userNameWithoutDomain = userName.contains('@') ? userName.substring(0, userName.indexOf('@')) : userName;
                String contactEmailWithoutDomain = contactEmail.contains('@') ? contactEmail.substring(0, contactEmail.indexOf('@')) : contactEmail;
                
                info.userEmail = relatedUser.Email != null ? relatedUser.Email : '';
                info.userName = relatedUser.Username != null ? relatedUser.Username : '';
                
                if (contactEmail != userEmail && userNameWithoutDomain == contactEmailWithoutDomain) {
                    // Group 2: Email different but username same (base part)
                    contactAndUserEmailDifferentUsernameSame.add(info);
                } else if (contactEmail == userEmail && userName != contactEmail) {
                    // Group 3: Email same but username different
                    contactAndUserEmailSameUsernameDifferent.add(info);
                } else if (contactEmail != userEmail && userNameWithoutDomain != contactEmailWithoutDomain) {
                    // Group 4: Both email and username different
                    contactAndUserEmailAndUsernameDifferent.add(info);
                }
                // Group 5: Has user login but primary account has NO contracts of type Membership at all
                if (c.AccountId == null || !accountIdsWithAnyMembershipContract.contains(c.AccountId)) {
                    contactsWithUserNoMembershipContracts.add(info);
                }
                // Group 6: Has user login; some Membership contracts but none are active (Status 'Active' or 'Activated ( Auto-Renew )')
                if (c.AccountId != null && accountIdsWithAnyMembershipContract.contains(c.AccountId) && !accountIdsWithActiveMembershipContract.contains(c.AccountId)) {
                    contactsWithUserNoActiveMembershipContracts.add(info);
                }
            }
        }
    }
    
    // Batch finish method - send email with results
    public void finish(Database.BatchableContext BC) {
        sendEmailReport();
    }
    
    // Method to send email with report tables
    private void sendEmailReport() {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { RECIPIENT_EMAIL });
        email.setSubject('User Email Changes Report - ' + Date.today().format());
        
        String htmlBody = buildEmailBody();
        email.setHtmlBody(htmlBody);
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
        }
    }
    
    // Method to build HTML email body with report tables
    private String buildEmailBody() {
        String html = '<html><body style="font-family: Arial, sans-serif;">';
        html += '<h2>User Email Changes Report</h2>';
        html += '<p>Report generated on: ' + DateTime.now().format() + '</p>';
        html += '<p><strong>Total Records Checked: ' + totalRecordsChecked + '</strong></p>';
        
        // Table 1: Contacts without Community User
        html += '<h3>Group 1: Contacts without Community User (' + noUserContacts.size() + ')</h3>';
        html += buildTable(noUserContacts);
        
        // Table 2: Email different but username same
        html += '<h3>Group 2: Email Different but Username Same (' + contactAndUserEmailDifferentUsernameSame.size() + ')</h3>';
        html += buildTable(contactAndUserEmailDifferentUsernameSame);
        
        // Table 3: Email same but username different
        html += '<h3>Group 3: Contact and User Email Same but Username Different (' + contactAndUserEmailSameUsernameDifferent.size() + ')</h3>';
        html += buildTable(contactAndUserEmailSameUsernameDifferent);
        
        // Table 4: Both email and username different
        html += '<h3>Group 4: Contact and User Email and Username Different (' + contactAndUserEmailAndUsernameDifferent.size() + ')</h3>';
        html += buildTable(contactAndUserEmailAndUsernameDifferent);
        
        // Table 5: Contacts with User Login, but no Membership Contracts
        html += '<h3>Group 5: Contacts with User Login, but no Membership Contracts (' + contactsWithUserNoMembershipContracts.size() + ')</h3>';
        html += buildTable(contactsWithUserNoMembershipContracts);
        
        // Table 6: Contacts with User Login, but no Active Membership (has Membership contracts, none Active/Activated Auto-Renew)
        html += '<h3>Group 6: Contacts with User Login, but no Active Membership (' + contactsWithUserNoActiveMembershipContracts.size() + ')</h3>';
        html += buildTable(contactsWithUserNoActiveMembershipContracts);
        
        // Table 7: Contacts with no User, but has Active Membership Contracts
        html += '<h3>Group 7: Contacts with no User, but has Active Membership Contracts (' + contactsWithNoUserButActiveMembership.size() + ')</h3>';
        html += buildTable(contactsWithNoUserButActiveMembership);
        
        html += '</body></html>';
        return html;
    }
    
    // Method to build HTML table
    private String buildTable(List<ContactInfo> contacts) {
        if (contacts.isEmpty()) {
            return '<p>No records found.</p>';
        }
        
        String table = '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; width: 100%;">';
        table += '<thead><tr style="background-color: #f0f0f0;">';
        table += '<th>Contact Email</th>';
        table += '<th>Contact Link</th>';
        table += '<th>User Email</th>';
        table += '<th>User Name</th>';
        table += '</tr></thead><tbody>';
        
        for (ContactInfo info : contacts) {
            table += '<tr>';
            table += '<td>' + escapeHtml(info.contactEmail) + '</td>';
            table += '<td><a href="' + escapeHtml(info.contactLink) + '">View Contact</a></td>';
            table += '<td>' + escapeHtml(info.userEmail) + '</td>';
            table += '<td>' + escapeHtml(info.userName) + '</td>';
            table += '</tr>';
        }
        
        table += '</tbody></table><br/>';
        return table;
    }
    
    // Helper method to escape HTML
    private String escapeHtml(String input) {
        if (input == null) {
            return '';
        }
        return input.escapeHtml4();
    }
}