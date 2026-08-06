@isTest
Public class scheduleupdateScrContracts_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

scheduleupdateScrContracts s1= new scheduleupdateScrContracts();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}