@isTest
private class Payment_Test {

    @isTest
    private static void testAsVisa() {

        Payment payment = new Payment('4111111111111111', '123', '01', '2030');

        System.assertEquals('VISA', payment.CardType);

    }
    
    @isTest
    private static void testAsMasterCard() {

        Payment payment = new Payment('5105105105105100', '123', '01', '2030');

        System.assertEquals('MC', payment.CardType);

    }
    
    @isTest
    private static void testAsAmericanExpress() {

        Payment payment = new Payment('378282246310005', '123', '01', '2030');

        System.assertEquals('AMEX', payment.CardType);

    }
    
    @isTest
    private static void testAsDiscover() {

        Payment payment = new Payment('6011111111111117', '123', '01', '2030');

        System.assertEquals('DS', payment.CardType);

    }
    
    @isTest
    private static void testAsDinersClub() {

        Payment payment = new Payment('30569309025904', '123', '01', '2030');

        System.assertEquals('DC', payment.CardType);

    }
    
    @isTest
    private static void testCharge() {

        Account account = new Account();
        account.Name = 'TEST';
        INSERT account;

        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 100.00;
        opportunity.AccountId = account.Id;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'New Lead';
        opportunity.CloseDate = Date.today();
        INSERT opportunity;
        
        Payment payment = new Payment('4111111111111111', '123', '01', '2030');
        
		ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opportunity.id);
        insert order; 
        
        System.assertEquals('VISA', payment.CardType);
        
        payment.charge(opportunity.Id);

    }

    @isTest
    private static void testChargeBackupDisabled() {

        Default_Settings__c enableChargentBackup = new Default_Settings__c(Name = 'EnableChargentBackup', Active__c = FALSE);
        INSERT enableChargentBackup;

        Account account = new Account();
        account.Name = 'TEST';
        INSERT account;

        Opportunity opportunity = new Opportunity();
        opportunity.Amount = 100.00;
        opportunity.AccountId = account.Id;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'New Lead';
        opportunity.Company__c = 'GARP';
        opportunity.CloseDate = Date.today();
        INSERT opportunity;
        
        Payment payment = new Payment('4111111111111111', '123', '01', '2030');
        
		ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opportunity.id);
        insert order; 
        
        System.assertEquals('VISA', payment.CardType);
        
        payment.charge(opportunity.Id);

} 

    @isTest
    private static void testChargeBackupEnabled() {
                    
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(
                Name = 'test',
                ChargentBase__Merchant_ID__c = 'test',
                ChargentBase__Active__c = true 
        );
        INSERT chrgGtway;
    
        INSERT new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.Id);

        Paypalsettings__c prs = new Paypalsettings__c();
        prs.Partner__c = 'VeriSign';          
        prs.EndPoint__c = 'https://payflowpro.paypal.com';
        prs.Password__c = 'Test';
        prs.Paypal_GateWay_ID__c = chrgGtway.Id;
        prs.UserName__c = 'Test';
        prs.Vendor__c = 'Test';
        prs.name ='GARP';
        INSERT prs;

        Default_Settings__c enableChargentBackup = new Default_Settings__c(Name = 'EnableChargentBackup', Active__c = False);
        INSERT enableChargentBackup;

        Account account = new Account();
        account.Name = 'TEST';
        INSERT account;

        Opportunity opportunity = new Opportunity();
        opportunity.Gateway__c = chrgGtway.Id;
        opportunity.Amount = 100.00;
        opportunity.AccountId = account.Id;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'New Lead';
        opportunity.Company__c = 'GARP';
        opportunity.CloseDate = Date.today();
        INSERT opportunity;
        
        Payment payment = new Payment('4111111111111111', '123', '01', '2030');
		
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opportunity.id);
        insert order;   
        
        System.assertEquals('VISA', payment.CardType);
        
        payment.charge(opportunity.Id);

    }  

}