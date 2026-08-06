public class RiskDotNetQueueable implements System.Queueable, Database.AllowsCallouts {
    public static String endPoint = System.Label.Risk_Net_Endpoint;
    public static String method = 'POST';
    public List<API_Transaction__c> lstApiTrns = new List<API_Transaction__c>();
    public List<Id> contactIds = new List<Id>();
    public Map<Id,Contact> Contacts = new Map<Id,Contact>();
    public Map<Id,Contract> contracts = new Map<Id,Contract>();
    
    // Class to create user
      public RiskDotNetQueueable(Set<Id> contractIdset) { 
          system.debug('Entered RDN Utility class================>');
          Map<Id,Contract> contractIds = new Map<Id,Contract>([Select Id,CustomerSignedId,StartDate,EndDate,Status from Contract where ID IN: contractIdset]);
          for(Id cont : contractIds.keySet()) {
              contactIds.add(contractIds.get(cont).CustomerSignedId);
          }
          for(contact cont : [Select Id,Name,FirstName,LastName,RPT_Clean_Country__c,email,GARP_Member_ID__c From Contact Where id IN: contactIds ] )
          { 
              Contacts.put(cont.Id,cont);
          }
          this.contracts =  contractIds;
    }
    
    public void execute(System.QueueableContext context) {
        for(Id cont: contracts.keySet() ) {
        
            string requestBody = RiskDotNetAPIBody.Body(contracts.get(cont),contactIds,Contacts); 
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod(method);
            req.setHeader('content-type','application/json');
            system.debug('reqBody=========>'+requestBody);
                
            req.setBody(requestBody);
                
            Http h = new Http();
            HttpResponse res = new HttpResponse();
            if(test.isRunningTest()) {
                res.setBody('{"status":"ok","data":{"org_size":"","org_industry":"","name":"GARP-0001","id":"GARP-0001","companies":[{"id":"GARP-COMP10001"}]}}');
                res.setHeader('Content-Type', 'application/json');
                res.setStatusCode(200);
            } else {
                
                res = h.send(req);
                
            }
            API_Transaction__c apiTransaction = new API_Transaction__c();   
            apiTransaction.Type__c = 'Risk.net';
            apiTransaction.Request_URL_Long_Text__c = endPoint;
            apiTransaction.Contract__c = cont;
            apiTransaction.Contact__c = contracts.get(cont).CustomerSignedId;
            apiTransaction.Request_Body__c = requestBody;
            apiTransaction.Response_Code__c = String.ValueOf(res.getStatusCode());
            apiTransaction.Response_Body__c = res.getBody();
            lstApiTrns.add(apiTransaction);
        }
        if(!lstApiTrns.isEmpty()) {
            insert lstApiTrns;
        }
    }
}