@isTest
public class MemberManagementScreenTestClass {
    static Account account;
    static Contact contact;
    static Opportunity opportunity;
    static Site__c site;
    static Exam_Group__c objExamGrp;
    static Exam__c exam,exam1,exam2;
    static Exam_Sites__c examSite,examSite1,examSite2;
    static Contract contract;
    static Exam_Attempt__c examRegistration;
    static MemberManagementScreenClass.dataWrapper wrapper = new  MemberManagementScreenClass.dataWrapper();
    
    Public static void testData(){
        account = new Account(Name = 'test',BillingStreet = 'xxx',BillingCountry='USA',
                              BillingState='xxx',BillingPostalCode='00123',BillingCity='Newport');
        insert account;
        
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Member'];
        // RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Member'];
        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com',RecordTypeId = rt.Id);  
        insert contact; 
        
        opportunity = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                      company__c = 'Payment', accountId = account.id,stageName = 'closed',
                                      Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity; 
        
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opportunity.id);
        insert order;
        
        ChargentOrders__Transaction__c tran1 = new ChargentOrders__Transaction__c();
        tran1.Opportunity__c =opportunity.id;
        tran1.ChargentOrders__Order__c = order.id;
        tran1.ChargentOrders__Response__c ='0';
        tran1.ChargentOrders__Response_Status__c ='Approved';
        tran1.ChargentOrders__Response_Message__c='Approved';
        tran1.ChargentOrders__Type__c  ='charge';
        insert tran1;
        
        site = new Site__c(Site_Code__c = '123',name = 'test',Display_Address__c = 'test',active__c = true,
                           Non_selectable__c = false, Is_OSTA_Information_Required__c= true,Exam_Date__c = system.today());
        insert site; 
        
        objExamGrp = new Exam_Group__c();
        objExamGrp.Name = 'test';
        objExamGrp.Active__c = true; 
        objExamGrp.Exam_Date__c = system.today();
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() - 500 ;    
        insert objExamGrp;
        
        Exam_Group__c objExamGrp1 = new Exam_Group__c();
        objExamGrp1.Name = 'test';
        objExamGrp1.Active__c = false; 
        objExamGrp1.Exam_Date__c = system.today();
        objExamGrp1.Last_Date_For_Late_Registration__c = system.today() - 500 ;    
        insert objExamGrp1;
                
        exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1'; 
        insert exam;
        
        
        exam1 = new Exam__c();
        exam1.Exam_Group__c = objExamGrp1.id;
        exam1.Exam_Date__c = system.today() + 30;
        exam1.exam__c = 'FRM Part 2'; 
        insert exam1;
        
        exam2 = new Exam__c();
        exam2.Exam_Group__c = objExamGrp1.id;
        exam2.Exam_Date__c = system.today() + 30;
        exam2.exam__c = 'FRM Full Program'; 
        insert exam2;
        
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
    
