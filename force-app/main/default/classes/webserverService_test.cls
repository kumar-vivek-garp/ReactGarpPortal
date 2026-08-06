@isTest
private class webserverService_test {

    static Form__c form;
    static Event_Contact__c ec;
    static Country_Code__c countryCode; 
    
    static {
        // setup test data  
         
        Event__c evt = new Event__c(Name = 'Event');
        insert evt;
         
        ec = new Event_Contact__c(Name = 'Contact',Email__c = 'a@a.com',Event__c = evt.Id);
        insert ec;
        
        form = new Form__c(Name = 'TESTFORM', Form_Name__c = 'TESTFORM', Subscriptions__c = 'FRM');
        INSERT form;
        
        countryCode  = new Country_Code__c(Name = 'United States', Country__c = 'United States', ISOCode__c = 'USA');
        INSERT countryCode;
        
    }
    
    @isTest
    public static void testDoGet() {
        webserverService.returntData results = new webserverService.returntData();
    }
    
    @isTest
    public static void sendContact(){
        webserverService.sendContactUs(ec.Id, 'Bob Johnson', 'a@a.com', 'hi!');
    }
    
    @isTest
    public static void addFormData(){      
        webserverService.addFormData('formName','fname','lname','fname.lname@test.com','Test message.', (String)countryCode.Id, '1234567890','1234567890', null, 'Individual','company','Test title ','51-100','Membership','Test Campaign','Test Content','Test Medium','Test Source','Test Term');
    }
    
    @isTest
    public static void addFormData2(){      
        webserverService.addFormData('formName','fname','lname','fname.lname@test.com','Test message.', (String)countryCode.Id, '1234567890','1234567890', null, 'Individual','company','Test title ','51-100','Membership','Test Campaign','Test Content','Test Medium','Test Source','Test Term');
    }
    
    @isTest
    public static void addFormData3(){      
        webserverService.addFormData('formName','fname',NULL,'fname.lname@test.com','Test message.','USA', '1234567890','1234567890', null, 'Individual','company','Test title ','51-100','Membership','Test Campaign','Test Content','Test Medium','Test Source','Test Term');
    }
    
    @isTest
    public static void webserverServicesendContactUs(){      
        webserverService.webserverService('sendContactUs','formName',ec.Id,'fname','lname','fname.lname@test.com','Test message.','USA', '1234567890','1234567890', null, 'Individual','company','Test title ','51-100','Membership','Test Campaign','Test Content','Test Medium','Test Source','Test Term');
    }
    
    @isTest
    public static void webserverServiceAddFormData(){      
        webserverService.webserverService('addFormData','formName',ec.Id,'fname','lname','fname.lname@test.com','Test message.','USA', '1234567890','1234567890', null, 'Individual','company','Test title ','51-100','Membership','Test Campaign','Test Content','Test Medium','Test Source','Test Term');
    }
    
    @isTest
    public static void webserverService(){      
        webserverService.webserverService('Test','formName',ec.Id,'fname','lname','fname.lname@test.com','Test message.','USA', '1234567890','1234567890', null, 'Individual','company','Test title ','51-100','Membership','Test Campaign','Test Content','Test Medium','Test Source','Test Term');
    }
}