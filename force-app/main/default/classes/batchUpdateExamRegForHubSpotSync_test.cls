@isTest
Public class batchUpdateExamRegForHubSpotSync_test
{
    Public static testMethod void MyUnitTest()
    {
        test.starttest();
        
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        objExamGrp.SCR_Active__c = true;
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;    
        insert objExamGrp;
        
        scheduleBatchUpdateExamRegForHubSpotSync s1= new scheduleBatchUpdateExamRegForHubSpotSync();
        system.schedule('Test Schedule','0 0 0 * * ?',s1);
        Test.stoptest();
    }

}