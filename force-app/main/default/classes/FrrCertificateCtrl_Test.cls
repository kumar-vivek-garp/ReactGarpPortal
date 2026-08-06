@isTest
public class FrrCertificateCtrl_Test {
	
    @isTest
    static void Unittest_FRR1(){
        
        Account acc = new Account(Name = 'test');
        insert acc;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',FirstName='test2',
                                      GARP_Member_ID__c = '10515');
        insert contact;
        
        Contract contract = new Contract();
        contract.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract','ICBRR Program');
        contract.CustomerSignedId = contact.Id;
        contract.Status = 'Draft';
        contract.AccountId = acc.Id;
        contract.All_Requirements_Completed_Date__c = Date.today();
        INSERT contract;
        
        ApexPages.currentPage().getParameters().put('id',contact.id);
        
        Test.startTest();
        
        FrrCertificateCtrl Frrc = new FrrCertificateCtrl ();  
        Frrc.displayDay = 'Monday';
        Frrc.displayMonth = 'July';
        Frrc.displayYear = '2022';
        Frrc.allCompleteDate = Date.today();
        Frrc.contract = contract;
        
        Test.stopTest();
    }
    
    //For Empty Contract 
    @isTest
    static void Unittest_FRR2(){
        
        Test.startTest();
        FrrCertificateCtrl Frrc = new FrrCertificateCtrl ();
        Test.stopTest();
    }
    
    @isTest
    static void Unittest_FRR251(){
        
        Account acc = new Account(Name = 'test');
        insert acc;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',FirstName='test2',
                                      GARP_Member_ID__c = '10515');
        insert contact;
        
        Contract contract = new Contract();
        contract.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract','FRR25 Program');
        contract.CustomerSignedId = contact.Id;
        contract.Status = 'Draft';
        contract.AccountId = acc.Id;
        contract.All_Requirements_Completed_Date__c = Date.today();
        INSERT contract;
        
        ApexPages.currentPage().getParameters().put('id',contact.id);
        
        Test.startTest();
        
        Frr25CertificateCtrl Frrc = new Frr25CertificateCtrl();  
        Frrc.displayDay = 'Monday';
        Frrc.displayMonth = 'July';
        Frrc.displayYear = '2022';
        Frrc.allCompleteDate = Date.today();
        Frrc.contract = contract;
        
        Test.stopTest();
    }
    
    //For Empty Contract 
    @isTest
    static void Unittest_FRR252(){
        
        Test.startTest();
        Frr25CertificateCtrl Frrc = new Frr25CertificateCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void Unittest_FRRMicro1(){
        
        Account acc = new Account(Name = 'test');
        insert acc;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',FirstName='test2',
                                      GARP_Member_ID__c = '10515');
        insert contact;
        
        Contract contract = new Contract();
        contract.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract','FRR MC1 Program');
        contract.CustomerSignedId = contact.Id;
        contract.Status = 'Draft';
        contract.AccountId = acc.Id;
        contract.All_Requirements_Completed_Date__c = Date.today();
        INSERT contract;
        
        ApexPages.currentPage().getParameters().put('id',contact.id);
        ApexPages.currentPage().getParameters().put('type','FRRMC1');
        
        Test.startTest();
        
        MicroCourseCertificateCtrl Frrc = new MicroCourseCertificateCtrl();  
        Frrc.displayDay = 'Monday';
        Frrc.displayMonth = 'July';
        Frrc.displayYear = '2022';
        Frrc.allCompleteDate = Date.today();
        Frrc.contract = contract;
        
        Test.stopTest();
    }
    
    //For Empty Contract 
    @isTest
    static void Unittest_FRRMicro2(){
        
        Test.startTest();
        MicroCourseCertificateCtrl Frrc = new MicroCourseCertificateCtrl();
        Test.stopTest();
    }
}