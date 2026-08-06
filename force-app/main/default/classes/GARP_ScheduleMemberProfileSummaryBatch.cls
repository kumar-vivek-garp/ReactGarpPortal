global class GARP_ScheduleMemberProfileSummaryBatch implements Schedulable {
   global void execute(SchedulableContext sc) {   
       GARP_MemberProfileSummaryBatch obj = new GARP_MemberProfileSummaryBatch('needed',NULL,NULL,'normal',true,false);
       Id batchId = Database.executeBatch(obj);
   }
}