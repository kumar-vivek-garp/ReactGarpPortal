@isTest
public class TRRPrintAsPDFController_Test {
    
    static testMethod void unitTest_1(){
        test.startTest(); 
        Tuition_Reimbursement_Request__c trr = new Tuition_Reimbursement_Request__c(Information_Subject_to_Tax__c=True,Taxation_Acknowledgement__c=True,Tuition_Acknowledgement__c= true,Approval_Validity__c= true);
        insert trr;
        String trrId = ApexPages.currentPage().getParameters().put('id',trr.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(trr);
        TRRPrintAsPDFController trrpdf = new TRRPrintAsPDFController(sc);
        trrpdf.getNow();
        trrpdf.fetchData();
        test.stopTest();
    }
}