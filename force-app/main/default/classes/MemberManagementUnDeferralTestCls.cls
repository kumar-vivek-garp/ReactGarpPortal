/**
* Test Class for MemberManagementUnDeferralCls
**/
@isTest
public class MemberManagementUnDeferralTestCls {
    static Account account;
    static Contact contact;
    static Opportunity opportunity;
    static Site__c site;
    static Exam_Group__c objExamGrp;
    static Exam__c exam;
    static Exam__c exam1;
    static Exam__c exam2;
    static Exam_Sites__c examSite;
    static Exam_Sites__c examSite1;
    static Exam_Sites__c examSite2;
    static Contract contract;
    
    Public static void testData() {
        account = new Account(Name = 'test',BillingStreet = 'xxx',BillingCountry='USA',BillingState='xxx',BillingPostalCode='00123',BillingCity='Newport');
        insert account;
        
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Member'];
        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com',RecordTypeId = rt.Id);  
        insert contact; 
        
        opportunity = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = account.id,stageName = 'closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity; 
        
        contract  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',
                                 recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program') ,
                                 Opportunity__c = opportunity.id,accountId = opportunity.AccountId); 
        insert contract;
        
        site = new Site__c(Site_Code__c = '123',name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false, Is_OSTA_Information_Required__c= true);
        insert site; 
        
        objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = false; 
        Date dt3 = system.today();
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() + 30 ;    
        insert objExamGrp;
        
        exam1 = new Exam__c();
        exam1.Exam_Group__c = objExamGrp.id;
        exam1.Exam_Date__c = system.today() + 30;
        exam1.exam__c = 'ERP Part 1'; 
        insert exam1;
        
        exam2 = new Exam__c();
        exam2.Exam_Group__c = objExamGrp.id;
        exam2.Exam_Date__c = system.today() + 30;
        exam2.exam__c = 'FRM Part 2'; 
        insert exam2;
        
        exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1'; 
        insert exam;
        
