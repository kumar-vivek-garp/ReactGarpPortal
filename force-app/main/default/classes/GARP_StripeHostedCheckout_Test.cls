@isTest
public class GARP_StripeHostedCheckout_Test {

    /** Minimal Opportunity with Account (mirrors GARP_StripeClass_Test). */
    private static Opportunity newStripeTestOpportunity() {
        Account acc = new Account(Name = 'StripeTestAcct', Member_First_Name__c = 'Test', Member_Last_Name__c = 'User');
        insert acc;
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Stripe Test Order',
            StageName = 'New Lead',
            CloseDate = System.today() + 15,
            Amount = 100,
            Billing_Email__c = 'stripeopp@test.com',
            Display_Invoice_Number__c = 'W999',
            Program__c = 'Print',
            company__c = 'Payment',
            Eligible_for_Membership_Extension__c = false,
            Auto_Renew__c = false
        );
        insert opp;
        return [
            SELECT Id, Name, Display_Invoice_Number__c, Amount, Billing_Email__c, Auto_Renew__c,
                   Account.Member_First_Name__c, Account.Member_Last_Name__c,
                   Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Postal_Code__c, Shipping_Country__c, Shipping_Phone_No__c,
                   Billing_Address__c, Billing_City__c, Billing_State_Text__c, Billing_Zip_Postal__c, Billing_Country__c, Billing_Phone__c,
                   (SELECT Id, TotalPrice, Product2.ProductCode, Product2.Name, Product2.Stripe_Tax_Code__c FROM OpportunityLineItems)
            FROM Opportunity WHERE Id = :opp.Id
        ];
    }

    @isTest
    static void testHostedCheckout_NoTax() {
        GARP_StripeSettings__c ss = new GARP_StripeSettings__c(
            Name = 'StripeSettings', Is_Active__c = true, Use_Stripe__c = true,
            Server_Side_API_Key__c = 'sk_test_xxx', Client_Side_API_Key__c = 'pk_test_xxx',
            Default_Product_ID__c = 'prod_test');
        insert ss;

        Opportunity opp = newStripeTestOpportunity();

        Test.startTest();
        GARP_StripeClass.returnInitializeStripeCheckoutSession ret =
            GARP_StripeHostedCheckout.initializeCheckoutSession(opp, 'https://example.com/checkout?id=1');
        Test.stopTest();

        System.assertEquals('Success', ret.status, 'Hosted session should be created');
        System.assertNotEquals(null, ret.respCreateSession, 'Expected a session payload');
        System.assertNotEquals(null, ret.respCreateSession.url, 'Hosted session must return a redirect url');
    }

    @isTest
    static void testHostedCheckout_StripeTaxBranch() {
        GARP_StripeSettings__c ss = new GARP_StripeSettings__c(
            Name = 'StripeSettings', Is_Active__c = true, Use_Stripe__c = true, Use_Stripe_Tax__c = true,
            Server_Side_API_Key__c = 'sk_test_xxx', Client_Side_API_Key__c = 'pk_test_xxx',
            Default_Product_ID__c = 'prod_test');
        insert ss;

        Opportunity opp = newStripeTestOpportunity();

        Test.startTest();
        // No line items + no shipping exercises the automatic_tax / billing-address branch.
        GARP_StripeClass.returnInitializeStripeCheckoutSession ret =
            GARP_StripeHostedCheckout.initializeCheckoutSession(opp, null);
        Test.stopTest();

        System.assertEquals('Success', ret.status, 'Tax-branch hosted session should be created');
        System.assertNotEquals(null, ret.respCreateSession.url);
    }

    @isTest
    static void testHostedCheckout_NullOpp() {
        GARP_StripeClass.returnInitializeStripeCheckoutSession ret =
            GARP_StripeHostedCheckout.initializeCheckoutSession(null, null);
        System.assertEquals('Failure', ret.status);
        System.assertEquals('Required params missing', ret.message);
    }

    @isTest
    static void testAutoRenew_RequiresMember() {
        GARP_StripeSettings__c ss = new GARP_StripeSettings__c(
            Name = 'StripeSettings', Is_Active__c = true, Use_Stripe__c = true,
            Server_Side_API_Key__c = 'sk_test_xxx', Client_Side_API_Key__c = 'pk_test_xxx');
        insert ss;

        // Running test user is not a Customer Community member -> guard path.
        GARP_StripeClass.returnInitializeStripeCheckoutSession ret =
            GARP_StripeHostedCheckout.initializeEnableAutoRenewSession('https://example.com/checkout');
        System.assertEquals('Failure', ret.status);
    }
}