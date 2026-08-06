@isTest
private class OpportunityTriggerTest {
    static set<String> prodkeycodes=new set<string>();   
    static set<string> GL_CODE=new set<string>();
    static set<String> prodcodes=new set<string>();  
    
    @TestSetup
    static void createTestData() {
        Integer totalCount = 5;
        Integer totalCountOpp = 1;
        
        List<Exam_Group__c> examGrpResults = TestDataFactory.createExamGroup(totalCount);
        insert examGrpResults;
        
        // insert product 
        List<Product2> OppProduct2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'FRM1',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '5',GL_Code__c = '4999',Weight__c=5,Tax_Authority__c = 'SGP');
        OppProduct2List.add(p1);
        Product2 p2 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',productCode = 'FRM1E',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '6',GL_Code__c = '4999',Weight__c=6);
        OppProduct2List.add(p2);
        Product2 p3 = new Product2(Name = ' Test Product3',Description='Test Product Entry3 For Product',productCode = 'MEMC',isActive = true,Is_Shippable__c = true,Family='AffiliateMember',
                                   Customs_Cost__c = '6',GL_Code__c = '4999',Weight__c=6);
        OppProduct2List.add(p3);
        Product2 p4 = new Product2(Name = ' Test Product4',Description='Test Product Entry4 For Product',productCode = 'FRMRET1',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '6',GL_Code__c = '4999',Weight__c=6);
        OppProduct2List.add(p4);
        Product2 p5 = new Product2(Name = ' Test Product5',Description='Test Product Entry5 For Product',productCode = 'SCRX',isActive = true,Is_Shippable__c = true,Family='AffiliateMember',
                                   Customs_Cost__c = '6',GL_Code__c = '4999',Weight__c=6);
        OppProduct2List.add(p5);
        Product2 p6 = new Product2(Name = ' Test Product5',Description='Test Product Entry5 For Product',productCode = 'SAERP1',isActive = true,Is_Shippable__c = true,Family='IndividualMember',
                                   Customs_Cost__c = '6',GL_Code__c = '4999',Weight__c=6);
        OppProduct2List.add(p6);
        Product2 p7 = new Product2(Name = ' Test Product5',Description='Test Product Entry5 For Product',productCode = 'DCERTFRM',isActive = true,Is_Shippable__c = true,Family='AffiliateMember',
                                   Customs_Cost__c = '6',GL_Code__c = '4999',Weight__c=6);
        OppProduct2List.add(p7);
        Product2 p8 = new Product2(Name = ' Test Product5',Description='Test Product Entry5 For Product',productCode = 'PRFEE',Company__c = 'GRA',isActive = true,Is_Shippable__c = true,Family='AffiliateMember',
                                   Customs_Cost__c = '6',GL_Code__c = '6110',Weight__c=6);
        OppProduct2List.add(p8);
        insert OppProduct2List;
        
        
        // insert pricebook entry for the product
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice1);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[1].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice2);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[2].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice3);
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[3].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice4);
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[4].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice5);
        PricebookEntry standardPrice6 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[5].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice6);
        PricebookEntry standardPrice7 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[6].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice7);
        PricebookEntry standardPrice8 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),Product2Id = OppProduct2List[7].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice8);
        insert PricebookEntryList ;
        
        System.debug('code1'+PricebookEntryList[0].Product2.Productcode);
        
        Exam_Registration_Modification__c erm = new Exam_Registration_Modification__c();
        insert erm;
        
        List<Opportunity> OppResults=TestDataFactory.createOpportunity(totalCountOpp);
        for(Opportunity opp : OppResults){
            Opp.Pricebook2Id = Test.getStandardPricebookId();
            Opp.stagename = 'New Lead';
            opp.Ups_Stage__c = 'Sent to GT';
            Opp.Frm1__c = True;
            Opp.Frm2__c = True;
            Opp.Erp1__c = True;
            Opp.Erp2__c = True;
            opp.Exam_Registration_Modification__c = erm.Id;
        }
        insert OppResults;
        
        
        List<Contact> ContactResults=TestDataFactory.createContacts(totalCount);
        insert ContactResults;
        
        OppResults[0].Renew_Membership__c = true;
        //OppResults[2].Renew_Membership__c = true;
        //OppResults[3].Renew_Membership__c = true;
        OppResults[0].Shipping_Street__c = 'test shipping street1';
        update OppResults;
        
        List<Contract> ContractResults=TestDataFactory.createContract(totalCount,OppResults,ContactResults);
        ContractResults[0].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        ContractResults[1].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'OSTA_Program');
        ContractResults[2].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        ContractResults[3].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
        insert ContractResults;
        ContractResults[0].Status = 'Draft';
        ContractResults[1].Status = 'Activated';
        update ContractResults;
        
        Contact con = new Contact();
        con.Id= ContractResults[0].CustomerSignedId;
        con.AccountId = OppResults[0].AccountId;
        update con; 
        
        Scholarship_Application__c sa = new Scholarship_Application__c(Applicant__c = ContractResults[0].CustomerSignedId,
                                                                       Exam_Type__c='FRM',Status__c='Submitted', Exam_Group__c= examGrpResults[0].Id);       
        insert sa;
        
        List<Exam_Attempt__c> ExamAttemptList = TestDataFactory.createExamAttempt(3,OppResults,ContractResults);
        insert ExamAttemptList;
        
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[0].Id,UnitPrice = 250,
                                                                   Quantity = 1,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[1].Id,UnitPrice = 250,
                                                                   Quantity = 1,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem2);
        OpportunityLineItem oppLineItem3 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[2].Id,UnitPrice = 250,
                                                                   Quantity = 1,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem3);
        OpportunityLineItem oppLineItem4 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[3].Id,UnitPrice = 250,
                                                                   Quantity = 1,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem4);
        OpportunityLineItem oppLineItem5 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[4].Id,UnitPrice = 250,
                                                                   Quantity = 1,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem5);
        OpportunityLineItem oppLineItem6 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[5].Id,UnitPrice = 250,
                                                                   Quantity = 1,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        
        OpportunityLineItemList.add(oppLineItem6);
        OpportunityLineItem oppLineItem7 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[6].Id,UnitPrice = 250,
                                                                   Quantity = 1,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem7);
        OpportunityLineItem oppLineItem8 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[7].Id,UnitPrice = 250,
                                                                   Product2Id = OppProduct2List[7].Id, Quantity = 1,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem8);
        insert OpportunityLineItemList;
        
        System.debug('code2'+OpportunityLineItemList[0].Productcode);
        
        List<Event_Registration__c> EventRegistrationResults=TestDataFactory.createEventRegistration(totalCount,OppResults);
        insert EventRegistrationResults;
        
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = OppResults[0].id);
        insert order;  
        ChargentOrders__Transaction__c payment = new ChargentOrders__Transaction__c(Opportunity__c = OppResults[0].id,
                                                                                    ChargentOrders__Type__c = 'Charge',
                                                                                    ChargentOrders__Order__c = order.id,
                                                                                    ChargentOrders__Response_Status__c= 'Approved');
        insert payment;
        
        List<Product_Refunds__c> ProductRefundsList = new List<Product_Refunds__c>();
        Product_Refunds__c refund1 = new Product_Refunds__c (Status__c='Completed',Cancel_E_book__c = True,Take_Membership__c = true,
                                                             Refund_amount__c =123, opportunity__c = OppResults[0].id,
                                                             product__c = OppProduct2List[0].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund1);
        
        insert ProductRefundsList;
    } 
    
    @isTest static void testOpportunityTrigger_ClosedStage(){
        list<Site__c> listsite=new list<site__c>();
        Site__c site_record = new Site__c( name = 'Test Site ',Display_Address__c = 'Test Display_Address__c ',
                                          active__c = true,Non_selectable__c = false,Exam_Date__c = System.today().addDays(13),
                                          ATA_region_name__c= 'test',ATA_region_code__c = 'test');
        listsite.add(site_record);
        insert listsite;    
        Exam_Sites__c exam_site_res = new Exam_Sites__c(Site__c = listsite[0].id,Exam_Date__c = system.today().addDays(30));
        insert exam_site_res;
        List<Exam_Attempt__c> ExamAttemptList = [Select id,Exam_Site__c from Exam_Attempt__c limit 1];
        ExamAttemptList[0].Exam_Site__c = exam_site_res.id;
        update ExamAttemptList;
        List<OpportunityLineItem> OpportunityLineItemList = [Select Id,Product_company__c,Exam_Registration__c from OpportunityLineItem  LIMIT 2];
        OpportunityLineItemList[0].Exam_Registration__c = ExamAttemptList[0].Id;
        OpportunityLineItemList[0].Product_company__c = 'testing';
        
        Account account = new Account();
        account.Name = 'TEST';
        INSERT account;
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed Lost';
        opportunity.CloseDate = Date.today();
        opportunity.Resend_Order_To_ShipEdge__c = false;
        INSERT opportunity;
        Test.startTest();
        
        List<Opportunity> oppList = [Select Id,Certified_Membership_Individual__c,Renew_Membership__c,Resend_Order_To_ShipEdge__c,accountId,Has_Books__c,Auto_Renew__c,Ups_Stage__c,Cancel_Books__c,
                                     Exam_Registration_Modification__c,stagename from Opportunity LIMIT 2];
        Opportunity opp = oppList[0];
        
        opp.stagename = 'Closed';
        opp.Ups_Stage__c = null;
        Opp.recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Opportunity','Manual');
        opp.Manual_State__c = 'test';
        opp.Institutional_Sale__c = false;
        opp.Institutional_Sale_Stage__c = 'Draft';
        opp.Inst_Sale_Emails__c = 'test@test.com';
        //opp.Inst_Sale_Service_End_Date__c = Date.newInstance(2016, 12, 9);
        opp.Alternate_Method_of_Payment__c = 'Wire';
        Opp.Do_Not_change_amount__c = True;
        opp.Inst_Sale_Opp__c = null;
        opp.Resend_Order_To_ShipEdge__c = true;
        opp.Acceptable_Inst_Sale_Products__c = false;
        opp.Auto_Renew__c =  True;
        opp.Products_SKU__c = 'test,teest';
        opp.Cancel_Books__c = true;
        opp.Has_Books__c = true;
        opp.Tracking_Number__c = '';
        update opp;
        
        OpportunityHandler oppHandler = new OpportunityHandler();
        //oppHandler.processBeforeUpdateAndGetMaps(oppList[0],oppList[1]);
        oppHandler.procShpCnclAndRsnd(oppList[0],oppList[1]);
        oppHandler.procShpCnclAndRsnd(oppList[0],oppList[1]);
        opp.Tracking_Number__c = 'test';
        oppHandler.procShpCnclAndRsnd(oppList[0],oppList[1]);
        
        opp.Ups_Stage__c = 'New Order';
        opp.Cancel_Books__c = false;
        Opp.Do_Not_change_amount__c = False;
        opp.Certified_Membership_Individual__c = False;
        update opp;
        oppHandler.procShpCnclAndRsnd(oppList[0],oppList[1]);
        oppHandler.procShpCnclAndRsnd(oppList[0],oppList[1]);
        
        oppHandler.processBeforeUpdateAndGetMaps(oppList[0],oppList[1]);
        
        
        test.stopTest();
    } 
    
    @isTest static void testOpportunityTrigger_RecurringIntentStage(){
        List<OpportunityLineItem> OpportunityLineItemList = [Select Id,Product_company__c from OpportunityLineItem  LIMIT 2];
        OpportunityLineItemList[0].Product_company__c = 'testing';
        test.startTest();
        List<Opportunity> oppList = [Select Id,stagename from Opportunity LIMIT 2];
        Opportunity opp = oppList[0];
        opp.stagename = 'Recurring Intent';
        Opp.recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Opportunity','Manual');
        Opp.Auto_Renew__c = True;
        update opp;
        test.stopTest();
    }
    
    
    @isTest static void testOpportunityTrigger_ClosedLostStage(){
        
        List<OpportunityLineItem> OpportunityLineItemList = [Select Id,Product_company__c from OpportunityLineItem  LIMIT 2];
        OpportunityLineItemList[0].Product_company__c = 'testing';
        
        test.startTest();
        List<Opportunity> oppList = [Select Id,stagename from Opportunity LIMIT 2];
        Opportunity opp = oppList[0];
        opp.stagename = 'Closed Lost';
        opp.Event_Order__c = true;
        Opp.recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Opportunity','Manual');
        Opp.Auto_Renew__c = True;
        update opp;
        
        list<contract> contrlist=[select id,recordtypeId,Status,Opportunity__c from contract limit 1];
        contrlist[0].recordtypeId=RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        contrlist[0].Opportunity__c = oppList[0].id;
        contrlist[0].status = 'Activated';
        update contrlist;
        
        test.stopTest();
    }
    
    @isTest static void testOpportunityTriggerHelperV1(){
        List<OpportunityLineItem> OpportunityLineItemList = [Select Id,Product_company__c from OpportunityLineItem  LIMIT 4];
        List<Product2> ProductList = [Select Id,ProductCode,Family,GL_Code__c from Product2  LIMIT 4];
        List<Scholarship_Application__c> Sa_list =[Select Applicant__c,Exam_Type__c,Status__c,Exam_Group__c from Scholarship_Application__c Limit 1];
        Sa_list[0].Status__c = 'Approved';
        update Sa_list;
        
        List<Contact> ContactList = [Select Id,Email from Contact  LIMIT 4];
        
        Product_Rate_Offering__c pro = new Product_Rate_Offering__c(Contact__c = ContactList[0].Id,
                                                                    Current_Product__c=ProductList[0].Id,
                                                                    Customer_Email__c = ContactList[0].Email.tolowercase(),
                                                                    Status__c = 'Active');
        insert pro;
        test.startTest();
        OpportunityLineItemList[0].Product_company__c = 'testing';
        List<Opportunity> oppList = [Select Id,AccountId,stagename from Opportunity LIMIT 4];
        
        Opportunity opp0 = oppList[0];
        //Opportunity opp2 = oppList[2];
        //Opportunity opp3 = oppList[3];
        
        List<Opportunity> closedOppList = new List<Opportunity>();
        closedOppList.add(opp0);
        //closedOppList.add(opp2);
        //closedOppList.add(opp3);
        
        List<ChargentOrders__Transaction__c> TransactionResults=TestDataFactory.createChargentSFATransaction(closedOppList.size(),closedOppList);
        //insert TransactionResults; 
        
        List<Contract> ContractResults=[select id,AccountId,Membership_Type__c,recordtypeId,CustomerSignedId,Status from Contract LIMIT 4];
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'Risk_Net');
        //ContractResults[0].status = 'Activated';
        ContractResults[1].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'OSTA_Program');
        ContractResults[2].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'SCR_Program');
        ContractResults[3].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        ContractResults[1].status = 'Activated';
        ContractResults[3].status = 'Activated';
        update ContractResults;
        
        opp0.stagename = 'Closed';
        opp0.recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Opportunity','Manual');
        opp0.Manual_State__c = 'test';
        opp0.Alternate_Method_of_Payment__c = 'Wire';
        
        update oppList;     
        OpportunityHandler oppHandler = new OpportunityHandler();
        OpportunityLineItem opplineitem = [select OpportunityId ,PricebookEntryId,UnitPrice, 
                                           Quantity,Product_company__c,Exam_Registration__c,
                                           Scholarship_Application__c from OpportunityLineItem 
                                           where OpportunityId =: oppList[0].id limit 1];
        oppHandler.updateIdsForRecordIdMap('RetabulationRequest',opplineitem.Exam_Registration__c);
        //List<ChargentOrders__Transaction__c> TransactionResults=TestDataFactory.createChargentSFATransaction(oppList.size(),oppList);
        //insert TransactionResults; 
        
        test.stopTest();
    }
    
    
    
    @isTest 
    static void testOpportunityTriggerUtils_New(){
        List<OpportunityLineItem> OpportunityLineItemList = [Select Id,UnitPrice,Product_company__c,OpportunityId,Opportunity.AccountId,quantity from OpportunityLineItem  LIMIT 4];
        Map<Id,Contact> accIdToContactMap = new Map<Id,Contact>([SELECT id,FirstName,LastName,Email,HomePhone,AccountId FROM Contact]);
        Account acc= [SELECT id from Account LIMIT 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        opportunityTriggerUtils_New.getNewRiskContract(OpportunityLineItemList[0], accIdToContactMap);
        
        Id OSTARecTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'OSTA_Program');
        //Id frmProgramId = accIdToFRMMap.containskey(oli.Opportunity.AccountId)?accIdToFRMMap.get(oli.Opportunity.AccountId).Id:null;
        
        opportunityTriggerUtils_New.getNewOSTAContract(acc.Id, OpportunityLineItemList[0].OpportunityId,con.Id,OSTARecTypeId,null);
        opportunityTriggerUtils_New.getUPSCode('UPS Next Day Air');
        opportunityTriggerUtils_New.getUPSCode('UPS 2nd Day Air');
        opportunityTriggerUtils_New.getUPSCode('UPS Ground');
        opportunityTriggerUtils_New.getUPSCode('UPS Worldwide Express');
        opportunityTriggerUtils_New.getUPSCode('UPS Worldwide Expedited');
        opportunityTriggerUtils_New.getUPSCode('UPS Standard');
        opportunityTriggerUtils_New.getUPSCode('UPS 3 Day Select');
        opportunityTriggerUtils_New.getUPSCode('UPS Next Day Air Saver');
        opportunityTriggerUtils_New.getUPSCode('UPS Next Day Air Early A.M.');
        opportunityTriggerUtils_New.getUPSCode('UPS Worldwide Express Plus');
        opportunityTriggerUtils_New.getUPSCode('UPS 2nd Day Air A.M.');
        opportunityTriggerUtils_New.getUPSCode('UPS Saver');
        opportunityTriggerUtils_New.getUPSCode(null);
    }
    
    @isTest static void testOpportunityTriggerHelperV2(){
        
        List<Contact> lstContact  = [SELECT id,FirstName,LastName,Email,HomePhone,AccountId FROM Contact limit 1];
        lstContact[0].Email='test@gmail.com';
        update lstContact;
        list<string> Gc=new list<string>{'4000','4001','4002','4011','4012'};
            list<String> pc=new list<string>{'FRM1','FRM1E','MEMC','FRMRET1','SCRX','SAERP1','DCERTFRM','ENC2X','FRM1X','ENC1X','FRM2X'};
                list<String> pkc=new list<string>();        
        
        for (Integer i =0;i<1;i++){ 
            pkc.add(pc[i]+':'+Gc[i]+':'+lstContact[i].Email);
        }
        prodkeycodes=new set<string>(pkc);   
        GL_CODE=new set<string>(Gc);
        prodcodes=new set<string>(pc);  
        
        List<Product2> prod = [select id,productCode,isActive,Is_Shippable__c,Family,GL_Code__c from Product2 limit 1] ;
        prod[0].productCode=pc[0];
        prod[0].GL_Code__c=Gc[0];
        update prod;
        Product_Rate_Offering__c prorate = new Product_Rate_Offering__c(Contact__c = lstContact[0].Id,
                                                                        Current_Product__c=prod[0].Id,Attestation_Required__c=false,
                                                                        Customer_Email__c = lstContact[0].Email.tolowercase(),
                                                                        Status__c = 'Active');
        insert prorate;
        test.startTest();
        OpportunityTriggerHelper_New.closeRateOffers(prodcodes,GL_CODE,lstContact,prodkeycodes);
        prorate.Attestation_Required__c=true;
        OpportunityTriggerHelper_New.closeRateOffers(prodcodes,GL_CODE,lstContact,prodkeycodes);
        test.stopTest();
    }
    
    @isTest 
    static void testMethod1(){
        
        Id memberRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,accountId FROM Opportunity]);
        Opportunity opp = [SELECT Id,accountId FROM Opportunity LIMIT 1];
        Set<Id> oppIdSet = oppMap.keySet();
        opportunityTriggerUtils_New.cancelFFRA(oppIdSet);
        
        Map<Id, String> garpMemberIdByOpportunityId = new Map<Id, String>();
        for(Product_Refunds__c pr : [SELECT Id,Opportunity__c,GARP_ID__c FROM Product_Refunds__c]){
            garpMemberIdByOpportunityId.put(pr.Opportunity__c, pr.GARP_ID__c);
        }
        
        opportunityTriggerUtils_New.unprovisionMobiuseBook(garpMemberIdByOpportunityId,'FRM','');
        opportunityTriggerUtils_New.getNewMemberContract(opp,memberRecordTypeID,'Individual');
        OpportunityTriggerHelper_New.getOppProductMethodMapAllProducts();
    }
    
    @isTest 
    static void stripetaxMethod1(){
        Opportunity opp = [SELECT Id,accountId FROM Opportunity LIMIT 1];
        opp.StripeTaxMethod__c = 'Regular';
         test.startTest();
        update opp;
         test.stopTest();
    }
}