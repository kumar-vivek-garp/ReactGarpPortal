global class ResendPearsonVueRTIDataBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
     
    global ResendPearsonVueRTIDataBatch(){
        insertIntegration();
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Query all Integration_Data__c records.
        String query = 'SELECT Contract__c,Contract__r.ContractNumber,Id,Name,Re_Run__c,CreatedDate FROM Integration_Data__c where Re_Run__c = true ORDER BY Version_Number__c DESC';
        return Database.getQueryLocator(query);
    }
    
    global static void insertIntegration(){
        Set<Id> integrationId = new Set<Id>();
        Map<String,String> integrationMap = new Map<String,String>();
        List<Integration_Data__c> PearsonActiveCloneList = new List<Integration_Data__c>();
        for(Integration_Data__c Pearson : [SELECT Contract__c,Contract__r.ContractNumber,Id,Name,Re_Run__c,CreatedDate FROM Integration_Data__c where Call_out_Status__c ='Error' AND Re_Run__c = true ORDER BY Version_Number__c DESC]){
            integrationId.add(Pearson.ID);
            integrationMap.Put(Pearson.Contract__c,Pearson.Contract__r.ContractNumber);
            Pearson.Re_Run__c = false;
            PearsonActiveCloneList.add(Pearson);
        }
        
        List<Integration_Data__c>  PearsonActiveList= ScrContractTriggerHelper.cloneActiveRecord(integrationId);
        for(Integration_Data__c ps: PearsonActiveList){
            ps.Re_Run__c = true;
            if(ps.Version_Number__c != null)
                ps.Version_Number__c = ps.Version_Number__c+1;
            if(integrationMap.containsKey(ps.Contract__c))
            ps.Name = integrationMap.get(ps.Contract__c) +' - '+ ps.Version_Number__c;
            ps.Call_out_Status__c = 'Initial';
            PearsonActiveCloneList.add(ps);
        }
        if(PearsonActiveCloneList.size()>0){ 
           upsert PearsonActiveCloneList; 
        }
        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Set<Id> integrationId = new Set<Id>();
        for(Integration_Data__c Pearson : (List<Integration_Data__c>) scope){ 
            integrationId.add(Pearson.ID);
        }
        system.debug(scope);
        PearsonVueRTIDataHelper.PearsonVueDate(integrationId);
    }
    global void finish(Database.BatchableContext BC){
        
    }
}