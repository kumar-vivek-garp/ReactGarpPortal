@isTest
public class FRR_Authorization_Letter_test {

    Static User user;
    static contact contact;
    static Account account;
    Static Opportunity opp;
    Static Exam_Attempt__c examAttempt;
        
    static void setup(){
        
        // Setup Products
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        // Create User
        user = GARP_TestFactory.createIndividualUser();
        
        // Create Member        
        //opp = GARP_TestFactory.createMember();
        
        opp = [select id,AccountId,StageName from Opportunity limit 1];
        
        List<Contact> lstCont = [select id, accountId, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c from contact];
        contact = lstCont[0];        
        
        contact.MailingStreet = '111 Street Rd';
        contact.MailingCity = 'Jersey City';
        contact.MailingState = 'New Jersey';
        contact.MailingPostalCode = '07310';
        contact.MailingCountry = 'USA';
        update contact;

        List<Account> lstAcct = [select id, Name from Account where id = :contact.accountId];
        account = lstAcct[0];        
                
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        examAttempt = GARP_TestFactory.createExamAttempt(opp,frmContract,'FRM');
    }
    
    @isTest
    static void unitTest1() {
        
        setup();
        
        test.startTest();

        PageReference pageRef = Page.FRR_Authorization_Letter;
        pageRef.getParameters().put('id',examAttempt.id);
        Test.setCurrentPage(pageRef); 
        FRR_Authorization_Letter pageCtrl = new FRR_Authorization_Letter();

        PageReference pageRef1 = Page.FRR25_Authorization_Letter;
        pageRef1.getParameters().put('id',examAttempt.id);
        Test.setCurrentPage(pageRef); 
        FRR25_Authorization_Letter pageCtrl1 = new FRR25_Authorization_Letter();
            
        PageReference pageRef2 = Page.MicroCourse_Authorization_Letter;
        pageRef2.getParameters().put('id',examAttempt.id);
        Test.setCurrentPage(pageRef); 
        MicroCourse_Authorization_Letter pageCtrl2 = new MicroCourse_Authorization_Letter();
        
        test.stopTest();
    }
    
}