@isTest//(SeeAllData=true) 
public with sharing class RiskDotNetUtilityTestClass {

    static Account account;
    static Opportunity opportunity;
    static Contact contact;
    
    @isTest
    public static void testData(){
        account = new Account(Name = 'test');
        insert account;
        
        System.debug('**account' + account);

        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com',
        KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17), GARP_Member_ID__c = '2342342');
        insert contact;

        opportunity = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,
                                      company__c = 'Payment', Billing_Email__c = 'test@test.com',accountId = account.id,
                                      stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15,
                                      Billing_First_Name__c='test', Billing_Last_Name__c = 'Name');        
        insert opportunity;
        
        System.debug('**opportunity' + opportunity);
        
    }

    @isTest
    public static void RiskDotNetCreateActiveUser() {
        testData();
        test.startTest();
        RiskDotNetUtilityClass c = new RiskDotNetUtilityClass();
        Opportunity opp = opportunity;
        
        System.debug('**opp' + opp);
        
        Contact con = Contact;
        Contract contract  = new Contract(ContractTerm =2,startDate = system.today()- 1,
                                          Membership_Type__c = 'Individual',recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Risk.Net'),
                                          Opportunity__c = opp.id,accountId = opp.AccountId, CustomerSignedId = con.id); 
        
        System.debug('**contract' + contract);
        
        insert contract;
        contract.Status = 'Activated';
        update contract;
        Test.setMock(HttpCalloutMock.class, new RiskDotNetMockHttpCallout(200));
        RiskDotNetUtilityClass.CreateUser(contract.id,con.id,'active');
        test.stopTest();
    }

    public static testMethod void RiskDotNetCreateInActiveUser() {
        testData();
        test.startTest();
        RiskDotNetUtilityClass c = new RiskDotNetUtilityClass();
        Opportunity opp = opportunity;
        Contact con = Contact;
        Contract contract  = new Contract(ContractTerm =2,startDate = system.today()- 1,Membership_Type__c = 'Individual',
                                          recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Risk.Net'),Opportunity__c = opp.id,
                                          accountId = opp.AccountId, CustomerSignedId = con.id); 
        insert contract;
        contract.Status = 'Canceled';
        update contract;
        Test.setMock(HttpCalloutMock.class, new RiskDotNetMockHttpCallout(200));
        RiskDotNetUtilityClass.CreateUser(contract.id,con.id,'Inactive');
        test.stopTest();
    }
    public static testMethod void RiskDotNetRetry() {
    	testData();
        test.startTest();
        RiskDotNetUtilityClass c = new RiskDotNetUtilityClass();
        Opportunity opp = opportunity;
        Contact con = Contact;
        Contract contract  = new Contract(ContractTerm =2,startDate = system.today()- 1,Membership_Type__c = 'Individual',
                                          recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Risk.Net'),Opportunity__c = opp.id,
                                          accountId = opp.AccountId, CustomerSignedId = con.id, Re_try__c = true); 
        insert contract;
        contract.Status = 'Activated';
        update contract;
        Test.setMock(HttpCalloutMock.class, new RiskDotNetMockHttpCallout(400));
        RiskDotNetUtilityClass.CreateUser(contract.id,con.id,'active');
        test.stopTest();
    }
}