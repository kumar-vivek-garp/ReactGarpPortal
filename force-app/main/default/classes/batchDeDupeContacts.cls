global class batchDeDupeContacts implements Database.Batchable<SObject>{

    public String mode;  
    public String sType;  
    public MAP<string,List<Contact>> mapRestContacts = new MAP<string,List<Contact>>();
    public MAP<string,Contact> mapFirstContacts = new MAP<string,Contact>();
    
    global batchDeDupeContacts (String modeIn, String sType){
        
       /* system.debug('Function: batchDeDupeContacts ');
        system.debug('mode:' + modeIn);*/
        
        this.mode= modeIn;        
        this.sType = sType;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(this.mode == 'batch') {
            return Database.getQueryLocator('select ID,Email from Contact where Batch_Dedupe__c = True');
        } else if(this.mode != null) {
            return Database.getQueryLocator('select ID,Email from Contact where email = :mode');
        } else {
        	return Database.getQueryLocator('select ID,Email from Contact where Email != NULL AND IsDeleted = False AND CreatedDate > YESTERDAY');    
        }        
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        
        //System.debug('scope:' + scope);       
        
        SET<String> emails = new SET<String>();
        for(Contact c :scope) {
            emails.add(c.email);
        }
        //System.debug('emails:' + emails);

         Set<String> regPROGRAMTYPES = new Set<String>{
            'FRM Program',
            'ERP Program',
            'SCR Program',
            'Risk AI Program',
            'ICBRR Program',
            'FBR Program',
            'RAIJ Program'
        };
           
        
        List<Contact> lstContact = [select id, email, RecordTypeID, RecordType.Name, Membership_Type__c, 
                                    AccountId, Account.RecordTypeID, Account.RecordType.Name,
                                    KPI_FRM_Certified__c, KPI_ERP_Certified__c, KPI_SCR_Holder__c
                                    from Contact where Email != NULL AND IsDeleted = False 
                              		AND email in :emails];
        //System.debug('lstContact:' + lstContact);
        MAP<String,Contact> mapContacts = new MAP<String,Contact>();
        for(Contact c :lstContact) {
            mapContacts.put(c.id,c);
        }
        
        List<Contact> lstContactClean = [select id, email, AccountId
                                    	from Contact where Email != NULL AND IsDeleted = False 
                              			AND email in :emails Order By CreatedDate DESC];
       // System.debug('lstContactClean:' + lstContactClean);
        
        
        mapRestContacts = new MAP<string,List<Contact>>();
        mapFirstContacts = new MAP<string,Contact>();
        Set<String> acctIds = new Set<String>();
        Set<String> restContactIDs = new Set<String>();
        Set<String> firstContactIDs = new Set<String>();
        
        for(Contact c :lstContactClean) {
            
            //System.debug('c:' + c);
            
            acctIds.add(c.AccountId);
            //System.debug('acctIds:' + acctIds);
            
            Contact fndFirstContacts = mapFirstContacts.get(c.email);
            List<Contact> fndRestContacts = mapRestContacts.get(c.email);
            
            //System.debug('fndFirstContacts:' + fndFirstContacts);
            //System.debug('fndRestContacts:' + fndRestContacts);
            
            if(fndFirstContacts == NULL) {
                mapFirstContacts.put(c.email,c);
                //System.debug('Add first:' + c);
                
            } else {
                
                Contact fndFirstCont = mapContacts.get(fndFirstContacts.id);
                //System.debug('fndFirstCont:' + fndFirstCont.RecordType.Name);
                
                Contact fndCont = mapContacts.get(c.id);
                //System.debug('fndCont:' + fndCont.RecordType.Name);
                
                if(fndFirstCont != NULL && fndCont != NULL &&
                   ((fndFirstCont.RecordTypeID == NULL && fndCont.RecordTypeID != NULL) ||
                   (fndFirstCont.RecordType.Name == 'Business Relationship' && fndCont.RecordType.Name == 'Member') ||
                   (fndFirstCont.Membership_Type__c != 'Individual' && fndCont.Membership_Type__c == 'Individual') ||
                   (fndFirstCont.Account.RecordType.Name != 'Individual' &&  fndCont.Account.RecordType.Name == 'Individual') ||
                   (!fndFirstCont.KPI_FRM_Certified__c && (fndCont.KPI_FRM_Certified__c || fndCont.KPI_ERP_Certified__c || fndCont.KPI_SCR_Holder__c)))) {
                
                       mapFirstContacts.put(c.email,c);
                       //System.debug('Reassign first:' + c);
                       
                       c = fndFirstContacts;
                }
                
                if(fndRestContacts == NULL) {
                    fndRestContacts = new List<Contact>();
                    fndRestContacts.add(c);
                    mapRestContacts.put(c.email, fndRestContacts);
                    //System.debug('New Rest first:' + fndRestContacts);
                    restContactIDs.add(c.id);
                    
                } else {
                    fndRestContacts.add(c);
                    mapRestContacts.put(c.email, fndRestContacts);
                   // System.debug('Add Rest:' + fndRestContacts);
                    restContactIDs.add(c.id);
                }
            }
        }
        
       // System.debug('mapFirstContacts:' + mapFirstContacts);
       // System.debug('mapRestContacts:' + mapRestContacts);
       // System.debug('restContactIDs:' + restContactIDs);
     
        List<AccountContactRelation> lstAcctContRels = [select id,AccountId,ContactId, Contact.Email from AccountContactRelation where ContactId in :restContactIDs];
       // System.debug('lstAcctContRels:' + lstAcctContRels);
        
        MAP<string,Set<String>> mapRestAcctRel = new MAP<string,Set<String>>();
        if(!lstAcctContRels.isEmpty()) {
            for(AccountContactRelation acr :lstAcctContRels) {
                Set<String> fndAcctRel = mapRestAcctRel.get(acr.Contact.Email);
                if(fndAcctRel == NULL) {
                    fndAcctRel = new Set<String>();
                }
                fndAcctRel.add(acr.AccountId);
                mapRestAcctRel.put(acr.Contact.Email, fndAcctRel);
            }
        }
        //System.debug('mapRestAcctRel:' + mapRestAcctRel);
        
        List<Account> lstAcct = [select id, name from Account where id in :acctIds AND (RecordType.Name = 'Individual' OR RecordTypeId = NULL)];
        
        MAP<String,Account> mapAcct = new MAP<String,Account>();
        if(!lstAcct.isEmpty()) {
            for(Account a :lstAcct) {
                mapAcct.put(a.id, a);
            }
        }
        //System.debug('mapAcct:' + mapAcct);
                
        MAP<string,List<Account>> mapRestAccts = new MAP<string,List<Account>>();
        MAP<string,Set<String>> mapRestAcctIds = new MAP<string,Set<String>>();
        MAP<string,Account> mapFirstAccts = new MAP<string,Account>();
            
        for(Contact c :mapFirstContacts.values()) {
            
          //  System.debug('fnd acct c:' + c);
            firstContactIDs.add(c.id);

            List<Contact> fndRestContacts = mapRestContacts.get(c.email);
            //System.debug('fnd acct fndRestContacts:' + fndRestContacts);
            
            if(fndRestContacts != NULL) {
                Account fndAcct = mapAcct.get(c.AccountId);
               // System.debug('fndAcct:' + fndAcct);
                
                if(fndAcct != NULL) {
                    mapFirstAccts.put(fndAcct.id,fndAcct);
                   // System.debug('Add mapFirstAccts:' + mapFirstAccts);
                    
                    for(Contact crest :fndRestContacts) {
                        
                       // System.debug('Build Acct maps crest:' + crest);
                        
                        Account fndMapAcct = mapAcct.get(crest.AccountId);
                       // System.debug('Build Acct maps fndMapAcct:' + fndMapAcct);
                        
                        if(fndMapAcct != NULL && crest.AccountId != fndAcct.Id) {
                                                        
                            List<Account> fndRestAcct = mapRestAccts.get(fndAcct.Id);
                           // System.debug('Build Acct maps fndRestAcct:' + fndRestAcct);
                            
                            if(fndRestAcct == NULL) {
                                fndRestAcct = new List<Account>();
                                fndRestAcct.add(fndMapAcct);
                                mapRestAccts.put(fndAcct.id, fndRestAcct);
                              //  System.debug('Build Acct maps new mapRestAccts:' + fndRestAcct);
                                
                                Set<String> fndRestAcctIds = new Set<String>();
                                fndRestAcctIds.add(fndMapAcct.id);
                                mapRestAcctIds.put(fndAcct.id, fndRestAcctIds);
                               // System.debug('Build Acct maps new mapRestAcctIds:' + fndRestAcctIds);
                                
                            } else {
                                
                                Set<String> fndRestAcctIds = mapRestAcctIds.get(fndAcct.Id);
                                //System.debug('fndRestAcctIds:' + fndRestAcctIds);
                                
                                Boolean containsAcctId = fndRestAcctIds.contains(fndMapAcct.Id);
                               // System.debug('containsAcctId:' + containsAcctId);
                                
                                if(fndRestAcctIds != NULL && !containsAcctId) {
                                    fndRestAcct.add(fndMapAcct);
                                    mapRestAccts.put(fndAcct.Id, fndRestAcct);
                                   // System.debug('Build Acct maps add mapRestAccts:' + mapRestAccts);
                                }
                                
                            }
                        }
                    }
                }
            }
        }
       /* System.debug('mapFirstAccts:' + mapFirstAccts);
        System.debug('mapRestAccts:' + mapRestAccts);
        System.debug('firstContactIDs:' + firstContactIDs);*/
        
        
        Boolean mergeAcct = False;
        for(Contact c :mapFirstContacts.values()) {
            
           // System.debug('merge c:' + c);
            
            List<Contact> fndRestContacts = mapRestContacts.get(c.email);
           // System.debug('fndRestContacts:' + fndRestContacts);
            
            List<Account> fndRestAcct = mapRestAccts.get(c.AccountId);
           // System.debug('fndRestAcct:' + fndRestAcct);
            
            Account fndFirstAcct = mapFirstAccts.get(c.AccountId);
            //System.debug('fndFirstAcct:' + fndFirstAcct);
            
            if(fndRestContacts != NULL) {
                
                if(fndFirstAcct != NULL && fndRestAcct != NULL && sType == 'Account') {
                    Database.MergeResult[] results = Database.merge(fndFirstAcct, fndRestAcct, false);
                   // System.debug('merge acct results:' + results); 
                    mergeAcct = true;
                }
                
                if(sType == 'Contact') {
                	Database.MergeResult[] results = Database.merge(c, fndRestContacts, false);
                	//System.debug('merge contact results:' + results); 
            	}
            }
        }
        
        List<AccountContactRelation> lstFirstAcctContRels = [select id,AccountId,ContactId, Contact.Email from AccountContactRelation where ContactId in :firstContactIDs];
       // System.debug('lstFirstAcctContRels:' + lstFirstAcctContRels);

        List<AccountContactRelation> lstRestAcctContRels = [select id,AccountId,ContactId, Contact.Email from AccountContactRelation where ContactId in :restContactIDs];
       // System.debug('lstRestAcctContRels:' + lstRestAcctContRels);
        Set<String> restAcctIds = new Set<String>();
        for(AccountContactRelation acr :lstRestAcctContRels) {
            restAcctIds.add(acr.AccountId);
        }
        
        MAP<string,Set<String>> mapFirstAcctRel = new MAP<string,Set<String>>();
        if(!lstAcctContRels.isEmpty()) {
            for(AccountContactRelation acr :lstFirstAcctContRels) {
                Set<String> fndAcctRel = mapFirstAcctRel.get(acr.Contact.Email);
                if(fndAcctRel == NULL) {
                    fndAcctRel = new Set<String>();
                }
                fndAcctRel.add(acr.AccountId);
                mapFirstAcctRel.put(acr.Contact.Email, fndAcctRel);
            }
        }
       // System.debug('mapFirstAcctRel:' + mapRestAcctRel);  
        
        List<AccountContactRelation> newAcctRel = new List<AccountContactRelation>();
        for(Contact c :mapFirstContacts.values()) {
            
            Set<String> fndAcctRel = mapRestAcctRel.get(c.email);
           // System.debug('fndAcctRel:' + fndAcctRel); 
            
            if(fndAcctRel != NULL) {
                for(String acctId :fndAcctRel) {
                   // System.debug('acctId:' + acctId); 
                    
                    Set<String> fndFirstAcctRel = mapFirstAcctRel.get(c.email);
                   // System.debug('fndFirstAcctRel:' + fndFirstAcctRel); 
                    
                    Boolean firstExists=False;
                    if(fndFirstAcctRel != NULL && fndFirstAcctRel.contains(acctId)) {
                        firstExists = True;
                    }
                   // System.debug('firstExists:' + firstExists);
                    
                    Boolean restAcctExists = restAcctIds.contains(acctId);
                   // System.debug('restAcctExists:' + restAcctExists);
                    
                    if(acctId != c.AccountId && !firstExists && restAcctExists) {
                        AccountContactRelation acr = new AccountContactRelation(ContactId=c.Id, AccountID=acctId);
                        newAcctRel.add(acr);
                       // System.debug('add newAcctRel:' + acr);
                    }
                }
            }            
        }
       // System.debug('newAcctRel:' + newAcctRel); 
        insert newAcctRel;
        
        List<Contract> lstContracts = [select Id, AccountId, Membership_Type__c, Status, RecordType.Name 
                                       from Contract where Status in ('Activated','Activated ( Auto-Renew )','Completed') and 
                                       AccountId in :mapFirstAccts.keyset() order by AccountId, RecordTypeId, StartDate ASC];

       // System.debug('lstContracts:' + lstContracts);
        
        if(mergeAcct) {
            // Clean Up Programs
            Contract lastProgram = null;
            List<Contract> updatePrograms = new List<Contract>();
            Contract lastIndividualMembership = null;
            Contract lastCompletedExam = null;
            for(Contract c :lstContracts) {
                
               // System.debug('c:' + c);
                
                // Reset for each new Account or Program Type
                if(lastProgram != NULL && (lastProgram.AccountId != c.AccountId || lastProgram.RecordTypeID != c.RecordTypeID)) {
                    
                  //  System.debug('reset:' + c);
                    
                    lastProgram = null;
                    lastIndividualMembership = null;
                    lastCompletedExam = null;
                }
                
               // System.debug('lastProgram:' + lastProgram);
                
                // Compare last Program
                if(lastProgram != NULL) { //Chinnapa
                    if(regPROGRAMTYPES.contains(c.RecordType.Name)) {
                        if(lastCompletedExam != NULL) {
                            c.status = 'Canceled';
                            updatePrograms.add(c);
                            
                           // System.debug('updatePrograms current lastCompletedExam exists:' + c);
                            
                        } else {
                            lastProgram.status = 'Canceled';
                            updatePrograms.add(lastProgram);
                            
                           // System.debug('update lastProgram lastCompletedExam null:' + lastProgram);
                            
                        }
                    } else if(c.RecordType.Name == 'Membership' && c.Status != 'Completed') {
                        if(c.Membership_Type__c == 'Affiliate' && lastIndividualMembership != NULL) {
                            c.status = 'Canceled';
                            updatePrograms.add(c);
                            
                           // System.debug('update current aff last exists:' + c);
                            
                        } else if(c.Membership_Type__c == 'Affiliate' && lastIndividualMembership == NULL) {
                            
                            lastProgram.status = 'Canceled';
                            updatePrograms.add(lastProgram);
                            
                           // System.debug('update last aff last null:' + lastProgram);
                            
                        } else if(c.Membership_Type__c == 'Individual' && lastIndividualMembership != NULL) {
                            lastIndividualMembership.status = 'Canceled';
                            updatePrograms.add(lastIndividualMembership);
                            
                           // System.debug('update lastIndividualMembership inv last exists:' + lastIndividualMembership);
                            
                        } else {
                            lastProgram.status = 'Canceled';
                            updatePrograms.add(lastProgram);
                            
                           // System.debug('update last inv last null:' + c);
                        }
                    } else if(c.Status != 'Completed') {
                        lastProgram.status = 'Canceled';
                        updatePrograms.add(lastProgram);
                        
                       // System.debug('update last:' + lastProgram);
                    }
                }            
                if(c.Status != 'Completed' && c.RecordType.Name == 'Membership' && c.Membership_Type__c == 'Individual') {
                    lastIndividualMembership = c;
                    //System.debug('lastIndividualMembership:' + c);
                }
                
                if(regPROGRAMTYPES.contains(c.RecordType.Name)) {
                    if(c.Status == 'Completed') {
                        lastCompletedExam = c;
                        //System.debug('lastCompletedExam:' + c);
                    }
                    lastProgram = c;
                } else if(c.Status != 'Completed') {
                    lastProgram = c;
                }
            }         
           // System.debug('updatePrograms:' + updatePrograms);
            if(!Test.isRunningTest()) {
            	update updatePrograms;    
            }
	        
        }
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String receipientList = 'alberto.garcia@garp.com'; //system.label.Exception_Recipient_List;
        List<String> toAddresses = new list<string>();
        toAddresses.addall(receipientList.split(','));
        message.setToAddresses(toAddresses);
        message.setSubject('Merge Contacts');
        
        //System.debug('mapFirstContacts:' + mapFirstContacts);
        
        String messageBody = 'First:\n';
        for(Contact c :mapFirstContacts.values()) {
            messageBody = messageBody + c.id + '~' + c.email + '\n';
        }
        //System.debug('messageBody:' + messageBody);
        
        messageBody = messageBody + '\n\n' + 'Rest:\n';
        
        //System.debug('mapRestContacts:' + mapRestContacts);        
        for(String em :mapRestContacts.keySet()) {
            List<Contact> fndCnt = mapRestContacts.get(em);
            for(Contact c :fndCnt) {
                messageBody = messageBody + c.id + '~' + c.email + '\n';
            }
            messageBody = messageBody + '\n\n';
        }
       // System.debug('messageBody:' + messageBody);
        
        message.setPlainTextBody(messageBody);
        mails.add(message);
        //system.debug('message ==='+message);
        
        if(!Test.isRunningTest() && !mapRestContacts.isEmpty() ) {
        	Messaging.sendEmail(mails);
        }
                
    }
    
    global void finish(Database.BatchableContext BC){
        

    }
}