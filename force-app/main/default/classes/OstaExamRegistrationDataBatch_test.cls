@isTest
private class OstaExamRegistrationDataBatch_test {

    @testSetup
    public static void testSetup(){
        
         INSERT new Exam_Date__c(Name = 'Exam Date', Date_String__c = String.valueOf(System.today().addDays(60)));
        
        ExamRegistrationTestDataFactory.setupChargent();
        ExamRegistrationTestDataFactory.setupAccountOwner();     
        ExamRegistrationTestDataFactory.setupActivePricebook();
        ExamRegistrationTestDataFactory.setupFeeProducts();
        ExamRegistrationTestDataFactory.setupBookProducts();
        ExamRegistrationTestDataFactory.setupExamRegistrationDependencyObjects();
        
    }
    
    @isTest
    public static void test1(){
        
        //User user = ExamRegistrationTestDataFactory.createExamRegistration('FRM', 'Credit Card', 'TESTUSERONE', TRUE, TRUE);
        User user = ExamRegistrationTestDataFactory.createAffiliateContact();
        List<Opportunity> opportunities = [SELECT Id, StageName FROM Opportunity WHERE AccountId = :user.AccountId];
        for(Opportunity opportunity: opportunities){
            opportunity.StageName = 'Closed';
        }
        
        //Contact cont1 = GARP_TestFactory.createMember('user2@garpqa.com',true);
        
        Id ostaRecId = RecordTypeHelper.GetRecordTypeId('Contract','OSTA Program');
        Contract osta = new Contract(
            AccountId = user.AccountId,
            RecordTypeId = ostaRecId,
            Opportunity__c = opportunities[0].Id,
            StartDate = Date.today().AddDays(-10),
            ContractTerm = 12
        );
        insert osta;
        
        osta.Status = 'Activated';
        update osta;
        
        Contract osta2 = new Contract(
            AccountId = user.AccountId,
            RecordTypeId = ostaRecId,
            Opportunity__c = opportunities[0].Id,
            StartDate = Date.today().AddDays(-10),
            ContractTerm = 12
        );
        insert osta2;
        
        osta2.Status = 'Activated';
        update osta2;
        
        Test.startTest();
        
        UPDATE opportunities;
        
        List<Exam_Sites__c> lstExamSitePart1 = [select Id, Exam_Part__c, Exam_Part__r.Exam_Administration__c from Exam_Sites__c where Exam__r.Exam__c = 'FRM Part 1'];
        List<Exam_Sites__c> lstExamSitePart2 = [select Id, Exam_Part__c, Exam_Part__r.Exam_Administration__c from Exam_Sites__c where Exam__r.Exam__c = 'FRM Part 2'];
        
        
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Result__c = 'Fail', Exam_Part__c = lstExamSitePart1[0].Exam_Part__c,Exam_Site__c = lstExamSitePart1[0].id,
                                      Exam_Administration__c = lstExamSitePart1[0].Exam_Part__r.Exam_Administration__c,Defered__c = NULL,
                                      Member__c = user.ContactId);

        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Result__c = 'Fail', Exam_Part__c = lstExamSitePart2[0].Exam_Part__c,Exam_Site__c = lstExamSitePart2[0].id,
                                      Exam_Administration__c = lstExamSitePart2[0].Exam_Part__r.Exam_Administration__c,Defered__c = NULL,
                                      Member__c = user.ContactId);
        
        insert attempt1;
        insert attempt2;
        
        System.debug('Exam_Attempt 1:' + attempt1);
        System.debug('Exam_Attempt 2:' + attempt2);
        
        List<Exam_Attempt__c> lstEAs = [select id, Section__c, Exam_Site__r.Country__c from Exam_Attempt__c];
        for(Exam_Attempt__c ea :lstEAs) {
            System.debug('ea:' + ea.Id + '~' + ea.Section__c + '~' + ea.Exam_Site__r.Country__c);
        }
        
        Id batchJobId = Database.executeBatch(new OstaExamRegistrationDataBatch('quarterly',null,null,null), 200);
        Id batchJobId1 = Database.executeBatch(new OstaExamRegistrationDataBatch('exam','May',String.ValueOf(System.today().Year()),null), 200);
        Id batchJobId2 = Database.executeBatch(new OstaExamRegistrationDataBatch('exam','May',String.ValueOf(System.today().Year()),user.AccountId), 200);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void test2(){
        
        //User user = ExamRegistrationTestDataFactory.createExamRegistration('FRM', 'Credit Card', 'TESTUSERONE', TRUE, TRUE);
        User user = ExamRegistrationTestDataFactory.createAffiliateContact();
        List<Opportunity> opportunities = [SELECT Id, StageName FROM Opportunity WHERE AccountId = :user.AccountId];
        for(Opportunity opportunity: opportunities){
            opportunity.StageName = 'Closed';
        }
        
        //Contact cont1 = GARP_TestFactory.createMember('user2@garpqa.com',true);
        
        Id ostaRecId = RecordTypeHelper.GetRecordTypeId('Contract','OSTA Program');
        Contract osta = new Contract(
            AccountId = user.AccountId,
            RecordTypeId = ostaRecId,
            Opportunity__c = opportunities[0].Id,
            StartDate = Date.today().AddDays(-10),
            ContractTerm = 12
        );
        insert osta;

        osta.Status = 'Activated';
        update osta;
        
        Contract osta2 = new Contract(
            AccountId = user.AccountId,
            RecordTypeId = ostaRecId,
            Opportunity__c = opportunities[0].Id,
            StartDate = Date.today().AddDays(-10),
            ContractTerm = 12
        );
        insert osta2;
        
        osta2.Status = 'Activated';
        update osta2;
        
        Test.startTest();
        
        UPDATE opportunities;
        
        List<Exam_Sites__c> lstExamSitePart1 = [select Id, Exam_Part__c, Exam_Part__r.Exam_Administration__c from Exam_Sites__c where Exam__r.Exam__c = 'FRM Part 1'];
        List<Exam_Sites__c> lstExamSitePart2 = [select Id, Exam_Part__c, Exam_Part__r.Exam_Administration__c from Exam_Sites__c where Exam__r.Exam__c = 'FRM Part 2'];
        
        
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Result__c = 'Fail', Exam_Part__c = lstExamSitePart1[0].Exam_Part__c,Exam_Site__c = lstExamSitePart1[0].id,
                                      Exam_Administration__c = lstExamSitePart1[0].Exam_Part__r.Exam_Administration__c,Defered__c = NULL,
                                      Member__c = user.ContactId);

        insert attempt1;
        
        System.debug('Exam_Attempt 1:' + attempt1);
        
        List<Exam_Attempt__c> lstEAs = [select id, Section__c, Exam_Site__r.Country__c from Exam_Attempt__c];
        for(Exam_Attempt__c ea :lstEAs) {
            System.debug('ea:' + ea.Id + '~' + ea.Section__c + '~' + ea.Exam_Site__r.Country__c);
        }
        
        Id batchJobId = Database.executeBatch(new OstaExamRegistrationDataBatch('quarterly',null,null,null), 200);
        Id batchJobId1 = Database.executeBatch(new OstaExamRegistrationDataBatch('exam','May',String.ValueOf(System.today().Year()),null), 200);
        Id batchJobId2 = Database.executeBatch(new OstaExamRegistrationDataBatch('exam','May',String.ValueOf(System.today().Year()),user.AccountId), 200);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void test3(){
        
        //User user = ExamRegistrationTestDataFactory.createExamRegistration('FRM', 'Credit Card', 'TESTUSERONE', TRUE, TRUE);
        User user = ExamRegistrationTestDataFactory.createAffiliateContact();
        List<Opportunity> opportunities = [SELECT Id, StageName FROM Opportunity WHERE AccountId = :user.AccountId];
        for(Opportunity opportunity: opportunities){
            opportunity.StageName = 'Closed';
        }
        
        //Contact cont1 = GARP_TestFactory.createMember('user2@garpqa.com',true);
        
        Id ostaRecId = RecordTypeHelper.GetRecordTypeId('Contract','OSTA Program');
        Contract osta = new Contract(
            AccountId = user.AccountId,
            RecordTypeId = ostaRecId,
            Opportunity__c = opportunities[0].Id,
            StartDate = Date.today().AddDays(-10),
            ContractTerm = 12
        );
        insert osta;

        osta.Status = 'Activated';
        update osta;
        
        Contract osta2 = new Contract(
            AccountId = user.AccountId,
            RecordTypeId = ostaRecId,
            Opportunity__c = opportunities[0].Id,
            StartDate = Date.today().AddDays(-10),
            ContractTerm = 12
        );
        insert osta2;

        osta2.Status = 'Activated';
        update osta2;
        
        Test.startTest();
        
        UPDATE opportunities;
        
        List<Exam_Sites__c> lstExamSitePart2 = [select Id, Exam_Part__c, Exam_Part__r.Exam_Administration__c from Exam_Sites__c where Exam__r.Exam__c = 'FRM Part 2'];
        
        

        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Result__c = 'Fail', Exam_Part__c = lstExamSitePart2[0].Exam_Part__c,Exam_Site__c = lstExamSitePart2[0].id,
                                      Exam_Administration__c = lstExamSitePart2[0].Exam_Part__r.Exam_Administration__c,Defered__c = NULL,
                                      Member__c = user.ContactId);
        
        insert attempt2;
        
        System.debug('Exam_Attempt 2:' + attempt2);
        
        List<Exam_Attempt__c> lstEAs = [select id, Section__c, Exam_Site__r.Country__c from Exam_Attempt__c];
        for(Exam_Attempt__c ea :lstEAs) {
            System.debug('ea:' + ea.Id + '~' + ea.Section__c + '~' + ea.Exam_Site__r.Country__c);
        }
        
        Id batchJobId = Database.executeBatch(new OstaExamRegistrationDataBatch('quarterly',null,null,null), 200);
        Id batchJobId1 = Database.executeBatch(new OstaExamRegistrationDataBatch('exam','May',String.ValueOf(System.today().Year()),null), 200);
        Id batchJobId2 = Database.executeBatch(new OstaExamRegistrationDataBatch('exam','May',String.ValueOf(System.today().Year()),user.AccountId), 200);
        
        Test.stopTest();
        
    }
    
}