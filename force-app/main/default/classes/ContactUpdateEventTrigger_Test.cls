@isTest
private class ContactUpdateEventTrigger_Test {
    @isTest
    static void testEvents(){
        test.startTest();
        
        Contact_Update_Event__e event1 = new Contact_Update_Event__e();
        event1.Update_type__c = 'Contract';
        event1.Exam_Reg_Contract_Id__c = 'Test';
        event1.Record_Id__c = 'Test';
        EventBus.publish(event1);
        
        Test.getEventBus().deliver();
        test.stopTest();
    }
    
    @isTest
    static void testExamRegUpdate(){
        List<Contact> ContactResults=TestDataFactory.createContacts(1);
        insert ContactResults;
        List<Exam_Group__c> ExamGroupResults = TestDataFactory.createExamGroup(1);
        insert ExamGroupResults;
        Exam__c exam = new Exam__c();
        exam.Exam_Group__c = ExamGroupResults[0].id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1';
        exam.Name = 'FRM Part 1';
        insert exam;
        List<Exam__c> examResults = new List<Exam__c>{exam};
        List<Exam_Part__c> examPartResults = TestDataFactory.createExamPart(1,ExamResults);
        insert examPartResults;
        List<Exam_Sites__c> examSiteResults = TestDataFactory.createExamSite(1,examPartResults,ExamResults);
        insert examSiteResults;
        List<Opportunity> OppResults=TestDataFactory.createOpportunity(1);
        insert OppResults;
        
        Exam_Sites__c es = [Select Id from Exam_Sites__c where Exam__r.Exam__c = 'FRM Part 1' Limit 1];
        Contact con = [Select Id from Contact limit 1];
        Exam_Part__c ep= [Select Id,Exam_Administration__c from Exam_Part__c Limit 1];
        
        Exam_Attempt__c record = new Exam_Attempt__c();
        record.Exam_Site__c = es.id;
        record.Member__c = con.Id;//contact id
        record.cancelled__c = false;
        record.Exam_Administration__c = ep.Exam_Administration__c;
        record.Exam_Part__c = ep.id;
        record.Opportunity__c = OppResults[0].Id;
        record.Result__c = 'Fail';
        
        insert record;
        
        test.startTest();
        Contact_Update_Event__e event1 = new Contact_Update_Event__e();
        event1.Update_type__c = 'Exam_Attempt__c';
        event1.Exam_Reg_Contract_Id__c = record.Id;
        event1.Record_Id__c = con.Id;
        EventBus.publish(event1);
        
        Test.getEventBus().deliver();
        test.stopTest();
    }

}