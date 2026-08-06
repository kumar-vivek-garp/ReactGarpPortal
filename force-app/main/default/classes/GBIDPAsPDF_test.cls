@isTest
public class GBIDPAsPDF_test {

    static Study__c study;
    static Study_Contact__c studyContact;
    static Disclosure_Protocol__c disclosureProtocol;
    static Study_Disclose_Protocol_Submission__c dps;
    
    static void testData(){ 
        study = new Study__c(Name = 'Study',Disclosure_Protocol__c = 'text',CurrencyIsoCode='USD',Study_Fee__c=50,Payment_Required__c =true);
        insert study;
        
        studyContact = new Study_Contact__c(Name = 'Study Contact');
        insert studyContact;
        
        disclosureProtocol = new Disclosure_Protocol__c();
        disclosureProtocol.Study__c = study.Id;
        disclosureProtocol.DP_Status__c = 'Active';
        insert disclosureProtocol;
        
        dps = new Study_Disclose_Protocol_Submission__c(Name='DP Submission', Study_Contact__c = studyContact.Id, Study__c = study.Id, Signed_Date_Time__c = datetime.now());
        insert dps;
        
    }
    
    @isTest
	public static void unitTest_1(){
        
        testData();
        
        test.startTest(); 
        
        ApexPages.currentPage().getParameters().put('studyId', study.id);
        ApexPages.currentPage().getParameters().put('submissionId', dps.Id);
        
        GBIDPAsPDF gp = new GBIDPAsPDF();
        
        gp.fetchData(study.id, dps.Id,null);

        test.stopTest();
        
    }
    
    @isTest
	public static void unitTest_2(){
        
        testData();
        
        test.startTest(); 
        
        ApexPages.currentPage().getParameters().put('studyId', study.id);
        
        GBIDPAsPDF gp = new GBIDPAsPDF();
        
        gp.fetchData(study.id, dps.Id,null);

        test.stopTest();
        
    }
     

}