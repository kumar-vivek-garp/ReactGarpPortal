@isTest
public class EventSponsorDataTest {
    public static String eventId { get; set; }
    public static List<Event_Sponsor__c> sponsors { get; set;}
    
    @testSetup
    private static void setup(){
        eventId = new Event__c().Id;
        insertSponsorTestData();
        insertCdriveTestData();
    }
    
    @isTest
    private static void getSponsors (){ 
        Test.startTest();
        EventSponsorData response = EventSponsorData.getAllSponsorInfoForEventId(eventId);
        Test.stopTest();
        
        System.assertNotEquals(null, response.eventSponsors);
    }
    
    private static void insertCdriveTestData() {
        List <cdrive__Cloud_Files__c> cdriveFiles = new List<cdrive__Cloud_Files__c>{
            new cdrive__Cloud_Files__c(
                cdrive__contextID__c = sponsors.get(0).Id,
                cdrive__File_Name__c = 'salesforce.jpg'
            ),
            new cdrive__Cloud_Files__c(
                cdrive__contextID__c = sponsors.get(1).Id,
                cdrive__File_Name__c = 'pardot.jpg'
            )
        };
            
        INSERT cdriveFiles;
    }
    
    private static void insertSponsorTestData() {
        sponsors = new List<Event_Sponsor__c>{
            new Event_Sponsor__c(
                Name = 'Salesforce',
                Event__c = eventId
            ),
            new Event_Sponsor__c(
                Name = 'Pardot',
                Event__c = eventId
            )
        };
            
        INSERT sponsors;
    }
}