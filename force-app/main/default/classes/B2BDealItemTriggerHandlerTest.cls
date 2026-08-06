@isTest
public class B2BDealItemTriggerHandlerTest {

    
    @IsTest
    static void unitTest_1(){
        
        String studyMaterialRT = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Study_Materials');
        String EventRT = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Events');
        id teamregRecTypeid = RecordTypehelper.getRecordTypeIdFromSchema('Team_Registration__c', 'Team_Registration');
        
        Country_Code__c cc = new Country_Code__c(Name='US',Country__c='United States',VAT__c = 8000);
        insert cc;
        
        Contact con = new Contact(LastName = 'test');
        insert con;
        
        test.startTest();
        
  		Team_Registration__c reg1 = new Team_registration__c();
        reg1.Name='test team reg1';
        reg1.Contact__c=con.Id;
        reg1.Exam_Type__c = 'FRM I';
        reg1.Start_Date__c = system.today() ;
        reg1.End_Date__c=system.today();
        reg1.Seats_Allowed__c =1;
        //reg1.Include_Books__c = true;
        reg1.RecordTypeId = teamregRecTypeid;
        reg1.Include_Exam_or_Courses__c = true;
        //reg1.Payment_Status__c = 'Cancelled';
        reg1.Shipping_Contact_Name__c = 'test';
        reg1.Shipping_Contact_Phone__c = '99078979876878';
        reg1.Shipping_Address__c = 'test';
        reg1.Shipping_Postal_Code__c = 'test';
        reg1.Shipping_City__c = 'test';
        insert reg1;
        
        B2B_Deal_Item__c bdi = new B2B_Deal_Item__c();
		bdi.B2B_Deal__c = reg1.id;
        bdi.RecordTypeId = studyMaterialRT;
        bdi.FRM_Part_I_Hard_Books__c = 34;
        bdi.FRM_Part_II_Hard_Books__c = 34;
        bdi.SCR_Hard_Books__c = 34;
        bdi.FRR_Hard_Books__c = 34;
        bdi.RAI_Hard_Books__c = 2;
        bdi.Shipping_Country__c = 'United States';
        insert bdi;
        
        bdi.RecordTypeId = EventRT;
        bdi.Access_Code__c = 'testaccess';
        update bdi;
        
        test.stopTest();
    }
}