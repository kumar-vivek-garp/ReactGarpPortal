@isTest
public class GlobalBenchprepAccessClassTest {
	 @isTest static void testGlobalBenchpreAccessAdd() {
        String conEmail = 'apex_tester123@noemail.com';
        Contact con = TestingHelper.createContact(conEmail, true, true);
        
        User user = [SELECT Id, LocaleSidKey,ContactId FROM User WHERE ContactId = :con.Id];
        
        Test.startTest(); 
        System.runAs(user) {
            Contact conrec = [Select Id,GARP_Member_ID__c From Contact Where Id=:user.ContactId]; 
            try {
              String req = '{"coursesluglist":[{"courseId":"FRMBP","expirationdate":"2026-05-20","isslugfound":true,"slugId":"frm25","slugtype":"Add","disableexternalid":true,"required":true}';
                req += ',{"courseId":"FRM1BPPE","expirationdate":"2026-05-20","isslugfound":true,"slugId":"frm1pe","slugtype":"Add","disableexternalid":true,"required":true},';
                 req += '{"courseId":"RAIBP","expirationdate":"2026-05-20","isslugfound":true,"slugId":"rai25","slugtype":"Add","disableexternalid":true,"required":true}],';
                 req += '"garpId":"'+conrec.GARP_Member_ID__c+'"}';
              GlobalBenchprepAccessClass.updatebenchpreAccess(req);  
                GlobalBenchprepAccessClass.getbenchpreuserAccess(conrec.GARP_Member_ID__c);
                GlobalBenchprepAccessClass.getBenchPrepConfig('[{"unlock_events":[{"external_id":"test","event_slug":"frm251pe"}],"expiration_date":"2025-11-18","course_slug":"frm25"}]');
            }catch(Exception e) { 
                
            }
        }
        Test.stopTest();
    }
    
    @isTest static void testGlobalBenchpreAccessRemove() {
        String conEmail = 'apex_tester123@noemail.com';
        Contact con = TestingHelper.createContact(conEmail, true, true);
        
        User user = [SELECT Id, LocaleSidKey,ContactId FROM User WHERE ContactId = :con.Id];
        
        Test.startTest(); 
        System.runAs(user) {
            Contact conrec = [Select Id,GARP_Member_ID__c From Contact Where Id=:user.ContactId]; 
            try {
              String req = '{"coursesluglist":[{"courseId":"FRMBP","expirationdate":"2026-05-20","isslugfound":true,"slugId":"frm25","slugtype":"Add","disableexternalid":true,"required":true}';
                req += ',{"courseId":"RAIBP","expirationdate":"2026-05-20","isslugfound":true,"slugId":"rai25","slugtype":"Remove","disableexternalid":true,"required":true}],';
                 req += '"garpId":"'+conrec.GARP_Member_ID__c+'"}';
                GlobalBenchprepAccessClass.updatebenchpreAccess(req);  
                GlobalBenchprepAccessClass.createEbookSlug(req);  
                
                
            }catch(Exception e) { 
                
            }
        }
        Test.stopTest();
    }
}