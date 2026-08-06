/*  Class for integration with ShareFile.com from Citrix
 *  Invoked By Process Builder: GBI Set Sharefile Study/Study Account/Study Contact
 *  [12/07/2018 Xiang] - Switch future call into batch
 *  [07/30/2019 Xiang] - [US-24370] Added File Upload function
 */
public class shareFileClass {

    public class authResp {
        String access_token;
    }
    
    public class getFolderResp {
        String code;
        String FileCount;
        String Id;
    }

    public class getUserResp {
        String code;
        String Id;
    }
    
    public class addUserPref {
        Boolean CanResetPassword;
        Boolean CanViewMySettings;
    }

    public class zoneProp {
        String Id;
    }
    
    public class addUserReq {
        String Email;
        String FirstName;
        String LastName;
        String Company;
        String Password;
        Boolean notify;
        addUserPref Preferences;
        zoneProp DefaultZone;
    }
    
    public class createFolderReq {
        String Name;
        String Description;
        zoneProp Zone;
        String ExpirationDate;
    }
    
    public class principal {
        String Id;
    }

    public class giveAccessReq {
        principal Principal;
        Boolean CanUpload;
        Boolean CanDownload;
        Boolean CanView;
        Boolean CanDelete;
        Boolean CanManagePermissions;
        String Message;
    }
    
    public class sendNotifyReq {
        List<String> UserIds;
        String CustomMessage;
    }
    
    public static Boolean testNotFound;
    
    public static HTTPResponse sendRequest(String method, String url, String bodyIn, String token, Boolean isAuth) {
        
        String endpoint = 'https://garp.sf-api.com/sf/v3';
        if(url != null)
            endpoint = url;
        
        System.debug('endpoint:' + endpoint);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
            
        if(isAuth == true) {
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setMethod('POST');            
        } else {
            request.setHeader('Content-Type', 'application/json');
            if(token != null)
                request.setHeader('Authorization', 'Bearer ' + token);
            request.setMethod(method);
            System.debug('method:' + method);

        }
            
        if(bodyIn != null) {
            request.setbody(bodyIn);
            System.debug('body:' + bodyIn);
        }
            
        
        Http http = new Http();
        
        HTTPResponse response;       
        Integer statusCode;
        
        if(!Test.isRunningTest()){
            response = http.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            response.setBody('{"code":"123","id":"1234"}'); 
            if(testNotFound != NULL && testNotFound == True) {
                statusCode = 404;
                response.setStatusCode(404);
            } else {
                statusCode = 200;
                response.setStatusCode(200);                
            }
        }        
        
        System.debug('response:' + response.getStatusCode());
        System.debug('body:' + response.getBody());
                
        return response;
    }    
    
    public static String limitSize(String inStr, Integer maxSize) {
        if(inStr != null) {
            if(inStr.length() > maxSize)
                return inStr.substring(0, maxSize);
            else return inStr;
        }
        return inStr;
    }

    public static API_Transaction__c addApiTransaction(String description, String studyId, String studyAccountId, String studyContactId, String req, String reqBody, String resp, String respCode) {
        API_Transaction__c api = new API_Transaction__c(Description__c=description, Study__c=studyId, Study_Account__c=studyAccountId, Study_Contact__c=studyContactId, Type__c='Sharefile', Request__c=limitSize(req,255), Body__c=reqBody, Response__c=limitSize(resp,255), Response_Code__c=respCode);
        return api;
    }
    
    /*** Start File Upload Methods ***/
    private static Map<String, Sharefile_API_Config__c> sfConfigs {
        get {
            if(null == sfConfigs) {
                sfConfigs = Sharefile_API_Config__c.getall();
            }
            return sfConfigs;
        }
        set;
    }
    
    private static HttpResponse authShareFile(Id studyContactId, List<API_Transaction__c> lstApiTrans) {
        String authEmail = sfConfigs.get('AuthEmail').Value__c;
        String authPassword = sfConfigs.get('AuthPassword').Value__c;
        String authClientId = sfConfigs.get('AuthClientId').Value__c;
        String authClientSecret = sfConfigs.get('AuthClientSecret').Value__c;
        String loginEndPoint = sfConfigs.get('LoginEndPoint').Value__c;
        
        String params = 'grant_type=password&client_id=' + authClientId + '&client_secret=' + authClientSecret + '&username=' + authEmail + '&password=' + authPassword;
        
        HTTPResponse resp = sendRequest(null, loginEndPoint, params, null, true);
        lstApiTrans.add(addApiTransaction('Auth', null, null, studyContactId, loginEndPoint, params, resp.getBody(), String.valueOf(resp.getStatusCode())));
        
        return resp;
    }
    
