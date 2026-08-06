@isTest
public class DeferralExtensionRequestCtrlTest {
    
    @testSetup
    private static void testSetup(){
        
        Account account = new Account(
            Name = 'TEST CO'
        );
        
        INSERT account;
        
        Contact contact = new Contact(
            FirstName = 'TESTQA',
            LastName = 'TESTQA',
            Email = 'testqa@tesqa.com'
        );
        
        INSERT contact;
        
        Form__c form = new Form__c(
            Name = 'deferral-frm-nov-2025', 
            Form_Name__c = 'deferral-frm-nov-2025',
            Status__c = 'Active'
        );
        
        INSERT form;
        
    }
    
    @isTest
    private static void loadPageWithValidId(){
        
        Test.startTest();
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        PageReference deferralExtensionRequest = Page.DeferralExtensionRequest;
        Test.setCurrentPage(deferralExtensionRequest);

        ApexPages.currentPage().getParameters().put('id', contact.Id);
        
        DeferralExtensionRequestCtrl extension = new DeferralExtensionRequestCtrl();
        
        Test.stopTest();
        
        System.assertEquals(
            contact.Id, 
            extension.contact.Id, 
            'It should be able to located a Contact using the provided ID.'
        );
        
    }
    
    @isTest
    private static void loadPageWithValidIdMakeSelectionAndSubmit(){
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();

        PageReference deferralExtensionRequest = Page.DeferralExtensionRequest;
        Test.setCurrentPage(deferralExtensionRequest);

        ApexPages.currentPage().getParameters().put('id', contact.Id);
        
        DeferralExtensionRequestCtrl extension = new DeferralExtensionRequestCtrl();
        
        extension.submit();
                
        Test.stopTest();
        
        System.assertEquals(
            1, 
            [SELECT Id FROM Form_Data__c].size(), 
            'It should have the Form Data after the form is submitted.'
        );
        
    }
    
    @isTest
    private static void loadPageWithInvalidId(){
        
        Test.startTest();
        
        String contactId = '0034000001xoy4j';
        
        PageReference deferralExtensionRequest = Page.DeferralExtensionRequest;
        Test.setCurrentPage(deferralExtensionRequest);

        ApexPages.currentPage().getParameters().put('id', contactId);
        
        DeferralExtensionRequestCtrl extension = new DeferralExtensionRequestCtrl();
        
        Test.stopTest();
        
        System.assertEquals(
            'There is no account associated with this ID.', 
            extension.message, 
            'There is no account associated with this ID.'
        );
        
    }
    
    @isTest
    private static void loadPageWithValidIdAndDeferralExtensionRequstedOnSet(){
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Form__c form = [SELECT Id FROM Form__c LIMIT 1];
        
        Form_Data__c formData = new Form_Data__c(Form__c = form.Id, Contact__c = contact.Id);
        
        INSERT formData;

        Test.startTest();
        
        PageReference deferralExtensionRequest = Page.DeferralExtensionRequest;
        Test.setCurrentPage(deferralExtensionRequest);

        ApexPages.currentPage().getParameters().put('id', contact.Id);
        
        DeferralExtensionRequestCtrl extension = new DeferralExtensionRequestCtrl();      
        
        Test.stopTest();
        
        System.assertEquals(
            'You have already made your selection.', 
            extension.message, 
            'You have already made your selection.'
        );
        
    }
    
    @isTest
    private static void loadPageMissingForm(){
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Form__c form = [SELECT Id FROM Form__c LIMIT 1];
        
        DELETE form;

        Test.startTest();
        
        PageReference deferralExtensionRequest = Page.DeferralExtensionRequest;
        Test.setCurrentPage(deferralExtensionRequest);

        ApexPages.currentPage().getParameters().put('id', contact.Id);
        
        DeferralExtensionRequestCtrl extension = new DeferralExtensionRequestCtrl();      
        
        Test.stopTest();
        
        System.assertEquals(
            'Please create a form for this page with the Form_Name__c of "deferral-frm-nov-2025".', 
            extension.message, 
            'Please create a form for this page with the Form_Name__c of "deferral-frm-nov-2025".'
        );
        
    }

    @isTest
    private static void loadPageInactiveForm(){
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Form__c form = [SELECT Id, Status__c FROM Form__c LIMIT 1];
        
        form.Status__c = null;

        UPDATE form;

        Test.startTest();
        
        PageReference deferralExtensionRequest = Page.DeferralExtensionRequest;
        Test.setCurrentPage(deferralExtensionRequest);

        ApexPages.currentPage().getParameters().put('id', contact.Id);
        
        DeferralExtensionRequestCtrl extension = new DeferralExtensionRequestCtrl();      
        
        Test.stopTest();
        
        System.assertEquals('The deferral extension request period has ended.', extension.message, 'The deferral extension request period has ended.');
        
    }
    
}