@IsTest
public class RaijCertificateCtrlTest {

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
        contract.RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','RAIJ_Program');
        contract.CustomerSignedId = contact.Id;
        contract.AccountId = account.Id;
        contract.All_Requirements_Completed_Date__c = Date.today();
        INSERT contract;

        contract.Status = 'Completed';
        UPDATE contract;

        Test.startTest();

        Test.setCurrentPage(Page.RaijCertificate);

        System.currentPageReference().getParameters().put('id', contact.Id);

        RaijCertificateCtrl ctrl = new RaijCertificateCtrl();

        Test.stopTest();

        System.assertEquals(null, ctrl.errorMessage, 'A completed RAIJ contract should render the certificate without an error.');
        System.assertEquals(contract.Id, ctrl.contract.Id, 'The RAIJ contract should be resolved for the certificate.');
    }

}