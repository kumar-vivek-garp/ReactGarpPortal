@isTest
public class LoginController_Test{
    
    @TestSetup static void setupData() {
        
        Id profileId1 = [select id from profile where name=: 'Customer Community'].id;
        Account ac = new Account(name = 'Test Customer Community') ;
        insert ac;
        
        Contact con = new Contact(LastName = 'Test_Contact_Community' ,
                                  AccountId = ac.Id,
                                  First_Name_as_it_Appears_on_ID__c = 'Test',
                                  Middle_Name_as_it_Appears_on_ID__c = 'T',
                                  Last_Name_as_it_Appears_on_ID__c = 'Test');
        insert con;
        
        System.debug('@mal-CON-ID'+con.Id);
        
        User communityUser = new User(alias = 'comUser'
                                      ,email = 'testCommunityUsermig123@test.com'
                                      ,emailencodingkey='UTF-8'
                                      ,lastname = 'Batman'
                                      ,languagelocalekey='en_US'
                                      ,localesidkey='en_US'
                                      ,profileid = profileId1
                                      ,country = 'France'
                                      ,IsActive = true
                                      ,ContactId = con.Id
                                      ,timezonesidkey='America/Los_Angeles'
                                      ,username = 'testCommunityUsermig123@test.com');
        insert communityUser;
    }
    
    static testMethod void testLogin(){
        ApexPages.currentPage().getParameters().put('action', 'jobtarget');
        LoginController controller1 = new LoginController();        
        controller1.login();
        ApexPages.currentPage().getParameters().put('action', 'meeting');
        ApexPages.currentPage().getParameters().put('id', 'testid');
        LoginController controller2 = new LoginController();        
        controller2.login();
        controller2.resetPassword();
        Id BussinessRecId = RecordTypeHelper.GetRecordTypeId('Account','Business');
        Account acc = new Account(name = 'Test Account',RecordTypeID = BussinessRecId);
        insert acc;
        Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Contact','Member');
        Id memBusRecType = RecordTypeHelper.GetRecordTypeId('Contact','Business Relationship');
        Contact ct = new Contact(firstName='Fname',LastName='LName',KPI_FRM_Certified__c=true,accountId = acc.Id,Email='Test@Test.com',recordTypeId=memBusRecType);
        insert ct;
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'AFREE',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        insert prod;
        
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;  
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = activePricebook.Id, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        ApexPages.currentPage().getParameters().put('action', 'meeting');
        ApexPages.currentPage().getParameters().put('id',  null);
        
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX');
        //controller2.createMember(lc);
        LoginController controller3 = new LoginController();  
        controller3.username = ct.email;
        controller3.firstName = ct.firstName;
        controller3.LastName = ct.LastName;
        controller3.country = 'United States';
        controller3.company = 'test States';
        controller3.jobFunction = 'tst jobates';
        controller3.industry = 'tst industry';
        //controller3.register();
        
        //LoginController.getAllCustomerCompanies();
        //system.debug(controller3.jobFunctionList);
        //system.debug(controller3.industryList);
        //system.debug(controller3.countryList);
        
        controller3.init();
        controller3.checkIsLoggedIn();
        
        ApexPages.currentPage().getParameters().put('action', 'jobtarget');
        ApexPages.currentPage().getParameters().put('start', '/test/');
        
        //controller3.register();
        controller3.init();
        PageReference pg = controller3.login();
        System.debug('pg'+pg);
        controller3.checkIsLoggedIn();
        
        ApexPages.currentPage().getParameters().put('action', 'auth');
        
        //controller3.register();
        controller3.init();
        PageReference pg1 = controller3.login();
        System.debug('pg1'+pg1);
        controller3.checkIsLoggedIn();
        
        ct.GBI_Participant__c = false;
        Update ct;
        
        ApexPages.currentPage().getParameters().put('action', 'eBookFRM');
        controller3.username = 'Tes@ts.com';
        //controller3.register();
        controller3.init();
        PageReference pg2 = controller3.login();
        System.debug('pg2'+pg2);
        controller3.checkIsLoggedIn();
        
        LoginController controller4 = new LoginController();  
        controller4.isGRA = 'true';
        controller4.checkIsLoggedIn();
        PageReference pg3 = controller4.login();
        System.debug('pg3'+pg3);
        controller4.resetPasswordResetSuccessful();
        controller4.getHasErrors();
        
        LoginController controller5 = new LoginController();  
        ApexPages.currentPage().getParameters().put('start', 'my-account');
        ApexPages.currentPage().getParameters().put('garp_gated_url', 'http://www.garp.org');
        ApexPages.currentPage().getParameters().put('track_cta', 'paywall');
        controller5.username = 'Tes@ts.com';
        //controller3.register();
        controller5.init();
        PageReference pg5 = controller5.login();
        System.debug('pg5'+pg5);
        controller5.checkIsLoggedIn();
        
    }
    
