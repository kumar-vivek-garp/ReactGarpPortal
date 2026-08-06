@isTest
public class sitePaymentGARPControllerB2B_test {
    
    static Account acc ;
    static Opportunity opp; 
    static ChargentOrders__Transaction__c chargentTrans;
    static TempAccount tempaccount;
    static Contact contact;
    static Lead lead;
    static ChargentOrders__Transaction__c payment1;
    static ChargentOrders__Transaction__c payment2;
    
    static void testData(){ 
                    
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Merchant_ID__c = 'dasghjtru548709-4',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
        Acc = new Account(Name = 'test');
        insert acc;
         
        opp = new Opportunity(amount = 123,Name = 'Test', company__c = 'Payment', accountId = acc.id, stageName = 'New Lead', closedate = system.today()+ 15, LEGACY_Purchase_Date__c  = system.today());        
        insert opp;
                      
        contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com');
        insert contact;
                      
        lead = new Lead(lastname = 'test',firstName = 'test' ,status = 'Open',email= 'test@test.com',company = acc.id);
        insert lead;
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opp.id);
        insert order;                       
        payment1 = new ChargentOrders__Transaction__c(Opportunity__c = opp.id,ChargentOrders__Order__c = order.id,ChargentOrders__Type__c= 'Charge', ChargentOrders__Response_Status__c= 'Approved',ChargentOrders__Amount__c =60, ChargentOrders__Payment_Method__c='Credit Card');
        payment2 = new ChargentOrders__Transaction__c(Opportunity__c = opp.id,ChargentOrders__Order__c = order.id,ChargentOrders__Type__c= 'Charge', ChargentOrders__Response_Status__c= 'Approved',ChargentOrders__Amount__c =60, ChargentOrders__Payment_Method__c='Check');
        insert new ChargentOrders__Transaction__c[]{ payment1,payment2};
            }
    
    static testMethod void unitTest_1(){
        testData();
        test.startTest();               
        ApexPages.currentPage().getParameters().put('id',opp.id);
        sitePaymentGARPControllerB2B invoice = new sitePaymentGARPControllerB2B();
        invoice.getNow();
        invoice.fetchData();
        sitePaymentGARPControllerB2B.opportunitywrapper wrap = new sitePaymentGARPControllerB2B.opportunitywrapper(opp);
        test.stopTest();
    }
 
}