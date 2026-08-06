/**
* Class BulkOrderTriggerHandler
*
* Trigger Handler for the Bulk_Orders__c SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class BulkOrderTriggerHandler implements TriggerAbstract {
    public static boolean stopRecurssion = false;
    static List<Bulk_Orders__c > BOList = new List<Bulk_Orders__c >();
    Map<String,Bulk_Orders__c> BOMap = new Map<String,Bulk_Orders__c>();
    
    // Constructor
    public BulkOrderTriggerHandler(){}
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        if(!stopRecurssion){
            
            if (Trigger.isDelete){}
        }
    }
    
    public void bulkAfter(){
        //system.debug('**********In BulkOrderTriggerHandler bulkAfter*******  ');
        
        if(!stopRecurssion){
            if(!trigger.isDelete){
                //system.debug('     <<::  bulkAfter  trigger.oldMap ::>>   '+trigger.oldMap);
            }
        }
    }
    
    public void beforeInsert(SObject so){
        if(!stopRecurssion){
            Bulk_Orders__c newBO = (Bulk_Orders__c)so;
            updatecountrycode(newBO,null);
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        Bulk_Orders__c newBO = (Bulk_Orders__c)so;
        Bulk_Orders__c oldBO = (Bulk_Orders__c)oldSo;
        if(!stopRecurssion){
            updatecountrycode(newBO,oldBO);
        }
    }
    
    public void beforeDelete(SObject so){}
    
    public void afterInsert(SObject so){
        Bulk_Orders__c newBO = (Bulk_Orders__c)so;
        if(!stopRecurssion){
            if(newBO.Status__c == 'Approved'){
                BOMap.put(newBO.Id, newBO);
            }
           // system.debug(BOMap.size()+'     <<::  afterInsert  BOMap ::>>   '+BOMap);
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        Bulk_Orders__c newBO = (Bulk_Orders__c)so;
        Bulk_Orders__c oldBO = (Bulk_Orders__c)oldSo;
        
        if(!stopRecurssion){
            if(oldBO.Status__c != newBO.Status__c && newBO.Status__c == 'Approved'){
                BOMap.put(newBO.Id, newBO);
            }
           //system.debug(BOMap.size()+'     <<::  afterUpdate  BOMap ::>>   '+BOMap);
        }
    }
    
    public void afterDelete(SObject so){}
    
    /**
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally(){
        if(!stopRecurssion){
            if(!BOMap.isEmpty()){
                BulkOrderTriggerHandlerHelper.createOpportunity(BOMap);
            }
            if(trigger.isAfter){
                if(trigger.isUpdate){
                    stopRecurssion = true;
                }
            }
        }
    }
    
    // Code from "updatecountrycode" Trigger
    public void updatecountrycode(Bulk_Orders__c newBO,Bulk_Orders__c oldBO){
        if(String.isNotBlank(newBO.Shipping_Country__c)){
            CountryCodes__c countryCodes = CountryCodes__c.getValues(newBO.Shipping_Country__c);
            newBO.Country_Code_for_UPS__c = countryCodes != null ? countryCodes.Country_Code__c : '';
        }
    }
    
}