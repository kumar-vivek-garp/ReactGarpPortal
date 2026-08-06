@isTest
public class Tableau_IntegrationClassTest {
    @TestSetup
    static void createTestData() { 
        
       Integer totalCount = 1; 
        
        List<Opportunity> OppResults =TestDataFactory.createOpportunity(totalCount);
        //oppresults
        insert OppResults;
        
        List<Contact> ContactResults =TestDataFactory.createContacts(totalCount);
        for(Integer counter=0; counter < totalCount; counter++) {
            ContactResults[counter].AccountId = OppResults[counter].AccountId;
        }
        insert ContactResults;
        
        List<Contract> ContractResults = TestDataFactory.createContract(totalCount,OppResults,ContactResults);
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'Membership'); 
        ContractResults[0].Member_Email__c = 'testcontract@test.com';
        ContractResults[0].ContractTerm = 5;
        ContractResults[0].Membership_type__C = 'Individual'; 
        insert ContractResults; 
        
    }
    
    @isTest static void CreteTableauIntegrationTest(){ 
        test.startTest(); 
        List<Contract> ContractResults = [Select id,Status from Contract limit 1];  
        ContractResults[0].Status = 'Activated ( Auto-Renew )';
        update ContractResults;
        test.stopTest(); 
    }
     
    
    @isTest static void CreteTableauIntegrationTest1(){ 
        test.startTest(); 
        List<Contract> ContractResults = [Select id,Status,AccountId from Contract limit 1];
        Test.setMock(HttpCalloutMock.class, new TableauIntegrationMock());
         Map<String,String> lstCreateUserIdsMap = new Map<string,String>();
        lstCreateUserIdsMap.put(ContractResults[0].AccountId,ContractResults[0].Id);
        Tableau_IntegrationClass.tableauIntegration('CreateUser',lstCreateUserIdsMap); 
        Tableau_IntegrationClass.addApiTransaction('test','','Test data','','',new Contact(),null); 
        test.stopTest();  
    }
    @isTest static void RemoveTableauIntegrationTest1(){ 
        test.startTest(); 
        List<Contract> ContractResults = [Select id,Status,AccountId from Contract limit 1];
        Test.setMock(HttpCalloutMock.class, new TableauIntegrationMock()); 
        Map<String,String> lstCreateUserIdsMap = new Map<string,String>();
        lstCreateUserIdsMap.put(ContractResults[0].AccountId,ContractResults[0].Id);
        Tableau_IntegrationClass.tableauIntegration('RemoveUser',lstCreateUserIdsMap); 
         Tableau_IntegrationClass.RemoveTableauUser('test',null,'https://test.com',new Contact(),null);
        // Tableau_IntegrationClass.UpdateTableauUser(null,'test',null,'https://test.com');
        test.stopTest();  
    }
    public class TableauIntegrationMock  implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals(req.getEndpoint(), req.getEndpoint());
            System.assertEquals(req.getMethod(), req.getMethod());
             String reqbody ='';
            if(req.getEndpoint().contains('/auth/signin')){
                reqbody = '{"credentials":{"site":{"id":"testdata123","contentUrl":""},"user":{"id":"testuser"},"token":"Testdcab3"}}';
            }else if(req.getMethod() == 'GET'){
                 reqbody ='{"pagination":{"pageNumber":"1","pageSize":"1","totalAvailable":"1"},"users":{"user":null}}';
            }else if(req.getMethod() == 'POST'){
                 reqbody ='{"user":{"name":"test@test.com","siteRole":"Viewer","authSetting":"SAML"}}';
            }
            // Create a fake response
            HttpResponse res = new HttpResponse();  
             
            res.setBody(reqbody);
            res.setStatusCode(200);
            return res;
        }
    }
}