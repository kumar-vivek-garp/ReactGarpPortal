@RestResource(urlMapping='/SearchDirectory/*')
global without sharing class SearchDirectoryWebService {
    global class returnSearchDirectoryInfo {
        global String statusMessage;
        global Integer statusCode;
        global GARP_BC_Membership.searchResults searchResults;
    }
    @HttpPost
    global static returnSearchDirectoryInfo doPost() {
        returnSearchDirectoryInfo results = new returnSearchDirectoryInfo();
        try{ 
            RestRequest req = RestContext.request;
            String incomingToken = req.headers.get('Garp-Token'); 
            if(incomingToken == 'khgIVBU^RTI&6rI&KUTGib6t'){ 
                 
                GARP_BC_Membership.searchParams input = (GARP_BC_Membership.searchParams)JSON.deserialize(req.requestBody.toString(), GARP_BC_Membership.searchParams.class);
                 
                results.searchResults = GARP_BC_Membership.searchMembers(null,input,false);
                results.statusMessage = 'Success';
                results.statusCode = 200;
                return results;
            }else{
                results.searchResults = new GARP_BC_Membership.searchResults();
                results.statusMessage = 'Invalid Auth Token';
                results.statusCode = 401;
                return results;
            }
            }catch(Exception ex){
                results.searchResults = new GARP_BC_Membership.searchResults();
                results.statusMessage = ex.getMessage()+' '+ex.getStackTraceString();
                results.statusCode = 401;
                return results;
            }
        }
   
}