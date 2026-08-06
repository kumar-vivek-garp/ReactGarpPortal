@isTest
public class ExamResultsLetterControllerMay2016_Test {
 
    Static Account acc;
    Static Contact ct;
    Static Opportunity opp;
    static Exam_Sites_For_FRM_Batch__c ess;
    Static Exam_Attempt__c ea;
    Static Exam_Attempt__c ea1;
    
    
    Static Exam_Sites__c es;
    Static Exam_Sites__c es2;
    Static Exam_Sites__c es1;
    Static Exam_Sites__c es3;
    
    Static Exam__c exam;
    Static Exam__c exam2;
    Static Exam__c exam1;
    Static Exam__c exam3;
    
    static Site__c site;
    static Site__c site1;
    
    
    static Exam_Group__c examGroup;
    static Exam_Group__c examGroup1;
   
    static void testData()
     {
        acc = new Account(name = '15-Nov', Calculated_Expire_Date__c = system.today(), Last_Contract_Exp_Calc__c = system.today());
        insert acc;
        
        ct = new Contact(accountId = acc.Id,lastName='Test Contact',email='test@test1.com');
        insert ct;
        
        Date myDate = Date.newInstance(2015,11,21);

       
        examGroup = new Exam_Group__c(Name = '15-Nov',Exam_Date__c=myDate);
        insert examGroup;
        
        site = new Site__c(Name = 'Test Site',Site_Code__c = '123');
        insert site;
        
        exam = new Exam__c(Name = 'Test EXAM',Exam__c = 'FRM Part 1',Exam_Date__c = myDate,Exam_Group__c =examGroup.Id );
        insert exam;

        exam2 = new Exam__c(Name = 'Test EXAM',Exam__c = 'FRM Part 2',Exam_Date__c = myDate,Exam_Group__c =examGroup.Id );
        insert exam2;
        
        es = new Exam_Sites__c(name = 'Test ES1',Exam__c = exam.Id,Site__c = site.id);
        insert es;
        
        es2 = new Exam_Sites__c(Name = 'Test Exam Site',Exam__c = exam2.Id,Site__c = site.id);
        insert es2;
        
        ess = new Exam_Sites_For_FRM_Batch__c (Name ='FRM Details',section__c='FRM Part 2', Exam_Id__c =exam.id);
        insert ess;


        examGroup1 = new Exam_Group__c(Name = 'Test Exam Group',Active__c = true,Exam_Date__c=system.today()+15);
        insert examGroup1;
        
        site1 = new Site__c(Name = 'Test Site',Site_Code__c = '123');
        insert site1;
        
        exam1 = new Exam__c(Name = 'Test EXAM',Exam__c = 'FRM Part 1',Exam_Date__c = system.today()+15,Exam_Group__c =examGroup1.Id );
        insert exam1;

        exam3 = new Exam__c(Name = 'Test EXAM',Exam__c = 'FRM Part 2',Exam_Date__c = system.today()+15,Exam_Group__c =examGroup1.Id );
        insert exam3;
        
        es1 = new Exam_Sites__c(name = 'Test ES1',Exam__c = exam1.Id,Site__c = site.id);
        insert es1;
        
        es3 = new Exam_Sites__c(Name = 'Test Exam Site',Exam__c = exam3.Id,Site__c = site.id);
        insert es3;

        
        opp = new Opportunity(name = 'Test Opp1', AccountId = acc.Id, CloseDate = system.today(), StageName = 'Closed', FRM_1_Registration_Fee__c = 350.00);
        insert opp;
         
         contract cont  = new Contract(ContractTerm =2,startDate = system.today()- 1,Membership_Type__c = 'Individual',recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program') ,Opportunity__c = opp.id,accountId = acc.id); 
        insert cont;
        cont.Status = 'Activated';
        update cont;
        
        Candidate_Requirement__c reqt = new Candidate_Requirement__c();
        reqt.Candidate_Commitment__c = cont.id;
        reqt.name = 'PASS FRM1';
        insert reqt;
        
        Candidate_Requirement__c reqt1 = new Candidate_Requirement__c();
        reqt1.Candidate_Commitment__c = cont.id;
        reqt1.name = 'PASS FRM2';
        insert reqt1;
        
        ea = new Exam_Attempt__c(name = 'Test EA1', Exam_Site__c = es.Id, Opportunity__c =opp.Id,Candidate_Commitment__c=cont.id,result__C ='fail',Member__c=ct.id,Candidate_Requirement__c = reqt.id);
        insert ea;

       
        ea1 = new Exam_Attempt__c(name = 'Test EA2', Exam_Site__c = es3.Id, Opportunity__c =opp.Id,Candidate_Commitment__c=cont.id, Defered__c = 'Approved',Member__c = ct.Id,Candidate_Requirement__c = reqt1.id);
        insert ea1;

          insert new Exam_Results__c(Name='15-Nov', Email_Date__c =date.newInstance(2015,5,16), Next_Certificate_Distribution_Date__c=date.newInstance(2015,5,16), Next_Exam_Date__c=date.newInstance(2015,5,16), Work_Experience_Submission_Date__c=date.newInstance(2015,5,16));        
        
        }
     
     static testMethod void UnitTest_1()
    {
        test.startTest();
        testData();
        ApexPages.currentPage().getParameters().put('id',ea.id);
        ExamResultsLetterControllerMay2016 exams = new ExamResultsLetterControllerMay2016();
        exams.getFullExamDate();
        exams.getExamDate();
        exams.getWorkExperienceSubmissionDeadline();
        exams.getNextCertificateDistributionDate();
        exams.getWorkExperienceSubmissionDate();
        exams.getFrm2Deadline();
        exams.getExamMonth();
        exams.getExamMonthAndYear();
        exams.getCandidateName();
        exams.getNextExamDate(); 
        exams.getEmailDate();
        exams.getmemberGARPId();    
        test.stopTest();
    }

}