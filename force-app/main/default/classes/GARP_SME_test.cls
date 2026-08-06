@isTest
public class GARP_SME_test {

    static Contact con;
    
    static void testData(){ 
        con = new Contact(lastname = 'Test',email='abc@abc.com',Mobile_Phone_Code__c='United States (+1)', MobilePhone='9175867012');
        insert con;
        
        DateTime now = DateTime.now();
       
        
        Webcast__c webcast = new Webcast__c(
            Name='webcast',
            Start_Date__c = now ,
            Topic_Tags__c = 'Environment & Biodiversity',
            Status__c = 'Active'
        );
        insert webcast;
        
        Presenter__c pres = new Presenter__c(
            Contact__c = con.Id,
            Webcast__c = webcast.Id
        );
        insert pres;
                
        Chapter_Meeting__c chaptMeeting = new Chapter_Meeting__c(
            Name = 'Chapter Meeting',
            Start__c = now,
            Topic_Tags__c = 'Environment & Biodiversity',
            Status__c = 'Active'
        );
        insert chaptMeeting;
        
        Chapter_Speaker__c cs = new Chapter_Speaker__c(
            Contact__c = con.Id
        );
        insert cs;

        Chapter_Meeting_Speaker__c cms = new Chapter_Meeting_Speaker__c(
        	Chapter_Speaker__c = cs.Id,
            Chapter_Meeting__c = chaptMeeting.Id
        );
        
        insert cms;

        Event__c evt = new Event__c(
            Name='QAEvent',
            Start_Date__c = now,
            Topic_Tags__c = 'Environment & Biodiversity',
            Status__c = 'Active'
        );
        insert evt;
        
        Event_Sessions__c es = new Event_Sessions__c(
            Name = 'Event Session',
            Event__c = evt.Id
        );
        insert es;
        
        Event_Speaker__c evtSpeaker = new Event_Speaker__c(
            Contact__c = con.Id
        );
        insert evtSpeaker;
        
        Event_Speaker_Session_Track__c est = new Event_Speaker_Session_Track__c(
            Name = 'Track1',
            Event_Session__c = es.Id,
            Event_Speaker__c = evtSpeaker.Id
        );
        insert est;
    }
    
    static testMethod void unitTest_2(){
        testData();
        test.startTest(); 
        List<String> contactIds = new List<String>();
        contactIds.add(con.Id);
        GARP_BC_SME.setSMEProfiles(contactIds);
        
        test.stopTest();
    }
}