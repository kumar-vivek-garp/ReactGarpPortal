@istest
public class ResendPearsonVueRTIDataBatch_Test {
     static testMethod void PearsonVueRTIDataBatch(){
        Integration_Data__c intdate = new Integration_Data__c();  
        intdate.Version_Number__c = 1;
        intdate.Name ='test';
        intdate.Is_Active__c =true;
        intdate.Garp_Id__c ='01404258';
        intdate.Exam_Type__c = 'SCR';
        intdate.Re_Run__c = true;
        intdate.Outbound_Event_Types__c ='CDD';
        intdate.Call_out_Status__c ='Error';
        intdate.Pearson_Vue_Appointment_ID__c = '210378726';
        insert intdate;
        Test.startTest();
          Test.setMock(HttpCalloutMock.class, new PearsonRTIRequest_test());
        ResendPearsonVueRTIDataBatch batch = new ResendPearsonVueRTIDataBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
    }
    
   
}