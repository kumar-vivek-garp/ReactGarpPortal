@isTest
public class GBI_Studies_test {

    static String studyId;
    static String userEmail;
    static String studyVoteId;
    static String studyVoteQuestionId;
    static String surveyId;
    static String questionId;
    static GBI_MS_Studies.getNextSurveyQuestionData surveyData;
    static String surveyAnswer;
    static Id attachmentId;
    
    // Legacy Test Items
    static Account acc,acc1;
    static Contact contact,con;
    static Profile profile;
    static User user;
    static User user1;
    static User u;
    
    static FAQ_Category__c gbiFAQ;
    static FAQ_Section__c gbiFAQSection;
    static FAQ_Subsection__c gbiFAQSubSec;    
    static FAQ_Category__c studyFAQ;
    static FAQ_Section__c studyFAQSection;
    static FAQ_Subsection__c studyFAQSubSec;
    
    static Study__c study;
    static Study__c study2;
    static Disclosure_Protocol__c Dis_Pro;
    static Study_Disclose_Protocol_Submission__c dp;
    static Study_Contact__c sc;
    static Study_Contact__c sc1;
    static Study_Account__c sa;
    static Study_Round__c sr;
    static Study_Vote__c sv;
    static Study_Vote_Question__c svq;
    static Study_Contact_Vote__c scv;
    static Study_Data_Submission__c sds;
    static Study_Document__c sd;
    static Study_Document__c sd1;
    static Study_Document__c sd2;
    
    static Study_Survey__c ss1;
    static Study_Survey__c ss2;
    static Study_Survey_Question__c sq1;
    static Study_Survey_Question__c sq2;
    static Study_Survey_Answer__c sa1;
    static Study_Survey_Choice__c ssc1;
    static Study_Survey_Submission__c sss;
    static GBI_MS_Studies.getUserReturnData getUserReturnData;
    static GBI_MS_Studies.getSudiesReturnData getSudiesReturnData;
    
    static Attachment attach;
    
    static void testData() {
        
        Acc = new Account(Name = 'test', GBI_Region__c='North America'); 
        insert acc;
        
        //rd.gbiMetaData = [select Id, Name, G_SIB__c, Year__c, Account__c from GBI_Meta_Data__c];
        
        GBI_Meta_Data__c gmd = new GBI_Meta_Data__c(Name='Meta',G_SIB__c=True,Year__c='2018', Account__c=acc.Id);
        insert gmd;
        
        con = new Contact(
            GBI_Participant__c = TRUE,
            KPI_ERP_Certified__c = TRUE,
            KPI_FRM_Certified__c = TRUE,
            GARP_Directory_Opt_In__c = TRUE,
            lastname = 'Test',
            AccountId = acc.id,
            email='gbi_qa1@garpqa.com',
            KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17)
        );
        
        insert con;
        
        profile = [SELECT Id FROM Profile WHERE id = '00e400000017dA8' limit 1]; 
        
        //user = [select Id, Email from User where contactId = :con.Id];
        
        //user1 = new User(Alias = 'newUser', Email='newuser@testorg.com', contactId = contact1.id,EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
        //insert user1;
        
        
        acc1 = new Account(Name = 'GARP');
        insert acc1;
        
