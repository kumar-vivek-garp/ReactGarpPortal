public with sharing class QualtricsApiService {

    public static List<Api_Transaction__c> apiTransactions = new List<Api_Transaction__c>();

    public class result{
        public String id { get; set; }
        public String type { get; set; }
        public String name { get; set; }
        public String baseUrl { get; set; }
        public String contactLookupId { get; set; }
        public List<QualtricsElement> elements { get; set; }
    }

    public class meta{
        public String httpStatus { get; set; }
        public String requestId { get; set; }
    }

    public class response{
         public Result result { get; set; }
         public Meta meta { get; set; }
    }

    public class QualtricsElement{
        public String id { get; set; }
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String email { get; set; }
        public String phoneNumber { get; set; }
        public String contactId { get; set; }
        public String link { get; set; }
        public String linkExpiration { get; set; }
        public Id externalDataReference { get; set; }
    }

    public class QualticsMailingListRequest{
        public String name { get; set; }
        public QualticsMailingListRequest(String surveyId, String studyAccountId){
            this.name = surveyId + '_' + studyAccountId;
        }
    }

    public class QualtricsContactRequest{

        public String extRef { get; set; }

        public QualtricsContactRequest(Id extRef){
            this.extRef = (String)extRef;
        }

    }

    public class QualtricsDistributionLinkRequest{
        
        public String surveyId { get; set; }
        public String linkType { get; set; }
        public String description { get; set; }
        public String action { get; set; }
        public String expirationDate { get; set;}
        public String mailingListId { get; set; }

        public QualtricsDistributionLinkRequest(String surveyId, String mailingListId){
            this.action = 'CreateDistribution';
            this.linkType = 'Individual';
            this.surveyId = surveyId;
            this.description = surveyId;
            this.mailingListId = mailingListId;
            this.expirationDate = Datetime.now().addMinutes(10).format('YYYY-MM-DD hh:mm:ss');
        }

    }

    /**
    @description Creates a Qualtrics Mailing List related to Study Account
    @param directoryId the default directory id defined by Qualtrics
    @param studyId the Study ID (Salesforce)
    @param studyAccountId the Study Account ID (Salesforce)
    @return QualtricsApiService.response containing the Qualtrics Mailing List ID
    */
    public static QualtricsApiService.response createMailingList(String directoryId, Id studyId, Id studyAccountId){

        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new QualtricsApiRequestMock(QualtricsApiRequestMock.QualtricsApiRequestType.CREATE_MAILING_LIST));
        }

        QualticsMailingListRequest request = new QualticsMailingListRequest(studyId, studyAccountId);

        String requestUrl = '/directories/' + directoryId + '/mailinglists';
        String jsonString = JSON.serializePretty(request);

        String response = new Request().post(requestUrl, jsonString);

        QualtricsApiService.response qResponse = (QualtricsApiService.response)JSON.deserialize(response, QualtricsApiService.response.class);

        String body = 'REQUEST:\n\n' + jsonString + '\n\nRESPONSE:\n\n' + JSON.serializePretty(qResponse);

        apiTransactions.add(new Api_Transaction__c(
            Request_URL_Long_Text__c = requestUrl,
            Study__c = studyId,
            Study_Account__c = studyAccountId,
            Body__c = body,
            Response_Code__c = qResponse.meta.httpStatus
        ));

        return qResponse;

    }

    /**
    @description Creates a Qualtrics Contact inside of an existing Mailing List
    @param directoryId the default directory id defined by Qualtrics
    @param mailingListId the mailing list ID to generate a Distribution against
    @param studyId the Study ID (Salesforce)
    @param studyAccountId the Study Account ID (Salesforce)
    @return QualtricsApiService.response containing the Qualtrics Contact ID
    */
    public static QualtricsApiService.response createContactInMailingList(String directoryId, String mailingListId, Id studyId, Id studyAccountId){

        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new QualtricsApiRequestMock(QualtricsApiRequestMock.QualtricsApiRequestType.CREATE_CONTACT_IN_MAILING_LIST));
        }

        QualtricsContactRequest request = new QualtricsContactRequest(studyAccountId);

        String requestUrl = '/directories/' + directoryId + '/mailinglists/' + mailingListId + '/contacts';
        String jsonString = JSON.serializePretty(request);

        String response = new Request().post(requestUrl, jsonString);

        QualtricsApiService.response qResponse = (QualtricsApiService.response)JSON.deserialize(response, QualtricsApiService.response.class);

        String body = 'REQUEST:\n\n' + jsonString + '\n\nRESPONSE:\n\n' + JSON.serializePretty(qResponse);

        apiTransactions.add(new Api_Transaction__c(
            Request_URL_Long_Text__c = requestUrl,
            Study__c = studyId,
            Study_Account__c = studyAccountId,
            Body__c = body,
            Response_Code__c = qResponse.meta.httpStatus
        ));

        return qResponse;

    }

    /**
    @description Generates Distribution Links associated with the Survey and Distribution
    @param surveyId the Qualtrics Survey which the links the are associated with
    @param mailingListId the mailing list ID to generate a Distribution against
    @param studyId the Study ID (Salesforce)
    @param studyAccountId the Study Account ID (Salesforce)
    @return QualtricsApiService.response containing the Qualtrics Distribution ID
    */
    public static QualtricsApiService.response generateDistributionLinks(String surveyId, String mailingListId, Id studyId, Id studyAccountId){

        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new QualtricsApiRequestMock(QualtricsApiRequestMock.QualtricsApiRequestType.GENERATE_DISTRIBUTION_LINKS));
        }

        QualtricsDistributionLinkRequest request = new QualtricsDistributionLinkRequest(surveyId, mailingListId);

        String requestUrl = '/distributions';
        String jsonString = JSON.serializePretty(request);

        String response = new Request().post(requestUrl, jsonString);

        QualtricsApiService.response qResponse = (QualtricsApiService.response)JSON.deserialize(response, QualtricsApiService.response.class);

        String body = 'REQUEST:\n\n' + jsonString + '\n\nRESPONSE:\n\n' + JSON.serializePretty(qResponse);

        apiTransactions.add(new Api_Transaction__c(
            Request_URL_Long_Text__c = requestUrl,
            Study__c = studyId,
            Study_Account__c = studyAccountId,
            Body__c = body,
            Response_Code__c = qResponse.meta.httpStatus
        ));

        return qResponse;

    }

    /**
    @description Retrieves all Distribution Links associated with the Survey and Distribution
    @param surveyId the Qualtrics Survey which the links the are associated with
    @param distributionId the Qualtrics Distribution ID to retrieve links from
    @param studyId the Study ID (Salesforce)
    @param studyAccountId the Study Account ID (Salesforce)
    @return QualtricsApiService.response containing a list of Qualtrics Distribution Links
    */
    public static QualtricsApiService.response getDistributionLinks(String surveyId, String distributionId, Id studyId, Id studyAccountId){
        
        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new QualtricsApiRequestMock(QualtricsApiRequestMock.QualtricsApiRequestType.GET_DISTRIBUTION_LINKS));
        }

        String requestUrl = '/distributions/' + distributionId + '/links?surveyId=' + surveyId;

        String response = new Request().get(requestUrl);

        QualtricsApiService.response qResponse = (QualtricsApiService.response)JSON.deserialize(response, QualtricsApiService.response.class);

        String body = 'RESPONSE:\n\n' + JSON.serializePretty(qResponse);

        apiTransactions.add(new Api_Transaction__c(
            Request_URL_Long_Text__c = requestUrl,
            Study__c = studyId,
            Study_Account__c = studyAccountId,
            Body__c = body,
            Response_Code__c = qResponse.meta.httpStatus
        ));

        return qResponse;

    }

    public class Request{

        private Http h { get; set; }
        private HttpRequest req { get; set; }
        private String url { get; set; }

        private String baseUrl { get; set; }
        private String xApiToken { get; set; }

        public Request(){

            this.h = new Http();
            this.req = new HttpRequest();
            this.baseUrl = 'https://az1.qualtrics.com/API/v3';
            this.xApiToken = Label.Qualtrics_X_Api_Token;

        }

        public String post(String url, String jsonBody){

            System.debug(url);

            this.req.setEndpoint(this.baseUrl + url);
            this.req.setMethod('POST');
            this.req.setHeader('X-API-TOKEN', this.xApiToken);
            this.req.setHeader('Content-Type', 'application/json');
            this.req.setBody(jsonBody);

            HttpResponse res = this.h.send(this.req);

            return res.getBody();

        }

        public String get(String url){

            System.debug(url);

            this.req.setEndpoint(this.baseUrl + url);
            this.req.setMethod('GET');
            this.req.setHeader('X-API-TOKEN', this.xApiToken);

            HttpResponse res = this.h.send(this.req);

            return res.getBody();

        }

    }

}