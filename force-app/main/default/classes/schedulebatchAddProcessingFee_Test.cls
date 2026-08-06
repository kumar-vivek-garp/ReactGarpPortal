@isTest
public class schedulebatchAddProcessingFee_Test {

    Public static testMethod void MyUnitTest()
    {
    test.starttest();
    schedulebatchAddProcessingFee s1= new schedulebatchAddProcessingFee();
    system.schedule('Test Schedule','0 0 0 * * ?',s1);
    Test.stoptest();
    }

    
}