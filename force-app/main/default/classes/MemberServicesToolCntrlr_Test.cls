@isTest
public class MemberServicesToolCntrlr_Test {
	static Account acc;
    static Contact contact;
    static Opportunity opp;
    static PriceBook2 pb;
    static Exam_Group__c objExamGrp;
    static Exam_Group__c objExamGrpNew;
    static Exam_Attempt__c attempt;
    static Exam_Attempt__c attempt2;
    static Exam__c exam;
    static Exam__c exam2;
    static Exam_Sites__c exmSite;
    static Exam_Sites__c exmSite2;
    static Site__c site;
    static venue__c venue;
    static room__c room;
    static Exam_Administration__c examAdmin;
    static Exam_Administration__c examAdmin2;
    static Exam_Part__c examPart;
    static Exam_Part__c examPart2;
        
    static void testData(string contEmail){ 
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        Acc = new Account(Name = 'test');
        insert acc;
        
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        contact = new Contact(lastname = 'Test',AccountId = acc.id,email=contEmail,KPI_ERP_Enrollment_Date__c = Date.newInstance(2021, 2, 17));
        insert contact;
        
        pb = new PriceBook2();
        pb.Id = Test.getStandardPricebookId();
        pb.IsActive = true;
        
        update pb;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prd = new Product2();
        prd.Name = 'FRM1';
        prd.ProductCode = 'FRM1';
        prd.GL_Code__c = '4020';
        prd.IsActive = true;
        prd.Company__c = 'GARP';
        prodList.add(prd);
        
        Product2 prd2 = new Product2();
        prd2.Name = 'ERP';
        prd2.ProductCode = 'ENC';
        prd2.GL_Code__c = '4020';
        prd2.IsActive = true;
        prd2.Company__c = 'GARP';
        prodList.add(prd2);
        
        insert prodList;
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.IsActive = true;
        pbe.UnitPrice = 150;
        pbe.PriceBook2Id = pb.Id;
        pbe.Product2Id = prodList[0].id;
        pbeList.add(pbe);
        
        PriceBookEntry pbe2 = new PriceBookEntry();
        pbe2.IsActive = true;
        pbe2.UnitPrice = 150;
        pbe2.PriceBook2Id = pb.Id;
        pbe2.Product2Id = prodList[1].id;
        pbeList.add(pbe2);
        
        insert pbeList;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.UnitPrice = pbe.UnitPrice;
        oli.Quantity = 1;
        oli.PricebookEntryId = pbe.id;
        oli.OpportunityId = opp.id;
        oli.Description = 'Test';
        insert oli;
        
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(Opportunity__c = opp.id);
        insert order; 
        
        ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
        trans.Opportunity__c = opp.Id;
        trans.ChargentOrders__Amount__c = 150;
        trans.ChargentOrders__Order__c = order.id;
        trans.ChargentOrders__Response_Message__c = 'Approved';
        trans.ChargentOrders__Response_Status__c = 'Approved';
        trans.ChargentOrders__Type__c = 'Charge';
        trans.ChargentOrders__Gateway_Date__c =system.now();
        insert trans;
        
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
        
        List<Exam__c> examList = new List<Exam__c>();
        exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1';
        examList.add(exam);
        
        exam2 = new Exam__c();
        exam2.Exam_Group__c = objExamGrp.id;
        exam2.Exam_Date__c = system.today() + 30;
        exam2.exam__c = 'FRM Part 2'; 
        examList.add(exam2);
        insert examList;
        
        List<Exam_Administration__c> examAdminList = new List<Exam_Administration__c>();
        examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = objExamGrp.id;
        examAdmin.Exam_Date__c = system.today();
        examAdmin.Exam_Type__c = 'FRM';
        examAdminList.add(examAdmin);
        
        examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = objExamGrp.id;
        examAdmin2.Exam_Date__c = system.today().addDays(30);
        examAdmin2.Exam_Type__c = 'FRM';
        examAdminList.add(examAdmin2);
        insert examAdminList;
        
        examPart = new Exam_Part__c();
        examPart.Exam__c = exam.id;
        examPart.Exam_Administration__c = examAdmin.id;
        examPart.Exam_Date__c = system.today();
        examPart.Delivery_Method__c = 'CBT';
        insert examPart;
        
        examPart2 = new Exam_Part__c();
        examPart2.Exam__c = exam2.id;
        examPart2.Exam_Administration__c = examAdmin2.id;
        examPart.Exam_Date__c = system.today().adddays(30);
        examPart2.Delivery_Method__c = 'CBT';
        insert examPart2;
        
        List<Exam_Sites__c> siteList = new List<Exam_Sites__c>();
        exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id,exam_part__c = examPart.id);
        siteList.add(exmSite);
        exmSite2 = new Exam_Sites__c(Site__c = site.id,exam__c = exam2.id,exam_part__c = examPart2.id);
        siteList.add(exmSite2);
        insert siteList; 
        
