public class TwilioClass {

    public class twilioEventData {
        public String email;
        public Integer timestamp;
        //String smtp-id;
        public String event;
        public List<String> category;
        public String sg_event_id;
        public String sg_message_id;
    }

    public class retSendSMS {
        public API_Transaction__c apitrans;
    }

    public class reqSendSMS {
        public String toPhone;
        public String body;
    }

    public class twilioRespSendSMS {
        String body;
        String direction;
        //String from;
        String date_updated;
        String error_message;
        String to;
        String status;
        String sid;
        String error_code;
        String price_unit;
    }
    
    public class retSendEmail {
        public API_Transaction__c apitrans;
    }
    
    public class reqSendEmail {
        public String toAddress;
        public String fromAddress;
        public String subject;
        public String body;
        public Boolean isHTML;
        public String reference;
    }
    
    public class twilioEmailError {
        String message;
        String field;
        String help;
    }    
    
    public class twilioEmailErrors {
        List<twilioEmailError> errors;
    }
    
    public class twilioEmailContent {
        String type;
        String value;
    }    
    
    public class twilioEmailAddress {
        String email;
    }
    
    public class twilioPersonalization {
        List<twilioEmailAddress> to;
    }
    
    public class twilioSendEmail {
        List<twilioPersonalization> personalizations;
        twilioEmailAddress fromAddress;
        String subject;
        List<twilioEmailContent> content;
        List<String> categories;
    }
    
    public static retSendEmail sendEmail(reqSendEmail reqSendEmail) {
        retSendEmail ret = new retSendEmail();
        
        String apikey = Label.TwilioEmailAuthToken;
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://api.sendgrid.com/v3/mail/send';
        system.debug('endpoint:' + endpoint);
        
        request.setEndPoint(endpoint);
        request.setMethod('POST');        
        request.setHeader('content-type', 'application/json');
        request.setHeader('authorization', 'Bearer ' + apikey);
        
        twilioSendEmail tSendEmail = new twilioSendEmail();
        tSendEmail.personalizations = new List<twilioPersonalization>();
        
        twilioPersonalization tPerson = new twilioPersonalization();
        tPerson.to = new List<twilioEmailAddress>();
        
        twilioEmailAddress tEmailAddr = new twilioEmailAddress();
        tEmailAddr.email = reqSendEmail.toAddress;
        tPerson.to.add(tEmailAddr);
        
        tSendEmail.personalizations.add(tPerson);
        
        tSendEmail.fromAddress = new twilioEmailAddress();
        tSendEmail.fromAddress.email = reqSendEmail.fromAddress;
        
        tSendEmail.subject = reqSendEmail.subject;
        
        tSendEmail.content = new List<twilioEmailContent>();
        twilioEmailContent tEmailCont = new twilioEmailContent();
        tEmailCont.type = 'text/HTML';
        tEmailCont.value = reqSendEmail.body;
        tSendEmail.content.add(tEmailCont);
        if(reqSendEmail.reference != NULL) {
            tSendEmail.categories = new List<String>();
            tSendEmail.categories.add(reqSendEmail.reference);
        }
        
        String jsonBody = JSON.serialize(tSendEmail);
        jsonBody = jsonBody.ReplaceAll('fromAddress','from');
        request.setBody(jsonBody);
        System.debug('jsonBody:' + jsonBody);
        
        // Create version to save to API Trans without HTML body
        tSendEmail.content = new List<twilioEmailContent>();
        tEmailCont = new twilioEmailContent();
        tEmailCont.type = 'text/HTML';
        tEmailCont.value = 'EMAIL BODY GOES HERE';
        tSendEmail.content.add(tEmailCont);
        
        String jsonBodyLog = JSON.serialize(tSendEmail);
        jsonBodyLog = jsonBodyLog.ReplaceAll('fromAddress','from');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 202;
        }
        system.debug('statusCode:' + String.valueOf(statusCode));
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"body":"Sent from your Twilio trial account - Hello There!","num_segments":"1","direction":"outbound-api","from":"+18776790934","date_updated":"Thu, 16 Mar 2023 14:34:01 +0000","price":null,"error_message":null,"uri":"/2010-04-01/Accounts/AC89f23919bfc4da30805a564595958298/Messages/SM17345885a9b280ddad1fb2d3f0c8b30b.json","account_sid":"AC89f23919bfc4da30805a564595958298","num_media":"0","to":"+19175867035","date_created":"Thu, 16 Mar 2023 14:34:01 +0000","status":"queued","sid":"SM17345885a9b280ddad1fb2d3f0c8b30b","date_sent":null,"messaging_service_sid":null,"error_code":null,"price_unit":"USD","api_version":"2010-04-01","subresource_uris":{"media":"/2010-04-01/Accounts/AC89f23919bfc4da30805a564595958298/Messages/SM17345885a9b280ddad1fb2d3f0c8b30b/Media.json"}}';
        }
        System.debug('body rep:' + respbody);
        
        ret.apitrans = new API_Transaction__c (
            Type__c = 'Twillio',
            Email__c = reqSendEmail.toAddress,
            Response_Body__c = respbody,
            Request_URL_Long_Text__c = endpoint,
            Request_Body__c = jsonBodyLog.left(32767),
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        if(respbody.indexOf('errors') > -1) {
            twilioEmailErrors errs = (twilioEmailErrors)JSON.deserialize(respbody, twilioEmailErrors.class);
            if(errs != NULL && !errs.errors.IsEmpty()) {
                String erromsg = '';
                ret.apitrans.Error__c = errs.errors[0].message;
            }
        }
        
        System.debug('ret.apitrans:' + ret.apitrans);
        
        return ret;
    }
    
   
    public static retSendSMS sendSMS(reqSendSMS reqSendSMS) {
        retSendSMS ret = new retSendSMS();
        
        String accountId = Label.TwilioAccountID;
        if(accountId == NULL) {
            accountId = '123';
        }
        String apikey = Label.TwilioAuthToken;
        if(apikey == NULL) {
            apikey = '123';
        }
        String fromPhone = Label.TwilioPhoneNumber;
        if(fromPhone == NULL) {
            fromPhone = '123';
        }
        
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://api.twilio.com/2010-04-01/Accounts/' + accountId + '/Messages.json';
        system.debug('endpoint:' + apikey);
        
        request.setEndPoint(endpoint);
        request.setMethod('POST'); 
                
        Blob headerValue = Blob.valueOf(accountId + ':' + apikey);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String payload = 'From='+EncodingUtil.urlEncode(fromPhone,'UTF-8')+'&To='+EncodingUtil.urlEncode(reqSendSMS.toPhone,'UTF-8')+'&Body='+EncodingUtil.urlEncode(reqSendSMS.body,'UTF-8');
        System.debug(payload);
        
        request.setBody(payload);
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 202;
        }
        system.debug('statusCode:' + String.valueOf(statusCode));
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{}';
        }
        System.debug('body rep:' + respbody);
        
        ret.apitrans = new API_Transaction__c (
            Type__c = 'Twillio',
            Email__c = reqSendSMS.toPhone,
            Response_Body__c = respbody,
            Request_URL_Long_Text__c = endpoint,
            Request_Body__c = payload.left(32767),
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        if(respbody.indexOf('errors') > -1) {
            twilioRespSendSMS resp = (twilioRespSendSMS)JSON.deserialize(respbody, twilioRespSendSMS.class);
            if(resp != NULL && !String.isEmpty(resp.error_message)) {
                ret.apitrans.Error__c = resp.error_message;
            }
        }
        
        System.debug('ret.apitrans:' + ret.apitrans);
        
        return ret;
    }
}