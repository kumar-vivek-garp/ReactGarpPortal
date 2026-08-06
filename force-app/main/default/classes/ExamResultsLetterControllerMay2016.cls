/**************************************************

Controller class for Exam Results Letter Pdf 

***************************************************/

public class ExamResultsLetterControllerMay2016 {
    
    private static final String FRM_PART_ONE = 'FRM Part 1';
    private static final String FRM_PART_TWO = 'FRM Part 2';
    private static final String FAIL = 'Fail';
    
    public String now { get; set; }
    
    public Exam_Attempt__c examAttempt { get; set; }
    public Contact candidate { get; set; }
    public Boolean frm1FailFrm2NotGraded { get; set; }
    public Boolean frm2NotGraded { get; set; }    
    private String examGroup { get; set; }
    
    // New Stuff    
    public Boolean isFRM { get; set; }  // FRM or ERP
    public Boolean passPartI { get; set; }  // True / Fale
    public Boolean passPartII { get; set; }  // True / Fale
    public Boolean isPartI { get; set; }  // True / Fale
    public Boolean isDual { get; set; }  // True / Fale
    public Boolean isWindowClosed { get; set; }  // True / Fale
    public integer lastExamMonth {get;set;}
    public string lastExamMonthName {get;set;}
    public string examName {get;set;}
    public integer lastExamYear {get;set;}
    Map<Integer,String> calMap = new Map<Integer,String>();
    
 //   public string memberGARPId {get;set;}
       
    //From Custom Settings
    public String getNextExamDate() { 
        Date nextExamDt = Exam_Results__c.getInstance(examGroup).Next_Exam_Date__c;     
        DateTime nextExamDateTime = DateTime.newInstance(nextExamDt.year(), nextExamDt.month(), nextExamDt.day());
        return nextExamDateTime.format('MMMMM dd, yyyy');
    }
    
    //From Custom Settings
    public String getEmailDate() { 
        Date emailDate = Exam_Results__c.getInstance(examGroup).Email_Date__c;     
        DateTime emailDateTime = DateTime.newInstance(emailDate.year(), emailDate.month(), emailDate.day());
        return emailDateTime.format('MMMMM dd, yyyy');
    }
    
    public String getFullExamDate() { 
        Date examDt = examAttempt.Exam_Date__c;       
        system.debug('examDt:' + examDt);
        if(examAttempt.Sunday_Exam__c == true || (examAttempt.RAD_Status__c != null && examAttempt.RAD_Status__c == 'Approved') ||
           (examAttempt.Room__r.Venue__r.Country__c != null && examAttempt.Room__r.Venue__r.Country__c == 'Israel')) {
               examDt = examDt.addDays(1);
               system.debug('addDays');
           }        
        system.debug('examDt:' + examDt);
        DateTime nextExamDateTime = DateTime.newInstance(examDt.year(), examDt.month(), examDt.day());
        return nextExamDateTime.format('MMMMM dd, yyyy');
    }
    
    
    public String getExamDate() { 
        Date examDt = examAttempt.Exam_Date__c;       
        system.debug('examDt:' + examDt);
        if(examAttempt.Sunday_Exam__c == true || (examAttempt.RAD_Status__c != null && examAttempt.RAD_Status__c == 'Approved') ||
           (examAttempt.Room__r.Venue__r.Country__c != null && examAttempt.Room__r.Venue__r.Country__c == 'Israel')) {
               examDt = examDt.addDays(1);
               system.debug('addDays');
           }        
        system.debug('examDt:' + examDt);
        DateTime nextExamDateTime = DateTime.newInstance(examDt.year(), examDt.month(), examDt.day());
        return nextExamDateTime.format('MMMMM yyyy');
    }
    
    //5 years from the day of the exam is the deadline for work experience submission
    public String getWorkExperienceSubmissionDeadline() { 
        Date examDt = examAttempt.Exam_Date__c;
        if(examAttempt.Sunday_Exam__c == true || (examAttempt.RAD_Status__c != null && examAttempt.RAD_Status__c == 'Approved') ||
           (examAttempt.Room__r.Venue__r.Country__c != null && examAttempt.Room__r.Venue__r.Country__c == 'Israel')) {
               examDt = examDt.addDays(1);
           }
        
        DateTime deadline = DateTime.newInstance(examDt.year() + 5, examDt.month(), examDt.day());
        return deadline.format('MMMMM yyyy');
    }
    
