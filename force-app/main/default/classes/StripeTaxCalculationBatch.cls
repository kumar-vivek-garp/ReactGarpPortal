global class StripeTaxCalculationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            Select Id From Opportunity WHERE (StripeTaxMethod__c = 'Batch Tax Calculate' or StripeTaxMethod__c = 'Batch Tax Calculate Preview')
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) { 
         Set<String> oppId = new Set<String>();
        for(Opportunity op:scope){  
            oppId.add(op.Id);
        }
         StripeTaxCalUtil.StripeTaxCulate(oppId);
    }
    
    global void finish(Database.BatchableContext bc) { 
    }
    
}