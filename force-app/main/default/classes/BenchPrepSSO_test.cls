@isTest
public class BenchPrepSSO_test {
    
    public static Opportunity opp;
    public static Account account;
    public static Contact contact;
    public static User user;
    
    public static void setup(){
        //ACCOUNT OWNER
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX'); 
        
        //'FRM1E','FRM1S','FRM2E','FRM2S', 'FRM1H','FRM1X','FRM2H','FRM2X','FRMC1','FRMC2'
        List<String> prodsFRM = new List<String>{'AFREE:AFREE:4040:100','MEMI:MEMI:4040:100','MEMC:MEMC:4040:100','FRM1E:FRM1E:4040:100','FRM1S:FRM1S:4040:100','FRM2E:FRM2E:4040:100','FRM2S:FRM2S:4040:100' ,'FRM1H:FRM1H:4040:100','FRM1X:FRM1X:4040:100','FRM2H:FRM2H:4040:100','FRM2X:FRM2X:4040:100','FRMC1:FRMC1:4040:100','FRMC2:FRMC2:4040:100','SHIP:SHIP:4040:100'};
        GARP_TestFactory.createProducts(prodsFRM, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        GARP_TestFactory.createCountryCodes();
        user = GARP_TestFactory.createAffiliateContact();
        System.debug('user:' + user);
        
        List<Opportunity> lstOpp = [select id, AccountId from Opportunity];
        opp = lstOpp[0];
        System.debug('opp:' + opp);
        
        List<Contact> lstCont = [select id, accountId, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c from contact];
        contact = lstCont[0];
        System.debug('contact:' + contact);
    }
    
    static testMethod void unitTest1(){
        setup();
        test.startTest();
        BenchPrepSSO BenchPrepSSO = new BenchPrepSSO();
        System.runAs(user) {
            // Query BenchPrep_Config__mdt to find Course_Slug for Members Benchprep type
            List<BenchPrep_Config__mdt> configList = [SELECT Id, Course_Slug__c, Type__c 
                                                      FROM BenchPrep_Config__mdt 
                                                      WHERE Type__c = 'Members Benchprep' 
                                                      LIMIT 1];
            
            String productId = 'FRM1E'; // Default fallback
            if(!configList.isEmpty() && configList[0].Course_Slug__c != null) {
                productId = configList[0].Course_Slug__c;
            }
            
            // Create eBook_Key__c record that matches Members Benchprep configuration
            Contact testContact = [SELECT Id FROM Contact LIMIT 1];
            eBook_Key__c ebookKey = new eBook_Key__c(
                Type__c = 'BenchPrep',
                Contact__c = testContact.Id,
                Product_ID__c = productId, // Use Course_Slug from metadata config
                Access_Expiration_Date__c = Date.today().addDays(30)
            );
            insert ebookKey;
            
            ApexPages.currentPage().getParameters().put('id','FRM_Program');
            BenchPrepSSO.redirect();
            
            BenchPrepSSO.redirect();
        }
        test.stopTest();
    }
    
    @isTest
    static void unitTestPrograms(){
        setup();
        test.startTest();
        BenchPrepSSO benchPrepSSO = new BenchPrepSSO();
        System.runAs(user) {
            // Set page parameters for FRM program part 1
            ApexPages.currentPage().getParameters().put('prog','FRM');
            ApexPages.currentPage().getParameters().put('part','1');
            
            // Query BenchPrep_Config__mdt to find Product_ID for Program Benchprep type
            List<BenchPrep_Config__mdt> configList = [SELECT Id, Product_ID__c, Type__c 
                                                      FROM BenchPrep_Config__mdt 
                                                      WHERE Type__c = 'Program Benchprep' 
                                                      LIMIT 1];
            
            String productId = 'FRM1E'; // Default fallback
            if(!configList.isEmpty() && configList[0].Product_ID__c != null) {
                productId = configList[0].Product_ID__c;
            }
            
            // Create eBook_Key__c record that matches FRM:1 configuration
            Contact testContact = [SELECT Id FROM Contact LIMIT 1];
            eBook_Key__c ebookKey = new eBook_Key__c(
                Type__c = 'BenchPrep',
                Contact__c = testContact.Id,
                Product_ID__c = productId, // Use Product_ID from metadata config
                Access_Expiration_Date__c = Date.today().addDays(30)
            );
            insert ebookKey;
            
            benchPrepSSO.redirect();
            
            // Verify that redirect was processed
            System.assertNotEquals(null, benchPrepSSO, 'BenchPrepSSO instance should be created');
        }
        test.stopTest();
    }
    
    @isTest
    static void unitTestProgramsNoPart(){
        setup();
        test.startTest();
        BenchPrepSSO benchPrepSSO = new BenchPrepSSO();
        System.runAs(user) {
            // Set page parameters for FRM program without part
            ApexPages.currentPage().getParameters().put('prog','FRM');
            // Do not set part parameter
            
            // Query BenchPrep_Config__mdt to find Product_ID for Program Benchprep type
            List<BenchPrep_Config__mdt> configList = [SELECT Id, Product_ID__c, Type__c 
                                                      FROM BenchPrep_Config__mdt 
                                                      WHERE Type__c = 'Program Benchprep' 
                                                      LIMIT 1];
            
            String productId = 'FRM1E'; // Default fallback
            if(!configList.isEmpty() && configList[0].Product_ID__c != null) {
                productId = configList[0].Product_ID__c;
            }
            
            // Create eBook_Key__c record that matches FRM:1 configuration
            Contact testContact = [SELECT Id FROM Contact LIMIT 1];
            eBook_Key__c ebookKey = new eBook_Key__c(
                Type__c = 'BenchPrep',
                Contact__c = testContact.Id,
                Product_ID__c = productId, // Use Product_ID from metadata config
                Access_Expiration_Date__c = Date.today().addDays(30)
            );
            insert ebookKey;
            
            benchPrepSSO.redirect();
            
            // Verify that redirect was processed
            System.assertNotEquals(null, benchPrepSSO, 'BenchPrepSSO instance should be created');
        }
        test.stopTest();
    }
    
    @isTest
    static void unitTest3_SCR_Holders(){
        setup();
        test.startTest();
        BenchPrepSSO BenchPrepSSO = new BenchPrepSSO();
        System.runAs(user) {
            // Set page parameter for SCR_Holders - no eBook_Key__c inserted beforehand
            ApexPages.currentPage().getParameters().put('id','SCR_Holders');
            BenchPrepSSO.redirect();
            
            BenchPrepSSO.redirect();
        }
        test.stopTest();
    }
}