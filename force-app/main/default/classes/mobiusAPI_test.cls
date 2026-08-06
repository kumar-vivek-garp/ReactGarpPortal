@isTest
private class mobiusAPI_test{
    static Contact cont1;
    static Account acct1;
    static Opportunity opp1;    
    
    static void tesData() {
        acct1 = new Account(name = 'Test Account1',Profile_ID_Created_Date__c=system.today());
        insert acct1;
        
        cont1 = new Contact(FirstName='Test', LastName='Account', Company__c='GARP', Email='Test.Account@123.com', AccountID=acct1.Id, do_not_fire__c=true);
        insert cont1;
        
        opp1 = new Opportunity(Name='TestOpp', AccountID=acct1.Id, Amount=100.00, StageName='Closed', CloseDate=system.today());
        insert opp1;        
    }
    
    Private static testMethod void myUnitTest_1(){
        
        test.starttest();
        tesData();
        
        Remote_Sites__c setting = new Remote_Sites__c();
        setting.Name = 'Mobius';
        setting.Site_URL__c = 'http://preprod.garp.org:8081';
        insert setting;
        
        mobiusAPI.pingMobius();
        mobiusAPI.mCreateOrganization(1, 'Org', 1234);
        mobiusAPI.mGetOrganization(1, 1234);
        
        mobiusAPI.mUser mu = new mobiusAPI.mUser();
        mobiusAPI.mAddUser(1, 1234, mu);
        mobiusAPI.mModifyUser(1, 1234, mu);
        mobiusAPI.mGetUser(1, 1234);
        mobiusAPI.mGetUserList(1, 1234);
        mobiusAPI.mEnrollUser(1, 1234, 1234);
        mobiusAPI.mUnEnrollUser(1, 1234, 1234);
        mobiusAPI.mGetProductList(1);
        mobiusAPI.mUserLogin(1, 'a@a.com', 1, 1);
        mobiusAPI.mProvisionAnEBook('FRM', '1', '', 36, new List<Integer>{1234}, opp1.Id, 'a@a.com', 'firstName', 'lastName', '1234');
        
        mobiusAPI.mUnProvisionAnEBook(opp1.Id,1234, new Set<Integer>{1234});
            
        test.stoptest();      
        
    }    
    
}