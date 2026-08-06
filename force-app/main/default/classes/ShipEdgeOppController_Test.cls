@isTest
public class ShipEdgeOppController_Test {
    
    @isTest static void UnitTest1(){
        
        Account acc=new Account(name='Test');
        insert acc;
        
        
        Opportunity Opp=new Opportunity(Name = 'Test',stageName = 'New Lead', CloseDate = Date.today(),accountid=acc.id,
                                        Display_Invoice_Number__c = '7896',Customs_Cost__c = '1200');
        insert Opp;
        Test.Starttest();
        ShipEdgeOppController.getShipEdgeGetOrderDetails((String)Opp.id);
        Test.Stoptest();
        
    }
    @isTest static void UnitTest2(){
        
        Account acc=new Account(name='Test');
        insert acc;
        
        
        Opportunity Opp=new Opportunity(Name = 'Test',stageName = 'New Lead', CloseDate = Date.today(),accountid=acc.id,
                                        Display_Invoice_Number__c = '7896',Customs_Cost__c = '1200',Has_Books__c = true);
        insert Opp;
        Test.Starttest();
        ShipEdgeOppController.getShipEdgeGetOrderDetails((String)Opp.id);
        Test.Stoptest();
        
    }
    @isTest static void UnitTest3(){
        
        Account acc=new Account(name='Test');
        insert acc;
        
        
        Opportunity Opp=new Opportunity(Name = 'Test',stageName = 'New Lead', CloseDate = Date.today(),accountid=acc.id,
                                        Display_Invoice_Number__c = '7896',Customs_Cost__c = '1200',Has_Books__c = true,Ship_Edge_Order_Id__c = 'Test');
        insert Opp;
        Test.Starttest();
        ShipEdgeOppController.getShipEdgeGetOrderDetails((String)Opp.id);
        Test.Stoptest();
        
    }
}