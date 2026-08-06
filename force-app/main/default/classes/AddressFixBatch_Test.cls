@isTest
public class AddressFixBatch_Test {

@isTest
    static void unitTest(){
        
        Account account = new Account();
        account.Name = 'TEST Account';
        account.BillingStreet = 'Test0\nTest1\nTest1\r\n';
        account.ShippingStreet = 'Test0\nTest1\nTest1\r\n';
        INSERT account;
        
        Contact contact = new Contact();
        contact.Email = 'TEST@TEST.com';
        contact.FirstName = 'TEST';
        contact.LastName = 'TEST';
        contact.AccountId = account.Id;
        contact.MailingStreet = 'Test0\nTest1\nTest1\r\n';
        INSERT contact;
        
        Test.startTest();
        
        system.schedule('Test Schedule','0 0 0 * * ?',new scheduleAddressFixBatch());
        Contact contact1 = new Contact();
        contact1.Email = 'TEST@TEST.com';
        contact1.FirstName = 'TEST';
        contact1.LastName = 'TEST';
        contact1.AccountId = account.Id;
        contact1.MailingStreet = 'Test0\nTest1\r\n';
        INSERT contact1;
        AddressFixBatch batch = new AddressFixBatch(''); 
        database.executebatch(batch,1);
        Test.stopTest();
        
    }

}