@isTest
private class ShipEdgeUpdateOppWebService_Test { 
    
    
    @isTest static void test_doPatch(){

		Account acc=new Account(name='Test');
        insert acc;
       
        
		Opportunity Opp=new Opportunity(Name = 'Test',stageName = 'New Lead',Ship_Edge_Order_Id__c='11937', CloseDate = Date.today(),accountid=acc.id);
		insert opp;
		id recordId=opp.id;
		
        webHookRequestWrapper reqWrapper = new webHookRequestWrapper();
        webHookRequestWrapper.cls_order order = new webHookRequestWrapper.cls_order();
        order.id = '11937';
        order.tracking_number = 'testtrack';
        reqWrapper.order = order;
        
		RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        
        request.requestUri = '/shipEdge';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(json.serialize(reqWrapper));
        
        RestContext.request = request;
        RestContext.response= res;
        
        test.starttest();
		ShipEdgeUpdateOppWebService.doPatch();
        test.stopTest();
		//System.assert(SucOrErr == 'Success');
	}
}