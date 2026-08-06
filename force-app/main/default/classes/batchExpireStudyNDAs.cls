global class batchExpireStudyNDAs implements Database.Batchable<SObject>{
         
            Set<String> checkStatus = new Set<String>{'Expired'};
            public String testIds;  
            
            global batchExpireStudyNDAs(String testIds){ 
                this.testIds= testIds;
            }    
            
            global Database.QueryLocator start(Database.BatchableContext BC){
            
                           Set<String> ids = new Set<String>{''};
                       
                           if(this.testIds != null) {
                               ids = new Set<String>{this.testIds};
                                   }
                          
               if(this.testIds != null) {       
                   return Database.getQueryLocator('SELECT Id, Name, Latest_NDA_Dated_Date__c, Next_NDA_Review_Date__c, Received_At__c, Status__c, Account__c FROM Study_NDA__c where id in:ids and Status__c not in:checkStatus');
               } else {
                   return Database.getQueryLocator('SELECT Id, Name, Latest_NDA_Dated_Date__c, Next_NDA_Review_Date__c, Received_At__c, Status__c, Account__c FROM Study_NDA__c where Status__c not in:checkStatus');
               }
           
           }
            
           global void execute(Database.BatchableContext BC, List<Study_NDA__c> scope){
            
                List<Study_NDA__c> lstStudyNDAs = new List<Study_NDA__c>();
                       
  
                for(Study_NDA__c nda : scope){
                        
                if (nda.Next_NDA_Review_Date__c == date.today() - 1)
                {
                nda.Status__c = 'Expired';
               }
                lstStudyNDAs.add(nda);
        }
                update lstStudyNDAs;
        }
    
         global void finish(Database.BatchableContext BC){
                 }
        }