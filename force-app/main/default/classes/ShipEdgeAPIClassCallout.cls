@isTest
global class ShipEdgeAPIClassCallout implements HttpCalloutMock{
    String jsonString = null;
	
    global ShipEdgeAPIClassCallout(String jsonString){
        this.jsonString = jsonString;
    }
    
    global HttpResponse respond(HttpRequest req){
        
        HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(jsonString);
		res.setStatusCode(200);
		return res;

	}	   
    
}