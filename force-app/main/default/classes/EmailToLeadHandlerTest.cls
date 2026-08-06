@isTest
public class EmailToLeadHandlerTest {

    public static Messaging.InboundEmail.Header headerFactory(String name, String value){
        
        Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
        h.name = name;
        h.value = value;
        
        return h;
        
    }
    
    @isTest
    public static void createDuplicateLeads(){
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = 'Valid Email Subject Line';
        email.fromAddress = 'firsntame.lastname@test.com';
        email.plainTextBody = 'Lorem ipsum dolor sit amet, ius tua, mel cu admodum splendide eloquentiam. Modo dicat lucilius in vis, vis ut semper incorrupte. Ad rebum posse consectetuer eam.';  
             
        Messaging.InboundEmail.Header fromHeader = new Messaging.InboundEmail.Header();
        fromHeader.name = 'From';
        
        email.headers = new List<Messaging.InboundEmail.Header>();
        email.headers.add(headerFactory('From', 'FirstName LastName <firsntame.lastname@test.com>'));
               
        EmailToLeadHandler emailToLeadHandlerValid = new EmailToLeadHandler();
        System.assertEquals(true, emailToLeadHandlerValid.handleInboundEmail(email, envelope).success);
                        
    }
    
    @isTest
    public static void createInvalidTestEmail(){
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.fromAddress = 'firsntame.lastname@test.com';
        email.subject = 'Valid Email Subject Line';
        email.plainTextBody = 'Lorem ipsum dolor sit amet, ius tua, mel cu admodum splendide eloquentiam. Modo dicat lucilius in vis, vis ut semper incorrupte. Ad rebum posse consectetuer eam.';  
             
        email.headers = new List<Messaging.InboundEmail.Header>();
        email.headers.add(headerFactory('From', 'FirstName LastName <asdsa>'));//invalid email address
                     
        EmailToLeadHandler emailToLeadHandlerInvalid = new EmailToLeadHandler();
        System.assertEquals(false, emailToLeadHandlerInvalid.handleInboundEmail(email, envelope).success);   
                
    }
    
}