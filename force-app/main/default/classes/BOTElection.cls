public class BOTElection {
    
    public class returnelectionCandidates {
        public List < Board__c  > electionBoardDetails { get; set; }
        public List < Board_Participation__c > allElectionCandidates { get; set; }
        public List < String  > allElectionCandidatesMediaURLs { get; set; }
        public Boolean hasVotervotedBefore { get; set; }
        public Boolean isElectionOpen { get; set; }
        public Boolean showWidgetOnDash { get; set; }
    } 
    
    public class returnVotingResponse {
        public List <sObject> allVotedElectionCandidates { get; set; }
        public Boolean isVoterEligibleToVote { get; set; }
        public Boolean hasVotervotedBefore { get; set; }
        public Boolean wasTheVotingSuccessful { get; set; }
        public List <Contact> voterMembershipContract { get; set; }
        public List <Board_Participation__History> voteParticipationHistory { get; set; }
        public List <User> userIdFromContactId { get; set; }   
    }
    
    public static returnelectionCandidates electionCandidates(String contactId) {
        returnelectionCandidates rd = new returnelectionCandidates();
        
        Boolean isElectionOpen = false;
        Boolean showWidgetOnDash = false;
        DateTime currentDate = DateTime.now();
        
        List < Board__c > electionBoardDetails = [SELECT Name, Number_Of_Open_Seats__c, Election_Start_Date__c, Election_End_Date__c, Is_Current_Election__c, Show_Widget_On_Dash__c FROM Board__c where Is_Current_Election__c = true];
        List < Board_Participation__c > allElectionCandidates = [SELECT Name, Contact__r.GARP_Profile__r.Bio__c, Contact__r.GARP_Profile__r.Id, Board__c, Board_Title__c, Contact__r.Name, Contact__r.GARP_Profile__r.Qualifications__c FROM Board_Participation__c where Board__r.Is_Current_Election__c=true];
        List<String> GARPProfileIDsOfElectionCandidates = new List<String>();
        List<String> allElectionCandidatesMediaURLs = new List<String>();
        
        for(Board_Participation__c electionCandidate: allElectionCandidates){
            GARPProfileIDsOfElectionCandidates.add(electionCandidate.Contact__r.GARP_Profile__r.Id);
        }
        
        List < cdrive__Cloud_Files__c > allElectionCandidatesMedia = [SELECT Id, cdrive__contextID__c, cdrive__File_Name__c from cdrive__Cloud_Files__c where cdrive__contextID__c = :GARPProfileIDsOfElectionCandidates]; 
        for(cdrive__Cloud_Files__c electionCandidateMedia: allElectionCandidatesMedia){
            allElectionCandidatesMediaURLs.add('https://s3-us-west-2.amazonaws.com/garpsalesforcepublic/GARP_Profile__c/' + electionCandidateMedia.cdrive__contextID__c + '/' + electionCandidateMedia.Id + '_' + electionCandidateMedia.cdrive__File_Name__c);
        }  
        String ElectionYear = electionBoardDetails[0].Name;  
        
        if((electionBoardDetails[0].Election_Start_Date__c < currentDate) && (electionBoardDetails[0].Election_End_Date__c > currentDate)){
            isElectionOpen = true;
        }
        
        if(electionBoardDetails[0].Show_Widget_On_Dash__c){
            showWidgetOnDash = true;
        }
        
        rd.electionBoardDetails = electionBoardDetails;
        rd.allElectionCandidates = allElectionCandidates;
        rd.allElectionCandidatesMediaURLs = allElectionCandidatesMediaURLs;
        rd.hasVotervotedBefore = hasVoterVotedInThisElectionBefore(contactId, ElectionYear);
        rd.isElectionOpen = isElectionOpen;
        rd.showWidgetOnDash = showWidgetOnDash;
        return rd;
    }
    
    public static Boolean hasVoterVotedInThisElectionBefore(String voter, String boardYear) {
        Boolean hasVotervotedBefore = false;
        String userId = '';
        
        List < User > userIdFromContactId = [SELECT ContactId from User where Contact.Id = :voter];
        for(User userDetails: userIdFromContactId){
            userId = userDetails.Id;
        }        
        
        List <Board_Participation__History> voteParticipationHistory = [SELECT Id, Field, CreatedById, NewValue, OldValue FROM Board_Participation__History WHERE field='Total_Votes__c' and parent.Board__r.name = :boardYear and CreatedById = :userId];
        Integer size = voteParticipationHistory.size();
        
        if(size > 0){
            hasVotervotedBefore = true;
        }
        return hasVotervotedBefore;
    }
    
    public static returnVotingResponse voteForElectionCandidates(LIST<String> listOfIds, String voter, String boardYear) {
        returnVotingResponse rd = new returnVotingResponse();
        Boolean canVoterVote = false;
        Boolean hasVotervotedBefore = false;
        Boolean wasTheVotingSuccessful = false;
        String userId = '';
        
        //      1. Check Membership Status
        
        List<Contact> voterMembershipContract = [select Id, Name, RPT_Membership_Payment_Status__c from Contact where Id = :voter];
        
        for(Contact electionVoter: voterMembershipContract){
            if(electionVoter.RPT_Membership_Payment_Status__c == 'In Good Standing'){
                canVoterVote = true;
            } else {
                canVoterVote = false;
            }
        }
        
        //      2. make sure the member hasn't voted in this election before
        //          a. Grab the Users User ID from their Contact ID.    
        
        List < User > userIdFromContactId = [SELECT ContactId from User where Contact.Id = :voter];
        
        for(User userDetails: userIdFromContactId){
            userId = userDetails.Id;
        }        
        
        List <Board_Participation__History> voteParticipationHistory = [SELECT Id, Field, CreatedById, NewValue, OldValue FROM Board_Participation__History WHERE field='Total_Votes__c' and parent.Board__r.name = :boardYear and CreatedById = :userId];
        Integer size = voteParticipationHistory.size();
        
        if(size > 0){
            hasVotervotedBefore = true;
        }
        
        //       3. If the Member is eligiable to Vote, Case His/Her vote
        
        if((canVoterVote == true) && (hasVotervotedBefore == false)){
            List < Board_Participation__c > boardParticipationDetailsByID = [SELECT Name, Total_Votes__c, Board__c, Board_Title__c, Contact__r.Name FROM Board_Participation__c where (Election_Candidate__c = true and Contact__c = :listOfIds)];
            
            for(Board_Participation__c boardParticipant: boardParticipationDetailsByID){
                boardParticipant.Total_Votes__c = boardParticipant.Total_Votes__c + 1;
            }
            update boardParticipationDetailsByID;
            Integer numberOfCandidatesVotedFor = boardParticipationDetailsByID.size();
            if(numberOfCandidatesVotedFor > 0){
                wasTheVotingSuccessful = true;
            }
            rd.allVotedElectionCandidates = boardParticipationDetailsByID;
            rd.wasTheVotingSuccessful = wasTheVotingSuccessful;
            rd.isVoterEligibleToVote = canVoterVote;
            rd.hasVotervotedBefore = hasVotervotedBefore;
        } else {
            rd.isVoterEligibleToVote = canVoterVote;
            rd.hasVotervotedBefore = hasVotervotedBefore;
        }      
        return rd;
    }
    
}