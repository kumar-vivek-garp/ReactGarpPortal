@isTest
public class GARP_AWSAppFlow_Webhook_test {

    @isTest  static void WebhookTest1() {
        
        // Setup Data
        GARP_AWSAppFlow_To_Rivers__c settingAppFlowRivers = new GARP_AWSAppFlow_To_Rivers__c();
        settingAppFlowRivers.Name = 'HubSpotContactDataSync';
        settingAppFlowRivers.RiverID__c = '123';
        insert settingAppFlowRivers;
        
        GARP_API_Settings__c settingAPI = new GARP_API_Settings__c();
        settingAPI.Name = 'Rivery';
        settingAPI.EndPoint__c = 'https://www.garp.org/fakeapi';
        settingAPI.AuthToken__c = '123abc';
        insert settingAPI;
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        // List<String> response = new List<String>();
        Test.startTest();
        GARP_AWSAppFlow_Webhook.webhook();        
        Test.stopTest();
    }
}