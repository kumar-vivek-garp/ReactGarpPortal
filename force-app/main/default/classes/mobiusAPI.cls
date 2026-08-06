global class mobiusAPI {
    
    Public static Integer GARPOrgIdGlobal = 1111;
    Public static Integer apiVersionGlobal = 1;
    Public static Integer studentLevelGlobal = 0;
    Public static String apiTypeGlobal = 'Mobius';
    
    public class MobiusException extends Exception {}
    
    public class mOrg {
        Integer GARPOrgId;
        String Name;
    } 
    
    public class mUser {
        public Integer trash;
        public Integer level;
        public String firstName;
        public String lastName;
        public String email;
        public Integer GARPUserId;
    }
    
    public class mEnrollment {
        Integer product;
        Long expiry;
    }
    
    public class mProduct {
        Integer id;
        String name;
        Decimal price;
        String summary;
    }
    
    public class mResp {
        Integer status;
        String statusMsg;
    }
    
    
    public class mPingReq {
        String function;
    }
    
    public class mPingResp {
        Integer status;
        Integer version;
        String statusMsg;
    }
    
    public class mCreateOrganizationReq {
        String function;
        Integer version;
        String name;
        Integer GARPOrgId;        
    }
    
    public class mCreateOrganizationResp {
        String status;
        String statusMsg;        
        Integer orgId;
    }
    
    public class mGetOrganizationReq {
        String function;
        Integer version;
        Integer GARPOrgId;        
    }
    
    public class mGetOrganizationResp {
        Integer status;
        String statusMsg;        
        mOrg org;
    }
    
    public class mAddUserReq {
        String function;
        Integer version;
        Integer GARPOrgId;        
        mUser user;
    }
    
    public class mAddUserResp {
        Integer status;
        String statusMsg;        
        Integer userID;
    }
    
    public class mModifyUserReq {
        String function;
        Integer version;
        Integer GARPUserId;        
        mUser user;
    }
    
    public class mModifyUserResp { 
        Integer status;
        String statusMsg;        
        Integer userID;
    }
    
    public class mGetUserReq {
        String function;
        Integer version;
        Integer GARPUserId;        
        String email;
    }
    
    public class mGetUserResp {
        Integer status;
        String statusMsg;        
        mUser user;
        List<mEnrollment> enrollments;
    }
    
    public class mGetUserListReq {
        String function;
        Integer version;
        Integer GARPOrgId;        
    }
    
    public class mGetUserListResp {
        Integer status;
        String statusMsg;        
        List<String> users;
    }
    
    public class mEnrollUserReq {
        String function;
        Integer version;
        Integer GARPUserId;
        Integer product;        
    }
    
    public class mEnrollUserResp {
        Integer status;
        String statusMsg;        
    }
    
    public class mUnEnrollUserReq {
        String function;
        Integer version;
        Integer GARPUserId;
        Integer product;        
    }
    
    public class mUnEnrollUserResp {
        Integer status;
        String statusMsg;        
    }
    
    public class mGetProductListReq {
        String function;
        Integer version;
    }
    
    public class mGetProductListResp {
        Integer status;
        String statusMsg;        
        List<mProduct> products;
    }
    
    global class mUserLoginReq {
        global  String function;
        global  Integer version;
        global  String email;
        global  Integer context;
        global  Integer pageNumber;        
    }
    
    global class mUserLoginResp {
        global Integer status;
        global String statusMsg;        
        global String link;
    }
    
    public class mModifyOrganizationReq {
        String function;
        Integer version;
        Integer GARPOrgId;        
        String name;
        Boolean active;
    }
    
    public class mModifyOrganizationResp {
        Integer status;
        String statusMsg;        
    }
    
    global class mobiusRespWrapper {
        global  API_Transaction__c apiTrans;
        global  string response;
    }
    
    private static string limitString(String inStr, Integer max) {
        String respStr = inStr;
        if(String.isNotEmpty(inStr) && inStr.length() > max)
            respStr = inStr.subString(0,max);
        return respStr;
    }
    
    private static String getExceptionDetail(Exception e) {
        String detail = 'Line:' + e.getLineNumber() + ',Type:' + e.getTypeName() + ',Msg:' + e.getMessage() + ',Trace:' + e.getStackTraceString();
        detail = limitString(detail, 255);
        
        return detail;
    }
    
    public static mobiusRespWrapper sendRequest(String jsonData, String reqMethod) {
        
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        Map<String,Remote_Sites__c> rSites = Remote_Sites__c.getall();
        String siteURL = rSites.get('Mobius').Site_URL__c;
        
        request.setEndPoint(siteURL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        
        System.debug('jsonData:' + jsonData);
        request.setBody(jsonData);
        
        HttpResponse response;
        Integer statusCode;
        String ret;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }        
        system.debug('statusCode:' + String.valueOf(statusCode));
        String body;
        if(statusCode == 200) {
            if(!Test.isRunningTest()){
                body = response.getBody();
            } else {
                body = '{}';
            }            
            if(body != NULL && body.indexOf('{') == -1) {
                body=body.remove('"');
                body=body.remove('\n');
                body = '{"status":1,"Error":"' + body + '"}';
            }
            System.debug('body:' + body);
            ret=body;
        }
        
        API_Transaction__c apiTrans = new API_Transaction__c();
        apiTrans.Body__c = jsonData;
        apiTrans.Request__c = reqMethod;
        apiTrans.Type__c = apiTypeGlobal;                    
        apiTrans.Response_Code__c = String.valueOf(statusCode);
        apiTrans.Response__c = limitString(body, 255);   
        
        System.debug('APITransaction:' + apiTrans);
        
        mobiusRespWrapper mrw = new mobiusRespWrapper();
        mrw.apiTrans = apiTrans;
        mrw.response = body;
        return mrw;
    }
    
    public static mobiusRespWrapper pingMobius() {
        mPingReq mp = new mPingReq();
        mp.function = 'Ping';
        String JSONString = JSON.serialize(mp);
        
        mobiusRespWrapper resp = sendRequest(JSONString, mp.function);
        System.debug('resp:' + resp);
        return resp;                
    }
    
    public static mobiusRespWrapper mCreateOrganization(Integer version, String name, Integer GARPOrgId){
        mCreateOrganizationReq req = new mCreateOrganizationReq();
        req.function = 'CreateOrganization';
        req.version = version;
        req.name = name;
        req.GARPOrgId = GARPOrgId;
        String JSONString = JSON.serialize(req);
        mobiusRespWrapper resp = sendRequest(JSONString, req.function);
        System.debug('resp:' + resp);       
        return resp;
    }
    
    public static mobiusRespWrapper mGetOrganization(Integer version, Integer GARPOrgId){
        mGetOrganizationReq req = new mGetOrganizationReq();
        req.function = 'GetOrganization';
        req.version = version;
        req.GARPOrgId = GARPOrgId;
        String JSONString = JSON.serialize(req);
        mobiusRespWrapper resp = sendRequest(JSONString, req.function);
        if(Test.isRunningTest()){
            resp.Response = '{"status":0,"org":{"orgId":"2","GARPOrgId":"1111","name":"GARP"}}';
        }
        System.debug('resp:' + resp);      
        return resp;
    }
    
    public static mobiusRespWrapper mAddUser(Integer version, Integer GARPOrgId, mUser user){
        mAddUserReq req = new mAddUserReq();
        req.function = 'AddUser';
        req.version = version;
        req.GARPOrgId = GARPOrgId;
        req.user = user;
        String JSONString = JSON.serialize(req);
        mobiusRespWrapper resp = sendRequest(JSONString, req.function);
        System.debug('resp:' + resp);     
        return resp;
    }
    
    public static mobiusRespWrapper mModifyUser(Integer version, Integer GARPUserId, mUser user){
        mModifyUserReq req = new mModifyUserReq();
        req.function = 'ModifyUser';
        req.version = version;
        req.GARPUserId = GARPUserId;
        req.user = user;
        String JSONString = JSON.serialize(req);
        mobiusRespWrapper resp = sendRequest(JSONString, req.function);
        System.debug('resp:' + resp);    
        return resp;
    }
    
    @future (callout=true)
    public static void updateUserEmailAsync(Integer version, Integer GARPUserId, Id contactId, String email){
        
        mModifyUserReq req = new mModifyUserReq();
        
        req.function = 'ModifyUser';
        req.version = version;
        req.GARPUserId = GARPUserId;
        
        mUser user = new mUser();
        user.Email = email;
        
        req.user = user;
        
        mobiusRespWrapper resp = sendRequest(JSON.serialize(req), req.function);
        
        API_Transaction__c apiTrans = resp.apiTrans;
        apiTrans.Contact__c = contactId;
        
        INSERT apiTrans;
        
    }
    
    public static mobiusRespWrapper mGetUser(Integer version, Integer GARPUserId){
        mGetUserReq req = new mGetUserReq();
        req.function = 'GetUser';
        req.version = version;
        req.GARPUserId = GARPUserId;
        String JSONString = JSON.serialize(req);
        mobiusRespWrapper resp = sendRequest(JSONString, req.function);
        System.debug('resp:' + resp);     
        return resp;
    }
    
    public static mobiusRespWrapper mGetUserList(Integer version, Integer GARPOrgId){
        mGetUserListReq req = new mGetUserListReq();
        req.function = 'GetUserList';
        req.version = version;
        req.GARPOrgId = GARPOrgId;
        String JSONString = JSON.serialize(req);
        mobiusRespWrapper resp = sendRequest(JSONString, req.function);
        System.debug('resp:' + resp);     
        return resp;
    }
    
    public static mobiusRespWrapper mEnrollUser(Integer version, Integer GARPUserId, Integer product){
        mEnrollUserReq req = new mEnrollUserReq();
        req.function = 'EnrollUser';
        req.version = version;
        req.GARPUserId = GARPUserId;
        req.product = product;
        String JSONString = JSON.serialize(req);
        mobiusRespWrapper resp = sendRequest(JSONString, req.function);
        System.debug('resp:' + resp);      
        return resp;
    }
    
    public static mobiusRespWrapper mUnEnrollUser(Integer version, Integer GARPUserId, Integer product){
        mUnEnrollUserReq req = new mUnEnrollUserReq();
        req.function = 'UnEnrollUser';
        req.version = version;
        req.GARPUserId = GARPUserId;
        req.product = product;
        String JSONString = JSON.serialize(req);
        mobiusRespWrapper resp = sendRequest(JSONString, req.function);
        System.debug('resp:' + resp);     
        return resp;
    }
    
    public static mobiusRespWrapper mGetProductList(Integer version){
        mGetProductListReq req = new mGetProductListReq();
        req.function = 'GetProductList';
        req.version = version;
        String JSONString = JSON.serialize(req);
        mobiusRespWrapper resp = sendRequest(JSONString, req.function);
        System.debug('resp:' + resp);        
        return resp;
    }
    
    public static mobiusRespWrapper mUserLogin(Integer version, String email, Integer context, Integer pageNumber){
        mUserLoginReq req = new mUserLoginReq();
        req.function = 'UserLogin';
        req.version = version;
        req.email = email;
        req.context = context;
        if(pageNumber != null)
            req.pageNumber = pageNumber;
        String JSONString = JSON.serialize(req);
        mobiusRespWrapper resp = sendRequest(JSONString, req.function);
        System.debug('resp:' + resp);    
        return resp;
    }
    
    @future(callout=true)
    public static void mUnProvisionAnEBook(Id opportunityId, Integer garpUserId, Set<Integer> productIds){
        
        List<API_Transaction__c> apiTransactions = new List<API_Transaction__c>();
        
        try{

            MobiusRespWrapper organizationRes = MGetOrganization(apiVersionGlobal, GARPOrgIdGlobal);
            
            apiTransactions.add(organizationRes.apiTrans);
            
            MGetOrganizationResp organization = (MGetOrganizationResp)JSON.deserialize(organizationRes.response, MGetOrganizationResp.class);
            
            if(organization != null && organization.status == 0 && organization.org != null && organization.org.GARPOrgId != null){
                
                Integer GARPOrgId = organization.org.GARPOrgId;
                
                MobiusRespWrapper userRes = mGetUser(apiVersionGlobal, GARPUserId);
                
                apiTransactions.add(userRes.apiTrans);
                
                MGetUserResp user = (MGetUserResp)JSON.deserialize(userRes.response, MGetUserResp.class);
                
                if(user != null && user.status == 1){
                    
                    apiTransactions.add(new API_Transaction__c(Error__c = 'Unable to locate user in Mobius with the given GARP User ID: ' + GARPUserId));
                    
                }else{
                
                    for(Integer productId: productIds){
                        MobiusRespWrapper unenrollRes = mUnEnrollUser(apiVersionGlobal, GARPUserId, productId);
                        apiTransactions.add(unenrollRes.apiTrans);
                        MEnrollUserResp unenroll = (MEnrollUserResp)JSON.deserialize(unenrollRes.response, MEnrollUserResp.class);
                    }
                    
                    eBook_Key__c eBookKey = [SELECT Id, Opportunity__c, Cancelled__c FROM eBook_Key__c WHERE Opportunity__c = :opportunityId LIMIT 1];
                    
                    if(eBookKey == null){
                        apiTransactions.add(new API_Transaction__c(Error__c = 'There was no eBook Key associated with this opportunity.'));
                    }else{
                    
                        eBookKey.Cancelled__c = true;
                        
                        UPDATE eBookKey;
                        
                    }
                    
                }
                
            }
            
        }catch(Exception e){
            apiTransactions.add(new API_Transaction__c(Error__c = e.getMessage()));
        }
        
        for(API_Transaction__c apiTransaction: apiTransactions){
            apiTransaction.Opportunity__c = OpportunityId;
        }
        
        if(!apiTransactions.isEmpty()) INSERT apiTransactions;
        
    }
    
    public static void mProvisionAnEBookFromBatch(String exam, String part, String productId, Integer accessDuration, List<Integer> iProdList, String OppId, String email, String firstName, String lastName, String GARPUserId) {
        mProvisionAnEBookSync(exam, part, productId, accessDuration, iProdList, OppId, email, firstName, lastName, GARPUserId, false);
    }
    
    @future(callout=true)
    public static void mProvisionAnEBook(String exam, String part, String productId, Integer accessDuration, List<Integer> iProdList, String OppId, String email, String firstName, String lastName, String GARPUserId) {
        mProvisionAnEBookSync(exam, part, productId, accessDuration, iProdList, OppId, email, firstName, lastName, GARPUserId, false);
    }
    
    // Added Boolean saveLater as argument, changed return from void to List of book keys and transaction. 
    // Return value are only needed in batch. When saveLater is true, code need to insert eBook key and API logs after all callouts.
    public static List<List<SObject>> mProvisionAnEBookSync(String exam, String part, String productId, Integer accessDuration, List<Integer> iProdList, String OppId, String email, String firstName, String lastName, String GARPUserId, Boolean saveLater) {
        List<List<SObject>> returnList = new List<List<SObject>>();
        List<eBook_Key__c> bookKeys = new List<eBook_Key__c>();
        List<API_Transaction__c> lstApiTrans = new List<API_Transaction__c>();
        
        try {
            String eBookType;
            if(part != Null) {
                eBookType = exam + ' Exam Part ' + part;
            } else {
                eBookType = exam;
            }
            Integer iGarpID = Integer.valueOf(GARPUserId);
            
            mobiusRespWrapper wGOResp = mGetOrganization(apiVersionGlobal, GARPOrgIdGlobal);
            System.debug('mGetOrganization:' + wGOResp);
            lstApiTrans.add(wGOResp.apiTrans);
            
            mGetOrganizationResp goResp = (mGetOrganizationResp)JSON.deserialize(wGOResp.response, mGetOrganizationResp.class);
            System.debug('goResp:' + goResp);     
            
            Integer retVal = goResp.status;
            
            if(retVal == 0 && goResp != null && goResp.org != null && goResp.org.GARPOrgId != null) {
                Integer GARPOrgId = goResp.org.GARPOrgId;
                mobiusRespWrapper wGUResp = mGetUser(apiVersionGlobal, iGarpID);
                System.debug('mGetUser:' + wGUResp);
                lstApiTrans.add(wGUResp.apiTrans);
                
                mGetUserResp guResp = (mGetUserResp)JSON.deserialize(wGUResp.response, mGetUserResp.class);
                System.debug('mrespX:' + guResp);        
                
                mUser setUser = new mUser();
                setUser.email = email;
                setUser.firstName = firstName;
                setUser.lastName = lastName;
                setUser.level = studentLevelGlobal;
                setUser.GARPUserId = iGarpID;
                
                Default_Settings__c mobiusPreventUserEnrollment = Default_Settings__c.getValues('MobiusPreventUserEnrollment');
                if(mobiusPreventUserEnrollment.Active__c == FALSE){
                    // User does not exist
                    if(guResp != null && guResp.status == 1) {
                        mobiusRespWrapper wAUResp = mAddUser(apiVersionGlobal, GARPOrgId, setUser);
                        lstApiTrans.add(wAUResp.apiTrans);
                        System.debug('mAddUser:' + wAUResp);
                        
                        mAddUserResp mauResp = (mAddUserResp)JSON.deserialize(wAUResp.response, mAddUserResp.class);
                        System.debug('mauResp:' + mauResp);     
                        retVal = mauResp.status;
                        
                    } 
    
                    retVal = 0;
                
                
                
                
                    for(Integer prod :iProdList) {
                        mobiusRespWrapper wEUResp = mEnrollUser(apiVersionGlobal, iGarpID, prod);
                        System.debug('mEnrollUser:' + wEUResp);
                        lstApiTrans.add(wEUResp.apiTrans);
                        
                        mEnrollUserResp meuResp = (mEnrollUserResp)JSON.deserialize(wEUResp.response, mEnrollUserResp.class);
                        System.debug('meuResp:' + meuResp); 
                        if(meuResp.status != 0)
                            retVal = meuResp.status;
                    }
                }
                
                if(retVal == 0) {
                    Date dt = Date.today();
                    dt = dt.addMonths(accessDuration);
                    eBook_Key__c ek = new eBook_Key__c();
                    ek.Opportunity__c = OppId;
                    ek.Member_EMail__c = email;
                    ek.Key__c = OppId + eBookType;
                    ek.Type__c = eBookType;
                    ek.Is_API__c = true;
                    ek.Access_Duration_in_Months__c = accessDuration;                    
                    ek.Access_Expiration_Date__c= dt;
                    ek.Product_ID__c = productId;
                    System.debug('Insert Key:' + ek);
                    if(!saveLater) {
                        insert ek;
                    }else {
                        bookKeys.add(ek);
                    }
                }
  
            }
            System.debug('lstApiTrans:' + lstApiTrans);
            if(lstApiTrans != null && lstApiTrans.size() > 0) {
                for(API_Transaction__c apiTrans :lstApiTrans)
                    apiTrans.Opportunity__c = OppId;
                
                if(!saveLater) insert lstApiTrans;
            }
        } catch(exception e) {
            System.debug('Exception:' + e);
            if(lstApiTrans != null && lstApiTrans.size() > 0) {
                for(API_Transaction__c apiTrans :lstApiTrans) {
                    apiTrans.Error__c = getExceptionDetail(e);
                    apiTrans.Opportunity__c = OppId;
                }
                
                if(!saveLater) insert lstApiTrans;
            }            
        }
        
        returnList.add(bookKeys);
        returnList.add(lstApiTrans);
        return returnList;
    }
    
}