@isTest
public class ExamRegistrationHandlerClass_Test {
    
    static Account acc;
    static Contact contact;
    static Opportunity opp; 
    static Exam_Group__c objExamGrp;
    static Exam_Group__c objExamGrpNew;
    static Exam__c examFRM1;
    static Exam__c examFRM2;
    static Exam__c examERP1;
    static Exam__c examERP2;
    static Exam_Sites__c exmSite;
    static Exam_Sites__c exmSite2;
    static Exam_Sites__c exmSite3;
    static Exam_Sites__c exmSite4;
    static Site__c site;
    static venue__c venue;
    static room__c room;
    static Exam_Administration__c examAdmin;
    static Exam_Administration__c examAdmin2;
    static Exam_Part__c examPart;
    static Exam_Part__c examPart2;
    static Exam_Part__c examPartERP1;
    static Exam_Part__c examPartERP2;
    
    static void testData(){ 
        Default_Settings__c ds = new Default_Settings__c();
        ds.Name = 'Default';
        ds.ATA_PSI_Callout__c = true;
        insert ds;
        
        Acc = new Account(Name = 'test');
        insert acc;
        
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment',
                              accountId = acc.id,stageName = 'Closed',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        contact = new Contact(lastname = 'Test',AccountId = acc.id,email='test@test.com',
                              KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        List<Exam_Group__c> examGrpList = new List<Exam_Group__c>();
        objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true; 
        objExamGrp.Exam_Date__c = system.today().addDays(13);
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today().addDays(1);
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today().addDays(9) ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today().addDays(10) ; 
        examGrpList.add(objExamGrp);
        
        objExamGrpNew = new Exam_Group__c();
        objExamGrpNew.Active__c = false; 
        objExamGrpNew.Exam_Date__c = system.today().addDays(15);
        objExamGrpNew.Registration_Start_Date__c = system.today().addDays(5);
        objExamGrpNew.Last_Date_For_Early_Registration__c = system.today().addDays(3);
        objExamGrpNew.Last_Date_For_Standard_Registration__c = system.today().addDays(11) ;
        objExamGrpNew.Last_Date_For_Late_Registration__c = system.today().addDays(12) ;
        examGrpList.add(objExamGrpNew);
        
        insert examGrpList;
        Date examDate = date.newInstance(2021,01,16);
        List<Exam__c> examList = new List<Exam__c>();
        examFRM1 = new Exam__c(Exam_Group__c = objExamGrp.id,Exam_Date__c = examDate,exam__c = 'FRM Part 1');
        examList.add(examFRM1);
        examFRM2 = new Exam__c(Exam_Group__c = objExamGrp.id,Exam_Date__c = examDate,exam__c = 'FRM Part 2');
        examList.add(examFRM2);
        examERP1 = new Exam__c(Exam_Group__c = objExamGrp.id,Exam_Date__c = examDate,exam__c = 'ERP Exam Part I');
        examList.add(examERP1);
        examERP2 = new Exam__c(Exam_Group__c = objExamGrp.id,Exam_Date__c = examDate,exam__c = 'ERP Exam Part II');
        examList.add(examERP2);
        insert examList;
        
        List<Exam_Administration__c> examAdminList = new List<Exam_Administration__c>();
        examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = objExamGrp.id;
        examAdmin.Exam_Date__c = system.today();
        examAdminList.add(examAdmin);
        
        examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = objExamGrpNew.id;
        examAdmin2.Exam_Date__c = system.today().addDays(30);
        examAdminList.add(examAdmin2);
        insert examAdminList;
        
        List<Exam_Part__c> examPartList = new List<Exam_Part__c>();
        examPart = new Exam_Part__c(Exam__c = examFRM1.id,Exam_Administration__c = examAdmin.id,
                                    Exam_End_Date__c=System.today()+30,Exam_Start_Date__c=System.today(),Exam_Date__c = null,Delivery_Method__c = 'CBT',ATA_Batch_Code__c = '123456');
        examPartList.add(examPart);
        examPart2 = new Exam_Part__c(Exam__c = examFRM2.id,Exam_Administration__c = examAdmin2.id,
                                     Exam_Date__c = system.today().adddays(30),Delivery_Method__c = 'CBT',ATA_Batch_Code__c = '234567');
        examPartList.add(examPart2);
        examPartERP1 = new Exam_Part__c(Exam__c = examERP1.id,Exam_Administration__c = examAdmin.id,
                                        Exam_Date__c = system.today().adddays(30),Delivery_Method__c = 'CBT', ATA_Batch_Code__c = '345678');
        examPartList.add(examPartERP1);
        examPartERP2 = new Exam_Part__c(Exam__c = examERP2.id,Exam_Administration__c = examAdmin2.id,
                                        Exam_Date__c = system.today().adddays(30),Delivery_Method__c = 'CBT', ATA_Batch_Code__c = '456789');
        examPartList.add(examPartERP2);
        insert examPartList;
        
        List<Exam_Sites__c> siteList = new List<Exam_Sites__c>();
        exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM1.id);
        siteList.add(exmSite);
        exmSite2 = new Exam_Sites__c(Site__c = site.id,exam__c = examFRM2.id);
        siteList.add(exmSite2);
        exmSite3 = new Exam_Sites__c(Site__c = site.id,exam__c = examERP1.id);
        siteList.add(exmSite3);
        exmSite4 = new Exam_Sites__c(Site__c = site.id,exam__c = examERP2.id);
        siteList.add(exmSite4);
        insert siteList; 
        
        venue = new venue__c(site__c = site.id,active__c = true);
        insert venue;
        
        room = new room__c (Venue__c  = venue.id,Capacity__c = 100,Active__c = true);
        insert room;
    }
    static testMethod void	testPSIRegistration(){
        testData();
        test.startTest();
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,
                                                      Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt);
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin2.Id,
                                                       Exam_Part__c = examPart2.Id, Exam_Site__c = exmSite2.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt2);
        Exam_Attempt__c attempt3 = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,
                                                       Exam_Part__c = examPartERP1.Id, Exam_Site__c = exmSite3.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt3);
        Exam_Attempt__c attempt4 = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin2.Id,
                                                       Exam_Part__c = examPartERP1.Id, Exam_Site__c = exmSite4.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt4);
        insert examAttemptList;
        ATAPSIUtilClass.examRegistrationTriggerRecursion = false;
        attempt.Integration_Type__c = 'Update Eligibility Lifecycle';
        attempt2.Integration_Type__c = 'Cancel Eligibility Lifecycle';
        attempt3.Integration_Type__c = 'Eligibility Lifecycle';
        attempt4.Exam_Part__c = examPartERP2.id;
        update examAttemptList;
        test.stopTest();
    }
    
    static testMethod void	testATARegistration(){
        testData();
        site.ATA_region_code__c = '012345';
        site.ATA_region_name__c = 'US,New Jersey';
        update site;
        
        test.startTest();
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        Integration_Data__c intd = new Integration_Data__c();
        intd.Email__c = contact.Email;
        intd.First_Name__c = contact.FirstName;
        intd.Last_Name__c = contact.LastName;
        insert intd;
        Exam_Attempt__c attempt = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false,ATA_Cert_id__c = 'Test',ATA_Cert_Type__c = 'Test Type',ATA_Name_as_it_appears_on_ID__c = 'Test User' );
        examAttemptList.add(attempt);
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin2.Id,Exam_Part__c = examPart2.Id, Exam_Site__c = exmSite2.id,Member__c = contact.id,cancelled__c = false,ATA_Cert_id__c = 'Test',ATA_Cert_Type__c = 'Test Type',ATA_Name_as_it_appears_on_ID__c = 'Test User' );
        examAttemptList.add(attempt2);
        Exam_Attempt__c attempt3 = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPartERP1.Id, Exam_Site__c = exmSite3.id,Member__c = contact.id,cancelled__c = false,ATA_Cert_id__c = 'Test',ATA_Cert_Type__c = 'Test Type',ATA_Name_as_it_appears_on_ID__c = 'Test User' );
        examAttemptList.add(attempt3);
        Exam_Attempt__c attempt4 = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin2.Id,Exam_Part__c = examPartERP1.Id, Exam_Site__c = exmSite4.id,Member__c = contact.id,cancelled__c = false,ATA_Cert_id__c = 'Test',ATA_Cert_Type__c = 'Test Type',ATA_Name_as_it_appears_on_ID__c = 'Test User' );
        examAttemptList.add(attempt4);
        insert examAttemptList;
        
        ATAPSIUtilClass.examRegistrationTriggerRecursion = false;
        attempt.Integration_Type__c = 'Update Import Registration New';
        attempt2.Integration_Type__c = 'Delete Registration';
        attempt2.Active_Integration_Data__c = intd.id;
        attempt2.Cancelled__c = true;
        attempt2.Defered__c = 'Pending';
        attempt3.Integration_Type__c = 'Import Registration New';
        attempt4.Exam_Part__c = examPartERP2.id;
        update examAttemptList;
        
        test.stopTest();
    }
    static testMethod void	testExamSiteChange(){
        testData();
        site.ATA_region_code__c = '012345';
        site.ATA_region_name__c = 'US,New Jersey';
        update site;
        
        Integration_Data__c intd = new Integration_Data__c();
        intd.Email__c = contact.Email;
        intd.First_Name__c = contact.FirstName;
        intd.Last_Name__c = contact.LastName;
        insert intd;
        
        test.startTest();
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,
                                                      Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false );
        
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt);
        examAttemptList.add(attempt2);
        insert examAttemptList;
        
        ATAPSIUtilClass.examRegistrationTriggerRecursion = false;
        attempt.Exam_Site__c = exmSite2.Id;
        attempt.Active_Integration_Data__c = intd.id;
        update attempt;
        
        site.ATA_region_code__c = '';
        site.ATA_region_name__c = '';
        update site; 
        
        attempt2.Integration_Type__c = 'Delete Registration';
        attempt2.Active_Integration_Data__c = intd.id;
        attempt2.Cancelled__c = true;
        attempt2.Defered__c = 'Pending';
        update attempt2;
        attempt.Exam_Part__c = examPart.Id;
        update attempt;
        test.stopTest();
    }
    
    static testMethod void testRateOffering(){
        
        testData();
        test.startTest();
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false);
        examAttemptList.add(attempt);
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin2.Id,Exam_Part__c = examPartERP1.Id, Exam_Site__c = exmSite3.id,Member__c = contact.id,cancelled__c = false);
        examAttemptList.add(attempt2);
        insert examAttemptList;
        ExamRegistrationHandlerClass.isCreateRateRecursive  = false;
        attempt.result__c = 'Fail';
        attempt2.result__c = 'Pass';
        update examAttemptList;
        test.stopTest();
    }
    
    static testMethod void	testRemaining(){
        testData();
        
        Integration_Data__c intd = new Integration_Data__c();
        intd.Email__c = contact.Email;
        intd.First_Name__c = contact.FirstName;
        intd.Last_Name__c = contact.LastName;
        insert intd;
        
        test.startTest();
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, 
                                                      Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false,Defered__c = 'Pending' );
        examAttemptList.add(attempt);
        
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, 
                                                       Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false);
        examAttemptList.add(attempt1);
        
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin2.Id,Exam_Part__c = examPart2.Id, 
                                                       Exam_Site__c = exmSite2.id,Member__c = contact.id,Active_Integration_Data__c=null,cancelled__c = false,ATA_Cert_id__c = 'Test',ATA_Cert_Type__c = 'Test Type',ATA_Name_as_it_appears_on_ID__c = 'Test User');
        examAttemptList.add(attempt2);
        Exam_Attempt__c attempt3 = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPartERP1.Id,
                                                       Exam_Site__c = exmSite3.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt3);
        Exam_Attempt__c attempt4 = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin2.Id,Exam_Part__c = examPartERP1.Id,
                                                       Exam_Site__c = exmSite4.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt4);
        insert examAttemptList;
        
        
        
        ATAPSIUtilClass.examRegistrationTriggerRecursion = false;
        attempt.Exam_Site__c = exmSite2.Id;
        attempt.Active_Integration_Data__c = intd.id;
        attempt.Defered__c = 'Approved';
        
        //update attempt;
        
        site.ATA_region_code__c = '';
        site.ATA_region_name__c = '';
        update site; 
        
        attempt1.Exam_Part__c = examPartERP1.Id;
        
        attempt2.Active_Integration_Data__c = intd.id;
        attempt2.Cancelled__c = true;
        attempt2.Defered__c = 'Pending';
        //update attempt2;
        attempt2.ATA_Name_as_it_appears_on_ID__c ='Test';
        
        //attempt.Integration_Type__c = 'Update Eligibility Lifecycle';
        //attempt2.Integration_Type__c = 'Cancel Eligibility Lifecycle';
        //attempt3.Integration_Type__c = 'Eligibility Lifecycle';
        attempt4.Exam_Part__c = examPartERP2.id;
        
        attempt2.Exam_Part__c= examPartERP2.id;
        
        update examAttemptList;
        
        test.stopTest();
    }
    static testMethod void	testRemaining1(){
        testData();
        site.ATA_region_code__c = '';
        site.ATA_region_name__c = '';
        update site;
        Integration_Data__c intd = new Integration_Data__c();
        intd.Email__c = contact.Email;
        intd.First_Name__c = contact.FirstName;
        intd.Last_Name__c = contact.LastName;
        insert intd;
        
        test.startTest();
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        List<Exam_Attempt__c> examAttemptList1 = new List<Exam_Attempt__c>();
        Exam_Attempt__c attempt = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, 
                                                      Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false,Defered__c = 'Pending',ATA_Cert_id__c = 'Test',ATA_Cert_Type__c = 'Test Type',ATA_Name_as_it_appears_on_ID__c = 'Test User');
        examAttemptList.add(attempt);
        
        Exam_Attempt__c attempt1 = new Exam_Attempt__c(Outbound_Type__c = 'ATA',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, 
                                                       Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt1);
        
        Exam_Attempt__c attempt2 = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin2.Id,Exam_Part__c = examPart2.Id, 
                                                       Exam_Site__c = exmSite2.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt2);
        Exam_Attempt__c attempt3 = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPartERP1.Id,
                                                       Exam_Site__c = exmSite3.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt3);
        Exam_Attempt__c attempt4 = new Exam_Attempt__c(Outbound_Type__c = 'PSI',Opportunity__c = opp.id,Exam_Administration__c = examAdmin2.Id,Exam_Part__c = examPartERP1.Id,
                                                       Exam_Site__c = exmSite4.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt4);
        insert examAttemptList;
        
        
        site.ATA_region_code__c = '012345';
        site.ATA_region_name__c = 'US,New Jersey';
        update site;
        ATAPSIUtilClass.examRegistrationTriggerRecursion = false;
        attempt.Exam_Site__c = exmSite2.Id; 
        attempt.Active_Integration_Data__c = intd.id;
        attempt.Defered__c = 'Approved';
        attempt.ATA_Name_as_it_appears_on_ID__c ='Test';
        
        attempt1.Exam_Part__c = examPartERP1.Id;
        
        attempt2.Active_Integration_Data__c = intd.id;
        attempt2.Cancelled__c = true;
        attempt2.Defered__c = 'Pending';
        //update attempt2;
        
        
        //attempt.Integration_Type__c = 'Update Eligibility Lifecycle';
        //attempt2.Integration_Type__c = 'Cancel Eligibility Lifecycle';
        //attempt3.Integration_Type__c = 'Eligibility Lifecycle';
        Map<Id,Exam_Attempt__c> oldMap=new Map<Id,Exam_Attempt__c>();
        attempt4.Exam_Part__c = examPartERP2.id;
        attempt3.Active_Integration_Data__c = intd.id;
        attempt3.Outbound_Type__c = 'ATA';
        attempt3.Defered__c = 'Pending';
        attempt3.Exam_Part__c= examPartERP2.id;
        examAttemptList1.add(attempt);
        oldMap.put(attempt.id,attempt);
        examAttemptList1.add(attempt1);
        oldMap.put(attempt1.id,attempt1);
        examAttemptList1.add(attempt2);
        oldMap.put(attempt2.id,attempt2);
        examAttemptList1.add(attempt3);
        oldMap.put(attempt3.id,attempt3);
        examAttemptList1.add(attempt4);
        oldMap.put(attempt4.id,attempt4);
        update examAttemptList1;
        ExamRegistrationHandlerClass.createRateOffering(examAttemptList1,oldMap);
        test.stopTest();
    }
}