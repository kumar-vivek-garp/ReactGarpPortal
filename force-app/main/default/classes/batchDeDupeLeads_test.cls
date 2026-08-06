@isTest
private class batchDeDupeLeads_test {

    /** Unique per call so org duplicate rules / existing data do not block inserts. */
    private static String testEmail(String prefix) {
        return prefix
            + String.valueOf(Math.abs(Crypto.getRandomInteger()))
            + '.'
            + String.valueOf(Math.abs(Crypto.getRandomInteger()))
            + '@bddltest.example.com';
    }

    /**
     * Inserts each Lead with a unique Email, then updates all to {@code sharedEmail} with duplicate-rule bypass.
     * Some orgs dedupe same-email Lead inserts even with allowSave on insert; update avoids that path.
     */
    private static void insertThenUnifyEmail(List<Lead> leads, String sharedEmail) {
        if (leads == null || leads.isEmpty()) {
            return;
        }
        Integer i = 0;
        for (Lead l : leads) {
            l.Email = sharedEmail + '.t' + String.valueOf(i++);
        }
        insert leads;
        for (Lead l : leads) {
            l.Email = sharedEmail;
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.update(leads, dml);
    }

    @isTest
    static void leadOnlyDuplicates_mergeIntoOldest() {
        String email = testEmail('leadonly');
        List<Lead> pair = new List<Lead>{
            new Lead(Company = 'Co', LastName = 'Old'),
            new Lead(Company = 'Co', LastName = 'New')
        };
        insertThenUnifyEmail(pair, email);

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('all', true), 200);
        Test.stopTest();

        List<Lead> remaining = [SELECT Id, Email FROM Lead WHERE Email = :email AND IsConverted = FALSE];
        System.assertEquals(1, remaining.size(), 'Duplicate leads should merge to one');
    }

    @isTest
    static void leadWithContact_convertsAndReparentsFormData() {
        String email = testEmail('tocon');
        Account acct = new Account(Name = 'batchDeDupeLeads Acct');
        insert acct;
        Contact c = new Contact(AccountId = acct.Id, FirstName = 'Keep', LastName = 'Contact', Email = email);
        insert c;
        c = [SELECT Id, AccountId FROM Contact WHERE Id = :c.Id];

        Lead dup = new Lead(Company = 'LCo', LastName = 'DupLead', Email = email);
        insert dup;

        Form_Data__c fd = new Form_Data__c(Email__c = email, Lead__c = dup.Id);
        insert fd;

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('all', true), 200);
        Test.stopTest();

        List<Lead> openLeads = [SELECT Id FROM Lead WHERE Email = :email AND IsConverted = FALSE];
        System.assertEquals(0, openLeads.size(), 'Lead should be converted');

