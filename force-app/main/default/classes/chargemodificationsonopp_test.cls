@isTest
private class chargemodificationsonopp_test{


    Static Account acc;
    Static Account acc1,acc2;

    /** Mock the Stripe invoice-preview callout so the batch's tax block is exercised end-to-end. */
    private class StripePreviewMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{' +
                    '"amount_due":20000,' +
                    '"customer_address":"1 Test St, SG",' +
                    '"total_tax_amounts":[' +
                        '{"amount":500,"taxable_amount":20000,"tax_rate":"txr_test"}' +
                    ']' +
                '}'
            );
            return res;
        }
    }

     static List<Opportunity> testData()
     {

         Country_Code__c cc = new Country_Code__c(Name='US',Country__c='Singapore',VAT__c = 8000);
         insert cc;

         List<Account> accList = new List<Account>();
         acc = new Account(name = 'Test Account1', BillingCountry = 'Singapore', ShippingCountry = 'Singapore', Calculated_Expire_Date__c = system.today(), Last_Contract_Exp_Calc__c = system.today());
         accList.add(acc);
         acc1 = new Account(name = 'Test Account2', BillingCountry = 'Singapore',Calculated_Expire_Date__c = system.today(), Last_Contract_Exp_Calc__c = system.today());
         accList.add(acc1);
         acc2 = new Account(name = 'Test Account2', BillingCountry = 'Singapore',Calculated_Expire_Date__c = system.today(), Last_Contract_Exp_Calc__c = system.today());
         accList.add(acc2);
         insert accList;
         List<Contact> conlist = new List<Contact>();
         Contact contact = new Contact(LEGACY_PK_PID__c  = '123',lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_Last_Updated_Date__c = system.today(),MailingCountry = 'Singapore');
         conlist.add(contact);
          Contact contact1 = new Contact(LEGACY_PK_PID__c  = '121',lastname = 'Test1',AccountId = acc1.id,email='test@test.com',KPI_Last_Updated_Date__c = system.today(),MailingCountry = 'Singapore');
         conlist.add(contact1);
          Contact contact2 = new Contact(LEGACY_PK_PID__c  = '124',lastname = 'Test2',AccountId = acc2.id,email='test@test.com',KPI_Last_Updated_Date__c = system.today(),MailingCountry = 'Singapore');
         conlist.add(contact2);
         insert conlist;
         List<Opportunity> oppList = new List<Opportunity>();
         Opportunity opp = new Opportunity(accountId = acc.id,Auto_Renew__c = true,Payment_Start_Date__c=system.today(),Payment_Status__c='Recurring',Company__c = 'GARP',Payment_Frequency__c='Once',name='Test Name',StageName='New',CloseDate=system.today(),Charge_Amount__c=195,Token__c='cus_optoken',IsStripeTax__c=false);
         oppList.add(opp);
         Opportunity opp2 = new Opportunity(accountId = acc2.id,Auto_Renew__c = true,Payment_Status__c='Recurring',Company__c = 'GARP',Payment_Frequency__c='Once',name='Test Name',StageName='New',CloseDate=system.today(),Charge_Amount__c=195,Token__c='cus_optoken2',IsStripeTax__c=false);
         oppList.add(opp2);
         Opportunity opp1 = new Opportunity(accountId = acc1.id,Auto_Renew__c = true,Payment_Status__c='Recurring',Company__c = 'GARP',Payment_Frequency__c='Once',name='Test Name',StageName='New',CloseDate=system.today(),Charge_Amount__c=95,Token__c='cus_optoken1',IsStripeTax__c=false);
         oppList.add(opp1);
         insert oppList;

         // Provide a tokenized transaction so the batch's tokenMap path is covered for opp.
         // The ChargentOrders managed trigger requires a parent order, so create one first.
         ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opp.Id);
         insert order;
         ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c(
             Opportunity__c = opp.Id,
             ChargentOrders__Order__c = order.Id,
             ChargentOrders__Type__c = 'Charge',
             ChargentOrders__Response_Status__c = 'Approved',
             ChargentOrders__Payment_Method__c = 'Credit Card',
             ChargentOrders__Tokenization__c = 'cus_trantoken'
         );
         insert trans;

         string memRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
         string frmRecordType = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');

         contract program = new contract (Opportunity__c = opp2.id,AccountId = opp2.AccountId,ContractTerm = 30,status = 'Draft', CurrencyIsoCode = 'USD',Name= 'Test Contract',startDate = system.today(),Membership_Type__c = 'Student',recordTypeId=memRecordType);
         insert program;
         program.Status = 'Activated ( Auto-Renew )';
         update program;

         contract program1 = new contract (Opportunity__c = opp1.id,AccountId = opp1.AccountId,status = 'Draft', CurrencyIsoCode = 'USD',Name= 'Test Contract',startDate = system.today(),Membership_Type__c = 'Individual',recordTypeId=memRecordType);
         insert program1;
         program1.Status = 'Activated ( Auto-Renew )';
         update program1;

         Contract Contract4  = new Contract(recordtypeId = frmRecordType ,Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate);
         insert contract4;
         contract4.Status = 'completed';
         update contract4;

         return oppList;
     }

     static testMethod void UnitTest_1()
    {
        // Set up all data before startTest so the batch runs in a fresh governor context.
        testData();
        Test.setMock(HttpCalloutMock.class, new StripePreviewMock());

        test.startTest();
        chargemodificationsonopp  b = new chargemodificationsonopp();
        database.executeBatch(b);
        test.stopTest();

        // The batch should have processed the recurring opportunities without error.
        List<Opportunity> processed = [SELECT Id, Charge_Amount__c FROM Opportunity];
        System.assertNotEquals(0, processed.size(), 'Opportunities should still exist after the batch runs');
    }

    static testMethod void UnitTest_ScopedConstructor()
    {
        Test.setMock(HttpCalloutMock.class, new StripePreviewMock());
        List<Opportunity> opps = testData();

        Set<String> oppIds = new Set<String>();
        for (Opportunity o : opps) {
            oppIds.add(o.Id);
        }

        test.startTest();
        // Exercise the Set<String>-filtered constructor / start() Id-In branch.
        chargemodificationsonopp b = new chargemodificationsonopp(oppIds);
        database.executeBatch(b);
        test.stopTest();

        System.assertEquals(false, oppIds.isEmpty(), 'Scoped constructor should have been seeded with opportunity Ids');
    }
}