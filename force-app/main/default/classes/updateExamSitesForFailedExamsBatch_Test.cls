@isTest
public class updateExamSitesForFailedExamsBatch_Test {
    @testSetup
    public static void testSetup(){
        String StrDefered = 'Approved';       
        String oppstatus = 'closed';
        
        SiteMappingCodes__c cs = new SiteMappingCodes__c();
        cs.Name = 'China';
        cs.Old_Site_Code__c = '100';
        cs.New_Site_Code__c = '999';
        insert cs;
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        Opportunity opp = new Opportunity(Name = 'Test',Eligible_for_Membership_Extension__c = true,company__c = 'Payment', accountId = acc.id,stageName = oppstatus,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        ChargentOrders__ChargentOrder__c order = [Select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: opp.id];
        
        System.debug('order'+order);
        //Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,accountId = acc.id,stageName = oppstatus,Program__c = 'Print' ,closedate = system.today()+ 15);        
        //insert opp;
        
        List<Product2> prodlist =new List<Product2>();
        Product2 Prod1 = new Product2(Name = 'FRM 1 Early',Company__c = 'GARP',Product_ID__c = '2011SCRPE1011',productCode = 'FRM1E', Family = 'Hardware', isActive = true);
        prodlist.add(Prod1);
        Product2 Prod12 = new Product2(Name = 'FRM 2 Early',Company__c = 'GARP',Product_ID__c = '2011SCRPE1011',productCode = 'FRM2E', Family = 'Hardware', isActive = true);
        prodlist.add(Prod12);
        INSERT prodlist; 
        System.debug('prodid=='+prodlist[0].id);
        System.debug('code1=='+prodlist[0].Productcode);
  
        PricebookEntry PE1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodlist[0].Id, UnitPrice = 425.00, IsActive = true,UseStandardPrice = false);
        INSERT PE1;
        PricebookEntry PE12 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodlist[1].Id, UnitPrice = 425.00, IsActive = true,UseStandardPrice = false);
        INSERT PE12;
        
        System.debug('PE1=='+PE1.ProductCode);
       
