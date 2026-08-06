public class ATACallOutQueueable implements Queueable,Database.AllowsCallouts{
	public Set<Id> intDataIdSet;
    public ATACallOutQueueable(Set<Id> intDataIds){
        this.intDataIdSet = intDataIds;
    }
	public void execute(QueueableContext context) {
        ATA_SchedulingInterfaceClass.ATASchedulingIntegrationCallOut(intDataIdSet);       
    }
}