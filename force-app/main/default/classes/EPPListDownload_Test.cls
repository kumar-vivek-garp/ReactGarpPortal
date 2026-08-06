@isTest
public class EPPListDownload_Test {
    
    @testSetup
    static void setupTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community' LIMIT 1];
        
        Account a2 = new Account(name = 'Account2');
        insert a2;
        System.debug('Inserted Account a2: ' + a2.Id);
        
        Contact c1 = new Contact(
            do_not_fire__c = true, 
            GARP_Member_ID__c = '12345', 
            lastname = 'John', 
            FirstName = 'John',
            MailingCountry = 'United States of America',
            MailingStreet = '123 Test St',
            MailingCity = 'Test City',
            MailingState = 'TS',
            MailingPostalCode = '12345',
            AccountID = a2.ID, 
            email = 'john@contact.com', 
            KPI_Member__c = True, 
            Exam_Prep_Provider_Outreach__c = true,
            Phone = '1234567890'
        );
        insert c1;
        System.debug('Inserted Contact c1: ' + c1.Id);
        
        // EPP_Data_Manager__c and Region__c are likely set by workflow/process builder
        // If needed, update them via DML after insert if they become writeable
        // For now, the Contact will be queried in EPPListDownload constructor
        
        User user1 = new User(
            TimeZoneSidKey = 'America/Denver',
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            ContactId = c1.Id, 
            Username = 'johncontact@garp.com.test' + System.now().getTime(), 
            CommunityNickname = 'GARP SYSTEM',
            Alias = 'GSystem',
            CurrencyIsoCode = 'USD', 
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LastName = 'System', 
            Email = 'johncontact@garp.com'
        );
        insert user1;
        System.debug('Inserted User user1: ' + user1.Id);
        
        Account acc = new Account(name = 'Account1');
        insert acc;
        System.debug('Inserted Account acc: ' + acc.Id);
        
        EPP_Account__c EPPAccount1 = new EPP_Account__c(
            Name = 'Fred', 
            Primary_EPP_Contact__c = c1.Id, 
            EPP_FRM__c = true, 
            EPP_ERP__c = true, 
            EPP_Region_s__c = 'Americas', 
            EPP_Registration_Status__c = 'Approved', 
            Account__c = acc.Id,
            Program__c = 'FRM'
        ); 
        Insert EPPAccount1;
        System.debug('Inserted EPP_Account__c EPPAccount1: ' + EPPAccount1.Id);
        
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;    
        insert objExamGrp;
        System.debug('Inserted Exam_Group__c objExamGrp: ' + objExamGrp.Id);
        
        Exam__c exam = new Exam__c(Name='May 2015 ERP Exam', Exam__c='FRM', Exam_Code__c ='1111:2015~5');
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = Date.NewInstance(2015,5,1);
        insert exam;
        System.debug('Inserted Exam__c exam: ' + exam.Id);
        
        Site__c testsite = new Site__c(Name='USA, MA, BOSTON',Site_Code__c ='1800-11', Display_Address__c ='Westborough, Boston , MA, USA');
        insert testsite;
        System.debug('Inserted Site__c testsite: ' + testsite.Id);
        
        // Create Exam Administration
        Exam_Administration__c examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Type__c = 'FRM';
        examAdmin.Month__c = 'May';
        examAdmin.Year__c = 2015;
        examAdmin.Exam_Group__c = objExamGrp.Id;
        insert examAdmin;
        System.debug('Inserted Exam_Administration__c examAdmin: ' + examAdmin.Id);
        
        // Create Exam Part
        Exam_Part__c examPart = new Exam_Part__c();
        examPart.Exam_Administration__c = examAdmin.Id;
        examPart.Exam__c = exam.Id;
        examPart.Exam_Date__c = system.today() + 20;
        examPart.Exam_End_Date__c = system.today() + 25;
        examPart.Delivery_Method__c = 'CBT';
        insert examPart;
        System.debug('Inserted Exam_Part__c examPart: ' + examPart.Id);
        
        Exam_Sites__c examSite = new Exam_Sites__c(Name='May 2015 ERP Exam USA, MA, Boston', CurrencyIsoCode = 'USD', Site__c=testsite.id);
        examSite.Exam__c = exam.id;
        examSite.Exam_Part__c = examPart.Id;
        insert examSite;
        System.debug('Inserted Exam_Sites__c examSite: ' + examSite.Id);
        
