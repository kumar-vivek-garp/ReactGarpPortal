@isTest
public class LibysnClass_Test {
    Public testMethod static void testAll(){        
        Test.startTest();
        scheduleLibsynRSS RSS = new scheduleLibsynRSS();
        String sch = '0 0 0 * * ?';
        system.schedule('Test status Check', sch, RSS );
        
        List<String> params = new List<String>();
        params.add('updateAllFeeds');
        List<List<String>> inputParams = new List<List<String>>();
        inputParams.add(params);
        
        LibysnClass.LibysnClassInvocable(inputParams);
        
        LibysnClass.getRSSFeed('https://feeds.libsyn.com/284498/rss/?include-libsyn-metadata=true');
        
        Test.stopTest();

    }
}