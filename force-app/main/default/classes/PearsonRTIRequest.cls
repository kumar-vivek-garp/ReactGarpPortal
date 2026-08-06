public class PearsonRTIRequest {
    private static final String xmlvertion = '<?xml version="1.0" encoding="UTF-8"?>'; 
   /* public String pingServiceRequestXML(){
        string xmlstring=xmlvertion; 
        xmlstring += '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:sch="http://ws.pearsonvue.com/ping/schema">'+
            '<soapenv:Header/>'+
            '<soapenv:Body>'+
            '<sch:pingServiceRequest/>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
        return xmlstring;
    }*/
    
    public String  pingdatabaseRequestXML(requestWrapper req){
       
       system.debug('&&&&&:'+req);
       
        string xmlstring=xmlvertion;  
        xmlstring += '<soapenv:Envelope xmlns:sch="http://ws.pearsonvue.com/ping/schema" xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'+
            '<soapenv:Header>'+
            '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'+
            '<wsse:UsernameToken wsu:Id="UsernameToken-28678335" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
            '<wsse:Username>'+req.Username+'</wsse:Username>'+
            '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+req.Password+'</wsse:Password>'+
            '</wsse:UsernameToken>'+
            '</wsse:Security>'+
            '</soapenv:Header>'+
            '<soapenv:Body>'+
            '<sch:pingDatabaseRequest/>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
        return xmlstring;
    }
    
    public String CDDserviceRequestXML(requestWrapper req){ 
    
      system.debug('&&&&&:'+req);
      
        string xmlstring = xmlvertion; 
        xmlstring += '<soapenv:Envelope xmlns:sch="http://ws.pearsonvue.com/rti/cdd/schema" xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'+
            '<soapenv:Header>'+
            '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'+
            '<wsse:UsernameToken wsu:Id="UsernameToken-42A48ED8C2EC4C5E3C15819486315961" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
            '<wsse:Username>'+req.Username+'</wsse:Username>'+
            '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+req.Password+'</wsse:Password>'+
            '</wsse:UsernameToken>'+
            '</wsse:Security>'+
            '</soapenv:Header>'+ 
            '<soapenv:Body>'+
            '<sch:cddRequest  clientCandidateID="'+getsizeLimitCharacters(req.integrationData.Garp_Id__c,50)+'" clientID="'+req.clientID+'">'+
            '<candidateName>'+
            '<firstName>'+getsizeLimitCharacters(req.integrationData.First_Name__c,30)+'</firstName>'+
            '<lastName>'+getsizeLimitCharacters(req.integrationData.Last_Name__c,50)+'</lastName>'+
            '<middleName>'+getsizeLimitCharacters(req.integrationData.Middle_Name__c,30)+'</middleName>'+
            '</candidateName>'+
            '<webAccountInfo>'+
            '<email>'+getsizeLimitCharacters(req.integrationData.Email__c,255)+'</email>'+
            '</webAccountInfo>'+
            '<lastUpdate>'+datetimeGMT(req.integrationData.Last_updated_Time__c)+'</lastUpdate>'+
            '<primaryAddress>'+
            '<addressType>'+req.integrationData.Address_Type__c+'</addressType>'+
            '<companyName>'+req.companyName+'</companyName>'+
            '<address1>'+getsizeLimitCharacters(req.integrationData.Address_1__c,40)+'</address1>'+
            '<address2>'+getsizeLimitCharacters(req.integrationData.Address_2__c,40)+'</address2>'+
            '<city>'+getsizeLimitCharacters(req.integrationData.city__c,32)+'</city>'+
            '<state>'+getsizeLimitCharacters(req.integrationData.state__c,50)+'</state>'+
            '<postalCode>'+getsizeLimitCharacters(req.integrationData.Postal_Code__c,16)+'</postalCode>'+
            '<country>'+getsizeLimitCharacters(req.integrationData.country__c,3)+'</country>'+
            '<phone>'+
            '<phoneNumber>'+getsizeLimitCharacters(req.integrationData.phone_Number__c,20)+'</phoneNumber>'+
            '<phoneCountryCode>'+req.integrationData.Phone_Country_Code__c+'</phoneCountryCode>'+
            '</phone>'+
            '</primaryAddress>'+
            '</sch:cddRequest>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
       /* xmlstring += '<soapenv:Envelope xmlns:sch="http://ws.pearsonvue.com/rti/cdd/schema" xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope"> <soapenv:Header> <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"> <wsse:UsernameToken wsu:Id="UsernameToken-42A48ED8C2EC4C5E3C15819486315961" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> <wsse:Username>wsvcgarpctt</wsse:Username> <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">C9Tsw#sO</wsse:Password> </wsse:UsernameToken> </wsse:Security> </soapenv:Header> <soapenv:Body> <sch:cddRequest  clientCandidateID="00001235" clientID="426"> <candidateName> <firstName>John</firstName> <lastName>Smith</lastName></candidateName> <webAccountInfo> <email>abc.test@abc13.com</email></webAccountInfo> <lastUpdate>2020/02/18 09:50:18 GMT</lastUpdate> <primaryAddress> <addressType>Work</addressType> <companyName>Pearson VUE</companyName><address1>5601 Green Valley Drive</address1> <address2>Suite 220</address2> <city>Bloomington</city> <state>MN</state> <postalCode>55437</postalCode> <country>USA</country>  <phone> <phoneNumber>9526813000</phoneNumber> <phoneCountryCode>1</phoneCountryCode> </phone></primaryAddress></sch:cddRequest> </soapenv:Body> </soapenv:Envelope>';
        */        
        return xmlstring;
    }
    
    public String EADserviceRequestXML(requestWrapper req){
    
     system.debug('&&&&&:'+req);
        String authType ='';
        if(req.integrationData.Exam_Registrations__r.Second_Attempt_Pearson__c == true){
            authType = 'Update';
        }else{
            authType = req.integrationData.Authorization_Type__c;
        }
        string xmlstring = xmlvertion;
        xmlstring += '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:sch="http://ws.pearsonvue.com/rti/ead/schema">'+
            '<soapenv:Header>'+
            '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'+
            '<wsse:UsernameToken wsu:Id="UsernameToken-'+req.integrationData.Pearson_Vue_Candidate_ID__c+'" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
            '<wsse:Username>'+req.username+'</wsse:Username>'+
            '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+req.password+'</wsse:Password>'+
            '</wsse:UsernameToken>'+
            '</wsse:Security>'+
            '</soapenv:Header>'+
            '<soapenv:Body>';  
            if(req.integrationData.Pearson_Vue_Authorization_ID__c != null && req.integrationData.Pearson_Vue_Authorization_ID__c != ''){
                xmlstring += '<sch:eadRequest clientID="'+req.clientID+'" authorizationTransactionType="'+authType+'" authorizationID="'+integer.valueOf(req.integrationData.Pearson_Vue_Authorization_ID__c)+'">';
            }else{
                xmlstring += '<sch:eadRequest clientID="'+req.clientID+'" authorizationTransactionType="'+authType+'">';
            }        
            xmlstring += '<clientCandidateID>'+getsizeLimitCharacters(req.integrationData.Garp_Id__c,50)+'</clientCandidateID>';
            if(req.integrationData.Exam_Registrations__r.Second_Attempt_Pearson__c == true){
                xmlstring += '<examAuthorizationCount>2</examAuthorizationCount>';
            }else{
                xmlstring += '<examAuthorizationCount>1</examAuthorizationCount>';
            }
            xmlstring += '<examSeriesCode>'+req.examSeriesCode+'</examSeriesCode>'+
            '<eligibilityApptDateFirst>'+req.integrationData.eligibilityApptDateFirst__c+'</eligibilityApptDateFirst>'+
            '<eligibilityApptDateLast>'+req.integrationData.eligibilityApptDateLast__c+'</eligibilityApptDateLast>'+
            '<lastUpdate>'+datetimeGMT(req.integrationData.Last_updated_Time__c)+'</lastUpdate>';
              if(req.accommodationCode != null && req.accommodationCode != '')
              xmlstring +='<clientAccommodations> <clientAccommodation accommodationCode="'+req.accommodationCode+'"/></clientAccommodations>';
             xmlstring +='</sch:eadRequest>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>'; 
        /*xmlstring += '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:sch="http://ws.pearsonvue.com/rti/ead/schema"> <soapenv:Header> <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"> <wsse:UsernameToken wsu:Id="UsernameToken-26398355" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> <wsse:Username>wsvcgarpctt</wsse:Username> <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">C9Tsw#sO</wsse:Password> </wsse:UsernameToken> </wsse:Security> </soapenv:Header> <soapenv:Body> <sch:eadRequest clientID="426" authorizationTransactionType="Add"><clientCandidateID>00001235</clientCandidateID> <examAuthorizationCount>1</examAuthorizationCount> <examSeriesCode>SCR</examSeriesCode><eligibilityApptDateFirst>2020/11/18 09:50:18</eligibilityApptDateFirst> <eligibilityApptDateLast>2020/12/18 09:50:18</eligibilityApptDateLast> <lastUpdate>2020/02/18 09:50:18 GMT</lastUpdate> </sch:eadRequest> </soapenv:Body> </soapenv:Envelope>';*/
        return xmlstring;    
    }
    public class requestWrapper{
        public String Username;
        public String Password;
        public String companyName;
        public Integration_Data__c integrationData;
        public opportunity opp; 
        public Integer candidateID;
        public String clientCandidateID;
        public Integer clientID;
        public String ReminderPreference;
        public String ConfirmationPreference;
        public String LocalePreference;
        public String GRAD_PROGRAM;
        public Integer authorizationID;
        public String clientAuthorizationID;
        public String examSeriesCode;
        public String accommodationCode; 
        public requestWrapper(){
            opp = new Opportunity();
            integrationData = new Integration_Data__c();
        }
    }
    public string datetimeGMT(DateTime dt){
        String formatGmt = '';
        DateTime dttime = system.now();
        if(dt != null)
            formatGmt = dt.format('yyyy/MM/dd HH:mm:ss zz', 'Etc/GMT');
        else
            formatGmt = dttime.format('yyyy/MM/dd HH:mm:ss zz', 'Etc/GMT');
        return formatGmt;
    }
  
  public String getsizeLimitCharacters(String sizeString,Integer maxSize){ 
    if(sizeString != null){
      if(sizeString.length() > maxSize ){
        sizeString = sizeString.substring(0, maxSize);
      }  
    }
    return sizeString;
  }
}