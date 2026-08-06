@isTest
public class DuplicatePTOTest {

    @isTest
    static void unitTest(){
        
        Integer targetYear = System.today().year() + 1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Accounting'];

        User user = new User(alias='tst9527', email='nosuchuser39@nomail.com',
            emailencodingkey='UTF-8', firstname='Tiesto', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid=p.Id, country='United States', IsActive=true,
            ContactId=null,
            timezonesidkey='America/Los_Angeles', username='atst9527' + System.now().millisecond() + '@nomail.com');
            
        insert user;
        
        user.alias = 'tst9529';
        user.PTO_Office__c = 'NJ';
        user.Start_Date_with_Company__c = Date.newInstance(System.today().year() + 1, 1, 1).addMonths(-49);
        
              
        GARP_Time_Off_Balance__c gto = new GARP_Time_Off_Balance__c(Employee__c = user.Id,Vacation_Days_Allottment__c = 15, Start_Date__c = Date.newInstance(targetYear, 1, 1), End_Date__c = Date.newInstance(targetYear, 12, 31));
		insert gto;
        
        GARP_Time_Off_Balance__c gto1 = new GARP_Time_Off_Balance__c(Employee__c = user.Id,Vacation_Days_Allottment__c = 15, Start_Date__c = Date.newInstance(targetYear, 1, 1), End_Date__c = Date.newInstance(targetYear, 12, 31));
		insert gto1;
        
        GARP_Time_Off_Request__c gtor1 = new  GARP_Time_Off_Request__c(GARP_Time_Off_Balance__c = gto.id,
                                                                      Start_Day_Off__c = Date.newInstance(targetYear,2,20),
                                                                      End_Day_Off__c = Date.newInstance(targetYear,2,24),
                                                                      Acknowledgment__c = true,Status__c = 'Approved');
        insert gtor1;
        
        GARP_Time_Off_Request__c gtor = new  GARP_Time_Off_Request__c(GARP_Time_Off_Balance__c = gto.id,
                                                                      Start_Day_Off__c = Date.newInstance(targetYear,2,20),
                                                                      End_Day_Off__c = Date.newInstance(targetYear,2,24),
                                                                      Acknowledgment__c = true,Status__c = 'Approved');
        insert gtor;
        
        Test.startTest();
        gtor.Status__c = 'Submitted';
        gtor.Start_Day_Off__c = Date.newInstance(targetYear,2,22);
        update gtor;
        
        Test.stopTest();
        
    }
    
}