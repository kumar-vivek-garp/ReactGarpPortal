@isTest
private class PolicyController_Test {
    
    @isTest private static void getEventPolicies(){
        
        RecordType rtype = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Non_Convention' LIMIT 1];
        
        Event__c event = new Event__c();
        event.RecordTypeId = rtype.Id;
        event.Cancellation_Policy__c = 'TEST';
        event.Events_Photography_Release__c = 'TEST';
        event.Payment_Policy__c = 'TEST';
        INSERT event;
        
        Test.startTest();
        
        Response.Detail res = PolicyController.get(event.Id);
        
        PolicyController.Policies policies = (PolicyController.Policies)res.data;
        
        System.assertEquals(200, res.status);
        System.assertEquals('Non-Convention', policies.recordTypeName);
        
        Test.stopTest();
        
    }
    
    @isTest private static void getConventionPolicies(){
        
        RecordType rtype = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Convention' LIMIT 1];
        
        Event__c event = new Event__c();
        event.RecordTypeId = rtype.Id;
        event.Cancellation_Policy__c = 'TEST';
        event.Events_Photography_Release__c = 'TEST';
        event.Payment_Policy__c = 'TEST';
        INSERT event;
        
        Test.startTest();
        
        Response.Detail res = PolicyController.get(event.Id);
        
        PolicyController.Policies policies = (PolicyController.Policies)res.data;
        
        System.assertEquals(200, res.status);
        System.assertEquals('Convention', policies.recordTypeName);
        
        Test.stopTest();
        
    }
    
    @isTest private static void getChapterMeetingPolicies(){
        
        Chapter_Meeting__c chapterMeeting = new Chapter_Meeting__c();
        chapterMeeting.Cancellation_Policy__c = 'TEST';
        chapterMeeting.Payment_Policy__c = 'TEST';
        INSERT chapterMeeting;
        
        Test.startTest();
        
        Response.Detail res = PolicyController.get(chapterMeeting.Id);
        
        PolicyController.Policies policies = (PolicyController.Policies)res.data;
        
        System.assertEquals(200, res.status);
        System.assertEquals('Chapter_Meeting__c', policies.sObjectTypeName);
        
        Test.stopTest();
        
    }
    
    @isTest private static void getUnsupportedTypePolicies(){
        
        Webcast__c webcast = new Webcast__c();
        webcast.Name = 'TEST';
        INSERT webcast;
        
        Test.startTest();
        
        Response.Detail res = PolicyController.get(webcast.Id);
        
        System.assertEquals(400, res.status);

        Test.stopTest();
        
    }

}