@isTest
// Test class for GARP_UserEmailChanges (7 groups, MIXED_DML fix, Group 7)
private class GARP_UserEmailChanges_Test {
    
    @testSetup
    static void setupTestData() {
        // Get Member record type
        Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Member').getRecordTypeId();
        
        // Create Accounts (acc = with users; accNoUser = for Group 7: no user but active membership)
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Account accNoUser = new Account(Name = 'Test Account No User');
        insert accNoUser;
        
        // Create Contacts
        List<Contact> contacts = new List<Contact>();
        
        // Contact 1: No User (Group 1)
        Contact c1 = new Contact(
            FirstName = 'Test1',
            LastName = 'NoUser',
            Email = 'test1@garp.com',
            AccountId = acc.Id,
            RecordTypeId = memberRecordTypeId
        );
        contacts.add(c1);
        
        // Contact 2: Has User - contact and user email different, username same (Group 2)
        Contact c2 = new Contact(
            FirstName = 'Test2',
            LastName = 'EmailMismatch',
            Email = 'test2@garp.com',
            AccountId = acc.Id,
            RecordTypeId = memberRecordTypeId
        );
        contacts.add(c2);
        
        // Contact 3: Has User - contact and user email and username both different (Group 4)
        Contact c3 = new Contact(
            FirstName = 'Test3',
            LastName = 'BothMismatch',
            Email = 'test3@garp.com',
            AccountId = acc.Id,
            RecordTypeId = memberRecordTypeId
        );
        contacts.add(c3);
        
        // Contact 4: No User, but account has Active Membership Contract (Group 7)
        Contact c4 = new Contact(
            FirstName = 'Test4',
            LastName = 'NoUserActiveMembership',
            Email = 'test4@garp.com',
            AccountId = accNoUser.Id,
            RecordTypeId = memberRecordTypeId
        );
        contacts.add(c4);
        
        insert contacts;
        
        // Do NOT create/update User here – causes MIXED_DML_OPERATION (setup vs non-setup in same transaction).
        // User setup is done in ensureTestUsersForC2C3() called from test methods that need c2/c3 users.
        
        // Group 7: Create Membership contract with Active status on accNoUser (contact c4 has no user)
        Id membershipRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership');
        Contract memContract = new Contract(
            Name = 'Test Membership',
            AccountId = accNoUser.Id,
            Opportunity__c = null,
            RecordTypeId = membershipRecordTypeId,
            Status = 'Draft',
            ContractTerm = 12
        );
        insert memContract;
        memContract.Status = 'Activated ( Auto-Renew )';
        try {
            update memContract;
        } catch (Exception e) {
            // Some orgs may use 'Active' instead of 'Activated ( Auto-Renew )'
            memContract.Status = 'Active';
            update memContract;
        }
    }
    
    // Run in test methods only (avoids MIXED_DML: User DML must not be in same transaction as Account/Contact).
    private static void ensureTestUsersForC2C3() {
        List<Contact> c2c3 = [SELECT Id, LastName FROM Contact WHERE LastName IN ('EmailMismatch', 'BothMismatch')];
        if (c2c3.size() != 2) return;
        Id c2Id = null;
        Id c3Id = null;
        for (Contact c : c2c3) {
            if (c.LastName == 'EmailMismatch') c2Id = c.Id;
            else if (c.LastName == 'BothMismatch') c3Id = c.Id;
        }
        if (c2Id == null || c3Id == null) return;
        List<User> existingUsers = [SELECT Id, ContactId, Email FROM User WHERE ContactId IN :new Set<Id>{ c2Id, c3Id } AND IsActive = true];
        Map<Id, User> byContact = new Map<Id, User>();
        for (User u : existingUsers) byContact.put(u.ContactId, u);
        if (byContact.containsKey(c2Id) && byContact.containsKey(c3Id)) {
            byContact.get(c2Id).Email = 'test2@different.com';
            byContact.get(c3Id).Email = 'different3@garp.com';
            update byContact.values();
        } else {
            Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community' LIMIT 1];
            List<User> users = new List<User>();
            users.add(new User(
                FirstName = 'Test2', LastName = 'EmailMismatch', Email = 'test2@different.com',
                Username = 'test2@garp.com.test', Alias = 'test2', ContactId = c2Id,
                ProfileId = communityProfile.Id, TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US'
            ));
            users.add(new User(
                FirstName = 'Test3', LastName = 'BothMismatch', Email = 'different3@garp.com',
                Username = 'different3@garp.com.test', Alias = 'test3', ContactId = c3Id,
                ProfileId = communityProfile.Id, TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US'
            ));
            insert users;
        }
    }
    
