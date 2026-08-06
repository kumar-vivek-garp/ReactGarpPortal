@isTest
Public class schedulebatchCloseLateDeferralOpps_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

schedulebatchCloseLateDeferralOpps s1= new schedulebatchCloseLateDeferralOpps();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}