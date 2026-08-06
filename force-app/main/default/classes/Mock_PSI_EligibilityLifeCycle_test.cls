@isTest
global class Mock_PSI_EligibilityLifeCycle_test implements HttpCalloutMock {
	// HTTP Response
    global HTTPResponse respond(HTTPRequest req) { 
        string JsonString = '{"test_code":"ERP1","schedule_start_date":null,"portion_codes":null,"eligibility_end_date":"2020-11-23","client_eligibility_id":"PSI-00000004","candidate":{"suffix":null,"special_accommodations":null,"school_code":"","province_state":"NJ","postal_code":"07086-5305","office_phone":"","middle_name":"","last_name":"kathi","home_phone":null,"first_name":"vivek","email":"1@testing.comweqweq","country":null,"city":"WEEHAWKEN","candidate_id":"1495692","address2":null,"address1":"WEEHAWKEN","additional_attributes":[{"value":"","key":""}]}}';
        // Create a fake response
        HttpResponse res = new HttpResponse();
        req.setHeader('Token','testAccessToken');
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JsonString);
        res.setStatusCode(200);
        return res;
    }
}