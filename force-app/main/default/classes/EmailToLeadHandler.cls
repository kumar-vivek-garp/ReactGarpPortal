global class EmailToLeadHandler implements Messaging.InboundEmailHandler {
    
    public Lead convertToLead (Messaging.InboundEmail email){

        Map<String, String> headerMap = new Map<String, String>();
        
        for(Messaging.InboundEmail.Header h: email.headers){
            System.debug(h.name + ' = ' + h.value);
            headerMap.put(h.name, h.value);
        }
        
        Lead lead = new Lead();
        
        if(headerMap.containsKey('From')){
            
            String fromHeader = headerMap.get('From');
            
            Pattern p = pattern.compile('(?i)(.+)(\\s)(.+)(\\s)(\\<)((.+)(\\@)(.+)(\\.)(com))(\\>)');
            Matcher m = p.matcher(fromHeader);
            
            m.find();
            
            if(m.matches()){
                               
                lead.FirstName  = m.group(1);
                lead.LastName   = m.group(3);
                lead.Email      = m.group(6);
                lead.Company    = m.group(9);
                
            }
                        
        }
        
        if(email.subject != null){          
            lead.Description = 'Subject: ' + email.subject + '\n\n';
        }
        
        if(email.plainTextBody != null){
            lead.Description += email.plainTextBody;
        }
        
        lead.LeadSource = 'Sales Inbox';
        
        return lead;
        
    }
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        try{     
            Lead lead = convertToLead(email);
            INSERT lead;
            result.success = true;     
        }catch(Exception e){
            result.success = false;
            result.message = e.getMessage();
        }
        
        return result;
        
    }
    
}