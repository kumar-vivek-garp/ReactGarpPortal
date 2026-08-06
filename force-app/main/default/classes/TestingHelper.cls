@isTest
public without sharing class TestingHelper {
    
    // Individual Account Record Type
    public static Id individualId {
        get {
            if(null == individualId) {
                individualId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Individual'].Id;
            }
            
            return individualId;
        }
        private set;
    }
    
    // Convention Event Record Type
    public static Id conventionId {
        get {
            if(null == conventionId) {
                conventionId = [SELECT Id FROM RecordType WHERE SObjectType = 'Event__c' AND DeveloperName = 'Convention'].Id;
            }
            
            return conventionId;
        }
        private set;
    }
    
    // If Account is Individual Record Type, Site User is auto created
    public static Contact createContact(String conEmail, Boolean useIndiRecType, Boolean isCreate) {
        Account acct = new Account(Name = 'Apex Test User Trigger');
        if(useIndiRecType) acct.RecordTypeId = individualId;
        insert acct;
        
        Contact con = new Contact(FirstName = 'Apex', LastName = 'TestCon', AccountId = acct.Id, Email = conEmail, Phone = '646951' + Math.round(Math.random() * 10000));
        if(isCreate) insert con;
        
        return con;
    }
    
    public static Event__c createConvention(Boolean isCreate) {
        Datetime nowDt = System.now();
        
       
        
        Event__c evt = new Event__c(RecordTypeId = conventionId, 
            Name = 'Apex Test GARP 20th Convention', Title__c = 'Apex Test GARP 20th Convention', Status__c = 'Draft', Start_Date__c = nowDt, End_Date__c = nowDt.addDays(3)
        );
        if(isCreate) insert evt;
        
         Event_Rate__c evtR = new Event_Rate__c(Name ='Erly', Event__c=evt.id);
        insert evtR;
        
        evt.Status__c = 'Active';
        update evt;
        
        return evt;
    }
    
    public static Event_Registration__c createRegistration(String contId, String evtId, Boolean isCreate) {
        Event_Registration__c evtRegis = new Event_Registration__c(Contact__c = contId, Event__c = evtId);
        if(isCreate) insert evtRegis;
        
        return evtRegis;
    }
    
    public static Event_Sessions__c createEventSession(String evtId, Boolean isCreate) {
        Event_Sessions__c evtSess = new Event_Sessions__c(Event__c = evtId, Start_Date_Time__c = System.now(), End_Date_Time__c = System.now().addDays(1), Category__c = 'Market', Subcategory__c = 'Metrics');
        if(isCreate) insert evtSess;
        
        return evtSess;
    }
    
    public static Event_Speaker__c createEventSpeaker(Contact cont, Boolean isCreate) {
        Event_Speaker__c evtSpkr = new Event_Speaker__c(Contact__c = cont.Id, First_Name__c = cont.FirstName, Last_Name__c = cont.LastName);
        
        if(isCreate) insert evtSpkr;
        
        return evtSpkr;
    }
    
    public static Event_Speaker_Session_Track__c createSpeakerSession(String sessId, String spkrId, Boolean isCreate) {
        Event_Speaker_Session_Track__c esst = new Event_Speaker_Session_Track__c(Status__c = 'Active', Event_Session__c = sessId, Event_Speaker__c = spkrId);
        
        if(isCreate) insert esst;
        
        return esst;
    }
    
    public static Chapter_Meeting_Speaker__c createChapterMeetingSpeaker(Contact con, Boolean isCreate) {
        Chapter__c chap = new Chapter__c(Name = 'Apex Test Chapter', Status__c = 'Active');
        insert chap;
        
        Chapter_Meeting__c chapMeet = new Chapter_Meeting__c(Name = 'Apex Test Chap Meet', Chapter_Meeting_Name__c = 'Apex Test Chapter Meeting', Status__c = 'Active', Start__c = System.now().addDays(-1), End__c = System.now(), Category__c = 'Energy', Subcategory__c = 'Oil', Chapter__c = chap.Id);
        insert chapMeet;
        
        Chapter_Speaker__c chapSpkr = new Chapter_Speaker__c(Contact__c = con.Id, First_Name__c = con.FirstName, Last_Name__c = con.LastName);
        insert chapSpkr;
        
        Chapter_Meeting_Speaker__c cms = new Chapter_Meeting_Speaker__c(Chapter_Meeting__c = chapMeet.Id, Chapter_Speaker__c = chapSpkr.Id);
        if(isCreate) insert cms;
        
        return cms;
    }
    
    public static Webcast__c createWebcast(Boolean isCreate) {
        Id recTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Content__c' AND DeveloperName = 'Event'].Id;
        Content__c content = new Content__c(RecordTypeId = recTypeId, Name = 'Apex Test Content', Category__c = 'Credit', Subcategory__c = 'Capital');
        insert content;
        
        Webcast__c wc = new Webcast__c(Name = 'Apex Test Webcast', Status__c = 'Active', Start_Date__c = System.now().addDays(-1), End_Date__c = System.now(), Content__c = content.Id);
        
        if(isCreate) insert wc;
        
        return wc;
    }
    
    public static Presenter__c createWebcastPresenter(String webcastId, String contactId, Boolean isCreate) {
        Presenter__c pres = new Presenter__c(Webcast__c = webcastId, Contact__c = contactId);
        
        if(isCreate) insert pres;
        
        return pres;
    }
    
    public static void createAlumniSetting(String conEmail) {
        ConventionAlumni__c alumEmail = new ConventionAlumni__c();
        alumEmail.Name = conEmail;
        alumEmail.Alumni_Email__c = conEmail;
        insert alumEmail;
    }
    
    public static Opportunity createOppty(String name, Boolean isCreate) {
        return createOppty(name, isCreate, true);
    }

    // When using SeeAllData, do not create dependency. Example: SeeAllData is required for ConnectApi test and insertDependent should be false
    public static Opportunity createOppty(String name, Boolean isCreate, Boolean insertDependent) {
        if(insertDependent) {
            setupChargentGateway();
        }
        
        Account acct = new Account(Name = 'Apex Test User Trigger', GARP_ID__c=System.now().format('yyMddhhmmss') + Integer.valueOf(Math.random()*10));
        insert acct;
        
        Opportunity opp = new Opportunity(AccountId = acct.Id, Name = name, StageName = 'New Lead', CloseDate = System.today().addDays(5), PriceBook2Id = Test.getStandardPricebookId());
        
        if(isCreate) insert opp;
        return opp;
    }
    
    public static void setupChargentGateway() {
        Id payPalRecTypeId = Schema.SObjectType.ChargentBase__Gateway__c.getRecordTypeInfosByName().get('Payflow Pro (PayPal)').getRecordTypeId();
        ChargentBase__Gateway__c gatewayGarp = new ChargentBase__Gateway__c(RecordTypeId = payPalRecTypeId, Name='paypal garp', ChargentBase__Active__c=true, ChargentBase__Test_Mode__c=true);
        ChargentBase__Gateway__c gatewayGRA = new ChargentBase__Gateway__c(RecordTypeId = payPalRecTypeId, Name='paypal gra', ChargentBase__Active__c=true, ChargentBase__Test_Mode__c=true);
        insert new ChargentBase__Gateway__c[]{gatewayGarp, gatewayGRA};
        
        // Hard Requirement in trigger onOpportunityInsertUpdate
        updateids__c testUpdtId = new updateids__c(Name = 'GARP', Record_id__c = gatewayGarp.Id);
        updateids__c testUpdtId2 = new updateids__c(Name = 'GRA', Record_id__c = gatewayGRA.Id);
        
        insert new updateids__c[]{testUpdtId, testUpdtId2};
    }

    public static Opportunity createInstSaleOppty(String name, String company, Boolean isCreate, Boolean insertDependent) {
        Opportunity tstOppty = TestingHelper.createOppty(name, false, insertDependent);
        tstOppty.Company__c = company;
        tstOppty.Institutional_Sale__c = true;
        tstOppty.Inst_Sale_Service_End_Date__c = System.today().addDays(7);
        
        if(isCreate) insert tstOppty;
        return tstOppty;
    }

    public static User createUser(String profileName, String email, Boolean isCreate) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];

        User user = new User(alias='tst9527', email=email,
            emailencodingkey='UTF-8', firstname='Tiesto', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid=p.Id, country='United States', IsActive=true,
            ContactId=null,
            timezonesidkey='America/Los_Angeles', username='atst9527' + System.now().millisecond() + '@nomail.com');
            
        if(isCreate) insert user;
        
        return user;
    }

    // compType should be either GARP or GRA
    public static Product2 createProduct(String compType, String name, Boolean isCreate) {
        Product2 prod = new Product2(Name = name, Company__c = compType, GL_Code__c = '4030Test', ProductCode = 'Test_Prod', Acct_Prod_Code__c = 'Test_Prod', Acct_Dept_Code__c = 'Test_Dep', Acct_GL_Short_Title__c = 'Test Title');
        
        if(isCreate) {
            insert prod;
            createEntry(prod.Id); 
        }
        
        return prod;
    }
    
    public static void createEntry(String prodId) {
        Id pricebookId = Test.getStandardPricebookId();
        insert new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prodId, UnitPrice = 15, IsActive = true);
    }
    
    public static List<Product2> createFRMProds() {
        Product2 frmExam = new Product2(Name='FRM Exam Part I Early Registration', Company__c='GARP', GL_Code__c='4001', ProductCode='FRM1E',  Acct_Dept_Code__c='CER', Acct_Prod_Code__c='FRM1', Acct_GL_Short_Title__c = 'Exam Income May');
        Product2 frmEnroll = new Product2(Name='FRM Enrollment Fee', Company__c='GARP', GL_Code__c='4010', ProductCode='FRM1',  Acct_Dept_Code__c='CER', Acct_Prod_Code__c='FRM1', Acct_GL_Short_Title__c = 'Enrollment Income');
        Product2 frmBook = new Product2(Name='FRM Exam Part I Books', Company__c='GARP', GL_Code__c='4030', ProductCode='FRM1H',  Acct_Dept_Code__c='CER', Acct_Prod_Code__c='FRM1H', Acct_GL_Short_Title__c = 'Material Income', Weight__c = 1);
        Product2 frmShip = new Product2(Name='Shipping and Handling', Company__c='GARP', ProductCode='SHIP');
        Product2 miscProd = new Product2(Name='Misc Product', Company__c='GARP', ProductCode='MISC');
        
        List<Product2> frmProds = new List<Product2>{frmExam, frmEnroll, frmBook, frmShip, miscProd};
        insert frmProds;
        
        for(Product2 prod : frmProds) {
            createEntry(prod.Id);
        }
        
        return frmProds;
    } 
    
    public static OpportunityLineItem createOpptyProduct(String oppId, String prodId, Boolean isCreate) {
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppId, Product2Id = prodId, Quantity = 1, UnitPrice = 10, ServiceDate = System.today(), Description = 'Test Product on Oppty');
        
        if(isCreate) insert oli;
        return oli;
    }
    
    public static List<Mobius_Products__c> createMobiusSettings(Boolean isCreate) {
        List<Mobius_Products__c> mProdList;
        Mobius_Products__c mProd1 = new Mobius_Products__c(Name='FRM Current Year', Year__c=''+System.today().year());
        Mobius_Products__c mProd2 = new Mobius_Products__c(Name='FRM Exam Part I Book 1', Exam__c='FRM', Year__c='' + System.today().year(), Product_Id__c=30, Part__c='I');
        Mobius_Products__c mProd3 = new Mobius_Products__c(Name='FRM Exam Part II Book 1', Exam__c='FRM', Year__c='' + System.today().year(), Product_Id__c=33, Part__c='II');

        Mobius_Products__c mProd4 = new Mobius_Products__c(Name='SCR Current Year', Year__c=''+System.today().year());
        Mobius_Products__c mProd5 = new Mobius_Products__c(Name='SCR Book', Exam__c='SCR', Year__c='' + System.today().year(), Product_Id__c=30, Part__c=NULL);

        mProdList = new List<Mobius_Products__c>{mProd1, mProd2, mProd3, mProd4, mProd5};
        
        if(isCreate) insert mProdList;
        return mProdList;
    }
    
    public static Line_Item_Discount__c createItemDiscount(String oppId, String prodId, Boolean isCreate) {
        Line_Item_Discount__c itemDisc = new Line_Item_Discount__c(Opportunity__c = oppId, Product__c = prodId, Discount_Percent__c = 10);
        if(isCreate) insert itemDisc;
        
        return itemDisc;
    }
    
    public static Line_Item_Discount__c setupInstSaleOppWithDisc(String oppName) {
        Opportunity tstOpp = TestingHelper.createInstSaleOppty(oppName, 'GARP', true, true);
        List<Product2> prods = TestingHelper.createFRMProds();
        TestingHelper.createProduct(null, 'Inst Sale Total Discount', true);
        
        OpportunityLineItem oli = createOpptyProduct(tstOpp.Id, prods[0].Id, false);
        oli.UnitPrice=100;
        insert oli;
        
        return createItemDiscount(tstOpp.Id, prods[0].Id, true);
    }
    
    public static Study_Round__c createStudyVersion(Id studyId, Boolean isCreate) {
        Study_Round__c testRound = new Study_Round__c(
            Name = 'Round 1', Published_Date__c = System.today(), Round__c = 'Version 1', Status__c = 'Data Collection', 
            Study_Part__c = 'Part I', Study__c = studyId
        );
        
        if(isCreate) insert testRound;
        return testRound;
    }
    
    public static Study_Account__c createGBIStudyAccount(Id studyId, Boolean isCreate) {
        Id acctRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Institution').getRecordTypeId();
        Account gbiAcct = new Account(RecordTypeId = acctRecTypeId, Name = 'Test GBI Account', 
                                      GBI_Region__c = 'EU', GBI_Country_Code__c = 'DE', BillingCountry = 'Germany');
        insert gbiAcct;
        
        Study_Account__c stdyAcct = new Study_Account__c(Account__c = gbiAcct.Id, Study__c = studyId, Status__c = 'Active',Study_Fee_Type__c='Free');
        
        if(isCreate) insert stdyAcct;
        return stdyAcct;
    }
    
    public static List<GBI_Meta_Data__c> createGBIMetadata(Id acctId, Boolean isCreate) {
        GBI_Meta_Data__c gbiMeta1 = new GBI_Meta_Data__c(
            Name = 'G-SIB', Account__c = acctId, G_SIB__c = true, Year__c = '2019'
        );
        GBI_Meta_Data__c gbiMeta2 = new GBI_Meta_Data__c(
            Name = 'G-SIB', Account__c = acctId, G_SIB__c = false, Year__c = '2018'
        );
        
        List<GBI_Meta_Data__c> gbiMetaList = new List<GBI_Meta_Data__c>{gbiMeta1, gbiMeta2};
        if(isCreate) insert gbiMetaList;
        
        return gbiMetaList;
    }
    
    /*
        // Community Profile Id
        public static Id communityProfileId {
            get {
                if(null == communityProfileId) {
                    communityProfileId = [SELECT Id FROM Profile WHERE Name='Customer Community'].Id;
                }
                
                return communityProfileId;
            }
            private set;
        }
        public static User createSiteUser(String conEmail, Id conId, Boolean isCreate) {
            User user = new User(alias='atst123', email=conEmail,
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid=communityProfileId, country='United States', IsActive=true,
                ContactId=conId,
                timezonesidkey='America/Los_Angeles', username='atst' + System.now().millisecond() + '@nomail.com');
                
            if(isCreate) insert user;
            
            return user;
        }
    */

}