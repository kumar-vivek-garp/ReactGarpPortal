global class batchStudyVoteStatusUpdate implements Database.Batchable<sobject>{

    
  global Database.Querylocator start (Database.BatchableContext BC) {
    
          return Database.getQueryLocator('SELECT Id, Name, End_Date__c, Start_Date__c, Status__c, Study__c FROM Study_Vote__c where Status__c = \'Opened\' and End_Date__c < today');
      
 }     
   global void execute (Database.BatchableContext BC, List<Study_Vote__c> scope) {
       
       List<Study_Vote__c> scopecont = new list<Study_Vote__c>();
       
       for (Study_Vote__c sv: scope) 
       { 
        
              if(sv.End_Date__c < DateTime.Now() && sv.Status__c =='Opened') {
               sv.Status__c = 'Closed';   
           } 
           scopecont.add(sv);    
           
       }
      if(!scopecont.isEmpty()) { 
      update scopecont;  
  }
}
  global void finish(Database.BatchableContext BC){}
  
  
}