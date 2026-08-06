global class ScheduleBatchFaliures implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchFaliures batch = new BatchFaliures(); 
      database.executebatch(batch);
   }
}