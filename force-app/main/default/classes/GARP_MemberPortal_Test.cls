@isTest
public class GARP_MemberPortal_Test {
    
    /*
    Static List<Contract> conlist;
    Static Contact con ;
    Static Account acct ;
    Static Opportunity opp;
    Static List<OpportunityLineItem> OppLineItems;
    Static String eventId;
    */
    
    Static User user;
    Static Account account;
    Static Contact contact;
    Static Opportunity opp;
    
    static void setup(){
        GARP_TestFactory.IndividualMemberSetup setup = GARP_TestFactory.setupIndividualMember(false);
        user = setup.user;
        opp = setup.opp;
        contact = setup.contact;
        account = setup.account;
        System.Debug('**contact:' + contact);

        Remote_Sites__c setting = new Remote_Sites__c();
        setting.Name = 'Mobius';
        setting.Site_URL__c = 'http://preprod.garp.org:8081';
        insert setting;
    }
    
    static void setupThrow(){
        
        // Setup Products
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        // Create User
        user = GARP_TestFactory.createIndividualUserThrow();
        
        // Create Member        
        //opp = GARP_TestFactory.createMember();
        
        opp = [select id,AccountId,StageName from Opportunity limit 1];
        
        List<Contact> lstCont = [select id, accountId, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c from contact];
        contact = lstCont[0];        

        List<Account> lstAcct = [select id, Name from Account where id = :contact.accountId];
        account = lstAcct[0];        

        Remote_Sites__c setting = new Remote_Sites__c();
        setting.Name = 'Mobius';
        setting.Site_URL__c = 'http://preprod.garp.org:8081';
        insert setting;
    }
    
    static void setupCertified(){
        
        // Setup Products
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        // Create User
        user = GARP_TestFactory.createIndividualUser();
        
        GARP_TestFactory.makeIndividualCertified(user.accountId);
        GARP_TestFactory.makeIndividualSCRHolder(user.accountId);
        GARP_TestFactory.makeIndividualRAIHolder(user.accountId);
        
        opp = [select id,AccountId,StageName from Opportunity limit 1];
        
        List<Account> lstAcct = [select id, Name from Account where id = :user.accountId];
        account = lstAcct[0]; 
        
        List<Contact> lstCont = [select id, accountId from contact where id = :user.contactId];
        contact = lstCont[0];
    }
    
