@isTest
private class Utilities_test{
    
    static Lead leadId;
    static Account acc ;    
    static Contact contact; 
    static Form_Session__c formSess;
    static Chapter_Meeting__c chapmeeting;
    static Chapter_Meeting__c chapmeeting2;
    static Chapter__c chapter;
    static Chapter__c chapter2;
    static Chapter_Member__c chapMember;
    static Chapter_Member__c chapMember2;
    static contract con;
    static Candidate_Requirement__c cr;
    static CPE_Activity_Type__c activity;
    static CPE_Claim__c claim;
    static Form__c fromobj1;
    static void tesData() {
        Acc = new Account(Name = 'test');
        insert acc;
        
        contact = new Contact(KPI_ERP_Certified__c = true,KPI_FRM_Certified__c = true,GARP_Directory_Opt_In__c = true,
                              lastname = 'Test',AccountId = acc.id,email='fn.ln@garp.com',
                              KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        con = new contract(StartDate = system.today(),Accountid = acc.id,Status = 'Draft',CurrencyIsoCode = 'USD',ContractTerm = 12);
        insert con;
        con.Status = 'Activated ( Auto-Renew )';
        con.ContractTerm = 24;
        con.StartDate = date.newInstance(2022, 01, 01);
        con.recordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','CPE');
        update con;
        
        cr = new Candidate_Requirement__c(Name='CPD Credit',Candidate_Commitment__c = con.id,Status__c = 'Initial');
        insert cr;
        
        activity = new CPE_Activity_Type__c (name = 'Webcasts', Active__c = true);
        insert activity;
        
        claim = new CPE_Claim__c (Candidate_Requirement__c = cr.id, Credits_Earned__c =40, Approved__c  = True, ApprovedCredits__c = 40);
        insert claim;
        
        formSess = new Form_Session__c();
        insert formSess ;
        
        insert new CAPTCHA_Configuration__c(Name = 'Exam Registration',Enabled__c = true);
        
        leadId = new Lead();
        leadId.FirstName = 'TEST';
        leadId.LastName = 'LEAD';
        leadId.Email = 'test@test.com';
        leadId.Company = 'TEST LEAD';
        leadId.IsConverted = FALSE ;
        insert leadId;
        
        chapter = new Chapter__c(Name = 'TestChapter', Status__c = 'Active');
        insert chapter;
        chapter2 = new Chapter__c(Name = 'TestChapter', Status__c = 'Active');
        insert chapter2;
        
        chapMember = new Chapter_Member__c(Name = 'test member',Director__c = true,Can_Request_Meetings__c = true,Can_Manage_Attendance__c=true,Can_View_Resources__c = true,Chapter__c = chapter.Id);
        insert chapMember;
        chapMember2 = new Chapter_Member__c(Name = 'test member',Director__c = false,Can_Request_Meetings__c = true,Can_Manage_Attendance__c=true,Can_View_Resources__c = true,Chapter__c = chapter2.Id);
        insert chapMember2;
        chapmeeting = new Chapter_Meeting__c(Name='Test Chapter Meeting', Start__c=System.now().addDays(15), End__c=System.now().addDays(15).addHours(2),Chapter__c = chapter.Id);
        insert chapmeeting;
        
        chapmeeting2 = new Chapter_Meeting__c(Name='Test Chapter Meeting', Start__c=System.now().addDays(15), End__c=System.now().addDays(15).addHours(2),Chapter__c = chapter2.Id);
        insert chapmeeting2;
        
        fromobj1 = new Form__c();
        fromobj1.Name = 'Test Form Data1';
        fromobj1.Form_Name__c ='Test Form Data1';
        fromobj1.Subscriptions__c = 'FRM Exam Updates1';
        insert fromobj1;
    }
    
    @isTest
    public static void testVerifyUser(){
        
        GARP_TestFactory.createCountryCodes();
        
        test.startTest();

        // Setup Products
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});

        // Create User
        User user = GARP_TestFactory.createUser();
        
        // Create Member        
        Opportunity opp = GARP_TestFactory.createMember();
        
        List<Contact> lstCont = [select id, accountId, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c from contact];
        Contact contact = lstCont[0];
        System.debug('!!contact:' + contact);
        
        // Create Expired Contract
        Contract programContract = new Contract(
            Name = 'FBR',
            Status='Draft',
            AccountId = contact.accountId,
            Opportunity__c = opp.Id,
            CustomerSignedId = contact.Id,
            StartDate = System.Today().AddDays(-365),
            ContractTerm = 12,
            RecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract', 'FBR Program')
        );
        INSERT programContract;
        programContract.Status = 'Expired';
        UPDATE programContract;
        
        // Get Reg Info
        GARP_MS_Courses.getFFRRegistrationInfo(); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Courses.getFFRRegistrationSettings();
        