        examSite = new Exam_Sites__c(Name = 'test',Site__c = site.id,exam__c = exam.id,Exam_Date__c = system.today() + 30);
        insert examSite;
        examSite1 = new Exam_Sites__c(Name = 'test',Site__c = site.id,exam__c = exam1.id,Exam_Date__c = system.today() + 30);
        insert examSite1;
        examSite2 = new Exam_Sites__c(Name = 'test',Site__c = site.id,exam__c = exam2.id,Exam_Date__c = system.today() + 30);
        insert examSite2;
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'FRM1',GL_Code__c = '4020',Family = 'Hardware');
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'Laptop X200',productCode = 'ENC',GL_Code__c = '4020',Family = 'Hardware' );
        insert prod1;
        
        Product2 prod2 = new Product2(Name = 'Laptop X200',productCode = 'CHLF',GL_Code__c = '2008',Family = 'Hardware',IsActive = true);
        insert prod2;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod.Id,UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod1.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice1;
        
        PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod2.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice2;
        
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opportunity.id,PricebookEntryId = customPrice2.id,Unitprice = 12000,Quantity = 1 );
        insert lineItem;
        OpportunityLineItem lineItem1 = new OpportunityLineItem(OpportunityId = opportunity.id,PricebookEntryId = customPrice.id,Unitprice = 12000,Quantity = 1);
        insert lineItem1;
    } 
    
    public testMethod static void GARPIdValidation(){
        testData();
        test.startTest();
        Contact con = [Select id, GARP_Member_ID__c  from Contact];
        MemberManagementUnDeferralCls.GARPIdValidation(con.GARP_Member_ID__c);
        MemberManagementUnDeferralCls.GARPIdValidation(null);
        test.stopTest();
    }
    
    Public testMethod static void getexamAttemptDetailsList() {
        testData();
        contact con = [Select id from contact LIMIT 1];
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,
                                                      Member__c = con.id,cancelled__c = false );
        insert attempt;
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                       Opportunity__c = opportunity.id, Exam_Site__c = examSite1.id,
                                                       Member__c = con.id,cancelled__c = false );
        insert attempt1;         
        Date ExamDate = system.today() + 30;
        List<Exam_Attempt__c> conts = [Select id from Exam_Attempt__c where Member__c =:con.id  and Opportunity_StageName__c ='closed' 
                                                 and result__C =:null And Cancelled__c = false And 
                                                 Exam_Date__c =:ExamDate + 30 order by Exam_Date__c];
        system.debug('conts=========>'+conts.size());
        test.startTest();
        MemberManagementUnDeferralCls.getexamAttemptDetailsList(con.id, system.today() + 30);
        test.stopTest();
    }
    
    Public testMethod static void getExamGroupsList() {
        testData();
        test.startTest();
        MemberManagementUnDeferralCls.getExamGroupsList();  
        test.stopTest();
    }
    
    Public testMethod static void updateDeferralDetail() {
        test.startTest();
        testData();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Pending',Result__c = null,Opportunity__c = opportunity.id,
                                                      Exam_Site__c = examSite2.id,Member__c = contact.id,cancelled__c = false,
                                                      Candidate_Commitment__c = contract.id);
        insert attempt;
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,Opportunity__c = opportunity.id,
                                                       Exam_Site__c = examSite.id,Member__c = contact.id,cancelled__c = false,
                                                      Candidate_Commitment__c = contract.id);
        insert attempt1;
        MemberManagementUnDeferralCls.updateDeferralDetail(attempt.Id, objExamGrp.id, 'NO', 'Yes', system.today()+30, system.today()+30);  
        MemberManagementUnDeferralCls.updateDeferralDetail(attempt.Id, objExamGrp.id, 'yes', 'Yes', system.today()+30, system.today()+30);  
        MemberManagementUnDeferralCls.updateDeferralDetail(attempt.Id, objExamGrp.id, 'yes', 'No', system.today()+30, system.today()+30);  
        MemberManagementUnDeferralCls.updateDeferralDetail(attempt.Id, objExamGrp.id, 'yes', 'No', system.today(), system.today()+30);  
		test.stopTest();
    }
    
    Public testMethod static void updateopportunityoli() {
        test.startTest();
        testData();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = 'Pass',Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,Member__c = contact.id,cancelled__c = false );
        insert attempt;
        MemberManagementUnDeferralCls.updateopportunityoli(opportunity.id,'yes','test');
        test.stopTest();
    }
    
    Public testMethod static void createOpportunityLineItems() {
        test.startTest();
        testData();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = 'Pass',Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,Member__c = contact.id,cancelled__c = false );
        insert attempt;
        MemberManagementUnDeferralCls.createOpportunityLineItems('FRM1', '4020', opportunity.id, attempt.Id);
        test.stopTest();
    }
    
    Public testMethod static void createTransactions() {
        test.startTest();
        testData();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = 'Pass',Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,Member__c = contact.id,cancelled__c = false );
        insert attempt;
        /*ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opportunity.id);
        insert order;*/
        MemberManagementUnDeferralCls.createTransactions(opportunity.id);
        test.stopTest();
    }
    
    Public testMethod static void ProductRefunds() {
        test.startTest();
        testData();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = 'Pass',Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,Member__c = contact.id,cancelled__c = false );
        insert attempt;      
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opportunity.id);
        insert order;  
        ChargentOrders__Transaction__c tran1 = new ChargentOrders__Transaction__c();
        tran1.Opportunity__c =opportunity.id;
        tran1.ChargentOrders__Response__c ='0';
        tran1.ChargentOrders__Response_Status__c ='Approved';
        tran1.ChargentOrders__Response_Message__c='Approved';
        tran1.ChargentOrders__Order__c = order.id;
        tran1.ChargentOrders__Type__c  ='charge';
        insert tran1;
        MemberManagementUnDeferralCls.ProductRefunds(attempt.id,opportunity.id,opportunity.id,'yes');
        test.stopTest();
    } 
}