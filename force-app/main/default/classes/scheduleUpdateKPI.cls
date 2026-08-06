global class scheduleUpdateKPI implements Schedulable {
   global void execute(SchedulableContext sc) {
      UpdateKPI batch = new UpdateKPI('fixexamattempt'); 
      database.executebatch(batch);
   }
}