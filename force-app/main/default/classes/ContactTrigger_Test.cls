@isTest
private class ContactTrigger_Test {
    
    @TestSetup
    static void createTestData() {
        
        Integer totalCount=2;   
        List<Account> AccountResults=TestDataFactory.createAccounts(2);
        insert AccountResults;
        List<Contact> contactResults=TestDataFactory.createContacts(totalcount);
        contactResults[0].Company__c = 'Test';
        contactResults[0].AccountId = AccountResults[0].Id;
        contactResults[0].Name_as_it_Appears_on_ID__c = 'Test';
        contactResults[0].Email_Subscription_Change_Source__c = 'Test';
        //contactResults[0].KPI_CPE_Last_Completed_Cycle__c = 'Test';
        contactResults[0].CPD_User_Type__c = 'Lapsed InActive';
        contactResults[0].KPI_CPE_Credits__c = 0;
        contactResults[0].KPI_CPE_Last_Cycle_Credits__c = 0;
        contactResults[0].Email_Daily_News__c = false;
        contactResults[0].SCR_Updates__c = false;
        contactResults[0].Email_The_Week_in_Risk__c = false;
        contactResults[0].Email_Chapter_Meetings__c = false;
        contactResults[0].Exam_Prep_Provider_Outreach__c = false;
        contactResults[0].Email_Webcasts__c = false;
        contactResults[0].Email_Events__c = false;
        contactResults[0].Email_CorporateTeamBuilding__c = false;
        contactResults[0].Email_InsightAnalysis__c = false;
        contactResults[0].Email_GARP_Updates__c = false;
        contactResults[0].Email_Information_Exchange__c = false;
        contactResults[0].Email_Career_Center_Job_Board__c = false;
        contactResults[0].Email_CPE_News__c = false;
        contactResults[0].Email_Member_Update__c = false;
        contactResults[0].HasOptedOutOfEmail = false;
        contactResults[0].Email_FRM__c = false;
        contactResults[0].Email_ERP__c = false;
        contactResults[0].GARP_Directory_Invite_Opt_Out__c = false;
        contactResults[0].GARP_Directory_Opt_In__c = true;
        contactResults[0].Bloomberg_Profile_Opt_In__c = true;
        contactResults[0].Other_Qualifications__c='Test';
        contactResults[0].KPI_Membership_Payment_Status__c = 'Lapsed';
       
      
        contactResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contact','Member');
        contactResults[1].AccountId = AccountResults[1].Id;
        contactResults[1].HasOptedOutOfEmail = true;
        contactResults[1].Email_Subscription_Change_Source__c = 'test';
        insert Contactresults;
    }
    
    @isTest static void testContactTrigger(){
        
        List<Contact> TestResults=[Select AccountId,email,KPI_ERP_Enrollment_Date__c,Company__c,FirstName,LastName,RecordTypeId,Name_as_it_Appears_on_ID__c,Exam_Prep_Provider_Outreach__c,
                                   KPI_Membership_Auto_Renew_Status__c,KPI_CPE_Participation__c,CPD_User_Type__c,Email_Daily_News__c,Email_The_Week_in_Risk__c,
                                   KPI_Membership_Payment_Status__c,KPI_CPE_Last_Cycle_Credits__c,Created_From_Flow__c,SCR_Updates__c,Email_Chapter_Meetings__c,
                                   Email_Member_Update__c,Email_Career_Center_Job_Board__c,Email_CPE_News__c,HasOptedOutOfEmail,Email_FRM__c,Email_ERP__c,
                                   Email_Subscription_Change_Source__c,GARP_Directory_Invite_Opt_Out__c,Currently_in_School__c,
                                   Email_Events__c,Email_CorporateTeamBuilding__c,Email_InsightAnalysis__c,Email_GARP_Updates__c,Email_Information_Exchange__c,
                                   Event_Contributor__c,Event_Participant__c,KPI_CPE_Credits__c,KPI_CPE_Last_Completed_Cycle__c,Email_Webcasts__c
                                   from Contact LIMIT 2];
        
        Contact con = TestResults[0];
       
        con.Company__c = 'Test Today';
        con.LastName = 'Test LastName';
        con.FirstName = 'firstName changed';
        con.email = 'Test@changeemail.com';
        con.Email_Daily_News__c = true;
        con.SCR_Updates__c = true;
        con.Email_The_Week_in_Risk__c = true;
        con.Email_Chapter_Meetings__c = true;
        con.Email_Webcasts__c = true;
        con.Exam_Prep_Provider_Outreach__c = true;
        con.Email_Events__c = true;
        con.Email_CorporateTeamBuilding__c = true;
        con.Email_InsightAnalysis__c = true;
        con.Email_GARP_Updates__c = true;
        con.Email_Information_Exchange__c = true;
        con.Email_Member_Update__c = true;
        con.Email_Career_Center_Job_Board__c = true;
        con.Email_CPE_News__c = true;
        con.HasOptedOutOfEmail = false;
        con.Email_FRM__c = true;
        con.Email_ERP__c = true;
        con.GARP_Directory_Invite_Opt_Out__c = true;
        con.KPI_Membership_Payment_Status__c = 'In Good Standing';
        con.Email_Subscription_Change_Source__c = 'Test';
        con.Currently_in_School__c = true;
       // con.KPI_CPE_Last_Cycle_Credits__c =0;
        con.KPI_CPE_Last_Cycle_Credits__c=1;
        con.KPI_CPE_Last_Completed_Cycle__c='Test';
        update con;
        Contact con1 = TestResults[1];
        con1.HasOptedOutOfEmail = true;
        con1.Email_Subscription_Change_Source__c = 'test';
        update con1;
    }
    
}