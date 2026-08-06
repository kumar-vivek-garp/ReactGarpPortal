@isTest
public class GARP_Membership_test {
    public static Account account;
    public static Contact contact;
    public static User user;
    public static Profile profile;
    public static Opportunity opp;
    
    public static void setup(){
        //'FRM1E','FRM1S','FRM2E','FRM2S', 'FRM1H','FRM1X','FRM2H','FRM2X','FRMC1','FRMC2'
        List<String> prodsFRM = new List<String>{'AFREE:AFREE:4040:100','MEMI:MEMI:4040:100','MEMC:MEMC:4040:100','FRM1E:FRM1E:4040:100','FRM1S:FRM1S:4040:100','FRM2E:FRM2E:4040:100','FRM2S:FRM2S:4040:100' ,'FRM1H:FRM1H:4040:100','FRM1X:FRM1X:4040:100','FRM2H:FRM2H:4040:100','FRM2X:FRM2X:4040:100','FRMC1:FRMC1:4040:100','FRMC2:FRMC2:4040:100','SHIP:SHIP:4040:100'};
        GARP_TestFactory.createProducts(prodsFRM, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        GARP_TestFactory.createCountryCodes();
        contact = GARP_TestFactory.createMember('garpqamem@garpqa.com', True);
        
        //ACCOUNT OWNER
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX'); 

        //user =  GARP_TestFactory.createAffiliateContact();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        user = new User(Alias = uid, Email= uid + '@garpqa.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@garpqa.com');      
        insert user;
        System.debug('~~~USER:' + user);
    }
    
    public static void setupMemberSearch(){
        account = new Account(Name = 'test');
        INSERT account;
        
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(
            GARP_Dir_Privacy_Additional_Detail__c = true,
            GARP_Dir_Privacy_Job_Information__c = true,
            GARP_Dir_Privacy_Prof_Background__c = false,
            KPI_ERP_Certified__c = true,
            Corporate_Title__c='garp',
            KPI_FRM_Certified__c = true,
            GARP_Directory_Opt_In__c = true,
            lastname = 'CONTACTONE',
            AccountId = account.id,
            email='daghtes12t@test.com',
            KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),
            Name_As_it_Appears_On_ID__c = 'testtest',
            ID_Number__c = 'dasf123l',
            ID_Type__c = 'Passport',
            Area_of_Concentration__c = 'Individual',
            Professional_Designation_CA__c = true,
            Professional_Designation_CFA__c = true,
            Professional_Designation_CMA__c = true,
            Professional_Designation_CPA__c = true,
            Professional_Designation_Other__c = true,
            Professional_Designation_PMP__c = true,
            Professional_Designation_ACCA__c = true,
            KPI_CPE_Current_Cycle__c = 'test',
            KPI_CPE_Last_Completed_Cycle__c = 'test',
            KPI_CPE_Requirement_Status__c = 'test'
        ));
        
