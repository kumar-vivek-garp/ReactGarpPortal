public class ATAExamStatusTriggerHandler {

    public static void processIntegrations(List<ATA_Exam_Status__e> newEvents){
        //system.debug('in processIntegrations newEvents::>>   '+newEvents);
        
        Id ATARecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Integration_Data__c','ATA');
        List<Integration_Data__c> activeintegrationdataList = new List<Integration_Data__c>();
        set<Id> ATAintegrationId = new set<Id>();
        Integer recordCount = 0;
        
        
        List<String> batchNoList = new List<String>();
        List<Integration_Data__c> intDataList = new List<Integration_Data__c>();
        List<String> subjectCodeList = new List<String>();
        List<String> certIdList = new List<String>();
        List<String> examRedIdList = new List<String>();
        Map<String,ATA_Exam_Status__e> certIdEvtMap = new Map<String,ATA_Exam_Status__e>();
        Map<String,Integration_Data__c> certIdIntDataMap = new Map<String,Integration_Data__c>();
        
        for(ATA_Exam_Status__e evt : newEvents) {
            
            batchNoList.add(evt.batch_no__c);
            subjectCodeList.add(evt.subject_code__c);
            certIdList.add(evt.cert_id__c);
            certIdEvtMap.put(evt.cert_id__c,evt);
        }
        
        Map<id,Integration_Data__c> intDatamap = new Map<id,Integration_Data__c>([Select Id,Exam_Registrations__r.Cancelled__c from Integration_Data__c  where Garp_Id__c IN: certIdList 
                                                                                  and ATA_Outbound_Batch_Code__c IN:batchNoList and ATA_subject_code__c IN:subjectCodeList 
                                                                                  and Is_Active__c =true and RecordTypeId =:ATARecordTypeId and Exam_Registrations__r.Cancelled__c = false]);
        //system.debug('in processIntegrations intDatamap::>>   '+intDatamap);
        if(!intDatamap.keySet().isEmpty()){
            activeintegrationdataList = ATAPSIUtilClass.cloneActiveIntegrationData(intDatamap.keySet()); 
        }
        //system.debug('in processIntegrations activeintegrationdataList::>>   '+activeintegrationdataList);
        for(Integration_Data__c intData : activeintegrationdataList){
            certIdIntDataMap.put(intData.Garp_Id__c , intData);
            examRedIdList.add(intdata.Exam_Registrations__c);
        }
        
        Map<Id,Decimal> integrationdatavertionMap = getLatestVersionIntegritaion(examRedIdList);
        //system.debug('in processIntegrations integrationdatavertionMap::>>   '+integrationdatavertionMap);
        
        
        
        for(ATA_Exam_Status__e evt : newEvents) {
            Integration_Data__c intdata = new Integration_Data__c(); 
            recordCount++;
            //System.debug('recordCount::>> '+ recordCount);    
            if (recordCount >=  200) {
                break;
            }
            else{
                
                intdata = certIdIntDataMap.get(evt.cert_id__c);
                
                //Map<Id,Decimal> integrationdatavertionMap = ATAPSIUtilClass.getLatestVersionIntegritaion(intdata.Exam_Registrations__c);
                if(integrationdatavertionMap.keySet() != NULL && integrationdatavertionMap.containsKey(intdata.Exam_Registrations__c)){
                    intdata.Version_Number__c = integrationdatavertionMap.get(intdata.Exam_Registrations__c)+1;
                }
                
                intdata.Name = 'ATA Notify Registration ' + intdata.Version_Number__c;
                intdata.ATA_Exam_Delivered_Status__c = evt.exam_status__c;  
                
                intDataList.add(intdata);
                //System.debug('Position::>>  '+EventBusSubscriber.Position);
                
            }
            //platform event bus
            if(!Test.isRunningTest()){
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(evt.ReplayId);           
            }
        }
        //system.debug('intDataList ::>>   '+intDataList);
        if(!intDataList.isEmpty()){
            insert intDataList;
        }
    }
    
    
    
    public static Map<Id,Decimal> getLatestVersionIntegritaion(List<String> examRegId){
        Map<Id,Decimal> checkDupicateDataMap = new Map<Id,Decimal>();              
        for(Integration_Data__c ps:[SELECT Id,Version_Number__c,Is_Active__c,Exam_Registrations__c FROM Integration_Data__c  WHERE Exam_Registrations__c IN: examRegId  Order By Version_Number__c Desc Limit 1]){  
            if(!checkDupicateDataMap.containsKey(ps.Exam_Registrations__c)){  
                checkDupicateDataMap.put(ps.Exam_Registrations__c,ps.Version_Number__c);
            }                                    
        }
        return checkDupicateDataMap;
    }
}