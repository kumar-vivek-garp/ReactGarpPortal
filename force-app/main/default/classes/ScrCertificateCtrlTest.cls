@IsTest
public class ScrCertificateCtrlTest {

    @IsTest
    private static void loadCertificate(){
     
        Account account = new Account();
        account.Name = 'TEST';
        INSERT account;

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'test';
        contact.LastName = 'test';
        contact.Company__c = 'test inc.';
        INSERT contact;

        Contract contract = new Contract();
        contract.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program');
        contract.CustomerSignedId = contact.Id;
        contract.AccountId = account.Id;
        contract.All_Requirements_Completed_Date__c = Date.today();
        INSERT contract;

        contract.Status = 'Completed';
        UPDATE contract;

        Test.startTest();

        Test.setCurrentPage(Page.ScrCertificate); 
               
        System.currentPageReference().getParameters().put('id', contact.Id);

        ScrCertificateCtrl ctrl = new ScrCertificateCtrl();
        
        Test.stopTest();

    }

}