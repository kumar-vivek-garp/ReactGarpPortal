/**
* Class OpportunityLineItemTriggerHandler
*
* Trigger Handler for the OpportunityLineItem SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/

public without sharing class OpportunityLineItemTriggerHandler implements TriggerAbstract {
    public static boolean stopRecurssion = false;
    static Map<String,List<OpportunityLineItem>> relatedOppIdOLIMap = new Map<String,List<OpportunityLineItem>>();
    
    // Constructor
    public OpportunityLineItemTriggerHandler(){}
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        if(!stopRecurssion){
        }
    }
    
    public void bulkAfter(){
        if(trigger.isUpdate && trigger.oldMap != null){
            /*for(OpportunityLineItem newOLI: (List<OpportunityLineItem>)Trigger.new){
                OpportunityLineItem oldOLI = (OpportunityLineItem)Trigger.oldMap.get(newOLI.Id);
                if(newOLI.Site_Code__c != null && oldOLI.Site_Code__c != null && oldOLI.Site_Code__c != newOLI.Site_Code__c){
                    if(relatedOppIdOLIMap.containsKey(newOLI.OpportunityId)){
                        List<OpportunityLineItem> oliList = relatedOppIdOLIMap.get(newOLI.OpportunityId);
                        oliList.add(newOLI);
                        relatedOppIdOLIMap.put(newOLI.OpportunityId,oliList);
                    }else{
                        relatedOppIdOLIMap.put(newOLI.OpportunityId,new List<OpportunityLineItem>{newOLI});
                    }
                    
                }
            }*/
        }
    }
    
    public void beforeInsert(SObject so){
        if(!stopRecurssion){
            
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        // Cast the SObject to an Contact
        OpportunityLineItem newRecord = (OpportunityLineItem)so;
        OpportunityLineItem oldRecord = (OpportunityLineItem)oldSo;
        if(!stopRecurssion){
            //processBeforeUpdateAndInsert(newRecord,oldRecord);
        }
    }
    
    public void beforeDelete(SObject so){}
    
    public void afterInsert(SObject so){
        OpportunityLineItem newRecord = (OpportunityLineItem)so;
        if(!stopRecurssion){
            //processAfterUpdateAndInsert(newRecord,null);
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        // Cast the SObject to an Contact
        OpportunityLineItem newRecord = (OpportunityLineItem)so;
        OpportunityLineItem oldRecord = (OpportunityLineItem)oldSo;
        if(!stopRecurssion){
            //processBeforeUpdateAndInsert(newRecord,oldRecord);
        }
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
        if(!stopRecurssion){
            if(trigger.isAfter){
                if(trigger.isUpdate){
                    stopRecurssion = true;
                    //ContactTriggerHelper.createCommunityUser(trigger.new);
                    /*if(relatedOppIdOLIMap.KeySet().size() > 0){
                        ID jobID = System.enqueueJob(new OpportunityLineItemQueueableClass(relatedOppIdOLIMap));
                        System.debug('jobID::>>>   '+jobID);
                    }*/
                }
            }
        }
    }
    
    
}