        Form_Data__c fdAfter = [SELECT Id, Contact__c, Lead__c FROM Form_Data__c WHERE Id = :fd.Id];
        System.assertEquals(c.Id, fdAfter.Contact__c, 'Form_Data should point to contact');
        System.assertEquals(null, fdAfter.Lead__c, 'Lead__c should be cleared so Form_Data is not lost on merge/convert');
    }

    @isTest
    static void dryRun_doesNotCommit() {
        String email = testEmail('drymrg');
        insertThenUnifyEmail(
            new List<Lead>{
                new Lead(Company = 'A', LastName = 'L1'),
                new Lead(Company = 'A', LastName = 'L2')
            },
            email
        );

        Integer openBefore = [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE];
        System.assertEquals(2, openBefore);

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('all', false), 200);
        Test.stopTest();

        System.assertEquals(
            openBefore,
            [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE],
            'Dry run should not merge or convert'
        );
    }

    @isTest
    static void schedule_smoke() {
        String jobName = 'bddl_sched_' + String.valueOf(Math.abs(Crypto.getRandomInteger()));
        Test.startTest();
        System.schedule(jobName, '0 0 0 * * ?', new scheduleBatchDeDupeLeads());
        Test.stopTest();
    }

    /** start(): Batch_Dedupe__c scope; execute(): blank Email → scopeEmails empty → early return */
    @isTest
    static void batchMode_leadWithoutEmail_scopeEmailsEmpty() {
        Lead noEmail = new Lead(Company = 'Co', LastName = 'NoEmail', Batch_Dedupe__c = true);
        insert noEmail;

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('batch', true), 200);
        Test.stopTest();

        Lead after = [SELECT Id, Batch_Dedupe__c FROM Lead WHERE Id = :noEmail.Id];
        System.assertEquals(true, after.Batch_Dedupe__c, 'Lead should remain unchanged');
    }

    /** start(): mode == 'batch' with Email; merge duplicate flagged leads */
    @isTest
    static void batchMode_twoFlaggedLeads_mergeLeadOnly() {
        String email = testEmail('batchflg');
        insertThenUnifyEmail(
            new List<Lead>{
                new Lead(Company = 'Co', LastName = 'A', Batch_Dedupe__c = true),
                new Lead(Company = 'Co', LastName = 'B', Batch_Dedupe__c = true)
            },
            email
        );
        System.assertEquals(2, [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE]);

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('batch', true), 200);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE]);
    }

    /** start(): mode == null → CreatedDate >= YESTERDAY */
    @isTest
    static void nullMode_yesterdayWindow_leadOnlyMerge() {
        String email = testEmail('nullmod');
        insertThenUnifyEmail(
            new List<Lead>{
                new Lead(Company = 'Co', LastName = 'A'),
                new Lead(Company = 'Co', LastName = 'B')
            },
            email
        );
        System.assertEquals(2, [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE]);

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads(null, true), 200);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE]);
    }

    /** start(): non-null mode other than batch/all → single-email SOQL (trim + escape) */
    @isTest
    static void emailLiteralMode_trimsAndMerges() {
        String email = testEmail('literal');
        insertThenUnifyEmail(
            new List<Lead>{
                new Lead(Company = 'Co', LastName = 'A'),
                new Lead(Company = 'Co', LastName = 'B')
            },
            email
        );
        System.assertEquals(2, [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE]);

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('  ' + email + '  ', true), 200);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE]);
    }

    /** Three leads + contact + multiple Form_Data__c: merge + convert + sweeps */
    @isTest
    static void threeLeadsOneContact_threeFormData_mergeAndConvert() {
        String email = testEmail('threefd');
        Account acct = new Account(Name = 'batchDeDupeLeads Acct3');
        insert acct;
        Contact c = new Contact(AccountId = acct.Id, FirstName = 'C', LastName = 'Three', Email = email);
        insert c;

        insertThenUnifyEmail(
            new List<Lead>{
                new Lead(Company = 'Co', LastName = 'L1'),
                new Lead(Company = 'Co', LastName = 'L2'),
                new Lead(Company = 'Co', LastName = 'L3')
            },
            email
        );
        List<Lead> rows = [SELECT Id FROM Lead WHERE Email = :email ORDER BY LastName ASC];
        System.assertEquals(3, rows.size());

        List<Form_Data__c> fds = new List<Form_Data__c>{
            new Form_Data__c(Email__c = email, Lead__c = rows[0].Id),
            new Form_Data__c(Email__c = email, Lead__c = rows[1].Id),
            new Form_Data__c(Email__c = email, Lead__c = rows[2].Id)
        };
        insert fds;

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('all', true), 200);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE]);
        for (Form_Data__c fd : [SELECT Contact__c, Lead__c FROM Form_Data__c WHERE Id IN :new Map<Id, Form_Data__c>(fds).keySet()]) {
            System.assertEquals(c.Id, fd.Contact__c);
            System.assertEquals(null, fd.Lead__c);
        }
    }

    /** Dry run: LEAD_TO_LEAD (DRY RUN) + LEAD_TO_CONTACT (DRY RUN) detail paths */
    @isTest
    static void dryRun_threeLeadsWithContact() {
        String email = testEmail('dry3lc');
        Account acct = new Account(Name = 'batchDeDupeLeads Dry3');
        insert acct;
        insert new Contact(AccountId = acct.Id, FirstName = 'D', LastName = 'R', Email = email);

        insertThenUnifyEmail(
            new List<Lead>{
                new Lead(Company = 'Co', LastName = 'D1'),
                new Lead(Company = 'Co', LastName = 'D2'),
                new Lead(Company = 'Co', LastName = 'D3')
            },
            email
        );

        Integer openBefore = [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE];
        System.assertEquals(3, openBefore);

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('all', false), 200);
        Test.stopTest();

        System.assertEquals(
            openBefore,
            [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE],
            'Dry run must not remove or convert leads'
        );
    }

    /** Single lead + contact: no merge branch; convert (or dry convert) only */
    @isTest
    static void dryRun_singleLeadWithContact_noDupMerge() {
        String email = testEmail('dry1lc');
        Account acct = new Account(Name = 'batchDeDupeLeads Dry1');
        insert acct;
        insert new Contact(AccountId = acct.Id, FirstName = 'S', LastName = 'olo', Email = email);
        insert new Lead(Company = 'Co', LastName = 'Only', Email = email);

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('all', false), 200);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE]);
    }

    /** Two unrelated emails in one batch: second convert reuses cached LeadStatus label */
    @isTest
    static void twoSingletonsWithContacts_secondConvertUsesCachedStatus() {
        String e1 = testEmail('cachea');
        String e2 = testEmail('cacheb');
        Account acct = new Account(Name = 'batchDeDupeLeads CacheAcct');
        insert acct;
        insert new List<Contact>{
            new Contact(AccountId = acct.Id, FirstName = 'A', LastName = 'One', Email = e1),
            new Contact(AccountId = acct.Id, FirstName = 'B', LastName = 'Two', Email = e2)
        };
        insert new List<Lead>{
            new Lead(Company = 'Co', LastName = 'L1', Email = e1),
            new Lead(Company = 'Co', LastName = 'L2', Email = e2)
        };

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('all', true), 200);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Lead WHERE Email IN (:e1, :e2) AND IsConverted = FALSE]);
    }

    /** Convert path with no Form_Data__c (reparent + post-convert sweeps are no-ops) */
    @isTest
    static void singleLeadWithContact_noFormData_converts() {
        String email = testEmail('nfd');
        Account acct = new Account(Name = 'batchDeDupeLeads NFD');
        insert acct;
        insert new Contact(AccountId = acct.Id, FirstName = 'N', LastName = 'FD', Email = email);
        insert new Lead(Company = 'Co', LastName = 'L', Email = email);

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('all', true), 200);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE]);
    }

    /** No duplicate work: finish() summary body “no actions” branch */
    @isTest
    static void noDupes_noContact_noActionsRecorded() {
        String email = testEmail('single');
        insert new Lead(Company = 'Co', LastName = 'Solo', Email = email);

        Test.startTest();
        Database.executeBatch(new batchDeDupeLeads('all', true), 200);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Email = :email AND IsConverted = FALSE]);
    }
}