public class EventAgendaAsPDF {
    
    public List<AgendaDay> AgendaDays {get; set;}
    public List<AgendaItemsWrapper> AgendaItems {get; set;}
    public Integer totalDays {get; set;}
    public String eventName {get; set;}
    
    public EventAgendaAsPDF() {        
        String eventId = ApexPages.currentPage().getParameters().get('id');
        AgendaDays = new List<AgendaDay>();
        totalDays = 0;
        fecthData(eventId);
    } 
    
    public void fecthData(String eventId) {
        
        List<Event__c> lstEvent = [select Id, Name from Event__c where ID = :eventId];
        
        if(lstEvent != null && lstEvent.size() > 0) {
        
            eventName = lstEvent[0].Name;
            
            List<Event_Sessions__c> lstSessions = [
                    SELECT Id, Title__c, Description__c, Details__c, Start_Date_Time__c, End_Date_Time__c, Event_Session_Track__c, Session_Type__c, Show_in_List_View__c, Type__c
                    FROM Event_Sessions__c 
                    WHERE Status__c = 'Active' AND Event__c = :eventId ORDER BY Start_Date_Time__c
                ];          
            if(lstSessions != null && lstSessions.size() > 0) {
                
                List<Event_Speaker_Session_Track__c> lstTracks = [
                    Select Id, Event_Session__c, Event_Session_Track__c, Event_Session_Track__r.Name, Event_Speaker__c, Event_Speaker__r.Name, Event_Speaker__r.Byline__c
                    FROM Event_Speaker_Session_Track__c
                    WHERE Event_Session__c in :lstSessions
                ];
                
                MAP<String,Event_Speaker_Session_Track__c> mapTracks = new MAP<String,Event_Speaker_Session_Track__c>();
                MAP<String,List<SpeakerInfo>> mapSpeakers = new MAP<String,List<SpeakerInfo>>();
                if(lstTracks != null && lstTracks.size() > 0) {                    
                    for(Event_Speaker_Session_Track__c esst :lstTracks) {
                        if(esst.Event_Speaker__c != NULL) {
                            List<SpeakerInfo> fndSpeakers = mapSpeakers.get(esst.Event_Session__c);
                            if(fndSpeakers == NULL) {
                                List<SpeakerInfo> speakers = new List<SpeakerInfo>();
                                SpeakerInfo speaker = new SpeakerInfo();
                                speaker.name = esst.Event_Speaker__r.Name;
                                speaker.byLine = esst.Event_Speaker__r.Byline__c;
                                speakers.add(speaker);
                                mapSpeakers.put(esst.Event_Session__c, speakers);
                            } else {
                                SpeakerInfo speaker = new SpeakerInfo();
                                speaker.name = esst.Event_Speaker__r.Name;
                                speaker.byLine = esst.Event_Speaker__r.Byline__c;
                                fndSpeakers.add(speaker);
                                mapSpeakers.put(esst.Event_Session__c, fndSpeakers);
                            }
                        }
                        mapTracks.put(esst.Event_Session__c, esst);
                    }
                }
                
                DateTime lastDay = lstSessions[0].Start_Date_Time__c;
                Integer dayCnt = 0;
                Integer sessionCnt = 0;
                
                List<AgendaItemsWrapper> agendaItems = new List<AgendaItemsWrapper>();
                List<AgendaItemsWrapper> townItems = new List<AgendaItemsWrapper>();
                
                for(Event_Sessions__c es :lstSessions) {
                    sessionCnt++;
                    system.debug('es:' + es);
                    
                    Event_Speaker_Session_Track__c fndTrack = mapTracks.get(es.Id);
                    String track = null;
                    if(fndTrack != NULL && fndTrack.Event_Session_Track__c != NULL) {
                        track = fndTrack.Event_Session_Track__r.Name;
                    }
                    String duration = null;
                    String sessionTime = null;
                    String startTime = null;
                    String endTime = null;
                    if(es.Start_Date_Time__c != NULL && es.End_Date_Time__c != null) {
                        Long dur = (es.End_Date_Time__c.getTime() - es.Start_Date_Time__c.getTime()) / 1000 / 60;
                        duration = String.valueOf(dur);
                        
                        sessionTime = es.Start_Date_Time__c.format('hh:mm');
                        startTime = es.Start_Date_Time__c.format('hh:mm a');
                        endTime = es.End_Date_Time__c.format('hh:mm a');
                    }
                    
                    system.debug('es.Start_Date_Time__c == lastDay' + es.Start_Date_Time__c + '==' + lastDay);
                    Boolean sameDay = (es.Start_Date_Time__c.day() == lastDay.day() && es.Start_Date_Time__c.month() == lastDay.month() && es.Start_Date_Time__c.year() == lastDay.year());
                    
                    if(sameDay) {
                        if(es.Session_Type__c == 'Happening') {
                            AgendaItemsWrapper aiw = new AgendaItemsWrapper(es.Title__c, sessionTime, startTime, endTime, track, duration, NULL, 'session', 0, 0,0);
                            townItems.add(aiw);
                        } else {
                            List<SpeakerInfo> speakers = mapSpeakers.get(es.Id);
                            AgendaItemsWrapper aiw = new AgendaItemsWrapper(es.Title__c, sessionTime, startTime, endTime, track, duration, speakers, 'session', 0, 0,0);
                            agendaItems.add(aiw);                        
                        }
                    }
                    
                    if(!sameDay || sessionCnt == lstSessions.size()) {
                        totalDays++;
                        String dayTitle = null;
                        String dayFormatted = null;
                        if(dayCnt == 0) {
                            dayTitle = 'Day One';
                        } else if(dayCnt == 1) {
                            dayTitle = 'Day Two';
                        } else if(dayCnt == 2) {
                            dayTitle = 'Day Three';
                        } else if(dayCnt == 3) {
                            dayTitle = 'Day Four';
                        }
                        dayCnt++;
                        
                        dayFormatted = lastDay.format('EEEE, MMMM dd yyyy');
                        system.debug('dayFormatted:' + dayFormatted);
                        
                        List<AgendaItemsWrapper> saveAgendaItems = new List<AgendaItemsWrapper>();
                        for(AgendaItemsWrapper ai :agendaItems) {
                            saveAgendaItems.add(ai);
                        }
    
                        List<AgendaItemsWrapper> saveTownItems = new List<AgendaItemsWrapper>();
                        for(AgendaItemsWrapper ai :townItems) {
                            saveTownItems.add(ai);
                        }
    
                        AgendaDay ad = new AgendaDay(dayCnt, dayTitle, dayFormatted, saveAgendaItems, saveTownItems);
                        AgendaDays.add(ad);
                        
                                                
                        agendaItems = new List<AgendaItemsWrapper>();
                        townItems = new List<AgendaItemsWrapper>();
                        
                        if(es.Session_Type__c == 'Happening') {
                            AgendaItemsWrapper aiw = new AgendaItemsWrapper(es.Title__c, sessionTime, startTime, endTime, track, duration, NULL, 'session',0,0,0);
                            townItems.add(aiw);
                        } else {
                            List<SpeakerInfo> speakers = mapSpeakers.get(es.Id);
                            AgendaItemsWrapper aiw = new AgendaItemsWrapper(es.Title__c, sessionTime, startTime, endTime, track, duration, speakers, 'session',0,0,0);
                            agendaItems.add(aiw);                        
                        }
                        lastDay = es.Start_Date_Time__c;
                    }
                }    
                
                // Add Line Breaks
                Integer maxItemsPerPage = 7;
                Integer townCnt=0;
                Integer itemCnt=1;
                Integer totalPageCnt=1;
                
                for(AgendaDay ad: AgendaDays) {
                    if(ad.townItems != NULL) {
                        townCnt = ad.townItems.size()+1;
                    }
                    System.debug('maxItemsPerPage:' + maxItemsPerPage);
                    System.debug('townCnt:' + townCnt);
                    
                    itemCnt=1;
                    Integer pageCnt=1;
                    Integer totalPages= Integer.valueOf(Math.Ceil(Double.valueOf(ad.agendaItems.size())/Double.valueOf(maxItemsPerPage)));
                    
                    System.debug('totalItems:' + ad.agendaItems.size());
                    System.debug('totalPages:' + totalPages);
                    
                    List<AgendaItemsWrapper> saveAgendaItems = new List<AgendaItemsWrapper>();

                    // Add Page Number                    
                    AgendaItemsWrapper aiw = new AgendaItemsWrapper(null, null, null, null, null, null, null, 'pages',totalPageCnt,0,1);
                    saveAgendaItems.add(aiw);
                    System.debug('Add Page Number!' + aiw);
                    totalPageCnt++;
                    System.debug('totalPageCnt' + totalPageCnt);
                    
                    for(AgendaItemsWrapper ai :ad.agendaItems) {
                        
                        System.debug('pageCnt:' + pageCnt);
                        System.debug('itemCnt:' + itemCnt);
                        System.debug('totalPageCnt:' + totalPageCnt);
                        
                        saveAgendaItems.add(ai);
                        
                        if(itemCnt == maxItemsPerPage) {
                            System.debug('PageBreak!');
                            itemCnt=1;
                            aiw = new AgendaItemsWrapper(null, null, null, null, null, null, null, 'break',0,0,0);
                            saveAgendaItems.add(aiw);
                            
                            aiw = new AgendaItemsWrapper(null, null, null, null, null, null, null, 'pages',totalPageCnt,0,0);
                            saveAgendaItems.add(aiw);
                            System.debug('Add Page Number!' + aiw);
                            
                            totalPageCnt++;
                            System.debug('totalPageCnt' + totalPageCnt);
                        } else {
                            itemCnt++;                           
                        }
    
                    }
                    ad.agendaItems = saveAgendaItems;
                    
                    // Need break before Town Items?
                    if(ad.townItems != NULL && (itemCnt + townCnt) > maxItemsPerPage) {
                        System.debug('PageBreak - Town!');
                        aiw = new AgendaItemsWrapper(null, null, null, null, null, null, null, 'break',0,0,0);
                        saveAgendaItems.add(aiw);
                        pageCnt++;
                        itemCnt=1;
                        
                        
                        List<AgendaItemsWrapper> saveTownItems = new List<AgendaItemsWrapper>();
                        
                        aiw = new AgendaItemsWrapper(null, null, null, null, null, null, null, 'pages',totalPageCnt,0,0);
                        saveTownItems.add(aiw);
                        System.debug('Add Page Number!' + aiw);
                        
                        totalPageCnt++;
                        System.debug('totalPageCnt' + totalPageCnt);
                        for(AgendaItemsWrapper ti :ad.townItems) {
                            saveTownItems.add(ti);
                        }
                        ad.townItems = saveTownItems;
                    }
                }
                
                // Add Total Pages to Page Count
                totalPageCnt--;
                for(AgendaDay ad: AgendaDays) {
                    for(AgendaItemsWrapper ai :ad.agendaItems) {
                        if(ai.pageCount != 0) {
                            ai.totalPages = totalPageCnt;
                        }
                    }
                    if(ad.townItems != null) {
                        for(AgendaItemsWrapper ti :ad.townItems) {
                            if(ti.pageCount != 0) {
                                ti.totalPages = totalPageCnt;
                            }
                        }
                    }
                }
            }
        }
        
            
        system.debug('AgendaDays:' + AgendaDays);
    }
    
    
    public class AgendaDay {
        public Integer dayCount {get; set;}
        public String dayTitle {get; set;}
        public String dayFormatted {get; set;}
        public List<AgendaItemsWrapper> agendaItems {get; set;}
        public List<AgendaItemsWrapper> townItems {get; set;}
        
