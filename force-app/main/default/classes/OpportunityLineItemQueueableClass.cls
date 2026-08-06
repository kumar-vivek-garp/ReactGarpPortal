public class OpportunityLineItemQueueableClass implements Queueable, Database.AllowsCallouts  {
    
    public Map<String,List<OpportunityLineItem>> relatedOppIdOLIMap;
    
    public OpportunityLineItemQueueableClass(Map<String,List<OpportunityLineItem>> relatedOppIdOLIMap){
        this.relatedOppIdOLIMap = relatedOppIdOLIMap ;  
    }
    
    public void execute(QueueableContext context) {
        if(relatedOppIdOLIMap.KeySet().size() > 0){
            SageApiWebService.updateOppLineItems(relatedOppIdOLIMap );
        }
    }
}