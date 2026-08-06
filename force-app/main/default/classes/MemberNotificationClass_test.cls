@isTest
public class MemberNotificationClass_test {
    
    static Member_Notification__c note;
    static Member_Notification_Recipient__c rec;
    static Contact con;
    static Member_Notification__c note1;
    static Member_Notification_Recipient__c rec1;
    static Member_Notification__c note2;
    static Member_Notification_Recipient__c rec2;
    
    static void testData(){ 
        
        con = new Contact(lastname = 'Test',email='abc@abc.com',Mobile_Phone_Code__c='United States (+1)', MobilePhone='9175867012', GARP_Member_ID__c='1234567');
        insert con;

        Contact con2 = new Contact(lastname = 'AnotherTest',email='abc2@abc.com',Mobile_Phone_Code__c='United States (+1)', MobilePhone='9175867012', GARP_Member_ID__c='7654321');
        insert con2;
        
        note = new Member_Notification__c(Name='notify', Custom_Message__c='aaa', Status__c='Approved', Template__c='Site Closed', Message_Types__c='Email;SMS', Sending_Platform__c = 'Twilio');
        insert note;
        
        rec = new Member_Notification_Recipient__c(Name='Test', Member_Notification__c = note.id, Email__c='abc@abc.com', GARP_ID__c='1234567',
                                                   Sent_Date_Time__c= DateTime.newInstanceGmt(2022, 4, 22, 8, 0, 0));
        insert rec;
        
        Member_Notification_Recipient__c recA = new Member_Notification_Recipient__c(Name='AnotherTest', Member_Notification__c = note.id, Email__c='abc2@abc.com', GARP_ID__c='7654321',
                                                                                     Contact__c = con2.Id, Sent_Date_Time__c= DateTime.newInstanceGmt(2022, 4, 22, 8, 0, 0));
        insert recA;
        
        note1 = new Member_Notification__c(Name='notify', Custom_Message__c='aaa', Status__c='Sent', Template__c='Site Closed', Show_In_Portal__c = True, 
                                                                  Type__c = 'Exam', Expire_Date__c = Date.today().AddDays(30));
        insert note1;
        
        rec1 = new Member_Notification_Recipient__c(Name='Test', Member_Notification__c = note1.id, Email__c='abc@abc.com', GARP_ID__c='1234567',
                                                                                     Contact__c = con.Id, Sending_Status__c='Sent', Sent_Date_Time__c=DateTime.now() );
        insert rec1;
        
        recA = new Member_Notification_Recipient__c(Name='AnotherTest', Member_Notification__c = note1.id, Email__c='abc2@abc.com', GARP_ID__c='7654321',
                                                                                     Contact__c = con2.Id, Sending_Status__c='Sent', Sent_Date_Time__c=DateTime.now() );
        insert recA;
        

        note2 = new Member_Notification__c(Name='notify', Custom_Message__c='aaa', Status__c='Approved', Template__c='Site Closed', Message_Types__c='Email', Sending_Platform__c = 'Salesforce');
        insert note2;
        
        rec2 = new Member_Notification_Recipient__c(Name='Test', Member_Notification__c = note2.id, Email__c='abc@abc.com', GARP_ID__c='1234567',
                                                   Sent_Date_Time__c= DateTime.newInstanceGmt(2022, 4, 22, 8, 0, 0));
        insert rec2;
       
        recA = new Member_Notification_Recipient__c(Name='AnotherTest', Member_Notification__c = note2.id, Email__c='abc2@abc.com', GARP_ID__c='7654321',
                                                   Sent_Date_Time__c= DateTime.newInstanceGmt(2022, 4, 22, 8, 0, 0));
        insert recA;


        Member_Notification_Email_Log_Entry__c nml = new Member_Notification_Email_Log_Entry__c(Name='l1', Email_Address__c='abc@abc.com',
                                                                                                Message__c='Error', 
                                                                                                Log_Action__c='P',
                                                                                                Log_Date_Time__c = DateTime.newInstanceGmt(2022, 4, 22, 8, 0, 0));
        insert nml;        
        
        Exam_Sites__c es = new Exam_Sites__c(
            Name='Site',
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
        testData();
        test.startTest(); 
        
        Member_Notification_Email_Log_Entry__c logentry = new Member_Notification_Email_Log_Entry__c(
          Email_Address__c = 'abc@abc.com',
            Log_Action__c = 'P',
            Log_Date_Time__c = DateTime.newInstanceGmt(2021, 1, 1, 11, 0, 0),
            Message__c = 'Error Sending',
            Retry_Count__c = 1,
            Sender__c = 'From GARP'
        );
        insert logentry;
        
        List<Member_Notification_Email_Log_Entry__c> emailLogEntries = [select id, Email_Address__c, Log_Action__c, Log_Date_Time__c, Message__c, Retry_Count__c, Sender__c from Member_Notification_Email_Log_Entry__c order by Log_Date_Time__c];
        MemberNotificationClass.updateSendingStatus(note.id, emailLogEntries);        
        
       // Database.executeBatch(new MemberNotificationEmailLogBatch(note.id));
        
        test.stopTest();
    } 
    
    static testMethod void unitTest_2A(){
        testData();
        test.startTest(); 
        
        MemberNotificationClass.getMemberNotificationsExamAlerts(con.Id);
        MemberNotificationClass.getMemberNotifications(null);
        
        test.stopTest();
    }
    
    static testMethod void unitTest_1(){
        testData();
        test.startTest(); 
        
        MemberNotificationClass.sendNotificationButton(note.id);
        //MemberNotificationClass.sendNotificationButtonAura(note.id);
        MemberNotificationClass.emailTracker();        
        MemberNotificationClass.setMemberNotificationAsViewed(rec.id);
        
        List<String> params = new List<String>();
        params.add('sendNotificationTest');
        params.add(note.id);
        params.add('abc@abc.com');
        List<List<String>> inputParams = new List<List<String>>();
        inputParams.add(params);        
        MemberNotificationClass.MemberNotificationInvocable(inputParams);        
        
        MemberNotificationClass.sendNotificationTestButton(note.id, 'abc@abc.com');
        
        note.Status__c='Sent';
        update note;
        
        MemberNotificationClass.resendNotificationButton(note.id, rec.id);
        //MemberNotificationClass.resendNotificationButtonAura(note.id);
        //MemberNotificationClass.resendNotificationRecipientButtonAura(rec.id);
        
        
        test.stopTest();
    }     
    
    static testMethod void unitTest_EmailTracker(){
        testData();
        test.startTest(); 
        
        PageReference pageRef = Page.MemberNotificationEmailTracker ; 
        pageRef.getParameters().put('recid',rec.id);
        pageRef.getParameters().put('url','https://www.garp.org');
        Test.setCurrentPage(pageRef);
        
        MemberNotificationClass.emailTracker();
        
        test.stopTest();
    }     
    
    static testMethod void unitTest_1A(){
        testData();
        test.startTest(); 
        
        List<String> params = new List<String>();
        params.add('sendNotificationButtonAura');
        params.add(note.id);
        List<List<String>> inputParams = new List<List<String>>();
        inputParams.add(params);        
        MemberNotificationClass.MemberNotificationInvocable(inputParams);      
        
        //MemberNotificationClass.sendNotificationButtonAura(note.id);
        test.stopTest();
    }     
    static testMethod void unitTest_1B(){
        testData();
        test.startTest(); 
        
        List<String> params = new List<String>();
        params.add('resendNotification');
        params.add(note.id);
        List<List<String>> inputParams = new List<List<String>>();
        inputParams.add(params);        
        MemberNotificationClass.MemberNotificationInvocable(inputParams);      
        
        //MemberNotificationClass.resendNotificationButtonAura(rec.id);
        test.stopTest();
    }     
    static testMethod void unitTest_1C(){
        testData();
        test.startTest(); 
        
        List<String> params = new List<String>();
        params.add('resendNotificationRecipient');
        params.add(rec.id);
        List<List<String>> inputParams = new List<List<String>>();
        inputParams.add(params);        
        MemberNotificationClass.MemberNotificationInvocable(inputParams);      
        
        //MemberNotificationClass.resendNotificationRecipientButtonAura(rec.id);
        test.stopTest();
    }     
    
    static testMethod void unitTest_1D(){
        testData();
        test.startTest(); 
        
        MemberNotificationClass.sendNotification(note2.id);
        
        test.stopTest();
    }     
    
    static testMethod void unitTest_3(){
        testData();
        test.startTest(); 
        
        List<String> params = new List<String>();
        params.add('genAudiencePreview');
        params.add('2022');
        params.add('November');
        params.add('FRM Part I');
        params.add('Registered');
        params.add('');         
        List<List<String>> inputParams = new List<List<String>>();
        inputParams.add(params);
        
        MemberNotificationClass.MemberNotificationInvocable(inputParams);    
        
        List<String> params1 = new List<String>();
        params1.add('genAudience');
        params1.add('2022');
        params1.add('November');
        params1.add('FRM Part I');
        params1.add('Registered');
        params1.add('');         
        params1.add('');         
        params1.add('');
        params1.add('');
        params1.add(note.Id);                  
        List<List<String>> inputParams1 = new List<List<String>>();
        inputParams1.add(params1);
        
        MemberNotificationClass.MemberNotificationInvocable(inputParams1);

        MemberNotificationClass.genAudiencePreview('2022','November','FRM Part II','Registered',null,null,null,null);
        MemberNotificationClass.genAudiencePreview('2022','November','FRM Part I and II','Registered',null,null,null,null);
        MemberNotificationClass.genAudiencePreview('2022','November','SCR','Registered',null,null,null,null);
        MemberNotificationClass.genAudiencePreview('2022','November','SCR','Paid',null,null,null,null);
        MemberNotificationClass.genAudience('2022','November','FRM Part II','Registered',null,null,null,null,note.Id);
        MemberNotificationClass.genAudience('2022','November','FRM Part I and II','Registered',null,null,null,null,note.Id);
        MemberNotificationClass.genAudience('2022','November','SCR','Registered',null,null,null,null,note.Id);
        MemberNotificationClass.genAudience('2022','November','SCR','Paid',null,null,null,null,note.Id);
        
        List<String> params2 = new List<String>();
        params2.add('removeAudience');
        params2.add(note.Id);
        List<List<String>> inputParams2 = new List<List<String>>();
        inputParams2.add(params2);        
        MemberNotificationClass.MemberNotificationInvocable(inputParams2);
        
        //MemberNotificationClass.removeAudience(note.Id);
        
        test.stopTest();
    }    
    
    static testMethod void unitTest_TwilioWebHook(){
        testData();
        test.startTest(); 
        TwilioWebhook.webhook();
        test.stopTest();
    }    
    
}