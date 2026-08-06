@isTest
Public class SendMembershipemailscheduler_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

SendMembershipemailscheduler s1= new SendMembershipemailscheduler();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}