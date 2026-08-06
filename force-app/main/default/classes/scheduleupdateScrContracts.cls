global class scheduleupdateScrContracts implements Schedulable {
   global void execute(SchedulableContext sc) {
      updateScrContracts batch = new updateScrContracts(); 
      database.executebatch(batch,10);
   }
}