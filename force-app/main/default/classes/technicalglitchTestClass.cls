@isTest
public class technicalglitchTestClass {

    public static Exam_Group__c nextExamGroup ;
    public static Exam_Group__c examGroup ;
    public static Contact contact ;
    public static Account account ;
    public static Site__c testSiteNonChina ;
    public static Opportunity opportunity;
    public static Exam_Attempt__c examRegistration1;
    public static List<Exam_Administration__c> lstExamAdmins ;
    public static Exam_Administration__c examAdmin;
    public static Exam_Administration__c examAdmin1;
    public static Exam_Administration__c examAdmin2;
    public static Exam_Administration__c examAdmin3;
    public static List<Exam__c> lstExams ;
    public static Exam__c scr;
    public static Exam__c frm1;
    public static Exam__c frm2;
    public static List<Exam_Part__c> lstExamParts ;
    public static Exam_Part__c exampart; 
    public static Exam_Part__c exampart1;
    public static Exam_Part__c exampart2;
    public static Exam_Part__c exampart3;
    public static List<Exam_Sites__c> lstExamSites ;
    public static Exam_Sites__c examSiteNonChinaExamPart1 ;
    public static Exam_Sites__c examSiteNonChinaExamPart2 ;
    public static Exam_Sites__c examSiteNonChinaExamPart3 ;
    public static String garpId;
    
