public class ContactUpdateEvtTriggerHandler {
	public static void updateContacts(List<Contact_Update_Event__e> newEvents){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<Integration_Log__c> logList = new List<Integration_Log__c>();
        Integer counter = 0;
        
        for(Contact_Update_Event__e evt : newEvents){
            counter++;
            System.debug('Counter = '+ counter);    
            if (counter >  200) {
                break;
            }
            if(evt.Update_type__c == 'Exam_Attempt__c'){
                contactIds.add(evt.Record_Id__c);
            }else if(evt.Update_type__c == 'Contract'){
                accountIds.add(evt.Record_Id__c);
            }
            //Integration_Log__c log = createLogRecord(evt,'Success');
            //logList.add(log);
            if(!Test.isRunningTest())
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(evt.ReplayId);
        }
        
        if(!contactIds.isEmpty()){
            AsynContactUpdate.updateContactFromExamAttempt(contactIds);
        }
        
        if(!accountIds.isEmpty()){
            AsynContactUpdate.updateContactFromContract(accountIds);
        }
        
        /*if(!logList.isEmpty())
            insert logList;*/
    }
    
    /*public static Integration_Log__c createLogRecord(Contact_Update_Event__e evt,string status){
        Integration_Log__c log = new Integration_Log__c();
        log.Integration_Type__c = 'Contact Update';
        log.Event_Replay_Id__c = evt.ReplayId;
        log.New_Record__c = evt.New_Record__c;
        log.Old_Record__c = evt.Old_Record__c;
        log.Platform_Event_Type__c = 'Contact Update Event';
        log.Status__c = status;
        if(evt.Update_type__c == 'Exam_Attempt__c'){
            log.Exam_Registration__c = evt.Exam_Reg_Contract_Id__c;
        }else if(evt.Update_type__c == 'Contract'){
            log.Program__c = evt.Exam_Reg_Contract_Id__c;
        }
        
        return log;
    }*/
}