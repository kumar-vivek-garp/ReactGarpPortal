global class SetDataSeedingExternalIdBatch implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts {

    public String sObjectType;
    public List<Database.SaveResult> errors = new List<Database.SaveResult>();

    public SetDataSeedingExternalIdBatch(String sObjectType){
        this.sObjectType = sObjectType;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){     
        return Database.getQueryLocator('SELECT Id, Data_Seeding_External_ID__c FROM ' + sObjectType + ' WHERE Data_Seeding_External_ID__c = null');
    }

    global void execute(Database.BatchableContext BC, List<sObject> records){

        Schema.SObjectType schemaSObjectType = Schema.getGlobalDescribe().get(sObjectType);

        List<sObject> toUpdate = new List<sObject>();
        for(sObject record: records){
            sObject obj = schemaSObjectType.newSObject();
            obj.put('Id', record.Id);
            obj.put('Data_Seeding_External_ID__c', record.Id);
            toUpdate.add(obj);
        }

        Database.SaveResult[] results = Database.update(toUpdate, false);

        for(Database.SaveResult sr: results){
            if(!sr.isSuccess()){
                errors.add(sr);
            }
        }
  
    }
        
    global void finish(Database.BatchableContext BC){

        try {

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String receipientList = system.label.Exception_Recipient_List;
            List<String> toAddresses = new list<string>();
            toAddresses.addall(receipientList.split(','));
            mail.setToAddresses(toAddresses);
            mail.setSubject('Set Data Seed External ID Batch Job Errors: ' + BC.getJobId());
            mail.setPlainTextBody('sObject: ' + this.sObjectType + '\n\nErrors: \n\n' + JSON.serializePretty(this.errors));
            if(!errors.isEmpty()){
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

    }

}