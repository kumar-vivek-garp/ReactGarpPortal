global class CalculateExperience_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query  = 'SELECT Id, No_of_Months_F__c,Start_Date__c, End_Date__c,Program_Requirement__c,Program_Requirement__r.Status__c,Program_Requirement__r.Total_Experience_Months__c';
        query += ' FROM Experience__c Where Program_Requirement__r.Status__c = \'Ready For Review\' and';
        query += ' Program_Requirement__c != Null ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Experience__c> Scope){
        
        List<Candidate_Requirement__c> PreqList = new List<Candidate_Requirement__c>();
        Map<String,List<Experience__c>> PRExpMap = new Map<String,List<Experience__c>>();
        Map<String,Integer> ExpMap = new Map<String,Integer>();
        for(Experience__c exprn : Scope){
            
            if(PRExpMap.containsKey(exprn.Program_Requirement__c)){
                PRExpMap.get(exprn.Program_Requirement__c).add(exprn);
            }else{
                PRExpMap.put(exprn.Program_Requirement__c,new List<Experience__c>{exprn});
            }   
        }
        
        for(String prId : PRExpMap.keySet()){
            Integer sumOfExp = 0;
            for(Experience__c exprn : PRExpMap.get(prId)){
                if(exprn.End_Date__c == Null){
                    sumOfExp = sumOfExp + exprn.Start_Date__c.monthsBetween(Date.Today());
                }
                else{
                    sumOfExp = sumOfExp + exprn.Start_Date__c.monthsBetween(exprn.End_Date__c);
                }
                system.debug('sumOfExp::>>   '+sumOfExp);
            }
            ExpMap.put(prId,sumOfExp); 
        }
        if(ExpMap.keyset().size()>0){
            for(Candidate_Requirement__c cr: [select id,Total_Experience_Months__c from Candidate_Requirement__c where id IN: ExpMap.keyset()]){
                if(ExpMap.get(cr.id) != cr.Total_Experience_Months__c){
                    
                    cr.Total_Experience_Months__c = ExpMap.get(cr.id);
                    PreqList.add(cr);
                }
                
            }
            
        }
            
        if(PreqList.size()>0){
            update PreqList;
        }
    }
        
    global void finish(Database.BatchableContext BC){}
}