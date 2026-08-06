@isTest
public class gbiService_test {

    private static final String API_KEY = 'test-api-key-gbi';

    @TestSetup
    static void setup() {
        GBI_Service_Config__c apiKeySetting = new GBI_Service_Config__c(Name = 'X-API-KEY', Value__c = API_KEY);
        insert apiKeySetting;
        GBI_Service_Config__c bucketSetting = new GBI_Service_Config__c(Name = 'AWS_Bucket', Value__c = 'default-gbi-bucket');
        insert bucketSetting;

        Study__c s = new Study__c(Name = 'GBI Service Test Study', Status__c = 'In Progress', Start_Date__c = Date.today().addDays(-10), End_Date__c = Date.today().addDays(90));
        insert s;

        Study_Round__c sr = new Study_Round__c(Name = 'Round 1', Study__c = s.Id, Status__c = 'Data Collection', Round__c = 'Version 1');
        insert sr;

        Account accNo = new Account(Name = 'Acct No Bucket', GBI_region__c = 'North America', BillingCountry = 'United States');
        insert accNo;

        Account accWith = new Account(Name = 'Acct With Bucket', GBI_region__c = 'North America', BillingCountry = 'United Kingdom', GBI_AWS_Bucket__c = 'custom-account-bucket');
        insert accWith;

        insert new Study_Account__c(Name = 'SA AWS', Study__c = s.Id, Account__c = accNo.Id, Status__c = 'Active', Role__c = 'Participant', Secure_File_Platform__c = 'AWS');
        insert new Study_Account__c(Name = 'SA AWS Custom', Study__c = s.Id, Account__c = accWith.Id, Status__c = 'Active', Role__c = 'Participant', Secure_File_Platform__c = 'ShareFile;AWS');
        insert new Study_Account__c(Name = 'SA Non-AWS', Study__c = s.Id, Account__c = accNo.Id, Status__c = 'Active', Role__c = 'Participant', Secure_File_Platform__c = 'ShareFile');

        insert new GBI_Meta_Data__c(Name = 'Meta 2019', G_SIB__c = true, Year__c = '2019', Account__c = accNo.Id);
    }

