@isTest
Public class createOppForRecurrings_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

createOppForRecurrings s1= new createOppForRecurrings();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}