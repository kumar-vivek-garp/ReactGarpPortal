public class GARP_BC_Authentication {

     public static Boolean isAuthenticated() {            
        String userId = UserInfo.getUserId(); 
        Boolean found = false;
        
        List<User> lstUser = [Select u.Id,u.ContactId from User u where u.Id = :userId];
        if( lstUser != null && lstUser.size() > 0 ) {
            List<Contact> lstContact = [select Id, Name, KPI_FRM_Certified__c, KPI_ERP_Certified__c from Contact where Id = :lstUser[0].ContactId];
            if( lstContact != null && lstContact.size() > 0 ) {            
                found=true;
            }
        }
        return found;
    }
}