global class BatchSyncSiteToCreateSage implements database.batchable<sobject>,Database.AllowsCallouts{
private List<string> recordIds;
    private List<String> sageFieldsList;
    public BatchSyncSiteToCreateSage(List<string> oliIds){ 
        this.recordIds = oliIds;
    }
    
    public BatchSyncSiteToCreateSage(){  
    }
      
    global database.querylocator start(Database.BatchableContext BC){
        string query;
        string syncStatus = 'Create to Sync'; 
        query = 'Select Id,Site_Sync_Status__c,Opportunity.Display_Invoice_Number__c,Opportunity.ia_crm__Intacct_Transaction__c,OpportunityId,Site_Code__c,Site_Code__r.ia_crm__Intacct_Id__c,Product_ID__c,TotalPrice,UnitPrice,Sage_Shipping_Country__c,Sage_Shipping_State__c,Sage_Reporting_Country__c,';
        query += 'Sage_Reporting_State__c,Tax_Authority__c,ia_crm__Intacct_Location__c,ia_crm__Intacct_Location__r.ia_crm__Intacct_Entity_ID__c,';
        query += 'ia_crm__Department__c,ia_crm__Department__r.ia_crm__Department_ID__c,Quantity,ia_crm__Class__c,ia_crm__Class__r.ia_crm__Class_ID__c,';
        query += 'Intacct_Template__c,Intacct_Template__r.Name,ia_crm__Project__c,ia_crm__Project__r.ia_crm__Project_ID__c,Vendor_ID__c,ServiceDate,ia_crm__Service_End_Date__c from OpportunityLineItem where Site_Sync_Status__c =: syncStatus';
        if(recordIds != null){
            query += ' and Id In:recordIds';
        } 
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope){
        Map<Id,OpportunityLineItem> linesToUpdateMap = new  Map<Id,OpportunityLineItem>();
        Map<String,List<OpportunityLineItem>> relatedOppIdOLIMap = new Map<String,List<OpportunityLineItem>>();
        Map<String,String> oppMap = new Map<String,String>();
        Map<string,String> responseMap = new Map<string,String>();
        for(OpportunityLineItem oli : scope){
            String response = SageApiWebService.createOppFieldsLineItem(oli);
            if(response != 'Exception' && response != 'Auth Error')
            responseMap.put(oli.Id,response);
            oppMap.put(oli.Id,oli.OpportunityId);
        }
        
        for(String oliId:responseMap.keySet()){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.Id = oliId;
            String response = responseMap.get(oliId);
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
                        if(oppMap.get(oliId) == oppId){ 
                            oli.Site_Sync_Status__c = 'Synced';
                            linesToUpdateMap.put(oliId,oli); 
                        }
                    }else if(status == 'failure'){
                        string oppId = childNode.getChildElement('controlid',null).gettext();
                        if(oppMap.get(oliId) == oppId){ 
                            oli.Site_Sync_Status__c = 'Failed';
                            linesToUpdateMap.put(oliId,oli); 
                        }
                    }
                }
            }
        }
        
        
        if(!linesToUpdateMap.isEmpty())
        	database.update(linesToUpdateMap.values(),false);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}