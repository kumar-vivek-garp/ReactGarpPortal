@isTest
public class InvoiceAsPDFController_test {
    
    static Account acc ;
    static Opportunity opp; 
    static Opportunity opp1;
    static Legacy_Transaction__c payment;
    static ChargentOrders__Transaction__c chargentTrans;
    static TempAccount tempaccount;
    static Contact contact;
    static Exam_Attempt__c attempt;
    static Exam_Attempt__c attempt2;
    static Exam_Sites__c exmSite;
  //  static Original_Exam_Site__c origSite;
    static Site__c site;
    static Contract contract;
    static Lead lead;
    static Exam_Group__c objExamGrp;
    static Exam__c exam;
    static Candidate_Requirement__c reqt;
    static Chapter_Meeting__c chapMeeting ;
    static Chapter_Meeting_Registration__c meetingReg;
    static ChargentOrders__Transaction__c payment1;
    static ChargentOrders__Transaction__c payment2;
    static Event_Registration__c event1;
    static Event__c event;
    static Event_Rate__c evtR;
    static Product_Refunds__c prf;
    
    
    static void testData(){ 
        
        Product2 prod = new Product2(Name = 'Laptop X200',productCode = 'AFREE',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        Product2 prod1 = new Product2(Name = 'fax',productCode = 'AFREE',GL_Code__c = '4999',Family = 'Hardware',isActive = true);
        Product2 prod2 = new Product2(Name = 'Laptop X200',productCode = 'FRM1S',GL_Code__c = '4011',Family = 'Hardware',isActive = true);
        Product2 prod3 = new Product2(Name = 'Laptop X200',productCode = 'PRFEE',GL_Code__c = '6110',Family = 'Hardware',isActive = true);
        Product2 prod4 = new Product2(Name = 'Laptop X200',productCode = 'CBRHI',GL_Code__c = '4000',Family = 'Hardware',isActive = true);
        Product2 prod5 = new Product2(Name = 'Laptop X200',productCode = 'CBRHI',Family = 'Hardware',isActive = true);
        insert new Product2[]{ prod,prod1,prod2,prod3,prod4 ,prod5};
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod3.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod4.Id,UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod5.Id,UnitPrice = 10000, IsActive = true);
        insert new PricebookEntry[] { standardPrice,standardPrice1,standardPrice2,standardPrice3,standardPrice4,standardPrice5 };
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        PricebookEntry customPrice1 = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod1.Id, UnitPrice = 12000, IsActive = true);
        insert new PricebookEntry[]{ customPrice,customPrice1 };
         
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
        Acc = new Account(Name = 'test');
        insert acc;
        
        contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        opp = new Opportunity(amount = 123,Name = 'Test',ia_crm__Intacct_Transaction__c = 'Salesforce - Refund',Eligible_for_Membership_Extension__c = true,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15, Alternate_Method_of_Payment__c = 'Wire Transfer');
        insert opp;
        
        opp1 = new Opportunity(amount = 123,Name = 'Test opp1',ia_crm__Intacct_Transaction__c = 'Salesforce - Refund',Eligible_for_Membership_Extension__c = true,company__c = 'Payment', accountId = acc.id,stageName = 'closed',Program__c = 'Print' ,closedate = system.today()+ 15, Alternate_Method_of_Payment__c = 'Wire Transfer');
        insert opp1;
        
        payment = new Legacy_Transaction__c(Payment_Method__c = 'Credit Card',Fee__c = 3,Opportunity__c = opp1.id,Type__c = 'Charge', Amount__c = 253,Response_Status__c= 'Approved');
        insert payment;
        
        Date sdate = Date.newInstance(2023, 12, 31);
        event = new Event__c();
        event.Name = 'Event Test';
        event.Status__c = 'Draft';
        event.Start_Date__c = sdate;
        //event.Start_Date__c = system.today() + 15;
        event.Event_Cancellation_Days__c = 3;
        // Event Name must match up with what is in the mock response.
        event.Name = 'GARP Risk Convention 2020';
        event.Title__c = 'GARP Risk Convention 2020';
        //event.Event_Cancellation_Date__c = system.today();
        INSERT event;
        
        event1 = new Event_Registration__c();
        event1.Event__c = event.Id;
        event1.Contact__c = contact.Id;
        event1.Professional_Designations__c = 'CFA;CPA;';
        event1.Status__c = 'Registered and Paid';
        event1.Opportunity__c = opp.id;
        event1.Event_Registration_Date__c =  Date.newInstance(2008, 12, 1);
        INSERT event1;
        
        evtR = new Event_Rate__c(Name ='Erly', Start_Date__c =  Date.newInstance(2008, 12, 1),Type__c = 'Early',Alternate_Payment_Deadline__c = Date.newInstance(2008, 12, 1),
                                 End_Date__c =  Date.newInstance(2008, 12, 1),Event__c=event.id);
        insert evtR; 
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contract; 
        Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = ContractRecordTypeInfo .get('FRM Program').getRecordTypeId();
        contract = new Contract(Opportunity__c = opp.id,AccountId = acc.id,recordTypeId = rtId);
        insert contract;
        
