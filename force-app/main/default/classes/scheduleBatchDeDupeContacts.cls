global class scheduleBatchDeDupeContacts implements Schedulable {
   string recordId;
   global void execute(SchedulableContext sc) {
      batchDeDupeContacts b = new batchDeDupeContacts(null,'Account'); 
      database.executebatch(b);
      batchDeDupeContacts b1 = new batchDeDupeContacts(null,'Contact'); 
      database.executebatch(b1);
   }
}