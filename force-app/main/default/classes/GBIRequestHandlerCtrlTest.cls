@isTest
private class GBIRequestHandlerCtrlTest {
	
    @isTest
    private static void testAuraMethods() {
        setupData();
		Id study1Id = [SELECT Id FROM Study__c WHERE Name = 'Apex Test Study 1'].Id;
        
        Test.startTest();
        GBIRequestHandlerCtrl.loadUser();
        GBIRequestHandlerCtrl.loadStudies();
        GBIRequestHandlerCtrl.loadStudy(study1Id);
        
        GBIRequestHandlerCtrl.enqueueGBIRequest('{"AppName":"GBI_Study_Loader",AppRoute:"load-ratios", "Database":"' + study1Id + '"}');
        GBIRequestHandlerCtrl.enqueueDeleteGBIRequest();
        Test.stopTest();
    }
    
    private static void setupData() {
		Study__c testStudy1 = new Study__c(Name = 'Apex Test Study 1', Status__c = 'In Progress');
        Study__c testStudy2 = new Study__c(Name = 'Apex Test Study 2', Status__c = 'In Progress');
        insert new Study__c[] {testStudy1, testStudy2};
        
        TestingHelper.createStudyVersion(testStudy1.Id, true);
        
        TestingHelper.createGBIStudyAccount(testStudy1.Id, true);
        
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test GBI Account'];
        
        TestingHelper.createGBIMetadata(acct.Id, true);
	}
    
}