    @testSetup
    public static void setup(){
        Exam_Attempt__c examReg1 = new Exam_Attempt__c();
        
        account = new Account();
        account.Name = 'TEST CO';
        account.GARP_ID__c  = '101010';
        INSERT account;
        
        contact = new Contact();
        contact.Email = 'TEST@TEST.com';
        contact.FirstName = 'TEST';
        contact.LastName = 'TEST';
        contact.GARP_Member_ID__c = '101010';
        contact.AccountId = account.Id;
        INSERT contact;
        garpId = contact.GARP_Member_ID__c;
        
        nextExamGroup = new Exam_Group__c();
        nextExamGroup.Name = '21-Nov';
        nextExamGroup.Active__c = false;
        nextExamGroup.Registration_Start_Date__c = Date.today().addDays(20);
        nextExamGroup.Exam_Change_Start_Date_Time__c= DateTime.now().addDays(30);
        INSERT nextExamGroup;
        
        examGroup = new Exam_Group__c();
        examGroup.Name = '21-May';
        examGroup.Active__c = true;
        examGroup.Exam_Date__c = Date.today().addDays(-5);
        examGroup.Next_Exam_Group__c = nextExamGroup.id;
        examGroup.Exam_Ticket_Available_Date__c = Date.today().addDays(10);
        examGroup.Exam_Results_Available_Date__c = Date.today().addDays(10);
        examGroup.Exam_Change_Start_Date_Time__c= DateTime.now().addDays(15);
        INSERT examGroup;
        
        testSiteNonChina = new Site__c();
        testSiteNonChina.Name = 'Canada, Surrey';
        testSiteNonChina.Active__c = true;
        testSiteNonChina.Display_Address__c = 'Canada, Surrey';
        testSiteNonChina.Is_OSTA_Information_Required__c = false;
        INSERT testSiteNonChina;
        
        opportunity = new Opportunity();
        opportunity.Amount = 700.00;
        opportunity.Name = 'TEST';
        opportunity.StageName = 'Closed';
        opportunity.CloseDate = Date.today();
        Insert opportunity;
        
        lstExams = new List<Exam__c>();
        scr = new Exam__c();
        scr.Name = 'scr Exam';
        scr.Exam_Group__c = examGroup.Id;
        scr.Exam__c = 'SCR';
        scr.Exam_Date__c = Date.today().addDays(10); 
        lstExams.add(scr);
        
        frm1 = new Exam__c();
        frm1.Name = 'FRM Part 1 Exam';
        frm1.Exam_Group__c = examGroup.Id;
        frm1.Exam__c = 'FRM Part 1';
        frm1.Exam_Date__c = Date.today().addDays(10); 
        lstExams.add(frm1);
        
        frm2 = new Exam__c();
        frm2.Name = 'FRM Part 2 Exam';
        frm2.Exam_Group__c = examGroup.Id;
        frm2.Exam__c = 'FRM Part 2';
        frm2.Exam_Date__c = Date.today().addDays(10); 
        lstExams.add(frm2);
        INSERT lstExams; 
        
        lstExamAdmins = new List<Exam_Administration__c>();
        examAdmin = new Exam_Administration__c();
        examAdmin.Exam_Group__c = examGroup.id;
        examAdmin.Exam_Date__c = system.today();
        examAdmin.Exam_Type__c = 'SCR' ;
        examAdmin.Exam_Results_Release_Date__c = DateTime.now().addDays(90);   
        lstExamAdmins.add(examAdmin);
        
        examAdmin1 = new Exam_Administration__c();
        examAdmin1.Exam_Group__c = nextExamGroup.id;
        examAdmin1.name = 'SCR exam';
        examAdmin1.Exam_Date__c = system.today();
        examAdmin1.Exam_Type__c = 'SCR' ;
        examAdmin1.Exam_Results_Release_Date__c = DateTime.now().addDays(90);   
        lstExamAdmins.add(examAdmin1);
        
        examAdmin2 = new Exam_Administration__c();
        examAdmin2.Exam_Group__c = nextExamGroup.id;
        examAdmin2.name = 'Nov exam';
        examAdmin2.Exam_Date__c = system.today()-15;
        examAdmin2.Exam_Type__c = 'FRM' ;
        examAdmin2.Exam_Results_Release_Date__c = DateTime.now().addDays(90);   
        lstExamAdmins.add(examAdmin2);
        
        examAdmin3 = new Exam_Administration__c();
        examAdmin3.Exam_Group__c = nextExamGroup.id;
        examAdmin3.name = 'Dec exam';
        examAdmin3.Exam_Date__c = system.today();
        examAdmin3.Exam_Type__c = 'FRM' ;
        //examAdmin3.Exam_Results_Release_Date__c = Date.today().addDays(120);   
        lstExamAdmins.add(examAdmin3);
        insert lstExamAdmins;
        
        lstExamParts = new List<Exam_Part__c>();
        exampart = new Exam_Part__c();
        exampart.Exam__c = scr.Id;
        exampart.Exam_Administration__c = examAdmin1.Id ;
        exampart.Delivery_Method__c = 'CBT';
        exampart.Exam_Start_Date__c = Date.today();
        exampart.Exam_End_Date__c = Date.today().addDays(10);
        lstExamParts.add(exampart);
        
        exampart1 = new Exam_Part__c();
        exampart1.Exam__c = frm1.Id;
        exampart1.Exam_Administration__c = examAdmin2.Id ;
        exampart1.Delivery_Method__c = 'CBT';
        exampart1.Exam_Start_Date__c = Date.today();
        exampart1.Exam_End_Date__c = Date.today().addDays(10);
        lstExamParts.add(exampart1);
        
        exampart2 = new Exam_Part__c();
        exampart2.Exam__c = frm2.Id;
        exampart2.Exam_Administration__c = examAdmin3.Id ;
        exampart2.Delivery_Method__c = 'CBT';
        exampart2.Exam_Start_Date__c = Date.today();
        exampart2.Exam_End_Date__c = Date.today().addDays(10);
        lstExamParts.add(exampart2);
        insert lstExamParts;
        
        lstExamSites = new List<Exam_Sites__c> ();
        examSiteNonChinaExamPart1 = new Exam_Sites__c();
        examSiteNonChinaExamPart1.Name = 'SCR Canada';
        examSiteNonChinaExamPart1.Site__c = testSiteNonChina.Id;
        examSiteNonChinaExamPart1.Exam__c = scr.Id;
        examSiteNonChinaExamPart1.Exam_Part__c = exampart.id;
        lstExamSites.add(examSiteNonChinaExamPart1);
        
        examSiteNonChinaExamPart2 = new Exam_Sites__c();
        examSiteNonChinaExamPart2.Name = 'Frm Canada';
        examSiteNonChinaExamPart2.Site__c = testSiteNonChina.Id;
        examSiteNonChinaExamPart2.Exam__c = frm1.Id;
        examSiteNonChinaExamPart2.Exam_Part__c = exampart1.id;
        lstExamSites.add(examSiteNonChinaExamPart2);
        
        examSiteNonChinaExamPart3 = new Exam_Sites__c();
        examSiteNonChinaExamPart3.Name = 'Frm Canada';
        examSiteNonChinaExamPart3.Site__c = testSiteNonChina.Id;
        examSiteNonChinaExamPart3.Exam__c = frm2.Id;
        examSiteNonChinaExamPart3.Exam_Part__c = exampart2.id;
        lstExamSites.add(examSiteNonChinaExamPart3);
        INSERT lstExamSites;
        
        examRegistration1 = new Exam_Attempt__c();
        examRegistration1.Member__c = contact.Id;
        examRegistration1.Opportunity__c = opportunity.Id;
        examRegistration1.Exam_Site__c = examSiteNonChinaExamPart1.Id;
        examRegistration1.Exam_Administration__c = examAdmin.id;
        examRegistration1.Exam_Part__c = exampart.id;
        examRegistration1.Cancelled__c = FALSE;
        examRegistration1.Result__c = NULL;
        INSERT examRegistration1;
    }
    
