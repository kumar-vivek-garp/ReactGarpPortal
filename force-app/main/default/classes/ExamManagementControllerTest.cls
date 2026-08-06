@isTest
public class ExamManagementControllerTest {
    
    public static Account account;
    public static Contact contact;
    public static Profile profileId ;
    public static User user;
    static set<id> setOpportunities=new Set<id>();
    public static Exam_Sites__c examSiteChinaExamPart1;
    public static Exam_Sites__c examSiteChinaExamPart2;
    
    public static Exam_Sites__c examSiteNonChinaExamPart1;
    public static Exam_Sites__c examSiteNonChinaExamPart2;
    
    public static Site__c testSiteChina;    
    public static Site__c testSiteNonChina;    
    
    public static Exam_Group__c examGroup;
    public static Exam_Group__c examGroup1;
    public static Exam_Group__c nextExamGroup;
    
    public static Exam_Part__c exampart;
    public static Exam_Part__c exampart1;
    public static Exam_Part__c exampart2;
    
    public static Exam_Administration__c examAdmin;
    public static Exam_Administration__c examAdmin1;
    
    public static List<Exam_attempt__c> examRegList = new  List<Exam_attempt__c>();
    public static Exam__c frmPart1;
    public static Exam__c frmPart2;
    
    public static Product2 CHLF;
    public static Product2 OSTA;
    public static Product2 FRMRET1;
    public static Product2 FRMRET2;
    public static Product2 ERPRET1;
    public static Product2 ERPRET2;
    
    public static PricebookEntry CHLFPBE;
    public static PricebookEntry OSTAPBE;
    public static PricebookEntry FRMRET1PBE;
    public static PricebookEntry FRMRET2PBE;
    public static PricebookEntry ERPRET1PBE;
    public static PricebookEntry ERPRET2PBE;
    
    
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
    
