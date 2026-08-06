@isTest
Public class schedulebatchCreateProfileIds_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

schedulebatchCreateProfileIds s1= new schedulebatchCreateProfileIds();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}