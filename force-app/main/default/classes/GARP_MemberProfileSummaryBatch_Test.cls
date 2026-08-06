@isTest
public class GARP_MemberProfileSummaryBatch_Test {

    
    static Account acc ;
    static Opportunity opp; 
    static ChargentOrders__Transaction__c chargentTrans;
    static TempAccount tempaccount;
    static Contact contact;
    static Exam_Attempt__c attempt;
    static Exam_Attempt__c attempt2;
    static Exam_Sites__c exmSite;
    static Site__c site;
    static Contract contract,contract1,Contract2;
    static Lead lead;
    static Exam_Group__c objExamGrp;
    static Exam__c exam;
    static Candidate_Requirement__c reqt;
    static Chapter_Meeting__c chapMeeting ;
    static Chapter_Meeting_Registration__c chapterMeetingReg;
    static ChargentOrders__Transaction__c payment1;
    static ChargentOrders__Transaction__c payment2;
    static Event_Registration__c event1;
    static Product_Refunds__c prf;
    static Member_Profile_Summary__c mps;
    static PricebookEntry standardPrice;
    static List<OpportunityLineItem> OpportunityLineItemList;
    
    static void testData(){ 
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'FRM1E',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        Product2 prod1 = new Product2(Name = 'fax',productCode = 'ENC1E',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        Product2 prod2 = new Product2(Name = 'Laptop X200',productCode = 'SCRCME',GL_Code__c = '4011',Family = 'Hardware',isActive = true);
        Product2 prod3 = new Product2(Name = 'Laptop X200',productCode = 'CBR',GL_Code__c = '6110',Family = 'Hardware',isActive = true);
        Product2 prod4 = new Product2(Name = 'Laptop X200',productCode = 'FCBR',GL_Code__c = '4000',Family = 'Hardware',isActive = true);
        Product2 prod5 = new Product2(Name = 'Laptop X200',productCode = 'MEMI',GL_Code__c = '4999',Family = 'Hardware',isActive = true, Order_Summary_Product_Line__c = 'Membership', Order_Summary_Product_Category__c = 'Membership', Order_Summary_Product_Name__c = 'Individual Membership');
        Product2 prod6 = new Product2(Name = 'Laptop X200',productCode = 'FRM1H',GL_Code__c = '4500',Family = 'Hardware',isActive = true);
        Product2 prod7 = new Product2(Name = 'Laptop X200',productCode = 'DCERTFRM',GL_Code__c = '4000',Family = 'Hardware',isActive = true);
        Product2 prod8 = new Product2(Name = 'Laptop X200',productCode = 'FRM1',GL_Code__c = '4020',Family = 'Hardware',isActive = true);
        insert new Product2[]{ prod,prod1,prod2,prod3,prod4,prod5,prod6,prod7,prod8};
        
        Id pricebookId = Test.getStandardPricebookId();
        standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod3.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod4.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod5.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice6 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod6.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice7 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod7.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice8 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod8.Id,UnitPrice = 10000, IsActive = true);
        insert new PricebookEntry[] { standardPrice,standardPrice1,standardPrice2,standardPrice3,standardPrice4,standardPrice5,standardPrice6,standardPrice7,standardPrice8 };
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        PricebookEntry customPrice1 = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod1.Id, UnitPrice = 12000, IsActive = true);
        insert new PricebookEntry[]{ customPrice,customPrice1 };
        
        acc = new Account();
        acc.Name = 'TEST ACCOUNT';
        INSERT acc;
        
