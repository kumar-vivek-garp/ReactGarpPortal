@isTest
Public class scheduleDeclinedRecurringTrans_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

scheduleDeclinedRecurringTrans s1= new scheduleDeclinedRecurringTrans();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}