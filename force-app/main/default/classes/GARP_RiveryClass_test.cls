@isTest
public class GARP_RiveryClass_test {

    @isTest static void runRiverTest1() {      
        
        // Setup Data
        GARP_API_Settings__c settingAPI = new GARP_API_Settings__c();
        settingAPI.Name = 'Rivery';
        settingAPI.EndPoint__c = 'https://www.garp.org/fakeapi';
        settingAPI.AuthToken__c = '123abc';
        insert settingAPI;
        
        Test.startTest();
        GARP_Common.apiReturnInfo ret = GARP_RiveryClass.runRiver('123');
        Test.stopTest();
    }
    
    
}