@isTest
private class addThisFeed_test{

	static Content__c cont1;

    static void tesData() {

        Integration_Settings__c intSettings = new Integration_Settings__c (Name = 'AddThis', End_Point__c = 'https://www.garp.com/api',API_Key__c = 'test');
        insert intSettings;
        
        cont1 = new Content__c(Name='Bob', Share_Count__c=1);
        insert cont1;
        
     }
  
      Private static testMethod void myUnitTest_1(){
        test.starttest();
        tesData();
        
		addThisFeed.getFeedMethod();
          
        test.stoptest();      
          
	}
    Private static testMethod void myUnitTest_2(){
        test.starttest();
        
		addThisFeed.createErrorLog('Test Method','Test File','Test Message','Test Error');
          
        test.stoptest();      
          
	}
}