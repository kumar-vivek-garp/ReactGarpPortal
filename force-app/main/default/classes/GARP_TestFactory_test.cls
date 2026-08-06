@isTest
public class GARP_TestFactory_test {

    @isTest
    public static void test1(){
        
        GARP_TestFactory.createMember('garpqamem@garpqa.com', True);
        
        Product2 prod1 = GARP_TestFactory.createProduct('MEMI','MEMI','4040');
        insert prod1;
        PricebookEntry price = GARP_TestFactory.createPriceBook(prod1.Id, 100);
        insert price;
        
        GARP_TestFactory.createCountryCodes();
        
    }
}