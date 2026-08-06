@isTest
public class LeadauditHistory_test {
    
    static   lEAD L ;
    
    static void testData(){
        
        L = new lead(lastname = 'Test12121',email='te12st@garp.com',Company='Garp'); 
        insert L;
        
    } 
    
    static testMethod void unitTest_1(){
        
        testData();
        test.startTest();
        Map<Id, lead> oldMap = new Map<Id, lead> ();
        List<lead> le = new List<lead> ();
        lead L1 = new lead();
        
        
        le=[select id,Email,Email_Subscription_Change_Source__c, SCR_Updates__c ,FirstName,LastName,Email_Daily_News__c,Email_Chapter_Meetings__c,exam_Prep_Provider_Outreach__c,Email_Information_Exchange__c,Email_Webcasts__c,Email_Events__c,Email_CorporateTeamBuilding__c,Email_InsightAnalysis__c,Email_GARP_Updates__c,Email_Member_Update__c,Email_Career_Center_Job_Board__c,Email_CPE_News__c,HasOptedOutOfEmail,Email_FRM__c,Email_ERP__c  from lead where id=:l.id];
        L1 =Le[0];
       
        L1.Email='test@test.com';
        L1.Email_Subscription_Change_Source__c='true';
        L1.FirstName='GARP';
        L1.LastName='qa';
        L1.Email_Daily_News__c=true;
        L1.Email_The_Week_in_Risk__c=true;
        L1.Email_Chapter_Meetings__c=true;
        L1.Exam_Prep_Provider_Outreach__c=true;
        L1.Email_Webcasts__c=true;
        L1.Email_Events__c=true;
        L1.Email_CorporateTeamBuilding__c=true;
        L1.Email_InsightAnalysis__c=true;
        L1.Email_GARP_Updates__c=true;
        L1.Email_Information_Exchange__c=true;
        L1.Email_Member_Update__c=true;
        L1.Email_Career_Center_Job_Board__c=true;
        L1.Email_CPE_News__c=true;
        L1.HasOptedOutOfEmail=true;
        L1.Email_FRM__c=true;
        L1.Email_ERP__c =true;
        L1.SCR_Updates__c = true;
        update L1;
        
        oldMap.put(L.Id,L);
        le.add(L1);
        
        system.debug('oldMap==:'+oldMap);
        LeadAuditHistory.trackLeadFields (Le , oldMap);
        
        
        test.stopTest();
        
    }
    
    
}