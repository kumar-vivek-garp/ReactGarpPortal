@isTest
Public class scheduleUpdateContracts_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

scheduleUpdateContracts s1= new scheduleUpdateContracts();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}