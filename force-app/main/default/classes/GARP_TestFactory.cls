@isTest
public class GARP_TestFactory {

    /**
     * Wrapper returned by setupIndividualMember() with the User, Account, Contact, and Opportunity created for an individual member setup.
     */
    public class IndividualMemberSetup {
        public User user;
        public Account account;
        public Contact contact;
        public Opportunity opp;
    }
    
    @TestVisible private static GARP_BC_Orders.checkoutCart createCheckoutCart(String prodCode, Boolean isStudyMat){
        
        GARP_BC_Orders.checkoutCart checkoutCart = new GARP_BC_Orders.checkoutCart();
        checkoutCart.checkoutProducts = new List<GARP_BC_Orders.checkoutProduct>();
        GARP_BC_Orders.checkoutProduct prod = new GARP_BC_Orders.checkoutProduct();
        prod.productCode = prodCode;
        prod.glCode = '4040';        
        prod.unitPrice = 100;
        prod.quantity = 1;
        prod.description = 'product';
        prod.isStudyMaterial = isStudyMat;
        checkoutCart.checkoutProducts.add(prod);
        
        return checkoutCart;
        
    }

    
    @TestVisible private static void createAffiliateProgram(){
        
        Account account = new Account(Name='Test', EPP_Accounting_Code__c='123');
        insert account;

        Affiliate_Program__c affProg = new Affiliate_Program__c(
            Account__c = account.Id,
            Affiliate_Code__c = '123',
            Start_Date__c = system.today().addDays(-30),
            End_Date__c = system.today().addDays(30),
            Product__c = 'FRM Exam'
        );
        insert affProg;
                
    }
    
    @TestVisible private static String createEvent(String memProdId, String nonMemProdId, Boolean isInviteOnly){

        DateTime nw = DateTime.now();
        
        Form__c form = new Form__c(
            Name = 'form',
            Form_Name__c = 'form'
        );
        insert form;
        
        Content__c cont = new Content__c(
            Content_Name__c = 'Meeting',
            Description__c = 'Is a meeting',
            Location__c = 'Location',
            Event_Start_Date_Time__c = nw,
            Event_End_Date_Time__c = nw.addHours(1),
            Form__c = form.Id
        );
        insert cont;
        
        Time_Zone__c tz = new Time_Zone__c(
            Name = 'Eastern',
            Abbreviation__c = 'EST'
        );
        insert tz;
                
        Event__c ev = new Event__c(
            Name = 'Event',
            Title__c = 'Event',
            Overview__c = 'Event',
            Invite_Only__c = isInviteOnly,
            Delivery_Method__c = 'Hybrid',
            Start_Date__c = nw.AddHours(-100),
            End_Date__c = nw.AddHours(100),
            Status__c = 'Active',
            Is_Sponsored_Event__c = True,
            ON24_Event_Id__c = '1234',
            ON24_URL__c = 'http',
            Content__c = cont.Id,
            Time_Zone__c = tz.Id
        );
        insert ev;
        
        Event_Rate__c er = new Event_Rate__c(
            Name = 'Rate',
            Event__c = ev.Id,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(1),
            Member_Rate__c = 100,
            Non_Member_Rate__c = 150,
            Product_Member_Code__c = memProdId,
            Product_Non_Member_Code__c = nonMemProdId
        );
        insert er;
        //SELECT Id, Name, Start_Date__c, Product_Member_Code__r.GL_Code__c, Product_Non_Member_Code__r.GL_Code__c, Product_Member_Code__r.ProductCode, Product_Non_Member_Code__r.ProductCode, Product_Alumni_Code__r.GL_Code__c, Product_Alumni_Code__r.ProductCode, End_Date__c, Member_Rate__c, Non_Member_Rate__c, Alumni_Rate__c from Event_Rates__r WHERE (Start_Date__c <= TODAY and End_Date__c >= TODAY))
        
         // Insert Event Discount
        Event_Discount__c ed = new Event_Discount__c();
        
        ed.Event__c = ev.Id;
        ed.Discount_Code__c = 'DISCOUNTCODE';
        ed.Discount_To_Fixed_Price__c = 0;
        ed.Start_Date__c = Date.today().addDays(-1);
        ed.End_Date__c = Date.today().addDays(1);
        ed.Registration_Type__c = 'Attendee';
        
        INSERT ed;
        
        // Insert Product Discount
        Product_Discount__c pd1 = new Product_Discount__c();
        
        pd1.Event_Discount__c = ed.Id;
        pd1.Product__c = memProdId;
        
        INSERT pd1;
        
        Product_Discount__c pd2 = new Product_Discount__c();
        
        pd2.Event_Discount__c = ed.Id;
        pd2.Product__c = nonMemProdId;
        
        INSERT pd2;
        
        return ev.id;
    }
    
    @TestVisible private static String createWebcast(){

        DateTime nw = DateTime.now();
        
        Form__c form = new Form__c(
            Name = 'form',
            Form_Name__c = 'form'
        );
        insert form;
        
        Content__c cont = new Content__c(
            Content_Name__c = 'Meeting',
            Description__c = 'Is a meeting',
            Location__c = 'Location',
            Event_Start_Date_Time__c = nw,
            Event_End_Date_Time__c = nw.addHours(1),
            Form__c = form.Id
        );
        insert cont;
        
        Time_Zone__c tz = new Time_Zone__c(
            Name = 'Eastern',
            Abbreviation__c = 'EST'
        );
        insert tz;
        
        Webcast__c wc = new Webcast__c(
            Name = 'Webcast',
            Description__c = 'stuff',
            Start_Date__c = nw.AddHours(-100),
            End_Date__c = nw.AddHours(100),
            Start_Time__c = '10am',
            End_Time__c = '11am',
            Status__c = 'Active',
            Title__c = 'Webcast',
            Is_Sponsored__c = True,
            EventId__c = '1234',
            On_Demand_URL__c = 'http',
            Content__c = cont.Id,
            Time_Zone__c = tz.Id,
            Sponsor_Name__c = 'Test'
        );
        insert wc;
        
        return wc.id;
    }
    
    @TestVisible private static String createChapterMeeting(){
        
                
        Chapter__c chapt = new Chapter__c(Name='Chapter');
        insert chapt;
        
        Chapter_Meeting_Location__c cml = new Chapter_Meeting_Location__c(
            Name='Location',
            Building_Name__c = 'Building',
            Address_Street_1__c = '123 Street',
            Address_Street_2__c = '4th floor',
            Venue_Location__c = 'Venue Location',
            Address_City__c = 'City',
            Address_State_Provence__c = 'State',
            Address_Postal_Code__c = '111111',
            Address_Country__c = 'United States'
        );
        insert cml;
        
        DateTime nw = DateTime.now();
        
        Form__c form = new Form__c(
            Name = 'form',
            Form_Name__c = 'form'
        );
        insert form;
        
        Content__c cont = new Content__c(
            Content_Name__c = 'Meeting',
            Description__c = 'Is a meeting',
            Location__c = 'Location',
            Event_Start_Date_Time__c = nw,
            Event_End_Date_Time__c = nw.addHours(1),
            Form__c = form.Id
        );
        insert cont;
        
        Time_Zone__c tz = new Time_Zone__c(
            Name = 'Eastern',
            Abbreviation__c = 'EST'
        );
        insert tz;
        
        Chapter_Meeting__c cm = new Chapter_Meeting__c(
            Chapter_Meeting_Name__c = 'Meeting', 
            Chapter_Meeting_Location__c = cml.id,
            Last_Day_of_Registration__c = Date.today(),
            Start__c = nw.addHours(-100),
            End__c = nw.addHours(100),
            Is_Sponsored__c = True,
            Sponsor_Name__c = 'Sponsor',
            Time_Zone__c = tz.Id,
            Status__c = 'Active',
            Chapter__c = chapt.Id,
            ON24_URL__c = 'http://url.com',
            ON24_Event_Id__c = '123',      
            Virtual_Start_DateTime__c = system.today(),
            Virtual_End_DateTime__c = system.today().adddays(1),
            Virtual_Meeting_URL__c = 'http',
            Virtual_Meeting_Instructions__c = 'meet',
            In_Person_Title__c = 'title',
            Virtual_Title__c = 'title',
            Delivery_Method__c = 'Hybrid'
        );
        insert cm;
        
        return cm.Id;
    }
    
