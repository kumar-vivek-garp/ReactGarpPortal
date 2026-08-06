@isTest
private class EBookSyncQueueTest {
    
    @isTest
    private static void test_utils() {
        Test.startTest();
        Boolean useQueue = EBookSyncQueue.useQueue;
        
        EBookSyncQueue queue = new EBookSyncQueue('FRM', 'I', '19FRM1X', 36, new Integer[]{13,14,15,30}, new Opportunity[]{}, 0, false);
        Test.stopTest();
    }
    
    @isTest
    private static void test_queue() {
        Opportunity oppty = TestingHelper.createOppty('Test Apex Oppty', false, true);
        oppty.Shipping_E_mail__c = 'auser.testo@nomail.com';
        oppty.Shipping_First_Name__c ='Auser'; 
        oppty.Shipping_Last_Name__c= 'Testo';
        
        Opportunity oppty2 = oppty.clone(false, false, false, false);
        oppty2.Name = 'Test Apex Oppty 2';
        oppty.Shipping_E_mail__c = 'auser.testo2@nomail.com';
        oppty.Shipping_Last_Name__c= 'Testo2';
        insert new Opportunity[]{oppty, oppty2};
        
        Test.startTest();
        System.enqueueJob(new EBookSyncQueue('FRM', 'I', '19FRM1X', 36, new Integer[]{13,14,15,30}, new Opportunity[]{oppty}, 0, false));
        Test.stopTest();
    }
    
}