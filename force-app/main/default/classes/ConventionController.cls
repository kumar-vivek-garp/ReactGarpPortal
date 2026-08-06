global class ConventionController { 
    
    public class Wrapper{
        public EventWrapper parent { get; set; }
        public List<EventWrapper> children { get; set; }
    }
        
    public class EventWrapper {
        public Event__c event { get; set; }
        public Event_Rate__c eventRate { get; set; }
        public List<EventSessionWrapper> eventSessions { get; set; }
        public Event_Registration__c eventRegistration { get; set; }
        public List <cdrive__Cloud_Files__c> eventImages { get; set; } 
    }
    
    public class EventSessionWrapper{
        public Event_Speaker__c eventSpeaker { get; set; }
        public Event_Sessions__c eventSession { get; set; }
        public Event_Session_Registration__c eventSessionRegistration { get; set; }
    }
       
    public static Map<Id, Event_Registration__c> createEventRegistrationByEventIdMapUsingContactId(String contactId){
                
        /**
         * Retrieve Event Registrations WHERE:
         * The contactId is the ContactId of the current user
         * The year of the Convention is in the current year or future years (would only break for Events spanning across years)
         * Creates a map of Event Registrations by Event ID
         */
       
        Map<Id, Event_Registration__c> eventRegistrationByEventId = new Map<Id, Event_Registration__c>();
        
        for(Event_Registration__c er: [
            SELECT 
                Id, 
                Contact__c,
                Member_Email__c,
                Registration_ID__c,            
                Contact__r.KPI_FRM_Certified__c,
                Contact__r.KPI_ERP_Certified__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Title,
                Contact__r.Company__c,
                Contact__r.Corporate_Title__c,
                Contact__r.Area_of_Concentration__c,
                Contact__r.MobilePhone,
                Contact__r.Job_Function__c,
                Contact__r.Risk_Specialty__c,
                User__r.FirstName,
                User__r.LastName,
                Dietary_Restriction__c, 
                Dietary_Restriction_Description__c,
                Dietary_Restriction_Types__c,
                Special_Requirements__c,
                Professional_Designations__c ,
                Emergency_Contact_Name__c,
                Emergency_Contact_Phone__c,
                Status__c,
                Event__c,
                Event__r.RecordTypeId,
                Event__r.RecordType.Name,
                Event__r.Start_Date__c,
                Event__r.Invite_Only__c,
                Event__r.Hide_Address_fields__c,
                Event__r.Title__c,
                Event__r.Max_Capacity_Met__c,
                Event__r.Content__r.Custom_Header__c,
                Event__r.Content__r.Custom_Footer__c,
                Event__r.Time_Zone__r.Name,
                Event__r.Online_Meeting_URL__c,
                Event__r.Online_Meeting_Notes__c,
                Event__r.Delivery_Method__c, 
                Contact__r.How_Did_You_Hear_About_Us__c,
                Contact__r.Professional_Designation_ACCA__c,
                Contact__r.Professional_Designation_CA__c,
                Contact__r.Professional_Designation_CFA__c,
                Contact__r.Professional_Designation_CMA__c,
                Contact__r.Professional_Designation_CPA__c,
                Contact__r.Professional_Designation_Other__c,
                Opportunity__c,
                Opportunity__r.Invoice_Paid_Status__c,
                Opportunity__r.Display_Invoice_Number__c,
                Opportunity__r.Amount
            FROM 
                Event_Registration__c
            WHERE 
                Contact__c = :contactId AND 
                Event__c != null AND 
                CALENDAR_YEAR(Event__r.Start_Date__c) >= :Datetime.now().year()
            ORDER BY 
                Event__r.Start_Date__c DESC
        ]){
            eventRegistrationByEventId.put(er.Event__c, er);
        }  
        
        return eventRegistrationByEventId;
    }
    
    public static Map<Id, Event_Registration__c> createEventRegistrationByEventIdMapUsingContactIdAndEventId (String contactId, String eventId){
                
        /**
         * Retrieve Event Registrations WHERE:
         * The contactId is the ContactId of the current user
         * The Event__r.Id OR Event__r.Parent_Event__c IS EQUAL TO the eventId parameter     
         * Creates a map of Event Registrations by Event ID
         */
       
        Map<Id, Event_Registration__c> eventRegistrationByEventId = new Map<Id, Event_Registration__c>();
        
        for(Event_Registration__c er: [
            SELECT 
                Id, 
                Contact__c,
                Member_Email__c,
                Registration_ID__c,            
                Contact__r.KPI_FRM_Certified__c,
                Contact__r.KPI_ERP_Certified__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Title,
                Contact__r.Company__c,
                Contact__r.Corporate_Title__c,
                Contact__r.Area_of_Concentration__c,
                Contact__r.MobilePhone,
                Contact__r.Job_Function__c,
                Contact__r.Risk_Specialty__c,
                User__r.FirstName,
                User__r.LastName,
                Dietary_Restriction__c, 
                Dietary_Restriction_Description__c,
                Dietary_Restriction_Types__c,
                Special_Requirements__c,
                Professional_Designations__c ,
                Emergency_Contact_Name__c,
                Emergency_Contact_Phone__c,
                Status__c,
                Attendee_Type__c,
                Event__c,
                Event__r.RecordTypeId,
                Event__r.RecordType.Name,
                Event__r.Start_Date__c,
                Event__r.Invite_Only__c,
                Event__r.Parent_Event__c,
                Event__r.Title__c,
                Event__r.Hide_Address_fields__c,
                Event__r.Max_Capacity_Met__c,
                Event__r.Content__r.Custom_Header__c,
                Event__r.Content__r.Custom_Footer__c,
                Event__r.Time_Zone__r.Name,
                Event__r.Online_Meeting_URL__c,
                Event__r.Online_Meeting_Notes__c,       
                Event__r.Delivery_Method__c,         
                Contact__r.Professional_Designation_ACCA__c,
                Contact__r.Professional_Designation_CA__c,
                Contact__r.Professional_Designation_CFA__c,
                Contact__r.Professional_Designation_CMA__c,
                Contact__r.Professional_Designation_CPA__c,
                Contact__r.Professional_Designation_Other__c,
                Contact__r.How_Did_You_Hear_About_Us__c,
                Opportunity__c,
                Opportunity__r.Invoice_Paid_Status__c,
                Opportunity__r.Display_Invoice_Number__c,
                Opportunity__r.Amount
            FROM 
                Event_Registration__c
            WHERE 
                Contact__c = :contactId AND 
                (Event__c = :eventId OR Event__r.Parent_Event__c = :eventId)
            ORDER BY 
                Event__r.Start_Date__c DESC
        ]){
            eventRegistrationByEventId.put(er.Event__c, er);
        }  
        
        return eventRegistrationByEventId;
    }
    
    public static Map<Id, Event_Rate__c> createEventRateByEventIdMap (Set<Id> eventIds){
        
        /**
        * Retrieves the Event Rates for the given date
        * and puts them in a map by Event ID
        */ 
        
        Map<Id, Event_Rate__c> eventRateByEventId = new Map<Id, Event_Rate__c>();
        
        for(Event_Rate__c er: [
            SELECT 
            Id, 
            Name, 
            Event__c,
            Member_Rate__c, 
            Non_Member_Rate__c,
            RPT_Grace_Period__c,
            RPT_Last_Date_for_Rate_Effectiveness__c,
            Start_Date__c,
            End_Date__c 
            FROM Event_Rate__c 
            WHERE Event__c IN :eventIds AND Start_Date__c <= :Date.today() AND End_Date__c >= :Date.today()
        ]){
            eventRateByEventId.put(er.Event__c, er);
        }
        
        return eventRateByEventId;
    }
    
    public static Map<Id, Event__c> createEventByEventIdMap (Set<Id> eventIds){
        
        /**
        * Creates a map of events by Event ID. 
        */ 
        
        return new Map<Id, Event__c>([
            SELECT 
            Id, 
            Name,
            Parent_Event__c,
            Start_Date__c,
            End_Date__c,
            RecordTypeId,
            Description__c,
            Byline__c,
            Overview__c,
            Address__c,
            VenueName__c,
            Invite_Only__c,
            Title__c,
            Hide_Address_fields__c,
            Time_Zone__c,
            Time_Zone__r.Name,
            Max_Capacity_Met__c,
            RSVP_Waitlist_Copy__c,
            Bypass_Information_Collection_Page__c,
            Content__r.Custom_Header__c,
            Content__r.Custom_Footer__c,
            Content__r.Form__r.Form_Name__c, 
            Event_Background_Image__c,
            ON24_Event_Id__c, 
            ON24_URL__c,
            Online_Meeting_URL__c,
            Online_Meeting_Notes__c,
            Delivery_Method__c                      
            FROM Event__c
            WHERE Id IN :eventIds OR Parent_Event__c IN :eventIds
        ]);      
        
    }
    
    public static Map<Id, List<EventSessionWrapper>> createEventSessionByEventIdMap (Set<Id> eventIds, Set<Id> eventRegistrationIds){
                     
        /**
        * Creates a map of lists of EventSessionWrappers 
        * (i.e. Event Session joined with an Event Session Registration) by event ID.
        */ 
        
        Map<Id, List<EventSessionWrapper>> eventSessionByIdMap = new Map<Id, List<EventSessionWrapper>>();
        
        List<Event_Sessions__c> eventSessions = [
            SELECT 
            Id, 
            Name, 
            Title__c,
            Subtitle__c,
            Event__c, 
            Status__c, 
            Start_Date_Time__c, 
            Description__c,
            End_Date_Time__c,
            Event_Session_Track__c,
            Certified_Only__c,  
            Show_On_Summary_Schedule__c,    
            Show_in_List_View__c,   
            Show_in_Registration_Agenda_Builder__c, 
            Show_in_Manage_Agenda_Builder__c,    
            Type__c,  
            (
                SELECT Id, Name, Event_Session__c, Event_Registration__c 
                FROM Event_Session_Registrations__r 
                WHERE Event_Registration__c IN :eventRegistrationIds LIMIT 1
            ),
            (
                SELECT Id, Name, Role__c, Event_Session__c, Event_Speaker__r.First_Name__c, Event_Speaker__r.Last_Name__c, Event_Speaker__r.Byline__c   
                FROM Event_Speaker_Session_Tracks__r
            )
            FROM Event_Sessions__c 
            WHERE Event__c != null AND Event__c IN :eventIds
        ];
        
        for(Event_Sessions__c es: eventSessions){
            
            EventSessionWrapper esw = new EventSessionWrapper();           
            esw.eventSession = es;            
            for(Event_Session_Registration__c esr: es.Event_Session_Registrations__r){
                esw.eventSessionRegistration = esr;
            }
            
            if(eventSessionByIdMap.containsKey(es.Event__c)){   
                
                /**
                * If containsKey(es.Event__c) a list has already been initialized, 
                * so just add the given element to the list for map the given map key.
                */
                
                eventSessionByIdMap.get(es.Event__c).add(esw);
                
            }else{                  
                
                /**
                * If no key exists in the map, initialize a new list and insert the
                * given element and put the list into the map at the given key. 
                */
                
                eventSessionByIdMap.put(es.Event__c, new List<EventSessionWrapper>{esw});
                
            }   
            
        }
        
        return eventSessionByIdMap;
        
    }
    
    public static Map<Id, List<cdrive__Cloud_Files__c>> createEventImagesByEventIdMap(Set<Id> eventIds){
        
        Map<Id, List<cdrive__Cloud_Files__c>> eventImagesByEventIdMap = new Map<Id, List<cdrive__Cloud_Files__c>>();
        for(cdrive__Cloud_Files__c file :[
            SELECT 
            Id, 
            cdrive__contextID__c, 
            cdrive__File_Name__c 
            FROM cdrive__Cloud_Files__c 
            WHERE cdrive__contextID__c = :eventIds 
        ]){
            if(eventImagesByEventIdMap.containsKey(file.cdrive__contextID__c)){
                eventImagesByEventIdMap.get(file.cdrive__contextID__c).add(file);
            }else{
                eventImagesByEventIdMap.put(file.cdrive__contextID__c, new List<cdrive__Cloud_Files__c>{file});
            }
        }
               
        return eventImagesByEventIdMap;
               
    }
    
    public static Set<Id> getEventRegistrationIds(Map<Id, Event_Registration__c> eventRegistrationByEventId){      
        Set<Id> eventRegistrationIds = new Set<Id>(); 
        for(Event_Registration__c er: eventRegistrationByEventId.values()){
            eventRegistrationIds.add(er.Id);
        }
        return eventRegistrationIds;
    }
    
    @RemoteAction
    public static Response.Detail getEventRegistrationByEventRegistrationId(String eventRegistrationId){
        
        Response.Detail res = new Response.Detail();
        
        List<Event_Registration__c> eventRegistrations = [
            SELECT 
            Id, 
            Name, 
            Registration_ID__c,
            Opportunity__c, 
            Opportunity__r.Display_Invoice_Number__c, 
            Event__c, 
            Event__r.Start_Date__c,
            Event__r.End_Date__c, 
            Event__r.Name, 
            Event__r.Description__c,
            Event__r.VenueName__c,
            Event__r.Address__c,
            Event__r.RecordTypeId,
            Event__r.RecordType.Name,
            Event__r.Invite_Only__c,
            Event__r.Title__c,
            Event__r.Hide_Address_fields__c,
            Event__r.Time_Zone__r.Name,
            Event__r.Max_Capacity_Met__c,
            Event__r.Online_Meeting_URL__c,
            Event__r.Online_Meeting_Notes__c,
            Event__r.Delivery_Method__c,
            Event__r.ON24_Event_Id__c,
            Event__r.ON24_URL__c
            FROM Event_Registration__c
            WHERE Id = :eventRegistrationId
        ];
        
        if(eventRegistrations.isEmpty()){
            res.status = 404;
            res.message = 'Unable to locate record with ID ' + eventRegistrationId;
        }else{
            res.data = eventRegistrations[0];
            res.status = 200;
            res.message = 'Successfully located record with ID ' + eventRegistrationId; 
        }
        
        return res;
        
    }
    
    @RemoteAction
    public static List<Wrapper> getRegistrationsByContactIdAndEventId(String contactId, String eventId){
        
        Map<Id, Event_Registration__c> eventRegistrationByEventId = null;
        
        if(eventId != null){
            eventRegistrationByEventId = createEventRegistrationByEventIdMapUsingContactIdAndEventId(contactId, eventId);
        }else{
            eventRegistrationByEventId = createEventRegistrationByEventIdMapUsingContactId(contactId);
        }
        
        Map<Id, Event__c> eventByEventId = createEventByEventIdMap(eventRegistrationByEventId.keySet());
        
        Set<Id> eventRegistrationIds = new Set<Id>(getEventRegistrationIds(eventRegistrationByEventId));
        Set<Id> eventIds = new Set<Id>(eventByEventId.keySet());

        Map<Id, Event_Rate__c> eventRateByEventId = createEventRateByEventIdMap(eventIds);
        Map<Id, List<cdrive__Cloud_Files__c>> eventImagesByEventId = createEventImagesByEventIdMap(eventIds);
        Map<Id, List<EventSessionWrapper>> eventSessionsByEventId = createEventSessionByEventIdMap(eventIds, eventRegistrationIds);
                            
        Map<Id, EventWrapper> parentEvents = new Map<Id, EventWrapper>();
        Map<Id, List<EventWrapper>> childEvents = new Map<Id, List<EventWrapper>>();
             
        for(String key: eventIds){
            
            /**
            * Joins all related sObject records by Event ID
            * in a the EventWrapper object.
            */
            
            EventWrapper ew = new EventWrapper();

            ew.event = (eventByEventId.containsKey(key))                            ? eventByEventId.get(key) : null;            
            ew.eventRate = (eventRateByEventId.containsKey(key))                    ? eventRateByEventId.get(key) : null;
            ew.eventImages = (eventImagesByEventId.containsKey(key))                ? eventImagesByEventId.get(key) : null;
            ew.eventSessions = (eventSessionsByEventId.containsKey(key))            ? eventSessionsByEventId.get(key) : null;
            ew.eventRegistration = (eventRegistrationByEventId.containsKey(key))    ? eventRegistrationByEventId.get(key) : null;
            
            if(eventId == null){
            
                Id parentEventId = eventByEventId.get(key).Parent_Event__c;
                
                if(parentEventId != null){                
                    if(childEvents.containsKey(parentEventId)){                    
                        childEvents.get(parentEventId).add(ew);                    
                    }else{                    
                        childEvents.put(parentEventId, new List<EventWrapper>{ew});                    
                    }                
                }else{
                    parentEvents.put(key, ew);            
                }
                
            }else{
                
                Id parentEventId = eventId;
                
                if(parentEventId != key){
                    if(childEvents.containsKey(parentEventId)){                    
                        childEvents.get(parentEventId).add(ew);                    
                    }else{                    
                        childEvents.put(parentEventId, new List<EventWrapper>{ew});                    
                    }
                }else{
                    parentEvents.put(key, ew);
                }
                
            }
            
        }
        
        String conventionRecordType = RecordTypeHelper.GetRecordTypeId('Event__c', 'Convention');
        
        List<Wrapper> relatedEvents = new List<Wrapper>();   
        for(String key: parentEvents.keySet()){
            
            Wrapper w = new Wrapper();
            w.parent = parentEvents.get(key);   

            if(childEvents.containsKey(key)){
                if(!childEvents.get(key).isEmpty()){
                    w.children = childEvents.get(key);
                }
            }
            
            /**
             * Ensures only Parents of type "Convention" are included in the dataset
             * if no eventId is defined.  If the eventId is defined don't exlude any
             * related events.
             */
            if(eventId == null){
                if(w.parent.event.RecordTypeId == conventionRecordType){
                    relatedEvents.add(w);
                }
            }else{
                relatedEvents.add(w);
            }

        }
        
        return relatedEvents;
        
    }
       
    @RemoteAction
    public static Object getProfessionalDesignationsMetadata(){
        
        /**
        * Retrieves the Professional Designations
        * picklist values and returns them to client.
        */ 
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Event_Registration__c').getDescribe().fields.getMap();
        return fieldMap.get('Professional_Designations__c').getDescribe().getPicklistValues();
        
    } 
    
    @RemoteAction
    public static Object getDietaryRestrictionTypesMetadata(){
        
        /**
        * Retrieves the Dietary Restriction Types
        * picklist values and returns them to client.
        */ 
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Event_Registration__c').getDescribe().fields.getMap();        
        return fieldMap.get('Dietary_Restriction_Types__c').getDescribe().getPicklistValues();
        
    } 
    
    @RemoteAction
    public static List<Wrapper> updateEventRegistration (String eventRegistrationJSON){
        
        /**
        * Updates the entire Event Registration
        * and returns the updated data model to client.
        */  
        
        Event_Registration__c eventRegistration = null;
        if(eventRegistrationJSON != null) eventRegistration = (Event_Registration__c)JSON.deserialize(eventRegistrationJSON, Event_Registration__c.class); 
        
        if(eventRegistration != null){
            UPDATE eventRegistration;   
            if(eventRegistration.Contact__r != null){
                UPDATE eventRegistration.Contact__r;
            }
            return getRegistrationsByContactIdAndEventId(eventRegistration.Contact__c, eventRegistration.Event__c);
        }
        
        return null;
        
    }
    
    @RemoteAction
    public static List<Wrapper> updateEventRegistrationPersonalInformation (String eventRegistrationJSON){
        
        /**
        * Updates the defined info fields on
        * the Event Registration and returns the updated
        * data model to client.
        */   
        
        Event_Registration__c eventRegistration = null;
        if(eventRegistrationJSON != null) eventRegistration = (Event_Registration__c)JSON.deserialize(eventRegistrationJSON, Event_Registration__c.class); 
        
        if(eventRegistration != null && eventRegistration.Contact__r != null){
            
            Contact toUpdate = new Contact();
            toUpdate.Id = eventRegistration.Contact__c;
            toUpdate.Title = eventRegistration.Contact__r.Title;
            toUpdate.Company__c = eventRegistration.Contact__r.Company__c;
            toUpdate.Corporate_Title__c = eventRegistration.Contact__r.Corporate_Title__c;
            toUpdate.Area_of_Concentration__c = eventRegistration.Contact__r.Area_of_Concentration__c;
            toUpdate.MobilePhone = eventRegistration.Contact__r.MobilePhone;
            toUpdate.Job_Function__c = eventRegistration.Contact__r.Job_Function__c;
            toUpdate.Risk_Specialty__c = eventRegistration.Contact__r.Risk_Specialty__c;
            
            UPDATE toUpdate; 
            
            return getRegistrationsByContactIdAndEventId(eventRegistration.Contact__c, eventRegistration.Event__c);
            
        }
        
        return null;
        
    }
    
    @RemoteAction
    public static List<Wrapper> updateEventRegistrationDietaryRestrictions (String eventRegistrationJSON){
        
        /**
        * Updates the Dietary Restriction fields on
        * the Event Registration and returns the updated
        * data model to client.
        */   
        
        Event_Registration__c eventRegistration = null;
        if(eventRegistrationJSON != null) eventRegistration = (Event_Registration__c)JSON.deserialize(eventRegistrationJSON, Event_Registration__c.class); 
        
        if(eventRegistration != null){
            
            Event_Registration__c toUpdate = new Event_Registration__c();
            toUpdate.Id = eventRegistration.Id;
            toUpdate.Dietary_Restriction__c = eventRegistration.Dietary_Restriction__c;
            toUpdate.Dietary_Restriction_Types__c = eventRegistration.Dietary_Restriction_Types__c;
            toUpdate.Dietary_Restriction_Description__c = eventRegistration.Dietary_Restriction_Description__c;
            
            UPDATE toUpdate; 
            
            return getRegistrationsByContactIdAndEventId(eventRegistration.Contact__c, eventRegistration.Event__c);
            
        }
        
        return null;
        
    }
    
    @RemoteAction
    public static List<Wrapper> updateEventRegistrationProfessionalDesignations (String eventRegistrationJSON){
     
        /**
        * Updates the Professional Designations field on
        * the Event Registration and returns the updated
        * data model to client.
        */   
        
        Event_Registration__c eventRegistration = null;
        if(eventRegistrationJSON != null) eventRegistration = (Event_Registration__c)JSON.deserialize(eventRegistrationJSON, Event_Registration__c.class); 
        
        if(eventRegistration != null){
            
            Event_Registration__c toUpdate = new Event_Registration__c();
            toUpdate.Id = eventRegistration.Id;
            toUpdate.Professional_Designations__c = eventRegistration.Professional_Designations__c;
            
            UPDATE toUpdate; 
            
            return getRegistrationsByContactIdAndEventId(eventRegistration.Contact__c, eventRegistration.Event__c);
            
        }
        
        return null;
        
    }
    
    @RemoteAction
    public static List<Wrapper> updateEventRegistrationSpecialRequirements (String eventRegistrationJSON){
        
        /**
        * Updates the Special Requirements fields on
        * the Event Registration and returns the updated
        * data model to client.
        */       
        
        Event_Registration__c eventRegistration = null;
        if(eventRegistrationJSON != null) eventRegistration = (Event_Registration__c)JSON.deserialize(eventRegistrationJSON, Event_Registration__c.class); 
        
        if(eventRegistration != null){
            
            Event_Registration__c toUpdate = new Event_Registration__c();
            toUpdate.Id = eventRegistration.Id;
            toUpdate.Special_Requirements__c = eventRegistration.Special_Requirements__c;
            
            UPDATE toUpdate; 
            
            return getRegistrationsByContactIdAndEventId(eventRegistration.Contact__c, eventRegistration.Event__c);
            
        }
        
        return null;
        
    }
    
    @RemoteAction
    public static List<Wrapper> updateEventRegistrationEmergencyContact (String eventRegistrationJSON){
        
        /**
        * Updates the Emergency Contact fields on
        * the Event Registration and returns the updated
        * data model to client.
        */
        
        Event_Registration__c eventRegistration = null;
        if(eventRegistrationJSON != null) eventRegistration = (Event_Registration__c)JSON.deserialize(eventRegistrationJSON, Event_Registration__c.class); 
        
        if(eventRegistration != null){
            
            Event_Registration__c toUpdate = new Event_Registration__c();
            toUpdate.Id = eventRegistration.Id;
            toUpdate.Emergency_Contact_Name__c = eventRegistration.Emergency_Contact_Name__c;
            toUpdate.Emergency_Contact_Phone__c = eventRegistration.Emergency_Contact_Phone__c;
            
            UPDATE toUpdate; 
            
            return getRegistrationsByContactIdAndEventId(eventRegistration.Contact__c, eventRegistration.Event__c);
            
        }
        
        return null;
        
    }
    
    @RemoteAction
    public static String addEventSessionRegistrationByContact(String contactId, String eventId, String sessionId){
        
        List<Event_Registration__c> lstReg = [select Id, Name from Event_Registration__c where Contact__c = :contactId AND Event__c = :eventId];
        
        if(lstReg != NULL && lstReg.size() > 0) {
            
            List<Event_Sessions__c> lstSess = [Select Id, Name, Status__c from Event_Sessions__c where Id = :sessionId and Status__c = 'Active'];
            if(lstSess != NULL && lstSess.size() > 0) {
                        
                List<Event_Session_Registration__c> lstSessReg = [select Id from Event_Session_Registration__c where Event_Registration__c = :lstReg[0].Id AND Event_Session__c = :sessionId];
                
                if(lstSessReg == NULL || lstSessReg.size() == 0) {
                    
                    Event_Session_Registration__c es = new Event_Session_Registration__c();
                    es.Event_Registration__c = lstReg[0].Id;
                    es.Event_Session__c = sessionId;
                    insert es;
                    
                    return 'OK';
                    
                } else {
                    return 'Already registered for this session';
                }
                
            } else {
                return 'Session not found';
            }
            
        } else {
            return 'Registration not found';   
        }
        

    }
    
    @RemoteAction
    public static Event_Session_Registration__c insertDeleteEventSessionRegistration(String eventRegistrationId, String eventSessionId){
        
        Event_Registration__c eventRegistration = [
            SELECT Id, Contact__c, Event__c 
            FROM Event_Registration__c 
            WHERE Id = :eventRegistrationId LIMIT 1
        ];
        
        if(eventRegistration != null){
            
            List<Event_Session_Registration__c> eventSessionRegistrations = [
                SELECT Id, Event_Session__c, Event_Registration__c 
                FROM Event_Session_Registration__c
                WHERE Event_Registration__c = :eventRegistrationId AND Event_Session__c = :eventSessionId
                LIMIT 1
            ];
            
            if(eventSessionRegistrations.isEmpty()){
                
                Event_Session_Registration__c eventSessionRegistration = new Event_Session_Registration__c(
                    Event_Session__c = eventSessionId, 
                    Event_Registration__c = eventRegistrationId
                );
                
                INSERT eventSessionRegistration;
                
                return eventSessionRegistration;
                
            }else{
                
                DELETE eventSessionRegistrations;
                
            }

        }
        
        return null;
        
    }

    @RemoteAction
    public static List<Wrapper> insertDeleteEventSessionRegistrations(String eventRegistrationId, String toInsert, String toDelete){
              
        /**
        * Updates the users' Event Session Registrations
        * and returns the updated data model to client.  
        */
        
        List<Event_Session_Registration__c> toInsertList;
        List<Event_Session_Registration__c> toDeleteList;
        
        if(toInsert != null) toInsertList = (List<Event_Session_Registration__c>)JSON.deserialize(toInsert, List<Event_Session_Registration__c>.class);  
        if(toDelete != null) toDeleteList = (List<Event_Session_Registration__c>)JSON.deserialize(toDelete, List<Event_Session_Registration__c>.class);

        Event_Registration__c eventRegistration = [SELECT Id, Contact__c, Event__c FROM Event_Registration__c WHERE Id = :eventRegistrationId LIMIT 1];
        
        if(eventRegistration != null){
            
            if(toInsertList != null && !toInsertList.isEmpty()) INSERT toInsertList;
            if(toDeleteList != null && !toDeleteList.isEmpty()) DELETE toDeleteList;
            
            return getRegistrationsByContactIdAndEventId(eventRegistration.Contact__c, eventRegistration.Event__c);
            
        }
        
        return null;
        
    }
    
    @RemoteAction
    public static Map<String, List<Schema.PicklistEntry>> fetchContactPicklistValues(){
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        
        Map<String, List<Schema.PicklistEntry>> picklistValuesByFieldName = new Map<String, List<Schema.PicklistEntry>>();
        
        for(String fieldName: fieldMap.keySet()){
            if(fieldMap.containsKey(fieldName)){
                
                Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
                
                List<Schema.PicklistEntry> getPicklistValues = fieldMap.get(fieldName).getDescribe().getPicklistValues();
                
                if(getPicklistValues != null && !getPicklistValues.isEmpty()){
                    picklistValuesByFieldName.put(field.Name, getPicklistValues);
                }
                    
            }
        }
               
        return picklistValuesByFieldName;
        
    }
    
    
    public ConventionController(sfdcAppRemoter ctrl){}
    
}