@isTest
global class ATA_ScheduleInterfaceClass_TestMock implements HttpCalloutMock {
	// HTTP Response
    global HTTPResponse respond(HTTPRequest req) { 
        string JsonString = '{"timestamp":"2020-10-13T11:59:55-04:00","sign_type":"SHA1","sign":"w5go0a5V0DEjvc2bnn4Adrx960cI0O1WFzrNhlfQLcEkhzfWTg8HYiBvEGoxIoLhhFcSSkuUW/Pd0ffWRDgnCMWb9tygyrQuP22Q==","biz_content":[{"status":2,"region_subject":[{"subject_name":"FRM Exam Part I","subject_code":"FRM01","region_name":"China, Beijing","region_code":"086001"}],"reg_time":"2020-10-13T11:59:52-04:00","reg_code":"1496386","pay_status":2,"name":"testuser","gender":null,"cert_type":"5","cert_id":"1496386","batch_no":"202009071"}],"app_id":"96e23938ab9611ea87080242ac110002","resp_msg": "SUCCESS"}';
        // Create a fake response
        HttpResponse res = new HttpResponse();
        req.setHeader('Token','testAccessToken');
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JsonString);
        res.setStatusCode(200);
        return res;
    }
}