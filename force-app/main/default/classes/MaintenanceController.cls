global with sharing class MaintenanceController {
    
    global MaintenanceController() {
        
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List < String > toAddresses = new List < String > ();
            toAddresses.add('alberto.garcia@garp.com');
            mail.setToAddresses(toAddresses);
            mail.setSubject('Community Maint Page was Viewed');
            mail.setHTMLBody('Community Maint Page was Viewed');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(exception ex) {
            
        }
		        
    }
    
    global PageReference init() {
        System.PageReference retLogin;
        return retLogin;
    }
    
}