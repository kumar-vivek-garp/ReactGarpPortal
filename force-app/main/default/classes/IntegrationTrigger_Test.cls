@isTest
private class IntegrationTrigger_Test {
        
    @isTest 
    static void testIntegrationStreamtest(){
        Integer totalCount=13;	
        List<Integration_Stream_Event__e> InteStreamResults=TestDataFactory.createIntegraStream(totalcount);
       
        Integration_Stream_Event__e e=InteStreamResults[0];
        Integration_Log__c log =IntegrationTriggerHandler.createLogRecord(e,'Success');
        if(e.Object_Name__c == 'Opportunity')
            log.Opportunity__c = e.Record_Id__c;   
        System.Test.startTest();
        System.debug('===========STARTED======testIntegrationStream_AI=====');
         IntegrationTriggerHandler.processIntegrations(InteStreamResults);
        insert log;
        System.Test.stopTest();
        System.assertEquals(InteStreamResults[0].Integration_Type__c,'PearsonVue');   
    }
    
    @isTest
    static void testEvents(){
        List<Integration_Stream_Event__e> evtList = new List<Integration_Stream_Event__e>();
        
        Integration_Stream_Event__e event1 = new Integration_Stream_Event__e();
        event1.Object_Name__c = 'Opportunity';
        evtList.add(event1);
        
        Integration_Stream_Event__e event2 = new Integration_Stream_Event__e();
        event2.Object_Name__c = 'Contract';
        evtList.add(event2);
        
        Integration_Stream_Event__e event3 = new Integration_Stream_Event__e();
        event3.Object_Name__c = 'Exam_Attempt__c';
        event3.Integration_Type__c = 'ATA';
        evtList.add(event3);
        
        Integration_Stream_Event__e event4 = new Integration_Stream_Event__e();
        event4.Object_Name__c = 'Exam_Attempt__c';
        event4.Integration_Type__c = 'PSI';
        evtList.add(event4);
        
        test.startTest();
        EventBus.publish(evtList);
        test.stopTest();
    }
    
    @isTest
    static void testException(){
        List<Integration_Stream_Event__e> evtList = new List<Integration_Stream_Event__e>();
        
        Integration_Stream_Event__e event1 = new Integration_Stream_Event__e();
        event1.Object_Name__c = 'Opportunity';
        event1.Record_Id__c = 'Test';
        event1.Integration_Type__c = 'PSI';
        evtList.add(event1);
        
        test.startTest();
        EventBus.publish(evtList);
        Test.getEventBus().deliver();
        test.stopTest();
    }

}