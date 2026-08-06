public class ON24EngagementHubSSO {

    Pagereference page = new pagereference('https://www.garp.org/#!/404');

    public pagereference redirect() {
    
        String eventId = ApexPages.currentPage().getParameters().get('id');
        if(eventId == NULL || eventId == 'null') {
            eventId = '';
        }
        System.Debug('eventId:' + eventId);
        
        List<User> users = [SELECT Id, ContactId, Email FROM User WHERE Id = :UserInfo.getUserId()];
        System.Debug('users:' + users);
        
        if(!users.isEmpty()) {           
            List<Contact> contacts = [SELECT Id, Name, KPI_Membership_Payment_Status__c ,Email, AccountID FROM Contact WHERE Id = :users[0].ContactId];
            System.Debug('contacts:' + contacts);
            
            if( contacts != null && contacts.size() > 0 ) {            
            
                String memberId = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership');
                List<Contract> lstCont = [select Id, Name, Status from Contract where AccountID = :contacts[0].AccountID  and RecordTypeId = :memberId AND Status like 'Activated%'];
                System.Debug('lstCont:' + lstCont);
                
                if(lstCont != NULL && lstCont.size() > 0 && lstCont[0].Status.subString(0,9) == 'Activated') {
            
                    String gatedEventId;
                    List<Webcast__c> lstWebcasts = [select id, EventId__c, Gated_EventID__c from Webcast__c where EventId__c = :eventId];
                    System.Debug('lstWebcasts:' + lstWebcasts);
                    
                    if(!lstWebcasts.IsEmpty()) {
                        if(lstWebcasts[0].Gated_EventID__c != NULL) {
                        	gatedEventId = lstWebcasts[0].Gated_EventID__c;
                        }
                    } else {
                        List<Chapter_Meeting__c> lstChapterMeetings = [select id, ON24_Event_Id__c, Gated_EventID__c from Chapter_Meeting__c where ON24_Event_Id__c = :eventId];
                        System.Debug('lstWebcasts:' + lstChapterMeetings);
                        
                        if(!lstChapterMeetings.IsEmpty()) {
                            if(lstChapterMeetings[0].Gated_EventID__c != NULL) {
                                gatedEventId = lstChapterMeetings[0].Gated_EventID__c;
                            }
                        } else {
                            List<Event__c> lstEvents = [select id, ON24_Event_Id__c, Gated_EventID__c from Event__c where ON24_Event_Id__c = :eventId];
                            System.Debug('lstEvents:' + lstChapterMeetings);
                            
                            if(!lstEvents.IsEmpty()) {
                                if(lstEvents[0].Gated_EventID__c != NULL) {
                                    gatedEventId = lstEvents[0].Gated_EventID__c;
                                }
                            }
                        }
                    }
                    
                    if(gatedEventId != NULL) {
                        eventId = gatedEventId;
                    }
                    System.Debug('eventId Final:' + eventId);
                    
                    String accountEmail = contacts[0].Email;
                    
                    
                    String sredir = 'https://gateway.on24.com/wcc/login?eventId=2960348&sessionid=1&key=67B583B1ACBD79DE9C7AC600CA57A098&email=' + accountEmail + '&targetUrl=';
                    if(eventId != '') {
                        sredir = 'https://gateway.on24.com/wcc/login?eventId=2960348&sessionid=1&key=67B583B1ACBD79DE9C7AC600CA57A098&email=' + accountEmail + '&targetUrl=eh/2960348/lp/' + eventId;
                    }
                    System.Debug('sredir:' + sredir);
                        
                    page = new pagereference(sredir);
                }
            }
        }    
        return page;
    }
    
}