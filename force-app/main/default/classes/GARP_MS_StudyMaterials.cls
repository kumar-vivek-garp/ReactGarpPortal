public class GARP_MS_StudyMaterials {
/*
    
    @RemoteAction
    public static List<GARP_BC_StudyMaterials.eBook> getMyEBooks(){
        Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_StudyMaterials.getMyEBooks(users[0].AccountId, NULL);
        }
		return null;
    }
        
    @RemoteAction
    public static GARP_BC_StudyMaterials.studyMaterialsInfo getStudyMaterials(){
        Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_StudyMaterials.getStudyMaterials(users[0].AccountId, users[0].ContactId, False, False); 
        }
		return null;
    }
*/   
    public GARP_MS_StudyMaterials(sfdcAppRemoter ctrl){}    
}