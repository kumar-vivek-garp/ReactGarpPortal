/**
* Class AffiliateProgramTriggerHandler
* Trigger Handler for the Affiliate_Program__c SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class AffiliateProgramTriggerHandler implements TriggerAbstract {
    public static boolean stopRecurssion = false;
    
    // Constructor
    public AffiliateProgramTriggerHandler(){}
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        if(!stopRecurssion){
            if (!Trigger.isDelete){}
        }
    }
    
    public void bulkAfter(){
        if(!stopRecurssion){
            
            if (!Trigger.isDelete){}
            
        }
    }
    
    
    public void beforeInsert(SObject so){
        if(!stopRecurssion){
            Affiliate_Program__c newObj = (Affiliate_Program__c)so;
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        if(!stopRecurssion){
            Affiliate_Program__c newObj = (Affiliate_Program__c)so;
            Affiliate_Program__c oldObj = (Affiliate_Program__c)oldSo;
        }
    }
    
    public void beforeDelete(SObject so){
        Affiliate_Program__c newObj = (Affiliate_Program__c)so;
    }
    
    public void afterInsert(SObject so){
        if(!stopRecurssion){}
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
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
        if(!stopRecurssion){
            if(trigger.isBefore && trigger.isInsert){
                checkAccessCode(trigger.new);
            }
            
            if(trigger.isAfter){
                
                if(trigger.isUpdate){
                    stopRecurssion = true;
                }
            }
        }
    }
    
    
    public static void checkAccessCode(List<Affiliate_Program__c> APList){
        Set<String> accessCodeSet = new Set<String>();
        
        List<Affiliate_Program__c> fullAPList = [Select Id,Affiliate_Code__c from Affiliate_Program__c WHERE Affiliate_Code__c != NULL LIMIT 50000];
        
        for(Affiliate_Program__c record : fullAPList){
            accessCodeSet.add(record.Affiliate_Code__c);
        }
        
        
        for(Affiliate_Program__c rec : APList){
            if(string.isBlank(rec.Affiliate_Code__c)){
                string uniqueCode;
                do{
                    uniqueCode = Utilities.getRandomCode();
                }while(accessCodeSet.contains(uniqueCode));
                rec.Affiliate_Code__c = uniqueCode;
            }
        }
    }
    
}