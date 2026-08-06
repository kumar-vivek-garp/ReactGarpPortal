@isTest
public class TwilioClass_test {

    @isTest  
    static void sendSMS() {
        Test.startTest();
        TwilioClass.reqSendSMS req = new TwilioClass.reqSendSMS();
        req.toPhone = '+1234567890';
        req.body = 'Hello!';
        TwilioClass.sendSMS(req);
        Test.stopTest();        
    }
    
    @isTest  
    static void sendEmail() {
        Test.startTest();
        TwilioClass.reqSendEmail req = new TwilioClass.reqSendEmail();
        req.toAddress = 'joe@joe.com';
        req.fromAddress = 'mem@garp.com';
        req.subject = 'Subject';
        req.body = 'Hello!';
        req.isHTML = True;
        req.reference = '123';
        TwilioClass.sendEmail(req);
        Test.stopTest();        
    }
    
}