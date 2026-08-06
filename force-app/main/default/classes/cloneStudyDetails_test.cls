@isTest
public class cloneStudyDetails_test {
    
    static Account account ;
   
    static Study__c study;
    static Study_Account__c StudyAccount;
    static Study_Contact__c StudyContact;
    static Contact contact;
    
        
    static void testData(){ 
           
       
        
       study = new study__C(Name = 'test');
       insert study;
        
        account = new Account(Name = 'test');
        insert account;

        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
         
        StudyAccount = new Study_Account__c(Name = 'Test',Account__c = account.id,Study__c = study.id,Study_Fee_Type__c='Free');
        insert StudyAccount;


        StudyContact = new Study_Contact__c(Name ='test',Study_Account__c=StudyAccount.id,Study__c=study.id,Contact__c=contact.id,DP_Notification_Sent_At__c=null);
        insert StudyContact;
        
       
    }
    
    static testMethod void unitTest_1(){
        testData();
        test.startTest();
        ApexPages.currentPage().getParameters().put('Id',study.id);
        cloneStudyDetails clonedetails = new cloneStudyDetails(new ApexPages.StandardController(study));
        clonedetails.tempStudyRecord = study;
        cloneDetails.cloneStudyDetails();
        test.stopTest();
    }
}