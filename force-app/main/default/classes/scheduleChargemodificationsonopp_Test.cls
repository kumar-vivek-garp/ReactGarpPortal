@isTest
Public class scheduleChargemodificationsonopp_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

scheduleChargemodificationsonopp s1= new scheduleChargemodificationsonopp();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}