    // Load Study Account Folder Id from ShareFile
    private static Map<String, Object> loadStudyAccountFolderId(Study_Contact__c studyContact) {
        List<API_Transaction__c> lstApiTrans = new List<API_Transaction__c>();
        String studyAccountFolderId = null;
        
        String studyId = studyContact.Study__c;
        String studyAccountId = studyContact.Study_Account__c;
        String accountId = studyContact.Study_Account__r.Account__c;
        
        // 1. Authenticate
        String authToken;
        HttpResponse authResp = authShareFile(studyContact.Id, lstApiTrans);
        
        if(authResp.getStatusCode() == 200) {
            authResp ar = (authResp)JSON.deserialize(authResp.getBody(), authResp.class);    
            authToken = ar.access_token;
            
            String baseEndPoint = sfConfigs.get('BaseEndPoint').Value__c;
            String baseFolderId = sfConfigs.get('BaseFolderID').Value__c;

            String studyFolderId = null;
            
            // 2. Get Study Folder
            // https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)/ByPath?path=/Study_Id
            String url = baseEndPoint + String.format('/Items({0})/ByPath?path=/{1}', new String[]{baseFolderId, studyId});
            HttpResponse resp = sendRequest('GET', url, null, authToken, false);
            
            lstApiTrans.add(addApiTransaction('Get Study Folder ' + studyAccountId, null, studyAccountId, null, url, null, resp.getBody(), String.valueOf(resp.getStatusCode())));
            
            if(resp.getStatusCode() == 200) {
                getFolderResp gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                studyFolderId = gfr.Id;
                
                // 3. Get Account Folder
                // https://garp.sf-api.com/sf/v3/Items(ShareFile_Study_Id)/ByPath?path=/Account_Id
                url = BaseEndPoint + String.format('/Items({0})/ByPath?path=/{1}', new String[]{studyFolderId, accountId});
                resp = sendRequest('GET', url, null, authToken, false);
                
                lstApiTrans.add(addApiTransaction('Get Study Account Folder ' + accountId, null, studyAccountId, null, url, null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                
                if(resp.getStatusCode() == 200) {
                    // Get Study Account Folder Id
                    gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                    studyAccountFolderId = gfr.Id;
                }
            }
        }
        
        return new Map<String, Object>{'authToken' => authToken, 'studyAccountFolderId' => studyAccountFolderId, 'lstApiTrans' => lstApiTrans};        
    }
    
    // [US-24370] Get Upload Link to the Study Account Folder from ShareFile. If folder doesn't exist call setStudyAccount to create folders.
    public static String generateSFUploadLink(Study_Contact__c studyContact) {
        String uploadLink;
        String studyAccountId = studyContact.Study_Account__c;
        
        // Get Results from Loading Study Account Id
        Map<String, Object> acctFolderResult = loadStudyAccountFolderId(studyContact);
        String authToken = (String) acctFolderResult.get('authToken');
        String studyAccountFolderId = (String)acctFolderResult.get('studyAccountFolderId');
        List<API_Transaction__c> lstApiTrans = (List<API_Transaction__c>)acctFolderResult.get('lstApiTrans');
        
        if(String.isNotEmpty(studyAccountFolderId)) {
            // Default Config - Require ShareFile Login, expire after 30 mins
            Boolean requireLogin = true, requireInfo = false;
            Integer expireMins = 30;
            
            if(sfConfigs.containsKey('Upload_RequireLogin')) {
                requireLogin = Boolean.valueOf(sfConfigs.get('Upload_RequireLogin').Value__c);
            }
            if(sfConfigs.containsKey('Upload_RequireInfo')) {
                requireInfo = Boolean.valueOf(sfConfigs.get('Upload_RequireInfo').Value__c);
            }
            if(sfConfigs.containsKey('Upload_ExpireMins')) {
                expireMins = Integer.valueOf(sfConfigs.get('Upload_ExpireMins').Value__c);
            }
            
            String expDateStr = System.now().addMinutes(expireMins).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            String title = 'Get share link from GBI for ' + studyContact.Id;
            Map<String, String> parentMap = new Map<String, String>{'Id' => studyAccountFolderId};
            
            // Create Share Request Body
            Map<String, Object> shareModelBody = new Map<String, Object>{
                'ShareType' => 'Request', 'RequireLogin' => requireLogin, 'RequireUserInfo' => requireInfo, 'ExpirationDate' => expDateStr,
                'Title' => title, 'Parent' => parentMap
            };
            
            // Get Upload URL (Request Share)
            String url = sfConfigs.get('BaseEndPoint').Value__c + '/Shares';
            HttpResponse resp = sendRequest('POST', url, JSON.serialize(shareModelBody), authToken, false);
            
            lstApiTrans.add(addApiTransaction('Get Upload Link for Study Account Folder ' + studyContact.Study_Account__r.Account__c, null, studyAccountId, null, url, null, resp.getBody(), String.valueOf(resp.getStatusCode())));
            
            if(resp.getStatusCode() == 200) {
                if(Test.isRunningTest()) {
                    uploadLink = 'https://abc.com/api/random_share';
                }else {
                    ShareModel shareMdl = (ShareModel)JSON.deserialize(resp.getBody(), ShareModel.class);
                	uploadLink = shareMdl.Uri; 
                }
                
            }
        }else {
            System.debug('generateSFUploadLink() - Study Account Folder Id load failed OR need to create folder.');
            setStudyAccount(studyAccountId);
        }

        insert lstApiTrans;        
        
        return uploadLink;
    }
    
    @testVisible private class ShareModel {
        @testVisible private String Id {get;set;}                // Id of the posted Share
        @testVisible private String Uri {get;set;}               // Uri to return to user
        @testVisible private String url {get;set;}               // url of the posted Share
        @testVisible private String AliasID {get;set;}           // alias Id of posted Share
        @testVisible private String CreationDate {get;set;}      // Created Date of posted Share
        @testVisible private String ExpirationDate {get;set;}    // Expiration Date of posted Share
    }
    
    // [US-24370] Alternative Approach for uploading file - Use Salesforce as middle tier. If raw only text based files are supported
    /* public static String generateSFFileUploadLink(Study_Contact__c studyContact, String fileName) {
        String fileUploadLink;
        String studyAccountId = studyContact.Study_Account__c;
        
        // Get Results from Loading Study Account Id
        Map<String, Object> acctFolderResult = loadStudyAccountFolderId(studyContact);
        String authToken = (String) acctFolderResult.get('authToken');
        String studyAccountFolderId = (String)acctFolderResult.get('studyAccountFolderId');
        List<API_Transaction__c> lstApiTrans = (List<API_Transaction__c>)acctFolderResult.get('lstApiTrans');
        
        if(String.isNotEmpty(studyAccountFolderId)) {
            // 4. Get Upload URL
            String url = sfConfigs.get('BaseEndPoint').Value__c + String.format('/Items({0})/Upload2', new String[]{studyAccountFolderId});
            Map<String, Object> upldReqBody = new Map<String, Object>{
                'Method' => 'standard', 'Raw' => true, 'FileName' => fileName
            };
            HttpResponse resp = sendRequest('POST', url, JSON.serialize(upldReqBody), authToken, false);
            lstApiTrans.add(addApiTransaction('Get File Upload Link for Study Account Folder ' + studyContact.Study_Account__r.Account__c, null, studyAccountId, null, url, null, resp.getBody(), String.valueOf(resp.getStatusCode())));
            
            if(resp.getStatusCode() == 200) {
                UploadSpec us = (UploadSpec)JSON.deserialize(resp.getBody(), UploadSpec.class);
                fileUploadLink = us.ChunkUri;
            }
        }else {
            setStudyAccountSync(studyAccountId);
        }
        
        insert lstApiTrans;
        
        return fileUploadLink;
    }
    
    private class UploadSpec {
        private String Method {get;set;}
        private String ChunkUri {get;set;}
        private String ProgressData {get;set;}
    } */
    /*** End File Upload Methods ***/
    
    public static List<API_Transaction__c> disableUser(String studyContactId, String folderID, String authToken, String email) {
        
        System.debug('disableUser');
        
        List<API_Transaction__c> lstApiTrans = new List<API_Transaction__c>();
        Map<String, Sharefile_API_Config__c> rSites =   Sharefile_API_Config__c.getall();
        String BaseEndPoint = rSites.get('BaseEndPoint').Value__c;
        String ZoneId = rSites.get('ZoneId').Value__c;

        // Get User
        String userID = NULL;
        
        // https://garp.sf-api.com/sf/v3/Users?emailaddress=garcia.alberto.crespo@gmail.com
        String url = BaseEndPoint + String.format('/Users?emailaddress={0}', new String[]{email});
        HTTPResponse resp = sendRequest('GET',url,Null, authToken, False);
        lstApiTrans.add(addApiTransaction('Get User', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));


        if(resp.getStatusCode() == 200) {
            
            // Set User ID
            getUserResp gur = (getUserResp)JSON.deserialize(resp.getBody(), getUserResp.class);    
            userID = gur.Id;        
            
            // https://garp.sf-api.com/sf/v3/AccessControls(principalid=id,itemid=id)
            url = BaseEndPoint + String.format('/AccessControls(principalid={0},itemid={1})', new String[]{userID, folderID});
            resp = sendRequest('DELETE',url,null, authToken, False);
            lstApiTrans.add(addApiTransaction('Remove Access To Folder', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
        }
        return lstApiTrans;
    }


    public static List<API_Transaction__c> setUser(String studyContactId, Boolean hasAccess, String folderID, String authToken, String email, String firstName, String lastName, String company, String studyName) {
        
        System.debug('setUser');
        
        List<API_Transaction__c> lstApiTrans = new List<API_Transaction__c>();
        Map<String, Sharefile_API_Config__c> rSites =   Sharefile_API_Config__c.getall();
        String BaseEndPoint = rSites.get('BaseEndPoint').Value__c;
        String ZoneId = rSites.get('ZoneId').Value__c;
        
        // Get User
        String userID = NULL;
        Boolean hasFolderAccess = false;
        
        // https://garp.sf-api.com/sf/v3/Users?emailaddress=garcia.alberto.crespo@gmail.com
        String url = BaseEndPoint + String.format('/Users?emailaddress={0}', new String[]{email});
        HTTPResponse resp = sendRequest('GET',url,Null, authToken, False);
        lstApiTrans.add(addApiTransaction('Get User', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
        
        // If not found
        if(resp.getStatusCode() == 404 && hasAccess == True) {
        
            // Add User
            zoneProp cfzr = new zoneProp();
            cfzr.Id = ZoneId;
            
            addUserPref aup = new addUserPref();
            aup.CanResetPassword=true;
            aup.CanViewMySettings=true;
            
            addUserReq aur = new addUserReq();
            aur.Email = email;
            aur.FirstName = firstName;
            aur.LastName = lastName;
            aur.Company = company;
            aur.Password = 'qr3t45g8uIUHyR^efE$^%E';
            aur.notify = true;
            aur.Preferences = aup;
            aur.DefaultZone = cfzr;
            
            String JSONString = JSON.serialize(aur);
            
            // https://garp.sf-api.com/sf/v3/Users
            url = BaseEndPoint + '/Users';
            resp = sendRequest('POST',url,JSONString, authToken, False);
            lstApiTrans.add(addApiTransaction('Add User', Null, Null, studyContactId, url, JSONString, resp.getBody(), String.valueOf(resp.getStatusCode())));

        }
        
        if(resp.getStatusCode() == 200) {
            
            // Set User ID
            getUserResp gur = (getUserResp)JSON.deserialize(resp.getBody(), getUserResp.class);    
            userID = gur.Id;
            
            // https://garp.sf-api.com/sf/v3/AccessControls(principalid=49c298ec-d7f3-47bc-9fe8-f2dcf53d128e,itemid=foa0ec36-7858-40c8-a1d2-0e2af4ce87f0)
            url = BaseEndPoint + String.format('/AccessControls(principalid={0},itemid={1})', new String[]{userID,folderID});
            resp = sendRequest('GET',url , Null, authToken, False);
            lstApiTrans.add(addApiTransaction('Get User Folder Access', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
            
            if(resp.getStatusCode() == 200) {
                hasFolderAccess = true;
            }   
        }
        
        // User Exists
        if(userID != NULL) {
            
            // Give Access To Folder is not already there
            if(hasAccess == True && hasFolderAccess == False) {
            
                principal p = new principal();
                p.Id = userID;
                
                giveAccessReq gar = new giveAccessReq();
                gar.Principal = p;
                gar.CanUpload = true;
                gar.CanDownload = true;
                gar.CanView = true;
                gar.CanDelete = false;
                gar.CanManagePermissions = false;
                gar.Message = '';
                
                String JSONString = JSON.serialize(gar);
                
                // https://garp.sf-api.com/sf/v3/Items(foa0ec36-7858-40c8-a1d2-0e2af4ce87f0)/AccessControls?recursive=false
                url = BaseEndPoint + String.format('/Items({0})/AccessControls?recursive=false', new String[]{folderID});
                resp = sendRequest('POST',url,JSONString, authToken, False);
                lstApiTrans.add(addApiTransaction('Give Access To Folder', Null, Null, studyContactId, JSONString, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                
                // Send Notification
                sendNotifyReq snr= new sendNotifyReq();
                List<String> lstStr = new List<String>();
                lstStr.add(userID);
                snr.UserIds = lstStr;
                snr.CustomMessage = 'You now have access to the ' + studyName + ' Folder.';
                JSONString = JSON.serialize(snr);
                
                url = BaseEndPoint + String.format('/Items({0})/AccessControls/NotifyUsers', new String[]{folderID});
                resp = sendRequest('POST',url,JSONString, authToken, False);
                lstApiTrans.add(addApiTransaction('Send Notification', Null, Null, studyContactId, JSONString, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
            
            } else if(hasAccess == False && hasFolderAccess == True) {
                
                // If has folder access but should not remove it
                
                // https://garp.sf-api.com/sf/v3/AccessControls(principalid=id,itemid=id)
                url = BaseEndPoint + String.format('/AccessControls(principalid={0},itemid={1})', new String[]{userID, folderID});
                resp = sendRequest('DELETE',url,null, authToken, False);
                lstApiTrans.add(addApiTransaction('Remove Access To Folder', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                
            }
        }
        return lstApiTrans;
        
    }
    
    // Check if Study Account Folder exists, if not create Folder. Then call setUser to.
    public static List<API_Transaction__c> setAccount(String StudyID, Boolean hasAccess, String studyAccountId, String studyAccountName, String accountID, String studyFolderID, String authToken) {
        System.debug('setAccount');
        
        List<API_Transaction__c> lstApiTrans = new List<API_Transaction__c>();
        
        Map<String, Sharefile_API_Config__c> rSites =   Sharefile_API_Config__c.getall();
        String BaseEndPoint = rSites.get('BaseEndPoint').Value__c;
        String BaseFolderID = rSites.get('BaseFolderID').Value__c;
        String ZoneId = rSites.get('ZoneId').Value__c;

        if(studyFolderID != NULL) {
            
            // Study Account Folder
            String studyAccountFolderID=NULL;
            
            // Check if Study Account folder exists
            // https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)/ByPath?path=/Account_Id
            String url = BaseEndPoint + String.format('/Items({0})/ByPath?path=/{1}', new String[]{studyFolderID, accountID});
            HTTPResponse resp = sendRequest('GET',url,Null, authToken, False);
            lstApiTrans.add(addApiTransaction('Get Study Account Folder ' + accountID, Null, studyAccountId, NUll, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
            
            // If Study Account Folder Not Found
            if(resp.getStatusCode() == 404) {
                
                // Create Study Account Folder
                zoneProp cfzr = new zoneProp();
                cfzr.Id = ZoneId;
                
                createFolderReq cfr = new createFolderReq();
                cfr.Name = accountID;
                cfr.Zone = cfzr;
                cfr.ExpirationDate = '9999-12-31T23:59:59.9999999Z';
                
                String JSONString = JSON.serialize(cfr);
                
                // https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)/Folder?overwrite=false&passthrough=false
                url = BaseEndPoint + String.format('/Items({0})/Folder?overwrite=false&passthrough=false', new String[]{studyFolderID});
                resp = sendRequest('POST',url,JSONString, authToken, False);
                lstApiTrans.add(addApiTransaction('Create Study Account Folder ' + accountID, Null, studyAccountId, NUll, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                
                getFolderResp gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                studyAccountFolderID = gfr.Id;
                
            } else {
                
                // Get Study Account Folder ID
                getFolderResp gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                studyAccountFolderID = gfr.Id;
            }
            
            // Add Study Contact
            List<Study_Contact__c> lstStudyCnts = [select Id, Contact_Email__c, Contact__r.FirstName, Contact__r.LastName, Study__r.Name from Study_Contact__c where Study_Account__c = :studyAccountId AND Status__c = 'Active' AND Role__c includes ('Data Manager')];
            for(Study_Contact__c sc :lstStudyCnts) {
                
                List<API_Transaction__c> lat = setUser(sc.Id, hasAccess, studyAccountFolderID, authToken, sc.Contact_Email__c, sc.Contact__r.FirstName, sc.Contact__r.LastName, studyAccountName, sc.Study__r.Name);
                for(API_Transaction__c at :lat) {
                    lstApiTrans.add(at);
                }
            }                                       
        }
        
        return lstApiTrans;
    }

    public static void setStudy(String studyId) {
        System.debug('setStudy');

        List<Study__c> lstS = [select Id, Name, Status__c from Study__c where Id = :studyId AND Status__c in ('In Progress','Completed','Suspended') and Secure_File_Integration_Status__c = 'Enabled'];
        if(lstS.size() > 0) {
            // Xiang - Added Secure_File_Platform__c check
            List<Study_Account__c> lstSA = [Select Id, Name, Status__c from Study_Account__c where Study__c = :studyId AND Status__c in ('Active','Suspended') AND Secure_File_Platform__c includes ('ShareFile')];
            System.debug('lstSA:' + lstSA);
            
            // Switch from future method to batch - No more than 50 method calls per Apex invocation
            /* for(Study_Account__c sa :lstSA) {
                setStudyAccount(sa.Id);
            } */
            
            ShareFileSetStudy_Batch sfBatch = new ShareFileSetStudy_Batch(lstSA);
            Database.executeBatch(sfBatch, 1);
        }
    }
    
    @future(callout=true)
    public static void setStudyAccount(String studyAccountId) {
        setStudyAccountSync(studyAccountId);
    }
    
    // Xiang - Separate Sync and Future calls for setStudyAccount
    /*  Check Study Folder exists, if not create Folder. Then call setAccount to check/create Study Account Folder.
        Study need to be ShareFile enabled, Study Account need to be active 
    */
    public static void setStudyAccountSync(String studyAccountId) {
        System.debug('setStudyAccount: ' + studyAccountId);
        
        List<API_Transaction__c> lstApiTrans = new List<API_Transaction__c>();
        List<Study_Account__c> lstSA = [select Id, Account__c, Account__r.Name, Status__c, Secure_File_Platform__c, Study__c, Study__r.Status__c, Study__r.Secure_File_Integration_Status__c from Study_Account__c where Id = :studyAccountId AND Status__c in ('Active','Suspended') and Study__r.Secure_File_Integration_Status__c = 'Enabled' AND Secure_File_Platform__c includes ('ShareFile')];
        
        System.debug('Study Account size (lstSA): ' + lstSA.size());
        if(lstSA.size() > 0) {
            Study_Account__c sa = lstSA[0];
            String StudyID = sa.Study__c;
            String StudyAccountName = sa.Account__r.Name;
            String accountID = sa.Account__c;
            Boolean hasAccess = false;
            if(sa.Status__c == 'Active' && sa.Study__r.Status__c == 'In Progress') {
                hasAccess = true;
            }
            
            Map<String, Sharefile_API_Config__c> rSites = Sharefile_API_Config__c.getall();
            String AuthEmail = rSites.get('AuthEmail').Value__c;
            String AuthPassword = rSites.get('AuthPassword').Value__c;
            String AuthClientId = rSites.get('AuthClientId').Value__c;
            String AuthClientSecret = rSites.get('AuthClientSecret').Value__c;
            String LoginEndPoint = rSites.get('LoginEndPoint').Value__c;
            String BaseEndPoint = rSites.get('BaseEndPoint').Value__c;
            String BaseFolderID = rSites.get('BaseFolderID').Value__c;
            String ZoneId = rSites.get('ZoneId').Value__c;
            
            // Authenticate
            String authToken;
            String params = 'grant_type=password&client_id=' + AuthClientId + '&client_secret=' + AuthClientSecret + '&username=' + AuthEmail + '&password=' + AuthPassword;
            
            HTTPResponse resp = sendRequest(NULL,LoginEndPoint, params, Null, True);
            lstApiTrans.add(addApiTransaction('Auth', Null, studyAccountId, NUll, LoginEndPoint, params, resp.getBody(), String.valueOf(resp.getStatusCode())));
            
            if(resp.getStatusCode() == 200) {
                
                authResp ar = (authResp)JSON.deserialize(resp.getBody(), authResp.class);    
                authToken = ar.access_token;
                system.debug('Token:' + authToken);
                
                // Get Base Folder
                // https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)?includeDeleted=false            
                String url = BaseEndPoint + String.format('/Items({0})?includeDeleted=false', new String[]{BaseFolderID});
                resp = sendRequest('GET',url, Null, authToken, False);
                lstApiTrans.add(addApiTransaction('Get Base Folder', NUll, studyAccountId, NUll, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                
                if(resp.getStatusCode() == 200) {
                    
                    // Study Folder
                    String studyFolderID=NULL;
                    
                    // Check if Study folder exists
                    // https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)/ByPath?path=/Study_Id
                    url = BaseEndPoint + String.format('/Items({0})/ByPath?path=/{1}', new String[]{BaseFolderID, StudyID});
                    resp = sendRequest('GET', url, Null, authToken, False);
                    lstApiTrans.add(addApiTransaction('Get Study Folder ' + studyAccountId, NUll, studyAccountId, NUll, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                    
                    // If Study Folder Not Found
                    if(resp.getStatusCode() == 404) {
                        
                        // Create Study Folder
                        zoneProp cfzr = new zoneProp();
                        cfzr.Id = ZoneId;
                        
                        createFolderReq cfr = new createFolderReq();
                        cfr.Name = StudyID;
                        cfr.Zone = cfzr;
                        cfr.ExpirationDate = '9999-12-31T23:59:59.9999999Z';
                        
                        String JSONString = JSON.serialize(cfr);
                        
                        // https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)/Folder?overwrite=false&passthrough=false
                        url = BaseEndPoint + String.format('/Items({0})/Folder?overwrite=false&passthrough=false', new String[]{BaseFolderID});
                        resp = sendRequest('POST', url, JSONString, authToken, False);
                        lstApiTrans.add(addApiTransaction('Create Study Folder ' + StudyID, studyId, Null, NUll, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                        
                        if(resp.getStatusCode() == 200) {
                            
                            // Study Folder Created
                            getFolderResp gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                            studyFolderID = gfr.Id;
                        } else {
                            
                            // Failed to create Study Folder. Check if Study folder exists again
                            url = BaseEndPoint + String.format('/Items({0})/ByPath?path=/{1}', new String[]{BaseFolderID, StudyID});
                            resp = sendRequest('GET', url, Null, authToken, False);
                            lstApiTrans.add(addApiTransaction('Get Study Folder ' + studyAccountId, NUll, studyAccountId, NUll, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                            
                            if(resp.getStatusCode() == 200) {
                                
                                // Get Folder ID
                                getFolderResp gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                                studyFolderID = gfr.Id;
                            }
                        }
                    } else {
                        
                        // Study Folder Exists. Get Folder ID
                        getFolderResp gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                        studyFolderID = gfr.Id;
                    }
                    
                    // If Study Folder Found after all checks
                    if(studyFolderID != NULL) {
                        
                        List<API_Transaction__c> lat = setAccount(studyId, hasAccess, studyAccountId, StudyAccountName, accountID, studyFolderID, authToken);
                        for(API_Transaction__c at :lat) {
                            lstApiTrans.add(at);
                        }
                    }
                }
            }
            
            System.debug('lstApiTrans:' + lstApiTrans);
            insert lstApiTrans;
        }
    }

    public static List<API_Transaction__c> getStudyContact(String studyContactId) {
        
        System.debug('getStudyContact');
        
        List<API_Transaction__c> lstApiTrans = new List<API_Transaction__c>();
        List<Study_Contact__c> lstSC = [select Id, Status__c, Role__c, Contact_Email__c, Contact__r.FirstName, Contact__r.LastName, Study_Account__c, Study_Account__r.Account__c, Study_Account__r.Account__r.Name, Study_Account__r.Status__c, Study__c from Study_Contact__c where Id = :studyContactId];
        if(lstSC.size() > 0) {
            Study_Contact__c sc = lstSC[0];
            String StudyID = sc.Study__c;
            String studyAccountId = sc.Study_Account__c;
            String StudyAccountName = sc.Study_Account__r.Account__r.Name;
            String accountID = sc.Study_Account__r.Account__c;
            Boolean hasAccess = false;
            if(sc.Status__c == 'Active' && sc.Study_Account__r.Status__c == 'Active' && sc.Role__c.indexOf('Data Manager') > -1) {
                hasAccess = true;
            }
           
            Map<String, Sharefile_API_Config__c> rSites =   Sharefile_API_Config__c.getall();
            String AuthEmail = rSites.get('AuthEmail').Value__c;
            String AuthPassword = rSites.get('AuthPassword').Value__c;
            String AuthClientId = rSites.get('AuthClientId').Value__c;
            String AuthClientSecret = rSites.get('AuthClientSecret').Value__c;
            String LoginEndPoint = rSites.get('LoginEndPoint').Value__c;
            String BaseEndPoint = rSites.get('BaseEndPoint').Value__c;
            String BaseFolderID = rSites.get('BaseFolderID').Value__c;
            String ZoneId = rSites.get('ZoneId').Value__c;
            
            // Authenticate
            String authToken;
            String params = 'grant_type=password&client_id=' + AuthClientId + '&client_secret=' + AuthClientSecret + '&username=' + AuthEmail + '&password=' + AuthPassword;
            
            HTTPResponse resp = sendRequest(NULL,LoginEndPoint, params, Null, True);
            lstApiTrans.add(addApiTransaction('Auth', Null, Null, studyContactId, LoginEndPoint, params, resp.getBody(), String.valueOf(resp.getStatusCode())));
            
            if(resp.getStatusCode() == 200) {
                authResp ar = (authResp)JSON.deserialize(resp.getBody(), authResp.class);    
                authToken = ar.access_token;
                system.debug('Token:' + authToken);
                
                
                // Get Base Folder
                //https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)?includeDeleted=false            
                String url = BaseEndPoint + String.format('/Items({0})?includeDeleted=false', new String[]{BaseFolderID});
                resp = sendRequest('GET',url,Null, authToken, False);
                lstApiTrans.add(addApiTransaction('Get Base Folder', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                
                if(resp.getStatusCode() == 200) {
                    
                    // Study Folder
                    String studyFolderID=NULL;
                    
                    // Check if Study folder exists
                    // https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)/ByPath?path=/Study Account Y
                    url = BaseEndPoint + String.format('/Items({0})/ByPath?path=/{1}', new String[]{BaseFolderID, StudyID});
                    resp = sendRequest('GET',url,Null, authToken, False);
                    lstApiTrans.add(addApiTransaction('Get Study Folder', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));

                    // If Folder Found
                    if(resp.getStatusCode() == 200) {

                        // Get Folder ID
                        getFolderResp gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                        studyFolderID = gfr.Id;

                        // Study Account Folder
                        String studyAccountFolderID=NULL;
                        
                        // Check if Study Account folder exists
                        // https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)/ByPath?path=/Study Account Y
                        url = BaseEndPoint + String.format('/Items({0})/ByPath?path=/{1}', new String[]{studyFolderID, accountID});
                        resp = sendRequest('GET',url,Null, authToken, False);
                        lstApiTrans.add(addApiTransaction('Get Study Account Folder', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                        
                        // If Folder Found
                        if(resp.getStatusCode() == 200) {
                            
                            // Get Folder ID
                            gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                            studyAccountFolderID = gfr.Id;                            

                            // https://garp.sf-api.com/sf/v3/Users?emailaddress=garcia.alberto.crespo@gmail.com
                            url = BaseEndPoint + String.format('/Users?emailaddress={0}', new String[]{sc.Contact_Email__c});
                            resp = sendRequest('GET',url,Null, authToken, False);
                            lstApiTrans.add(addApiTransaction('Get User', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                            
                            if(resp.getStatusCode() == 200) {
                                
                                // Set User ID
                                getUserResp gur = (getUserResp)JSON.deserialize(resp.getBody(), getUserResp.class);    
                                String userID = gur.Id;
                                
                                // https://garp.sf-api.com/sf/v3/AccessControls(principalid=49c298ec-d7f3-47bc-9fe8-f2dcf53d128e,itemid=foa0ec36-7858-40c8-a1d2-0e2af4ce87f0)
                                url = BaseEndPoint + String.format('/AccessControls(principalid={0},itemid={1})', new String[]{userID,studyAccountFolderID});
                                resp = sendRequest('GET',url , Null, authToken, False);
                                lstApiTrans.add(addApiTransaction('Get User Folder Access', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                            }                            
                                                        
                        }
                    }
                }
            }
        }
        return lstApiTrans;
    }

    
    @future(callout=true)
    public static void setStudyContact(String studyContactId) {
        
        System.debug('setStudyContact');
        
        List<API_Transaction__c> lstApiTrans = new List<API_Transaction__c>();
        List<Study_Contact__c> lstSC = [select Id, Status__c, Role__c, Contact_Email__c, Contact__r.FirstName, Contact__r.LastName, Study_Account__c, Study_Account__r.Account__c, Study_Account__r.Account__r.Name, Study_Account__r.Status__c, Study_Account__r.Secure_File_Platform__c, Study__c, Study__r.Name from Study_Contact__c where Id = :studyContactId AND Status__c in ('Active','Suspended') AND Study__r.Secure_File_Integration_Status__c = 'Enabled' AND Study_Account__r.Secure_File_Platform__c includes ('ShareFile')];
        if(lstSC.size() > 0) {
            Study_Contact__c sc = lstSC[0];
            String StudyID = sc.Study__c;
            String studyAccountId = sc.Study_Account__c;
            String StudyAccountName = sc.Study_Account__r.Account__r.Name;
            String accountID = sc.Study_Account__r.Account__c;
            Boolean hasAccess = false;
            if(sc.Status__c == 'Active' && sc.Study_Account__r.Status__c == 'Active' && sc.Role__c.indexOf('Data Manager') > -1) {
                hasAccess = true;
            }
           
            Map<String, Sharefile_API_Config__c> rSites =   Sharefile_API_Config__c.getall();
            String AuthEmail = rSites.get('AuthEmail').Value__c;
            String AuthPassword = rSites.get('AuthPassword').Value__c;
            String AuthClientId = rSites.get('AuthClientId').Value__c;
            String AuthClientSecret = rSites.get('AuthClientSecret').Value__c;
            String LoginEndPoint = rSites.get('LoginEndPoint').Value__c;
            String BaseEndPoint = rSites.get('BaseEndPoint').Value__c;
            String BaseFolderID = rSites.get('BaseFolderID').Value__c;
            String ZoneId = rSites.get('ZoneId').Value__c;
            
            // Authenticate
            String authToken;
            String params = 'grant_type=password&client_id=' + AuthClientId + '&client_secret=' + AuthClientSecret + '&username=' + AuthEmail + '&password=' + AuthPassword;
            
            HTTPResponse resp = sendRequest(NULL,LoginEndPoint, params, Null, True);
            lstApiTrans.add(addApiTransaction('Auth', Null, Null, studyContactId, LoginEndPoint, params, resp.getBody(), String.valueOf(resp.getStatusCode())));
            
            if(resp.getStatusCode() == 200) {
                authResp ar = (authResp)JSON.deserialize(resp.getBody(), authResp.class);    
                authToken = ar.access_token;
                system.debug('Token:' + authToken);

                // Get Base Folder
                //https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)?includeDeleted=false            
                String url = BaseEndPoint + String.format('/Items({0})?includeDeleted=false', new String[]{BaseFolderID});
                resp = sendRequest('GET',url,Null, authToken, False);
                lstApiTrans.add(addApiTransaction('Get Base Folder', Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                
                if(resp.getStatusCode() == 200) {
                    
                    // Study Folder
                    String studyFolderID=NULL;
                    
                    // Check if Study folder exists
                    // https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)/ByPath?path=/Study Account Y
                    url = BaseEndPoint + String.format('/Items({0})/ByPath?path=/{1}', new String[]{BaseFolderID, StudyID});
                    resp = sendRequest('GET',url,Null, authToken, False);
                    lstApiTrans.add(addApiTransaction('Get Study Folder ' + StudyID, Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));

                    // If Folder Found
                    if(resp.getStatusCode() == 200) {

                        // Get Folder ID
                        getFolderResp gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                        studyFolderID = gfr.Id;

                        // Study Account Folder
                        String studyAccountFolderID=NULL;
                        
                        // Check if Study Account folder exists
                        // https://garp.sf-api.com/sf/v3/Items(foe74ec2-f686-4c01-88a2-51748635c31e)/ByPath?path=/Study Account Y
                        url = BaseEndPoint + String.format('/Items({0})/ByPath?path=/{1}', new String[]{studyFolderID, accountID});
                        resp = sendRequest('GET',url,Null, authToken, False);
                        lstApiTrans.add(addApiTransaction('Get Study Account Folder ' + accountID, Null, Null, studyContactId, url, Null, resp.getBody(), String.valueOf(resp.getStatusCode())));
                        
                        // If Folder Found
                        if(resp.getStatusCode() == 200) {
                            
                            // Get Folder ID
                            gfr = (getFolderResp)JSON.deserialize(resp.getBody(), getFolderResp.class);
                            studyAccountFolderID = gfr.Id;                            
                            
                            List<API_Transaction__c> lat = setUser(sc.Id, hasAccess, studyAccountFolderID, authToken, sc.Contact_Email__c, sc.Contact__r.FirstName, sc.Contact__r.LastName, StudyAccountName, sc.Study__r.Name);
                            for(API_Transaction__c at :lat) {
                                lstApiTrans.add(at);
                            }   
                        }
                    }                
                }
            }
        }
        System.debug('lstApiTrans:' + lstApiTrans);
        insert lstApiTrans;

    }
    
    public String statusMessage {get;set;}
    
    private final Study_Contact__c sc;
    public shareFileClass(ApexPages.StandardController stdController) {
        this.sc = (Study_Contact__c)stdController.getRecord();
    }
    public shareFileClass() {
    }
    
    public void getStatus() {
        List<API_Transaction__c> lstApiTrans = getStudyContact(sc.Id);
        
        System.debug('lstApiTrans: ' + lstApiTrans);
        statusMessage='';
        
        List<Study_Contact__c> lstSC = [select Id, Sharefile_Folder_Access__c, Sharefile_Folder_Access_Last_Updated__c from Study_Contact__c where Id = :sc.Id];
        if(lstSC.size() > 0) {

            lstSC[0].Sharefile_Folder_Access__c = 'Does Not Have Access';
            for(API_Transaction__c apiTrans :lstApiTrans) {
                //statusMessage += String.valueOf(apiTrans) + '<br>';
                if(apiTrans.Description__c == 'Auth' && apiTrans.Response_Code__c != '200') {
                    statusMessage = 'Could not authenticate.';
                } else if(apiTrans.Description__c == 'Get Base Folder' && apiTrans.Response_Code__c != '200') {
                    statusMessage = 'GBI Folder Not Found.';
                } else if(apiTrans.Description__c == 'Get Study Folder' && apiTrans.Response_Code__c != '200') {
                    statusMessage = 'Study Folder Not Found.';
                } else if(apiTrans.Description__c == 'Get Study Account Folder' && apiTrans.Response_Code__c != '200') {
                    statusMessage = 'Study Account Folder Not Found.';
                } else if(apiTrans.Description__c == 'Get User' && apiTrans.Response_Code__c != '200') {
                    statusMessage = 'User Not Found.';
                } else if(apiTrans.Description__c == 'Get User Folder Access' && apiTrans.Response_Code__c != '200') {
                    statusMessage = 'User Does not have Access.';
                } else if(apiTrans.Description__c == 'Get User Folder Access' && apiTrans.Response_Code__c == '200') {
                    statusMessage = 'User has Access.';
                    lstSC[0].Sharefile_Folder_Access__c = 'Has Access';
                }
            }
            lstSC[0].Sharefile_Folder_Access_Last_Updated__c = System.now();
            update lstSC;
        }        
        System.debug('statusMessage: ' + statusMessage);
    }
        
    @InvocableMethod(label='sharefileFlow' description='Operate sharefile integration.')
    public static void sharefileFlow(List<List<String>> inputParams) {  
        
        System.debug('inputParams:' + inputParams);
        
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
            System.debug('method:' + method);
            System.debug('param1:' + param1);
            System.debug('param2:' + param2);
            System.debug('param3:' + param3);
            System.debug('param4:' + param4);
            
            if(!Test.isRunningTest()){   
                if(method == 'setStudyAccount') {
                    setStudyAccount(param1);
                } else if(method == 'setStudyContact') {
                    setStudyContact(param1);
                } else if(method == 'setStudy') {
                    setStudy(param1);
                }             
            }
        }
    }
}