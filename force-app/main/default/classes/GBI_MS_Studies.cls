public class GBI_MS_Studies {

    // Wrappers

    public class faqReturnData {
        public List<FAQ_Category__c> faqCategories { get; set; }
        public List<FAQ_Section__c> listFAQSections { get; set; }
        public List<FAQ_Subsection__c> listFAQSubSections { get; set; }
        public List<Frequently_Asked_Questions__c> FAQs { get; set; }
    }

    public class getSudiesReturnData {
        public Boolean isGARPEmployee { get; set; }
        public User userData { get; set; }
        public Contact contactData { get; set; }
        public Account accountData { get; set; }
        public Id indvAccountRecordTypeId { get; set; }
        public List<Study__c> studies { get; set; }
        public List<Study_NDA__c> studyNDAs { get; set; }
        public List<Disclosure_Protocol__c> disclosureProtocols { get; set; }
    }

    public class reqStudiesList {
        public String status { get; set; }
        public String riskBucket { get; set; }
        public String riskType { get; set; }
        public String riskCategory { get; set; }  // myStudies, myOrgStudies, otherStudies
        public Boolean participtation { get; set; }
        public String coverage { get; set; }
        public Integer year { get; set; }
        public Integer offset{ get; set; }
        public Integer quantity { get; set; }
    }

    public class retStudyInfo {
        public Study__c studyInfo;
        public Study__c parentStudyInfo;
        public Study_Account__c studyAccount;
        public Study_Contact__c studyContact;
        public Study_Disclose_Protocol_Submission__c dpSubmission;
        public Boolean hasDP;
        public Boolean isDPSigned;
        public Boolean hasVoteDataManager;
        public Boolean hasDataManager;
        public Boolean hasVoter;
        public Boolean canViewDetails;
        public Boolean canSignDP;
        public Boolean canManageUsers;
    }

    public class retStudiesInfo {
        public Integer statusCode;
        public String statusMsg;
        public Boolean isGARPEmployee;
        public Study_NDA__c ndaSubmission;
        public List<retStudyInfo> myStudies;
        public List<retStudyInfo> myOrgStudies;
        public List<retStudyInfo> otherStudies;
    }

    public class returnParticipants {
        public String StudyAccountName;
        public List<Study_Contact__c> StudyContacts;
    }

    public class returnParticipatingInstitutions {
        public String accountId;
        public String name;
        public String firmType;
        public String country;
        public String region;
        public Integer studyCount;
    }

    public class retStudyDetail {
        public Study__c studyDetail;
        public Study_NDA__c studyNDA;
        public Boolean hasAccess;
        public Boolean isStudyDPSigned;
        public Integer statusCode;
        public String statusMessage;
        public List<returnParticipants> lstParticipants;
        public List<Study_Contact__c> lstRepsFromMyInstitution;
        public List<Study_Round__c> studyRounds;
        public List<Disclosure_Protocol__c> disclosureProtocols;
        public List<Study_Disclose_Protocol_Submission__c> disclosureProtocolSubmissions;
        public List<Study_Disclose_Protocol_Submission__c> disclosureProtocolSubmissionsPrev;
        public List<Study_Contact__c> lstStudyContact;
        public Study_Contact__c myStudyContact;
        public List<Study_Document__c> lstStudyDocuments;
        public List<Study_Survey__c> lstStudySurveys;
        public List<Study_Survey__c> lstStudySurveysCompleted;
        public List<Study_Vote__c > lstStudyVotes;
        public List<Study_Vote__c > lstStudyVotesCompleted;
        public String secureFileSystems;
        public Boolean hasDP;
        public Boolean canSignDP;
        public Boolean canUploadFile;
        public Boolean isDataCollectionInProgress;
        public Date dataCollectionEndDate;
        public Boolean canManageUsers;
        public Boolean hasMyFile;
        public Boolean hasAnalytics;
        public Boolean showMyFilesResults;
        public Boolean showAnalyticsResults;
        public Disclosure_Protocol__c latestDisclosureProtocol;
        public String latestDisclosureProtocolViewUrl;
    }

    public class child {
        public String name;
        public String roles;
        public String avatar;
    }

    public class formattedListParticipants {
        public String name;
        public List<child> children;
    }

    public class retStudyDetailFormatted {
        public Study__c studyDetail;
        public Study_NDA__c studyNDA;
        public Boolean hasAccess;
        public Boolean isStudyDPSigned;
        public Integer statusCode;
        public String statusMessage;
        public List<formattedListParticipants> lstParticipants;
        public List<child> lstRepsFromMyInstitution;
        public List<Study_Round__c> studyRounds;
        public List<Disclosure_Protocol__c> disclosureProtocols;
        public List<Study_Disclose_Protocol_Submission__c> disclosureProtocolSubmissions;
        public List<Study_Disclose_Protocol_Submission__c> disclosureProtocolSubmissionsPrev;
        public List<Study_Contact__c> lstStudyContact;
        public Study_Contact__c myStudyContact;
        public List<Study_Document__c> lstStudyDocuments;
        public List<Study_Survey__c> lstStudySurveys;
        public List<Study_Survey__c> lstStudySurveysCompleted;
        public List<Study_Vote__c > lstStudyVotes;
        public List<Study_Vote__c > lstStudyVotesCompleted;
        public String secureFileSystems;
        public Boolean hasDP;
        public Boolean canSignDP;
        public Boolean canUploadFile;
        public Boolean isDataCollectionInProgress;
        public Date dataCollectionEndDate;
        public Boolean canManageUsers;
        public Boolean hasMyFile;
        public Boolean hasAnalytics;
        public Boolean showMyFilesResults;
        public Boolean showAnalyticsResults;
    }

    public class studiesFilter{
        public List<String> lstStatus;
        public List<String> lstRiskBucket;
        public List<String> lstRiskType;
        public List<String> lstParticipation;
        public List<String> lstYears;
    }

    public class getUserReturnData {
        public User userData { get; set; }
        public Contact contactData { get; set; }
        public Account accountData { get; set; }
        public Id indvAccountRecordTypeId { get; set; }

        public List<Study__c> studies { get; set; }
        public List<Study_Contact__c> studyContacts { get; set; }
        public List<Account> studyContactAccounts { get; set; }
        public List<AccountContactRelation> studyAccountContactRelation { get; set; }

        public List<User> studyUsers { get; set; }
        public List<Study_Account__c> studyAccounts { get; set; }
        public List<Study_Round__c> studyRounds { get; set; }

        public List<FAQ_Category__c> faqCategories { get; set; }
        public List<FAQ_Section__c> listFAQSections { get; set; }
        public List<FAQ_Subsection__c> listFAQSubSections { get; set; }
        public List<Frequently_Asked_Questions__c> FAQs { get; set; }
        public List<Study_Vote__c> studyVotes { get; set; }
        public List<Study_Vote_Question__c> studyVoteQuestions { get; set; }
        public List<Study_Contact_Vote__c> studyContactVotes { get; set; }  // May need to hide others votes

        public List<Study_Data_Submission__c> studyDataSubmissions { get; set; }

        public List<Disclosure_Protocol__c> disclosureProtocols { get; set; }
        public List<Study_Disclose_Protocol_Submission__c> submissionDPs { get; set; }

        public List<Study_Document__c> graDocuments  { get; set; }
        public List<Study_Document__c> studyDocuments  { get; set; }

        public List<GBI_Update__c> gbiUpdates { get; set; }

        public AggregateResult[] studyAccountCount { get; set; }

        public Boolean isGARPEmployee { get; set; }
        public List<Study_NDA__c> studyNDAs { get; set; }

        public List<Study_Survey__c> studySurveys { get; set; }
    }

    public class StudyVotesData {
        public Study_Vote__c studyVote { get; set; }
        public List<Study_Vote_Question__c> studyVoteQuestions { get; set; }
        public List<Study_Contact_Vote__c> studyContactVotes { get; set; }
        public Integer statusCode;
        public String statusMessage;
    }

    public class StudyVoteQuestion {
        public Id Id;
        public String answer;
    }

    public class StudyVoteWrapper {
        public Id StudyId;
        public Id StudyVoteId;
        public List<StudyVoteQuestion> questions;
    }

    public class submitStudyVoteInfo {
        public Integer statusCode;
        public String statusMessage;
    }

    public class verifyStudyAccessData {
        public String errorMessage;
        public MAP<ID,ID> myStudyAccounts;
        public MAP<ID,ID> myStudyContacts;
    }

    public class relatedStudiesInfo {
        public Integer statusCode;
        public String statusMessage;
        public List<relatedStudy> relatedStudies;
    }

    public class relatedStudy {
        public Study__c study;
        public Boolean hasAccess;
    }

    public class UploadLink {
        public Integer statusCode;
        public String statusMessage;
        public String uploadLink;
    }

    public class getNextSurveyQuestionData {
        public Study_Survey_Question__c surveyQuestion;
        public Study_Survey_Answer__c surveyAnswer;
        public List<Study_Survey_Question__c> lstQuestions;
        public List<Study_Survey_Answer__c> lstAnswers;
        Public Integer statusCode;
        Public String statusMessage;
    }

    public class profileInfo {
        public Contact contactData;
        public String myAccount;
        public List<participantInfo> otherStudyParticipants;
        public List<studyInfo> myStudies;
        Public Integer statusCode;
        Public String statusMessage;
        Public Boolean hasPillar3Access;
        Public Boolean hasStudyAccess;
        Public Boolean hasPillar3Attestation;
        Public Boolean hasPillar3LiteAttestation;
        Public Boolean hasSignedNDA;
    }

    public class participantInfo {
        public String name;
        public String imageURL;
    }

    public class studyInfo {
        public String name;
        public String id;
    }

    public class returnDPSubmission {
        public String submissionId;
        public Integer statusCode;
        public String statusMessage;
    }

    public class StudyRegistrationDocument {
        public String documentType;  // 'Unsigned DP' or 'Signed DP' or 'Invoice'
        public String documentId;
        public String documentName;
        public String documentUrl;
        public String signedDate;  // Date only formatted string (MM/dd/yyyy)
        public String signedDateTime;  // Date + time formatted string (MM/dd/yyyy hh:mm a)
        public Long signedTimestamp;  // Timestamp code (epoch milliseconds) for frontend date operations
        public Boolean isLatest;  // Indicates if this is the latest signed DP
        public Decimal paymentAgreedAmount;
        public String paymentAgreedDate;  // Date only formatted string (MM/dd/yyyy)
        public String paymentAgreedDateTime;  // Date + time formatted string (MM/dd/yyyy hh:mm a)
        public Long paymentAgreedTimestamp;  // Timestamp code (epoch milliseconds) for frontend date operations
    }

    public class returnGetStudyRegistrationDocuments {
        public List<StudyRegistrationDocument> signedDisclosureProtocols;
        public List<StudyRegistrationDocument> invoices;
        public Integer statusCode;
        public String statusMessage;
    }

    public class returnUpdateProfile {
        public Integer statusCode;
        public String statusMessage;
    }

    public class returnUpdatePhoto {
        public String photoURL;
        public Integer statusCode;
        public String statusMessage;
    }

    public class returnSendSupportEmail {
        public Integer statusCode;
        public String statusMessage;
    }

    // Methods

    @RemoteAction
    public static List<returnParticipatingInstitutions> getParticipatingInstitutions(){
        return GBI_BC_Studies.getParticipatingInstitutions();
    }

    @RemoteAction
    public static retStudyDetailFormatted getStudyDetail(String studyId) {
        GBI_Common.debugLog('GBI_MS_Studies','getStudyDetail','studyId',studyId);

        retStudyDetailFormatted studyDetailFormatted = new retStudyDetailFormatted();

        retStudyDetail study = GBI_BC_Studies.getStudyDetail(studyId);
        GBI_Common.debugLog('GBI_MS_Studies','getStudyDetail','study',study);

        if(study.statusCode != 200) {
            studyDetailFormatted.statusCode = study.statusCode;
            studyDetailFormatted.statusMessage = study.statusMessage;
            return studyDetailFormatted;
        }

        studyDetailFormatted.isStudyDPSigned = study.isStudyDPSigned;
        if(!study.isStudyDPSigned) {
            studyDetailFormatted.studyDetail = study.studyDetail;
            studyDetailFormatted.studyNDA = study.studyNDA;
            studyDetailFormatted.myStudyContact = study.myStudyContact;
            studyDetailFormatted.hasAccess = study.hasAccess;
            studyDetailFormatted.disclosureProtocols = study.disclosureProtocols;
            studyDetailFormatted.canUploadFile = study.canUploadFile;
            studyDetailFormatted.isDataCollectionInProgress = study.isDataCollectionInProgress;
            studyDetailFormatted.dataCollectionEndDate = study.dataCollectionEndDate;
            studyDetailFormatted.hasDP = study.hasDP;
            studyDetailFormatted.canSignDP = study.canSignDP;
            studyDetailFormatted.canManageUsers = study.canManageUsers;
            studyDetailFormatted.hasMyFile = study.hasMyFile;
            studyDetailFormatted.hasAnalytics = study.hasAnalytics;
            studyDetailFormatted.showMyFilesResults = study.showMyFilesResults;
            studyDetailFormatted.showAnalyticsResults = study.showAnalyticsResults;
            studyDetailFormatted.statusCode = study.statusCode;
            studyDetailFormatted.statusMessage = study.statusMessage;
            GBI_Common.debugLog('GBI_MS_Studies','getStudyDetail','studyDetailFormatted',studyDetailFormatted);
            return studyDetailFormatted;
        }

        List<formattedListParticipants> lstParticipants = new List<formattedListParticipants>();
        if(!study.lstParticipants.IsEmpty()) {

            for (returnParticipants part : study.lstParticipants) {
                GBI_Common.debugLog('GBI_MS_Studies','getStudyDetail','Loop Participants',part);

                formattedListParticipants participant = new formattedListParticipants();
                List<child> children = new List<child>();
                participant.name = part.StudyAccountName;
                GBI_Common.debugLog('GBI_MS_Studies','getStudyDetail','participant',participant);

                for(Study_Contact__c cont : part.StudyContacts) {
                    child child = new child();
                    child.name  =     cont.Contact__r.Name;
                    child.roles =     cont.Role__c;
                    child.avatar=     cont.Contact__r.Photo_URL__c;
                    children.add(child);
                }
                GBI_Common.debugLog('GBI_MS_Studies','getStudyDetail','children',children);

                participant.children = children;
                lstParticipants.add(participant);
            }

        }
        GBI_Common.debugLog('GBI_MS_Studies','getStudyDetail','lstParticipants',lstParticipants);

        List<child> lstRepsFromMyInstitution = new List<child>();
        if(!study.lstRepsFromMyInstitution.IsEmpty()) {
            for(Study_Contact__c cont : study.lstRepsFromMyInstitution) {
                child child = new child();
                child.name  =     cont.Contact__r.Name;
                child.roles =     cont.Role__c;
                child.avatar=     cont.Contact__r.Photo_URL__c;
                lstRepsFromMyInstitution.add(child);
            }
        }
        GBI_Common.debugLog('GBI_MS_Studies','getStudyDetail','lstRepsFromMyInstitution',lstRepsFromMyInstitution);

        studyDetailFormatted.studyDetail = study.studyDetail;
        studyDetailFormatted.studyNDA = study.studyNDA;
        studyDetailFormatted.hasAccess = study.hasAccess;
        studyDetailFormatted.canSignDP = study.canSignDP;
        studyDetailFormatted.canUploadFile = study.canUploadFile;
        studyDetailFormatted.isDataCollectionInProgress = study.isDataCollectionInProgress;   
        studyDetailFormatted.dataCollectionEndDate = study.dataCollectionEndDate;
        studyDetailFormatted.canManageUsers = study.canManageUsers;
        studyDetailFormatted.hasMyFile = study.hasMyFile;
        studyDetailFormatted.hasAnalytics = study.hasAnalytics;
        studyDetailFormatted.showMyFilesResults = study.showMyFilesResults;
        studyDetailFormatted.showAnalyticsResults = study.showAnalyticsResults;

        studyDetailFormatted.lstParticipants = lstParticipants;
        studyDetailFormatted.lstRepsFromMyInstitution = lstRepsFromMyInstitution;
        studyDetailFormatted.studyRounds = study.studyRounds;
        studyDetailFormatted.disclosureProtocols = study.disclosureProtocols;
        studyDetailFormatted.disclosureProtocolSubmissions = study.disclosureProtocolSubmissions;
        studyDetailFormatted.disclosureProtocolSubmissionsPrev = study.disclosureProtocolSubmissionsPrev;
        studyDetailFormatted.lstStudyContact = study.lstStudyContact;
        studyDetailFormatted.myStudyContact = study.myStudyContact;
        studyDetailFormatted.lstStudyDocuments = study.lstStudyDocuments;
        studyDetailFormatted.lstStudySurveys = study.lstStudySurveys;
        studyDetailFormatted.lstStudySurveysCompleted = study.lstStudySurveysCompleted;
        studyDetailFormatted.lstStudyVotes = study.lstStudyVotes;
        studyDetailFormatted.lstStudyVotesCompleted = study.lstStudyVotesCompleted;

        studyDetailFormatted.statusCode = study.statusCode;
        studyDetailFormatted.statusMessage = study.statusMessage;

        GBI_Common.debugLog('GBI_MS_Studies','getStudyDetail','studyDetailFormatted',studyDetailFormatted);

        return studyDetailFormatted;
    }

    public class returnSetPillar3Attestation {
        public Integer statusCode;
        public String statusMessage;
    }

    @RemoteAction
    public static retStudiesInfo getListStudies(reqStudiesList reqWrapper) {
        return GBI_BC_Studies.getListStudies(reqWrapper);
    }

    @RemoteAction
    public static List<Study_Account__c> getParticipantInformation(){
        return GBI_BC_Studies.getParticipantInformation();
    }

    @RemoteAction
    public static studiesFilter getStudiesFilters(){
        return GBI_BC_Studies.getStudiesFilters();
    }

    @RemoteAction
    public static relatedStudiesInfo getRelatedStudies(String studyId){
        return GBI_BC_Studies.getRelatedStudies(studyId);
    }

    @RemoteAction
    public static returnDPSubmission submitDP(String studyId, String invoiceEmail){
        return GBI_BC_Studies.submitDP(studyId, invoiceEmail);
    }

    @RemoteAction
    public static returnGetStudyRegistrationDocuments getStudyRegistrationDocuments(String studyId, String studyAccountId) {
        return GBI_BC_Studies.getStudyRegistrationDocuments(studyId, studyAccountId);
    }

    @RemoteAction
    public static GBI_MS_Studies.UploadLink loadSFUploadLink(Id studyId) {
        return GBI_BC_Studies.loadSFUploadLink(studyId);
    }

    @RemoteAction
    public static StudyVotesData getStudyVote(String studyId, String studyVoteId){
        return GBI_BC_Studies.getStudyVote(studyId, studyVoteId);
    }

    @RemoteAction
    public static submitStudyVoteInfo submitVotes(StudyVoteWrapper studyVoteWrapper){
        return GBI_BC_Studies.submitVotes(studyVoteWrapper);
    }

    @RemoteAction
    public static getNextSurveyQuestionData getFirstStudySurveyQuestion(String studyId, String surveyId){
        return GBI_BC_Studies.getFirstStudySurveyQuestion(studyId, surveyId);
    }

    @RemoteAction
    public static getNextSurveyQuestionData getStudySurveyQuestion(String studyId, String surveyId, String questionId, getNextSurveyQuestionData surveyData){
        return GBI_BC_Studies.getStudySurveyQuestion(studyId, surveyId, questionId, surveyData);
    }

    @RemoteAction
    public static getNextSurveyQuestionData submitStudySurveyAnswer(String studyId, String surveyId, String surveyQuestionId, String surveyAnswer, getNextSurveyQuestionData surveyData){
        return GBI_BC_Studies.submitStudySurveyAnswer(studyId, surveyId, surveyQuestionId, surveyAnswer, surveyData);
    }

    @RemoteAction
    public static getNextSurveyQuestionData commitSurveyData(String studyId, String surveyId, getNextSurveyQuestionData surveyData){
        return GBI_BC_Studies.commitSurveyData(studyId, surveyId, surveyData);
    }

    @RemoteAction
    public static returnSetPillar3Attestation setPillar3Attestation(Boolean isLite) {
        return GBI_BC_Studies.setPillar3Attestation(isLite);
    }

    @RemoteAction
    public static profileInfo getMyProfileInfo(){
        return GBI_BC_Studies.getMyProfileInfo();
    }

    @RemoteAction
    public static returnUpdateProfile updateProfileInfo(String firstName, String lastName, String title, String phone, String altphone, String email) {
        return GBI_BC_Studies.updateProfileInfo(firstName, lastName, title, phone, altphone, email);
    }

    @RemoteAction
    public static returnUpdatePhoto setUserPhoto(Id attachmentId, String fileText, String fileName){
        String attchId = GBI_BC_Studies.uploadAttachment(attachmentId, fileText, fileName);
        return GBI_BC_Studies.setUserPhoto(attchId);
    }

    @RemoteAction
    public static returnUpdatePhoto removeUserPhoto(){
        return GBI_BC_Studies.removeUserPhoto();
    }

    @RemoteAction
    public static returnSendSupportEmail sendSupportEmail(String subject, String description, Boolean isPillar3){
        return GBI_BC_Studies.sendSupportEmail(subject, description, isPillar3);
    }

    @RemoteAction
    public static faqReturnData getFAQInformation(){
        return GBI_BC_Studies.getFAQInformation();
    }

    @RemoteAction
    public static AWSSecureFileClass.returnUploadFile uploadAWSFile(string studyId, String fileName, String fileData, String fileId, String uploadId, String folderId, String authToken, Boolean isLastPart){
        return GBI_BC_Studies.uploadAWSFile(studyId, fileName, fileData, fileId, uploadId, folderId, authToken, isLastPart);
    }

    @RemoteAction
    public static AWSSecureFileClass.returnGetQuicksightEmbedURL getAnalyticsDashboardEmbedURL(string studyId){
        return GBI_BC_Studies.getDashboardEmbedURL(studyId);
    }

    @RemoteAction
    public static AWSSecureFileClass.returnGetFolder getAWSFolder(string studyId) {
        return GBI_BC_Studies.getAWSFolder(studyId);
    }

    @RemoteAction
    public static AWSSecureFileClass.returnGetFolder getAWSSubFolder(string studyId, string folderId) {
        return GBI_BC_Studies.getAWSSubFolder(studyId, folderId);
    }

    @RemoteAction
    public static AWSSecureFileClass.returnDownloadFile getAWSDownloadFile(String studyId, String folderId, String fileId, Integer start, String authToken) {
        return GBI_BC_Studies.getAWSDownloadFile(studyId, folderId, fileId, start, authToken);
    }

    @RemoteAction
    public static AWSSecureFileClass.returnSetCustomer AWSSecureFileSetCustomer(String studyId) {
        return GBI_BC_Studies.AWSSecureFileSetCustomer(studyId);
    }

    @RemoteAction
    public static AWSSecureFileClass.returnSetUser AWSSecureFileSetUser(String studyId) {
        return GBI_BC_Studies.AWSSecureFileSetUser(studyId);
    }

    @RemoteAction
    public static GBI_BC_Studies.returnGetManageUsersScreenInfo getManageUsersScreenInfo(String studyId) {
        return GBI_BC_Studies.getManageUsersScreenInfo(studyId);
    }

    @RemoteAction
    public static GBI_BC_Studies.returnSetManageUsersAccess setManageUsersAccess(String studyId, String studyContactId, Boolean hasManageUserAccess) {
        return GBI_BC_Studies.setManageUsersAccess(studyId, studyContactId, hasManageUserAccess);
    }

    @RemoteAction
    public static GBI_BC_Studies.returnSetStudyContactState SetStudyContactState(String studyId, String studyContactId, Boolean isEnabled) {
        return GBI_BC_Studies.SetStudyContactState(studyId, studyContactId, isEnabled);
    }

    @RemoteAction
    public static GBI_BC_Studies.returnSetManageUserInfo setManageUserInfo(String studyId, GBI_BC_Studies.StudyContactInfo studyContactInfo) {
        return GBI_BC_Studies.setManageUserInfo(studyId, studyContactInfo);
    }

    @RemoteAction
    public static GBI_BC_Studies.returnGetManageUsersStudies getManageUsersStudies(String studyId) {
        return GBI_BC_Studies.getManageUsersStudies(studyId);
    }

    @RemoteAction
    public static GBI_BC_Studies.returnGetManageUsersStudyContacts getManageUsersStudyContacts(String studyId, String sourceStudyId) {
        return GBI_BC_Studies.getManageUsersStudyContacts(studyId, sourceStudyId);
    }

    @RemoteAction
    public static GBI_BC_Studies.returnManageUsersAddContactsFromOtherStudy ManageUsersAddContactsFromOtherStudy(String studyId, List<GBI_BC_Studies.StudyContactInfo> studyContactInfos) {
        return GBI_BC_Studies.ManageUsersAddContactsFromOtherStudy(studyId, studyContactInfos);
    }

    @RemoteAction
    public static GBI_BC_Studies.returnFindManageUsersStudyContacts findManageUsersStudyContacts(String studyId, String searchText) {
        return GBI_BC_Studies.findManageUsersStudyContacts(studyId, searchText);
    }

}