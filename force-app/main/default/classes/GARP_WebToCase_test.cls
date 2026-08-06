@isTest
public class GARP_WebToCase_test {

    
    @isTest
    static void unitTest_GARP_WebToCase(){

        test.startTest();              
                
        PageReference pageRef = Page.GARP_WebToCase; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('web_origin', 'HubSpot'); 
        ApexPages.currentPage().getParameters().put('first_name', 'first');
        ApexPages.currentPage().getParameters().put('last_name', 'last');
        ApexPages.currentPage().getParameters().put('email', 'email@email.com');
        ApexPages.currentPage().getParameters().put('garp_id', '12345678');
        ApexPages.currentPage().getParameters().put('subject', 'subject');
        ApexPages.currentPage().getParameters().put('description', 'description');
        ApexPages.currentPage().getParameters().put('recaptcha_token', 'ergertgertgertgherthet');
        ApexPages.currentPage().getParameters().put('first_name', 'first');
        
        GARP_WebToCase wabToCasepage = new GARP_WebToCase();
        wabToCasepage.initialize();
        
        test.stopTest();
    }
}