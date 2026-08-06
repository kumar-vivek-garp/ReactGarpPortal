public without sharing class paymentUtils {
    public static void publishPaymentEvent(string oppId,decimal amount,string status){
        Payment_Transaction__e transEvt = new Payment_Transaction__e();
        transEvt.Amount__c = amount;
        transEvt.Status__c = status;
        transEvt.Opportunity_Id__c = oppId;
        Eventbus.publish(transEvt);
    }
}