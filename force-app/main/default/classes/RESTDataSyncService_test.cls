@isTest
public class RESTDataSyncService_test {
    static testMethod void myUnitTest() {
        RESTDataSyncService.teamRegistrationData tr = new RESTDataSyncService.teamRegistrationData();
        RESTDataSyncService.setTeamRegistration(tr);
    }
}