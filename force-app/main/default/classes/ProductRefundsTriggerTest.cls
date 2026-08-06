@isTest
private class ProductRefundsTriggerTest {
    Static List<MembershipRefundCodes__c> MembershipRefundlist;
    Static List<Product_Refunds__c> ProductRefundsList;
    @TestSetup
    static void createTestData() {
        Integer totalCount = 23;
        
        List<Exam_Group__c> examGrpResults = TestDataFactory.createExamGroup(totalCount);
        insert examGrpResults;
        
        // insert product
        List<Product2> Product2List = new List<Product2>();
        Product2 p1 = new Product2(Name = ' Test Product1',Description='Test Product Entry1 For Product',productCode = 'ENC2X',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '5',Weight__c=5,GL_Code__c='4011');
        Product2List.add(p1);
        Product2 p2 = new Product2(Name = ' Test Product2',Description='Test Product Entry2 For Product',productCode = 'FRM1X',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Weight__c=6,GL_Code__c='4011');
        Product2List.add(p2);
        Product2 p3 = new Product2(Name = ' Test Product3',Description='Test Product Entry3 For Product',productCode = 'SCRX',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Weight__c=6,GL_Code__c='4011');
        Product2List.add(p3);
        Product2 p4 = new Product2(Name = ' Test Product4',Description='Test Product Entry4 For Product',productCode = 'ENC1X',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Weight__c=6,GL_Code__c='4011');
        Product2List.add(p4);
        Product2 p5 = new Product2(Name = ' Test Product4',Description='Test Product Entry4 For Product',productCode = 'FRM2X',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Weight__c=6,GL_Code__c='4011');
        Product2List.add(p5);
        Product2 p6 = new Product2(Name = ' Test Product4',Description='Test Product Entry4 For Product',productCode = 'MISC',isActive = true,Is_Shippable__c = true,
                                   Customs_Cost__c = '6',Weight__c=6,GL_Code__c='4011');
        Product2List.add(p6);
        insert Product2List;
        
                
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
        
        
        // insert pricebook entry for the product
        List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[0].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice1);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[1].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice2);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[2].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice3);
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[3].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice4);
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[4].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice5);
        PricebookEntry standardPrice6 = new PricebookEntry(Pricebook2Id = standardPricebook.Id,Product2Id = Product2List[5].Id,UnitPrice = 250,IsActive = true,UseStandardPrice = false);
        PricebookEntryList.add(standardPrice6);
        insert PricebookEntryList ;
        
        Exam_Registration_Modification__c erm = new Exam_Registration_Modification__c();
        insert erm;
        
        List<Opportunity> OppResults=TestDataFactory.createOpportunity(totalCount);
        for(Opportunity opp : OppResults){
            Opp.Pricebook2Id = standardPricebook.Id;
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
        
        
        List<Contract> ContractResults=TestDataFactory.createContract(totalCount,OppResults,ContactResults);
        ContractResults[0].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        ContractResults[1].recordtypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');    
        insert ContractResults;
        ContractResults[0].Status = 'Completed';
        ContractResults[1].Status = 'Activated'; 
        update ContractResults;
        
        Contact con = new Contact();
        con.Id= ContractResults[0].CustomerSignedId;
        con.AccountId = OppResults[0].AccountId;
        update con;
        
        Contact con1 = new Contact();
        con1.Id= ContractResults[1].CustomerSignedId;
        con1.AccountId = OppResults[1].AccountId;
        update con1;
        
        List<eBook_Key__c> EbookKey=TestDataFactory.createEbookKey(totalCount,OppResults);
        insert EbookKey;
        
        List<Event_Registration__c> EventReg=TestDataFactory.createEventRegistration(totalCount,OppResults);
        EventReg[0].Status__c  = 'Cancelled';
        insert EventReg;
        
        
        Scholarship_Application__c sa = new Scholarship_Application__c(Applicant__c = ContractResults[0].CustomerSignedId,
                                                                       Exam_Type__c='FRM',Status__c='Submitted', Exam_Group__c= examGrpResults[0].Id);
        insert sa;
        Scholarship_Application__c sa1 = new Scholarship_Application__c(Applicant__c = ContractResults[1].CustomerSignedId,
                                                                        Exam_Type__c='ERP',Status__c='Submitted', Exam_Group__c= examGrpResults[1].Id);
        insert sa1;
        
        List<Exam_Attempt__c> ExamAttemptList =TestDataFactory.createExamAttempt(3,OppResults,ContractResults);
        
        
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = OppResults[0].Id,PricebookEntryId = PricebookEntryList[0].Id,UnitPrice = 7000,
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = OppResults[1].Id,PricebookEntryId = PricebookEntryList[1].Id,UnitPrice = 250,
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem2);
        OpportunityLineItem oppLineItem3 = new OpportunityLineItem(OpportunityId = OppResults[2].Id,PricebookEntryId = PricebookEntryList[2].Id,UnitPrice = 250,
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem3);
        OpportunityLineItem oppLineItem4 = new OpportunityLineItem(OpportunityId = OppResults[3].Id,PricebookEntryId = PricebookEntryList[3].Id,UnitPrice = 250,
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem4);
        OpportunityLineItem oppLineItem5 = new OpportunityLineItem(OpportunityId = OppResults[4].Id,PricebookEntryId = PricebookEntryList[4].Id,UnitPrice = 250,
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem5);
        OpportunityLineItem oppLineItem6 = new OpportunityLineItem(OpportunityId = OppResults[5].Id,PricebookEntryId = PricebookEntryList[5].Id,UnitPrice = 250,
                                                                   Quantity = 5,Product_company__c='GRA Test',Exam_Registration__c = ExamAttemptList[0].Id,Scholarship_Application__c = sa.Id);
        OpportunityLineItemList.add(oppLineItem6);
        
        insert OpportunityLineItemList;
        
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = OppResults[0].id);
        insert order;  
         
            
        ChargentOrders__Transaction__c payment = new ChargentOrders__Transaction__c(Opportunity__c = OppResults[0].id,ChargentOrders__Type__c = 'Charge',
                                                                              		ChargentOrders__Order__c = order.id,
                                                                                    ChargentOrders__Response_Status__c= 'Approved');
        insert payment;
        
     
        
        //SELECT Id,Name,Product_Code__c FROM MembershipRefundCodes__c
        List<MembershipRefundCodes__c> MembershipRefundlist=new List<MembershipRefundCodes__c>();
        MembershipRefundCodes__c memrefund1 = new MembershipRefundCodes__c(Name='test1',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund1);
        MembershipRefundCodes__c memrefund2 = new MembershipRefundCodes__c(Name='test2',Product_Code__c ='FRM2X');
        MembershipRefundlist.add(memrefund2);
        MembershipRefundCodes__c memrefund3 = new MembershipRefundCodes__c(Name='test3',Product_Code__c ='SCRX');
        MembershipRefundlist.add(memrefund3);
        MembershipRefundCodes__c memrefund4 = new MembershipRefundCodes__c(Name='test4',Product_Code__c ='ENC1X');
        MembershipRefundlist.add(memrefund4);
        MembershipRefundCodes__c memrefund5 = new MembershipRefundCodes__c(Name='test5',Product_Code__c ='ENC2X');
        MembershipRefundlist.add(memrefund5);
        MembershipRefundCodes__c memrefund6 = new MembershipRefundCodes__c(Name='test6',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund6);
        MembershipRefundCodes__c memrefund7 = new MembershipRefundCodes__c(Name='test7',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund7);
        MembershipRefundCodes__c memrefund8 = new MembershipRefundCodes__c(Name='test8',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund8);
        MembershipRefundCodes__c memrefund9 = new MembershipRefundCodes__c(Name='test9',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund9);
        MembershipRefundCodes__c memrefund10 = new MembershipRefundCodes__c(Name='test10',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund10);
        MembershipRefundCodes__c memrefund11 = new MembershipRefundCodes__c(Name='test11',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund11);
        MembershipRefundCodes__c memrefund12 = new MembershipRefundCodes__c(Name='test12',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund12);
        MembershipRefundCodes__c memrefund13 = new MembershipRefundCodes__c(Name='test13',Product_Code__c ='SCRX');
        MembershipRefundlist.add(memrefund13);
        MembershipRefundCodes__c memrefund14 = new MembershipRefundCodes__c(Name='test14',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund14);
        MembershipRefundCodes__c memrefund15 = new MembershipRefundCodes__c(Name='test15',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund15);
        MembershipRefundCodes__c memrefund16 = new MembershipRefundCodes__c(Name='test16',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund16);
        MembershipRefundCodes__c memrefund17 = new MembershipRefundCodes__c(Name='test17',Product_Code__c ='MISC');
        MembershipRefundlist.add(memrefund17);
        MembershipRefundCodes__c memrefund18 = new MembershipRefundCodes__c(Name='test18',Product_Code__c ='FRM1X');
        MembershipRefundlist.add(memrefund18);
        insert MembershipRefundlist;
        
        
         List<Product_Refunds__c> ProductRefundsList = new List<Product_Refunds__c>();
        Product_Refunds__c refund1 = new Product_Refunds__c (Status__c='Completed',Cancel_E_book__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[0].id,product__c = Product2List[0].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund1);
        Product_Refunds__c refund2 = new Product_Refunds__c (Status__c='Completed',Cancel_ERP_Enrollment__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[17].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund2);
        Product_Refunds__c refund3 = new Product_Refunds__c (Status__c='Completed',Cancel_FRM_Enrollment__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[2].id,product__c = Product2List[2].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund3);
        Product_Refunds__c refund4 = new Product_Refunds__c (Status__c='Completed',Cancel_FRM1__c  = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[0].id,product__c = Product2List[3].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund4);
        Product_Refunds__c refund5 = new Product_Refunds__c (Status__c='Completed',Cancel_FRM2__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[4].id,product__c = Product2List[4].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund5);
        Product_Refunds__c refund6 = new Product_Refunds__c (Status__c='Completed',Cancel_ERP__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[5].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund6);
        Product_Refunds__c refund7 = new Product_Refunds__c (Status__c='Completed',Cancel_ERP1__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[6].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund7);
        Product_Refunds__c refund8 = new Product_Refunds__c (Status__c='Completed',Cancel_ERP2__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[7].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund8);
        Product_Refunds__c refund9 = new Product_Refunds__c (Status__c='Completed',Charge_Back__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                             opportunity__c = OppResults[8].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund9);
        Product_Refunds__c refund10 = new Product_Refunds__c (Status__c='Completed', Cancel_Wiley__c =true, Wiley_Quantity__c =15.00,Refund_amount__c =123,
                                                              opportunity__c = OppResults[9].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund10);
        Product_Refunds__c refund11 = new Product_Refunds__c (Status__c='Submitted',Cancel_Event__c = True,Cancel_FBRA__c = True,Charge_Back__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                              opportunity__c = OppResults[0].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund11);
        Product_Refunds__c refund12 = new Product_Refunds__c (Status__c='Completed',Cancel_Event__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                              opportunity__c = OppResults[11].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund12);
        Product_Refunds__c refund13 = new Product_Refunds__c (Status__c='Completed',Cancel_OTSA__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                              opportunity__c = OppResults[12].id,product__c = Product2List[2].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund13);
        Product_Refunds__c refund14 = new Product_Refunds__c (Status__c='Completed',Cancel_SCR__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                              opportunity__c = OppResults[13].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund14);
        Product_Refunds__c refundrai = new Product_Refunds__c (Status__c='Completed',Cancel_RISK_AI__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                              opportunity__c = OppResults[21].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refundrai);
        Product_Refunds__c refund15 = new Product_Refunds__c (Status__c='Completed',Cancel_FRR__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                              opportunity__c = OppResults[14].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund15);
        Product_Refunds__c refund16 = new Product_Refunds__c (Status__c='Completed',Cancel_Practice_exam__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                              opportunity__c = OppResults[15].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund16);
        Product_Refunds__c refund17 = new Product_Refunds__c (Status__c='Completed',Re_stocking_fees__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                              opportunity__c = OppResults[16].id,product__c = Product2List[5].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund17);
        Product_Refunds__c refund18 = new Product_Refunds__c (Status__c='Approved',Cancel_Risk_Net__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                              opportunity__c = OppResults[1].id,product__c = Product2List[1].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund18); 
         Product_Refunds__c refund19 = new Product_Refunds__c (Status__c='Completed',Cancel_FBRA__c = True,Charge_Back__c = True,Take_Membership__c = true,Refund_amount__c =123,
                                                              opportunity__c = OppResults[10].id,product__c = Product2List[2].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refund19);
        Product_Refunds__c refundfrr = new Product_Refunds__c (Status__c='Approved',Refund_amount__c =123,opportunity__c = OppResults[20].id,product__c = Product2List[2].id,Cancel_Program_Name__c= 'FRR25 Program',Cancel_Exam_Section_Name__c='FRR25',Unique_Id__c = 'FRR25'+OppResults[10].id,UniqueProductOpportunity__c='FRR25'+OppResults[10].id,Payment_Order_Transaction__c = payment.id);
        ProductRefundsList.add(refundfrr);
        insert ProductRefundsList;
        
    } 
    
    
    
    @isTest static void testProductRefundsV1(){
        test.startTest();
        MembershipRefundlist=[SELECT Name,Product_Code__c FROM MembershipRefundCodes__c LIMIT 18];
        UPDATE MembershipRefundlist;
        ProductRefundsList = [Select Id,Status__c,Product_Code__c  from Product_Refunds__c where Status__c='Completed' LIMIT 19];
        ProductRefundsList[10].Status__c='Submitted';
        update ProductRefundsList;      
		test.stopTest();
    }
    
    @isTest static void testProductRefundsV2(){
        test.startTest();	
        List<Contract> ContractResults = [Select id,Status from Contract where Status='Completed'];
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRM_Program');
        update ContractResults;
        ContractResults[0].Status = 'Activated ( Auto-Renew )';
        update ContractResults;
        List<Exam_Attempt__c> EA = [Select id from Exam_Attempt__c];
        update EA;
        ProductRefundsList = [Select Id,Status__c,Product_Code__c,Charge_Back__c,product__c  from Product_Refunds__c where Status__c='Submitted' and Cancel_FBRA__c = True LIMIT 1];
		ProductRefundsList[0].Status__c='Completed';
        ProductRefundsList[0].Cancel_Event__c = True;
        ProductRefundsList[0].Charge_Back__c = True;
        update ProductRefundsList;
        
		//List<Exam_Attempt__c> examresults=[select id,Cancelled__c,Section__c,opportunity__C from Exam_Attempt__c limit 1];
       // examresults[0].Section__c ='ERP Exam Part I';
		//update examresults;
		List<Contract> accContractList = [Select id,Status,AccountId from Contract where Status='Activated' and RecordType.Name = 'Membership'];
            updateContractByRefunds.updateContractTerm(new Set<id>{accContractList[0].AccountId});
        accContractList[0].ContractTerm = 15;
        update accContractList[0];
        updateContractByRefunds.updateContractTerm(new Set<id>{accContractList[0].AccountId});
        test.stopTest();
    }
    
     @isTest static void testProductRefundsV3(){
        test.startTest();	
         ProductRefundsList = [Select Id,Status__c,Opportunity__c,Product_Code__c,Charge_Back__c,product__c  from Product_Refunds__c where  Cancel_Program_Name__c = 'FRR25 Program'  and Cancel_Exam_Section_Name__c = 'FRR25' LIMIT 1];
		
        List<Contract> ContractResults = [Select id,Status from Contract where Status='Completed' limit 1];
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRR25_Program'); 
        ContractResults[0].Status = 'Activated';
        ContractResults[0].Opportunity__c = ProductRefundsList[0].Opportunity__c;
        update ContractResults;
        
        ProductRefundsList[0].Status__c='Completed'; 
        update ProductRefundsList;
         
    }  
}