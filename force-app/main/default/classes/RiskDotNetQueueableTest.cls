@isTest
public class RiskDotNetQueueableTest {
    public static Account account;
    public static Contact contact;
    
    @isTest
    public static void RiskDotNetQueueable(){
        List<RiskDotNetUserCreation__c> settings = new List<RiskDotNetUserCreation__c>();
        RiskDotNetUserCreation__c setting1 = new RiskDotNetUserCreation__c();
        setting1.Name = 'id';
        setting1.Value__c = 'Test';
        settings.add(setting1);
        
        RiskDotNetUserCreation__c setting2 = new RiskDotNetUserCreation__c();
        setting2.Name = 'Name';
        setting2.Value__c = 'Test';
        settings.add(setting2);
        
        RiskDotNetUserCreation__c setting3 = new RiskDotNetUserCreation__c();
        setting3.Name = 'CompaniesId';
        setting3.Value__c = 'Test';
        settings.add(setting3);
        
        RiskDotNetUserCreation__c setting3b = new RiskDotNetUserCreation__c();
        setting3b.Name = 'CompaniesName';
        setting3b.Value__c = 'Test';
        settings.add(setting3b);
        
        RiskDotNetUserCreation__c setting4 = new RiskDotNetUserCreation__c();
        setting4.Name = 'GARP';
        setting4.Value__c = 'Test';
        settings.add(setting4);
        
        RiskDotNetUserCreation__c setting5 = new RiskDotNetUserCreation__c();
        setting5.Name = 'SubscriptionPrice';
        setting5.Value__c = 'Test';
        settings.add(setting5);
        
        RiskDotNetUserCreation__c setting6 = new RiskDotNetUserCreation__c();
        setting6.Name = 'SubscriptionVat';
        setting6.Value__c = 'Test';
        settings.add(setting6);
        
        RiskDotNetUserCreation__c setting7 = new RiskDotNetUserCreation__c();
        setting7.Name = 'SubscriptionSeats';
        setting7.Value__c = '1';
        settings.add(setting7);
        
        RiskDotNetUserCreation__c setting8 = new RiskDotNetUserCreation__c();
        setting8.Name = 'SubscriptionType';
        setting8.Value__c = 'Test';
        settings.add(setting8);
        
        RiskDotNetUserCreation__c setting9 = new RiskDotNetUserCreation__c();
        setting9.Name = 'subscription_type';
        setting9.Value__c = 'Test';
        settings.add(setting9);
        
        RiskDotNetUserCreation__c setting10 = new RiskDotNetUserCreation__c();
        setting10.Name = 'SubscriptionPaid';
        setting10.Value__c = '1';
        settings.add(setting10);
        
        RiskDotNetUserCreation__c setting11 = new RiskDotNetUserCreation__c();
        setting11.Name = 'SubscriptionCorp_offer';
        setting11.Value__c = '1';
        settings.add(setting11);
        
        RiskDotNetUserCreation__c setting12 = new RiskDotNetUserCreation__c();
        setting12.Name = 'subscriptionTrial';
        setting12.Value__c = '0';
        settings.add(setting12);
        
        RiskDotNetUserCreation__c setting13 = new RiskDotNetUserCreation__c();
        setting13.Name = 'SubscriptionInActive';
        setting13.Value__c = '1';
        settings.add(setting13);
        
        RiskDotNetUserCreation__c setting14 = new RiskDotNetUserCreation__c();
        setting14.Name = 'SubscriptionActive';
        setting14.Value__c = '0';
        settings.add(setting14);
        
        insert settings;
        
        
        account = new Account();
        account.Name = 'TEST CO';
        INSERT account;
        
        contact = new Contact();
        contact.Email = 'TEST@TEST.com';
        contact.FirstName = 'TEST';
        contact.LastName = 'TEST';
        contact.AccountId = account.Id;
        INSERT contact;
        
        Contract Program = new Contract(
            AccountId = account.Id,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Risk.Net'),
            Status = 'Draft',
            Name = 'test Program',
            StartDate = Date.today(),
            ContractTerm = 9999,
            CustomerSignedId = contact.id
        );
        
        insert program;
        
        // Test.setMock(HttpCalloutMock.class, new MockHttpRiskDotNet());
        Test.startTest();
        // need to review----
        RiskDotNetQueueable Risktest = new RiskDotNetQueueable(new Set<Id>{program.id} );
        System.enqueueJob(Risktest);
        Test.stopTest();
    }
}