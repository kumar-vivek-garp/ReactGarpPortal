public class GARP_MS_Registration {
    @RemoteAction
    public static GARP_BC_Registration.registrationFees getRegistrationFees(GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo) {
        return GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
    }
    
    @RemoteAction
    public static GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomer(GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo) {
        return GARP_BC_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
    }
    
    @RemoteAction
    public static GARP_BC_Registration.setRegistrationReturnInfo setRegistration(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo) {
        return GARP_BC_Registration.setRegistration(setRegistrationInfo);
    }
        
    @RemoteAction    
    public static GARP_BC_Orders.setOrderReturnInfo payOrder(GARP_BC_Registration.createOrderInfo setCourseOrderInfo) {
        return GARP_BC_Registration.payOrder(setCourseOrderInfo);
    }
    
    @RemoteAction
    public static GARP_BC_Registration.paymentStatus checkRegistrationPaymentStatus(String orderId) {
        return GARP_BC_Registration.checkRegistrationPaymentStatus(orderId);
    }    
    
    @RemoteAction
    public static Boolean rollbackSetRegistration(String leadId, String accountId, String email, String orderId) {
      return GARP_BC_Registration.rollbackSetRegistration(leadId, accountId, email, orderId, 'Cancel Registration');
    }    
    
    @RemoteAction    
    public static String getSessionState(String sessionToken) {
        return GARP_BC_Registration.getSessionState(sessionToken);
    }
    
    public GARP_MS_Registration(sfdcAppRemoter ctrl){}
}