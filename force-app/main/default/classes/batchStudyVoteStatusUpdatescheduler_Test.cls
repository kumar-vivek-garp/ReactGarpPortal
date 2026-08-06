@isTest
Public class batchStudyVoteStatusUpdatescheduler_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

batchStudyVoteStatusUpdatescheduler sv1= new batchStudyVoteStatusUpdatescheduler();
system.schedule('Test Schedule', '0 0 0 * * ?', sv1);
Test.stoptest();
}

}