    @istest
    public static void getPicklistValues(){
        Test.startTest();
        technicalglitchClass.getPicklistValues();
        Test.stopTest();
    }
    
    @istest
    public static void getExamRegistrations(){
        Test.startTest();
        system.debug('garpId=======>'+garpId);
        technicalglitchClass.getExamRegistrations(garpId);
        Test.stopTest();
    }
    
    @istest
    public static void getExamAdmins(){
        Test.startTest();
        Map<String,Exam_Attempt__c> examRegs = new Map<String,Exam_Attempt__c>();
        for(Exam_Attempt__c e : [Select id,name, Exam_Name__c,Section__c ,
                                  Exam_Administration__r.Exam_Group__c,Member__c,Exam_Part__r.Exam__r.Exam__c,Exam_Part__c
                                  from Exam_Attempt__c ]){
                                examRegs.put(e.Section__c,e);      
            
        }
        technicalglitchClass.getExamAdmins('SCR',examRegs);
        Test.stopTest();
    }
    
    @istest
    public static void getExamSites(){
        Test.startTest();
        Map<String,String> mapExamAdmins = new Map<String,String>();
        Map <String,String> frm1MapExamAdmins = new Map <String,String> ();
        Map <String,String> frm2MapExamAdmins = new Map <String,String> ();
        Map<String,Exam_Attempt__c> examRegs = new Map<String,Exam_Attempt__c>();
        Map<String,String> mapFrm1ExamSites = new Map<String,String>();
        Map<String,String> mapFrm2ExamSites = new Map<String,String>();
        Map<String,String> mapScrExamSites = new Map<String,String>();
        for(Exam_Attempt__c e : [Select id,name, Exam_Name__c,Section__c ,
                                  Exam_Administration__r.Exam_Group__c,Member__c,Exam_Part__r.Exam__r.Exam__c,Exam_Part__c
                                  from Exam_Attempt__c ]){
                                examRegs.put(e.Section__c,e);      
            
        }
         // Exam_Administration__c ea = [Select id, name from Exam_Administration__c where Exam_Group__c =: nextExamGroup.id];
        for(Exam_Administration__c e: [Select id, name from Exam_Administration__c where name = 'SCR exam']){
            mapExamAdmins.put(e.name, e.id);
        }
        technicalglitchClass.getExamSites('SCR exam', mapExamAdmins, 'SCR');
        for(Exam_Sites__c es : [select id, name from Exam_Sites__c where name = 'SCR Canada']){
            mapScrExamSites.put(es.name,es.id);
        }
         String strExamDetails = '{\"garpId\":\"\",\"selectedExamRegs\":[\"SCR\"], \"examRegs\":'+JSON.serialize(examRegs)+','+
            ' \"SelectedFrm1ExamAdmin\":\"\",\"frm1MapExamAdmins\":'+JSON.serialize(frm1MapExamAdmins)+', \"SelectedFrm2ExamAdmin\":\"\",\"frm2MapExamAdmins\":'+JSON.serialize(frm2MapExamAdmins)+','+
            ' \"SelectedScrExamAdmin\":\"SCR exam\" ,\"scrMapExamAdmins\":'+JSON.serialize(mapExamAdmins)+','+
            '\"examFrm1Sites\":\"\",\"mapFrm1ExamSites\":'+JSON.serialize(mapFrm1ExamSites)+',\"examFrm2Sites\":\"\",\"mapFrm2ExamSites\":'+JSON.serialize(mapFrm2ExamSites)+','+
            '\"examScrSites\":\"SCR Canada\",\"mapScrExamSites\":'+JSON.serialize(mapScrExamSites)+',\"frm1Exists\":false,\"frm2Exists\":false,\"scrExists\":true,'+
            '\"freeDefferalCheck\":\"Yes\",\"oneTimeDeferralCheck\":\"No\"}';
        // system.debug('strExamDetails======>'+strExamDetails);
            technicalglitchClass.getSaveRecord(strExamDetails);
        Approval_Matrix__c a = [Select id, name,Approval_Status__c from Approval_Matrix__c];
        a.Approval_Status__c = 'Approved';
        update a;
        Test.stopTest();
    }
    