    static void setupEBooks() {
        
        // Setup eBooks
        List<String> prodsAUX = new List<String>{'FFRXF:FFRXF:4999:100','CBRX:CBRX:4040:100','RAIBP:RAIBP:4040:100','SCRX:SCRX:4040:100','FRM1X:FRM1X:4040:100'};
        GARP_TestFactory.createProducts(prodsAUX, new Set<String>{}, new Set<String>{}, new Set<String>{'FFRXF','CBRX','RAIBP','SCRX','FRM1X'});

        Opportunity ebookOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FFRXF');
        System.Debug('ebookOpp:' + ebookOpp);
        
        List<OpportunityLineItem> OppLineItems = new List<OpportunityLineItem>();
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(ebookOpp.id,'CBRX'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(ebookOpp.id,'RAIBP'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(ebookOpp.id,'SCRX'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(ebookOpp.id,'FRM1X'));
        insert OppLineItems;
        
        ebookOpp.StageName = 'Closed';
        update ebookOpp;
        
        List<eBook_Key__c> eBookKeys = GARP_TestFactory.createEbookKey(ebookOpp);
        System.Debug('eBookKeys:' + eBookKeys);
        insert eBookKeys;
    }
    
    static void setupNewFRR() {
        
        String examGroupRecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'MicroCourse');
        
        Exam_Group__c objExamGrp = new Exam_Group__c();
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;
        objExamGrp.RecordTypeId = examGroupRecordTypeId;
        insert objExamGrp;
        
        Exam__c ex = new Exam__c(Name='FRRMC1',Exam__c='FRRMC1',Exam_Group__c=objExamGrp.Id,Exam_Date__c=Date.Today(),MC_Course_Name__c='FRR MC1',MC_Course_Form_Key__c='form-mc1',
                                 MC_Course_Study_Materials_Product_Codes__c='FRRMC1HB,FRRMC1BP',
                                 MC_Course_Program_Record_Type__c='FRR MC1 Program',MC_Course_Program_Record_Type_API_Name__c='FRR_MC1_Program',
                                 MC_Course_Member_Product_Code__c='MC1M',MC_Course_Non_Member_Product_Code__c='MC1NM',MC_Course_Certified_Product_Code__c='MC1C',
                                 MC_Course_Retake_Product_Code__c='MC12A');
        Insert ex;
        
        Exam_Sites__c exmSite = new Exam_Sites__c(exam__c = ex.id);
        insert exmSite;
    }
    
    @isTest
    static void unitTest_Orders() {
        
        setup();
        
        // Setup eBooks
        List<String> prodsAUX = new List<String>{'FFRXF:FFRXF:4999:100','CBRX:CBRX:4040:100','RAIBP:RAIBP:4040:100','SCRX:SCRX:4040:100','FRM1X:FRM1X:4040:100'};
        GARP_TestFactory.createProducts(prodsAUX, new Set<String>{}, new Set<String>{}, new Set<String>{'FFRXF','CBRX','RAIBP','SCRX','FRM1X'});

        Opportunity ebookOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FFRXF');
        System.Debug('ebookOpp:' + ebookOpp);
        
        test.startTest();
        
        List<Opportunity> lstOpp = [select Id from Opportunity];
        
        System.runAs(user) {
            GARP_MS_MemberPortal.cancelUnpaidOrder(ebookOpp.Id);
            GARP_MS_MemberPortal.payPendingOrder(ebookOpp.Id);
        }
        
        test.stopTest();
        
    }
    
    @isTest
    static void unitTest_FRMCV1(){
        
        setup();
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        frmContract.Status = 'Activated';
        update frmContract;
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        Candidate_Requirement__c crExam1 = GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        Candidate_Requirement__c crExam2 = GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        Candidate_Requirement__c crCV = GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(opp,frmContract,'FRM');
        List<Exam_Attempt__c> lstEAs = [select Id, Result__c, Exam_Site__c, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c, Exam_Part__r.Exam__c, Exam_Part__r.Exam__r.Exam__c from Exam_Attempt__c where id = :frmAttempt.Id];
        System.debug('** lstEAs:' + lstEAs);
        
        Exam_Attempt__c frm2Attempt = GARP_TestFactory.createExamAttemptPart2(opp, frmContract, lstEAs[0].Exam_Administration__r.Exam_Group__c, lstEAs[0].Exam_Administration__c);
        List<Exam_Attempt__c> lstEA2s = [select Id, Result__c, Exam_Site__c, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c, Exam_Part__r.Exam__c, Exam_Part__r.Exam__r.Exam__c from Exam_Attempt__c where id = :frm2Attempt.Id];
        System.debug('** lstEA2s:' + lstEA2s);
        
        lstEAs[0].Result__c = 'Pass';
        update lstEAs;
        
        lstEA2s[0].Result__c = 'Pass';
        update lstEA2s;
        
        crExam1.Status__c = 'Completed';
        crExam1.Date_of_Completion__c = Date.Today().AddDays(-365);
        update crExam1;

        crExam2.Status__c = 'Completed';
        crExam2.Date_of_Completion__c = Date.Today().AddDays(-365);
        update crExam2;
        
        List<Contract> lstFrmContracts = [select id, Status, (SELECT Id, Name, Status__c, Date_of_Completion__c, Exam__c, Approved_Credits_Total__c, CPE_Credit_Requirement__c, recordType.DeveloperName FROM Candidate_Requirements__r) from contract where id = :frmContract.Id];
        System.debug('** lstFrmContracts:' + lstFrmContracts);
        for(Candidate_Requirement__c cr :lstFrmContracts[0].Candidate_Requirements__r) {
            System.debug('** cr.Status__c:' + cr.Status__c);
            System.debug('** cr.recordType.DeveloperName:' + cr.recordType.DeveloperName);
        }        
        test.startTest();
        
        System.runAs(user) {
            
            GARP_BC_MyPrograms.workExperience workExperience = new GARP_BC_MyPrograms.workExperience();
            workExperience.programRequirement = crCV.Id;
            workExperience.startDate = '10/21/2019';
            workExperience.endDate = '11/17/2021';
            workExperience.company = 'GARP';
            workExperience.title = 'Associate';
            workExperience.type = 'Professional';
            workExperience.description = 'This is a job. This is a job. This is a job. This is a job. This is a job. ';
            workExperience.manager = 'Jim Bob';
            workExperience.jobFunction = 'Trading';
            workExperience.riskSpecialty = 'Data Risk';
            workExperience.jobType = 'Full Time';
            workExperience.educationalRole = 'Professor';
            
            GARP_BC_MemberPortal.returnSetWorkExperienceInfo retWE = GARP_MS_MemberPortal.setWorkExperienceInfo('FRM',NULL, workExperience);
            
            GARP_BC_MemberPortal.returnCVPageInfo returnCVPageInfo = GARP_MS_MemberPortal.getCVPageInfo('FRM');
            System.debug('** returnCVPageInfo:' + returnCVPageInfo);
            
            GARP_BC_MyPrograms.workExperience lastWE;
            
            for(GARP_BC_MyPrograms.workExperience we :returnCVPageInfo.workExperiences) {
                System.debug('** we:' + we);
                lastWE = we;                
                GARP_MS_MemberPortal.getWorkExperienceInfo('FRM',we.id);
                GARP_MS_MemberPortal.setWorkExperienceInfo('FRM',we.id, we);
            }
            
            GARP_BC_MemberPortal.returnSubmitCVInfo retcv = GARP_MS_MemberPortal.submitCVInfo('FRM');
            GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo retcvatt = GARP_MS_MemberPortal.uploadWorkExperienceAttachment(lastWE.id, 'filename', 'filedata');
            GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo retgetatt = GARP_MS_MemberPortal.getWorkExperienceAttachments(lastWE.id);
            GARP_MS_MemberPortal.downloadWorkExperienceAttachment(retgetatt.attachments[0].id);
            GARP_BC_MemberPortal.returnWorkExperienceAttachmentInfo retgdelatt = GARP_MS_MemberPortal.deleteWorkExperienceAttachment(retgetatt.attachments[0].id);
            
            GARP_MS_MemberPortal.deleteWorkExperienceInfo('FRM',lastWE.id);
            
            GARP_Common.Address mailingAddress = new GARP_Common.Address();
            mailingAddress.company = 'GARP';
            mailingAddress.street1 = '111 Town Square Pl';
            mailingAddress.street2 = '14th Floor';
            mailingAddress.city = 'Jersey City';
            mailingAddress.province = 'New Jersey';
            mailingAddress.postalCode = '07310';
            mailingAddress.country = 'United States';

            GARP_MS_MemberPortal.setCVAddressInfo('FRM',mailingAddress, mailingAddress, 'OSTArecipient');

            Map<String, Object> formData = new Map<String, Object>();
            String institutionType;
            
            institutionType = 'Company';
            formData.put('jobFunction','stuff');
            formData.put('riskSpecialty','stuff');
            formData.put('educationalRole','stuff');
            formData.put('jobType','stuff');
            formData.put('jobType','company');
            
            GARP_MS_MemberPortal.isContactRequiredToHaveDocuments(formData, institutionType);

            formData.put('experienceId',retWE.newExperienceId);
            GARP_MS_MemberPortal.isContactRequiredToHaveDocuments(formData, institutionType);

            institutionType = 'EPP';
            GARP_MS_MemberPortal.isContactRequiredToHaveDocuments(formData, institutionType);

        }
        
        test.stopTest();
    }
     
    @isTest
    static void unitTest_Dash(){
        setup();
        test.startTest();
        
        contact.GBI_Participant__c = True;
        //contact.EPP_Data_Manager__c = True;
        
        EPP_Account__c eppAcct = new EPP_Account__c(Name='EPP', Account__c = account.Id, Primary_EPP_Contact__c = contact.Id);
        insert eppAcct;
        
        contact.BenchPrep_Viewer__c = True;
        update contact;
                
        System.runAs(user) {
           
            GARP_MS_MemberPortal.getNavBarInfo();
            GARP_MS_MemberPortal.getDashboardInfo('');
            GARP_MS_MemberPortal.getPurchaseHistoryInfo();

            new GARP_MS_MemberPortal(new sfdcAppRemoter());
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_Profile(){
        
        setup();
        
        test.startTest();
        
        System.runAs(user) {
            GARP_MS_MemberPortal.getNavBarInfo();
            GARP_MS_MemberPortal.getDashboardInfo('');
            GARP_MS_MemberPortal.getComponentUpdateProfileInfo();
            GARP_BC_MemberPortal.returnProfileDemographicsFormInfo ret = GARP_MS_MemberPortal.getProfileDemographicsFormInfo();
            GARP_MS_MemberPortal.setProfileDemographicsFormInfo(ret.profileDemographicsContactInfo);
            
            GARP_MS_MemberPortal.muteProfileComponent(true);
            GARP_MS_MemberPortal.muteProfileComponent(false);
            
            GARP_BC_MemberPortal.returnGetProfilePersonalFormInfo ret1 = GARP_MS_MemberPortal.getProfilePersonalFormInfo();
            GARP_MS_MemberPortal.setProfilePersonalInfo(ret1.personalInfo);
            
            GARP_MS_MemberPortal.getProfileMembershipInfo();
            
            GARP_MS_MemberPortal.setAutorenewMembershipOff();
            
            GARP_BC_Orders.orderPaymentInfo orderPaymentInfo = new GARP_BC_Orders.orderPaymentInfo();
            orderPaymentInfo.expireMonth = 1;
            orderPaymentInfo.expireYear = 2025;
            orderPaymentInfo.paymentType = 'Credit';
            orderPaymentInfo.ccv = '123';
            orderPaymentInfo.cardNumber = '1234567890987654';
                
            GARP_MS_MemberPortal.enableAutoRenew();
                             
            GARP_MS_MemberPortal.getProfileChaptersInfo();
            GARP_MS_MemberPortal.setProfileChaptersInfo('Poland','Germany');
            
            GARP_BC_MemberPortal.returnGetProfileExpertiseInfo ret2 = GARP_MS_MemberPortal.getProfileExpertiseInfo();
            GARP_MS_MemberPortal.setProfileExpertiseInfo(ret2.memberExpertiseInfo);
            
            //GARP_MS_MemberPortal.getOrderInfo(retOrder.OrderId);
            
            GARP_MS_MemberPortal.removeMemberPhoto();
            String fileText = '123';
            GARP_BC_MemberPortal.returnUploadMemberPhoto retUpload = GARP_MS_MemberPortal.uploadMemberPhoto(NULL, fileText, 'attachment');
            String attId = retUpload.statusMessage;
            
            GARP_MS_MemberPortal.setMemberPhoto(attId);
        }
        
        test.stopTest();
    }

    @isTest
    static void unitTest_Membership(){
        
        setupCertified();
        
        eBook_Key__c record = new eBook_Key__c();
        record.Name= 'Test Key';
        record.Key__c='23424refef1';
        record.Type__c = 'BenchPrep';
        record.Access_Duration_in_Months__c=36;
        record.Cancelled__c = FALSE;
        
        String frmBenchPrepForMembersSlug = Label.GARP_FRM_BenchPrep_For_Members_Slug;
        
        record.Product_ID__c = frmBenchPrepForMembersSlug;
        record.Contact__c = contact.Id;
        record.Complimentary__c  = True;
        insert record;
        
        test.startTest();
        
        System.runAs(user) {
            GARP_MS_MemberPortal.getDashboardInfo('');
            
            GARP_MS_MemberPortal.getComponentNewNotificationsInfo();
            GARP_MS_MemberPortal.getAllNotifications();
            
            GARP_MS_MemberPortal.getDirectorySearchFormInfo();
            
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
            GARP_MS_MemberPortal.searchMemberDirectory(searchParams);
            
            GARP_BC_MemberPortal.returnGetMemberDirectorySettingsFormInfo ret = GARP_MS_MemberPortal.getMemberDirectorySettingsFormInfo();
            GARP_MS_MemberPortal.setMemberDirectorySettingsFormInfo(ret.memberDirectorySettingsInfo.memberDirectorySettings);
            
            GARP_BC_Membership.sendMemberMessageInfo mi = new GARP_BC_Membership.sendMemberMessageInfo();
            mi.recipientContactId = contact.Id;
            mi.messageType = 'Directory_Connect_Invite';
            mi.message = 'Hello!';
            
            GARP_MS_MemberPortal.sendMemberDirectoryMessage(mi);
            
            GARP_MS_MemberPortal.getPurchaseHistoryInfo();            
            GARP_TestFactory.createMemberOffers();
            GARP_MS_MemberPortal.getMembershipPageInfo();
                        
            GARP_MS_MemberPortal.submitCustomerCase('title', 'description');
            
            GARP_MS_MemberPortal.setEmailPreferenceUpdate();
            GARP_MS_MemberPortal.setSMSPreferenceUpdate(false, false);
            GARP_MS_MemberPortal.setSMSPreferenceUpdate(true, true);
        }
        
        test.stopTest();
    }

    /** Covers GARP_BC_MemberPortal branches: getContact(null), verifyMemberPortalAccess(No Membership), getNavBarInfo(GBI Only). */
    @isTest
    static void unitTest_BC_CoverageBranches() {
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});

        // 1. getContact with non-existent id -> hits return null branch (line 36)
        Contact cNull = GARP_BC_MemberPortal.getContact('003000000000000AAA');
        System.assert(cNull == null, 'getContact should return null for non-existent id');

        // 2. Account with contracts but no Membership -> verifyMemberPortalAccess "No Membership Found" (lines 103-104)
        Account acctNoMem = new Account(Name = 'Test No Membership', RecordTypeId = RecordTypeHelper.GetRecordTypeId('Account', 'Individual'));
        acctNoMem.OwnerId = UserInfo.getUserId();
        insert acctNoMem;
        Contact contNoMem = new Contact(AccountId = acctNoMem.Id, LastName = 'NoMem', Email = 'nomem@test.com', RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contact', 'Member'));
        insert contNoMem;
        Id frmRtId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program');
        insert new Contract(AccountId = acctNoMem.Id, RecordTypeId = frmRtId, Status = 'Draft', ContractTerm = 12);
        GARP_BC_MemberPortal.navBarInfo navNoMem = GARP_BC_MemberPortal.getNavBarInfo(contNoMem.Id);
        System.assert(navNoMem.statusCode == 403, 'Expected 403 when no membership');
        System.assert(navNoMem.statusMessage != null && navNoMem.statusMessage.contains('Denied'), 'Expected Portal Access Denied');

        // 3. GBI participant + non-Individual account -> getNavBarInfo "Portal Access Denied, GBI Only" (lines 142-143)
        Id businessRtId = RecordTypeHelper.GetRecordTypeId('Account', 'Business');
        if (businessRtId != null) {
            Account acctGBI = new Account(Name = 'Test GBI', RecordTypeId = businessRtId);
            acctGBI.OwnerId = UserInfo.getUserId();
            insert acctGBI;
            Contact contGBI = new Contact(AccountId = acctGBI.Id, LastName = 'GBI', Email = 'gbi@test.com', GBI_Participant__c = true, RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contact', 'Member'));
            insert contGBI;
            GARP_BC_MemberPortal.navBarInfo navGBI = GARP_BC_MemberPortal.getNavBarInfo(contGBI.Id);
            System.assert(navGBI.statusCode == 403, 'Expected 403 for GBI only');
            System.assert(navGBI.statusMessage != null && navGBI.statusMessage.contains('GBI'), 'Expected GBI Only message');
        }
    }

    /** Covers getExamSetupFeesCheckoutInfo and examSetupAuthorizeRegistrations success path (valid member with portal access). */
    @isTest
    static void unitTest_ExamSetupWithValidMember() {
        setup();
        // Activate membership so verifyMemberPortalAccess returns 200 (createIndividualUser leaves it Draft)
        List<Contract> membershipContracts = [
            SELECT Id, Status FROM Contract
            WHERE AccountId = :account.Id AND RecordType.DeveloperName = 'Membership' LIMIT 1
        ];
        if (!membershipContracts.isEmpty()) {
            membershipContracts[0].Status = 'Activated';
            update membershipContracts[0];
        }
        test.startTest();
        System.runAs(user) {
            GARP_BC_MyPrograms.returnGetExamSetupFeesCheckoutInfo feesRet = GARP_MS_MemberPortal.getExamSetupFeesCheckoutInfo(null);
            System.assert(feesRet != null, 'getExamSetupFeesCheckoutInfo should return');
            System.assert(feesRet.statusCode == 200, 'Expected 200 with valid member; got ' + feesRet.statusCode + ': ' + feesRet.statusMessage);

            GARP_BC_MyPrograms.returnExamSetupAuthorizeRegistrations authRet = GARP_MS_MemberPortal.examSetupAuthorizeRegistrations('frm', false);
            System.assert(authRet != null, 'examSetupAuthorizeRegistrations should return');
            System.assert(authRet.statusCode == 200 || authRet.statusCode == 501, 'Expected 200 or 501 (e.g. No scheduling) with valid member; got ' + authRet.statusCode + ': ' + authRet.statusMessage);

            GARP_BC_MemberPortal.returnGetOrderInfo orderRet = GARP_MS_MemberPortal.getOrderInfo(null);
            System.assert(orderRet != null, 'getOrderInfo should return');
            System.assert(orderRet.statusCode == 200 || orderRet.statusCode == 404, 'Expected 200 or 404 with valid member; got ' + orderRet.statusCode + ': ' + orderRet.statusMessage);
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_ProgramDetailFRR() {
        setup();
        List<String> prods = new List<String>{'CBRNM:CBRNM:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        test.startTest();
        System.runAs(user) {
            Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'CBRNM');
            Contract frrContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId, 'ICBRR Program');
            frrContract.Opportunity__c = programOpp.Id;
            update frrContract;
            GARP_TestFactory.createExamAttempt(programOpp, frrContract, 'FRR');
            frrContract.Status = 'Activated';
            update frrContract;
            GARP_BC_MemberPortal.returnCourseInfo ret = GARP_MS_MemberPortal.getFRRProgramDetailInfo();
            System.assert(ret != null && ret.statusCode == 200, 'getFRRProgramDetailInfo should return 200');
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_ProgramDetailFFR() {
        setup();
        List<String> prods = new List<String>{'FBRNM:FBRNM:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        test.startTest();
        System.runAs(user) {
            Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FBRNM');
            Contract ffrContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId, 'FBR Program');
            ffrContract.Opportunity__c = programOpp.Id;
            update ffrContract;
            ffrContract.Status = 'Activated';
            update ffrContract;
            GARP_BC_MemberPortal.returnCourseInfo ret = GARP_MS_MemberPortal.getFFRProgramDetailInfo();
            System.assert(ret != null && ret.statusCode == 200, 'getFFRProgramDetailInfo should return 200');
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_ProgramDetailSCR() {
        setup();
        test.startTest();
        System.runAs(user) {
            Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'MEMI');
            Contract scrContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId, 'SCR Program');
            scrContract.Opportunity__c = programOpp.Id;
            update scrContract;
            GARP_TestFactory.createExamAttempt(programOpp, scrContract, 'SCR');
            scrContract.Status = 'Activated';
            update scrContract;
            GARP_BC_MemberPortal.returnProgramsDetailInfo ret = GARP_MS_MemberPortal.getSCRProgramDetailInfo('');
            System.assert(ret != null && ret.statusCode == 200, 'getSCRProgramDetailInfo should return 200');
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_ProgramDetailRAI() {
        setup();
        test.startTest();
        System.runAs(user) {
            Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'MEMI');
            Contract riskaiContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId, 'Risk AI Program');
            riskaiContract.Opportunity__c = programOpp.Id;
            update riskaiContract;
            GARP_TestFactory.createExamAttempt(programOpp, riskaiContract, 'RiskAI');
            riskaiContract.Status = 'Activated';
            update riskaiContract;
            GARP_BC_MemberPortal.returnProgramsDetailInfo ret = GARP_MS_MemberPortal.getRAIProgramDetailInfo('');
            System.assert(ret != null && ret.statusCode == 200, 'getRAIProgramDetailInfo should return 200');
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_ProgramDetailRAIJ() {
        setup();
        test.startTest();
        System.runAs(user) {
            Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'MEMI');
            Contract raijContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId, 'RAIJ Program');
            raijContract.Opportunity__c = programOpp.Id;
            update raijContract;
            GARP_TestFactory.createExamAttempt(programOpp, raijContract, 'raij');
            raijContract.Status = 'Activated';
            update raijContract;
            GARP_BC_MemberPortal.returnProgramsDetailInfo ret = GARP_MS_MemberPortal.getRAIJProgramDetailInfo('');
            System.assert(ret != null && ret.statusCode == 200, 'getRAIJProgramDetailInfo should return 200');
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_GetMostRecentEBook() {
        setup();
        test.startTest();
        System.runAs(user) {
            List<GARP_BC_StudyMaterials.eBook> myEBooks = GARP_BC_StudyMaterials.getMyEBooks(contact.AccountId, new List<Opportunity>{ opp });
            GARP_BC_StudyMaterials.eBook recent = GARP_BC_MemberPortal.getMostRecentEBook(contact, 'FRR', myEBooks);
            GARP_BC_MemberPortal.getMostRecentEBook(contact, 'RiskAI', new List<GARP_BC_StudyMaterials.eBook>());
        }
        test.stopTest();
    }
    
    @isTest
    static void unitTest_CPD(){
        
        setupCertified();
        
        test.startTest();
        
        String cpdReq = GARP_TestFactory.createCPDContract(contact.Id, contact.accountId, opp.Id);
        CPE_Claim__c claim = GARP_TestFactory.createCPDClaim(cpdReq);
        GARP_TestFactory.createCPDActivities();
        
        System.runAs(user) {
            
            GARP_MS_MemberPortal.getDashboardInfo('');
            GARP_MS_MemberPortal.getComponentCPDInfo('');
            
            GARP_BC_MemberPortal.returnCPDListingInfo cpdListInfo = GARP_MS_MemberPortal.getCPDListingInfo();
            GARP_MS_MemberPortal.getCPDClaimFormInfo();
                
            GARP_BC_CPD.cpdClaim cpdClaim = new GARP_BC_CPD.cpdClaim(claim);
            
            // Error
            GARP_MS_MemberPortal.setCPDClaimInfo(cpdClaim);
            
            DateTime dt = DateTime.NewInstance(cpdClaim.dateOfCompletion.year(), cpdClaim.dateOfCompletion.month(), cpdClaim.dateOfCompletion.day());
            cpdClaim.dateOfCompletionString = dt.format('MM/dd/yyyy');            
            GARP_MS_MemberPortal.setCPDClaimInfo(cpdClaim);
            
            GARP_BC_CPD.cpdCycleInfo cycleInfo = cpdListInfo.CPDProgramInfo.cycles[0];
            
            System.Debug('****cycleInfo:' + cycleInfo);
            
            GARP_MS_MemberPortal.setCPDAttestation(cycleInfo.attestationID);
            GARP_MS_MemberPortal.deleteCPDClaim(claim.Id);
            
            GARP_BC_CPD.cpdActivitiesFilters filter = new GARP_BC_CPD.cpdActivitiesFilters();
            filter.activityTypes = 'Reading Book';
            filter.areasOfStudy = 'Credit Risk';
            filter.providers = 'GARP';
            filter.sortOrder = 'Credits High to Low';
            filter.pageSize = 10;
            filter.pageCurrent = 1;
            
            GARP_BC_MemberPortal.returnCPDActivitiesBrowseFormInfo acpActs = GARP_MS_MemberPortal.getCPDActivitiesBrowseFormInfo(filter, NULL);
            GARP_BC_CPD.cpdActivity cpdAct = acpActs.cpdActivityInfo.cpdActivities[0];
            
            GARP_MS_MemberPortal.setCPDActivityAsClaim(cpdAct);
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyPrograms1(){
        
        setup();
        setupNewFRR();
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        frmContract.Status = 'Activated';
        update frmContract;
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(opp,frmContract,'FRM');
                
        test.startTest();
        
        System.runAs(user) {
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            
            // Normal
            GARP_MS_MemberPortal.getDashboardInfo('');
            GARP_MS_MemberPortal.EPPOptIn('frm', true);            
            GARP_MS_MemberPortal.getExamResultsListing('');
            GARP_MS_MemberPortal.setExamResultLastViewDate(frmAttempt.Id);
            GARP_MS_MemberPortal.getAlertBarInfo('');
            GARP_MS_MemberPortal.getComponentAdInfo();
            GARP_BC_MemberPortal.hasPracticeExamAccess(contact, 'frm', frmContract, frmAttempt);            
            GARP_MS_MemberPortal.getErrataFormInfo('frm');
            
            GARP_MS_MemberPortal.getComponentEnrolledProgramsInfo();
            
            GARP_MS_MemberPortal.getProgramsListingInfo('');
            
            // OSTA
            GARP_BC_MemberPortal.returnGetOSTAIDInfo ret = GARP_MS_MemberPortal.getOSTAIDInfo();
            GARP_MS_MemberPortal.setOSTAIDInfo(ret.OSTAIDInfo);
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsERP(){
        
        setup();
        
        Contract erpContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'ERP Program');
        erpContract.Status = 'Activated';
        update erpContract;
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(erpContract,'ERP Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(erpContract,'ERP Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(erpContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(opp,erpContract,'ERP');
                
        test.startTest();
        
        System.runAs(user) {
            GARP_MS_MemberPortal.getERPProgramDetailInfo('');
            GARP_MS_MemberPortal.getProgramsListingInfo('');
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyPrograms2(){
        
        setup();
        setupNewFRR();
        
        setupEBooks();
        
        test.startTest();
        
        // Create Products
        List<String> prods = new List<String>{'CBRNM:CBRNM:4999:100','FRR25NM:FRR25NM:4999:100','MC1NM:MC1NM:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});

        System.runAs(user) {            
            // Other Programs
            /*
            // FFR
            GARP_MS_MemberPortal.getFFRProgramDetailInfo();

            Contract ffrContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FBR Program');            
            ffrContract.Status = 'Activated';
            GARP_MS_MemberPortal.getFFRProgramDetailInfo();
                        
            // FRR
            GARP_MS_MemberPortal.getFRRProgramDetailInfo();

            Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'CBRNM');
            System.Debug('programOpp:' + programOpp);
            
            Contract frrContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'ICBRR Program');
            frrContract.Opportunity__c = programOpp.Id;
            update frrContract;
            
            Exam_Attempt__c ea = GARP_TestFactory.createExamAttempt(programOpp,frrContract,'FRR');
            System.Debug('ea:' + ea);
            
            frrContract.Status = 'Activated';
            update frrContract;            
            GARP_MS_MemberPortal.getFRRProgramDetailInfo();
            */
            
            // FRR25
            GARP_MS_MemberPortal.getFRR25ProgramDetailInfo();
            
            Opportunity programfrr25Opp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRR25NM');
            System.Debug('programfrr25Opp:' + programfrr25Opp);
            
            Contract frr25Contract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRR25 Program');
            frr25Contract.Opportunity__c = programfrr25Opp.Id;
            update frr25Contract;
            
            Exam_Attempt__c eafrr25Opp = GARP_TestFactory.createExamAttempt(programfrr25Opp,frr25Contract,'FRR25');
            System.Debug('eafrr25Opp:' + eafrr25Opp);
            
            frr25Contract.Status = 'Activated';
            update frr25Contract;            
            GARP_MS_MemberPortal.getFRR25ProgramDetailInfo();

            // FRRMicro1
            GARP_MS_MemberPortal.getMicroCourseProgramDetailInfo('FRRMC1');
            
            Opportunity programfrrmc1Opp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'MC1NM');
            System.Debug('programfrrmc1Opp:' + programfrrmc1Opp);
            
            Contract frrmc1Contract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRR MC1 Program');
            frrmc1Contract.Opportunity__c = programfrrmc1Opp.Id;
            update frrmc1Contract;
            
            Exam_Attempt__c eafrrmc1Opp = GARP_TestFactory.createExamAttempt(programfrrmc1Opp,frrmc1Contract,'FRRMC1');
            System.Debug('eafrrmc1Opp:' + eafrrmc1Opp);
            
            frrmc1Contract.Status = 'Activated';
            update frrmc1Contract;            
            GARP_MS_MemberPortal.getMicroCourseProgramDetailInfo('FRRMC1');

                        
            //SCR
            /*
            Contract scrContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'SCR Program');
            scrContract.Status = 'Activated';
            update scrContract;
            
            GARP_TestFactory.createExamAttempt(opp,scrContract,'SCR');
            GARP_MS_MemberPortal.getSCRProgramDetailInfo('');
            
            Contract riskaiContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'Risk AI Program');
            riskaiContract.Status = 'Activated';
            update riskaiContract;
            
            GARP_TestFactory.createExamAttempt(opp,riskaiContract,'RISKAI');
            GARP_MS_MemberPortal.getRAIProgramDetailInfo('');
            */
            
            GARP_MS_MemberPortal.getProgramsListingInfo('');
            
        }
        
        test.stopTest();
    }    
    
    @isTest
    static void unitTest_MyPrograms3(){
        setup();
        test.startTest();
        
        System.runAs(user) {
           
            GARP_MS_MemberPortal.getNavBarInfo();
            GARP_MS_MemberPortal.getDashboardInfo('');
            GARP_MS_MemberPortal.getPurchaseHistoryInfo();
            GARP_MS_MemberPortal.getExamSetupFormInfo('I');
            GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo = new GARP_BC_MyPrograms.examSetupExamSelectionsInfo();
            String cpdReq = GARP_TestFactory.createCPDContract(contact.Id, contact.accountId, opp.Id);
            Candidate_Requirement__c cr = [select id,Candidate_Commitment__c from Candidate_Requirement__c where id =:cpdReq];
            contract contr = [select id,CustomerSignedId from Contract where id =: cr.Candidate_Commitment__c];
            Exam_Attempt__c ea = GARP_TestFactory.createExamAttempt(opp,contr,'scr');
            examSetupExamSelectionsInfo.selectedAdminPart1  = ea.Exam_Administration__c; 
            examSetupExamSelectionsInfo.selectedSitePart1  = ea.Exam_Site__c; 
            GARP_MS_MemberPortal.getExamSetupExamSelectionInfo('scr',examSetupExamSelectionsInfo);
            //GARP_MS_MemberPortal.setExamSetupExamSelectionsChanges('scr',examSetupExamSelectionsInfo);
            GARP_BC_MyPrograms.returnGetExamSetupIDInfo retget = new GARP_BC_MyPrograms.returnGetExamSetupIDInfo();
            retget = GARP_MS_MemberPortal.getExamSetupIDInfo('scr',examSetupExamSelectionsInfo);
            GARP_BC_MyPrograms.setIdCandidateInfo setIdCandidateInfo = new GARP_BC_MyPrograms.setIdCandidateInfo();
            setIdCandidateInfo.idExpireDate = '12/27/2009';
            setIdCandidateInfo.idName = 'test';//retget.idCandidateInfo.idName;
            setIdCandidateInfo.idNumber = '123';// retget.idCandidateInfo.idNumber;
            //setIdCandidateInfo.idType = retget.idCandidateInfo.idType;
            setIdCandidateInfo.mobilePhoneLocation = 'testloc';
            setIdCandidateInfo.ostaIDLocation = 'China';
            setIdCandidateInfo.ostaDateOfBirth =  '12/27/2009';
    
            GARP_MS_MemberPortal.setExamSetupIDInfo('scr',examSetupExamSelectionsInfo,setIdCandidateInfo);
                        
            new GARP_MS_MemberPortal(new sfdcAppRemoter());
        }
        
        test.stopTest();
    }

    
    @isTest
    static void unitTest_Events(){
        
        setup();
        
        List<String> prodsAUX = new List<String>{'AFREE:AFREE:4999:100','MEMI:MEMI:4040:100','MEMC:MEMC:4040:100','CRTM:CRTM:4040:100','CRTNM:CRTNM:4040:100','SLSTX:SLSTX:4040:100','CBR2A:CBR2A:4040:100'};
        GARP_TestFactory.createProducts(prodsAUX, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        MAP<String,PricebookEntry> prodMap = GARP_TestFactory.getPriceBooksEntries(new List<String>{'AFREE','MEMI','MEMC','CRTM','CRTNM','SLSTX','CBR2A'});
        
        PricebookEntry peMem = prodMap.get('CRTM:4040');
        PricebookEntry peNonMem = prodMap.get('CRTNM:4040');
        String eventId = GARP_TestFactory.createEvent(peMem.Product2.Id, peNonMem.Product2.Id, false);
        GARP_TestFactory.createChapterMeeting();
        GARP_TestFactory.createWebcast();
        
        // Create Event Registration
        Event_Registration__c er = new Event_Registration__c(Event__c = eventId, Contact__c = contact.Id);
        insert er;
        
        test.startTest();

        System.runAs(user) {
            GARP_MS_MemberPortal.getDashboardInfo('');
            
            GARP_MS_MemberPortal.getComponentUpcomingEventsInfo();
            GARP_MS_MemberPortal.getEventsListingInfo();
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_StudyMats(){
        
        setup();
        
        // Get Reg Info
        GARP_MS_Exams.getFRMRegistrationInfo(NULL); // Just call to cover
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Exams.getFRMRegistrationSettings(NULL);
        
        Set<String> studyMats = new Set<String>(); 
        studyMats.addAll(programRegistrationInfo.studyMatProductCodes);
        GARP_TestFactory.createProducts(GARP_TestFactory.createProductList(programRegistrationInfo.studyMatProductCodes), new Set<String>{}, new Set<String>{}, studyMats);

        List<Folder__c> lstFolder = [select id from Folder__c];
        GARP_TestFactory.createExamGroupForStudyMats(lstFolder[0].id);
        
        List<eBook_Key__c> eBookList = GARP_TestFactory.createEbookKey(opp);
        insert eBookList;

        List<GARP_BC_StudyMaterials.eBookItem> eBookItems = new List<GARP_BC_StudyMaterials.eBookItem>();
        GARP_BC_StudyMaterials.eBookItem ei = new GARP_BC_StudyMaterials.eBookItem();
        ei.title = 'Book';
        ei.vendorId = 123;
        eBookItems.add(ei);
        
        test.startTest();
        
        System.runAs(user) {
            
            GARP_MS_MemberPortal.getBenchPrepLinks();
            
            GARP_MS_MemberPortal.getStudyMaterialListing();
            GARP_MS_MemberPortal.getMyEBooksInfo();
            GARP_MS_MemberPortal.getEBookAccessURL('123');
            GARP_MS_MemberPortal.getEBookAccessURLs(eBookItems);
            GARP_MS_MemberPortal.getErrataFormInfo('frm');
            
            GARP_BC_StudyMaterials.errataFormSubmissionInfo efs = new GARP_BC_StudyMaterials.errataFormSubmissionInfo();
            efs.programType = 'frm';
            efs.studyMaterial = '2024 FRM Exam Part I';
            efs.book = 'Foundations of Risk Management';
            efs.pageNumber = '12';
            efs.errorDescription = 'error';
            GARP_BC_MemberPortal.returnSubmitErrataFormInfo retsf = GARP_MS_MemberPortal.submitErrataForm(efs);
            
            GARP_BC_MemberPortal.returnAttachFileErrataSubmission retatt = GARP_MS_MemberPortal.attachFileErrataSubmission(retsf.errataId, 'fileName', 'filetext', NULL);
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_EPP(){
        setup();        
        
        EPP_Account__c eppAccount = new EPP_Account__c(
            Name = 'EPP Account', 
            Primary_EPP_Contact__c = contact.Id, 
            EPP_ERP__c = True, 
            EPP_FRM__c = True,
            EPP_SCR__c = True, 
            EPP_RAI__c = True,
            EPP_Location__c = 'USA', 
            EPP_Region_s__c = 'Americas', 
            EPP_Registration_Status__c = 'Approved', 
            Program__c = 'FRM',
            Account__c = account.Id
        );
        insert eppAccount;
        
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;    
        insert objExamGrp;
        System.debug('Inserted Exam_Group__c objExamGrp: ' + objExamGrp.Id);
        
        Date tdy = Date.Today();
        Integer year = tdy.Year();
        if(tdy.month() == 12) {
            year++;
        }
        System.debug('Exam year: ' + year);
        
        Exam__c exam = new Exam__c(Name='May ' + year + ' FRM Exam', Exam__c='FRM', Exam_Code__c ='1111:2015~5');
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = Date.NewInstance(year,5,1);
        insert exam;
        System.debug('Inserted Exam__c exam: ' + exam.Id);
        
        Site__c testsite = new Site__c(Name='USA, MA, BOSTON',Site_Code__c ='1800-11', Display_Address__c ='Westborough, Boston , MA, USA');
        insert testsite;
        System.debug('Inserted Site__c testsite: ' + testsite.Id);
        
        // Create Exam Administration
        Exam_Administration__c examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Type__c = 'FRM';
        examAdmin.Month__c = 'May';
        examAdmin.Year__c = year;
        examAdmin.Exam_Group__c = objExamGrp.Id;
        insert examAdmin;
        System.debug('Inserted Exam_Administration__c examAdmin: ' + examAdmin.Id);
        
        // Create Exam Part
        Exam_Part__c examPart = new Exam_Part__c();
        examPart.Exam_Administration__c = examAdmin.Id;
        examPart.Exam__c = exam.Id;
        examPart.Exam_Date__c = system.today() + 20;
        examPart.Exam_End_Date__c = system.today() + 25;
        examPart.Delivery_Method__c = 'CBT';
        insert examPart;
        System.debug('Inserted Exam_Part__c examPart: ' + examPart.Id);
        
        Exam_Sites__c examSite = new Exam_Sites__c(Name='May ' + year + ' FRM Exam USA, MA, Boston', CurrencyIsoCode = 'USD', Site__c=testsite.id);
        examSite.Exam__c = exam.id;
        examSite.Exam_Part__c = examPart.Id;
        insert examSite;
        System.debug('Inserted Exam_Sites__c examSite: ' + examSite.Id);
        
        // Create EPP Deal
        EPP_Deal__c eppDeal = new EPP_Deal__c();
        eppDeal.EPP_Account__c = eppAccount.Id;
        eppDeal.Exam_Year__c = year;
        eppDeal.Report_Download_Type_1__c = 'January';
        eppDeal.Report_Download_DateTime_1__c = System.now();
        eppDeal.Status__c = 'Active';
        insert eppDeal;
        System.debug('Inserted EPP_Deal__c eppDeal: ' + eppDeal.Id + ', EPP_Account__c: ' + eppDeal.EPP_Account__c + ', Exam_Year__c: ' + eppDeal.Exam_Year__c);
        
        // Create Team_Registration__c (B2B Deal) for B2B_Deal_Item__c
        Team_Registration__c teamReg = new Team_Registration__c(
            Name = 'Test Team Reg',
            Exam_Type__c = 'FRM I',
            Seats_Allowed__c = 10,
            Start_Date__c = system.today().addDays(-1),
            End_Date__c = system.today().addDays(30),
            Payment_Status__c = 'Paid',
            Status__c = 'Approved',
            Contact__c = contact.Id
        );
        teamReg.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Team_Registration__c', 'B2B Deal');
        insert teamReg;
        System.debug('Inserted Team_Registration__c teamReg: ' + teamReg);
        
        // Create B2B_Deal_Item__c
        B2B_Deal_Item__c b2bDealItem = new B2B_Deal_Item__c(
            B2B_Deal__c = teamReg.Id,
            EPP_Deal__c = eppDeal.Id,
            Exam_Type__c = 'FRM I',
            Seats_Allowed__c = 10,
            Access_Code__c = 'TEST123',
            Start_Date__c = system.today().addDays(-2),
            End_Date__c = system.today().addDays(2)
        );
        b2bDealItem.RecordTypeId = RecordTypeHelper.GetRecordTypeId('B2B_Deal_Item__c', 'Exams & Courses');
        insert b2bDealItem;
        System.debug('Inserted B2B_Deal_Item__c b2bDealItem: ' + b2bDealItem);
       
        // Create Affiliate_Program__c
        Affiliate_Program__c affProgram = new Affiliate_Program__c(
            EPP_Deal__c = eppDeal.Id,
            Product__c = 'FRM Exam',
            Affiliate_Code__c = 'AFF123',
            Start_Date__c = system.today().addDays(-1),
            End_Date__c = system.today().addDays(30)
        );
        insert affProgram;
        System.debug('Inserted Affiliate_Program__c affProgram: ' + affProgram);
        
        // Create Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test EPP Opportunity',
            AccountId = account.Id,
            StageName = 'Closed Won',
            CloseDate = system.today() + 30,
            Affiliate_Program__c = affProgram.Id,
            EPP_Deal__c = eppDeal.Id,
            B2B_Deal_Item__c = b2bDealItem.Id,
            Is_Exam_Net_New__c = True
        );
        insert testOpp;
        System.debug('Inserted Opportunity testOpp: ' + testOpp.Id);
        
         // Create Exam Attempt with only writable fields
        Exam_Attempt__c testExamAttempt = new Exam_Attempt__c(
            Name = 'Test Exam Attempt',
            Member__c = contact.Id,
            Cancelled__c = false,
            EPP_Opt_In__c = System.now(), // DateTime field
            Exam_Site__c = examSite.Id,
            Opportunity__c = testOpp.Id,
            Exam_Administration__c = examAdmin.Id,
            Exam_Part__c = examPart.Id
        );
        insert testExamAttempt;
        
        List<Exam_Attempt__c> ea = [select id, Name, Member__c, Cancelled__c, EPP_Opt_In__c, Exam_Site__c, Opportunity__c, Exam_Administration__c, Exam_Part__c,
                                    Reg_Status__c, Candidate_Region__c, Exam_Administration__r.Year__c, Exam_Administration__r.Exam_Type__c,
                                    RPT_Administration_Month__c, EPP_Deal_ID__c, EPP_Referal__c
                                    from Exam_Attempt__c where id = :testExamAttempt.Id
                                   ];
        
        testExamAttempt = ea[0];

        System.debug('testOptInReport - testExamAttempt.Id: ' + testExamAttempt.Id);
        System.debug('testOptInReport - testExamAttempt.EPP_Opt_In__c: ' + testExamAttempt.EPP_Opt_In__c);
        System.debug('testOptInReport - testExamAttempt.Reg_Status__c: ' + testExamAttempt.Reg_Status__c);
        System.debug('testOptInReport - testExamAttempt.Cancelled__c: ' + testExamAttempt.Cancelled__c);
        System.debug('testOptInReport - testExamAttempt.Candidate_Region__c: ' + testExamAttempt.Candidate_Region__c);
        System.debug('testOptInReport - Exam_Administration__r.Exam_Type__c: ' + testExamAttempt.Exam_Administration__r.Exam_Type__c);
        System.debug('testOptInReport - Exam_Administration__r.Year__c: ' + testExamAttempt.Exam_Administration__r.Year__c);
        System.debug('testOptInReport - testExamAttempt.RPT_Administration_Month__c: ' + testExamAttempt.RPT_Administration_Month__c);
        
        System.debug('testOptInReport - testExamAttempt.EPP_Deal_ID__c: ' + testExamAttempt.EPP_Deal_ID__c);
        System.debug('testOptInReport - testExamAttempt.EPP_Referal__c: ' + testExamAttempt.EPP_Referal__c);
        System.debug('testOptInReport - testExamAttempt.EPP_Opt_In__c: ' + testExamAttempt.EPP_Opt_In__c);
        
        test.startTest();
        System.runAs(user){
            
            List<Affiliate_Program__c> lstAff = [select id from Affiliate_Program__c];
            System.debug('lstAff: ' + lstAff);

            List<B2B_Deal_Item__c> lstb2b = [select id from B2B_Deal_Item__c];
            System.debug('lstb2b: ' + lstb2b);
            
            GARP_EPPPortal epppage = new GARP_EPPPortal();
            epppage.init();
        }
        test.stopTest();
    }


    // --- Error tests: No member contract (all contracts canceled), then runAs(user), call methods with NULL/False params. 10 methods per test. ---

    @isTest
    static void unitTest_Errors1() {
        setup();
        test.startTest();
        List<Contract> lstContracts = [SELECT Id, Status, RecordTypeId FROM Contract];
        for (Contract c : lstContracts) { c.Status = 'Canceled'; }
        update lstContracts;
        System.runAs(user) {
            GARP_MS_MemberPortal.getNavBarInfo();
            GARP_MS_MemberPortal.getDashboardInfo(null);
            GARP_MS_MemberPortal.getComponentUpdateProfileInfo();
            GARP_MS_MemberPortal.getProfileDemographicsFormInfo();
            GARP_MS_MemberPortal.setProfileDemographicsFormInfo(null);
            GARP_MS_MemberPortal.muteProfileComponent(false);
            GARP_MS_MemberPortal.getProfilePersonalFormInfo();
            GARP_MS_MemberPortal.setProfilePersonalInfo(null);
            GARP_MS_MemberPortal.getProfileMembershipInfo();
            GARP_MS_MemberPortal.setAutorenewMembershipOff();
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Errors2() {
        setup();
        test.startTest();
        List<Contract> lstContracts = [SELECT Id, Status, RecordTypeId FROM Contract];
        for (Contract c : lstContracts) { c.Status = 'Canceled'; }
        update lstContracts;
        System.runAs(user) {
            GARP_MS_MemberPortal.enableAutoRenew();
            GARP_MS_MemberPortal.getProfileChaptersInfo();
            GARP_MS_MemberPortal.setProfileChaptersInfo(null, null);
            GARP_MS_MemberPortal.getProfileExpertiseInfo();
            GARP_MS_MemberPortal.setProfileExpertiseInfo(null);
            GARP_MS_MemberPortal.getComponentNewNotificationsInfo();
            GARP_MS_MemberPortal.getAllNotifications();
            GARP_MS_MemberPortal.getDirectorySearchFormInfo();
            GARP_MS_MemberPortal.searchMemberDirectory(null);
            GARP_MS_MemberPortal.getMemberDirectorySettingsFormInfo();
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Errors3() {
        setup();
        test.startTest();
        List<Contract> lstContracts = [SELECT Id, Status, RecordTypeId FROM Contract];
        for (Contract c : lstContracts) { c.Status = 'Canceled'; }
        update lstContracts;
        System.runAs(user) {
            GARP_MS_MemberPortal.setMemberDirectorySettingsFormInfo(null);
            GARP_MS_MemberPortal.sendMemberDirectoryMessage(null);
            GARP_MS_MemberPortal.getPurchaseHistoryInfo();
            GARP_MS_MemberPortal.getMembershipPageInfo();
            GARP_MS_MemberPortal.submitCustomerCase('title', 'description');
            GARP_MS_MemberPortal.setEmailPreferenceUpdate();
            GARP_MS_MemberPortal.getComponentCPDInfo(null);
            GARP_MS_MemberPortal.getCPDClaimFormInfo();
            GARP_MS_MemberPortal.getCPDListingInfo();
            GARP_MS_MemberPortal.setCPDClaimInfo(null);
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Errors4() {
        setup();
        test.startTest();
        List<Contract> lstContracts = [SELECT Id, Status, RecordTypeId FROM Contract];
        for (Contract c : lstContracts) { c.Status = 'Canceled'; }
        update lstContracts;
        System.runAs(user) {
            GARP_MS_MemberPortal.deleteCPDClaim(null);
            GARP_MS_MemberPortal.setCPDAttestation(null);
            GARP_MS_MemberPortal.getCPDActivitiesBrowseFormInfo(null, null);
            GARP_MS_MemberPortal.setCPDActivityAsClaim(null);
            GARP_MS_MemberPortal.getExamSetupFormInfo('frm');
            GARP_MS_MemberPortal.getExamSetupExamSelectionInfo('frm', null);
            GARP_MS_MemberPortal.getExamSetupFeesCheckoutInfo(null);
            GARP_MS_MemberPortal.examSetupAuthorizeRegistrations('frm', false);
            GARP_MS_MemberPortal.getExamSetupIDInfo('frm', null);
            GARP_MS_MemberPortal.setExamSetupIDInfo('frm', null, null);
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Errors5() {
        setup();
        test.startTest();
        List<Contract> lstContracts = [SELECT Id, Status, RecordTypeId FROM Contract];
        for (Contract c : lstContracts) { c.Status = 'Canceled'; }
        update lstContracts;
        System.runAs(user) {
            GARP_MS_MemberPortal.getStudyMaterialListing();
            GARP_MS_MemberPortal.getOrderInfo(null);
            GARP_MS_MemberPortal.cancelUnpaidOrder(null);
            GARP_MS_MemberPortal.getCVPageInfo('FRM');
            GARP_MS_MemberPortal.getWorkExperienceInfo('FRM', null);
            GARP_MS_MemberPortal.setWorkExperienceInfo('FRM', null, null);
            GARP_MS_MemberPortal.deleteWorkExperienceInfo('FRM', null);
            GARP_MS_MemberPortal.setCVAddressInfo('FRM', null, null, null);
            GARP_MS_MemberPortal.submitCVInfo('FRM');
            GARP_MS_MemberPortal.getAlertBarInfo(null);
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Errors6() {
        setup();
        test.startTest();
        List<Contract> lstContracts = [SELECT Id, Status, RecordTypeId FROM Contract];
        for (Contract c : lstContracts) { c.Status = 'Canceled'; }
        update lstContracts;
        System.runAs(user) {
            GARP_MS_MemberPortal.getComponentEnrolledProgramsInfo();
            GARP_MS_MemberPortal.getProgramsListingInfo(null);
            GARP_MS_MemberPortal.getFRRProgramDetailInfo();
            GARP_MS_MemberPortal.getFFRProgramDetailInfo();
            GARP_MS_MemberPortal.getFRMProgramDetailInfo(null);
            GARP_MS_MemberPortal.getSCRProgramDetailInfo(null);
            GARP_MS_MemberPortal.getRAIProgramDetailInfo(null);
            GARP_MS_MemberPortal.getRAIJProgramDetailInfo(null);
            GARP_MS_MemberPortal.EPPOptIn('frm', false);
            GARP_MS_MemberPortal.getExamResultsListing(null);
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Errors7() {
        setup();
        test.startTest();
        List<Contract> lstContracts = [SELECT Id, Status, RecordTypeId FROM Contract];
        for (Contract c : lstContracts) { c.Status = 'Canceled'; }
        update lstContracts;
        System.runAs(user) {
            GARP_MS_MemberPortal.setExamResultLastViewDate(null);
            GARP_MS_MemberPortal.getComponentUpcomingEventsInfo();
            GARP_MS_MemberPortal.getEventsListingInfo();
            GARP_MS_MemberPortal.getComponentAdInfo();
            GARP_MS_MemberPortal.getMyEBooksInfo();
            GARP_MS_MemberPortal.getEBookAccessURLs(null);
            GARP_MS_MemberPortal.getEBookAccessURL(null);
            GARP_MS_MemberPortal.getErrataFormInfo('frm');
            GARP_MS_MemberPortal.submitErrataForm(null);
            GARP_MS_MemberPortal.getBenchPrepLinks();
        }
        test.stopTest();
    }

    // --- Exception tests: setupThrow() (user with Contact FirstName = 'Throw'), then runAs(user), call methods with NULL/False params. 10 methods per test. ---

    @isTest
    static void unitTest_Exceptions1() {
        setupThrow();
        test.startTest();
        System.runAs(user) {
            GARP_MS_MemberPortal.getNavBarInfo();
            GARP_MS_MemberPortal.getDashboardInfo(null);
            GARP_MS_MemberPortal.getComponentUpdateProfileInfo();
            GARP_MS_MemberPortal.getProfileDemographicsFormInfo();
            GARP_MS_MemberPortal.setProfileDemographicsFormInfo(null);
            GARP_MS_MemberPortal.muteProfileComponent(false);
            GARP_MS_MemberPortal.getProfilePersonalFormInfo();
            GARP_MS_MemberPortal.setProfilePersonalInfo(null);
            GARP_MS_MemberPortal.getProfileMembershipInfo();
            GARP_MS_MemberPortal.setAutorenewMembershipOff();
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Exceptions2() {
        setupThrow();
        test.startTest();
        System.runAs(user) {
            GARP_MS_MemberPortal.enableAutoRenew();
            GARP_MS_MemberPortal.getProfileChaptersInfo();
            GARP_MS_MemberPortal.setProfileChaptersInfo(null, null);
            GARP_MS_MemberPortal.getProfileExpertiseInfo();
            GARP_MS_MemberPortal.setProfileExpertiseInfo(null);
            GARP_MS_MemberPortal.getComponentNewNotificationsInfo();
            GARP_MS_MemberPortal.getAllNotifications();
            GARP_MS_MemberPortal.getDirectorySearchFormInfo();
            GARP_MS_MemberPortal.searchMemberDirectory(null);
            GARP_MS_MemberPortal.getMemberDirectorySettingsFormInfo();
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Exceptions3() {
        setupThrow();
        test.startTest();
        System.runAs(user) {
            GARP_MS_MemberPortal.setMemberDirectorySettingsFormInfo(null);
            GARP_MS_MemberPortal.sendMemberDirectoryMessage(null);
            GARP_MS_MemberPortal.getPurchaseHistoryInfo();
            GARP_MS_MemberPortal.getMembershipPageInfo();
            GARP_MS_MemberPortal.submitCustomerCase('title', 'description');
            GARP_MS_MemberPortal.setEmailPreferenceUpdate();
            GARP_MS_MemberPortal.setSMSPreferenceUpdate(false, false);
            GARP_MS_MemberPortal.uploadMemberPhoto(null, null, null);
            GARP_MS_MemberPortal.setMemberPhoto(null);
            GARP_MS_MemberPortal.removeMemberPhoto();
            GARP_MS_MemberPortal.getComponentCPDInfo(null);
            GARP_MS_MemberPortal.getCPDClaimFormInfo();
            GARP_MS_MemberPortal.getCPDListingInfo();
            GARP_MS_MemberPortal.setCPDClaimInfo(null);
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Exceptions4() {
        setupThrow();
        test.startTest();
        System.runAs(user) {
            GARP_MS_MemberPortal.deleteCPDClaim(null);
            GARP_MS_MemberPortal.setCPDAttestation(null);
            GARP_MS_MemberPortal.getCPDActivitiesBrowseFormInfo(null, null);
            GARP_MS_MemberPortal.setCPDActivityAsClaim(null);
            GARP_MS_MemberPortal.getExamSetupFormInfo('frm');
            GARP_MS_MemberPortal.getExamSetupExamSelectionInfo('frm', null);
            GARP_MS_MemberPortal.getExamSetupFeesCheckoutInfo(null);
            GARP_MS_MemberPortal.examSetupAuthorizeRegistrations('frm', false);
            GARP_MS_MemberPortal.getExamSetupIDInfo('frm', null);
            GARP_MS_MemberPortal.setExamSetupIDInfo('frm', null, null);
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Exceptions5() {
        setupThrow();
        test.startTest();
        System.runAs(user) {
            GARP_MS_MemberPortal.getStudyMaterialListing();
            GARP_MS_MemberPortal.getOrderInfo(null);
            GARP_MS_MemberPortal.cancelUnpaidOrder(null);
            GARP_MS_MemberPortal.getCVPageInfo('FRM');
            GARP_MS_MemberPortal.getWorkExperienceInfo('FRM', null);
            GARP_MS_MemberPortal.setWorkExperienceInfo('FRM', null, null);
            GARP_MS_MemberPortal.deleteWorkExperienceInfo('FRM', null);
            GARP_MS_MemberPortal.setCVAddressInfo('FRM', null, null, null);
            GARP_MS_MemberPortal.submitCVInfo('FRM');
            GARP_MS_MemberPortal.getAlertBarInfo(null);
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Exceptions6() {
        setupThrow();
        test.startTest();
        System.runAs(user) {
            GARP_MS_MemberPortal.getComponentEnrolledProgramsInfo();
            GARP_MS_MemberPortal.getProgramsListingInfo(null);
            GARP_MS_MemberPortal.getFRRProgramDetailInfo();
            GARP_MS_MemberPortal.getFFRProgramDetailInfo();
            GARP_MS_MemberPortal.getFRMProgramDetailInfo(null);
            GARP_MS_MemberPortal.getSCRProgramDetailInfo(null);
            GARP_MS_MemberPortal.getRAIProgramDetailInfo(null);
            GARP_MS_MemberPortal.getRAIJProgramDetailInfo(null);
            GARP_MS_MemberPortal.EPPOptIn('frm', false);
            GARP_MS_MemberPortal.getExamResultsListing(null);
        }
        test.stopTest();
    }

    @isTest
    static void unitTest_Exceptions7() {
        setupThrow();
        test.startTest();
        System.runAs(user) {
            GARP_MS_MemberPortal.setExamResultLastViewDate(null);
            GARP_MS_MemberPortal.getComponentUpcomingEventsInfo();
            GARP_MS_MemberPortal.getEventsListingInfo();
            GARP_MS_MemberPortal.getComponentAdInfo();
            GARP_MS_MemberPortal.getMyEBooksInfo();
            GARP_MS_MemberPortal.getEBookAccessURLs(null);
            GARP_MS_MemberPortal.getEBookAccessURL(null);
            GARP_MS_MemberPortal.getErrataFormInfo('frm');
            GARP_MS_MemberPortal.submitErrataForm(null);
            GARP_MS_MemberPortal.getBenchPrepLinks();
        }
        test.stopTest();
    }

    // --- No RunAs: call GARP_MS_MemberPortal methods without RunAs (running user is not Customer Community; each returns 403). ~10 methods per test. ---

    @isTest
    static void unitTest_MS_NoRunAs_1() {
        test.startTest();
        GARP_MS_MemberPortal.getNavBarInfo();
        GARP_MS_MemberPortal.getDashboardInfo(null);
        GARP_MS_MemberPortal.getComponentUpdateProfileInfo();
        GARP_MS_MemberPortal.getProfileDemographicsFormInfo();
        GARP_MS_MemberPortal.setProfileDemographicsFormInfo(null);
        GARP_MS_MemberPortal.muteProfileComponent(false);
        GARP_MS_MemberPortal.getProfilePersonalFormInfo();
        GARP_MS_MemberPortal.setProfilePersonalInfo(null);
        GARP_MS_MemberPortal.uploadMemberPhoto(null, null, null);
        GARP_MS_MemberPortal.setMemberPhoto(null);
        test.stopTest();
    }

    @isTest
    static void unitTest_MS_NoRunAs_2() {
        test.startTest();
        GARP_MS_MemberPortal.removeMemberPhoto();
        GARP_MS_MemberPortal.setEmailPreferenceUpdate();
        GARP_MS_MemberPortal.setSMSPreferenceUpdate(false, false);
        GARP_MS_MemberPortal.getProfileMembershipInfo();
        GARP_MS_MemberPortal.setAutorenewMembershipOff();
        GARP_MS_MemberPortal.enableAutoRenew();
        GARP_MS_MemberPortal.getProfileChaptersInfo();
        GARP_MS_MemberPortal.setProfileChaptersInfo(null, null);
        GARP_MS_MemberPortal.getProfileExpertiseInfo();
        GARP_MS_MemberPortal.setProfileExpertiseInfo(null);
        test.stopTest();
    }

    @isTest
    static void unitTest_MS_NoRunAs_3() {
        test.startTest();
        GARP_MS_MemberPortal.getComponentNewNotificationsInfo();
        GARP_MS_MemberPortal.getAllNotifications();
        GARP_MS_MemberPortal.getComponentCPDInfo(null);
        GARP_MS_MemberPortal.getCPDListingInfo();
        GARP_MS_MemberPortal.getCPDClaimFormInfo();
        GARP_MS_MemberPortal.setCPDClaimInfo(null);
        GARP_MS_MemberPortal.deleteCPDClaim(null);
        GARP_MS_MemberPortal.setCPDAttestation(null);
        GARP_MS_MemberPortal.getCPDActivitiesBrowseFormInfo(null, null);
        GARP_MS_MemberPortal.setCPDActivityAsClaim(null);
        test.stopTest();
    }

    @isTest
    static void unitTest_MS_NoRunAs_4() {
        test.startTest();
        GARP_MS_MemberPortal.getCVPageInfo(null);
        GARP_MS_MemberPortal.getWorkExperienceInfo(null, null);
        GARP_MS_MemberPortal.setWorkExperienceInfo(null, null, null);
        GARP_MS_MemberPortal.deleteWorkExperienceInfo(null, null);
        GARP_MS_MemberPortal.setCVAddressInfo(null, null, null, null);
        GARP_MS_MemberPortal.submitCVInfo(null);
        GARP_MS_MemberPortal.getComponentEnrolledProgramsInfo();
        GARP_MS_MemberPortal.getProgramsListingInfo(null);
        GARP_MS_MemberPortal.getFRRProgramDetailInfo();
        GARP_MS_MemberPortal.getFRR25ProgramDetailInfo();
        test.stopTest();
    }

    @isTest
    static void unitTest_MS_NoRunAs_5() {
        test.startTest();
        GARP_MS_MemberPortal.getMicroCourseProgramDetailInfo(null);
        GARP_MS_MemberPortal.getFFRProgramDetailInfo();
        GARP_MS_MemberPortal.getFRMProgramDetailInfo(null);
        GARP_MS_MemberPortal.getERPProgramDetailInfo(null);
        GARP_MS_MemberPortal.getSCRProgramDetailInfo(null);
        GARP_MS_MemberPortal.getRAIProgramDetailInfo(null);
        GARP_MS_MemberPortal.getRAIJProgramDetailInfo(null);
        GARP_MS_MemberPortal.EPPOptIn(null, false);
        GARP_MS_MemberPortal.getExamResultsListing(null);
        GARP_MS_MemberPortal.setExamResultLastViewDate(null);
        test.stopTest();
    }

    @isTest
    static void unitTest_MS_NoRunAs_6() {
        test.startTest();
        GARP_MS_MemberPortal.getExamSetupFormInfo(null);
        GARP_MS_MemberPortal.getExamSetupExamSelectionInfo(null, null);
        GARP_MS_MemberPortal.getExamSetupFeesCheckoutInfo(null);
        GARP_MS_MemberPortal.getExamSetupIDInfo(null, null);
        GARP_MS_MemberPortal.setExamSetupIDInfo(null, null, null);
        GARP_MS_MemberPortal.examSetupAuthorizeRegistrations(null, false);
        GARP_MS_MemberPortal.getAlertBarInfo(null);
        GARP_MS_MemberPortal.getComponentUpcomingEventsInfo();
        GARP_MS_MemberPortal.getEventsListingInfo();
        GARP_MS_MemberPortal.getBenchPrepLinks();
        test.stopTest();
    }

    @isTest
    static void unitTest_MS_NoRunAs_7() {
        test.startTest();
        GARP_MS_MemberPortal.getComponentAdInfo();
        GARP_MS_MemberPortal.getStudyMaterialListing();
        GARP_MS_MemberPortal.getMyEBooksInfo();
        GARP_MS_MemberPortal.getEBookAccessURLs(null);
        GARP_MS_MemberPortal.getEBookAccessURL(null);
        GARP_MS_MemberPortal.getErrataFormInfo(null);
        GARP_MS_MemberPortal.submitErrataForm(null);
        GARP_MS_MemberPortal.attachFileErrataSubmission(null, null, null, null);
        GARP_MS_MemberPortal.getDirectorySearchFormInfo();
        GARP_MS_MemberPortal.searchMemberDirectory(null);
        test.stopTest();
    }

    @isTest
    static void unitTest_MS_NoRunAs_8() {
        test.startTest();
        GARP_MS_MemberPortal.getMemberDirectorySettingsFormInfo();
        GARP_MS_MemberPortal.setMemberDirectorySettingsFormInfo(null);
        GARP_MS_MemberPortal.sendMemberDirectoryMessage(null);
        GARP_MS_MemberPortal.getPurchaseHistoryInfo();
        GARP_MS_MemberPortal.getOrderInfo(null);
        GARP_MS_MemberPortal.cancelUnpaidOrder(null);
        GARP_MS_MemberPortal.payPendingOrder(null);
        GARP_MS_MemberPortal.getMembershipPageInfo();
        GARP_MS_MemberPortal.submitCustomerCase(null, null);
        GARP_MS_MemberPortal.getOSTAIDInfo();
        test.stopTest();
    }

    @isTest
    static void unitTest_MS_NoRunAs_9() {
        test.startTest();
        GARP_MS_MemberPortal.setOSTAIDInfo(null);
        GARP_MS_MemberPortal.uploadWorkExperienceAttachment(null, null, null);
        GARP_MS_MemberPortal.deleteWorkExperienceAttachment(null);
        GARP_MS_MemberPortal.getWorkExperienceAttachments(null);
        GARP_MS_MemberPortal.downloadWorkExperienceAttachment(null);
        GARP_MS_MemberPortal.isContactRequiredToHaveDocuments(null, null);
        test.stopTest();
    }

}