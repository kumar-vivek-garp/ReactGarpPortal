@isTest
public class CreateScholarshipRefunds_Test {

    static Account acc ;
    static Opportunity opp; 
    static Contact contact;
  
    private static void testData(){ 
        
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;
        
        Id pricebookId = activePricebook.Id;

        Product2 FRM1E = new Product2(Name = 'FRM 1 Early', productCode = 'FRM1E', GL_Code__c = '4002', Family = 'Hardware', isActive = true);
        INSERT FRM1E; 
        
        Product2 SAFRM1 = new Product2(Name = 'FRM Part 1 Scholarship Refund', ProductCode = 'SAFRM1', GL_Code__c = '4003', Family = 'Hardware', isActive = true);
        INSERT SAFRM1; 
        
        PricebookEntry FRM1EPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = FRM1E.Id, UnitPrice = 425.00, IsActive = true);
        INSERT FRM1EPBE;
        
        PricebookEntry SAFRM1PBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = SAFRM1.Id, UnitPrice = 0.00, IsActive = true);
        INSERT SAFRM1PBE;
 
        INSERT new UpdateIds__c(Name='User', Record_Id__c='00540000001y7OX');        
         
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test', ChargentBase__Merchant_ID__c = 'dasghjtru548709-4', ChargentBase__Active__c = true);
        INSERT chrgGtway;
        
        INSERT new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
 
        acc = new Account(Name = 'test');
        INSERT acc;

        contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        INSERT contact;
        
        Id manualRecId = RecordTypeHelper.GetRecordTypeId('Opportunity', 'Manual'); 
        opp = new Opportunity(
            Amount = 123,
            Name = 'Test', 
            Gateway__c = chrgGtway.id,
            RecordTypeID = manualRecId,
            Inst_Sale_Service_End_Date__c=system.today()+ 15,
            Eligible_for_Membership_Extension__c = false,
            company__c = 'Payment', 
            accountId = acc.id,stageName = 'New Lead',
            Program__c = 'Print',
            Inst_Sale_Code__c = 'Promocode',
            Institutional_Sale__c = false,
            Institutional_Sale_Stage__c = 'Approved',
            closedate = system.today()+ 15
        );        
        INSERT opp;

        OpportunityLineItem oppli1 = new OpportunityLineItem();
        oppli1.Quantity=1;
        oppli1.OpportunityId=opp.Id; 
        oppli1.UnitPrice = FRM1EPBE.UnitPrice;
        oppli1.product2id= FRM1E.Id;
        oppli1.PriceBookEntryId = FRM1EPBE.Id;
        INSERT oppli1;
        
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opp.id);
        insert order; 
        list<ChargentOrders__Transaction__c> tran = new list<ChargentOrders__Transaction__c>();
        ChargentOrders__Transaction__c tran1 = new ChargentOrders__Transaction__c();
        tran1.Opportunity__c = opp.id;
        tran1.ChargentOrders__Order__c = order.id;
        tran1.ChargentOrders__Response__c = '0';
        tran1.ChargentOrders__Response_Status__c = 'Approved';
        tran1.ChargentOrders__Type__c  = 'charge';
        tran1.ChargentOrders__Response_Message__c = 'Approved';
        tran.add(tran1);
        INSERT tran1;
   
    }   
    
    @isTest
    private static void myUnitTest_1() {
        
        testData();
        test.startTest();
        CreateScholarshipRefunds.Pricecal(opp.id);
        test.stopTest();     
        
    }
    
}