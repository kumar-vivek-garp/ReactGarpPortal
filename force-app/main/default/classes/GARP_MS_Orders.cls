public class GARP_MS_Orders {

    // Wrappers
    
    @RemoteAction
    public static GARP_BC_Registration.getRegistrationInfo getCheckoutRegistrationInfo(GARP_BC_Orders.checkoutCart checkoutCart) {
        return GARP_BC_Orders.getCheckoutRegistrationInfo(checkoutCart);
    } 

    @RemoteAction
    public static GARP_BC_Orders.returnOrderOperation removePendingPaymentOrder(String OrderId) {
        return GARP_BC_Orders.removePendingPaymentOrder(OrderId);
    } 
    
    @RemoteAction
    public static List<GARP_BC_Orders.orderInfo> getOrderHistory() {
        Id userId = UserInfo.getUserId();
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
        if(!users.isEmpty()){
            return GARP_BC_Orders.getOrderHistory(users[0].AccountId);
        }
        return null;  
    }
    
    public GARP_MS_Orders(sfdcAppRemoter ctrl){}
}