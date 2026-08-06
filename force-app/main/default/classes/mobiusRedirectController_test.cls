@isTest
public class mobiusRedirectController_test {
    static testMethod void unitTest_1(){
        //testData();
        test.startTest();  
        
        ApexPages.currentPage().getParameters().put('eBookType', 'FRM Exam Part I');
        mobiusRedirectController op = new mobiusRedirectController();
        op.ssoURL = 'http://www.google.com';
        op.redirect();
        
        
        test.stopTest();
        
    }


}