    @istest
    public static void getvalidateFrm1Frm2(){
        Test.startTest();
        Map <String,String> frm1MapExamAdmins = new Map <String,String> ();
        Map <String,String> frm2MapExamAdmins = new Map <String,String> ();
        List<String> selectedExamRegs = new List<String>();
        Map<String,Exam_Attempt__c> examRegs = new Map<String,Exam_Attempt__c>();
        for(Exam_Attempt__c e : [Select id,name, Exam_Name__c,Section__c ,
                                  Exam_Administration__r.Exam_Group__c,Member__c,Exam_Part__r.Exam__r.Exam__c,Exam_Part__c
                                  from Exam_Attempt__c ]){
                                examRegs.put(e.Section__c,e);      
            
        }
        for(Exam_Administration__c e: [Select id, name from Exam_Administration__c where name = 'Nov exam']){
            frm1MapExamAdmins.put(e.name,e.id);
        }
        for(Exam_Administration__c e: [Select id, name from Exam_Administration__c where name = 'Dec exam']){
            frm2MapExamAdmins.put(e.name,e.id);
        }
        selectedExamRegs.add('FRM Part 1');
        selectedExamRegs.add('FRM Part 2');
        technicalglitchClass.getvalidateFrm1Frm2('Nov exam',frm1MapExamAdmins,'Dec exam',frm2MapExamAdmins,selectedExamRegs);
        
        String strExamDetails = '{\"garpId\":\"\",\"selectedExamRegs\":[\"SCR\"], \"examRegs\":'+examRegs+','+
            ' \"SelectedFrm1ExamAdmin\":\"\",\"frm1MapExamAdmins\":\"\", \"SelectedFrm2ExamAdmin\":\"\",\"frm2MapExamAdmins\":\"\",'+
            ' \"SelectedScrExamAdmin\":\"\" ,\"scrMapExamAdmins\":\"\",\"examFrm1Sites\":\"\",\"examFrm1Sites\":\"\",'+
            '\"examFrm1Sites\":\"\",\"mapFrm1ExamSites\":\"\",\"examFrm2Sites\":\"\",\"mapFrm2ExamSites\":\"\",'+
            '\"examScrSites\":\"\",\"mapScrExamSites\":\"\",\"frm1Exists\":true,\"frm2Exists\":true,\"scrExists\":false,'+
            '\"freeDefferalCheck\":\"Yes\",\"oneTimeDeferralCheck\":\"No\"}';
        system.debug('strExamDetails======>'+strExamDetails);
       // technicalglitchClass.getSaveRecord(strExamDetails);
        Test.stopTest();
    }
    
    @istest
    public static void getSaveRecord(){
        Test.startTest();
        Map<String,Exam_Attempt__c> examRegs = new Map<String,Exam_Attempt__c>();
        for(Exam_Attempt__c e : [Select id,name, Exam_Name__c,Section__c ,
                                  Exam_Administration__r.Exam_Group__c,Member__c,Exam_Part__r.Exam__r.Exam__c,Exam_Part__c
                                  from Exam_Attempt__c ]){
                                examRegs.put(e.Section__c,e);      
            
        }
         String strExamDetails = '{\"garpId\":\"\",\"selectedExamRegs\":[\"Scr\"], \"examRegs\":'+examRegs+','+
            ' \"SelectedFrm1ExamAdmin\":\"\"}';
        system.debug('strExamDetails======>'+strExamDetails);
        // technicalglitchClass.getSaveRecord(strExamDetails);
        Test.stopTest();
    }
    @istest
    public static void technicalGlitchTrigger(){
    }
    
}