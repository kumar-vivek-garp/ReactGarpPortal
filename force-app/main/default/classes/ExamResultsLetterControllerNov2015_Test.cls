@isTest
public class ExamResultsLetterControllerNov2015_Test { 
    
    static Account acc ;
    static Opportunity opp; 
    static Contact contact;
    static Exam_Attempt__c attempt;
    static Exam_Sites__c exmSite;
    static Site__c site;
    static Exam_Group__c objExamGrp;
    static Exam__c exam;
           
    static void testData() { 
        
        acc = new Account(Name = 'test');
        insert acc;
         
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        objExamGrp = new Exam_Group__c();
        objExamGrp.Name = '15-Nov';
        objExamGrp.Active__c = true;
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;    
        insert objExamGrp;
        
        exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = Date.parse('11/21/2015');
        exam.exam__c = 'FRM Part 1'; 
        insert exam;
        
        exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        insert exmSite;
        
        contact = new Contact(KPI_ERP_Certified__c = true,KPI_FRM_Certified__c = true,GARP_Directory_Opt_In__c = true,
                              firstname = 'John', lastname = 'Galt', Middle_Initial__c = 'C', 
                              AccountId = acc.id, email='test@test.com', KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        Venue__c venue = new Venue__c(Name='My Venue', Site__c=site.Id, Address1__c='MyHome', City__c = 'Kinnelon', 
                                      State__c ='NJ', Country__c='USA', Zipcode__c='07405', Venue_Code__c = 'XXX');
        insert venue;
        
        Room__c room = new Room__c(Name='MyRoom', Capacity__c=60, Venue__c=venue.Id);
        insert room;
        
        attempt = new Exam_Attempt__c(Opportunity__c = opp.id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false, Room__c=room.Id,
                                     Seat_No__c='21');
        insert attempt;

        //Custom Settings Object        
        Exam_Results__c cust = new Exam_Results__c(Name = '15-Nov',
                                                   Email_Date__c = Date.parse('01/05/2016'),
                                                   Next_Exam_Date__c = Date.parse('05/21/2016'),
                                                   Next_Certificate_Distribution_Date__c = Date.parse('04/15/2016'),
                                                   Work_Experience_Submission_Date__c = Date.parse('03/31/2016'));
        insert cust;
                      
     }
         
    static testMethod void unitTest_1(){
        testData();
                     
        ApexPages.currentPage().getParameters().put('id', attempt.id);
        ExamResultsLetterControllerNovember2015 ctrl = new ExamResultsLetterControllerNovember2015();
        
        System.assertEquals(ctrl.getNextExamDate(), 'May 21, 2016'); 
        System.assertEquals(ctrl.getEmailDate(), 'January 05, 2016');
        System.assertEquals(ctrl.getExamDate(), 'November 2015'); 
        ctrl.getWorkExperienceSubmissionDeadline(); 
        ctrl.getNextCertificateDistributionDate();
        ctrl.getWorkExperienceSubmissionDate();  
        ctrl.getFrm2Deadline();
        ctrl.getFullExamDate();
        ctrl.getExamDate();
        ctrl.getWorkExperienceSubmissionDeadline();
        ctrl.getFrm2Deadline();
        System.assertEquals(ctrl.getExamMonth(), 'November'); 
        System.assertEquals(ctrl.getExamMonthAndYear(), 'November 2015'); 
        System.assertEquals(ctrl.IsError, null);
        System.assertEquals(ctrl.getCandidateName(), 'John C Galt'); 
             
    }
}