        Contract  = new Contract(Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contract;

        contract.Status = 'Activated';
        update contract;
        
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
        
        exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1'; 
        insert exam;
        
        exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        insert exmSite;
        
        attempt = new Exam_Attempt__c(Opportunity__c = opp.id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false, Original_Exam_Site__c ='Site');
        insert attempt;
        
        attempt2 = new Exam_Attempt__c(Opportunity__c = opp.id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false, Original_Exam_Site__c ='Site');
        insert attempt2;


        lead = new Lead(lastname = 'test',firstName = 'test' ,status = 'Open',email= 'test@test.com',company = acc.id);
        insert lead;
        
        reqt = new Candidate_Requirement__c();
        reqt.Candidate_Commitment__c = contract.id;
        reqt.name = 'FRM1 test';
        insert reqt;
        
        chapMeeting = new Chapter_Meeting__c();
        insert chapMeeting;
        
        meetingReg = new Chapter_Meeting_Registration__c();
        meetingReg.Opportunity__c = opp.id;
        meetingReg.Chapter_Meeting__c = chapMeeting.id;
        meetingReg.contact__c = contact.id;
        insert meetingReg;
        
            
        OpportunityLineItem lineItem1 = new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice.id);
        OpportunityLineItem lineItem2 = new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice1.id);
        OpportunityLineItem lineItem3 = new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice2.id);
        OpportunityLineItem lineItem4 = new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice3.id, Description='credit card by fax');
        OpportunityLineItem lineItem5 = new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice3.id, Description='wire');
        OpportunityLineItem lineItem6 = new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp.id,PricebookEntryId = standardPrice4.id);
        OpportunityLineItem lineItem7 = new OpportunityLineItem(TotalPrice = 20,quantity = 1,OpportunityId = opp1.id,PricebookEntryId = standardPrice5.id);
        insert new OpportunityLineItem[]{ lineItem1,lineItem2,lineItem3,lineItem4,lineItem5,lineItem6,lineItem7 };
        
        ChargentOrders__ChargentOrder__c order = [Select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: opp.id];
        
        payment1 = new ChargentOrders__Transaction__c(Opportunity__c = opp.id,ChargentOrders__Type__c= 'Charge',ChargentOrders__Order__c = order.id, ChargentOrders__Response_Status__c= 'Approved',ChargentOrders__Amount__c =60, ChargentOrders__Payment_Method__c='Credit Card');
        payment2 = new ChargentOrders__Transaction__c(Opportunity__c = opp.id,ChargentOrders__Type__c= 'Charge',ChargentOrders__Order__c = order.id, ChargentOrders__Response_Status__c= 'Approved',ChargentOrders__Amount__c =60, ChargentOrders__Payment_Method__c='Check');
        insert new ChargentOrders__Transaction__c[]{ payment1,payment2 };
        
        prf = new Product_Refunds__c (Status__c='Completed',Reason__c = 'Reason', Refund_amount__c =123,opportunity__c = opp.id,product__c = prod.id,Payment_Order_Transaction__c = payment1.id);
        insert prf;
         
    }
    
    @isTest
    static void unitTest_1(){
        testData();
        test.startTest();               
        ApexPages.currentPage().getParameters().put('id',opp.id);
        InvoiceAsPDFController invoice = new InvoiceAsPDFController();
        invoice.getNow();
        invoice.fetchData();
        evtR.Type__c = 'Standard';
        update evtR;
        invoice.fetchData();
        InvoiceAsPDFController.opportunitywrapper wrap = new InvoiceAsPDFController.opportunitywrapper(opp);
        //InvoiceAsPDFController.ExamAttemptWrapper ex = new InvoiceAsPDFController.ExamAttemptWrapper(attempt);
        InvoiceAsPDFController.PaymentWrapper pay = new InvoiceAsPDFController.PaymentWrapper(payment1, 'Reason', true);
        InvoiceAsPDFController.ChaptMeetingRegWrapper meetingRegWrpr = new InvoiceAsPDFController.ChaptMeetingRegWrapper(meetingReg);
        test.stopTest();
    }
    
    @isTest
    static void unitTest_2(){
        testData();
        opp.Institutional_Sale__c = true;
        opp.Inst_Sale_Service_End_Date__c=system.today()+ 15;
        opp.Acceptable_Inst_Sale_Products__c = false;
        update opp;
        test.startTest();               
        ApexPages.currentPage().getParameters().put('id',opp.id);
        InvoiceAsPDFController invoice = new InvoiceAsPDFController();
        invoice.fetchData();
        test.stopTest();
    }
    
    @isTest
    static void unitTest_3(){
        testData();
        
        test.startTest();               
        ApexPages.currentPage().getParameters().put('id',opp1.id);
        InvoiceAsPDFController invoice = new InvoiceAsPDFController();
        invoice.fetchData();
       
        test.stopTest();
    }
   
}