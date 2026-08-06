global class UpdateFormDataBulkLoad implements Database.Batchable<sObject> {
    
    public String recordId;  
    
    global UpdateFormDataBulkLoad (String recordId){
        this.recordId = recordId;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        if(recordId != null){
            return DataBase.getQueryLocator([SELECT Id, Bulk_Load__c FROM Form_Data__c WHERE Bulk_Load__c = true AND Id = :recordId]);
        }
        
        return DataBase.getQueryLocator([SELECT Id, Bulk_Load__c FROM Form_Data__c WHERE Bulk_Load__c = true]);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Form_Data__c> scope) {
        
        for (Form_Data__c formData: scope){
            formData.Bulk_Load__c = false;
            formData.Status__c = 'Completed';
        }
        
        UPDATE scope;
        
    }
    
    global void finish(Database.BatchableContext BC) {}
    
}