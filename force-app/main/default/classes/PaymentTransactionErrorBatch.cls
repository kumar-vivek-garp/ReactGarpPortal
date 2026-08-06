global class PaymentTransactionErrorBatch implements Database.Batchable<sObject>, Database.Stateful {
    global String csvColumnHeader;
    global List<String> csvRowValues = new List<String>();
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        DATE today = system.today();
        if(test.isRunningTest()){
            query = 'SELECT Id,Amount__c,Authorization__c,Opportunity_ID__c,Chargent_Token__c,Gateway_Date__c,Gateway_ID__c,Response_Status__c FROM eComm_Transaction__c LIMIT 1';
        } else {
            query = 'SELECT Id,Amount__c,Authorization__c,Opportunity_ID__c,Chargent_Token__c,Gateway_Date__c,Gateway_ID__c,Response_Status__c FROM eComm_Transaction__c where Createddate= yesterday Order By Createddate DESC';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<eComm_Transaction__c> scope){
        String OpportunityId = '';
        String OpportunityName = '';
        string GarpId ='';
        string DisplayInvoiceNumber ='';
        string ChargentToken ='';
        string GatewayID ='';
        string ChargentAuthorization ='';
        DateTime GatewayDate = null;
        string Authorization ='';
        string ResponseStatus ='';
        Map<String,String> oppIdToTokenMap = new Map<String,String>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<String,Opportunity> oppMap = new Map<String,Opportunity>();
        Map<String,ChargentOrders__Transaction__c> ChargentTransactionMap = new Map<String,ChargentOrders__Transaction__c>();
        for(eComm_Transaction__c ecomm : scope){
            if(String.isNotBlank(ecomm.Opportunity_ID__c))
                oppIdToTokenMap.put(ecomm.Opportunity_ID__c,ecomm.Opportunity_ID__c+ecomm.Chargent_Token__c);
        }
        
        oppList = [Select Id,Amount,Name,Display_Invoice_Number__c,GARP_Member_ID__c, 
                       (Select Id,ChargentOrders__Type__c,ChargentOrders__Response__c,ChargentOrders__Response_Status__c,
                    ChargentOrders__Response_Message__c,ChargentOrders__Amount__c,ChargentOrders__Gateway_ID__c,
                    ChargentOrders__Tokenization__c from Transactions__r Where ChargentOrders__Type__c = 'Charge'
                    AND (ChargentOrders__Response__c = '0' OR ChargentOrders__Response__c = 'OK') AND ChargentOrders__Response_Status__c = 'Approved' 
                    Order By CreatedDate ASC) 
                   from Opportunity where Id IN:oppIdToTokenMap.keyset()];
        
        for(Opportunity opp : oppList){
 			oppMap.put(opp.id, opp);
            for(ChargentOrders__Transaction__c sfa : opp.Transactions__r){
                ChargentTransactionMap.put(opp.Id+sfa.ChargentOrders__Tokenization__c, sfa);
            }
        }
        
        for(eComm_Transaction__c tran:scope){
            String key = tran.Opportunity_Id__c+tran.Chargent_Token__c;
            if(oppMap.containskey(tran.Opportunity_Id__c)){
                if(!ChargentTransactionMap.containskey(key)){
                    OpportunityId = tran.Opportunity_Id__c; 
                    OpportunityName = oppMap.get(tran.Opportunity_Id__c).Name;
                    GarpId = oppMap.get(tran.Opportunity_Id__c).GARP_Member_ID__c;
                    DisplayInvoiceNumber = oppMap.get(tran.Opportunity_Id__c).Display_Invoice_Number__c;
                    ChargentToken = tran.Chargent_Token__c;
                    GatewayID = tran.Gateway_ID__c;
                    Authorization = tran.Authorization__c;
                    GatewayDate = tran.Gateway_Date__c;
                    ResponseStatus = tran.Response_Status__c;
                    String rowStr = OpportunityId +','+OpportunityName+','+GarpId+','+DisplayInvoiceNumber+','+ChargentToken+','+GatewayID+','+Authorization+','+GatewayDate+','+ResponseStatus;
                    csvRowValues.add(rowStr);
            	}
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        if(!csvRowValues.isEmpty()){
            csvColumnHeader = 'OpportunityId,OpportunityName,GarpId,DisplayInvoiceNumber,ChargentToken,GatewayID,Authorization,GatewayDate,ResponseStatus \n';
            String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
            system.debug(csvFile);  
            
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(csvFile);
            string csvname= 'PaymentTransactionErrors.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String receipientList = system.label.Exception_Recipient_List;
            List<String> toAddresses = new list<string>();
            toAddresses.addall(receipientList.split(','));
            String subject ='Payment Transaction Errors CSV '+system.today();
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('Payment Transaction Errors CSV');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            if(!test.isRunningTest()){
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }
    }
}