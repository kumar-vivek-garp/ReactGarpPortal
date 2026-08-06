global class GBI_StudyVoteReminderBatchSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
		Database.executeBatch(new GBI_StudyVoteReminderBatch(NULL,NULL));
   }
}