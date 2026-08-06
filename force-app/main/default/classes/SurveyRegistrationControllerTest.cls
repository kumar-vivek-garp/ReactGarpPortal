@isTest
private class SurveyRegistrationControllerTest {
       
    @isTest
    private static void getSurvey(){
        
        GARP_Survey__c garpSurvey = new GARP_Survey__c();
        
        garpSurvey.Name = 'TEST SURVEY';
        garpSurvey.End_Date_Time__c = System.now().addDays(30);
        garpSurvey.Start_Date_Time__c = System.now().addDays(-30);
        
        INSERT garpSurvey;   
        
        SurveyRegistrationController.getSurvey(garpSurvey.Id);
        
    }
    
    @isTest
    private static void getSurveyBadId(){
        
        GARP_Survey__c garpSurvey = new GARP_Survey__c();
        
        garpSurvey.Name = 'TEST SURVEY';
        garpSurvey.End_Date_Time__c = System.now().addDays(30);
        garpSurvey.Start_Date_Time__c = System.now().addDays(-30);
        
        INSERT garpSurvey;   
        
        SurveyRegistrationController.getSurvey('a2A2a000000Jna');
        
    }
    
    @isTest
    private static void getSurveyNotAvailable(){
        
        GARP_Survey__c garpSurvey = new GARP_Survey__c();
        
        garpSurvey.Name = 'TEST SURVEY';
        garpSurvey.End_Date_Time__c = System.now().addDays(-30);
        garpSurvey.Start_Date_Time__c = System.now().addDays(30);
        
        INSERT garpSurvey;   
        
        SurveyRegistrationController.getSurvey(garpSurvey.Id);
        
    }
    
    @isTest
    private static void getSurveyNullId(){
               
        SurveyRegistrationController.getSurvey(null);
        
    }
    
    @isTest
    private static void createSurveyParticipants(){
        
        GARP_Survey__c garpSurvey = new GARP_Survey__c();
        
        garpSurvey.Name = 'TEST SURVEY';
        garpSurvey.End_Date_Time__c = System.now().addDays(30);
        garpSurvey.Start_Date_Time__c = System.now().addDays(-30);
        
        INSERT garpSurvey;   
        
        GARP_Survey_Participant__c garpSurveyParticipant = new GARP_Survey_Participant__c();
        
        garpSurveyParticipant.Company__c = 'TEST';
        garpSurveyParticipant.Email__c = 'test@test.com';
        garpSurveyParticipant.First_Name__c = 'TEST';
        garpSurveyParticipant.Last_Name__c = 'TEST';
        garpSurveyParticipant.Title__c = 'TEST';
        garpSurveyParticipant.Phone__c = '1234567890';
        
        SurveyRegistrationController.createSurveyParticipants(garpSurvey.Id, new List<GARP_Survey_Participant__c>{garpSurveyParticipant});
        
    }
    
    @isTest
    private static void createSurveyParticipantsSurveyNotAvailable(){
        
        GARP_Survey__c garpSurvey = new GARP_Survey__c();
        
        garpSurvey.Name = 'TEST SURVEY';
        garpSurvey.End_Date_Time__c = System.now().addDays(-30);
        garpSurvey.Start_Date_Time__c = System.now().addDays(30);
        
        INSERT garpSurvey;   
        
        GARP_Survey_Participant__c garpSurveyParticipant = new GARP_Survey_Participant__c();
        
        garpSurveyParticipant.Company__c = 'TEST';
        garpSurveyParticipant.Email__c = 'test@test.com';
        garpSurveyParticipant.First_Name__c = 'TEST';
        garpSurveyParticipant.Last_Name__c = 'TEST';
        garpSurveyParticipant.Title__c = 'TEST';
        garpSurveyParticipant.Phone__c = '1234567890';
        
        SurveyRegistrationController.createSurveyParticipants(garpSurvey.Id, new List<GARP_Survey_Participant__c>{garpSurveyParticipant});
        
    }
    
    @isTest
    private static void createSurveyParticipantsSurveyNullId(){
        
        GARP_Survey__c garpSurvey = new GARP_Survey__c();
        
        garpSurvey.Name = 'TEST SURVEY';
        garpSurvey.End_Date_Time__c = System.now().addDays(30);
        garpSurvey.Start_Date_Time__c = System.now().addDays(-30);
        
        INSERT garpSurvey;   
        
        GARP_Survey_Participant__c garpSurveyParticipant = new GARP_Survey_Participant__c();
        
        garpSurveyParticipant.Company__c = 'TEST';
        garpSurveyParticipant.Email__c = 'test@test.com';
        garpSurveyParticipant.First_Name__c = 'TEST';
        garpSurveyParticipant.Last_Name__c = 'TEST';
        garpSurveyParticipant.Title__c = 'TEST';
        garpSurveyParticipant.Phone__c = '1234567890';
        
        SurveyRegistrationController.createSurveyParticipants(null, new List<GARP_Survey_Participant__c>{garpSurveyParticipant});
        
    }
    
    @isTest
    private static void createSurveyParticipantsSurveyBadId(){
        
        GARP_Survey__c garpSurvey = new GARP_Survey__c();
        
        garpSurvey.Name = 'TEST SURVEY';
        garpSurvey.End_Date_Time__c = System.now().addDays(30);
        garpSurvey.Start_Date_Time__c = System.now().addDays(-30);
        
        INSERT garpSurvey;   
        
        GARP_Survey_Participant__c garpSurveyParticipant = new GARP_Survey_Participant__c();
        
        garpSurveyParticipant.Company__c = 'TEST';
        garpSurveyParticipant.Email__c = 'test@test.com';
        garpSurveyParticipant.First_Name__c = 'TEST';
        garpSurveyParticipant.Last_Name__c = 'TEST';
        garpSurveyParticipant.Title__c = 'TEST';
        garpSurveyParticipant.Phone__c = '1234567890';
        
        SurveyRegistrationController.createSurveyParticipants('a2A2a000000Jna', new List<GARP_Survey_Participant__c>{garpSurveyParticipant});
        
    }
    
}