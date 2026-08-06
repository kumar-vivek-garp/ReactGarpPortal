Global class UpdateClosedLostOfOppWithOLItem_BatSch implements Schedulable {
    Global void Execute(SchedulableContext SC){
        Database.executeBatch(new UpdateClosedLostOfOppWithOLItem_Batch());
    }
}