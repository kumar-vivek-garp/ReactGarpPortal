@isTest
public class GenerateStudyImportFile_test {

    static Study__c study;
    static Study_Account__c studyAccount;
    
    static void testData(){ 
        study = new Study__c(Name='Study', Status__c='In Progress', Study_Abbreviation__c='STDY', Secure_File_Integration_Status__c='Enabled');
        insert study;
        studyAccount = new Study_Account__c(Name='StudyAccount', Status__c='Active', Secure_File_Platform__c='Serv-U', Study__c = study.Id,Study_Fee_Type__c='Free');
        insert studyAccount;
    }
    
    static testMethod void unitTest_1(){
        testData();
        system.debug('study:' + study);
        system.debug('studyAccount:' + studyAccount);
        generateStudyImportFile gtif = new generateStudyImportFile();
        gtif.studyId = study.Id;
		gtif.loadAccounts();
    }    
    
}