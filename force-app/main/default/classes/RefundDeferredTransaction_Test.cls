@isTest
private class RefundDeferredTransaction_Test {

    static Account acc ;
    static Opportunity opp; 
    static ChargentOrders__Transaction__c obj;     
    
    static Account acc1 ;
    static Opportunity opp1; 
    static ChargentOrders__Transaction__c obj1;     
        
        
    static void testData() {
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
        Acc = new Account(Name = 'test');
        insert acc;
         
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opp.id);
        insert order;
        
        
        List<ChargentOrders__Transaction__c> tranList = new List<ChargentOrders__Transaction__c>();
        obj = new ChargentOrders__Transaction__c(Opportunity__c=opp.Id,ChargentOrders__Order__c = order.id,ChargentOrders__Type__c='Charge',ChargentOrders__Response_Status__c='Approved');
        tranList.add(obj);
        
        
        ChargentBase__Gateway__c chrgGtway1 = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway1;
        
        insert new UpdateIds__c(Name = 'GARP1', Record_Id__c = chrgGtway1.id);
        
        Acc1 = new Account(Name = 'test1');
        insert acc1;
         
        opp1 = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc1.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp1;
        
        ChargentOrders__ChargentOrder__c order1 = new ChargentOrders__ChargentOrder__c(Opportunity__c = opp1.id);
        insert order1;
        
        obj1 = new ChargentOrders__Transaction__c(Opportunity__c=opp1.Id,ChargentOrders__Order__c = order1.id,ChargentOrders__Type__c='Charge Back Loss',ChargentOrders__Response_Status__c='Approved');
        tranList.add(obj1);
        insert tranList;
        
    }
    
    static testMethod void unitTest_1(){
        testData();
        ChargentOrderTransactionTriggerHandler.OppListToUpdate.clear();
        Apexpages.StandardController std = new Apexpages.StandardController(obj);
        RefundDeferredTransaction transaction1 = new RefundDeferredTransaction(std);
        transaction1.bPaidInFull = true;
        transaction1.saveTransaction();
        transaction1.CancelTransaction();
        transaction1.getItems();
    }
    
    static testMethod void unitTest_2(){
        testData();
        ChargentOrderTransactionTriggerHandler.OppListToUpdate.clear();
        Apexpages.StandardController std = new Apexpages.StandardController(obj1);
        RefundDeferredTransaction transaction2 = new RefundDeferredTransaction(std);
        transaction2.bPaidInFull = true;
        transaction2.saveTransaction();
        transaction2.CancelTransaction();
        transaction2.getItems();
    }
    
    }