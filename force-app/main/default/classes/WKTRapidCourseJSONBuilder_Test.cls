@isTest
public class WKTRapidCourseJSONBuilder_Test {
	
    Static User communityUser;
    Static Account ac;
    static void testdata(){
      
        Id profileId1 = [select id from profile where name=: 'Customer Community'].id;
        ac = new Account(name = 'Test Customer Community') ;
        insert ac;
        
        Contact con = new Contact(LastName = 'Test_Contact_Community' ,
                                  AccountId = ac.Id, 
                                  First_Name_as_it_Appears_on_ID__c = 'Test',
                                  Middle_Name_as_it_Appears_on_ID__c = 'T',
                                  Last_Name_as_it_Appears_on_ID__c = 'Test');
        insert con;
        
        communityUser = new User(alias = 'comUser'
                                      ,email = 'testCommunityUsermig123@test.com'
                                      ,emailencodingkey='UTF-8'
                                      ,lastname = 'Batman'
                                      ,languagelocalekey='en_US'
                                      ,localesidkey='en_US'
                                      ,profileid = profileId1
                                      ,country = 'France'
                                      ,IsActive = true
                                      ,ContactId = con.Id
                                      ,Rapid_Courses__c = ''                 
                                      ,timezonesidkey='America/Los_Angeles'
                                      ,username = 'testCommunityUsermig123@test.com');
        insert communityUser;  
    }
    
    @isTest
    static void unitTest(){
        testdata();
        
        Contact con1 = new Contact(LastName = 'Test_Contact', AccountId = ac.Id);
        insert con1;
        
        User User = new User(alias = 'comUser1'
                                      ,email = 'testCommunityUsermig1123@test1.com'
                                      ,emailencodingkey='UTF-8'
                                      ,lastname = 'Testman'
                                      ,languagelocalekey='en_US'
                                      ,localesidkey='en_US'
                                      ,profileid = communityUser.ProfileId
                             		  ,ContactId = con1.Id
                                      ,country = 'France'
                                      ,IsActive = true
                             		  ,Rapid_Courses__c = '[{"automation_script_id":2,"input":{"course_id":2,"idempotency_key":"garpw123"}}]' 
                                      ,timezonesidkey='America/Los_Angeles'
                                      ,username = 'testCommunityUsermig1123@test1.com');
        insert User;   
        
        test.startTest();
        
     	WKTRapidCourseJSONBuilder.updateUser(communityUser,2,'w123');
     	WKTRapidCourseJSONBuilder.updateUser(User,2,'w123');
        
        test.stopTest();
    }
}