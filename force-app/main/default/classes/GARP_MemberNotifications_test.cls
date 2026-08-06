@isTest
public class GARP_MemberNotifications_test {

    static Member_Notification__c note;
    static Member_Notification_Recipient__c rec;
    static Contact con;
    static Member_Notification__c note1;
    static Member_Notification_Recipient__c rec1;
    static Member_Notification__c note2;
    static Member_Notification_Recipient__c rec2;
    
    static void testData(){ 
        
        con = new Contact(lastname = 'Test',email='abc@abc.com',Mobile_Phone_Code__c='United States (+1)', MobilePhone='9175867012');
        insert con;

        Contact con2 = new Contact(lastname = 'AnotherTest',email='abc2@abc.com',Mobile_Phone_Code__c='United States (+1)', MobilePhone='9175867012');
        insert con2;
        
        note = new Member_Notification__c(Name='notify', Custom_Message__c='aaa', Status__c='Approved', Template__c='Site Closed', Message_Types__c='Email;SMS', Sending_Platform__c = 'Twilio');
        insert note;
        
        rec = new Member_Notification_Recipient__c(Name='Test', Member_Notification__c = note.id, Email__c='abc@abc.com', GARP_ID__c='12345',
                                                   Sent_Date_Time__c= DateTime.newInstanceGmt(2022, 4, 22, 8, 0, 0));
        insert rec;
        
        Member_Notification_Recipient__c recA = new Member_Notification_Recipient__c(Name='AnotherTest', Member_Notification__c = note.id, Email__c='abc2@abc.com', GARP_ID__c='123456',
                                                                                     Contact__c = con2.Id, Sent_Date_Time__c= DateTime.newInstanceGmt(2022, 4, 22, 8, 0, 0));
        insert recA;
        
        note1 = new Member_Notification__c(Name='notify', Custom_Message__c='aaa', Status__c='Sent', Template__c='Site Closed', Show_In_Portal__c = True, 
                                                                  Type__c = 'Exam', Expire_Date__c = Date.today().AddDays(30));
        insert note1;
        
        rec1 = new Member_Notification_Recipient__c(Name='Test', Member_Notification__c = note1.id, Email__c='abc@abc.com', GARP_ID__c='12345',
                                                                                     Contact__c = con.Id, Sending_Status__c='Sent', Sent_Date_Time__c=DateTime.now() );
        insert rec1;
        
        recA = new Member_Notification_Recipient__c(Name='AnotherTest', Member_Notification__c = note1.id, Email__c='abc2@abc.com', GARP_ID__c='123456',
                                                                                     Contact__c = con2.Id, Sending_Status__c='Sent', Sent_Date_Time__c=DateTime.now() );
        insert recA;
        

        note2 = new Member_Notification__c(Name='notify', Custom_Message__c='aaa', Status__c='Approved', Template__c='Site Closed', Message_Types__c='Email', Sending_Platform__c = 'Salesforce');
        insert note2;
        
        rec2 = new Member_Notification_Recipient__c(Name='Test', Member_Notification__c = note2.id, Email__c='abc@abc.com', GARP_ID__c='12345',
                                                   Sent_Date_Time__c= DateTime.newInstanceGmt(2022, 4, 22, 8, 0, 0));
        insert rec2;
       
        recA = new Member_Notification_Recipient__c(Name='AnotherTest', Member_Notification__c = note2.id, Email__c='abc2@abc.com', GARP_ID__c='123456',
                                                   Sent_Date_Time__c= DateTime.newInstanceGmt(2022, 4, 22, 8, 0, 0));
        insert recA;


        Member_Notification_Email_Log_Entry__c nml = new Member_Notification_Email_Log_Entry__c(Name='l1', Email_Address__c='abc@abc.com',
                                                                                                Message__c='Error', 
                                                                                                Log_Action__c='P',
                                                                                                Log_Date_Time__c = DateTime.newInstanceGmt(2022, 4, 22, 8, 0, 0));
        insert nml;        
        
        Exam_Sites__c es = new Exam_Sites__c(
            Name='site',
            Country__c='USA'
        );
        insert es;
        
        Exam_Attempt__c ea = new Exam_Attempt__c(   
            Member__c = con.Id,
            Exam_Site__c = es.Id
        );
        insert ea;
    }
    
    static testMethod void unitTest_2(){
        test.startTest(); 
        GARP_MS_MemberNotifications.getEmergencyAlerts();
        test.stopTest();
    }
    
    static testMethod void unitTest_1(){
        testData();
        test.startTest(); 
        GARP_MS_MemberNotifications.setMemberNotificationAsViewed(rec.id);
        GARP_MS_MemberNotifications.getExamAlerts();
        test.stopTest();
    }     
    
}