    @isTest
    static void remainingTest(){
        
        Id BussinessRecId = RecordTypeHelper.GetRecordTypeId('Account','Business');
        Account acc = new Account(name = 'Test Account',RecordTypeID = BussinessRecId);
        insert acc;
        Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Contact','Member');
        Id memBusRecType = RecordTypeHelper.GetRecordTypeId('Contact','Business Relationship');
        Contact ct = new Contact(firstName='Fname',LastName='LName',KPI_FRM_Certified__c=true,accountId = acc.Id,Email='Test@Test.com',recordTypeId=memBusRecType);
        insert ct;
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'AFREE',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        insert prod;
        
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;  
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = activePricebook.Id, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        List<User> lstUsers = [SELECT Id,ContactId FROM
                               User WHERE username =: 'testCommunityUsermig123@test.com' LIMIT 1];
        
        
        
        system.runAs(lstUsers[0]){
            GARP_TestFactory.createCountryCodes();
            PageReference pageRef = new pagereference('https://test.com');
            Test.setCurrentPage(pageRef);
            LoginController controller5 = new LoginController();  
            ApexPages.currentPage().getParameters().put('action', 'auth');
            ApexPages.currentPage().getHeaders().put('CipherSuite','testaddress');
            ApexPages.currentPage().getHeaders().put('ReturnUrl','https://connect.garp.com');
            controller5.username = 'testCommunityUsermig123@test.com';
            controller5.password = 'pwdTes@ts.com';
            controller5.loginErrMsg = 'Error';
            controller5.regOppId = 'regOppId';
            controller5.sessionID = 'sessionID';
            PageReference pg4 = controller5.init();
            System.debug('pg4'+pg4);
            ct.GBI_Participant__c = True;
            Update ct;
            
            controller5.init();
            controller5.checkIsLoggedIn();       
            
            ApexPages.currentPage().getParameters().put('action', 'eBookFRM');
            ApexPages.currentPage().getParameters().put('actionId',  '1');
            ApexPages.currentPage().getParameters().put('start', '/test/');
            ApexPages.currentPage().getParameters().put('goto', 'test');
            
            controller5.action = 'eBookFRM';
            controller5.login();
            controller5.action = 'jobtarget';
            ApexPages.currentPage().getParameters().put('action', 'jobtarget');
            controller5.username = 'testCommunityUsermig123@test.com';
            controller5.init();
            controller5.login();
            controller5.action = 'auth';
            ApexPages.currentPage().getParameters().put('action', 'auth');
            controller5.username = 'testCommunityUsermig123@test.com';
            controller5.redirectParam = 'https://test.com';
            controller5.returnUrl = 'https://connect.garp.com';
            ApexPages.currentPage().getParameters().put('ReturnUrl', 'https://connect.garp.com');    
            ApexPages.currentPage().getParameters().put('username', 'testCommunityUsermig123@test.com');
            ApexPages.currentPage().getParameters().put('password', 'pwdTes@ts.com');
            controller5.username = 'testCommunityUsermig123@test.com';
            //controller5.login();
            controller5.init();
            ApexPages.currentPage().getParameters().put('actionId',  '1');
            controller5.action = 'eBookFRM';
            controller5.init();
            controller5.action = '';
            controller5.redirectParam = 'http://www.google.com';
            controller5.init();
            
            ApexPages.currentPage().getHeaders().put('CipherSuite','testaddress');
            ApexPages.currentPage().getHeaders().put('Referer','teststart=GBIReferer');
            PageReference pg5 = controller5.init();
            System.debug('pg5'+pg5);
            Default_Settings__c DS = new Default_Settings__c(Name = 'LogLogin',Active__c=True);
            insert DS;
            controller5.checkIsLoggedIn();
            
            //controller5.checkIsNewPortal('access_content');
        }
    }
    
