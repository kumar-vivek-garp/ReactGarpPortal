global class globalBenchprepAccessBatch implements Database.Batchable<sobject>,Database.stateful,Schedulable{
    private string recordId;
    Set<Id> errorsMap = new  Set<Id>();
    Set<String> errorsMessage = new  Set<String>();
    global globalBenchprepAccessBatch(String inputRecordId){
         this.recordId = inputRecordId;
    }
    global globalBenchprepAccessBatch(){}
    global database.querylocator start(Database.BatchableContext bc){
        String stagename = 'Closed';
        String query ='Select Id From Opportunity Where StageName=:stagename';  
        if(recordId != null){
            query += ' and Id =: recordId';
        }else{
            query += ' and CreatedDate=today';
        }
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc,List<Opportunity> scope){
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity opp:scope){
            oppIdSet.add(opp.Id); 
        }
        try { 
            provisionBenchPrep_Queueable.updateuserinformation(oppIdSet);
        }catch(Exception ex){
            errorsMap.addAll(oppIdSet);
            errorsMessage.add(ex.getMessage()+'\n\n'+ex.getStackTraceString()+'\n\n');
        }
    }
    global void finish(Database.BatchableContext bc){
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String receipientList = system.label.Exception_Recipient_List;
            List<String> toAddresses = new list<string>();
            toAddresses.addall(receipientList.split(','));
            mail.setToAddresses(toAddresses);
            mail.setSubject('Update Global Benchprep Access Batch Job Completed: ' + BC.getJobId());            
            if(errorsMap.size() > 0){
                mail.setPlainTextBody('Benchprep Access' + '\n\nErrors: \n\n' + JSON.serializePretty(this.errorsMap)+ '\n\nErrors Messasge: \n\n' +JSON.serializePretty(this.errorsMessage));
            }else{
                mail.setPlainTextBody('Benchprep Access Successes');
            }    
            if(!test.isRunningTest()){            
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }catch(Exception ex){}
    }
    
    global void execute(SchedulableContext sc) {
        globalBenchprepAccessBatch b = new globalBenchprepAccessBatch(); 
        database.executebatch(b,20);
    }
}