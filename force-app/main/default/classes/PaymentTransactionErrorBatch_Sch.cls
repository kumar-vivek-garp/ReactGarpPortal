global class PaymentTransactionErrorBatch_Sch implements Schedulable{
	global void execute(SchedulableContext sc) {
      PaymentTransactionErrorBatch batch = new PaymentTransactionErrorBatch(); 
      database.executebatch(batch);
   }
}