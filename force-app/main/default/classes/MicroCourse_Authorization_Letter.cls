public class MicroCourse_Authorization_Letter {

    public String contractStartDate { get; set; }
    public String contractEndDate { get; set; }
    
    public String candidateFullName { get; set; }
    public String candidateEmail { get; set; }
    public String candidateAddress { get; set; }
    public String candidateGARPId { get; set; }
    
    public String examSchedulingId { get; set; }
    
    public String currentYear  { get; set; }
    public String programName { get; set; }
    
    public MicroCourse_Authorization_Letter() {
        
        String examId = ApexPages.currentPage().getParameters().get('id');
        String courseType = ApexPages.currentPage().getParameters().get('type');
        System.Debug('courseType:' + courseType);

        if(examId == NULL) {
            return;
        }
        
        currentYear =  String.ValueOf( Date.Today().Year() );
        
        List<Exam_Attempt__c> examAttempts = [Select Id, Member__r.FullName__c, Member__r.Email, Member__r.GARP_Member_ID__c,
                                              Member__r.MailingCity, Member__r.MailingState, Member__r.MailingPostalCode, Member__r.MailingCountry, Member__r.MailingStreet, 
                                              Candidate_Commitment__r.StartDate, Candidate_Commitment__r.EndDate
                                              FROM Exam_Attempt__c WHERE id= :examId];
        
        if (examAttempts == null || examAttempts.size() == 0) {
            return;         
        }    
        
        Exam_Attempt__c ea = examAttempts[0];
        
        candidateFullName = ea.Member__r.FullName__c;
        candidateEmail = ea.Member__r.Email;
        candidateGARPId = ea.Member__r.GARP_Member_ID__c;
                
        String programRecordTypeName;
        if(courseType == 'FRRMC1') {
            programRecordTypeName = 'FRR MC1 Program';
            programName = 'FRR Series: Credit Risk Management';
        } else if(courseType == 'FRRMC2') {
            programRecordTypeName = 'FRR MC2 Program';
            programName = 'FRR Series: Market Risk Management';
        } else if(courseType == 'FRRMC3') {
            programRecordTypeName = 'FRR MC3 Program';
            programName = 'FRR Series: Operational Risk Management';
        } else if(courseType == 'FRRMC4') {
            programRecordTypeName = 'FRR MC4 Program';
            programName = 'FRR Series: Asset and Liability Management';
        }
        System.Debug('programRecordTypeName:' + programRecordTypeName);
        System.Debug('programName:' + programName);
        
        candidateAddress = '';
        if(ea.Member__r.MailingStreet != NULL) {
            candidateAddress += ea.Member__r.MailingStreet + '<br/>';
        }
        if(ea.Member__r.MailingCity != NULL) {
            candidateAddress += ea.Member__r.MailingCity;
	        if(ea.Member__r.MailingState != NULL) {
    	        candidateAddress += ', ' + ea.Member__r.MailingState;
        	    if(ea.Member__r.MailingPostalCode != NULL) {
            		candidateAddress += ', ' + ea.Member__r.MailingPostalCode + '<br/>';
        		}
            }
        }
        
        if(ea.Member__r.MailingCountry != NULL) {
            candidateAddress += ea.Member__r.MailingCountry + '<br/>';
        }
        
        MAP<Integer,String> monthMap =  GARP_Common.getMonthMapByNumber();
        
        String startDateMonth = monthMap.get(ea.Candidate_Commitment__r.StartDate.month());
        contractStartDate = startDateMonth + ' ' + ea.Candidate_Commitment__r.StartDate.day() + ', ' + ea.Candidate_Commitment__r.StartDate.year();

        String endDateMonth = monthMap.get(ea.Candidate_Commitment__r.EndDate.month());
        contractEndDate = endDateMonth + ' ' + ea.Candidate_Commitment__r.EndDate.day() + ', ' + ea.Candidate_Commitment__r.EndDate.year();

    }
    
    
}