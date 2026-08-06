global class scheduleUpdateMemberPrograms implements Schedulable {

    global void execute(SchedulableContext sc) {
        UpdateKPI batch = new UpdateKPI('memberprogramcountdown'); 
        database.executebatch(batch,50);
    }
}