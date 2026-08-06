@isTest
public class gbiFlow_test {

    static Study__c study;
    static Study_Contact__c studyContact;
    static Study_Account__c studyAccount;
    static Study_Contact_Vote__c studyContactVote;
    static Contact contact;
    
    static void testData(){ 
        
        contact = new Contact();
        contact.LastName = 'Bob';
        contact.email = 'bob@bob.com';
        INSERT contact;
        
        study = new Study__c();
        study.Name = 'STUDY TEST';
        study.Disclosure_Protocol__c = 'TEST';
        INSERT study;
        
        studyAccount = new Study_Account__c();
        studyAccount.Study__c = study.Id;
        studyAccount.Name = 'STUDY ACCOUNT TEST';
        studyAccount.Study_Fee_Type__c='Free';
        INSERT studyAccount;
        
        studyContact = new Study_Contact__c();
        studyContact.Name = 'STUDY CONTACT TEST';
        studyContact.Study_Account__c = studyAccount.Id;
        INSERT studyContact;
        
        studyContactVote = new Study_Contact_Vote__c();
        studyContactVote.Name = 'STUDY CONTACT VOTE TEST';
        studyContactVote.Study_Contact__c = studyContact.Id;
        studyContactVote.Vote__c='Yes';
        INSERT studyContactVote;
        
    }
    
    @isTest
	public static void unitTest_1(){
        
        testData();
        
        test.startTest(); 
        
        Integer expectedLimits = 0;
        Integer actualLimits = Limits.getEmailInvocations();
        System.assertEquals(expectedLimits, actualLimits, 'wrong limits before');
                       
        gbiFlow.sendMailGBI(contact.Id, studyContactVote.Id);

        expectedLimits = 1;
        actualLimits = Limits.getEmailInvocations();
        System.assertEquals(expectedLimits, actualLimits, 'wrong limits before');     
        
        test.stopTest();
        
    }
       
    @isTest
    public static void unitTest_2(){
        
        testData();
        
        test.startTest(); 
        
        Integer expectedLimits = 0;
        Integer actualLimits = Limits.getEmailInvocations();
        System.assertEquals(expectedLimits, actualLimits, 'wrong limits before');
                       
        List<String> ids = new List<String>{
          contact.Id + '~' + studyContactVote.Id   
        };
        
        gbiFlow.sendGBIVoteEMail(ids);

        expectedLimits = 1;
        actualLimits = Limits.getEmailInvocations();
        System.assertEquals(expectedLimits, actualLimits, 'wrong limits before');     
        
        test.stopTest();
        
    }    
     
}