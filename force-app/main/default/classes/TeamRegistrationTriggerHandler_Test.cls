@isTest
public class TeamRegistrationTriggerHandler_Test {
    
 	static Contact con;
    static Id teamregRecTypeid;
    
    static void testsetup(){
        
        con = new Contact(LastName = 'Testting',Email = 'test2@test.garp.com');
        insert con;
        teamregRecTypeid = RecordTypehelper.getRecordTypeIdFromSchema('Team_Registration__c', 'Team_Registration');
    }

    @IsTest
    static void unitTest_1(){
        
        testsetup();
        test.startTest();
        String studyMaterialRT = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Study_Materials');
        String EventRT = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Events');
  		Team_Registration__c reg1 = new Team_registration__c();
        reg1.Name='test team reg1';
        reg1.Contact__c=con.Id;
        reg1.Exam_Type__c = 'FRM I';
        reg1.Start_Date__c = system.today() ;
        reg1.End_Date__c=system.today();
        reg1.Seats_Allowed__c =1;
        reg1.RecordTypeId = teamregRecTypeid;
        reg1.Include_Exam_or_Courses__c = true;
        reg1.Shipping_Contact_Name__c = 'test';
        reg1.Shipping_Contact_Phone__c = '99078979876878';
        reg1.Shipping_Address__c = 'test';
        reg1.Shipping_Postal_Code__c = 'test';
        reg1.Shipping_City__c = 'test';
        reg1.BD_Rep_Email__c = 'test@test.garp.com';
        insert reg1;
        
        B2B_Deal_Item__c bdi = new B2B_Deal_Item__c();
		bdi.B2B_Deal__c = reg1.id;
        bdi.RecordTypeId = studyMaterialRT;
        insert bdi;
        
        TeamRegistrationTriggerHandler.stopRecurssion = false;
        reg1.Payment_Status__c = 'Paid';
        reg1.Shipping_Cost__c = 56;
        reg1.Include_Books__c = true;
        update reg1;
   		
		test.stopTest();
    }
}