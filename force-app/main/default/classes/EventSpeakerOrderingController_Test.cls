@isTest
private class EventSpeakerOrderingController_Test {
    static Event__c ev;
    private static testmethod void setupData(){
        ev = new Event__c(name='test event');
        insert ev;
        Event_Sessions__c evSess = new Event_Sessions__c (name='test event session', Event__c = ev.Id);
        insert evSess;
        Event_Speaker_Session_Track__c evSpkr = new Event_Speaker_Session_Track__c(name='test speaker', Event_Session__c=evSess.Id);
        insert evSpkr;
    }
    private static testmethod void updateOrdersTest(){
        setupData();
        test.startTest();
        EventSpeakerOrderingController evSpkCo = new EventSpeakerOrderingController (new Apexpages.Standardcontroller(ev));
        evSpkCo.getSpeakerDetails();
        evSpkCo.updateOrderByValues();
        test.stopTest();
    }
    private static testmethod void updateOrdersTestNoSpeaker(){
        ev = new Event__c(name='test event');
        insert ev;
        test.startTest();
        EventSpeakerOrderingController evSpkCo = new EventSpeakerOrderingController (new Apexpages.Standardcontroller(ev));
        evSpkCo.getSpeakerDetails();
        test.stopTest();
    }
}