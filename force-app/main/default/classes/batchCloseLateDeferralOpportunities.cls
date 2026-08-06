global class batchCloseLateDeferralOpportunities implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc){
        Date dt = Date.today().adddays(-6);
         String stageName = 'New Lead'; 

     String query1 = 'select Id,Late_EA_Id__c, StageName from Opportunity  Where Purchase_Date__c <: dt';
        query1 += ' AND  Late_EA_Id__c != \''+ +'\''; 
        query1 += ' AND  StageName = \''+stageName+'\'';      
         return Database.getQueryLocator(query1);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> opps){
        list<opportunity> oppids = new list<opportunity>();
        for(Opportunity opp : opps)
        {
            opp.StageName = 'Closed Lost';
            oppids.add(opp);
            
        }
        
        update oppids;
            
    }

    global void finish(Database.BatchableContext bc){
           
    }

}