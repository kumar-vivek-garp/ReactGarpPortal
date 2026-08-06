global class GARP_AbandonedCartBatch implements Database.Batchable<SObject>, Database.Stateful {

    Public String mode; 
    
    global GARP_AbandonedCartBatch(String modeIn) {
        System.debug('modeIn:' + modeIn);
        
        this.mode= modeIn;   
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        // 1 hour ago
        DateTime dt = DateTime.now() - Double.valueOf(60) / 1440;
        String query = 'select id, Form__r.Form_Name__c, Email__c, Contact__c, Lead__c, Batch_Completed__c from Form_Data__c where Status__c = \'Abandoned\' AND Batch_Completed__c = FALSE AND CreatedDate > :dt AND (Form__r.Track_Abandon_Cart__c = TRUE OR Form__r.Form_Name__c in (\'2026-financial-risk-symposium\',\'exam-registration-frm\',\'exam-registration-scr\',\'exam-registration-riskai\',\'membership-individual\')) ORDER BY CreatedDate DESC';
        if(mode != NULL) {
            query = 'select id, Form__r.Form_Name__c, Email__c, Contact__c, Lead__c, Batch_Completed__c from Form_Data__c where id = :mode';
        }
        System.debug('query:' + query);
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<Form_Data__c> scope){
        
        Set<String> contactIDs = new Set<String>();
        Set<String> leadIDs = new Set<String>();
        Set<String> emailIDs = new Set<String>();
        
        MAP<String,String> mapContactLeadForm = new MAP<String,String>();
        
        DateTime dt = DateTime.now();
        
        for(Form_Data__c fd :scope) {
            if(fd.Contact__c != NULL) {
                contactIDs.add(fd.Contact__c);
                mapContactLeadForm.put(fd.Contact__c, fd.Form__r.Form_Name__c);
            } 
            
            if(fd.Lead__c != NULL) {
                leadIDs.add(fd.Lead__c);
                mapContactLeadForm.put(fd.Lead__c, fd.Form__r.Form_Name__c);
            }
            
            if(fd.Email__c != NULL) {
                emailIDs.add(fd.Email__c);
                mapContactLeadForm.put(fd.Email__c, fd.Form__r.Form_Name__c);
            }
            
            fd.Batch_Completed__c = TRUE;
        }
        System.debug('scope:' + scope);
        database.update(scope,false);
        
        System.debug('contactIDs:' + contactIDs);
        System.debug('leadIDs:' + leadIDs);
        System.debug('emailIDs:' + emailIDs);
        
        List<Contact> lstUpdateContacts = [select id, Email, Last_Abandoned_Cart__c, Last_Abandoned_Cart_Form__c from Contact where id in :contactIDs OR email in :emailIDs];
        System.debug('lstUpdateContacts:' + lstUpdateContacts);
        
        for(Contact c :lstUpdateContacts) {
            c.Last_Abandoned_Cart__c = dt;
            String fm = mapContactLeadForm.get(c.Id);
            if(fm != NULL) {
                c.Last_Abandoned_Cart_Form__c = fm;
            } else {
                fm = mapContactLeadForm.get(c.Email);
                if(fm != NULL) {
                    c.Last_Abandoned_Cart_Form__c = fm;
                }
            }
        }
        System.debug('lstUpdateContacts update:' + lstUpdateContacts);
        database.update(lstUpdateContacts,false);
        
        List<Lead> lstUpdateLeads = [select id, Email, Last_Abandoned_Cart__c, Last_Abandoned_Cart_Form__c from Lead where IsConverted = FALSE AND (id in :leadIDs OR email in :emailIDs)];
        System.debug('lstUpdateContacts:' + lstUpdateContacts);
        System.debug('lstUpdateLeads:' + lstUpdateLeads);
        
        for(Lead l :lstUpdateLeads) {
            l.Last_Abandoned_Cart__c = dt;
            String fm = mapContactLeadForm.get(l.Id);
            if(fm != NULL) {
                l.Last_Abandoned_Cart_Form__c = fm;
            } else {
                fm = mapContactLeadForm.get(l.Email);
                if(fm != NULL) {
                    l.Last_Abandoned_Cart_Form__c = fm;
                }
            }            
        }
        System.debug('lstUpdateLeads update:' + lstUpdateLeads); 
        database.update(lstUpdateLeads,false);
    }
    
    global void finish(Database.BatchableContext bc){        
    }
}