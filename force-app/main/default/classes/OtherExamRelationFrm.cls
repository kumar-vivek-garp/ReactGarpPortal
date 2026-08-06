global class OtherExamRelationFrm implements Database.Batchable<sObject>,Database.StateFul{
       
       List<Exam_Date__c > lstDate = Exam_Date__c.getAll().values();
       date datExam1 = lstDate[0]. Date__c;  
       String datExam = lstDate[0].Date_String__c;
       String ExamAdminId = lstDate[0].Exam_Group_Id__c;  

global Database.QueryLocator start(Database.BatchableContext BC){
      
  //run this batch for only one record at once.

        String strSection ='FRM Part 2';
        string id ='a1a1W000009H0It';
        String oppstatus = 'closed';
        string teststrsection ='FRM Part 2';
        

    String query1 = 'SELECT Id,Exam_Site__c,Member__c,Site_code__c,Candidate_Commitment__c ,Exam_Site__r.Site__c,ADA_Status__c,RAD_Status__c,Opportunity_StageName__c ,Other_Exam_Registrations__c,Site_Id__c FROM Exam_Attempt__c Where Section__c=:strSection';
    query1 += ' AND Exam_Administration__c =\''+ExamAdminId+'\''; 
    query1 += ' AND Opportunity_StageName__c =\''+oppstatus+'\'';                 
    query1 += ' AND  Cancelled__c != true';                
    
               
      if(test.isRunningTest()){
            
            query1 = 'SELECT Id,Exam_Site__c,Member__c,Candidate_Commitment__c,Site_code__c,Exam_Site__r.Site__c,ADA_Status__c,RAD_Status__c,Opportunity_StageName__c ,Other_Exam_Registrations__c,Site_Id__c FROM Exam_Attempt__c Where Section__c =:teststrsection';
            query1 += ' AND Opportunity_StageName__c =\''+oppstatus+'\'';  
            query1 += ' AND  Cancelled__c != true';                
             
         }              
              
         return Database.getQueryLocator(query1);      
      
   }

   global void execute(Database.BatchableContext BC, List<Exam_Attempt__c> scope){
        
        string Exam2Id='';
        List<String> lstMember = new List<String>();
        Map<String,Id> mapExam2 = new Map<String,Id>();
        List<Exam_Attempt__c> objExmAttempt = new List<Exam_Attempt__c>();
        List<Exam_Attempt__c> objExmAttempt1 = new List<Exam_Attempt__c>();
        list<id> eaid = new list<id>();
        
        
      for(Exam_Attempt__c objList : scope)
        {
            lstMember .add(objList.Member__c);  
            eaid.add(objList.id);
            
        }
        
        id es =(new list<id>(eaid) )[0];

       
        List<Exam_Attempt__c> lstExam2 = [SELECT Id,Member__c,Cancelled__c,ADA_Status__c,Defered__c,RAD_Status__c,Opportunity_StageName__c FROM Exam_Attempt__c where Member__c in: lstMember AND Section__c ='FRM Part 1' AND Exam_Administration__c =:ExamAdminId and Cancelled__c !=true  and Opportunity_StageName__c ='closed' ];
        
      for(Exam_Attempt__c objExam2 : lstExam2)
        {
            mapExam2.put(objExam2.Member__c,objExam2.id);
            
        } 
      
      for(Exam_Attempt__c lstExam21 : lstExam2)
        {
            if(lstExam21!= null )
            {
              
              lstExam21.Other_Exam_Registrations__c=es;
              objExmAttempt1.add(lstExam21);
             
        }}
        
      for(Exam_Attempt__c objScope : scope)
        {
            if(mapExam2!= null && mapExam2.get(objScope.Member__c)!= null)
            {
               Exam2Id = mapExam2 != null && mapExam2.size() > 0 ? mapExam2.get(objScope.Member__c) : null;
               objScope.Other_Exam_Registrations__c=Exam2Id != null ? Exam2Id : null;  
               objExmAttempt.add(objScope);
            
              }}
         
         Database.saveresult[] SR = database.update(objExmAttempt, false);  
         Database.saveresult[] SR1 = database.update(objExmAttempt1, false);  
    }
  
   global void finish(Database.BatchableContext BC){
   
   }
}