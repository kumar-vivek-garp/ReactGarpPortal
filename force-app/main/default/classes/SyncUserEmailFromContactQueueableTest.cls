@isTest
public class SyncUserEmailFromContactQueueableTest {
    @isTest static void testCommunityupdateUserEmail() {
        String conEmail = 'apex_1tester123@noemail.com';
        Account acc = new Account(Name = 'test');
        insert acc;
        Contact con = TestingHelper.createContact(conEmail, true, true);
        
        User user = [SELECT Id, LocaleSidKey FROM User WHERE ContactId = :con.Id];
        
       Test.startTest();
        System.runAs(user) { 
            try {  
                con.Email = 'apex_1tester2026@noemail.com';
                update con;
                  System.enqueueJob(new SyncUserEmailFromContactQueueable(new set<id>{con.id}));
            }catch(Exception e) {
                System.debug(e); 
            } 
        }
        Test.stopTest();
    }
}