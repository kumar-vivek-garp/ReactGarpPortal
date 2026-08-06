Public class UpdateClosedLostOfOppWithOLItem_Batch implements Database.Batchable<Sobject>{
    
    Public Database.QueryLocator Start(Database.BatchableContext bc){
        String oppstatus = 'New Lead';
        String prodCode = 'FRM1';
        String glCode = '4020';
        //string recordid = '0066u000008Jzak';
        Date dt = system.today().adddays(-5);
        String query = 'SELECT Id, opportunityId, opportunity.Stagename,Opportunity.createdDate,ProductCode, CreatedDate FROM OpportunityLineItem ';
        query += ' Where opportunity.Stagename =:oppstatus';                 
        query += ' AND ProductCode =: prodCode';
        query += ' AND Product2.Gl_Code__c =: glCode';
        query += ' AND Opportunity.createdDate <: dt';
        //query += ' AND opportunityId=: recordId';
        return Database.getQueryLocator(query);
    }
    
    Public void Execute(Database.BatchableContext bc, List<OpportunityLineItem> scope){
        
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityLineItem oli : scope){
            oppIds.add(oli.opportunityId);
        }
        
        if(oppIds.size() > 0){
            List<Opportunity> OppList = new List<Opportunity>();
            for(Opportunity opp : [select id,stageName from Opportunity where id in: oppIds]){
                opp.StageName = 'Closed Lost';
                OppList.add(opp);
            }
            if(OppList.size() > 0){
                Update OppList;
            }
        }
    }
    
    Public void Finish(Database.BatchableContext bc){}
}