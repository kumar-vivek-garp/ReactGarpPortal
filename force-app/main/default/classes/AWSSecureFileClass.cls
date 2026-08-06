public class AWSSecureFileClass {    
    
    // API Call Methods
    
    //public static string testNamedCredAWSQuickSightGET() {
    //    HttpRequest req = new HttpRequest();
    //    req.setEndpoint('callout:AWS_Quicksight');
    //    req.setMethod('GET');                       
    //    Http http = new Http();
    //    HTTPResponse res = http.send(req);                
    //    System.debug(res.getBody());
    //    return res.getBody();
    //}


    public class respAWSQuicksightEmbed {
        public String AnonymousUserArn;
        public String EmbedUrl;
        public String RequestId;
    }
    
    
    public static respAWSQuicksightEmbed sendGetQuicksightEmbedURL(String dashboardId, String bankKey, String fieldData) {
        GARP_Common.debugLog('AWSSecureFileClass','sendGetQuicksightEmbedURL','dashboardId',dashboardId);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetQuicksightEmbedURL','bankKey',bankKey);
        
        HttpRequest req = new HttpRequest();
        String awsAccountId = Label.GARP_AWS_Account;
        String endPoint = 'callout:AWS_Quicksight/accounts/' + awsAccountId + '/embed-url/anonymous-user';
        req.setEndpoint(endPoint);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetQuicksightEmbedURL','endPoint',endPoint);
       
        String userArn = 'arn:aws:quicksight:us-east-1:' + awsAccountId;

        String embedUrlRequestBody = '{"AwsAccountId": "' + awsAccountId + '","SessionLifetimeInMinutes": 600,"Namespace": "default",';
        embedUrlRequestBody+='"SessionTags":[{"Key": "Org_tag","Value":"'+ bankKey + ',' + fieldData + '"}],';
        embedUrlRequestBody+='"AuthorizedResourceArns":["' + userArn + ':dashboard/' + dashboardId + '"],';
        embedUrlRequestBody+='"ExperienceConfiguration":{"Dashboard":{"InitialDashboardId": "' + dashboardId + '"}}}';
        
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setbody(embedUrlRequestBody);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetQuicksightEmbedURL','embedUrlRequestBody',embedUrlRequestBody);
        
        Http http = new Http();
        
        String respbody;
        if(!Test.isRunningTest()) {
            HTTPResponse res = http.send(req);  
            respbody = res.getBody();            
        } else {
            respbody = '{"AnonymousUserArn":"arn:aws:quicksight:us-east-1:906094709071:anonymousUser/default/4de1baec3b14474ab77bdf70c0b01130","EmbedUrl":"https://us-east-1.quicksight.aws.amazon.com/embed/33e35756aa6840ce9a03ef5a154f7713/dashboards/e1b9214a-71a0-4b38-928a-bded98b6059c?identityprovider=quicksight&isauthcode=true&code=AYABeC5K-yszFUmAgZOyThEBkZsAAAABAAdhd3Mta21zAEthcm46YXdzOmttczp1cy1lYXN0LTE6MjU5NDgwNDYyMTMyOmtleS81NGYwMjdiYy03MDJhLTQxY2YtYmViNS0xNDViOTExNzFkYzMAuAECAQB4g1oL4hdUJZc1aKfcGo-VQb_jBEsh0RowAd9MxoJqXpEBsiwpFVKEvg5jmEla1141CAAAAH4wfAYJKoZIhvcNAQcGoG8wbQIBADBoBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDI89emsZqrYX2R0DmQIBEIA7GdifvCfmki7HaLFumQmV8bC9Wjo-hZiLLsnHPCUKiZ_zFPT5DV-MzJzUhJZ-e3ZBU2cb0vmf06_NC6MCAAAAAAwAABAAAAAAAAAAAAAAAAAAknYZxWxux8djjAlI5-4dv_____8AAAABAAAAAAAAAAAAAAABAAAAmznPx6ff16Ypa7cveFa035ONAGiC8Lq9bftPPnfrYVjeynMzaEEh9RQ7HE3X3o79i2Y5xVt5Y6xVfGf958cWRygkQLxkNhBD5kZknXa8vhF_92khxv0iAHPKOLsMoM1tZAj9kqoX7plel4q3If7JXcymVMau58jbEpmoAbzZxHqNdiOCV62UUtItk6kT2Aj1zvqLlUrbm9GKcRu3Ghk2bYz0v9TAqE9yS2d9cA%3D%3D","RequestId":"40ae611d-7d9c-4d9f-bc90-446100f7511a"}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetQuicksightEmbedURL','respbody',respbody);
        
        respAWSQuicksightEmbed respAWSQuicksightEmbed = (respAWSQuicksightEmbed)JSON.deserialize(respbody, respAWSQuicksightEmbed.class);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetQuicksightEmbedURL','respAWSQuicksightEmbed',respAWSQuicksightEmbed);
        
        return respAWSQuicksightEmbed;     
        
    }
    
    // Auth
    
    public class reqAuth {
        public String email;
        public String password;
    }
    
    public class respAuth {
        public String status;
        public Integer statusCode;
        public String message;
        public String data;
    }

    public class respAuthError {
        public String status;
        public Integer statusCode;
        public String message;
        public String data;
    }

    
    public class returnSendAuth {
        public API_Transaction__c apiTrans;
        public respAuth respAuth;
    }

    public static returnSendAuth sendAuth() {
        returnSendAuth returnSendAuth = new returnSendAuth();
        reqAuth req = new reqAuth();
        
        String username = Label.GARP_AWSSecureFile_Username;
        String password = Label.GARP_AWSSecureFile_Password;
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAuth','username',username);
        GARP_Common.debugLog('AWSSecureFileClass','sendAuth','password',password);
        
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/users/login';

        GARP_Common.debugLog('AWSSecureFileClass','sendAuth','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('POST');        
        request.setHeader('content-type', 'application/json');
        
        req.email = username;
        req.password = password;
        
        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        GARP_Common.debugLog('AWSSecureFileClass','sendAuth','jsonBody',jsonBody);
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAuth','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status": "success","statusCode": 200,"message": "Successfully Logged In","data": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN5c3RlbXVzZXJAc2VjdXJlZmlsZXNoYXJlLmNvbSIsImlhdCI6MTczNjg5MDE2MCwiZXhwIjoxNzM2ODkzNzYwfQ.ozmT2uSULPR4qjHOlWEFO7tdhxeEFTqwZWC_BP0Hbc0"}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAuth','respbody',respbody);
        
        respAuth respAuth = (respAuth)JSON.deserialize(respbody, respAuth.class);
        
        returnSendAuth.respAuth = respAuth;
        
        returnSendAuth.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendAuth',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = jsonBody.left(32767),
            Response_Code__c = String.ValueOf(statusCode)
        );
        GARP_Common.debugLog('AWSSecureFileClass','sendAuth','apitrans',returnSendAuth.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAuth','returnSendAuth',returnSendAuth);
        
        return returnSendAuth;
    }
    
    
    // Get System User Info
    
    public class respUserInfoDataAssignFolder {
        public String folderId;
        public String folderName;
        public String id;
        public String folderExternalId;
    }
    
    public class respUserInfoData {
        public String userType;
        public String status;
        public String email;
        public String id;
        public String name;
        public String externalId;
        public List<String> customerAccountsIds;
        public List<respUserInfoDataAssignFolder> assignedFolders;
    }
    
    public class respUserInfo {
        public String status;
        public Integer statusCode;
        public String message;
        public respUserInfoData data;
    }
    
    public class returnSendGetUserInfo {
        public API_Transaction__c apiTrans;
        public respUserInfo respUserInfo;
    }
    
    public static returnSendGetUserInfo sendGetUserInfo(String authToken) {
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUserInfo','authToken',authToken);
        
        returnSendGetUserInfo returnSendGetUserInfo = new returnSendGetUserInfo();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/users/userInfo';

        GARP_Common.debugLog('AWSSecureFileClass','sendGetUserInfo','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('GET');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUserInfo','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Successfully fetched","data":{"password":"$2b$10$ya7e00LEJA9j7.Ckc8SOZe0OqlhiFznRphHNzQ3gQQqyupLxnQOPK","customerAccountsIds":["1738241934448_j7snl26uy8","1738247452407_dquo2c6lqnb"],"userType":"Internal","status":"Active","email":"systemuser@securefileshare.com","id":"1733481557614_86x4opg5y93","name":"System User","roleId":"1727962776117_ow4kkirnab","externalId":"System User","role":{"isActive":true,"description":"","id":"1727962776117_ow4kkirnab","name":"Admin","permissionIds":["1735905549274_ac5tf8fvi"],"status":"Active"},"permissions":[{"action":"Create","id":"1728055983946_0s5j942vd1os","name":"Create Customer","resource":"Customer"}],"customers":[{"createdDate":"2025-02-04T18:25:26.915Z","bucketId":"1738248000490_u4ir5y1wea","status":"Active","rootFolderId":"1739313172444_m6atfc5yh5","id":"1739313176405_mtvjjl0vmg","name":"Nykredit","externalId":"0014000001qdQmkAAE"}],"assignedFolders":[{"canDelete":true,"customerAccountId":"1738241934448_j7snl26uy8","canDownload":true,"userId":"1733481557614_86x4opg5y93","folderId":"1738241927536_jihva555tep","canUpload":true,"folderName":"BOA","id":"1739313628977_3ejcj7ufjlh","folderExternalId":"BOA_12345"},{"canDelete":true,"customerAccountId":"1738247452407_dquo2c6lqnb","canDownload":true,"userId":"1733481557614_86x4opg5y93","folderId":"1738247441306_53m1y1kjeww","canUpload":true,"folderName":"CitiBank","id":"1739313628977_w26zc9f78q","folderExternalId":"0016u00000k5JNqAAM"}]}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUserInfo','respbody',respbody);
        
        respUserInfo respUserInfo = (respUserInfo)JSON.deserialize(respbody, respUserInfo.class);
        
        returnSendGetUserInfo.respUserInfo = respUserInfo;
        
        returnSendGetUserInfo.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendGetUserInfo',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = endpoint,
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUserInfo','apitrans',returnSendGetUserInfo.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUserInfo','returnSendGetUserInfo',returnSendGetUserInfo);
        
        return returnSendGetUserInfo;
    }
    
    
    
    // GET User
    
    public class respUserFolder {
        public Boolean canRead;
        public Boolean canDownload;
        public Boolean canUpload;
        public String folderId;
        public String folderExternalId;
    }

    public class respUserCustomer {
        public String rootFolderId;
        public String id;
        public String externalId;
        public String name;
        public String bucketId;
        public String customerId;
        public String status;
    }
    
    public class respGetUserData {
        List<respUser> users;
    }
    
    public class respGetUser {
        public String status;
        public Integer statusCode;
        public String message;
        public respGetUserData data;
    }
    
    public class respUser {
        public String userType;
        public String status;
        public String email;
        public String userId;
        public String id;
        public String externalId;
        public String name;
        List<respUserFolder> assignedFolders;
        List<respUserCustomer> customers;
    }
    
    public class returnSendGetUser {
        public API_Transaction__c apiTrans;
        public respGetUser respGetUser;
    }
    
    public static returnSendGetUser sendGetUser(String authToken, String contactId) {
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUser','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUser','contactId',contactId);
        
        returnSendGetUser returnSendGetUser = new returnSendGetUser();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/users/external?externalId=' + contactId;

        GARP_Common.debugLog('AWSSecureFileClass','sendGetUser','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('GET');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUser','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Successfully fetched","data":{"users":[{"customerAccountsIds":["1733304300417_14srwgzsakb"],"userType":"External","userId":"ERRT","status":"Active","email":"garcia.alberto.crespo+prepodgbi@gmail.com","id":"1733304338303_3fa8shrpznt","name":"Matt Lovett","roleId":"1732202251599_iu8niggwqqq","assignedFolders":[{"canRead":false,"customerAccountId":"1733304300417_14srwgzsakb","canDownload":false,"userId":"1733304338303_3fa8shrpznt","folderId":"1733304294351_lty4wd3pgu","canUpload":true,"id":"1736878679587_qfprjifl2fb"}],"customers":[{"rootFolderId":"1733304294351_lty4wd3pgu","id":"1733304300417_14srwgzsakb","name":"Morgan Stanley","bucketId":"1728303251601_iyqg3tip72","customerId":"Morgan_1234","status":"Active"}],"role":{"description":"Customer","id":"1732202251599_iu8niggwqqq","name":"Customer","permissionIds":["1728056176196_ndxzycjrco"],"status":"Active"}}]}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUser','respbody',respbody);
        
        respGetUser respGetUser = (respGetUser)JSON.deserialize(respbody, respGetUser.class);
        
        returnSendGetUser.respGetUser = respGetUser;
        
        returnSendGetUser.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Contact__c = contactId,
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendGetUser',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUser','apitrans',returnSendGetUser.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetUser','returnSendGetUser',returnSendGetUser);
        
        return returnSendGetUser;
    }
    
        
    public class respCreateUserData {
        public String status;
        public String roleId;
        public String userType;
        public String email;
        public String name;
        public String id;
        public String externalId;
    }
    
    public class respCreateUser {
        public String status;
        public Integer statusCode;
        public String message;
        public respCreateUserData data;
    }
    
     public class returnSendCreateUser {
        public API_Transaction__c apiTrans;
        public respCreateUser respCreateUser;
    }
    
    public class reqCreateUserFoldersPermissions {
        public Boolean canUpload;
        public Boolean canDownload;
        public Boolean canDelete;
    }
    
    public class reqCreateUserFolders {
        public String id;
        public String folderName;
        public String folderExternalId;
        public String customerAccountId;
        public reqCreateUserFoldersPermissions permissions;
    }
    
    public class reqCreateUser {
        public String name;
        public String email;
        public String userType;
        public String userId;
        public List<String> customerAccountsIds;
        public String roleId;        
        public List<reqCreateUserFolders> assignFolders;
    }
    
    public static returnSendCreateUser sendCreateUser(String authToken, String contactId, String contactName, String contactEmail, String customerId, String studyName, String studyId, String studyFolderId) {
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','contactName',contactName);
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','contactEmail',contactEmail);
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','customerId',customerId);
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','studyName',studyName);
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','studyId',studyId);
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','studyFolderId',studyFolderId);
               
        returnSendCreateUser returnSendCreateUser = new returnSendCreateUser();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/users';

        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('POST');        
        request.setHeader('content-type', 'application/json');
        
        reqCreateUser req = new reqCreateUser();
        req.name = contactName;
        req.email = contactEmail;
        req.userType = 'External';
        req.userId = contactId;
        req.roleId = Label.GARP_AWSSecureFile_RoleId;
        
        req.customerAccountsIds = new List<String>();
        req.customerAccountsIds.add(customerId);
        
        req.assignFolders = new List<reqCreateUserFolders>();
        
        reqCreateUserFolders reqCreateUserFolders = new reqCreateUserFolders();
        reqCreateUserFolders.id = studyFolderId;
        reqCreateUserFolders.folderName = studyName;
        reqCreateUserFolders.folderExternalId = studyName;
        reqCreateUserFolders.customerAccountId = customerId;
        reqCreateUserFolders.permissions = new reqCreateUserFoldersPermissions();
        
        reqCreateUserFolders.permissions.canUpload = True;
        reqCreateUserFolders.permissions.canDownload = True;
        reqCreateUserFolders.permissions.canDelete = False;
        
        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','jsonBody',jsonBody);
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":201,"message":"Successfully created","data":{"status":"Active","roleId":"1732202251599_iu8niggwqqq","customerAccountsIds":["1739540001740_oa25rp7vhsn"],"userType":"External","email":"760894@garp.com","name":"John Schiavetta","id":"1739552922175_exbqxqdy6k4","assignedFolders":[{"id":"1739552922183_ped6in9soy","userId":"1739552922175_exbqxqdy6k4","folderId":"1739480496752_rv49new3s9","folderName":"Buy-Side Operational Error Benchmarking Study","folderExternalId":"a3P5d000000S80UEAS","customerAccountId":"1739540001740_oa25rp7vhsn","canUpload":true,"canDownload":true,"canDelete":false}],"externalId":"0031W000022fLQPQA2"}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','respbody',respbody);
        
        respCreateUser respCreateUser = (respCreateUser)JSON.deserialize(respbody, respCreateUser.class);
        
        returnSendCreateUser.respCreateUser = respCreateUser;
        
        returnSendCreateUser.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Contact__c = contactId,
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendCreateUser',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = jsonBody,
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','apitrans',returnSendCreateUser.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendCreateUser','returnSendCreateUser',returnSendCreateUser);
        
        return returnSendCreateUser;
    }
    
    public class respAddUserFolderRights {
        public String status;
        public Integer statusCode;
        public String message;
        public respCreateUserData data;
    }
    
     public class returnSendAddUserFolderRights {
        public API_Transaction__c apiTrans;
        public respAddUserFolderRights respAddUserFolderRights;
    }
    
    public static returnSendAddUserFolderRights sendAddUserFolderRights(String authToken, String userId, String folderId, Boolean canUpload, Boolean canDownload) {
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','userId',userId);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','folderId',folderId);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','canUpload',canUpload);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','canDownload',canDownload);
               
        returnSendAddUserFolderRights returnSendAddUserFolderRights = new returnSendAddUserFolderRights();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/users/' + userId + '/folders/' + folderId;

        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('POST');        
        request.setHeader('content-type', 'application/json');
        
        reqCreateUserFoldersPermissions req = new reqCreateUserFoldersPermissions();
        req.canUpload = canUpload;
        req.canDownload = canDownload;
        req.canDelete = False;
        
        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','jsonBody',jsonBody);
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Successfully folder assigned","data":{}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','respbody',respbody);
        
        respAddUserFolderRights respAddUserFolderRights = (respAddUserFolderRights)JSON.deserialize(respbody, respAddUserFolderRights.class);
        
        returnSendAddUserFolderRights.respAddUserFolderRights = respAddUserFolderRights;
        
        returnSendAddUserFolderRights.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendAddUserFolderRights',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = jsonBody,
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','apitrans',returnSendAddUserFolderRights.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserFolderRights','returnSendAddUserFolderRights',returnSendAddUserFolderRights);
        
        return returnSendAddUserFolderRights;
    }
    
    
    public static returnSendAddUserFolderRights sendUpdateUserFolderRights(String authToken, String userId, String folderId, Boolean canUpload, Boolean canDownload) {
        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','userId',userId);
        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','folderId',folderId);
        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','canUpload',canUpload);
        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','canDownload',canDownload);
               
        returnSendAddUserFolderRights returnSendAddUserFolderRights = new returnSendAddUserFolderRights();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/users/' + userId + '/folders/' + folderId;

        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('PUT');        
        request.setHeader('content-type', 'application/json');
        
        reqCreateUserFoldersPermissions req = new reqCreateUserFoldersPermissions();
        req.canUpload = canUpload;
        req.canDownload = canDownload;
        req.canDelete = False;
        
        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','jsonBody',jsonBody);
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Successfully folder assigned","data":{}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','respbody',respbody);
        
        respAddUserFolderRights respAddUserFolderRights = (respAddUserFolderRights)JSON.deserialize(respbody, respAddUserFolderRights.class);
        
        returnSendAddUserFolderRights.respAddUserFolderRights = respAddUserFolderRights;
        
        returnSendAddUserFolderRights.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendAddUserFolderRights',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = jsonBody,
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','apitrans',returnSendAddUserFolderRights.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendUpdateUserFolderRights','sendUpdateUserFolderRights',returnSendAddUserFolderRights);
        
        return returnSendAddUserFolderRights;
    }
    
    
    // GET Folder
    
    public class respGetFolderDataFolders {
        public String name;
        public String id;
        public String externalId;
    }

    public class respGetFolderDataFiles {
        public String name;
        public String id;
        public String uploadedDate;
        public String uploadedBy;
    }
    
    public class respGetFolderData {
        public String id;
        public List<respGetFolderDataFolders> folders;
        public List<respGetFolderDataFiles> files;
    }
    
    public class respGetFolder {
        public String status;
        public Integer statusCode;
        public String message;
        public String errorDetail;
        public respGetFolderData data;
    }
    
    public class returnSendGetFolder {
        public API_Transaction__c apiTrans;
        public respGetFolder respGetFolder;
    }
    
    public static returnSendGetFolder sendGetFolder(String authToken, String contactId, String folderId) {
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFolder','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFolder','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFolder','folderId',folderId);
        
        returnSendGetFolder returnSendGetFolder = new returnSendGetFolder();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/folders/' + folderId;

        GARP_Common.debugLog('AWSSecureFileClass','sendGetFolder','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('GET');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        if(contactId != NULL) {
            request.setHeader('userExternalId', contactId);    
        }
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFolder','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Fetched successfully","data":{"customerAccountId":"1738260097472_0ckduzdhnbqq","bucketId":"1738248000490_u4ir5y1wea","parentFolderId":"1738260085395_oxkcuaqmex","folderKey":"0016u00000k5JNqAAM/a3P6u0000009I0FEAU/","id":"1738260327159_bgo9u6rzra9","name":"Test Study","isRootFolder":false,"externalId":"a3P6u0000009I0FEAU","folders":[{"customerAccountId":"1738260097472_0ckduzdhnbqq","bucketId":"1738248000490_u4ir5y1wea","parentFolderId":"1738260327159_bgo9u6rzra9","folderKey":"0016u00000k5JNqAAM/a3P6u0000009I0FEAU/Results/","id":"1738348063864_6g9722clk3a","name":"Results","isRootFolder":false,"externalId":"Results"}],"files":[{"bucketId":"1738248000490_u4ir5y1wea","folderId":"1738260327159_bgo9u6rzra9","uploadedBy":"1727964759650_i17031n9nxc","fileKey":"0016u00000k5JNqAAM/a3P6u0000009I0FEAU/7KB Data sheet.xlsx","uploadStatus":"Initialized","uploadedDate":"Fri Feb 14 2025 14:51:51 GMT+0000 (Coordinated Universal Time)","id":"1739544711184_4lb9n76ubhe","name":"7KB Data sheet.xlsx"},{"tempChunkFolder":"0016u00000k5JNqAAM/a3P6u0000009I0FEAU/temp/JVwvOYOTY49uPL442h4AdM.g03MU1ujqg75VLHk88nhUERbhtII28l4ZDr8Z4L3pJdt96KRCihyLcizPvYmj5u1ofj7NGOjzp5ixFtgxCCW0qtgPHQwRd9.7GMItDnsb/","uploadId":"JVwvOYOTY49uPL442h4AdM.g03MU1ujqg75VLHk88nhUERbhtII28l4ZDr8Z4L3pJdt96KRCihyLcizPvYmj5u1ofj7NGOjzp5ixFtgxCCW0qtgPHQwRd9.7GMItDnsb","parts":[{"PartNumber":1,"ETag":""}],"currentChunkSize":0,"bucketId":"1738248000490_u4ir5y1wea","folderId":"1738260327159_bgo9u6rzra9","uploadedBy":"1733481557614_86x4opg5y93","fileKey":"0016u00000k5JNqAAM/a3P6u0000009I0FEAU/BackGround4.jpg","uploadStatus":"Completed","uploadedDate":"Tue Feb 18 2025 17:52:26 GMT+0000 (Coordinated Universal Time)","id":"1739901146872_3m4k9lnaks3","name":"BackGround4.jpg"}],"info":{"canDelete":true,"customerAccountId":"1738260097472_0ckduzdhnbqq","canDownload":true,"userId":"1733481557614_86x4opg5y93","folderId":"1738260327159_bgo9u6rzra9","canUpload":true,"folderName":"Test Study","id":"1739313628977_kpwahsyxbze","folderExternalId":"a3P6u0000009I0FEAU"}}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFolder','respbody',respbody);
        
        respGetFolder respGetFolder = (respGetFolder)JSON.deserialize(respbody, respGetFolder.class);
        
        returnSendGetFolder.respGetFolder = respGetFolder;
        
        returnSendGetFolder.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Contact__c = contactId,
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendGetFolder',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        if(contactId != NULL) {
            returnSendGetFolder.apitrans.Headers__c = 'userExternalId:'+ contactId;
        }
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFolder','apitrans',returnSendGetFolder.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFolder','returnSendGetFolder',returnSendGetFolder);
        
        return returnSendGetFolder;
    }

    // Upload File
     
    public class respFileUploadData {
        public String fileKey;
        public String name;
        public String id;
        public String uploadId;
    }


    public class respFileUpload {
        public String status;
        public Integer statusCode;
        public String message;
        public String errorDetail;
        public respFileUploadData data;
    }
    
    public class reqFileUpload {
        public String file;
    }
    
    public class returnSendUploadFile {
        public API_Transaction__c apiTrans;
        public respFileUpload respFileUpload;
    }
    
    // https://stackoverflow.com/questions/55761644/how-to-upload-an-audio-file-in-apex-code-via-multipart-formdata
    public static final String BOUNDARY = '----FormBoundary4Amf13kZd';
    public static final String EXTRABOUNDARY = '--' + BOUNDARY;
    
    public static Blob multiPartFormDataBody(Blob file, String contentType, String filename, Map<String, String> metadataMap) {
        contentType = contentType == '' ? 'application/octet-stream' : contentType;
        
        String bodyStartHex;
        String bodyEndHex = EncodingUtil.convertToHex(Blob.valueOf(EXTRABOUNDARY + '--\r\n'));
        
        if(file != NULL) {
            bodyStartHex = EncodingUtil.convertToHex(Blob.valueOf(EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name=\"file\"; filename="' + filename + '"\r\nContent-Type: ' + contentType + '\r\n\r\n'));            
        } else {
            bodyStartHex = '';          
        }
        
        GARP_Common.debugLog('AWSSecureFileClass','multiPartFormDataBody','contentType',contentType);
        GARP_Common.debugLog('AWSSecureFileClass','multiPartFormDataBody','bodyStartHex',bodyStartHex);
        GARP_Common.debugLog('AWSSecureFileClass','multiPartFormDataBody','bodyEndHex',bodyEndHex);
        
        if(file != NULL) {
            bodyStartHex += EncodingUtil.convertToHex(file);
        }
        
        if (metadataMap != null && metadataMap.size() != 0) {
            String formElements = '\r\n';
            for (String key : metadataMap.keySet()) {
                formElements += EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name=\"' + key + '\"\r\n\r\n' + metadataMap.get(key) + '\r\n';
            }
            GARP_Common.debugLog('AWSSecureFileClass','multiPartFormDataBody','formElements',formElements);
            bodyStartHex += EncodingUtil.convertToHex(Blob.valueOf(formElements));
        } else {
            // the extra '--' at the end is crucial
            bodyEndHex = EncodingUtil.convertToHex(Blob.valueOf('\r\n' + EXTRABOUNDARY + '--'));
            GARP_Common.debugLog('AWSSecureFileClass','multiPartFormDataBody','bodyEndHex',bodyEndHex);
        }
        return EncodingUtil.convertFromHex(bodyStartHex + bodyEndHex);
    }
    
    public static returnSendUploadFile sendUploadFile(String contactId, String authToken, String fileName, String fileId, String uploadId, String folderId, String fileData, Boolean isLastPart) {
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','authToken',authToken);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','fileName',fileName);
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','fileId',fileId);
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','uploadId',uploadId);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','folderId',folderId);
        //GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','fileData',fileData.length());
        
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','isLastPart',isLastPart);
        
        returnSendUploadFile returnSendUploadFile = new returnSendUploadFile();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/folders/' + folderId + '/files';
        
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('POST');    
        
        // Try https://github.com/muenzpraeger/salesforce-einstein-vision-apex/blob/master/src/classes/EinsteinVision_HttpBodyPart.cls
        request.setHeader('Content-Type', 'multipart/form-data; boundary=' + BOUNDARY);

        Map<String, String> metadataMap = new Map<String, String>();
        
        //metadataMap.put('userExternalId',contactId);  
        metadataMap.put('fileName',fileName);  
        metadataMap.put('fileSize','1');  
        
            
        if(fileId != NULL) {
            metadataMap.put('fileId',fileId);    
            metadataMap.put('uploadId',uploadId);   
            if(isLastPart) {
                metadataMap.put('isUploadComplete','true');   
            }
        }
        
        String logBody = '';
        if(!isLastPart && fileData != NULL) {
            request.setBodyAsBlob(multiPartFormDataBody(EncodingUtil.base64Decode(fileData), 'application/vnd.ms-excel', fileName, metadataMap)); 
            logBody = '[File Data][' + 'application/vnd.ms-excel' + '][' + fileName + '][' + metadataMap + ']';
        } else {
            request.setBodyAsBlob(multiPartFormDataBody(NULL, 'application/vnd.ms-excel', fileName, metadataMap));
            logBody = '[NULL][' + 'application/vnd.ms-excel' + '][' + fileName + '][' + metadataMap + ']';
        }
        
        request.setHeader('userExternalId', contactId);
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        //reqFileUpload req = new reqFileUpload();
        //req.file = fileData;
        //String jsonBody = JSON.serialize(req);
        //request.setBody(jsonBody);
        //GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','jsonBody',jsonBody);
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Successfully fetched","data":{"users":[{"customerAccountsIds":["1733304300417_14srwgzsakb"],"userType":"External","userId":"ERRT","status":"Active","email":"garcia.alberto.crespo+prepodgbi@gmail.com","id":"1733304338303_3fa8shrpznt","name":"Matt Lovett","roleId":"1732202251599_iu8niggwqqq","assignedFolders":[{"canRead":false,"customerAccountId":"1733304300417_14srwgzsakb","canDownload":false,"userId":"1733304338303_3fa8shrpznt","folderId":"1733304294351_lty4wd3pgu","canUpload":true,"id":"1736878679587_qfprjifl2fb"}],"customers":[{"rootFolderId":"1733304294351_lty4wd3pgu","id":"1733304300417_14srwgzsakb","name":"Morgan Stanley","bucketId":"1728303251601_iyqg3tip72","customerId":"Morgan_1234","status":"Active"}],"role":{"description":"Customer","id":"1732202251599_iu8niggwqqq","name":"Customer","permissionIds":["1728056176196_ndxzycjrco"],"status":"Active"}}]}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','respbody',respbody);
        
        respFileUpload respFileUpload = (respFileUpload)JSON.deserialize(respbody, respFileUpload.class);
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','respFileUpload',respFileUpload);
        
        returnSendUploadFile.respFileUpload = respFileUpload;
        
        returnSendUploadFile.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendUploadFile',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Response_Code__c = String.ValueOf(statusCode),
            Body__c = GARP_Common.limitSize(logBody, 131000),
            Headers__c = 'Content-Type:multipart/form-data; boundary=' + BOUNDARY + ';userExternalId:' + contactId
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','apitrans',returnSendUploadFile.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendUploadFile','returnSendUploadFile',returnSendUploadFile);
        
        return returnSendUploadFile;
    }
    
    // Get File Detail (Scan Status)
    public class respGetFileDetailData {
        public String id;
        public String name;
        public String fileKey;
        public String bucketId;
        public String folderId;
        public String uploadedBy;
        public String uploadedDate;
        public String scanStatus;
        public String uploadStatus;
    }

    public class respGetFileDetail {
        public String status;
        public Integer statusCode;
        public String message;
        public String errorDetail;
        public respGetFileDetailData data;
    }

    public class returnSendGetFileDetail {
        public API_Transaction__c apiTrans;
        public respGetFileDetail respGetFileDetail;
    }

    public static returnSendGetFileDetail sendGetFileDetail(String authToken, String contactId, String fileId) {
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFileDetail','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFileDetail','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFileDetail','fileId',fileId);

        returnSendGetFileDetail returnSendGetFileDetail = new returnSendGetFileDetail();

        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();

        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/files/' + fileId;

        GARP_Common.debugLog('AWSSecureFileClass','sendGetFileDetail','endpoint',endpoint);

        request.setEndPoint(endpoint);
        request.setMethod('GET');
        request.setHeader('content-type', 'application/json');

        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');

        if(contactId != NULL) {
            request.setHeader('userExternalId', contactId);
        }

        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFileDetail','statusCode',statusCode);

        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"File details fetched successfully","data":{"id":"1770219233146_p0pi897hsxn","name":"GBI Data.xlsx","fileKey":"0011W00002QSHtSQAX/a3P5d000000UKKuEAO/GBI Data.xlsx","bucketId":"1769001600529_vv961oq4gyp","folderId":"1770218713461_etcmeikjfas","uploadedBy":"1770218714926_b9n2ltp7bwd","uploadedDate":"Wed Feb 04 2026 15:33:53 GMT+0000 (Coordinated Universal Time)","scanStatus":"CLEAN","uploadStatus":"Completed"}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetFileDetail','respbody',respbody);

        respGetFileDetail respGetFileDetail = (respGetFileDetail)JSON.deserialize(respbody, respGetFileDetail.class);

        returnSendGetFileDetail.respGetFileDetail = respGetFileDetail;

        returnSendGetFileDetail.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Contact__c = contactId,
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendGetFileDetail',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Response_Code__c = String.ValueOf(statusCode)
        );

        if(contactId != NULL) {
            returnSendGetFileDetail.apitrans.Headers__c = 'userExternalId:' + contactId;
        }

        GARP_Common.debugLog('AWSSecureFileClass','sendGetFileDetail','apitrans',returnSendGetFileDetail.apitrans);

        GARP_Common.debugLog('AWSSecureFileClass','sendGetFileDetail','returnSendGetFileDetail',returnSendGetFileDetail);

        return returnSendGetFileDetail;
    }
    
    public class respDownloadError {
        public String status;
        public Integer statusCode;
        public String message;
        public String errorDetail;
    }
    
    public class returnSendDownloadFile {
        public API_Transaction__c apiTrans;
        public Blob fileDataBlob;
        public Integer fileSize;
        public String errorDetail;
        public Integer statusCode;
    }
    
    public static returnSendDownloadFile sendDownloadFile(String contactId, String authToken, String folderId, String fileId, Integer start) {
        GARP_Common.debugLog('AWSSecureFileClass','sendDownloadFile','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','sendDownloadFile','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendDownloadFile','folderId',folderId);
        GARP_Common.debugLog('AWSSecureFileClass','sendDownloadFile','fileId',fileId);
        GARP_Common.debugLog('AWSSecureFileClass','sendDownloadFile','start',start);
        
        returnSendDownloadFile returnSendDownloadFile = new returnSendDownloadFile();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/folders/' + folderId + '/files/' + fileId + '/download?start=' + String.ValueOf(start) + '&chunkSize=1048576'; // 1 MB

        GARP_Common.debugLog('AWSSecureFileClass','sendDownloadFile','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('GET');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        request.setHeader('userExternalId', contactId);
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendDownloadFile','statusCode',statusCode);
        
        Blob respbodyBlob;
        if(!Test.isRunningTest()){
            respbodyBlob = response.getBodyAsBlob();
        } else {
            //respbodyBlob = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendDownloadFile','respbodyBlob',respbodyBlob);
        
        returnSendDownloadFile.statusCode = statusCode;
        
        if(statusCode == 200) {
            returnSendDownloadFile.fileDataBlob = respbodyBlob;
            
            string[] headerkeys = response.getHeaderKeys();
            for(string s : headerkeys){
                system.debug('***header: ' + s + ' value: ' + response.getHeader(s));
            }
            
            
            String fileSizeStr = response.getHeader('File-Size');
            if(fileSizeStr != NULL) {
                returnSendDownloadFile.fileSize = Integer.ValueOf(fileSizeStr);
                system.debug('***fileSize: ' + returnSendDownloadFile.fileSize);
            }
        } else {
            returnSendDownloadFile.statusCode = statusCode;
            respDownloadError respDownloadError = (respDownloadError)JSON.deserialize(response.getBody(), respDownloadError.class);
            returnSendDownloadFile.errorDetail = respDownloadError.errorDetail;
        }
        
        returnSendDownloadFile.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Contact__c = contactId,
            Response_Body__c = 'filedata too large',
            Description__c = 'sendDownloadFile',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Response_Code__c = String.ValueOf(statusCode),
            Headers__c = 'userExternalId:' + contactId
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendDownloadFile','apitrans',returnSendDownloadFile.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendDownloadFile','returnSendDownloadFile',returnSendDownloadFile);
        
        return returnSendDownloadFile;
    }
    
    // Provisioning Calls
    
    public class respGetBucketData {
        public String id;
        public String name;
        public String status;
    }
    
    public class respGetBuckets {
        public List<respGetBucketData> buckets;
    }
    
    public class respGetBucket {
        public String status;
        public Integer statusCode;
        public String message;
        public respGetBuckets data;
    }
    
    public class returnSendGetBuckets {
        public API_Transaction__c apiTrans;
        public respGetBucket respGetBucket;
    }
    
    public static returnSendGetBuckets sendGetBuckets(String authToken, String bucketName) {
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBuckets','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBuckets','bucketName',bucketName);
        
        returnSendGetBuckets returnSendGetBuckets = new returnSendGetBuckets();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/buckets?name=' + bucketName.tolowercase() + '&status=Active';

        GARP_Common.debugLog('AWSSecureFileClass','sendGetBuckets','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('GET');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBuckets','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Successfully fetched","data":{"buckets":[{"id":"1738832700347_jilwu8jjtc","name":"0014000000irpzmaa1","status":"Active"},{"id":"1734624900168_1csoilq0wcb","name":"demoanumedia","status":"InActive"}],"lastEvaluatedKey":{"id":"1739286600503_wfdpy63kp0q"},"hasMorePages":true}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBuckets','respbody',respbody);
        
        respGetBucket respGetBucket = (respGetBucket)JSON.deserialize(respbody, respGetBucket.class);
        
        returnSendGetBuckets.respGetBucket = respGetBucket;
        
        returnSendGetBuckets.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendGetBuckets',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBuckets','apitrans',returnSendGetBuckets.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBuckets','returnSendGetBuckets',returnSendGetBuckets);
        
        return returnSendGetBuckets;
    }
    
    public class respGetBucketFolderData {
        public String id;
        public String name;
        public String externalId;
    }
    
    public class respGetBucketFolders {
        public List<respGetBucketFolderData> folders;
    }
    
    public class respGetBucketFolder {
        public String status;
        public Integer statusCode;
        public String message;
        public respGetBucketFolders data;
    }
    
    public class returnSendGetBucketFolders {
        public API_Transaction__c apiTrans;
        public respGetBucketFolder respGetBucketFolder;
    }
    
    public static returnSendGetBucketFolders sendGetBucketFolders(String authToken, String bucketId) {
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBucketFolders','authToken',authToken);
        
        returnSendGetBucketFolders returnSendGetBucketFolders = new returnSendGetBucketFolders();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/buckets/' + bucketId + '/folders';

        GARP_Common.debugLog('AWSSecureFileClass','sendGetBucketFolders','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('GET');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBucketFolders','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Fetched successfully","data":{"root":"anybank","folders":[{"folderKey":"123456789/","id":"1739476871424_3fhajl9scxk","bucketId":"1728303251601_iyqg3tip72","name":"agtestrootfolderA","isRootFolder":false,"externalId":"123456789"},{"customerAccountId":"1738241934448_j7snl26uy8","bucketId":"1728303251601_iyqg3tip72","folderKey":"BOA_12345/","id":"1738241927536_jihva555tep","name":"BOA","isRootFolder":true,"externalId":"BOA_12345"}]}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBucketFolders','respbody',respbody);
        
        respGetBucketFolder respGetBucketFolder = (respGetBucketFolder)JSON.deserialize(respbody, respGetBucketFolder.class);
        
        returnSendGetBucketFolders.respGetBucketFolder = respGetBucketFolder;
        
        returnSendGetBucketFolders.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendGetBucketFolders',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBucketFolders','apitrans',returnSendGetBucketFolders.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetBucketFolders','returnSendGetBucketFolders',returnSendGetBucketFolders);
        
        return returnSendGetBucketFolders;
    }
    
    public class respAddBucketRootFolderData {
        public String id;
        public String name;
        public String externalId;
    }
    
    public class respAddBucketRootFolder {
        public String status;
        public Integer statusCode;
        public String message;
        public respAddBucketRootFolderData data;
    }
    
    public class returnSendAddBucketRootFolder {
        public API_Transaction__c apiTrans;
        public respAddBucketRootFolder respAddBucketRootFolder;
    }
    
    public class reqAddBucketRootFolder {
        public String name;
        public String folderId;
    }
    
    public static returnSendAddBucketRootFolder sendAddBucketRootFolder(String bucketId, String folderName, String folderId, String authToken) {
        GARP_Common.debugLog('AWSSecureFileClass','sendAddBucketRootFolder','bucketId',bucketId);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddBucketRootFolder','folderName',folderName);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddBucketRootFolder','folderId',folderId);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddBucketRootFolder','authToken',authToken);
        
        returnSendAddBucketRootFolder returnSendAddBucketRootFolder = new returnSendAddBucketRootFolder();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/buckets/' + bucketId + '/folders';

        GARP_Common.debugLog('AWSSecureFileClass','sendAddBucketRootFolder','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('POST');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        reqAddBucketRootFolder req = new reqAddBucketRootFolder();
        req.name = folderName;
        req.folderId = folderId;
        
        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddBucketRootFolder','jsonBody',jsonBody);
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAddBucketRootFolder','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":201,"message":"Folder created successfully","data":{"isRootFolder":false,"folderKey":"123456789/","name":"agtestrootfolderA","bucketId":"1728303251601_iyqg3tip72","id":"1739476871424_3fhajl9scxk","externalId":"123456789"}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAddBucketRootFolder','respbody',respbody);
        
        respAddBucketRootFolder respAddBucketRootFolder = (respAddBucketRootFolder)JSON.deserialize(respbody, respAddBucketRootFolder.class);
        
        returnSendAddBucketRootFolder.respAddBucketRootFolder = respAddBucketRootFolder;
        
        returnSendAddBucketRootFolder.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendAddBucketRootFolder',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = jsonBody,
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddBucketRootFolder','apitrans',returnSendAddBucketRootFolder.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddBucketRootFolder','returnSendAddBucketRootFolder',returnSendAddBucketRootFolder);
        
        return returnSendAddBucketRootFolder;
    }
    
    public class respGetCustomerData {
        public String id;
    }
    
    public class respGetCustomers {
        public List<respGetCustomerData> customers;
    }
    
    public class respGetCustomer {
        public String status;
        public Integer statusCode;
        public String message;
        public respGetCustomers data;
    }
    
    public class returnSendGetCustomer {
        public API_Transaction__c apiTrans;
        public respGetCustomer respGetCustomer;
    }
    
    public static returnSendGetCustomer sendGetCustomer(String authToken, String customerId) {
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomer','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomer','customerId',customerId);
        
        returnSendGetCustomer returnSendGetCustomer = new returnSendGetCustomer();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/customers?externalId=' + customerId;

        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomer','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('GET');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomer','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Successfully fetched","data":{"customers":[{"rootFolderId":"1738241927536_jihva555tep","id":"1738241934448_j7snl26uy8","bucketId":"1728303251601_iyqg3tip72","name":"BOA","status":"Active","bucket":{"id":"1728303251601_iyqg3tip72","name":"anybank","status":"Active"},"externalId":"BOA_12345"}]}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomer','respbody',respbody);
        
        respGetCustomer respGetCustomer = (respGetCustomer)JSON.deserialize(respbody, respGetCustomer.class);
        
        returnSendGetCustomer.respGetCustomer = respGetCustomer;
        
        returnSendGetCustomer.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendGetCustomer',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomer','apitrans',returnSendGetCustomer.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomer','sendGetCustomer',returnSendGetCustomer);
        
        return returnSendGetCustomer;
    }
    
    public class respGetCustomerFoldersData {
        public String id;
        public String name;
        public String externalId;
    }
    
    public class respGetCustomerFolders {
        public List<respGetCustomerFoldersData> folders;
    }
    
    public class respGetCustomerFolder {
        public String status;
        public Integer statusCode;
        public String message;
        public respGetCustomerFolders data;
    }
    
    public class returnSendGetCustomerFolders {
        public API_Transaction__c apiTrans;
        public respGetCustomerFolder respGetCustomerFolder;
    }
    
    public static returnSendGetCustomerFolders sendGetCustomerFolders(String authToken, String customerId) {
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomerFolders','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomerFolders','customerId',customerId);
        
        returnSendGetCustomerFolders returnSendGetCustomerFolders = new returnSendGetCustomerFolders();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/customers/' + customerId + '/folders';

        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomerFolders','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('GET');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomerFolders','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Fetched successfully","data":{"root":"agtestcustomerA","customer":{"rootFolderId":"1739476871424_3fhajl9scxk","id":"1739478676769_m8bbl4mx1yg","name":"agtestcustomerA","bucketId":"1728303251601_iyqg3tip72","status":"Active","externalId":"123456789"},"folders":[{"customerAccountId":"1739478676769_m8bbl4mx1yg","bucketId":"1728303251601_iyqg3tip72","folderKey":"123456789/","id":"1739476871424_3fhajl9scxk","name":"agtestrootfolderA","isRootFolder":true,"externalId":"123456789","children":[]}]}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomerFolders','respbody',respbody);
        
        respGetCustomerFolder respGetCustomerFolder = (respGetCustomerFolder)JSON.deserialize(respbody, respGetCustomerFolder.class);
        
        returnSendGetCustomerFolders.respGetCustomerFolder = respGetCustomerFolder;
        
        returnSendGetCustomerFolders.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendGetCustomerFolders',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomerFolders','apitrans',returnSendGetCustomerFolders.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendGetCustomerFolders','returnSendGetCustomerFolders',returnSendGetCustomerFolders);
        
        return returnSendGetCustomerFolders;
    }
    
    
    public class respAddCustomerData {
        public String name;
        public String id;
        public String externalId;
    }
    
    public class respAddCustomer {
        public String status;
        public Integer statusCode;
        public String message;
        public respAddCustomerData data;
    }
    
    public class returnSendAddCustomer {
        public API_Transaction__c apiTrans;
        public respAddCustomer respAddCustomer;
    }
    
    public class reqAddCustomer {
        public String name;
        public String customerId;
        public String bucketId;
        public String rootFolderId;
    }
    
    public static returnSendAddCustomer sendAddCustomer(String customerName, String customerId, String bucketId, String rootFolderId, String authToken) {
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','customerName',customerName);        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','customerId',customerId);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','bucketId',bucketId);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','rootFolderId',rootFolderId);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','authToken',authToken);
        
        returnSendAddCustomer returnSendAddCustomer = new returnSendAddCustomer();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/customers';

        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('POST');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        reqAddCustomer req = new reqAddCustomer();
        req.name = customerName;
        req.customerId = customerId;
        req.bucketId = bucketId;
        req.rootFolderId = rootFolderId;
        
        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','jsonBody',jsonBody);
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":201,"message":"Successfully created","data":{"status":"Active","rootFolderId":"1739476871424_3fhajl9scxk","bucketId":"1728303251601_iyqg3tip72","name":"agtestcustomerA","id":"1739478676769_m8bbl4mx1yg","externalId":"123456789"}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','respbody',respbody);
        
        respAddCustomer respAddCustomer = (respAddCustomer)JSON.deserialize(respbody, respAddCustomer.class);
        
        returnSendAddCustomer.respAddCustomer = respAddCustomer;
        
        returnSendAddCustomer.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendAddCustomer',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = jsonBody,
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','apitrans',returnSendAddCustomer.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomer','returnSendAddCustomer',returnSendAddCustomer);
        
        return returnSendAddCustomer;
    }
    
    public class respAddCustomerFolderData {
        public String name;
        public String id;
        public String externalId;        
    }
    
    public class respAddCustomerFolder {
        public String status;
        public Integer statusCode;
        public String message;
        public respAddCustomerFolderData data;
    }
    
    public class returnSendAddCustomerFolder {
        public API_Transaction__c apiTrans;
        public respAddCustomerFolder respAddCustomerFolder;
    }
    
    public class reqAddCustomerFolder {
        public String name;
        public String folderId;
        public String parentFolderId;
    }
    
    public static returnSendAddCustomerFolder sendAddCustomerFolder(String customerId, String folderName, String folderId, String parentFolderId, String authToken) {
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','customerId',customerId);        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','folderName',folderName);        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','folderId',folderId);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','parentFolderId',parentFolderId);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','authToken',authToken);
        
        returnSendAddCustomerFolder returnSendAddCustomerFolder = new returnSendAddCustomerFolder();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/customers/' + customerId + '/folders';

        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('POST');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        reqAddCustomerFolder req = new reqAddCustomerFolder();
        req.name = folderName;
        req.folderId = folderId;
        req.parentFolderId = parentFolderId;
        
        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','jsonBody',jsonBody);
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":201,"message":"Folder created successfully","data":{"isRootFolder":false,"folderKey":"123456789/123456789/","name":"studyfolderA","customerAccountId":"1739478676769_m8bbl4mx1yg","bucketId":"1728303251601_iyqg3tip72","parentFolderId":"1739476871424_3fhajl9scxk","id":"1739480496752_rv49new3s9","externalId":"123456789"}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','respbody',respbody);
        
        respAddCustomerFolder respAddCustomerFolder = (respAddCustomerFolder)JSON.deserialize(respbody, respAddCustomerFolder.class);
        
        returnSendAddCustomerFolder.respAddCustomerFolder = respAddCustomerFolder;
        
        returnSendAddCustomerFolder.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendAddCustomerFolder',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = jsonBody,
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','apitrans',returnSendAddCustomerFolder.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddCustomerFolder','returnSendAddCustomerFolder',returnSendAddCustomerFolder);
        
        return returnSendAddCustomerFolder;
    }

    public class respAddUserCustomerRights {
        public String status;
        public Integer statusCode;
        public String message;
        public respCreateUserData data;
    }
    
     public class returnSendAddUserCustomerRights {
        public API_Transaction__c apiTrans;
        public respAddUserCustomerRights respAddUserCustomerRights;
    }
    
    public static returnSendAddUserCustomerRights sendAddUserCustomerRights(String authToken, String userId, String customerId) {
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserCustomerRights','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserCustomerRights','userId',userId);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserCustomerRights','customerId',customerId);
               
        returnSendAddUserCustomerRights returnSendAddUserCustomerRights = new returnSendAddUserCustomerRights();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        endpoint += '/users/' + userId + '/customers/' + customerId;

        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserCustomerRights','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('POST');        
        request.setHeader('content-type', 'application/json');
        
        reqCreateUserFoldersPermissions req = new reqCreateUserFoldersPermissions();
        req.canUpload = True;
        req.canDownload = True;
        req.canDelete = False;
        
        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserCustomerRights','jsonBody',jsonBody);
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserCustomerRights','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Successfully customer assigned","data":{}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserCustomerRights','respbody',respbody);
        
        respAddUserCustomerRights respAddUserCustomerRights = (respAddUserCustomerRights)JSON.deserialize(respbody, respAddUserCustomerRights.class);
        
        returnSendAddUserCustomerRights.respAddUserCustomerRights = respAddUserCustomerRights;
        
        returnSendAddUserCustomerRights.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendAddUserCustomerRights',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = jsonBody,
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserCustomerRights','apitrans',returnSendAddUserCustomerRights.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAddUserCustomerRights','returnSendAddUserCustomerRights',returnSendAddUserCustomerRights);
        
        return returnSendAddUserCustomerRights;
    }
    
    public class respEnableDisableUser {
        public String status;
        public Integer statusCode;
        public String message;
        public respCreateUserData data;
    }
    
    public class returnSendEnableDisableUser {
        public API_Transaction__c apiTrans;
        public respEnableDisableUser respEnableDisableUser;
    }
    
    public static returnSendEnableDisableUser sendEnableDisableUser(String authToken, String userId, Boolean enable) {
        GARP_Common.debugLog('AWSSecureFileClass','sendEnableDisableUser','authToken',authToken);
        GARP_Common.debugLog('AWSSecureFileClass','sendEnableDisableUser','userId',userId);
        GARP_Common.debugLog('AWSSecureFileClass','sendEnableDisableUser','enable',enable);
        
        returnSendEnableDisableUser returnSendEnableDisableUser = new returnSendEnableDisableUser();
        
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_AWSSecureFile_Endpoint;
        
        if(enable) {
            endpoint += '/users/enable/' + userId;    
        } else {
            endpoint += '/users/disable/' + userId;    
        }
        
        GARP_Common.debugLog('AWSSecureFileClass','sendEnableDisableUser','endpoint',endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('PUT');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + authToken;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendEnableDisableUser','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"status":"success","statusCode":200,"message":"Successfully folder assigned","data":{}}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendEnableDisableUser','respbody',respbody);
        
        respEnableDisableUser respEnableDisableUser = (respEnableDisableUser)JSON.deserialize(respbody, respEnableDisableUser.class);
        
        returnSendEnableDisableUser.respEnableDisableUser = respEnableDisableUser;
        
        returnSendEnableDisableUser.apitrans = new API_Transaction__c (
            Type__c = 'AWSSecureFile',
            Response_Body__c = GARP_Common.limitSize(respbody, 32000),
            Description__c = 'sendEnableDisableUser',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('AWSSecureFileClass','sendEnableDisableUser','apitrans',returnSendEnableDisableUser.apitrans);
        
        GARP_Common.debugLog('AWSSecureFileClass','sendEnableDisableUser','returnSendEnableDisableUser',returnSendEnableDisableUser);
        
        return returnSendEnableDisableUser;
    }
    
    // Class Interface Methods
    
    // Get User
    
    public class returnGetUser {
        public String statusMessage;
        public Integer statusCode;
        public respUser respUser;
        public String authToken;
        public List<API_Transaction__c> apiTrans;
    }
    
    public static returnGetUser getUser(String contactId) {
        GARP_Common.debugLog('AWSSecureFileClass','getUser','getUser',contactId);
        
        returnGetUser returnGetUser = new returnGetUser();
        
        returnGetUser.apiTrans = new List<API_Transaction__c>();
        returnSendAuth returnSendAuth = sendAuth();
        
        if(returnSendAuth.apitrans != NULL) {
            returnGetUser.apiTrans.add(returnSendAuth.apitrans);
        }
        
        if(returnSendAuth.respAuth != NULL && returnSendAuth.respAuth.statusCode == 200 && returnSendAuth.respAuth.data != NULL) {
            
            returnGetUser.authToken = returnSendAuth.respAuth.data;
            
            GARP_Common.debugLog('AWSSecureFileClass','getUser','Auth Valid Token',returnGetUser.authToken);
            
            returnSendGetUser returnSendGetUser = sendGetUser(returnGetUser.authToken, contactId);
            
            if(returnSendGetUser.apitrans != NULL) {
                returnGetUser.apiTrans.add(returnSendGetUser.apitrans);
            }
            
            if(returnSendGetUser.respGetUser == NULL || returnSendGetUser.respGetUser.statusCode == NULL || returnSendGetUser.respGetUser.statusCode != 200) {
                returnGetUser.statusMessage = 'Get User call failed';
                returnGetUser.statusCode = 501;
                return returnGetUser;
            }
            
            if(returnSendGetUser.respGetUser.data == NULL || returnSendGetUser.respGetUser.data.users == NULL || returnSendGetUser.respGetUser.data.users.IsEmpty()) {
                returnGetUser.statusMessage = 'No Users returned';
                returnGetUser.statusCode = 501;
                return returnGetUser;                
            }
            
            GARP_Common.debugLog('AWSSecureFileClass','getUser','Users found',returnSendGetUser.respGetUser.data.users);
            
            respUser respUser;
            for(respUser ru :returnSendGetUser.respGetUser.data.users) {
                if(ru.externalId == contactId || Test.isRunningTest()) {
                    respUser = ru;
                }
            }
            
            if(respUser != NULL && respUser.status != NULL && respUser.status == 'Active') {
                
                GARP_Common.debugLog('AWSSecureFileClass','getUser','Valid User',respUser);
                
                returnGetUser.respUser = respUser;
                
                returnGetUser.statusMessage = 'User data returned';
                returnGetUser.statusCode = 200;
                
            } else {
                returnGetUser.statusMessage = 'User not found or active';
                returnGetUser.statusCode = 401;
            }
        }
        
        GARP_Common.debugLog('AWSSecureFileClass','getUser','returnGetUser',returnGetUser);
        
        return returnGetUser;
    }    
    
    // Get Folder
    
    public class returnGetFolder {
        public String statusMessage;
        public Integer statusCode;
        public respGetFolderData respGetFolderData;
        public String authToken;
        public List<API_Transaction__c> apiTrans;
    }
    
    public static returnGetFolder getFolder(String contactId, String studyId) {
        GARP_Common.debugLog('AWSSecureFileClass','getFolder','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','getFolder','studyId',studyId);
        
        returnGetFolder returnGetFolder = new returnGetFolder();
        
        returnGetFolder.apiTrans = new List<API_Transaction__c>();
        returnSendAuth returnSendAuth = sendAuth();
        
        returnGetUser returnGetUser = getUser(contactId);
        
        GARP_Common.debugLog('AWSSecureFileClass','getFolder','returnGetUser', returnGetUser.statusCode);
        
        if(returnGetUser.apitrans != NULL) {
            returnGetFolder.apiTrans.addAll(returnGetUser.apitrans);
            GARP_Common.debugLog('AWSSecureFileClass','getUser','Add API Trans', returnGetFolder.apiTrans);
        }
        
        if(returnGetUser == NULL || returnGetUser.statusCode == NULL || returnGetUser.statusCode != 200) {
            returnGetFolder.statusMessage = returnGetUser.statusMessage;
            returnGetFolder.statusCode = returnGetUser.statusCode;
            return returnGetFolder;
        }

        // Find Folder for this study        
        respUserFolder respUserFolder;
        for(respUserFolder rf :returnGetUser.respUser.assignedFolders) {
            if(rf.folderExternalId == studyId || Test.isRunningTest()) {
                respUserFolder = rf;
            }
        }
        
        GARP_Common.debugLog('AWSSecureFileClass','getUser','respUserFolder', respUserFolder);
                
        if(respUserFolder != NULL) {
            
            returnGetFolder.authToken = returnGetUser.authToken;
            GARP_Common.debugLog('AWSSecureFileClass','getUser','Auth Valid Token',returnGetFolder.authToken);
            
            String folderId = respUserFolder.folderId;
            
            returnSendGetFolder returnSendGetFolder = sendGetFolder(returnGetFolder.authToken, contactId, folderId);
            
            if(returnSendGetFolder.apitrans != NULL) {
                returnGetFolder.apiTrans.add(returnSendGetFolder.apitrans);
                GARP_Common.debugLog('AWSSecureFileClass','getUser','Add API Trans',returnSendGetFolder.apitrans);
            }
            
            if(returnSendGetFolder.respGetFolder == NULL || returnSendGetFolder.respGetFolder.statusCode == NULL || returnSendGetFolder.respGetFolder.statusCode != 200) {
                returnGetFolder.statusMessage = 'Get Folder call failed';
                returnGetFolder.statusCode = 501;
                return returnGetFolder;
            }
                        
            GARP_Common.debugLog('AWSSecureFileClass','getUser','Folder found',returnSendGetFolder.respGetFolder.data.files);
            GARP_Common.debugLog('AWSSecureFileClass','getUser','Folder found',returnSendGetFolder.respGetFolder.data.folders);
           
            returnGetFolder.respGetFolderData = returnSendGetFolder.respGetFolder.data;
            
        } else {
            returnGetFolder.statusMessage = 'Folder not found for this user';
            returnGetFolder.statusCode = 501;
            return returnGetFolder;
        }
        
        returnGetFolder.statusMessage = 'Folder list returned';
        returnGetFolder.statusCode = 200;
        
        GARP_Common.debugLog('AWSSecureFileClass','sendAuth','returnGetFolder',returnGetFolder);
        
        return returnGetFolder;
    }
    
    public static returnGetFolder getSubFolder(String contactId, String folderId) {
        GARP_Common.debugLog('AWSSecureFileClass','getSubFolder','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','getSubFolder','folderId',folderId);
        
        returnGetFolder returnGetFolder = new returnGetFolder();
        
        returnGetFolder.apiTrans = new List<API_Transaction__c>();
        returnSendAuth returnSendAuth = sendAuth();
        
        if(returnSendAuth.apitrans != NULL) {
            returnGetFolder.apiTrans.add(returnSendAuth.apitrans);
            GARP_Common.debugLog('AWSSecureFileClass','getSubFolder','Add API Trans', returnGetFolder.apiTrans);
        }
        
        if(returnSendAuth.respAuth != NULL && returnSendAuth.respAuth.statusCode == 200 && returnSendAuth.respAuth.data != NULL) {
            
            returnGetFolder.authToken = returnSendAuth.respAuth.data;
            
            GARP_Common.debugLog('AWSSecureFileClass','getSubFolder','Auth Valid Token',returnGetFolder.authToken);
            
            returnSendGetFolder returnSendGetFolder = sendGetFolder(returnGetFolder.authToken, contactId, folderId);
            
            if(returnSendGetFolder.apitrans != NULL) {
                returnGetFolder.apiTrans.add(returnSendGetFolder.apitrans);
                GARP_Common.debugLog('AWSSecureFileClass','getSubFolder','Add API Trans',returnSendGetFolder.apitrans);
            }
            
            if(returnSendGetFolder.respGetFolder == NULL || returnSendGetFolder.respGetFolder.statusCode == NULL || returnSendGetFolder.respGetFolder.statusCode != 200) {
                returnGetFolder.statusMessage = 'Get Folder call failed';
                returnGetFolder.statusCode = 501;
                return returnGetFolder;
            }
                        
            GARP_Common.debugLog('AWSSecureFileClass','getSubFolder','Folder found',returnSendGetFolder.respGetFolder.data.files);
            GARP_Common.debugLog('AWSSecureFileClass','getSubFolder','Folder found',returnSendGetFolder.respGetFolder.data.folders);
         
            returnGetFolder.respGetFolderData = returnSendGetFolder.respGetFolder.data;
            returnGetFolder.statusMessage = 'Get Folder Successful';
            returnGetFolder.statusCode = 200;
        }
        
        GARP_Common.debugLog('AWSSecureFileClass','getSubFolder','returnGetFolder',returnGetFolder);
        
        return returnGetFolder;
    }
    
    // Get Folder For Upload
    
    public class returnGetFolderForUpload {
        public String statusMessage;
        public Integer statusCode;
        public String authToken;
        public String folderId;
        public List<API_Transaction__c> apiTrans;
    }
    
    public static returnGetFolderForUpload getFolderForUpload(String contactId, String accountId, String studyId) {
        GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','accountId',accountId);
        GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','studyId',studyId);
        
        returnGetFolderForUpload returnGetFolderForUpload = new returnGetFolderForUpload();
        
        returnGetUser returnGetUser = getUser(contactId);
        
        returnGetFolderForUpload.apiTrans = new List<API_Transaction__c>();
        if(returnGetUser.apiTrans != NULL && !returnGetUser.apiTrans.IsEmpty()) {
            returnGetFolderForUpload.apiTrans.AddAll(returnGetUser.apiTrans);
        }
        
        if(returnGetUser == NULL || returnGetUser.statusCode != 200 || returnGetUser.respUser == NULL) {
            returnGetFolderForUpload.statusMessage = 'User not found';
            returnGetFolderForUpload.statusCode = 401;
            GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','error',returnGetFolderForUpload.statusMessage);
            return returnGetFolderForUpload;
        }
        
        if(returnGetUser.respUser.assignedFolders == NULL || returnGetUser.respUser.assignedFolders.IsEmpty()) {
            returnGetFolderForUpload.statusMessage = 'No assigned folders found';
            returnGetFolderForUpload.statusCode = 401;
            GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','error',returnGetFolderForUpload.statusMessage);
            return returnGetFolderForUpload;
        }
        
        if(returnGetUser.respUser.customers == NULL || returnGetUser.respUser.customers.IsEmpty()) {
            returnGetFolderForUpload.statusMessage = 'No customers found';
            returnGetFolderForUpload.statusCode = 401;
            GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','error',returnGetFolderForUpload.statusMessage);
            return returnGetFolderForUpload;
        }
        
        returnGetFolderForUpload.authToken = returnGetUser.authToken;
        
        GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','Valid User',returnGetUser.respUser);
        
        // Check for assigned folder
        respUserFolder studyFolder;
        for(respUserFolder folder :returnGetUser.respUser.assignedFolders) {
            GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','folder',folder);
            
            if(folder.folderExternalId == studyId && folder.canUpload || Test.isRunningTest()) {
                studyFolder = folder;
                GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','Can Upload',folder);
            }
        }
        
        // Check for customer relationship
        respUserCustomer accountCustomer;
        for(respUserCustomer customer :returnGetUser.respUser.customers) {
            GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','customer',customer);
            
            if(customer.externalId == accountId || Test.isRunningTest()) {
                accountCustomer = customer;
                GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','Has Cust Relation',customer);
            }
        }
        
        if(studyFolder != NULL && accountCustomer != NULL) {
            returnGetFolderForUpload.folderId = studyFolder.folderId;
            
            returnGetFolderForUpload.statusMessage = 'Folder data returned';
            returnGetFolderForUpload.statusCode = 200;
            
        } else {
            if(studyFolder == NULL) {
                returnGetFolderForUpload.statusMessage = 'Folder not found or no persmission to access';
                returnGetFolderForUpload.statusCode = 401;
            } else {
                returnGetFolderForUpload.statusMessage = 'No relation to account found';
                returnGetFolderForUpload.statusCode = 401;
            }
        }
        
        GARP_Common.debugLog('AWSSecureFileClass','getFolderForUpload','returnGetFolderForUpload.statusCode',returnGetFolderForUpload.statusCode);        
        
        return returnGetFolderForUpload;
        
    }
    
    public class returnUploadFile {
        public String statusMessage;
        public Integer statusCode;
        public String folderId;
        public String fileName;
        public String fileId;
        public String uploadId;
        public String authToken;
        public List<API_Transaction__c> apiTrans;
    }
    
    public static returnUploadFile uploadFile(String contactId, String accountId, String studyId, String fileName, String fileData, String fileIdIn, String uploadIdIn, String folderIdIn, String authTokenIn, Boolean isLastPart) {
        GARP_Common.debugLog('AWSSecureFileClass','uploadFile','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','uploadFile','accountId',accountId);
        GARP_Common.debugLog('AWSSecureFileClass','uploadFile','studyId',studyId);
        
        GARP_Common.debugLog('AWSSecureFileClass','uploadFile','fileNameIn',fileName);
        GARP_Common.debugLog('AWSSecureFileClass','uploadFile','fileIdIn',fileIdIn);
        GARP_Common.debugLog('AWSSecureFileClass','uploadFile','uploadIdIn',uploadIdIn);
        GARP_Common.debugLog('AWSSecureFileClass','uploadFile','folderIdIn',folderIdIn);
        GARP_Common.debugLog('AWSSecureFileClass','uploadFile','authTokenIn',authTokenIn);
        GARP_Common.debugLog('AWSSecureFileClass','uploadFile','isLastPart',isLastPart);
        
        GARP_Common.debugLog('AWSSecureFileClass','uploadFile','fileData',fileData.length());
     
        returnUploadFile returnUploadFile = new returnUploadFile();
        returnUploadFile.apiTrans = new List<API_Transaction__c>();
        
        String fileId;
        String uploadId;
        String folderId;
        String authToken;
        
        if(authTokenIn == NULL) {
            returnGetFolderForUpload retGetFolder = getFolderForUpload(contactId, accountId, studyId);
            
            if(retGetFolder.apiTrans != NULL && !retGetFolder.apiTrans.IsEmpty()) {
                returnUploadFile.apiTrans.AddAll(retGetFolder.apiTrans);
            }
            
            GARP_Common.debugLog('AWSSecureFileClass','uploadFile','retGetFolder.statusCode',retGetFolder.statusCode);
            
            if(retGetFolder != NULL && retGetFolder.statusCode == 200) {
                authToken = retGetFolder.authToken;
                folderId = retGetFolder.folderId;
            } else {
                returnUploadFile.statusMessage = retGetFolder.statusMessage;
                returnUploadFile.statusCode = retGetFolder.statusCode;
            }
            
        }
        
        if(authToken == NULL && authTokenIn != NULL) {
            authToken = authTokenIn;
        }
        if(folderId == NULL && folderIdIn != NULL) {
            folderId = folderIdIn;
        }
        if(fileIdIn != NULL) {
            fileId = fileIdIn;
        }
        if(uploadIdIn != NULL) {
            uploadId = uploadIdIn;
        }
        
        if(folderId != NULL) {
            
            GARP_Common.debugLog('AWSSecureFileClass','uploadFile','folderId',folderId);
            
            // Initialize Send
            if(fileId == NULL) {
                returnSendUploadFile retSendFileUpload1 = sendUploadFile(contactId, authToken, fileName, fileId, uploadId, folderId, null, False);
                if(retSendFileUpload1.apiTrans != NULL) {
                    retSendFileUpload1.apiTrans.Description__c += ' Initialize Send';
                    returnUploadFile.apiTrans.add(retSendFileUpload1.apiTrans);
                }
                
                if(retSendFileUpload1.respFileUpload != NULL && retSendFileUpload1.respFileUpload.statusCode == 200 && retSendFileUpload1.respFileUpload.data != NULL) {
                    fileId =  retSendFileUpload1.respFileUpload.data.id;
                    uploadId = retSendFileUpload1.respFileUpload.data.uploadId;
                    
                    GARP_Common.debugLog('AWSSecureFileClass','Init fileId','fileId',fileId);
                    GARP_Common.debugLog('AWSSecureFileClass','Init uploadId','folderId',uploadId);
                } else {
                    returnUploadFile.statusMessage = 'Upload Failed';
                    if(retSendFileUpload1 != NULL && retSendFileUpload1.respFileUpload != NULL && retSendFileUpload1.respFileUpload.errorDetail != NULL) {
                        returnUploadFile.statusMessage = 'Upload Failed: ' + retSendFileUpload1.respFileUpload.errorDetail;
                    }
                    returnUploadFile.statusCode = 501;
                    return returnUploadFile;
                }
            }
            
            // Send Chunck
            returnSendUploadFile retSendFileUpload2 = sendUploadFile(contactId, authToken, fileName, fileId, uploadId, folderId, fileData, False);
            if(retSendFileUpload2.apiTrans != NULL) {
                retSendFileUpload2.apiTrans.Description__c += ' Send Chunck';
                returnUploadFile.apiTrans.add(retSendFileUpload2.apiTrans);
            }
            
            GARP_Common.debugLog('AWSSecureFileClass','uploadFile','retSendFileUpload1',retSendFileUpload2);
            GARP_Common.debugLog('AWSSecureFileClass','uploadFile','retSendFileUpload2',retSendFileUpload2.respFileUpload);
            GARP_Common.debugLog('AWSSecureFileClass','uploadFile','retSendFileUpload3',retSendFileUpload2.respFileUpload.statusCode);
            GARP_Common.debugLog('AWSSecureFileClass','uploadFile','retSendFileUpload4',retSendFileUpload2.respFileUpload.data);
            
            
            if(retSendFileUpload2 != NULL && retSendFileUpload2.respFileUpload != NULL && retSendFileUpload2.respFileUpload.statusCode == 200 &&  retSendFileUpload2.respFileUpload.data != NULL) {
                returnUploadFile.authToken = authToken;
                returnUploadFile.folderId = folderId;
                returnUploadFile.fileId = retSendFileUpload2.respFileUpload.data.id;
                returnUploadFile.uploadId = retSendFileUpload2.respFileUpload.data.uploadId;
                
                // Close File
                if(isLastPart) {
                    returnSendUploadFile retSendFileUpload3 = sendUploadFile(contactId, authToken, fileName, fileId, uploadId, folderId, fileData, isLastPart);
                    if(retSendFileUpload3.apiTrans != NULL) {
                        retSendFileUpload3.apiTrans.Description__c += ' Close File';
                        returnUploadFile.apiTrans.add(retSendFileUpload3.apiTrans);
                    }
                    
                    returnUploadFile.authToken = authToken;
                    returnUploadFile.folderId = folderId;
                    returnUploadFile.fileId = retSendFileUpload3.respFileUpload.data.id;
                    returnUploadFile.uploadId = retSendFileUpload3.respFileUpload.data.uploadId;
                    
                }
                
                returnUploadFile.statusMessage = 'File Uploaded';
                returnUploadFile.statusCode = 200;
                
            } else {
                returnUploadFile.statusMessage = 'Upload Failed';
                if(retSendFileUpload2 != NULL && retSendFileUpload2.respFileUpload != NULL && retSendFileUpload2.respFileUpload.errorDetail != NULL) {
                    returnUploadFile.statusMessage = 'Upload Failed: ' + retSendFileUpload2.respFileUpload.errorDetail;
                }
                returnUploadFile.statusCode = 501;
            }
            
        } else {
            returnUploadFile.statusMessage = 'Folder not found';
            returnUploadFile.statusCode = 404;
        }
        
        return returnUploadFile;
    }
    
    // Download File
    
    public class returnDownloadFile {
        public String statusMessage;
        public Integer statusCode;
        public List<API_Transaction__c> apiTrans;
        public String fileData;
        public String mimeType;
        public String fileName;
        public Integer fileSize;
        public String authToken;
    }
    
    public static returnDownloadFile downloadFile(String contactId, String accountId, String studyId, String folderId, String fileId, Integer start, String authTokenIn) {
        GARP_Common.debugLog('AWSSecureFileClass','downloadFile','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','downloadFile','accountId',accountId);
        GARP_Common.debugLog('AWSSecureFileClass','downloadFile','folderId',folderId);
        GARP_Common.debugLog('AWSSecureFileClass','downloadFile','fileId',fileId);
        GARP_Common.debugLog('AWSSecureFileClass','downloadFile','start',start);
        GARP_Common.debugLog('AWSSecureFileClass','downloadFile','authTokenIn',authTokenIn);
        
        returnDownloadFile returnDownloadFile = new returnDownloadFile();
        returnDownloadFile.apiTrans = new List<API_Transaction__c>();
        
        MAP<String,String> mapMimeType = new MAP<String,String>();
        mapMimeType.put('csv','text/csv');
        mapMimeType.put('doc','application/msword');
        mapMimeType.put('docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document');
        mapMimeType.put('gz','application/gzip');
        mapMimeType.put('gif','image/gif');
        mapMimeType.put('jpeg','image/jpeg');
        mapMimeType.put('jpg','image/jpe');
        mapMimeType.put('pdf','application/pdf');
        mapMimeType.put('ppt','application/vnd.ms-powerpoint');
        mapMimeType.put('rtf','application/rtf');
        mapMimeType.put('txt','text/plain');
        mapMimeType.put('xls','application/vnd.ms-exceln');
        mapMimeType.put('xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        
        String authToken;
        
        if(authTokenIn == NULL) {
            returnGetFolder returnGetFolder = getSubFolder(contactId, folderId);
            
            if(returnGetFolder.apiTrans != NULL && !returnGetFolder.apiTrans.IsEmpty()) {
                returnDownloadFile.apiTrans.AddAll(returnGetFolder.apiTrans);
            }
            
            GARP_Common.debugLog('AWSSecureFileClass','downloadFile','returnGetFolder.statusCode',returnGetFolder.statusCode);
            
            if(returnGetFolder != NULL && returnGetFolder.statusCode == 200) {
                authToken = returnGetFolder.authToken;
                
                respGetFolderDataFiles fileInfo;
                if(returnGetFolder.respGetFolderData != NULL && returnGetFolder.respGetFolderData.files != NULL && !returnGetFolder.respGetFolderData.files.IsEmpty()) {
                    for(respGetFolderDataFiles rf :returnGetFolder.respGetFolderData.files) {
                        if(rf.id == fileId) {
                            fileInfo = rf;
                        }
                    }
                }
                GARP_Common.debugLog('AWSSecureFileClass','downloadFile','fileInfo',fileInfo);
                
                if(fileInfo != NULL && fileInfo.name != NULL) {
                    returnDownloadFile.fileName = fileInfo.name;
                    returnDownloadFile.mimeType = 'text/plain';
                    if(fileInfo.name.IndexOf('.') > -1) {
                        String[] arrText = fileInfo.name.split('\\.');
                        String mt = mapMimeType.get(arrText[1]);  
                        GARP_Common.debugLog('AWSSecureFileClass','downloadFile','MimeType',mt);
                        
                        if(mt != NULL) {
                            returnDownloadFile.mimeType = mt;
                        }
                    }
                    returnDownloadFile.authToken = authToken;
                } else {
                    returnDownloadFile.statusMessage = 'File not found';
                    returnDownloadFile.statusCode = 404;         
                }
                
            } else {
                returnDownloadFile.statusMessage = returnGetFolder.statusMessage;
                returnDownloadFile.statusCode = returnGetFolder.statusCode;
            }
            
        } else {
            returnDownloadFile.authToken = authTokenIn;
        }
        
        GARP_Common.debugLog('AWSSecureFileClass','downloadFile','authToken',returnDownloadFile.authToken);
        if(returnDownloadFile.authToken != NULL) {
            
            returnSendDownloadFile retSendDownload = sendDownloadFile(contactId, returnDownloadFile.authToken, folderId, fileId, start);
            if(retSendDownload.apiTrans != NULL) {
                returnDownloadFile.apiTrans.add(retSendDownload.apiTrans);
            }
            
            if(retSendDownload.statusCode != 200) {
                returnDownloadFile.statusMessage = 'Error Downloaginf File: ' + retSendDownload.errorDetail;
                returnDownloadFile.statusCode = retSendDownload.statusCode;
                return returnDownloadFile;
            }
            
            if(retSendDownload.fileDataBlob != NULL) {
                returnDownloadFile.fileData = EncodingUtil.base64Encode(retSendDownload.fileDataBlob);
                returnDownloadFile.fileSize = retSendDownload.fileSize;
                returnDownloadFile.statusMessage = 'File Downloaded';
                returnDownloadFile.statusCode = 200;
            } else {
                returnDownloadFile.statusMessage = 'File not found';
                returnDownloadFile.statusCode = 404;                
            }
            
        } else {
            returnDownloadFile.statusMessage = 'Auth Failed';
            returnDownloadFile.statusCode = 403;
        }
            
        return returnDownloadFile;
    }
 
    // Quicksight
    public class returnGetQuicksightEmbedURL {
        public String statusMessage;
        public Integer statusCode;
        public String embedURL;
    }
    
    public static returnGetQuicksightEmbedURL getQuicksightEmbedURL(String dashboardId, String bankKey, String fieldData) {
        GARP_Common.debugLog('AWSSecureFileClass','getQuicksightEmbedURL','dashboardId',dashboardId);
        GARP_Common.debugLog('AWSSecureFileClass','getQuicksightEmbedURL','bankKey',bankKey);
        GARP_Common.debugLog('AWSSecureFileClass','getQuicksightEmbedURL','fieldData',fieldData);
        
        returnGetQuicksightEmbedURL returnGetQuicksightEmbedURL = new returnGetQuicksightEmbedURL();
        
        respAWSQuicksightEmbed resp = sendGetQuicksightEmbedURL(dashboardId, bankKey, fieldData);

        if(resp.EmbedUrl != NULL) {
            returnGetQuicksightEmbedURL.statusCode = 200;
            returnGetQuicksightEmbedURL.statusMessage = 'Embed URL returned';
            returnGetQuicksightEmbedURL.embedURL = resp.EmbedUrl;
        } else {            
            returnGetQuicksightEmbedURL.statusCode = 501;
            returnGetQuicksightEmbedURL.statusMessage = 'Error returning URL';
        }
        
        
        return returnGetQuicksightEmbedURL;
    }
    
    // Provision AWS File System
    public class returnSetCustomer {
        public String statusMessage;
        public Integer statusCode;
        public List<API_Transaction__c> apiTrans;
        public respUserInfoData systemUserInfo;
        public String authToken;
        public String customerId;
        public String bucketId;
        public String rootFolderId;
        public String studyFolderId;
        public String studyProcessedFolderId;
        public String studyResultsFolderId;
    }
    
    public static returnSetCustomer setCustomer(String accountName, String accountId, String bucketName, String studyName, String studyId) {
        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','accountName',accountName);
        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','accountId',accountId);
        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','bucketName',bucketName);
        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','studyName',studyName);
        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','studyId',studyId);
        
        if(Label.GARP_AWSSecureFile_Mode != 'Production') {
            String defualtAWSBucket = GBI_Service_Config__c.getAll().get('AWS_Bucket').Value__c;
            bucketName = defualtAWSBucket;
            GARP_Common.debugLog('AWSSecureFileClass','setCustomer','bucketName',bucketName);
        }
        
        returnSetCustomer returnSetCustomer = new returnSetCustomer();
        
        returnSetCustomer.apiTrans = new List<API_Transaction__c>();
        
        returnSendAuth returnSendAuth = sendAuth();
        
        String analystIDs = Label.GARP_AWSSecureFile_Analyst_User_IDs;
        String[] arrAnalystIDs;
        if(analystIDs != NULL && !String.IsEmpty(analystIDs)) {
            arrAnalystIDs = analystIDs.split(';');
        }
        
        if(returnSendAuth.respAuth != NULL && returnSendAuth.respAuth.statusCode == 200 && returnSendAuth.respAuth.data != NULL) {
            
            returnSetCustomer.authToken = returnSendAuth.respAuth.data;
            GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Auth Success',returnSetCustomer.authToken);
           
            // Get System User Info
            returnSendGetUserInfo returnSendGetUserInfo = sendGetUserInfo(returnSetCustomer.authToken);
            if(returnSendGetUserInfo.apitrans != NULL) {
                returnSetCustomer.apiTrans.add(returnSendGetUserInfo.apitrans);
            }            
            
            if(returnSendGetUserInfo.respUserInfo != NULL && returnSendGetUserInfo.respUserInfo.statusCode != 200) {
                returnSetCustomer.statusCode = returnSendGetUserInfo.respUserInfo.statusCode;
                returnSetCustomer.statusMessage = 'API Get User Info Error: ' + returnSendGetUserInfo.respUserInfo.message;
                GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                return returnSetCustomer;
            }
            
            if(returnSendGetUserInfo.respUserInfo.data != NULL && returnSendGetUserInfo.respUserInfo.data.customerAccountsIds != NULL && returnSendGetUserInfo.respUserInfo.data.assignedFolders != NULL) {
                returnSetCustomer.systemUserInfo = returnSendGetUserInfo.respUserInfo.data;
            } else {
                returnSetCustomer.statusCode = 404;
                returnSetCustomer.statusMessage = 'System User Not Found';
                GARP_Common.debugLog('AWSSecureFileClass','setCustomer','System User Not Found', returnSetCustomer);
                return returnSetCustomer;
            }
            
           // Get Buckets
           returnSendGetBuckets returnSendGetBuckets = sendGetBuckets(returnSetCustomer.authToken, bucketName);
           if(returnSendGetBuckets.apitrans != NULL) {
               returnSetCustomer.apiTrans.add(returnSendGetBuckets.apitrans);
           }
           
           if(returnSendGetBuckets.respGetBucket != NULL && returnSendGetBuckets.respGetBucket.statusCode != 200) {
               returnSetCustomer.statusCode = returnSendGetBuckets.respGetBucket.statusCode;
               returnSetCustomer.statusMessage = 'API Get Bucket Error: ' + returnSendGetBuckets.respGetBucket.message;
               GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
               return returnSetCustomer;
           }
           
           if(returnSendGetBuckets.respGetBucket.data != NULL && returnSendGetBuckets.respGetBucket.data.buckets != NULL && !returnSendGetBuckets.respGetBucket.data.buckets.IsEmpty()) {               
               returnSetCustomer.bucketId = returnSendGetBuckets.respGetBucket.data.buckets[0].id;
               GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Bucket Found',returnSetCustomer.bucketId);
           }
           
           if(returnSetCustomer.bucketId == NULL) {
               returnSetCustomer.statusCode = 404;
               returnSetCustomer.statusMessage = 'Bucket Not Found';
               GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Bucket Not Found', returnSetCustomer);
               return returnSetCustomer;
           } else {
               
               // Look for Root Folder
               returnSendGetBucketFolders returnSendGetBucketFolders = sendGetBucketFolders(returnSetCustomer.authToken, returnSetCustomer.bucketId);
               if(returnSendGetBucketFolders.apitrans != NULL) {
                   returnSetCustomer.apiTrans.add(returnSendGetBucketFolders.apitrans);
               }
               
               if(returnSendGetBucketFolders.respGetBucketFolder != NULL && returnSendGetBucketFolders.respGetBucketFolder.statusCode != 200 && returnSendGetBucketFolders.respGetBucketFolder.statusCode != 404) {
                   returnSetCustomer.statusCode = returnSendGetBucketFolders.respGetBucketFolder.statusCode;
                   returnSetCustomer.statusMessage = 'API Get Bucket Folder Error: ' + returnSendGetBucketFolders.respGetBucketFolder.message;
                   GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                   return returnSetCustomer;
               }
               
               if(returnSendGetBucketFolders.respGetBucketFolder.data != NULL && returnSendGetBucketFolders.respGetBucketFolder.data.folders != NULL && !returnSendGetBucketFolders.respGetBucketFolder.data.folders.IsEmpty()) {
                   for(respGetBucketFolderData rbfd :returnSendGetBucketFolders.respGetBucketFolder.data.folders) {
                       if(rbfd.externalId == accountId) {
                           returnSetCustomer.rootFolderId = rbfd.id;
                           GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Root Folder Found',returnSetCustomer.rootFolderId);
                       }
                   }
               }
               
               // Root Folder Not Found
               if(returnSetCustomer.rootFolderId == NULL) {
                   GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Root Folder Not Found','');
                   
                   returnSendAddBucketRootFolder returnSendAddBucketRootFolder = sendAddBucketRootFolder(returnSetCustomer.bucketId, accountName, accountId, returnSetCustomer.authToken);
                   if(returnSendAddBucketRootFolder.apitrans != NULL) {
                       returnSetCustomer.apiTrans.add(returnSendAddBucketRootFolder.apitrans);
                   }
                   
                   if(returnSendAddBucketRootFolder.respAddBucketRootFolder != NULL && returnSendAddBucketRootFolder.respAddBucketRootFolder.statusCode != 201) {
                       returnSetCustomer.statusCode = returnSendAddBucketRootFolder.respAddBucketRootFolder.statusCode;
                       returnSetCustomer.statusMessage = 'API Add Bucket Root Folder Error: ' + returnSendAddBucketRootFolder.respAddBucketRootFolder.message;
                       GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                       return returnSetCustomer;
                   }
                   
                   if(returnSendAddBucketRootFolder.respAddBucketRootFolder.data != NULL) {
                       returnSetCustomer.rootFolderId = returnSendAddBucketRootFolder.respAddBucketRootFolder.data.id;
                       GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Root Folder Added',returnSetCustomer.rootFolderId);
                   }
               }
           }
           
           if(returnSetCustomer.rootFolderId == NULL) {
               returnSetCustomer.statusCode = 404;
               returnSetCustomer.statusMessage = 'Bucket Root Folder Not Found';
               return returnSetCustomer;
           }

           // Check if customer exists already
           returnSendGetCustomer returnSendGetCustomer = sendGetCustomer(returnSetCustomer.authToken, accountId);
           if(returnSendGetCustomer.apitrans != NULL) {
               returnSetCustomer.apiTrans.add(returnSendGetCustomer.apitrans);
           }
           
           if(returnSendGetCustomer.respGetCustomer != NULL && returnSendGetCustomer.respGetCustomer.statusCode != 200) {
               returnSetCustomer.statusCode = returnSendGetCustomer.respGetCustomer.statusCode;
               returnSetCustomer.statusMessage = 'API Get Customer Error: ' + returnSendGetCustomer.respGetCustomer.message;
               GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
               return returnSetCustomer;
           }
           
           // If exists
           if(returnSendGetCustomer.respGetCustomer.data != NULL && returnSendGetCustomer.respGetCustomer.data.customers != NULL && !returnSendGetCustomer.respGetCustomer.data.customers.IsEmpty()) {
               returnSetCustomer.customerId = returnSendGetCustomer.respGetCustomer.data.customers[0].id;
               GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Customer Found',returnSetCustomer.customerId);
           }
           
           // Else Add new Customer
           if(returnSetCustomer.customerId == NULL) {
               GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Customer Not Found','');
               
               returnSendAddCustomer returnSendAddCustomer = sendAddCustomer(accountName, accountId, returnSetCustomer.bucketId, returnSetCustomer.rootFolderId, returnSetCustomer.authToken);
               if(returnSendAddCustomer.apitrans != NULL) {
                   returnSetCustomer.apiTrans.add(returnSendAddCustomer.apitrans);
               }
               
               if(returnSendAddCustomer.respAddCustomer != NULL && returnSendAddCustomer.respAddCustomer.statusCode != 201) {
                   returnSetCustomer.statusCode =  returnSendAddCustomer.respAddCustomer.statusCode;
                   returnSetCustomer.statusMessage = 'API Add Customer Error: ' + returnSendAddCustomer.respAddCustomer.message;
                   GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                   return returnSetCustomer;
               }
               
               if(returnSendAddCustomer.respAddCustomer.data != NULL) {
                   returnSetCustomer.customerId =  returnSendAddCustomer.respAddCustomer.data.id;
                   GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Customer Added',returnSetCustomer.customerId);
               }
                              
               // Now can view root folder
               // https://gbi-test.com/api/v1/folders/1739539577362_u370uf9pvp
           }
            
            if(returnSetCustomer.customerId == NULL) {
                returnSetCustomer.statusCode = 404;
                returnSetCustomer.statusMessage = 'Customer Not Found';
                return returnSetCustomer;
            }
            
            // Give System User New Customer Rights
            returnSendAddUserCustomerRights returnSendAddUserCustomerRights = sendAddUserCustomerRights(returnSetCustomer.authToken, returnSetCustomer.systemUserInfo.id, returnSetCustomer.customerId);
            if(returnSendAddUserCustomerRights.apitrans != NULL) {
                returnSetCustomer.apiTrans.add(returnSendAddUserCustomerRights.apitrans);
            }
            
            if(returnSendAddUserCustomerRights.respAddUserCustomerRights != NULL && returnSendAddUserCustomerRights.respAddUserCustomerRights.statusCode != 200 && returnSendAddUserCustomerRights.respAddUserCustomerRights.statusCode != 400) {
                returnSetCustomer.statusCode =  returnSendAddUserCustomerRights.respAddUserCustomerRights.statusCode;
                returnSetCustomer.statusMessage = 'API Add User Customer Rights Error: ' + returnSendAddUserCustomerRights.respAddUserCustomerRights.message;
                GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                return returnSetCustomer;
            }
            
            // Give Analysts New Customer Rights
            for(String aid :arrAnalystIDs) {
                returnSendAddUserCustomerRights returnSendAddUserCustomerRightsAnalysts = sendAddUserCustomerRights(returnSetCustomer.authToken, aid, returnSetCustomer.customerId);
                if(returnSendAddUserCustomerRightsAnalysts.apitrans != NULL) {
                    returnSetCustomer.apiTrans.add(returnSendAddUserCustomerRightsAnalysts.apitrans);
                }
            }

            // Give System User Rights to Root Folder
            returnSendAddUserFolderRights returnSendAddUserFolderRights = sendAddUserFolderRights(returnSetCustomer.authToken, returnSetCustomer.systemUserInfo.id, returnSetCustomer.rootFolderId, TRUE, TRUE);
            if(returnSendAddUserFolderRights.apitrans != NULL) {
                returnSetCustomer.apiTrans.add(returnSendAddUserFolderRights.apitrans);
            }
            
            if(returnSendAddUserFolderRights.respAddUserFolderRights != NULL && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 200 && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 409) {
                returnSetCustomer.statusCode = returnSendAddUserFolderRights.respAddUserFolderRights.statusCode;
                returnSetCustomer.statusMessage = 'API Add System User Root Folder Rights Error: ' + returnSendAddUserFolderRights.respAddUserFolderRights.message;
                GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                return returnSetCustomer;
            }
            
            // Give Analysts Root Folder Rights
            for(String aid :arrAnalystIDs) {
                returnSendAddUserFolderRights returnSendAddUserFolderRightsAnalysts = sendAddUserFolderRights(returnSetCustomer.authToken, aid, returnSetCustomer.rootFolderId, TRUE, TRUE);
                if(returnSendAddUserFolderRightsAnalysts.apitrans != NULL) {
                    returnSetCustomer.apiTrans.add(returnSendAddUserFolderRightsAnalysts.apitrans);
                }
            }

            // Study Folder
            returnSendGetFolder returnSendGetFolder = sendGetFolder(returnSetCustomer.authToken, NULL, returnSetCustomer.rootFolderId);
            if(returnSendGetFolder.apitrans != NULL) {
                returnSetCustomer.apiTrans.add(returnSendGetFolder.apitrans);
            }
            
            if(returnSendGetFolder.respGetFolder != NULL && returnSendGetFolder.respGetFolder.statusCode != 200) {
                returnSetCustomer.statusCode = returnSendGetFolder.respGetFolder.statusCode;
                returnSetCustomer.statusMessage = 'API Get Customer Folders Error: ' + returnSendGetFolder.respGetFolder.errorDetail;
                GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                return returnSetCustomer;
            }
            
            if(returnSendGetFolder.respGetFolder.data != NULL && returnSendGetFolder.respGetFolder.data.folders != NULL && !returnSendGetFolder.respGetFolder.data.folders.IsEmpty()) {
                for(respGetFolderDataFolders rgcf :returnSendGetFolder.respGetFolder.data.folders) {
                    if(rgcf.externalId == studyId) {
                        returnSetCustomer.studyFolderId = rgcf.id;
                        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Folder Found',returnSetCustomer.studyFolderId);
                    }
                }               
            }
            
            // Study Folder not found, Add one
            if(returnSetCustomer.studyFolderId == NULL) {
                GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Folder Not Found','');
                
                returnSendAddCustomerFolder returnSendAddCustomerFolder = sendAddCustomerFolder(returnSetCustomer.customerId, studyName, studyId, returnSetCustomer.rootFolderId, returnSetCustomer.authToken);
                if(returnSendAddCustomerFolder.apitrans != NULL) {
                    returnSetCustomer.apiTrans.add(returnSendAddCustomerFolder.apitrans);
                }
                
                if(returnSendAddCustomerFolder.respAddCustomerFolder != NULL && returnSendAddCustomerFolder.respAddCustomerFolder.statusCode != 201) {
                    returnSetCustomer.statusCode = returnSendAddCustomerFolder.respAddCustomerFolder.statusCode;
                    returnSetCustomer.statusMessage = 'API Add Study Folders Error: ' + returnSendAddCustomerFolder.respAddCustomerFolder.message;
                    GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                    return returnSetCustomer;
                }
                
                if(returnSendAddCustomerFolder.respAddCustomerFolder.data != NULL) {
                    returnSetCustomer.studyFolderId = returnSendAddCustomerFolder.respAddCustomerFolder.data.id;
                    GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Folder Added',returnSetCustomer.studyFolderId);
                }
            }
            
            GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Folder',returnSetCustomer.studyFolderId);
            
            if(returnSetCustomer.studyFolderId == NULL) {
                returnSetCustomer.statusCode = 404;
                returnSetCustomer.statusMessage = 'Study Folder Not Found and Cannot Create';
                return returnSetCustomer;
            } else {
                
                // Give System User Rights to Study Folder
                returnSendAddUserFolderRights = sendAddUserFolderRights(returnSetCustomer.authToken, returnSetCustomer.systemUserInfo.id, returnSetCustomer.studyFolderId, TRUE, TRUE);
                if(returnSendAddUserFolderRights.apitrans != NULL) {
                    returnSetCustomer.apiTrans.add(returnSendAddUserFolderRights.apitrans);
                }
                
                if(returnSendAddUserFolderRights.respAddUserFolderRights != NULL && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 200 && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 409) {
                    returnSetCustomer.statusCode = returnSendAddUserFolderRights.respAddUserFolderRights.statusCode;
                    returnSetCustomer.statusMessage = 'API Add System User Study Folder Rights Error: ' + returnSendAddUserFolderRights.respAddUserFolderRights.message;
                    GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                    return returnSetCustomer;
                }
                
                // Give Analysts Study Folder Rights
                for(String aid :arrAnalystIDs) {
                    returnSendAddUserFolderRights returnSendAddUserFolderRightsAnalysts = sendAddUserFolderRights(returnSetCustomer.authToken, aid, returnSetCustomer.studyFolderId, TRUE, TRUE);
                    if(returnSendAddUserFolderRightsAnalysts.apitrans != NULL) {
                        returnSetCustomer.apiTrans.add(returnSendAddUserFolderRightsAnalysts.apitrans);
                    }
                }
                
                // Study Processed & Results Folder
                returnSendGetFolder = sendGetFolder(returnSetCustomer.authToken, NULL, returnSetCustomer.studyFolderId);
                if(returnSendGetFolder.apitrans != NULL) {
                    returnSetCustomer.apiTrans.add(returnSendGetFolder.apitrans);
                }
                
                if(returnSendGetFolder.respGetFolder != NULL && returnSendGetFolder.respGetFolder.statusCode != 200) {
                    returnSetCustomer.statusCode = returnSendGetFolder.respGetFolder.statusCode;
                    returnSetCustomer.statusMessage = 'API Get Customer Processed/Results Folders Error: ' + returnSendGetFolder.respGetFolder.errorDetail;
                    GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                    return returnSetCustomer;
                }
                
                if(returnSendGetFolder.respGetFolder.data != NULL && returnSendGetFolder.respGetFolder.data.folders != NULL && !returnSendGetFolder.respGetFolder.data.folders.IsEmpty()) {
                    for(respGetFolderDataFolders rgcf :returnSendGetFolder.respGetFolder.data.folders) {
                        if(rgcf.name == 'Processed') {
                            returnSetCustomer.studyProcessedFolderId = rgcf.id;
                            GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Processed Folder Found',returnSetCustomer.studyProcessedFolderId);
                        } else if(rgcf.name == 'Results') {
                            returnSetCustomer.studyResultsFolderId = rgcf.id;
                            GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Results Folder Found',returnSetCustomer.studyResultsFolderId);
                        }
                    }               
                }
                
                // Study Processed Folder not found, Add one
                if(returnSetCustomer.studyProcessedFolderId == NULL) {
                    GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Processed Folder Not Found','');
                    
                    returnSendAddCustomerFolder returnSendAddCustomerFolder = sendAddCustomerFolder(returnSetCustomer.customerId, 'Processed', studyId + 'Processed', returnSetCustomer.studyFolderId, returnSetCustomer.authToken);
                    if(returnSendAddCustomerFolder.apitrans != NULL) {
                        returnSetCustomer.apiTrans.add(returnSendAddCustomerFolder.apitrans);
                    }
                    
                    if(returnSendAddCustomerFolder.respAddCustomerFolder != NULL && returnSendAddCustomerFolder.respAddCustomerFolder.statusCode != 201) {
                        returnSetCustomer.statusCode = returnSendAddCustomerFolder.respAddCustomerFolder.statusCode;
                        returnSetCustomer.statusMessage = 'API Add Study Processed Folders Error: ' + returnSendAddCustomerFolder.respAddCustomerFolder.message;
                        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                        return returnSetCustomer;
                    }
                    
                    if(returnSendAddCustomerFolder.respAddCustomerFolder.data != NULL) {
                        returnSetCustomer.studyProcessedFolderId = returnSendAddCustomerFolder.respAddCustomerFolder.data.id;
                        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Processed Folder Added',returnSetCustomer.studyProcessedFolderId);
                    }
                }               
                
                GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Processed Folder',returnSetCustomer.studyProcessedFolderId);
                
                if(returnSetCustomer.studyProcessedFolderId != NULL) {
                                        
                    // Give System User Rights to Study Processed Folder
                    returnSendAddUserFolderRights = sendAddUserFolderRights(returnSetCustomer.authToken, returnSetCustomer.systemUserInfo.id, returnSetCustomer.studyProcessedFolderId, TRUE, TRUE);
                    if(returnSendAddUserFolderRights.apitrans != NULL) {
                        returnSetCustomer.apiTrans.add(returnSendAddUserFolderRights.apitrans);
                    }
                    
                    if(returnSendAddUserFolderRights.respAddUserFolderRights != NULL && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 200 && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 409) {
                        returnSetCustomer.statusCode = returnSendAddUserFolderRights.respAddUserFolderRights.statusCode;
                        returnSetCustomer.statusMessage = 'API Add System User Study Folder Rights Error: ' + returnSendAddUserFolderRights.respAddUserFolderRights.message;
                        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                        return returnSetCustomer;
                    }
                    
                    // Give Analysts Study Processed Folder Rights
                    for(String aid :arrAnalystIDs) {
                        returnSendAddUserFolderRights returnSendAddUserFolderRightsAnalysts = sendAddUserFolderRights(returnSetCustomer.authToken, aid, returnSetCustomer.studyProcessedFolderId, TRUE, TRUE);
                        if(returnSendAddUserFolderRightsAnalysts.apitrans != NULL) {
                            returnSetCustomer.apiTrans.add(returnSendAddUserFolderRightsAnalysts.apitrans);
                        }
                    }

                    GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Processed Folder Rights Added','');
                    
                    returnSetCustomer.statusCode = 200;
                    returnSetCustomer.statusMessage = 'Customer Set Successfully';
                    
                } else {
                    returnSetCustomer.statusCode = 404;
                    returnSetCustomer.statusMessage = 'Study Processed Folder Not Found and Cannot Create';
                    return returnSetCustomer;
                }
                
                // Study Results Folder not found, Add one
                if(returnSetCustomer.studyResultsFolderId == NULL) {
                    GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Results Folder Not Found','');
                    
                    returnSendAddCustomerFolder returnSendAddCustomerFolder = sendAddCustomerFolder(returnSetCustomer.customerId, 'Results', accountId + 'Results', returnSetCustomer.studyFolderId, returnSetCustomer.authToken);
                    if(returnSendAddCustomerFolder.apitrans != NULL) {
                        returnSetCustomer.apiTrans.add(returnSendAddCustomerFolder.apitrans);
                    }
                    
                    if(returnSendAddCustomerFolder.respAddCustomerFolder != NULL && returnSendAddCustomerFolder.respAddCustomerFolder.statusCode != 201) {
                        returnSetCustomer.statusCode = returnSendAddCustomerFolder.respAddCustomerFolder.statusCode;
                        returnSetCustomer.statusMessage = 'API Add Study Results Folders Error: ' + returnSendAddCustomerFolder.respAddCustomerFolder.message;
                        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                        return returnSetCustomer;
                    }
                    
                    if(returnSendAddCustomerFolder.respAddCustomerFolder.data != NULL) {
                        returnSetCustomer.studyResultsFolderId = returnSendAddCustomerFolder.respAddCustomerFolder.data.id;
                        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Results Folder Added',returnSetCustomer.studyResultsFolderId);
                    }
                }               
                
                GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Results Folder',returnSetCustomer.studyResultsFolderId);
                
                if(returnSetCustomer.studyResultsFolderId != NULL) {
                                        
                    // Give System User Rights to Study Results Folder
                    returnSendAddUserFolderRights = sendAddUserFolderRights(returnSetCustomer.authToken, returnSetCustomer.systemUserInfo.id, returnSetCustomer.studyResultsFolderId, TRUE, TRUE);
                    if(returnSendAddUserFolderRights.apitrans != NULL) {
                        returnSetCustomer.apiTrans.add(returnSendAddUserFolderRights.apitrans);
                    }
                    
                    if(returnSendAddUserFolderRights.respAddUserFolderRights != NULL && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 200 && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 409) {
                        returnSetCustomer.statusCode = returnSendAddUserFolderRights.respAddUserFolderRights.statusCode;
                        returnSetCustomer.statusMessage = 'API Add System User Study Folder Rights Error: ' + returnSendAddUserFolderRights.respAddUserFolderRights.message;
                        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','API Error', returnSetCustomer);
                        return returnSetCustomer;
                    }
                    
                    // Give Analysts Study Results Folder Rights
                    for(String aid :arrAnalystIDs) {
                        returnSendAddUserFolderRights returnSendAddUserFolderRightsAnalysts = sendAddUserFolderRights(returnSetCustomer.authToken, aid, returnSetCustomer.studyResultsFolderId, TRUE, TRUE);
                        if(returnSendAddUserFolderRightsAnalysts.apitrans != NULL) {
                            returnSetCustomer.apiTrans.add(returnSendAddUserFolderRightsAnalysts.apitrans);
                        }
                    }

                    GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Study Results Folder Rights Added','');
                    
                    returnSetCustomer.statusCode = 200;
                    returnSetCustomer.statusMessage = 'Customer Set Successfully';
                    
                } else {
                    returnSetCustomer.statusCode = 404;
                    returnSetCustomer.statusMessage = 'Study Results Folder Not Found and Cannot Create';
                    return returnSetCustomer;
                }
                
            }
            
           
       } else {
           returnSetCustomer.statusCode = 403;
           returnSetCustomer.statusMessage = 'Authentication Failed';
       }
        
        GARP_Common.debugLog('AWSSecureFileClass','setCustomer','Final returnSetCustomer', returnSetCustomer);
        return returnSetCustomer;
    }
 
    public class returnSetUser {
        public String statusMessage;
        public Integer statusCode;
        public List<API_Transaction__c> apiTrans;
        public String authToken;
        public String customerId;
        public String bucketId;
        public String rootFolderId;
        public String studyFolderId;
    }
    
    public static returnSetUser setUser(String accountName, String accountId, String bucketName, String studyName, String studyId, String contactName, String contactId, String contactEmail, Boolean canUpload, Boolean canDownload, Boolean enabled) {
        GARP_Common.debugLog('AWSSecureFileClass','setUser','accountName',accountName);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','accountId',accountId);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','bucketName',bucketName);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','studyName',studyName);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','studyId',studyId);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','contactName',contactName);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','contactId',contactId);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','canUpload',canUpload);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','canDownload',canDownload);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','enabled',enabled);
        
        returnSetUser returnSetUser = new returnSetUser();
        returnSetUser.apiTrans = new List<API_Transaction__c>();
        
        // Disable User
        if(!enabled) {
            String authToken;
            returnSendAuth returnSendAuth = sendAuth();
            
            if(returnSendAuth.respAuth != NULL && returnSendAuth.respAuth.statusCode == 200 && returnSendAuth.respAuth.data != NULL) {    
                authToken = returnSendAuth.respAuth.data;
                GARP_Common.debugLog('AWSSecureFileClass','setUser','Auth Success',authToken);
            } else {
                returnSetUser.statusCode = 401;
                returnSetUser.statusMessage = 'Authentication Failed';
                return returnSetUser;
            }
            
            // See if User already exists
            returnSendGetUser returnSendGetUser = sendGetUser(authToken, contactId);
            if(returnSendGetUser.apitrans != NULL) {
                returnSetUser.apiTrans.add(returnSendGetUser.apitrans);
            }
            
            if(returnSendGetUser.respGetUser != NULL && returnSendGetUser.respGetUser.statusCode != 200) {
                returnSetUser.statusCode = returnSendGetUser.respGetUser.statusCode;
                returnSetUser.statusMessage = 'API Get User Error: ' + returnSendGetUser.respGetUser.message;
                GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSetUser);
                return returnSetUser;
            }
            
            // User Found
            if(returnSendGetUser.respGetUser.data != NULL && returnSendGetUser.respGetUser.data.users != NULL && !returnSendGetUser.respGetUser.data.users.IsEmpty()) {
                respUser foundUser = returnSendGetUser.respGetUser.data.users[0];
                
                // If Enabled, disable them
                if(foundUser.status == 'Active') {
                    
                    // Disable User
                    returnSendEnableDisableUser returnSendEnableDisableUser = sendEnableDisableUser(authToken, foundUser.Id, False);
                    if(returnSendEnableDisableUser.apitrans != NULL) {
                        returnSetUser.apiTrans.add(returnSendEnableDisableUser.apitrans);
                    }
                    
                    if(returnSendEnableDisableUser.respEnableDisableUser != NULL && returnSendEnableDisableUser.respEnableDisableUser.statusCode != 200) {
                        returnSetUser.statusCode = returnSendEnableDisableUser.respEnableDisableUser.statusCode;
                        returnSetUser.statusMessage = 'API Enable/Disable User Error: ' + returnSendEnableDisableUser.respEnableDisableUser.message;
                        GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSetUser);
                        return returnSetUser;
                    }
                    
                }
                returnSetUser.statusCode = 200;
                returnSetUser.statusMessage = 'User Set Successfully';
                return returnSetUser;
                
            } else {
                returnSetUser.statusCode = 404;
                returnSetUser.statusMessage = 'User Not Found';
                return returnSetUser;
            }
        }
        
        if(Label.GARP_AWSSecureFile_Mode != 'Production') {
            String defualtAWSBucket = GBI_Service_Config__c.getAll().get('AWS_Bucket').Value__c;
            bucketName = defualtAWSBucket;
            GARP_Common.debugLog('AWSSecureFileClass','setUser','bucketName',bucketName);
        }
        
        // Save these
        respUser foundUser;
        respCreateUserData createUser;
        
        returnSetCustomer returnSetCustomer = setCustomer(accountName, accountId, bucketName, studyName, studyId);
        if(returnSetCustomer.apitrans != NULL) {
            returnSetUser.apiTrans.addAll(returnSetCustomer.apitrans);
        }
     
        if(returnSetCustomer.statusCode != 200) {
            returnSetUser.statusCode = returnSetCustomer.statusCode;
            returnSetUser.statusMessage = returnSetCustomer.statusMessage;
            return returnSetUser;
        } 
        
        GARP_Common.debugLog('AWSSecureFileClass','setUser','authToken', returnSetCustomer.authToken);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','customerId', returnSetCustomer.customerId);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','bucketId', returnSetCustomer.bucketId);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','rootFolderId', returnSetCustomer.rootFolderId);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','studyFolderId', returnSetCustomer.studyFolderId);
        GARP_Common.debugLog('AWSSecureFileClass','setUser','studyProcessedFolderId', returnSetCustomer.studyProcessedFolderId);
        
        String userId;
        
        // See if User already exists
        returnSendGetUser returnSendGetUser = sendGetUser(returnSetCustomer.authToken, contactId);
        if(returnSendGetUser.apitrans != NULL) {
            returnSetUser.apiTrans.add(returnSendGetUser.apitrans);
        }
        
        if(returnSendGetUser.respGetUser != NULL && returnSendGetUser.respGetUser.statusCode != 200) {
            returnSetUser.statusCode = returnSendGetUser.respGetUser.statusCode;
            returnSetUser.statusMessage = 'API Get User Error: ' + returnSendGetUser.respGetUser.message;
            GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSetUser);
            return returnSetUser;
        }
        
        // User Found
        if(returnSendGetUser.respGetUser.data != NULL && returnSendGetUser.respGetUser.data.users != NULL && !returnSendGetUser.respGetUser.data.users.IsEmpty()) {
            foundUser = returnSendGetUser.respGetUser.data.users[0];
            userId = foundUser.id;
            GARP_Common.debugLog('AWSSecureFileClass','setUser','User Found', foundUser);

            // If Disabled, enable them
            if(foundUser.status == 'InActive') {
                
                GARP_Common.debugLog('AWSSecureFileClass','setUser','User Disabled, now enable them', '');
                
                // Enable User
                returnSendEnableDisableUser returnSendEnableDisableUser = sendEnableDisableUser(returnSetCustomer.authToken, userId, True);
                if(returnSendEnableDisableUser.apitrans != NULL) {
                    returnSetUser.apiTrans.add(returnSendEnableDisableUser.apitrans);
                }
                
                if(returnSendEnableDisableUser.respEnableDisableUser != NULL && returnSendEnableDisableUser.respEnableDisableUser.statusCode != 200) {
                    returnSetUser.statusCode = returnSendEnableDisableUser.respEnableDisableUser.statusCode;
                    returnSetUser.statusMessage = 'API Add User Folder Rights Error: ' + returnSendEnableDisableUser.respEnableDisableUser.message;
                    GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSetUser);
                    return returnSetUser;
                }
            }
            
            // Does User have rights to study folder
            respUserFolder getUserStudyFolder;
            respUserFolder getUserStudyProcessedFolder;
            if(foundUser.assignedFolders != NULL && !foundUser.assignedFolders.IsEmpty()) {
                for(respUserFolder ruf :foundUser.assignedFolders) {
                    if(ruf.folderExternalId == studyId) {
                        getUserStudyFolder = ruf;
                        GARP_Common.debugLog('AWSSecureFileClass','setUser','User Study Folder Rights Found', getUserStudyFolder);
                    }
                    if(ruf.folderExternalId == studyId+'Processed') {
                        getUserStudyProcessedFolder = ruf;
                        GARP_Common.debugLog('AWSSecureFileClass','setUser','User Processed Folder Rights Found', getUserStudyProcessedFolder);
                    }
                }
            }
            
            // No Study Folder Rights Found, Add Rights
            if(getUserStudyFolder == NULL) {
                GARP_Common.debugLog('AWSSecureFileClass','setUser','User Study Folder Rights Not Found', '');
                
                // Add rights to Study Folder
                returnSendAddUserFolderRights returnSendAddUserFolderRights = sendAddUserFolderRights(returnSetCustomer.authToken, foundUser.id, returnSetCustomer.studyFolderId, canUpload, canDownload);
                if(returnSendAddUserFolderRights.apitrans != NULL) {
                    returnSetUser.apiTrans.add(returnSendAddUserFolderRights.apitrans);
                }
                
                if(returnSendAddUserFolderRights.respAddUserFolderRights != NULL && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 200 && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 409) {
                    returnSetUser.statusCode = returnSendAddUserFolderRights.respAddUserFolderRights.statusCode;
                    returnSetUser.statusMessage = 'API Add User Folder Rights Error: ' + returnSendAddUserFolderRights.respAddUserFolderRights.message;
                    GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSetUser);
                    return returnSetUser;
                }
                
                GARP_Common.debugLog('AWSSecureFileClass','setUser','User Study Folder Rights Added', returnSendAddUserFolderRights.respAddUserFolderRights);
            } else {
                
                // Update Folder Rights
                returnSendAddUserFolderRights returnSendAddUserFolderRights = sendUpdateUserFolderRights(returnSetCustomer.authToken, foundUser.id, returnSetCustomer.studyFolderId, canUpload, canDownload);
                if(returnSendAddUserFolderRights.apitrans != NULL) {
                    returnSetUser.apiTrans.add(returnSendAddUserFolderRights.apitrans);
                }
                
                if(returnSendAddUserFolderRights.respAddUserFolderRights != NULL && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 200 && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 409) {
                    returnSetUser.statusCode = returnSendAddUserFolderRights.respAddUserFolderRights.statusCode;
                    returnSetUser.statusMessage = 'API Update User Folder Rights Error: ' + returnSendAddUserFolderRights.respAddUserFolderRights.message;
                    GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSetUser);
                    return returnSetUser;
                }
                
                GARP_Common.debugLog('AWSSecureFileClass','setUser','User Study Folder Rights Updated', returnSendAddUserFolderRights.respAddUserFolderRights);
                
            }
            
            // No Study Processed Folder Rights Found, Add Rights
            if(getUserStudyProcessedFolder == NULL) {
                GARP_Common.debugLog('AWSSecureFileClass','setUser','User Processed Folder Rights Not Found', '');
                
                // Add rights to Study Folder
                returnSendAddUserFolderRights returnSendAddUserFolderRights = sendAddUserFolderRights(returnSetCustomer.authToken, foundUser.id, returnSetCustomer.studyProcessedFolderId, canUpload, canDownload);
                if(returnSendAddUserFolderRights.apitrans != NULL) {
                    returnSetUser.apiTrans.add(returnSendAddUserFolderRights.apitrans);
                }
                
                if(returnSendAddUserFolderRights.respAddUserFolderRights != NULL && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 200 && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 409) {
                    returnSetUser.statusCode = returnSendAddUserFolderRights.respAddUserFolderRights.statusCode;
                    returnSetUser.statusMessage = 'API Add User Processed Folder Rights Error: ' + returnSendAddUserFolderRights.respAddUserFolderRights.message;
                    GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSetUser);
                    return returnSetUser;
                }
                
                GARP_Common.debugLog('AWSSecureFileClass','setUser','User Processed Folder Rights Added', returnSendAddUserFolderRights.respAddUserFolderRights);
            } else {
                
                // Update Folder Rights
                returnSendAddUserFolderRights returnSendAddUserFolderRights = sendUpdateUserFolderRights(returnSetCustomer.authToken, foundUser.id, returnSetCustomer.studyProcessedFolderId, canUpload, canDownload);
                if(returnSendAddUserFolderRights.apitrans != NULL) {
                    returnSetUser.apiTrans.add(returnSendAddUserFolderRights.apitrans);
                }
                
                if(returnSendAddUserFolderRights.respAddUserFolderRights != NULL && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 200 && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 409) {
                    returnSetUser.statusCode = returnSendAddUserFolderRights.respAddUserFolderRights.statusCode;
                    returnSetUser.statusMessage = 'API Update User Processed Folder Rights Error: ' + returnSendAddUserFolderRights.respAddUserFolderRights.message;
                    GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSetUser);
                    return returnSetUser;
                }
                
                GARP_Common.debugLog('AWSSecureFileClass','setUser','User Processed Folder Rights Updated', returnSendAddUserFolderRights.respAddUserFolderRights);
                
            }
        }
        
        if(Test.isRunningTest()) {
            foundUser = NULL;
        }
        
        // Else Add new user
        if(foundUser == NULL) {

            // Create User
            GARP_Common.debugLog('AWSSecureFileClass','setUser','User Not Found','');
            
            returnSendCreateUser returnSendCreateUser = sendCreateUser(returnSetCustomer.authToken, contactId, contactName, contactEmail, returnSetCustomer.customerId, studyName, studyId, returnSetCustomer.studyFolderId);
            if(returnSendCreateUser.apitrans != NULL) {
                returnSetUser.apiTrans.add(returnSendCreateUser.apitrans);
            }
            
            if(returnSendCreateUser.respCreateUser != NULL && returnSendCreateUser.respCreateUser.statusCode != 201) {
                returnSetUser.statusCode = returnSendCreateUser.respCreateUser.statusCode;
                returnSetUser.statusMessage = 'API Get Customer Folders Error: ' + returnSendCreateUser.respCreateUser.message;
                GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSendCreateUser);
                return returnSetUser;
            }
            
            if(returnSendCreateUser.respCreateUser.data != NULL) {
                createUser = returnSendCreateUser.respCreateUser.data;
                userId = createUser.id;
                GARP_Common.debugLog('AWSSecureFileClass','setUser','User Added',createUser);
            }
            
            // Add rights to Study Folder
            returnSendAddUserFolderRights returnSendAddUserFolderRights = sendAddUserFolderRights(returnSetCustomer.authToken, createUser.id, returnSetCustomer.studyFolderId, canUpload, canDownload);
            if(returnSendAddUserFolderRights.apitrans != NULL) {
                returnSetUser.apiTrans.add(returnSendAddUserFolderRights.apitrans);
            }
            
            if(returnSendAddUserFolderRights.respAddUserFolderRights != NULL && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 200 && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 409) {
                returnSetUser.statusCode = returnSendAddUserFolderRights.respAddUserFolderRights.statusCode;
                returnSetUser.statusMessage = 'API Add User Folder Rights Error: ' + returnSendAddUserFolderRights.respAddUserFolderRights.message;
                GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSetUser);
                return returnSetUser;
            }
            
            GARP_Common.debugLog('AWSSecureFileClass','setUser','User Study Folder Rights Added', returnSendAddUserFolderRights.respAddUserFolderRights);
            
            // Add rights to Study Folder
            returnSendAddUserFolderRights = sendAddUserFolderRights(returnSetCustomer.authToken, createUser.id, returnSetCustomer.studyProcessedFolderId, canUpload, canDownload);
            if(returnSendAddUserFolderRights.apitrans != NULL) {
                returnSetUser.apiTrans.add(returnSendAddUserFolderRights.apitrans);
            }
            
            if(returnSendAddUserFolderRights.respAddUserFolderRights != NULL && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 200 && returnSendAddUserFolderRights.respAddUserFolderRights.statusCode != 409) {
                returnSetUser.statusCode = returnSendAddUserFolderRights.respAddUserFolderRights.statusCode;
                returnSetUser.statusMessage = 'API Add User Processed Folder Rights Error: ' + returnSendAddUserFolderRights.respAddUserFolderRights.message;
                GARP_Common.debugLog('AWSSecureFileClass','setUser','API Error', returnSetUser);
                return returnSetUser;
            }
            
            GARP_Common.debugLog('AWSSecureFileClass','setUser','User Processed Folder Rights Added', returnSendAddUserFolderRights.respAddUserFolderRights);
            
        }
        
        if(userId == NULL) {
            returnSetUser.statusCode = 404;
            returnSetUser.statusMessage = 'User Not Found';
            return returnSetUser;
        }
        
        returnSetUser.statusCode = 200;
        returnSetUser.statusMessage = 'User Set Successfully';
        
        return returnSetUser;
    }
    
    public static void setStudy(String studyId) {
        GBI_Common.debugLog('GBI_BC_Studies','setStudy','studyId',studyId);
        
        List<Study_Contact__c> lstStudyContact = [select id, AWS_Folder_Access__c, AWS_Folder_Access_Last_Updated__c, Role__c,
                                                  Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email,
                                                  Study__r.Secure_File_Integration_Status__c,
                                                  Study_Account__r.Secure_File_Platform__c, Study_Account__r.Account__c, Study_Account__r.Account__r.Name,  
                                                  Study_Account__r.Account__r.Alternate_Name__c, Study__c, Study__r.Name, Status__c, Study_Account__r.Status__c
                                                  from Study_Contact__c where Contact__c != NULL AND Study__c = :studyId];
        GBI_Common.debugLog('GBI_BC_Studies','setStudy','lstStudyContact',lstStudyContact);
        
        if(!lstStudyContact.IsEmpty()) {
            if(lstStudyContact[0].Study__r.Secure_File_Integration_Status__c != NULL && lstStudyContact[0].Study__r.Secure_File_Integration_Status__c == 'Enabled') {
                Database.executeBatch(new AWSSecureFileBatch(lstStudyContact), 1);        
            }
        }
    }    
    
    public static void setStudyAccount(String studyAccountId) {
        GBI_Common.debugLog('GBI_BC_Studies','setStudy','studyAccountId',studyAccountId);
        
        List<Study_Account__c> lstStudyAccount = [select id, Status__c, Secure_File_Platform__c, Account__c, Account__r.Name,  
                                                  Account__r.Alternate_Name__c, Study__c, Study__r.Name,
                                                  Study__r.Secure_File_Integration_Status__c
                                                  from Study_Account__c where Id = :studyAccountId];
        GBI_Common.debugLog('GBI_BC_Studies','setStudy','lstStudyAccount',lstStudyAccount);
        
        if(!lstStudyAccount.IsEmpty()) {
            Study_Account__c studyAccount = lstStudyAccount[0];
            
            if(studyAccount.Study__r.Secure_File_Integration_Status__c != NULL && studyAccount.Study__r.Secure_File_Integration_Status__c == 'Enabled' &&
               studyAccount.Secure_File_Platform__c != NULL && studyAccount.Secure_File_Platform__c.IndexOf('AWS') > -1) {
                
                   AWSSecureFileClass.returnSetCustomer retSetCustomer;
                   
                   if(studyAccount.Status__c == 'Active') {
                       String accountName = studyAccount.Account__r.Name;
                       if(studyAccount.Account__r.Alternate_Name__c != NULL) {
                           accountName = studyAccount.Account__r.Alternate_Name__c;
                       }
                       
                       retSetCustomer = setCustomer(accountName, studyAccount.Account__c, studyAccount.Account__c, studyAccount.Study__r.Name, studyAccount.Study__c);
                       
                       GBI_Common.debugLog('GBI_BC_Studies','setStudy','lstStudyAccount',lstStudyAccount);
                       
                       
                       if(retSetCustomer.apiTrans != NULL && !retSetCustomer.apiTrans.IsEmpty()) {
                           for(API_Transaction__c apit :retSetCustomer.apiTrans) {
                               apit.Study_Account__c = studyAccountId;
                           }
                           //insert ret.apiTrans;
                       }
                       
                       GBI_Common.debugLog('GBI_BC_Studies','setCustomer','statusCode',retSetCustomer.statusCode);
                   }
                   
                
                if(studyAccount.Status__c != 'Active' || retSetCustomer.statusCode == 200) {
                    List<Study_Contact__c> lstStudyContact = [select id, AWS_Folder_Access__c, AWS_Folder_Access_Last_Updated__c, Role__c,
                                                              Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email,
                                                              Study__r.Secure_File_Integration_Status__c,
                                                              Study_Account__r.Secure_File_Platform__c, Study_Account__r.Account__c, Study_Account__r.Account__r.Name,  
                                                              Study_Account__r.Account__r.Alternate_Name__c, Study__c, Study__r.Name, Status__c, Study_Account__r.Status__c
                                                              from Study_Contact__c where Contact__c != NULL AND Study_Account__c = :studyAccountId];
                    GBI_Common.debugLog('GBI_BC_Studies','setStudy','lstStudyContact',lstStudyContact);
                    
                    if(!lstStudyContact.IsEmpty()) {
                        Database.executeBatch(new AWSSecureFileBatch(lstStudyContact), 1);    
                    }
                }
            }
        }
    }    
    
    @future(callout=true)
    public static void setStudyContact(String studyContactId) {
        GBI_Common.debugLog('GBI_BC_Studies','setStudyContact','studyContactId',studyContactId);
        
        List<Study_Contact__c> lstStudyContact = [select id, AWS_Folder_Access__c, AWS_Folder_Access_Last_Updated__c, Role__c,
                                                  Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email,
                                                  Study__r.Secure_File_Integration_Status__c,
                                                  Study_Account__r.Secure_File_Platform__c, Study_Account__r.Account__c, Study_Account__r.Account__r.Name,  
                                                  Study_Account__r.Account__r.Alternate_Name__c, Study__c, Study__r.Name, Status__c, Study_Account__r.Status__c
                                                  from Study_Contact__c where Id = :studyContactId];
        GBI_Common.debugLog('GBI_BC_Studies','setStudyContact','lstStudyContact',lstStudyContact);

        if(!lstStudyContact.IsEmpty()) {
            Study_Contact__c studyContact = lstStudyContact[0];
                        
            if(studyContact.Study__r.Secure_File_Integration_Status__c != NULL && studyContact.Study__r.Secure_File_Integration_Status__c == 'Enabled' &&
               studyContact.Study_Account__r.Secure_File_Platform__c != NULL && studyContact.Study_Account__r.Secure_File_Platform__c.IndexOf('AWS') > -1) {
                
                String accountName = studyContact.Study_Account__r.Account__r.Name;
                if(studyContact.Study_Account__r.Account__r.Alternate_Name__c != NULL) {
                    accountName = studyContact.Study_Account__r.Account__r.Alternate_Name__c;
                }
                
                String contactName = studyContact.Contact__r.FirstName + ' ' + studyContact.Contact__r.LastName;
                
                Boolean enabled = (studyContact.Status__c == 'Active' && studyContact.Study_Account__r.Status__c == 'Active');
                GBI_Common.debugLog('GBI_BC_Studies','setStudyContact','enabled',enabled);
                
                Boolean canUpload = (studyContact.Role__c != NULL && studyContact.Role__c.IndexOf('Data Manager') > -1);
                Boolean canDownload = True;
                   
                AWSSecureFileClass.returnSetUser ret = setUser(accountName, studyContact.Study_Account__r.Account__c, studyContact.Study_Account__r.Account__c, studyContact.Study__r.Name, studyContact.Study__c, contactName, studyContact.Contact__c, studyContact.Contact__r.Email, canUpload, canDownload, enabled);
                GBI_Common.debugLog('GBI_BC_Studies','setStudyContact','statusCode',ret.statusCode);
                
                if(ret.statusCode == 200 && enabled) {
                    studyContact.AWS_Folder_Access__c = 'Has Access';
                } else if(ret.statusCode == 200 && !enabled) {
                    studyContact.AWS_Folder_Access__c = 'Does Not Have Access';
                } else {
                    studyContact.AWS_Folder_Access__c = NULL;
                }
                studyContact.AWS_Folder_Access_Last_Updated__c = DateTime.Now();
                update studyContact;
                
                if(ret.apiTrans != NULL && !ret.apiTrans.IsEmpty()) {
                    for(API_Transaction__c apit :ret.apiTrans) {
                        apit.Study_Contact__c = studyContactId;
                    }
                    insert ret.apiTrans;
                }
            } else {
                GBI_Common.debugLog('GBI_BC_Studies','setStudyContact','AWS Secure File Not Enabled for this Study Account','');
            }
        }
    }
    
    @InvocableMethod(label='SecureAWSFileFlow' description='Operate AWS Secure File integration.')
    public static void secureAWSFileFlow(List<List<String>> inputParams) {  
        
        GARP_Common.debugLog('AWSSecureFileClass','secureAWSFileFlow','inputParams', inputParams);
        
        String method;
        String param1;
        String param2;
        String param3;
        String param4;
        List<String> ids = inputParams[0];
        
        if(!ids.isEmpty()){
            Integer cnt=0;
            for(String idVal :ids) {
                if(cnt==0)
                    method = idVal;
                else if(cnt==1)
                    param1 = idVal;
                else if(cnt==2)
                    param2 = idVal;
                else if(cnt==3)
                    param3 = idVal;
                else if(cnt==4)
                    param4 = idVal;
                cnt++;
            }
            
            GARP_Common.debugLog('AWSSecureFileClass','secureAWSFileFlow','method', method);
            GARP_Common.debugLog('AWSSecureFileClass','secureAWSFileFlow','param1', param1);            
            GARP_Common.debugLog('AWSSecureFileClass','secureAWSFileFlow','param2', param2);            
            GARP_Common.debugLog('AWSSecureFileClass','secureAWSFileFlow','param3', param3);            
            GARP_Common.debugLog('AWSSecureFileClass','secureAWSFileFlow','param4', param4);            
            
            //if(!Test.isRunningTest()){   
                if(method == 'setStudyAccount') {
                    setStudyAccount(param1);
                } else if(method == 'setStudyContact') {
                    setStudyContact(param1);
                } else if(method == 'setStudy') {
                    setStudy(param1);
                }             
            //}
        }
    }
}