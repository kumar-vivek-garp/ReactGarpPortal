global class BatchUpdateSiteOppProd implements database.batchable<sobject>{
    
    private string recordId;
    public BatchUpdateSiteOppProd(string inputRecordId){
        recordId = inputRecordId;
    }
    
    public BatchUpdateSiteOppProd(){
        
    }
     
    global database.querylocator start(Database.BatchableContext BC){
        string query;
        
        if(Test.isrunningtest()){            
            query = 'Select Id,Member__r.AccountId,Section__c,Result__c,Opportunity__c,Integration_Data_Exam_Location_Country__c,Active_Integration_Data__r.Exam_Location_Country__c,Exam_Site__r.Name from Exam_Attempt__c where Result__c != null and cancelled__c != true';
        }
        
        else{    
        string examPartId = Failed_Exams_Setup__mdt.getInstance('SiteUpdate').Exam_Admin_For_Query__c;
        query = 'Select Id,Member__r.AccountId,Section__c,Result__c,Opportunity__c,Integration_Data_Exam_Location_Country__c,Active_Integration_Data__r.Exam_Location_Country__c,Exam_Site__r.Name from Exam_Attempt__c where Result__c != null and Exam_Part__c =: examPartId and cancelled__c != true';
       
        }
        
        if(recordId != null){
            query += ' and id =: recordId';
        }
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Exam_Attempt__c> scope){
        Map<Id,String> opportunityIdMap = new Map<Id,String>();
        Map<Id,String> accountIdToSiteMap = new Map<Id,String>();
        Map<String,String> IntacctUserDimensionMap = new Map<String,String>();
        Map<String,Country_Code__c> countryCodeMap = new Map<String,Country_Code__c>();
        Map<String,String> countryISOCodeMap = new Map<String,String>();
        Map<String,Site_Code_MDT__mdt> siteCodeMap = new map<String,Site_Code_MDT__mdt>();
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
        
        //Map for Site codes from Sage
        for(ia_crm__Intacct_User_Dimension__c ciud : [SELECT ID,Name FROM ia_crm__Intacct_User_Dimension__c LIMIT 10000]){
            IntacctUserDimensionMap.put(ciud.Name.substring(0,4), ciud.Id);
        }
        
        for(Country_Code__c cc : [SELECT ID,Country__c,ISOCode__c FROM Country_Code__c LIMIT 10000]){
            countryCodeMap.put(cc.ISOCode__c, cc);
        }
        
        //Map for Country name to site code
        for(Site_Code_MDT__mdt mdt : [Select DeveloperName,Label,code__c,ISO_Name__c from Site_Code_MDT__mdt]){
            siteCodeMap.put(mdt.Label, mdt);
            if(String.IsNotBlank(mdt.ISO_Name__c)){
                countryISOCodeMap.put(mdt.Label,mdt.ISO_Name__c);
            }
        }
        
        //Get Account id and Opp id
        for(Exam_Attempt__c ea : scope){
            String section = ea.Section__c;
            if(section == 'SCR' || section == 'RiskAI' || section == 'RAIJ'){
                if(ea.Result__c == 'No-Show' && siteCodeMap.containskey(ea.Exam_Site__r.Name)){
                    accountIdToSiteMap.put(ea.Member__r.AccountId,siteCodeMap.get(ea.Exam_Site__r.Name).Code__c);
                }else if(ea.Result__c != null && ea.Result__c != 'No-Show'){
                    if(string.isnotBlank(ea.Integration_Data_Exam_Location_Country__c) && countryCodeMap.containskey(ea.Integration_Data_Exam_Location_Country__c)){
                        string countryName = countryCodeMap.get(ea.Integration_Data_Exam_Location_Country__c).Country__c;
                        if(siteCodeMap.containskey(countryName)){
                            accountIdToSiteMap.put(ea.Member__r.AccountId,siteCodeMap.get(countryName).Code__c);
                        }
                    }
                }
            }else if(section == 'FRM Part 1' || section == 'FRM Part 2'){
                if((ea.Result__c == 'No-Show' || ea.Result__c == 'Not Graded') && siteCodeMap.containskey(ea.Exam_Site__r.Name)){
                    accountIdToSiteMap.put(ea.Member__r.AccountId,siteCodeMap.get(ea.Exam_Site__r.Name).Code__c);
                }else if(ea.Result__c != null && ea.Result__c != 'No-Show' && siteCodeMap.containskey(ea.Integration_Data_Exam_Location_Country__c)){
                    accountIdToSiteMap.put(ea.Member__r.AccountId,siteCodeMap.get(ea.Integration_Data_Exam_Location_Country__c).Code__c);
                }
            }
            opportunityIdMap.put(ea.Opportunity__c,ea.Section__c);
        }
        
        //system.debug(accountIdToSiteMap);
        
        List<Opportunity> oppsList = [Select Id,AccountId,(Select Id,ProductCode,Product_Id__c from OpportunityLineitems) from Opportunity where Id IN: opportunityIdMap.keyset()];
        
        //Build the correct Product ID to be updated
        Map<Id,String> accountIdToProductIdMap = new Map<Id,String>();
        Set<String> frm1Codes = new Set<String>{'FRM1E','FRM1S','FRM1TE'};
        Set<String> frm2Codes = new Set<String>{'FRM2E','FRM2S','FRM2TE'};
        Set<String> scrCodes = new Set<String>{'SCRME','SCRMS','SCRNME','SCRNMS','SCRCME','SCRCMS','SCR2A','SCRTME','SCRTMS','SCRTNME','SCRTNMS','SCRTCME','SCRTCMS','SCRTR'};
        Set<String> raiCodes = new Set<String>{'RAICME','RAICMS','RAIME','RAIMS','RAINME','RAINMS','RAITCME','RAITCMS','RAITME','RAITMS','RAITNME','RAITNMS','RAI2A','RAITR'}; //Chinnapa
        Set<String> raijCodes = new Set<String>{'RAIJCME','RAIJCMS','RAIJME','RAIJMS','RAIJNME','RAIJNMS','RAIJTCME','RAIJTCMS','RAIJTME','RAIJTMS','RAIJTNME','RAIJTNMS','RAIJ2A','RAIJTR'}; 
        for(Opportunity opp : oppsList){
            for(OpportunityLineitem oli : opp.OpportunityLineitems){
                if(opportunityIdMap.get(opp.Id) == 'FRM Part 1' && frm1Codes.contains(oli.ProductCode)){
                    accountIdToProductIdMap.put(opp.AccountId, oli.Product_Id__c);
                }else if(opportunityIdMap.get(opp.Id) == 'FRM Part 2' && frm2Codes.contains(oli.ProductCode)){
                    accountIdToProductIdMap.put(opp.AccountId, oli.Product_Id__c);
                }else if(opportunityIdMap.get(opp.Id) == 'SCR' && scrCodes.contains(oli.ProductCode)){
                    accountIdToProductIdMap.put(opp.AccountId, oli.Product_Id__c);
                }else if(opportunityIdMap.get(opp.Id) == 'RiskAI' && raiCodes.contains(oli.ProductCode)){
                    accountIdToProductIdMap.put(opp.AccountId, oli.Product_Id__c);
                }else if(opportunityIdMap.get(opp.Id) == 'RAIJ' && raijCodes.contains(oli.ProductCode)){
                    accountIdToProductIdMap.put(opp.AccountId, oli.Product_Id__c);
                }
            }
        }
        //system.debug(accountIdToProductIdMap);
        
        //Find all Opps for the Account
        List<Opportunity> opptyList = [Select Id,AccountId, (Select Id,Site_Code__c,Site_Sync_Status__c,OpportunityId,Opportunity.AccountId,ProductCode,Product_Id__c,UnitPrice
                                                   from OpportunityLineItems
                                                   where Product_Id__c IN: accountIdToProductIdMap.values()) 
                                       from Opportunity where AccountId IN: accountIdToProductIdMap.keyset() and ia_crm__Intacct_Sync_Status_1__c = 'OK' and StageName = 'Closed' 
                                       Order By CloseDate DESC];
        
        /*List<OpportunityLineItem> oliList = [Select Id,Site_Code__c,Site_Sync_Status__c,OpportunityId,Opportunity.AccountId,ProductCode,Product_Id__c
                                              from OpportunityLineItem
                                              where Site_Sync_Status__c = null and Opportunity.AccountId IN: accountIdToProductIdMap.keyset()
                                              and Product_Id__c IN: accountIdToProductIdMap.values() and Opportunity.ia_crm__Intacct_Sync_Status_1__c = 'OK' Order By Createddate DESC];*/
        //Update site code for latest Opp
        Map<Id,Id> accToUpdOppMap = new Map<Id,Id>();
        for(Opportunity opp : opptyList){
            if(!accToUpdOppMap.containskey(opp.AccountId)){
                for(OpportunityLineItem oli : opp.OpportunityLineItems){
                    if(accountIdToProductIdMap.containskey(oli.Opportunity.AccountId) && oli.Product_ID__c == accountIdToProductIdMap.get(oli.Opportunity.AccountId) && oli.UnitPrice > 0 ){
                        if(oli.Site_Sync_Status__c == null || (oli.Site_Sync_Status__c != null && oli.Site_Sync_Status__c != 'Synced')){
                            if(accountIdToSiteMap.containskey(oli.Opportunity.AccountId)){
                                if(IntacctUserDimensionMap.containskey(accountIdToSiteMap.get(oli.Opportunity.AccountId))){
                                    oli.Site_Code__c = IntacctUserDimensionMap.get(accountIdToSiteMap.get(oli.Opportunity.AccountId));
                                    oli.Site_Sync_Status__c = 'Ready To Sync';
                                }else{
                                    oli.Site_Sync_Status__c = 'Site Not Found';
                                }
                                oliToUpdate.add(oli);
                                accToUpdOppMap.put(opp.AccountId,opp.Id);
                            }else{
                                oli.Site_Sync_Status__c = 'Site Not Found';
                                oliToUpdate.add(oli);
                                accToUpdOppMap.put(opp.AccountId,opp.Id);
                            }
                        }else if(oli.Site_Sync_Status__c != null && oli.Site_Sync_Status__c == 'Synced'){
                            accToUpdOppMap.put(opp.AccountId,opp.Id);
                        }
                    }
                }
            }
        }
        
        if(!oliToUpdate.isEmpty())
            update oliToUpdate;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}