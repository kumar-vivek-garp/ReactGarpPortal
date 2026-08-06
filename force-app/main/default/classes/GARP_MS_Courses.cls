public class GARP_MS_Courses {

    // Methods
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getFRRRegistrationInfo(String regCode) {
        return GARP_BC_Courses.getFRRRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getFRR25RegistrationInfo(String regCode) {
        return GARP_BC_Courses.getFRR25RegistrationInfo(regCode);
    }
    
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getMicroCourseRegistrationInfo(String courseCode, String regCode) {
        return GARP_BC_Courses.getMicroCourseRegistrationInfo(courseCode, regCode);
    }

    
    
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getFFRRegistrationInfo() {
        return GARP_BC_Courses.getFFRRegistrationInfo();
    }
    
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getSCRRegistrationInfo(String regCode) {
        return GARP_BC_Courses.getSCRRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getRiskAIRegistrationInfo(String regCode) {
        return GARP_BC_Courses.getRiskAIRegistrationInfo(regCode);
    }

    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getRAIJRegistrationInfo(String regCode) {
        return GARP_BC_Courses.getRAIJRegistrationInfo(regCode);
    }
    
    public GARP_MS_Courses(sfdcAppRemoter ctrl){}
}