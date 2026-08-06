@isTest
Public class batchExpireStudyNDAsScheduler_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();
batchExpireStudyNDAsScheduler s1= new batchExpireStudyNDAsScheduler();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}