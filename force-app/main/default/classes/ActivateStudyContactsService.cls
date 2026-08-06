public class ActivateStudyContactsService {
    
    public static void activateStudyContacts(List<Study_Contact__c> scope){
        
        //system.debug('scope:' + scope);
        List<User> lstUsers = new List<User>();       
        List<Contact> lstContacts = new List<Contact>();
        List<Account> lstAccounts = new List<Account>();
        
        List<User> newUsers = new List<User>();       
        List<Contact> newContacts = new List<Contact>();
        List<Contact> updateContacts = new List<Contact>();
        List<Account> newAccounts = new List<Account>();
        
        List<String> lstEmails = new List<String>();
        
        MAP<String,User> mapUser = new MAP<String,User>();
        MAP<String,Account> mapAcct = new MAP<String,Account>();
        MAP<String,Contact> mapCont = new MAP<String,Contact>();
        
       for(Study_Contact__c pr :scope) {
           lstEmails.add(pr.Study_Contact_Email__c);
      }
        
       // system.debug('lstEmails:' + lstEmails);
        
        
        lstAccounts = [select Id, Name, Member_Email__c from Account where Member_Email__c in :lstEmails];
        
        for(Account acct :lstAccounts) {
            mapAcct.put(acct.Member_Email__c, acct);
        }       
        //system.debug('mapAcct:' + mapAcct);
        
        lstContacts = [select Id, Name, Email, AccountId, GBI_Participant__c from Contact where Email in :lstEmails];
        for(Contact cont :lstContacts) {
            mapCont.put(cont.Email, cont);
        }       
        //system.debug('mapCont:' + mapCont);
        
        lstUsers = [select username, Email, contactId from User where Email in :lstEmails];
        for(User u :lstUsers) {
            mapUser.put(u.Email, u);
        }       
        //system.debug('mapUser:' + mapUser);
        
       /* lstAccounts = [select Id, Name, Member_Email__c from Account where Member_Email__c in :lstEmails];
        for(Account acct :lstAccounts) {
            mapAcct.put(acct.Member_Email__c, acct);
        }  */     
        
        for(Study_Contact__c pr :scope) {
            //system.debug('pr:' + pr);
            Contact fndCont = mapCont.get(pr.Study_Contact_Email__c);
            //Account fndAcct = mapAcct.get(pr.Study_Contact_Email__c);
            if(fndCont == null) {
                Contact newContact = new Contact();
                newContact.RecordtypeId = recordtypehelper.getRecordtypeID('Contact','Business Relationship');
                
                Integer intIndex = pr.Name.indexOf(' ');
                String fname='First';
                String lname='Last';
                if(intIndex > -1) {
                    fname = pr.Name.subString(0,intIndex);
                    lname = pr.Name.subString(intIndex+1, pr.Name.length());
                }
                
                newContact.FirstName=fname;
                newContact.LastName=lname;
                newContact.Email=pr.Study_Contact_Email__c;
                newContact.AccountId=pr.Study_Account__r.Account__c;   
                newContact.GBI_Participant__c = True;
                newContacts.add(newContact);
            } else {
                fndCont.GBI_Participant__c = True;
                updateContacts.add(fndCont);
            }
        }
        //System.debug('This should not be empty' +newContacts);
        insert newContacts;
      update updateContacts;
      
      lstContacts = [select Id, Name, Email, do_not_fire__c,FirstName,LastName,GARP_ID_New__c,GARP_Member_ID__c,Password__c,recordTypeId from Contact where Email in :lstEmails];
       //system.debug('lstContacts:' + lstContacts);
        List<User> userList=new List<User>();
        
        Profile pf = [SELECT Id FROM profile WHERE name='Customer Community' limit 1];
        for(Contact con :lstContacts) {
            mapCont.put(con.Email, con);
           
            User fUser = mapUser.get(con.Email);
          if(fUser == null) {
                User mockUser=new User();
                mockUser.contactId=con.Id;
                mockUser.username= con.Email;
                mockUser.firstname=con.FirstName;
                mockUser.lastname=con.LastName;
                mockUser.email=con.Email;
                mockUser.communityNickname = con.GARP_ID_New__c+string.valueof(Math.random()).substring(4,9);
                mockUser.alias = con.GARP_ID_New__c.substring(1,6);                     
                mockUser.profileid = pf.Id;
                mockUser.emailencodingkey='UTF-8';
                mockUser.languagelocalekey='en_US';
                mockUser.localesidkey='en_US';
                mockUser.timezonesidkey='America/New_York';             
                Database.DMLOptions dlo = new Database.DMLOptions();
                dlo.EmailHeader.triggerUserEmail = true;
                dlo.EmailHeader.triggerAutoResponseEmail= true;
                mockUser.setOptions(dlo);   
                userList.add(mockUser); 
                //system.debug('mockUser == '+mockUser);
            }
        }    
        //The system debug was added by Kyan
        //System.debug(userlist);
        try {
            insert userList;    
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            
              AppError__c appErr = new AppError__c(
                Error__c = e.getMessage() + ':Line:' + e.getLineNumber(),
                Method__c = 'activateStudyContacts'
            );
            insert appErr;
            
        }
        
       //System.debug('outside final loop');
        
        for(Study_Contact__c pr :scope) {
            Contact fndCont = mapCont.get(pr.Study_Contact_Email__c);
            if(fndCont != null) {
                pr.Contact__c = fndCont.Id;
               //System.debug('This is the id' + fndCont.Id);
            }
        }
        
        update scope;
        
    }
    
    @InvocableMethod(label='Create Contacts from Study Contacts' description='Creates contacts for study contacts if they do not currently exist in Salesforce')
    public static void getStudyTopicids(List<Study_Contact__c> scope) {
       //System.debug(Scope);
        List<String> allIds = new List<String>();
        
        for(Study_Contact__c needId : scope){
            allIds.add(needId.id);
        }
        
        //System.debug(allIds);
        
        List<Study_Contact__c> newScope = [select id, name, Contact__c, Study_Contact_Email__c, Study_Account__r.Account__c from Study_Contact__c  where id in: allIds];
        //System.debug(newScope);
        activateStudyContacts(newScope);
        
        //List<Account> accounts = [SELECT Name FROM Account WHERE Id in :ids];
        /*for (Account account : accounts) {
accountNames.add(account.Name);
}
*/
    }
    
}