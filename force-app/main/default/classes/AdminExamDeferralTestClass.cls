@isTest
public class AdminExamDeferralTestClass {
    @testSetup
    public static void testSetup(){ 
        
        Account Acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp = new Opportunity(amount = 123,
                                          Name = 'Test',
                                          Eligible_for_Membership_Extension__c = false,
                                          company__c = 'Payment', accountId = acc.id,
                                          stageName = 'New Lead',Program__c = 'Print' ,
                                          closedate = system.today()+ 15);        
        insert opp;
        
        Contact contact = new Contact(lastname = 'Test',
                                      AccountId = acc.id,email='test@test.com',
                                      KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        Site__c site = new Site__c(name = 'test',Display_Address__c = 'test',
                                   active__c = true,Non_selectable__c = false,Site_Code__c = '123');
        insert site; 
        
        Exam_Group__c examGroup = new Exam_Group__c(
            Active__c = TRUE,
            RecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Group__c', 'FRM/ERP'),
            Exam_Date__c = System.today().addDays(60),
            Registration_Start_Date__c = System.today().addDays(-10),
            Last_Date_For_Early_Registration__c = System.today().addDays(10),
            Last_Date_For_Standard_Registration__c = System.today().addDays(20),
            Last_Date_For_Late_Registration__c = System.today().addDays(30)
        );
        INSERT examGroup;
        
        Exam_Registration_Window__c examRegistrationWindow = new Exam_Registration_Window__c(
            Exam_Group__c = examGroup.Id,
            Type__c = 'Early',
            Exam_Registration_Window_Open__c = system.today().addDays(-30), 
            Exam_Registration_Window_Close__c = system.today().addDays(30)        
        );
        INSERT examRegistrationWindow;
        
        //FRM
        Exam__c frmExamPart1 = new Exam__c(
            Exam_Group__c = examGroup.Id,
            Exam_Date__c = System.today().addDays(60),
            Exam__c = 'FRM Part 1',
            Name = 'FRM Exam Part I'
        );
        insert frmExamPart1;
        
        Exam__c frmExamPart2 = new Exam__c(
            Exam_Group__c = examGroup.Id,
            Exam_Date__c = System.today().addDays(60),
            Exam__c = 'FRM Part 2',
            Name = 'FRM Exam Part II'
        );
        insert frmExamPart2;
        
        Exam__c erpExamPart1 = new Exam__c(
            Exam_Group__c = examGroup.Id,
            Exam_Date__c = System.today(),
            Exam__c = 'ERP Exam Part I',
            Name = 'ERP Exam Part I'
        );
        insert erpExamPart1;
        
        Exam__c erpExamPart2 = new Exam__c(
            Exam_Group__c = examGroup.Id,
            Exam_Date__c = System.today().addDays(60),
            Exam__c = 'ERP Exam Part II',
            Name = 'ERP Exam Part II'
        );
        insert erpExamPart2;
        
        Exam_Administration__c examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = examGroup.id;
        examAdmin1.Exam_Date__c = system.today();
        insert examAdmin1;
        
        Exam_Administration__c examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = examGroup.id;
        examAdmin2.Exam_Date__c = system.today()+20;
        insert examAdmin2;
        
        Exam_Part__c examPart = new Exam_Part__c();
        examPart.Exam__c = frmExamPart1.id;
        examPart.Exam_Administration__c = examAdmin1.id;
        examPart.Exam_Date__c = system.today();
        examPart.Delivery_Method__c = 'CBT';
        insert examPart;
        
        Exam_Part__c examPart2 = new Exam_Part__c();
        examPart2.Exam__c = frmExamPart2.id;
        examPart2.Exam_Administration__c = examAdmin2.id;
        examPart2.Exam_Date__c = system.today().adddays(30);
        examPart2.Delivery_Method__c = 'CBT';
        insert examPart2;
        
        Exam_Sites__c exmSite1 = new Exam_Sites__c(Site__c = site.id,exam__c = frmExamPart1.id);
        insert exmSite1;
        Exam_Sites__c exmSite2 = new Exam_Sites__c(Site__c = site.id,exam__c = frmExamPart2.id);
        insert exmSite2;
        Exam_Sites__c exmSite3 = new Exam_Sites__c(Site__c = site.id,exam__c = erpExamPart1.id);
        insert exmSite3;
        Exam_Sites__c exmSite4 = new Exam_Sites__c(Site__c = site.id,exam__c = erpExamPart2.id);
        insert exmSite4;
        
    }
    
    @isTest
    public static void getExamAdminExamList(){
        AdminExamDeferralClass.ExamAdministration adminExamClass = new AdminExamDeferralClass.ExamAdministration();
        Exam_Group__c examGrp = [Select id from Exam_Group__c LIMIT 1];
        AdminExamDeferralClass.getExamAdminExamList(examGrp.id);
    }
    
    @isTest
    public static void getwrapper(){
        AdminExamDeferralClass.getwrapper();
    }
    
    @isTest
    public static void getFromToExamGroupList(){
        AdminExamDeferralClass.getFromToExamGroupList();
    }
    
    @isTest
    public static void getExamAdministrationsList(){
        Exam_Group__c examGrp = [Select id from Exam_Group__c LIMIT 1];
        AdminExamDeferralClass.getExamAdministrationsList(examGrp.id,examGrp.id);
        AdminExamDeferralClass.getExamAdministrationsList(examGrp.id,'');
        AdminExamDeferralClass.getExamAdministrationsList('',examGrp.id);
        AdminExamDeferralClass.getExamAdministrationsList('','');
    }
    
    @isTest
    public static void getExamExamPartList(){
        Exam_Administration__c examAdm = [Select id from Exam_Administration__c LIMIT 1];
        AdminExamDeferralClass.getExamExamPartList(examAdm.id);
    }
    
    @isTest
    public static void getToExamadminList(){
        List<Exam__c> exams = [select id,Exam__c,Exam_Group__c from Exam__c];
        List<String> lstexams = new List<String>();
        for(Exam__c exam :exams){
            lstexams.add(exam.Exam__c);
        }
        Exam_Group__c examGrp = [Select id from Exam_Group__c LIMIT 1];
        AdminExamDeferralClass.getToExamadminList(examGrp.id,examGrp.id,lstexams);
    }
    
    @isTest
    public static void getExamPartSiteList(){
        test.startTest();
        List<Exam__c> exams = [select id,Exam__c,Exam_Group__c from Exam__c];
        List<String> lstexams = new List<String>();
        for(Exam__c exam :exams){
            lstexams.add(exam.Exam__c);
        }
        List<String> lstexamAdmin = new List<String>();
        for(Exam_Administration__c examAdmin : [Select id,Exam_Group__c from Exam_Administration__c]) {
            lstexamAdmin.add(examAdmin.id);
        }
        Exam_Group__c examGrp = [Select id from Exam_Group__c LIMIT 1];
        String strExamGrp = examGrp.id; 
        String strExamAdmin = lstexamAdmin[0];
        AdminExamDeferralClass.getExamPartSiteList(strExamGrp,strExamGrp,lstexams,strExamAdmin,lstexamAdmin,lstexams,'From To Not Empty');
        AdminExamDeferralClass.getExamPartSiteList(strExamGrp,strExamGrp,lstexams,strExamAdmin,lstexamAdmin,lstexams,'From To Empty');
        AdminExamDeferralClass.getExamPartSiteList(strExamGrp,strExamGrp,lstexams,strExamAdmin,lstexamAdmin,lstexams,'From Empty');
        test.stopTest();
    }
    
    @isTest
    public static void saveExamAdmindata(){
        AdminExamDeferralClass.ExamAdministration adminExamClass = new AdminExamDeferralClass.ExamAdministration();
        // Map<String,List<Exam_Sites__c>> siteMap,List<String> examType,Map<String,List<Exam_Sites__c>> allexamsitemap,String examwrap,String FromToAdminData
        // AdminExamDeferralClass.getExamAdminExamList(examGrp.id);
        Map<String,List<Exam_Sites__c>> mapExamSites = new Map<String,List<Exam_Sites__c>>();
        List<Exam_Sites__c> frmExamSites1 = [Select id,Site__c,exam__c,exam__r.Exam__c,Site__r.Site_Code__c,Exam_Sites__c.Name from Exam_Sites__c where exam__r.Exam__c = 'FRM Part 1'];
        mapExamSites.put('FRM Part 1',frmExamSites1);
        List<Exam_Sites__c> frmExamSites2 = [Select id,Site__c,exam__c,exam__r.Exam__c,Site__r.Site_Code__c,Exam_Sites__c.Name from Exam_Sites__c where exam__r.Exam__c = 'FRM Part 2'];
        mapExamSites.put('FRM Part 2',frmExamSites2);
        List<Exam_Sites__c> erpExamSites1 = [Select id,Site__c,exam__c,exam__r.Exam__c,Site__r.Site_Code__c,Exam_Sites__c.Name from Exam_Sites__c where exam__r.Exam__c = 'ERP Exam Part I'];
        mapExamSites.put('ERP Exam Part I',erpExamSites1);
        List<Exam_Sites__c> erpExamSites2 = [Select id,Site__c,exam__c,exam__r.Exam__c,Site__r.Site_Code__c,Exam_Sites__c.Name from Exam_Sites__c where exam__r.Exam__c = 'ERP Exam Part II'];
        mapExamSites.put('ERP Exam Part II',erpExamSites2);
        
        List<Exam__c> exams = [select id,Exam__c,Exam_Group__c from Exam__c];
        List<String> lstexams = new List<String>();
        for(Exam__c exam :exams){
            lstexams.add(exam.Exam__c);
        }
        List<String> lstExamAdmin = new List<String>();
        for(Exam_Administration__c examAdmin : [Select id from Exam_Administration__c]){
            lstExamAdmin.add(examAdmin.id);
        }
        /* let JSONString = {
            'fromgroupId': '',
            'toGroupId':'',
            'selectedGroupFromexam':'',
            'selecetedFromExam':'',
            'selecetedToExam':'',
            'examType':examType,
            'FromToAdminData':''
                }; */
        
        
        Exam_Group__c examGrp = [select id from Exam_Group__c LIMIT 1];
        String strExamGrp = examGrp.id;
        
        AdminExamDeferralClass.ExamAdministration instance = new AdminExamDeferralClass.ExamAdministration();
        instance.FromGroupId = exams[0].Exam_Group__c;
        instance.ToGroupId = exams[0].Exam_Group__c;
        instance.selectedExamType = lstexams;
        instance.ToExamAdminId = lstExamAdmin;
        String myJSON = JSON.serialize(instance);
        
        AdminExamDeferralClass.saveExamAdmindata(mapExamSites,lstexams,mapExamSites,myJSON,'From To Not Empty');
        AdminExamDeferralClass.saveExamAdmindata(mapExamSites,lstexams,mapExamSites,myJSON,'From To Empty');
        AdminExamDeferralClass.saveExamAdmindata(mapExamSites,lstexams,mapExamSites,myJSON,'From Empty');

    }
    
}