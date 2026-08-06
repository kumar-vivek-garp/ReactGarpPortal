@isTest
public class GARP_AbandonedCartBatch_test {

    @isTest
    public static void testBatch1(){
        
        Contact cont = new Contact(firstname = 'fn', lastname = 'ln');
        insert cont;
        
        Form__c form = new Form__c(
            Name='exam-registration-frm',
            Form_Name__c='exam-registration-frm'
        );
        insert form;
        
        Form_Data__c fd = new Form_Data__c();
        fd.Status__c = 'Abandoned';
        fd.Contact__c = cont.Id;
        fd.Form__c = form.Id;
        insert fd;
        
        test.starttest();
        Database.executeBatch(new GARP_AbandonedCartBatch(NULL));
        Test.stoptest();
    }
    
    @isTest
    public static void testBatch2(){

        Lead lead = new Lead(LastName = 'ln', Company='company', Email = 'lead@lead.com');
        insert lead;
        
        Form__c form = new Form__c(
            Name='exam-registration-frm',
            Form_Name__c='exam-registration-frm'
        );
        insert form;
        
        Form_Data__c fd = new Form_Data__c();
        fd.Status__c = 'Abandoned';
        fd.Lead__c = lead.Id;
        fd.Form__c = form.Id;
        insert fd;
        
        test.starttest();
        Database.executeBatch(new GARP_AbandonedCartBatch(NULL));
        Test.stoptest();
    }
    
    Public static testMethod void testSchedule()
    {
        test.starttest();
        GARP_AbandonedCartBatchSchedule s1= new GARP_AbandonedCartBatchSchedule();
        system.schedule('Test Schedule','0 0 0 * * ?',s1);
        Test.stoptest();
    }
    
}