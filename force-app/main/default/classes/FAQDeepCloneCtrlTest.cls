@isTest
public class FAQDeepCloneCtrlTest {

    @testSetup
    public static void setup(){

		FAQ_Category__c faqc = new FAQ_Category__c();        
        faqc.Name = 'TESTFAQC';        
        INSERT faqc;
        
        FAQ_Section__c faqs = new FAQ_Section__c();        
        faqs.Name = 'TESTFAQS';
        faqs.FAQ_Category__c = faqc.Id;
        INSERT faqs;
        
        FAQ_Subsection__c faqss = new FAQ_Subsection__c();
   		faqss.Name = 'TESTFAQSS';
        faqss.FAQ_Category__c = faqc.Id;
        faqss.FAQ_Section__c = faqs.Id;
        INSERT faqss;
             
        Frequently_Asked_Questions__c frequentlyAskedQuestions = new Frequently_Asked_Questions__c();
        frequentlyAskedQuestions.Name = 'TESTFREQUENTLYASKEDQUESTIONS';
        frequentlyAskedQuestions.FAQ_Category__c = faqc.Id;
        frequentlyAskedQuestions.FAQ_Section__c = faqs.Id;
        frequentlyAskedQuestions.FAQ_Subsection__c = faqss.Id;
        INSERT frequentlyAskedQuestions;
        
    }
    
    @isTest
    public static void pass(){
        
        PageReference currentPageRef = Page.FolderDeepClone;
        
        Test.setCurrentPage(currentPageRef);  
        
        currentPageRef.getParameters().put('id', [SELECT Id, Name FROM FAQ_Category__c WHERE Name = 'TESTFAQC' LIMIT 1].Id);
               
        FAQDeepCloneCtrl ctrl = new FAQDeepCloneCtrl(new ApexPages.StandardController([SELECT Id, Name FROM FAQ_Category__c WHERE Name = 'TESTFAQC' LIMIT 1]));    
        
        PageReference nextPageReference = ctrl.doDeepClone();
        
        Test.setCurrentPage(nextPageReference);
                
    }
      
}