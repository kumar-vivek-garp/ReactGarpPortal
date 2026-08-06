@isTest
public class DigitalBadge_test {

    static contact contact;
    static contact contact1;
    static Account account;
    
    @isTest 
    public static void testData(){
        
        account = new Account(Name = 'test');
        insert account;
        contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com', KPI_SCR_Holder__c= true ,KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17), KPI_ERP_Certified_Year__c = '2018', GARP_Member_ID__c = 'xxxx123');
        insert contact;

        contact1 = new Contact(lastname = 'Test1',AccountId = account.id,email='test1@test.com',KPI_SCR_Holder__c=true, KPI_SCR_Completion_Date__c = Date.newInstance(2009, 2, 17));
        insert contact1;
        
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        frmContract.Status = 'Activated';
        update frmContract;
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Candidate_Requirement__c cr1 = new Candidate_Requirement__c(
            Candidate_Commitment__c = frmContract.Id,
            recordTypeId = ProgReqRecId,
            Exam__c = 'FRM Part I',
            Status__c = 'Completed'
        ); 
        insert cr1;

        Candidate_Requirement__c cr2 = new Candidate_Requirement__c(
            Candidate_Commitment__c = frmContract.Id,
            recordTypeId = ProgReqRecId,
            Exam__c = 'FRM Part II',
            Status__c = 'Completed'
        ); 
        insert cr2;
        
       Test.StartTest(); 

       PageReference pageRef = Page.DigitalBadgeFRM;
       pageRef.getParameters().put('id',contact.id);
       Test.setCurrentPage(pageRef); 
       DigitalBadge badge = new DigitalBadge();
       badge.urlRedirection();
        
       PageReference page = Page.DigitalBadgeFRM;
       page.getParameters().put('id',contact.GARP_Member_ID__c);
       Test.setCurrentPage(page); 
       DigitalBadge db = new DigitalBadge();
       
       //PageReference page1 = Page.DigitalBadgeSCR;
       pageRef.getParameters().put('id',contact1.id);
       Test.setCurrentPage(pageRef); 
       DigitalBadgeSCR db1 = new DigitalBadgeSCR();
       db1.urlRedirection();

       //PageReference page1 = Page.DigitalBadgeSCR;
       pageRef.getParameters().put('id',contact.id);
       Test.setCurrentPage(pageRef); 
       DigitalBadgeSCR db2 = new DigitalBadgeSCR();
       db2.urlRedirection();

       pageRef.getParameters().put('id',contact.id);
       Test.setCurrentPage(pageRef); 
       DigitalBadgeRISKAI db3 = new DigitalBadgeRISKAI();
       db3.urlRedirection();

       pageRef.getParameters().put('id',contact.id);
       Test.setCurrentPage(pageRef); 
       DigitalBadgeRISKAI db4 = new DigitalBadgeRISKAI();
       db4.urlRedirection();
        
        pageRef.getParameters().put('id',contact.id);
        Test.setCurrentPage(pageRef); 
        DigitalBadgeFRMI db5 = new DigitalBadgeFRMI();
        db5.urlRedirection();

        pageRef.getParameters().put('id',contact.id);
        Test.setCurrentPage(pageRef); 
        DigitalBadgeFRMII db6 = new DigitalBadgeFRMII();
        db6.urlRedirection();

        
      Test.StopTest();  
       
    }

}