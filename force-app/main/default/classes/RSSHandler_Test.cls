@isTest
public class RSSHandler_Test {
    Public testMethod static void testAll(){
        Test.startTest();
        RSSHandler RSS = new RSSHandler();
        String sch = '0 0 0 * * ?';
        system.schedule('Test status Check', sch, RSS );
        Test.stopTest();

    }
}