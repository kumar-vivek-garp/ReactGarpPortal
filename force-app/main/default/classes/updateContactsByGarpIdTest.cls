@isTest
public class updateContactsByGarpIdTest {
    @testSetup
    static void setupData() { 
        
        // Create Contact with GARP_Member_ID__c
        Contact con = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            HomePhone = '1234567890',
            OtherPhone = '0987654321',
            MailingCity = 'New York',
            MailingCountry = 'United States',
            MailingPostalCode = '10001',
            MailingState = 'NY',
            Mailing_Address_Company__c = 'GARP',
            GARP_Member_ID__c = 'GARP123'
        );
        insert con;
    }
    
    @isTest
    static void testBeforeInsertWithMatchingGarpId() {
        Contact con = [SELECT GARP_Member_ID__c FROM Contact LIMIT 1];
        
        certificate_shipping__c cert = new certificate_shipping__c(
            Garp_id__c = con.GARP_Member_ID__c,
            Tracking_Number__c = 'TRACK123', 
            Do_not_fire__c = false,
			Member__c = con.Id
        );
        
        insert cert;
        
        certificate_shipping__c insertedCert = [SELECT Member_Shipping_Attention__c, Member_Shipping_City__c, 
                                                Member_Shipping_Company_Name__c, Member_Shipping_Country__c, 
                                                Member_Shipping_E_mail__c, Member_Shipping_Phone_No__c,
                                                Member_Shipping_Postal_Code__c, Member_Shipping_State__c,
                                                Country_Code_for_UPS__c, Shipping_Adress1__c, Shipping_Address2__c, Shipping_Address3__c
                                                FROM certificate_shipping__c WHERE Id = :cert.Id];
        
        System.assertEquals('John Doe', insertedCert.Member_Shipping_Attention__c);
        System.assertEquals('New York', insertedCert.Member_Shipping_City__c);
        System.assertEquals('GARP', insertedCert.Member_Shipping_Company_Name__c);
        System.assertEquals('United States', insertedCert.Member_Shipping_Country__c);
        System.assertEquals('john.doe@example.com', insertedCert.Member_Shipping_E_mail__c);
        System.assertEquals('1234567890', insertedCert.Member_Shipping_Phone_No__c);
        System.assertEquals('10001', insertedCert.Member_Shipping_Postal_Code__c);
        System.assertEquals('NY', insertedCert.Member_Shipping_State__c);  
    }
    
    @isTest
    static void testBeforeUpdateTrackingNumberChange() {
        Contact con = [SELECT GARP_Member_ID__c FROM Contact LIMIT 1];
        
        certificate_shipping__c cert = new certificate_shipping__c(
            Garp_id__c = con.GARP_Member_ID__c, 
            Member__c = con.Id,
            Do_not_fire__c = false
        );
        insert cert;
        
        cert.Tracking_Number__c = 'NEWTRACK001';
        update cert;
        
        certificate_shipping__c updatedCert = [SELECT Member_Shipping_Attention__c, Tracking_Number__c, Shipping_Adress1__c FROM certificate_shipping__c WHERE Id = :cert.Id];
        System.assertEquals('John Doe', updatedCert.Member_Shipping_Attention__c); 
    }
     
}