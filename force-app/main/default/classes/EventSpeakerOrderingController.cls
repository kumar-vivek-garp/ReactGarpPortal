public with sharing class EventSpeakerOrderingController {
    private String eventId;
    public List<EvSpeakerOrderWrapper > EvSpeakerOrderList {get;set;}
    private map<String, String> evSpeakerNameIdMap = new map<String, String> ();
    private List<Event_Speaker_Session_Track__c> evSessSpeakerList ;
    public EventSpeakerOrderingController(ApexPages.StandardController controller) {
        eventId = controller.getId();
        getSpeakerDetails();
    }
    public PageReference getSpeakerDetails(){
        evSessSpeakerList = [Select Order_By__c, Featured__c, Event_Session__c, Event_Speaker__c, Event_Speaker__r.Name from Event_Speaker_Session_Track__c
                where Event_Session__r.Event__c = :eventId ];
        if(evSessSpeakerList == null || evSessSpeakerList.size() == 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There are no Event Speakers for this event');
            ApexPages.addMessage(myMsg);
            return null;
        }
        EvSpeakerOrderList = new List<EvSpeakerOrderWrapper>();
        for(Event_Speaker_Session_Track__c evSpSess : evSessSpeakerList ){
            if(evSpeakerNameIdMap.get(evSpSess.Event_Speaker__r.Name) == null){
                evSpeakerNameIdMap.put(evSpSess.Event_Speaker__r.Name, evSpSess.Event_Speaker__c);
                EvSpeakerOrderWrapper evObj = new EvSpeakerOrderWrapper ();
                evObj.EvSpeakerName = evSpSess.Event_Speaker__r.Name;
                evObj.EvSpeakerId = evSpSess.Event_Speaker__c;
                evObj.orderby  = evSpSess.Order_By__c;
                evObj.featured  = evSpSess.Featured__c;
                EvSpeakerOrderList.add(evObj);
            }
        }
        return null;

    }

    public PageReference updateOrderByValues(){
        if(evSessSpeakerList != null && evSessSpeakerList.size() > 0){
            for(Event_Speaker_Session_Track__c evSessSp : evSessSpeakerList){
                for(EvSpeakerOrderWrapper  evObj : EvSpeakerOrderList){
                    if(evSessSp.Event_Speaker__c == evObj.EvSpeakerId){
                        evSessSp.Order_By__c = evObj.orderby;
                        evSessSp.Featured__c = evObj.featured;
                    }
                }

            }
            update evSessSpeakerList;
        }
        PageReference pg = new PageReference ('/'+eventId );
        return pg;
    }

    public Class EvSpeakerOrderWrapper {
        public String EvSpeakerName {get;set;}
        public String EvSpeakerId {get;set;}
        public decimal orderby {get;set;}
        public boolean featured {get;set;}
    }
}