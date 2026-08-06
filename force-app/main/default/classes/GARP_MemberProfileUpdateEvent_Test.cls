@isTest
public class GARP_MemberProfileUpdateEvent_Test {
    
    @testSetup
    private static void testSetup(){
        Account Acc = new Account(Name = 'TEST');    
        INSERT Acc;
        Contact contact = new Contact(FirstName = 'TEST',LastName = 'LASTNAME',Email = 'test@test.com', AccountId=Acc.Id);
        INSERT contact;
    }
    
    @isTest
    private static void test_MemberProfileUpdateEvent(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        Member_Profile_Update__e evt = new Member_Profile_Update__e(Contact_ID__c = con.Id);
        eventbus.publish(evt);
    	Test.getEventBus().deliver();
        Test.stopTest();
    }
}