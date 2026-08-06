global class scheduleAddressFixBatch implements Schedulable {
     global void execute(SchedulableContext sc) {
      AddressFixBatch batch = new AddressFixBatch(null); 
      database.executebatch(batch,200);
     }
}