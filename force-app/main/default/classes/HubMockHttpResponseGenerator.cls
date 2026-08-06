@isTest
global class HubMockHttpResponseGenerator implements HttpCalloutMock {
    
    private Integer reponseStatusCode;
    
    global HubMockHttpResponseGenerator(Integer reponseStatusCode){
        this.reponseStatusCode = reponseStatusCode;
    }
    
    
    global HTTPResponse Respond(HTTPRequest req) {
        
        //System.assertEquals('https://console.rivery.io/api/run', req.getEndpoint());
       
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"example":"test"}');
        response.setStatusCode(reponseStatusCode);
        return response;
        
    }

}