global class batchStudyVoteStatusUpdatescheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchStudyVoteStatusUpdate batch = new batchStudyVoteStatusUpdate(); 
      database.executebatch(batch,10);
   }
}