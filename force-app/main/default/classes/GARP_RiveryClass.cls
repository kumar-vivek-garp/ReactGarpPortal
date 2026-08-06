public class GARP_RiveryClass {

    public class runRiverRequest{
        public string river_id;
    }
    
    public static GARP_Common.apiReturnInfo sendRequest(String sendJSON) {
        String endPoint;
        String authToken;
        GARP_Common.apiReturnInfo ret = new GARP_Common.apiReturnInfo();
        
        Map<String, GARP_API_Settings__c> settings = GARP_API_Settings__c.getAll();
        GARP_API_Settings__c apiSetting;
        if(!settings.IsEmpty()) {
            apiSetting = settings.get('Rivery');
            GARP_Common.debugLog('GARP_RiveryClass','sendRequet','Rivery apiSetting',apiSetting);
        }
        
        if(apiSetting != NULL && apiSetting.EndPoint__c != NULL && apiSetting.AuthToken__c != NULL && sendJSON != NULL && sendJSON.length() > 0) {
            endPoint = apiSetting.EndPoint__c;
            authToken = apiSetting.AuthToken__c;
            if(apiSetting.AuthToken2__c!= NULL) {
                authToken+=apiSetting.AuthToken2__c;
            }
        } else {
            return null;
        }
        GARP_Common.debugLog('GARP_RiveryClass','sendRequet','endPoint',endPoint);
        GARP_Common.debugLog('GARP_RiveryClass','sendRequet','authToken',authToken);
        GARP_Common.debugLog('GARP_RiveryClass','sendRequet','sendJSON',sendJSON);
        
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
                
        request.setEndPoint(endPoint);
        request.setHeader('Authorization','Bearer '+authToken);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');        
        request.setBody(sendJSON);
        
        HttpResponse response;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            ret.statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            ret.statusCode = 200;
        }        
        GARP_Common.debugLog('GARP_RiveryClass','sendRequet','statusCode',ret.statusCode);
        
        if(ret.statusCode == 200) {
            if(!Test.isRunningTest()){
                ret.body = response.getBody();
            } else {
                ret.body = '{}';
            }            
            GARP_Common.debugLog('GARP_RiveryClass','sendRequet','body',ret.body);
        }
        return ret;
    }
    
    public static GARP_Common.apiReturnInfo runRiver(String riverID) {
        GARP_Common.apiReturnInfo ret;
        
        runRiverRequest requestRivery = new runRiverRequest();
        requestRivery.river_id = riverID;
        ret = sendRequest(JSON.serialize(requestRivery));
        GARP_Common.debugLog('GARP_RiveryClass','runRiver','ret',ret);
        
        return ret;
    }
    
}