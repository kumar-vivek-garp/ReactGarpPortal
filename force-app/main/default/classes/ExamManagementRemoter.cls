public class ExamManagementRemoter {
    @RemoteAction    
    public static List<Exam_Attempt__c> getExamResults(String closedKey) {
        User vUser = utilities.verifyLoggedInUser();    
        return ExamManagementController.getExamResults(vUser.ContactId, closedKey);
    }
    
    
    @RemoteAction
    static public ExamManagementController.programInfo getProgramInfo(String programType) {
        return ExamManagementController.getProgramData(programType,'');
    }

    
    @RemoteAction
    static public ExamManagementController.allProgramData getAllProgramInfo(String closedKey) {
        return ExamManagementController.getAllProgramInfo(closedKey);
    }
    
    @RemoteAction
    static public void updateOSTAIDInfo(Id contactId, String idType, String idNumber, String idLocation, Date expDate) {
        ExamManagementController.updateOSTAIDInfo(contactId, idType, idNumber, idLocation, expDate);
    }
    
    @RemoteAction
    static public void logFailedAuthorization(String examRegId) {
        ExamManagementController.logFailedAuthorization(examRegId);
    }
    
    @RemoteAction
    static public void createCBTIntegrationAuthorization(String examRegId) {
        ExamManagementController.createCBTIntegrationAuthorization(examRegId);
    }
    
    @RemoteAction
    static public void clearCBTIntegrationAuthorization(String examRegId) {
        ExamManagementController.clearCBTIntegrationAuthorization(examRegId);
    }
    
    
    
    
    @RemoteAction
    static public void processExamRegModsFromClient(Id examRegModId) {
        Set<Id> setExamRegMods = new Set<Id>();
        setExamRegMods.add(examRegModId);
        ExamManagementController.processExamRegMods(setExamRegMods);
    }
    
    @RemoteAction 
    static public ExamManagementController.examRescheduleData createExamRescheduleFeesOrder(String examRegId, String selectedAdminPartI, String selectedAdminPartII, String selectedSitePartI, String selectedSitePartII) {
        string userId = userinfo.getUserId();
        // 'Deferral Standard'
        return ExamManagementController.createExamRescheduleFeesOrderInternal(examRegId, selectedAdminPartI, selectedAdminPartII, selectedSitePartI, selectedSitePartII, userId,false,false,null,false);
    }
    
    @RemoteAction 
    static public ExamManagementController.examRescheduleData getExamRescheduleFees(String examRegId, String selectedAdminPartI, String selectedAdminPartII, String selectedSitePartI, String selectedSitePartII) {
        string userId = userinfo.getUserId();
        return ExamManagementController.getExamRescheduleFeesInternal(examRegId, selectedAdminPartI, selectedAdminPartII, selectedSitePartI, selectedSitePartII, userId, false, false);
    }
    
    @RemoteAction 
    static public ExamManagementController.examRescheduleData getExamRescheduleInformation(Id examRegId) {
        String userId = UserInfo.getUserId();
        return ExamManagementController.getExamRescheduleData(examRegId, NULL, NULL, NULL, NULL,userId);
    }
    
    @RemoteAction 
    public static Response.Envelope changeExamSiteOnExamRegistrations(Id examRegistrationId, Id targetExamSiteId){
        return ExamManagementController.changeExamSiteOnExamRegistrations(examRegistrationId, targetExamSiteId);
    }
    
    public ExamManagementRemoter(sfdcAppRemoter ctrl){}
}