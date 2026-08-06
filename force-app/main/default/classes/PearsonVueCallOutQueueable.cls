public class PearsonVueCallOutQueueable implements Queueable,Database.AllowsCallouts{
    public Set<Id> pearsonIds;
    public PearsonVueCallOutQueueable(Set<Id> pearsonIdSet){
        this.pearsonIds = pearsonIdSet;
    }
	public void execute(QueueableContext context) {
        PearsonVueRTIDataHelper.PearsonVueDate(pearsonIds);       
    }
}