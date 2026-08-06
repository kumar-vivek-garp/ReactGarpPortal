global class OrderTransactionInvocableBatch_Sch implements Schedulable{
    global void execute(SchedulableContext sc) {
        OrderTransactionInvocableBatch s1= new OrderTransactionInvocableBatch();
        database.executebatch(s1);
    }
}