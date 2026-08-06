global class batchUpdatetransaction implements Database.Batchable<SObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('select id, ChargentOrders__Credit_Card_Number__c, ChargentOrders__Tokenization__c  from ChargentOrders__Transaction__c ');
     }
    
    
    global void execute(Database.BatchableContext BC, List<ChargentOrders__Transaction__c> scope){
       
        for(ChargentOrders__Transaction__c objOpp : scope){
            objOpp.ChargentOrders__Credit_Card_Number__c = '';
        }
        update scope;
    }
        

    global void finish(Database.BatchableContext BC){}

}