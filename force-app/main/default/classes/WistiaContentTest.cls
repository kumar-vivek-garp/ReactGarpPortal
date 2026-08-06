@isTest
public class WistiaContentTest {

    @testSetup
    public static void setup(){
        Content__c content = new Content__c();
        content.Sku__c = '21526911';
        INSERT content;
    }
    
    @isTest
    public static void test(){
        Test.setMock(HttpCalloutMock.class, new WistiaContentMockHttpCallout());
        Test.startTest();
        new SchedulableWistiaContent().execute(null);
        Test.stopTest();
    }
    
}