        venue = new venue__c(site__c = site.id,active__c = true);
        insert venue;
        
        room = new room__c (Venue__c  = venue.id,Capacity__c = 100,Active__c = true);
        insert room;
        //ATAPSIUtilClass.examRegistrationTriggerRecursion = true;
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();
        attempt = new Exam_Attempt__c(Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false );
        examAttemptList.add(attempt);
        
        attempt2 = new Exam_Attempt__c(Opportunity__c = opp.id,Exam_Administration__c = examAdmin.Id,Exam_Part__c = examPart.Id, Exam_Site__c = exmSite2.id,Member__c = contact.id,cancelled__c = false,Result__c = 'No-Show' );
        examAttemptList.add(attempt2);
        insert examAttemptList;
        
    }
    static testMethod void testMethods(){
        testData('test@test.com.garp.test.ms21188809');
        string garpId = [Select Id,GARP_Member_ID__c from Contact Limit 1].GARP_Member_ID__c;
        test.startTest();
        List<Exam_Attempt__c> registrationList = MemberServicesTool_Controller.getRegistrations(garpId);
        List<Exam_Group__c> groupList = MemberServicesTool_Controller.getExamGroups(registrationList);
        MemberServicesTool_Controller.getExamAdministrations(groupList[0].Id, registrationList);
        test.stopTest();
    }
    
    static testMethod void testExamSites(){
        testData('test@test.com.garp.test.ms21112277');
        test.startTest();
        String AdminId = [Select Id from Exam_Administration__c Limit 1].Id;
        List<Exam_Sites__c> siteList = MemberServicesTool_Controller.getExamSites(AdminId,new List<String>{'FRM Part 1'},'Part 1');
        List<Exam_Sites__c> siteList2 = MemberServicesTool_Controller.getExamSites(AdminId,new List<String>{'FRM Part 2'},'Part 2');
        List<Exam_Sites__c> siteList3 = MemberServicesTool_Controller.getExamSites(AdminId,new List<String>{'SCR'},'Part 1');
        test.stopTest();
    }
    
    static testMethod void testSaveData(){
        testData('test@test.com.garp.test.ms21234');
        test.startTest();
        string garpId = [Select Id,GARP_Member_ID__c from Contact where email='test@test.com.garp.test.ms21234' Limit 1].GARP_Member_ID__c;
        Set<String> examParts = new Set<String>{'FRM Part 1','FRM Part 2','SCR'};
        List<Exam_Attempt__c> registrationList = [Select Id,Name,Section__c,Exam_Date__c,Exam_Site__c,Exam_Administration__c,
                       			Exam_Administration__r.Name,Exam_Site__r.Name,Exam_Part__c,
                       		    Exam_Administration__r.Exam_Group__c,Exam_Administration__r.Exam_Group__r.Next_Exam_Group__c,
                       			Exam_Administration__r.Exam_Group__r.Active__c,Exam_Administration__r.Exam_Group__r.SCR_Active__c
                       			from Exam_Attempt__c 
                       			where Garp_Id__c =: garpId
                       			AND Section__c IN: examParts
                       			AND Cancelled__c = False
                       			AND Opportunity_StageName__c ='closed'
                       			AND Result__c =null];
        List<Exam_Administration__c> admins = [Select Id,Exam_Group__c,Exam_Type__c from Exam_Administration__c];
        List<Exam_Sites__c> sites = [Select Id from Exam_Sites__c];
        List<Exam_Part__c> parts = [Select Id from Exam_Part__c];
        MemberServicesTool_Controller.requestWrapper request = new MemberServicesTool_Controller.requestWrapper();
        request.changeType = 'Defer';
        request.freeDeferral = 'Yes';
        request.garpId = garpId;
        request.movingToActiveGroup = true;
        request.part1Administration = admins[1].id;
        request.part1ExamSite = sites[0].id;
        request.part2Administration = admins[1].id;
        request.part2ExamSite = sites[1].id;
        request.part1ExamPart = parts[0].id;
        request.part2ExamPart = parts[1].id;
        request.registrations = registrationList;
        request.subtype = 'Deferral - Free';
        MemberServicesTool_Controller.saveData(JSON.serialize(request));
        
        Exam_Registration_Modification__c modification = new Exam_Registration_Modification__c();
        modification.Part_I_Exam_Registration__c = attempt.id;
        modification.Part_I_Exam_Admin_From__c = examAdmin.id;
        modification.Part_I_Exam_Admin_To__c = examAdmin2.id;
        modification.Part_I_Exam_Group_From__c = objExamGrp.Id;
        modification.Part_I_Exam_Group_To__c = objExamGrpNew.Id;
        modification.Part_I_Exam_Part_From__c = examPart.Id;
        modification.Part_I_Exam_Part_To__c = examPart2.Id;
        modification.Part_I_Exam_Site_From__c = exmSite.id;
        modification.Part_I_Exam_Site_To__c = exmSIte2.id;
        modification.Part_II_Exam_Registration__c = attempt2.id;
        modification.Part_II_Exam_Admin_To__c = examAdmin.id;
        modification.Part_II_Exam_Admin_From__c = examAdmin2.id;
        modification.Part_II_Exam_Group_To__c = objExamGrp.Id;
        modification.Part_II_Exam_Group_From__c = objExamGrpNew.Id;
        modification.Part_II_Exam_Part_To__c = examPart.Id;
        modification.Part_II_Exam_Part_From__c = examPart2.Id;
        modification.Part_II_Exam_Site_To__c = exmSite.id;
        modification.Part_II_Exam_Site_From__c = exmSIte2.id;
        modification.Status__c = 'Pending Bulk Modification';
        
        insert modification;
        
        opp.Exam_Registration_Modification__c = modification.Id;
        update opp;
        
        MemberServicesTool_Controller.processRegistrations(new Set<Id>{modification.id},true,true);
        test.stopTest();
    }
    
    static testMethod void testSaveData2(){
        testData('test@test.com.garp.test.ms21567');
        test.startTest();
        string garpId = [Select Id,GARP_Member_ID__c from Contact where email='test@test.com.garp.test.ms21567' Limit 1].GARP_Member_ID__c;
        Set<String> examParts = new Set<String>{'FRM Part 1','FRM Part 2','SCR'};
        List<Exam_Attempt__c> registrationList = [Select Id,Name,Section__c,Exam_Date__c,Exam_Site__c,Exam_Administration__c,
                       			Exam_Administration__r.Name,Exam_Site__r.Name,Exam_Part__c,
                       		    Exam_Administration__r.Exam_Group__c,Exam_Administration__r.Exam_Group__r.Next_Exam_Group__c,
                       			Exam_Administration__r.Exam_Group__r.Active__c,Exam_Administration__r.Exam_Group__r.SCR_Active__c
                       			from Exam_Attempt__c 
                       			where Garp_Id__c =: garpId
                       			AND Section__c IN: examParts
                       			AND Cancelled__c = False
                       			AND Opportunity_StageName__c ='closed'
                       			AND Result__c =null];
        List<Exam_Administration__c> admins = [Select Id,Exam_Group__c,Exam_Type__c from Exam_Administration__c];
        List<Exam_Sites__c> sites = [Select Id from Exam_Sites__c];
        MemberServicesTool_Controller.requestWrapper request = new MemberServicesTool_Controller.requestWrapper();
        request.changeType = 'Defer';
        request.freeDeferral = 'Yes';
        request.garpId = garpId;
        request.movingToActiveGroup = true;
        request.part1Administration = admins[1].id;
        request.part1ExamSite = sites[0].id;
        request.registrations = registrationList;
        MemberServicesTool_Controller.saveData(JSON.serialize(request));
        
        Exam_Registration_Modification__c modification = new Exam_Registration_Modification__c();
        modification.Part_I_Exam_Registration__c = attempt.id;
        modification.Part_I_Exam_Admin_From__c = examAdmin.id;
        modification.Part_I_Exam_Admin_To__c = examAdmin2.id;
        modification.Part_I_Exam_Group_From__c = objExamGrp.Id;
        modification.Part_I_Exam_Group_To__c = objExamGrpNew.Id;
        modification.Part_I_Exam_Part_From__c = examPart.Id;
        modification.Part_I_Exam_Part_To__c = examPart2.Id;
        modification.Part_I_Exam_Site_From__c = exmSite.id;
        modification.Part_I_Exam_Site_To__c = exmSIte2.id;
        modification.Status__c = 'Pending Bulk Modification';
        
        insert modification;
        
        opp.Exam_Registration_Modification__c = modification.Id;
        update opp;
        
        MemberServicesTool_Controller.processRegistrations(new Set<Id>{modification.id},true,true);
        test.stopTest();
    }
}