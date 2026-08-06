@isTest
public class SearchDirectoryWebServiceTest {
    @isTest
    static void testSearchDirectoryWebService(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/SearchDirectory'; 
        req.headers.put('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.headers.put('Garp-Token','khgIVBU^RTI&6rI&KUTGib6t');
        String jsonBody = '{"searchText":"test","industries":"","jobFunctions":"","riskSpecialties":"","corporateTitles":"","company":"","pageSize":5,"pageCurrent":1,"sortField":"Name"}';
        req.requestBody = Blob.valueOf(jsonBody);
        Test.startTest(); 
            RestContext.request = req;
            RestContext.response = res;
            SearchDirectoryWebService.doPost();
        Test.stopTest(); 
    }
    @isTest
    static void ErrorSearchDirectoryWebService(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/SearchDirectory'; 
        req.headers.put('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.headers.put('Garp-Token','testdata');
        String jsonBody = '{"searchText":"test","industries":"","jobFunctions":"","riskSpecialties":"","corporateTitles":"","company":"","pageSize":5,"pageCurrent":1,"sortField":"Name"}';
        req.requestBody = Blob.valueOf(jsonBody);
        Test.startTest(); 
            RestContext.request = req;
            RestContext.response = res;
            SearchDirectoryWebService.doPost();
        Test.stopTest(); 
    }
    
    @isTest
    static void ErrorSearchDirectoryWebService2(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/SearchDirectory'; 
        req.headers.put('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.headers.put('Garp-Token','khgIVBU^RTI&6rI&KUTGib6t');
        String jsonBody = '{"searchText":"test"}';
        req.requestBody = Blob.valueOf(jsonBody);
        Test.startTest(); 
            RestContext.request = req;
            RestContext.response = res;
            SearchDirectoryWebService.doPost();
        Test.stopTest(); 
    }
}