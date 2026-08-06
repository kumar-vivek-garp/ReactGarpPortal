@isTest
public class B2BOpportunityAttachment_test {

static Account acc ;
static Opportunity opp;

  static void testData(){ 
  
   Acc = new Account(Name = 'test');
   insert acc;
         
   opp = new Opportunity(amount = 123,Name = 'Test', company__c = 'Payment', accountId = acc.id, stageName = 'New Lead', closedate = system.today()+ 15, LEGACY_Purchase_Date__c  = system.today());        
   insert opp;                

   Attachment attach=new Attachment();    
   attach.Name='Unit Test Attachment';
   Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
   attach.body=bodyBlob;
   attach.parentId=opp.id;
   insert attach;

}
     static testMethod void unitTest_1(){
     testData();
     test.startTest();  
     ApexPages.currentPage().getParameters().put('id',opp.id);
     B2BOpportunityAttachment oppatt = new B2BOpportunityAttachment();
     oppatt.getFile();
     test.stopTest();

}
}