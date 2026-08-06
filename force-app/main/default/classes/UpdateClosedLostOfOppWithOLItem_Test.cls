@isTest
public class UpdateClosedLostOfOppWithOLItem_Test {
    
    @isTest
    static void unitTest(){
        
        Account acc=new Account(name='Test');
        insert acc;
        
        
        Opportunity Opp=new Opportunity(Name = 'Test',stageName = 'New Lead', CloseDate = Date.today().adddays(-4),accountid = acc.id);
        insert Opp;
        
        Pricebook2 activePricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = TRUE
        );
        
        UPDATE activePricebook;
        
        Product2 Prod1 = new Product2(Name = 'FRM 1 Early', Customs_Cost__c='5',productCode = 'FRM1',Is_Shippable__c = TRUE, GL_Code__c = '4020', Family = 'Hardware', isActive = true);
        INSERT Prod1; 
        
        Product2 Prod2 = new Product2(Name = 'FRM 1 Early', Customs_Cost__c='5',productCode = 'FRM1',Is_Shippable__c = TRUE, GL_Code__c = '4002', Family = 'Hardware', isActive = true);
        INSERT Prod2; 
        
        PricebookEntry PE1 = new PricebookEntry(Pricebook2Id = activePricebook.Id, Product2Id = Prod1.Id, UnitPrice = 425.00, IsActive = true);
        INSERT PE1;
        
        
        OpportunityLineItem oppli1 = new OpportunityLineItem();
        oppli1.Quantity=5;
        oppli1.OpportunityId=opp.Id;
        oppli1.UnitPrice = PE1.UnitPrice;
        oppli1.product2id= Prod1.Id;
        oppli1.PriceBookEntryId = PE1.Id;
        INSERT oppli1;
        
        OpportunityLineItem oppli2 = new OpportunityLineItem();
        oppli2.Quantity=5;
        oppli2.OpportunityId=opp.Id;
        oppli2.UnitPrice = PE1.UnitPrice;
        oppli2.product2id= Prod2.Id;
        oppli2.PriceBookEntryId = PE1.Id;
        INSERT oppli2;
        
        Test.setCreatedDate(opp.id, Date.today().adddays(-6));
        Test.startTest();
        
        UpdateClosedLostOfOppWithOLItem_BatSch sch = new UpdateClosedLostOfOppWithOLItem_BatSch();
        system.schedule('Test Schedule','0 0 0 * * ?',sch);
        Test.stopTest();
        
    }
}