public class PSICallOutQueueable implements Queueable,Database.AllowsCallouts{
	public Set<Id> intDataIdSet;
    public PSICallOutQueueable(Set<Id> intDataIds){
        this.intDataIdSet = intDataIds;
    }
	public void execute(QueueableContext context) {
        PSI_EligibilityLifecycle.PSIEligibilityLifecycleCallOutExt(intDataIdSet);      
    }
}