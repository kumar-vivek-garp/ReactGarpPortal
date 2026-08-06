public class GARP_BC_SME {

    public static Boolean setSMEProfiles(List<String> inContactIds) {
    	Boolean retSuccess = True;
        
        Set<String> contactIds = new Set<String>();
        List<Contact> lstContacts = [select Id from Contact where id in :inContactIds];
        System.debug('lstContacts:' + lstContacts);
        
        for(Contact c :lstContacts) {
            contactIds.add(c.Id);
        }
        System.debug('contactIds:' + contactIds);
        
        // Get Data
         
        // SME
        List<SME_Registration__c> lstSMEProfiles = [select Id, Contact__c, System_Identification_Topic_Tags__c, 
                                                    System_Identification_Risk_Content_Areas__c,Event_Speaker_Count__c, Chapter_Speaker_Count__c, 
                                                    Webcast_Presenter_Count__c,Last_Event_Speaker_Date__c, Last_Chapter_Speaker_Date__c, 
                                                    Last_Webcast_Presenter_Date__c from SME_Registration__c 
                                                    where Contact__c in :contactIds];
        System.debug('lstSMEProfiles:' + lstSMEProfiles);
        
        MAP<String,SME_Registration__c> mapSMEProfile = new MAP<String,SME_Registration__c>();
        for(SME_Registration__c smp :lstSMEProfiles) {
            mapSMEProfile.put(smp.Contact__c, smp);
        }
        System.debug('mapSMEProfile:' + mapSMEProfile);
        
        // WEBCAST
        List<Presenter__c> lstWebcastPresentors = [select Id, Contact__c, Webcast__r.Name, Webcast__r.Topic_Tags__c, Webcast__r.Start_Date__c, Webcast__r.Risk_Content_Areas__c
                                                   from Presenter__c 
                                                   where Contact__c in :contactIds AND Webcast__c != NULL AND Webcast__r.Status__c = 'Active'];
        System.debug('lstWebcastPresentors:' + lstWebcastPresentors);
        
        MAP<String,List<Presenter__c>> mapWebcastPresentors = new MAP<String,List<Presenter__c>>();
        for(Presenter__c pres :lstWebcastPresentors) {
            List<Presenter__c> listPresentors = mapWebcastPresentors.get(pres.Contact__c);
            if(listPresentors == NULL) {
                listPresentors = new List<Presenter__c>();                
            }
            listPresentors.add(pres);
            mapWebcastPresentors.put(pres.Contact__c, listPresentors);
        }
        System.debug('mapWebcastPresentors:' + mapWebcastPresentors);
        
        // CHAPTERS
        List<Chapter_Speaker__c> lstChapSpeakers = [select Id, Contact__c from Chapter_Speaker__c where Contact__c in :contactIds];
        MAP<String,Chapter_Speaker__c> mapChaptSpeakers = new MAP<String,Chapter_Speaker__c>();
        for(Chapter_Speaker__c cs :lstChapSpeakers) {
            mapChaptSpeakers.put(cs.Id, cs);
        }
        System.debug('mapChaptSpeakers:' + mapChaptSpeakers);
        
        List<Chapter_Meeting_Speaker__c> lstChaptMeetSpeakers = [Select Id, Chapter_Speaker__c, Chapter_Meeting__r.Name, 
                                                                 Chapter_Meeting__r.Start_Date__c, Chapter_Meeting__r.Topic_Tags__c, Chapter_Meeting__r.Risk_Content_Areas__c
                                                                 From Chapter_Meeting_Speaker__c Where Chapter_Speaker__c in :mapChaptSpeakers.keySet() AND Chapter_Meeting__r.Status__c = 'Active'];
        System.debug('lstChaptMeetSpeakers:' + lstChaptMeetSpeakers);
        
        MAP<String,List<Chapter_Meeting_Speaker__c>> mapChaptMeetSpeakers = new MAP<String,List<Chapter_Meeting_Speaker__c>>();
        for(Chapter_Meeting_Speaker__c cms :lstChaptMeetSpeakers) {
            Chapter_Speaker__c fndChapterSpeakers = mapChaptSpeakers.get(cms.Chapter_Speaker__c);
            System.debug('fndChapterSpeakers:' + fndChapterSpeakers);
            
            if(fndChapterSpeakers != NULL) {
                List<Chapter_Meeting_Speaker__c> listChaptMeetingSpeakers = mapChaptMeetSpeakers.get(fndChapterSpeakers.Contact__c);
                System.debug('listChaptMeetingSpeakers:' + listChaptMeetingSpeakers);
                
                if(listChaptMeetingSpeakers == NULL) {
                    listChaptMeetingSpeakers = new List<Chapter_Meeting_Speaker__c>();                
                }
                listChaptMeetingSpeakers.add(cms);
                mapChaptMeetSpeakers.put(fndChapterSpeakers.Contact__c, listChaptMeetingSpeakers);
            }
        }
        System.debug('mapChaptMeetSpeakers:' + mapChaptMeetSpeakers);
        
        // EVENTS
        List<Event_Speaker__c> lstEventSpeakers = [select Id, Contact__c from Event_Speaker__c where Contact__c in :contactIds];
        System.debug('lstEventSpeakers:' + lstEventSpeakers);
        MAP<String,Event_Speaker__c> mapEventSpeakers = new MAP<String,Event_Speaker__c>();
        if(!lstEventSpeakers.isEmpty()) {
            for(Event_Speaker__c es :lstEventSpeakers) {
                mapEventSpeakers.put(es.Id, es);
            }
        }
        
        List<Event_Speaker_Session_Track__c> lstSST = [select Id, Event_Speaker__c, Event_Session__r.Event__r.Name, 
                                                       Event_Session__r.Event__r.Topic_Tags__c, Event_Session__r.Event__r.Start_Date__c, Event_Session__r.Event__r.Risk_Content_Areas__c
                                                      from Event_Speaker_Session_Track__c where Event_Speaker__c in :mapEventSpeakers.keySet() AND Event_Session__r.Event__r.Status__c ='Active'];
        MAP<String,List<Event_Speaker_Session_Track__c>> mapSessionSpeakers = new MAP<String,List<Event_Speaker_Session_Track__c>>();
        for(Event_Speaker_Session_Track__c cms :lstSST) {
            Event_Speaker__c fndEventSpeakers = mapEventSpeakers.get(cms.Event_Speaker__c);
            System.debug('fndEventSpeakers:' + fndEventSpeakers);
            
            if(fndEventSpeakers != NULL) {
                List<Event_Speaker_Session_Track__c> listSessionSpeakers = mapSessionSpeakers.get(fndEventSpeakers.Contact__c);
                System.debug('listSessionSpeakers:' + listSessionSpeakers);
                
                if(listSessionSpeakers == NULL) {
                    listSessionSpeakers = new List<Event_Speaker_Session_Track__c>();                
                }
                listSessionSpeakers.add(cms);
                mapSessionSpeakers.put(fndEventSpeakers.Contact__c, listSessionSpeakers);
            }
        }
        System.debug('mapSessionSpeakers:' + mapSessionSpeakers);
        
        // Process Data
        List<SME_Registration__c> listUpdateSME = new List<SME_Registration__c>();
        for(String contId :contactIds) {
            
            System.debug('Loop contId:' + contId);
            
            // SETUP
           // Set<String> topics = new Set<String>();
            Set<String> areas = new Set<String>();
            Integer webcastCount = 0;
            Integer chapterCount = 0;
            Integer eventCount = 0;
            Date tdy = Date.today();
            
            SME_Registration__c smeProfile = mapSMEProfile.get(contId);
            if(smeProfile == NULL) {
                smeProfile = new SME_Registration__c();
                smeProfile.Contact__c = contId;
            }
            System.debug('smeProfile:' + smeProfile);
            
            // Process Webcasts
            List<Presenter__c> listWebcastPresentors = mapWebcastPresentors.get(contId);
            if(listWebcastPresentors != NULL) {
                for(Presenter__c pres :listWebcastPresentors) {
                    //System.debug('pres topics:' + pres.Webcast__r.Topic_Tags__c);
                     System.debug('pres areas:' + pres.Webcast__r.Risk_Content_Areas__c);
                    
                    // Topics
                  /*  if(pres.Webcast__r.Topic_Tags__c != NULL) {
                        for(String topic: pres.Webcast__r.Topic_Tags__c.split(';')){
                            topics.add(topic);
                        }
                    }*/
                    
                    // Areas
                    if(pres.Webcast__r.Risk_Content_Areas__c!= NULL) {
                        for(String area: pres.Webcast__r.Risk_Content_Areas__c.split(';')){
                            areas.add(area);
                        }
                    }
                        
                    
                    //System.debug('topics:' + topics);
                    System.debug('Areas:' + Areas);
                    
                    // Speaking Count
                    System.debug('pres start date:' + pres.Webcast__r.Start_Date__c);
                    
                    if(pres.Webcast__r.Start_Date__c != NULL && pres.Webcast__r.Start_Date__c <= tdy) {
                        webcastCount++;
                        smeProfile.Last_Webcast_Presenter_Date__c = Date.valueOf(pres.Webcast__r.Start_Date__c);
                    }
                    System.debug('webcastCount:' + webcastCount);
                }
            }
            
            // Process Chapters
            List<Chapter_Meeting_Speaker__c> listChapterMeetingSpeakers = mapChaptMeetSpeakers.get(contId);
            System.debug('listChapterMeetingSpeakers:' + listChapterMeetingSpeakers);
            
            if(listChapterMeetingSpeakers != NULL) {
                for(Chapter_Meeting_Speaker__c cms :listChapterMeetingSpeakers) {
                    System.debug('cms:' + cms);
                    // Topics
                    /*if(cms.Chapter_Meeting__r.Topic_Tags__c != NULL) {                        
                        for(String topic: cms.Chapter_Meeting__r.Topic_Tags__c.split(';')){
                            // TODO: Need to normalize these topcis with Webcasts and Events
                            topics.add(topic);
                        }
                    }
                    System.debug('topics:' + topics);*/
                    
                    // Areas
                    
                   if(cms.Chapter_Meeting__r.Risk_Content_Areas__c != NULL) {                        
                        for(String area: cms.Chapter_Meeting__r.Risk_Content_Areas__c.split(';')){
                            //TODO: Need to normalize these topcis with Webcasts and Events
                            areas.add(area);
                        }
                    }
                    System.debug('areas:' + areas);
                    
                    
                    // Speaking Count
                    System.debug('cms start date:' + cms.Chapter_Meeting__r.Start_Date__c);
                    
                    if(cms.Chapter_Meeting__r.Start_Date__c != NULL && cms.Chapter_Meeting__r.Start_Date__c <= tdy) {
                        smeProfile.Last_Chapter_Speaker_Date__c = Date.valueOf(cms.Chapter_Meeting__r.Start_Date__c);
                        chapterCount++;
                    }
                    System.debug('chapterCount:' + chapterCount);
                }
            }
            
            // Process Events
            List<Event_Speaker_Session_Track__c> listSessionSpeakers = mapSessionSpeakers.get(contId);
            System.debug('listSessionSpeakers:' + listSessionSpeakers);
            
            if(listSessionSpeakers != NULL) {
                for(Event_Speaker_Session_Track__c cms :listSessionSpeakers) {
                    System.debug('cms:' + cms);
                    // Topics
                    /*if(cms.Event_Session__r.Event__r.Topic_Tags__c != NULL) {
                        for(String topic: cms.Event_Session__r.Event__r.Topic_Tags__c.split(';')){
                            topics.add(topic);
                        }
                    }
                    System.debug('topics:' + topics);*/
                    
                    //Areas
                    if(cms.Event_Session__r.Event__r.Risk_Content_Areas__c!= NULL) {
                        for(String area: cms.Event_Session__r.Event__r.Risk_Content_Areas__c.split(';')){
                           areas.add(area);
                        }
                    }
                    System.debug('areas:' + areas);
                    
                    // Speaking Count
                    System.debug('cms start date:' + cms.Event_Session__r.Event__r.Start_Date__c);
                    
                    if(cms.Event_Session__r.Event__r.Start_Date__c != NULL && cms.Event_Session__r.Event__r.Start_Date__c <= tdy) {
                        smeProfile.Last_Event_Speaker_Date__c = Date.valueOf(cms.Event_Session__r.Event__r.Start_Date__c);
                        eventCount++;
                    }
                    System.debug('eventCount:' + eventCount);
                }
            }
            
            // Final Update
           // System.debug('topics:' + topics);
              System.debug('areas:' + areas);
            
          /*  smeProfile.System_Identification_Topic_Tags__c = '';
            for(String top :topics) {
                smeProfile.System_Identification_Topic_Tags__c += top + ';';
            }*/
            
            smeProfile.System_Identification_Risk_Content_Areas__c = '';
            for(String top :areas) {
                smeProfile.System_Identification_Risk_Content_Areas__c += top + ';';
            }
            
            smeProfile.Webcast_Presenter_Count__c = webcastCount;
            smeProfile.Chapter_Speaker_Count__c = chapterCount;
            smeProfile.Event_Speaker_Count__c = eventCount;
            System.debug('smeProfile:' + smeProfile);
            
            listUpdateSME.add(smeProfile);
        }
        
        System.debug('listUpdateSME:' + listUpdateSME);
        upsert listUpdateSME;
        
        return retSuccess;
    }
    
    @InvocableMethod(label='GARP SME' description= 'Call setSMEProfiles Method.')

        public static void setSMEProfilesInvocable(List<List<String>> inputParams){
            system.debug('inputParams:' +inputParams);
            if(!inputParams.isEmpty()){
            setSMEProfiles(inputParams[0]);  
                
          }
        
        } 
      
 
}