    public static void setup(){
        
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;  
        
        Id pricebookId = activePricebook.Id;
        
        //FEES      
        CHLF = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'CHLF', GL_Code__c = '4999', Family = 'Hardware', IsActive = true);
        OSTA = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'CHNDF', GL_Code__c = '2009', Family = 'Hardware', IsActive = true);
        FRMRET1 = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'FRMRET1', GL_Code__c = '2009', Family = 'Hardware', IsActive = true);
        FRMRET2 = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'FRMRET2', GL_Code__c = '2009', Family = 'Hardware', IsActive = true);
        ERPRET1 = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'ERPRET1', GL_Code__c = '2009', Family = 'Hardware', IsActive = true);
        ERPRET2 = new Product2(Company__c = 'GARP', Name = 'Laptop X200', ProductCode = 'ERPRET2', GL_Code__c = '2009', Family = 'Hardware', IsActive = true);
        
        INSERT CHLF;
        INSERT OSTA;
        INSERT FRMRET1;
        INSERT FRMRET2;
        INSERT ERPRET1;
        INSERT ERPRET2;
        
        CHLFPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = CHLF.Id, UnitPrice = 10000, IsActive = true);
        OSTAPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = OSTA.Id, UnitPrice = 10000, IsActive = true);
        FRMRET1PBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = FRMRET1.Id, UnitPrice = 10000, IsActive = true);
        FRMRET2PBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = FRMRET2.Id, UnitPrice = 10000, IsActive = true);
        ERPRET1PBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = ERPRET1.Id, UnitPrice = 10000, IsActive = true);
        ERPRET2PBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = ERPRET2.Id, UnitPrice = 10000, IsActive = true);
        
        INSERT CHLFPBE;
        INSERT OSTAPBE;
        INSERT FRMRET1PBE;
        INSERT FRMRET2PBE;
        INSERT ERPRET1PBE;
        INSERT ERPRET2PBE;
        
        List<Exam_Group__c> examGroupList = new List<Exam_Group__c>();
        nextExamGroup = new Exam_Group__c();
        nextExamGroup.Name = '21-Nov';
        nextExamGroup.Active__c = false;
        nextExamGroup.SCR_Active__c = false;
        nextExamGroup.Registration_Start_Date__c = Date.today().addDays(20);
        nextExamGroup.Exam_Date__c = Date.today().addDays(-5);
        nextExamGroup.Exam_Change_Start_Date_Time__c= DateTime.now().addDays(30);
        insert nextExamGroup;
        
        examGroup = new Exam_Group__c();
        examGroup.Name = '21-May';
        examGroup.Active__c = TRUE;
        examGroup.Exam_Date__c = Date.today().addDays(-5);
        examGroup.Next_Exam_Group__c = nextExamGroup.id;
        examGroup.Exam_Ticket_Available_Date__c = Date.today().addDays(10);
        examGroup.Exam_Results_Available_Date__c = Date.today().addDays(10);
        examGroup.Exam_Change_Start_Date_Time__c= DateTime.now().addDays(15);
        examGroupList.add(examGroup);
        
        examGroup = new Exam_Group__c();
        examGroup.Name = '21-SCR';
        examGroup.SCR_Active__c = true;
        examGroup.Next_Exam_Group__c = nextExamGroup.id;
        examGroup.Exam_Date__c = Date.today().addDays(-5);
        examGroup.Exam_Ticket_Available_Date__c = Date.today().addDays(10);
        examGroup.Exam_Results_Available_Date__c = Date.today().addDays(10);
        examGroup.Exam_Change_Start_Date_Time__c= DateTime.now().addDays(15);
        examGroupList.add(examGroup);
        
        insert examGroupList;
        
        frmPart1 = new Exam__c();
        frmPart1.Name = 'May 2018 FRM Exam Part I';
        frmPart1.Exam_Group__c = examGroup.Id;
        frmPart1.Exam__c = 'FRM Part 1';
        frmPart1.Exam_Date__c = Date.today().addDays(10); 
        INSERT frmPart1; 
        
        frmPart2 = new Exam__c();
        frmPart2.Name = 'May 2018 FRM Exam Part II';
        frmPart2.Exam_Group__c = examGroup.Id;
        frmPart2.Exam__c = 'FRM Part 2';
        frmPart2.Exam_Date__c = Date.today().addDays(10);
        INSERT frmPart2;
        account = new Account();
        account = [Select Id,Name From Account Where Name =:'Test Customer Community' limit 1];
        contact = new Contact();
        contact = [Select Id,Name, FirstName, LastName, Email, HomePhone, accountId, Account.BillingCountry, Account.BillingState,
                   Account.BillingPostalCode, Account.BillingStreet, Account.BillingCity
                   From Contact Where LastName =:'Test_Contact_Community' limit 1];
        /* account = new Account();
account.Name = 'TEST CO';
INSERT account;

contact = new Contact();
contact.Email = 'TEST@TEST.com';
contact.FirstName = 'TEST';
contact.LastName = 'TEST';

contact.AccountId = account.Id;
contact.First_Name_as_it_Appears_on_ID__c = 'Test';
contact.Middle_Name_as_it_Appears_on_ID__c = 'T';
contact.Last_Name_as_it_Appears_on_ID__c = 'Test';
INSERT contact;*/
        
        
        profileid = [Select Id from profile where Name='Customer Community']; //System Administrator
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        user = new User(firstname = 'ABC', lastName = 'XYZ', email = uniqueName + '@test' + orgId + '.org',ContactId = contact.Id, 
                        Username = uniqueName + '@test' + orgId + '.org', EmailEncodingKey = 'ISO-8859-1',IsActive =true, 
                        Alias = uniqueName.substring(18, 23), TimeZoneSidKey = 'America/Los_Angeles', 
                        LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', ProfileId = profileId.Id);
        /*insert user;
user = new User(LastName = 'testLIVESTON',
FirstName='testJASON',
ContactId = contact.id,
Alias = 'test',
Email = 'test.liveston@asdf.com',
Username = 'testliveston@asdf.com',
ProfileId = profileId.id,
TimeZoneSidKey = 'GMT',
LanguageLocaleKey = 'en_US',
EmailEncodingKey = 'UTF-8',
LocaleSidKey = 'en_US'
);
insert user;*/
        
        testSiteChina = new Site__c();
        testSiteChina.Name = 'China, Guangzhou';
        testSiteChina.Active__c = true;
        testSiteChina.Display_Address__c = 'China, Guangzhou';
        testSiteChina.Is_OSTA_Information_Required__c = true;
        INSERT testSiteChina;
        
        testSiteNonChina = new Site__c();
        testSiteNonChina.Name = 'Canada, Surrey';
        testSiteNonChina.Active__c = true;
        testSiteNonChina.Display_Address__c = 'Canada, Surrey';
        testSiteNonChina.Is_OSTA_Information_Required__c = false;
        INSERT testSiteNonChina;
        
        examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = examGroup.id;
        examAdmin.Exam_Date__c = system.today();
        examAdmin.Exam_Type__c = 'FRM' ;
        examAdmin.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin;
        
        exampart = new Exam_Part__c();
        exampart.Exam__c = frmPart1.Id;
        exampart.Exam_Administration__c = examAdmin.Id ;
        exampart.Delivery_Method__c = 'CBT';
        exampart.Exam_Start_Date__c = Date.today();
        exampart.Exam_Date__c = Date.today();
        exampart.Exam_End_Date__c = Date.today().addDays(10);
        
        insert exampart;
        
        exampart2 = new Exam_Part__c();
        exampart2.Exam__c = frmPart2.Id;
        exampart2.Exam_Administration__c = examAdmin.Id ;
        exampart2.Delivery_Method__c = 'CBT';
        exampart2.Exam_Start_Date__c = Date.today();
        exampart2.Exam_Date__c = Date.today();
        exampart2.Exam_End_Date__c = Date.today().addDays(10);
        
        insert exampart2;
        
        examSiteChinaExamPart1 = new Exam_Sites__c();
        examSiteChinaExamPart1.Name = 'May 2018 FRM Exam Part I, China, Guangzhou';
        examSiteChinaExamPart1.Site__c = testSiteChina.Id;
        examSiteChinaExamPart1.Exam__c = frmPart1.Id;
        examSiteChinaExamPart1.Exam_Part__c = exampart.Id;
        INSERT examSiteChinaExamPart1;
        
        examSiteChinaExamPart2 = new Exam_Sites__c();
        examSiteChinaExamPart2.Name = 'May 2018 FRM Exam Part II, China, Guangzhou';
        examSiteChinaExamPart2.Site__c = testSiteChina.Id;
        examSiteChinaExamPart2.Exam__c = frmPart2.Id;
        examSiteChinaExamPart2.Exam_Part__c = exampart2.Id;
        INSERT examSiteChinaExamPart2;
        
        examSiteNonChinaExamPart1 = new Exam_Sites__c();
        examSiteNonChinaExamPart1.Name = 'May 2018 FRM Exam Part I, Canada, Surrey';
        examSiteNonChinaExamPart1.Site__c = testSiteNonChina.Id;
        examSiteNonChinaExamPart1.Exam__c = frmPart1.Id;
        examSiteNonChinaExamPart1.Exam_Part__c = exampart.Id;
        INSERT examSiteNonChinaExamPart1;
        
        examSiteNonChinaExamPart2 = new Exam_Sites__c();
        examSiteNonChinaExamPart2.Name = 'May 2018 FRM Exam Part II, Canada, Surrey';
        examSiteNonChinaExamPart2.Site__c = testSiteNonChina.Id;
        examSiteNonChinaExamPart2.Exam__c = frmPart2.Id;
        examSiteNonChinaExamPart2.Exam_Part__c = exampart2.Id;
        INSERT examSiteNonChinaExamPart2;
        
    }
    
    static Account acc;
    //static sfdcAppRemoter.fieldInfo fieldInfo;
    //static sfdcAppRemoter.getUserReturnData getUserReturnData;
    static Product2 prod;
    static Product2 prod1;
    static Product2 prod2;
    static Product2 prod3;
    static Opportunity opp,opp1;
    //static Registration.wrapperCreateOrder wco;
    static Contract contract;
    static Contact contact1;
    static Profile profile;
    static User user1;
    static Lead lead;
    static Site__c site;
    static Exam_Group__c objExamGrp;
    static Exam__c exam;
    static Exam_Sites__c exmSite;
    static Candidate_Requirement__c reqt;
    static Exam_Attempt__c attempt1;
    static Exam_Attempt__c attempt;
    
    static void testDataSfdc(){ 
        
        //sfdcAppRemoter.account=acc;
        //fieldInfo = new sfdcAppRemoter.fieldInfo();
        //fieldInfo.name = 'firstname';
        //fieldInfo.label = 'first name'; 
        //fieldInfo.type = 'text'; 
        //fieldInfo.maxLength = 20;
        //fieldInfo.description = 'test';
        
        //getUserReturnData = new sfdcAppRemoter.getUserReturnData();
        List<eBook_Key__c> ebookkeylst = new List<eBook_Key__c>(); 
        eBook_Key__c ekey = new eBook_Key__c(Name='Test Key', Key__c='23424refef1', Type__c = 'ERP Exam Part I',Access_Duration_in_Months__c=36);
        ebookkeylst.add(ekey);
        eBook_Key__c ekey1 = new eBook_Key__c(Name='Test Key', Key__c='23424refef2', Type__c = 'ERP Exam Part II',Access_Duration_in_Months__c=36);
        ebookkeylst.add(ekey1);
        eBook_Key__c ekey2 = new eBook_Key__c(Name='Test Key', Key__c='23424refef3', Type__c = 'FRR',Access_Duration_in_Months__c=36);
        ebookkeylst.add(ekey2);
        eBook_Key__c ekey3 = new eBook_Key__c(Name='Test Key', Key__c='23424refef4', Type__c = 'FFR',Access_Duration_in_Months__c=36);
        ebookkeylst.add(ekey3);
        insert ebookkeylst;
        //getUserReturnData.eBookData = ebookkeylst;
        prod = new Product2(FRM_Exam__c=True, ERP_Exam__c=True, FRM_1_Book__c=True, FRM_2_Book__c=True, ERP_Study_Center__c=True, ICBRR_Study_Center__c=True, SCR_Study_Center__c=True,FBR_Study_Center__c = True, FRM_Study_Center__c = true,Name = 'Laptop X200',productCode = 'AFREE',GL_Code__c = '4999',Family = 'Hardware',Weight__c=3,isActive = true);
        insert prod;
        
        prod1 = new Product2(FRM_Exam__c=True, ERP_Exam__c=True, FRM_1_Book__c=True, FRM_2_Book__c=True, ICBRR_Study_Center__c=True, FBR_Study_Center__c = True, SCR_Study_Center__c=True,ERP_Study_Center__c = true,Name = 'Laptop X200',productCode = 'MEMR',GL_Code__c = '2007',Family = 'Hardware',Weight__c=3,isActive = true);
        insert prod1;
        
        prod2 = new Product2(Name = 'Laptop X200',productCode = 'FRM1S',GL_Code__c = '4999',Family = 'Hardware',Weight__c=3,isActive = true);
        insert prod2; 
        
        prod3 = new Product2(Name = 'For Testing RestoreAMPFree',productCode = 'PRFEE',GL_Code__c = '6110',Family = 'Hardware',Weight__c=3,isActive = true);
        insert prod3;
        
        Product2 prod4 = new Product2(Name = 'For Testing RestoreAMPFree',productCode = 'SLSTX',GL_Code__c = '6110',Family = 'Hardware',Weight__c=3,isActive = true);
        insert prod4;
        Product2 prod5 = new Product2(Name = 'For Testing RestoreAMPFree',productCode = 'SHIP',GL_Code__c = '6110',Family = 'Hardware',Weight__c=3,isActive = true);
        insert prod5;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry restoreAmpFreeEntry1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod3.Id,UnitPrice = 10000, IsActive = true);
        insert restoreAmpFreeEntry1;
        
        PricebookEntry restoreAmpFreeEntry2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod3.Id,UnitPrice = 10000, IsActive = true);
        insert restoreAmpFreeEntry2;
        
        PricebookEntry customPrice = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice; 
        
        PricebookEntry customPrice1 = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod1.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice1;
        
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod4.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice4;
        
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod5.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice5;
        
        insert new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX');        
        
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        insert new UpdateIds__c(Name= 'ICBRR', Record_Id__c = 'a1e40000006sqih');   
        //a1e40000006sqih  a0Cf0000004O778
        acc = new Account(
            Name = 'TestAccount',
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Account','Individual'),
            CurrencyIsoCode  = 'USD'
        );
        
        insert acc;
        
        
        contact = new Contact(KPI_ERP_Certified__c = true,KPI_FRM_Certified__c = true,GARP_Directory_Opt_In__c = true,Membership_Type__c='Individual',
                              Company__c='test',Job_Function__c='Consulting',Corporate_Title__c='Associate',Area_of_Concentration__c='Individual',
                              Other_Qualifications__c='test',KPI_membership_Payment_Status__c='In Good Standing',lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        Team_Registration__c Reg = new Team_Registration__c(BD_Rep_Email__c='test123@gmail.com',Name='test team reg',
                                                            Contact__c=contact.Id,End_Date__c=system.today(),
                                                            Start_Date__c=system.today()-1,
                                                            Manual_Invoice_Number__c='INV-000115',
                                                            Payment_Status__c='paid',Exam_Type__c='FRR',
                                                            Include_Exam_or_Courses__c = TRUE,
                                                            Discounted_Price__c=NULL,Seats_Allowed__c =4,Seats_Used__c=1);
        insert reg;
        
        opp = new Opportunity(amount = 123,Name = 'Test', Team_Registration__c = Reg.id, Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        //wco = new Registration.wrapperCreateOrder();
        //wco.opportunityId = opp.Id;
        
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contract; 
        Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = ContractRecordTypeInfo .get('SCR Program').getRecordTypeId();
        contract = new Contract(Opportunity__c = opp.id,AccountId = acc.id,recordTypeId = rtId);
        insert contract;
        
        Contract  = new Contract(Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12     ,StartDate = opp.CloseDate        );
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        
        
        user = [select Id, Email from User where contactId = :contact.Id];
        
        //user = [select Id, Email from User where contactId = :contact.Id];
        
        contact1 = new Contact(
            KPI_ERP_Certified__c = true,
            KPI_FRM_Certified__c = true,
            GARP_Directory_Opt_In__c = true,
            recordtypeId = RecordTypeHelper.GetRecordTypeId('Contact','Business Relationship'),
            firstname = 'FirstNameTest',
            lastname = 'Testdhaskd',
            AccountId = acc.id,
            email='daghtest@test.com',
            Membership_Type__c='Individual',
            KPI_membership_Payment_Status__c='In Good Standing',
            KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),
            Name_As_it_Appears_On_ID__c = 'testtest',
            ID_Number__c = 'dasf123l',
            ID_Type__c = 'Passport',
            Company__c='test',Job_Function__c='Consulting',Corporate_Title__c='Associate',Area_of_Concentration__c='Individual'
        );
        
        INSERT contact1;
        
        
        profile = [SELECT Id FROM Profile WHERE id = '00e400000017dA8' limit 1]; 
        
        user1 = new User(
            Alias = 'newUser', 
            Email='newuser@testorg.com', 
            contactId = contact1.id,
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='newuser@testorg.com'
        );
        
        INSERT user1;
        
        lead = new Lead(lastname = 'test',firstName = 'test' ,status = 'Open',email= 'test@test.com',company = acc.id);
        insert lead;
        
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;   
        objExamGrp.Loading_Exam_Results__c=True;
        insert objExamGrp;
        
        exam = new Exam__c();
        exam.Name='testexam';
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1'; 
        insert exam;
        
        exmSite = new Exam_Sites__c(Name='testsite',Exam_Date__c = system.today().addDays(30),Site__c =site.id,exam__c = exam.id);
        insert exmSite;
        
        reqt = new Candidate_Requirement__c();
        reqt.Candidate_Commitment__c = contract.id;
        reqt.name = 'FRM1 test';
        insert reqt;
        
        attempt1 = new Exam_Attempt__c(Opportunity__c = opp.id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false, Candidate_Requirement__c=reqt.id);
        insert attempt1;
        
        
        attempt = new Exam_Attempt__c(Opportunity__c = opp.id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false, Candidate_Requirement__c=reqt.id,
                                      Other_Exam_Registrations__c=attempt1.id, Result__c = 'Pass');
        insert attempt;
        
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id,Product2Id = prod1.Id,PricebookEntryId = standardPrice1.Id,UnitPrice = 7000,Description='test',
                                                                  Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = attempt1.Id);
        insert oppLineItem;
        
        OpportunityLineItem oppLineItem4 = new OpportunityLineItem(OpportunityId = opp.Id,Product2Id = prod4.Id,PricebookEntryId = standardPrice4.Id,UnitPrice = 7000,Description='test',
                                                                  Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = attempt1.Id);
        insert oppLineItem4;
        
        OpportunityLineItem oppLineItem5 = new OpportunityLineItem(OpportunityId = opp.Id,Product2Id = prod5.Id,PricebookEntryId = standardPrice5.Id,UnitPrice = 7000,Description='test',
                                                                  Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = attempt1.Id);
        insert oppLineItem5;
        
        contact.CPE_Current_Program_Requirement__c = reqt.Id;
        update contact;
                        
        tempAccount tempAccount = new tempAccount();
        tempAccount.id = contact.id; 
        tempAccount.eppHelp = true;
        tempAccount.infoExchange = true;
        tempAccount.contactId = contact.id;
        tempAccount.FirstName = 'test';
        tempAccount.LastName = 'test';
        tempAccount.Email = 'test@test.com';
        tempAccount.Membership_Type = 'AFREE';
        tempAccount.garpMembership_Type = 'AFREE';
        tempAccount.ACCA = false;
        tempAccount.CA = false;
        tempAccount.CFA = false;
        tempAccount.CMA = false;
        tempAccount.CPA = false;
        tempAccount.InSchool = false;
        tempAccount.OtherDesignation = false;
        tempAccount.PMP = false;
        tempAccount.autoRenew = false;
        tempAccount.erpSwitch = false;
        tempAccount.frmSwitch = false;
        tempAccount.graduationDate = 'Invalid Date';
        tempAccount.hasBooks = false;
        tempAccount.isErpChecked = false;
        tempAccount.isFbrChecked = false;
        tempAccount.isFbraChecked = false;
        tempAccount.isFrmChecked = false;
        tempAccount.isIcbrChecked = false;
        tempAccount.isStudentChecked = false;
        tempAccount.productcode = new List<String>(); 
        TempAccount.productDefinition productDefition = new TempAccount.productDefinition();
        productDefition.GLCode = '4999';
        productDefition.ProductCode = 'AFREE';
        tempAccount.productcode1 = new TempAccount.productDefinition[]{ productDefition };   
            tempAccount.siteName = 'undefined';
        tempAccount.isWorking = false;
        tempAccount.jobTarget = false;       
        tempAccount.referral = 'Bloomberg Terminal'; 
        tempAccount.sameShip = 'true';
        tempAccount.switchFeeEnabled = false;
        tempAccount.ShippingOptionsString = 'test:12,test:12,test:12';
        tempAccount.BillingStreetTwo = 'test';
        tempAccount.BillingStreetThree = 'test';
        tempAccount.MailingStreetTwo = 'test';
        tempAccount.MailingStreetThree = 'test';
        tempAccount.isFrmChecked = true;
        tempAccount.OtherDesignation = true;
        tempAccount.isStudentChecked = true;
        tempAccount.taxPrice = 123;
        tempAccount.isIcbrChecked = true;
        tempAccount.siteName = 'test';
        
        Content__c content = new Content__c();
        content.Content_Type__c = 'News Feed' ;
        //content.Status__c = 'Draft' ;
        content.Status__c = 'Active' ;
        content.Visibility_ERP__c = 'Certified';
        content.Visibility_SCR__c = 'Certified';
        content.Visibility_FRM__c = 'Certified';
        content.Visibility_Membership__c='Paid';
        content.Is_On_Demand__c = true;
        content.Raw_HTML__c = 'test';
        insert content;
        
        Folder__c folder = new Folder__c();
        folder.Name = 'Test';
        insert folder;
        
        Content_Folders__c content_folder = new Content_Folders__c();
        content_folder.Content__c = content.Id;
        content_folder.Folder__c = folder.Id;
        
        insert content_folder;
                                
    }
    
    
    
    @isTest
    public static void testSfdcMethods(){
        testDataSfdc();
        Test.startTest();
        ExamManagementRemoter.getExamResults('');
        Test.stopTest();
    }
        
        
    @isTest
    public static void startOutsideOfChinaAndSwitchIntoChina(){
        
        setup();
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        setOpportunities.add(opportunity.id);
        Exam_Attempt__c examRegistration2 = new Exam_Attempt__c();
        examRegistration2.Member__c = contact.Id;
        examRegistration2.Opportunity__c = opportunity.Id;
        examRegistration2.Defered__c = 'Approved';
        examRegistration2.Cancelled__c=True;
        examRegistration2.Exam_Site__c=examSiteChinaExamPart1.id;
        examRegList.add(examRegistration2);
        INSERT examRegList;
        
        Exam_Administration__c examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = examGroup.id;
        examAdmin1.Exam_Date__c = system.today();
        examAdmin1.Exam_Type__c = 'FRM' ;
        examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        examAdmin1.Exam_Admin_Modifications_Start_Date__c = system.today()+4;   
        examAdmin1.Exam_Admin_Modifications_End_Date__c = system.today().adddays(30);   
        examAdmin1.Exam_Scheduling_Start_Date__c = system.today()+4;    
        examAdmin1.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        insert examAdmin1;
        
        Exam_Part__c expart1 = new Exam_Part__c();
        expart1.Exam__c = frmPart2.Id;
        expart1.Exam_Administration__c = examAdmin1.Id ;
        expart1.Exam__c=frmPart1.id;
        expart1.Delivery_Method__c = 'CBT';
        
        expart1.Exam_Start_Date__c = Date.today();
        expart1.Exam_Date__c = Date.today();
        expart1.Exam_End_Date__c = Date.today().addDays(10);
        
        insert expart1;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Exam_Part__c = expart1.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Exam_Site__c = examSiteNonChinaExamPart2.Id;
        examRegistration.Cloned_From__c = examRegList[0].Id;
        examRegistration.Exam_Administration__c  = examAdmin1.Id ;
        INSERT examRegistration;
        
        OpportunityLineItem oppli1 = new OpportunityLineItem();
        oppli1.Quantity=1;
        oppli1.OpportunityId=opportunity.Id; 
        oppli1.TotalPrice=10;
        oppli1.PriceBookEntryId = CHLFPBE.Id;
        insert oppli1;
        
        
        Test.startTest();
        ExamManagementRemoter.changeExamSiteOnExamRegistrations(examRegistration.Id, examSiteChinaExamPart1.Id);
        
        Date tdy = Date.today();
        ExamManagementRemoter.updateOSTAIDInfo(contact.Id, 'Passport', '12345657', 'China', tdy);
        ExamManagementController.computeNumberOfDeferredOutExamRegistrationsInActiveCycle(examRegList);       
        
        Site__c chinaHongKong = [select id,Is_OSTA_Information_Required__c from Site__c where Is_OSTA_Information_Required__c = false limit 1];
        chinaHongKong.Is_OSTA_Information_Required__c = True;
        update chinaHongKong;
        ExamManagementRemoter.updateOSTAIDInfo(contact.Id, 'Passport', '12345657', 'China', tdy);
        Test.stopTest();
    }
    
    @isTest
    public static void startInsideOfChinaAndSwitchOutOfChina(){
        
        setup();
        
        Contract frmProgram = new Contract(
            AccountId = account.Id,
            //RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'OSTA Program'),
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program'),
            Status = 'Draft',
            Name = 'FRM Program',
            StartDate = Date.today(),
            ContractTerm = 9999
        );
        
        INSERT frmProgram;
        
        frmProgram.Status = 'Activated ( Auto-Renew )';
        
        UPDATE frmProgram; 
        
        /*Contract frmProgram1 = new Contract(
AccountId = account.id,
RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program'),
Status = 'Draft',
Name = 'FRM Program1',
CustomerSignedId = contact.id,
StartDate = Date.today(),
ContractTerm = 9999
);

INSERT frmProgram1;

frmProgram1.Status = 'Activated ( Auto-Renew )';

UPDATE frmProgram1; */
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'New Lead';
        opportunity.CloseDate = Date.today();
        INSERT opportunity;
        
        Opportunity opportunity1 = new Opportunity();
        opportunity1.AccountId = account.Id;
        opportunity1.Amount = 700.00;
        opportunity1.Name = 'TEST';
        opportunity1.StageName = 'Closed';
        opportunity1.CloseDate = Date.today();
        INSERT opportunity1;
        
        
        
        Id pricebookId = Test.getStandardPricebookId();
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Exam_Site__c = examSiteChinaExamPart1.Id;
        INSERT examRegistration;
        
        Exam_Attempt__c examRegistrationClosed = new Exam_Attempt__c();
        examRegistrationClosed.Member__c = contact.Id;
        examRegistrationClosed.Opportunity__c = opportunity1.Id;
        examRegistrationClosed.Exam_Site__c = examSiteChinaExamPart1.Id;
        INSERT examRegistrationClosed;
       
        /*OSTA_Exam_Registration_Data__c OstaExamRegData=new OSTA_Exam_Registration_Data__c();
OstaExamRegData.Exam_Registration__c=examRegistration.id;
OstaExamRegData.OSTA_Program__c=frmProgram.id;
insert OstaExamRegData;*/
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opportunity1.Id;
        oli.Product2Id = CHLF.Id;
        oli.UnitPrice = 40.00;
        oli.Quantity = 1;
        oli.PricebookEntryId = CHLFPBE.Id;
        oli.Exam_Registration__c = examRegistration.Id;
        INSERT oli;
        
        OpportunityLineItem osta = new OpportunityLineItem();
        osta.OpportunityId = opportunity.Id;
        osta.Product2Id = OSTA.Id;
        osta.UnitPrice = 10.00;
        osta.Quantity = 1;
        osta.PricebookEntryId = OSTAPBE.Id;
        osta.Exam_Registration__c = examRegistration.Id;
        INSERT osta;
        
        opportunity.StageName = 'Closed';
        UPDATE opportunity;
        
        Test.startTest();
         
        Contract ostaProgram = ExamManagementController.createOstaProgram(opportunity, osta);
        ostaProgram = ExamManagementController.fetchOstaProgram(account.Id);
        ExamManagementController.createOrUpdateOstaExamRegistrationData(ostaProgram);
        ///ExamManagementController.createOrUpdateOstaExamRegistrationData(frmProgram);
        ExamManagementController.changeExamSiteOnExamRegistrations(examRegistration.Id, examSiteNonChinaExamPart1.Id);
        
        Contract ostaProgram1 = ExamManagementController.createOstaProgram(opportunity1, oli);
        ostaProgram1 = ExamManagementController.fetchOstaProgram(account.Id);
        ExamManagementController.createOrUpdateOstaExamRegistrationData(ostaProgram1);
        //ExamManagementController.createOrUpdateOstaExamRegistrationData(frmProgram1);
        ExamManagementController.changeExamSiteOnExamRegistrations(examRegistrationClosed.Id, examSiteNonChinaExamPart1.Id);
        Test.stopTest();
    } 
    
    
    @isTest
    public static void deferAndUndeferChinaExamRegistrations(){
        
        setup();
        Contract frmProgram = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program'),
            Status = 'Draft',
            Name = 'FRM Program',
            StartDate = Date.today(),
            ContractTerm = 9999
        );
        INSERT frmProgram;
        frmProgram.Status = 'Activated ( Auto-Renew )';
        UPDATE frmProgram; 
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        INSERT opportunity;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Exam_Site__c = examSiteNonChinaExamPart1.Id;
        examRegList.add(examRegistration);
        
        Exam_Attempt__c examReg = new Exam_Attempt__c();
        examReg.Member__c = contact.Id;
        examReg.Opportunity__c = opportunity.Id;
        examReg.Exam_Site__c = examSiteChinaExamPart2.Id;
        examRegList.add(examReg);
        INSERT examRegList;
            
        Exam_Attempt__c examRegistrationPart1 = new Exam_Attempt__c();
        examRegistrationPart1.Member__c = contact.Id;
        examRegistrationPart1.Opportunity__c = opportunity.Id;
        examRegistrationPart1.Cancelled__c = FALSE;
        examRegistrationPart1.Exam_Site__c = examSiteChinaExamPart1.Id;
        examRegistrationPart1.Cloned_From__c = examRegList[0].Id;
        INSERT examRegistrationPart1;
        
        Exam_Attempt__c examRegistrationPart2 = new Exam_Attempt__c();
        examRegistrationPart2.Member__c = contact.Id;
        examRegistrationPart2.Opportunity__c = opportunity.Id;
        examRegistrationPart2.Cancelled__c = FALSE;
        examRegistrationPart2.Exam_Site__c = examSiteChinaExamPart2.Id;
        examRegistrationPart1.Cloned_From__c = examRegList[1].Id;
        INSERT examRegistrationPart2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opportunity.Id;
        oli.Product2Id = CHLF.Id;
        oli.UnitPrice = 40.00;
        oli.Quantity = 1;
        oli.PricebookEntryId = CHLFPBE.Id;
        oli.Exam_Registration__c = examRegistrationPart2.Id;
        INSERT oli;
        
        
        Test.startTest();
        
        ExamManagementController.computeDeferralLocationFeesOrProductRefunds(opportunity.Id, examRegistrationPart2.Id, ExamManagementController.DeferralAction.DEFER);
        ExamManagementController.createDeferralProductRefunds(examRegistrationPart2.Id, ExamManagementController.DeferralAction.DEFER);
        
        examRegistrationPart2.Defered__c = 'Pending';
        examRegistrationPart2.Deferral_Status__c = 'Deferred Out';
        
        UPDATE examRegistrationPart2;
        
        ExamManagementController.computeDeferralLocationFeesOrProductRefunds(opportunity.Id, examRegistrationPart1.Id, ExamManagementController.DeferralAction.DEFER);
        ExamManagementController.createDeferralProductRefunds(examRegistrationPart1.Id, ExamManagementController.DeferralAction.DEFER);
        
        
        examRegistrationPart1.Defered__c = 'Pending';
        examRegistrationPart1.Deferral_Status__c = 'Deferred Out';
        
        UPDATE examRegistrationPart1;  
        
        ExamManagementController.computeDeferralLocationFeesOrProductRefunds(opportunity.Id, examRegistrationPart1.Id, ExamManagementController.DeferralAction.UNDEFER);
        ExamManagementController.createDeferralProductRefunds(examRegistrationPart1.Id, ExamManagementController.DeferralAction.UNDEFER);
        
        examRegistrationPart1.Defered__c = null;
        examRegistrationPart1.Deferral_Status__c = null;
        
        UPDATE examRegistrationPart1;  
        
        ExamManagementController.computeDeferralLocationFeesOrProductRefunds(opportunity.Id, examRegistrationPart2.Id, ExamManagementController.DeferralAction.UNDEFER);
        ExamManagementController.createDeferralProductRefunds(examRegistrationPart2.Id, ExamManagementController.DeferralAction.UNDEFER);
        Test.stopTest();
        
        
    } 
    
    @isTest
    public static void requestRetabulation(){
        
        setup();
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        INSERT opportunity;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Result__c = 'Fail';
        examRegistration.Exam_Site__c = examSiteNonChinaExamPart1.Id;
        INSERT examRegistration;
        
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.Exam_Registration__c = examRegistration.Id;
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.Product2Id = FRMRET1.Id;
        opportunityLineItem.UnitPrice = 100.00;
        opportunityLineItem.Quantity = 1;
        opportunityLineItem.PricebookEntryId = FRMRET1PBE.Id;
        INSERT opportunityLineItem;
        
        Test.startTest();
        
        
        Set<Id> retabulationRequestExamRegistrationIds = new Set<Id>();
        retabulationRequestExamRegistrationIds.add(examRegistration.Id);
        
        Map<Id, OpportunityLineItem> retabulationRequestFeesMapByOpportunityId = new Map<Id, OpportunityLineItem>();
        retabulationRequestFeesMapByOpportunityId.put(opportunity.Id, opportunityLineItem);
        
        ExamManagementController.setExamRegistionReScoreStatusForReview(retabulationRequestExamRegistrationIds, retabulationRequestFeesMapByOpportunityId);
        
        Test.stopTest();        
        
    }
    
    @isTest
    public static void setScholarshipApplicationStatusAsUsed(){
        
        setup();
        Scholarship_Application__c scholarshipApplication = new Scholarship_Application__c();
        scholarshipApplication.Exam_Group__c = examGroup.Id;
        scholarshipApplication.Applicant__c = contact.Id;
        scholarshipApplication.Status__c = 'Approved';
        INSERT scholarshipApplication;
        Set<Id> scholarshipApplicationIds = new Set<Id>{scholarshipApplication.Id};
            
            Test.startTest();
        
        ExamManagementController.setScholarshipApplicationStatusAsUsed(scholarshipApplicationIds);
        
        Test.stopTest(); 
        
        System.assertEquals('Used', [SELECT Status__c FROM Scholarship_Application__c WHERE Id = :scholarshipApplication.Id LIMIT 1].Status__c);
    }
    
    @isTest
    public static void getAllProgramInfo(){
        setup();
        Test.startTest();
        
        ExamManagementRemoter.getAllProgramInfo('');
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void getProgramData(){
        setup();
        // Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
        /*User user = new User(Alias = 'nUser', Email='newuser@testorg.com', 
contactId = contact.id,EmailEncodingKey='UTF-8', 
LastName='Testing', LanguageLocaleKey='en_US',
LocaleSidKey='en_US', ProfileId = p.Id, 
TimeZoneSidKey='America/Los_Angeles', 
UserName='nuser123@testorg.com');*/
        
        
        Contact con = new Contact();
        con.Email = 'TEST@TESabcT.com';
        con.FirstName = 'TEST';
        con.LastName = 'TEST';
        con.AccountId = account.Id;
        con.First_Name_as_it_Appears_on_ID__c = 'Test';
        con.Middle_Name_as_it_Appears_on_ID__c = 'T';
        con.Last_Name_as_it_Appears_on_ID__c = 'Test';
        con.OSTA_Full_ID__c = Null;
        con.OSTA_ID_Location__c = 'China';
        con.ID_Type__c = 'Passport';
        con.OSTA_Full_ID__c = '';
        INSERT con;
        
        system.debug('user.id=============>'+user.id);
        system.debug('user.contactId=============>'+user.contactId);
        Contract Program = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program'),
            Name = 'Test Contract'
        );
        INSERT Program ;
        
        Program.Status = 'Activated';
        update Program;
        
         Contract OSTAProgram = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'OSTA Program'),
            Status = 'Draft',
            Name = 'OSTA Program',
            StartDate = Date.today(),
            ContractTerm = 9999
        );
        
        INSERT OSTAProgram;
        OSTAProgram.Status = 'Activated';
        UPDATE OSTAProgram; 
        
        Candidate_Requirement__c canReq = new Candidate_Requirement__c();
        canReq.Candidate_Commitment__c = Program.id;
        canReq.name = 'FRM1 test';
        canReq.Exam__c = frmPart1.Id;
        canReq.Status__c = 'Completed';
        insert canReq;
        
        Exam_Administration__c examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = examGroup.id;
        examAdmin1.Exam_Date__c = system.today();
        examAdmin1.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin1.Exam_Type__c = 'FRM' ;
        examAdmin1.Exam_Admin_Modifications_Start_Date__c = system.today(); 
        examAdmin1.Exam_Admin_Modifications_End_Date__c = system.today().adddays(30);   
        examAdmin1.Exam_Scheduling_Start_Date__c = system.today();  
        examAdmin1.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        examAdmin1.Registration_Start_Date__c = system.today().adddays(-30);
        examAdmin1.Registration_End_Date__c = system.today().adddays(30);
        examAdmin1.Contingency_Administration__c = False;
        insert examAdmin1;
        
        Exam_Administration__c examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = examGroup.id;
        examAdmin2.Exam_Date__c = system.today();
        examAdmin2.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin2.Exam_Type__c = 'FRM' ;
        examAdmin2.Exam_Admin_Modifications_Start_Date__c = system.today(); 
        examAdmin2.Exam_Admin_Modifications_End_Date__c = system.today().adddays(30);   
        examAdmin2.Exam_Scheduling_Start_Date__c = system.today();  
        examAdmin2.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        examAdmin2.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        examAdmin2.Registration_Start_Date__c = system.today().adddays(-30);
        examAdmin2.Registration_End_Date__c = system.today().adddays(30);
        examAdmin2.Contingency_Administration__c = False;
        insert examAdmin2;
        
        Exam_Part__c expart1 = new Exam_Part__c();
        expart1.Exam__c = frmPart2.Id;
        expart1.Exam_Administration__c = examAdmin1.Id ;
        expart1.Delivery_Method__c = 'CBT';
        expart1.Exam_Date__c = Date.today();
        expart1.Exam_Start_Date__c = Date.today();
        expart1.Exam_End_Date__c = Date.today().addDays(10);
        
        insert expart1;
        
        Exam_Provider__c ep = new Exam_Provider__c(Name = 'GARP');
        insert ep;
        
        Exam_Sites__c exsite = new Exam_Sites__c();
        exsite.Name = 'FRM Part 1';
        exsite.Site__c = testSiteNonChina.Id;
        exsite.Exam__c = frmPart1.Id;
        exsite.Exam_Part__c = expart1.id;
        exsite.Exam_Provider__c = ep.id;
        INSERT exsite;
        
        Exam_Sites__c exsite2 = new Exam_Sites__c();
        exsite2.Name = 'FRM Part 2';
        exsite2.Site__c = testSiteChina.Id;
        exsite2.Exam__c = frmPart2.Id;
        exsite2.Exam_Part__c = expart1.id;
        exsite2.Exam_Provider__c = ep.id;
        INSERT exsite2;
        
        Venue__c vn1 = new Venue__c(Name='test', Institution_Name__c='test', Building_Name__c='test', Address1__c='test', Address2__c='test',City__c='test', State__c='test',Zipcode__c='12345',Country__c='test', Site__c = testSiteChina.Id, Active__c = True);
        insert vn1;
        Venue__c vn2 = new Venue__c(Name='test', Institution_Name__c='test', Building_Name__c='test', Address1__c='test', Address2__c='test',City__c='test', State__c='test',Zipcode__c='12345',Country__c='test', Site__c = testSiteNonChina.Id, Active__c = True);
        insert vn2;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Exam_Administration__c = examAdmin1.Id;
        examRegistration.Exam_Part__c = expart1.Id;
        examRegistration.Exam_Site__c = exsite.Id;
        
        INSERT examRegistration;
        
        Exam_Attempt__c examRegistration2 = new Exam_Attempt__c();
        examRegistration2.Member__c = contact.Id;
        examRegistration2.Opportunity__c = opportunity.Id;
        examRegistration2.Exam_Site__c = exsite2.Id;
        INSERT examRegistration2;
        Test.startTest();
        
        ExamManagementController.getProgramInfo('frm');
            
        ExamManagementController.getProgramData('frm','');
        ExamManagementController.getProgramData('frm','kiujgh&^%Rrf7u');
        
        ExamManagementController.getProgramData('erp','');
        ExamManagementController.getProgramData('SCR','');
        
        ExamManagementController.validateIDFormat('A897c78fd', con.OSTA_ID_Location__c, con.ID_Type__c);
        ExamManagementController.validateIDFormat('A897c7', 'china2', con.ID_Type__c);
        ExamManagementController.validateIDFormat('A897c7', 'china2', 'passport2');
        
        ExamManagementController.clearCBTIntegrationAuthorization(examRegistration2.Id);
        ExamManagementRemoter.clearCBTIntegrationAuthorization(examRegistration2.Id);
            
        ExamManagementController emc = new ExamManagementController();
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void getProgramInfo(){
        setup();
        
        ExamManagementRemoter.getProgramInfo('frm');
        ExamManagementRemoter.getProgramInfo('erp');
        ExamManagementRemoter.getProgramInfo('erp');
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Exam_Site__c = examSiteChinaExamPart1.Id;
        //examRegistration.RPT_Exam_Provider__c = 'PSI';
        INSERT examRegistration;
        
        Exam_Provider__c ep = new Exam_Provider__c();
        ep.Name = 'PSI';
        insert ep;
        
        Exam_Sites__c examSite1 = new Exam_Sites__c();
        examSite1.Name = 'May 2018 FRM Exam Part I, China, Guangzhou';
        examSite1.Site__c = testSiteChina.Id;
        examSite1.Exam__c = frmPart1.Id;
        examSite1.Exam_Provider__c = ep.id;
        examSite1.Exam_Part__c = exampart.Id;
        INSERT examSite1;
        
        Exam_Attempt__c examRegistration1 = new Exam_Attempt__c();
        examRegistration1.Member__c = contact.Id;
        examRegistration1.Opportunity__c = opportunity.Id;
        examRegistration1.Exam_Site__c = examSite1.Id;
        INSERT examRegistration1;
        
        Test.startTest();
        
        ExamManagementController.createCBTIntegrationAuthorization(examRegistration1.Id);
        ep.Name = 'ATA';
        update ep;
        ExamManagementRemoter.createCBTIntegrationAuthorization(examRegistration1.Id);
        ExamManagementRemoter.logFailedAuthorization(examRegistration.Id);
        
        Test.stopTest(); 
    }
    
    
    @isTest
    public static void processExamRegMods() {
        setup();
        
        Account acc = new Account(name = 'test');
        insert acc;
        
        Contract ostaProgram = new Contract(
            AccountId = acc.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'OSTA Program'),
            Status = 'Draft',
            Name = 'OSTA Program',
            OSTA_Last_Upload_Date__c = Null,
            StartDate = Date.today(),
            ContractTerm = 9999
        );
        
        INSERT ostaProgram;
        ostaProgram.Status = 'Activated';
        UPDATE ostaProgram;
        
        Contract frmProgram = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program'),
            Status = 'Draft',
            Name = 'FRM Program'
        );
        INSERT frmProgram ;
       
        Exam_Administration__c examAdmin0 = new Exam_Administration__c();
        examAdmin0.Exam_Group__c = nextExamGroup.id;
        examAdmin0.Exam_Date__c = system.today().addDays(-5);
        examAdmin0.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin0;
        
        Exam_Administration__c examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = examGroup.id;
        examAdmin1.Exam_Date__c = system.today().addDays(-5);
        examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin1;
        
        Exam_Administration__c examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = nextExamGroup.id;
        examAdmin2.Exam_Date__c = system.today().addDays(10);
        examAdmin2.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin2.Exam_Type__c = 'FRM' ;
        examAdmin2.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin2;
        
        List<Exam_Attempt__c> attemptList = new List<Exam_Attempt__c>();
        Exam_Attempt__c examRegistration0 = new Exam_Attempt__c();
        examRegistration0.Member__c = contact.Id;
        examRegistration0.Exam_Part__c = exampart.Id;
        examRegistration0.Exam_Administration__c = examAdmin0.Id;
        examRegistration0.Candidate_Commitment__c = frmProgram.id;
        examRegistration0.Exam_Site__c = examSiteChinaExamPart1.Id;
        attemptList.add(examRegistration0);
        
        Exam_Attempt__c examRegistration00 = new Exam_Attempt__c();
        examRegistration00.Member__c = contact.Id;
        examRegistration00.Exam_Part__c = exampart.Id;
        examRegistration00.Candidate_Commitment__c = frmProgram.id;
        examRegistration00.Exam_Administration__c = examAdmin0.Id;
        examRegistration00.Exam_Site__c = examSiteChinaExamPart1.Id;
        attemptList.add(examRegistration00);
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Exam_Part__c = exampart.Id;
        examRegistration.Exam_Administration__c = examAdmin1.Id;
        examRegistration.Candidate_Commitment__c = ostaProgram.id;
        examRegistration.Exam_Site__c = examSiteChinaExamPart1.Id;
        attemptList.add(examRegistration);
        
        Exam_Attempt__c examRegistration2 = new Exam_Attempt__c();
        examRegistration2.Member__c = contact.Id;
        examRegistration2.Exam_Part__c = exampart2.Id;
        examRegistration2.Exam_Administration__c = examAdmin1.Id;
        examRegistration2.Exam_Site__c = examSiteNonChinaExamPart2.Id;
        examRegistration2.Candidate_Commitment__c = ostaProgram.id;
        attemptList.add(examRegistration2);
        INSERT attemptList;
        
        Exam_Registration_Modification__c examRegMod0 = new Exam_Registration_Modification__c();
        examRegMod0.Part_I_Exam_Admin_From__c = examadmin1.id;
        examRegMod0.Part_II_Exam_Admin_From__c  = examAdmin0.id;
        examRegMod0.Part_I_Exam_Registration__c = examRegistration00.id;
        examRegMod0.Part_II_Exam_Registration__c = examRegistration0.id;
        examRegMod0.Part_I_Exam_Admin_To__c  = examAdmin0.id;
        examRegMod0.Part_II_Exam_Admin_To__c  = examadmin1.id ;
        examRegMod0.Part_I_Exam_Site_From__c=NULL; 
        examRegMod0.Part_I_Exam_Site_To__c=examSiteChinaExamPart1.id;
        examRegMod0.Part_II_Exam_Site_From__c=examSiteChinaExamPart2.id;
        examRegMod0.Part_II_Exam_Site_To__c=examSiteChinaExamPart1.id;
        examRegMod0.Status__c = 'Pending';
        insert examRegMod0 ;
        
        Exam_Registration_Modification__c examRegMod = new Exam_Registration_Modification__c();
        
        examRegMod.Part_I_Exam_Admin_From__c = examAdmin1.id ;
        examRegMod.Part_II_Exam_Admin_From__c  = examAdmin1.id ;
        examRegMod.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod.Part_I_Exam_Admin_To__c  = examAdmin2.id;
        examRegMod.Part_II_Exam_Admin_To__c  = examAdmin2.id ;
        examRegMod.Created_from_MS_Tool__c = false;
        
        examRegMod.Status__c = 'Pending';
        insert examRegMod ;
     
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'New Lead';
        opportunity.CloseDate = Date.today();
        opportunity.Exam_Registration_Modification__c = examRegMod0.id;
        INSERT opportunity;
        
        
        Opportunity opportunity1 = new Opportunity();
        opportunity1.AccountId = acc.Id;
        opportunity1.Amount = 700.00;
        opportunity1.Name = 'TEST';
        opportunity1.StageName = 'New Lead';
        opportunity1.CloseDate = Date.today();
        opportunity1.Exam_Registration_Modification__c = examRegMod.id;
        INSERT opportunity1;
        
        Test.startTest();
        
        ExamManagementController.processExamRegMods(new set<id>{examRegMod.id});
        ExamManagementController.processExamRegMods(new set<id>{examRegMod0.id});
        //ExamManagementController.processExamRegModsBulk(new set<id>{examRegMod0.id},true,true);
        
        Test.stopTest(); 
    }
    
    
    
    
    @isTest
    public static void processExamRegModsFromClient(){
        setup();
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Exam_Site__c = examSiteNonChinaExamPart1.Id;
        INSERT examRegistration;
        Test.startTest();
        
        ExamManagementRemoter.processExamRegModsFromClient(examRegistration.Id);
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void findRefundOpp(){
        setup();
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Exam_Site__c = examSiteNonChinaExamPart1.Id;
        INSERT examRegistration;
        
        Exam_Attempt__c examRegistration1 = new Exam_Attempt__c();
        examRegistration1.Member__c = contact.Id;
        examRegistration1.Opportunity__c = opportunity.Id;
        examRegistration1.Exam_Site__c = examSiteNonChinaExamPart1.Id;
        examRegistration1.Cloned_From__c = examRegistration.Id;
        INSERT examRegistration1;
        Test.startTest();
        
        ExamManagementController.findRefundOpp(examRegistration1);
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void issueProductRefund(){
        setup();
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opportunity.id);
        insert order; 
        ChargentOrders__Transaction__c Chargent = new ChargentOrders__Transaction__c(Opportunity__c=opportunity.Id,
                                                                          ChargentOrders__Order__c = order.id,
                                                                          ChargentOrders__Type__c='Charge',
                                                                          ChargentOrders__Response_Status__c='Approved');
        insert Chargent;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Exam_Site__c = examSiteNonChinaExamPart1.Id;
        INSERT examRegistration;
        
        
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.Exam_Registration__c = examRegistration.Id;
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.Product2Id = CHLF.Id;
        opportunityLineItem.UnitPrice = 100.00;
        opportunityLineItem.Quantity = 1;
        opportunityLineItem.PricebookEntryId = CHLFPBE.Id;
        INSERT opportunityLineItem;
        Test.startTest();
        ExamManagementController.issueProductRefund(opportunity.Id , 'CHLF', 1);
        
        Test.stopTest(); 
    }
    
    @isTest
    public static void createOppLineItem(){
        setup();
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Exam_Site__c = examSiteNonChinaExamPart1.Id;
        INSERT examRegistration;
        
        
        
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.Exam_Registration__c = examRegistration.Id;
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.Product2Id = CHLF.Id;
        opportunityLineItem.UnitPrice = 100.00;
        opportunityLineItem.Quantity = 1;
        opportunityLineItem.PricebookEntryId = CHLFPBE.Id;
        INSERT opportunityLineItem;
        
        //List<prodLine> lstProds = new List<prodLine>();
        ExamManagementController.prodLine pc = new ExamManagementController.prodLine();
        pc.prodCode = 'CHLF';
        pc.glCode = '2008';
        pc.description = 'OSTA Location Fee';
        pc.amount = 200;
        pc.examRegId = examRegistration.Id;
        
        
        MAP<String, Product2> mapProduct = new MAP<String, Product2>();
        mapProduct.put('CHLF:2008',CHLF);
        
        MAP<String, PricebookEntry> mapPrice = new MAP<String, PricebookEntry>();
        String mapPriceId = CHLFPBE.Id;
        String oppId = opportunity.Id;
        String strmMapPrice = CHLF.ID;
        mapPrice.put(mapPriceId,CHLFPBE);
        mapPrice.put(strmMapPrice,CHLFPBE);
        Test.startTest(); 
        ExamManagementController.createOppLineItem(oppId , pc, mapProduct,mapPrice,null);
        Test.stopTest(); 
    }
    
    @isTest
    public static void cancelOstaProgram(){
        setup();
        Contract program = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'OSTA Program'),
            Name = 'Activated'
        );
        INSERT program ;
        program.Status = 'Activated';
        update program;
        Test.startTest();
        ExamManagementController.cancelOstaProgram(account.Id);
        Test.stopTest(); 
    }
    
    @isTest
    public static void issueRefundNew(){
        setup();
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Exam_Site__c = examSiteNonChinaExamPart1.Id;
        INSERT examRegistration;
        
        
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.Exam_Registration__c = examRegistration.Id;
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.Product2Id = CHLF.Id;
        opportunityLineItem.UnitPrice = 100.00;
        opportunityLineItem.Quantity = 1;
        opportunityLineItem.PricebookEntryId = CHLFPBE.Id;
        INSERT opportunityLineItem;
        
        MAP<Id,Opportunity> mapOpp = new MAP<Id,Opportunity>([select Id, AccountId,Name,
                                                              (SELECT Id, ProductCode, Product2Id, Product2.ProductCode, Description, PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice FROM OpportunityLineItems),
                                                              (SELECT Id, Opportunity__c, ChargentOrders__Response_Status__c, ChargentOrders__Amount__c FROM Transactions__r 
                                                               WHERE ChargentOrders__Response_Status__c = 'Approved' ORDER BY ChargentOrders__Amount__c ASC),
                                                              (select Id, Name, Opportunity__c from Product_Refunds__r where Product_Code__c = 'CHLF' AND Status__c != 'Denied')
                                                              from Opportunity where ID =: opportunity.Id]);
        Test.startTest();
        ExamManagementController.issueProductRefund(mapOpp.get(opportunity.id), 'CHLF', 1);
        Test.stopTest(); 
    }
    
    /*@isTest
public static void computeOSTAProgramMoves(){
setup();
Opportunity opportunity = new Opportunity();
opportunity.Amount = 700.00;
opportunity.Name = 'TEST';
opportunity.StageName = 'Closed';
opportunity.CloseDate = Date.today();
Insert opportunity;
//setOpportunities.add(opportunity.id);

Exam_Attempt__c examRegistration1 = new Exam_Attempt__c();
examRegistration1.Member__c = contact.Id;
examRegistration1.Opportunity__c = opportunity.Id;
examRegistration1.Exam_Site__c = examSiteNonChinaExamPart1.Id;
INSERT examRegistration1;

Exam_Attempt__c examRegistration2 = new Exam_Attempt__c();
examRegistration2.Member__c = contact.Id;
examRegistration2.Opportunity__c = opportunity.Id;
examRegistration2.Exam_Site__c = examSiteNonChinaExamPart2.Id;
INSERT examRegistration2;

Exam_Administration__c examAdmin1 = new Exam_Administration__c();
examAdmin1.Exam_Group__c = examGroup.id;
examAdmin1.Exam_Date__c = system.today();
examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
insert examAdmin1;

system.debug('examSiteChinaExamPart1=======>'+examSiteChinaExamPart1);
system.debug('testSiteChina==========>'+testSiteChina);
ExamManagementController.computeOSTAProgramMoves(examRegistration1, examRegistration2, examSiteChinaExamPart1,
examSiteChinaExamPart2, examAdmin1, examAdmin1,examSiteChinaExamPart1, 
examSiteChinaExamPart2, examAdmin1, examAdmin1);
}*/
    
    @isTest
    public static void getExamPartNumber(){
        setup();
        Test.startTest();
        ExamManagementController.getExamPartNumber('ERP Exam Part I');
        ExamManagementController.getExamPartNumber('ERP Exam Part II');
        ExamManagementController.getExamPartNumber('abc');
        Test.stopTest(); 
    }
    
    @isTest
    public static void getExamRescheduleData(){
        setup();
        
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        //Profile p= [Select Id from profile where Name='Customer Community'];
        /*User user = new User(Alias = 'nUser', Email='newuser@testorg.com', 
contactId = contact.id,EmailEncodingKey='UTF-8', 
LastName='Testing', LanguageLocaleKey='en_US',
LocaleSidKey='en_US', ProfileId = p.Id, 
TimeZoneSidKey='America/Los_Angeles', 
UserName='nuser123@testorg.com');*/
        
        //Profile p= [SELECT Id,Name FROM Profile WHERE Name = 'Customer Community' limit 1];
        /*Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

User user = new User(LastName = 'testLIVESTON',
FirstName='testJASON',
ContactId = contact.id,
Alias = 'test',
Email = 'test.liveston@asdf.com',
Username = 'testliveston@asdf.com',
ProfileId = profileId.id,
TimeZoneSidKey = 'GMT',
LanguageLocaleKey = 'en_US',
EmailEncodingKey = 'UTF-8',
LocaleSidKey = 'en_US'
);
insert user;*/
        system.debug('user.id=============>'+user.id);
        system.debug('user.contactId=============>'+user.contactId);
        Contract Program = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program'),
            Name = 'Test Contract'
        );
        INSERT Program ;
        
        Program.Status = 'Activated';
        update Program;
        
        Exam_Administration__c examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = examGroup.id;
        examAdmin1.Exam_Date__c = system.today();
        examAdmin1.Exam_Type__c = 'FRM' ;
        examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        examAdmin1.Exam_Admin_Modifications_Start_Date__c = system.today()+4;   
        examAdmin1.Exam_Admin_Modifications_End_Date__c = system.today().adddays(30);   
        examAdmin1.Exam_Scheduling_Start_Date__c = system.today()+4;    
        examAdmin1.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        insert examAdmin1;
        
        Exam_Administration__c examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = examGroup.id;
        examAdmin2.Exam_Date__c = system.today();
        examAdmin2.Exam_Type__c = 'erp' ;
        examAdmin2.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin2;
        
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        
        
        Exam_Part__c expart1 = new Exam_Part__c();
        expart1.Exam__c = frmPart2.Id;
        expart1.Exam_Administration__c = examAdmin1.Id ;
        expart1.Exam__c=frmPart1.id;
        expart1.Delivery_Method__c = 'CBT';
        expart1.Exam_Start_Date__c = Date.today();
        expart1.Exam_Date__c = Date.today();
        expart1.Exam_End_Date__c = Date.today().addDays(10);
        
        insert expart1;
        
        
        Exam_Part__c expart2 = new Exam_Part__c();
        expart2.Exam__c = frmPart2.Id;
        expart2.Exam_Administration__c = examAdmin2.Id ;
        expart2.Exam__c=frmPart1.id;
        expart2.Delivery_Method__c = 'CBT';
        expart2.Exam_Start_Date__c = Date.today();
        expart2.Exam_Date__c = Date.today();
        expart2.Exam_End_Date__c = Date.today().addDays(10);
        
        insert expart2;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Defered__c = 'Pending';
        examRegistration.Exam_Site__c = examSiteChinaExamPart1.Id;
        examRegistration.Exam_Administration__c = examAdmin1.Id ; 
        examRegistration.Exam_Part__c = expart1.Id;
        INSERT examRegistration;
        
        Exam_Attempt__c examRegistration1 = new Exam_Attempt__c();
        examRegistration1.Member__c = contact.Id;
        examRegistration1.Opportunity__c = opportunity.Id;
        examRegistration1.Exam_Site__c = examSiteChinaExamPart2.Id;
        examRegistration1.Exam_Administration__c = examAdmin2.Id ;
        examRegistration1.Exam_Part__c = expart2.Id; 
        INSERT examRegistration1;
        
        
        Test.startTest();  
        List<User> lstUsers = [SELECT Id,ContactId FROM 
                               User WHERE username =: 'testCommunityUsermig123@test.com' LIMIT 1];
        String userId = lstUsers[0].Id;
                
        ExamManagementController.createExamRescheduleFeesOrderInternal(examRegistration.Id, examAdmin1.Id, examAdmin2.Id, examSiteChinaExamPart1.Id, examSiteChinaExamPart2.Id,userId,false,false,null,false);
        ExamManagementController.createExamRescheduleFeesOrderInternal(examRegistration1.Id, examAdmin2.Id, examAdmin2.Id, examSiteChinaExamPart2.Id, examSiteChinaExamPart2.Id,userId,false,false,null,false);
        
        ExamManagementController.createExamRescheduleFeesOrderInternal(examRegistration1.Id, examAdmin2.Id, examAdmin1.Id, examSiteChinaExamPart2.Id, examSiteChinaExamPart1.Id,userId,false,false,null,false);
        
        
        Test.stopTest(); 
        
    }
    
    @isTest
    public static void getExamRescheduleInformation(){
        setup();
        
        // Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
        /*User user = new User(Alias = 'nUser', Email='newuser@testorg.com', 
contactId = contact.id,EmailEncodingKey='UTF-8', 
LastName='Testing', LanguageLocaleKey='en_US',
LocaleSidKey='en_US', ProfileId = p.Id, 
TimeZoneSidKey='America/Los_Angeles', 
UserName='nuser123@testorg.com');*/
        system.debug('user.id=============>'+user.id);
        system.debug('user.contactId=============>'+user.contactId);
        Contract Program = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program'),
            Name = 'Test Contract'
        );
        INSERT Program ;
        
        Program.Status = 'Activated';
        update Program;
        
        Exam_Administration__c examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = examGroup.id;
        examAdmin1.Exam_Date__c = system.today();
        examAdmin1.Exam_Type__c = 'FRM' ;
        examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        examAdmin1.Exam_Admin_Modifications_Start_Date__c = system.today()+4;   
        examAdmin1.Exam_Admin_Modifications_End_Date__c = system.today().adddays(30);   
        examAdmin1.Exam_Scheduling_Start_Date__c = system.today()+4;    
        examAdmin1.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        insert examAdmin1;
        
        Exam_Administration__c examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = nextExamGroup.id;
        examAdmin2.Exam_Date__c = system.today().addDays(10);
        examAdmin2.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin2.Exam_Type__c = 'ERP' ;
        examAdmin2.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin2;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        
        
        Exam_Part__c expart1 = new Exam_Part__c();
        expart1.Exam__c = frmPart2.Id;
        expart1.Exam_Administration__c = examAdmin1.Id ;
        expart1.Exam__c=frmPart1.id;
        expart1.Delivery_Method__c = 'CBT';
        
        expart1.Exam_Start_Date__c = Date.today();
        expart1.Exam_Date__c = Date.today();
        expart1.Exam_End_Date__c = Date.today().addDays(10);
        
        insert expart1;
        
            
        List<Exam_Attempt__c> attemptList = new List<Exam_Attempt__c>();
        
        Exam_Attempt__c examRegistration1 = new Exam_Attempt__c();
        examRegistration1.Member__c = contact.Id;
        examRegistration1.Opportunity__c = opportunity.Id;
        examRegistration1.Exam_Site__c = examSiteChinaExamPart2.Id;
        examRegistration1.Exam_Administration__c = examAdmin2.Id;
        attemptList.add(examRegistration1);
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        examRegistration.Defered__c = 'Pending';
        examRegistration.Cloned_From__c = examRegistration1.id;
        examRegistration.Deferred_Exam_Administration__c = examAdmin1.Id;
        examRegistration.Deferred_From_Exam_Registration__c = examRegistration1.id;
        examRegistration.Exam_Site__c = examSiteChinaExamPart1.Id;
        examRegistration.Exam_Administration__c = examAdmin1.Id;
        attemptList.add(examRegistration);
        
        INSERT attemptList;
        /*Exam_Attempt__c examRegistration1 = new Exam_Attempt__c();
        examRegistration1.Member__c = contact.Id;
        examRegistration1.Opportunity__c = opportunity.Id;
        examRegistration1.Exam_Site__c = examSiteChinaExamPart2.Id;
        examRegistration1.Exam_Administration__c = examAdmin2.Id;
        attemptList.add(examRegistration1);
        INSERT attemptList;*/
        
        Exam_Registration_Modification__c examRegMod = new Exam_Registration_Modification__c();
        examRegMod.Part_I_Exam_Admin_From__c = examAdmin1.id ;
        examRegMod.Part_II_Exam_Admin_From__c  = examAdmin1.id ;
        examRegMod.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod.Part_II_Exam_Registration__c = examRegistration1.id;
        examRegMod.Part_I_Exam_Admin_To__c  = examAdmin1.id;
        examRegMod.Part_II_Exam_Admin_To__c  = examAdmin2.id ;
        examRegMod.Status__c = 'Pending';
        insert examRegMod ;
        
        Set<Id> setId = new Set<Id>();
        setId.add(examRegMod.Id);
        
        List<User> lstUsers = [SELECT Id,ContactId FROM 
                               User WHERE username =: 'testCommunityUsermig123@test.com' LIMIT 1];
        system.runAs(lstUsers[0]){
            
            Test.startTest();
            ExamManagementController.processExamRegModsBulk(setId);
            ExamManagementRemoter.getExamRescheduleInformation(examRegistration.id);
            //ExamManagementRemoter.getExamRescheduleInformation(examRegistration1.id);
            //ExamManagementRemoter.getExamRescheduleInformation(examRegistration1.id);
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testTransaction() {
        setup();
        Account acc = [Select Id from Account Limit 1];
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        Test.startTest();
        
        ExamManagementController.createTransaction(opp.Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void createExamRescheduleFeesOrder() {
        setup();
        
        
        List<Product2> Product2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'FRM1X',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4011');
        Product2List.add(p1);
        Product2 p2 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',productCode = 'CHLF',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Weight__c=6,GL_Code__c='4011');
        Product2List.add(p2);
        insert Product2List;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice1);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[1].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice2);
        insert PricebookEntryList ;
        
        //Account acc = [Select Id from Account Limit 1];
        List<Opportunity> OppResults= new List<Opportunity>();
        Opportunity opp1 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        Opportunity opp2 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        OppResults.add(opp1);
        OppResults.add(opp2);
        insert OppResults;
        
        Contract frmProgram = new Contract(AccountId = account.Id,CustomerSignedId = contact.Id,
                                           RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRM_Program'),
                                           Status = 'Draft',Name = 'FRM Program', Opportunity__c=OppResults[0].Id,StartDate = Date.today(), ContractTerm = 9999);
        INSERT frmProgram;        
        //frmProgram.Status = 'Activated ( Auto-Renew )';
        //  UPDATE frmProgram;
        
        Scholarship_Application__c sa = new Scholarship_Application__c(Applicant__c = frmProgram.CustomerSignedId,
                                                                       Exam_Type__c='FRM',Status__c='Submitted', Exam_Group__c= examGroup.Id);
        insert sa;
        
        Exam_Administration__c examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = examGroup.id;
        examAdmin1.Exam_Date__c = system.today();
        examAdmin1.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin1.Exam_Type__c = 'FRM' ;
        examAdmin1.Exam_Admin_Modifications_Start_Date__c = system.today(); 
        examAdmin1.Exam_Admin_Modifications_End_Date__c = system.today().adddays(30);   
        examAdmin1.Exam_Scheduling_Start_Date__c = system.today();  
        examAdmin1.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin1;
        
        Exam_Part__c exampart = new Exam_Part__c();
        
        exampart.Exam__c = frmPart1.Id;
        exampart.Exam_Administration__c = examAdmin1.Id ;
        exampart.Delivery_Method__c = 'CBT';
        exampart.Exam_Start_Date__c = Date.today();
        exampart.Exam_Date__c = Date.today();
        exampart.Exam_End_Date__c = Date.today().addDays(10);
        
        insert exampart;
        
        List<Exam_Attempt__c> examRegistrations = new List<Exam_Attempt__c>();
        Exam_Attempt__c examRegistration1 = new Exam_Attempt__c();
        examRegistration1.Member__c = contact.Id;
        examRegistration1.Candidate_Commitment__c = frmProgram.id;
        examRegistration1.Opportunity__c = OppResults[0].Id;
        examRegistration1.Exam_Site__c = examSiteChinaExamPart1.Id;
        examRegistration1.Exam_Part__c = exampart.Id;
        examRegistration1.Exam_Administration__c = examAdmin1.Id;
        insert examRegistration1; 
        Exam_Registration_Modification__c ERM1= NEW Exam_Registration_Modification__c();
        ERM1.Part_I_Exam_Registration__c=examRegistration1.ID;
        ERM1.Part_I_Exam_Admin_From__c=examAdmin1.Id;
        ERM1.Part_I_Exam_Admin_To__c=examAdmin1.Id;
        ERM1.Created_from_MS_Tool__c = false;
        ERM1.Status__c = 'Pending';
        INSERT ERM1;
        
        Exam_Attempt__c examReg = new Exam_Attempt__c();
        examReg.Member__c = contact.Id;
        examReg.Opportunity__c = OppResults[1].Id;
        examReg.Defered__c = 'Approved';
        examReg.Cancelled__c = True ;
        examReg.Exam_Site__c = examSiteChinaExamPart1.Id;
        insert examReg; 
        
        Exam_Attempt__c examReg1 = new Exam_Attempt__c();
        examReg1.Member__c = contact.Id;
        examReg1.Opportunity__c = OppResults[1].Id;
        examReg1.Exam_Site__c = examSiteChinaExamPart2.Id;
        examReg1.Other_Exam_Registrations__c=examReg.id;
        insert examReg1; 
        
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Opportunity__c = OppResults[1].Id;
        examRegistration.Exam_Site__c = examSiteChinaExamPart2.Id;
        examRegistration.Defered__c = 'Approved';
        examRegistration.Cancelled__c = FALSE ;
        examRegistration.Cloned_From__c = examReg1.Id;
        examRegistrations.add(examRegistration);
        insert examRegistrations;
        
        
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[0].Id,UnitPrice = 7000,Description='test',
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = examRegistration1.Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = OppResults[1].Id,PricebookEntryId = PricebookEntryList[1].Id,UnitPrice = 7000,Description='test',
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = examRegistrations[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem2);
        insert OpportunityLineItemList;       
        ChargentBase__Gateway__c gateway = new ChargentBase__Gateway__c(Name = 'paypal garp');
        insert gateway;
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = OppResults[0].id);
        insert order;
        ChargentOrders__Transaction__c payment = new ChargentOrders__Transaction__c(Opportunity__c = OppResults[0].id,ChargentOrders__Type__c = 'Charge',
                                                                                    ChargentOrders__Order__c = order.id,ChargentOrders__Gateway__c = gateway.id,
                                                                                    ChargentOrders__Response_Status__c= 'Approved');
        insert payment;
        ChargentOrders__ChargentOrder__c order1 = new ChargentOrders__ChargentOrder__c(Opportunity__c = OppResults[1].id);
        insert order1; 
        ChargentOrders__Transaction__c payment1 = new ChargentOrders__Transaction__c(Opportunity__c = OppResults[1].id,ChargentOrders__Type__c = 'Charge',
                                                                                     ChargentOrders__Order__c = order1.id,ChargentOrders__Gateway__c = gateway.id,
                                                                               ChargentOrders__Response_Status__c= 'Approved');
        insert payment1;
        
        
        List<Product_Refunds__c> ProductRefundsList = new List<Product_Refunds__c>();
        Product_Refunds__c refund1 = new Product_Refunds__c (Status__c='Completed',Cancel_E_book__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[0].id,product__c = Product2List[0].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund1);
        Product_Refunds__c refund2 = new Product_Refunds__c (Status__c='Completed',Cancel_ERP_Enrollment__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[1].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment1.id);
        ProductRefundsList.add(refund2);
        insert ProductRefundsList;
        
        setOpportunities.add(OppResults[1].id);
        Map<Id, Exam_Attempt__c> examRegistrationsMap = new Map<Id, Exam_Attempt__c>([SELECT Id,Opportunity__c,(SELECT id,OpportunityId,Exam_Registration__c,Product_company__c,Product2Id,Description,Quantity,UnitPrice,PricebookEntryId,Scholarship_Application__c from Opportunity_Line_Items__r) FROM Exam_Attempt__c LIMIT 50]);
        Set<Id> oppId = new Set<Id>();
        oppId.add(OppResults[0].Id);
        oppId.add(OppResults[1].Id);
        
        Test.startTest();
        
        ExamManagementController.getAllOpportunityIdsByExamRegistrations(examRegistrations);
        ExamManagementController.getProductRefundsByOpportunityIdMap(setOpportunities);
        ExamManagementController.getAllOpportunityIdsByExamRegistration(examRegistration1);
        ExamManagementController.computeNumberOfExamRegistrationsInActiveCycle(examRegistrations);
        ExamManagementController.fetchExamRegistrationInContext(examRegistrations[0].id);
        ExamManagementController.createChinaLocationFeeProductRefunds(examRegistrationsMap,oppId);
        ExamManagementController.createExamRescheduleOpp(contact,null,null);
        
        Test.stopTest();
    }
    
    @isTest
    public static void remainingTests() {
        setup();
        List<Exam_Attempt__c> attemptList = new List<Exam_Attempt__c>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
        User user = new User(Alias = 'nUser', Email='newuser@testorg.com', 
                             contactId = contact.id,EmailEncodingKey='UTF-8', 
                             LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles', 
                             UserName='nuser123@testorg.com');
        system.debug('user.id=============>'+user.id);
        system.debug('user.contactId=============>'+user.contactId);
        Contract Program = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program'),
            Name = 'Test Contract'
        );
        INSERT Program ;
        
        Program.Status = 'Activated';
        update Program;
        
        Exam_Administration__c examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = examGroup.id;
        examAdmin1.Exam_Date__c = system.today();
        examAdmin1.Exam_Type__c = 'FRM' ;
        examAdmin1.Exam_Admin_Modifications_Start_Date__c = system.today().adddays(-30);    
        examAdmin1.Exam_Admin_Modifications_End_Date__c = system.today().adddays(29);   
        examAdmin1.Exam_Scheduling_Start_Date__c = system.today().adddays(-30);    
        examAdmin1.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin1;
                
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        INSERT opportunity;
        
        Exam_Part__c expart1 = new Exam_Part__c();
        expart1.Exam__c = frmPart1.Id;
        expart1.Exam_Administration__c = examAdmin1.Id ;
        expart1.Delivery_Method__c = 'CBT';
        expart1.Exam_Start_Date__c = Date.today();
        expart1.Exam_Date__c = Date.today();
        expart1.Exam_End_Date__c = Date.today().addDays(10);
        
        insert expart1;
        
        Exam_Attempt__c examRegistration11 = new Exam_Attempt__c();
        examRegistration11.Member__c = contact.Id;
        examRegistration11.Opportunity__c = opportunity.Id;
        examRegistration11.Exam_Site__c = examSiteChinaExamPart1.Id;
        examRegistration11.Exam_Administration__c = examAdmin1.Id ;
        attemptList.add(examRegistration11);
        
        Exam_Administration__c examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = nextExamGroup.id;
        examAdmin2.Exam_Date__c = system.today().addDays(10);
        examAdmin2.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin2.Exam_Type__c = 'FRM' ;
        examAdmin2.Exam_Admin_Modifications_Start_Date__c = system.today().adddays(-30);    
        examAdmin2.Exam_Admin_Modifications_End_Date__c = system.today().adddays(29);   
        examAdmin2.Exam_Scheduling_Start_Date__c = system.today().adddays(-30);    
        examAdmin2.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        examAdmin2.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin2;
        
        Exam_Attempt__c examRegistration1 = new Exam_Attempt__c();
        examRegistration1.Member__c = contact.Id;
        examRegistration1.Opportunity__c = opportunity.Id;
        examRegistration1.Exam_Site__c = examSiteChinaExamPart2.Id;
        examRegistration1.Deferred_Exam_Administration__c = examAdmin2.Id ;
        examRegistration1.Exam_Administration__c = examAdmin1.Id ;
        INSERT examRegistration1;
        
        Exam_Administration__c examAdmin3 = new Exam_Administration__c();
        examAdmin3.Exam_Group__c = examGroup.id;
        examAdmin3.Exam_Date__c = system.today();
        examAdmin3.Exam_Type__c = 'ERP' ;
        examAdmin3.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin3;
        
        Exam_Administration__c examAdmin4 = new Exam_Administration__c();
        examAdmin4.Exam_Group__c = nextExamGroup.id;
        examAdmin4.Exam_Date__c = system.today().addDays(10);
        examAdmin4.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin4.Exam_Type__c = 'ERP' ;
        examAdmin4.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin4;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Exam_Part__c = expart1.Id;
        examRegistration.Exam_Administration__c = examAdmin1.Id;
        examRegistration.Exam_Site__c = examSiteChinaExamPart1.Id;
        examRegistration.Opportunity__c = opportunity.Id;
        attemptList.add(examRegistration);
        
        Exam_Attempt__c examRegistration111 = new Exam_Attempt__c();
        examRegistration111.Member__c = contact.Id;
        examRegistration111.Exam_Part__c = expart1.Id;
        examRegistration111.Exam_Administration__c = examAdmin1.Id;
        examRegistration111.Exam_Site__c = examSiteChinaExamPart1.Id;
        examRegistration111.Opportunity__c = opportunity.Id;
        attemptList.add(examRegistration111);
        
        Exam_Attempt__c examRegistration2 = new Exam_Attempt__c();
        examRegistration2.Member__c = contact.Id;
        examRegistration2.Exam_Part__c = exampart2.Id;
        examRegistration2.Exam_Administration__c = examAdmin1.Id;
        examRegistration2.Exam_Site__c = examSiteNonChinaExamPart2.Id;
        examRegistration2.Opportunity__c = opportunity.Id;
        attemptList.add(examRegistration2);
        INSERT attemptList;
        
        Exam_Registration_Modification__c examRegMod = new Exam_Registration_Modification__c();
        examRegMod.Part_I_Exam_Admin_From__c = examAdmin1.id ;
        examRegMod.Part_II_Exam_Admin_From__c  = examAdmin1.id ;
        examRegMod.Part_I_Exam_Registration__c = examRegistration1.id;
        examRegMod.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod.Part_I_Exam_Admin_To__c  = examAdmin2.id;
        examRegMod.Part_II_Exam_Admin_To__c  = examAdmin2.id ;
        examRegMod.Created_from_MS_Tool__c = false;
        examRegMod.Status__c = 'Pending';
        insert examRegMod ;
        
        Exam_Registration_Modification__c examRegMod1 = new Exam_Registration_Modification__c();
        examRegMod1.Part_I_Exam_Admin_From__c = examAdmin1.id ;
        examRegMod1.Part_I_Exam_Registration__c = examRegistration111.id;
        examRegMod1.Part_I_Exam_Admin_To__c  = examAdmin2.id;
        examRegMod1.Part_I_Exam_Site_From__c  = examSiteChinaExamPart1.id ;
        examRegMod1.Part_I_Exam_Site_To__c  = examSiteNonChinaExamPart1.id ;
        examRegMod1.Created_from_MS_Tool__c = false;
        examRegMod1.Status__c = 'Pending';
        insert examRegMod1 ;
        
        Exam_Registration_Modification__c examRegMod2 = new Exam_Registration_Modification__c();
        examRegMod2.Part_I_Exam_Admin_From__c = examAdmin1.id ;
        examRegMod2.Part_II_Exam_Admin_From__c  = examAdmin3.id ;
        examRegMod2.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod2.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod2.Part_I_Exam_Admin_To__c  = examAdmin2.id;
        examRegMod2.Part_II_Exam_Admin_To__c  = examAdmin4.id ;
        examRegMod2.Created_from_MS_Tool__c = false;
        examRegMod2.Status__c = 'Pending';
        insert examRegMod2 ;
        
        Contract OSTAProgram = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'OSTA Program'),
            Status = 'Draft',
            Name = 'FRM Program',
            StartDate = Date.today(),
            ContractTerm = 9999
        );
        
        INSERT OSTAProgram;
        OSTAProgram.Status = 'Activated';
        UPDATE OSTAProgram; 
        
        Set<Id> setId = new Set<Id>();
        setId.add(examRegMod.Id);
        setId.add(examRegMod1.Id); 
        setId.add(examRegMod2.Id); 
        
        List<User> lstUsers = [SELECT Id,ContactId FROM 
                               User WHERE username =: 'testCommunityUsermig123@test.com' LIMIT 1];
        String userId = lstUsers[0].Id;
        
        system.runAs(lstUsers[0]){
        Test.startTest(); 
        ExamManagementController.processExamRegMods(setId);
        ExamManagementController.processExamRegMods(setId);
        ExamManagementController.processExamRegModsBulk(setId);
        
        //Consult with Spuran :- Need to change logic in class:- Opportunity is not creating #2711,2756,3942
        //ExamManagementController.createExamRescheduleFeesOrderInternal(examRegistration1.id, examAdmin1.Id, examAdmin1.Id, examSiteChinaExamPart1.Id, examSiteChinaExamPart1.Id,userId,true,true,'Deferral Standard',false);
        //Consult with Spuran :- Need to change logic in class:- Opportunity is not creating #2711,2756,3942
        //ExamManagementController.createExamRescheduleFeesOrderInternal(examRegistration1.id, examAdmin1.Id, examAdmin2.Id, examSiteChinaExamPart1.Id, examSiteChinaExamPart2.Id,userId,true,true,'Deferral Standard',false);    
        
        ExamManagementController.getExamRescheduleData(examRegistration2.id, examAdmin1.Id, examAdmin2.Id, examSiteChinaExamPart2.Id, examSiteChinaExamPart2.Id,userId);    
        
        ExamManagementRemoter.getExamRescheduleFees(examRegistration1.id, examAdmin1.Id, examAdmin2.id, examSiteChinaExamPart1.Id, examSiteChinaExamPart2.Id);
        
        Test.stopTest();
        }
    }
    
    @isTest
    public static void remainingTests2() {
        setup();
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
        User user = new User(Alias = 'nUser', Email='newuser@testorg.com', 
                             contactId = contact.id,EmailEncodingKey='UTF-8', 
                             LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles', 
                             UserName='nuser123@testorg.com');
        
        
        List<Product2> Product2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'FRM1X',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4011');
        Product2List.add(p1);
        Product2 p2 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',productCode = 'CHLF',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Weight__c=6,GL_Code__c='4011');
        Product2List.add(p2);
        Product2 p3 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',productCode = 'CHNDF',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Weight__c=6,GL_Code__c='4011');
        Product2List.add(p3);
        insert Product2List;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 customPB = new Pricebook2(Name='GARP 2015/2016', isActive=true);
        insert customPB;
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        insert standardPrice1;
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[1].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        insert standardPrice2;
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[2].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        insert standardPrice3;
        //List<PricebookEntry> lstPriceBookEntry = [SELECT Id, Name, Product2Id, ProductCode, Unitprice from PriceBookEntry where Pricebook2.Name = 'GARP 2015/2016' AND Product2Id in :lstProducts];
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry CustPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(CustPrice1);
        PricebookEntry CustPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = Product2List[1].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(CustPrice2);
        PricebookEntry CustPrice3 = new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = Product2List[2].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(CustPrice3);
        insert PricebookEntryList ;
        
        
        List<Opportunity> OppResults= new List<Opportunity>();
        Opportunity opp1 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        Opportunity opp2 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        OppResults.add(opp1);
        OppResults.add(opp2);
        insert OppResults;
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        INSERT opportunity;
        
        Contract frmProgram = new Contract(AccountId = account.Id,CustomerSignedId = contact.Id,OSTA_Last_Upload_Date__c = Null,
                                           RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRM_Program'),
                                           Status = 'Draft',Name = 'FRM Program', Opportunity__c=OppResults[0].Id,StartDate = Date.today(), ContractTerm = 9999);
        INSERT frmProgram;        
        frmProgram.Status = 'Activated ( Auto-Renew )';
        UPDATE frmProgram;
        
        Contract frmProgram1 = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'OSTA Program'),
            Status = 'Draft',
            Name = 'FRM Program',
            OSTA_Last_Upload_Date__c = Null,
            StartDate = Date.today(),
            ContractTerm = 9999
        );
        
        INSERT frmProgram1;
        frmProgram1.Status = 'Activated';
        UPDATE frmProgram1; 
        
        Scholarship_Application__c sa = new Scholarship_Application__c(Applicant__c = frmProgram.CustomerSignedId,
                                                                       Exam_Type__c='FRM',Status__c='Submitted', Exam_Group__c= examGroup.Id);
        insert sa;
        
        
        List<Exam_Attempt__c> attemptList = new List<Exam_Attempt__c>();
        Exam_Administration__c examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = examGroup.id;
        //examAdmin1.Exam_Group__c = nextExamGroup.id;
        examAdmin1.Exam_Date__c = system.today();
        examAdmin1.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin1.Exam_Type__c = 'FRM' ;
        examAdmin1.Exam_Admin_Modifications_Start_Date__c = system.today()+5;   
        examAdmin1.Exam_Admin_Modifications_End_Date__c = system.today().adddays(29);   
        examAdmin1.Exam_Scheduling_Start_Date__c = system.today()-4;    
        examAdmin1.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin1;
        
        
        Exam_Administration__c examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = nextExamGroup.id;
        examAdmin2.Exam_Date__c = system.today().addDays(10);
        examAdmin2.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin2.Exam_Type__c = 'FRM' ;
        examAdmin2.Exam_Scheduling_Start_Date__c = system.today()-4;    
        examAdmin2.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        examAdmin2.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin2;
        
        Exam_Administration__c dupexamAdmin2 = new Exam_Administration__c();
        dupexamAdmin2.Exam_Group__c = examGroup.id;
        dupexamAdmin2.Exam_Date__c = system.today().addDays(10);
        dupexamAdmin2.Exam_Start_Date__c = system.today().addDays(5);
        dupexamAdmin2.Exam_Type__c = 'FRM' ;
        dupexamAdmin2.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert dupexamAdmin2;
        
        Exam_Part__c exampart = new Exam_Part__c();
        exampart.Exam__c = frmPart1.Id;
        exampart.Exam_Administration__c = examAdmin1.Id ;
        exampart.Delivery_Method__c = 'CBT';
        exampart.Exam_Start_Date__c = Date.today();
        exampart.Exam_Date__c = Date.today();
        exampart.Exam_End_Date__c = Date.today().addDays(10);
        insert exampart;
        
        exampart2 = new Exam_Part__c();
        exampart2.Exam__c = frmPart2.Id;
        exampart2.Exam_Administration__c = examAdmin2.Id ;
        exampart2.Delivery_Method__c = 'CBT';
        exampart2.Exam_Start_Date__c = Date.today();
        exampart2.Exam_Date__c = Date.today();
        exampart2.Exam_End_Date__c = Date.today().addDays(10);
        insert exampart2;
        
        Exam_Sites__c examSiteChinaExamPart1 = new Exam_Sites__c();
        examSiteChinaExamPart1.Name = 'May 2018 FRM Exam Part I, China, Guangzhou';
        examSiteChinaExamPart1.Site__c = testSiteChina.Id;
        examSiteChinaExamPart1.Exam__c = frmPart1.Id;
        examSiteChinaExamPart1.Exam_Part__c = exampart.Id;
        INSERT examSiteChinaExamPart1;
        
        Exam_Attempt__c examRegistration0 = new Exam_Attempt__c();
        examRegistration0.Member__c = contact.Id;
        examRegistration0.Exam_Part__c = exampart.Id;
        examRegistration0.Exam_Administration__c = examAdmin1.Id;
        examRegistration0.Deferred_Exam_Administration__c = Null;
        examRegistration0.Exam_Site__c = examSiteChinaExamPart1.Id;
        INSERT examRegistration0;
        
        Exam_Attempt__c examRegistration01 = new Exam_Attempt__c();
        examRegistration01.Member__c = contact.Id;
        examRegistration01.Exam_Part__c = exampart.Id;
        examRegistration01.Exam_Administration__c = examAdmin1.Id;
        examRegistration01.Deferred_Exam_Administration__c = Null;
        examRegistration01.Deferred_From_Exam_Registration__c = examRegistration0.id;
        examRegistration01.Exam_Site__c = examSiteChinaExamPart1.Id;
        
        examRegistration01.Cancelled__c=False;
        examRegistration01.Opportunity__c=Opportunity.id;
        examRegistration01.Cloned_From__c = examRegistration0.Id;
        examRegistration01.Result__c='No-Show';
        examRegistration01.Candidate_Commitment__c=frmProgram.id;
        examRegistration01.Original_Exam_Administration__c = examAdmin1.id;
        INSERT examRegistration01;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Cancelled__c=False;
        examRegistration.Opportunity__c=Opportunity.id;
        examRegistration.Cloned_From__c = examRegistration0.Id;
        examRegistration.Result__c='No-Show';
        examRegistration.Candidate_Commitment__c=frmProgram.id;
        examRegistration.Exam_Part__c = exampart.Id;
        examRegistration.Deferred_Exam_Administration__c = examAdmin1.id;
        examRegistration.Original_Exam_Administration__c = examAdmin1.id;
        examRegistration.Exam_Administration__c = examAdmin1.Id;
        examRegistration.Exam_Site__c = examSiteChinaExamPart1.Id;
        insert examRegistration;
    
        Exam_Attempt__c examRegistration2 = new Exam_Attempt__c();
        examRegistration2.Member__c = contact.Id;
        examRegistration2.Cloned_From__c = examRegistration0.Id;
        examRegistration2.Result__c='No-Show';
        examRegistration2.Candidate_Commitment__c=frmProgram1.id;
        examRegistration2.Exam_Part__c = exampart2.Id;
        examRegistration2.Cancelled__c=False;
        examRegistration2.Opportunity__c=Opportunity.id;
        examRegistration2.Deferred_Exam_Administration__c = examAdmin2.id;
        examRegistration2.Original_Exam_Administration__c = examAdmin2.id;
        examRegistration2.Exam_Administration__c = examAdmin2.Id;
        examRegistration2.Exam_Site__c = examSiteChinaExamPart2.Id;
        insert examRegistration2;
        
        Exam_Registration_Modification__c examRegMod0 = new Exam_Registration_Modification__c();
        examRegMod0.Part_I_Exam_Admin_From__c = examAdmin1.id;
        examRegMod0.Part_I_Exam_Registration__c = examRegistration0.id;
        examRegMod0.Part_I_Exam_Admin_To__c  = examAdmin2.id;
        examRegMod0.Status__c = 'Pending';
        insert examRegMod0;
        
        Exam_Registration_Modification__c examRegMod00 = new Exam_Registration_Modification__c();
        examRegMod00.Part_II_Exam_Admin_From__c = examAdmin2.id;
        examRegMod00.Part_I_Exam_Registration__c = examRegistration01.id;
        examRegMod00.Part_II_Exam_Registration__c = examRegistration01.id;
        examRegMod00.Part_II_Exam_Admin_To__c  = examAdmin1.id;
        examRegMod00.Status__c = 'Pending';
        insert examRegMod00;
        
        Exam_Registration_Modification__c examRegMod01 = new Exam_Registration_Modification__c();
        examRegMod01.Part_I_Exam_Admin_From__c = Null;
        examRegMod01.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod01.Part_I_Exam_Admin_To__c  = Null;
        examRegMod01.Status__c = 'Pending';
        insert examRegMod01;
        
        Exam_Registration_Modification__c examRegMod = new Exam_Registration_Modification__c();
        examRegMod.Customer_Email__c='TEST@TEST.com'; 
        examRegMod.Part_I_Exam_Admin_From__c = examAdmin1.id ;
        examRegMod.Part_II_Exam_Admin_From__c  = examAdmin2.id ;
        examRegMod.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod.Not_Applicable_to_One_Time_Def__c = true;
        examRegMod.Free_Deferral__c = true;
        examRegMod.Part_I_Exam_Admin_To__c  = examAdmin1.id;
        examRegMod.Part_II_Exam_Admin_To__c  = examAdmin2.id ;
        examRegMod.Created_from_MS_Tool__c = false;
        
        examRegMod.Status__c = 'Pending';
        insert examRegMod ;
        
        Exam_Registration_Modification__c examRegMod1 = new Exam_Registration_Modification__c();
        examRegMod1.Customer_Email__c='TEST@TEST.com'; 
        examRegMod1.Part_I_Exam_Admin_From__c = examAdmin2.id ;
        examRegMod1.Part_II_Exam_Admin_From__c  = examAdmin2.id ;
        examRegMod1.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod1.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod1.Part_I_Exam_Admin_To__c  = examAdmin1.id;
        examRegMod1.Part_II_Exam_Admin_To__c  = examAdmin1.id ;
        examRegMod1.Created_from_MS_Tool__c = false;
        examRegMod1.Not_Applicable_to_One_Time_Def__c = true;
        examRegMod1.Free_Deferral__c = true;
        examRegMod1.Status__c = 'Pending';
        insert examRegMod1 ;
        
        Exam_Registration_Modification__c examRegMod2 = new Exam_Registration_Modification__c();
        examRegMod2.Customer_Email__c='TEST@TEST.com';
        examRegMod2.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod2.Part_I_Exam_Admin_From__c = examAdmin1.id ;
        examRegMod2.Part_I_Exam_Site_From__c=NULL; 
        examRegMod2.Part_I_Exam_Site_To__c=examSiteChinaExamPart1.id;
        examRegMod2.Part_I_Exam_Admin_To__c  = dupexamAdmin2.id;
        examRegMod2.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod2.Part_II_Exam_Admin_From__c  = examAdmin1.id ;
        examRegMod2.Part_II_Exam_Site_From__c=examSiteChinaExamPart2.id;
        examRegMod2.Part_II_Exam_Site_To__c=examSiteChinaExamPart1.id;
        //examRegMod2.Part_II_Exam_Admin_To__c  = dupexamAdmin2.id ; 
        examRegMod2.Part_II_Exam_Admin_To__c  = examAdmin2.id ;
        examRegMod2.Created_from_MS_Tool__c = false;
        
        examRegMod2.Status__c = 'Pending';
        insert examRegMod2 ;
        
        
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[0].Id,UnitPrice = 7000,Description='test',
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = examRegistration.Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = OppResults[1].Id,PricebookEntryId = PricebookEntryList[1].Id,UnitPrice = 7000,Description='test',
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = examRegistration2.Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem2);
        OpportunityLineItem oppLineItem3 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[2].Id,UnitPrice = 7000,Description='test',
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = examRegistration2.Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem3);
        insert OpportunityLineItemList;       
        
        ChargentBase__Gateway__c gateway = new ChargentBase__Gateway__c(Name = 'paypal garp');
        insert gateway;
            
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = OppResults[0].id);
        insert order; 
        ChargentOrders__Transaction__c payment = new ChargentOrders__Transaction__c(Opportunity__c = OppResults[0].id,ChargentOrders__Type__c = 'Charge',
                                                                                    ChargentOrders__Order__c = order.id,ChargentOrders__Gateway__c = gateway.id,
                                                                              ChargentOrders__Response_Status__c= 'Approved');
        insert payment;
        ChargentOrders__ChargentOrder__c order1 = new ChargentOrders__ChargentOrder__c(Opportunity__c = OppResults[1].id);
        insert order1; 
        ChargentOrders__Transaction__c payment1 = new ChargentOrders__Transaction__c(Opportunity__c = OppResults[1].id,ChargentOrders__Type__c = 'Charge',
                                                                                     ChargentOrders__Order__c = order1.id,ChargentOrders__Gateway__c = gateway.id,
                                                                               ChargentOrders__Response_Status__c= 'Approved');
        insert payment1;
        
        
        List<Product_Refunds__c> ProductRefundsList = new List<Product_Refunds__c>();
        Product_Refunds__c refund1 = new Product_Refunds__c (Status__c='Completed',Cancel_E_book__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[0].id,product__c = Product2List[0].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund1);
        Product_Refunds__c refund2 = new Product_Refunds__c (Status__c='Completed',Cancel_ERP_Enrollment__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[0].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund2);
        insert ProductRefundsList;
        
        Set<Id> setId = new Set<Id>();
        setId.add(examRegMod.Id);
        setId.add(examRegMod1.Id);
        setId.add(examRegMod2.Id);
        setId.add(examRegMod0.Id);
        setId.add(examRegMod00.Id);
        setId.add(examRegMod01.Id);
        
        Test.startTest();
        
        List<User> lstUsers = [SELECT Id,ContactId FROM 
                               User WHERE username =: 'testCommunityUsermig123@test.com' LIMIT 1];
        String userId = lstUsers[0].Id;
        //Consult with Spuran :- Need to change logic in class:- Opportunity is not creating #2711,2756,3942
        //ExamManagementController.createExamRescheduleFeesOrderInternal(examRegistration.id, examAdmin1.Id, examAdmin2.Id, examSiteChinaExamPart1.Id, examSiteChinaExamPart2.Id,userId,true,true,'Deferral Standard',false);
        ExamManagementController.processExamRegModsBulk(setId);
        ExamManagementController.getExamResults(lstUsers[0].ContactId,null);
        examRegMod2.Part_I_Exam_Registration__c = examRegistration01.id;
        update examRegMod2;
        
        ExamManagementController.processExamRegModsBulk(new set<id>{examRegMod2.id});
        //ExamManagementController.createExamRescheduleFeesOrderInternal(examRegistration1.id, examAdmin1.Id, examAdmin2.Id, examSiteChinaExamPart1.Id, examSiteChinaExamPart2.Id,userId,true,true,'Deferral Standard');
        
        //ExamManagementController.getExamRescheduleFeesInternal(examRegistration.id, examAdmin1.Id, examAdmin2.Id, examSiteChinaExamPart1.Id, examSiteChinaExamPart2.Id,userId,true);
        ExamManagementController.findRefundOpp(examRegistration);
        ExamManagementController.findRefundOpp(examRegistration2);
    
        ExamManagementController.validateIDFormat('E12345678','Passport','China');
        ExamManagementController.validateIDFormat('E1234567','Passport','China');
        ExamManagementController.validateIDFormat('EA2345678','Passport','China');
        ExamManagementController.validateIDFormat('E123I5678','Passport','China');
        ExamManagementController.validateIDFormat('EA23I5678','Passport','China');
        
        ExamManagementController.validateIDFormat('123456789012345678','Driver\'s License','China');
        ExamManagementController.validateIDFormat('12345678901234567','Driver\'s License','China');
        
        
        Test.stopTest();     
    }   
    
    @isTest
    public static void remainingTests3() {
        setup();
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
        User user = new User(Alias = 'nUser', Email='newuser@testorg.com', 
                             contactId = contact.id,EmailEncodingKey='UTF-8', 
                             LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles', 
                             UserName='nuser123@testorg.com');
        
        
        List<Product2> Product2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'FRM1X',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4011');
        Product2List.add(p1);
        Product2 p2 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',productCode = 'CHLF',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Weight__c=6,GL_Code__c='4011');
        Product2List.add(p2);
        Product2 p3 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',productCode = 'CHNDF',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Weight__c=6,GL_Code__c='4011');
        Product2List.add(p3);
        insert Product2List;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        Pricebook2 customPB = new Pricebook2(Name='GARP 2015/2016', isActive=true);
        insert customPB;
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        insert standardPrice1;
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[1].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        insert standardPrice2;
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[2].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        insert standardPrice3;
        //List<PricebookEntry> lstPriceBookEntry = [SELECT Id, Name, Product2Id, ProductCode, Unitprice from PriceBookEntry where Pricebook2.Name = 'GARP 2015/2016' AND Product2Id in :lstProducts];
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry CustPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(CustPrice1);
        PricebookEntry CustPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = Product2List[1].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(CustPrice2);
        PricebookEntry CustPrice3 = new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = Product2List[2].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(CustPrice3);
        insert PricebookEntryList ;
        
        
        List<Opportunity> OppResults= new List<Opportunity>();
        Opportunity opp1 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        Opportunity opp2 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        OppResults.add(opp1);
        OppResults.add(opp2);
        insert OppResults;
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        INSERT opportunity;
        
        Contract frmProgram = new Contract(AccountId = account.Id,CustomerSignedId = contact.Id,OSTA_Last_Upload_Date__c = Null,
                                           RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRM_Program'),
                                           Status = 'Draft',Name = 'FRM Program', Opportunity__c=OppResults[0].Id,StartDate = Date.today(), ContractTerm = 9999);
        INSERT frmProgram;        
        frmProgram.Status = 'Activated ( Auto-Renew )';
        UPDATE frmProgram;
        
        Contract frmProgram1 = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'OSTA Program'),
            Status = 'Draft',
            Name = 'FRM Program',
            OSTA_Last_Upload_Date__c = Null,
            StartDate = Date.today(),
            ContractTerm = 9999
        );
        
        INSERT frmProgram1;
        frmProgram1.Status = 'Activated';
        UPDATE frmProgram1; 
        
        Scholarship_Application__c sa = new Scholarship_Application__c(Applicant__c = frmProgram.CustomerSignedId,
                                                                       Exam_Type__c='FRM',Status__c='Submitted', Exam_Group__c= examGroup.Id);
        insert sa;
        
        
        List<Exam_Attempt__c> attemptList = new List<Exam_Attempt__c>();
        Exam_Administration__c examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = examGroup.id;
        //examAdmin1.Exam_Group__c = nextExamGroup.id;
        examAdmin1.Exam_Date__c = system.today();
        examAdmin1.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin1.Exam_Type__c = 'FRM' ;
        examAdmin1.Exam_Admin_Modifications_Start_Date__c = system.today()+5;   
        examAdmin1.Exam_Admin_Modifications_End_Date__c = system.today().adddays(29);   
        examAdmin1.Exam_Scheduling_Start_Date__c = system.today()-4;    
        examAdmin1.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin1;
        
        
        Exam_Administration__c examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = nextExamGroup.id;
        examAdmin2.Exam_Date__c = system.today().addDays(10);
        examAdmin2.Exam_Start_Date__c = system.today().addDays(5);
        examAdmin2.Exam_Type__c = 'FRM' ;
        examAdmin2.Exam_Scheduling_Start_Date__c = system.today()-4;    
        examAdmin2.Exam_Scheduling_End_Date__c = system.today().adddays(30);
        examAdmin2.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert examAdmin2;
        
        Exam_Administration__c dupexamAdmin2 = new Exam_Administration__c();
        dupexamAdmin2.Exam_Group__c = examGroup.id;
        dupexamAdmin2.Exam_Date__c = system.today().addDays(10);
        dupexamAdmin2.Exam_Start_Date__c = system.today().addDays(5);
        dupexamAdmin2.Exam_Type__c = 'FRM' ;
        dupexamAdmin2.Exam_Results_Release_Date__c = DateTime.now().addDays(90);
        insert dupexamAdmin2;
        
        Exam_Part__c exampart = new Exam_Part__c();
        exampart.Exam__c = frmPart1.Id;
        exampart.Exam_Administration__c = examAdmin1.Id ;
        exampart.Delivery_Method__c = 'CBT';
        exampart.Exam_Start_Date__c = Date.today();
        exampart.Exam_Date__c = Date.today();
        exampart.Exam_End_Date__c = Date.today().addDays(10);
        insert exampart;
        
        exampart2 = new Exam_Part__c();
        exampart2.Exam__c = frmPart2.Id;
        exampart2.Exam_Administration__c = examAdmin2.Id ;
        exampart2.Delivery_Method__c = 'CBT';
        exampart2.Exam_Start_Date__c = Date.today();
        exampart2.Exam_Date__c = Date.today();
        exampart2.Exam_End_Date__c = Date.today().addDays(10);
        insert exampart2;
        
        Exam_Sites__c examSiteChinaExamPart1 = new Exam_Sites__c();
        examSiteChinaExamPart1.Name = 'May 2018 FRM Exam Part I, China, Guangzhou';
        examSiteChinaExamPart1.Site__c = testSiteChina.Id;
        examSiteChinaExamPart1.Exam__c = frmPart1.Id;
        examSiteChinaExamPart1.Exam_Part__c = exampart.Id;
        INSERT examSiteChinaExamPart1;
        
        Exam_Attempt__c examRegistration0 = new Exam_Attempt__c();
        examRegistration0.Member__c = contact.Id;
        examRegistration0.Exam_Part__c = exampart.Id;
        examRegistration0.Exam_Administration__c = examAdmin1.Id;
        examRegistration0.Deferred_Exam_Administration__c = Null;
        examRegistration0.Exam_Site__c = examSiteChinaExamPart1.Id;
        INSERT examRegistration0;
        
        Exam_Attempt__c examRegistration01 = new Exam_Attempt__c();
        examRegistration01.Member__c = contact.Id;
        examRegistration01.Exam_Part__c = exampart.Id;
        examRegistration01.Exam_Administration__c = examAdmin1.Id;
        examRegistration01.Deferred_Exam_Administration__c = Null;
        examRegistration01.Deferred_From_Exam_Registration__c = examRegistration0.id;
        examRegistration01.Exam_Site__c = examSiteChinaExamPart1.Id;
        INSERT examRegistration01;
        
        Exam_Attempt__c examRegistration = new Exam_Attempt__c();
        examRegistration.Member__c = contact.Id;
        examRegistration.Cancelled__c=False;
        examRegistration.Opportunity__c=Opportunity.id;
        examRegistration.Cloned_From__c = examRegistration0.Id;
        examRegistration.Result__c='No-Show';
        examRegistration.Candidate_Commitment__c=frmProgram.id;
        examRegistration.Exam_Part__c = exampart.Id;
        examRegistration.Deferred_Exam_Administration__c = examAdmin1.id;
        examRegistration.Original_Exam_Administration__c = examAdmin1.id;
        examRegistration.Exam_Administration__c = examAdmin1.Id;
        examRegistration.Exam_Site__c = examSiteChinaExamPart1.Id;
        insert examRegistration;
                    
        Exam_Attempt__c examRegistration2 = new Exam_Attempt__c();
        examRegistration2.Member__c = contact.Id;
        examRegistration2.Cloned_From__c = examRegistration0.Id;
        examRegistration2.Result__c='No-Show';
        examRegistration2.Candidate_Commitment__c=frmProgram1.id;
        examRegistration2.Exam_Part__c = exampart2.Id;
        examRegistration2.Cancelled__c=False;
        examRegistration2.Opportunity__c=Opportunity.id;
        examRegistration2.Deferred_Exam_Administration__c = examAdmin2.id;
        examRegistration2.Original_Exam_Administration__c = examAdmin2.id;
        examRegistration2.Exam_Administration__c = examAdmin2.Id;
        examRegistration2.Exam_Site__c = examSiteChinaExamPart2.Id;
        insert examRegistration2;
        
        Exam_Registration_Modification__c examRegMod0 = new Exam_Registration_Modification__c();
        examRegMod0.Part_I_Exam_Admin_From__c = examAdmin1.id;
        examRegMod0.Part_I_Exam_Registration__c = examRegistration0.id;
        examRegMod0.Part_I_Exam_Admin_To__c  = examAdmin2.id;
        examRegMod0.Status__c = 'Pending';
        insert examRegMod0;
        
        Exam_Registration_Modification__c examRegMod00 = new Exam_Registration_Modification__c();
        examRegMod00.Part_II_Exam_Admin_From__c = examAdmin2.id;
        examRegMod00.Part_II_Exam_Registration__c = examRegistration01.id;
        examRegMod00.Part_II_Exam_Admin_To__c  = examAdmin1.id;
        examRegMod00.Status__c = 'Pending';
        insert examRegMod00;
        
        Exam_Registration_Modification__c examRegMod01 = new Exam_Registration_Modification__c();
        examRegMod01.Part_I_Exam_Admin_From__c = Null;
        examRegMod01.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod01.Part_I_Exam_Admin_To__c  = Null;
        examRegMod01.Status__c = 'Pending';
        insert examRegMod01;
        
        Exam_Registration_Modification__c examRegMod = new Exam_Registration_Modification__c();
        examRegMod.Customer_Email__c='TEST@TEST.com'; 
        examRegMod.Part_I_Exam_Admin_From__c = examAdmin1.id ;
        examRegMod.Part_II_Exam_Admin_From__c  = examAdmin2.id ;
        examRegMod.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod.Not_Applicable_to_One_Time_Def__c = true;
        examRegMod.Free_Deferral__c = true;
        examRegMod.Part_I_Exam_Admin_To__c  = examAdmin1.id;
        examRegMod.Part_II_Exam_Admin_To__c  = examAdmin2.id ;
        examRegMod.Created_from_MS_Tool__c = false;
        
        examRegMod.Status__c = 'Pending';
        insert examRegMod ;
        
        Exam_Registration_Modification__c examRegMod1 = new Exam_Registration_Modification__c();
        examRegMod1.Customer_Email__c='TEST@TEST.com'; 
        examRegMod1.Part_I_Exam_Admin_From__c = examAdmin2.id ;
        examRegMod1.Part_II_Exam_Admin_From__c  = examAdmin2.id ;
        examRegMod1.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod1.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod1.Part_I_Exam_Admin_To__c  = examAdmin1.id;
        examRegMod1.Part_II_Exam_Admin_To__c  = examAdmin1.id ;
        examRegMod1.Created_from_MS_Tool__c = false;
        examRegMod1.Not_Applicable_to_One_Time_Def__c = true;
        examRegMod1.Free_Deferral__c = true;
        examRegMod1.Status__c = 'Pending';
        insert examRegMod1 ;
        
        Exam_Registration_Modification__c examRegMod2 = new Exam_Registration_Modification__c();
        examRegMod2.Customer_Email__c='TEST@TEST.com';
        examRegMod2.Part_I_Exam_Registration__c = examRegistration.id;
        examRegMod2.Part_I_Exam_Admin_From__c = examAdmin1.id ;
        examRegMod2.Part_I_Exam_Site_From__c=NULL; 
        examRegMod2.Part_I_Exam_Site_To__c=examSiteChinaExamPart1.id;
        examRegMod2.Part_I_Exam_Admin_To__c  = dupexamAdmin2.id;
        examRegMod2.Part_II_Exam_Registration__c = examRegistration2.id;
        examRegMod2.Part_II_Exam_Admin_From__c  = examAdmin1.id ;
        examRegMod2.Part_II_Exam_Site_From__c=examSiteChinaExamPart2.id;
        examRegMod2.Part_II_Exam_Site_To__c=examSiteChinaExamPart1.id;
        //examRegMod2.Part_II_Exam_Admin_To__c  = dupexamAdmin2.id ; 
        examRegMod2.Part_II_Exam_Admin_To__c  = examAdmin2.id ;
        examRegMod2.Created_from_MS_Tool__c = false;
        
        examRegMod2.Status__c = 'Pending';
        insert examRegMod2 ;
        
        
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[0].Id,UnitPrice = 7000,Description='test',
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = examRegistration.Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = OppResults[1].Id,PricebookEntryId = PricebookEntryList[1].Id,UnitPrice = 7000,Description='test',
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = examRegistration2.Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem2);
        OpportunityLineItem oppLineItem3 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[2].Id,UnitPrice = 7000,Description='test',
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = examRegistration2.Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem3);
        insert OpportunityLineItemList;       
        
        ChargentBase__Gateway__c gateway = new ChargentBase__Gateway__c(Name = 'paypal garp');
        insert gateway;
            
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = OppResults[0].id);
        insert order; 
        ChargentOrders__Transaction__c payment = new ChargentOrders__Transaction__c(Opportunity__c = OppResults[0].id,ChargentOrders__Type__c = 'Charge',
                                                                                    ChargentOrders__Order__c = order.id,ChargentOrders__Gateway__c = gateway.id,
                                                                              ChargentOrders__Response_Status__c= 'Approved');
        insert payment;
        ChargentOrders__ChargentOrder__c order1 = new ChargentOrders__ChargentOrder__c(Opportunity__c = OppResults[1].id);
        insert order1; 
        ChargentOrders__Transaction__c payment1 = new ChargentOrders__Transaction__c(Opportunity__c = OppResults[1].id,ChargentOrders__Type__c = 'Charge',
                                                                                     ChargentOrders__Order__c = order1.id,ChargentOrders__Gateway__c = gateway.id,
                                                                               ChargentOrders__Response_Status__c= 'Approved');
        insert payment1;
        
        
        List<Product_Refunds__c> ProductRefundsList = new List<Product_Refunds__c>();
        Product_Refunds__c refund1 = new Product_Refunds__c (Status__c='Completed',Cancel_E_book__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[0].id,product__c = Product2List[0].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund1);
        Product_Refunds__c refund2 = new Product_Refunds__c (Status__c='Completed',Cancel_ERP_Enrollment__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[0].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund2);
        insert ProductRefundsList;
        
        Set<Id> setId = new Set<Id>();
        setId.add(examRegMod.Id);
        setId.add(examRegMod1.Id);
        setId.add(examRegMod2.Id);
        setId.add(examRegMod0.Id);
        setId.add(examRegMod00.Id);
        setId.add(examRegMod01.Id);
        
        Test.startTest();
        
        List<User> lstUsers = [SELECT Id,ContactId FROM 
                               User WHERE username =: 'testCommunityUsermig123@test.com' LIMIT 1];
        String userId = lstUsers[0].Id;
        //Consult with Spuran :- Need to change logic in class:- Opportunity is not creating #2711,2756,3942
        //ExamManagementController.createExamRescheduleFeesOrderInternal(examRegistration.id, examAdmin1.Id, examAdmin2.Id, examSiteChinaExamPart1.Id, examSiteChinaExamPart2.Id,userId,true,true,'Deferral Standard',false);
        ExamManagementController.processExamRegModsBulk(setId);
        ExamManagementController.getExamResults(lstUsers[0].ContactId,null);
        ExamManagementController.getAllOpportunityIdsByExamRegistrations(new List<Exam_Attempt__c>{examRegistration2,examRegistration,examRegistration01,examRegistration0});   
        //ExamManagementController.createExamRescheduleFeesOrderInternal(examRegistration1.id, examAdmin1.Id, examAdmin2.Id, examSiteChinaExamPart1.Id, examSiteChinaExamPart2.Id,userId,true,true,'Deferral Standard');
        
        //ExamManagementController.getExamRescheduleFeesInternal(examRegistration.id, examAdmin1.Id, examAdmin2.Id, examSiteChinaExamPart1.Id, examSiteChinaExamPart2.Id,userId,true);
        ExamManagementController.findRefundOpp(examRegistration);
        ExamManagementController.findRefundOpp(examRegistration2);
    
        ExamManagementController.validateIDFormat('E12345678','Passport','China');
        ExamManagementController.validateIDFormat('E1234567','Passport','China');
        ExamManagementController.validateIDFormat('EA2345678','Passport','China');
        ExamManagementController.validateIDFormat('E123I5678','Passport','China');
        ExamManagementController.validateIDFormat('EA23I5678','Passport','China');
        
        ExamManagementController.validateIDFormat('123456789012345678','Driver\'s License','China');
        ExamManagementController.validateIDFormat('12345678901234567','Driver\'s License','China');
        
        
        Test.stopTest();     
    }   

    
}