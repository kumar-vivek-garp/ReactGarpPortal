@isTest
public class ConventionControllerTest {
       
    @testSetup
    public static void setup(){
        // EventMobiApiBatch is Deleted
        //EventMobiApiBatch.disableBatch = true;

        INSERT new Remote_Sites__c(
            Name = 'EventMobi', 
            Site_URL__c = 'http://test.com'
        );
        
        INSERT new EventMobi_Configuration__c(
            Name = 'X-API-KEY', 
            Value__c = 'asasdasdasd'
        );
        
        INSERT new EventMobi_Configuration__c(
            Name = 'EVENT-ID', 
            Value__c = 'test-event-id'
        );

        String recordTypeEventConvention    = RecordTypeHelper.GetRecordTypeId('Event__c', 'Convention');
        String recordTypeEventNonConvention = RecordTypeHelper.GetRecordTypeId('Event__c', 'Non-Convention');
        
        Event__c parentEvent = new Event__c();
        parentEvent.RecordTypeId    = recordTypeEventConvention;
        parentEvent.Start_Date__c   = Date.today().addDays(58);
        parentEvent.End_Date__c     = Date.today().addDays(60);
        parentEvent.Name            = 'PARENT EVENT';
        INSERT parentEvent;
        
        Event_Sessions__c eventSessions = new Event_Sessions__c();
        eventSessions.Name = 'TEST EVENT SESSION';
        eventSessions.Event__c = parentEvent.Id;
        eventSessions.Status__c = 'Active';
        INSERT eventSessions;
        
        Event__c childEvent1 = new Event__c();
        childEvent1.Start_Date__c   = Date.today().addDays(58);
        childEvent1.End_Date__c     = Date.today().addDays(60);
        childEvent1.Name            = 'CHILD EVENT 1';
        childEvent1.Parent_Event__c = parentEvent.Id;
        INSERT childEvent1;
        
        Event__c childEvent2 = new Event__c();
        childEvent2.Start_Date__c   = Date.today().addDays(58);
        childEvent2.End_Date__c     = Date.today().addDays(60);
        childEvent2.Name            = 'CHILD EVENT 2';
        childEvent2.Parent_Event__c = parentEvent.Id;
        INSERT childEvent2;
        
        Event_Rate__c parentEventRate = new Event_Rate__c();
        parentEventRate.Start_Date__c   = Date.today().addDays(-10);
        parentEventRate.End_Date__c     = Date.today().addDays(10);
        parentEventRate.Event__c        = parentEvent.Id;
        INSERT parentEventRate;
        
        Event_Rate__c child1EventRate = new Event_Rate__c();
        child1EventRate.Start_Date__c   = Date.today().addDays(-10);
        child1EventRate.End_Date__c     = Date.today().addDays(10);
        child1EventRate.Event__c        = childEvent1.Id;
        INSERT child1EventRate; 
        
        Event_Rate__c child2EventRate = new Event_Rate__c();
        child2EventRate.Start_Date__c   = Date.today().addDays(-10);
        child2EventRate.End_Date__c     = Date.today().addDays(10);
        child2EventRate.Event__c        = childEvent2.Id;
        INSERT child2EventRate;     
        
        Account account = new Account();
        account.Name = 'TEST ACCOUNT';
        INSERT account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'TEST FIRST NAME';
        contact.LastName = 'TEST LAST NAME';
        contact.Email ='test@test.com';
        INSERT contact;
        
        Event_Registration__c eventRegistrationForParentEvent = new Event_Registration__c();
        eventRegistrationForParentEvent.Contact__c = contact.Id;
        eventRegistrationForParentEvent.Event__c = parentEvent.Id;
        INSERT eventRegistrationForParentEvent;
        
        Event_Session_Registration__c eventSessionRegistration = new Event_Session_Registration__c();
        eventSessionRegistration.Event_Session__c = eventSessions.Id;
        eventSessionRegistration.Event_Registration__c = eventRegistrationForParentEvent.Id;
        INSERT eventSessionRegistration;
        
        Event_Registration__c eventRegistrationForChildEvent = new Event_Registration__c();
        eventRegistrationForChildEvent.Contact__c = contact.Id;
        eventRegistrationForChildEvent.Event__c = childEvent1.Id;
        INSERT eventRegistrationForChildEvent;

    }
    
