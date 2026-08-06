public without sharing class AWSSecureFileBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    private List<Study_Contact__c> studyContacts {get;set;}
    
    public AWSSecureFileBatch(List<Study_Contact__c> inptStudyContactss) {
        this.studyContacts = inptStudyContactss;
    }
    
    // Step 1: Gather records
    public Iterable<sObject> start(Database.BatchableContext info) {
        //System.debug('Starting Batch');
        //System.debug('studyContacts: ' + studyContacts);
        return studyContacts;
    }
    
    // Step 2: Process records in batches, size of scope is decided when executing batch
    public void execute(Database.BatchableContext info, List<Study_Contact__c> scope) {
        List<API_Transaction__c> apiTrans = new List<API_Transaction__c>();
        List<Study_Contact__c> updateStudyContacts = new List<Study_Contact__c>();
        
        for(Study_Contact__c studyContact: scope) {
            if(studyContact.Study_Account__r.Secure_File_Platform__c != NULL && studyContact.Study_Account__r.Secure_File_Platform__c.IndexOf('AWS') > -1) {
                
                String accountName = studyContact.Study_Account__r.Account__r.Name;
                if(studyContact.Study_Account__r.Account__r.Alternate_Name__c != NULL) {
                    accountName = studyContact.Study_Account__r.Account__r.Alternate_Name__c;
                }
                
                String contactName = studyContact.Contact__r.FirstName + ' ' + studyContact.Contact__r.LastName;
                
                Boolean enabled = (studyContact.Status__c == 'Active' && studyContact.Study_Account__r.Status__c == 'Active');
                //System.debug('enabled: ' + enabled);
                
                Boolean canUpload = (studyContact.Role__c != NULL && studyContact.Role__c.IndexOf('Data Manager') > -1);
                Boolean canDowanload = True;
                
                AWSSecureFileClass.returnSetUser ret = AWSSecureFileClass.setUser(accountName, studyContact.Study_Account__r.Account__c, studyContact.Study_Account__r.Account__c, studyContact.Study__r.Name, studyContact.Study__c, contactName, studyContact.Contact__c, studyContact.Contact__r.Email, canUpload, canDowanload, enabled);
                
                if(ret.statusCode == 200 && enabled) {
                    studyContact.AWS_Folder_Access__c = 'Has Access';
                } else if(ret.statusCode == 200 && !enabled) {
                    studyContact.AWS_Folder_Access__c = 'Does Not Have Access';
                } else {
                    studyContact.AWS_Folder_Access__c = NULL;
                }
                studyContact.AWS_Folder_Access_Last_Updated__c = DateTime.Now();
                updateStudyContacts.add(studyContact);
                
                if(ret.apiTrans != NULL && !ret.apiTrans.IsEmpty()) {
                    for(API_Transaction__c apit :ret.apiTrans) {
                        apit.Study_Contact__c = studyContact.Id;
                        apiTrans.add(apit);
                    }
                }
            }
        }
        insert apiTrans;
        update updateStudyContacts;
    }
    
    // Step 3: Post batch process upon all batches finished
    public void finish(Database.BatchableContext info) {
        //System.debug('Finishing Batch');
    }
}