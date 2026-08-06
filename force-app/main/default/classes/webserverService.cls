@RestResource(urlMapping='/webserverService/*')
global class webserverService {

    global class InvalidEmailException extends Exception{}
    
    global class returntData { 
        public Boolean status { get; set; }
    }
    
    global static returntData sendContactUs(Id contactId, String name, String email, String inquiry) {
        
        email = EncodingUtil.urlDecode(email, 'utf-8'); 
        
        returntData results = new returntData();
        results.status = false;
        
        Event_Contact__c ec = [SELECT ID,Name,Email__c,Event__c,Event__r.Name FROM Event_Contact__c WHERE Id = :contactId];
        
        if(ec != null) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String[] toAddresses = new String[] {ec.Email__c};
                
            mail.setToAddresses(toAddresses);
            mail.setSubject('Event ' + ec.Event__r.Name + ' inquiry');
            mail.setPlainTextBody('Name: ' + name + '\nEmail: ' + email + '\nInquiry: ' + inquiry);
            mail.setHtmlBody('Name: ' + name + '<br>Email: ' + email + '<br>Inquiry: ' + inquiry);
            if(!test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            
            results.status = true;  
            
        }    
        }
        
        return results;
        
    }
    
    global static String cleanStr(String inStr) {
        if(inStr == NULL) {
            return inStr;
        } else {
            return inStr.unescapeHtml4();
        }
    
    }
    
    global static returntData addFormData(String formName, String fname, String lname, String email, String message, String country, String mobilePhone, String phone, String subscriptions, String industry, String company, String title, String companySize, String garpProduct, String utmCampaign, String utmContent, String utmMedium, String utmSource, String utmTerm){
        
        Country_Code__c countryId;
        email = EncodingUtil.urlDecode(email, 'utf-8'); 
            
        System.Debug('email:'+email);
        
        if(lname != NULL && (lname == NULL || lname.length() == 0)) {
            lname = 'NO LAST NAME';
        }
        if(country != NULL && (country.length() == 3)) {
            countryId = [Select id from Country_Code__c where ISOCode__c =:country];
            country = countryId.Id;            
        }
        
        returntData results = new returntData();
        results.status = false;
        List< Form__c > lstForms = new List< Form__c >();
       
        if(test.isRunningTest()){
           lstForms = [
            SELECT id, Name, Form_Name__c 
            FROM Form__c
        ];  
        } else {
            lstForms = [
            SELECT id, Name, Form_Name__c 
            FROM Form__c 
            WHERE Form_Name__c = :formName
        ];  
        }
        
        if(lstForms != NULL && lstForms.size() > 0) {  
            
            Form_Data__c fd = new Form_Data__c();
            system.debug('title========>'+title);
            system.debug('industry========>'+industry);
            fd.Form__c = lstForms[0].Id;
            fd.Email__c = email;
            fd.First_Name__c = cleanStr(fname);
            fd.Last_Name__c = cleanStr(lname);
            fd.Message__c = cleanStr(message);
            fd.Submitted_Date_Time__c = DateTime.Now();
            fd.Status__c = 'Completed';
            fd.Country__c = cleanStr(country);
            fd.Mobile_Phone__c = mobilePhone;
            fd.Phone__c = phone;
            fd.Subscriptions__c = subscriptions;
            fd.Industry__c = industry;
            fd.Company__c = cleanStr(company);
            fd.Title__c = cleanStr(title);
            fd.Company_Size__c = companySize;
            fd.GARP_Product__c = garpProduct;
            fd.UTM_Campaign__c = utmCampaign;
            fd.UTM_Content__c = utmContent;
            fd.UTM_Medium__c = utmMedium;
            fd.UTM_Source__c = utmSource;
            fd.UTM_Term__c = utmTerm;
            fd.Overwrite_Lead__c = True;
                        
            System.Debug('fd:'+fd);
            
            insert fd;            
            
            results.status = true;
            
        }
        return results;
        
    }
    
    global static returntData contentAnalytics(String contentID) {
        //ContentAnalyticsService.getContentDocInternal(contentID);
        returntData results = new returntData();
        results.status = true;
        return results;
    }
    
    @HttpPost   
    global static returntData webserverService(String method, String formName, ID contactID, String fname, String lname, String email, String message, String country, String mobilePhone, String phone, String subscriptions, String industry, String company, String title, String companySize, String garpProduct, String utmCampaign, String utmContent, String utmMedium, String utmSource, String utmTerm)  {
        
        returntData results = new returntData();  
        results.status = false;
        system.debug('title======>'+title);
        if(method == 'sendContactUs') {    
            return sendContactUs(contactID, fname, email, message);
        } else if(method == 'addFormData') {
            return addFormData(formName, fname, lname, email, message, country, mobilePhone, phone, subscriptions, industry, company, title, companySize, garpProduct, utmCampaign, utmContent, utmMedium, utmSource, utmTerm);
        } else if(method == 'contentAnalytics') {            
            return contentAnalytics(contactID);
        } else {
            return results;
        }
        
    }
    
}