    @isTest 
    public static void getRegistrationsByContactIdAndEventId(){
        
        String contactId    = [SELECT Id FROM Contact LIMIT 1].Id;
        String eventId      = [SELECT Id, Contact__c, Event__c FROM Event_Registration__c WHERE Contact__c = :contactId AND Event__c != NULL LIMIT 1].Id;
        
        ConventionController.getRegistrationsByContactIdAndEventId(contactId, eventId); 
    }
    
    @isTest 
    public static void getDietaryRestrictionTypesMetadata(){
        ConventionController.getDietaryRestrictionTypesMetadata();
    }
    
    @isTest 
    public static void getProfessionalDesignationsMetadata(){
        ConventionController.getProfessionalDesignationsMetadata();
    }
    
    @isTest 
    public static void updateEventRegistration(){
        
        Event_Registration__c er = [
            SELECT Id, Name, Dietary_Restriction__c, Dietary_Restriction_Description__c, Dietary_Restriction_Types__c 
            FROM Event_Registration__c 
            LIMIT 1
        ];
        
        er.Dietary_Restriction__c = TRUE;
        er.Dietary_Restriction_Description__c = 'TEST';
            
        ConventionController.updateEventRegistration(JSON.serialize(er));
        
    }
    
    @isTest 
    public static void updateEventRegistrationDietaryRestrictions(){
        
        Event_Registration__c er = [
            SELECT Id, Name, Dietary_Restriction__c, Dietary_Restriction_Description__c, Dietary_Restriction_Types__c 
            FROM Event_Registration__c 
            LIMIT 1
        ];
        
        er.Dietary_Restriction__c = TRUE;
        er.Dietary_Restriction_Description__c = 'TEST';
            
        ConventionController.updateEventRegistrationDietaryRestrictions(JSON.serialize(er));
        
    }
    
    @isTest 
    public static void updateEventRegistrationSpecialRequirements(){
        
        Event_Registration__c er = [
            SELECT Id, Name, Dietary_Restriction__c, Dietary_Restriction_Description__c, Dietary_Restriction_Types__c 
            FROM Event_Registration__c 
            LIMIT 1
        ];
        
        er.Special_Requirements__c = 'TEST';
            
        ConventionController.updateEventRegistrationSpecialRequirements(JSON.serialize(er));
        
    }
    
    @isTest 
    public static void updateEventRegistrationEmergencyContact(){
        
        Event_Registration__c er = [
            SELECT Id, Name, Dietary_Restriction__c, Dietary_Restriction_Description__c, Dietary_Restriction_Types__c 
            FROM Event_Registration__c 
            LIMIT 1
        ];
        
        er.Emergency_Contact_Name__c = 'TEST';
        er.Emergency_Contact_Phone__c = 'TEST';
            
        ConventionController.updateEventRegistrationEmergencyContact(JSON.serialize(er));
        
    }
    
    @isTest 
    public static void updateEventRegistrationProfessionalDesignations(){
        
        Event_Registration__c er = [
            SELECT Id, Name, Dietary_Restriction__c, Dietary_Restriction_Description__c, Dietary_Restriction_Types__c 
            FROM Event_Registration__c 
            LIMIT 1
        ];
        
        er.Professional_Designations__c = 'AMA;';
            
        ConventionController.updateEventRegistrationProfessionalDesignations(JSON.serialize(er));
        
    }    
    
