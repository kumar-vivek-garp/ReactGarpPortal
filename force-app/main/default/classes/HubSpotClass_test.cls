@isTest
public class HubSpotClass_test {

    
    @isTest
    public static void testMethod1(){ 
        
        // Setup Products
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        // Create User
        User user = GARP_TestFactory.createIndividualUser();
        
        HubSpotClass.updateContactEmail(user.ContactId, 'garpqa.update@garpqa.com');
    }
}