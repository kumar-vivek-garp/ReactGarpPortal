/**
* Test Class for MemberManagementExamSiteChange
**/
@isTest
public class MemberManagementExamSiteChangeTestCls {
    static Account account;
    static Account account123;
    static Contact contact;
    static Contact contact123;
    static Opportunity opportunity;
    static Opportunity opportunity1;
    static Site__c site;
    static Exam_Group__c objExamGrp;
    static Exam__c exam;
    static Exam_Sites__c examSite;
    static Contract contract;
    static Exam_Attempt__c examAttempt;
    static Product_Refunds__c productRefund;
    
    Public static void testData() {
        account = new Account(Name = 'test',BillingStreet = 'xxx',BillingCountry='USA',BillingState='xxx',
                              BillingPostalCode='00123',BillingCity='Newport');
        insert account;
        
        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com');
        insert contact;
        
        opportunity = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                      company__c = 'Payment', accountId = account.id,stageName = 'closed',
                                      Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity; 
        
        contract  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',
                                 recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program') ,
                                 Opportunity__c = opportunity.id,accountId = opportunity.AccountId); 
        insert contract;
        
        site = new Site__c(Site_Code__c = '123',name = 'test',Display_Address__c = 'test',active__c = true,
                           Non_selectable__c = false, Is_OSTA_Information_Required__c= false);
        insert site; 
        
        objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = false; 
        Date dt3 = system.today();
        objExamGrp.Exam_Date__c = system.today() +15;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;    
        insert objExamGrp;
        
        exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1'; 
        insert exam;
        
        examSite = new Exam_Sites__c(Name = 'test',Site__c = site.id,exam__c = exam.id,Exam_Date__c = system.today() + 30);
        insert examSite;
        
        examAttempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,
                                                      Member__c = contact.id,cancelled__c = false );
        insert examAttempt;
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'FRM1',GL_Code__c = '4020',Family = 'Hardware');
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'Laptop X200',productCode = 'ENC',GL_Code__c = '4020',Family = 'Hardware' );
        insert prod1;
        
        Product2 prod2 = new Product2(Name = 'Laptop X200',productCode = 'CHLF',GL_Code__c = '2008',Family = 'Hardware',
                                      IsActive = true);
        insert prod2;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,
                                                          UnitPrice = 10000,IsActive = true);
        insert standardPrice;
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,
                                                           UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id,
                                                           UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod.Id,
                                                        UnitPrice = 12000,IsActive = true);
        insert customPrice;
        
        PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod1.Id,
                                                         UnitPrice = 12000,IsActive = true);
        insert customPrice1;
        
        PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod2.Id,
                                                         UnitPrice = 12000,IsActive = true);
        insert customPrice2;
        
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opportunity.id,
                                                               PricebookEntryId = customPrice2.id,Unitprice = 12000,
                                                               Quantity = 1 );
        insert lineItem;
        OpportunityLineItem lineItem1 = new OpportunityLineItem(OpportunityId = opportunity.id,
                                                                PricebookEntryId = customPrice.id,Unitprice = 12000,
                                                                Quantity = 1);
        insert lineItem1;
    }
    
    public testMethod static void GARPIdValidation(){
        testData();
        test.startTest();
        Contact con = [Select id, GARP_Member_ID__c  from Contact];
        MemberManagementExamSiteChange.GARPIdValidation(con.GARP_Member_ID__c);
        MemberManagementExamSiteChange.GARPIdValidation(null);
        test.stopTest();
    }
    
   /* Public testMethod static void getExamTypeList() {
        testData();
        test.startTest();
        MemberManagementExamSiteChange.getExamTypeList();  
        test.stopTest();
    }*/
    
    Public testMethod static void getexamAttemptDetailsList() {
        testData();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,
                                                      Member__c = contact.id,cancelled__c = false );
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                       Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,
                                                       Member__c = contact.id,cancelled__c = false );
        insert attempt1;         
        insert attempt;
        test.startTest();
        MemberManagementExamSiteChange.getexamAttemptDetailsList(contact.id);
        test.stopTest();
    }
    
    Public testMethod static void getSiteList() { 
        testData();
        test.startTest();
		Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = 'Pass',
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,
                                                      Member__c = contact.id,cancelled__c = false );
        insert attempt;
        MemberManagementExamSiteChange.getSiteList(attempt.id,null);
        MemberManagementExamSiteChange.getSiteList(attempt.id,'test');
        test.stopTest();
    }
    
    Public testMethod static void ExamSiteChangeUpdate() { 
        testData();
        test.startTest();
        account123 = new Account(Name = 'test',BillingStreet = 'xxx',BillingCountry='USA',BillingState='xxx',
                              BillingPostalCode='00123',BillingCity='Newport');
        insert account123;
        
        contact123 = new Contact(lastname = 'Test',AccountId = account123.id,email='test@test.com');
        insert contact123;
        opportunity1 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                      company__c = 'Payment', accountId = account123.id,stageName = 'closed',
                                      Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity1;
        Contract contract1  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',
                                           recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','OSTA Program') ,
                                           Opportunity__c = opportunity1.id,accountId = opportunity1.AccountId,
                                           OSTA_Last_Upload_Date__c = null, status = 'Draft');
        insert contract1; 
        contract1.Status ='Activated';
        update contract1;
        Site__c site1 = new Site__c(Site_Code__c = '123',name = 'test',Display_Address__c = 'test',active__c = true,
                           Non_selectable__c = false, Is_OSTA_Information_Required__c= true);
        insert site1; 
        Exam__c exam1 = new Exam__c();
        exam1.Exam_Group__c = objExamGrp.id;
        exam1.Exam_Date__c = system.today() + 30;
        exam1.exam__c = 'FRM Part 2'; 
        insert exam1;
        Exam_Sites__c examSite1 = new Exam_Sites__c(Name = 'test',Site__c = site1.id,exam__c = exam.id,
                                                    Exam_Date__c = system.today() + 30);
        insert examSite1;
        Exam_Sites__c examSite2 = new Exam_Sites__c(Name = 'test',Site__c = site1.id,exam__c = exam1.id,
                                                    Exam_Date__c = system.today() + 30);
        insert examSite2;
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Pending',Result__c = null,
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite2.id,
                                                      Member__c = contact.id,cancelled__c = false);
        insert attempt;
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                       Opportunity__c = opportunity.id, Exam_Site__c = examSite1.id,
                                                       Member__c = contact.id,cancelled__c = false );
        insert attempt1;
        MemberManagementExamSiteChange.ExamSiteChangeUpdate(site.id, attempt.id , contact.id);
        delete contract1;
        MemberManagementExamSiteChange.ExamSiteChangeUpdate(site.id, attempt.id , contact.id);
        test.stopTest();
    }
    
    Public testMethod static void ExamSiteChangeUpdate1() { 
        testData();
        test.startTest();
        Contract contract1  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',
                                 recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','OSTA Program') ,
                                 Opportunity__c = opportunity.id,accountId = opportunity.AccountId,
                                          OSTA_Last_Upload_Date__c = null, status = 'Draft');
        insert contract1; 
        contract1.Status ='Activated';
        update contract1;
        Site__c site1 = new Site__c(Site_Code__c = '123',name = 'test',Display_Address__c = 'test',active__c = true,
                           Non_selectable__c = false, Is_OSTA_Information_Required__c= true);
        insert site1;
        Exam_Sites__c examSite1 = new Exam_Sites__c(Name = 'test',Site__c = site1.id,exam__c = exam.id,
                                                    Exam_Date__c = system.today() + 30);
        insert examSite1;
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite1.id,
                                                      Member__c = contact.id,cancelled__c = false);
        insert attempt;
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                       Opportunity__c = opportunity.id, Exam_Site__c = examSite1.id,
                                                       Member__c = contact.id,cancelled__c = false );
        insert attempt1;         
        MemberManagementExamSiteChange.ExamSiteChangeUpdate(site.id, attempt.id , contact.id);
        test.stopTest();
    }
    
    Public testMethod static void createOpportunity() { 
        testData();
        test.startTest();
        Site__c SiteCode = [Select id,Site_Code__c from Site__c];
        Opportunity opportunity1 = new Opportunity(amount = 123,Name = 'Exam Site Change Fee',
                                                   Eligible_for_Membership_Extension__c = false,
                                                   company__c = 'Payment', accountId = account.id,stageName = 'closed',
                                                   Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity1;
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                      Opportunity__c = opportunity1.id, Exam_Site__c = examSite.id,
                                                      Member__c = contact.id,cancelled__c = false );
        insert attempt;
        MemberManagementExamSiteChange.createOpportunity(attempt,'Exam Site Change Fee',SiteCode.Site_Code__c);
        test.stopTest();
    }
    
    Public testMethod static void createOpportunityLineItems() { 
        testData();
        test.startTest();
        Opportunity opportunity1 = new Opportunity(amount = 123,Name = 'Exam Site Change Fee',
                                                   Eligible_for_Membership_Extension__c = false,
                                      company__c = 'Payment', accountId = account.id,stageName = 'closed',
                                      Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity1;
        List<Exam_Attempt__c> lstExamAttempt = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                      Opportunity__c = opportunity1.id, Exam_Site__c = examSite.id,
                                                      Member__c = contact.id,cancelled__c = false );
        insert attempt;
        lstExamAttempt.add(attempt);
        Map<Id,Exam_Attempt__c> objExamAttempt = new Map<Id,Exam_Attempt__c>();
        for (Exam_Attempt__c e: lstExamAttempt){
            objExamAttempt.put(e.id,e);
        }
        Map<String,String> examsiteMap = new Map<String,String>();
        List<Exam_Sites__c> examSiteLst = [Select Id,Move_Exam_Registration_code__c,Exam_Date__c,Site_code__c from Exam_Sites__c];
        MemberManagementExamSiteChange.createOpportunityLineItems('CHLF','2008',opportunity.id,objExamAttempt);
        test.stopTest();
    } 
    
    Public testMethod static void ProductRefunds() { 
        testData();
        test.startTest();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,
                                                      Member__c = contact.id,cancelled__c = false );
        insert attempt;
        Set<id> examAttemptSet = new Set <Id>();
        for (Exam_Attempt__c e:[Select id from Exam_Attempt__c]){
            examAttemptSet.add(e.id);
        }
        Set<id> Oppid = new Set<id>();
        for (Opportunity opp:[Select id from Opportunity]){
            Oppid.add(opp.id);
        }
        set<String> prodCode = new Set<String>();
        list<Product_Refunds__c> productRefunds = new List<Product_Refunds__c>();
        for (Product2 prdC:[Select id,productCode from Product2]){
            prodCode.add(prdC.productCode);
        }
        for(Product2 prdC:[Select id,productCode from Product2]){
            productRefund = new Product_Refunds__c ();
            productRefund.Opportunity__c = opportunity.id ;
            productRefund.Product__c = prdC.id;
            productRefunds.add(productRefund);
        }
        insert productRefunds;
        system.debug('productRefunds=====>'+productRefunds.size());
         set<String> prodGl = new Set<String>();
        for (Product2 prdG:[Select id,productCode,GL_Code__c from Product2 where GL_Code__c = '2008']){
            prodGl.add(prdG.GL_Code__c);
        }
        string query = 'Select Id,OpportunityId,Unitprice,ProductCode,Product2.Gl_Code__c From OpportunityLineItem';
        MemberManagementExamSiteChange.ProductRefunds(examAttemptSet,Oppid,prodCode,prodGl);
        test.stopTest();
    } 
    
    Public testMethod static void getExamSitedata() {
        
    }
}