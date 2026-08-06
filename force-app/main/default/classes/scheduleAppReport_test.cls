@isTest
public class scheduleAppReport_test {

    
    static void testData()
    {   
        List<AppError__c> appErrorList = new List<AppError__c>();
        AppError__c ae1 = new AppError__c(Message__c = '', Error__c = '"message":"k is not defined"');
        appErrorList.add(ae1);
        
        AppError__c ae2 = new AppError__c(Message__c = 'h is not defined', Error__c = '"message":"h is not defined"');
        appErrorList.add(ae2);
        
        AppError__c ae3 = new AppError__c(Message__c = '', Error__c = '"message":"k is not defined"');
        appErrorList.add(ae3);
        
        AppError__c ae4 = new AppError__c(Message__c = 'h is not defined', Error__c = '"message":"h is not defined"');
        appErrorList.add(ae4);
        
        AppError__c ae5 = new AppError__c(Message__c = 'No error');
        appErrorList.add(ae5);
        
        insert appErrorList;
        
    }    
    
    Public static testMethod void MyUnitTest()
    {
        testData();
        test.starttest();
        scheduleAppReport s1= new scheduleAppReport();
        system.schedule('Test Schedule','0 0 0 * * ?',s1);
        Test.stoptest();
    }

    
}