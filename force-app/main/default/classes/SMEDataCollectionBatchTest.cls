@isTest
private class SMEDataCollectionBatchTest {

	private static testMethod void test_batch() {
        Contact con = TestingHelper.createContact('apex_test@sample.garp', false, true);
        Event__c convEvt = TestingHelper.createConvention(true);
        Event_Speaker__c evtSpkr = TestingHelper.createEventSpeaker(con, true);
        Event_Sessions__c evtSess = TestingHelper.createEventSession(convEvt.Id, true);
        Event_Speaker_Session_Track__c esst = TestingHelper.createSpeakerSession(evtSess.Id, evtSpkr.Id, true);
        
        Chapter_Meeting_Speaker__c cms = TestingHelper.createChapterMeetingSpeaker(con, true);
        
        Webcast__c webcast = TestingHelper.createWebcast(true);
        Presenter__c pres = TestingHelper.createWebcastPresenter(webcast.Id, con.Id, true);
        
        Test.startTest();
        String cronExp = '0 0 2 ? * *';
        System.debug('Job Id: ' + System.schedule('Apex Test SME Data Collection Job', cronExp, new SMEDataCollectionBatch(100)));
        Test.stopTest();
	}

}