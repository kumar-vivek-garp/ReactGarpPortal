global without sharing class sfdcAppRemoter {


    public sfdcAppRemoter() { 

    }
 
    @RemoteAction
    public static mobiusAPI.mUserLoginResp ssoMobuisEBook(String productId){
        String userId = UserInfo.getUserId(); 
        mobiusAPI.mUserLoginResp mULResp;
        List<User> lstUser = [Select u.Id,u.ContactId from User u where u.Id = :userId];
        if( lstUser != null && lstUser.size() > 0 ) {
            List<Contact> lstContact = [select Id, Name, Email from Contact where Id = :lstUser[0].ContactId];
            if( lstContact != null && lstContact.size() > 0 ) {   
                mobiusAPI.mobiusRespWrapper wResp = mobiusAPI.mUserLogin(mobiusAPI.apiVersionGlobal,lstContact[0].Email, Integer.valueOf(productId), 0);
                System.debug('mUserLogin:' + wResp);  
                mULResp = (mobiusAPI.mUserLoginResp)JSON.deserialize(wResp.response, mobiusAPI.mUserLoginResp.class);
                System.debug('mULResp:' + mULResp);        
            }
        }
        return mULResp;
    }  

}