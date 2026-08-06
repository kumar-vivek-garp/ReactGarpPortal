/**
* Class SalesOrderHandler
* 
* Trigger Handler for the Sales Order SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class SalesOrderHandler implements TriggerAbstract {
    static Set<Id> opportunityIdSet = new Set<Id>();
    // Constructor
    public SalesOrderHandler(){
        
    }
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        
    }
    
    public void bulkAfter(){
    }
    
    public void beforeInsert(SObject so){
        
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        
    }
    
    public void beforeDelete(SObject so){
        
    }
    
    public void afterInsert(SObject so){
        ia_crm__Sales_Order__c newOrd = (ia_crm__Sales_Order__c)so;
        if(newOrd.ia_crm__Opportunity__c != null){
            opportunityIdSet.add(newOrd.ia_crm__Opportunity__c);
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        
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
        if(trigger.isafter && trigger.isInsert){
            SalesOrderHelper.Updateopportunity(opportunityIdSet);
        }
    }
}