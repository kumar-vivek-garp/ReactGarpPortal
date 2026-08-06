@isTest
public class CPDCertificate_Test {

    static contact contact;
    static contact contact1;
    static Account account;
    static Contract cont;
     
       @isTest 
    public static void testData(){
       
        account = new Account(Name = 'test');
        insert account;
        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com', KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17), KPI_ERP_Certified_Year__c = '2018');
        insert contact;

        contact1 = new Contact(lastname = 'Test1',AccountId = account.id,email='test1@test.com',KPI_SCR_Holder__c=true, KPI_SCR_Completion_Date__c = Date.newInstance(2009, 2, 17));
        insert contact1;
        
       Test.StartTest(); 

       PageReference pageRef = Page.CPDCertificate_FRM_ERP;
       pageRef.getParameters().put('id',contact.id);
       Test.setCurrentPage(pageRef); 
       CPDCertificateCtrl badge = new CPDCertificateCtrl();
        
      Test.StopTest();  
       
    }

}