    private static String getFirstPicklistValue(Schema.SObjectField fieldToken) {
        List<Schema.PicklistEntry> ple = fieldToken.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry e : ple) {
            if (e.isActive()) return e.getValue();
        }
        return null;
    }

    private static void setGetRequest(String requestUri, String xApiKey) {
        RestRequest req = new RestRequest();
        req.requestURI = requestUri;
        req.httpMethod = 'GET';
        if (xApiKey != null && req.headers != null) {
            req.headers.put('X-API-KEY', xApiKey);
        }
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    @isTest
    static void testGetStudiesWithDataProcessing() {
        List<Study__c> studies = [SELECT Id FROM Study__c WHERE Status__c = 'In Progress' LIMIT 1];
        System.assert(!studies.isEmpty(), 'Need at least one study In Progress');
        gbiService.returntData rd = gbiService.getStudiesWithDataProcessing();
        System.assertEquals(true, rd.status, 'status should be true');
        System.assertNotEquals(null, rd.studies, 'studies should not be null');
        System.assertNotEquals(null, rd.versions, 'versions should not be null');
        System.assertNotEquals(null, rd.studyAccounts, 'studyAccounts should not be null');
        for (Study_Account__c sa : rd.studyAccounts) {
            if (sa.Secure_File_Platform__c != null && sa.Secure_File_Platform__c.indexOf('AWS') > -1) {
                System.assert(String.isNotBlank(sa.AWS_Bucket__c), 'AWS study account should have bucket set');
            } else {
                System.assertEquals('', sa.AWS_Bucket__c, 'Non-AWS study account should have empty bucket');
            }
        }
    }

    @isTest
    static void testGetDataPorcessingMetaData() {
        gbiService.returntData rd = gbiService.getDataPorcessingMetaData();
        System.assertNotEquals(null, rd.accounts, 'accounts should not be null');
        System.assertNotEquals(null, rd.gbiMetaData, 'gbiMetaData should not be null');
    }

    @isTest
    static void testCreateDataSubmission() {
        String action = getFirstPicklistValue(Study_Data_Submission__c.Action__c);
        String statusVal = getFirstPicklistValue(Study_Data_Submission__c.Status__c);
        if (action == null || statusVal == null) {
            System.assert(false, 'Study_Data_Submission__c Action__c and Status__c must have at least one picklist value');
            return;
        }
        Study_Round__c sr = [SELECT Id FROM Study_Round__c LIMIT 1];
        Study_Account__c sa = [SELECT Id FROM Study_Account__c LIMIT 1];
        Study_Data_Submission__c ds = gbiService.createDataSubmission(sr.Id, sa.Id, action, statusVal, 'Test details');
        System.assertNotEquals(null, ds.Id, 'record should be inserted');
        System.assertEquals(sr.Id, ds.Study_Round__c, 'Study_Round__c should match');
        System.assertEquals(sa.Id, ds.Study_Account__c, 'Study_Account__c should match');
        System.assertEquals(action, ds.Action__c, 'Action__c should match');
        System.assertEquals(statusVal, ds.Status__c, 'Status__c should match');
        System.assertEquals('Test details', ds.Details__c, 'Details__c should match');
    }

    @isTest
    static void testHttpGetReturnsData() {
        setGetRequest('/services/apexrest/gbiService/', API_KEY);
        Test.startTest();
        gbiService.returntData rd = gbiService.gbiService();
        Test.stopTest();
        System.assertEquals(true, rd.status, 'GET with valid key should return success');
        System.assertNotEquals(null, rd.studies, 'studies should be returned');
        System.assert(RestContext.response.statusCode == null || RestContext.response.statusCode != 401, 'should not be 401');
    }

    @isTest
    static void testHttpGetReturnsMeta() {
        setGetRequest('/services/apexrest/gbiService/meta', API_KEY);
        Test.startTest();
        gbiService.returntData rd = gbiService.gbiService();
        Test.stopTest();
        System.assertEquals(true, rd.status, 'GET meta with valid key should return success');
        System.assertNotEquals(null, rd.gbiMetaData, 'gbiMetaData should be returned');
        System.assertNotEquals(null, rd.accounts, 'accounts should be returned');
    }

    @isTest
    static void testHttpGetUnauthorizedNoHeader() {
        setGetRequest('/services/apexrest/gbiService/', null);
        Test.startTest();
        gbiService.returntData rd = gbiService.gbiService();
        Test.stopTest();
        System.assertEquals(401, RestContext.response.statusCode, 'should return 401');
        System.assertEquals(false, rd.status, 'status should be false');
        System.assert(rd.details != null && rd.details.contains('401'), 'details should mention 401');
    }

    @isTest
    static void testHttpGetUnauthorizedWrongKey() {
        setGetRequest('/services/apexrest/gbiService/', 'wrong-key');
        Test.startTest();
        gbiService.returntData rd = gbiService.gbiService();
        Test.stopTest();
        System.assertEquals(401, RestContext.response.statusCode, 'should return 401');
        System.assertEquals(false, rd.status, 'status should be false');
    }

    @isTest
    static void testHttpPostSuccess() {
        String action = getFirstPicklistValue(Study_Data_Submission__c.Action__c);
        String statusVal = getFirstPicklistValue(Study_Data_Submission__c.Status__c);
        if (action == null || statusVal == null) return;
        Study__c s = [SELECT Id FROM Study__c LIMIT 1];
        Study_Round__c sr = [SELECT Id FROM Study_Round__c LIMIT 1];
        Study_Account__c sa = [SELECT Id FROM Study_Account__c LIMIT 1];
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/gbiService/';
        req.httpMethod = 'POST';
        if (req.headers != null) req.headers.put('X-API-KEY', API_KEY);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        gbiService.activityStatus astat = gbiService.gbiService('submit', s.Id, sr.Id, sa.Id, action, statusVal, 'Post test details');
        Test.stopTest();
        System.assertEquals(true, astat.status, 'POST with valid key should succeed');
        System.assert(astat.details != null && astat.details.contains('Study_Data_Submission__c'), 'details should contain record');
        List<Study_Data_Submission__c> submissions = [SELECT Id, Details__c FROM Study_Data_Submission__c WHERE Study_Round__c = :sr.Id AND Study_Account__c = :sa.Id];
        System.assertEquals(1, submissions.size(), 'one submission should be created');
        System.assertEquals('Post test details', submissions[0].Details__c, 'details should match');
    }

    @isTest
    static void testHttpPostWithTestBypass() {
        String action = getFirstPicklistValue(Study_Data_Submission__c.Action__c);
        String statusVal = getFirstPicklistValue(Study_Data_Submission__c.Status__c);
        if (action == null || statusVal == null) return;
        Study__c s = [SELECT Id FROM Study__c LIMIT 1];
        Study_Round__c sr = [SELECT Id FROM Study_Round__c LIMIT 1];
        Study_Account__c sa = [SELECT Id FROM Study_Account__c LIMIT 1];
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/gbiService/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        gbiService.activityStatus astat = gbiService.gbiService('submit', s.Id, sr.Id, sa.Id, action, statusVal, 'Test bypass');
        Test.stopTest();
        System.assertEquals(true, astat.status, 'POST in test can bypass key');
    }

    @isTest
    static void testHttpPostUnauthorized() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/gbiService/';
        req.httpMethod = 'POST';
        if (req.headers != null) req.headers.put('X-API-KEY', 'wrong');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        gbiService.activityStatus astat = gbiService.gbiService('submit', null, null, null, null, null, null);
        Test.stopTest();
        System.assertEquals(false, astat.status, 'POST with wrong key should fail');
        System.assertEquals(401, RestContext.response.statusCode, 'should return 401');
    }

    @isTest
    static void testHttpPostExceptionHandling() {
        String action = getFirstPicklistValue(Study_Data_Submission__c.Action__c);
        String statusVal = getFirstPicklistValue(Study_Data_Submission__c.Status__c);
        if (action == null) action = 'Upload';
        if (statusVal == null) statusVal = 'Completed';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/gbiService/';
        req.httpMethod = 'POST';
        if (req.headers != null) req.headers.put('X-API-KEY', API_KEY);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        gbiService.activityStatus astat = gbiService.gbiService('submit', null, 'invalidId', 'invalidId', action, statusVal, 'Will fail insert');
        Test.stopTest();
        System.assertEquals(false, astat.status, 'invalid ids should cause failure');
        System.assert(astat.details != null, 'details should contain error');
    }
}