        contacts.add(new Contact(
            GARP_Dir_Privacy_Additional_Detail__c = true,
            GARP_Dir_Privacy_Job_Information__c = false,
            GARP_Dir_Privacy_Prof_Background__c = true,
            KPI_ERP_Certified__c = true,
            Corporate_Title__c='garp',
            KPI_FRM_Certified__c = true,
            GARP_Directory_Opt_In__c = true,
            lastname = 'CONTACTTWO',
            AccountId = account.id,
            email='daghtes12t@test.com',
            KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),
            Name_As_it_Appears_On_ID__c = 'testtest',
            ID_Number__c = 'dasf123l',
            ID_Type__c = 'Passport',
            Area_of_Concentration__c = 'Individual',
            Professional_Designation_CA__c = true,
            Professional_Designation_CFA__c = true,
            Professional_Designation_CMA__c = true,
            Professional_Designation_CPA__c = true,
            Professional_Designation_Other__c = true,
            Professional_Designation_PMP__c = true,
            Professional_Designation_ACCA__c = true,
            KPI_CPE_Current_Cycle__c = 'test',
            KPI_CPE_Last_Completed_Cycle__c = 'test',
            KPI_CPE_Requirement_Status__c = 'test'
        ));
        
        contacts.add(new Contact(
            GARP_Dir_Privacy_Additional_Detail__c = false,
            GARP_Dir_Privacy_Job_Information__c = true,
            GARP_Dir_Privacy_Prof_Background__c = true,
            KPI_ERP_Certified__c = true,
            Corporate_Title__c='garp',
            KPI_FRM_Certified__c = true,
            GARP_Directory_Opt_In__c = true,
            lastname = 'CONTACTTHREE',
            AccountId = account.id,
            email='daghtes12t@test.com',
            KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),
            Name_As_it_Appears_On_ID__c = 'testtest',
            ID_Number__c = 'dasf123l',
            ID_Type__c = 'Passport',
            Area_of_Concentration__c = 'Individual',
            Professional_Designation_CA__c = true,
            Professional_Designation_CFA__c = true,
            Professional_Designation_CMA__c = true,
            Professional_Designation_CPA__c = true,
            Professional_Designation_Other__c = true,
            Professional_Designation_PMP__c = true,
            Professional_Designation_ACCA__c = true,
            KPI_CPE_Current_Cycle__c = 'test',
            KPI_CPE_Last_Completed_Cycle__c = 'test',
            KPI_CPE_Requirement_Status__c = 'test'
        ));
        
        INSERT contacts;
        
        profile = [SELECT Id FROM Profile WHERE usertype = 'CspLitePortal' limit 1]; 
    }
    
    @isTest
    public static void testMS(){
        sfdcAppRemoter ctrl = new sfdcAppRemoter();
        GARP_MS_Membership gmsmem = new GARP_MS_Membership(ctrl);
    }

    @isTest
    public static void testMemberDirectory1(){
        setup();
        setupMemberSearch();

        test.startTest();
       
        System.runAs(user){
            EmailTemplate template = new EmailTemplate (developerName = 'test',HtmlValue='{!Contact.GARP_ID__c}',Body='{!Contact.GARP_ID__c}',
                                          Subject='test subject',isActive = true, FolderId = user.id, 
                                          TemplateType= 'Text', Name = 'test');
            insert template;
        
            
            GARP_BC_Membership.sendMemberMessageInfo mi = new GARP_BC_Membership.sendMemberMessageInfo();
            mi.recipientContactId = contact.Id;
            mi.messageType = 'Directory_Connect_Invite';
            mi.message = 'Hello!';
            
            GARP_BC_Membership.sendDirectoryMessage(contact, TRUE, mi);
        }
        test.stopTest();
    }
    
    @isTest
    public static void testMemberDirectory2(){
        setup();
        setupMemberSearch();
        
        test.startTest();
        //GARP_MS_Membership.searchMembers(FALSE,FALSE,FALSE,'CONTACT', '', '','', '', '', 'lastname', 'DESC', 1, 1);
        //GARP_MS_Membership.searchMembers(TRUE,TRUE,FALSE,'CONTACTONE', '', '','Credit Risk', '', '', 'lastname', 'DESC', 1, 1);
        //GARP_MS_Membership.searchMembers(TRUE,FALSE,FALSE,'CONTACTTWO', '', '','Credit Risk', '', '', 'lastname', 'DESC', 1, 1);
        //GARP_MS_Membership.searchMembers(TRUE,TRUE,FALSE,'CONTACTTHREE', '', '','Credit Risk', '', '', 'lastname', 'DESC', 1, 1);
        //GARP_MS_Membership.searchMembers(TRUE,FALSE,FALSE,'OTHER', '', '','Credit Risk', '', '', 'lastname', 'DESC', 10, 1);
        //GARP_MS_Membership.searchMembers(TRUE,TRUE,FALSE,'UNKNOWN', '', '','Credit Risk', '', '', 'lastname', 'DESC', 1, 1);

        //GARP_MS_Membership.searchMembers(FALSE,FALSE,FALSE,'CONTACT', 'Individual', 'Consulting','', 'Associate', '', 'lastname', 'DESC', 1, 1);

        test.stopTest();
    }

    // Registration Tests 
        
    public static void runTestIndividualMembershipReg() {
        setup();
        setupMemberSearch();
        test.startTest();
        GARP_MS_Membership.getMembershipRegistrationInfo(NULL);
        GARP_BC_Membership.membershipInfo membershipInfo = GARP_BC_Membership.getmembershipInfo(contact.Id);
        GARP_BC_Registration.orderCustomerInfo orderCustInfo = new GARP_BC_Registration.orderCustomerInfo();
        orderCustInfo.firstName = 'Bob';
        orderCustInfo.lastName = 'Bob';
        orderCustInfo.contactId = contact.Id;
        orderCustInfo.accountId = contact.AccountId;
        orderCustInfo.phone = '1234567890';
        orderCustInfo.mobilePhone = '1234567890';
        orderCustInfo.mobilePhoneCode = 'United States (+1)';
        GARP_BC_Registration.orderPersonalInfo personalInfo = new GARP_BC_Registration.orderPersonalInfo();
        personalInfo.company = 'Company';
        personalInfo.idNumber = '123';
        personalInfo.ostaConsent = True;
        personalInfo.dateOfBirth = String.valueof(System.today());
        personalInfo.idExpireDate = String.valueof(System.today());
        GARP_Common.address addr = new GARP_Common.address();
        addr.country = 'United States';
        addr.province = 'New Jersey';
        addr.postalCode = '07310';
        addr.street1 = '111 Town Square Place';
        addr.street2 = '14th Floor';
        addr.street3 = 'In the back';
        addr.city = 'JERSEY CITY';
        addr.phone = '1234567890';
        GARP_BC_Membership.createMembershipAccount(user, contact, orderCustInfo, addr);
        Contact con = GARP_BC_Membership.updateNonMembershipContact(contact.Id, user, orderCustInfo, personalInfo, addr);
        GARP_BC_Membership.updateMembershipContact(contact.Id, user, orderCustInfo, personalInfo, addr);
        GARP_BC_Membership.updateMembershipAccount(con.AccountId, user, contact, orderCustInfo, addr);
        opp = GARP_TestFactory.createOrder(con.AccountId, con.id, 'MEMC');
        GARP_BC_Membership.hasCompedMembership(account.Id);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = new GARP_BC_Registration.setRegistrationInfo();
        setRegistrationInfo.customerInfo = orderCustInfo;
        setRegistrationInfo.paymentInfo = new GARP_BC_Orders.orderPaymentInfo();
        setRegistrationInfo.paymentInfo.paymentType = 'Credit Card';
        setRegistrationInfo.paymentInfo.billingAddress = new GARP_Common.address();
        setRegistrationInfo.paymentInfo.billingAddress.country = 'United States';
        setRegistrationInfo.paymentInfo.billingAddress.province = 'New Jersey';
        setRegistrationInfo.paymentInfo.billingAddress.postalCode = '07310';
        setRegistrationInfo.paymentInfo.billingAddress.street1 = '111 Town Square Place';
        setRegistrationInfo.paymentInfo.billingAddress.city = 'JERSEY CITY';
        setRegistrationInfo.paymentInfo.billingAddress.phone = '1234567890';
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = new GARP_BC_Registration.setRegistrationReturnInfo();
        setRegistrationReturnInfo.accountId = contact.AccountId;
        setRegistrationReturnInfo.contactId = contact.Id;
        GARP_BC_Membership.createRiskNetContract(setRegistrationInfo, setRegistrationReturnInfo, 'AFREE', membershipInfo);
        opp.Payment_Status__c = 'Recurring';
        update opp;
        setRegistrationReturnInfo.orderId = opp.Id;
        GARP_BC_Membership.createMembershipContract(setRegistrationInfo, setRegistrationReturnInfo, 'AFREE', membershipInfo);
        Contract cont = GARP_BC_Membership.createMembershipContract(setRegistrationInfo, setRegistrationReturnInfo, 'MEMI', membershipInfo);
        GARP_BC_Membership.createMembershipContract(setRegistrationInfo, setRegistrationReturnInfo, 'MEMC', membershipInfo);
        cont.Status = 'Draft';
        insert cont;
        cont.Status = 'Activated ( Auto-Renew )';
        update cont;
        GARP_StripeSettings__c ss1 = new GARP_StripeSettings__c(Name = 'StripeSettingsXX', Is_Active__c = true, Use_Stripe__c = true, Server_Side_API_Key__c = 'test', Client_Side_API_Key__c = 'testclientkey');
        insert ss1;
        GARP_BC_Membership.turnOffAutoRenewal(contact.AccountId, cont);
        GARP_BC_Membership.enableAutoRenew(user, contact, cont, False);
        GARP_BC_Membership.searchParams searchParams = new GARP_BC_Membership.searchParams();
        searchParams.searchText = 'test';
        searchParams.FRMOnly = TRUE;
        searchParams.industries = 'Individual';
        searchParams.jobFunctions = 'Research';
        searchParams.riskSpecialties = 'Market Risk';
        searchParams.corporateTitles = 'garp';
        searchParams.company = 'test';
        searchParams.pageSize = 1;
        searchParams.pageCurrent = 1;
        Member_Profile_Summary__c mps = new Member_Profile_Summary__c();
        mps.FRR_Attempts__c = 2;
        mps.FRM_Completed__c = TRUE;
        insert mps;
        contact = [SELECT Id, AccountId, GARP_ID_New__c, Company__c, GARP_Directory_Opt_In__c FROM Contact WHERE GARP_Directory_Opt_In__c = true LIMIT 1];
        contact.Company__c = 'test';
        contact.Risk_Specialty__c = 'Market Risk';
        contact.Job_Function__c = 'Research';
        contact.Member_Profile_Summary__c = mps.id;
        contact.MailingCity = 'test';
        update contact;
        GARP_BC_Membership.searchMembers(contact.id, searchParams, TRUE);
        searchParams.ERPOnly = TRUE;
        searchParams.SCROnly = TRUE;
        GARP_BC_Membership.searchMembers(contact.id, searchParams, FALSE);
        test.stopTest();
    }

    @isTest
    public static void testIndividualMembershipReg() { runTestIndividualMembershipReg(); }

    public static void runTestAffiliateMembershipReg() {
        setup();
        setupMemberSearch();
        test.startTest();
        GARP_MS_Membership.getAffiliateMembershipRegistrationInfo();
        GARP_BC_Membership.membershipInfo membershipInfo = GARP_BC_Membership.getmembershipInfo(contact.Id);
        GARP_BC_Registration.orderCustomerInfo orderCustInfo = new GARP_BC_Registration.orderCustomerInfo();
        orderCustInfo.firstName = 'Bob';
        orderCustInfo.lastName = 'Bob';
        orderCustInfo.contactId = contact.Id;
        orderCustInfo.accountId = contact.AccountId;
        orderCustInfo.phone = '1234567890';
        orderCustInfo.mobilePhone = '1234567890';
        orderCustInfo.mobilePhoneCode = 'United States (+1)';
        GARP_BC_Registration.orderPersonalInfo personalInfo = new GARP_BC_Registration.orderPersonalInfo();
        personalInfo.company = 'Company';
        personalInfo.idNumber = '123';
        personalInfo.ostaConsent = True;
        personalInfo.dateOfBirth = String.valueof(System.today());
        personalInfo.idExpireDate = String.valueof(System.today());
        GARP_Common.address addr = new GARP_Common.address();
        addr.country = 'United States';
        addr.province = 'New Jersey';
        addr.postalCode = '07310';
        addr.street1 = '111 Town Square Place';
        addr.street2 = '14th Floor';
        addr.city = 'JERSEY CITY';
        addr.phone = '1234567890';
        GARP_BC_Membership.createMembershipAccount(user, contact, orderCustInfo, addr);
        Contact con = GARP_BC_Membership.updateNonMembershipContact(contact.Id, user, orderCustInfo, personalInfo, addr);
        GARP_BC_Membership.updateMembershipContact(contact.Id, user, orderCustInfo, personalInfo, addr);
        GARP_BC_Membership.updateMembershipAccount(con.AccountId, user, contact, orderCustInfo, addr);
        opp = GARP_TestFactory.createOrder(con.AccountId, con.id, 'AFREE');
        GARP_BC_Membership.hasCompedMembership(account.Id);
        GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = new GARP_BC_Registration.setRegistrationInfo();
        setRegistrationInfo.customerInfo = orderCustInfo;
        setRegistrationInfo.paymentInfo = new GARP_BC_Orders.orderPaymentInfo();
        setRegistrationInfo.paymentInfo.paymentType = 'Credit Card';
        setRegistrationInfo.paymentInfo.billingAddress = new GARP_Common.address();
        setRegistrationInfo.paymentInfo.billingAddress.country = 'United States';
        setRegistrationInfo.paymentInfo.billingAddress.province = 'New Jersey';
        setRegistrationInfo.paymentInfo.billingAddress.postalCode = '07310';
        setRegistrationInfo.paymentInfo.billingAddress.street1 = '111 Town Square Place';
        setRegistrationInfo.paymentInfo.billingAddress.city = 'JERSEY CITY';
        setRegistrationInfo.paymentInfo.billingAddress.phone = '1234567890';
        GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = new GARP_BC_Registration.setRegistrationReturnInfo();
        setRegistrationReturnInfo.accountId = contact.AccountId;
        setRegistrationReturnInfo.contactId = contact.Id;
        GARP_BC_Membership.createRiskNetContract(setRegistrationInfo, setRegistrationReturnInfo, 'AFREE', membershipInfo);
        opp.Payment_Status__c = 'Recurring';
        update opp;
        setRegistrationReturnInfo.orderId = opp.Id;
        GARP_BC_Membership.createMembershipContract(setRegistrationInfo, setRegistrationReturnInfo, 'AFREE', membershipInfo);
        test.stopTest();
    }

    @isTest
    public static void testAffiliateMembershipReg() { runTestAffiliateMembershipReg(); }
}