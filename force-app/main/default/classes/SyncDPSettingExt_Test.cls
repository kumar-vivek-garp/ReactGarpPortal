@isTest
private class SyncDPSettingExt_Test {

	private static testMethod void testAll() {
        Account acct = new Account(Name='Test Apex Account');
        insert acct;
        
        Study__c stdy = new Study__c(Name='Test Apex Study');
        insert stdy;
        
        Study_Account__c stdAcct = new Study_Account__c(Name='Test Study Account', Study__c=stdy.Id, Account__c=acct.Id, Status__c='Active',Study_Fee_Type__c='Free');
        insert stdAcct;
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acct);
        
        Test.startTest();
        SyncDPSettingExt ext = new SyncDPSettingExt(stdCtrl);
        ext.getOpts();
        ext.dp_select_val = 'Enable';
        ext.syncDPSettings();
        
        ext.dp_select_val = 'Disable';
        ext.syncDPSettings();
        Test.stopTest();
	}

}