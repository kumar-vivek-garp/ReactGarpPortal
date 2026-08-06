public with sharing class RiskDotNetMemberShip {
    public static Boolean RiskRecursive = true;
    static id RiskNetId = RecordTypeHelper.GetRecordTypeId('Contract', 'Risk.Net');
    static set<Id> riskDotNetContractIds = new set<Id>();
    public static void CallRiskDotNet(List<Contract> newContracts, Map<Id, Contract> oldContracts) {
        RiskRecursive = false;
        for(Contract con: newContracts) {
            Contract beforeUpdate = oldContracts.get(con.Id);
            if( (beforeUpdate.ContractTerm != con.ContractTerm
                || beforeUpdate.Pearson_Member_Last_Name__c != con.Pearson_Member_Last_Name__c 
                || beforeUpdate.Pearson_Member_First_Name__c != con.Pearson_Member_First_Name__c
                || beforeUpdate.Pearson_Phone_No__c != con.Pearson_Phone_No__c
                || beforeUpdate.Member_Email__c != con.Member_Email__c 
                || beforeUpdate.Status != con.Status) 
                && con.RecordTypeId == RiskNetId  
                && con.API_Transaction_Status__c == null
            ){ 
                /* if(con.Status == 'Activated') {
                    // RiskDotNetUtilityClass.CreateUser(con.Id,con.CustomerSignedId,'active');
                    RiskDotNetQueueable RiskQueue = new RiskDotNetQueueable(con.Id,con.CustomerSignedId,'active');
                    
                   // OpportunityTriggerHelper_New.getIntgEvents(recordIds, objName, methodName);
                    ID jobID = System.enqueueJob(RiskQueue); 
                } 
                if(con.Status == 'Canceled' || con.Status == 'Expired') {
                    // RiskDotNetUtilityClass.CreateUser(con.Id,con.CustomerSignedId,'Inactive');
                    RiskDotNetQueueable RiskQueue = new RiskDotNetQueueable(con.Id,con.CustomerSignedId,'Inactive');
                    ID jobID = System.enqueueJob(RiskQueue); 
                } */
                if(con.Status == 'Activated' || con.Status == 'Canceled' || con.Status == 'Expired') { 
                    riskDotNetContractIds.add(con.Id);
                }
            }
            
            if(!riskDotNetContractIds.isEmpty()) {
                TriggerUtilities.getIntgEvents(riskDotNetContractIds, 'Contract', 'RiskDotNet');
            }
        }
    }
    
}