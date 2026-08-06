@isTest
public class GBI_Pillar3_Test {
    
    @IsTest
    static void test1(){
        
        Account acc = new Account(Name = 'test', GBI_Region__c='North America'); 
        insert acc;
        
        Contact con = new Contact( GBI_Participant__c = TRUE, KPI_ERP_Certified__c = TRUE, KPI_FRM_Certified__c = TRUE,
                                  GARP_Directory_Opt_In__c = TRUE,lastname = 'Test',AccountId = acc.id,email='newuseringbipiller@testorg.com',
                                  KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert con;        
        
        Contact cont = [SELECT Id FROM Contact WHERE Email = 'newuseringbipiller@testorg.com'];
        User usr = [SELECT Id, Email, contactId from User WHERE contactId =: cont.Id];
        
        system.runAs(usr){
            Pillar_3_Institution__c p3i = new Pillar_3_Institution__c(Name = 'p3i',Alias__c = 'Alias',Country__c = 'US',Institution_Type__c='Inst',
                                                                      Display_Name__c='Display_Name',Country_Code__c = 'US', Legal_Name__c='LName',
                                                                      Active__c = TRUE, CurrencyIsoCode = 'USD');
            insert p3i;
            
            Pillar_3_Report__c pr = new Pillar_3_Report__c();
            pr.Name = 'report';
            pr.Viz_URL__c = 'http://www.report.com';
            pr.Navigation_Tab__c = 'Data Views';
            pr.Order__c = 1;
            pr.Tab_Color__c = '#00A2DD';
            insert pr;
            System.debug('Add Pillar_3_Report__c:' + pr);
            
            GBI_MS_Pillar3.getPillar3Notifications();
            GBI_MS_Pillar3.getPillar3Filters();
            GBI_MS_Pillar3.getPillar3Menu();
            //GBI_MS_Pillar3.submitPillar3Attestation();
            
            GBI_MS_Studies msStud = new GBI_MS_Studies();
            GBI_MS_Pillar3 gbi = new GBI_MS_Pillar3(msStud);
        }
    }
    
    @IsTest
    static void test2(){
        
        Account acc = new Account(Name = 'test', GBI_Region__c='North America'); 
        insert acc;
        
        Contact con = new Contact( GBI_Analytics_Participant__c = TRUE, KPI_ERP_Certified__c = TRUE, KPI_FRM_Certified__c = TRUE,
                                  GARP_Directory_Opt_In__c = TRUE,lastname = 'Test',AccountId = acc.id,email='newuseringbipiller@testorg.com',
                                  KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert con;        
        
        Contact cont = [SELECT Id FROM Contact WHERE Email = 'newuseringbipiller@testorg.com'];
        User usr = [SELECT Id, Email, contactId from User WHERE contactId =: cont.Id];
        
        
        
        test.startTest();
        
        system.runAs(usr){
            Pillar_3_Institution__c p3i = new Pillar_3_Institution__c(Name = 'p3i',Alias__c = 'Alias',Country__c = 'US',Institution_Type__c='Inst',
                                                                      Display_Name__c='Display_Name',Country_Code__c = 'US', Legal_Name__c='LName',
                                                                      Active__c = TRUE, CurrencyIsoCode = 'USD');
            insert p3i;
            
            Pillar_3_Report__c pr = new Pillar_3_Report__c();
            pr.Name = 'report';
            pr.Viz_URL__c = 'http://www.report.com';
            pr.Navigation_Tab__c = 'Data Views';
            pr.Order__c = 1;
            pr.Tab_Color__c = '#00A2DD';
            insert pr;
            System.debug('Add Pillar_3_Report__c:' + pr);
            
            GBI_MS_Pillar3.getPillar3Notifications();
            GBI_MS_Pillar3.getPillar3Filters(); 
            GBI_MS_Pillar3.getPillar3Menu();
            //GBI_MS_Pillar3.submitPillar3Attestation();
        }
        
        test.stopTest();
    }
}