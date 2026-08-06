@isTest
public class stripe_checkout_test {

    Static User user;
    Static Account account;
    Static Contact contact;
    Static Opportunity opp;
    
     static void setup(){
         // Setup Products
         GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
         
         // Create User
         user = GARP_TestFactory.createIndividualUser();
         
         // Create Member        
         //opp = GARP_TestFactory.createMember();
         
         opp = [select id,AccountId,StageName from Opportunity limit 1];
         
         System.Debug('**opp:' + opp);
         
         List<Contact> lstCont = [select id, accountId, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c from contact];
         contact = lstCont[0];        
         
         List<Account> lstAcct = [select id, Name from Account where id = :contact.accountId];
         account = lstAcct[0];        
         
         GARP_StripeSettings__c ss1 = new GARP_StripeSettings__c(Name='StripeSettingsXX',Is_Active__c=TRUE,Use_Stripe__c= TRUE,Server_Side_API_Key__c = 'test',Client_Side_API_Key__c='testclientkey');
         insert ss1;
     }
    
    @isTest
    static void unitTestFRM(){
        
        setup();
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.stripe_checkout;
        pageRef.getParameters().put('regType','frm');
        pageRef.getParameters().put('session_id','');
        pageRef.getParameters().put('id',opp.Id);
        
        Test.setCurrentPage(pageRef); 
        stripe_checkout ctrl1 = new stripe_checkout();
        ctrl1.initializeStripe();
        
        ctrl1.goToOrders();
        ctrl1.goToRegistration();
        ctrl1.goToMyAccount();
        
         test.stopTest();
    }
    
    @isTest
    static void unitTestMEM(){
        
        setup();
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.stripe_checkout;
        pageRef.getParameters().put('regType','mem');
        pageRef.getParameters().put('session_id','');
        pageRef.getParameters().put('id',opp.Id);
        
        Test.setCurrentPage(pageRef); 
        stripe_checkout ctrl1 = new stripe_checkout();
        ctrl1.initializeStripe();
        
        test.stopTest();
    }
    
    @isTest
    static void unitTestSCR(){
        
        setup();
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.stripe_checkout;
        pageRef.getParameters().put('regType','scr');
        pageRef.getParameters().put('session_id','');
        pageRef.getParameters().put('id',opp.Id);
        
        Test.setCurrentPage(pageRef); 
        stripe_checkout ctrl1 = new stripe_checkout();
        ctrl1.initializeStripe();
        
        test.stopTest();
    }
    
    @isTest
    static void unitTestRiskAI(){
        
        setup();
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.stripe_checkout;
        pageRef.getParameters().put('regType','riskai');
        pageRef.getParameters().put('session_id','');
        pageRef.getParameters().put('id',opp.Id);
        
        Test.setCurrentPage(pageRef); 
        stripe_checkout ctrl1 = new stripe_checkout();
        ctrl1.initializeStripe();
        
        test.stopTest();
    }
    
    @isTest
    static void unitTestRAIJ(){
        
        setup();
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.stripe_checkout;
        pageRef.getParameters().put('regType','raij');
        pageRef.getParameters().put('session_id','');
        pageRef.getParameters().put('id',opp.Id);
        
        Test.setCurrentPage(pageRef); 
        stripe_checkout ctrl1 = new stripe_checkout();
        ctrl1.initializeStripe();
        
        test.stopTest();
    }

    @isTest
    static void unitTestCheckout(){
        
        setup();
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.stripe_checkout;
        pageRef.getParameters().put('regType','checkout');
        pageRef.getParameters().put('session_id','');
        pageRef.getParameters().put('id',opp.Id);
        
        Test.setCurrentPage(pageRef); 
        stripe_checkout ctrl1 = new stripe_checkout();
        ctrl1.initializeStripe();
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest2(){
        
        setup();
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.stripe_checkout;
        pageRef.getParameters().put('mode','setup');
        
        Test.setCurrentPage(pageRef); 
        stripe_checkout ctrl1 = new stripe_checkout();
        ctrl1.initializeStripe();
        
        test.stopTest();
    }
}