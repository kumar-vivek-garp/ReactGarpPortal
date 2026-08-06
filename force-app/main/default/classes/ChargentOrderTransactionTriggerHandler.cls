public without sharing class ChargentOrderTransactionTriggerHandler implements TriggerAbstract{
    Public static List<Opportunity> OppListToUpdate = new List<Opportunity>();
    static List<Product_Refunds__c> ProductRefundsListToUpdate = new List<Product_Refunds__c>();
    static Set<String> VoidTypeOppSet = new Set<String>();
    static Map<String,ChargentOrders__Transaction__c> RecurringTypeOppSet = new Map<String,ChargentOrders__Transaction__c>();
    static Map<String,ChargentOrders__Transaction__c> ChargeTypeOppSet = new Map<String,ChargentOrders__Transaction__c>();
    static Set<String> RefundOppSet = new Set<String>();
    static Map<String,ChargentOrders__Transaction__c> oppTransactionMap = new Map<String,ChargentOrders__Transaction__c>();
    static List<Transaction_Event__e> eventList = new List<Transaction_Event__e>();
    
    
    public static boolean stopRecurssion = true;
    
    // Constructor
    public ChargentOrderTransactionTriggerHandler(){
    }
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore(){
        if(stopRecurssion){}
    }
    
    public void bulkAfter(){
        if(stopRecurssion){}
    }
    
    public void beforeInsert(SObject so){
        //system.debug('**********In ChargentOrdersTriggerHandler beforeInsert*******  ');
        ChargentOrders__Transaction__c newTransaction = (ChargentOrders__Transaction__c)so;
        newTransaction.Opportunity__c = newTransaction.Opportunity_Formula__c;
        if(stopRecurssion){
            if(newTransaction.ChargentOrders__Response_Status__c == 'Approved' && newTransaction.ChargentOrders__Type__c == 'Charge' && 
               newTransaction.ChargentOrders__Amount__c > 0 && !newTransaction.ChargentOrders__Recurring__c && newTransaction.ChargentOrders__Payment_Method__c == 'Credit Card') {        
                   Transaction_Event__e evt = new Transaction_Event__e();
                   evt.Amount__c = newTransaction.ChargentOrders__Amount__c;
                   evt.Authorization__c = newTransaction.ChargentOrders__Authorization__c;
                   evt.Card_Last_4__c = newTransaction.ChargentOrders__Card_Last_4__c;
                   evt.Chargent_Token__c = newTransaction.ChargentOrders__Tokenization__c;
                   evt.Gateway_Date__c = newTransaction.ChargentOrders__Gateway_Date__c;
                   evt.Gateway_ID__c = newTransaction.ChargentOrders__Gateway_ID__c;
                   evt.Gateway_Response__c = newTransaction.ChargentOrders__Gateway_Response__c;
                   evt.Opportunity_ID__c = newTransaction.Opportunity__c;
                   evt.Response_Status__c = newTransaction.ChargentOrders__Response_Status__c;
                   eventList.add(evt); 
               }
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        
        if(stopRecurssion){}
    }
    
    public void beforeDelete(SObject so){
        //system.debug('**********In ChargentOrdersTransactionTriggerHandler beforeDelete*******  ');
        
    }
    
    public void afterInsert(SObject so){
        //system.debug('**********In ChargentOrdersTransactionTriggerHandler afterInsert*******  ');
        ChargentOrders__Transaction__c newTransaction = (ChargentOrders__Transaction__c)so;
        if(stopRecurssion){
            String ordersType = newTransaction.ChargentOrders__Type__c;
            if(!newTransaction.Do_not_fire__c){
                if(newTransaction.ChargentOrders__Response_Status__c== 'Approved' && ordersType =='Charge' && 
                   newTransaction.ChargentOrders__Recurring__c != true && newTransaction.Opportunity_Stage__c =='New Lead'){
                       ChargeTypeOppSet.put(newTransaction.Opportunity__c,newTransaction); 
                      
                   }
                
                
                if(newTransaction.ChargentOrders__Response_Status__c== 'Approved' && 
                   (ordersType =='Refund'|| ordersType =='Charge Back Accepted' || ordersType =='Charge Back Loss')){
                       RefundOppSet.add(newTransaction.Opportunity__c); 
                       
                       oppTransactionMap.put(newTransaction.Opportunity__c,newTransaction);    
                   }
            }
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
       //system.debug('**********In ChargentOrdersTransactionTriggerHandler afterUpdate*******  ');
        ChargentOrders__Transaction__c newTransaction = (ChargentOrders__Transaction__c)so;
        ChargentOrders__Transaction__c oldTransaction = (ChargentOrders__Transaction__c)oldSo;
        if(stopRecurssion){
            String ordersType = newTransaction.ChargentOrders__Type__c;
            //system.debug(newTransaction.ChargentOrders__Response_Status__c+'   :::    '+newTransaction.ChargentOrders__Type__c);
            if(newTransaction.ChargentOrders__Response_Status__c== 'Approved' && ordersType =='Void' && 
               newTransaction.ChargentOrders__Recurring__c != true && newTransaction.Opportunity_Stage__c =='New Lead'){
                   VoidTypeOppSet.add(newTransaction.Opportunity__c);                   
               }
            
            if(newTransaction.ChargentOrders__Response_Status__c== 'Approved' && newTransaction.Opportunity__c != oldTransaction.Opportunity__c &&
               (ordersType =='Charge' || ordersType =='Refund'|| ordersType =='Charge Back Accepted' || ordersType =='Charge Back Loss')){
                   RecurringTypeOppSet.put(newTransaction.Opportunity__c,newTransaction);                   
               }
        }
        
    }
    
    public void afterDelete(SObject so){
        //system.debug('**********In ChargentOrdersTransactionTriggerHandler afterDelete*******  ');
    }
    
    /**
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally(){
        if(!trigger.isDelete && stopRecurssion){
            if(trigger.isafter && trigger.isinsert){
                if(ChargeTypeOppSet.size() > 0){
                    for(Opportunity opp : [SELECT Id,StageName,Gateway__r.Name,Gateway__c, Account.Member_First_Name__c, Account.Member_Last_Name__c FROM Opportunity WHERE Id IN: ChargeTypeOppSet.keyset()]){
                        ChargentOrders__Transaction__c ordTrans = ChargeTypeOppSet.get(opp.Id);
                        opp.StageName = 'Closed';
                        opp.CloseDate = ordTrans.ChargentOrders__Gateway_Date__c != null ? ordTrans.ChargentOrders__Gateway_Date__c.Date() :  system.today();
                        opp.Payment_Method_New__c = ordTrans.ChargentOrders__Payment_Method__c;
                        opp.Alternate_Method_of_Payment__c= ordTrans.ChargentOrders__Payment_Method__c;
                        if(ordTrans.ChargentOrders__Credit_Card_Type__c != null){
                            opp.Cardtype__c = ordTrans.ChargentOrders__Credit_Card_Type__c;
                        }
                        if(opp.Gateway__c != null && opp.Gateway__r.Name.contains('paypal')){
                            opp.Gateway_Token__c = ordTrans.ChargentOrders__Tokenization__c;
                        }else{
                            opp.Gateway_Token__c = ordTrans.ChargentOrders__Gateway_ID__c;
                        }
                        opp.Gateway_Time__c = ordTrans.ChargentOrders__Gateway_Date__c;
                        opp.Token__c = ordTrans.ChargentOrders__Tokenization__c;
                        opp.Charge_transaction_count_number__c = 1;
                        if(ordTrans.ChargentOrders__Payment_Method__c == 'Free'){
                            opp.Free_Transaction_Checkbox__c = true;
                        }
                        
                        
                        System.Debug('********* Set Opp Address *************');  
						// CR 7/16/26 updated logic   
                        if(ordTrans.isStripePay__c == true){                    
                            mapOrderToOpportunity(opp, ordTrans);
                        }
                        OppListToUpdate.add(opp);
                    }
                }
                
                Map<Id,List<Product_Refunds__c>> oppToRefundProdsMap = new Map<Id,List<Product_Refunds__c>>();
                Map<Id,Id> switchTransactionMap = new Map<Id,Id>();
                if(RefundOppSet.size() > 0 && oppTransactionMap.size() > 0){
                    for(Product_Refunds__c pr : [SELECT Id,status__C,Opportunity__c,Reason__c,Product__c,Refund_Amount__c,Discount_Product_code__c FROM Product_Refunds__c WHERE Opportunity__c IN: RefundOppSet and status__c ='Approved']){
                        pr.Status__c  ='Completed';
                        pr.Payment_Order_Transaction__c = oppTransactionMap.get(pr.Opportunity__c).Id;
                        ProductRefundsListToUpdate.add(pr); 
                        if(pr.Reason__c != 'Switch'){
                            if(oppToRefundProdsMap.containsKey(pr.Opportunity__c)){
                                List<Product_Refunds__c> prodIds = oppToRefundProdsMap.get(pr.Opportunity__c);
                                prodIds.add(pr);
                                oppToRefundProdsMap.put(pr.Opportunity__c,prodIds);
                            }else{
                                oppToRefundProdsMap.put(pr.Opportunity__c,new List<Product_Refunds__c>{pr});
                            }
                        }else if(pr.Reason__c == 'Switch'){
                            switchTransactionMap.put(oppTransactionMap.get(pr.Opportunity__c).Id,pr.Opportunity__c);
                        }
                    }
                    
                    if(oppToRefundProdsMap != null || switchTransactionMap != null){
                        SageRefundProcessQueueable sageQueue = new SageRefundProcessQueueable(oppToRefundProdsMap,oppTransactionMap,switchTransactionMap);
                        ID jobID = System.enqueueJob(sageQueue);
                    }
                }
            }
            
            if(trigger.isafter && trigger.isUpdate){
                if(VoidTypeOppSet.size() > 0){
                    for(Opportunity opp : [SELECT Id,StageName FROM Opportunity WHERE Id IN: VoidTypeOppSet]){
                        opp.StageName = 'Recurring Intent';
                        opp.CloseDate = system.today();
                        OppListToUpdate.add(opp);
                    }
                }
                
                if(RecurringTypeOppSet.size() > 0){
                    for(Opportunity opp : [SELECT Id,StageName FROM Opportunity WHERE Id IN: RecurringTypeOppSet.keyset()]){
                        ChargentOrders__Transaction__c ordTrans = RecurringTypeOppSet.get(opp.Id);
                        if(ordTrans.ChargentOrders__Credit_Card_Type__c != null){
                            opp.Cardtype__c = ordTrans.ChargentOrders__Credit_Card_Type__c;
                        }
                        opp.Token__c = ordTrans.ChargentOrders__Tokenization__c;
                        opp.Payment_Method_New__c = ordTrans.ChargentOrders__Payment_Method__c;
                        opp.Alternate_Method_of_Payment__c= ordTrans.ChargentOrders__Payment_Method__c;
                        opp.Charge_transaction_count_number__c = 1;
                        if(ordTrans.ChargentOrders__Payment_Method__c == 'Free'){
                            opp.Free_Transaction_Checkbox__c = true;
                        }
                        OppListToUpdate.add(opp);
                    }
                }
            }
        
            if(OppListToUpdate.size() > 0){
              update OppListToUpdate;  
            }
            
            if(ProductRefundsListToUpdate.size() > 0){
                update ProductRefundsListToUpdate; 
            }
            
            if(eventList.size() > 0){
               EventBus.Publish(eventList); 
            }
            if(trigger.isAfter && trigger.isUpdate){
                stopRecurssion = false;
            }
        }
    }
    
    
    private static void mapOrderToOpportunity(Opportunity opp,ChargentOrders__Transaction__c ordTrans) {
        if (opp == null || ordTrans == null) {
            return;
        }
        
        if (opp.Account != null) {
            setIfNotNull( opp, Opportunity.Billing_First_Name__c, opp.Account.Member_First_Name__c);            
            setIfNotNull(opp,Opportunity.Billing_Last_Name__c,opp.Account.Member_Last_Name__c);            
            setIfNotNull(opp,Opportunity.Shipping_First_Name__c,opp.Account.Member_First_Name__c);            
            setIfNotNull(opp, Opportunity.Shipping_Last_Name__c,opp.Account.Member_Last_Name__c);
        }
        
        setIfNotNull(opp,Opportunity.Billing_Address__c,ordTrans.ChargentOrders__Billing_Address__c);
        
        setIfNotNull(opp,Opportunity.Billing_City__c,ordTrans.ChargentOrders__Billing_City__c);
        
        setIfNotNull(opp,Opportunity.Billing_State_Text__c,ordTrans.ChargentOrders__Billing_Province__c);
        
        setIfNotNull(opp,Opportunity.Billing_Zip_Postal__c,ordTrans.ChargentOrders__Billing_Postal_Code__c);
        
        setIfNotNull(opp,Opportunity.Billing_Country__c,ordTrans.ChargentOrders__Billing_Country__c);
        
        setIfNotNull(opp,Opportunity.Shipping_Street__c,ordTrans.Shipping_Street__c);
        
        setIfNotNull(opp,Opportunity.Shipping_City__c,ordTrans.Shipping_City__c);
        
        setIfNotNull(opp,Opportunity.Shipping_State__c,ordTrans.Shipping_State__c);
        
        setIfNotNull(opp,Opportunity.Shipping_Postal_Code__c,ordTrans.Shipping_Postal_Code__c);
        
        setIfNotNull(opp,Opportunity.Shipping_Country__c,ordTrans.Shipping_Country__c);        
        setIfNotNull(opp, Opportunity.Stripe_Tax_Country__c,ordTrans.Stripe_Tax_Country__c);
        
        setIfNotNull(opp,Opportunity.Stripe_Tax_Taxable_Amount__c,ordTrans.Stripe_Tax_Taxable_Amount__c);        
        setIfNotNull(opp,Opportunity.Stripe_Tax_Type__c,ordTrans.Stripe_Tax_Type__c);
    }
    
    private static void setIfNotNull(
        SObject oppRec,
        Schema.SObjectField oppField,
        Object ordTrans
    ) {
        if (ordTrans != null) {
            oppRec.put(oppField, ordTrans);
        }
    }
}