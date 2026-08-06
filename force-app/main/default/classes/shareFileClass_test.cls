@isTest
private class shareFileClass_test{

    static Account acc ;
	static Contact contact;
    static Profile profile;
    static User user;
    static User user1;
    
    static Study__c study;
    static Study_Disclose_Protocol_Submission__c dp;
    static Study_Contact__c sc;
    static Study_Account__c sa;
    static Study_Round__c sr;
    
    static void tesData() {

        Acc = new Account(Name = 'test');
        insert acc;

        contact = new Contact(KPI_ERP_Certified__c = true,KPI_FRM_Certified__c = true,GARP_Directory_Opt_In__c = true,lastname = 'Test',AccountId = acc.id,email='test123123213124@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        study = new Study__c(Name='study1', Status__c='In Progress', Secure_File_Integration_Status__c='Enabled');
        insert study;
        
        sa = new Study_Account__c(Name='SA', Secure_File_Platform__c='ShareFile', Role__c='Participant', Status__c='Active', Study__c=study.Id, Account__c=Acc.Id,Study_Fee_Type__c='Free');
        insert sa;

        sc = new Study_Contact__c(Role__c='Data Manager', Status__c='Active', Study__c=study.Id, Contact__c=contact.Id, Study_Account__c=sa.Id);
        insert sc;
        
        dp = new Study_Disclose_Protocol_Submission__c(Name='dp', Study_Contact__c=sc.Id, Study__c=study.Id, Study_Account__c=sa.Id);
        insert dp; 
        
		sr = new Study_Round__c(Name='SR', Round__c='Version 1', Status__c='Data Collection', Study__c=study.Id);        
        insert sr;

       Sharefile_API_Config__c AuthEmail = new Sharefile_API_Config__c();
        AuthEmail.Name = 'AuthEmail';
        AuthEmail.Value__c = 'a@a.com';
        insert AuthEmail;
        
        Sharefile_API_Config__c AuthPassword = new Sharefile_API_Config__c();
        AuthPassword.Name = 'AuthPassword';
        AuthPassword.Value__c = '12345';
        insert AuthPassword;

        Sharefile_API_Config__c AuthClientId = new Sharefile_API_Config__c();
        AuthClientId.Name = 'AuthClientId';
        AuthClientId.Value__c = 'asdfafsadf';
        insert AuthClientId;
            
        Sharefile_API_Config__c AuthClientSecret = new Sharefile_API_Config__c();
        AuthClientSecret.Name = 'AuthClientSecret';
        AuthClientSecret.Value__c = '1z223x2x';
        insert AuthClientSecret;

        Sharefile_API_Config__c LoginEndPoint = new Sharefile_API_Config__c();
        LoginEndPoint.Name = 'LoginEndPoint';
        LoginEndPoint.Value__c = 'https://abc.com/api';
        insert LoginEndPoint;

        Sharefile_API_Config__c BaseEndPoint = new Sharefile_API_Config__c();
        BaseEndPoint.Name = 'BaseEndPoint';
        BaseEndPoint.Value__c = 'https://abc.com/api';
        insert BaseEndPoint;

        Sharefile_API_Config__c BaseFolderID = new Sharefile_API_Config__c();
        BaseFolderID.Name = 'BaseFolderID';
        BaseFolderID.Value__c = '43243243';
        insert BaseFolderID;

        Sharefile_API_Config__c ZoneId = new Sharefile_API_Config__c();
        ZoneId.Name = 'ZoneId';
        ZoneId.Value__c = '43243243';
        insert ZoneId;
        
    }
    
    Private static testMethod void myUnitTest_1(){
        
        test.starttest();
        tesData();
        
        shareFileClass.testNotFound = False;
        
		shareFileClass.setStudyContact(sc.Id);
        shareFileClass.getStudyContact(sc.Id);
        shareFileClass.setStudyAccount(sa.Id);
        shareFileClass.setStudy(study.Id);
        
        shareFileClass.setAccount(study.Id, True, sa.Id, 'StudyAccount', acc.Id, '23r2r32r3', 'wdw333d3');
        shareFileClass.setUser(sc.Id, True, '23r2r32r3', 'wdw333d3', 'a@a.com', 'firstName', 'lastName', 'company', 'study xyz');

        shareFileClass.setAccount(study.Id, False, sa.Id, 'StudyAccount', acc.Id, '23r2r32r3', 'wdw333d3');
        shareFileClass.setUser(sc.Id, False, '23r2r32r3', 'wdw333d3', 'a@a.com', 'firstName', 'lastName', 'company', 'study xyz');

        shareFileClass.disableUser(sc.Id, '23r2r32r3', 'wdw333d3', 'a@a.com');     
            
        //shareFileClass sc = new shareFileClass();
        //sc.getStatus();
        
        test.stoptest();      
        
    }    
    
    Private static testMethod void myUnitTest_2(){
        
        test.starttest();
        tesData();
        
        shareFileClass.testNotFound = True;
        
		shareFileClass.setStudyContact(sc.Id);
        shareFileClass.getStudyContact(sc.Id);
        shareFileClass.setStudyAccount(sa.Id);
        shareFileClass.setStudy(study.Id);
        
        shareFileClass.setAccount(study.Id, True, sa.Id, 'StudyAccount', acc.Id, '23r2r32r3', 'wdw333d3');
        shareFileClass.setUser(sc.Id, True, '23r2r32r3', 'wdw333d3', 'a@a.com', 'firstName', 'lastName', 'company', 'study xyz');

        shareFileClass.setAccount(study.Id, False, sa.Id, 'StudyAccount', acc.Id, '23r2r32r3', 'wdw333d3');
        shareFileClass.setUser(sc.Id, False, '23r2r32r3', 'wdw333d3', 'a@a.com', 'firstName', 'lastName', 'company', 'study xyz');

        shareFileClass.disableUser(sc.Id, '23r2r32r3', 'wdw333d3', 'a@a.com');        
                
        test.stoptest();      
        
    }        
    
     Private static testMethod void myUnitTest_3(){
         
		test.starttest();
        tesData();
        
        shareFileClass.testNotFound = True;        
        shareFileClass.setUser(sc.Id, True, '23r2r32r3', 'wdw333d3', 'a@a.com', 'firstName', 'lastName', 'company', 'study xyz');

        shareFileClass.testNotFound = False;        
        shareFileClass.setUser(sc.Id, True, '23r2r32r3', 'wdw333d3', 'a@a.com', 'firstName', 'lastName', 'company', 'study xyz');

        shareFileClass.testNotFound = True;        
        shareFileClass.setUser(sc.Id, False, '23r2r32r3', 'wdw333d3', 'a@a.com', 'firstName', 'lastName', 'company', 'study xyz');

        shareFileClass.testNotFound = False;        
        shareFileClass.setUser(sc.Id, False, '23r2r32r3', 'wdw333d3', 'a@a.com', 'firstName', 'lastName', 'company', 'study xyz');

        List<String> lstString = new List<String>();
        lstString.add('setStudyAccount');
        lstString.add(acc.Id);
        
        List<List<String>> lstLst = new List<List<String>>();
        lstLst.add(lstString);
         
        shareFileClass.sharefileFlow(lstLst);
         
        test.stoptest();               
     }
    
}