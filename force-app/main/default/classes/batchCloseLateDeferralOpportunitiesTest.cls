@isTest
public class batchCloseLateDeferralOpportunitiesTest {
   
   private static final String OLD_OPP = 'Old Opp';

   public static testmethod void test() {

     Opportunity oldOpp = new Opportunity(Name = OLD_OPP, StageName = 'New Lead', Late_EA_Id__c='test', CloseDate = Date.today().addDays(1), LEGACY_Purchase_Date__c = DateTime.now().adddays(-7));
      insert oldOpp;
       
        Test.startTest();
        batchCloseLateDeferralOpportunities c = new batchCloseLateDeferralOpportunities();
        Database.executeBatch(c);
        Test.stopTest();
}
}