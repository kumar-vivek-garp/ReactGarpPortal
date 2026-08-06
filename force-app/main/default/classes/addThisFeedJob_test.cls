@isTest
public class  addThisFeedJob_test{

    static testMethod void UnitTest_1()
    {
        test.starttest();
        addThisFeedJob s1= new addThisFeedJob();
        system.schedule('Test Schedule','0 0 0 * * ?',s1);
        Test.stoptest();
    }

}