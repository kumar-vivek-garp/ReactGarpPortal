public without sharing class SyncDPSettingExt {
    
    public Account acct {get;set;}
    
    public String dp_select_val {get;set;}
    
    public List<SelectOption> getOpts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Enable', 'Enable All Study Accounts'));
        options.add(new SelectOption('Disable', 'Disable All Study Accounts'));
        return options;
    }
    
    public SyncDPSettingExt(ApexPages.StandardController acctCtrl) {
        if(!Test.isRunningTest()) acctCtrl.addFields(new List<String>{'Name'});
        acct = (Account)acctCtrl.getRecord();
    }
    
    // Sync all active Study Accounts
    public void syncDPSettings() {
        Id acctId = acct.Id;
        
        List<Study_Account__c> activeStdAccts = [SELECT Id, DP_Not_Required__c FROM Study_Account__c WHERE Account__c = :acctId AND Status__c = 'Active'];
        
        if(activeStdAccts.size() > 0) {
            for(Study_Account__c oneStdAcct : activeStdAccts) {
                if(dp_select_val == 'Enable') {
                    oneStdAcct.DP_Not_Required__c = true;
                }else if(dp_select_val == 'Disable') {
                    oneStdAcct.DP_Not_Required__c = false;
                }
            }
            
            update activeStdAccts;
        }
    }
}