		// Setup Products        
        List<String> prodSHIP = new List<String>{'SHIPFFR:SHIPFFR:4040:100'};
        GARP_TestFactory.createProducts(prodSHIP, new Set<String>{}, new Set<String>{}, new Set<String>{});        
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.mainNonMemberProductCode), new Set<String>{}, new Set<String>{}, new Set<String>{});
        Set<String> setStudyMats = new Set<String>();
        setStudyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{'FFRXF'}, new Set<String>{}, setStudyMats);
        GARP_TestFactory.createShippingRates(new List<String>{'CBRHB:4030'});
        
        System.runAs(user) {
            String userId = UserInfo.getUserId();
            System.debug('!!userId:' + userId);
            
            Utilities.verifyUserAccount();
            Utilities.getCurrentUserDetails();
        }
        
        test.stopTest();
    }
    
    Private static testMethod void myUnitTest_1(){
        
        test.starttest();
        tesData();
        
        Form_Data__c formData = new Form_Data__c();
        
        formData.First_Name__c = 'FN';
        formData.Last_Name__c = 'LN';
        formData.Email__c = 'fn.ln@garp.com';
        formData.Status__c = 'Abandoned';
        formData.Contact__c = contact.id;
        formData.Form__c = fromobj1.id; 
        insert formData;
        
        Utilities.FormDataResponse formDataResponse = Utilities.manageFormSubmission(formData, 'Test Form Data1');            
        
        formDataResponse = Utilities.manageFormSubmission(formData, 'Test Form Data1');  
        
        
        Utilities.migrateLeadFormDataToContact(formDataResponse.leadId, contact.Id, 'Test Form Data1', null);
        
        Utilities.migrateLeadFormDataToContact(formDataResponse.leadId, contact.Id, 'Test Form Data1', null);
        formDataResponse = Utilities.manageFormSubmission(formData, 'Test Form Data1');            
        
        Utilities.verifyGroupMembership('groupId');
        Utilities.verifyGroupTopicOwner('groupId','topicId');
        Utilities.verifyGroupTopicMember('groupId','topicId');
        Utilities.verifyGroupTopicPostOwner('groupId','topicId','postId');
        Utilities.verifyGroupTopicPostMember('groupId','topicId','postId');
        
        Utilities.getRandomCode();
        Utilities.getCurrentUserDetails();
        Utilities.verifyCaptcha('capresp','123.123.123.123');
        Utilities.blockSessionUser(formSess.Id,'fn.ln@garp.com');
        
        test.stoptest(); 
        
    }
    
    Private static testMethod void replaceChar(){
        test.starttest();
        tesData();
        insert new SpecialCharacters__c(name = '@',Replace_Character__c = 'a');
        Utilities.replaceChars('test@');
        Utilities.replaceExtendedChars('test@');
        test.stopTest();
    }
    
    Private static testMethod void getCaptchaConfiguration() {
        test.startTest();
        tesData();
        Utilities.getFormSessionToken();
        
        // Utilities.runCaptcha(formSess.id);
        test.stopTest();
    }
    
    Private static testMethod void updateFormSession() {
        test.startTest();
        tesData();
        Utilities.updateFormSession(formSess.Id,'fn.ln@garp.com');
        Utilities.getSecureWhereClause('contact','','');
        Utilities.getSecureWhereClause('lead',leadId.Id,'');
        Utilities.getSecureWhereClause('bloomberg_profile__c','','');
        Utilities.getSecureWhereClause('chapter_meeting__c',chapmeeting.Id ,'');
        // Utilities.getSecureWhereClause('cpe_claim__c','','');
        // Utilities.getSecureWhereClause('account','','');
        Utilities.getSecureWhereClause('proctor_registration__c','','');
        // Utilities.getSecureWhereClause('candidate_requirement__c','','');
        Utilities.runCaptcha(formSess.Id);
    }
    
    Private static testMethod void verifyChapterMeetingRights() {
        test.startTest();
        tesData();
        Utilities.verifyChapterMeetingRights(chapmeeting.Id,true,true,true);
        Utilities.verifyChapterMeetingRights(chapmeeting2.Id,true,false,false);
        Utilities.verifyChapterMeetingRights(chapmeeting2.Id,false,true,false);
        Utilities.verifyChapterMeetingRights(chapmeeting2.Id,false,false,true);
        test.stopTest();
    }
    
    Private static testMethod void getSecureWhereClauseList() {
        test.startTest();
        tesData(); 
        Utilities.getSecureWhereClauseList('contact','','');
        Utilities.getSecureWhereClauseList('bloomberg_profile__c','','');
        Utilities.getSecureWhereClauseList('account','','');
        Utilities.getSecureWhereClauseList('chapter_meeting__c','','');
        Utilities.getSecureWhereClauseList('proctor_registration__c','','');
        Utilities.getNetworkID();
        test.stopTest();
    }
    
   /* @IsTest(SeeAllData=true)
    Private static void verifyUserAccount() {
        test.startTest();
        tesData(); 
        // ConnectApi.ChatterUsers.getGroups(getNetworkID(), vUser.Id, 0, 25)
        ConnectApi.UserGroupPage testChatterUserPage = new ConnectApi.UserGroupPage();
        List<ConnectApi.ChatterGroupSummary> testgroupsList = new List<ConnectApi.ChatterGroupSummary>();
        testgroupsList.add(new ConnectApi.ChatterGroupSummary());
        testgroupsList.add(new ConnectApi.ChatterGroupSummary());
        testChatterUserPage.groups = testgroupsList;
        CollaborationGroup myGroup = new CollaborationGroup();
        
        myGroup.Name='My Group'; // Define group name here
        myGroup.CollaborationType='Public'; //It can be 'Public' or 'Private' 
        myGroup.NetworkId = [select Id, Name from Network where name = 'My GARP' LIMIT 1][0].Id;
        insert myGroup; 
        
        system.debug('myGroup.Id=========>'+myGroup.Id);
        FeedItem FI = new FeedItem(Body = 'Test', ParentId = myGroup.Id);
        insert FI;
        
        // Build a simple feed item
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;
        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(myGroup.NetworkId,
                                                               ConnectApi.FeedType.Record,myGroup.id,null,100,
                                                               ConnectApi.FeedSortOrder.CreatedDateDesc,testPage);
        Utilities.verifyGroupMembership(myGroup.Id);
        Utilities.getCurrentUserDetails();
        Utilities.verifyGroupTopicOwner(myGroup.id,FI.Id);
        test.stopTest();
    }*/
}