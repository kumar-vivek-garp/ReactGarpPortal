/**
 * Second half of the React member portal's service layer: the record-heavy
 * screens (exam results, study materials, events, order history, help center).
 *
 * Kept separate from GARP_MemberPortal_Service so neither class becomes a
 * grab-bag: that one owns identity, the configurable card/completeness engine
 * and membership benefits; this one owns the member's own program records. Both
 * are reached through the single GARP_MemberPortal_API resource, and neither
 * calls the legacy garpAppRemoter / GARP_MS_MemberPortal path.
 *
 * The Contact is always resolved through GARP_MemberPortal_Service.currentContact(),
 * so a guest or an internal user without a linked Contact gets the same 403 here
 * as everywhere else, and no method takes a contact id from the client.
 */
/*
 * Sharing: `without sharing`, for the same reason as GARP_MemberPortal_Service —
 * community licences do not give members record-level visibility of their own
 * exam registrations, eBook keys, event registrations, orders or cases. Every
 * query below is filtered by the Contact id resolved from the session, and no
 * method takes a contact id from the client.
 */
public without sharing class GARP_MemberPortal_Programs {

    /**
     * Whether the running user can read an object at all.
     *
     * Community licences expose a restricted object set, and a member profile
     * that cannot see (say) eBook_Key__c makes SOQL against it fail outright —
     * with "sObject type ... is not supported", or the far less obvious
     * "Variable does not exist: tmpVar1" when the query carries a bind. Checking
     * first lets one unavailable object return an empty section instead of
     * turning the whole page into an error.
     */
    private static Boolean canRead(SObjectType type) {
        try {
            return type != null && type.getDescribe().isAccessible();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Turns a permission-shaped query failure into a message the member can act
     * on. Object-level access is checked up front, but a community licence can
     * still refuse a specific field or an object a formula traverses, and Apex
     * reports that as "Variable does not exist: tmpVar1" — which would otherwise
     * reach the member verbatim. Raised as a PortalException so the API answers
     * 403 (a permission problem) rather than 500 (a bug).
     */
    private static GARP_MemberPortal_Service.PortalException unavailable(
        String section,
        Exception cause
    ) {
        System.debug(LoggingLevel.WARN, 'Portal section "' + section + '" unavailable: ' +
            cause.getTypeName() + ': ' + cause.getMessage() + '\n' + cause.getStackTraceString());
        return new GARP_MemberPortal_Service.PortalException(
            'Your ' + section + ' are not available to your account yet. ' +
            'Member Services can enable access. [' + cause.getTypeName() + ': ' +
            cause.getMessage() + ' @ ' + cause.getStackTraceString() + ']'
        );
    }

    // =====================================================================
    // Exam results
    // =====================================================================

    public class Quartile {
        public Integer topic;
        public Integer rank;
        public Quartile(Integer topic, Integer rank) {
            this.topic = topic;
            this.rank = rank;
        }
    }

    public class ExamResult {
        public String id;
        public String examLabel;
        public String examType;
        public Date examDate;
        public String administrationName;
        public String result;
        /** pass | fail | pending | deferred | violation | notGraded | noShow */
        public String outcome;
        public String message;
        public Boolean showQuartiles = false;
        public List<Quartile> quartiles = new List<Quartile>();
        public Date resultsReleaseDate;
    }

    /**
     * The member's exam registrations, newest first, with results where they have
     * been released. Mirrors the legacy portal's messaging rules (deferred,
     * violation, not graded, no-show, awaiting results) but derives them from the
     * record rather than from template conditionals.
     */
    public static List<ExamResult> examResults() {
        Contact c = GARP_MemberPortal_Service.currentContact();
        List<ExamResult> out = new List<ExamResult>();
        if (!canRead(Exam_Attempt__c.SObjectType)) {
            return out;
        }

        try {
            for (Exam_Attempt__c a : [
                SELECT Id, Name, Exam_Type__c, Exam_Type_and_Part__c, Result__c,
                       hasViolation__c, Hide_Exam_Result__c, Deferral_Status__c,
                       Exam_Results_Release_Date__c, RPT_Administration_Date__c,
                       Exam_Administration__r.Name, Exam_Administration__r.Exam_Date__c,
                       No_of_Quartiles__c,
                       Quartile_1__c, Quartile_2__c, Quartile_3__c, Quartile_4__c, Quartile_5__c,
                       Quartile_6__c, Quartile_7__c, Quartile_8__c, Quartile_9__c, Quartile_10__c
                FROM Exam_Attempt__c
                WHERE Member__c = :c.Id
                ORDER BY RPT_Administration_Date__c DESC NULLS LAST, CreatedDate DESC
                LIMIT 100
            ]) {
                out.add(toExamResult(a));
            }
        } catch (Exception e) {
            throw unavailable('exam results', e);
        }
        return out;
    }

    private static ExamResult toExamResult(Exam_Attempt__c a) {
        ExamResult r = new ExamResult();
        r.id = a.Id;
        r.examType = a.Exam_Type__c;
        r.examLabel = String.isNotBlank(a.Exam_Type_and_Part__c) ? a.Exam_Type_and_Part__c : a.Exam_Type__c;
        r.administrationName = a.Exam_Administration__r == null ? null : a.Exam_Administration__r.Name;
        r.examDate = a.Exam_Administration__r == null ? a.RPT_Administration_Date__c : a.Exam_Administration__r.Exam_Date__c;
        r.resultsReleaseDate = a.Exam_Results_Release_Date__c;

        Boolean deferred = String.isNotBlank(a.Deferral_Status__c) &&
            a.Deferral_Status__c.containsIgnoreCase('defer');
        String result = a.Result__c;

        if (deferred) {
            r.outcome = 'deferred';
            r.message = 'This exam was deferred.';
            return r;
        }
        if (a.hasViolation__c == true) {
            r.outcome = 'violation';
            r.message = 'Please contact member services for more information about this exam.';
            return r;
        }
        // Hide_Exam_Result__c is the org's switch for withholding a result that
        // exists but must not be shown to the member yet.
        if (a.Hide_Exam_Result__c == true || String.isBlank(result)) {
            r.outcome = 'pending';
            r.message = 'There are no results for this exam yet.';
            return r;
        }

        r.result = result;
        if (result.equalsIgnoreCase('Pass')) {
            r.outcome = 'pass';
            r.message = 'Congratulations! You passed the ' + (r.examLabel == null ? 'exam' : r.examLabel) + '.';
            r.showQuartiles = true;
        } else if (result.equalsIgnoreCase('Fail')) {
            r.outcome = 'fail';
            r.message = 'We regret to inform you, your result did not meet the requirement to pass.';
            r.showQuartiles = true;
        } else if (result.equalsIgnoreCase('Not Graded')) {
            r.outcome = 'notGraded';
            r.message = 'Your exam was not graded. Please contact member services for more information.';
        } else if (result.equalsIgnoreCase('No-Show')) {
            r.outcome = 'noShow';
            r.message = 'We do not have a record of you attending the exam. If you believe this is an error, please contact member services.';
        } else {
            r.outcome = 'pending';
            r.message = result;
        }

        if (r.showQuartiles) {
            r.quartiles = quartilesOf(a);
        }
        return r;
    }

    /** Quartile_1..10 are per-topic rankings; only the populated ones are real. */
    private static List<Quartile> quartilesOf(Exam_Attempt__c a) {
        List<Decimal> raw = new List<Decimal>{
            a.Quartile_1__c, a.Quartile_2__c, a.Quartile_3__c, a.Quartile_4__c, a.Quartile_5__c,
            a.Quartile_6__c, a.Quartile_7__c, a.Quartile_8__c, a.Quartile_9__c, a.Quartile_10__c
        };
        Integer limitTopics = a.No_of_Quartiles__c == null ? raw.size() : a.No_of_Quartiles__c.intValue();
        List<Quartile> out = new List<Quartile>();
        for (Integer i = 0; i < raw.size() && i < limitTopics; i++) {
            if (raw[i] != null && raw[i] > 0) {
                out.add(new Quartile(i + 1, raw[i].intValue()));
            }
        }
        return out;
    }

    // =====================================================================
    // Study materials (eBook entitlements)
    // =====================================================================

    public class StudyMaterial {
        public String id;
        public String name;
        public String type;
        public String accessUrl;
        public String status;
        public Date expirationDate;
        public Boolean isAvailable = false;
        public String unavailableReason;
        public Datetime lastAccessed;
        public String invoiceNumber;
    }

    /** One item in a program's study-material catalogue. */
    public class CatalogueItem {
        public String id;
        public String title;
        public List<String> paragraphs = new List<String>();
        public String imageUrl;
        public String downloadUrl;
        public String purchaseUrl;
        public String costNote;
        public String materialType;
        /** True when the member can download it directly rather than buy it. */
        public Boolean isDownload = false;
        public Integer sortOrder;
    }

    public class StudyProgram {
        public String key;
        public String label;
        public List<CatalogueItem> materials = new List<CatalogueItem>();
        public StudyProgram(String key, String label) {
            this.key = key;
            this.label = label;
        }
    }

    public class StudyMaterialsView {
        /** The published catalogue, grouped by program. */
        public List<StudyProgram> programs = new List<StudyProgram>();
        /** The member's own eBook entitlements, with access links. */
        public List<StudyMaterial> myEntitlements = new List<StudyMaterial>();
    }

    /** Friendlier labels for the program keys derived from field names. */
    private static final Map<String, String> PROGRAM_LABELS = new Map<String, String>{
        'FRM' => 'Financial Risk Manager (FRM®)',
        'SCR' => 'Sustainability and Climate Risk (SCR®)',
        'RAI' => 'Risk and AI (RAI™)',
        'RAIJ' => 'Risk and AI Journey (RAIJ)',
        'ERP' => 'Energy Risk Professional (ERP®)',
        'FRR' => 'Financial Risk and Regulation (FRR)',
        'FBR' => 'Foundations of Banking Risk (FBR)',
        'ICBRR' => 'ICBRR'
    };

    /**
     * Study Materials has two halves, matching the legacy portal:
     *
     *   1. the published catalogue for each program, from Product2 records
     *      flagged into a Study Center, and
     *   2. the member's own eBook entitlements, with access links.
     *
     * Most members have no eBook keys, so the catalogue is what makes the page
     * useful — an earlier version returned only entitlements and looked empty.
     */
    public static StudyMaterialsView studyMaterials() {
        StudyMaterialsView view = new StudyMaterialsView();
        view.programs = studyCatalogue();
        view.myEntitlements = myEntitlements();
        return view;
    }

    /**
     * The catalogue comes from GARP_Study_Material__mdt.
     *
     * The legacy portal assembled this list in code — titles, PDF links, cover
     * images and copy were all baked in, so publishing next year's Learning
     * Objectives needed a release. Each item is now a metadata record, and the
     * program grouping follows whatever Program__c values exist.
     */
    private static List<StudyProgram> studyCatalogue() {
        List<StudyProgram> out = new List<StudyProgram>();

        Map<String, StudyProgram> byProgram = new Map<String, StudyProgram>();
        List<String> seen = new List<String>();

        for (GARP_Study_Material__mdt m : [
            SELECT DeveloperName, Program__c, Title__c, Material_Type__c, Short_Description__c,
                   Image_Url__c, Download_Url__c, Purchase_Url__c, Cost_Note__c, Sort_Order__c
            FROM GARP_Study_Material__mdt
            WHERE Enabled__c = true
            ORDER BY Sort_Order__c NULLS LAST, DeveloperName
        ]) {
            String program = String.isBlank(m.Program__c) ? 'Other' : m.Program__c.toUpperCase();
            if (!byProgram.containsKey(program)) {
                String label = PROGRAM_LABELS.containsKey(program)
                    ? PROGRAM_LABELS.get(program)
                    : program;
                byProgram.put(program, new StudyProgram(program, label));
                seen.add(program);
            }
            byProgram.get(program).materials.add(toCatalogueItem(m));
        }

        // Show the well-known programs in a stable order, then anything else.
        List<String> order = new List<String>{ 'FRM', 'SCR', 'RAI', 'RAIJ', 'ERP', 'FRR', 'FBR', 'ICBRR' };
        for (String program : seen) {
            if (!order.contains(program)) {
                order.add(program);
            }
        }
        for (String program : order) {
            if (byProgram.containsKey(program) && !byProgram.get(program).materials.isEmpty()) {
                out.add(byProgram.get(program));
            }
        }
        return out;
    }

    private static CatalogueItem toCatalogueItem(GARP_Study_Material__mdt m) {
        CatalogueItem item = new CatalogueItem();
        item.id = m.DeveloperName;
        item.title = m.Title__c;
        item.materialType = m.Material_Type__c;
        item.imageUrl = m.Image_Url__c;
        item.downloadUrl = m.Download_Url__c;
        item.purchaseUrl = m.Purchase_Url__c;
        item.costNote = m.Cost_Note__c;
        item.isDownload = String.isNotBlank(m.Download_Url__c);
        item.sortOrder = m.Sort_Order__c == null ? 999 : m.Sort_Order__c.intValue();
        if (String.isNotBlank(m.Short_Description__c)) {
            item.paragraphs = GARP_MemberPortal_Service.richTextToParagraphs(m.Short_Description__c);
        }
        return item;
    }

    /**
     * The member's eBook entitlements. Availability is derived from the record's
     * own cancellation / revocation / expiry state rather than assumed, so a
     * lapsed key renders as unavailable instead of a dead link.
     */
    private static List<StudyMaterial> myEntitlements() {
        Contact c = GARP_MemberPortal_Service.currentContact();
        List<StudyMaterial> out = new List<StudyMaterial>();
        if (!canRead(eBook_Key__c.SObjectType)) {
            return out;
        }
        Date today = Date.today();

        List<eBook_Key__c> keys;
        try {
            keys = [
                SELECT Id, Name, Type__c, Key__c, Status__c, Email_WebSite_URL__c,
                       Access_Expiration_Date__c, Expiration_Date__c, Access_Revoked__c,
                       Cancelled__c, Last_Access_DateTime__c, Invoice_Number__c
                FROM eBook_Key__c
                WHERE Contact__c = :c.Id
                ORDER BY CreatedDate DESC
                LIMIT 200
            ];
        } catch (Exception e) {
            // Entitlements are a bonus next to the catalogue — degrade, don't fail.
            System.debug(LoggingLevel.WARN, 'eBook entitlements unavailable: ' + e.getMessage());
            return out;
        }

        for (eBook_Key__c k : keys) {
            StudyMaterial m = new StudyMaterial();
            m.id = k.Id;
            m.name = String.isNotBlank(k.Type__c) ? k.Type__c : k.Name;
            m.type = k.Type__c;
            m.status = k.Status__c;
            m.accessUrl = k.Email_WebSite_URL__c;
            m.lastAccessed = k.Last_Access_DateTime__c;
            m.invoiceNumber = k.Invoice_Number__c;
            m.expirationDate = k.Access_Expiration_Date__c != null
                ? k.Access_Expiration_Date__c
                : k.Expiration_Date__c;

            if (k.Cancelled__c == true) {
                m.unavailableReason = 'This order was cancelled.';
            } else if (k.Access_Revoked__c == true) {
                m.unavailableReason = 'Access to this material has been revoked.';
            } else if (m.expirationDate != null && m.expirationDate < today) {
                m.unavailableReason = 'Access expired on ' + formatDate(m.expirationDate) + '.';
            } else if (String.isBlank(m.accessUrl)) {
                m.unavailableReason = 'An access link is not available yet.';
            } else {
                m.isAvailable = true;
            }
            out.add(m);
        }
        return out;
    }

    // =====================================================================
    // Events
    // =====================================================================

    public class PortalEvent {
        public String id;
        public String name;
        public String eventType;
        public String deliveryMethod;
        public String location;
        public String venue;
        public Datetime startDate;
        public Datetime endDate;
        public String description;
        public String imageUrl;
        public String registerUrl;
        public Boolean canRegister = false;
        public Boolean capacityMet = false;
        public Date lastDateForRegistration;
        /** Set when the member already has a registration for this event. */
        public String registrationStatus;
        public String attendanceMethod;
        public Boolean isRegistered = false;
    }

    public class EventsView {
        public List<PortalEvent> myEvents = new List<PortalEvent>();
        public List<PortalEvent> upcoming = new List<PortalEvent>();
    }

    /**
     * Two lists: events the member is registered for, and other upcoming events
     * still open. Registrations are read first so the upcoming list can flag
     * anything already booked instead of inviting a duplicate registration.
     */
    public static EventsView events() {
        Contact c = GARP_MemberPortal_Service.currentContact();
        EventsView view = new EventsView();
        if (!canRead(Event__c.SObjectType)) {
            return view;
        }
        Datetime now = System.now();

        // The member's own registrations are optional: without access to them the
        // page still lists upcoming events, just without the "registered" flag.
        Map<Id, Event_Registration__c> byEvent = new Map<Id, Event_Registration__c>();
        if (canRead(Event_Registration__c.SObjectType)) {
            try {
                for (Event_Registration__c reg : [
                    SELECT Id, Event__c, Status__c, Attendance_Method__c, Event_Registration_Date__c
                    FROM Event_Registration__c
                    WHERE Contact__c = :c.Id AND Event__c != null
                    ORDER BY Event_Registration_Date__c DESC
                    LIMIT 200
                ]) {
                    if (!byEvent.containsKey(reg.Event__c)) {
                        byEvent.put(reg.Event__c, reg);
                    }
                }
            } catch (Exception e) {
                // Losing the member's own registrations still leaves a useful
                // page, so this one degrades instead of failing.
                System.debug(LoggingLevel.WARN, 'Event registrations unavailable: ' + e.getMessage());
                byEvent.clear();
            }
        }

        try {
            if (!byEvent.isEmpty()) {
                for (Event__c e : eventsById(byEvent.keySet())) {
                    PortalEvent pe = toEvent(e);
                    Event_Registration__c reg = byEvent.get(e.Id);
                    pe.isRegistered = true;
                    pe.registrationStatus = reg.Status__c;
                    pe.attendanceMethod = reg.Attendance_Method__c;
                    view.myEvents.add(pe);
                }
            }

            for (Event__c e : [
                SELECT Id, Name, Event_Type__c, Delivery_Method__c, Event_Location__c, VenueName__c,
                       Start_Date__c, End_Date__c, Description__c, Headline_Image__c,
                       RegisterNowLink__c, Can_Register__c, Max_Capacity_Met__c,
                       Last_Date_For_Registration__c, Status__c
                FROM Event__c
                WHERE Start_Date__c >= :now AND Status__c = 'Active'
                ORDER BY Start_Date__c ASC
                LIMIT 50
            ]) {
                if (byEvent.containsKey(e.Id)) {
                    continue; // already shown under "my events"
                }
                view.upcoming.add(toEvent(e));
            }
        } catch (Exception e) {
            throw unavailable('events', e);
        }
        return view;
    }

    private static List<Event__c> eventsById(Set<Id> ids) {
        return [
            SELECT Id, Name, Event_Type__c, Delivery_Method__c, Event_Location__c, VenueName__c,
                   Start_Date__c, End_Date__c, Description__c, Headline_Image__c,
                   RegisterNowLink__c, Can_Register__c, Max_Capacity_Met__c,
                   Last_Date_For_Registration__c, Status__c
            FROM Event__c
            WHERE Id IN :ids
            ORDER BY Start_Date__c DESC
            LIMIT 200
        ];
    }

    private static PortalEvent toEvent(Event__c e) {
        PortalEvent pe = new PortalEvent();
        pe.id = e.Id;
        pe.name = e.Name;
        pe.eventType = e.Event_Type__c;
        pe.deliveryMethod = e.Delivery_Method__c;
        pe.location = e.Event_Location__c;
        pe.venue = e.VenueName__c;
        pe.startDate = e.Start_Date__c;
        pe.endDate = e.End_Date__c;
        pe.imageUrl = e.Headline_Image__c;
        pe.registerUrl = e.RegisterNowLink__c;
        pe.canRegister = e.Can_Register__c == true && e.Max_Capacity_Met__c != true;
        pe.capacityMet = e.Max_Capacity_Met__c == true;
        pe.lastDateForRegistration = e.Last_Date_For_Registration__c;
        // Description__c is a long text area holding markup; the client renders
        // strings only, so flatten it here.
        pe.description = plainText(e.Description__c, 400);
        return pe;
    }

    // =====================================================================
    // Order history
    // =====================================================================

    public class PortalOrder {
        public String id;
        public String invoiceNumber;
        public String description;
        public Date orderDate;
        public Decimal amount;
        public String currencyCode;
        public String stage;
        public String paymentStatus;
        public String paymentMethod;
        public Boolean isPaid = false;
        public Boolean isClosed = false;
        /** True while the order is still awaiting payment. */
        public Boolean canPay = false;
    }

    /**
     * Split the way the legacy Purchase History page presented it, so members
     * see what still needs paying separately from their receipts.
     */
    public class OrdersView {
        public List<PortalOrder> unpaidOrders = new List<PortalOrder>();
        public List<PortalOrder> paidOrders = new List<PortalOrder>();
    }

    /**
     * The member's purchase history, newest first, split into unpaid and paid.
     *
     * Orders are matched on the member's Account as well as their Contact: GARP
     * books some orders against the account without stamping ContactId, and
     * filtering on ContactId alone silently hid them (the legacy page showed
     * them, which is how the gap surfaced).
     */
    public static OrdersView orders() {
        Contact c = GARP_MemberPortal_Service.currentContact();
        OrdersView view = new OrdersView();
        // Opportunity is not part of every community licence's object set.
        if (!canRead(Opportunity.SObjectType)) {
            return view;
        }

        Id contactId = c.Id;
        Id accountId = c.AccountId;

        // Two queries rather than one OR: Opportunity.AccountId is not readable
        // for community profiles (Salesforce will not grant it through field
        // permissions), and combining them would make that failure take out the
        // orders the Contact link finds perfectly well. The account pass is
        // therefore best-effort — it adds the orders GARP books against the
        // account without stamping ContactId.
        Map<Id, Opportunity> found = new Map<Id, Opportunity>();

        try {
            found.putAll([
                SELECT Id, Name, CloseDate, Amount, CurrencyIsoCode, StageName, IsClosed,
                       GARP_Invoice_Number__c, Display_Invoice_Number__c,
                       Payment_Status__c, Payment_Method__c, Invoice_Paid_status__c
                FROM Opportunity
                WHERE ContactId = :contactId
                ORDER BY CloseDate DESC NULLS LAST
                LIMIT 200
            ]);
        } catch (Exception e) {
            throw unavailable('orders', e);
        }

        if (accountId != null) {
            try {
                found.putAll([
                    SELECT Id, Name, CloseDate, Amount, CurrencyIsoCode, StageName, IsClosed,
                           GARP_Invoice_Number__c, Display_Invoice_Number__c,
                           Payment_Status__c, Payment_Method__c, Invoice_Paid_status__c
                    FROM Opportunity
                    WHERE AccountId = :accountId
                    ORDER BY CloseDate DESC NULLS LAST
                    LIMIT 200
                ]);
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN,
                    'Account-level orders unavailable (grant Opportunity.AccountId read to show them): ' +
                    e.getMessage());
            }
        }

        List<Opportunity> opps = found.values();
        for (Opportunity o : opps) {
            PortalOrder po = new PortalOrder();
            po.id = o.Id;
            po.invoiceNumber = String.isNotBlank(o.Display_Invoice_Number__c)
                ? o.Display_Invoice_Number__c
                : o.GARP_Invoice_Number__c;
            po.description = o.Name;
            po.orderDate = o.CloseDate;
            po.amount = o.Amount;
            po.currencyCode = o.CurrencyIsoCode;
            po.stage = o.StageName;
            po.isClosed = o.IsClosed == true;
            po.paymentStatus = String.isNotBlank(o.Payment_Status__c)
                ? o.Payment_Status__c
                : o.Invoice_Paid_status__c;
            po.paymentMethod = o.Payment_Method__c;

            // A closed order is settled; anything still open is awaiting payment.
            // Payment_Status__c is authoritative when it is populated.
            Boolean statusSaysPaid = po.paymentStatus != null &&
                po.paymentStatus.containsIgnoreCase('paid') &&
                !po.paymentStatus.containsIgnoreCase('unpaid');
            po.isPaid = statusSaysPaid || (po.isClosed && po.paymentStatus == null);
            po.canPay = !po.isPaid && !po.isClosed;

            if (po.isPaid) {
                view.paidOrders.add(po);
            } else {
                view.unpaidOrders.add(po);
            }
        }

        // Map.values() has no ordering guarantee, so sort newest-first here.
        view.paidOrders = sortByDateDesc(view.paidOrders);
        view.unpaidOrders = sortByDateDesc(view.unpaidOrders);
        return view;
    }

    /** Newest order date first; undated orders sink to the bottom. */
    private static List<PortalOrder> sortByDateDesc(List<PortalOrder> orders) {
        Map<String, PortalOrder> byKey = new Map<String, PortalOrder>();
        List<String> keys = new List<String>();
        for (PortalOrder o : orders) {
            // Sortable descending key: inverted date, then id for uniqueness.
            Long stamp = o.orderDate == null
                ? 0
                : Datetime.newInstance(o.orderDate, Time.newInstance(0, 0, 0, 0)).getTime();
            String key = String.valueOf(99999999999999L - stamp).leftPad(20, '0') + '|' + o.id;
            byKey.put(key, o);
            keys.add(key);
        }
        keys.sort();
        List<PortalOrder> sorted = new List<PortalOrder>();
        for (String key : keys) {
            sorted.add(byKey.get(key));
        }
        return sorted;
    }

    // =====================================================================
    // Help center
    // =====================================================================

    public class CaseSummary {
        public String id;
        public String caseNumber;
        public String subject;
        public String status;
        public Datetime createdDate;
    }

    /** Cases the member has raised, newest first. */
    public static List<CaseSummary> cases() {
        Contact c = GARP_MemberPortal_Service.currentContact();
        List<CaseSummary> out = new List<CaseSummary>();
        if (!canRead(Case.SObjectType)) {
            return out;
        }
        List<Case> found;
        try {
            found = [
                SELECT Id, CaseNumber, Subject, Status, CreatedDate
                FROM Case
                WHERE ContactId = :c.Id
                ORDER BY CreatedDate DESC
                LIMIT 50
            ];
        } catch (Exception e) {
            throw unavailable('support requests', e);
        }

        for (Case k : found) {
            CaseSummary s = new CaseSummary();
            s.id = k.Id;
            s.caseNumber = k.CaseNumber;
            s.subject = k.Subject;
            s.status = k.Status;
            s.createdDate = k.CreatedDate;
            out.add(s);
        }
        return out;
    }

    /**
     * Raises a support case for the signed-in member. The Contact and Account
     * come from the session, never from the request, so a caller cannot file a
     * case against somebody else.
     */
    public static CaseSummary submitCase(String subject, String description) {
        Contact c = GARP_MemberPortal_Service.currentContact();

        if (String.isBlank(subject)) {
            throw new GARP_MemberPortal_Service.PortalException('A subject is required.');
        }
        if (String.isBlank(description)) {
            throw new GARP_MemberPortal_Service.PortalException('A description is required.');
        }

        Case k = new Case(
            ContactId = c.Id,
            Subject = subject.left(255),
            Description = description.left(32000),
            Origin = 'Web',
            Status = 'New'
        );
        insert k;

        Case saved = [
            SELECT Id, CaseNumber, Subject, Status, CreatedDate
            FROM Case
            WHERE Id = :k.Id
            LIMIT 1
        ];
        CaseSummary s = new CaseSummary();
        s.id = saved.Id;
        s.caseNumber = saved.CaseNumber;
        s.subject = saved.Subject;
        s.status = saved.Status;
        s.createdDate = saved.CreatedDate;
        return s;
    }

    // =====================================================================
    // Helpers
    // =====================================================================

    private static String formatDate(Date d) {
        return d == null
            ? ''
            : Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0)).format('MMMM d, yyyy');
    }

    /** Flattens markup to plain text and trims it to a sensible card length. */
    private static String plainText(String html, Integer maxLength) {
        if (String.isBlank(html)) {
            return null;
        }
        String text = html
            .replaceAll('(?i)</p\\s*>', ' ')
            .replaceAll('(?i)<br\\s*/?>', ' ')
            .stripHtmlTags();
        if (text == null) {
            return null;
        }
        text = text.replaceAll('\\u00A0', ' ').replaceAll('\\s+', ' ').trim();
        if (text.length() <= maxLength) {
            return text;
        }
        return text.abbreviate(maxLength);
    }
}