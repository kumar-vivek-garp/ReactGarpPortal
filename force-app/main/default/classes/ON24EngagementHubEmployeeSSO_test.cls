@isTest
public class ON24EngagementHubEmployeeSSO_test {

    static User user1;
    static Contact contact1;
    static Contract contract;
    static Account acc ;
 	
    static void testDataNew() {

        Acc = new Account(Name = 'test');
        insert acc;
        
        contact1 = new Contact(KPI_Membership_Payment_Status__c  = 'In Good Standing',KPI_ERP_Certified__c = true,
                               KPI_FRM_Certified__c = true,GARP_Directory_Opt_In__c = true,lastname = 'Testdhaskd',
                               AccountId = acc.id,email='daghtest@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),
                               Name_As_it_Appears_On_ID__c = 'testtest' ,ID_Number__c = 'dasf123l',ID_Type__c = 'Passport',
                               Area_of_Concentration__c = 'Individual',firstName = 'Test Contact',company__c = 'Test garp',
                               title = 'Employee',MailingCity = 'Jersey City', mailingState = 'NJ',MailingCountry = 'USA');
        insert contact1;        

        Profile profile = [SELECT Id FROM Profile WHERE id = '00e40000000iraa' LIMIT 1]; 

        user1 = new User(Alias = 'newUser', Email='newuser@testorg.garp.com', ProfileId = profile.Id,EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='newuser.garp@testorg.garp.com');
        insert user1;

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contract; 
        Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = ContractRecordTypeInfo .get('Membership').getRecordTypeId();
        contract = new Contract(AccountId = acc.id,recordTypeId = rtId);
        
        insert contract;contract.Status = 'Activated';
        update contract;
        
    }
    
    static testMethod void unitTest_12(){
    
        testDataNew();
        test.startTest();
         system.runAs(user1){
            ON24EngagementHubEmployeeSSO onhub = new ON24EngagementHubEmployeeSSO();
            onhub .ON24EngagementHubEmployeeSSO();
        }
        test.stopTest();
    }
    
    static testMethod void testAPITranCreation(){
    
        testDataNew();
        test.startTest();
        API_Transaction__c tran = on24API.createAPITransactionRecord('event', null, contact1.id, 'test', 'test');
        on24API.SendRequest('testURL', tran.id);
        test.stopTest();
    }
}