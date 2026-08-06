global class GBI_StudyRoleAssignReminderBatchSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
		Database.executeBatch(new GBI_StudyRoleAssignmentReminderBatch(NULL,NULL));
   }
}