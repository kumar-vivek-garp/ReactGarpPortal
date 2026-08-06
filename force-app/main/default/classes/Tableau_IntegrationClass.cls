public class Tableau_IntegrationClass{ 
    public static List<API_Transaction__c> insertApiTransactions;
    public static Map<Id,Contact> updateContactGBIAnalyticsMap;
    public static String reqDataType; 
    public static void tableauIntegration(String usertype,Map<String,String> contractIdMap){
        insertApiTransactions = new List<API_Transaction__c>();
        updateContactGBIAnalyticsMap = new Map<Id,Contact>();
        reqDataType = usertype;
        try{ 
            Tableau_Integration__mdt tm = getTableauCongig(); 
           List<Contact> userList = [Select Id,Email,Name,AccountId From Contact Where AccountId In:contractIdMap.keySet()];
            clscredentials authcls = getAuthToken(tm,userList[0],contractIdMap);
            if(authcls != null && authcls.credentials != null && authcls.credentials.token != null){ 
                for(Contact user:userList){
                    try{ 
                        userinformation userinfo = new userinformation(); 
                        userinfo = getTableauUserInfo(user.Email,authcls,tm.Endpoint__c);  
                        if(usertype == 'CreateUser'){
                            if(userinfo != null && userinfo.users != null && userinfo.users.user == null){
                                userinfo usinfo = new userinfo(); 
                                usinfo.siteRole = 'Viewer';
                                usinfo.authSetting = 'SAML';
                                usinfo.name = user.Email; 
                                CreateTableauUser(usinfo,authcls,tm.Endpoint__c,user,contractIdMap);
                            }else{
                                Contact c = new Contact();
                                c.Id = user.Id;
                                c.GBI_Analytics_Participant__c = true;
                                updateContactGBIAnalyticsMap.put(c.Id,c);
                                API_Transaction__c apilog = addApiTransaction('Create Tableau User Exesting',null,null,JSON.serialize(userinfo.users.user),null,user,contractIdMap);
                                insertApiTransactions.add(apilog);
                            }
                        }else if(usertype == 'RemoveUser'){
                            if(userinfo != null && userinfo.users != null && userinfo.users.user != null && userinfo.users.user.size() >0){
                                cls_user us = userinfo.users.user[0];
                                if(us.id != null){
                                    RemoveTableauUser(us.id,authcls,tm.Endpoint__c,user,contractIdMap);
                                }
                            }else{
                                Contact c = new Contact();
                                c.Id = user.Id;
                                c.GBI_Analytics_Participant__c = false;
                                updateContactGBIAnalyticsMap.put(c.Id,c);
                                API_Transaction__c apilog = addApiTransaction('Remove Tableau No User',null,null,JSON.serialize(userinfo.users.user),null,user,contractIdMap);
                                insertApiTransactions.add(apilog);
                            }
                        }
                    } 
                    catch(Exception e){ 
                        API_Transaction__c apilog = addApiTransaction('Tableau Integration Error',string.join(contractIdMap.keySet(),','),e.getStackTraceString(),e.getMessage(),null,user,contractIdMap);
                        insertApiTransactions.add(apilog);
                    }
                }
                if(updateContactGBIAnalyticsMap.size() >0){
                    update updateContactGBIAnalyticsMap.values();
                }
            }
            
        }catch(Exception ex){ 
           API_Transaction__c apilog = addApiTransaction('Tableau Integration Error',string.join(contractIdMap.keySet(),','),ex.getStackTraceString(),ex.getMessage(),null,new Contact(),null);
            insertApiTransactions.add(apilog);
        }
        
        if(insertApiTransactions.size() > 0){
            insert insertApiTransactions;
        }
    }
     
    public static Tableau_Integration__mdt getTableauCongig(){
        Tableau_Integration__mdt tm = new Tableau_Integration__mdt();
        List<Tableau_Integration__mdt> ataMtd = [Select Id,Access_Token_Secret__c,Auth_Endpoint__c,Content_Url__c,Access_Token_Name__c,Endpoint__c from Tableau_Integration__mdt where DeveloperName ='Tableau_Authentication'];
        if(ataMtd.size() >0){
            tm = ataMtd[0];
        }
        return tm;
    }
      
    public static clscredentials getAuthToken(Tableau_Integration__mdt tm,Contact userobj,Map<String,String> contractIdMap){
        clscredentials tableau = new clscredentials();
        tableau.credentials = new cls_credentials();
        cls_credentials credentials = new cls_credentials();
        credentials.personalAccessTokenName = tm.Access_Token_Name__c;
        credentials.personalAccessTokenSecret = tm.Access_Token_Secret__c;
        credentials.site = new cls_site();
        cls_site site = new cls_site();
        site.contentUrl = tm.Content_Url__c; 
        credentials.site = site;
        clscredentials cld = new clscredentials();
        cld.credentials = credentials;
        String reqBody = JSON.serialize(cld,true); 
        HTTPResponse resp = new HTTPResponse();
        resp = httpCallout('POST',reqBody,tm.Auth_Endpoint__c,null); 
        if(resp.getStatusCode() == 200){
            tableau = (clscredentials) System.JSON.deserialize(resp.getBody(), clscredentials.class); 
        }else{
            API_Transaction__c apilog = addApiTransaction('Tableau Auth Error',reqBody,string.join(contractIdMap.keySet(),','),resp.getBody(),resp.getStatusCode()+'',userobj,contractIdMap);
            insertApiTransactions.add(apilog); 
        }
        return tableau;
    } 
    
     public static userinformation getTableauUserInfo(String username,clscredentials authcls,String tblendpoint){
         system.debug(authcls);
         userinformation userinfo = new userinformation(); 
         if(authcls != null && authcls.credentials.token != null){
             String endpoint = tblendpoint+'/'+authcls.credentials.site.id;
             if(username != null && username != ''){
                 endpoint += '/users?filter=name:eq:'+username+'&sort=name:asc';
             }
             HTTPResponse resp = new HTTPResponse();
             resp = httpCallout('GET',null,endpoint,authcls.credentials.token); 
             system.debug(resp.getBody());
             if(resp.getStatusCode() == 200){
                userinfo = (userinformation) System.JSON.deserialize(resp.getBody(), userinformation.class);  
             } 
         }
          return userinfo;
         
     }
	
	public static void CreateTableauUser(userinfo user,clscredentials authcls,String tblendpoint,Contact userobj,Map<String,String> contractIdMap){
         API_Transaction__c apilog = new API_Transaction__c(); 
         if(authcls != null && authcls.credentials.token != null){
             String endpoint = tblendpoint+'/'+authcls.credentials.site.id+'/users';
             userdata usinfo = new userdata();
             usinfo.user = user;
             String reqBody = JSON.serialize(usinfo,true); 
             system.debug(reqBody);
             HTTPResponse resp = new HTTPResponse();
             resp = httpCallout('POST',reqBody,endpoint,authcls.credentials.token); 
             system.debug(resp.getBody()); 
             if(resp.getStatusCode() == 201){
                 Contact c = new Contact();
                 c.Id = userobj.Id;
                 c.GBI_Analytics_Participant__c = true;
                 updateContactGBIAnalyticsMap.put(c.Id,c);
             }
             apilog = addApiTransaction('Create Tableau User',null,reqBody, resp.getBody(),resp.getStatusCode()+'',userobj,contractIdMap);
             insertApiTransactions.add(apilog);
         } 
     }
	/*//Not using
	public static userinfo UpdateTableauUser(userinfo user,String userId,clscredentials authcls,String tblendpoint){
        userinfo userdt = new userinfo();
 
         if(authcls != null && authcls.credentials.token != null){
             String endpoint = tblendpoint+'/'+authcls.credentials.site.id+'/users/'+userId;
             userdata usinfo = new userdata();
             usinfo.user = user;
             String reqBody = JSON.serialize(usinfo,true); 
             system.debug(reqBody);
             HTTPResponse resp = new HTTPResponse();
             resp = httpCallout('PUT',reqBody,endpoint,authcls.credentials.token); 
             system.debug(resp.getBody());
             if(resp.getStatusCode() == 200){
                userdt = (userinfo) System.JSON.deserialize(resp.getBody(), userinfo.class); 
                 system.debug(JSON.serialize(userdt));
             }else{
                 //create log
             }
         }
        return userdt; 
         
     } */
    
    public static void RemoveTableauUser(String userId,clscredentials authcls,String tblendpoint,Contact userobj,Map<String,String> contractIdMap){
        API_Transaction__c apilog = new API_Transaction__c(); 
         if(authcls != null && authcls.credentials.token != null){
             String endpoint = tblendpoint+'/'+authcls.credentials.site.id+'/users/'+userId; 
             HTTPResponse resp = new HTTPResponse();
             resp = httpCallout('DELETE',null,endpoint,authcls.credentials.token); 
             system.debug(resp.getBody());
             system.debug(resp.getStatusCode());  
             if(resp.getStatusCode() == 204){
                 Contact c = new Contact();
                 c.Id = userobj.Id;
                 c.GBI_Analytics_Participant__c = false;
                 updateContactGBIAnalyticsMap.put(c.Id,c);
             }
             apilog = addApiTransaction('Remove Tableau User',null,userId, resp.getBody(),resp.getStatusCode()+'',userobj,contractIdMap);
             insertApiTransactions.add(apilog);
         } 
     }
    
    public static API_Transaction__c addApiTransaction(String description,String req, String reqBody, String resp, String respCode,Contact user,Map<String,String> contractIdMap) {
        API_Transaction__c api = new API_Transaction__c(Description__c=description, 
                                                        Type__c='Tableau', 
                                                        Request__c=limitSize(req,255), 
                                                        Body__c=reqBody, 
                                                        Response__c=limitSize(resp,255), 
                                                        Response_Code__c=respCode, 
                                                        Name=user.Name+' Tableau '+reqDataType,
                                                        Contact__c=user.Id,
                                                        Account__c=user.AccountId,
                                                        Contract__c = contractIdMap != null && contractIdMap.containsKey(user.AccountId)?contractIdMap.get(user.AccountId):null
                                                        );
        return api;
    }
    
    public static String limitSize(String inStr, Integer maxSize) {
        if(inStr != null) {
            if(inStr.length() > maxSize)
                return inStr.substring(0, maxSize);
            else return inStr;
        }
        return inStr;
    }
    
    
    public static HTTPResponse httpCallout(String reqType,String reqBody,String endpoint,String authToken){
        HTTPResponse res = new HTTPResponse();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint); 
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        if(authToken != null){
            req.setHeader('X-Tableau-Auth',authToken);  
        }
        req.setMethod(reqType);
        if(reqBody != null)
        req.setBody(reqBody);
        Http http = new Http(); 
        res = http.send(req);
        return res;
    } 
    
    
    public class clscredentials{
        public cls_credentials credentials;
    }
    
    public class cls_credentials {
        public String personalAccessTokenName; 
        public String personalAccessTokenSecret;
        public cls_site site; 
        public cls_user user;
        public String token;	 
        public String estimatedTimeToExpiration;
    }
    public class cls_site {
        public String id;	
        public String contentUrl;
    }
    
    public class cls_user {
        public String id;	
        public cls_domain domain;
		public String authSetting;	 
		public String email;	 
		public String externalAuthUserId;	 
		public String fullName;	  
		public String name; 
		public String siteRole;	 
		public String locale; 
		public String language;	
        
    } 
    
    public class userinformation{
        public cls_pagination pagination;
        public cls_users users;
    } 
	public class cls_pagination {
		public String pageNumber;	 
		public String pageSize; 
		public String totalAvailable; 
	}
	public class cls_users {
		public cls_user[] user;
	}
	 
	public class cls_domain {
		public String name;	 
	}
    
    
    public class userdata{
        public userinfo user; 
    } 
    public class userinfo {
        public String fullName;	 
        public String email;	 
        public String password;	 
        public String siteRole;	 
        public String authSetting; 
        public String identityPoolName;	 
        public String idpConfigurationId;
        public String name;
    }  
}