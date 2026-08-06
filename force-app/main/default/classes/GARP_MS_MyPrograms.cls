public class GARP_MS_MyPrograms {

    /*
    @RemoteAction
    static public GARP_Common.returnInfo eppOptIn() {
		Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_MyPrograms.eppOptIn(users[0].ContactId);
        }
        return null;
    }
    
    @RemoteAction
    public static List<GARP_BC_MyPrograms.workExpierence> getWorkExperience(String contactId){
        Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_MyPrograms.getWorkExperience(users[0].ContactId);
        }
		return null;
    }
    
    @RemoteAction
    public static GARP_Common.returnInfo setWorkExperience(GARP_BC_MyPrograms.workExpierence workExpierence) {
        Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_MyPrograms.setWorkExperience(users[0].ContactId, users[0].AccountId, workExpierence);
        }
		return null;
    }
    
    @RemoteAction
    static public GARP_BC_MyPrograms.programInfo getProgramInfo(String programType) {
        return GARP_BC_MyPrograms.getProgramData(programType,'');
    }

    @RemoteAction
    static public GARP_BC_MyPrograms.allProgramData getAllProgramInfo(String closedKey) {
        return GARP_BC_MyPrograms.getAllProgramInfo(closedKey);
    }
    
    static public List<GARP_BC_MemberContent.contentData> getResources(String programType) {
    	Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_MyPrograms.getResources(users[0].ContactId, programType);
        }
		return null;
    }
    
    static public List<Exam_Attempt__c> getExamResults(String closedKey) {
    	Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_MyPrograms.getExamResults(users[0].ContactId, closedKey);
        }
		return null;
    }

	*/
}