    //From Custom Settings
    public String getNextCertificateDistributionDate() { 
        Date certDate = Exam_Results__c.getInstance(examGroup).Next_Certificate_Distribution_Date__c;     
        DateTime certDateTime = DateTime.newInstance(certDate.year(), certDate.month(), certDate.day());
        return certDateTime.format('MMMMM dd, yyyy'); 
    }
    
    //From Custom Settings
    public String getWorkExperienceSubmissionDate() { 
        Date workDate = Exam_Results__c.getInstance(examGroup).Work_Experience_Submission_Date__c;     
        DateTime workDateTime = DateTime.newInstance(workDate.year(), workDate.month(), workDate.day());
        return workDateTime.format('MMMMM dd, yyyy'); 
    }
    
    
    //Candidate has 4 years to pass FRM2 from day of passing FRM1     
    public String getFrm2Deadline() { 
        
        Date examDt = examAttempt.Exam_Date__c;
        if(examAttempt.Sunday_Exam__c == true || (examAttempt.RAD_Status__c != null && examAttempt.RAD_Status__c == 'Approved') ||
           (examAttempt.Room__r.Venue__r.Country__c != null && examAttempt.Room__r.Venue__r.Country__c == 'Israel')) {
               examDt = examDt.addDays(1);
           }
        
        DateTime frm2Deadline = DateTime.newInstance(examDt.year() + 4, examDt.month(), examDt.day());
        return frm2Deadline.format('MMMMM yyyy');
        
    }
    
    public String getExamMonth() { 
        
        Date examDt = examAttempt.Exam_Date__c;
        if(examAttempt.Sunday_Exam__c == true || (examAttempt.RAD_Status__c != null && examAttempt.RAD_Status__c == 'Approved') ||
           (examAttempt.Room__r.Venue__r.Country__c != null && examAttempt.Room__r.Venue__r.Country__c == 'Israel')) {
               examDt = examDt.addDays(1);
           }
        
        DateTime examDtTm = DateTime.newInstance(examDt.year(), examDt.month(), examDt.day());
        return examDtTm.format('MMMMM');
        
    }
    
    public String getExamMonthAndYear() { 
        
        Date examDt = examAttempt.Exam_Date__c;
        if(examAttempt.Sunday_Exam__c == true || (examAttempt.RAD_Status__c != null && examAttempt.RAD_Status__c == 'Approved') ||
           (examAttempt.Room__r.Venue__r.Country__c != null && examAttempt.Room__r.Venue__r.Country__c == 'Israel')) {
               examDt = examDt.addDays(1);
           }
        
        DateTime examDtTm = DateTime.newInstance(examDt.year(), examDt.month(), examDt.day());
        return examDtTm.format('MMMMM yyyy');
        
    } 
    