    @isTest 
    public static void updateEventRegistrationPersonalInformation(){
        
        Event_Registration__c er = [
            SELECT Id, Name, Dietary_Restriction__c, Dietary_Restriction_Description__c, Dietary_Restriction_Types__c, Contact__c, Contact__r.Title, Contact__r.Company__c 
            FROM Event_Registration__c 
            LIMIT 1
        ];
        
        er.Professional_Designations__c = 'AMA;';
            
        ConventionController.updateEventRegistrationPersonalInformation(JSON.serialize(er));
        
    }   
    
    @isTest 
    public static void insertDeleteEventSessionRegistrations(){

        //EventMobiApiBatch.disableBatch = true;

        Event_Registration__c er = [
            SELECT Id, Name, Event__c, Dietary_Restriction__c, Dietary_Restriction_Description__c, Dietary_Restriction_Types__c 
            FROM Event_Registration__c 
            LIMIT 1
        ];
        
        Event_Sessions__c es = [
            SELECT Id
            FROM Event_Sessions__c
            LIMIT 1
        ];
        
        String eventId = er.Event__c;
        String eventRegistrationId = er.Id;
        
        List<Event_Session_Registration__c> toDelete = [SELECT Id, Event_Session__c, Event_Registration__c FROM Event_Session_Registration__c];
        
        List<Event_Session_Registration__c> toInsert = new List<Event_Session_Registration__c>{
            new Event_Session_Registration__c(
                Event_Session__c = es.Id,
                Event_Registration__c = er.Id
            )
        };
            
        ConventionController.insertDeleteEventSessionRegistrations(
            eventRegistrationId, 
            JSON.serialize(toInsert), 
            JSON.serialize(toDelete)
        );
        
    }
    
    @isTest 
    public static void deleteEventSessionRegistration(){

        //EventMobiApiBatch.disableBatch = true;

        Event_Registration__c er = [
            SELECT Id, Name, Event__c, Dietary_Restriction__c, Dietary_Restriction_Description__c, Dietary_Restriction_Types__c 
            FROM Event_Registration__c 
            LIMIT 1
        ];
        
        Event_Sessions__c es = [
            SELECT Id
            FROM Event_Sessions__c
            LIMIT 1
        ];
            
        ConventionController.insertDeleteEventSessionRegistration(
            er.Id,
            es.Id
        );
        
    }

    @isTest 
    public static void insertEventSessionRegistration(){

        //EventMobiApiBatch.disableBatch = true;

        Event_Registration__c er = [
            SELECT Id, Name, Event__c, Dietary_Restriction__c, Dietary_Restriction_Description__c, Dietary_Restriction_Types__c 
            FROM Event_Registration__c 
            LIMIT 1
        ];
        
        Event_Sessions__c es = [
            SELECT Id
            FROM Event_Sessions__c
            LIMIT 1
        ];
        
        Event_Session_Registration__c esr = [
            SELECT Id 
            FROM Event_Session_Registration__c 
            WHERE Event_Registration__c = :er.Id AND Event_Session__c = :es.Id
        ];

        DELETE esr;
        
        ConventionController.insertDeleteEventSessionRegistration(
            er.Id,
            es.Id
        );
        
    }
    
    @isTest
    public static void addEventSessionRegistrationByContact(){

        //EventMobiApiBatch.disableBatch = true;

        Event_Registration__c er = [
            SELECT Id, Name, Event__c, Contact__c, Dietary_Restriction__c, Dietary_Restriction_Description__c, Dietary_Restriction_Types__c 
            FROM Event_Registration__c 
            LIMIT 1
        ];
        
        Event_Sessions__c es = [
            SELECT Id
            FROM Event_Sessions__c
            LIMIT 1
        ];
        
        Event_Session_Registration__c esr = [
            SELECT Id 
            FROM Event_Session_Registration__c 
            WHERE Event_Registration__c = :er.Id AND Event_Session__c = :es.Id
        ];

        DELETE esr;    
        
        ConventionController.addEventSessionRegistrationByContact(er.Contact__c, er.Event__c, es.Id);
        
    }
    
    @isTest
    public static void fetchContactPicklistValues(){
        ConventionController.fetchContactPicklistValues();
    }
    
}