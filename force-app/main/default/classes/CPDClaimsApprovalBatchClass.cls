global class CPDClaimsApprovalBatchClass implements Database.Batchable<sObject>, Database.Stateful {
    Global Database.QueryLocator start(Database.BatchableContext bc){
       // string otherType = 'Other';
        string prgActv = 'Activated ( Auto-Renew )'; 
        List<String> candidateStatus = new List<String>();
        candidateStatus.add('Activated ( Auto-Renew )');
        Date today = System.today();
        if (today.month() == 1 && today.day() == 1) { 
            candidateStatus.add('Completed');
            candidateStatus.add('Expired'); 
        }
        return Database.getQueryLocator(
            'SELECT ID,Name,Member__c,Garp_ID__c,Credits_Earned__c,CPD_Activity__c,Approved__c,CPE_Activity_Type__c,CPE_Activity_Type__r.name from CPE_Claim__c WHERE CPE_Activity_Type__c!= null and Approved__c=false and Candidate_Requirement__r.Candidate_Commitment__r.Status In: candidateStatus and(( Credits_Earned__c <=20 and CreatedDate != Last_N_Days:2) OR (To_Be_Approved__c=true ))');
    }
    
    global void execute(Database.BatchableContext BC, List<CPE_Claim__c> Scope){
        for(CPE_Claim__c ce:Scope){
         
             
                ce.Approved__c= True;
                
           
        }
        Update Scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}