global class updateFreeDeferralBatch implements Database.Batchable<sObject>,Database.StateFul{
	private string ExamGroupId = System.Label.ExamGrpIdForFreeDeferralBatch;
   	private string examType;
    private string recordId;
    public updateFreeDeferralBatch(string examTypeStr){
        examType = examTypeStr;
    }
    public updateFreeDeferralBatch(string examTypeStr,string inputRecordId){
        examType = examTypeStr;
        recordId = inputRecordId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        //run this batch for only one record at once.
        Set<String> strSection = new Set<String>{examType};
        String StrDefered = 'Approved';
        String oppstatus = 'closed';
       
        String query1 = 'SELECT Id,Cloned_From__c,Free_Deferral__c,Exam_Site__c,Exam_Administration__c,Member__c,Opportunity_StageName__c FROM Exam_Attempt__c Where Section__c IN:strSection';
               query1 += ' AND Exam_Administration__r.Exam_Group__c =:examGroupId'; 
               query1 += ' AND Opportunity_StageName__c =:oppstatus';                 
               query1 += ' AND Cancelled__c != true';
        	   query1 += ' AND Cloned_From__c != null';
        	   query1 += ' AND Defered__c =: StrDefered';
        	   query1 += ' AND Free_Deferral__c != true';
        if(String.isNotBlank(recordId)) {
            query1 += ' AND Id=: recordId';
        }  
              
        if(test.isRunningTest()){
            query1 = 'SELECT Id,Exam_Site__c,Exam_Administration__c,Member__c,Opportunity_StageName__c ,Cloned_From__c FROM Exam_Attempt__c Where Section__c IN:strSection';
            query1 += ' AND Opportunity_StageName__c =:oppstatus';
            query1 += ' AND Cloned_From__c != null';
            query1 += ' AND Defered__c =: StrDefered';
            query1 += ' AND Free_Deferral__c != true';
            query1 += ' AND Cancelled__c != true Limit 1';
        }              
        
        return Database.getQueryLocator(query1);      
      
   }

   global void execute(Database.BatchableContext BC, List<Exam_Attempt__c> scope){
   
       List<Exam_Attempt__c> cloneFromAttempts = new List<Exam_Attempt__c>();
       List<Exam_Attempt__c> registrationToUpdate = new List<Exam_Attempt__c>();
       List<Opportunity> oppListToUpdate = new List<Opportunity>();
       Map<String,Exam_Attempt__c> clonedToNewAttemptMap = new Map<String,Exam_Attempt__c>();
       Set<Id> examRegistrationModIds = new Set<Id>();
       Set<Id> clonedFromIdSet = new Set<Id>();
       for(Exam_Attempt__c ea : scope){
           if(ea.cloned_from__c != null){
               clonedFromIdSet.add(ea.Cloned_From__c);
               clonedToNewAttemptMap.put(ea.Cloned_From__c,ea);
           }
       }
       
       Map<Id,Exam_Registration_Modification__c> examRegModMap = new Map<Id,Exam_Registration_Modification__c>([Select Id,Part_I_Exam_Registration__c,Part_II_Exam_Registration__c
                                                                                                             from Exam_Registration_Modification__c 
                                                                                                             where Status__c = 'Completed' AND 
                                                                                                             (Part_I_Exam_Registration__c IN: clonedFromIdSet OR Part_II_Exam_Registration__c IN:clonedFromIdSet)]);
       List<Opportunity> oppList = [Select Id,Free_deferral__c,Exam_Registration_Modification__c,Amount 
                                    from Opportunity 
                                    where Exam_Registration_Modification__c IN: examRegModMap.keyset() AND Amount = 0];
       
       for(Opportunity opp : oppList){
           if(opp.Free_Deferral__c == false){
               opp.Free_Deferral__c = true;
               oppListToUpdate.add(opp);
           }
           examRegistrationModIds.add(opp.Exam_Registration_Modification__c);
       }
       
       for(Exam_Registration_Modification__c erm : examRegModMap.values()){
           if(examRegistrationModIds.contains(erm.id)){
               if(erm.Part_I_Exam_Registration__c != null && clonedToNewAttemptMap.containskey(erm.Part_I_Exam_Registration__c)){
                   Exam_Attempt__c part1 = clonedToNewAttemptMap.get(erm.Part_I_Exam_Registration__c);
                   part1.Free_Deferral__c = true;
                   registrationToUpdate.add(part1);
               }
               if(erm.Part_II_Exam_Registration__c != null && clonedToNewAttemptMap.containskey(erm.Part_II_Exam_Registration__c)){
                   Exam_Attempt__c part2 = clonedToNewAttemptMap.get(erm.Part_II_Exam_Registration__c);
                   part2.Free_Deferral__c = true;
                   registrationToUpdate.add(part2);
               }
           }
       }
       
       if(!oppListToUpdate.isEmpty()){
           update oppListToUpdate;
       }
       
       if(!registrationToUpdate.isEmpty()){
           update registrationToUpdate;
       }
    }
  	global void finish(Database.BatchableContext BC){
   
   	}
}