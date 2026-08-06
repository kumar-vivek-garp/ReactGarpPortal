public class EventsHelper{
    
    public class Event{
        public String eventType         { get; set; }
        public sObject event            { get; set; }
        public List<Speaker> speakers   { get; set; }
    }
    
    public class Speaker{
        
        public String id                { get; set; }
        public String firstName         { get; set; }
        public String lastName          { get; set; }
        public String biography         { get; set; }
        public String qualifications    { get; set; }
        
        public Speaker(String id, String firstName, String lastName, String biography, String qualifications){
            this.id             = id;
            this.firstName      = firstName;
            this.lastName       = lastName;  
            this.biography      = biography; 
            this.qualifications = qualifications; 
        }
        
    }
     
    public static Event fetchEventData(Id eventId, Id contactId){
        Map<Id, Event__c> eventsMap = new Map<Id, Event__c>([
            SELECT 
            Id,
            Name,
            Address__c,
            AddressMap_Image_URL__c,
            AlreadyRegisteredLink__c,
            Book_Hotel_Link__c,
            Cancellation_Policy__c,
            Can_Pay_By_wire__c,
            Can_Register__c,
            Chapter_Meeting__c,
            Content_Folder__c,
            Convert_ID__c,
            CPD_Credit__c,
            Delivery_Method__c,
            Description__c,
            Duration__c,
            DynamicNgClass__c,
            End_Date__c,
            Event_Day__c,
            Event_Last_Wire_Check_Day__c,
            Events_Photography_Release__c,
            GL_Code__c,
            Hashtag__c,
            Last_Date_For_Registration__c,
            Last_Date_for_Wire_Check_Registration__c,
            Overview__c,
            ON24_URL__c,
            Online_Meeting_URL__c,
            Online_Meeting_Notes__c,
            Parent_Event__c,
            Photo_Album_Link__c,
            Post_Event_Description__c,
            Product_Code__c,
            Program_Change__c,
            RegisterNowLink__c,
            Start_Date__c,
            Status__c,
            Title__c,
            Vanity_URL__c,
            Venue_Guidelines__c,
            VenueName__c,
            Custom_Location__c,
            Invite_Only__c,
            Approval_Required__c,
            Hide_Address_fields__c,
            Time_Zone__r.Abbreviation__c, 
            Time_Zone__r.Name, 
            Time_Zone__r.Add_This_Event_Zone__c, 
            RSVP_Activity_Name__c, RSVP_Activity_Location__c, RSVP_Activity_Start_Date_Time__c, RSVP_Activity_End_Date_Time__c, RSVP_Activity_Online_Meeting_URL__c,
            RecordTypeId,
            RecordType.Name,
            Content__c,
            Content__r.Id,
            Content__r.Name,
            Content__r.Location__c,
            Content__r.Description__c,
            Content__r.Event_Start_Date_Time__c,
            Content__r.Event_End_Date_Time__c,
            Content__r.Content_Name__c, 
            Content__r.Image__c, 
            Content__r.Raw_HTML__c, 
            Content__r.Duration_in_Minutes__c, 
            Content__r.Record_Type_Name__c,
            Content__r.Third_Party_URL__c,
            Content__r.Other_Description__c,
            (SELECT Id, Contact__c, Status__c, Approval_Status__c FROM Event_Registrations__r WHERE Contact__c = :contactId and Status__c != 'Cancelled')
            FROM Event__c 
            WHERE Content__c != null AND Id = :eventId
        ]);   
        
        Map<Id, Event_Sessions__c> eventSessionsMap = new Map<Id, Event_Sessions__c>([
            SELECT Id, Event__c FROM Event_Sessions__c WHERE Event__c IN :eventsMap.keySet()
        ]);
        
        Map<Id, Event_Speaker_Session_Track__c> eventSpeakerSessionTracksMap = new Map<Id, Event_Speaker_Session_Track__c>([
            SELECT Id, Event_Session__c, Event_Speaker__c FROM Event_Speaker_Session_Track__c WHERE Event_Session__c IN :eventSessionsMap.keySet()
        ]);
        
        Map<Id, Event_Speaker__c> eventSpeakersMap = new Map<Id, Event_Speaker__c>([
            SELECT Id, First_Name__c, Last_Name__c, Photo__c, Status__c, Bio__c, Byline__c, Company_Title_1__c, Company_Title_2__c, Company_Title_3__c FROM Event_Speaker__c
        ]);
        
        List<Event> events = new List<Event>();        
        for(Event__c event: eventsMap.values()){
            
            Event e = new Event();
            
            e.event     = event;
            e.speakers  = new List<Speaker>();
            e.eventType = event.RecordType.Name;
            
            for(Event_Sessions__c eventSession: eventSessionsMap.values()){
                if(event.Id == eventSession.Event__c){
                    for(Event_Speaker_Session_Track__c eventSpeakerSessionTrack: eventSpeakerSessionTracksMap.values()){
                        if(eventSession.Id == eventSpeakerSessionTrack.Event_Session__c && eventSpeakersMap.containsKey(eventSpeakerSessionTrack.Event_Speaker__c)){
                            
                            Event_Speaker__c eventSpeaker = eventSpeakersMap.get(eventSpeakerSessionTrack.Event_Speaker__c);
                                             
                            Speaker speaker = new Speaker(
                                eventSpeaker.Id, 
                                eventSpeaker.First_Name__c, 
                                eventSpeaker.Last_Name__c,
                                eventSpeaker.Bio__c,
                                eventSpeaker.Byline__c
                            );
                            
                            e.speakers.add(speaker);
                            
                        }
                    }
                }
            }
            
            events.add(e);
            
        }
        
        return (!events.isEmpty()) ? events[0] : null;
        
    }
    
    public static Event fetchWebcastData(Id eventId, Id contactId){
        
        Map<Id, Webcast__c> webcastsMap = new Map<Id, Webcast__c> ([
            SELECT 
            Id, 
            Name, 
            Description__c, 
            Short_Description__c,
            Duration__c, 
            End_Date__c, 
            Image__c, 
            Start_Date__c, 
            Status__c, 
            Title__c, 
            Convert_ID__c, 
            On_Demand_URL__c,
            Time_Zone__r.Abbreviation__c, 
            Time_Zone__r.Name, 
            Time_Zone__r.Add_This_Event_Zone__c, 
            Content__c,
            Content__r.Id,
            Content__r.Name,
            Content__r.Location__c,
            Content__r.Description__c,
            Content__r.Event_Start_Date_Time__c,
            Content__r.Event_End_Date_Time__c,
            Content__r.Content_Name__c, 
            Content__r.Image__c, 
            Content__r.Raw_HTML__c, 
            Content__r.Duration_in_Minutes__c, 
            Content__r.Record_Type_Name__c,
            Content__r.Third_Party_URL__c,
            Content__r.Other_Description__c,
            (SELECT Id, Contact__c, Status__c FROM Webcast_Registrations__r WHERE Contact__c = :contactId)
            FROM Webcast__c
            WHERE Content__c != null AND Id = :eventId
        ]);  
        
        Map<Id, Presenter__c> presentersMap = new Map<Id, Presenter__c>([
            SELECT Id, Name, Contact__c, Role__c, Webcast__c, Contact__r.FirstName, Contact__r.LastName
            FROM Presenter__c 
            WHERE Webcast__c IN :webcastsMap.keySet()
        ]);
        
        List<Event> events = new List<Event>();
        for(Webcast__c webcast: webcastsMap.values()){
            
            Event e = new Event();
            
            webcast.Content__r.Location__c = 'Online';
            
            e.event = webcast;
            e.speakers = new List<Speaker>();
            e.eventType = 'Webcast';
            
            for(Presenter__c presenter: presentersMap.values()){
                if(webcast.Id == presenter.Webcast__c){
                    
                    Speaker speaker = new Speaker(
                        presenter.Id, 
                        presenter.Contact__r.FirstName, 
                        presenter.Contact__r.LastName, 
                        null,
                        null
                    );
                    
                    e.speakers.add(speaker);
                    
                }
            }    
            
            events.add(e);
            
        }
        
        return (!events.isEmpty()) ? events[0] : null;
        
    }
    
    public static Event fetchChapterMeetingData(Id eventId, Id contactId){
        
        Map<Id, Chapter_Meeting__c> chapterMeetingsMap = new Map<Id, Chapter_Meeting__c>([
            SELECT 
            Id, 
            Name, 
            Delivery_Method__c,
            Virtual_Start_DateTime__c,
            Virtual_End_DateTime__c,
            Virtual_Meeting_URL__c,
            Virtual_Meeting_Instructions__c,
            In_Person_Title__c,
            Virtual_Title__c,
            Estimated_Cost__c, 
            Chapter_Meeting_Name__c, 
            Synopsis__c, 
            Last_Day_of_Registration__c, 
            NonMemberFee__c, 
            Cancellation_Policy__c, 
            Payment_Policy__c, 
            Start__c, 
            End__c, 
            Is_Sponsored__c, 
            Sponsor_Information__c, 
            Sponsor_Logo__c, 
            Sponsor_Name__c, 
            Sponsor_Website__c, 
            Time_Zone__r.Abbreviation__c, 
            Time_Zone__r.Name, 
            Time_Zone__r.Add_This_Event_Zone__c, 
            Status__c, 
            Chapter__c, 
            Chapter__r.Name, 
            Chapter_Meeting_Location__r.Building_Name__c, 
            Chapter_Meeting_Location__r.Address_Street_1__c, 
            Chapter_Meeting_Location__r.Address_Street_2__c, 
            Chapter_Meeting_Location__r.Venue_Location__c, 
            Chapter_Meeting_Location__r.Address_City__c, 
            Chapter_Meeting_Location__r.Address_State_Provence__c , 
            Chapter_Meeting_Location__r.Name, 
            Chapter_Meeting_Location__r.Address_Postal_Code__c, 
            Chapter_Meeting_Location__r.Address_Country__c, 
            Presentation__c, 
            Ceremony__c, 
            Group_Formation__c,
            ON24_API_Key__c,
            ON24_Event_Id__c,
            ON24_URL__c,
            Content__c,
            Content__r.Id,
            Content__r.Name,
            Content__r.Location__c,
            Content__r.Description__c,
            Content__r.Event_Start_Date_Time__c,
            Content__r.Event_End_Date_Time__c,
            Content__r.Content_Name__c, 
            Content__r.Image__c, 
            Content__r.Raw_HTML__c, 
            Content__r.Duration_in_Minutes__c, 
            Content__r.Record_Type_Name__c,
            Content__r.Third_Party_URL__c,
            Content__r.Other_Description__c,
            (SELECT Id, Contact__c, Status__c FROM Chapter_Meeting_Registrations__r WHERE Contact__c = :contactId)
            FROM Chapter_Meeting__c
            WHERE Content__c != null AND Id = :eventId
        ]);
        
        Map<Id, Chapter_Meeting_Speaker__c> chapterSpeakersMap = new Map<Id, Chapter_Meeting_Speaker__c>([
            SELECT 
            Id, 
            Content__c, 
            Chapter_Meeting__c, 
            Role__c, 
            Chapter_Speaker__c, 
            Chapter_Speaker__r.Biography__c, 
            Chapter_Speaker__r.Contact__c, 
            Chapter_Speaker__r.Contact__r.FirstName, 
            Chapter_Speaker__r.Contact__r.LastName,
            Chapter_Speaker__r.First_Name__c,
            Chapter_Speaker__r.Last_Name__c,
            Chapter_Speaker__r.Industry__c,
            Chapter_Speaker__r.Often_travels_to__c,
            Chapter_Speaker__r.Primary_Location__c,
            Chapter_Speaker__r.Qualifications__c,
            Chapter_Speaker__r.Speech_Topics__c
            FROM Chapter_Meeting_Speaker__c 
            WHERE Chapter_Meeting__c IN :chapterMeetingsMap.keySet()
        ]);
        
        List<Event> events = new List<Event>();
        for(Chapter_Meeting__c chapterMeeting: chapterMeetingsMap.values()){
            
            Event e = new Event();
            
            e.event = chapterMeeting;
            e.speakers = new List<Speaker>();
            e.eventType = 'Chapter Meeting';
            
            for(Chapter_Meeting_Speaker__c chapterMeetingSpeaker: chapterSpeakersMap.values()){
                if(chapterMeeting.Id == chapterMeetingSpeaker.Chapter_Meeting__c){
                    
                    Speaker speaker = new Speaker(
                        chapterMeetingSpeaker.Id, 
                        chapterMeetingSpeaker.Chapter_Speaker__r.First_Name__c,
                        chapterMeetingSpeaker.Chapter_Speaker__r.Last_Name__c, 
                        chapterMeetingSpeaker.Chapter_Speaker__r.Biography__c,
                        chapterMeetingSpeaker.Chapter_Speaker__r.Qualifications__c
                    );
                    
                    e.speakers.add(speaker);
                    
                }
            }    
            
            events.add(e);
            
        }
        
        return (!events.isEmpty()) ? events[0] : null;
        
    }
    
    public static Event fetchEventDetails(String eventId){
        
        Id userId = UserInfo.getUserId();
        System.debug('userId' + userId);
        
        if(userId != null){
            List<User> users = [SELECT Id, ContactId FROM User WHERE Id = :userId LIMIT 1];
            if(!users.isEmpty()){
                
                Id contactId = users[0].ContactId;
                System.debug('users' + users);
                System.debug('contactId' + contactId);
                
                List<Event__c> events = [SELECT Id FROM Event__c WHERE Id = :eventId];
                List<Webcast__c> webcasts = [SELECT Id FROM Webcast__c WHERE Id = :eventId];
                List<Chapter_Meeting__c> chapterMeetings = [SELECT Id FROM Chapter_Meeting__c WHERE Id = :eventId];
                System.debug('chapterMeetings ==' + chapterMeetings);
                if(!events.isEmpty()){
                    System.debug('fetchEventData');
                    return fetchEventData(events[0].Id, contactId);
                }else if(!webcasts.isEmpty()){
                    System.debug('fetchWebcastData');
                    return fetchWebcastData(webcasts[0].Id, contactId);
                }else if(!chapterMeetings.isEmpty()){
                    System.debug('fetchChapterMeetingData' + chapterMeetings[0].Id + ',' + 'contactId' + contactId);
                    return fetchChapterMeetingData(chapterMeetings[0].Id, contactId);
                }
                
            }
        }
        
        return null;
        
    } 
    
}