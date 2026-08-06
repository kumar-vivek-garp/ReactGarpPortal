@isTest
public class TCARPrintAsPDFController_Test {
    
    static testMethod void unitTest_1(){
        test.startTest(); 
        Training_Course_Reimbursement_Request__c tcr = new Training_Course_Reimbursement_Request__c(Acknowledgment__c = true,Tuition_Acknowledgement__c=true,Approval_Validity__c=true);
        insert tcr;
        String tcrId = ApexPages.currentPage().getParameters().put('id',tcr.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(tcr);
        TCARPrintAsPDFController tcrpdf = new TCARPrintAsPDFController(sc);
        tcrpdf.getNow();
        tcrpdf.fetchData();
        test.stopTest();
    }
}