/**
* Class ExperienceTriggerHandler
*
* Trigger Handler for the Experience__c SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class ExperienceTriggerHandler implements TriggerAbstract {
    public static boolean stopRecurssion = false;
    static Map<String,List<Experience__c>> PRExpMap = new Map<String,List<Experience__c>>();
    
    // Constructor
    public ExperienceTriggerHandler(){
        
    }
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        //system.debug('in here bulkBefore::>> '+stopRecurssion);
        if(!stopRecurssion){}
        //system.debug('PRExpMap bulkBefore::>> '+PRExpMap);
    }
    
    public void bulkAfter(){
        //system.debug('in here bulkAfter::>> '+stopRecurssion);
        Set<String> prIdSet = new Set<String>();
        if(!stopRecurssion){
            if (!Trigger.isDelete){
                for(Experience__c newExp : (List<Experience__c>)trigger.New){
                    prIdSet.add(newExp.Program_Requirement__c);
                }
            }else{
                for(Experience__c oldExp : (List<Experience__c>)trigger.Old){
                    prIdSet.add(oldExp.Program_Requirement__c);
                }
            }
            for(Experience__c exp : [SELECT Id, Program_Requirement__c, No_of_Months_F__c FROM Experience__c 
                                     WHERE Program_Requirement__c IN: prIdSet])
            {
                if(exp.Program_Requirement__c != null ){
                    if(PRExpMap.containsKey(exp.Program_Requirement__c)){
                        List<Experience__c> expList = PRExpMap.get(exp.Program_Requirement__c);
                        expList.add(exp);
                        PRExpMap.put(exp.Program_Requirement__c,expList);
                    }else{
                        PRExpMap.put(exp.Program_Requirement__c,new List<Experience__c>{exp});
                    }
                }
            }
        }
        //system.debug(!Trigger.isDelete+'     <<::PRExpMap bulkAfter::>> '+PRExpMap);
    }
    
    public void beforeInsert(SObject so){
        if(!stopRecurssion){
            Experience__c newRec = (Experience__c)so;
            populateNoOfMonths(newRec);
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        Experience__c newRec = (Experience__c)so;
        Experience__c oldRec = (Experience__c)oldSo;
        if(!stopRecurssion){
            if(newRec.Start_Date__c != oldRec.Start_Date__c || newRec.End_Date__c != oldRec.End_Date__c){
                populateNoOfMonths(newRec);
            }
        }
    }
    
    public void beforeDelete(SObject so){
        // Cast the SObject to an Experience__c
        Experience__c myCont = (Experience__c)so;
        
    }
    
    public void afterInsert(SObject so){
        Experience__c newCont = (Experience__c)so;
        if(!stopRecurssion){}
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        Experience__c newCont = (Experience__c)so;
        Experience__c oldCont = (Experience__c)oldSo;
        if(!stopRecurssion){}
    }
    
    public void afterDelete(SObject so){
    }
    
    /**
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally(){
        //system.debug('in here andFinally::>> '+stopRecurssion);
        if(!stopRecurssion){
            if(trigger.isAfter){
                if(!PRExpMap.keySet().isEmpty()){
                    populateNoOfMonthsOnPR(PRExpMap);
                }
                if(trigger.isUpdate){
                    stopRecurssion = true;
                }
            }
        }
    }
    
    public void populateNoOfMonths(Experience__c newRec){
        Date endDate = newRec.End_Date__c != NULL ? newRec.End_Date__c : system.Today();
        Integer monthsBetween = newRec.Start_Date__c.monthsBetween(endDate);
        //system.debug(newRec.Start_Date__c +'  ::  '+endDate+'  ::  '+monthsBetween);
        newRec.No_of_Months__c = monthsBetween;
    }
    
    public void populateNoOfMonthsOnPR(Map<String,List<Experience__c>> PRExpFinalMap){
        //system.debug('PRExpFinalMap::>>   '+PRExpFinalMap);
        List<Candidate_Requirement__c> PRList = new List<Candidate_Requirement__c>();
        for(String prId : PRExpFinalMap.keySet()){
            Integer sumOfExp = 0;
            for(Experience__c exp : PRExpFinalMap.get(prId)){
                sumOfExp = sumOfExp + Integer.valueOf(exp.No_of_Months_F__c);
               // system.debug(Integer.valueOf(exp.No_of_Months_F__c)+'  <<::sumOfExp::>>   '+sumOfExp);
            }
            
            Candidate_Requirement__c cr = new Candidate_Requirement__c(Id = prId, Total_Experience_Months__c = sumOfExp);
            //system.debug('cr::>>   '+cr);
            PRList.add(cr);
        }
        if(!PRList.isEmpty()){
            //system.debug('PRList::>>   '+PRList);
            update PRList;
        }
    }
}