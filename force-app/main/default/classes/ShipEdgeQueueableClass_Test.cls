@isTest
Private class ShipEdgeQueueableClass_Test{
    
    @isTest static void unitTest() {
        
        List<Opportunity> oppList=new List<Opportunity>();
        Set<String> SetOpp=new Set<String>();
        Set<id> SetOppID=new Set<id>();
        Account acc=new Account(name='Test');
        insert acc;
        
        for(Integer i=0;i<2;i++)
        {   
            oppList.add(new Opportunity(Name = 'Test'+i,
                                        stageName = 'New Lead',
                                        CloseDate = Date.today()+i,
                                        Customs_Cost__c = '1200'+i,
                                        accountid=acc.id,
                                        Products_SKU__c = '111-01'+i));
        }
        insert oppList;
        
        oppList = [SELECT Id FROM Opportunity where Name like 'Test%'];       
        //for(Opportunity opp:oppList)
        //SetOpp.add((String)opp.id);
        for(Opportunity opp:oppList)
            SetOppID.add((id)opp.id);
        
        
        Test.startTest();                            
        
        System.debug('ShipEdge'+ShipEdgeMDT__mdt.getInstance('ShipEdge'));
        System.enqueueJob(new ShipEdgeQueueableClass(SetOppID,'AddOrder'));
        System.enqueueJob(new ShipEdgeQueueableClass(SetOppID,'CancelOrder'));
        
        Test.stopTest();
    }
    
}