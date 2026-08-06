@isTest
private class SMESearchCompCtrlTest {
    
    @isTest
    private static void testSearch() {
        SME_Registration__c smeProf = new SME_Registration__c(First_Name__c = 'Apex', Last_Name__c = 'Test', Email__c = 'apexTest@sample.com');
        insert smeProf; 
        
        Test.startTest();
        SMESearchCompCtrl.searchSMEProfile('Oil;Regulation', 'category', 'United States', new List<String>{'garp', 'system', 'self'});
        SMESearchCompCtrl.searchSMEProfile('Oil,Regulation', 'category', 'United States', new List<String>{'garp', 'system', 'self'});
        SMESearchCompCtrl.searchSMEProfile('Apex', 'name', 'United States', new List<String>{'garp', 'system', 'self'});
        
        List<String> raikAreaList = new List<String>();
        raikAreaList.add('career_development');
        raikAreaList.add('career_trends'); 
        SMESearchCompCtrl.filterSearchSME('Commercial Banking',raikAreaList, 'Test', 'United States', new List<String>{'garp', 'system', 'self'},system.today(),system.today(),new List<String>{'Last_Chapter_Speaker_Date__c','Last_Webcast_Presenter_Date__c','Last_Event_Speaker_Date__c'});
        SMESearchCompCtrl.getPickListMapValues();
        SMESearchCompCtrl.fetchSMEDetail(smeProf.Id);
        Test.stopTest();
    }

    @isTest
    private static void testHelperMethods() {
        Country_Code__c cc = new Country_Code__c(Country__c = 'United States');
        insert cc;
        
        Test.startTest();
        SMESearchCompCtrl.fetchPicklistValues('Credit Risk', new String[]{'garp','system'});
        
        SMESearchCompCtrl.fetchCountries();
        
        SMESearchCompCtrl.getCountryNames('United Kingdom');
        SMESearchCompCtrl.getCountryNames('China');
        Test.stopTest();
    }
}