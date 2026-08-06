global class SageSyncReTryBatchScheduler implements Schedulable{
	global void execute(SchedulableContext sc) {
      SageSyncReTryBatch batch = new SageSyncReTryBatch(); 
      database.executebatch(batch,15);
   }
}