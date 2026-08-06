@isTest
public class sendCertificateOfAttendanceBatch_Test {
	@isTest
    static void testBatch(){
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        Certificate_of_Attendance__c coa = new Certificate_of_Attendance__c();
        coa.Contact_Name__c = contact.id;
        insert coa;
        
        test.startTest();
        SendCPDAttendanceEmailsCntrlr.sendEmailBatch();
        //Database.executeBatch(new sendCertificateOfAttendanceBatch());
        test.stopTest();
    }
}