global class GBI_StudyDPSignReminderBatchSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
		Database.executeBatch(new GBI_StudyDPSignReminderBatch(NULL,NULL));
   }
}