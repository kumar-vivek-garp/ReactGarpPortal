public class EventController {

    public class RegistrationWrapper{
        public String id                                    { get; set; }
        public String title                                 { get; set; }
        public String type                                  { get; set; }
        public Datetime starts_at                           { get; set; }
        public Datetime ends_at                             { get; set; }
        public Datetime starts_at_epoch                     { get; set; }
        public Chapter_Meeting_Registration__c chapterEvent { get; set; }
        public Event_Registration__c garpEvent              { get; set; }
        public Webcast_Registration__c webcastEvent         { get; set; }  
        public Event_Registration__c conventionEvent        { get; set; }
    }


    public static Map<Id, Event_Registration__c> getEventRegistrationsByEventEmail (String emailAddress){
        
        Map<Id, Event_Registration__c> output = new Map<Id, Event_Registration__c>();
        
        for(Event_Registration__c er: [
            SELECT
            Id,
            Name,
            Member_Email__c,
            Registration_ID__c,
            Status__c,
            Contact__c,
            Contact__r.KPI_Member__c,
            Event__c,
            Event__r.RecordType.Name,
            Event__r.Name,
            Event__r.Start_Date__c,
            Event__r.End_Date__c,
            Event__r.Title__c,
            Event__r.Description__c,
            Event__r.Duration__c,
            Event__r.Address__c,
            Event__r.Time_Zone__r.Name,
            Event__r.Max_Capacity_Met__c,
            Event__r.Online_Meeting_URL__c
            FROM Event_Registration__c
            WHERE Event__r.End_Date__c > :System.now() AND Member_Email__c = :emailAddress AND Event__c != null
        ]){
            output.put(er.Event__c, er);
        }
        
        return output;
    }

    
    public static Map<Id, Event_Registration__c> getEventRegistrationsByEventId (String contactId){
        
        Map<Id, Event_Registration__c> output = new Map<Id, Event_Registration__c>();
        
        for(Event_Registration__c er: [
            SELECT
            Id,
            Name,
            Member_Email__c,
            Registration_ID__c,
            Status__c,
            Contact__c,
            Event__c,
            Event__r.RecordType.Name,
            Event__r.Name,
            Event__r.Start_Date__c,
            Event__r.End_Date__c,
            Event__r.Title__c,
            Event__r.Description__c,
            Event__r.Duration__c,
            Event__r.Address__c,
            Event__r.Time_Zone__r.Name,
            Event__r.Max_Capacity_Met__c,
            Event__r.Online_Meeting_URL__c
            FROM Event_Registration__c
            WHERE Event__r.End_Date__c > :System.now() AND Contact__c = :contactId AND Event__c != null
        ]){
            output.put(er.Event__c, er);
        }
        
        return output;
    }
    
    public static Map<Id, Webcast_Registration__c> getWebcastRegistrationByWebcastId (String contactId){
       
        Map<Id, Webcast_Registration__c> output = new Map<Id, Webcast_Registration__c>();
        
        for(Webcast_Registration__c wr: [
            SELECT 
            Id, 
            Name,
            Status__c,
            Contact__c,
            Webcast__c,
            Webcast__r.Name,
            Webcast__r.Start_Date__c,
            Webcast__r.End_Date__c,
            Webcast__r.Title__c,
            Webcast__r.Description__c,
            Webcast__r.Time_Zone__r.Name
            FROM Webcast_Registration__c
            WHERE Webcast__r.End_Date__c > :System.now() AND Contact__c = :contactId AND Webcast__c != null
        ]){
            output.put(wr.Webcast__c, wr);  
        }
        
        return output;
        
    }
    
    public static Map<Id, Chapter_Meeting_Registration__c> getChapterMeetingRegistrationsByChapterMeetingId (String contactId){
        
        Map<Id, Chapter_Meeting_Registration__c> output = new Map<Id, Chapter_Meeting_Registration__c>();
        
        for(Chapter_Meeting_Registration__c cmr: [
            SELECT
            Id,
            Name,
            Chapter_Meeting_Name__c,
            Status__c,
            Contact__c,
            Chapter_Meeting__c,
            Chapter_Meeting__r.Name,
            Chapter_Meeting__r.Chapter_Meeting_Name__c,
            Chapter_Meeting__r.Start__c,
            Chapter_Meeting__r.Start_Date__c,
            Chapter_Meeting__r.End__c, 
            Chapter_Meeting__r.Registered__c,
            Chapter_Meeting__r.Shipping_Address__c,
            Chapter_Meeting__r.Shipping_Address_1__c,
            Chapter_Meeting__r.Shipping_Address_2__c,   
            Chapter_Meeting__r.Shipping_Address_3__c,   
            Chapter_Meeting__r.Shipping_Address_City__c,    
            Chapter_Meeting__r.Shipping_Address_Company__c, 
            Chapter_Meeting__r.Shipping_Address_Contact_Name__c,    
            Chapter_Meeting__r.Shipping_Address_Country__c, 
            Chapter_Meeting__r.Shipping_Address_Email__c,
            Chapter_Meeting__r.Shipping_Address_Phone__c,   
            Chapter_Meeting__r.Shipping_Address_State__c,
            Chapter_Meeting__r.Shipping_Address_Zip_Code__c,
            Chapter_Meeting__r.Sponsor_Information__c,
            Chapter_Meeting__r.Time_Zone__r.Abbreviation__c
            FROM Chapter_Meeting_Registration__c
            WHERE Chapter_Meeting__r.End__c > :System.now() AND Contact__c = :contactId AND Chapter_Meeting__c != null
        ]){
            output.put(cmr.Chapter_Meeting__c, cmr);
        }
        
        return output;
        
    }
    
    
    
    @RemoteAction
    public static Map<Id, Event_Registration__c> getEventsByEmailAddress(String emailAddress){
        Map<Id, Event_Registration__c> eventRegistrationsByEventId = getEventRegistrationsByEventEmail(emailAddress);
        return eventRegistrationsByEventId;
    }
        
    @RemoteAction
    public static List<RegistrationWrapper> getEventsByContactId(String contactId){
              
        Map<Id, Event_Registration__c> eventRegistrationsByEventId = getEventRegistrationsByEventId(contactId);
        Map<Id, Webcast_Registration__c> webcastRegistrationByWebcastId = getWebcastRegistrationByWebcastId(contactId);
        Map<Id, Chapter_Meeting_Registration__c> chapterMeetingRegistrationsByChapterMeetingId = getChapterMeetingRegistrationsByChapterMeetingId(contactId);            
        
        List<RegistrationWrapper> output = new List<RegistrationWrapper>();
        
        for(Event_Registration__c er: eventRegistrationsByEventId.values()){
            
            RegistrationWrapper rw = new RegistrationWrapper();    
            
            if(er.Event__r.RecordType.Name == 'Convention'){
                rw.id = er.Event__c;                                    
                rw.title = er.Event__r.Title__c;                                
                rw.type = 'special';                                    
                rw.starts_at = er.Event__r.Start_Date__c;                           
                rw.ends_at = er.Event__r.End_Date__c;                               
                rw.starts_at_epoch = er.Event__r.Start_Date__c;         
                rw.chapterEvent = null;
                rw.garpEvent = null;    
                rw.webcastEvent = null;     
                rw.conventionEvent = er;        
            }else{
                rw.id = er.Event__c;                                    
                rw.title = er.Event__r.Title__c;                                
                rw.type = 'success';                                    
                rw.starts_at = er.Event__r.Start_Date__c;                           
                rw.ends_at = er.Event__r.End_Date__c;                               
                rw.starts_at_epoch = er.Event__r.Start_Date__c;         
                rw.chapterEvent = null;
                rw.garpEvent = er;  
                rw.webcastEvent = null;     
                rw.conventionEvent = null;                  
            }
            
            output.add(rw);
            
        }
        
        for(Webcast_Registration__c wr: webcastRegistrationByWebcastId.values()){
            
            RegistrationWrapper rw = new RegistrationWrapper(); 
            
            rw.id = wr.Webcast__c;                                  
            rw.title = wr.Webcast__r.Title__c;                              
            rw.type = 'warn';//defines color of marker (pulled from calendar)                                   
            rw.starts_at = wr.Webcast__r.Start_Date__c;                         
            rw.ends_at = wr.Webcast__r.End_Date__c;                             
            rw.starts_at_epoch = wr.Webcast__r.Start_Date__c;           
            rw.chapterEvent = null;
            rw.garpEvent = null;    
            rw.webcastEvent = wr;   
            rw.conventionEvent = null; 
            
            output.add(rw);    
            
        }
        
        for(Chapter_Meeting_Registration__c cmr: chapterMeetingRegistrationsByChapterMeetingId.values()){
            
            RegistrationWrapper rw = new RegistrationWrapper(); 
            
            rw.id = cmr.Chapter_Meeting__c;                                 
            if(cmr.Chapter_Meeting__r.Chapter_Meeting_Name__c != null){
                rw.title = cmr.Chapter_Meeting__r.Chapter_Meeting_Name__c + ' - ' + cmr.Chapter_Meeting__r.Name + ' Chapter';
            }else{
                rw.title = cmr.Chapter_Meeting__r.Name + ' Chapter Meeting';
            }
            rw.type = 'info';//defines color of marker (pulled from calendar)                                   
            rw.starts_at = cmr.Chapter_Meeting__r.Start_Date__c;                            
            rw.ends_at = cmr.Chapter_Meeting__r.End__c;                             
            rw.starts_at_epoch = cmr.Chapter_Meeting__r.Start_Date__c;          
            rw.chapterEvent = cmr;
            rw.garpEvent = null;    
            rw.webcastEvent = null;     
            rw.conventionEvent = null; 
            
            output.add(rw);           
            
        }
        
        
        return output;
        
    }
    
    @RemoteAction
    public static Chapter_Meeting_Registration__c updateChapterMeetingRegistrationStatus(String chapterMeetingRegistrationId, String status){
        
    	Chapter_Meeting_Registration__c cmr = [
            SELECT Id, Chapter_Meeting__c, Contact__c, Status__c 
            FROM Chapter_Meeting_Registration__c 
            WHERE Id = :chapterMeetingRegistrationId
        ];
        
        if(cmr != null){
            
            cmr.Status__c = status;
            
            UPDATE cmr;
            
            Map<Id, Chapter_Meeting_Registration__c> chapterMeetingRegistrationsMap = getChapterMeetingRegistrationsByChapterMeetingId(cmr.Contact__c);
            
            return chapterMeetingRegistrationsMap.get(cmr.Chapter_Meeting__c);
            
        }
        
        return null;
        
    }
    
    public EventController(sfdcAppRemoter ctrl){}
    
}