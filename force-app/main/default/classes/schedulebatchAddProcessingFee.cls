global class schedulebatchAddProcessingFee implements Schedulable {

    global void execute(SchedulableContext sc) {
    
      batchAddProcessingFee batch = new batchAddProcessingFee(); 
      database.executebatch(batch);
     }}