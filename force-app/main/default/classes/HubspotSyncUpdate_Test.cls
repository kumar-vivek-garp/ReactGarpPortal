@isTest

Private class HubspotSyncUpdate_Test {
    
    
        @isTest  static void HubCallout() {
            // Set mock callout class 
            
            Test.setMock(HttpCalloutMock.class, new HubMockHttpResponseGenerator(200));
            
            // Setup Data
            GARP_Rivery_Settings__c settingRivery = new GARP_Rivery_Settings__c();
            settingRivery.Name = 'Podcast';
            settingRivery.RiverID__c = '12345';
            insert settingRivery;


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
            HubspotSyncUpdate.syncIfNeeded();
                
            List<string> response = HubspotSyncUpdate.syncMethod();
            Test.stopTest();
            
            //System.assertEquals('Sync Request Succeeded', response[0]); 
            
        }
    
    @isTest static void HubCallout2() {
        
        Test.setMock(HttpCalloutMock.class, new HubMockHttpResponseGenerator(404));
        
        // Setup Data
        GARP_Rivery_Settings__c settingRivery = new GARP_Rivery_Settings__c();
        settingRivery.Name = 'Podcast';
        settingRivery.RiverID__c = '12345';
        insert settingRivery;
        
        
        GARP_API_Settings__c settingAPI = new GARP_API_Settings__c();
        settingAPI.Name = 'Rivery';
        settingAPI.EndPoint__c = 'https://www.garp.org/fakeapi';
        settingAPI.AuthToken__c = '123abc';
        insert settingAPI;
        
        Test.startTest();
        System.schedule('HubspotSyncUpdate 1', '0 0 * * * ?', new HubspotSyncUpdate());
        
        List<string> response = HubspotSyncUpdate.syncMethod();
        Test.stopTest();
        //System.assertEquals(true, response[0].contains('404')); 
    }
}