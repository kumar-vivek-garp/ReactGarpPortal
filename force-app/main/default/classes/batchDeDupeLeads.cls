/**
 * Dedupes leads in batches (scope size 200 when scheduled with executeBatch(b, 200)).
 * For each execute chunk, loads all unconverted leads sharing emails from that chunk, then:
 * - Same email as an existing Contact: reparent Form_Data__c to the contact and clear Lead__c (so merge/convert
 *   does not drop or mishandle rows still tied to merged leads), merge duplicate leads
 *   (oldest by CreatedDate survives), convert the surviving lead to that contact (no new opportunity).
 * - No contact but multiple leads with the same email: merge duplicates into the oldest lead.
 * One summary email is sent from finish() with Lead→Contact and Lead→Lead counts and capped details.
 */
global class batchDeDupeLeads implements Database.Batchable<SObject>, Database.Stateful {

    public String mode { get; set; }
    public Boolean commitData { get; set; }

    private Integer leadToContactConverts = 0;
    private Integer leadToLeadMerges = 0;
    private Integer executeErrors = 0;
    private final List<String> detailLines = new List<String>();
    private final Set<Id> contactIdsToTouch = new Set<Id>();

    private static final Integer MAX_DETAIL_LINES = 400;
    private static final String SUMMARY_EMAIL_TO = 'alberto.garcia@garp.com';

    private String cachedConvertedStatus;

    global batchDeDupeLeads(String modeIn, Boolean commitDataIn) {
        this.mode = modeIn;
        this.commitData = commitDataIn == true;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String baseFields = 'SELECT Id, Email, Company, FirstName, LastName, CreatedDate, IsConverted ';
        String queryLocatorSoql;
        if (this.mode == 'batch') {
            queryLocatorSoql =
                baseFields + 'FROM Lead WHERE Batch_Dedupe__c = TRUE AND IsConverted = FALSE AND IsDeleted = FALSE';
        } else if (this.mode == 'all') {
            queryLocatorSoql =
                baseFields + 'FROM Lead WHERE Email != NULL AND IsConverted = FALSE AND IsDeleted = FALSE';
        } else if (this.mode != null) {
            String emailLiteral = String.escapeSingleQuotes(this.mode.trim());
            queryLocatorSoql =
                baseFields
                    + 'FROM Lead WHERE Email = \''
                    + emailLiteral
                    + '\' AND IsConverted = FALSE AND IsDeleted = FALSE';
        } else {
            queryLocatorSoql =
                baseFields
                    + 'FROM Lead WHERE Email != NULL AND IsConverted = FALSE AND IsDeleted = FALSE '
                    + 'AND CreatedDate >= YESTERDAY';
        }
        System.debug(
            LoggingLevel.INFO,
            'batchDeDupeLeads | start mode='
                + String.valueOf(this.mode)
                + ' commitData='
                + this.commitData
                + ' queryLocatorSoql='
                + queryLocatorSoql
        );
        return Database.getQueryLocator(queryLocatorSoql);
    }

    global void execute(Database.BatchableContext bc, List<Lead> scope) {
        System.debug(
            LoggingLevel.INFO,
            'batchDeDupeLeads | execute begin scopeSize=' + (scope == null ? 0 : scope.size()) + ' commitData=' + commitData
        );
        if (scope == null || scope.isEmpty()) {
            return;
        }

        Set<String> scopeEmails = new Set<String>();
        for (Lead l : scope) {
            if (String.isNotBlank(l.Email)) {
                scopeEmails.add(l.Email.trim());
            }
        }
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | scopeEmails distinctCount=' + scopeEmails.size() + ' scopeEmails=' + scopeEmails);
        if (scopeEmails.isEmpty()) {
            return;
        }

        System.debug(
            LoggingLevel.INFO,
            'batchDeDupeLeads | allLeads SOQL: SELECT Id, Email, ... FROM Lead WHERE ... Email IN :scopeEmails (bind size='
                + scopeEmails.size()
                + ')'
        );
        List<Lead> allLeads = [
            SELECT Id, Email, Company, FirstName, LastName, CreatedDate, IsConverted
            FROM Lead
            WHERE
                IsDeleted = FALSE
                AND IsConverted = FALSE
                AND Email != NULL
                AND Email IN :scopeEmails
        ];
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | allLeads rowCount=' + allLeads.size() + ' allLeads=' + allLeads);

        Map<String, List<Lead>> leadsByNormEmail = new Map<String, List<Lead>>();
        for (Lead l : allLeads) {
            String key = normalizeEmail(l.Email);
            if (!leadsByNormEmail.containsKey(key)) {
                leadsByNormEmail.put(key, new List<Lead>());
            }
            leadsByNormEmail.get(key).add(l);
        }
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | leadsByNormEmail keyCount=' + leadsByNormEmail.size() + ' leadsByNormEmail=' + leadsByNormEmail);

        System.debug(
            LoggingLevel.INFO,
            'batchDeDupeLeads | contacts SOQL: SELECT Id, Email, AccountId FROM Contact WHERE Email IN :scopeEmails (bind size='
                + scopeEmails.size()
                + ')'
        );
        List<Contact> contacts = [
            SELECT Id, Email, AccountId
            FROM Contact
            WHERE IsDeleted = FALSE AND Email != NULL AND Email IN :scopeEmails
        ];
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | contacts rowCount=' + contacts.size() + ' contacts=' + contacts);
        Map<String, Contact> contactByNormEmail = new Map<String, Contact>();
        for (Contact c : contacts) {
            String key = normalizeEmail(c.Email);
            if (!contactByNormEmail.containsKey(key)) {
                contactByNormEmail.put(key, c);
            }
        }
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | contactByNormEmail size=' + contactByNormEmail.size() + ' contactByNormEmail=' + contactByNormEmail);

        for (String normEmail : leadsByNormEmail.keySet()) {
            List<Lead> groupLeads = leadsByNormEmail.get(normEmail);
            if (groupLeads == null || groupLeads.isEmpty()) {
                continue;
            }
            Contact matchContact = contactByNormEmail.get(normEmail);
            if (matchContact != null) {
                processLeadGroupWithContact(normEmail, groupLeads, matchContact);
            } else if (groupLeads.size() > 1) {
                processLeadOnlyDuplicates(normEmail, groupLeads);
            }
        }
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | execute end batchId=' + bc.getJobId());
    }

    global void finish(Database.BatchableContext bc) {
        System.debug(
            LoggingLevel.INFO,
            'batchDeDupeLeads | finish begin leadToContactConverts='
                + leadToContactConverts
                + ' leadToLeadMerges='
                + leadToLeadMerges
                + ' executeErrors='
                + executeErrors
                + ' detailLines.size='
                + detailLines.size()
                + ' contactIdsToTouch='
                + contactIdsToTouch
        );
        touchContactsIfNeeded();

        String subject = buildFinishEmailSubject();
        String body = buildFinishEmailBody();
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | finish email subject=' + subject + ' bodyLength=' + String.valueOf(body.length()));

        if (Test.isRunningTest()) {
            return;
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ SUMMARY_EMAIL_TO });
        mail.setSaveAsActivity(false);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'batchDeDupeLeads finish email failed: ' + ex.getMessage());
        }
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | finish end');
    }

    private String buildFinishEmailSubject() {
        return 'Lead dedupe run complete — Contact merges: '
            + leadToContactConverts
            + ', Lead merges: '
            + leadToLeadMerges
            + (executeErrors > 0 ? ', Errors: ' + executeErrors : '');
    }

    private String buildFinishEmailBody() {
        String body = '';
        body += 'Lead → Contact conversions (merge + convert): ' + leadToContactConverts + '\r\n';
        body += 'Lead → Lead merges (duplicate leads, same email): ' + leadToLeadMerges + '\r\n';
        body += 'Execute errors: ' + executeErrors + '\r\n\r\n';
        body += 'Detail line legend:\r\n';
        body += '  LEAD_TO_CONTACT — fromLeadId = lead converted away; toContactId = existing contact it converted into.\r\n';
        body += '  LEAD_TO_LEAD — survivorLeadId = kept lead; mergedLeadIds = duplicate lead Id(s) merged into the survivor.\r\n';
        body += '  ERROR — includes email= plus survivorLeadId / mergedLeadIds / contactId and/or fromLeadId / toContactId as applicable.\r\n';
        body += '  Form_Data__c — rows are linked to the contact and Lead__c is cleared before merge/convert so they are not dropped when duplicate leads merge.\r\n\r\n';

        if (!detailLines.isEmpty()) {
            body += 'Detail (capped):\r\n';
            for (String line : detailLines) {
                body += line + '\r\n';
            }
        } else {
            body += 'No merge or convert actions recorded.\r\n';
        }
        return body;
    }

    private void processLeadGroupWithContact(String normEmail, List<Lead> groupLeads, Contact matchContact) {
        System.debug(
            LoggingLevel.INFO,
            'batchDeDupeLeads | processLeadGroupWithContact normEmail='
                + normEmail
                + ' groupLeads.size='
                + groupLeads.size()
                + ' groupLeads='
                + groupLeads
                + ' matchContact='
                + matchContact
        );
        List<Lead> sorted = new List<Lead>(groupLeads);
        sortLeadsByCreatedDateAsc(sorted);
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | processLeadGroupWithContact sorted=' + sorted);

        Set<Id> leadIds = new Set<Id>();
        for (Lead l : sorted) {
            leadIds.add(l.Id);
        }
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | processLeadGroupWithContact leadIds=' + leadIds);

        if (commitData) {
            reparentFormDataToContact(leadIds, matchContact.Id);
        }

        Lead master = sorted[0];
        List<Lead> dupes = new List<Lead>();
        for (Integer i = 1; i < sorted.size(); i++) {
            dupes.add(sorted[i]);
        }
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | processLeadGroupWithContact master=' + master + ' dupes=' + dupes);

        if (!dupes.isEmpty()) {
            if (commitData) {
                try {
                    System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | Database.merge (before convert) master=' + master.Id + ' dupes=' + dupes);
                    List<Database.MergeResult> mergeResults = Database.merge(leadStubForMerge(master.Id), leadStubsForMerge(dupes), false);
                    Database.MergeResult mr = mergeResults.isEmpty() ? null : mergeResults[0];
                    System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | merge results size=' + mergeResults.size() + ' first=' + mr);
                    if (mr == null || !mr.isSuccess()) {
                        recordMergeErrors(normEmail, idsMergeAndOptionalContact(master, dupes, matchContact), 'Lead merge before convert', mr);
                        return;
                    }
                    leadToLeadMerges += dupes.size();
                    addDetail(
                        'LEAD_TO_LEAD | email='
                            + normEmail
                            + ' | survivorLeadId='
                            + master.Id
                            + ' | mergedLeadIds='
                            + joinLeadIds(dupes)
                    );
                    sweepFormDataAfterLeadMerge(master.Id, matchContact.Id);
                } catch (Exception ex) {
                    recordError(normEmail, idsMergeAndOptionalContact(master, dupes, matchContact), 'Lead merge exception', ex.getMessage());
                    return;
                }
            } else {
                leadToLeadMerges += dupes.size();
                addDetail(
                    'LEAD_TO_LEAD (DRY RUN) | email='
                        + normEmail
                        + ' | survivorLeadId='
                        + master.Id
                        + ' | mergedLeadIds='
                        + joinLeadIds(dupes)
                );
            }
        }

        if (commitData) {
            try {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(master.Id);
                lc.setContactId(matchContact.Id);
                if (matchContact.AccountId != null) {
                    lc.setAccountId(matchContact.AccountId);
                }
                lc.setConvertedStatus(getConvertedStatusLabel());
                lc.setDoNotCreateOpportunity(true);
                System.debug(
                    LoggingLevel.INFO,
                    'batchDeDupeLeads | convertLead leadId='
                        + master.Id
                        + ' contactId='
                        + matchContact.Id
                        + ' accountId='
                        + matchContact.AccountId
                        + ' convertedStatus='
                        + getConvertedStatusLabel()
                );
                Database.LeadConvertResult lr = Database.convertLead(lc);
                System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | convertLead result=' + lr);
                if (!lr.isSuccess()) {
                    recordConvertErrors(normEmail, idsLeadToContact(master, matchContact), lr);
                    return;
                }
                leadToContactConverts++;
                contactIdsToTouch.add(matchContact.Id);
                sweepFormDataClearLeadAfterConvert(matchContact.Id);
                addDetail(
                    'LEAD_TO_CONTACT | email='
                        + normEmail
                        + ' | fromLeadId='
                        + master.Id
                        + ' | toContactId='
                        + matchContact.Id
                );
            } catch (Exception ex) {
                recordError(normEmail, idsLeadToContact(master, matchContact), 'convertLead exception', ex.getMessage());
            }
        } else {
            leadToContactConverts++;
            addDetail(
                'LEAD_TO_CONTACT (DRY RUN) | email='
                    + normEmail
                    + ' | fromLeadId='
                    + master.Id
                    + ' | toContactId='
                    + matchContact.Id
            );
        }
    }

    private void processLeadOnlyDuplicates(String normEmail, List<Lead> groupLeads) {
        System.debug(
            LoggingLevel.INFO,
            'batchDeDupeLeads | processLeadOnlyDuplicates normEmail=' + normEmail + ' groupLeads=' + groupLeads
        );
        List<Lead> sorted = new List<Lead>(groupLeads);
        sortLeadsByCreatedDateAsc(sorted);
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | processLeadOnlyDuplicates sorted=' + sorted);

        Lead master = sorted[0];
        List<Lead> dupes = new List<Lead>();
        for (Integer i = 1; i < sorted.size(); i++) {
            dupes.add(sorted[i]);
        }
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | processLeadOnlyDuplicates master=' + master + ' dupes=' + dupes);

        if (commitData) {
            try {
                System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | Database.merge (lead-only) master=' + master.Id + ' dupes=' + dupes);
                List<Database.MergeResult> mergeResults = Database.merge(leadStubForMerge(master.Id), leadStubsForMerge(dupes), false);
                Database.MergeResult mr = mergeResults.isEmpty() ? null : mergeResults[0];
                System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | merge results size=' + mergeResults.size() + ' first=' + mr);
                if (mr == null || !mr.isSuccess()) {
                    recordMergeErrors(normEmail, idsMergeAndOptionalContact(master, dupes, null), 'Lead-only merge', mr);
                    return;
                }
                leadToLeadMerges += dupes.size();
                addDetail(
                    'LEAD_TO_LEAD | email='
                        + normEmail
                        + ' | survivorLeadId='
                        + master.Id
                        + ' | mergedLeadIds='
                        + joinLeadIds(dupes)
                );
            } catch (Exception ex) {
                recordError(normEmail, idsMergeAndOptionalContact(master, dupes, null), 'Lead-only merge exception', ex.getMessage());
            }
        } else {
            leadToLeadMerges += dupes.size();
            addDetail(
                'LEAD_TO_LEAD (DRY RUN) | email='
                    + normEmail
                    + ' | survivorLeadId='
                    + master.Id
                    + ' | mergedLeadIds='
                    + joinLeadIds(dupes)
            );
        }
    }

    private static void sortLeadsByCreatedDateAsc(List<Lead> arr) {
        if (arr == null || arr.size() < 2) {
            return;
        }
        Integer n = arr.size();
        for (Integer i = 1; i < n; i++) {
            Lead key = arr[i];
            Integer j = i - 1;
            while (j >= 0 && arr[j].CreatedDate > key.CreatedDate) {
                arr[j + 1] = arr[j];
                j--;
            }
            arr[j + 1] = key;
        }
    }

    private void reparentFormDataToContact(Set<Id> leadIds, Id contactId) {
        if (leadIds.isEmpty()) {
            return;
        }
        System.debug(
            LoggingLevel.INFO,
            'batchDeDupeLeads | reparentFormDataToContact SOQL Form_Data__c WHERE Lead__c IN leadIds leadIds.size='
                + leadIds.size()
                + ' leadIds='
                + leadIds
                + ' contactId='
                + contactId
        );
        List<Form_Data__c> rows = [
            SELECT Id, Lead__c, Contact__c
            FROM Form_Data__c
            WHERE Lead__c IN :leadIds
        ];
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | reparentFormDataToContact rows=' + rows);
        for (Form_Data__c fd : rows) {
            fd.Contact__c = contactId;
            // Detach from Lead before merge/convert; merge can otherwise reparent or drop child rows still tied to merged leads.
            fd.Lead__c = null;
        }
        if (!rows.isEmpty()) {
            update rows;
        }
    }

    /**
     * After Database.merge, any Form_Data still linked to the surviving lead gets Contact__c and Lead__c cleared.
     */
    private void sweepFormDataAfterLeadMerge(Id masterLeadId, Id contactId) {
        List<Form_Data__c> rows = [
            SELECT Id, Lead__c, Contact__c
            FROM Form_Data__c
            WHERE Lead__c = :masterLeadId
        ];
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | sweepFormDataAfterLeadMerge count=' + rows.size() + ' masterLeadId=' + masterLeadId);
        if (rows.isEmpty()) {
            return;
        }
        for (Form_Data__c fd : rows) {
            fd.Contact__c = contactId;
            fd.Lead__c = null;
        }
        update rows;
    }

    /**
     * After convertLead, clear any Lead__c left on Form_Data for this contact (convert/triggers can repopulate it).
     */
    private void sweepFormDataClearLeadAfterConvert(Id contactId) {
        List<Form_Data__c> rows = [
            SELECT Id, Lead__c
            FROM Form_Data__c
            WHERE Contact__c = :contactId AND Lead__c != NULL
        ];
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | sweepFormDataClearLeadAfterConvert count=' + rows.size() + ' contactId=' + contactId);
        for (Form_Data__c fd : rows) {
            fd.Lead__c = null;
        }
        if (!rows.isEmpty()) {
            update rows;
        }
    }

    private void touchContactsIfNeeded() {
        if (!commitData || contactIdsToTouch.isEmpty()) {
            System.debug(
                LoggingLevel.INFO,
                'batchDeDupeLeads | touchContactsIfNeeded skip commitData=' + commitData + ' contactIdsToTouch.empty=' + contactIdsToTouch.isEmpty()
            );
            return;
        }
        System.debug(
            LoggingLevel.INFO,
            'batchDeDupeLeads | touchContactsIfNeeded SOQL Contact WHERE Id IN contactIdsToTouch ids=' + contactIdsToTouch
        );
        List<Contact> toUpdate = [
            SELECT Id, SyncToHubSpot__c
            FROM Contact
            WHERE Id IN :contactIdsToTouch
        ];
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | touchContactsIfNeeded toUpdate=' + toUpdate);
        for (Contact c : toUpdate) {
            c.SyncToHubSpot__c = true;
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    private String getConvertedStatusLabel() {
        if (String.isNotBlank(cachedConvertedStatus)) {
            return cachedConvertedStatus;
        }
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | getConvertedStatusLabel SOQL LeadStatus IsConverted=true LIMIT 1');
        List<LeadStatus> st = [
            SELECT MasterLabel
            FROM LeadStatus
            WHERE IsConverted = TRUE
            LIMIT 1
        ];
        cachedConvertedStatus = st.isEmpty() ? 'Closed - Converted' : st[0].MasterLabel;
        System.debug(LoggingLevel.INFO, 'batchDeDupeLeads | getConvertedStatusLabel result=' + cachedConvertedStatus + ' queriedRows=' + st);
        return cachedConvertedStatus;
    }

    private static String normalizeEmail(String email) {
        return email == null ? '' : email.trim().toLowerCase();
    }

    /**
     * Database.merge must receive minimal Lead rows. Full SOQL rows include read-only
     * system fields (CreatedDate, IsConverted); passing them causes FIELD_INTEGRITY / DML errors.
     */
    private static Lead leadStubForMerge(Id leadId) {
        return new Lead(Id = leadId);
    }

    private static List<Lead> leadStubsForMerge(List<Lead> leads) {
        List<Lead> stubs = new List<Lead>();
        if (leads == null) {
            return stubs;
        }
        for (Lead l : leads) {
            if (l != null && l.Id != null) {
                stubs.add(new Lead(Id = l.Id));
            }
        }
        return stubs;
    }

    /** Comma-separated Lead Ids for email / debug detail lines. */
    private static String joinLeadIds(List<Lead> leads) {
        if (leads == null || leads.isEmpty()) {
            return '';
        }
        List<String> ids = new List<String>();
        for (Lead l : leads) {
            if (l != null && l.Id != null) {
                ids.add(String.valueOf(l.Id));
            }
        }
        return String.join(ids, ',');
    }

    /** Ids for ERROR email lines (merge + optional contact). */
    private static String idsMergeAndOptionalContact(Lead master, List<Lead> dupes, Contact matchContact) {
        List<String> parts = new List<String>();
        if (master != null && master.Id != null) {
            parts.add('survivorLeadId=' + master.Id);
        }
        if (dupes != null && !dupes.isEmpty()) {
            parts.add('mergedLeadIds=' + joinLeadIds(dupes));
        }
        if (matchContact != null && matchContact.Id != null) {
            parts.add('contactId=' + matchContact.Id);
        }
        return parts.isEmpty() ? '(no-ids)' : String.join(parts, ' | ');
    }

    /** Ids for ERROR email lines (lead convert). */
    private static String idsLeadToContact(Lead master, Contact matchContact) {
        String fromId = (master != null && master.Id != null) ? String.valueOf(master.Id) : 'null';
        String toId = (matchContact != null && matchContact.Id != null) ? String.valueOf(matchContact.Id) : 'null';
        return 'fromLeadId=' + fromId + ' | toContactId=' + toId;
    }

    private void addDetail(String line) {
        if (detailLines.size() >= MAX_DETAIL_LINES) {
            return;
        }
        detailLines.add(line);
    }

    private void recordError(String normEmail, String idPart, String context, String message) {
        executeErrors++;
        addDetail('ERROR | email=' + normEmail + ' | ' + idPart + ' | ' + context + ' | ' + message);
    }

    private void recordMergeErrors(String normEmail, String idPart, String context, Database.MergeResult mr) {
        executeErrors++;
        String msg = '';
        if (mr != null) {
            for (Database.Error err : mr.getErrors()) {
                msg += (msg.length() > 0 ? '; ' : '') + err.getMessage();
            }
        }
        addDetail('ERROR | email=' + normEmail + ' | ' + idPart + ' | ' + context + ' | ' + msg);
    }

    private void recordConvertErrors(String normEmail, String idPart, Database.LeadConvertResult lr) {
        executeErrors++;
        String msg = '';
        if (lr != null) {
            for (Database.Error err : lr.getErrors()) {
                msg += (msg.length() > 0 ? '; ' : '') + err.getMessage();
            }
        }
        addDetail('ERROR | email=' + normEmail + ' | ' + idPart + ' | convertLead | ' + msg);
    }
}