    //Indicates if there was any error retrieving data or otherwise processing the request
    public Boolean isError { get; private set; }
    
    
    //Used same logic as that of Exam Ticket 
    public String getCandidateName() { 
        if (candidate == null) {
            return 'Candidate';
        }
        
        if (!String.isBlank(candidate.Name_As_it_Appears_On_ID__c)) {
            return candidate.Name_As_it_Appears_On_ID__c;   
        }
        
        if (!String.isBlank(candidate.Middle_Initial__c)) {
            return candidate.FirstName + ' ' + candidate.Middle_Initial__c + ' ' + candidate.LastName;     
        }
        else {
            return candidate.FirstName + ' ' + candidate.LastName; 
        }
    }   
    
   
   public String getmemberGARPId() { 
        if (candidate == null) {
            return '';
        }
        
        if (!String.isBlank(candidate.GARP_Member_ID__c)) {
            return candidate.GARP_Member_ID__c; 
              
                      
        }
       return '';
         
   }  
      
    
    public ExamResultsLetterControllerMay2016() {
        
        String examId = ApexPages.currentPage().getParameters().get('id');     
        if (examId == null) {
            isError = true;
            return;
        }
        
        List<Exam_Attempt__c> examAttempts = 
            [Select Id, Name, Member__c,  GARP_ID_Number__c, Attending_Exam_Name__c, Section_Exam_Name__c, Section__c, Candidate_Commitment__r.Last_Exam_registration_Date__c , Exam_Date__c, Result__c, hasViolation__c, Sunday_Exam__c, RAD_Status__c, Room__r.Venue__r.Country__c, Other_Exam_Registrations__r.Result__c, Other_Exam_Registrations__r.hasViolation__c, Exam_Site__r.Exam__r.Exam_Group__r.Name FROM Exam_Attempt__c WHERE id= :examId];
        if (examAttempts == null || examAttempts.size() == 0) {
            isError = true;
            return;         
        }    
        
        examAttempt = examAttempts.get(0);    
        
        if (examAttempt.hasViolation__c) {
            isError = true;
            return;
        }
        
        examName=examAttempt.Section_Exam_Name__c;
        lastExamMonth = 1;
        lastExamYear = 1;
        isFRM=false;
        isPartI=false;
        passPartI=false;
        passPartII=false;
        isDual=false;
        isWindowClosed=false;
        
        if(examAttempt.Candidate_Commitment__r.Last_Exam_registration_Date__c != null){    
         lastExamMonth =examAttempt.Candidate_Commitment__r.Last_Exam_registration_Date__c.month();
        }
        
        if(examAttempt.Candidate_Commitment__r.Last_Exam_registration_Date__c != null){
           lastExamYear = examAttempt.Candidate_Commitment__r.Last_Exam_registration_Date__c.year(); 
        }
        calMap.put(1,'January');
        calMap.put(2,'February');
        calMap.put(3,'March');
        calMap.put(4,'April');
        calMap.put(5,'May');
        calMap.put(6,'June');
        calMap.put(7,'July');
        calMap.put(8,'August');
        calMap.put(9,'September');
        calMap.put(10,'October');
        calMap.put(11,'November');
        calMap.put(12,'December');
        lastExamMonthName = calMap.get(lastExamMonth);
        
        if(examAttempt.Section_Exam_Name__c == 'FRM Exam Part I' || examAttempt.Section_Exam_Name__c == 'FRM Exam Part II') {
            isFRM=true;
        }
        
        if(examAttempt.Section_Exam_Name__c == 'FRM Exam Part I' || examAttempt.Section_Exam_Name__c == 'ERP Exam Part I') {
            isPartI=true;
        }
        
        if(examAttempt.Section_Exam_Name__c.indexOf('Part II') > -1) {
            if(examAttempt.Result__c == 'Pass' )
                passPartII=true;
        }
        
        if(examAttempt.Section_Exam_Name__c.indexOf('Part I') > -1) {
            if(examAttempt.Result__c == 'Pass')
                passPartI=true;
        }
        
        if(examAttempt.Attending_Exam_Name__c.indexOf('&') > -1) {
            isDual=true;
        }
        
        if(examAttempt.Candidate_Commitment__r.Last_Exam_registration_Date__c != null) {
            
            Date now = date.today();
            Integer examMonth = examAttempt.Exam_Date__c.month() + 1;
            Integer examYear = examAttempt.Exam_Date__c.year();
            
            Integer lastMonth = examAttempt.Candidate_Commitment__r.Last_Exam_registration_Date__c.month() + 1;
            Integer lastYear = examAttempt.Candidate_Commitment__r.Last_Exam_registration_Date__c.year();
            
            if(examYear == lastYear && examMonth >= lastMonth)
                isWindowClosed=true;
            
            if(examYear > lastYear)
                isWindowClosed=true;
        }
        
        //If exam is FRM2, and FRM1 has a Violation, then don't display the letter for FRM2 
        if (examAttempt.Section__c == FRM_PART_TWO && examAttempt.Other_Exam_Registrations__c != null && examAttempt.Other_Exam_Registrations__r.hasViolation__c) {
            isError = true;
            return;
        }
        
        candidate = [Select FirstName, LastName, Middle_Initial__c, Name_As_it_Appears_On_ID__c, GARP_Member_ID__c from Contact where Id= :examAttempt.Member__c ];    
        
        frm1FailFrm2NotGraded = false;
        if (examAttempt.Section__c == FRM_PART_TWO && examAttempt.Other_Exam_Registrations__c != null && examAttempt.Other_Exam_Registrations__r.Result__c == FAIL) {
            frm1FailFrm2NotGraded = true;
        }
        
        if (examAttempt.Section__c == FRM_PART_ONE && examAttempt.Result__c == 'Fail' && examAttempt.Other_Exam_Registrations__c != null) {
            frm1FailFrm2NotGraded = true;
        }
        
        examGroup = examAttempt.Exam_Site__r.Exam__r.Exam_Group__r.Name; 
        
    }
    
}