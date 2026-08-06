@isTest
Public class schedulebatchUpdateuserEmail_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

schedulebatchUpdateuserEmail s1= new schedulebatchUpdateuserEmail();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}