        Pricebook2 customPB = new Pricebook2(Name = 'GARP 2015/2016', isActive=true);
        insert customPB;
        	
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = Prod1.Id, UnitPrice = 425.00, IsActive = true);
        INSERT customPrice;
        	
        PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id,Product2Id = Prod12.Id, UnitPrice = 425.00, IsActive = true);
        INSERT customPrice2;
        
        System.debug('customPrice=='+customPrice.product2.ProductCode);
        
        Contract Contract  = new Contract(Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        
        Candidate_Requirement__c reqt = new Candidate_Requirement__c();
        reqt.Candidate_Commitment__c = Contract.id;
        reqt.name = 'FRM Part 1';
        reqt.Exam__c = 'FRM Part I';
        insert reqt;
                
        OpportunityLineItem oppli1 = new OpportunityLineItem();
        oppli1.Quantity=5;
        oppli1.OpportunityId=opp.Id;
        oppli1.Product2Id = prod1.id;
        oppli1.PricebookEntryId = customPrice.Id;
        oppli1.TotalPrice = 10;
        oppli1.Product_ID__c = '2022SCRPE2022';
        INSERT oppli1;
        
        System.debug('opplist1=='+oppli1);
        System.debug('codeoli1=='+oppli1.PricebookEntry.product2.ProductCode);
        
        OpportunityLineItem oppli2 = new OpportunityLineItem();
        oppli2.Quantity=5;
        oppli2.OpportunityId=opp.Id;
        oppli2.product2id= Prod12.Id;
        oppli2.PriceBookEntryId = customPrice2.Id;
        oppli2.TotalPrice = 10;
        oppli2.Product_ID__c = '2022SCRPE2022';
        INSERT oppli2;
        
        System.debug('opplist2=='+oppli2);
        System.debug('codeoli2=='+oppli2.PricebookEntry.product2.ProductCode);
        
        Site__c site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site;
        
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true; 
        objExamGrp.Exam_Date__c = system.today().addDays(30);
        objExamGrp.Registration_Start_Date__c = system.today().addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today().addDays(1);
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today().addDays(9) ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today().addDays(10) ;
        insert objExamGrp;
        
        
        Exam_Group__c objExamGrp1 = new Exam_Group__c();
        objExamGrp1.Active__c = false; 
        objExamGrp1.Exam_Date__c = system.today().addDays(30);
        objExamGrp1.Registration_Start_Date__c = system.today().addDays(4);
        objExamGrp1.Last_Date_For_Early_Registration__c = system.today().addDays(1);
        objExamGrp1.Last_Date_For_Standard_Registration__c = system.today().addDays(9) ;
        objExamGrp1.Last_Date_For_Late_Registration__c = system.today().addDays(10) ;
        insert objExamGrp1;
        
        List<Exam__c> examList = new List<Exam__c>();
        Exam__c examFRM1 = new Exam__c();
        examFRM1.Exam_Group__c = objExamGrp.id;
        examFRM1.Exam_Date__c = system.today().addDays(30);
        examFRM1.exam__c = 'FRM Part 1';
        examList.add(examFRM1);
        
        Exam__c examFRM2 = new Exam__c();
        examFRM2.Exam_Group__c = objExamGrp1.id;
        examFRM2.Exam_Date__c = system.today().addDays(30);
        examFRM2.exam__c = 'FRM Part 2'; 
        examList.add(examFRM2);
        
        Exam__c examERP1 = new Exam__c();
        examERP1.Exam_Group__c = objExamGrp.id;
        examERP1.Exam_Date__c = system.today().addDays(30);
        examERP1.exam__c = 'ERP Exam Part I'; 
        examList.add(examERP1);
        
        Exam__c examERP2 = new Exam__c();
        examERP2.Exam_Group__c = objExamGrp.id;
        examERP2.Exam_Date__c = system.today().addDays(30);
        examERP2.exam__c = 'ERP Exam Part II'; 
        examList.add(examERP2);
        insert examList;
        
        Exam_Administration__c examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = objExamGrp.id;
        examAdmin.Exam_Date__c = system.today().addDays(30);
        insert examAdmin;
        
        List<Exam_Part__c> examPartList = new List<Exam_Part__c>();
        Exam_Part__c examPart = new Exam_Part__c();
        examPart.Exam__c = examFRM1.id;
        examPart.Exam_Administration__c = examAdmin.id;
        examPart.Exam_Date__c = system.today().adddays(30);
        examPart.Delivery_Method__c = 'CBT';
        examPartList.add(examPart);
        
        Exam_Part__c examPart2 = new Exam_Part__c();
        examPart2.Exam__c = examFRM2.id;
        examPart2.Exam_Administration__c = examAdmin.id;
        examPart2.Exam_Date__c = system.today().adddays(30);
        examPart2.Delivery_Method__c = 'CBT';
        examPartList.add(examPart2);
        
        Exam_Part__c examPart4 = new Exam_Part__c();
        examPart4.Exam__c = examERP1.id;
        examPart4.Exam_Administration__c = examAdmin.id;
        examPart4.Exam_Date__c = system.today().adddays(30);
        examPart4.Delivery_Method__c = 'CBT';
        examPartList.add(examPart4);
        
        Exam_Part__c examPart5 = new Exam_Part__c();
        examPart5.Exam__c = examERP2.id;
        examPart5.Exam_Administration__c = examAdmin.id;
        examPart5.Exam_Date__c = system.today().adddays(30);
        examPart5.Delivery_Method__c = 'CBT';
        examPartList.add(examPart5);
        insert examPartList;
        
        List<Exam_Sites__c> siteList = new List<Exam_Sites__c>();
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM1.id);
        siteList.add(exmSite);
        Exam_Sites__c exmSite2 = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM2.id);
        siteList.add(exmSite2);
        Exam_Sites__c exmSite4 = new Exam_Sites__c(Site__c = site.id,exam__c = examERP1.id);
        siteList.add(exmSite4);
        Exam_Sites__c exmSite5 = new Exam_Sites__c(Site__c = site.id,exam__c = examERP2.id);
        siteList.add(exmSite5);
        insert siteList;
        
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Opportunity__c = opp.id,Candidate_Commitment__c = Contract.id,Exam_Administration__c = examAdmin.Id,Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false,Result__c = 'Fail' );
        examAttemptList.add(attempt);
        
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Defered__c = StrDefered,Opportunity__c = opp.id,Candidate_Commitment__c = Contract.id,Exam_Administration__c = examAdmin.Id,Exam_Site__c = exmSite2.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt2);
        
        Exam_Attempt__c attempt3 = new Exam_Attempt__c(Defered__c = StrDefered,Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart4.Id, Exam_Site__c = exmSite4.id,Member__c = contact.id,cancelled__c = false,Result__c = 'Fail');
        examAttemptList.add(attempt3);
        
        Exam_Attempt__c attempt4 = new Exam_Attempt__c(Defered__c = StrDefered,Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart5.Id, Exam_Site__c = exmSite5.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt4);
        
        insert examAttemptList;
        
        
        ia_crm__Class__c cls = new ia_crm__Class__c(
            ia_crm__Class_ID__c = 'TEstclass',
            ia_crm__Status__c= True,
            Name = 'Test');
        insert cls; 
    }
    
    @isTest
    public static void testFRM1(){
        test.startTest();
        //Id batchInstanceId = Database.executeBatch(new updateExamSitesForFailedExamsBatch('FRM Part 1','No Use'),1);
        Id batchInstanceId1 = Database.executeBatch(new updateExamSitesForFailedExamsBatch('FRM Part 1'),1);
        
        test.stopTest();
    }
    @isTest
    public static void testERP1(){
        test.startTest();
        
        Exam_Attempt__c ea = [Select Id,Exam_Site__c from Exam_Attempt__c where Exam_Site__r.Exam__r.Exam__c = 'ERP Exam Part I' AND Result__c = 'Fail'];
        Id batchInstanceId = Database.executeBatch(new updateExamSitesForFailedExamsBatch('ERP Exam Part I',ea.Id),1);
        Id batchInstanceId1 = Database.executeBatch(new updateExamSitesForFailedExamsBatch('ERP Exam Part I'),1);
        
        test.stopTest();
    }
    
     @isTest
    public static void testFRMCancel1(){
        test.startTest(); 
        Id batchInstanceId1 = Database.executeBatch(new updateExamSitesForFailedExamsBatch('FRM Part 1',true),1);
        
        test.stopTest();
    }
    @isTest
    public static void testFRMCancel2(){
        test.startTest();
        
        Exam_Attempt__c ea = [Select Id,Exam_Site__c from Exam_Attempt__c where Exam_Site__r.Exam__r.Exam__c = 'FRM Part 1' AND Result__c = 'Fail'];
        Id batchInstanceId = Database.executeBatch(new updateExamSitesForFailedExamsBatch('FRM Part 1',ea.Id,true),1); 
        
        test.stopTest();
    }

}