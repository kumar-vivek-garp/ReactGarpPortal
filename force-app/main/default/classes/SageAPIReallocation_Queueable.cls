public class SageAPIReallocation_Queueable implements System.Queueable, Database.AllowsCallouts{
    
    Public Set<Id> oppIds = new Set<Id>();
    Public SageAPIReallocation_Queueable(Set<Id> OppIdSet){
        this.oppIds = OppIdSet;
    }
    
    public void execute(System.QueueableContext context) {
        Map<Id,Opportunity> origOpps = new Map<Id,Opportunity>();
        List<Opportunity> oppslist = [Select Id,Display_Invoice_Number__c,Refund_Opportunity__c,CloseDate from Opportunity where Id IN: oppIds];
        for(Opportunity opp :oppslist) { 
            if(opp.Refund_Opportunity__c != null){
                origOpps.put(opp.Refund_Opportunity__c,opp);
            }
        }
        
        List<Opportunity> originalOpps = [Select Id,Display_Invoice_Number__c,
                                          (SELECT Id,Opportunity__c,Take_Membership__c FROM Product_Refunds__r where Take_Membership__c = true)  
                                          from Opportunity where Id in: origOpps.keyset()];
        
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        
        for(Opportunity opp :originalOpps) {
            if(opp.Product_Refunds__r.size() > 0){
                Map<String,String> resultMap = SageApiWebService.reallocation(opp.Display_Invoice_Number__c,origOpps.get(opp.Id).CloseDate);
                Boolean isChanged = FALSE;
                if(resultMap.containsKey('Authentication')){
                    isChanged = TRUE;
                    opp.Sage_Reallocation_Sync_Status__c = 'Authentication Failed';
                }
                if(resultMap.containsKey('revrecscheduleNotFound')){
                    isChanged = TRUE;
                    opp.Sage_Reallocation_Sync_Status__c = 'Schedule Not Found';
                }
                if(resultMap.containsKey('callOutFailed')){
                    isChanged = TRUE;
                    opp.Sage_Reallocation_Sync_Status__c = 'Reallocation Failed';
                    if(resultMap.containsKey('ErrMsg')){
                        opp.Sage_Reallocation_API_Message__c = resultMap.get('ErrMsg');
                    }
                }
                if(resultMap.containsKey('callOutPassed')){
                    isChanged = TRUE;
                    opp.Sage_Reallocation_Sync_Status__c = 'Success';
                }
                if(isChanged){
                    oppToUpdate.add(opp);
                }
            }
        }
        if(!oppToUpdate.isEmpty()){
            update oppToUpdate;
        }
    }
}