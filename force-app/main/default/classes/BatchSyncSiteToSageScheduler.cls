global class BatchSyncSiteToSageScheduler implements Schedulable {
    string recId;
    global void execute(SchedulableContext sc) {
        string inputRecordId = recId;
        BatchSyncSiteToSage batch = new BatchSyncSiteToSage(inputRecordId); 
        database.executeBatch(batch,100);
    }
}