        contact = new Contact(GBI_Participant__c = TRUE,KPI_ERP_Certified__c = TRUE,KPI_FRM_Certified__c = true,
                              GARP_Directory_Opt_In__c = true,lastname = 'Testdhaskd',
                              AccountId = acc.id,email='gbi_qa@garpqa.com',
                              KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),
                              Name_As_it_Appears_On_ID__c = 'testtest' ,
                              ID_Number__c = 'dasf123l',ID_Type__c = 'Passport');
        insert contact;
        
        profile = [SELECT Id FROM Profile WHERE id = '00e400000017dA8' limit 1]; 
        
        //user u = [select Id, contactId,Email,AccountID from User where contactId = :con.Id];
        
        /*u = new User(Alias = 'newUser', Email='newuser@testorg.com', contactId = con.id,
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = profile.Id, parentid = user.id,TimeZoneSidKey='America/Los_Angeles',
UserName='newuser@testorg.com');*/
        
        u = new User(Alias = 'newUser', Email='gbi_qa@garpqa.com', 
                     contactId = contact.id,EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles', 
                     UserName='newuser@testorg.com');
        insert u;
        
        studyFAQ = new FAQ_Category__c(Name='GBI');
        insert studyFAQ;
        
        studyFAQSection = new FAQ_Section__c(Name='GBI Sec', FAQ_Category__c=studyFAQ.Id);
        insert studyFAQSection;
        
        studyFAQSubSec = new FAQ_Subsection__c(Name='GBI SubSec', FAQ_Category__c=studyFAQ.Id, FAQ_Section__c=studyFAQSection.Id);
        insert studyFAQSubSec;
        
        gbiFAQ = new FAQ_Category__c(Name='GBI');
        insert gbiFAQ;
        
        gbiFAQSection = new FAQ_Section__c(Name='GBI Sec', FAQ_Category__c=gbiFAQ.Id);
        insert gbiFAQSection;
        
        gbiFAQSubSec = new FAQ_Subsection__c(Name='GBI SubSec', FAQ_Category__c=gbiFAQ.Id, FAQ_Section__c=gbiFAQSection.Id);
        insert gbiFAQSubSec;
        
        studyFAQ = new FAQ_Category__c(Name='GBI');
        insert studyFAQ;
        
        studyFAQSection = new FAQ_Section__c(Name='GBI Sec', FAQ_Category__c=studyFAQ.Id);
        insert studyFAQSection;
        
        studyFAQSubSec = new FAQ_Subsection__c(Name='GBI SubSec', FAQ_Category__c=studyFAQ.Id, FAQ_Section__c=studyFAQSection.Id);
        insert studyFAQSubSec;
        
        gbiFAQ = new FAQ_Category__c(Name='GBI');
        insert gbiFAQ;
        
        gbiFAQSection = new FAQ_Section__c(Name='GBI Sec', FAQ_Category__c=gbiFAQ.Id);
        insert gbiFAQSection;
        
        gbiFAQSubSec = new FAQ_Subsection__c(Name='GBI SubSec', FAQ_Category__c=gbiFAQ.Id, FAQ_Section__c=gbiFAQSection.Id);
        insert gbiFAQSubSec;
        
        study = new Study__c(Name='study1', FAQ_Category__c=studyFAQ.Id, Status__c='In Progress', Secure_File_Integration_Status__c = 'Enabled', Start_Date__c = Date.today().addDays(-30));
        insert study;
        
        study2 = new Study__c(Name='study2', FAQ_Category__c=studyFAQ.Id, Status__c='In Progress',
                              Secure_File_Integration_Status__c = 'Enabled',Study_Fee__c=100.0,Payment_Required__c = true, Start_Date__c = Date.today().addDays(-30));
        insert study2;
        
        Dis_Pro = new Disclosure_Protocol__c(Study__c = study.id,DP_Status__c = 'Active');
        insert Dis_Pro;
        
        Study_NDA__c nda = new Study_NDA__c(Account__c = acc1.Id, Status__c = 'Signed', Latest_NDA_Dated_Date__c = Date.today().addDays(-30));
        insert nda;
        
        Study_NDA__c nda1 = new Study_NDA__c(Account__c = Acc.Id, Status__c = 'Signed', Latest_NDA_Dated_Date__c = Date.today().addDays(-30));
        insert nda1;
        
        sa = new Study_Account__c(Name='SA', Role__c='Participant', Status__c='Active', Study__c=study.Id, Account__c=Acc.Id, Secure_File_Platform__c = 'ShareFile;AWS');
        insert sa;
        
        sc = new Study_Contact__c(Name='QA',Role__c='Voter', Status__c='Active', Study__c=study.Id, Contact__c=contact.Id, Study_Account__c=sa.Id);
        insert sc;

        Study_Account__c sa2 = new Study_Account__c(Name='SA', Role__c='Participant', Status__c='Active', Study__c=study2.Id, Account__c=Acc.Id, Secure_File_Platform__c = 'ShareFile;AWS');
        insert sa2;
        
        sc1 = new Study_Contact__c(Name='QA2',Role__c='Voter', Status__c='Active', Study__c=study2.Id, Contact__c=con.Id, Study_Account__c=sa2.Id);
        insert sc1;
        
        dp = new Study_Disclose_Protocol_Submission__c(Name='dp', Study_Contact__c=sc.Id, Study__c=study.Id, Study_Account__c=sa.Id, Disclosure_Protocol__c = Dis_Pro.Id);
        insert dp; 
        
        sr = new Study_Round__c(Name='SR', Round__c='Version 1', Status__c='Data Collection', Study__c=study.Id);        
        insert sr;
        
        sv = new Study_Vote__c(Name='SV', Start_Date__c=system.today(), End_Date__c=system.today()+20, Status__c='Opened', Study__c=study.Id);
        insert sv;
        
        svq = new Study_Vote_Question__c(Name='SQv', Question__c='Why?', Answers__c='Yes\nNo', Study_Vote__c=sv.Id);
        insert svq;
        
        scv = new Study_Contact_Vote__c(Study_Contact__c=sc.Id, Study_Account__c=sa.Id, Study_Vote_Question__c=svq.Id, Vote__c='Yes', Vote_Made_Date_Time__c=system.now());
        insert scv;
        
        sds = new Study_Data_Submission__c(Study_Account__c=sa.Id, Submission_Date_Time__c=system.now(), Study_Round__c=sr.Id);
        insert sds;
        
        sd = new Study_Document__c(Name='SD', Study__c=study.Id, Date_Added__c=system.today());
        insert sd;
        
        sd1 = new Study_Document__c(Name='SD1', Study__c=study.Id, Account__c=acc.ID, Date_Added__c=system.today());        
        insert sd1;
        
        sd2 = new Study_Document__c(Name='SD2', Date_Added__c=system.today());
        insert sd2;

        ss1 = new Study_Survey__c(Name='SS1', Status__c='Active', Study__c=study.Id);
        insert ss1;
        
        sq1 = new Study_Survey_Question__c(Name='SQ1', Is_First_Question__c=True, Question__c='ABC?', Study_Survey__c=ss1.Id);
        insert sq1;
        
        ssc1 = new Study_Survey_Choice__c(Name='SC1', Choice__c='123', Study_Survey_Question__c=sq1.Id);
        insert ssc1;
        
        sa1 = new Study_Survey_Answer__c(Name='SA1', Study_Account__c=sa.Id, Study_Contact__c=sc.Id, Study_Survey_Question__c=sq1.Id);        
        insert sa1;
        
        //sss = new Study_Survey_Submission__c(Status__c='Submitted',Study_Account__c = sa.Id,Study_Survey__c = ss1.Id);
        //insert sss;
        //System.debug('sss:' + sss);
        
        attach = new Attachment(Name='Attach', ParentId=contact.Id, Body=Blob.valueOf('xyz'));
        insert attach;
        
        // Set Params for calls
        studyId = study.Id;
        userEmail = 'gbi_qa@garpqa.com';
        studyVoteId = sv.Id;
        studyVoteQuestionId = svq.Id;
        surveyId = ss1.Id;
        questionId = sq1.Id;
        //static GBI_MS_Studies.getNextSurveyQuestionData surveyData;
        surveyAnswer = sa1.Id;
        attachmentId = attach.Id;
        
    }
    
    static void setupShareFileConfig() {
        Sharefile_API_Config__c AuthEmail = new Sharefile_API_Config__c();
        AuthEmail.Name = 'AuthEmail';
        AuthEmail.Value__c = 'a@a.com';
        
        Sharefile_API_Config__c AuthPassword = new Sharefile_API_Config__c();
        AuthPassword.Name = 'AuthPassword';
        AuthPassword.Value__c = '12345';
        
        Sharefile_API_Config__c AuthClientId = new Sharefile_API_Config__c();
        AuthClientId.Name = 'AuthClientId';
        AuthClientId.Value__c = 'asdfafsadf';
        
        Sharefile_API_Config__c AuthClientSecret = new Sharefile_API_Config__c();
        AuthClientSecret.Name = 'AuthClientSecret';
        AuthClientSecret.Value__c = '1z223x2x';
        
        Sharefile_API_Config__c LoginEndPoint = new Sharefile_API_Config__c();
        LoginEndPoint.Name = 'LoginEndPoint';
        LoginEndPoint.Value__c = 'https://abc.com/api';
        
        Sharefile_API_Config__c BaseEndPoint = new Sharefile_API_Config__c();
        BaseEndPoint.Name = 'BaseEndPoint';
        BaseEndPoint.Value__c = 'https://abc.com/api';
        
        Sharefile_API_Config__c BaseFolderID = new Sharefile_API_Config__c();
        BaseFolderID.Name = 'BaseFolderID';
        BaseFolderID.Value__c = '43243243';
        
        Sharefile_API_Config__c ZoneId = new Sharefile_API_Config__c();
        ZoneId.Name = 'ZoneId';
        ZoneId.Value__c = '43243243';
        
        Sharefile_API_Config__c uploadLogin = new Sharefile_API_Config__c();
        uploadLogin.Name = 'Upload_RequireLogin';
        uploadLogin.Value__c = 'true';
        
        Sharefile_API_Config__c uploadInfo = new Sharefile_API_Config__c();
        uploadInfo.Name = 'Upload_RequireInfo';
        uploadInfo.Value__c = 'false';
        
        Sharefile_API_Config__c uploadExpire = new Sharefile_API_Config__c();
        uploadExpire.Name = 'Upload_ExpireMins';
        uploadExpire.Value__c = '25';
        
        insert new List<Sharefile_API_Config__c> {AuthEmail, AuthPassword, AuthClientId, AuthClientSecret, LoginEndPoint, BaseEndPoint, BaseFolderID, ZoneId, uploadLogin, uploadInfo, uploadExpire};
	}
    
    static testMethod void testStudyListingA(){
        
        testData();
        test.startTest();
        
        List<GBI_MS_Studies.returnParticipatingInstitutions> ret = GBI_MS_Studies.getParticipatingInstitutions();
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getParticipatingInstitutions',ret);
        
        GBI_MS_Studies.reqStudiesList reqWrapper = new GBI_MS_Studies.reqStudiesList();
        GBI_MS_Studies.retStudiesInfo ret2 = GBI_MS_Studies.getListStudies(reqWrapper);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getListStudies',ret2);
        
        test.stopTest();
    }
    
    static testMethod void testManageUsers(){
        
        testData();
        test.startTest();
        
        sc.Can_Manage_Users__c = True;
        update sc;
        
        GBI_BC_Studies.returnGetManageUsersScreenInfo ret = GBI_MS_Studies.getManageUsersScreenInfo(studyId);
                        
        GBI_MS_Studies.getManageUsersStudies(studyId);
        GBI_MS_Studies.getManageUsersStudyContacts(studyId, study2.Id);
        
        if(ret != NULL && ret.studyContacts != NULL && !ret.studyContacts.IsEmpty()) {
            GBI_MS_Studies.ManageUsersAddContactsFromOtherStudy(studyId, ret.studyContacts);
            GBI_MS_Studies.findManageUsersStudyContacts(studyId, 'gbi_qa1@garpqa.com');
            
            GBI_MS_Studies.setManageUsersAccess(studyId, sc1.Id, False);
            GBI_MS_Studies.setManageUsersAccess(studyId, sc1.Id, True);
            
            GBI_MS_Studies.setManageUserInfo(studyId, ret.studyContacts[0]);  
        }        
        test.stopTest();
    }
    
    static testMethod void testManageUsersB(){
        
        testData();
        test.startTest();
        
        sc.Can_Manage_Users__c = True;
        update sc;
        
        GBI_MS_Studies.SetStudyContactState(studyId, sc1.Id, True);
        GBI_MS_Studies.SetStudyContactState(studyId, sc1.Id, False);
       
        GBI_BC_Studies.StudyContactInfo sci = new GBI_BC_Studies.StudyContactInfo();
        sci.name = 'Bob';
        sci.email = 'bob@email.com';
        sci.location = 'NYC';
        sci.phone = '1234567890';
        sci.roles='SME';
        sci.status = 'Proposed';
        sci.canManageUsers = False;
	    GBI_MS_Studies.setManageUserInfo(studyId, sci); 
        
        test.stopTest();
    }
    
    static testMethod void testAWSFile(){
        
        testData();
        
        GBI_Service_Config__c setting1 = new GBI_Service_Config__c();
        setting1.Name = 'AWS_Bucket';
        setting1.Value__c = 'gbibuckets';
        insert setting1;
        
        test.startTest();
        
        AWSSecureFileClass.returnUploadFile retUp = GBI_MS_Studies.uploadAWSFile(studyId, 'fileName', 'fileData', NULL, NULL, NULL, NULL, True);
    
        AWSSecureFileClass.returnGetFolder retFolder = GBI_MS_Studies.getAWSFolder(studyId);
        GBI_MS_Studies.getAWSSubFolder(studyId, '123');
        
        AWSSecureFileClass.returnDownloadFile retDownload = GBI_MS_Studies.getAWSDownloadFile(studyId, '1738348063864_6g9722clk3a', '1739544711184_4lb9n76ubhe', 0, null);
		        
        AWSSecureFileClass.returnGetQuicksightEmbedURL retQuick = GBI_MS_Studies.getAnalyticsDashboardEmbedURL(studyId);
        
        GBI_BC_Studies.AWSSecureFileSetCustomer(studyId);
        
        GBI_BC_Studies.AWSSecureFileSetUser(studyId);
        
        AWSSecureFileClass.sendUpdateUserFolderRights('authToken', 'userId', 'folderId', TRUE, TRUE);
        AWSSecureFileClass.sendGetCustomerFolders('authToken', 'customerId');
        AWSSecureFileClass.sendAddCustomer('customerName', 'customerId','bucketId', 'rootFolderId', 'authToken');
        
        List<String> lstString = new List<String>();
        lstString.add('setStudyAccount');
        lstString.add(sa.Id);
        
        List<List<String>> lstLst = new List<List<String>>();
        lstLst.add(lstString);
        
        AWSSecureFileClass.secureAWSFileFlow(lstLst);
        
        List<String> lstString1 = new List<String>();
        lstString1.add('setStudyContact');
        lstString1.add(sc.Id);
        
        List<List<String>> lstLst1 = new List<List<String>>();
        lstLst1.add(lstString1);
        
        AWSSecureFileClass.secureAWSFileFlow(lstLst1);
        
        sc.Status__c = 'Suspended';
        update sc;
        
        AWSSecureFileClass.secureAWSFileFlow(lstLst1);
        
        List<String> lstString2 = new List<String>();
        lstString2.add('setStudy');
        lstString2.add(sa.Id);
        
        List<List<String>> lstLst2 = new List<List<String>>();
        lstLst2.add(lstString2);
        
        AWSSecureFileClass.secureAWSFileFlow(lstLst2);

        
        test.stopTest();
    }
    
    static testMethod void testStudyListingB(){
        
        testData();
        test.startTest();
        
        List<Study_Account__c> ret3 = GBI_MS_Studies.getParticipantInformation();
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getParticipantInformation',ret3);
        
        GBI_MS_Studies.studiesFilter ret4 = GBI_MS_Studies.getStudiesFilters();
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getStudiesFilters',ret4);
        
        GBI_MS_Studies.relatedStudiesInfo ret5 = GBI_MS_Studies.getRelatedStudies(studyId);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getRelatedStudies',ret5);
        
        
        test.stopTest();
    }
    
    static testMethod void testStudyVote(){
        
        testData();
        setupShareFileConfig();

        test.startTest();
            
        GBI_MS_Studies.UploadLink ret7 =  GBI_MS_Studies.loadSFUploadLink(studyId);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','submitDP',ret7);
        
        GBI_MS_Studies.StudyVotesData ret8 = GBI_MS_Studies.getStudyVote(studyId,studyVoteId);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getStudyVote',ret8);
        
        GBI_MS_Studies.StudyVoteWrapper req = new GBI_MS_Studies.StudyVoteWrapper();
        
        req.StudyId = studyId;
        req.StudyVoteId = studyVoteId;
        req.questions = new List<GBI_MS_Studies.StudyVoteQuestion>();
        
        GBI_MS_Studies.StudyVoteQuestion quest1 = new GBI_MS_Studies.StudyVoteQuestion();
        quest1.Id = studyVoteQuestionId;
        quest1.answer = 'Answer';
        req.questions.add(quest1);
        
        GBI_MS_Studies.submitStudyVoteInfo ret9 = GBI_MS_Studies.submitVotes(req);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getStudyVote',ret9);
        
        GBI_MS_Studies.getNextSurveyQuestionData ret10 = GBI_MS_Studies.getFirstStudySurveyQuestion(studyId, surveyId);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getFirstStudySurveyQuestion',ret10);
               
        test.stopTest();
    }
    
    static testMethod void testProfilePhotoC(){
        
        testData();
        test.startTest();
        
        GBI_MS_Studies.profileInfo ret14 = GBI_MS_Studies.getMyProfileInfo();
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getMyProfileInfo',ret14);
        
        GBI_MS_Studies.returnUpdateProfile ret15 = GBI_MS_Studies.updateProfileInfo('firstNam', 'lastName', 'title', 'phone', 'altphone', 'email@email.com');
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','updateProfileInfo',ret15);
        
        GBI_MS_Studies.returnUpdatePhoto ret16 = GBI_MS_Studies.setUserPhoto(attachmentId, 'fileText', 'fileName');
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','setUserPhoto',ret16);
        
        
        GBI_MS_Studies.faqReturnData ret19 = GBI_MS_Studies.getFAQInformation();
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getFAQInformation',ret19);
        
		       
        test.stopTest();
    }
    
    @isTest
    static void testPillar3(){
        testData();
        
        Test.startTest();
        
        GBI_MS_Studies.getParticipatingInstitutions();
        GBI_MS_Studies.getStudyDetail(null); 
        
        GBI_MS_Studies.retStudyDetailFormatted rettest2_1 = GBI_MS_Studies.getStudyDetail(studyId);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test2','getStudyDetail',rettest2_1);
                
        GBI_MS_Studies.getStudyDetail(study2.Id);
        
        GBI_MS_Studies.setPillar3Attestation(False);
        GBI_MS_Studies.setPillar3Attestation(True);
        
        Test.stopTest();
    }
    
    @isTest
    static void testSurveyA(){
        testData();
        
        Test.startTest();
        
        
        GBI_MS_Studies.getNextSurveyQuestionData rettest2_2 = GBI_MS_Studies.getFirstStudySurveyQuestion(studyId, surveyId);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test2','getFirstStudySurveyQuestion',rettest2_2);
        surveyData = rettest2_2;
        
        GBI_MS_Studies.getNextSurveyQuestionData rettest2_3 = GBI_MS_Studies.getStudySurveyQuestion(studyId, surveyId, questionId, surveyData);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test2','getFirstStudySurveyQuestion',rettest2_3);
        
        surveyData = rettest2_3;
        
        GBI_MS_Studies.getNextSurveyQuestionData rettest2_8 = GBI_MS_Studies.getStudySurveyQuestion(studyId, surveyId, questionId, surveyData);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test2','getStudySurveyQuestion',rettest2_8);
        
        GBI_MS_Studies.getNextSurveyQuestionData rettest2_4 = GBI_MS_Studies.submitStudySurveyAnswer(studyId, surveyId, questionId, surveyAnswer, surveyData);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test2','submitStudySurveyAnswer',rettest2_4); 
        
        surveyData = rettest2_4;
        
        GBI_MS_Studies.getNextSurveyQuestionData rettest2_5 = GBI_MS_Studies.commitSurveyData(studyId, surveyId, surveyData);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test2','commitSurveyData',rettest2_5);
        
        sss = new Study_Survey_Submission__c();
        sss.Status__c='Submitted';
        sss.Study_Account__c = sa.Id;
        sss.Study_Survey__c = surveyId;
        insert sss;
                
        GBI_MS_Studies.getNextSurveyQuestionData rettest2_6 = GBI_MS_Studies.commitSurveyData(studyId, surveyId, surveyData);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test2','commitSurveyData',rettest2_6);
        
               
        Test.stopTest();
    }

	@isTest
    static void testProfilePhotoA(){
        testData();
        
        Test.startTest();
        
        GBI_MS_Studies.returnUpdatePhoto rettest2_6 = GBI_MS_Studies.removeUserPhoto();
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test2','removeUserPhoto',rettest2_6);
        
        GBI_MS_Studies.returnSendSupportEmail rettest2_7 = GBI_MS_Studies.sendSupportEmail('subject', 'description', False);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test2','sendSupportEmail',rettest2_7);
       
        Test.stopTest();
    }
    
    @isTest
    static void testOtherA(){
        testData();
        setupShareFileConfig();
        
        Study_Contact__c sc1 = new Study_Contact__c(Role__c='Data Manager', Status__c='Active', Study__c=study.Id, Contact__c=contact.Id, Study_Account__c=sa.Id);
        insert sc1;
        
        List<User> lstUsers = [SELECT Id,ContactId FROM User WHERE username =: 'newuser@testorg.com' LIMIT 1];
        
        Test.startTest();
        
        study.Payment_Required__c = True;
        study.Study_Fee__c = 5;
        update study;
        
        GBI_MS_Studies.returnUpdatePhoto rettest3_1 = GBI_MS_Studies.setUserPhoto(attachmentId, 'fileText', 'Attach');
        
        system.runAs(lstUsers[0]){
            
            GBI_MS_Studies.returnUpdatePhoto rettest3_2 = GBI_MS_Studies.setUserPhoto(attachmentId, 'fileText', 'Attach_Name');
            GBI_Common.debugLog('GBI_MS_BC_Studies_test','rettest3_2','setUserPhoto',rettest3_2);
            
            GBI_MS_Studies.retStudyDetailFormatted rettest3_3 = GBI_MS_Studies.getStudyDetail(studyId);
            
            GBI_MS_Studies.retStudyDetailFormatted rettest3_4 = GBI_MS_Studies.getStudyDetail(study2.id);
            
            GBI_MS_Studies.UploadLink rettest3_5 =  GBI_MS_Studies.loadSFUploadLink(studyId);
            GBI_Common.debugLog('GBI_MS_BC_Studies_test','rettest3_5','loadSFUploadLink',rettest3_5);
            
            GBI_MS_Studies.returnUpdatePhoto rettest3_6 = GBI_MS_Studies.removeUserPhoto();
            GBI_Common.debugLog('GBI_MS_BC_Studies_test','rettest3_6','removeUserPhoto',rettest3_6);
            
        	scv.Cancel_Vote__c = FALSE;
            update scv;
            
            GBI_MS_Studies.StudyVoteWrapper req = new GBI_MS_Studies.StudyVoteWrapper();
            
            req.StudyId = studyId;
            req.StudyVoteId = studyVoteId;
            req.questions = new List<GBI_MS_Studies.StudyVoteQuestion>();
            
            GBI_MS_Studies.StudyVoteQuestion quest1 = new GBI_MS_Studies.StudyVoteQuestion();
            quest1.Id = studyVoteQuestionId;
            quest1.answer = 'Answer';
            req.questions.add(quest1);
                        
            //Study_Contact__c sc2 = new Study_Contact__c(Role__c='Other', Status__c='Active', Study__c=study.Id, Contact__c=contact.Id, Study_Account__c=sa.Id);
        	//insert sc2;
            sc.Role__c='Other';
            update sc;
            scv.Cancel_Vote__c = True;
            update scv;
            GBI_MS_Studies.submitStudyVoteInfo ret9 = GBI_MS_Studies.submitVotes(req);    
			      
            req.StudyVoteId = Null;
            GBI_MS_Studies.submitStudyVoteInfo ret9_1 = GBI_MS_Studies.submitVotes(req);        	
        }
        
        Test.stopTest();       
    }
    
    @isTest
    static void testOtherB(){
        testData();
        Test.startTest();
        
        GBI_MS_Studies.submitDP(studyId,userEmail);
        
        Dis_Pro.DP_Status__c = 'Inactive';
        update Dis_Pro;
        
        Disclosure_Protocol__c Dis_Pro2 = new Disclosure_Protocol__c(Study__c = study.id,DP_Status__c = 'Active');
        insert Dis_Pro2;
        
        study.Payment_Required__c = True;
        study.Study_Fee__c = 100;
        update study;
        
        GBI_MS_Studies.submitDP(studyId,userEmail);
        
        Test.stopTest();       
    }
    static testMethod void testSurveyB(){
        
        testData();
        test.startTest();
        
        GBI_MS_Studies.StudyVotesData ret8 = GBI_MS_Studies.getStudyVote(studyId,studyVoteId);
        GBI_Common.debugLog('GBI_MS_BC_Studies_test','test1','getStudyVote',ret8);
        
        Contact.AccountId = acc1.id;
        update Contact;
        
        sa.DP_Not_Required__c = False;
        update sa;
        
        sv.Status__c = 'Draft';
        update sv;
        GBI_MS_Studies.getStudyVote(studyId,studyVoteId);
        
        surveyData = GBI_MS_Studies.getFirstStudySurveyQuestion(studyId, surveyId);
        surveyData = GBI_MS_Studies.getStudySurveyQuestion(studyId, surveyId, questionId, surveyData);
        surveyData = GBI_MS_Studies.submitStudySurveyAnswer(studyId, surveyId, questionId, surveyAnswer, surveyData);
               
        ss2 = new Study_Survey__c(Name='SS1', Status__c='Active', Study__c=study.Id);
        insert ss2;
        
        GBI_MS_Studies.commitSurveyData(studyId, ss2.id, surveyData); 
        List<User> lstUsers = [SELECT Id,ContactId FROM User WHERE username =: 'newuser@testorg.com' LIMIT 1];
        
        id attachidd;
        
        System.runas(lstUsers[0]){
        attachidd = GBI_BC_Studies.uploadAttachment(attachmentId, 'fileText', 'fileName');
        }
        GBI_BC_Studies.setUserPhoto(attachidd);
        
        test.stopTest();
    }
    
    @isTest
    static void testRemainingDummy(){
        //testData();
        //This test dummy block wrapper classes, not yet implemented/used for in GBI_MS_Studies or _BC 
        getSudiesReturnData = new  GBI_MS_Studies.getSudiesReturnData();
        getSudiesReturnData.contactData = contact;
        getSudiesReturnData.accountData = acc;
        getSudiesReturnData.studies = new List<Study__c>{null};
        getSudiesReturnData.studyNDAs = new List<Study_NDA__c>{null};
        getSudiesReturnData.disclosureProtocols = new  List<Disclosure_Protocol__c>{null};
            
		getUserReturnData = new GBI_MS_Studies.getUserReturnData();
        getUserReturnData.contactData = contact;
        getUserReturnData.accountData = acc;
        getUserReturnData.studies = new List<Study__c>{null};
        getUserReturnData.disclosureProtocols = new List<Disclosure_Protocol__c>{null};
		getUserReturnData.studyContacts =  new List<Study_Contact__c>{null}; 
		getUserReturnData.studyContactAccounts = new List<Account>{null}; 
        getUserReturnData.studyAccountContactRelation = new List<AccountContactRelation>{null};  
		getUserReturnData.studyUsers = new List<User>{null}; 
		getUserReturnData.studyAccounts = new List<Study_Account__c>{null}; 
		getUserReturnData.studyRounds = new List<Study_Round__c>{null};  
		getUserReturnData.faqCategories = new List<FAQ_Category__c>{null}; 
		getUserReturnData.listFAQSections = new List<FAQ_Section__c>{null}; 
		getUserReturnData.listFAQSubSections = new List<FAQ_Subsection__c>{null}; 
		getUserReturnData.FAQs = new List<Frequently_Asked_Questions__c>{null}; 
		getUserReturnData.studyVotes = new List<Study_Vote__c>{null}; 
		getUserReturnData.studyVoteQuestions = new List<Study_Vote_Question__c>{null}; 
		getUserReturnData.studyContactVotes = new List<Study_Contact_Vote__c>{null};  
		getUserReturnData.studyDataSubmissions = new List<Study_Data_Submission__c>{null};  
		getUserReturnData.disclosureProtocols = new List<Disclosure_Protocol__c>{null}; 
		getUserReturnData.submissionDPs = new List<Study_Disclose_Protocol_Submission__c>{null};  
		getUserReturnData.graDocuments = new List<Study_Document__c>()   ; 
        getUserReturnData.studyDocuments = new List<Study_Document__c>()   ;
        getUserReturnData.gbiUpdates = new List<GBI_Update__c>{null};  
        getUserReturnData.studyNDAs = new List<Study_NDA__c>{null};  
        getUserReturnData.studySurveys = new List<Study_Survey__c>{null};
        
		}
    
    
}