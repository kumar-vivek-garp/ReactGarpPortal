@RestResource(urlMapping='/ShipEdge')
global without sharing class ShipEdgeUpdateOppWebService {
    
    @HttpPost
    global static void doPatch() {
        String studyMaterialRT = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Study_Materials');
        List<Integration_Log__c> logList = new List<Integration_Log__c>();
        String returnValue = 'Success';
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        
        String jsonBody = '';
        if(!Test.isRunningTest() && request != null && request.requestBody != null){ jsonBody = request.requestBody.toString(); }
        else{
            if(Test.isRunningTest()){
                jsonBody = webHookRequestWrapper.testParse();
            }
        }
        
        try{
            webHookRequestWrapper reqWrapper = webHookRequestWrapper.parse(jsonBody);
            system.debug('reqWrapper::>>   '+reqWrapper);
            if(reqWrapper != null && reqWrapper.order != null && reqWrapper.order.Id != null){
                system.debug('reqWrapper  id::>>   '+reqWrapper.order.id);
                List<Opportunity> oppList = new List<Opportunity>();
                List<Opportunity> oppToUpdate = new List<Opportunity>();
                Set<Id> b2bDealItem = new Set<Id>();
                List<B2B_Deal_Item__c> b2bDIList = new List<B2B_Deal_Item__c>();
                
                oppList = [SELECT Id,Ship_Edge_Order_Id__c,Tracking_Number__c,Bulk_Orders__c,B2B_Deal_Item__c FROM Opportunity WHERE Ship_Edge_Order_Id__c =: reqWrapper.order.Id];
                for(Opportunity opp : oppList){
                    opp.Tracking_Number__c = reqWrapper.order.tracking_number;
                    opp.Ups_Stage__c = 'Completed';
                    oppToUpdate.add(opp);
                    logList.add(ShipEdgeAPIClass.createLogRecord(opp.Id,jsonBody,returnValue,returnValue,'ShipEdgeUpdateOppWebService'));
                    if(opp.B2B_Deal_Item__c != null){
                        b2bDealItem.add(opp.B2B_Deal_Item__c);
                    }
                }
                
                update oppToUpdate;
                
                
                for(B2B_Deal_Item__c bo : [Select Id,Tracking_Number__c,Shipping_Status__c from B2B_Deal_Item__c 
                                           WHERE Id IN: b2bDealItem AND RecordTypeId =: studyMaterialRT]){
                                               bo.Tracking_Number__c = reqWrapper.order.tracking_number;
                                               bo.Shipping_Status__c = 'Shipped';
                                               b2bDIList.add(bo);
                                           }
                
                if(!b2bDIList.isEmpty()){
                    update b2bDIList;
                }
            }
            res.responseBody = Blob.valueOf('Success'); 
            res.statusCode = 200; 
        }catch(Exception ex){ 
            res.responseBody = Blob.valueOf('Error'); 
            res.statusCode = 500;
        }
        
        if(logList.size() > 0){
            insert logList;
        }
    }
}