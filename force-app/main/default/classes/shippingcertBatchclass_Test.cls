@isTest
public class shippingcertBatchclass_Test {

     
    static Account a1;
    static Account a2;
    static Account a3;
    static Contact c1;
    static Contact c2;
    static Contact c3;
    static certificate_shipping__c cert;
    static certificate_shipping__c cert1;
    static certificate_shipping__c cert2;
    
    
    
    
    static void testData() {
        
        a1 = new Account(name = 'Test Account1');
        insert a1;
        
         a2 = new Account(name = 'Test Account2');
        insert a2;
        
         a3 = new Account(name = 'Test Account3');
        insert a3;
        
        c1 = new contact(lastname = 'Doe',firstname='John',AccountID = a1.ID,MailingCity='New York',Mailing_Address_Company__c='1234, New Port Mall',MailingCountry='US', email = 'JohnDoe@contact.com',OtherPhone='123456789',MailingPostalCode = '07301',MailingState='NJ', KPI_Member__c = True, Membership_Type__c = 'Individual',KPI_Membership_Payment_Status__c ='In Good Standing',GARP_Member_ID__c='101010');
        insert c1;
        
        c2 = new contact(lastname = 'Doe',firstname='John',AccountID = a2.ID,MailingCity='New York',Mailing_Address_Company__c='1234, New Port Mall',MailingCountry='GR', email = 'JohnDoe1@contact.com',OtherPhone='123456789',MailingPostalCode = '07301',MailingState='NJ', KPI_Member__c = True, Membership_Type__c = 'Individual',KPI_Membership_Payment_Status__c ='In Good Standing',GARP_Member_ID__c='101011');
        insert c2;
        
        
        c3 = new contact(lastname = 'Doe',firstname='John',AccountID = a3.ID,MailingCity='New York',Mailing_Address_Company__c='1234, New Port Mall',MailingCountry='IN', email = 'JohnDoe1@contact.com',OtherPhone='123456789',MailingPostalCode = '07301',MailingState='NJ', KPI_Member__c = True, Membership_Type__c = 'Individual',KPI_Membership_Payment_Status__c ='In Good Standing',GARP_Member_ID__c='101012');
        insert c3;
        
        cert = new certificate_shipping__c (Member__c=c1.id,CurrencyIsoCode = 'USD',Ups_Stage__c='New Order',Country_Code_for_UPS__c='US',Run_Now__c= true);
        insert cert;
        
        cert1 = new certificate_shipping__c (Member__c=c2.id,CurrencyIsoCode = 'USD',Ups_Stage__c='New Order',Country_Code_for_UPS__c='GR',Run_Now__c= true);
        insert cert1;
        
        cert2 = new certificate_shipping__c (Member__c=c3.id,CurrencyIsoCode = 'USD',Ups_Stage__c='New Order',Country_Code_for_UPS__c='IN',Run_Now__c= true);
        insert cert2;
        
        
    }
    
    static testMethod void unitTest_1(){
        
       
        test.startTest();
        testdata();
        shippingcertBatchclass b = new shippingcertBatchclass();
        ID batchprocessid  = Database.executeBatch(b);      
        test.stopTest();
              
        
    }
    
}