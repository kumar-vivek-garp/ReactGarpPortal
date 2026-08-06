global class BatchSyncSiteToSage implements database.batchable<sobject>,Database.AllowsCallouts{
    
    private string recordId;
    private List<String> sageFieldsList;
    public BatchSyncSiteToSage(string inputRecordId){
         sageFieldsList = new List<String>();
        recordId = inputRecordId;
    }
    
    public BatchSyncSiteToSage(string inputRecordId,List<String> fieldList){
        sageFieldsList = new List<String>();
        sageFieldsList = fieldList;
        recordId = inputRecordId;
    }
    
    public BatchSyncSiteToSage(){ 
         sageFieldsList = new List<String>();
    }
    
    global database.querylocator start(Database.BatchableContext BC){
        string query;
        string syncStatus = 'Ready To Sync';
        integer batchSize = (Integer)Failed_Exams_Setup__mdt.getInstance('SiteUpdate').Sync_Batch_Size__c;
        query = 'Select Id,Site_Sync_Status__c,OpportunityId,Site_Code__c,Product_ID__c,TotalPrice,UnitPrice,Sage_Shipping_Country__c,Sage_Shipping_State__c,Sage_Reporting_Country__c,Tax_Region__c,';
        query += 'Sage_Reporting_State__c,Tax_Authority__c,ia_crm__Intacct_Location__c,ia_crm__Intacct_Location__r.ia_crm__Intacct_Entity_ID__c,';
        query += 'ia_crm__Department__c,ia_crm__Department__r.ia_crm__Department_ID__c,Quantity,ia_crm__Class__c,ia_crm__Class__r.ia_crm__Class_ID__c,';
        query += 'Intacct_Template__c,Intacct_Template__r.Name,ia_crm__Project__c,ia_crm__Project__r.ia_crm__Project_ID__c,Vendor_ID__c,ServiceDate,ia_crm__Service_End_Date__c from OpportunityLineItem where Site_Sync_Status__c =: syncStatus';
        if(recordId != null){
            query += ' and Id =:recordId';
        }
		query += ' Limit :batchSize';
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope){
        List<OpportunityLineItem> linesToUpdate = new List<OpportunityLineItem>();
        Map<String,List<OpportunityLineItem>> relatedOppIdOLIMap = new Map<String,List<OpportunityLineItem>>();
        string response;
        for(OpportunityLineItem oli : scope){
            if(relatedOppIdOLIMap.containsKey(oli.OpportunityId)){
                List<OpportunityLineItem> oliList = relatedOppIdOLIMap.get(oli.OpportunityId);
                oliList.add(oli);
                relatedOppIdOLIMap.put(oli.OpportunityId,oliList);
            }else{
                relatedOppIdOLIMap.put(oli.OpportunityId,new List<OpportunityLineItem>{oli});
            }
        }
        
        if(relatedOppIdOLIMap.KeySet().size() > 0){ 
            if(sageFieldsList.size() >0){
                response = SageApiWebService.updateOppFieldsLineItems(relatedOppIdOLIMap,sageFieldsList);
            }else{
                response = SageApiWebService.updateOppLineItems(relatedOppIdOLIMap);
            }
            if(test.isRunningtest()){
                response = '<?xml version="1.0" encoding="UTF-8"?><response><operation><result><status>success</status> <controlid>testControlId</controlid><data listtype="revrecschedule" count="1" totalcount="1" numremaining="0" resultId=""><revrecschedule><RECORDNO>40</RECORDNO><SOREVRECSTARTDATE>1/1/2022</SOREVRECSTARTDATE></revrecschedule><api><sessionid>test</sessionid></api></data></result></operation><operation><result><status>failure</status> <controlid>testControlId2</controlid></result></operation></response>';
			}
            
            DOM.XMLNode responseNode;
            
            String IsResultStatusSuccess;
            Boolean IsResultDataAvailable;
            
            DOM.Document doc = new DOM.Document();
            doc.load(response);
            system.debug(response);
            //Retrieve the root element for this document.
            responseNode = doc.getRootElement();
            System.debug('responseNode == '+responseNode);
            
            for(DOM.XMLNode Node : responseNode.getChildElements()){
                if(Node.getName() == 'operation'){
                    DOM.XMLNode childNode = Node.getChildElement('result',null);
                    string status = childNode.getChildElement('status',null).gettext();
                    if(status == 'success'){
                        string oppId = childNode.getChildElement('controlid',null).gettext();
                        if(relatedOppIdOLIMap.containskey(oppId)){
                            for(OpportunityLineItem oli : relatedOppIdOLIMap.get(oppId)){
                                oli.Site_Sync_Status__c = 'Synced';
                                linesToUpdate.add(oli);
                            }
                        }
                    }else if(status == 'failure'){
                        string oppId = childNode.getChildElement('controlid',null).gettext();
                        if(relatedOppIdOLIMap.containskey(oppId)){
                            for(OpportunityLineItem oli : relatedOppIdOLIMap.get(oppId)){
                                oli.Site_Sync_Status__c = 'Failed';
                                linesToUpdate.add(oli);
                            }
                        }
                    }
                }
            }
            
            //Is Status Success
            /*IsResultStatusSuccess = responseNode.getChildElement('operation',null).getChildElement('result',null).getChildElement('status',null).getText();
            System.debug('IsResultStatusSuccess ='+IsResultStatusSuccess);
            
            if(IsResultStatusSuccess == 'success'){
                for(OpportunityLineItem oli : scope){
                    oli.Site_Sync_Status__c = 'Synced';
                }
            }else{
                for(OpportunityLineItem oli : scope){
                    oli.Site_Sync_Status__c = 'Failed';
                }
            }*/
        }
        if(!linesToUpdate.isEmpty())
        	update linesToUpdate;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}