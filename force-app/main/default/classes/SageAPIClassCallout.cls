@isTest
global class SageAPIClassCallout implements HttpCalloutMock{
        
    global HttpResponse respond(HttpRequest req){
        
        HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		res.setBody('<?xml version="1.0" encoding="UTF-8"?><testing>done!!</testing>');
		res.setStatusCode(200);
		return res;

	}	   
    
}