        public AgendaDay(Integer inDayCount, String inDayTitle, String inDayFormatted, List<AgendaItemsWrapper> inAgendaItems, List<AgendaItemsWrapper> intownItems) {
            dayCount = inDayCount;
            dayTitle = inDayTitle;
            dayFormatted = inDayFormatted;
            agendaItems = inAgendaItems;
            if(intownItems != NULL && intownItems.size() > 0) {
                townItems = intownItems;    
            } else {
                townItems = NULL;
            }
            
        }
    }
    
    public class SpeakerInfo {
        public String name {get; set;}
        Public String byLine {get; set;}        
    }
    
    public class AgendaItemsWrapper
    {

        public String title {get; set;}
        Public String sessionTime {get; set;}
        Public String startTime {get; set;}
        Public String endTime {get; set;}
        Public String track {get; set;}
        Public String duration {get; set;}
        Public List<SpeakerInfo> speakers {get; set;}
        Public String sessionType {get; set;}
        
        public Integer pageCount {get; set;}
        public Integer totalPages {get; set;}
        public Integer itemCount {get; set;}
        

        public AgendaItemsWrapper(String inTitle, String inSessionTime, String inStartTime, String inEndTime, String inTrack, String inDuration, List<SpeakerInfo> inSpeakers, String inSessionType, Integer inPageCount, Integer inTotalPages, Integer inItemCount)
        {
            title = inTitle;
            sessionTime = inSessionTime;
            startTime = inStartTime;
            endTime = inEndTime;
            track = inTrack;
            duration = inDuration;
            speakers = inSpeakers;
            sessionType = inSessionType;
            pageCount = inPageCount;
            totalPages = inTotalPages;
            itemCount = inItemCount;
        }
    }
}