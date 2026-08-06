@isTest
public class  wistiaFeedJob_test{

    static testMethod void UnitTest_1()
    {
        test.starttest();
        wistiaFeedJob s1= new wistiaFeedJob();
        system.schedule('Test Schedule','0 0 0 * * ?',s1);
        Test.stoptest();
    }

}