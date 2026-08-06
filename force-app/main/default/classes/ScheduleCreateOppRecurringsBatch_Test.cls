@isTest
Public class ScheduleCreateOppRecurringsBatch_Test
{
Public static testMethod void MyUnitTest()
{
test.starttest();

ScheduleCreateOppRecurringsBatch s1= new ScheduleCreateOppRecurringsBatch();
system.schedule('Test Schedule','0 0 0 * * ?',s1);
Test.stoptest();
}

}