    @TestVisible private static String createChapterMeeting(String memProdId, String nonMemProdId){
        
        Chapter__c chapt = new Chapter__c(Name='Chapter');
        insert chapt;
        
        Chapter_Meeting_Location__c cml = new Chapter_Meeting_Location__c(
            Name='Location',
            Building_Name__c = 'Building',
            Address_Street_1__c = '123 Street',
            Address_Street_2__c = '4th floor',
            Venue_Location__c = 'Venue Location',
            Address_City__c = 'City',
            Address_State_Provence__c = 'State',
            Address_Postal_Code__c = '111111',
            Address_Country__c = 'United States'
        );
        insert cml;
        
        DateTime nw = DateTime.now();
        
        Form__c form = new Form__c(
            Name = 'form',
            Form_Name__c = 'form'
        );
        insert form;
        
        Content__c cont = new Content__c(
            Content_Name__c = 'Meeting',
            Description__c = 'Is a meeting',
            Location__c = 'Location',
            Event_Start_Date_Time__c = nw,
            Event_End_Date_Time__c = nw.addHours(1),
            Form__c = form.Id
        );
        insert cont;
        
        Time_Zone__c tz = new Time_Zone__c(
            Name = 'Eastern',
            Abbreviation__c = 'EST'
        );
        insert tz;
        
        Chapter_Meeting__c cm = new Chapter_Meeting__c(
            Chapter_Meeting_Name__c = 'Meeting', 
            Chapter_Meeting_Location__c = cml.id,
            Last_Day_of_Registration__c = Date.today(),
            Start__c = nw.addHours(-100),
            End__c = nw.addHours(100),
            Is_Sponsored__c = True,
            Sponsor_Name__c = 'Sponsor',
            Time_Zone__c = tz.Id,
            Status__c = 'Active',
            Chapter__c = chapt.Id,
            ON24_URL__c = 'http://url.com',
            ON24_Event_Id__c = '123',      
            Virtual_Start_DateTime__c = system.today(),
            Virtual_End_DateTime__c = system.today().adddays(1),
            Virtual_Meeting_URL__c = 'http',
            Virtual_Meeting_Instructions__c = 'meet',
            In_Person_Title__c = 'title',
            Virtual_Title__c = 'title',
            Delivery_Method__c = 'Hybrid'
        );
        insert cm;
        
        
        Chapter_Meeting_Rate__c er = new Chapter_Meeting_Rate__c(
            Name = 'Rate',
            Chapter_Meeting__c  = cm.Id,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(1),
            Member_Rate__c = 100,
            Non_Member_Rate__c = 150,
            Product_Member__c  = memProdId,
            Product_Non_Member__c  = nonMemProdId
        );
        insert er;
        //SELECT Id, Name, Start_Date__c, Product_Member_Code__r.GL_Code__c, Product_Non_Member_Code__r.GL_Code__c, Product_Member_Code__r.ProductCode, Product_Non_Member_Code__r.ProductCode, Product_Alumni_Code__r.GL_Code__c, Product_Alumni_Code__r.ProductCode, End_Date__c, Member_Rate__c, Non_Member_Rate__c, Alumni_Rate__c from Event_Rates__r WHERE (Start_Date__c <= TODAY and End_Date__c >= TODAY))
        
         // Insert Event Discount
        Chapter_Meeting_Discount__c ed = new Chapter_Meeting_Discount__c ();
        
        ed.Chapter_Meeting__c  = cm.Id;
        ed.Discount_Code__c = 'DCODE';
        ed.Discount_To_Fixed_Price__c = 0;
        ed.Start_Date__c = Date.today().addDays(-1);
        ed.End_Date__c = Date.today().addDays(1);
        ed.Registration_Type__c = 'Attendee';
        
        INSERT ed;
        
        // Insert Product Discount
        Product_Discount__c pd1 = new Product_Discount__c();
        
        pd1.Chapter_Meeting_Discount__c  = ed.Id;
        pd1.Product__c = memProdId;
        
        INSERT pd1;
        
        Product_Discount__c pd2 = new Product_Discount__c();
        
        pd2.Chapter_Meeting_Discount__c  = ed.Id;
        pd2.Product__c = nonMemProdId;
        
        INSERT pd2;
        
        return cm.Id;
    }
    
    @TestVisible private static void Chp_Evt_Web_Registrations(String cmid,String eventId,String webcastid,id contactid){
        
        if(cmid != NULL) {
            Chapter_Meeting_Registration__c meetingReg = new Chapter_Meeting_Registration__c();
            meetingReg.Chapter_Meeting__c = cmid;
            meetingReg.contact__c = contactid;
            insert meetingReg;
        }
        
        if(eventId != NULL) {
            Event_Registration__c eventRegistrationForParentEvent = new Event_Registration__c();
            eventRegistrationForParentEvent.Contact__c = contactid;
            eventRegistrationForParentEvent.Event__c = eventId;
            INSERT eventRegistrationForParentEvent;
        }
        
        if(webcastid != NULL) {
            Webcast_Registration__c wr = new Webcast_Registration__c();
            wr.Contact__c = contactid;
            wr.Webcast__c = webcastid;
            INSERT wr;        
        }
        
    }
    @TestVisible private static Opportunity createOrder(String accountId, String contactId, String productCode){
        Opportunity opportunity = new Opportunity(
            Name = 'GARP Order',
            AccountId = accountId,
            Eligible_for_Membership_Extension__c = TRUE,
            CloseDate = Date.today(),
            StageName = 'New Lead',
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity', 'Automated')
        );
        insert opportunity;
        
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE ProductCode = :productCode LIMIT 1];
        
        OpportunityLineItem affiliateMembershipOpportunityOli = new OpportunityLineItem( 
            OpportunityId       = opportunity.Id,                          
            PricebookEntryId    = pbe.Id,
            Product2Id          = pbe.Product2Id,
            UnitPrice           = 0,
            Quantity            = 1,
            Description         = 'Individual Membership'
        );
        
        INSERT affiliateMembershipOpportunityOli;
        