        // Create EPP Deal
        EPP_Deal__c eppDeal = new EPP_Deal__c();
        eppDeal.EPP_Account__c = EPPAccount1.Id;
        eppDeal.Exam_Year__c = 2015;
        eppDeal.Report_Download_Type_1__c = 'January';
        eppDeal.Report_Download_DateTime_1__c = System.now();
        insert eppDeal;
        System.debug('Inserted EPP_Deal__c eppDeal: ' + eppDeal.Id + ', EPP_Account__c: ' + eppDeal.EPP_Account__c + ', Exam_Year__c: ' + eppDeal.Exam_Year__c);
    }
    
    static testMethod void testOptInReport(){
        Test.startTest();
        
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'john@contact.com' LIMIT 1];
        EPP_Account__c testEPPAccount = [SELECT Id FROM EPP_Account__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'johncontact@garp.com.test%' LIMIT 1];
        Exam_Sites__c testExamSite = [SELECT Id FROM Exam_Sites__c LIMIT 1];
        
        System.debug('testOptInReport - testContact.Id: ' + testContact.Id);
        System.debug('testOptInReport - testEPPAccount.Id: ' + testEPPAccount.Id);
        System.debug('testOptInReport - testUser.Id: ' + testUser.Id);
        System.debug('testOptInReport - testExamSite.Id: ' + testExamSite.Id);
        
        // Create Exam Attempt with only writable fields
        Exam_Attempt__c testExamAttempt = new Exam_Attempt__c(
            Name = 'Test Exam Attempt',
            Member__c = testContact.Id,
            Cancelled__c = false,
            EPP_Opt_In__c = System.now(), // DateTime field
            Exam_Site__c = testExamSite.Id
        );
        insert testExamAttempt;
        System.debug('testOptInReport - testExamAttempt.Id: ' + testExamAttempt.Id);
        System.debug('testOptInReport - testExamAttempt.EPP_Opt_In__c: ' + testExamAttempt.EPP_Opt_In__c);
        System.debug('testOptInReport - testExamAttempt.Reg_Status__c: ' + testExamAttempt.Reg_Status__c);
        System.debug('testOptInReport - testExamAttempt.Cancelled__c: ' + testExamAttempt.Cancelled__c);
        System.debug('testOptInReport - testExamAttempt.Candidate_Region__c: ' + testExamAttempt.Candidate_Region__c);
        System.debug('testOptInReport - testExamAttempt.RPT_Exam_Program__c: ' + testExamAttempt.RPT_Exam_Program__c);
        System.debug('testOptInReport - testExamAttempt.RPT_Administration_Year__c: ' + testExamAttempt.RPT_Administration_Year__c);
        System.debug('testOptInReport - testExamAttempt.RPT_Administration_Month__c: ' + testExamAttempt.RPT_Administration_Month__c);
        
        System.runAs(testUser){
            ApexPages.currentPage().getParameters().put('id', testEPPAccount.Id);
            ApexPages.currentPage().getParameters().put('type', 'optin');
            ApexPages.currentPage().getParameters().put('examprog', 'FRM');
            ApexPages.currentPage().getParameters().put('examyear', '2015');
            ApexPages.currentPage().getParameters().put('exammonth', 'May');
            
            EPPListDownload eppList = new EPPListDownload();
            eppList.getExamAttempts();
            
            // Test wrapper class
            EPPListDownload.wrapper w = new EPPListDownload.wrapper(); 
            w.garpId = '123';
            w.examName = 'FRM Part 1';
            w.email = 'mary@email.com';
            w.fName = 'Mary';
            w.lName = 'Doe';
            w.phone = '1234567890';
            w.membercountry = 'USA';
            w.region = 'Americas';
            w.examDate = 'May 2015';
            w.dateRegistered = system.today();
            w.mailingStreet = '123 Test St';
            w.MailingCity = 'Test City';
            w.MailingState = 'TS';
            w.MailingPostalCode = '12345';
            w.MailingCountry = 'USA';
            w.netNew = 'True';
            w.referalSource = 'Test';
            w.slno = 1;
        }
        
        Test.stopTest();
    }
    
    static testMethod void testReferralReport(){
        Test.startTest();
        
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'john@contact.com' LIMIT 1];
        EPP_Account__c testEPPAccount = [SELECT Id FROM EPP_Account__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'johncontact@garp.com.test%' LIMIT 1];
        Exam_Sites__c testExamSite = [SELECT Id FROM Exam_Sites__c LIMIT 1];
        
        // Create Exam Attempt for referral - EPP_Referal__c is likely a formula field
        // We'll create it and let formulas populate
        Exam_Attempt__c testExamAttempt = new Exam_Attempt__c(
            Name = 'Test Exam Attempt Referral',
            Member__c = testContact.Id,
            Cancelled__c = false,
            Exam_Site__c = testExamSite.Id
        );
        insert testExamAttempt;
        
        System.runAs(testUser){
            ApexPages.currentPage().getParameters().put('id', testEPPAccount.Id);
            ApexPages.currentPage().getParameters().put('type', 'referral');
            ApexPages.currentPage().getParameters().put('examprog', 'FRM');
            ApexPages.currentPage().getParameters().put('examyear', '2015');
            ApexPages.currentPage().getParameters().put('exammonth', 'May');
            
            EPPListDownload eppList = new EPPListDownload();
            eppList.getExamAttempts();
        }
        
        Test.stopTest();
    }
}