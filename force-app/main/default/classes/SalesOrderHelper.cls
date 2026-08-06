public class SalesOrderHelper {
    public static void UpdateOpportunity(Set<Id> oppIds){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Opportunity> oppList = [Select Id,ia_crm__Intacct_Sync_Status_1__c,ia_crm__Intacct_Transaction_ID__c,ia_crm__Intacct_Sync_Errors_1__c,
                                     ia_crm__Intacct_Transaction__c,Display_Invoice_Number__c
                                     from Opportunity where Id IN: oppIds];
        
        for(Opportunity opp : oppList){
            String transType = opp.ia_crm__Intacct_Transaction__c.substringafter('-').trim();
            if(opp.ia_crm__Intacct_Sync_Status_1__c != 'OK'){
                opp.ia_crm__Intacct_Sync_Status_1__c = 'OK';
                opp.ia_crm__Intacct_Sync_Errors_1__c = '';
                opp.ia_crm__Intacct_Transaction_ID__c = transType+'-'+opp.Display_Invoice_Number__c;
                oppsToUpdate.add(opp);
            }
        }
        
        if(!oppsToUpdate.isEmpty()){
            update oppsToUpdate;
        }
    }
}