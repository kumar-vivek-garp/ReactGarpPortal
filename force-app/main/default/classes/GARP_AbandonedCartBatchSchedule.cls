global class GARP_AbandonedCartBatchSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
       Database.executeBatch(new GARP_AbandonedCartBatch(NULL));
   }
}