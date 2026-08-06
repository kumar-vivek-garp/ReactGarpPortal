public class on24API {
    static string APIURL ='https://event.on24.com/utilApp/r?';
    static string sessionId ='1';
    static string key;
    static string firstName = '';
    static string lastName = '';
    static string company ='';
    static String TransactionType = 'on24';
    static string email;
    static string jobTitle;
    static string address;
    static string city;
    static string state;
    static string zipcode;
    static string country;
    static string ERP;
    static string FRM;
    static string companyType;
    static contact relevantContact ;
    static user relevantUser ;
    static  Lead relevantLead ;
    
    public static Boolean RiskRecursive = true;
    
    public static void manageAccessOnContract(List<Contract> newContracts, Map<Id, Contract> oldContracts) {
        RiskRecursive = false;
        String memberId = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership');
        System.Debug('memberId:' + memberId);
        
        
        for(Contract con: newContracts) {
            System.Debug('con:' + con);
                
            Contract beforeUpdate = oldContracts.get(con.Id);
            System.Debug('beforeUpdate :' + beforeUpdate );
                
            if((beforeUpdate.Member_Email__c != con.Member_Email__c || beforeUpdate.Status != con.Status) 
                && con.RecordTypeId == memberId
            ){ 
                if(con.Status == 'Activated') {
                    createON24EngagementHubRegistration(con.CustomerSignedId);
                } 
                //if(con.Status == 'Canceled' || con.Status == 'Expired') {
                    //disableON24EngagementHubRegistration(con.CustomerSignedId);
                //}
            }
        }
    }
    
    @future(callout=true)
    public static void createON24EngagementHubRegistration(String Contactid) {
        
        List<Contact> lstContact = [select id, firstName, lastName, Company__c, email,
                                   title, MailingStreet, MailingCity, MailingState, MailingPostalCode,KPI_FRM_Certified__c,
                                   KPI_ERP_Certified__c, Area_of_Concentration__c,
                                   MailingCountry, Membership_Type__c, KPI_Membership_Payment_Status__c from Contact where id =:contactid];
        System.Debug('lstContact :' + lstContact );
         
        API_Transaction__c trans = new API_Transaction__c();
        if(lstContact != NULL &&  lstContact.size() > 0) {
            
            if(lstContact[0].Membership_Type__c != NULL && lstContact[0].Membership_Type__c == 'Individual' 
               && lstContact[0].KPI_Membership_Payment_Status__c != NULL && lstContact[0].KPI_Membership_Payment_Status__c == 'In Good Standing') {
                   
                   
                   String callURL = 'https://gateway.on24.com/wcc/autoreg';
                   
                   HttpResponse res;
                   String body = 'grant_type=password' +  
                       '&eventId=2960348&sessionid=1&key=67B583B1ACBD79DE9C7AC600CA57A098&updateIfExist=Y&isBlocked=N' +
                       '&email=' + lstContact[0].Email + '&firstname=' + lstContact[0].firstName + 
                       '&lastname=' + lstContact[0].lastName + '&company=' + lstContact[0].Company__c + 
                       '&jobTitle=' + lstContact[0].title + '&city=' + lstContact[0].MailingCity + 
                       '&state=' + lstContact[0].MailingState + '&zip=' + lstContact[0].MailingPostalCode + 
                       '&country=' + lstContact[0].MailingCountry + '&CompanyType=' + lstContact[0].Area_of_Concentration__c + 
                       '&std2=' + lstContact[0].KPI_FRM_Certified__c + '&std3=' + lstContact[0].KPI_ERP_Certified__c; 
                   if ( !Test.isRunningTest() ) {
                       HttpRequest req = new HttpRequest();      
                       req.setEndpoint(callURL);
                       req.setMethod('POST');
                       req.setHeader('content-type', 'application/x-www-form-urlencoded');
                       req.setBody(body);  
                       System.Debug('body :' + body);  
                       
                       Http h=new Http();
                       res = h.send(req);
                       system.debug('res == '+res);
                   } else {
                       res = new HttpResponse();
                       res.setStatusCode(200);
                       res.setBody('{"firstname":"David","lastname":"HasselHoff","company":"HasselHoff Inc"}');
                   }
                   
                   trans.Type__c = 'on24';            
                   trans.Contact__c = Contactid;  
                   trans.Request__c = callURL;
                   trans.Body__c = body;
                   trans.Response_Code__c = String.valueOf(res.getStatusCode());
                   String respBody = res.getBody();
                   if(respBody.length() > 255) {
                       respBody = respBody.substring(0,254);
                   }
                   trans.Response__c = respBody;
                   insert trans;
               }
        }
    }    

    public static String createON24EngagementHubRegistrationForEmployee(String Userid){
        system.debug('Enetered On24API with Userid ====>'+Userid);
        List<User> lstUser = [select id,Name,Email,Title,CompanyName,Profile.UserLicense.Name,Access_On24__c from User where id =:Userid];
        System.Debug('lstUser :' + lstUser );
        
        API_Transaction__c trans = new API_Transaction__c();
        if(lstUser != NULL &&  lstUser.size() > 0) {
            
            if(lstUser[0].Profile.UserLicense.Name == 'Salesforce'){
                
                
                String callURL = 'https://gateway.on24.com/wcc/autoreg';
                
                HttpResponse res;
                String body = 'grant_type=password' +  
                    '&eventId=2960348&sessionid=1&key=67B583B1ACBD79DE9C7AC600CA57A098&updateIfExist=Y&isBlocked=N' +
                    '&email=' + lstUser[0].Email + '&firstname=' + lstUser[0].Name + 
                    '&company=' + 'GARP'; 
                if ( !Test.isRunningTest() ) {
                    HttpRequest req = new HttpRequest();      
                    req.setEndpoint(callURL);
                    req.setMethod('POST');
                    req.setHeader('content-type', 'application/x-www-form-urlencoded');
                    req.setBody(body);  
                    System.Debug('body :' + body);  
                    
                    Http h=new Http();
                    res = h.send(req);
                    system.debug('res == '+res);
                } else {
                    res = new HttpResponse();
                    res.setStatusCode(200);
                    res.setBody('{"firstname":"David","lastname":"HasselHoff","company":"HasselHoff Inc"}');
                }
                
                trans.Type__c = 'on24';            
                trans.User__c = Userid;  
                trans.Request__c = callURL;
                trans.Body__c = body;
                trans.Response_Code__c = String.valueOf(res.getStatusCode());
                String respBody = res.getBody();
                if(respBody.length() > 255) {
                    respBody = respBody.substring(0,254);
                }
                trans.Response__c = respBody;
                insert trans;
                
            } 
        }
        return trans.Response_Code__c;
    }    

    /*
    @future(callout=true)
    public static void disableON24EngagementHubRegistration(String Contactid) {
        
        List<Contact> lstContact = [select id, firstName, lastName, Company__c, email,
                                   title, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                                   MailingCountry from Contact where id =:contactid];
        
        API_Transaction__c trans = new API_Transaction__c();
        if(lstContact != NULL &&  lstContact.size() > 0) {
            
            String callURL = 'https://gateway.on24.com/wcc/autoreg';
            
            HttpResponse res;
            String body = 'grant_type=password' +  
                    '&eventId=2960348&sessionid=1&key=67B583B1ACBD79DE9C7AC600CA57A098&updateIfExist=Y&isBlocked=Y' +
                    '&email=' + lstContact[0].Email;
            if ( !Test.isRunningTest() ) {
                HttpRequest req = new HttpRequest();      
                req.setEndpoint(callURL);
                req.setMethod('POST');
                req.setHeader('content-type', 'application/x-www-form-urlencoded');
                req.setBody(body);    
                System.Debug('body :' + body);                  
                
                Http h=new Http();
                res = h.send(req);
                system.debug('res == '+res);
            } else {
                res = new HttpResponse();
                res.setStatusCode(200);
                res.setBody('{"firstname":"David","lastname":"HasselHoff","company":"HasselHoff Inc"}');
            }
            
            trans.Type__c = 'on24';            
            trans.Contact__c = Contactid;  
            trans.Request__c = callURL;
            trans.Body__c = body;
            trans.Response_Code__c = String.valueOf(res.getStatusCode());
            trans.Response__c = res.getBody();
            insert trans;
        }
    }    
    */

    public static API_Transaction__c createAPITransactionRecord(String registrationType, String RegistrationId, String Contactid, string eventID, String APIKey){
        API_Transaction__c trans = prepareAPITransactionRecord(registrationType, RegistrationId, Contactid, eventID, APIKey);
        if(trans != NULL) {
            insert trans;
        }
        return trans;
    }
    
    public static API_Transaction__c prepareAPITransactionRecord(String registrationType, String RegistrationId, String Contactid, string eventID, String APIKey){
        system.debug('Entered API Transaction');
        List<String> urlParameters = new list<String>();
        
        eventID ='eventid='+eventID;
        sessionId ='&sessionid='+sessionId;
        key = '&key=' + APIKey; 
        
        
        List<Contact> relevantContacts = [select id, firstName, lastName, Company__c, email,
                                          title, MailingStreet, MailingCity, MailingState, MailingPostalCode,KPI_FRM_Certified__c,
                                          KPI_ERP_Certified__c,MailingCountry, Area_of_Concentration__c from Contact where id =:contactid];
        
        if(relevantContacts != NULL && relevantContacts.size() > 0) {
            Contact relevantContact = relevantContacts[0];
            
            if(relevantContact.Area_of_Concentration__c != NULL) {
                companyType = 'companyType='+ relevantContact.Area_of_Concentration__c;
                urlParameters.add(companyType);
            }
            if(relevantContact.KPI_ERP_Certified__c != NULL) {
                ERP = 'std3='+ relevantContact.KPI_ERP_Certified__c;
                urlParameters.add(ERP);
            }
            if(relevantContact.KPI_FRM_Certified__c != NULL) {
                FRM = 'std2='+ relevantContact.KPI_FRM_Certified__c ;
                urlParameters.add(FRM);
            }
            if(relevantContact.firstName != null){
                firstName ='firstname=' + relevantContact.firstName;
                urlParameters.add(firstName);
            }
            if(relevantContact.lastname != null){
                lastName ='lastname=' + relevantContact.lastName;
                urlParameters.add(lastname);
            }
            if(relevantContact.email != null){
                email ='email=' + relevantContact.Email;
                urlParameters.add(email);    
            }
            if(relevantContact.company__c != null){
                company = 'company='+relevantContact.Company__c;
                urlParameters.add(company);
            }
            if(relevantContact.title != null){
                jobTitle ='job_title='+ relevantContact.Title;
                urlParameters.add(jobTitle);
            }
            if(relevantContact.MailingStreet != null){
                address ='address_street1=' + relevantContact.MailingStreet; 
                urlParameters.add(address);
            }
            if(relevantContact.MailingCity != null){
                city = 'city=' + relevantContact.mailingCity;
                urlParameters.add(city);
            }
            if(relevantContact.mailingState != null){
                state = 'state='+ relevantContact.mailingstate;
                urlParameters.add(state);
            }
            if(relevantContact.MailingPostalCode != null){
                zipcode ='zip='+relevantContact.MailingPostalCode;
                urlParameters.add(zipcode);
            }
            if(relevantContact.MailingCountry != null){
                country ='country='+relevantContact.MailingCountry;
                urlParameters.add(country);
            }
            
            String body = string.join(urlParameters,'&');
            
            String params = eventId + sessionId + key;
            params = params.replaceAll('[+]', '%20');//EncodingUtil.urlEncode(params, "UTF-8");
            
            String callURL = APIURL + params;
            
            API_Transaction__c trans = new API_Transaction__c();
            
            trans.Type__c = TransactionType;
            System.debug(TransactionType);
            trans.Contact__c = relevantContact.Id;  
            System.debug(relevantContact.Id);
            if(callURL.length() > 255) {
                callURL = callURL.substring(1, 255);
            }
            trans.Request__c = callURL;
            System.debug(callURL);
            if(registrationType == 'chaptermeeting') {
                trans.Chapter_Meeting_Registration__c = RegistrationId;
            } else if(registrationType == 'webcast') {
                trans.Webcast_Registration__c = RegistrationId;
            } else if(registrationType == 'event') {
                trans.Event_Registration__c = RegistrationId;
            }
            System.debug(RegistrationId);
            trans.body__c = body;
            System.debug(body);
            //insert trans;
            
            System.debug(trans.id);
            System.debug(trans);
            System.debug(trans.Request__c);
            return trans;
        } else {
            return null;
        }
        
    }
     
    
   /* public static API_Transaction__c createAPITransactionRecordForEmployee(String registrationType, String RegistrationId, String UserId, string eventID, String APIKey)
    {
        // EmployeeOn24, null, UserId, null, 
        system.debug('Entered API Transaction');
        List<String> urlParameters = new list<String>();
        
        eventID ='eventid='+eventID;
        sessionId ='&sessionid='+sessionId;
        key = '&key=' + APIKey; 

   
         relevantUser = [select id,Name,Email,Title,CompanyName,BMCServiceDesk__User_License__c,Access_On24__c from User where id =:Userid];

        
            companyType = 'companyType='+ 'Financial Risk';
            urlParameters.add(companyType);
        
            ERP = 'std3='+ 'false';
            urlParameters.add(ERP);
        
            FRM = 'std2='+ 'false';
            urlParameters.add(FRM);
        
            firstName ='firstname=' + relevantUser.Name;
            urlParameters.add(firstName);
        
        
            lastName ='lastname=' + relevantUser.Name;
            urlParameters.add(lastname);
        
            email ='email=' + relevantUser.Email;
            urlParameters.add(email);    
        
            company = 'company='+relevantUser.CompanyName;
            urlParameters.add(company);

            jobTitle ='job_title='+ relevantUser.Title;
            urlParameters.add(jobTitle);
        
            address ='address_street1=' + '111 Town Square Place'; 
            urlParameters.add(address);
        
            city = 'city=' + 'Jersey City';
            urlParameters.add(city);
        
            state = 'state='+ 'NewJersey';
            urlParameters.add(state);
        
            zipcode ='zip='+ '07310';
            urlParameters.add(zipcode);
        
            country ='country='+ 'United States';
            urlParameters.add(country);

        String body = string.join(urlParameters,'&');
        
        String params = eventId + sessionId + key;
        params = params.replaceAll('[+]', '%20');//EncodingUtil.urlEncode(params, "UTF-8");
        
        String callURL = APIURL + params;
        
        API_Transaction__c trans = new API_Transaction__c();
        
        trans.Type__c = TransactionType;
        System.debug(TransactionType);
        trans.User__c = relevantUser.Id;  
        System.debug(relevantUser.Id);
        trans.Request__c = callURL;
        System.debug(callURL);
        trans.body__c = body;
        System.debug(body);
        insert trans;
        
        System.debug(trans.id);
        System.debug(trans);
        System.debug(trans.Request__c);
        return trans;
    } */
    @future(callout=true)
    public static void SendRequest(String requestURL, String transID) {
        API_Transaction__c trans = [select Response__c, Request__c, body__c from API_Transaction__c where Id = :transID];
        if(trans != NULL) {
            trans = SendRequestSync(requestURL,trans);
            if(trans != NULL) {
                update trans;
            }
        }
    }
    
    public static API_Transaction__c SendRequestSync(String requestURL, API_Transaction__c trans) {
        system.debug('Entered SendRequest');
        //API_Transaction__c trans = [select Response__c, Request__c, body__c from API_Transaction__c where Id = :transID];
        if(trans != null) {
            try {

                HttpResponse res;
                if ( !Test.isRunningTest() ) {
                    HttpRequest req = new HttpRequest();      
                    system.debug('requestURL:' + trans.Request__c);
                    req.setEndpoint(trans.Request__c);
                    req.setMethod('POST');
                    req.setHeader('content-type', 'application/x-www-form-urlencoded');
                    req.setBody(trans.body__c);
                    Http h=new Http();
                    res = h.send(req);
                    system.debug('res == '+res);
                } else {
                    res = new HttpResponse();
                    res.setStatusCode(200);
                    res.setBody('{"firstname":"David","lastname":"HasselHoff","company":"HasselHoff Inc"}');
                }
                
                trans.Response_Code__c = String.valueof(res.getStatusCode());

                String resp = res.getBody();               
                trans.Response_Body__c = resp;

                //UPDATE trans;

            } catch(exception e) {
                String err = e.getMessage();
                if(err.length() > 255){
                    trans.Error__c = err.substring(0,255);
                } else {
                    trans.Error__c = err;
                }
                //UPDATE trans;
            }
        }
        return trans;
    }
}