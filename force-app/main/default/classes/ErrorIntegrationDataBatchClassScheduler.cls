global class ErrorIntegrationDataBatchClassScheduler implements Schedulable{
	global void execute(SchedulableContext sc) {
      ErrorIntegrationDataBatchClass batch = new ErrorIntegrationDataBatchClass(); 
      database.executebatch(batch);
   }
}