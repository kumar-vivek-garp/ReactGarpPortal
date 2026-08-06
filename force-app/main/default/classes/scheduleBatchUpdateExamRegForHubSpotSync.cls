global class scheduleBatchUpdateExamRegForHubSpotSync implements Schedulable {
   string recordId;
   global void execute(SchedulableContext sc) {
      batchUpdateExamRegForHubSpotSync b = new batchUpdateExamRegForHubSpotSync(); 
      database.executebatch(b,20);
   }
}