    Public testMethod static void getnavigateToURL() {
        test.startTest();
        MemberManagementScreenClass.getnavigateToURL('Ups Edit', '');
        testData();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = 'Pass',
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,
                                                      Member__c = contact.id,cancelled__c = false );
        insert attempt;
        ChargentOrders__Transaction__c trans = [Select id from ChargentOrders__Transaction__c LIMIT 1];
        Opportunity opp =  [select id, Display_Invoice_Number__c from Opportunity LIMIT 1];
        system.debug('Display_Invoice_Number__c======>'+opp.Display_Invoice_Number__c);
        MemberManagementScreenClass.getnavigateToURL('Ups Edit', opp.Display_Invoice_Number__c);
        MemberManagementScreenClass.getnavigateToURL('Switch Exam', opp.Display_Invoice_Number__c);
        MemberManagementScreenClass.getnavigateToURL('Create Switch Exam Fee', opp.Display_Invoice_Number__c);
        MemberManagementScreenClass.getnavigateToURL('Scholarship refund', opp.Display_Invoice_Number__c);
        MemberManagementScreenClass.getnavigateToURL('Update Opportunity Billing Info', opp.Display_Invoice_Number__c);
        MemberManagementScreenClass.getnavigateToURL('Update Opportunity Price', opp.Display_Invoice_Number__c);
        MemberManagementScreenClass.getnavigateToURL('Refund Free Deferral', opp.Display_Invoice_Number__c); 
        MemberManagementScreenClass.createFreeDeferralOpp(opp,false);
        MemberManagementScreenClass.getnavigateToURL('xxxx', opp.Display_Invoice_Number__c);
        test.stopTest();
    }
    
    public testMethod static void GARPIdValidation(){
        testData();
        test.startTest();
        Contact con = [Select id, GARP_Member_ID__c  from Contact];
        MemberManagementScreenClass.GARPIdValidation(con.GARP_Member_ID__c);
        MemberManagementScreenClass.GARPIdValidation(null);
        MemberManagementScreenClass.GARPIdMergeRequest(con.GARP_Member_ID__c);
        Account acc1 = new Account();
        acc1.Name = 'test1';
        acc1.BillingState = 'teststate' ;
        acc1.BillingStreet = 'teststreet' ;
        acc1.BillingCountry = 'testcon' ;
        acc1.BillingPostalCode = 'testcode' ;
        acc1.BillingCity = 'testcity' ;
        insert acc1;
        
        contact con1= new Contact(lastname = 'Test',
                                  AccountId = acc1.id,email='test@test.com',
                                  KPI_ERP_Enrollment_Date__c = Date.newInstance(2021, 2, 17),
                                  Middle_Name_as_it_Appears_on_ID__c = 'test4' ,
 								  First_Name_as_it_Appears_on_ID__c = 'test6' ,
 								  Last_Name_as_it_Appears_on_ID__c = 'test7' ,
                                  recordtypeId = RecordTypeHelper.GetRecordTypeId('contact','Member') ,
 								  RA_Phone__c = '1234567890',GARP_Member_ID__c = '10515' );
        insert con1;
        
        MemberManagementScreenClass.GARPIdMergeRequest('10515');
        Contract contract1  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',
                                           recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program') ,
                                           Opportunity__c = opportunity.id,accountId = acc1.id ,
                                           Status = 'Draft');
        insert contract1;
        contract1.status = 'Activated';
        update contract1;
        MemberManagementScreenClass.GARPIdMergeRequest('10515');
        test.stopTest();
    }
    
    Public testMethod static void getExamTypeList() {
        testData();
        test.startTest();
        MemberManagementScreenClass.getExamTypeList();  
        test.stopTest();
    }
    
    Public testMethod static void getActiveSiteList() {
        testData();
        test.startTest();
        Exam_Group__c exmGrpId = [select id,Exam_Date__c from Exam_Group__c LIMIT 1]; 
        MemberManagementScreenClass.getActiveSiteList(exmGrpId.id,'test');  
        test.stopTest();
    }
    
    Public testMethod static void ExamRegistration() {
        testData();
        test.startTest();
        Exam_Group__c exmGrpId = [select id from Exam_Group__c LIMIT 1]; 
        Account acc = [Select id from Account LIMIT 1];
        Opportunity opportunity = [select id,AccountId from opportunity where AccountId =:acc.id];
        Contract contract1  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',
                                           recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program') ,
                                           Opportunity__c = opportunity.id,accountId = opportunity.AccountId,
                                           Status = 'Draft');
        insert contract1;
        contract1.status = 'Activated';
        update contract1;
        MemberManagementScreenClass.ExamRegistration(contact.id,exmGrpId.id,'test');
        
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Defered__c ='Approved',Result__c = 'Pass',
                                                       Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,
                                                       Member__c = contact.id,cancelled__c = false,
                                                       Candidate_Commitment__c = contract1.Id);
        insert attempt1;
        MemberManagementScreenClass.getFRMExams(contact.id, system.today());
        delete contract1;
        //MemberManagementScreenClass.ExamRegistration(contact.id,exmGrpId.id,'test');
        test.stopTest();
    }
    
    Public testMethod static void CreateExamRegistrations() {
        testData();
        test.startTest();
        Site__c site = [select id from Site__c LIMIT 1];
        Exam_Group__c exmGrpId = [select id from Exam_Group__c LIMIT 1];
        Account acc = [select id from Account LIMIT 1];
        Contact con = [select id from Contact LIMIT 1];
        Opportunity opp =  [select id, Display_Invoice_Number__c from Opportunity LIMIT 1];
        Contract contract1  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',
                                           recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','OSTA Program') ,
                                           Opportunity__c = opportunity.id,accountId = acc.Id,
                                           Status = 'Draft');
        insert contract1;
        contract1.Status = 'Activated';
        update contract1;
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,
                                                      Member__c = con.id,cancelled__c = false,
                                                      Candidate_Commitment__c = contract1.Id);
        insert attempt;
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Defered__c ='Approved',Result__c = null,
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite1.id,
                                                      Member__c = con.id,cancelled__c = false,
                                                      Candidate_Commitment__c = contract1.Id);
        insert attempt1;
        Site__c site1 = new Site__c(Site_Code__c = '123',name = 'test',Display_Address__c = 'test',
                                    active__c = true,Non_selectable__c = false, Is_OSTA_Information_Required__c= false,
                                    Exam_Date__c = system.today());
        insert site1; 
        
        
        Map<String,List<String>> examRegistredMap = new Map<String,List<String>>();
        Map<String,List<String>> examRegistredMap1 = new Map<String,List<String>>();
        List<String> data = new List<String>();
        for(Exam_Attempt__c ex:[Select id,Section__c  from Exam_Attempt__c]){
            data.add(ex.Section__c);
        }
        examRegistredMap.put('Not Registred FRM Program',data);
        examRegistredMap1.put('Registred FRM Program',data);
        
        MemberManagementScreenClass.CreateExamRegistrations(con.id,exmGrpId.id, site.Id,'Early','FRM Part 1',examRegistredMap);
        MemberManagementScreenClass.CreateExamRegistrations(con.id,exmGrpId.id, site.Id,'Early','FRM Part 2',examRegistredMap1);
        MemberManagementScreenClass.CreateExamRegistrations(con.id,exmGrpId.id, site1.Id,'Early','FRM Part 1 And Part 2',examRegistredMap1);
        MemberManagementScreenClass.CreateExamRegistrations(site1.id,exmGrpId.id, site1.Id,'Early','FRM Part 1 And Part 2',examRegistredMap1);
        MemberManagementScreenClass.OnclickMembershipSwitch(opp.Display_Invoice_Number__c);
        MemberManagementScreenClass.createProgram(wrapper,opportunity.id);
        test.stopTest();
    }
    
    Public testMethod static void getFRMExams(){
        testData();
        test.startTest();
        Account acc = [select id from Account LIMIT 1];
        Contact con = [select id from Contact LIMIT 1];
        Opportunity opp = [select id,stageName from opportunity limit 1];
        opp.stageName = 'closed';
        update opp;
       
        Contract contract2  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',
                                           recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program') ,
                                           Opportunity__c = opp.id,accountId = acc.Id,
                                           Status = 'Draft');
        insert contract2;
        contract2.Status = 'Activated';
        update contract2;
        
        examRegistration = new Exam_Attempt__c();
        examRegistration.Result__c = 'No-Show';
        examRegistration.Opportunity__c = opp.Id;
        examRegistration.Member__c = con.id;
        examRegistration.Candidate_Commitment__c = contract2.Id;
        examRegistration.Exam_Site__c = examSite2.Id;
        examRegistration.cancelled__c = false;
        INSERT examRegistration;
        
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Defered__c ='Approved',Result__c = 'No-Show',
                                                       Opportunity__c = opp.id, Exam_Site__c = examSite.id,
                                                       Member__c = con.id,cancelled__c = false,
                                                       Candidate_Commitment__c = contract2.Id);
        insert attempt1;
        
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Defered__c ='pending',Result__c = 'pass',
                                                       Opportunity__c = opp.id, Exam_Site__c = examSite1.id,
                                                       Member__c = con.id,cancelled__c = false,
                                                       Candidate_Commitment__c = contract2.Id);
        insert attempt2;
		
        MemberManagementScreenClass.getFRMExams(con.id, system.today());
        MemberManagementScreenClass.createProgram(wrapper,opportunity.id);
        test.stopTest();
    }
    
    Public testMethod static void createproductList(){
        testData();
        test.startTest();
        Contact conn = [Select id from Contact];
        Account acc = [Select id from Account];
        Exam_Attempt__c attempt = new Exam_Attempt__c(Defered__c ='Approved',Result__c = 'Pass',
                                                      Opportunity__c = opportunity.id, Exam_Site__c = examSite.id,
                                                      Member__c = contact.id,cancelled__c = false );
        insert attempt;
        
        wrapper.enrollment = true;
        wrapper.OSTA = true;
        wrapper.ChinaLocation = true;
        wrapper.payType = 'Early';
        wrapper.examPartOne = 'FRM Part 1';
        wrapper.examPartTwo = 'FRM Part 2';
        wrapper.ExamMonth = 'May'; 
        wrapper.conid = conn.id ;
        wrapper.accid = opportunity.AccountId ;
        MemberManagementScreenClass.createproductList(wrapper);
        wrapper.payType = 'Standard';     
        MemberManagementScreenClass.createproductList(wrapper);
        wrapper.ExamMonth = 'Nov';
        wrapper.payType = 'Late';  
        MemberManagementScreenClass.createproductList(wrapper);
        MemberManagementScreenClass.hasCustomPermission();
        test.stopTest();
    }
}