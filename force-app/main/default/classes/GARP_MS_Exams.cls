public class GARP_MS_Exams {
    
	@RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getFRMRegistrationInfo(String regCode) {
        return GARP_BC_Exams.getFRMRegistrationInfo(regCode);
    }

    public GARP_MS_Exams(sfdcAppRemoter ctrl){}
}