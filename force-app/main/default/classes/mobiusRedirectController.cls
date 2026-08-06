public class mobiusRedirectController {
    
    public String ssoURL {get;set;}
    public String eBookType {get;set;}
    
     public mobiusRedirectController() {
         String prod = ApexPages.currentPage().getParameters().get('prod');
         mobiusAPI.mUserLoginResp resp = sfdcAppRemoter.ssoMobuisEBook(prod);
        if(resp != null && resp.status != NULL && resp.status == 0) {
            ssoURL = resp.link;    
         }         
     }
    
    public PageReference redirect(){
    	system.debug('ssoURL: ' + ssoURL );
        if(ssoURL != null){
            PageReference pageRef = new PageReference(ssoURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else{
            return null;
        }
    }    

}