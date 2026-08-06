global class SageSyncErrorBatchScheduler implements Schedulable{
	global void execute(SchedulableContext sc) {
      SageSyncErrorBatch batch = new SageSyncErrorBatch(); 
      database.executebatch(batch);
   }
}