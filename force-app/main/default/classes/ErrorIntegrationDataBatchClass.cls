global class ErrorIntegrationDataBatchClass implements Database.Batchable<sObject>, Database.Stateful {
    global String csvColumnHeader;
    global List<String> csvRowValues = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = '';
        DATE today = system.today();
        if(test.isRunningTest()){
            query = 'SELECT Id,Name,Call_out_Status__c,RecordTypeId,Call_out_Type__c, Garp_Id__c ,Integration_Type__c,Outbound_Event_Types__c,Contract__c,Exam_Registrations__c FROM Integration_Data__c LIMIT 1';
        } else {
            query = 'SELECT Id,Name,Call_out_Status__c,RecordTypeId,Call_out_Type__c, Integration_Type__c,Outbound_Event_Types__c,Contract__c,Exam_Registrations__c,Garp_Id__c FROM Integration_Data__c where Createddate= yesterday Order By Createddate DESC';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Integration_Data__c> scope)
    {
        Map<String,Integration_Data__c> ATAErrorMap = new Map<String,Integration_Data__c>();
        Map<String,Integration_Data__c> PSIErrorMap = new Map<String,Integration_Data__c>();
        Id ATARecordTypeId = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('ATA').getRecordTypeId();
        Id PSIRecordTypeId = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('PSI').getRecordTypeId(); 
        String IntegrationType = '';
        String RecordID = '';
        string CalloutType ='';
        String ExamRegistration = '';
        string GarpId ='';
        for(Integration_Data__c intdata:scope){ 
            if((intdata.RecordTypeId == ATARecordTypeId || intdata.RecordTypeId ==  PSIRecordTypeId) && intdata.Exam_Registrations__c != null){
                String ATAKey = intdata.Exam_Registrations__c +''+intdata.Call_out_Type__c +''+intdata.Outbound_Event_Types__c +''+ intdata.Integration_Type__c+''+intdata.Call_out_Status__c;
                system.debug(ATAKey);
                if(!ATAErrorMap.containsKey(ATAKey) && intdata.Call_out_Status__c == 'Error'){
                    RecordID = intdata.Id; 
                    IntegrationType = intdata.Integration_Type__c != null ? intdata.Integration_Type__c : '';
                    CalloutType =intdata.Call_out_Type__c != null ? intdata.Call_out_Type__c : '';
                    GarpId =intdata.Garp_Id__c != null ? intdata.Garp_Id__c : '';
                    ExamRegistration =intdata.Exam_Registrations__c != null ? intdata.Exam_Registrations__c : '';
                    String rowStr = RecordID +','+IntegrationType+','+ExamRegistration+','+CalloutType+','+GarpId+','+ExamRegistration;  
                    csvRowValues.add(rowStr);
                }
                ATAErrorMap.put(ATAKey,intdata);
            }
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        if(!csvRowValues.isEmpty()){
            csvColumnHeader = 'RecordID,IntegrationType,ExamRegistration,CalloutType,GarpId, \n';
            String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
            system.debug(csvFile);  
            
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(csvFile);
            string csvname= 'ErrorIntegrationData.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String receipientList = system.label.Exception_Recipient_List;
            List<String> toAddresses = new list<string>();
            toAddresses.addall(receipientList.split(','));
            String subject ='Error Integration Data CSV';
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('Error Integration Data CSV ');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            if(!test.isRunningTest()){
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }
    }
    
}