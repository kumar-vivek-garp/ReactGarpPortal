global class ScheduleCreateOppRecurringsBatch implements Schedulable {
   global void execute(SchedulableContext sc) {
      CreateOppRecurringsBatch batch = new CreateOppRecurringsBatch(); 
      database.executebatch(batch,1);
   }
}