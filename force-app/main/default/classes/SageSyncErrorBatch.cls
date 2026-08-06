global class SageSyncErrorBatch implements Database.Batchable<sObject>, Database.Stateful {
    global String csvColumnHeader;
    global List<String> csvRowValues = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = '';
        DATE today = system.today();
        if(test.isRunningTest()){
            query = 'SELECT Id,ia_crm__Intacct_Sync_Errors_1__c,Display_Invoice_Number__c,Payment_Method_New__c,GARP_Member_ID__c '+ 
                'FROM Opportunity LIMIT 2   ';
        } else {
            query = 'SELECT Id,ia_crm__Intacct_Sync_Errors_1__c,Display_Invoice_Number__c,Payment_Method_New__c,GARP_Member_ID__c '+ 
                'FROM Opportunity where Sage_Order_Approved__c = TRUE AND ia_crm__Intacct_Sync_Status_1__c = \'Error\'   ';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        
        String IntacctSyncErrors = '';
        String RecordID = '';
        string InvoiceNumber ='';
        String PaymentMethod = '';
        string MemberId ='';
        
        for(Opportunity oppData : scope){
            RecordID = oppData.Id; 
            IntacctSyncErrors = oppData.ia_crm__Intacct_Sync_Errors_1__c != null ? oppData.ia_crm__Intacct_Sync_Errors_1__c : '';
            InvoiceNumber =oppData.Display_Invoice_Number__c != null ? oppData.Display_Invoice_Number__c : '';
            MemberId =oppData.GARP_Member_ID__c != null ? oppData.GARP_Member_ID__c : '';
            PaymentMethod =oppData.Payment_Method_New__c != null ? oppData.Payment_Method_New__c : '';
            String rowStr = RecordID +','+InvoiceNumber+','+MemberId+','+PaymentMethod+','+IntacctSyncErrors;  
            csvRowValues.add(rowStr);
        }
    }
    global void finish(Database.BatchableContext BC){
        if(!csvRowValues.isEmpty()){
            csvColumnHeader = 'RecordID,InvoiceNumber,MemberId,PaymentMethod,IntacctSyncErrors, \n';
            String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
            system.debug('csvFile::>>    '+csvFile);  
            
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(csvFile);
            string csvname= 'SageSyncErrorData.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String receipientList = system.label.Exception_Recipient_List;
            List<String> toAddresses = new list<string>();
            toAddresses.addall(receipientList.split(','));
            String subject ='Sage Sync Error Data CSV';
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('Sage Sync Error Data CSV ');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            if(!test.isRunningTest()){
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }
    }
    
}