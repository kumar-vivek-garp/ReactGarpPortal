@isTest
public class GBIPaymentRcptRdrctCntrlrTest {
	static Account acc ;
    static Contact contact;
    static User user;
    static Study__c study;
    static Study_Disclose_Protocol_Submission__c dp;
    static Study_Contact__c sc;
    static Study_Account__c sa;
    
    static void testData() {

        Acc = new Account(Name = 'test', GBI_Region__c='North America'); 
        insert acc;

        contact = new Contact(
            GBI_Participant__c = TRUE,
            KPI_ERP_Certified__c = TRUE,
            KPI_FRM_Certified__c = TRUE,
            GARP_Directory_Opt_In__c = TRUE,
            lastname = 'Test',
            AccountId = acc.id,
            email='test123123213124@test.com',
            KPI_ERP_Enrollment_Date__c = Date.newInstance(2022, 2, 17)
        );
        
        insert contact; 
        
        user = [select Id, Email from User where contactId = :contact.Id];
        
        study = new Study__c(Name='study1', Status__c='In Progress', Secure_File_Integration_Status__c = 'Enabled');
        insert study;
        
        sa = new Study_Account__c(Name='SA', Role__c='  Participant', Status__c='Active', Study__c=study.Id, Account__c=Acc.Id, Secure_File_Platform__c = 'ShareFile',Study_Fee_Type__c='Free');
        insert sa;

        sc = new Study_Contact__c(Role__c='Voter', Status__c='Active', Study__c=study.Id, Contact__c=contact.Id, Study_Account__c=sa.Id);
        insert sc;
    }
    
    static testMethod void testQueueJob(){
    	testData();
        test.startTest();
        dp = new Study_Disclose_Protocol_Submission__c(Name='dp', Study_Contact__c=sc.Id, Study__c=study.Id, Study_Account__c=sa.Id);
        insert dp;
        PageReference testPage = Page.GBIPaymentReceiptRedirect; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(dp.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(dp);     
        GBIPaymentRcptRdrctCntrlr ext = new GBIPaymentRcptRdrctCntrlr(sc);
        ext.doRedirect();
        test.stopTest();
    }
}