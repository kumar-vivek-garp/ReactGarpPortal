public class StripeTaxCalQueueable implements Queueable, Database.AllowsCallouts {
    private Set<String> oppId;
    public StripeTaxCalQueueable(Set<String> oppIds){
        oppId = new Set<String>(); 
		this.oppId = oppIds;
    } 
    public void execute(QueueableContext context) { 
        StripeTaxCalUtil.StripeTaxCulate(oppId);
    }
    
   
}