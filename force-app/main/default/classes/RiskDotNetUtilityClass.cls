public with sharing class RiskDotNetUtilityClass {
    
    // method for API callout 
    public static HttpResponse callEndpoint(Id contractId,Id contactId,String endPoint,String method,String ContentType,String reqBody) {
    HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(method);
        request.setHeader('content-type','application/json');
        system.debug('reqBody=========>'+reqBody);
        system.debug('request==========>'+request);
        if(!String.isEmpty(reqBody)){
            request.setBody(reqBody);
        }
        Http http = new Http();
        HttpResponse response = http.send(request);
        String result = response.getBody();
        System.debug('result======>'+result);
        system.debug('response=========>'+response);

        API_Transaction__c apiTransaction = new API_Transaction__c();   
        apiTransaction.Type__c = 'Risk.net';
        apiTransaction.Request_URL_Long_Text__c = endPoint;
        apiTransaction.Contract__c = contractId;
        apiTransaction.Contact__c = contactId;
        apiTransaction.Request_Body__c = reqBody;
        apiTransaction.Response_Code__c = String.ValueOf(response.getStatusCode());
        apiTransaction.Response_Body__c = response.getBody();
        INSERT apiTransaction;

        return response;
    }

    // class to create user
    @future (callout=true)
    public static void CreateUser(Id contractId, Id contactId, string activeStatus){
        system.debug('Entered RDN Utility class================>');
        String endPoint = System.Label.GARP_Webserver + '/sfdc/risknet/relay';
        //need to review --> String requestBody = RiskDotNetAPIBody.Body(contractId,contactId,activeStatus);
        String requestBody = 'RiskDotNetAPIBody.Body(contractId,contactId,activeStatus)'; 
        String ResponseText = '';
        Contract updateContract = new Contract();
        
        system.debug('After requestBody======>'+requestBody);
        HttpResponse objResponse = RiskDotNetUtilityClass.callEndpoint(contractId,contactId,endPoint, 'POST', 'application/json',requestBody);
        ResponseText = objResponse.getBody();
        system.debug('objResponse========>'+objResponse);
        system.debug('ResponseText========>'+ResponseText);
        // Collect response in a object
        //RiskDotNetJsonResponse jstatus = (RiskDotNetJsonResponse)JSON.deserialize(ResponseText, RiskDotNetJsonResponse.class);
        //system.debug('jstatus.status========>'+jstatus.status);
        if(objResponse.getStatusCode() == 200) {
            updateContract.Id = contractId ;
            updateContract.API_Transaction_Status__c = 'Success';
            updateContract.Re_try__c = false;
            UPDATE updateContract;
        //} else if(objResponse.getStatusCode() == 200 && jstatus.status != 'ok') {
        //    updateContract.Id = contractId ;
        //    updateContract.API_Transaction_Status__c = 'Failure';
        //    updateContract.Re_try__c = false;
        //    UPDATE updateContract;
        } else {
            updateContract.Id = contractId ;
            updateContract.API_Transaction_Status__c = 'Failure';
            updateContract.Re_try__c = false;
            UPDATE updateContract;
        }
    }
}