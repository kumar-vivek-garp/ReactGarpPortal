@isTest
Public class scheduleShippingBatchclass_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

scheduleShippingBatchclass s1= new scheduleShippingBatchclass();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}