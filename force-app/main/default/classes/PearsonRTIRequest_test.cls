@isTest
global class PearsonRTIRequest_test  implements HttpCalloutMock {
 // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals(req.getEndpoint(), req.getEndpoint());
        System.assertEquals(req.getMethod(), req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse(); 
        String reqbody = '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:sch="http://ws.pearsonvue.com/ping/schema">'+
            '<soapenv:Header/> <soapenv:Body> <sch:pingResponse>  <result status="success" env="Prod" inProduction="true"/> </sch:pingResponse></soapenv:Body>'+
            '</soapenv:Envelope>';
        if(req.getEndpoint().endsWith('CDDService')){
            reqbody = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:vue="http://ws.pearsonvue.com">'+
                '<soap:Body><cdd:cddResponse xmlns:cdd="http://ws.pearsonvue.com/rti/cdd/schema" candidateID="204081880" clientCandidateID="01404084">'+
                '<status>Accepted</status><message/> <date>2020/03/10 04:55:48 GMT</date></cdd:cddResponse></soap:Body></soap:Envelope>'; 
        }
        res.setBody(reqbody);
        res.setStatusCode(200);
        return res;
    }
}