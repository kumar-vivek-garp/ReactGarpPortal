global class GBI_StudySubmissionReminderBatchSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
		Database.executeBatch(new GBI_StudySubmissionReminderBatch(NULL,NULL));
   }
}