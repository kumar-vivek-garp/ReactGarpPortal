@isTest
public class ChargentOrderTransactionTgrHdler_Test {
	    
    @isTest
    static void UnitTest(){
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
    	ChargentOrderTransactionTriggerHandler ctth = new ChargentOrderTransactionTriggerHandler();
        
        ChargentOrders__ChargentOrder__c order = [Select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: opp.id];
        
        ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
        trans.Opportunity__c = opp.Id;
        trans.ChargentOrders__Amount__c = 150;
        trans.ChargentOrders__Order__c = order.id;
        trans.ChargentOrders__Response_Message__c = 'Approved';
        trans.ChargentOrders__Response_Status__c = 'Approved';
        trans.ChargentOrders__Type__c = 'Charge';
        trans.ChargentOrders__Gateway_Date__c =system.now();
        insert trans;
        
        
        Test.startTest();
        ctth.beforeInsert((SObject)trans);
        ctth.beforeDelete((SObject)trans);
        ctth.afterDelete((SObject)trans);
        
		ChargentOrders__Transaction__c trans1 = [select id,ChargentOrders__Type__c,ChargentOrders__Amount__c from ChargentOrders__Transaction__c where ChargentOrders__Type__c = 'Charge'];
        trans1.ChargentOrders__Amount__c = 140;
        trans1.ChargentOrders__Type__c ='Void';
        trans1.ChargentOrders__Order__c = order.id;
        trans1.ChargentOrders__Recurring__c = false;
        trans1.ChargentOrders__Payment_Method__c = 'Free';
        trans.ChargentOrders__Type__c = 'Refund';
        update trans1;
        ctth.afterUpdate((SObject)trans,(SObject)trans1);   
        ctth.beforeUpdate((SObject)trans,(SObject)trans1);   
        Test.stopTest();
        
    }
    
    
    @isTest
    static void UnitTest1(){
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                          company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        Opportunity opp1 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                          company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 2);
        insert opp1;
        
    	ChargentOrderTransactionTriggerHandler ctth = new ChargentOrderTransactionTriggerHandler();
        
        ChargentOrders__ChargentOrder__c order = [Select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: opp.id];
        
        ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
        trans.Opportunity__c = opp.Id;
        trans.ChargentOrders__Amount__c = 150;
        trans.ChargentOrders__Order__c = order.id;
        trans.ChargentOrders__Response_Message__c = 'Approved';
        trans.ChargentOrders__Response_Status__c = 'Approved';
        trans.ChargentOrders__Type__c = 'Refund';
        trans.ChargentOrders__Gateway_Date__c =system.now();
        insert trans;
        
        Test.startTest();
        ctth.beforeInsert((SObject)trans);
        ChargentOrderTransactionTriggerHandler.stopRecurssion = true;
        trans.Opportunity__c = opp1.id;
        update trans;
        Test.stopTest();
        
    }
    
    @isTest
    static void UnitTest3(){
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
    	ChargentOrderTransactionTriggerHandler ctth = new ChargentOrderTransactionTriggerHandler();
        
        ChargentOrders__ChargentOrder__c order = [Select id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c =: opp.id];
        
        ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
        trans.Opportunity__c = opp.Id;
        trans.ChargentOrders__Amount__c = 150;
        trans.ChargentOrders__Order__c = order.id;
        trans.ChargentOrders__Response_Message__c = 'Approved';
        trans.ChargentOrders__Response_Status__c = 'Approved';
        trans.ChargentOrders__Type__c = 'Charge';
        trans.ChargentOrders__Gateway_Date__c =system.now();
        trans.ChargentOrders__Amount__c = 140;
        trans.ChargentOrders__Type__c ='Charge';
        trans.ChargentOrders__Order__c = order.id;
        trans.ChargentOrders__Recurring__c = false;
        trans.ChargentOrders__Payment_Method__c = 'Credit Card';
        trans.ChargentOrders__Type__c = 'Charge';
        insert trans;
        
        
        Test.startTest();
        ctth.beforeInsert((SObject)trans);
        ctth.beforeDelete((SObject)trans);
        ctth.afterDelete((SObject)trans);
            
        Test.stopTest();
        
    }
    
    
    
}