    @isTest
    static void resetPassword(){
        
        List<User> lstUsers = [SELECT Id,ContactId FROM
                               User WHERE username =: 'testCommunityUsermig123@test.com' LIMIT 1];
        lstUsers[0].IsPortalEnabled = True;
        update lstUsers;
        
        system.runAs(lstUsers[0]){
            
            LoginController controller = new LoginController(); 
            controller.emailForPasswordReset='testCommunityUsermig123@test.com';
            controller.resetPassword();
        }
    }
    
    static testMethod void testLogin_test(){
        
        Id BussinessRecId = RecordTypeHelper.GetRecordTypeId('Account','Business');
        Account acc = new Account(name = 'Test Account',RecordTypeID = BussinessRecId);
        insert acc;
        Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Contact','Member');
        Id memBusRecType = RecordTypeHelper.GetRecordTypeId('Contact','Business Relationship');
        
        Contact ct = new Contact(firstName='Fname',LastName='LName',KPI_FRM_Certified__c=true,accountId = acc.Id,Email='Tes1@ts.com',recordTypeId=memBusRecType);
        insert ct;
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'AFREE',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        insert prod;
        
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;  
        
        insert new CAPTCHA_Configuration__c(Name = 'Exam Registration',Override_Key__c = 'testkey',Enabled__c = true);
        Lead lead = new Lead();
        
        lead.FirstName = 'firstName';
        lead.LastName = 'LastName';
        lead.Email = 'Tes@ts.com';
        lead.Company = 'TEST';
        
        INSERT lead;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = activePricebook.Id, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        //ApexPages.currentPage().getParameters().put('id',  null);
        
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX');
        
        ApexPages.currentPage().getParameters().put('action', 'meeting');
        LoginController controller3 = new LoginController();  
        controller3.username = 'Tes@ts.com';
        controller3.firstName = 'firstName';
        controller3.LastName = 'LastName';
        //controller3.register();
        controller3.init();
        controller3.login();
        controller3.checkIsLoggedIn();
        
        ApexPages.currentPage().getParameters().put('action', 'jobtarget');
        controller3.username = 'Tes@ts.com';
        controller3.firstName = 'firstName';
        controller3.LastName = 'LastName';
        //controller3.register();
        
    }
    
    
    /*static testMethod void testLoginLog(){
ApexPages.currentPage().getParameters().put('action', 'jobtarget');
LoginController1 controller1 = new LoginController1();        
controller1.login();
ApexPages.currentPage().getParameters().put('action', 'meeting');
ApexPages.currentPage().getParameters().put('id', 'testid');
LoginController1 controller2 = new LoginController1();        
controller2.login();
controller2.resetPassword();

Account acc = new Account(name='Test Account');
insert acc;
Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Contact','Member');
Contact ct = new Contact(firstName='Fname',LastName='LName',KPI_FRM_Certified__c=true,accountId = acc.Id,Email='Test@Test.com',recordTypeId=recordTypeID);
insert ct;

ApexPages.currentPage().getParameters().put('action', null);
ApexPages.currentPage().getParameters().put('id',  null);

//controller2.createMember(lc);
LoginController1 controller3 = new LoginController1();  
controller3.username = 'Test@Test.com';
controller3.register();

LoginController1.getAllCustomerCompanies();
system.debug(controller3.jobFunctionList);
system.debug(controller3.industryList);
system.debug(controller3.countryList);

controller3.init();
controller3.checkIsLoggedIn();

LoginController1 controller4 = new LoginController1();  
controller4.isGRA = 'true';
controller4.checkIsLoggedIn();
controller4.login();
controller4.resetPasswordResetSuccessful();
controller4.getHasErrors();


}*/
    
}