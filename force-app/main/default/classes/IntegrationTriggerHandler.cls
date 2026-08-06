public class IntegrationTriggerHandler {
    public static void processIntegrations(List<Integration_Stream_Event__e> newEvents){
        List<Integration_Log__c> logList = new List<Integration_Log__c>();
        Map<String,Set<Id>> methodToRecordIDSet = new map<String,Set<Id>>();
        Integer recordCount = 0;
        for(Integration_Stream_Event__e evt : newEvents) {
            recordCount++;
            System.debug('Counter = '+ recordCount);    
            if (recordCount >=  15) {
                break;
            }
            else{
                if(String.isNotBlank(evt.Integration_Type__c)){
                    if(methodToRecordIDSet.containskey(evt.Integration_Type__c)){
                        Set<Id> recordIdSet = methodToRecordIDSet.get(evt.Integration_Type__c);
                        recordIdSet.add(evt.Record_Id__c);
                        methodToRecordIDSet.put(evt.Integration_Type__c,recordIdSet);
                    }else{
                        methodToRecordIDSet.put(evt.Integration_Type__c,new Set<Id>{evt.Record_Id__c});
                    }
                    if(evt.Integration_Type__c != 'ShipEdgeAdd' && evt.Integration_Type__c != 'ShipEdgeCancel'){
                        Integration_Log__c log = createLogRecord(evt,'Success');
                        logList.add(log);
                    }
                }
            }
            //platform event bus
            if(!Test.isRunningTest())
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(evt.ReplayId);           
        }
        if(methodToRecordIDSet.containskey('ATA')){
            ATACallOutQueueable ataCallout = new ATACallOutQueueable(methodToRecordIDSet.get('ATA'));
            ID jobID = System.enqueueJob(ataCallout);
        }
        if(methodToRecordIDSet.containskey('PSI')){
            PSICallOutQueueable psiCallout = new PSICallOutQueueable(methodToRecordIDSet.get('PSI'));
            ID jobID = System.enqueueJob(psiCallout);
        }
        if(methodToRecordIDSet.containskey('RiskDotNet')){
            RiskDotNetQueueable riskDotNetContractCallout = new RiskDotNetQueueable(methodToRecordIDSet.get('RiskDotNet'));
            ID jobID = System.enqueueJob(riskDotNetContractCallout);
        }
        if(methodToRecordIDSet.containskey('PearsonVue')){
            PearsonVueCallOutQueueable pearsonSCRCallout = new PearsonVueCallOutQueueable(methodToRecordIDSet.get('PearsonVue'));
            ID jobID = System.enqueueJob(pearsonSCRCallout);
        }
        if(methodToRecordIDSet.containskey('provisionEvents')){
            provEventAndChptMtngs_Queueable evtMtngQueue = new provEventAndChptMtngs_Queueable('Events',methodToRecordIDSet.get('provisionEvents'));
            ID jobID = System.enqueueJob(evtMtngQueue);
        }
        if(methodToRecordIDSet.containskey('ChapterMeeting')){
            provEventAndChptMtngs_Queueable evtMtngQueue = new provEventAndChptMtngs_Queueable('ChapterMeetings',methodToRecordIDSet.get('ChapterMeeting'));
            ID jobID = System.enqueueJob(evtMtngQueue);
        }
        if(methodToRecordIDSet.containskey('FRM1EBook')){
            provisionEBooks_Queueable ebookQueue = new provisionEBooks_Queueable('FRM1',methodToRecordIDSet.get('FRM1EBook'),false,null);
            ID jobID = System.enqueueJob(ebookQueue);
        }
        if(methodToRecordIDSet.containskey('FRM2EBook')){
            provisionEBooks_Queueable ebookQueue = new provisionEBooks_Queueable('FRM2',methodToRecordIDSet.get('FRM2EBook'),false,null);
            ID jobID = System.enqueueJob(ebookQueue);
        }
        if(methodToRecordIDSet.containskey('SCREBook')){
            provisionEBooks_Queueable ebookQueue = new provisionEBooks_Queueable('SCR',methodToRecordIDSet.get('SCREBook'),false,null);
            ID jobID = System.enqueueJob(ebookQueue);
        }
        if(methodToRecordIDSet.containskey('ERP2EBook')){
            provisionEBooks_Queueable ebookQueue = new provisionEBooks_Queueable('ERP2',methodToRecordIDSet.get('ERP2EBook'),false,null);
            ID jobID = System.enqueueJob(ebookQueue);
        }
        if(methodToRecordIDSet.containskey('FRREBook')){
            provisionEBooks_Queueable ebookQueue = new provisionEBooks_Queueable('FRR',methodToRecordIDSet.get('FRREBook'),false,null);
            ID jobID = System.enqueueJob(ebookQueue);
        }
        if(methodToRecordIDSet.containskey('FRREBookANDYardStick')){
            WKT_Settings__mdt wkt = WKT_Settings__mdt.getInstance('ICBRR_Program');
            provisionEBooks_Queueable ebookQueue = new provisionEBooks_Queueable('FRR',methodToRecordIDSet.get('FRREBookANDYardStick'),true,Integer.valueOf(wkt.Value__c));
            ID jobID = System.enqueueJob(ebookQueue);
        }
        if(methodToRecordIDSet.containskey('FFREBook')){
            WKT_Settings__mdt wkt = WKT_Settings__mdt.getInstance('FBR_Program');
            provisionEBooks_Queueable ebookQueue = new provisionEBooks_Queueable('FFR',methodToRecordIDSet.get('FFREBook'),true,Integer.valueOf(wkt.Value__c));
            ID jobID = System.enqueueJob(ebookQueue);
        }
        
        if(methodToRecordIDSet.containskey('ShipEdgeAdd')){
            system.debug('Check here');
            ShipEdgeQueueableClass shipQueue = new ShipEdgeQueueableClass(methodToRecordIDSet.get('ShipEdgeAdd'),'AddOrder');
            ID jobID = System.enqueueJob(shipQueue);
        }
        
        if(methodToRecordIDSet.containskey('ShipEdgeCancel')){
            system.debug('Check here');
            ShipEdgeQueueableClass shipQueue = new ShipEdgeQueueableClass(methodToRecordIDSet.get('ShipEdgeCancel'),'CancelOrder');
            ID jobID = System.enqueueJob(shipQueue);
        }
        
        if(methodToRecordIDSet.containskey('SAGEREALLOCATION')){
            SageAPIReallocation_Queueable sageQueue = new SageAPIReallocation_Queueable(methodToRecordIDSet.get('SAGEREALLOCATION'));
            ID jobID = System.enqueueJob(sageQueue);
        }
        
        if(methodToRecordIDSet.containskey('SCRBenchPrep')){ //Using for SCR And RISKAI
            provisionBenchPrep_Queueable scrBenchPrepQueue = new provisionBenchPrep_Queueable(methodToRecordIDSet.get('SCRBenchPrep'));
            ID jobID = System.enqueueJob(scrBenchPrepQueue);
        }
         
        if(methodToRecordIDSet.containskey('FRMBenchPrep')){
            provisionBenchPrep_Queueable frmBenchPrepQueue = new provisionBenchPrep_Queueable(methodToRecordIDSet.get('FRMBenchPrep'));
            ID jobID = System.enqueueJob(frmBenchPrepQueue);
        }
        
        if(methodToRecordIDSet.containskey('FRMBenchPrepExam')){
            provisionBenchPrep_Queueable frmBenchPrepQueue = new provisionBenchPrep_Queueable(methodToRecordIDSet.get('FRMBenchPrepExam'));
            ID jobID = System.enqueueJob(frmBenchPrepQueue);
        }
        
        if(methodToRecordIDSet.containskey('SageOrderProcess')){
            List<ia_crm.SyncOpportunityTransactionAction.SyncOpportunityTransactionRequest> recordIds = 
                new List<ia_crm.SyncOpportunityTransactionAction.SyncOpportunityTransactionRequest>();
            for(Id oppId : methodToRecordIDSet.get('SageOrderProcess')){
                ia_crm.SyncOpportunityTransactionAction.SyncOpportunityTransactionRequest recordId = 
                    new ia_crm.SyncOpportunityTransactionAction.SyncOpportunityTransactionRequest();
                recordId.recordId = oppId;
                recordIds.add(recordId);
                system.debug(recordId);
            }
            ia_crm.SyncOpportunityTransactionAction.syncOpportunityTransaction(recordIds);
        }
        
        if(!logList.isEmpty())
            insert logList;
    }
    
    public static Integration_Log__c createLogRecord(Integration_Stream_Event__e evt,string Status){
        Integration_Log__c log = new Integration_Log__c();
        log.Integration_Type__c = evt.Integration_Type__c;
        log.Event_Replay_Id__c = evt.ReplayId;
        log.Status__c = Status;
        log.Platform_Event_Type__c = 'Integration Stream Event';
        if(evt.Object_Name__c == 'Opportunity'){
            log.Opportunity__c = evt.Record_Id__c;
        }else if(evt.Object_Name__c == 'Contract'){
            if(evt.Integration_Type__c == 'PearsonVue'){
                log.Integration_Data__c = evt.Record_Id__c;
            }else{
                log.Program__c = evt.Record_Id__c;
            }
        }else if(evt.Object_Name__c == 'Exam_Attempt__c'){
            log.Integration_Data__c = evt.Record_Id__c;
        }
        
        return log;
    }
}