@isTest
public class EventContentRestControllerTest {
    public static String contentEventRecordTypeId = RecordTypeHelper.getRecordTypeId('Content__c', 'Event');
    @testSetup
    private static void setup() {
        List<Content__c> contents = new List<Content__c>{
            new Content__c(
                Name = 'Test Event Content 1',
                Description__c = 'Test Event Content Description 1',
                RecordTypeId = contentEventRecordTypeId
            ),
            new Content__c(
                Name = 'Test Webcast Content 2',
                Description__c = 'Test Webcast Content Description 2',
                RecordTypeId = contentEventRecordTypeId
            )
        };
        INSERT contents;
    }
    
    @isTest
    private static void test(){
        Test.startTest();
        EventContentRestController.doGet();
        EventContentRestController.getFeaturedEventContents();
        EventContentRestController.getEventContents();
        EventContentRestController.fetchFeaturedEventContent();
        Test.stopTest();
    }
}