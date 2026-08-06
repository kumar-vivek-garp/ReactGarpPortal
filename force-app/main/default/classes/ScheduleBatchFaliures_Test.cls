@isTest
Public class ScheduleBatchFaliures_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

ScheduleBatchFaliures s1= new ScheduleBatchFaliures();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}