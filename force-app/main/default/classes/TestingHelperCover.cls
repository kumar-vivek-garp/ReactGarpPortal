/* To cover TestingHelper methods with deployment with testLevel=RunSpecifiedTests
 * 02/25/2019 Xiang - Created
 */
@isTest
private class TestingHelperCover {
    
    @isTest static void cover_all() {
        Id tstIndId = TestingHelper.individualId;
        Id tstConvId = TestingHelper.conventionId;
        
        Contact con = TestingHelper.createContact('tst@sample.com', false, true);
        Event__c evt = TestingHelper.createConvention(true);
        
        TestingHelper.createRegistration(con.Id, evt.Id, false);
        Event_Sessions__c sess = TestingHelper.createEventSession(evt.Id, true);
        Event_Speaker__c spkr = TestingHelper.createEventSpeaker(con, true);
        TestingHelper.createSpeakerSession(sess.Id, spkr.Id, true);
        
        TestingHelper.createOppty('Test Oppty', true);
        
        TestingHelper.createInstSaleOppty('Test Oppty Inst', 'GARP', true, false);
        
        TestingHelper.createUser('Accounting', 'tstUsr@tstAcct.com', false);
    }
    
    @isTest static void cover_all_part2() {
        Contact con = TestingHelper.createContact('tst@sample.com', false, true);
        TestingHelper.createChapterMeetingSpeaker(con, true);
        
        Webcast__c wc = TestingHelper.createWebcast(true);
        TestingHelper.createWebcastPresenter(wc.Id, con.Id, true);
        TestingHelper.createAlumniSetting('tst@sample.com');
        
        Product2 prod = TestingHelper.createProduct('GARP', 'Test Product', true);
        TestingHelper.createFRMProds();
    }

}