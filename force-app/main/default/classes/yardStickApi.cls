public class yardStickApi {
    
    static string text;
    static string text1;
    static string text2;
    static string text3;
    static string text4;
    static opportunity opp;
    
    @future (callout=true)
    public static void CreateUserToken(String UserName,String OpptyId,String programid,string FirstName,string LastName){
        CreateUserTokenSync(UserName,OpptyId,programid,FirstName,LastName);
    }
    
    public static void CreateUserTokenSync(String UserName,String OpptyId,String programid,string FirstName,string LastName){
        opp = new Opportunity();
         opp.Id = OpptyId;
      try{
        
        List<YardStickURLSetting__mdt> YSUrl = [SELECT Id, DeveloperName, URL__c FROM YardStickURLSetting__mdt WHERE DeveloperName = 'Token_URL'];
        
        if(YSUrl.size() != 0 && YSUrl[0].URL__c != null){
            String Requesturl = YSUrl[0].URL__c+'&username='+UserName+'&returnformat=json';
            List<API_Transaction__c> ApiTransaction = new List<API_Transaction__c>();
            HttpResponse response = SendRequest(Requesturl);
            system.debug('==response.getBody()==In Create Token='+response.getBody());
            System.debug('STATUS:' + response.getStatus());
            System.debug('STATUS_CODE:' + response.getStatusCode());
            if(response.getStatusCode() == 200){
                JSONParser parser = JSON.createParser(response.getBody());
                System.JSONToken token;
                parser.nextToken(); 
                boolean userExist = false;
                while((token = parser.nextToken()) != null){
                    if ((parser.getCurrentToken() != JSONToken.FIELD_NAME)){
                        text = parser.getText();
                        system.debug('text'+text);
                        // this is to know if the user is acive or not.
                        if(text == 'Active'){
                            token=parser.nextToken();
                            text3=parser.getText();
                            if(text3=='0'){
                                userExist = true;                            
                            }    
                        }
                        // this is when it is a new user.
                        if(text == 'ERROR'){
                            token=parser.nextToken();
                            text3=parser.getText();
                            if(text3=='1'){
                                CreateUser(UserName,programid,FirstName,LastName);                            
                            }    
                        }
                        // this is when the user exist and is  active
                        if (text == 'USERID' && userExist==false) {
                            token=parser.nextToken();
                            text2=parser.getText();
                            system.debug('text2'+text2);
                            CreateGrant(text2,programid);                            
                        }
                        // this is when the user exist and is not active
                        if(text == 'USERID'&&userExist==true)  {
                            token=parser.nextToken();
                            text2=parser.getText();
                            system.debug('text2'+text2);
                            updateUser( UserName,text2, programid,FirstName,LastName);  
                        }
                    }                    
                }
                ApiTransaction = CreateAPITransaction(OpptyId,null,response.getBody(),String.valueOf(response.getStatusCode()));
            }   
            else{
                ApiTransaction = CreateAPITransaction(OpptyId,null,response.getBody(),String.valueOf(response.getStatusCode()));
            }
            if(ApiTransaction != null && ApiTransaction.size() > 0){
                Database.insert(ApiTransaction);
                system.debug('===ApiTransaction==='+ApiTransaction);
            }
        } 
        opp.Yardstick_Status__c ='Success'; 
        updateOpp();    
    }
    catch(exception e){
        opp.Yardstick_Status__c ='Failure'; 
        updateOpp();
    }
        
   }
    
    public static void CreateUser(String UserName,String programid,string FirstName,string LastName){
        List<YardStickURLSetting__mdt> YSUrl = [SELECT Id, DeveloperName, URL__c FROM YardStickURLSetting__mdt WHERE DeveloperName = 'CreateUser'];
        if(YSUrl != null && YSUrl[0].URL__c != null){
            Integer len = 10;
            Blob blobKey = crypto.generateAesKey(128);
            String key = EncodingUtil.convertToHex(blobKey);
            String pwd = key.substring(0,len);
            System.debug('************ '+pwd);
            String Requesturl = YSUrl[0].URL__c+'&username='+UserName+'&password='+pwd+'&FirstName='+FirstName+'&LastName='+LastName+'&Email='+UserName+'&returnformat=json';
            HttpResponse response = SendRequest(Requesturl);
            system.debug('==response.getBody()==In Create User='+response.getBody());
            System.debug('STATUS:' + response.getStatus());
            System.debug('STATUS_CODE:' + response.getStatusCode());        
            if(response.getStatusCode() == 200){
                JSONParser parser = JSON.createParser(response.getBody());
                System.JSONToken token;
                parser.nextToken(); 
                while((token = parser.nextToken()) != null){
                    if ((parser.getCurrentToken() != JSONToken.FIELD_NAME)){
                        text = parser.getText();
                        system.debug('text'+text);
                        
                        if (text == 'USERID') {
                            token=parser.nextToken();
                            text4=parser.getText();
                            system.debug('text4'+text4);  
                            CreateGrant(text4,programid);   
                            opp.Yardstick_pass__c = pwd;    
                            opp.Yardstick_Welcome_Email_Sent_Date__c = System.today(); 
                        }                                
                    }                            
                }          
            }
        }        
    }


    public static void updateUser(String UserName,String Userid,String programid,string FirstName,string LastName){
        List<YardStickURLSetting__mdt> YSUrl = [SELECT Id, DeveloperName, URL__c FROM YardStickURLSetting__mdt WHERE DeveloperName = 'updateUser'];
        if(YSUrl != null && YSUrl[0].URL__c != null){
            Integer len = 10;
            Blob blobKey = crypto.generateAesKey(128);
            String key = EncodingUtil.convertToHex(blobKey);
            String pwd = key.substring(0,len);
            System.debug('************ '+pwd);
            String Requesturl = YSUrl[0].URL__c+'&userid='+Userid+'&username='+UserName+'&password='+pwd+'&FirstName='+FirstName+'&LastName='+LastName+'&Email='+UserName+'&returnformat=json';
            HttpResponse response = SendRequest(Requesturl);
            system.debug('==response.getBody()==In Create User='+response.getBody());
            System.debug('STATUS:' + response.getStatus());
            System.debug('STATUS_CODE:' + response.getStatusCode());        
            if(response.getStatusCode() == 200){
                JSONParser parser = JSON.createParser(response.getBody());
                System.JSONToken token;
                parser.nextToken(); 
                while((token = parser.nextToken()) != null){
                    if ((parser.getCurrentToken() != JSONToken.FIELD_NAME)){
                        text = parser.getText();
                        system.debug('text'+text);
                        
                        if (text == 'USERID') {
                            token=parser.nextToken();
                            text4=parser.getText();
                            system.debug('text4'+text4);                         
                            CreateGrant(text4,programid);
                            opp.Yardstick_pass__c = pwd; 
                            opp.Yardstick_Welcome_Email_Sent_Date__c =System.today();                   
                        }                       
                    }                        
                }                            
            }          
        }
    }        
    

    
    public static void CreateGrant(String UserId,String programid){
        List<YardStickURLSetting__mdt> YSUrl = [SELECT Id, DeveloperName, URL__c FROM YardStickURLSetting__mdt WHERE DeveloperName = 'GrantProgram'];
        if(YSUrl != null && YSUrl[0].URL__c != null){
            String Requesturl = YSUrl[0].URL__c+'&userid='+UserId+'&programid='+programid+'&returnformat=json';
            HttpResponse response = SendRequest(Requesturl);
            system.debug('==response.getBody()==In Create Grant='+response.getBody());
            System.debug('STATUS:' + response.getStatus());
            System.debug('STATUS_CODE:' + response.getStatusCode());  
            opp.Yardstick_Granted_Date__c =System.today();       
           
        }
        
    }
    
    public static  List<API_Transaction__c> CreateAPITransaction(String OpptyId,String request,String Response,String Responsecode){
        List<API_Transaction__c> ApiTransaction = new List<API_Transaction__c>();
        API_Transaction__c rec = new API_Transaction__c();
        rec.Opportunity__c = OpptyId;
        rec.Request__c = request;
    
       if( String.valueof(Response).Length()>=255){
        system.debug('######:'+String.valueof(Response).Length()) ;
        rec.Response__c = String.valueof(Response).substring(0, 255);}
         
        if( String.valueof(Response).Length()<=255){
        system.debug('######:'+String.valueof(Response).Length()) ;
        rec.Response__c = Response;}
        rec.Response_Code__c = Responsecode;
        ApiTransaction.add(rec);
        return ApiTransaction;
    }
    
    public static HttpResponse SendRequest(String Requesturl){
        HttpRequest req = new HttpRequest();        
        req.setEndpoint(Requesturl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody('Body');
        system.debug('%%%%:'+req);
        HttpResponse response = new Http().send(req);
        return response;
    }
    
     public Static Void updateOpp(){
        If(opp.Id!=null){
            update opp;
        }
    }
}