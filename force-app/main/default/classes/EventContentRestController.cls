@RestResource(urlMapping='/eventContent')
global without sharing class EventContentRestController {
    
    global class Wrapper{
        public List<cdrive__Cloud_Files__c> cloudImages             { get; set; }
        public List<Content_Folders__c> featuredContentInformation  { get; set; }
        public List<Content__c> featuredEventContents               { get; set; }
        public List<Content__c> allEventContents                    { get; set; }   
    }
    
    public static Set<Id> getContentIds(List<Content__c> eventContentObjects){
        Set<Id> contentIds = new Set<Id>();
        for(Content__c content : eventContentObjects){
            contentIds.add(content.Id);
        }
        return contentIds;
    }
     
    public static List<Content_Folders__c> getFeaturedContentInformation() {
        return [
            SELECT 
            Id, 
            Content__c,
            Content__r.Name,
            Content__r.Hidden__c,
            Sort_Number__c,
            Content__r.Event_Start_Date_Time__c
            FROM Content_Folders__c
            WHERE 
            Folder__r.Site_Context__c       = 'root' AND 
            Folder__r.Section_Context__c    = 'my-events' AND 
            Folder__r.Domain_Context__c     = 'event' AND 
            Folder__r.View_Context__c       = 'featured'  
        ];
    }
    
    public static List<cdrive__Cloud_Files__c> getEventCloudImages(Set<Id> contentIds) {
        List<cdrive__Cloud_Files__c> result = [
            SELECT Id, 
            cdrive__contextID__c, 
            cdrive__File_Name__c 
            FROM cdrive__Cloud_Files__c 
            WHERE cdrive__contextID__c in :contentIds
        ];
        return result;
    }
       
    @HttpGet
    @RemoteAction
    global static Wrapper doGet() {
        
        List<Content__c> allEventsContent = getEventContents();
        
        // ACL
        String userId = UserInfo.getUserId();
        List<User> lstUser = [Select Id, Name, Email, ContactId, Username from User where Id = :userId];
        
        
        if(lstUser != NULL && lstUser.size() > 0) {
            if(lstUser[0].Name != 'GARP Membership') {
                String contactId = lstUser[0].ContactId;
                // Is Logged in User
                // Allow Invite Only Events
                List<Event_Registration__c> lstER = [select Id, Status__c, Event__c from Event_Registration__c where Contact__c = :contactId];
                
                MAP<String,String> mapEventReg = new MAP<String,String>();
                for(Event_Registration__c er :lstER) {
                    mapEventReg.put(er.Event__c, er.Status__c);
                }
                
                List<Content__c> allEventsContentNew = new List<Content__c>();
                
                for(Content__c c :allEventsContent) {
                    
                    Boolean hide = false;                
                    // AG 3/22/2023 - Hide if Content Hidden OR Invite only and no Show in Portal    
                    if(c.Hidden__c == true || (c.Events__r != null && c.Events__r.size() > 0 && c.Events__r[0].Invite_Only__c && c.Events__r[0].Show_In_Portal__c == False))  {
                        hide = true;
                        if(c.Events__r != null && c.Events__r.size() > 0) {                            
                            String eventId = c.Events__r[0].Id;
                            String fndReg = mapEventReg.get(eventId);
                            if(fndReg != NULL) {
                                hide = false;
                                //system.assert(false, 'BOOM!'+ eventId + '~' + fndReg);
                            }
                        }
                    }
                    if(!hide) {
                        allEventsContentNew.add(c);
                    }
                }
                allEventsContent = allEventsContentNew;
                
            }
        }
        
        
        Set<Id> contentIds = getContentIds(allEventsContent);
        
        Wrapper response = new Wrapper();
        
        response.allEventContents = allEventsContent;
        response.cloudImages = getEventCloudImages(contentIds);
        
        response.featuredContentInformation = getFeaturedContentInformation();
        
        return response;
        
    }
        
    @RemoteAction
    global static Wrapper fetchFeaturedEventContent(){
        
        List<Content__c> featuredEventContent = getFeaturedEventContents();
        Set<Id> contentIds = getContentIds(featuredEventContent);

        Wrapper response = new Wrapper();
        
        response.featuredEventContents = getFeaturedEventContents();   
        response.cloudImages = getEventCloudImages(contentIds);
        
        return response;
        
    }

    @RemoteAction
    global static List<Content__c> getFeaturedEventContents() {
        return [
            SELECT 
            Id, 
            Content_Name__c, 
            Vanity_URL__c, 
            Description__c, 
            Image__c, 
            Location__c, 
            Raw_HTML__c, 
            Event_Start_Date_Time__c, 
            Event_End_Date_Time__c, 
            Duration_in_Minutes__c, 
            Record_Type_Name__c,
            Status__c,
            Hidden__c,
            Third_Party_URL__c,
            (
                SELECT Id, Time_Zone__r.Name, Time_Zone__r.Time_Zone__c, Max_Capacity_Met__c, RSVP_Waitlist_Copy__c, Online_Meeting_URL__c, Invite_Only__c, RecordTypeId,Hide_Address_fields__c,RecordType.Name
                FROM Events__r
            ),
            (
                SELECT Id, Time_Zone__r.Name, Time_Zone__r.Time_Zone__c, ON24_URL__c
                FROM Chapter_Meetings__r
            ),
            (
                SELECT Id, Time_Zone__r.Name, Time_Zone__r.Time_Zone__c, On_Demand_URL__c 
                FROM Webcasts__r
            ),
            (
                SELECT Id, Sort_Number__c
                FROM Content_Folders__r 
            )
            FROM Content__c 
            WHERE 
            RecordType.Name = 'Event' AND
            Status__c = 'Active' AND
            Event_Start_Date_Time__c != null AND 
            Event_End_Date_Time__c != null AND
            Id IN (
                SELECT Content__c
                FROM Content_Folders__c
                WHERE 
                Folder__r.Site_Context__c       = 'root' AND 
                Folder__r.Section_Context__c    = 'my-events' AND 
                Folder__r.Domain_Context__c     = 'event' AND 
                Folder__r.View_Context__c       = 'featured'  
            )
            ORDER BY Event_Start_Date_Time__c DESC
        ];
    }
    
    @RemoteAction
    global static List<Content__c> getEventContents() {
        return [
            SELECT 
            Id, 
            Content_Name__c, 
            Vanity_URL__c, 
            Description__c, 
            Image__c, 
            Location__c, 
            Raw_HTML__c, 
            Event_Start_Date_Time__c, 
            Event_End_Date_Time__c, 
            Duration_in_Minutes__c, 
            Record_Type_Name__c,
            Status__c,
            Hidden__c,
            Third_Party_URL__c,
            (
                SELECT Id, Time_Zone__r.Name, Time_Zone__r.Time_Zone__c, Max_Capacity_Met__c, RSVP_Waitlist_Copy__c, ON24_URL__c, Online_Meeting_URL__c, Online_Meeting_Notes__c, Invite_Only__c, RecordTypeId, RecordType.Name, Hide_Address_fields__c, Delivery_Method__c, Show_In_Portal__c, Is_Pay_For_Event__c 
                FROM Events__r
            ),
            (
                SELECT Id, Time_Zone__r.Name, Time_Zone__r.Time_Zone__c, ON24_URL__c, Delivery_Method__c
                FROM Chapter_Meetings__r
            ),
            (
                SELECT Id, Time_Zone__r.Name, Time_Zone__r.Time_Zone__c, On_Demand_URL__c 
                FROM Webcasts__r
            )
            FROM Content__c 
            WHERE 
            RecordType.Name = 'Event' AND
            Status__c = 'Active' AND
            Event_Start_Date_Time__c != null AND 
            Event_End_Date_Time__c != null AND
            Id IN (
                SELECT Content__c
                FROM Content_Folders__c
                WHERE 
                Folder__r.Site_Context__c       = 'root' AND 
                Folder__r.Section_Context__c    = 'my-events' AND 
                Folder__r.Domain_Context__c     = 'event' AND 
                Folder__r.View_Context__c       = 'all'  
            )
            ORDER BY Event_Start_Date_Time__c DESC
            LIMIT 100
        ];
    }
   
    public EventContentRestController(sfdcAppRemoter ctrl){}
    
}