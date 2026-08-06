@isTest
public class PortalUserCtrlTest {

    @testSetup
    public static void setup(){
        
        Account a = new Account();
        a.Name = 'TESTACCOUNT';
        INSERT a;
        
        Contact c = new Contact();
        c.FirstName = 'TESTCONTACT';
        c.LastName = 'TESTCONTACT';
        c.Email = 'test@email.com';
        c.AccountId = a.Id;
        INSERT c;
               
    }
    
    @isTest
    public static void test(){
        
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        PortalUser_CTRL.getPortalUserData(c.Id);
        PortalUser_CTRL.getContact(c.Id);
    }
    
}