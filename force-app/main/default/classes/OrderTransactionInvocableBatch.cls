global class OrderTransactionInvocableBatch implements Database.Batchable<Sobject>{
    
	@InvocableMethod(Label = 'Update Opportunity From Order Item')
    public static void runOppBatch(List<String> opportunityIds){
        //Sage_Default_Records_Ref__mdt mtdt = Sage_Default_Records_Ref__mdt.getInstance('Order_Batch_Size');
        //id jobId = database.executeBatch(new OrderTransactionInvocableBatch(opportunityIds), Integer.valueOf(mtdt.Value__c));
    }
    
    public OrderTransactionInvocableBatch(){
    }
    
    global Database.QueryLocator start(database.BatchableContext bc){
        return database.getQueryLocator([Select Id,createddate,Opportunity__r.Sage_order_Approved__c,Opportunity__r.Sage_Paid_Date__c,
                                         Opportunity__r.ia_crm__Intacct_Sync_Status_1__c,Opportunity__r.ia_crm__Intacct_Sync_Errors_1__c 
                                         from Order_Transaction_item__c 
                                         where Status__c = 'Approved' and Opportunity__r.Sage_order_Approved__c = false limit 30]);
    }
    
    global void execute(database.BatchableContext bc, List<Order_Transaction_item__c> scope){
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity> oppsToUpdate = new List<opportunity>();
        
        for(Order_Transaction_item__c oti : scope){
            oppIds.add(oti.Opportunity__c);
            oti.Status__c = 'Processed';
        }
        
        List<Opportunity> oppsList = [Select Id,Sage_Order_Approved__c,ia_crm__Intacct_Sync_Status_1__c,ia_crm__Intacct_Sync_Errors_1__c
                                      from Opportunity where Id IN: oppIds and Sage_order_Approved__c = false];
        
        for(Opportunity opp : oppsList){
            opp.Sage_Order_Approved__c = true;
            opp.ia_crm__Intacct_Sync_Status_1__c = '';
            opp.ia_crm__Intacct_Sync_Errors_1__c = '';
            oppsToUpdate.add(opp);
        }
        
        update scope;
        
        if(!oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }
    }
    
    global void finish (Database.BatchableContext bc){
        
    }
}