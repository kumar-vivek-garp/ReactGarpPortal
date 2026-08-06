@isTest
Public class scheduleUpdateAccountSync_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

scheduleUpdateAccountSync s1= new scheduleUpdateAccountSync();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}