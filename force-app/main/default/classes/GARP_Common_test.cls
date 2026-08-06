@isTest
public class GARP_Common_test {
    public static Account account;
    public static Contact contact;
    
    public static void setup(){
        
        Product2 prod1 = GARP_TestFactory.createProduct('MEMI','MEMI','4040');
        insert prod1;
        PricebookEntry price = GARP_TestFactory.createPriceBook(prod1.Id, 100);
        insert price;
        
        Product2 prod2 = GARP_TestFactory.createProduct('MEMR','MEMR','4040');
        insert prod2;
        PricebookEntry price2 = GARP_TestFactory.createPriceBook(prod2.Id, 100);
        insert price2;
        
        Product2 prod3 = GARP_TestFactory.createProduct('PRFEE','PRFEE','4040');
        insert prod3;
        PricebookEntry price3 = GARP_TestFactory.createPriceBook(prod3.Id, 100);
        insert price3;
        
        GARP_TestFactory.createCountryCodes();
        contact = GARP_TestFactory.createMember('garpqamem@garpqa.com', True);
    }
    
    @isTest
    public static void testCommon1(){

        setup();
        test.startTest();
        
        GARP_Common.debugLog('Hello', '123');
        GARP_Common.addError('Hello', '123');
        
        Set<String> inSet = new Set<String>();
        inSet.add('Hello');
        GARP_Common.safeSet(inSet);
        
        GARP_Common.isLoadingResults(True, '123');
        
        GARP_Common.getCountries();
        GARP_Common.getInstitutions();
        GARP_Common.getPickListValues('Contact','Membership_Type__c');
        Boolean bool = True;
        GARP_Common.setSafeBoolean(bool);
        
        GARP_Common.debugLog('GARP_BC_Membership','getMembershipInfo','lstCont',bool);
        
        GARP_Common.CheckAuthentication();
        String addr = GARP_Common.formatAddressTextArea('street1', 'street2', 'street3');
        
        GARP_Common.address streets = GARP_Common.parseMultiAddressLine(addr);
        
        GARP_Common.convertLongStateToCode('NJ');
        GARP_Common.convertLongStateToCode('New Jersey');
        
        List<String> inList = new List<String>();
        inList.add('Hello');
        
        GARP_Common.safeList(inList);
        GARP_Common.setIfNotEmpty('hi', 'hi');
        GARP_Common.newLineToBR('hi');
        GARP_Common.hasNonWesternChars('hi');
        GARP_Common.getMonthMap();
        
        GARP_Common.getDependentPicklistValues( Errata__c.Section__c, Errata__c.Book_Practice_Exam__c );
        
        test.stopTest();
    }
    
}