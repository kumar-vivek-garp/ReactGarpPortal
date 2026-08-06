@isTest
public class GARP_MemberProfile_test {
    
    Static Account acct;
    Static Contact cont;
    Static Country_Code__c cc;
    Static Province__c pv;
    Static String RecordTypeId;
    Static Product2 prod;
    Static PricebookEntry pbe;
    Static Institution__c inst;
    static Opportunity opp; 
    static ChargentOrders__Transaction__c chargentTrans;
    public static MAP<String,Contract> mapContracts = new MAP<String,Contract>();
    
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
    Static List<OpportunityLineItem> OppLineItems;
    static Event_Registration__c event1;
    static Product_Refunds__c prf;
    static Member_Profile_Summary__c mps;
    static Event_Sessions__c eventSessions;
    static Event_Registration__c eventRegistrationForParentEvent;
    Static Webcast_Registration__c wr;	
    Static Form_Data__c formdata;
    Static Chapter_Member__c cm2;
    Static Chapter_Member__c cm1;
    Static List<Contract> conlist = new List<Contract>();
    Static ChargentOrders__ChargentOrder__c order;
    
    Public static void testSetup() {
        acct = new Account(
            Name = 'TestAccount',
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Account','Individual'),
            CurrencyIsoCode  = 'USD'
        );
        insert acct;
        
        Id Recordtypeid = RecordTypeHelper.GetRecordTypeId('contact','Member');
        cont = new Contact(AccountId = acct.id, FirstName='Cont', LastName='Last', Email='a@a.com',Member_Profile_Last_Updated__c = System.today(),
                           Is_Test_Override__c = 'Is Not Test',Recordtypeid = Recordtypeid, KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert cont;
        
        opp = new Opportunity(amount = 1230.0,Name = 'Test',ia_crm__Intacct_Transaction__c = 'Salesforce - Refund',Billing_Email__c = 'test@test.garp.com',
                              Eligible_for_Membership_Extension__c = true,company__c = 'Payment',accountId = cont.AccountId,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
                
        order = [Select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: opp.id];
        
        List<Product2> ProdList = new List<Product2>();
        ProdList.add(GARP_TestFactory.createProduct('FRM1E_name', 'FRM1E', '4999'));
        ProdList.add(GARP_TestFactory.createProduct('SCRCME_name', 'SCRCME', '4999'));
        ProdList.add(GARP_TestFactory.createProduct('CBR_name', 'CBR', '4011'));
        ProdList.add(GARP_TestFactory.createProduct('FBRNM_name', 'FBRNM', '4004'));
        ProdList.add(GARP_TestFactory.createProduct('ENC1E_name', 'ENC1E', '4004'));
        ProdList.add(GARP_TestFactory.createProduct('DCERTFRM_name', 'DCERTFRM', '4004'));
        ProdList.add(GARP_TestFactory.createProduct('FRM1_name', 'FRM1', '4020'));
        ProdList.add(GARP_TestFactory.createProduct('MEMF_name', 'MEMF', '4004'));
        ProdList.add(GARP_TestFactory.createProduct('FRM1H_name', 'FRM1H', '4999'));      
        insert ProdList;
        
        ProdList[0].Order_summary_Is_Scholarship__c = True;
        ProdList[1].Order_Summary_Is_B2B__c = True;
        ProdList[2].Order_Summary_Product_Line__c = 'Membership';
        ProdList[3].Order_Summary_Product_Category__c = 'Study Material';
        ProdList[2].Order_Summary_Product_Name__c = 'Affiliate Membership';
        //ProdList[6].Order_Summary_Product_Name__c = 'Student Membership';
        ProdList[5].Order_Summary_Product_Line__c = 'GARP';
        Update ProdList;        
        
        List<PricebookEntry> pbeLIst = new List<PricebookEntry>();
        pbeLIst.add(GARP_TestFactory.createPriceBook(ProdList[0].id, 6.5));
        pbeLIst.add(GARP_TestFactory.createPriceBook(ProdList[1].id, 6.5)) ;
        pbeLIst.add(GARP_TestFactory.createPriceBook(ProdList[2].id, 6.5));
        pbeLIst.add(GARP_TestFactory.createPriceBook(ProdList[3].id, 6.5));
        pbeLIst.add(GARP_TestFactory.createPriceBook(ProdList[4].id, 6.5));
        pbeLIst.add(GARP_TestFactory.createPriceBook(ProdList[5].id, 6.5));
        pbeLIst.add(GARP_TestFactory.createPriceBook(ProdList[6].id, 6.5));
        pbeLIst.add(GARP_TestFactory.createPriceBook(ProdList[7].id, 6.5));
        pbeLIst.add(GARP_TestFactory.createPriceBook(ProdList[8].id, 6.5));
        insert pbeLIst;
        
        OppLineItems = new List<OpportunityLineItem>();
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(opp.id,'FRM1E'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(opp.id,'SCRCME'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(opp.id,'CBR'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(opp.id,'FBRNM'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(opp.id,'ENC1E'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(opp.id,'DCERTFRM'));       
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(opp.id,'FRM1'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(opp.id,'MEMF'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(opp.id,'FRM1H'));
        insert  OppLineItems;
                
        conlist = GARP_TestFactory.createContractList(9,acct.id,opp.id,cont.id);
        
        GARP_TestFactory.createCountryCodes();
        
        String recordTypeEventConvention    = RecordTypeHelper.GetRecordTypeId('Event__c', 'Convention');
        Event__c parentEvent = new Event__c();
        parentEvent.RecordTypeId    = recordTypeEventConvention;
        parentEvent.Start_Date__c   = Date.today().addDays(58);
        parentEvent.End_Date__c     = Date.today().addDays(60);
        parentEvent.Name            = 'PARENT EVENT';
        INSERT parentEvent;
        
        
        RecordTypeId = RecordTypeHelper.GetRecordTypeId('Institution__c','Organization');
        
        Institution__c inst = new Institution__c (
            Institution_Name__c='Compy',
            RecordTypeId=RecordTypeId
        );
        insert inst;
        
        Chapter__c chapter = new Chapter__c(
            Name='Chapter'
        );
        insert chapter;
        
        cm1 = new Chapter_Member__c(
            Contact__c = cont.Id,
            Chapter__c = chapter.Id,
            IsPrimary__c = True,
            Committee_Member__c = True,
            Can_Manage_Attendance__c = True,
            Can_Request_Meetings__c = True,
            Can_View_Resources__c = True
        );
        insert cm1;
        
        
        cm2 = new Chapter_Member__c(
            Contact__c = cont.Id,
            Chapter__c = chapter.Id,
            IsSecondary__c = True,
            Committee_Member__c = True,
            Can_Manage_Attendance__c = True,
            Can_Request_Meetings__c = True,
            Can_View_Resources__c = True
        );
        insert cm2;
        
        
        Chapter_Meeting__c  chapterMeeting = new Chapter_Meeting__c();
        chapterMeeting.Name = 'TESTCHAPTERMEETING';
        INSERT chapterMeeting;
        
        
        Webcast__c webcast = [Select id from Webcast__c where id =: GARP_TestFactory.createWebcast() limit 1];
        
        
        GARP_TestFactory.Chp_Evt_Web_Registrations(chapterMeeting.id,parentEvent.Id,webcast.Id,cont.Id);
        
        wr = new Webcast_Registration__c();
        wr = [select id,Contact__c,Webcast__c from Webcast_Registration__c limit 1];
        
        chapterMeetingReg = new Chapter_Meeting_Registration__c();
        chapterMeetingReg = [select id,Contact__c,Chapter_Meeting__c from Chapter_Meeting_Registration__c limit 1];
        
        eventRegistrationForParentEvent = new Event_Registration__c();
        eventRegistrationForParentEvent = [select id,Contact__c,Event__c from Event_Registration__c limit 1];
        
        Form__c form = GARP_TestFactory.createForm('form');
        
        Lead lead = new Lead();
        
        lead.FirstName = 'TEST';
        lead.LastName = 'LASTNAME';
        lead.Email = 'test@test.com';
        lead.IsConverted = FALSE;
        lead.Company = 'TEST';
        
        INSERT lead;
        
        formdata = GARP_TestFactory.createFormData(form,lead);
        formdata.Contact__c = cont.id;
        formdata.OpportunityId__c = opp.id;
        update formdata;
    }
    
    @isTest
    static void testGetProfile() {
        
        testSetup();
        
        conlist[0].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        conlist[0].Status = 'activated ( auto-renew )';
        conlist[1].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ERP_Program');
        conlist[1].Status = 'Completed';
        conlist[2].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
        conlist[2].Status = 'Completed';
        conlist[3].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ICBRR_Program');
        conlist[3].Status = 'Completed';
        conlist[4].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FBR_Program');
        conlist[4].Status = 'Completed';
        conlist[5].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        conlist[5].Status = 'Activated';
        conlist[6].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','CPE');
        conlist[6].Status = 'Activated';
        conlist[7].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_Net');
        conlist[7].Status = 'Activated';
        conlist[8].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        conlist[8].Status = 'Completed';
        update conlist; 
        
        mapContracts.put('FRM_Program',conlist[0]);
        mapContracts.put('ERP_Program',conlist[1]);
        mapContracts.put('SCR_Program',conlist[2]);
        mapContracts.put('ICBRR_Program',conlist[3]);
        mapContracts.put('FBR_Program',conlist[4]);
        mapContracts.put('Membership',conlist[5]);
        mapContracts.put('CPE',conlist[6]);
        mapContracts.put('Risk_Net',conlist[7]);
        mapContracts.put('FRM_Program',conlist[8]);
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        List<Candidate_Requirement__c> CanReqList = new List<Candidate_Requirement__c>();
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[0].Id, Exam__c = 'FRM Part I',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[8].Id, Exam__c = 'FRM Part II',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[0].Id, Exam__c = 'FRM Full',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[0].Id, Exam__c = 'Job Experience',Name='Exam', Status__c='Active', recordTypeId=ProgReqJobRecId));
        
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'ERP Part I',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'ERP Part II',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[6].Id, Exam__c = 'ERP Full',Name='Exam', Status__c='Active', recordTypeId=ProgReqCPEId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'Job Experience',Name='Exam', Status__c='Active', recordTypeId=ProgReqJobRecId));
        insert CanReqList;
        
        
        //ExamRegistrationTestDataFactory.setupActivePricebook();
        
        Test.startTest();
        
        //GARP_BC_MemberProfile.getMemberProfileInfo(cont.id);
        
        GARP_BC_MemberProfile.memberDirectorySettingsInfo directorySettings = GARP_BC_MemberProfile.getDirectorySettingsInfo(cont.id); 
        GARP_BC_MemberProfile.setDirectorySettingsInfo(cont.Id,directorySettings.memberDirectorySettings);
        
        GARP_BC_MemberProfile.demographicsContactInfo demographicsContactInfo = new GARP_BC_MemberProfile.demographicsContactInfo();
        demographicsContactInfo = GARP_BC_MemberProfile.getDemographicsContactInfo(cont);
        GARP_BC_MemberProfile.setDemographicsContactInfo(cont,demographicsContactInfo);
        GARP_BC_MemberProfile.memberDirectorySettingsInfo memberDirectorySettingsInfo = new GARP_BC_MemberProfile.memberDirectorySettingsInfo();
        memberDirectorySettingsInfo = GARP_BC_MemberProfile.getMemberDirectorySettingsInfo(cont,mapContracts);
        GARP_BC_MemberProfile.memberDirectorySettings memberDirectorySettings = new GARP_BC_MemberProfile.memberDirectorySettings();
        memberDirectorySettings = memberDirectorySettingsInfo.memberDirectorySettings;
        GARP_BC_MemberProfile.setMemberDirectorySettingsInfo(cont,memberDirectorySettings);
                
        Test.stopTest();
    }

    
    @isTest
    public static void testProfileAuth(){
     
        //setup();        
        
        GARP_TestFactory.createCountryCodes();
        
        // Setup Products
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});

        // Create User
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX');
        User user = GARP_TestFactory.createAffiliateContact();
        System.debug('!!user:' + user);
        
        List<Contact> lstCont = [select id, FirstName, LastName, GARP_Member_ID__c, Photo_URL__c, Email, HomePhone, Phone, MobilePhone, Mobile_Phone_Code__c,
                                Mailing_Address_Company__c, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingStreet, Account.Billing_Address_Company__c,
                                Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingStreet
                                FROM Contact where id =: user.ContactId];
        
        System.debug('!!lstCont:' + lstCont);
        Contact contact = lstCont[0];
        
        Test.startTest();
        
        System.runAs(user) {
            GARP_BC_MemberProfile.personalInfo personalInfo = GARP_BC_MemberProfile.getPersonalInfo(contact);
            GARP_BC_MemberProfile.setPersonalInfo(contact, personalInfo);        
            GARP_Common.returnInfo ret = GARP_BC_MemberProfile.uploadMemberPhoto(contact, NULL, 'aaaaaaaaaaaaaaaaa', 'myphoto.jpg');
            GARP_BC_MemberProfile.setMemberPhoto(contact, user.Id, ret.msg); 
            GARP_BC_MemberProfile.removeMemberPhoto(contact); 
            
            GARP_BC_MemberProfile.expertiseInfo expertiseInfo = GARP_BC_MemberProfile.getExpertiseInfo(contact);
            GARP_BC_MemberProfile.setExpertiseInfo(contact, expertiseInfo);
            
            GARP_BC_MemberProfile.submitCustomerCase(contact, user.Id, 'test', 'this is a test');

        }
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testProfSummary(){
        testSetup();
        
        Id Recordtypeid = RecordTypeHelper.GetRecordTypeId('contact','Member');
        
        eventRegistrationForParentEvent.Contact__c = cont.Id;
        eventRegistrationForParentEvent.Opportunity__c = opp.id;
        update eventRegistrationForParentEvent;
        
        chapterMeetingReg.Contact__c = cont.Id;
        update chapterMeetingReg;
        wr.Contact__c = cont.Id;
        update wr;
        
        formdata.Contact__c = cont.id;
        update formdata;
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        Test.startTest();
        
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
        List<Exam_Attempt__c> examattList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Opportunity__c = opp.id, Result__c = 'Pass', Exam_Part__c = examPart.Id, Quartile_1__c=2,Quartile_2__c=2,Quartile_3__c=2,Quartile_4__c=2,Quartile_5__c=2,Quartile_6__c=2,Quartile_7__c=2,Quartile_8__c=2,Exam_Site__c = exmSite.id,Member__c = cont.id,cancelled__c = false, Original_Exam_Site__c ='Site');
        examattList.add(attempt);
        //insert attempt;
        
        Exam__c exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = Date.parse('05/19/2018');
        exam.exam__c = 'RiskAI'; 
        insert exam;
        
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        insert exmSite;
        
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Opportunity__c = opp.id,Result__c = 'Pass', Exam_Site__c = exmSite.id,Member__c = cont.id,cancelled__c = false, Original_Exam_Site__c ='Site');
        examattList.add(attempt2);
        //insert attempt2;
        
        /*Exam__c exam1 = new Exam__c();
        exam1.Exam_Group__c = objExamGrp.id;
        exam1.Exam_Date__c = Date.parse('05/19/2018');
        exam1.exam__c = 'RiskAI'; 
        insert exam1;
        
        Exam_Sites__c exmSite1 = new Exam_Sites__c(Site__c = site.id,exam__c = exam1.id);
        insert exmSite1;
        
        Exam_Attempt__c attempt3 = new Exam_Attempt__c(Opportunity__c = opp.id,Result__c = 'Pass', Exam_Site__c = exmSite1.id,Member__c = cont.id,cancelled__c = false, Original_Exam_Site__c ='Site');
        examattList.add(attempt3);*/
        //insert attempt3;
        insert  examattList;
        
        //List<Contract> conlist = [select id,Account.Name,RecordTypeID,CustomerSignedId,Status from Contract limit 9];
        //System.debug('conlist'+conlist);
        conlist[0].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        conlist[0].Status = 'activated';
        conlist[1].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ERP_Program');
        conlist[1].Status = 'Completed';
        conlist[2].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
        conlist[2].Status = 'Completed';
        conlist[3].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ICBRR_Program');
        conlist[3].Status = 'Completed';
        conlist[4].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FBR_Program');
        conlist[4].Status = 'Completed';
        conlist[5].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        conlist[5].Status = 'Activated';
        conlist[6].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','CPE');
        conlist[6].Status = 'Activated';
        conlist[7].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_Net');
        conlist[7].Status = 'Activated';
        conlist[8].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        conlist[8].Status = 'Completed';
        update conlist; 
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        List<Candidate_Requirement__c> CanReqList = new List<Candidate_Requirement__c>();
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[0].Id, Exam__c = 'FRM Part I',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[8].Id, Exam__c = 'FRM Part II',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[0].Id, Exam__c = 'FRM Full',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[0].Id, Exam__c = 'Job Experience',Name='Exam', Status__c='Active', recordTypeId=ProgReqJobRecId));
        
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'ERP Part I',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'ERP Part II',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'ERP Full',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'Job Experience',Name='Exam', Status__c='Active', recordTypeId=ProgReqJobRecId));
        insert CanReqList;
        
        payment1 = new ChargentOrders__Transaction__c(Opportunity__c = opp.id,ChargentOrders__Type__c= 'Charge',ChargentOrders__Order__c = order.id, 
        											  ChargentOrders__Response_Status__c= 'Approved',ChargentOrders__Amount__c =60,ChargentOrders__Payment_Method__c='Credit Card');
        insert payment1;
        
        prod = GARP_TestFactory.createProduct('MEMI_name', 'MEMI', '4040'); 
        insert prod;
        pbe = GARP_TestFactory.createPriceBook(prod.id, 6.5) ;      
        insert pbe;
        
        GARP_BC_MemberProfile.updateMemberProfileSummary(cont.id);
        
        prf = new Product_Refunds__c (Status__c='Completed',Reason__c = 'Reason', Refund_amount__c =12,opportunity__c = opp.id,product__c = prod.id,Payment_Order_Transaction__c = payment1.id);
        insert prf;
        
        GARP_MS_MemberProfile.getMemberProfileForEdit(cont.Id);
        
        GARP_MS_MemberProfile.memberProfileUpdate profileUpdate = new GARP_MS_MemberProfile.memberProfileUpdate();
        profileUpdate.profileParts = new GARP_MS_MemberProfile.profileParts();
        profileUpdate.ContactId = cont.Id;
        profileUpdate.AccountId = acct.id;
        
        profileUpdate.profileParts.NameEmail = True;
        profileUpdate.FirstName = 'first';
        profileUpdate.LastName = 'last';
        
        GARP_BC_MemberProfile.updateMemberProfileSummary(cont.id);
        GARP_BC_MemberProfile.updateMemberProfileSummarys(new List<String>{cont.id});
        
        mps = new Member_Profile_Summary__c();
        mps.ContactId__c = cont.id;
        mps.FRR_Attempts__c =2;
        insert mps;
        cont.Member_Profile_Summary__c = mps.id;
        update cont;
        
        GARP_BC_MemberProfile.updateMemberProfileSummary(cont.id);
        
        GARP_MC_MemberProfile.setMemberProfile(profileUpdate);
        GARP_BC_Authentication.isAuthenticated();
        
        GARP_MC_MemberProfile.setMemberEmail(profileUpdate);
        
        GARP_BC_MemberProfile.updateMemberProfileSummarys(new List<String>{cont.id});
        
        Opportunity oppty = [SELECT Id,StageName FROM Opportunity WHERE StageName = 'Closed' LIMIT 1];
        oppty.Amount = 123;
        update oppty;
        GARP_BC_MemberProfile.updateMemberProfileSummarys(new List<String>{cont.id});
        
        /*exam.exam__c = 'SCR'; 
        update exam;
        exmSite.exam__c = exam.id;
        update exmSite;
        attempt2.Exam_Site__c = exmsite.id;
        update attempt2;
        GARP_BC_MemberProfile.updateMemberProfileSummary(cont.id);*/
        
        /*Member_Profile_Summary__c mp = new Member_Profile_Summary__c();
        mp.ContactId__c = cont.id;
        mp.FRR_Attempts__c =2;
        insert mp;
        cont.Member_Profile_Summary__c = mp.id;
        update cont;
        
        exam.exam__c = 'FRM Part 2';
        update exam;
        exmSite.exam__c = exam.id;
        update exmSite;
        attempt.Exam_Site__c = exmsite.id;
       	update attempt;
        
        GARP_BC_MemberProfile.updateMemberProfileSummary(cont.id);*/
       
        Test.stopTest();
        
    }
    
    @isTest
    static void testProfSummary2(){
        testSetup();
        
        opportunity getopp = [Select amount, accountId,stageName,closedate from opportunity where id =: opp.Id ]; 
        System.Debug('***getopp1B:' + getopp);
        
        
        List<Contact> lstExsitingContacts = new List<Contact>();
        List<Contact> lstNewContacts = new List<Contact>();
        MAP<String,String> mapExistingMemProfileIdContactIds = new MAP<String,String>();
        Set<String> accountIDs = new Set<String>();
        Set<String> contactIDs = new Set<String>();
        Set<Contact> neededContacts = new Set<Contact>();
        MAP<String,Member_Profile_Summary__c> mapContactMemProfiles = new MAP<String,Member_Profile_Summary__c>();
        
        //ACCOUNT OWNER
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX'); 
        
        List<String> prodsFRM = new List<String>{'AFREE:AFREE:4040:100','MEMI:MEMI:4040:100','MEMC:MEMC:4040:100','FRM1E:FRM1E:4040:100','FRM1S:FRM1S:4040:100','FRM2E:FRM2E:4040:100','FRM2S:FRM2S:4040:100' ,'FRM1H:FRM1H:4040:100','FRM1X:FRM1X:4040:100','FRM2H:FRM2H:4040:100','FRM2X:FRM2X:4040:100','FRMC1:FRMC1:4040:100','FRMC2:FRMC2:4040:100','SHIP:SHIP:4040:100','SHIPFRM1:SHIPFRM1:4040:100','SHIPFRM2:SHIPFRM2:4040:100','SHIPSCR:SHIPSCR:4040:100','SHIPFFR:SHIPFFR:4040:100','SHIPFRR:SHIPFRR:4040:100'};
            GARP_TestFactory.createProducts(prodsFRM, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        GARP_TestFactory.createAffiliateContact();
        
        Account acc = [select id,Name from account where id =: cont.AccountId];
        contact cont1 = [select id,Member_Profile_Summary__c,accountid from contact where accountid =: cont.AccountId];
        Opportunity opp = [Select amount, accountId,stageName,closedate from opportunity where id = :opp.Id ]; 
        
        System.Debug('***getopp2:' + opp);
        
        opp.StageName = 'Closed';
        update opp;
        
        mps = new Member_Profile_Summary__c();
        mps.ContactId__c = cont1.id;
        mps.FRR_Attempts__c =2;
        insert mps;
        cont1.Member_Profile_Summary__c = mps.id;
        update cont1;
        
        mapContactMemProfiles.put(cont.Id, mps); 
        mapExistingMemProfileIdContactIds.put(mps.id, cont.Id);
        accountIDs.add(cont1.AccountId);
        contactIDs.add(cont1.id);
        neededContacts.add(cont1);
        
        eventRegistrationForParentEvent.Contact__c = cont1.Id;
        eventRegistrationForParentEvent.Opportunity__c = opp.id;
        update eventRegistrationForParentEvent;
        
        chapterMeetingReg.Contact__c = cont1.Id;
        update chapterMeetingReg;
        wr.Contact__c = cont1.Id;
        update wr;
        
        formdata.Contact__c = cont1.id;
        update formdata;
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        Test.startTest();
        
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
        List<Exam_Attempt__c> examattList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Opportunity__c = opp.id, Result__c = 'Pass', Exam_Part__c = examPart.Id, Quartile_1__c=2,Quartile_2__c=2,Quartile_3__c=2,Quartile_4__c=2,Quartile_5__c=2,Quartile_6__c=2,Quartile_7__c=2,Quartile_8__c=2,Exam_Site__c = exmSite.id,Member__c = cont.id,cancelled__c = false, Original_Exam_Site__c ='Site');
        examattList.add(attempt);
        //insert attempt;
        insert examattList;
        
        /*Exam__c exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = Date.parse('05/19/2018');
        exam.exam__c = 'SCR'; 
        insert exam;
        
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        insert exmSite;
        
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Opportunity__c = opp.id,Result__c = 'Pass', Exam_Site__c = exmSite.id,Member__c = cont1.id,cancelled__c = false, Original_Exam_Site__c ='Site');
        examattList.add(attempt2);
        //insert attempt2;
        
        Exam__c exam1 = new Exam__c();
        exam1.Exam_Group__c = objExamGrp.id;
        exam1.Exam_Date__c = Date.parse('05/19/2018');
        exam1.exam__c = 'ICBRR'; 
        insert exam1;
        
        Exam_Sites__c exmSite1 = new Exam_Sites__c(Site__c = site.id,exam__c = exam1.id);
        insert exmSite1;
        
        Exam_Attempt__c attempt3 = new Exam_Attempt__c(Opportunity__c = opp.id,Result__c = 'Pass', Exam_Site__c = exmSite1.id,Member__c = cont1.id,cancelled__c = false, Original_Exam_Site__c ='Site');
        examattList.add(attempt3);
        //insert attempt3;
        insert  examattList;
        */
        
        conlist[0].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        conlist[0].Opportunity__c = opp.id;
        conlist[0].Status = 'activated';
        update conlist; 
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        List<Candidate_Requirement__c> CanReqList = new List<Candidate_Requirement__c>();
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[0].Id, Exam__c = 'FRM Part I',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        insert CanReqList;
        
        GARP_BC_MemberProfile.calcMemberProfileSummary(mapExistingMemProfileIdContactIds,mapContactMemProfiles, accountIDs, contactIDs, neededContacts,lstNewContacts, lstExsitingContacts, 'fine', true, false);
        
        Member_Profile_Summary__c mps = new Member_Profile_Summary__c();
        GARP_BC_MemberProfile.oppInfo oppInfo = new GARP_BC_MemberProfile.oppInfo();
        oppInfo.orderSummaryProductLine = 'ERP';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'Events';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'FFR';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'FRM';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'FRR';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'GARP';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'GARP Content';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'Membership';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'RAI';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'SCR';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'FRR25';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'Micro Course';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        oppInfo.orderSummaryProductLine = 'Unknown';
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        mps = GARP_BC_MemberProfile.setRevenueByProduct(mps, opp, oppInfo, 'fine');
        
        
        Test.stopTest();
        
    }
    
    
    @isTest
    static void test1() {
        
        testSetup();
        Test.startTest();
        GARP_BC_MemberProfile.getCountries();
        GARP_BC_MemberProfile.getInstitutions();
        GARP_MS_MemberProfile.searchInstitutions('Com', 'Organization'); 
        GARP_BC_MemberProfile.getPickListValues('Contact','Area_of_Concentration__c');
        
        GARP_MC_PublicForms.searchInstitutions('Com', 'Organization'); 
        
        Test.stopTest();
        
    }
    
    @isTest
    static void test2() {
        
        testSetup();
        Test.startTest();
        
        GARP_MS_MemberProfile.memberProfileEdit mpe = GARP_MS_MemberProfile.getMemberProfileForEdit(cont.Id);
        GARP_MS_MemberProfile.memberProfileEdit mpe1 = GARP_MS_MemberProfile.getMemberProfileForEdit(null);
        
        GARP_MS_MemberProfile.memberProfileUpdate profileUpdate = new GARP_MS_MemberProfile.memberProfileUpdate();
        profileUpdate.profileParts = new GARP_MS_MemberProfile.profileParts();
        profileUpdate.ContactId = cont.Id;
        profileUpdate.AccountId = cont.AccountId;
        
        profileUpdate.profileParts.NameEmail = True;
        profileUpdate.FirstName = 'first';
        profileUpdate.LastName = 'last';
        GARP_MS_MemberProfile.setMemberProfile(profileUpdate);
        
        profileUpdate.profileParts.NameEmail = False;
        profileUpdate.profileParts.PhoneNumbers = False;
        profileUpdate.profileParts.EmploymentInformation = False;
        profileUpdate.profileParts.AcademicInformation = False;
        profileUpdate.profileParts.CompanyTitle = False;
        profileUpdate.profileParts.MailingAddress = True;
        profileUpdate.Mailing_Address_Company = 'Comp';
        GARP_MS_MemberProfile.setMemberProfile(profileUpdate);
        
        profileUpdate.profileParts.NameEmail = False;
        profileUpdate.profileParts.MailingAddress = False;
        profileUpdate.profileParts.PhoneNumbers = True;
        profileUpdate.HomePhone = '111111111';
        GARP_MS_MemberProfile.setMemberProfile(profileUpdate);
        
        profileUpdate.profileParts.NameEmail = False;
        profileUpdate.profileParts.MailingAddress = False;
        profileUpdate.profileParts.PhoneNumbers = False;
        profileUpdate.profileParts.EmploymentInformation = True;
        profileUpdate.Currently_Working_Status = 'Working';
        GARP_MS_MemberProfile.setMemberProfile(profileUpdate);
        
        profileUpdate.profileParts.NameEmail = False;
        profileUpdate.profileParts.MailingAddress = False;
        profileUpdate.profileParts.PhoneNumbers = False;
        profileUpdate.profileParts.EmploymentInformation = False;
        profileUpdate.profileParts.AcademicInformation = True;
        profileUpdate.School_Name = 'School';
        GARP_MS_MemberProfile.setMemberProfile(profileUpdate);
        
        profileUpdate.profileParts.NameEmail = False;
        profileUpdate.profileParts.MailingAddress = False;
        profileUpdate.profileParts.PhoneNumbers = False;
        profileUpdate.profileParts.EmploymentInformation = False;
        profileUpdate.profileParts.AcademicInformation = False;
        profileUpdate.profileParts.CompanyTitle = True;
        profileUpdate.Company = 'Comp';
        GARP_MS_MemberProfile.setMemberProfile(profileUpdate);
        
        profileUpdate.profileParts.NameEmail = False;
        profileUpdate.profileParts.MailingAddress = False;
        profileUpdate.profileParts.PhoneNumbers = False;
        profileUpdate.profileParts.EmploymentInformation = False;
        profileUpdate.profileParts.AcademicInformation = False;
        profileUpdate.profileParts.CompanyTitle = False;
        profileUpdate.profileParts.Survey = True;
        profileUpdate.Company = 'Comp';
        GARP_MS_MemberProfile.setMemberProfile(profileUpdate);
        
        profileUpdate.profileParts.NameEmail = False;
        profileUpdate.profileParts.MailingAddress = False;
        profileUpdate.profileParts.PhoneNumbers = False;
        profileUpdate.profileParts.EmploymentInformation = False;
        profileUpdate.profileParts.AcademicInformation = False;
        profileUpdate.profileParts.CompanyTitle = False;        
        profileUpdate.profileParts.BillingAddress = True;
        profileUpdate.profileParts.Survey = False;
        profileUpdate.Billing_Address_Company = 'Comp';
        GARP_MS_MemberProfile.setMemberProfile(profileUpdate);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void test3() {
        
        testSetup();
        
        List<Contract> conlist = [select id,Account.Name,RecordTypeID,CustomerSignedId,Status from Contract];
        System.debug('conlist'+conlist);
        conlist[0].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        conlist[0].Status = 'activated';
        conlist[1].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ERP_Program');
        conlist[1].Status = 'Completed';
        conlist[2].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
        conlist[2].Status = 'Completed';
        conlist[3].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ICBRR_Program');
        conlist[3].Status = 'Completed';
        conlist[4].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FBR_Program');
        conlist[4].Status = 'Completed';
        conlist[5].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        conlist[5].Status = 'Activated';
        conlist[6].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','CPE');
        conlist[6].Status = 'Activated';
        conlist[7].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_Net');
        conlist[7].Status = 'Activated';
        conlist[8].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        conlist[8].Status = 'Completed';
        update conlist; 
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        List<Candidate_Requirement__c> CanReqList = new List<Candidate_Requirement__c>();
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[0].Id, Exam__c = 'FRM Part I',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[8].Id, Exam__c = 'FRM Part II',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[0].Id, Exam__c = 'FRM Full',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[0].Id, Exam__c = 'Job Experience',Name='Exam', Status__c='Active', recordTypeId=ProgReqJobRecId));
        
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'ERP Part I',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'ERP Part II',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'ERP Full',Name='Exam', Status__c='Active', recordTypeId=ProgReqRecId));
        CanReqList.add(new Candidate_Requirement__c(Candidate_Commitment__c=conlist[1].Id, Exam__c = 'Job Experience',Name='Exam', Status__c='Active', recordTypeId=ProgReqJobRecId));
        insert CanReqList;
        
        
        Test.startTest();
        
        GARP_MC_MemberProfile.getMemberProfileForEdit(cont.Id);
        
        GARP_MS_MemberProfile.memberProfileUpdate profileUpdate = new GARP_MS_MemberProfile.memberProfileUpdate();
        profileUpdate.profileParts = new GARP_MS_MemberProfile.profileParts();
        profileUpdate.ContactId = cont.Id;
        profileUpdate.AccountId = acct.id;
        
        profileUpdate.profileParts.NameEmail = True;
        profileUpdate.FirstName = 'first';
        profileUpdate.LastName = 'last';
        
        GARP_BC_MemberProfile.updateMemberProfileSummary(cont.id);
        
        GARP_MC_MemberProfile.setMemberProfile(profileUpdate);
        GARP_BC_Authentication.isAuthenticated();
        
        GARP_MC_MemberProfile.setMemberEmail(profileUpdate);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void test4() {
        testSetup();
        Contact conRec = [SELECT Id,Currently_Working_Status__c,Area_of_Concentration__c,Industry_Working_Year__c FROM Contact Limit 1];
        conRec.Currently_Working_Status__c = 'Working';
        conRec.Area_of_Concentration__c = 'Insurance';
        conRec.Industry_Working_Year__c = '2024';
        conRec.Company__c = 'test';
        conRec.Corporate_Title__c = 'Associate';
        conRec.Job_Function__c = 'Research';
        conRec.Risk_Specialty__c = 'Data Risk';
        conRec.Risk_Management_Working_Year__c = '2024';
        conRec.School_Name__c = 'Research';
        conRec.Highest_Degree__c = 'Masters';
        conRec.Expected_Graduation_Date__c = '04/02/2024';
        conRec.Expected_Graduation_Month__c = 'April';
        //insert conRec;
        List<Opportunity> oppty = [SELECT Id,StageName FROM Opportunity /*WHERE StageName = 'Closed' LIMIT 1*/];
        //oppty.Amount = 123;
        //update oppty;
        system.debug('oppty::>>   '+oppty);
        
        Contact contactRec = [SELECT Id FROM Contact /*WHERE AccountId =: oppty.AccountId*/ Limit 1];
        system.debug('contactRec::>>   '+contactRec);
        
        Test.startTest();
        GARP_BC_MemberProfile.computeProfilePercentComplete(conRec);
        GARP_BC_MemberProfile.updateMemberProfileSummarys(new List<String>{contactRec.id});
        Test.stopTest();
        
    }
    
}