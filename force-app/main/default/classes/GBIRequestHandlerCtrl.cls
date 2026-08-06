/*	Apex Controller for GBIRequestHandlerComp Lightning Component
 *	08/14/2019 Xiang: [US-25015] Created.
 */
public without sharing class GBIRequestHandlerCtrl {
	
    // Load Integration Configuration
    private static Map<String, String> gbiConfigs {
        get {
            if(null == gbiConfigs) {
                gbiConfigs = new Map<String, String>();
                for(GBI_Handler_Config__mdt oneConfig : [SELECT DeveloperName, Value__c FROM GBI_Handler_Config__mdt]) {
                    gbiConfigs.put(oneConfig.DeveloperName, oneConfig.Value__c);
                }
            }
            return gbiConfigs;
        }
        set;
    }
    
    @AuraEnabled
    public static User loadUser() {
        User u = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        return u;
    }
    
    @AuraEnabled
    public static List<Study__c> loadStudies() {
        Set<String> statusSet = new Set<String>();
        
        String studyStatus = gbiConfigs.get('STUDY_STATUS');
        if(String.isNotEmpty(studyStatus)) {
            statusSet.addAll(studyStatus.split(','));
        }else {
            statusSet.add('In Progress');
        }
        
        List<Study__c> studyList = [SELECT Id, Name FROM Study__c WHERE Status__c IN :statusSet];
        return studyList;
    }
    
    @AuraEnabled
    public static StudyDetail loadStudy(Id studyId) {
        StudyDetail sd = new StudyDetail();
        
        // Used Separate Queries to avoid potential not all records returned Salesforce issue
        sd.studyRounds = [SELECT Id, Study_Part__c FROM Study_Round__c WHERE Study__c = :studyId AND Status__c NOT IN (null)];
        sd.studyAccounts = [SELECT Id, Name, Account__c, Account__r.GBI_region__c, Account__r.GBI_Country_Code__c, Account__r.BillingCountry
                            FROM Study_Account__c WHERE Study__c = :studyId AND Status__c = 'Active' ORDER BY Name ASC];
        
        Set<Id> accountIds = new Set<Id>();
        for(Study_Account__c studyAccount : sd.studyAccounts) {
            accountIds.add(studyAccount.Account__c);
        }
        
        sd.gbiMetadata = [SELECT Id, Name, G_SIB__c, Year__c, Account__c FROM GBI_Meta_Data__c WHERE Account__c IN :accountIds];
        return sd;
    }
    
    @AuraEnabled
    public static GBIResult enqueueGBIRequest(String reqBody) {
        String enqueueUrl = gbiConfigs.get('BASE_URL') + '/enqueue';
        
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('ApiKey', gbiConfigs.get('API_KEY'));
        headerMap.put('User', UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
        headerMap.put('Content-Type', 'application/json');
        
        System.debug('Request URL: ' + enqueueUrl);
        System.debug('Request Headers: ' + headerMap);
        System.debug('Request Body: ' + reqBody);
        
        HttpResponse resp = sendRequest(enqueueUrl, 'POST', reqBody, headerMap);

        System.debug('Response Status: ' + resp.getStatusCode() + ' - ' + resp.getStatus());
        System.debug('Response Body: ' + resp.getBody());
		
        GBIResult resultData = new GBIResult(resp);
        return resultData;
    }
    
    @AuraEnabled
    public static GBIResult enqueueDeleteGBIRequest() {
        String deleteUrl = gbiConfigs.get('BASE_URL') + '/delete-jobs-by-user';
        
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('ApiKey', gbiConfigs.get('API_KEY'));
        headerMap.put('User', UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
        
        HttpResponse resp = sendRequest(deleteUrl, 'POST', null, headerMap);
        
        GBIResult resultData = new GBIResult(resp);
        return resultData;
    }

    public static HttpResponse sendRequest(String endpoint, String method, String body, Map<String, String> headers) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(Integer.valueOf(gbiConfigs.get('TIMEOUT')));
        
        req.setMethod(method);
        req.setEndpoint(endpoint);
        
        if(String.isNotEmpty(body)) {
            req.setBody(body);
        }
        
        if(null != headers && !headers.isEmpty()) {
            for(String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }
        
        HttpResponse resp;
        if(Test.isRunningTest()) {
            // For Testing without Integration
            resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setStatus('OK');
            resp.setBody('{"Status":"Pass"}');
        }else {
            resp = new Http().send(req);
        }
        
        return resp;
    }
    
    public class StudyDetail {
        @AuraEnabled public List<Study_Round__c> studyRounds {get; private set;}
        @AuraEnabled public List<Study_Account__c> studyAccounts {get; private set;}
        @AuraEnabled public List<GBI_Meta_Data__c> gbiMetadata {get; private set;}
    }
    
    public class GBIResult {
        @AuraEnabled public Integer statusCode {get; private set;}
        @AuraEnabled public String status {get; private set;}
        @AuraEnabled public String body {get; private set;}
        
        // For additional details
        @AuraEnabled public Map<String, String> details {get; private set;}
        
        public GBIResult(HttpResponse resp) {
            this.statusCode = resp.getStatusCode();
            this.status = resp.getStatus();
            this.body = resp.getBody();
        }
    }
    
    /* public static String prepareRequestBody(String appName, String appRoute, String studyId, String inptStudyPart, List<String> studyAcctIds, String inptStudyTables, String inptRatioSetDesc, String inptRatioSetComp, String inptRatioSetId) {
        GBIRequest req = new GBIRequest();
        
        req.AppName = appName;
        req.AppRoute = appRoute;
                                                
        req.database = studyId;
        req.studyPart = inptStudyPart;
        req.studyParticipants = String.join(studyAcctIds, ',');
        req.studyTables = inptStudyTables;
        req.ratioSetDescription = inptRatioSetDesc;
        req.ratioSetComposition = inptRatioSetComp;
        req.associatedRatioSetXID = inptRatioSetId;

		req.clientAttr = new Map<String, String>();
                                                
        String jsonBody = JSON.serializePretty(req, true);
        return jsonBody;
    } */
    
    /* private class GBIRequest {
        private String AppName {get;set;}
        private String AppRoute {get;set;}
        
        private String database {get;set;}
        private String studyPart {get;set;}
        private String studyParticipants {get;set;}
        private String studyTables {get;set;}
        private String ratioSetDescription {get;set;}
        private String ratioSetComposition {get;set;}
        private String associatedRatioSetXID {get;set;}
        
        private Map<String, String> clientAttr {get;set;}
        private Map<String, Object> clientMeta {get;set;}
    }*/
}