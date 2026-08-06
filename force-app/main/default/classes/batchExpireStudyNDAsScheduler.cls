global class batchExpireStudyNDAsScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchExpireStudyNDAs batch = new batchExpireStudyNDAs(NULL); 
      database.executebatch(batch,10);
   }
}