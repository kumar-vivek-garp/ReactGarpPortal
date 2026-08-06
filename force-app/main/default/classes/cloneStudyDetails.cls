public with sharing class cloneStudyDetails
{
    // properites
    public Study__c tempStudyRecord{get;set;}
    ApexPages.StandardController stdController {get;set;}
    
    public cloneStudyDetails(ApexPages.StandardController controller) {
            tempStudyRecord = (Study__c)controller.getRecord();
            stdController = controller;
    }
    
    
    public PageReference cloneStudyDetails()
    {
        // setup the save point for rollback
        Savepoint sp = Database.setSavepoint();
        
        Study__c currentStudyRecord;
        Study__c newStudyRecord;
        try{
        currentStudyRecord = [SELECT Id, Conference_Call_Details__c, Conference_Call_Status__c, CurrencyIsoCode, Data_Provided__c,Description__c, Disclosure_Protocol__c, Document_Folder_Name__c, End_Date__c, FAQ_Category__c, LastViewedDate, Number_of_Participants__c, OwnerId, Parent_Study__c, Record_Link__c, Reference_Study__c, Risk_Type__c, Start_Date__c, Status__c, Name, Study_Objective__c, Type__c  FROM Study__c where id =:ApexPages.currentPage().getParameters().get('Id') ];
        
        newStudyRecord = currentStudyRecord.clone(false);
        newStudyRecord.Name = tempStudyRecord.Name; 
        newStudyRecord.Cloned_From__c = currentStudyRecord.Id;    

        try{
        insert newStudyRecord;   
        }catch(Exception ex)
        {
            if(ex.getMessage().contains('duplicate'))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate record. Please check the records in the system.'));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;                    
        }
   
       
        List<Study_Account__c> lst_StudyAccount = new List<Study_Account__c>();
        for(Study_Account__c StudyAccount :[SELECT Id, Account__c,  Email_WebSite_URL__c, OwnerId, Record_Link__c, Role__c, Status__c, Study__c, Name FROM Study_Account__c where Study__c!=null and Study__c=:currentStudyRecord.Id])
        {
            Study_Account__c s = StudyAccount.clone(false);
            s.cloned_from__c = StudyAccount.Id;
            s.Study__c = newStudyRecord.Id;
            
            lst_StudyAccount.add(s);
        }
        
        if(lst_StudyAccount.size() > 0)
            insert lst_StudyAccount;
        
       
        Map<String,String> map_oldNewStudyAccount = new Map<String,String>();
        for(Study_Account__c s:[Select Id,Cloned_From__c from Study_Account__c where Id In:lst_StudyAccount])
        {
            map_oldNewStudyAccount.put(s.Cloned_From__c,s.Id);
        }       
        
        List<Study_Contact__c> lst_StudyContact = new List<Study_Contact__c>();
        List<Study_Account__c> lst_StudyAccountSite = new List<Study_Account__c>(); 
        Map<Id,Study_Contact__c> mapClonedSites = new Map<Id,Study_Contact__c>();
        for(Study_Contact__c Studycontact :[SELECT Id, Account__c, Contact__c,  DP_Notification_Sent_At__c, /*DP_Sign_DateTime__c,*/ DP_Signee__c, Email_WebSite_URL__c, Last_Email_Change__c, Last_Login_Date_Time__c, LastViewedDate, OwnerId, Record_Link__c, Role__c, Status__c, Study__c, Study_Account__c, Study_Contact_Email__c, Study_Disclose_Protocol_Submission__c, Study_Name__c, Name, SystemModstamp FROM Study_Contact__c  where Study_Account__c IN :map_oldNewStudyAccount.keySet() and Study__c=:currentStudyRecord.id ])
        {
                Study_Contact__c s = Studycontact.clone(false);
                s.Study_Account__c = map_oldNewStudyAccount.get(Studycontact.Study_Account__c );
                s.Study_Disclose_Protocol_Submission__c =null;
                s.DP_Notification_Sent_At__c =null;
               s.Study__c = newStudyRecord.id;
              
                    
                lst_StudyContact.add(s);
        }
        system.debug('mapClonedSites == '+mapClonedSites);
        system.debug('lst_StudyAccountSite == '+lst_StudyAccountSite);
        if(lst_StudyContact.size()>0)
            insert lst_StudyContact;
   
        }catch(exception e)
        {
          // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        PageReference p =  new PageReference('/'+newStudyRecord.Id+'/e');
        p.getParameters().put('retURL','/'+newStudyRecord.Id);
        p.setRedirect(true);
        return p;    
   
   }}