        return opportunity;
    }
    
    @TestVisible private static User createIndividualUser() {
        // Create User
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX');
        User user = createIndividualContact(False);
        System.debug('!!user:' + user);
        
        return user;
    }
    
    @TestVisible private static User createIndividualUserThrow() {
        // Create User
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX');
        User user = createIndividualContact(True);
        System.debug('!!user:' + user);
        
        return user;
    }
    
    @TestVisible private static User createUser() {
        // Create User
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX');
        User user = createAffiliateContact();
        System.debug('!!user:' + user);
        
        return user;
    }
    
    @TestVisible private static Opportunity createMember() {
        
        Lead newLead = createLead();
        System.debug('!!newLead:' + newLead);
        
        List<Opportunity> lstOpp = [select id, AccountId from Opportunity];
        Opportunity opp = lstOpp[0];
        System.debug('!!opp:' + opp);
        
        List<Contact> lstCont = [select id, accountId, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c from contact];
        Contact contact = lstCont[0];
        System.debug('!!contact:' + contact);
        
        Opportunity opp1 = createIndividualMemberOrder(contact.accountId, contact.Id);
        
        return opp1;
    }

    /**
     * Sets up products, creates an individual user, and returns a wrapper with the user, account, contact, and an opportunity.
     * Uses the first Opportunity and Contact in the org after creating the user (e.g. from createIndividualContact).
     * @param doThrow when true, uses createIndividualUserThrow(); otherwise createIndividualUser().
     */
    public static IndividualMemberSetup setupIndividualMember(Boolean doThrow) {
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        User u = (doThrow == true) ? GARP_TestFactory.createIndividualUserThrow() : GARP_TestFactory.createIndividualUser();
        List<Opportunity> lstOpp = [SELECT Id, AccountId, StageName FROM Opportunity LIMIT 1];
        Opportunity o = lstOpp.isEmpty() ? null : lstOpp[0];
        List<Contact> lstCont = [SELECT Id, AccountId, Email, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c FROM Contact];
        Contact c = lstCont.isEmpty() ? null : lstCont[0];
        Account a = null;
        if (c != null) {
            List<Account> lstAcct = [SELECT Id, Name FROM Account WHERE Id = :c.AccountId];
            a = lstAcct.isEmpty() ? null : lstAcct[0];
        }
        // Activate the membership contract created by createIndividualContact
        if (a != null) {
            Id memRtId = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership');
            List<Contract> contracts = [SELECT Id, Status FROM Contract WHERE AccountId = :a.Id AND RecordTypeId = :memRtId LIMIT 1];
            if (!contracts.isEmpty()) {
                contracts[0].Status = 'Activated';
                update contracts[0];
            }
        }

        IndividualMemberSetup result = new IndividualMemberSetup();
        result.user = u;
        result.account = a;
        result.contact = c;
        result.opp = o;
        return result;
    }

    /**
     * Same as setupIndividualMember(false). Kept for backward compatibility.
     */
    public static IndividualMemberSetup setupIndividualMember() {
        return setupIndividualMember(false);
    }
    
    @TestVisible private static Opportunity createIndividualMemberOrder(String accountId, String contactId){

        Opportunity opportunity = new Opportunity(
            Name = 'Individual Membership',
            AccountId = accountId,
            Eligible_for_Membership_Extension__c = TRUE,
            CloseDate = Date.today(),
            StageName = 'New Lead',
            Billing_Email__c = 'test@test.garp.com',
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity', 'Automated')
        );

        INSERT opportunity;

        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE ProductCode = 'MEMI' LIMIT 1];

        OpportunityLineItem affiliateMembershipOpportunityOli = new OpportunityLineItem( 
            OpportunityId       = opportunity.Id,                          
            PricebookEntryId    = pbe.Id,
            Product2Id          = pbe.Product2Id,
            UnitPrice           = 0,
            Quantity            = 1,
            Description         = 'Individual Membership',
            Product_ID__c       = '2022SCRPE2022'
        );

        INSERT affiliateMembershipOpportunityOli;

        Contract membershipContract = new Contract(
            Name = 'Individual Membership',
            AccountId = accountId,
            Opportunity__c = opportunity.Id,
            CustomerSignedId = contactId,
            StartDate = System.Today(),
            ContractTerm = 12,
            Membership_Type__c = 'Individual',
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership')
        );
        
        INSERT membershipContract;
        
        membershipContract.Status = 'Activated';
        update membershipContract;

        return opportunity;

    }
    

    @TestVisible private static Lead createLead(){
        Lead newLead = new Lead(
                Email='garpqa@garpqa.com', 
                LeadSource='formKey',
                LastName='GARPQA', 
                FirstName='TEST', 
                Company='Company'
            );
        newLead.OwnerId = [SELECT Id, Record_id__c FROM updateids__c WHERE name = 'User' LIMIT 1].Record_id__c;
        insert newLead;
        
        return newLead;
    }
    
    @TestVisible private static User createAffiliateContact(){

        Account account = new Account();
        account.Name = 'TEST';
        account.OwnerId = [SELECT Id, Record_id__c FROM updateids__c WHERE name = 'User' LIMIT 1].Record_id__c;
        account.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Account', 'Individual');
        INSERT account;

        Opportunity opportunity = new Opportunity(
            Name = 'Affiliate Membership',
            AccountId = account.Id,
            Eligible_for_Membership_Extension__c = TRUE,
            CloseDate = Date.today(),
            StageName = 'New Lead',
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity', 'Automated')
        );

        INSERT opportunity;

        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE ProductCode = 'AFREE' LIMIT 1];

        OpportunityLineItem affiliateMembershipOpportunityOli = new OpportunityLineItem( 
            OpportunityId       = opportunity.Id,                          
            PricebookEntryId    = pbe.Id,
            Product2Id          = pbe.Product2Id,
            UnitPrice           = 0,
            Quantity            = 1,
            Description         = 'Affiliate Membership'
        );

        INSERT affiliateMembershipOpportunityOli;

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.Email = 'garpqa@garpqa.com';
        contact.FirstName = 'GARPQA';
        contact.LastName = 'TEST';
        contact.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contact', 'Member');
        INSERT contact;

        Contract membershipContract = new Contract(
            Name = 'Affiliate Membership',
            AccountId = account.Id,
            Opportunity__c = opportunity.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today(),
            ContractTerm = 12,
            Membership_Type__c = 'Affiliate',
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership')
        );
        
        INSERT membershipContract;

        opportunity.StageName = 'Closed';

        UPDATE opportunity;
        
        List<User> users =  [
            SELECT Id, ContactId, AccountId
            FROM User 
            WHERE ContactId = :contact.Id LIMIT 1
        ];
        
        System.debug(users);
        
        if(users.isEmpty()){
            return null;
        }else{
            return users[0];
        }

    }
    
    @TestVisible private static User createIndividualContact(Boolean isThrow){

        Account account = new Account();
        account.Name = 'TEST';
        account.OwnerId = [SELECT Id, Record_id__c FROM updateids__c WHERE name = 'User' LIMIT 1].Record_id__c;
        account.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Account', 'Individual');
        INSERT account;

        Opportunity opportunity = new Opportunity(
            Name = 'Individual Membership',
            AccountId = account.Id,
            Eligible_for_Membership_Extension__c = TRUE,
            CloseDate = Date.today(),
            StageName = 'New Lead',
            Billing_Email__c = 'garpqa@garpqa.com',
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity', 'Automated')
        );

        INSERT opportunity;

        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE ProductCode = 'MEMI' LIMIT 1];

        OpportunityLineItem affiliateMembershipOpportunityOli = new OpportunityLineItem( 
            OpportunityId       = opportunity.Id,                          
            PricebookEntryId    = pbe.Id,
            Product2Id          = pbe.Product2Id,
            UnitPrice           = 0,
            Quantity            = 1,
            Description         = 'Individual Membership'
        );

        INSERT affiliateMembershipOpportunityOli;

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.Email = 'garpqa@garpqa.com';
        if(isThrow) {
            contact.FirstName = 'throw';
        } else {
            contact.FirstName = 'GARPQA';    
        }
        contact.LastName = 'TEST';
        contact.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contact', 'Member');
        INSERT contact;

        Contract membershipContract = new Contract(
            Name = 'Individual Membership',
            AccountId = account.Id,
            Opportunity__c = opportunity.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today(),
            ContractTerm = 12,
            Membership_Type__c = 'Individual',
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership')
        );
        
        INSERT membershipContract;
        //membershipContract.Status = 'Active';
        //update membershipContract;

        opportunity.StageName = 'Closed';

        UPDATE opportunity;
        
        List<User> users =  [
            SELECT Id, ContactId, AccountId
            FROM User 
            WHERE ContactId = :contact.Id LIMIT 1
        ];
        
        System.debug('New User:' + users);
        
        if(users.isEmpty()){
            return null;
        }else{
            return users[0];
        }

    }

    @TestVisible private static void makeIndividualCertified(String accountId){
        Id frmProgRecId = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');    
        
        Contract frmContract = new Contract(Opportunity__c = null, AccountId = accountId, recordTypeId = frmProgRecId, Status='Draft', ContractTerm = 12);
        insert frmContract;
        frmContract.Status = 'Completed';
        update frmContract;
    }

    @TestVisible private static void makeIndividualERPCertified(String accountId){
        Id progRecId = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program');    
        
        Contract contract = new Contract(Opportunity__c = null, AccountId = accountId, recordTypeId = progRecId, Status='Draft', ContractTerm = 12);
        insert contract;
        contract.Status = 'Completed';
        update contract;
    }

    @TestVisible private static void makeIndividualSCRHolder(String accountId){
        Id progRecId = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program');    
        
        Contract contract = new Contract(Opportunity__c = null, AccountId = accountId, recordTypeId = progRecId, Status='Draft', ContractTerm = 12);
        insert contract;
        contract.Status = 'Completed';
        update contract;
    }

    @TestVisible private static void makeIndividualRAIHolder(String accountId){
        Id progRecId = RecordTypeHelper.GetRecordTypeId('Contract','Risk AI Program');    
        
        Contract contract = new Contract(Opportunity__c = null, AccountId = accountId, recordTypeId = progRecId, Status='Draft', ContractTerm = 12);
        insert contract;
        contract.Status = 'Completed';
        update contract;
    }
    
    public static Team_Registration__c createTeamReg(String teamRegType, Decimal discount, Boolean isScholarship, Boolean compMembership, Boolean addSCRDiscountLineItem) {
        
        Contact cont = new Contact(
            FirstName = 'bob',
            LastName = 'bob',
            Email = 'bob@bob.com'
        );
        insert cont;
        
        Team_Registration__c teamReg = new Team_Registration__c(
            Name = 'TeamReg',
            //Exam_Type__c = teamRegType,
            Seats_Allowed__c = 15,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(30),
            Payment_Status__c = 'Paid',
            Status__c = 'Approved',
            Contact__c = cont.Id,
            Is_Scholarship__c = isScholarship,
            Include_Exam_or_Courses__c = True
        );
        
        teamReg.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Team_Registration__c','B2B Deal');
        if(isScholarship) {
            teamReg.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Team_Registration__c','B2B Deal Scholarship');    
        }
        
        insert teamReg;
        
        b2b_deal_Item__c item = new b2b_deal_Item__c();
        item.B2B_Deal__c = teamReg.id;
        item.Access_Code__c = '123';
        item.Start_Date__c = system.today().adddays(-2);
        item.End_Date__c = system.today().adddays(2);
        item.Exam_Type__c = teamRegType;
        item.Seats_Allowed__c = 1;
        item.Add_Discount_Line_Item__c = addSCRDiscountLineItem;
        
        if(discount != NULL) {
            item.Discounted_Price__c = discount;
        }
        
        if(compMembership) {
            item.Free_Membership__c = True;
        }
        
        insert item;
        
        List<Team_Registration__c> tr = [select Id, Access_Code__c from Team_Registration__c where id = :teamReg.id];
        
        return tr[0];
    }
    
    public static Contact createMember(String email, Boolean isCertified) {
        Contact cont;
        
        Id individualRecId = RecordTypeHelper.GetRecordTypeId('Account','Individual');
        Account acct = new Account(Name = 'Member' + email, Member_Email__c = email, RecordTypeId = individualRecId);
        insert acct;
        
        Id memContRecId = RecordTypeHelper.GetRecordTypeId('Contact','Member');
        cont = new Contact(firstname = 'fn', lastname = 'ln', AccountId = acct.id, GARP_Directory_Connect_Feature__c = True,
                           Membership_Type__c = 'Individual', KPI_Membership_Payment_Status__c = 'In Good Standing',
                              email=email, RecordTypeId=memContRecId);
        insert cont;
        
        Id memProgRecId = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
        
        Contract memContract = new Contract(Opportunity__c = null, AccountId = acct.id, recordTypeId = memProgRecId, Status='Draft', ContractTerm = 12);
        insert memContract;
        memContract.Status = 'Activated';
        update memContract;
        
        if(isCertified) {
            Id frmProgRecId = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');    
            
            Contract frmContract = new Contract(Opportunity__c = null, AccountId = acct.id, recordTypeId = frmProgRecId, Status='Draft', ContractTerm = 12);
            insert frmContract;
            frmContract.Status = 'Completed';
            update frmContract;
            
        }
        
        return cont;
        
    }
    
    public static GARP_BC_Registration.setRegistrationInfo setupSetRegistrationInfo(GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo, GARP_BC_Registration.programRegistrationInfo programRegistrationInfo,  GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo, GARP_BC_Registration.registrationFees registrationFees) {
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = new GARP_BC_Registration.setRegistrationInfo();
        
        setRegistrationInfo.customerInfo = new GARP_BC_Registration.orderCustomerInfo();
        setRegistrationInfo.customerInfo.FirstName = 'GARPQA';
        setRegistrationInfo.customerInfo.LastName = 'TEST';
        setRegistrationInfo.customerInfo.Email = 'garpqa@garpqa.com';
        setRegistrationInfo.customerInfo.Phone = '1234567890';
        setRegistrationInfo.customerInfo.LeadId = verifyExistingCustomerReturnInfo.leadId;
        setRegistrationInfo.customerInfo.ContactId = verifyExistingCustomerReturnInfo.contactId;
        setRegistrationInfo.customerInfo.AccountId = verifyExistingCustomerReturnInfo.accountId;
        
        setRegistrationInfo.paymentInfo = new GARP_BC_Orders.orderPaymentInfo();
        setRegistrationInfo.paymentInfo.paymentType = 'Credit Card';
        setRegistrationInfo.paymentInfo.CardNumber = '1234567890123456';
        setRegistrationInfo.paymentInfo.CCV = '123';
        setRegistrationInfo.paymentInfo.ExpireMonth = 1;
        setRegistrationInfo.paymentInfo.ExpireYear = system.today().addDays(365).year();
        
        setRegistrationInfo.paymentInfo.billingAddress = new GARP_Common.address();
        setRegistrationInfo.paymentInfo.billingAddress.country = 'United States';
        setRegistrationInfo.paymentInfo.billingAddress.province = 'New Jersey';
        setRegistrationInfo.paymentInfo.billingAddress.postalCode = '07310';
        setRegistrationInfo.paymentInfo.billingAddress.street1 = '111 Town Square Place';
        setRegistrationInfo.paymentInfo.billingAddress.city = 'JERSEY CITY';
        setRegistrationInfo.paymentInfo.billingAddress.phone = '1234567890';        
        
        setRegistrationInfo.addressInfo = new GARP_BC_Registration.addressInfo();
        setRegistrationInfo.addressInfo.billingAddress = new GARP_Common.address();
        setRegistrationInfo.addressInfo.billingAddress.country = 'United States';
        setRegistrationInfo.addressInfo.billingAddress.province = 'New Jersey';
        setRegistrationInfo.addressInfo.billingAddress.postalCode = '07310';
        setRegistrationInfo.addressInfo.billingAddress.street1 = '111 Town Square Place';
        setRegistrationInfo.addressInfo.billingAddress.city = 'JERSEY CITY';
        setRegistrationInfo.addressInfo.billingAddress.phone = '1234567890';
        setRegistrationInfo.addressInfo.billingAndShippingSame = true;
        
        setRegistrationInfo.captchaInfo = new GARP_BC_Registration.captchaInfo();
        setRegistrationInfo.personalInfo = new GARP_BC_Registration.orderPersonalInfo(); 
        
        setRegistrationInfo.programRegistrationInfo = programRegistrationInfo;
        
        setRegistrationInfo.teamRegInfo = null;
        
        setRegistrationInfo.consentInfo = new GARP_BC_Registration.consentInfo();        
        setRegistrationInfo.consentInfo.privacyPolicyAttestation = TRUE;
        setRegistrationInfo.consentInfo.examPolicyAttestation = TRUE;
        setRegistrationInfo.consentInfo.OSTAConsent = TRUE;
        setRegistrationInfo.consentInfo.valuableContentAttestation = TRUE;
        setRegistrationInfo.consentInfo.sponsorContentAttestation = TRUE;
        setRegistrationInfo.consentInfo.eppOutreachConsent = TRUE;
        
        setRegistrationInfo.membershipOptions = getRegistrationFeesInfo.membershipOptions;
        
        setRegistrationInfo.isEventBundleSelected = False;
        setRegistrationInfo.eventOptions = new GARP_BC_Events.eventOptions();     
        
        if(getRegistrationFeesInfo.examSelectionInfo != NULL) {
            setRegistrationInfo.examSelectionInfo = getRegistrationFeesInfo.examSelectionInfo;    
        }

        setRegistrationInfo.selectedProducts =  registrationFees.feeProductsForDisplay;
        setRegistrationInfo.studyMaterials = getRegistrationFeesInfo.studyMaterials;
    
        return setRegistrationInfo;
    }
    
    public static GARP_BC_Registration.createOrderInfo setupPayOrderInfo(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.registrationFees regFees, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo) {
        GARP_BC_Registration.createOrderInfo createOrderInfo = new GARP_BC_Registration.createOrderInfo();
        
        createOrderInfo.customerInfo = setRegistrationInfo.customerInfo;
        createOrderInfo.personalInfo = setRegistrationInfo.personalInfo;
        createOrderInfo.studyMaterials = setRegistrationInfo.studyMaterials;
        createOrderInfo.selectedProducts = regFees.feeProducts;
        createOrderInfo.membershipOptions = setRegistrationInfo.membershipOptions;
        createOrderInfo.captchaInfo = setRegistrationInfo.captchaInfo;
        //createOrderInfo.hasSelectedMembership = setRegistrationInfo.hasSelectedMembership;
        createOrderInfo.programRegistrationInfo = setRegistrationInfo.programRegistrationInfo;
        createOrderInfo.addressInfo = setRegistrationInfo.addressInfo;
        createOrderInfo.teamRegInfo = setRegistrationInfo.teamRegInfo;
        createOrderInfo.examSelectionInfo = setRegistrationInfo.examSelectionInfo;
        createOrderInfo.consentInfo = setRegistrationInfo.consentInfo;
        
        createOrderInfo.paymentInfo = setRegistrationInfo.paymentInfo;
        createOrderInfo.paymentInfo.existingOrderId = setRegistrationReturnInfo.orderId;
        createOrderInfo.customerInfo.accountId = setRegistrationReturnInfo.accountId;
        createOrderInfo.customerInfo.contactId = setRegistrationReturnInfo.contactId;
        
        return createOrderInfo;
    }
        
    public static GARP_BC_Registration.verifyExistingCustomerInfo setupVerifyExistingCustomerInfo() {
        return setupVerifyExistingCustomerInfo(null);
    }

    public static GARP_BC_Registration.verifyExistingCustomerInfo setupVerifyExistingCustomerInfo(GARP_BC_Registration.programRegistrationInfo programRegistrationInfo) {
        GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = new GARP_BC_Registration.verifyExistingCustomerInfo();
        
        verifyExistingCustomerInfo.firstName = 'GARPQA';
        verifyExistingCustomerInfo.lastName = 'TEST';
        verifyExistingCustomerInfo.email = 'garpqa@garpqa.com';
        verifyExistingCustomerInfo.leadId = NULL;
        verifyExistingCustomerInfo.formKey = (programRegistrationInfo != null && programRegistrationInfo.formName != null) ? programRegistrationInfo.formName : 'form';
        verifyExistingCustomerInfo.cta = NULL;
        verifyExistingCustomerInfo.allowMemberPublicRegistration = (programRegistrationInfo != null && programRegistrationInfo.allowMemberPublicRegistration != null) ? programRegistrationInfo.allowMemberPublicRegistration : TRUE;
        
        return verifyExistingCustomerInfo;
    }
        
    
    public static GARP_BC_Registration.getRegistrationFeesInfo setupGetFeesInfo(String paymentType, Boolean hasSelectedMembership, GARP_BC_Registration.getRegistrationInfo regInfo) {
        GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = new GARP_BC_Registration.getRegistrationFeesInfo();
        
        getRegistrationFeesInfo.programRegistrationInfo = regInfo.programRegistrationInfo;
        getRegistrationFeesInfo.paymentType = paymentType;
        getRegistrationFeesInfo.teamRegCode = null;
        
        getRegistrationFeesInfo.membershipOptions = new GARP_BC_Registration.membershipOptions();
        getRegistrationFeesInfo.membershipOptions.hasSelectedMembership = hasSelectedMembership;
        
        getRegistrationFeesInfo.isEventBundleSelected = False;
        
        getRegistrationFeesInfo.addressInfo = new GARP_BC_Registration.addressInfo();
        getRegistrationFeesInfo.addressInfo.billingAddress = new GARP_Common.address();
        getRegistrationFeesInfo.addressInfo.billingAddress.country = 'United States';
        getRegistrationFeesInfo.addressInfo.billingAddress.province = 'New Jersey';
        getRegistrationFeesInfo.addressInfo.billingAddress.postalCode = '07310';
        getRegistrationFeesInfo.addressInfo.billingAddress.street1 = '111 Town Square Place';
        getRegistrationFeesInfo.addressInfo.billingAddress.city = 'JERSEY CITY';
        getRegistrationFeesInfo.addressInfo.billingAddress.phone = '1234567890';
        getRegistrationFeesInfo.addressInfo.billingAndShippingSame = true;        
        
        if(regInfo.examSelectionInfo != NULL) {
            getRegistrationFeesInfo.examSelectionInfo = regInfo.examSelectionInfo;
            getRegistrationFeesInfo.examSelectionInfo.partSelected = regInfo.examSelectionInfo.partsAvailable[0];
            getRegistrationFeesInfo.examSelectionInfo.part1Info.selectedSiteId = regInfo.examSelectionInfo.part1Info.examAdmins[0].examSites[0].Id;        
            
            // Look for OSTA instead
            for(GARP_BC_Registration.examSiteInfo site :regInfo.examSelectionInfo.part1Info.examAdmins[0].examSites) {
                if(site.isOSTA) {
                    getRegistrationFeesInfo.examSelectionInfo.part1Info.selectedSiteId = site.Id;
                }
            }
        }
        
        // Select Study Materials
        if(regInfo.studyMaterials != NULL && regInfo.studyMaterials.size() > 0) {
            getRegistrationFeesInfo.studyMaterials = regInfo.studyMaterials;    
            for(GARP_BC_StudyMaterials.studyMaterial sm :getRegistrationFeesInfo.studyMaterials) {
                if(sm.isCompWithReg == False) {
                    sm.selected = True;
                    break;
                }
            }
        }      
        
        return getRegistrationFeesInfo;
    }

    public static List<String> getAuxProductList() {
        return new List<String>{'MEMFX:MEMFX:4040:100','MEMF:MEMF:4040:100','MEMI:MEMI:4040:100','MEMR:MEMR:4999:100','AFREE:AFREE:4999:100','MEMC:MEMC:4040:100','PRFEE:PRFEE:4040:100','CDNTAX:CDNTAX:4040:100','VATTAX:VATTAX:4040:100','SLSTX:SLSTX:4040:100'};
    }
    
    public static List<String> createProductList(String inProd) {
        List<String> outProdList = new List<String>();
        String newProd;
        
        String GLCode = '4040';
        if(inProd == 'FRM1') {
            GLCode = '4010';
        }
        
		newProd = inProd + ':' + inProd + ':' + GLCode + ':100';
        outProdList.add(newProd);
        return outProdList;
    }
    
    public static List<String> createProductList(List<String> inProdList) {
        List<String> outProdList = new List<String>();
        for(String prod :inProdList) {
            
            String GLCode = '4040';
            if(prod == 'FRM1') {
                GLCode = '4010';
            }
            
            String newProd = prod + ':' + prod + ':' + GLCode + ':100';
            outProdList.add(newProd);
        }
        return outProdList;
    }
    
    public static List<String> createProductList(List<String> inProdList, Decimal price) {
        List<String> outProdList = new List<String>();
        for(String prod :inProdList) {
            
            String GLCode = '4040';
            if(prod == 'FRM1') {
                GLCode = '4010';
            }
            
            String newProd = prod + ':' + prod + ':' + GLCode + ':' + price;
            outProdList.add(newProd);
        }
        return outProdList;
    }

    public static Map<String, Product2> createProducts(List<String> prods, Set<String> comped, Set<String> shipped, Set<String> studyMat) {
        Map<String, Product2> result = new Map<String, Product2>();
        Id pricebookId = Test.getStandardPricebookId();
        GARP_Common.debugLog('GARP_TestFactory','createProducts','pricebookId',pricebookId);
        
        Folder__c folder = new Folder__c(
            Name = 'Folder'
        );
        insert folder;
        
        MAP<String, Content__c> newMapContents = new MAP<String, Content__c>();
        MAP<String, Content_Folders__c> newMapContentFolders = new MAP<String, Content_Folders__c>();
        MAP<String, Product2> newMAPProducts = new MAP<String, Product2>();
        MAP<String, PricebookEntry> newMAPPBEs = new MAP<String, PricebookEntry>();
        
        for(String prod :prods) {
            
            System.debug('Loop prod:'+prod);
            
            List<String> parts = prod.split(':');
            
            String prodKey = parts[0];
            System.debug('prodKey:'+prodKey);
            
            Product2 prod2 = new Product2(Name = prodKey,productCode = parts[1],GL_Code__c = parts[2],isActive = true, Pre_Order_Date__c=Date.today().addDays(-1),Product_ID__c = '30', Tax_Rate__c = .01);
            if(comped.contains(parts[1])) {
                prod2.Is_Comped_Registration__c = True;
            } else {
                prod2.Is_Comped_Registration__c = False;
            }
            if(shipped.contains(parts[1])) {
                prod2.Is_Shippable__c = True;
            } else {
                prod2.Is_Shippable__c = False;
            }      
            prod2.Tax_Rate__c = 8;
            if(studyMat.contains(parts[1])) {
                Content__c newContent = new Content__c(
                    Name=prodKey,
                    Content_Name__c='book',
                    Description__c='blah',
                    Story__c='blah',
                    Image__c='http://www.garp.org/image',
                    Start_Date__c=Date.today().addDays(-1),
                    Status__c='Active'
                );
                //insert newContent;
               
                System.debug('Insert newContent:'+newContent);
                newMapContents.put(prodKey, newContent);
                
                //prod2.Content__c = newContent.id;
                
                Content_Folders__c cf = new Content_Folders__c(
                    Name = prodKey,
                    //Content__c = newContent.id,
                    Folder__c = folder.id
                );
                //insert cf;
                
                System.debug('Insert Content_Folders__c:'+cf);
                newMapContentFolders.put(prodKey, cf);
                
            }            
            System.debug('Insert prod2:'+prod2);
            //insert prod2;
            newMAPProducts.put(prodKey, prod2);
            
            PricebookEntry pe = new PricebookEntry(Product_ID__c=prodKey, Pricebook2Id = pricebookId, UnitPrice = Decimal.valueOf(parts[3]), IsActive = true);
            System.debug('Insert pe:'+pe);
            
            newMAPPBEs.put(prodKey,pe);
        }
        
        System.debug('newMapContents:'+newMapContents);
        System.debug('newMapContentFolders:'+newMapContentFolders);
        System.debug('newMAPProducts:'+newMAPProducts);
        System.debug('newMAPPBEs:'+newMAPPBEs);
        
        if(!newMapContents.IsEmpty()) {
            insert newMapContents.Values();
            for(Content__c c :newMapContents.Values()) {
                System.Debug('New Content:' + c);
            }
        }

        if(!newMapContentFolders.IsEmpty()) {    
            for(Content_Folders__c cf :newMapContentFolders.Values()) {
                Content__c fndContent = newMapContents.get(cf.Name);
                System.Debug('fndContent:' + fndContent);
                if(fndContent != NULL) {
                    cf.Content__c = fndContent.Id;
                }
                System.Debug('New Content Folder:' + cf);
            }
            insert newMapContentFolders.Values();
        }
        
        if(!newMAPProducts.IsEmpty()) {
            for(Product2 p :newMAPProducts.Values()) {
                Content__c fndContent = newMapContents.get(p.Name);
                System.Debug('fndContent:' + fndContent);
                if(fndContent != NULL) {
                    p.Content__c = fndContent.Id;
                }
                System.Debug('New Product2:' + p);
            }
            insert newMAPProducts.Values();
            for(Product2 p :newMAPProducts.Values()) {
                System.Debug('New Product2 After Insert:' + p);
            }
        }
        
        if(!newMAPPBEs.IsEmpty()) {
            
            for(PricebookEntry pbe :newMAPPBEs.Values()) {
                Product2 fndProduct2 = newMAPProducts.get(pbe.Product_ID__c);
                System.Debug('fndProduct2:' + fndProduct2);
                if(fndProduct2 != NULL) {
                    pbe.Product2Id = fndProduct2.Id;
                }
                System.Debug('New PricebookEntry:' + pbe);
            }
            insert newMAPPBEs.Values();
        }

        for (Product2 p : newMAPProducts.Values()) {
            result.put(p.ProductCode, p);
        }
        return result;
    }
    
    public static MAP<String,PricebookEntry> getPriceBooksEntries(List<String> productCodes) {
        MAP<String,PricebookEntry> mapProdByCodes = new MAP<String,PricebookEntry>();
               
        if(productCodes == NULL) {
            productCodes = new List<String>();
        }
        
        GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','productCodes',productCodes);

        for(String prod :productCodes) {
            GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','get prod',prod);
        }
        
        List<PricebookEntry> lstPricebookEntry = [
            SELECT ID, Pricebook2Id, Pricebook2.Name, Product2.Id, Product2.FRM_Exam__c, Product2.ERP_Exam__c, Product2.Name, Product2.ProductCode, 
            Product2.Content__c, Product2.Content__r.Content_Name__c, Product2.Content__r.Description__c, Product2.Content__r.Image__c,  Product2.Content__r.Story__c,  
            Product2.Content__r.Start_Date__c,Product2.Content__r.Third_Party_URL__c,Product2.Pre_Order_Shipping_Date__c,Product2.Pre_Order_Date__c,
            Product2.Invoice_Name__c,Product2.Product_ID__c,
            Product2.GL_Code__c, Product2.IsActive, Product2.Is_Shippable__c, Product2.Taxable__c, 
            Product2.Electronic_Delivery__c, Product2.Do_Not_Charge_VAT__c, Product2.Is_VAT_Tax__c,
            Product2.Is_Comped_Registration__c, Product2.Inventory__c,
            Product2.Weight__c, Pricebook2.IsActive, UnitPrice, UseStandardPrice 
            FROM PriceBookEntry 
            WHERE IsActive = TRUE AND Product2.ProductCode != NULL AND
            (Product2.ProductCode in :productCodes)
        ];
        GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','lstPricebookEntry',lstPricebookEntry);
        
        for(PricebookEntry pbe :lstPricebookEntry) {
            if(Test.isRunningTest() || pbe.Pricebook2.Name == 'GARP 2015/2016') {
                mapProdByCodes.put(pbe.Product2.ProductCode+':'+pbe.Product2.GL_Code__c, pbe);
                
                GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','Add mapProdByCodes',pbe.Product2.ProductCode+':'+pbe.Product2.GL_Code__c);
            }
        }
        GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','mapProdByCodes',mapProdByCodes);
        
        return mapProdByCodes;
    }
   
    @TestVisible private static Product2 createProduct(String name, String prodCode, String GLCode) {
        return new Product2(Name = name,productCode = prodCode,GL_Code__c = GLCode,isActive = true);        
    }
    
    @TestVisible private static PricebookEntry createPriceBook(String productId, Decimal price) {
        Id pricebookId = Test.getStandardPricebookId();
        return new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productId, UnitPrice = price, IsActive = true);
    }
    
    @TestVisible private static void createUnmatchedBusinessAccount() {
        Account acct = new Account(
            Name = 'UNMATCHED-BUSINESS-ACCOUNT'
        );
        insert acct;
        
        Default_Record_References__c setting = new Default_Record_References__c();
        setting.Name = 'UNMATCHED-BUSINESS-ACCOUNT';
        setting.Record_Reference_ID__c = acct.Id;
        insert setting;
    }
    
    @TestVisible private static void createCountryCodes() {
        
        Country_Code__c cc = new Country_Code__c(
            Name='US',
            PK_Country__c='227',
            Country__c='United States',
            PhoneCode__c='1',
            Currency__c='USD',
            LetterCode__c='US',
            RegionID__c='5',
            ISOCode__c='USA'
        );
        insert cc;
        
        Province__c pv = new Province__c(
            Name='New York',
            Country_Code__c=cc.id,
            Code__c='NY'
        );
        Province__c pv1 = new Province__c(
            Name='New Jersey',
            Country_Code__c=cc.id,
            Code__c='NJ'
        );
        insert pv1;
        
        Country_Code__c cc1 = new Country_Code__c(
            Name='CA',
            PK_Country__c='227',
            Country__c='Canada',
            PhoneCode__c='1',
            Currency__c='CAD',
            LetterCode__c='CA',
            RegionID__c='5',
            ISOCode__c='CAN'
        );
        insert cc1;
        
        Province__c pv2 = new Province__c(
            Name='Ontario',
            Country_Code__c=cc1.id,
            Code__c='OT'
        );
        insert pv2;
        
        Country_Code__c cc2 = new Country_Code__c(
            Name='SG',
            PK_Country__c='111',
            Country__c='Singapore',
            PhoneCode__c='32',
            Currency__c='USD',
            LetterCode__c='US',
            RegionID__c='5',
            ISOCode__c='SGA',
            VAT__c = 8,
            VAT_Product_Code__c = 'VATTAX'
        );
        insert cc2;
        
    }
    
    @TestVisible private static FAQ_Category__c createFAQs(String categoryName) {
        FAQ_Category__c faqCat = new FAQ_Category__c(
            Name = categoryName
        );
        insert faqCat;
        
        FAQ_Section__c faqSec = new FAQ_Section__c(
            Name = 'sec1',
            FAQ_Category__c = faqCat.Id, 
            Section_Order_Number__c = 1
        );
        insert faqSec;
        
        FAQ_Subsection__c faqSubSec = new FAQ_Subsection__c(
            Name = 'subsec1', 
            FAQ_Category__c = faqCat.Id, 
            FAQ_section__c = faqSec.Id, 
            Subsection_Order_Number__c = 1
        );
        insert faqSubSec;
        
        Frequently_Asked_Questions__c faq = new Frequently_Asked_Questions__c(
            Name = 'quest1', 
            GA_Label__c = 'quest1', 
            FAQ_Rank__c = 1, 
            FAQ_Question__c = 'quest?', 
            FAQ_Answer__c = 'answer.',
            FAQ_Category__c = faqCat.Id,
            FAQ_Section__c = faqSec.Id, 
            FAQ_Subsection__c = faqSubSec.Id
        );
        insert faq;
        
        return faqCat;
    }
    
    @TestVisible private static Form__c createForm(String formName) {
        Form__c form = new Form__c(
            Name = formName,
            Form_Name__c = formName
        );
        insert form;
        return form;
    }    
    
    @TestVisible
    private static Form_Data__c createFormData(Form__c newForm, Lead lead) {
        Form_Data__c fdata = new Form_Data__c();
        fdata.Form__c = newForm.id; 
        fdata.lead__c = lead.id;
        fdata.Email__c = lead.Email;
        fdata.Subscription__c = 'No';
        fdata.Last_Name__c = 'TestLname';
        fdata.First_Name__c = 'TestLname';
        fdata.Status__c ='Completed';
        fdata.Subscriptions__c = 'FRM Exam Updates';
        insert fdata;
        return fdata;
    }
    
    @TestVisible
    private static List<Shipping_Charge__c> createShippingRates(List<String> prods) {
        List<Country_Code__c> lstCC = [select Id from Country_Code__c];
        List<Shipping_Charge__c> newSCs = new List<Shipping_Charge__c>();
        for(Country_Code__c cc :lstCC) {
            for(String prod :prods) {
                List<String> parts = prod.split(':');
                Shipping_Charge__c sc = new Shipping_Charge__c(
                    Country_Code__c = cc.Id,
                    Shipping_Charge__c = 10,
                    Product_Code__c = parts[0],
                    GL_Code__c = parts[1]
                );
                newSCs.add(sc); 
            }
        }
        insert newSCs;
        return newSCs;
    }
    
    @TestVisible
    private static List<eBook_Key__c> createEbookKey(Opportunity Opp){
        List<eBook_Key__c> results=new List<eBook_Key__c>();
        List<String> TypeList = new List<String>{'FRM','FRM Exam Part I','FRM Exam Part II','SCR','FRR','FFR','RiskAI'};
        for(Integer counter=0; counter < TypeList.size(); counter++){
            eBook_Key__c record=new eBook_Key__c();
            record.Name= 'Test Key'+counter;
            record.Opportunity__c = opp.id;
            record.Key__c='23424refef1'+counter;
            record.Type__c = TypeList[counter];
            record.Access_Duration_in_Months__c=36;
            record.Cancelled__c = FALSE;
            record.Opportunity_1Assigned_Date__c = date.newInstance(2019, 3, 21);
            record.Product_ID__c = '2022SCRPE2022';
            record.Access_Expiration_Date__c = date.newInstance(2035, 3, 21);
            results.add(record);       
        }                          
        return results;            
    }
    
    @TestVisible
    private static List<Mobius_Products__c> createMobiusProducts( ){
        List<Mobius_Products__c> results = new List<Mobius_Products__c>();
        Integer numRecords=[Select count() from Opportunity_Product_Mapping__mdt];
        List<Opportunity_Product_Mapping__mdt> prodCodeResults=[Select MasterLabel from Opportunity_Product_Mapping__mdt];
        for(Integer counter=0;counter< numRecords; counter++){
            Mobius_Products__c record = new Mobius_Products__c();
            record.name = '2020 FRM Exam Part I Book 1'+counter;
            record.Year__c = '2020';
            record.Exam__c = 'FRM';
            record.Part__c = 'I';
            record.Product_Id__c = 52;
            record.Salesforce_Product_Code__c = prodCodeResults[counter].MasterLabel;
            record.Access_Duration_in_Months__c = 36;
            results.add(record);
        }
        return results; 
    }
    
     @TestVisible private static OpportunityLineItem createOrderIndiviWithOpp(String oppid, String productCode){
                
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE ProductCode = :productCode LIMIT 1];
        
        OpportunityLineItem affiliateMembershipOpportunityOli = new OpportunityLineItem( 
            OpportunityId       = oppid,                          
            PricebookEntryId    = pbe.Id,
            Product2Id          = pbe.Product2Id,
            UnitPrice           = 100,
            Quantity            = 1,
            Description         = 'Individual Membership'
        );
        
        return affiliateMembershipOpportunityOli;
    }
    
    @TestVisible private static List<Contract> createContractList(Integer TotalCount,String accountId,String opportunityId,String contactId){
        List<Contract> contractList = new List<Contract>();
        for(Integer i=0; i<TotalCount ; i++){
            contractList.add(new Contract(
                Name = 'Affiliate Membership',
                AccountId = accountId,
                Opportunity__c = opportunityId,
                CustomerSignedId = contactId,
                StartDate = System.Today(),
                ContractTerm = 12,
                Membership_Type__c = 'Affiliate',
                RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership')
            ));
        }
        INSERT contractList;
        return contractList;
    }
    
    @TestVisible private static Exam_Attempt__c createExamAttempt(Opportunity opp, Contract cont, String examtype){
        
        Site__c site = new Site__c(name = 'test',Display_Address__c = 'test',Is_OSTA_Information_Required__c = True,active__c = true,Non_selectable__c = false);
        insert site; 
        
        List<Exam_Group__c> lstExamGroups = [select id, Active__c, SCR_Active__c, recordTypeId from Exam_Group__c];
        
        Exam_Group__c objExamGrp;
        String examGroupRecordTypeId;
        String examRecType;
        if(examtype.ToLowerCase() == 'scr') {
            examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'SCR');
            examRecType = 'SCR';
        } else if(examtype.ToLowerCase() == 'riskai') {
            examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'RiskAI');
            examRecType = 'RiskAI';
        } else if(examtype.ToLowerCase() == 'frr') {
            examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRM/ERP');
            examRecType = 'ICBRR';
        } else if(examtype.ToLowerCase() == 'frr25') {
            examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRR25');
            examRecType = 'FRR25';
        } else if(examtype.ToLowerCase() == 'frrmc1') {
            examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'MicroCourse');
            examRecType = 'MicroCourse';
        } else if(examtype.ToLowerCase() == 'raij') {
            examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'RAIJ');
            examRecType = 'RAIJ';
        } else {
            examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRM/ERP');
            examRecType = 'FRM Part 1';
        }
        if(lstExamGroups.IsEmpty()) {
            objExamGrp = new Exam_Group__c();
            if(examtype.ToLowerCase() == 'scr') {
                objExamGrp.SCR_Active__c = true;
            } else {
                objExamGrp.Active__c = true;    
            }
            
            Date dt1 = system.today();
            objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
            objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
            objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
            objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;
            objExamGrp.RecordTypeId = examGroupRecordTypeId;
            insert objExamGrp;
        } else {
            objExamGrp = lstExamGroups[0];
            objExamGrp.Active__c = false;
            objExamGrp.SCR_Active__c = false;    
            if(examtype.ToLowerCase() == 'scr') {
                objExamGrp.SCR_Active__c = true;    
            } else {
                objExamGrp.Active__c = true;    
            }
            objExamGrp.RecordTypeId = examGroupRecordTypeId;
            update objExamGrp;
        }
        system.debug('objExamGrp:' + objExamGrp);
        
        List<Exam_Attempt__c> examattList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt;
        
        Exam__c exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = examRecType; 
        insert exam;
        
        Date tdy = system.today();
        
        if(examtype.ToLowerCase() == 'frm' || examtype.ToLowerCase() == 'scr' || examtype.ToLowerCase() == 'riskai' || examtype.ToLowerCase() == 'raij') {
            Exam_Administration__c examAdmin = new Exam_Administration__c();
            examAdmin.Exam_Group__c = objExamGrp.id;
            examAdmin.Exam_Admin_Modifications_Start_Date__c = tdy.addDays(-30);
            examAdmin.Exam_Admin_Modifications_End_Date__c = tdy.addDays(30);
            examAdmin.Exam_Scheduling_Start_Date__c = tdy.addDays(-30);
            examAdmin.Exam_Scheduling_End_Date__c = tdy.addDays(30);
            examAdmin.Exam_Type__c = examtype;
            examAdmin.Registration_Start_Date__c = tdy.addDays(-30);
            examAdmin.Registration_End_Date__c = tdy.addDays(30);
            examAdmin.Contingency_Administration__c = False;
            insert examAdmin;
            
            Exam_Part__c examPart = new Exam_Part__c();
            examPart.Exam__c = exam.id;
            examPart.Exam_Administration__c = examAdmin.id;
            examPart.Exam_Date__c = system.today();
            examPart.Delivery_Method__c = 'CBT';        
            insert examPart;
            
            Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,Exam_Part__c = examPart.id, exam__c = exam.id);
            insert exmSite;
            
            Exam_Registration_Window__c examRegistrationWindow = new Exam_Registration_Window__c(
                Exam_Group__c = objExamGrp.Id,
                Exam_Administration__c = examAdmin.Id,
                Type__c = 'Early',
                Exam_Registration_Window_Open__c = system.today().addDays(-30), 
                Exam_Registration_Window_Close__c = system.today().addDays(30)        
            );
            INSERT examRegistrationWindow;
            Product2 frmExamPart1StandardProduct = new Product2(
                Name = 'FRM PART 1 STANDARD REGISTRATION',
                Company__c = 'GARP', 
                ProductCode = 'FRM1S',
                GL_Code__c = '4999',
                Family = 'Exams',
                isActive = true
            );        
            INSERT frmExamPart1StandardProduct; 
            
            Pricebook2 activePricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = TRUE
            );
            
            UPDATE activePricebook;
            
            Id pricebookId = activePricebook.Id;
            
            PricebookEntry frmExamPart1StandardPricebookEntry = new PricebookEntry(
                Pricebook2Id = pricebookId, 
                Product2Id = frmExamPart1StandardProduct.Id, 
                UnitPrice = 350, 
                UseStandardPrice = FALSE,
                IsActive = true
            );
            INSERT frmExamPart1StandardPricebookEntry;
            
            Exam_Rate__c frmExamPart1ExamRate = new Exam_Rate__c(
                Exam_Registration_Window__c = examRegistrationWindow.Id,
                Exam__c = exam.Id,
                Product__c = frmExamPart1StandardProduct.Id,
                Exam_Administration__c = examAdmin.id,
                Exam_Part__c = examPart.Id,
                Rate_Type__c = 'Non-Member'
            );
            INSERT frmExamPart1ExamRate;
            
            attempt = new Exam_Attempt__c(Opportunity__c = opp.id, Result__c = 'Pass',
                                                          Exam_Part__c = examPart.Id,Exam_Site__c = exmSite.id,
                                                          Exam_Administration__c = examAdmin.id,Defered__c = 'Pending',
                                                          Member__c = cont.CustomerSignedId,Candidate_Commitment__c = cont.id,
                                                          cancelled__c = false,Original_Exam_Site__c ='Site',
                                                          Category_1__c='cat1', Quartile_1__c=1,
                                                          Category_2__c='cat1', Quartile_2__c=1,
                                                          Category_3__c='cat1', Quartile_3__c=1,
                                                          Category_4__c='cat1', Quartile_4__c=1,
                                                          Category_5__c='cat1', Quartile_5__c=1,
                                                          Category_6__c='cat1', Quartile_6__c=1,
                                                          Category_7__c='cat1', Quartile_7__c=1,
                                                          Category_8__c='cat1', Quartile_8__c=1,
                                                          Category_9__c='cat1', Quartile_9__c=1);
            examattList.add(attempt);
        } else {
            
            Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id, exam__c = exam.id);
            insert exmSite;
            
            attempt = new Exam_Attempt__c(Opportunity__c = opp.id,Exam_Site__c = exmSite.id, Result__c = 'Pass', 
                                                          Defered__c = 'Pending',
                                                          Member__c = cont.CustomerSignedId,Candidate_Commitment__c = cont.id,
                                                          cancelled__c = false,Original_Exam_Site__c ='Site',
                                                          Category_1__c='cat1', Quartile_1__c=1,
                                                          Category_2__c='cat1', Quartile_2__c=1,
                                                          Category_3__c='cat1', Quartile_3__c=1,
                                                          Category_4__c='cat1', Quartile_4__c=1,
                                                          Category_5__c='cat1', Quartile_5__c=1,
                                                          Category_6__c='cat1', Quartile_6__c=1,
                                                          Category_7__c='cat1', Quartile_7__c=1,
                                                          Category_8__c='cat1', Quartile_8__c=1,
                                                          Category_9__c='cat1', Quartile_9__c=1);
            examattList.add(attempt);
        }
        
        insert  examattList;

        return attempt;        
    }
    
    @TestVisible private static Exam_Attempt__c createExamAttemptPart2(Opportunity opp, Contract cont, String examGroupId, String examAdminId){
        
        Site__c site = new Site__c(name = 'test',Display_Address__c = 'test',Is_OSTA_Information_Required__c = True,active__c = true,Non_selectable__c = false);
        insert site; 
        
        List<Exam_Attempt__c> examattList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt;
        
        Exam__c exam = new Exam__c();
        exam.Exam_Group__c = examGroupId;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c =  'FRM Part 2'; 
        insert exam;
        
        Exam_Part__c examPart = new Exam_Part__c();
        examPart.Exam__c = exam.id;
        examPart.Exam_Administration__c = examAdminId;
        examPart.Exam_Date__c = system.today();
        examPart.Delivery_Method__c = 'CBT';        
        insert examPart;
            
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,Exam_Part__c = examPart.id, exam__c = exam.id);
        insert exmSite;
            
        Exam_Registration_Window__c examRegistrationWindow = new Exam_Registration_Window__c(
            Exam_Group__c = examGroupId,
            Exam_Administration__c = examAdminId,
            Type__c = 'Early',
            Exam_Registration_Window_Open__c = system.today().addDays(-30), 
            Exam_Registration_Window_Close__c = system.today().addDays(30)        
        );
        
        INSERT examRegistrationWindow;
        Product2 frmExamPart2StandardProduct = new Product2(
            Name = 'FRM PART 2 STANDARD REGISTRATION',
            Company__c = 'GARP', 
            ProductCode = 'FRM2S',
            GL_Code__c = '4999',
            Family = 'Exams',
            isActive = true
        );        
        INSERT frmExamPart2StandardProduct; 
            
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;
        
        Id pricebookId = activePricebook.Id;
        
        PricebookEntry frmExamPart2StandardPricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = frmExamPart2StandardProduct.Id, 
            UnitPrice = 350, 
            UseStandardPrice = FALSE,
            IsActive = true
        );
        INSERT frmExamPart2StandardPricebookEntry;
        
        Exam_Rate__c frmExamPart2ExamRate = new Exam_Rate__c(
            Exam_Registration_Window__c = examRegistrationWindow.Id,
            Exam__c = exam.Id,
            Product__c = frmExamPart2StandardProduct.Id,
            Exam_Administration__c = examAdminId,
            Exam_Part__c = examPart.Id,
            Rate_Type__c = 'Non-Member'
        );
        INSERT frmExamPart2ExamRate;
        
        attempt = new Exam_Attempt__c(Opportunity__c = opp.id, Result__c = 'Pass',
                                      Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,
                                      Exam_Administration__c = examAdminId, Defered__c = 'Pending',
                                      Member__c = cont.CustomerSignedId, Candidate_Commitment__c = cont.id,
                                      cancelled__c = false, Original_Exam_Site__c ='Site',
                                      Category_1__c='cat1', Quartile_1__c=1,
                                      Category_2__c='cat1', Quartile_2__c=1,
                                      Category_3__c='cat1', Quartile_3__c=1,
                                      Category_4__c='cat1', Quartile_4__c=1,
                                      Category_5__c='cat1', Quartile_5__c=1,
                                      Category_6__c='cat1', Quartile_6__c=1,
                                      Category_7__c='cat1', Quartile_7__c=1,
                                      Category_8__c='cat1', Quartile_8__c=1,
                                      Category_9__c='cat1', Quartile_9__c=1);
        examattList.add(attempt);
        
        insert  examattList;

        return attempt;        
    }
    
    @TestVisible private static Candidate_Requirement__c createCandidateCommitment(Contract contract,String Exam,id recordType){
        
        Candidate_Requirement__c cr = new Candidate_Requirement__c(Candidate_Commitment__c=contract.Id, Exam__c = Exam,Name='CommitName'+Exam, Status__c='Active', recordTypeId=recordType);
        insert cr;
        return cr;
        
    }
    
    @TestVisible private static void createCampaign(Form__c formData, Lead ld){

        Campaign camp = new Campaign();
        camp.Name = 'Testcampaign';
        camp.IsActive = TRUE;
        camp.Status = 'In Progress';
        camp.Conversion_Form__c = formData.id;
        insert ( camp );
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId  = camp.id;
        cm.leadid = ld.id;
        insert cm;
    }

    @TestVisible private static void createCommunityUser(contact con){
       
        Id profileId1 = [select id from profile where name=: 'Customer Community'].id;
        
       
        User communityUser = new User(alias = 'comUser'
                                      ,email = 'testCommunityUsermig123@test.com'
                                      ,emailencodingkey='UTF-8'
                                      ,lastname = 'Batman'
                                      ,languagelocalekey='en_US'
                                      ,localesidkey='en_US'
                                      ,profileid = profileId1
                                      ,country = 'France'
                                      ,IsActive = true
                                      ,ContactId = con.Id
                                      ,timezonesidkey='America/Los_Angeles'
                                      ,username = 'testCommunityUsermig123@test.com');
        insert communityUser;
    
    }    
    
    public static void createMemberNotifications(String contactId) {
        Member_Notification__c mn = new Member_Notification__c(
            Name = 'notify',
            Subject__c = 'Hello',
            Template__c = 'abc',
            Status__c = 'Sent',
            Show_In_Portal__c = True,
            Type__c = 'Exam',
            Expire_Date__c = Date.Today().AddDays(30)
        );
        insert mn;
        
        Member_Notification_Recipient__c mnr = new Member_Notification_Recipient__c(
            Contact__c = contactId,
            Name = 'joe',
            Email__c = 'joe@joe.com',
            GARP_ID__c = '123',
            Sending_Status__c = 'Sent',
            Sent_Date_Time__c = Date.Today().AddDays(-1),
            Sent_Message__c = 'Hello',
            Is_Viewed_In_Portal__c = False
        );
        
        insert mnr;
    }
    
    public static void createMemberOffers() {
        
        Membership_Exclusive_Offers__c mo = new Membership_Exclusive_Offers__c(
            Name = 'offer',
            Memb_Offer_Logo__c = 'https://www.garp.org/images/offer.jpg',
            Authenticated_Description__c = 'offer',
            Authenticated_Affiliate_Can_Use_Offer__c = True,
            Non_Member_Description__c = 'blah blah...',
            Non_US_Description__c = 'blah blah...',
            Member_Description__c = 'blah blah...',
            Memb_Offer_Promo_Code__c = '1234',
            External_Link_Name__c = 'Link',
            Memb_Offer_External_Link__c = 'https://www.site.org/abc',
            Memb_Offer_Status__c = 'Active'
        );
        insert mo;
    }
    
    public static String createCPDContract(String contactId, String AccountId, String oppId) {
        Contract cpdContract = new Contract(
            AccountId = AccountId,
            Opportunity__c = oppId,
            CustomerSignedId = contactId,
            StartDate = Date.Today().AddDays(-30),
            ContractTerm=24,
            RecordTypeId=RecordTypeHelper.GetRecordTypeId('Contract','CPE')
        );
        insert cpdContract;
        
        Candidate_Requirement__c cpdReq = new Candidate_Requirement__c(
            Candidate_Commitment__c = cpdContract.Id,
            Name = 'CPE',
            Status__c = 'Initial',
            CPE_Credit_Requirement__c = 20,
            RecordTypeId=RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE')
        );
        
        insert cpdReq;
        
        Candidate_Requirement__c cpdReq1 = new Candidate_Requirement__c(
            Candidate_Commitment__c = cpdContract.Id,
            Name = 'Attest',
            Status__c = 'Initial',
            RecordTypeId=RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Attest')
        );
        
        insert cpdReq1;


        cpdContract.Status = 'Activated';
        update cpdContract;
        
        return cpdReq.Id;
    }
    
    public static CPE_Claim__c createCPDClaim(String progReqId) {
        CPE_Activity_Type__c actType = new CPE_Activity_Type__c(Name='Training Course', Active__c = True);
        insert actType;
        
        CPE_Claim__c claim = new CPE_Claim__c (Candidate_Requirement__c = progReqId, 
                                               Credits_Earned__c =40, Approved__c  = True, 
                                               ApprovedCredits__c = 40, 
                                               CPE_Activity_Type__c = actType.Id,
                                               Date_of_Completion__c = Date.Today().addDays(-30));
        insert claim; 
        
        return claim;
    }
    
    public static void createCPDActivities() {
        
        CPE_Activity_Type__c actType = new CPE_Activity_Type__c(Name='Reading Book', Active__c = True);
        insert actType;
        
        CPE_Activity__c ca = new CPE_Activity__c(
            Name = 'activity',
            Title__c = 'activity',
            Description__c = 'blah...',
            Status__c = 'Active',
            Location__c = 'NY',
            Start_Date__c = Date.Today().AddDays(-30),
            End_Date__c = Date.Today().AddDays(30),
            CPE_Activity_Type__c = actType.Id,
            Area_of_Study__c = 'Credit Risk',
            Credit__c = 5,
            Activity_Date__c = Date.Today(),
            Date_Description__c = 'Today',
            Organization__c = 'GARP',
            Provider__c = 'GARP',
            Publication__c = 'NY Times',
            URL__c = 'https://www.site.com/abc'            
        );
        insert ca;
    }
    
    public static Contract createProgramContract(String contactId, String accountId, String recTypeName) {
        Id progRecId = RecordTypeHelper.GetRecordTypeId('Contract',recTypeName);    
        
        Contract contract = new Contract(Opportunity__c = null, 
                                            AccountId = accountId, 
                                            recordTypeId = progRecId, 
                                            Status='Draft', 
                                            StartDate=Date.Today().AddDays(-30),
                                            ContractTerm = 12,
                                            CustomerSignedId = contactId);
        insert contract;
        
        return contract;
    }
    
    public static void createExamGroupForStudyMats(String folderId) {
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10;    
        objExamGrp.FRM_Study_Materials_Folder__c = folderId;
        objExamGrp.SCR_Study_Materials_Folder__c = folderId;
        objExamGrp.FRR_Study_Materials_Folder__c = folderId;
        insert objExamGrp;
    }

    /**
     * Query program contracts for an account by Contract record type name.
     * Uses same record type names as GARP_BC_Courses (e.g. 'ICBRR Program', 'FRR25 Program', 'FBR Program', 'SCR Program', 'Risk AI Program', 'RAIJ Program', 'FRR MC1 Program').
     * Excludes Canceled contracts so the newly created registration contract is returned.
     */
    public static List<Contract> getProgramContracts(Id accountId, String contractRecordTypeName) {
        if (accountId == null || String.isBlank(contractRecordTypeName)) {
            return new List<Contract>();
        }
        Id rtId = RecordTypeHelper.GetRecordTypeId('Contract', contractRecordTypeName);
        return [SELECT Id, RecordTypeId, RecordType.Name, AccountId, Status
                FROM Contract
                WHERE AccountId = :accountId
                  AND RecordTypeId = :rtId
                  AND Status != 'Canceled'
                ORDER BY CreatedDate DESC];
    }

    /**
     * Assert that the account has at least one program contract of the given record type after registration.
     * Use after setRegistration() to verify the registrant has the expected program contract.
     */
    public static void assertRegistrationCreatedProgramContract(Id accountId, String contractRecordTypeName) {
        List<Contract> contracts = getProgramContracts(accountId, contractRecordTypeName);
        System.assert(!contracts.isEmpty(),
            'Expected account to have a Contract with record type "' + contractRecordTypeName + '" after registration. Found: ' + contracts.size());
        System.assertEquals(contractRecordTypeName, contracts[0].RecordType.Name,
            'Contract record type name should match expected program.');
    }

    /**
     * Assert that the contract has a Candidate_Requirement__c (Exam record type) with the expected Exam__c.
     * Use after setRegistration() for course/contract types that create a program requirement (FRR->ICBRR, FRR25->FRR25, FFR->FBR, Micro->courseCode).
     * @param accountId Account id from setRegistrationReturnInfo.accountId
     * @param contractRecordTypeName Contract record type name, e.g. 'FRR25 Program', 'FBR Program', 'FRR MC1 Program', 'ICBRR Program'
     * @param expectedExamCode Expected Candidate_Requirement__c.Exam__c: 'FRR25', 'FBR', 'ICBRR', or micro course code e.g. 'FRRMC1'
     */
    public static void assertRegistrationCreatedCandidateRequirementExamCode(Id accountId, String contractRecordTypeName, String expectedExamCode) {
        List<Contract> contracts = getProgramContracts(accountId, contractRecordTypeName);
        System.assert(!contracts.isEmpty(),
            'Expected account to have a Contract with record type "' + contractRecordTypeName + '" before checking Candidate_Requirement.');
        Set<Id> contractIds = new Set<Id>();
        for (Contract c : contracts) { contractIds.add(c.Id); }
        List<Candidate_Requirement__c> reqs = [SELECT Id, Exam__c FROM Candidate_Requirement__c WHERE Candidate_Commitment__c IN :contractIds];
        System.assert(!reqs.isEmpty(),
            'Expected at least one Candidate_Requirement__c for contract(s) with record type "' + contractRecordTypeName + '". Found: ' + reqs.size());
        System.assertEquals(expectedExamCode, reqs[0].Exam__c,
            'Candidate_Requirement__c.Exam__c should be "' + expectedExamCode + '". Got: ' + reqs[0].Exam__c);
    }

    /**
     * Assert that the Opportunity has at least one line item with the given main product code (Product2.ProductCode).
     * Use after setRegistration() to verify the order was built with the correct main product (e.g. FRR25 public = FRRSNM, FRR25 Auth = FRRSM).
     * @param opportunityId Order (Opportunity) id from setRegistrationReturnInfo.orderId (or Exam_Attempt__c.Opportunity__c)
     * @param expectedProductCode Expected Product2.ProductCode on an OpportunityLineItem, e.g. 'FRRSNM', 'FRRSM'
     */
    public static void assertRegistrationOpportunityHasMainProduct(Id opportunityId, String expectedProductCode) {
        List<OpportunityLineItem> lineItems = [SELECT Id, Product2.ProductCode FROM OpportunityLineItem WHERE OpportunityId = :opportunityId AND Product2.ProductCode = :expectedProductCode];
        System.assert(!lineItems.isEmpty(),
            'Expected Opportunity ' + opportunityId + ' to have at least one line item with ProductCode "' + expectedProductCode + '". Found: ' + lineItems.size());
    }

    /**
     * Assert that the registration created an Exam_Attempt__c with the expected RPT_Exam_Program__c and RecordType.
     * Use after setRegistration() to verify combined exam registration logic set the program and record type correctly.
     * @param opportunityId Order (Opportunity) id from setRegistrationReturnInfo.orderId
     * @param expectedRPT_Exam_Program Expected RPT_Exam_Program__c and RecordType.Name: 'SCR', 'RAIJ', 'RiskAI', or 'FRR25'
     */
    public static void assertRegistrationCreatedExamAttemptProgram(Id opportunityId, String expectedRPT_Exam_Program) {
        List<Exam_Attempt__c> attempts = [SELECT Id, RPT_Exam_Program__c, RecordType.Name FROM Exam_Attempt__c WHERE Opportunity__c = :opportunityId];
        System.assert(!attempts.isEmpty(),
            'Expected at least one Exam_Attempt__c for Opportunity ' + opportunityId + ' after registration. Found: ' + attempts.size());
        System.assertEquals(expectedRPT_Exam_Program, attempts[0].RPT_Exam_Program__c,
            'Exam_Attempt__c.RPT_Exam_Program__c should be "' + expectedRPT_Exam_Program + '". Got: ' + attempts[0].RPT_Exam_Program__c);
        System.assertEquals(expectedRPT_Exam_Program, attempts[0].RecordType.Name,
            'Exam_Attempt__c RecordType.Name should be "' + expectedRPT_Exam_Program + '". Got: ' + attempts[0].RecordType.Name);
    }

}