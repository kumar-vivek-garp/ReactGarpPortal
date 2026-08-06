@isTest
public class GBI_StudyVoteReminderBatch_test {
    
    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Study Account',
            Type = 'Customer'
        );
        insert testAccount;
        
        // Create test Study
        Study__c testStudy = new Study__c(
            Name = 'Test Study',
            Status__c = 'In Progress',
            End_Date__c = Date.today().addDays(30),
            Disable_Study_Submission_Reminder__c = false
        );
        insert testStudy;
        
        // Create test Study Account
        Study_Account__c testStudyAccount = new Study_Account__c(
            Study__c = testStudy.Id,
            Account__c = testAccount.Id
        );
        insert testStudyAccount;
        
        // Create test Study Contact with Voter role
        Study_Contact__c testStudyContact = new Study_Contact__c(
            Study__c = testStudy.Id,
            Study_Account__c = testStudyAccount.Id,
            Study_Contact_Email__c = 'test@example.com',
            Status__c = 'Active',
            Role__c = 'Voter'
        );
        insert testStudyContact;
        
        // Create test Study Vote (must be open today)
        Study_Vote__c testStudyVote = new Study_Vote__c(
            Study__c = testStudy.Id,
            Status__c = 'Opened',
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(7)
        );
        insert testStudyVote;
    }
    
    @isTest
    static void testBatchWithStudyAccountId() {
        // Get test data
        Study_Account__c testStudyAccount = [SELECT Id FROM Study_Account__c LIMIT 1];
        Study__c testStudy = [SELECT Id FROM Study__c LIMIT 1];
        Study_Contact__c testStudyContact = [SELECT Id FROM Study_Contact__c LIMIT 1];
        
        System.Debug('***testStudyAccount:' + testStudyAccount);
        System.Debug('***testStudy:' + testStudy);
        System.Debug('***testStudyContact:' + testStudyContact);
        
        Test.startTest();
        
        // Create and execute batch with study account ID
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(testStudyAccount.Id, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was updated
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c LIMIT 1];
        System.assertNotEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                              'Study Vote Reminder Sent On should be set');
        System.assertNotEquals(null, updatedContact.Vote_End_Date__c, 
                              'Vote End Date should be set');
    }
    
    @isTest
    static void testBatchWithStudyId() {
        // Get test data
        Study__c testStudy = [SELECT Id FROM Study__c LIMIT 1];
        
        Test.startTest();
        
        // Create and execute batch with study ID
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, testStudy.Id);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was updated
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c LIMIT 1];
        System.assertNotEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                              'Study Vote Reminder Sent On should be set');
        System.assertNotEquals(null, updatedContact.Vote_End_Date__c, 
                              'Vote End Date should be set');
    }
    
    @isTest
    static void testBatchWithNoFilters() {
        Test.startTest();
        
        // Create and execute batch with no filters
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was updated
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c LIMIT 1];
        System.assertNotEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                              'Study Vote Reminder Sent On should be set');
        System.assertNotEquals(null, updatedContact.Vote_End_Date__c, 
                              'Vote End Date should be set');
    }
    
    @isTest
    static void testBatchWithExistingVoteSubmission() {
        // Get test data
        Study_Contact__c testStudyContact = [SELECT Id, Study_Account__c FROM Study_Contact__c LIMIT 1];
        Study_Vote__c testStudyVote = [SELECT Id FROM Study_Vote__c LIMIT 1];
        
        // Create Study Vote Question
        Study_Vote_Question__c testVoteQuestion = new Study_Vote_Question__c(
            Study_Vote__c = testStudyVote.Id,
            Question__c = 'Test Question'
        );
        insert testVoteQuestion;
        
        // Create Study Contact Vote (existing vote submission)
        Study_Contact_Vote__c testContactVote = new Study_Contact_Vote__c(
            Study_Contact__c = testStudyContact.Id,
            Study_Vote_Question__c = testVoteQuestion.Id,
            Vote__c = 'Yes'
        );
        insert testContactVote;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because vote already submitted)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c WHERE Id = :testStudyContact.Id];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set when vote already submitted');
    }
    
    @isTest
    static void testBatchWithSuspendedContact() {
        // Get test data and update contact to suspended
        Study_Contact__c testStudyContact = [SELECT Id FROM Study_Contact__c LIMIT 1];
        testStudyContact.Status__c = 'Suspended';
        update testStudyContact;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because status is suspended)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c WHERE Id = :testStudyContact.Id];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set for suspended contacts');
    }
    
    @isTest
    static void testBatchWithNoEmailContact() {
        // Get test data and update contact to have no email
        Study_Contact__c testStudyContact = [SELECT Id FROM Study_Contact__c LIMIT 1];
        testStudyContact.Study_Contact_Email__c = null;
        update testStudyContact;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because no email)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c WHERE Id = :testStudyContact.Id];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set for contacts without email');
    }
    
    @isTest
    static void testBatchWithStudyNotInProgress() {
        // Get test data and update study status
        Study__c testStudy = [SELECT Id FROM Study__c LIMIT 1];
        testStudy.Status__c = 'Completed';
        update testStudy;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because study not in progress)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c LIMIT 1];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set for studies not in progress');
    }
    
    @isTest
    static void testBatchWithDisabledReminders() {
        // Get test data and disable reminders
        Study__c testStudy = [SELECT Id FROM Study__c LIMIT 1];
        testStudy.Disable_Study_Submission_Reminder__c = true;
        update testStudy;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because reminders disabled)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c LIMIT 1];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set when reminders are disabled');
    }
    
    @isTest
    static void testBatchWithNoOpenVotes() {
        // Get test data and close the vote
        Study_Vote__c testStudyVote = [SELECT Id FROM Study_Vote__c LIMIT 1];
        testStudyVote.Status__c = 'Closed';
        update testStudyVote;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because no open votes)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c LIMIT 1];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set when no open votes exist');
    }
    
    @isTest
    static void testBatchWithVoteEndDateInPast() {
        // Get test data and update vote to have end date in the past
        Study_Vote__c testStudyVote = [SELECT Id FROM Study_Vote__c LIMIT 1];
        testStudyVote.End_Date__c = Date.today().addDays(-1); // End date in the past
        update testStudyVote;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because vote end date is in the past)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c LIMIT 1];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set when vote end date is in the past');
    }
    
    @isTest
    static void testBatchWithVoteStartDateInFuture() {
        // Get test data and update vote to have start date in the future
        Study_Vote__c testStudyVote = [SELECT Id FROM Study_Vote__c LIMIT 1];
        testStudyVote.Start_Date__c = Date.today().addDays(1); // Start date in the future
        update testStudyVote;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because vote start date is in the future)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c LIMIT 1];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set when vote start date is in the future');
    }
    
    @isTest
    static void testBatchWithVoteSubmissionForSpecificOpenVote() {
        // Get test data
        Study_Contact__c testStudyContact = [SELECT Id, Study_Account__c FROM Study_Contact__c LIMIT 1];
        Study_Vote__c testStudyVote = [SELECT Id FROM Study_Vote__c LIMIT 1];
        
        // Create another study vote that's closed
        Study__c testStudy = [SELECT Id FROM Study__c LIMIT 1];
        Study_Vote__c closedStudyVote = new Study_Vote__c(
            Study__c = testStudy.Id,
            Status__c = 'Opened',
            Start_Date__c = Date.today().addDays(-5),
            End_Date__c = Date.today().addDays(-1) // Closed vote
        );
        insert closedStudyVote;
        
        // Create Study Vote Question for the open vote
        Study_Vote_Question__c testVoteQuestion = new Study_Vote_Question__c(
            Study_Vote__c = testStudyVote.Id, // Open vote
            Question__c = 'Test Question'
        );
        insert testVoteQuestion;
        
        // Create Study Contact Vote for the open vote (existing vote submission)
        Study_Contact_Vote__c testContactVote = new Study_Contact_Vote__c(
            Study_Contact__c = testStudyContact.Id,
            Study_Vote_Question__c = testVoteQuestion.Id,
            Vote__c = 'Yes'
        );
        insert testContactVote;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because vote already submitted for open vote)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c WHERE Id = :testStudyContact.Id];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set when vote already submitted for open vote');
    }
    
    @isTest
    static void testBatchWithNonVoterRole() {
        // Get test data and update contact to have a non-voter role
        Study_Contact__c testStudyContact = [SELECT Id FROM Study_Contact__c LIMIT 1];
        testStudyContact.Role__c = 'Admin'; // Non-voter role
        update testStudyContact;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because role is not Voter)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c WHERE Id = :testStudyContact.Id];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set for non-voter roles');
    }
    
    @isTest
    static void testBatchWithMultipleRolesIncludingVoter() {
        // Get test data and update contact to have multiple roles including Voter
        Study_Contact__c testStudyContact = [SELECT Id FROM Study_Contact__c LIMIT 1];
        testStudyContact.Role__c = 'Voter;Admin'; // Multiple roles including Voter
        update testStudyContact;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was updated (because role includes Voter)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c WHERE Id = :testStudyContact.Id];
        System.assertNotEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                              'Study Vote Reminder Sent On should be set when role includes Voter');
        System.assertNotEquals(null, updatedContact.Vote_End_Date__c, 
                              'Vote End Date should be set');
    }
    
    @isTest
    static void testBatchWithNullRole() {
        // Get test data and update contact to have null role
        Study_Contact__c testStudyContact = [SELECT Id FROM Study_Contact__c LIMIT 1];
        testStudyContact.Role__c = null; // Null role
        update testStudyContact;
        
        Test.startTest();
        
        // Create and execute batch
        GBI_StudyVoteReminderBatch batch = new GBI_StudyVoteReminderBatch(null, null);
        Id batchId = Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify batch was executed
        System.assertNotEquals(null, batchId, 'Batch should have been executed');
        
        // Verify Study Contact was NOT updated (because role is null)
        Study_Contact__c updatedContact = [SELECT Id, Study_Vote_Reminder_Sent_On__c, Vote_End_Date__c 
                                         FROM Study_Contact__c WHERE Id = :testStudyContact.Id];
        System.assertEquals(null, updatedContact.Study_Vote_Reminder_Sent_On__c, 
                           'Study Vote Reminder Sent On should NOT be set when role is null');
    }
    
    @isTest
    static void testBatchConstructor() {
        // Test constructor with both parameters
        GBI_StudyVoteReminderBatch batch1 = new GBI_StudyVoteReminderBatch('testAccountId', 'testStudyId');
        System.assertEquals('testAccountId', batch1.studyAccountId, 'Study Account ID should be set');
        System.assertEquals('testStudyId', batch1.studyId, 'Study ID should be set');
        
        // Test constructor with null parameters
        GBI_StudyVoteReminderBatch batch2 = new GBI_StudyVoteReminderBatch(null, null);
        System.assertEquals(null, batch2.studyAccountId, 'Study Account ID should be null');
        System.assertEquals(null, batch2.studyId, 'Study ID should be null');
        
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, new GBI_StudyVoteReminderBatchSchedule());
    }
}