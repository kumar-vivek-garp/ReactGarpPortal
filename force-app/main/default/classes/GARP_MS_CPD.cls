public class GARP_MS_CPD {

    /*
    // Service Wrappers
    
    
    // Service Methods
    public static GARP_BC_CPD.cpdProgramInfo getCPDProgramInfo(){
        Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_CPD.getCPDProgramInfo(users[0].AccountId);
        }
        return null;
    }
    
    public static GARP_Common.returnInfo setCPDProgramInfo(GARP_BC_CPD.cpdClaim cpdClaim) {
        Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_CPD.setCPDProgramInfo(users[0].AccountId, cpdClaim);
        }
        return null;
    }
	*/
}