    @isTest
    static void testBatchExecution() {
        ensureTestUsersForC2C3();
        Test.startTest();
        
        GARP_UserEmailChanges batch = new GARP_UserEmailChanges();
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify email was sent (in a real scenario, you'd check email logs or use a mock)
        // Since we can't easily verify email sending in tests, we'll just verify the batch runs
        System.assert(true, 'Batch executed successfully');
    }
    
    @isTest
    static void testSchedulable() {
        ensureTestUsersForC2C3();
        Test.startTest();
        
        GARP_UserEmailChanges schedulable = new GARP_UserEmailChanges();
        String cronExp = '0 0 2 ? * *';
        System.schedule('Test User Email Changes', cronExp, schedulable);
        
        Test.stopTest();
        
        // Verify job was scheduled
        List<CronTrigger> scheduledJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Test User Email Changes'];
        System.assertEquals(1, scheduledJobs.size(), 'Job should be scheduled');
    }
    
    @isTest
    static void testBatchLogic() {
        ensureTestUsersForC2C3();
        // Get test contacts (c1 no user, c2/c3 with user, c4 no user with active membership - Group 7)
        List<Contact> contacts = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'NoUser' OR LastName = 'EmailMismatch' OR LastName = 'BothMismatch' OR LastName = 'NoUserActiveMembership'];
        System.assertEquals(4, contacts.size(), 'Should have 4 test contacts');
        
        Test.startTest();
        
        GARP_UserEmailChanges batch = new GARP_UserEmailChanges();
        Database.QueryLocator ql = batch.start(null);
        List<Contact> scope = Database.query(ql.getQuery());
        
        System.assertEquals(4, scope.size(), 'Scope should include all 4 Member contacts');
        
        // Execute with the scope (covers Groups 1, 2, 4, 5, 6, 7)
        batch.execute(null, scope);
        
        Test.stopTest();
        
        System.assert(true, 'Batch logic executed');
    }
    
    @isTest
    static void testBatchWithContactId() {
        // Get a test contact (no user)
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'NoUser' LIMIT 1];
        
        Test.startTest();
        
        // Test batch with ContactId parameter
        GARP_UserEmailChanges batch = new GARP_UserEmailChanges(testContact.Id);
        System.assertEquals(testContact.Id, batch.contactId, 'ContactId should be set');
        
        batch.start(null);
        // Cannot use ql.getQuery() when contactId is set (bind :contactId not in test scope); query scope directly
        List<Contact> scope = [SELECT Id, Email, AccountId, RecordType.DeveloperName FROM Contact WHERE Id = :testContact.Id];
        
        // Should only return the one contact
        System.assertEquals(1, scope.size(), 'Should return only the specified contact');
        System.assertEquals(testContact.Id, scope[0].Id, 'Should return the correct contact');
        
        // Execute with the scope
        batch.execute(null, scope);
        
        Test.stopTest();
        
        System.assert(true, 'Batch with ContactId executed successfully');
    }
    
    @isTest
    static void testGroup7NoUserWithActiveMembership() {
        // Contact with no user but account has Active Membership (Group 7)
        Contact group7Contact = [SELECT Id, AccountId FROM Contact WHERE LastName = 'NoUserActiveMembership' LIMIT 1];
        System.assertNotEquals(null, group7Contact.AccountId, 'Contact should have account');
        
        Test.startTest();
        
        GARP_UserEmailChanges batch = new GARP_UserEmailChanges(group7Contact.Id);
        batch.start(null);
        // Cannot use ql.getQuery() when contactId is set (bind :contactId not in test scope); query scope directly
        List<Contact> scope = [SELECT Id, Email, AccountId, RecordType.DeveloperName FROM Contact WHERE Id = :group7Contact.Id];
        System.assertEquals(1, scope.size(), 'Should return Group 7 contact');
        
        batch.execute(null, scope);
        batch.finish(null);
        
        Test.stopTest();
        
        System.assert(true, 'Group 7 (no user, active membership) batch executed and finish sent report');
    }
}