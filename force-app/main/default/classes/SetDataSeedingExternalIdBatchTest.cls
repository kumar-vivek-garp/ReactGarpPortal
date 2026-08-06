@isTest
public class SetDataSeedingExternalIdBatchTest {

    @TestSetup
    private static void makeData(){
        Event__c event = new Event__c();
        event.Name = 'test';
        INSERT event;
    }

    @IsTest
    private static void testUnit () {

        Event__c event = [SELECT Id, Data_Seeding_External_ID__c FROM Event__c];
        event.Data_Seeding_External_ID__c = null;
        UPDATE event;

        Test.startTest();

        // GARP Base Configuration Objects
        Set<String> sObjectTypes = new Set<String>{
            'Exam__c',
            'Exam_Group__c',
            'Exam_Rate__c',
            'Exam_Registration_Window__c',
            'Exam_Sites__c',
            'Site__c',
            'Room__c',
            'Venue__c',
            'Product2',
            'Chapter__c',
            'Chapter_Meeting__c',
            'Event__c',
            'Event_Combo_Rate__c',
            'Event_Rate__c',
            'Webcast__c',
            'Exam_Administration__c',
            'Exam_Part__c'
        };

        for(String sObjectType: sObjectTypes){
            Database.executeBatch(new SetDataSeedingExternalIdBatch(sObjectType), 200);
        }

        Test.stopTest();

    }

}