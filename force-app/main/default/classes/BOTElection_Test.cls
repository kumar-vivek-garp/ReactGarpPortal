@isTest
public class BOTElection_Test {
    
    static Account voterAccount;
    static Contact voterContact;
    static Profile profile;
    static User userIdFromContactId;
    static Board__c boardDetails;
    static List < Board_Participation__c > boardParticipationDetails;
    static List < Board_Participation__c > boardParticipationDetailsByID;
    static List < String  > listOfIds;
    static Integer numberOfCandidatesVotedFor;
    static List< String > GARPProfileIDsOfElectionCandidates;
    static List< Board_Participation__History > voteParticipationHistory;
    static Boolean isVoterEligibleToVote;
    static Boolean wasTheVotingSuccessful;
    
    static void testDataelectionCandidatesTest(){ 
        voterAccount = new Account(Name = 'test');
        insert voterAccount;
        
        voterContact = new Contact(lastname = 'testLastname', AccountId = voterAccount.id, email='test@test.com', Membership_Type__c='Individual');
        insert voterContact;
        
        profile = [SELECT Id FROM Profile WHERE id = '00e400000017dA8' limit 1];
        
        userIdFromContactId = new User(Alias = 'newUser', Email='newuser@testorg.com', contactId = voterContact.id,EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
        
        boardDetails = new Board__c(Is_Current_Election__c=true);
        insert boardDetails;
        
        listOfIds = new List<String>();
        
        boardParticipationDetails = new List<Board_Participation__c>();
        insert boardParticipationDetails;
        
        voteParticipationHistory = new List<Board_Participation__History>();
        insert voteParticipationHistory;
        
        GARPProfileIDsOfElectionCandidates = new List<String>();
        
        boardParticipationDetailsByID = new List<Board_Participation__c>();
        insert boardParticipationDetailsByID;
        
    }
    
    static void testDatavoteForElectionCandidatesTest(){ 
        
        voterAccount = new Account(Name = 'test');
        insert voterAccount;
        
        voterContact = new Contact(lastname = 'testLastname', AccountId = voterAccount.id, email='test@test.com', Membership_Type__c='Individual');
        insert voterContact;
        
        isVoterEligibleToVote = true;
        wasTheVotingSuccessful = true;
    }
    
    static testMethod void electionCandidatesTest() {
        
        testDataelectionCandidatesTest();
        test.startTest();
        
        BOTElection botvoting = new BOTElection();
        BOTElection.electionCandidates(voterContact.id);
        test.stopTest();
    }
    
    static testMethod void voteForElectionCandidatesTest() {
        
        testDatavoteForElectionCandidatesTest();
        test.startTest();
        
        BOTElection botCommitVote = new BOTElection();
        BOTElection.voteForElectionCandidates(listOfIds, 'voter', 'boardYear');
        
        test.stopTest();
    }
    
    
}