        //Member_Profile_Summary__c = mps.id,
        Id Recordtypeid = RecordTypeHelper.GetRecordTypeId('contact','Member');
        contact = new Contact(lastname = 'test',AccountId = acc.id,email='test@test.com',Member_Profile_Last_Updated__c = System.today(),
                               Is_Test_Override__c = 'Is Not Test',Recordtypeid = Recordtypeid, KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        mps = new Member_Profile_Summary__c();
        mps.ContactId__c =contact.id;
        insert mps;
        
        Test.setCreatedDate(contact.Id, System.Today()-1);
        
        opp = new Opportunity(amount = 123,Name = 'Test',ia_crm__Intacct_Transaction__c = 'Salesforce - Sales Invoice',Billing_Email__c = 'test@test.garp.com',
                              Eligible_for_Membership_Extension__c = true,company__c = 'Payment',accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;


        Opportunity opp1 = new Opportunity(amount = 123,Name = 'Test',ia_crm__Intacct_Transaction__c = 'Salesforce - Sales Invoice',Billing_Email__c = 'test@test.garp.com',
                              Eligible_for_Membership_Extension__c = true,company__c = 'Payment',accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp1;
        
        String recordTypeEventConvention    = RecordTypeHelper.GetRecordTypeId('Event__c', 'Convention');
        Event__c parentEvent = new Event__c();
        parentEvent.RecordTypeId    = recordTypeEventConvention;
        parentEvent.Start_Date__c   = Date.today().addDays(58);
        parentEvent.End_Date__c     = Date.today().addDays(60);
        parentEvent.Name            = 'PARENT EVENT';
        INSERT parentEvent;
        
        Event_Sessions__c eventSessions = new Event_Sessions__c();
        eventSessions.Name = 'TEST EVENT SESSION';
        eventSessions.Event__c = parentEvent.Id;
        INSERT eventSessions;

        Event_Registration__c eventRegistrationForParentEvent = new Event_Registration__c();
        eventRegistrationForParentEvent.Contact__c = contact.Id;
        eventRegistrationForParentEvent.Opportunity__c = opp.Id;
        eventRegistrationForParentEvent.Event__c = parentEvent.Id;
        INSERT eventRegistrationForParentEvent;
        
        Id rtId = RecordTypeHelper.GetRecordTypeId('contract','FRM Program');
        Contract  = new Contract(Opportunity__c = opp.id, recordTypeId = rtId,AccountId = acc.id ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contract;
        
        contract.Status = 'completed';
        update contract;
        
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        reqt = new Candidate_Requirement__c(Candidate_Commitment__c=contract.Id, Exam__c = 'Job Experience',Name='Exam', Status__c='Initial', recordTypeId=ProgReqJobRecId);
        insert reqt;
                
        rtId = RecordTypeHelper.GetRecordTypeId('contract','ICBRR Program'); 
        Contract1  = new Contract(Opportunity__c = opp.id, recordTypeId = rtId,AccountId = acc.id ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contract1;

        contract1.Status = 'completed';
        update contract1;
        rtId = RecordTypeHelper.GetRecordTypeId('contract','SCR Program');                
        Contract2  = new Contract(Opportunity__c = opp.id, recordTypeId = rtId,AccountId = acc.id ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contract2;
        contract2.Status = 'Activated';
        update contract2;
        rtId = RecordTypeHelper.GetRecordTypeId('contract','FBR Program');                
        Contract Contract3  = new Contract(Opportunity__c = opp.id, recordTypeId = rtId,AccountId = acc.id ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert Contract3;
        Contract3.Status = 'Activated';
        update Contract3;
        
        
        rtId = RecordTypeHelper.GetRecordTypeId('contract','ERP Program');                
        Contract Contract4  = new Contract(Opportunity__c = opp.id, recordTypeId = rtId,AccountId = acc.id ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert Contract4;
        Contract4.Status = 'Activated';
        update Contract4;
        
        rtId = RecordTypeHelper.GetRecordTypeId('contract','Membership');                
        Contract Contract5  = new Contract(Opportunity__c = opp.id, recordTypeId = rtId,AccountId = acc.id ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert Contract5;
        Contract5.Status = 'Activated';
        update Contract5;
        
        OpportunityLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItemList.add(new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice.id));
        OpportunityLineItemList.add(new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice1.id));
        OpportunityLineItemList.add(new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice2.id));
        OpportunityLineItemList.add(new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice3.id, Description='credit card by fax'));
        OpportunityLineItemList.add(new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice4.id));
        OpportunityLineItemList.add(new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice5.id, Description='wire'));
        OpportunityLineItemList.add(new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice6.id, Description='wire handbook'));
        OpportunityLineItemList.add(new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice7.id, Description='wire handbook'));
        OpportunityLineItemList.add(new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice8.id, Description='wire handbook'));
        insert OpportunityLineItemList;
        
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE ProductCode = 'MEMI' LIMIT 1];
        
        OpportunityLineItem membershipOpportunityOli = new OpportunityLineItem( 
            OpportunityId       = opp1.Id,                          
            PricebookEntryId    = pbe.Id,
            Product2Id          = pbe.Product2Id,
            UnitPrice           = 0,
            Quantity            = 1,
            Description         = 'Individual Membership'
        );
        
        INSERT membershipOpportunityOli;
        
        opp1.StageName = 'Closed';
        update opp1;
                
        ChargentOrders__ChargentOrder__c order = [Select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: opp.id];
        
        payment1 = new ChargentOrders__Transaction__c(Opportunity__c = opp.id,ChargentOrders__Type__c= 'Charge',ChargentOrders__Order__c = order.id, ChargentOrders__Response_Status__c= 'Approved',ChargentOrders__Amount__c =60, ChargentOrders__Payment_Method__c='Credit Card');
        insert payment1;
                
        prf = new Product_Refunds__c (Status__c='Completed',Reason__c = 'Reason', Refund_amount__c =12,opportunity__c = opp.id,product__c = prod.id,Payment_Order_Transaction__c = payment1.id);
        insert prf;
        
        Webcast__c webcast = new Webcast__c();
        webcast.Name = 'TESTWEBCAST';
        webcast.Start_Date__c = Datetime.now().addDays(10);
        webcast.End_Date__c = Datetime.now().addDays(11);
        INSERT webcast;
        
        Webcast_Registration__c wr = new Webcast_Registration__c();
        wr.Contact__c = contact.Id;
        wr.Webcast__c = webcast.Id;
        INSERT wr;
        
        Chapter_Meeting__c  chapterMeeting = new Chapter_Meeting__c();
        chapterMeeting.Name = 'TESTCHAPTERMEETING';
        INSERT chapterMeeting;
        
        Chapter_Meeting_Registration__c chapterMeetingReg = new Chapter_Meeting_Registration__c();
        chapterMeetingReg.Chapter_Meeting__c = chapterMeeting.Id;
        chapterMeetingReg.Contact__c = contact.Id;
        INSERT chapterMeetingReg;
    }
    
    @isTest
    static void unitTest1(){
        
        testData();
        opp = [select id,accountId,(select id,ProductCode,Description,TotalPrice,product2.GL_Code__c from OpportunityLineItems) from Opportunity where accountId =: acc.id limit 1];
        
        Test.startTest();
        
        Database.executeBatch(new GARP_MemberProfileSummaryBatch('all',NULL,NULL,NULL,true,true));
        GARP_MemberProfileSummaryBatch.getOppTypeName(opp,new MAP<String, String>{'opp.id'=>'OpportunityLineItemList'},'fine');
        Test.stopTest();
        
    }
    
    @isTest
    static void unitTest2(){
        testData();
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;    
        insert objExamGrp;
        
        Exam_Administration__c examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = objExamGrp.id;
        examAdmin.Exam_Date__c = system.today().addDays(30);
        insert examAdmin;
 
        exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1'; 
        insert exam;
               
        exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        insert exmSite;
        
        Exam_Part__c examPart = new Exam_Part__c();
        examPart.Exam__c = exam.id;
        examPart.Exam_Administration__c = examAdmin.id;
        examPart.Exam_Date__c = system.today().adddays(30);
        examPart.Delivery_Method__c = 'CBT';        
        insert examPart;
        
        Exam_Attempt__c attempt = new Exam_Attempt__c(Opportunity__c = opp.id, Result__c = 'Pass',Member__c = contact.id, Exam_Part__c = examPart.Id, Quartile_1__c=2,Quartile_2__c=2,Quartile_3__c=2,Quartile_4__c=2,Quartile_5__c=2,Quartile_6__c=2,Quartile_7__c=2,Quartile_8__c=2,Exam_Site__c = exmSite.id,/*Member__c = contact.id,*/cancelled__c = false, Original_Exam_Site__c ='Site');
        insert attempt;
        
        Exam__c exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = Date.parse('05/19/2018');
        exam.exam__c = 'SCR'; 
        insert exam;
        
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        insert exmSite;

        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Opportunity__c = opp.id,Result__c = 'Pass', Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false, Original_Exam_Site__c ='Site');
        insert attempt2;
        
        Exam__c exam1 = new Exam__c();
        exam1.Exam_Group__c = objExamGrp.id;
        exam1.Exam_Date__c = Date.parse('05/19/2018');
        exam1.exam__c = 'ICBRR'; 
        insert exam1;
        
        Exam_Sites__c exmSite1 = new Exam_Sites__c(Site__c = site.id,exam__c = exam1.id);
        insert exmSite1;
        
        Exam_Attempt__c attempt3 = new Exam_Attempt__c(Opportunity__c = opp.id,Result__c = 'Pass', Exam_Site__c = exmSite1.id,Member__c = contact.id,cancelled__c = false, Original_Exam_Site__c ='Site');
        insert attempt3;
        
        
        Test.startTest();
        
        Database.executeBatch(new GARP_MemberProfileSummaryBatch('needed','2017-01-01',contact.id,'fine',true,true));
        GARP_MemberProfileSummaryBatch.getExamResult('Pass');
        GARP_MemberProfileSummaryBatch.getExamScore(attempt,'fine');
        GARP_MemberProfileSummaryBatch.getExamScore(attempt2,'fine');
        GARP_MemberProfileSummaryBatch.getExamScore(attempt3,'fine');
        GARP_MemberProfileSummaryBatch.getExamAdminDate(attempt);
        Test.stopTest();
        
    }
    
  /*  @isTest
    static void testProSumryManageBatch(){
        testData();
        
        mps = new Member_Profile_Summary__c();
        mps.ContactId__c ='contact.id';
        mps.FRR_Attempts__c =2;
        insert mps;
        
        Test.startTest();
        
        Database.executeBatch(new GARP_MemberProfileSummaryManageBatch('deleteall',NULL));
        Test.stopTest();
        
    } */
    
    @isTest
    static void testMemProfSumrySchr() {  
        
        testData();
        
        
        test.starttest();
        mps = new Member_Profile_Summary__c();
        mps.ContactId__c =contact.id;
        mps.FRR_Attempts__c =2;
        insert mps;
        contact.Member_Profile_Summary__c = mps.id;
        update contact;
        
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, new GARP_ScheduleMemberProfileSummaryBatch());
        test.stopTest();
    }
   
}