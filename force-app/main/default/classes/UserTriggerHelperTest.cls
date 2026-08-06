@isTest
private class UserTriggerHelperTest {

    @isTest static void testCommunityUserChangeLocale() {
        String conEmail = 'apex_tester123@noemail.com';
        Contact con = TestingHelper.createContact(conEmail, true, true);
        User user = [SELECT Id, LocaleSidKey FROM User WHERE ContactId = :con.Id];
        
        Test.startTest();
        System.runAs(user) {
            try {
                user.LocaleSidKey = 'zh_CN'; 
                update user;
            }catch(Exception e) {
                System.debug(e);
                System.assert(e.getMessage().contains(Label.SiteUserLocaleMsg));
            }
        }
        Test.stopTest();
    }
    @isTest static void testCommunityupdateUserEmail() {
        String conEmail = 'apex_tester123@noemail.com';
        Account acc = new Account(Name = 'test');
        insert acc;
        Contact con = TestingHelper.createContact(conEmail, true, true);
        con.AccountId = acc.Id;
        update con;
        User user = [SELECT Id, LocaleSidKey FROM User WHERE ContactId = :con.Id];
        
        Test.startTest();
        System.runAs(user) {
            try { 
                user.Email = 'apex_tester12345@noemail.com';
                update user;
            }catch(Exception e) {
                System.debug(e);
                System.assert(e.getMessage().contains(Label.SiteUserLocaleMsg));
            }
        }
        Test.stopTest();
    }
}