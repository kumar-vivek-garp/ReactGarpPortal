global class addThisFeed{

    public class addThisStatsItem {
        public Integer shares;
        public String URL;
    }
       
    
    
    @future(callout=true)
    public static void getFeedMethod() {
        
        String URL = null;
        String apiKey = null;
        List<Integration_Settings__c> lstSettings = Integration_Settings__c.getall().values();
        for(Integration_Settings__c cs :lstSettings) {
            if(cs.Name == 'AddThis') {
                //addThisFeed.addThisStatsItemsettings = cs;
                URL = cs.End_Point__c;
                apiKey = cs.API_Key__c;
            }
        }
        
        List<Content__c> lstContent = [select Id, Name, Share_Count__c from Content__c where Share_Count__c != null];
        if(lstContent!=null && lstContent.size()>0) {
            for(Content__c c :lstContent) {
                c.Share_Count__c=null;
            }
        }
        
        if(URL!=null) {
            Http httpProtocol = new Http();
            // Create HTTP request to send.
            HttpRequest request = new HttpRequest();
            // Set the endpoint URL.
            String endpoint = URL;
            request.setEndPoint(endpoint);
            request.setHeader('X-Api-Key', apiKey);
            // Set the HTTP verb to GET.
            request.setMethod('GET');
            // Send the HTTP request and get the response.
            // The response is in JSON format.

            String body = null;
            if ( !Test.isRunningTest() ) {
                HttpResponse response = httpProtocol.send(request);
                if(response.getStatusCode() == 200){
                    body = response.getBody();
                    System.debug(body);
                }else{
                    createErrorLog('Method:getFeedMethod','Class:addThisFeed','Callout Failed','Response Code'+response.getStatusCode()+'Body:'+response.getBody());
                    return;
                }
            } else {
                body = '[{"shares":29,"url":"http://www.garp.org/#!/risk-intelligence/detail/a1Z40000003CjVSEA0"},{"shares":22,"url":"http://www.garp.org/#!/risk-intelligence/detail/a1Z40000003CcggEAC"}]';
                System.debug(body);                
            }            
            MAP<String,Integer> mapShares = new MAP<String,Integer>();
            
            try{
                // Parse JSON response to get all the totalPrice field values.
                JSONParser parser = JSON.createParser(body);
                Double grandTotal = 0.0;
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                        while (parser.nextToken() != null) {
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                addThisStatsItem item = (addThisStatsItem)parser.readValueAs(addThisStatsItem.class);
                                system.debug('shares: ' + item.shares);
                                system.debug('URL: ' + item.URL);
                                //http://www.garp.org/#!/risk-intelligence/detail/a1Z40000003CjVSEA0
                                
                                String[] arrText = item.URL.split('/');                    
                                if(arrText.size() > 0) {
                                    for(String s :arrText) {
                                        if(s.indexOf('a1Z') > -1) {
                                            System.debug('Match:' + s);
                                            mapShares.put(s,item.shares);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }catch(exception e){
                createErrorLog('Method:getFeedMethod'+' Line:'+e.getLineNumber(),'Class:addThisFeed',e.getMessage(),'JSONResponse:'+body);
                return;
            }
            system.debug('mapShares=' + mapShares);  
            List<Content__c> updateContent = new List<Content__c>();
            if(mapShares.size() > 0) {
                List<Content__c> lstContentUpdate = [select Id, Name, Share_Count__c from Content__c where ID in :mapShares.keySet()];
                if(lstContentUpdate!=null && lstContentUpdate.size()>0) {
                    for(Content__c c :lstContentUpdate) {
                        Integer shareCnt = mapShares.get(c.Id);
                        if(shareCnt != null) {
                            c.Share_Count__c=shareCnt;
                            updateContent.add(c);
                        }
                        	
                    }
                }
                system.debug('updateContent=' + updateContent); 
                if(updateContent.size() > 0) {
                    update lstContent;
                    update updateContent;
                }
            }
            
        }    
    }
    
    public static void createErrorLog(string method,string file, string message,string error){
        AppError__c ae = new AppError__c();
        ae.Method__c = method;
        ae.File__c = file;
        ae.Message__c = message;
        ae.Error__c = error;
        insert ae;
    }
}