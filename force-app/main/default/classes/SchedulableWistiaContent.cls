global class SchedulableWistiaContent implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new QueueableWistiaContent(1));
    }
}