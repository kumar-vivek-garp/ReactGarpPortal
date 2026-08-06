@isTest
public class deleteTestData_Test {
    
    static Opportunity opp; 
    static Exam_Attempt__c examattempt;
    static Site__c testsite;
    static Exam_Sites__c examSite;
    static Exam__c exam;
    static Exam_Group__c objExamGrp;
    static Chapter_Meeting__c chapMeeting ;
    static Chapter_Meeting_Registration__c meetingReg;
    static Contract contract;
    static contact c1;
    
    static void testData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community'];
        
        Account a2 = new Account(name = 'Test Account2',Is_Test_Override__c = 'Is Test');
        insert a2;
        
        c1 = new contact(do_not_fire__c = true, GARP_Member_ID__c = '12345', lastname = 'Test Contact1', MailingCountry ='Cuba', AccountID = a2.ID, email = 'testcontact1@contact.com',recordtypeid = RecordTypeHelper.GetRecordTypeId('Contact','Business Relationship'));
        insert c1;
 
        opp = new Opportunity(amount = 123,Name = 'Test', company__c = 'Payment', accountId = a2.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15, LEGACY_Purchase_Date__c  = system.today());        
        insert opp;
        
        objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;    
        insert objExamGrp;
        
        exam = new Exam__c(Name='May 2015 ERP Exam', Exam__c='ERP', Exam_Code__c ='1111:2015~5');
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 13;
        insert exam;
        
        testsite = new Site__c(Name='USA, MA, BOSTON',Site_Code__c ='1800-11', Display_Address__c  ='Westborough, Boston , MA, USA');
        insert testsite;
        
        examSite = new Exam_Sites__c(Name='May 2015 ERP Exam USA, MA, Boston', CurrencyIsoCode = 'USD', Site__c=testsite.id);
        examSite.Exam__c = exam.id;
        insert examSite;
        
        examattempt = new Exam_Attempt__c(Name='John Doe', Member__c = c1.id, Cancelled__c = False, Defered__c = 'pending');
        examattempt.Exam_Site__c = examSite.id;
        insert examattempt;
        
        chapMeeting = new Chapter_Meeting__c();
        insert chapMeeting;
        
        meetingReg = new Chapter_Meeting_Registration__c();
        meetingReg.Chapter_Meeting__c = chapMeeting.id;
        meetingReg.contact__c = c1.id;
        insert meetingReg;
        
        contract  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program') ,Opportunity__c = opp.id,accountId = opp.AccountId); 
        insert contract;
        contract.Status = 'Activated';
        update contract;
        
    }
    
    static testMethod void myUnitTest_1() {
        
        testData();
        
        test.startTest();
        
        deleteTestData dtd1 = new deleteTestData();
        deleteTestData.objectWrapper obj = new deleteTestData.objectWrapper();
        contact c =[select id ,GARP_Member_ID__c,accountid from contact where id =:c1.id];
        
        string garpid = c.GARP_Member_ID__c;
        
        deleteTestData.deleteTestData(garpid);
        
        
        test.stopTest();     
        
    }
    
    static testMethod void batchAPex() {
        testData();
        
        test.startTest();
        DeteleTestData_Batch batch = new DeteleTestData_Batch ();   
        database.executeBatch(batch);
        test.stopTest();
    }
    
    static testMethod void testScheduler() {  
        testData(); 
        test.starttest();
        DeteleTestData_Batch_schld myClass = new DeteleTestData_Batch_schld ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}