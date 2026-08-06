@isTest
public class RiskDotNetMockHttpCallout implements HttpCalloutMock {
    private Integer reponseStatusCode;
    public RiskDotNetMockHttpCallout(Integer reponseStatusCode){
        this.reponseStatusCode = reponseStatusCode;
    }
    public HttpResponse respond(HttpRequest req) {
        // Create a fake response
        String endpoint = req.getEndpoint(); 
        system.debug('endpoint==============>'+endpoint);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"ok"}');
        res.setStatusCode(reponseStatusCode);
        return res; 
    }
}