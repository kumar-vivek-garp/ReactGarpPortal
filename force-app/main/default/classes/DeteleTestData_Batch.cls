global class DeteleTestData_Batch implements Database.Batchable<sObject>,Database.Stateful {
    global String csvColumnHeader;
    global List<String> successCsvRowValues = new List<String>();
    global List<String> failureCsvRowValues = new List<String>();
    global List<String> examRegUpdatedGarpIds = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query; 
        Set<String> IsTestOverride = new Set<String>{'Is Not Test'};
            if(test.isRunningTest()) {
                query = 'Select id,GARP_ID__c from Account where Is_Test_Override__c Not IN: IsTestOverride and Is_Test__c = true and GARP_ID__c = \'1711609\'' ;
            } else {
                query = 'Select id,GARP_ID__c from Account where Is_Test_Override__c Not IN: IsTestOverride and Is_Test__c = true and GARP_ID__c = \'1711604\'' ;
            } // AND CreatedDate = LAST_N_DAYS:7
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Account> Scope) { 
        for(Account a : Scope) {
            deleteTestData.objectWrapper obj = new deleteTestData.objectWrapper();
            // obj = deleteTestData.deleteTestData('1711609');
            obj = deleteTestData.deleteTestData(a.GARP_ID__c);
            system.debug('deleteTestDataWrapperClass=======>'+ obj);
            system.debug('Message=======>'+ obj.Message);
            system.debug('GARP_ID__c=====>'+a.GARP_ID__c);
            String rowStr = '';
            if(obj.Message  == 'sucess'){
                rowStr = a.GARP_ID__c + ',' + obj.Message;
                successCsvRowValues.add(rowStr);
            } else if (obj.Message  == 'Call back') {
                examRegUpdatedGarpIds.add(a.GARP_ID__c);
            } else {
                rowStr = a.GARP_ID__c + ',' + obj.Message;
                failureCsvRowValues.add(rowStr);
            }
        }
        
        system.debug('successCsvRowValues======>'+successCsvRowValues);
        system.debug('failureCsvRowValues======>'+failureCsvRowValues);
        
    }    
    
    global void finish(Database.BatchableContext BC) {
        
        csvColumnHeader = 'GarpId,Message, \n';
        String sCsvFile ;
        String fCsvFile ;
        blob sCsvBlob;
        blob fCsvBlob;
        string csvname;
        List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
        
        if(!successCsvRowValues.isEmpty()) { 
            
            sCsvFile = csvColumnHeader + String.join(successCsvRowValues,'\n');
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            sCsvBlob = Blob.valueOf(sCsvFile);
            csvname= 'SucessDataDelete.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(sCsvBlob);
            efaList.add(csvAttc);
        }
        if(!failureCsvRowValues.isEmpty()) {
            fCsvFile = csvColumnHeader + String.join(failureCsvRowValues,'\n');
            Messaging.EmailFileAttachment failurecsvAttc = new Messaging.EmailFileAttachment();
            fCsvBlob = Blob.valueOf(fCsvFile);
            csvname= 'FailureDataDelete.csv';
            failurecsvAttc.setFileName(csvname);
            failurecsvAttc.setBody(fCsvBlob);
            efaList.add(failurecsvAttc);
        }
        
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String receipientList = system.label.Exception_Recipient_List;
        List<String> toAddresses = new list<string>();
        toAddresses.add('revathi.thadepu@garp.com');
        String subject ='Data Delete CSV';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Data Delete CSV ');
        email.setFileAttachments(efaList);
        if(!test.isRunningTest()){
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
        if(examRegUpdatedGarpIds.size() > 0) {
            DeteleTestData_Batch btch = new DeteleTestData_Batch();
            Database.executeBatch(btch, 1);
        } 
        
        // table success and failed.garpid's and account and message  
        
    }
}