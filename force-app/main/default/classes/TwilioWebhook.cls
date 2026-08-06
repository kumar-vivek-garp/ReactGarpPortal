@RestResource(urlMapping='/twilio/*')
global class TwilioWebhook {
    
    @HttpPost
    global static void webhook() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        
        //try{
            
            String rawJson;
            if(Test.isRunningTest()){
                rawJson = '[{"timestamp":1679059157,"sg_message_id":"U68TooorQ1eyGscMFru3wQ.filterdrecv-canary-bfd88b58f-m8l44-1-641467A8-60.0","sg_event_id":"Ym91bmNlLTQtMzI4OTc1NDUtVTY4VG9vb3JRMWV5R3NjTUZydTN3US0w","event":"bounce","email":"frmregmobilea@frmregmobilea.com","category":["a4y590000009A4ZAAU"]}]';
                res = new RestResponse();
            } else {
                rawJson = req.requestBody.toString();
            }
            System.debug('rawJson request:' + rawJson);
            
            List<TwilioClass.twilioEventData> events = (List<TwilioClass.twilioEventData>)JSON.deserialize(rawJson, List<TwilioClass.twilioEventData>.class);
            System.debug('events:' + events);
            
            MemberNotificationClass.processTwilioWebhook(events);
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Success');
            System.debug('Done!');
        /*
        } catch(Exception ex){
            System.debug('Error!' + ex.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(' Internal Server Error: '+ex.getMessage());
        }
		*/
    }
}