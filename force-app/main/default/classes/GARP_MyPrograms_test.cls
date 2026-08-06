@isTest
public class GARP_MyPrograms_test {
    
    Static User user;
    Static Account account;
    Static Contact contact;
    Static Opportunity opp;
    
    static void setup(){
        
        // Setup Products
        GARP_TestFactory.createProducts(GARP_TestFactory.getAuxProductList(), new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        // Create User
        user = GARP_TestFactory.createIndividualUser();
        
        // Create Member        
        //opp = GARP_TestFactory.createMember();
        
        opp = [select id,AccountId,StageName from Opportunity limit 1];
        
        List<Contact> lstCont = [select id, accountId, Original_Business_Account_ID__c, Original_Business_Contact_Owner_ID__c from contact];
        contact = lstCont[0];        
        
        List<Account> lstAcct = [select id, Name from Account where id = :contact.accountId];
        account = lstAcct[0];        
        
        Remote_Sites__c setting = new Remote_Sites__c();
        setting.Name = 'Mobius';
        setting.Site_URL__c = 'http://preprod.garp.org:8081';
        insert setting;
    }
    
    static void setupEBooks() {
        
        // Setup eBooks
        List<String> prodsAUX = new List<String>{'FFRXF:FFRXF:4999:100','CBRX:CBRX:4040:100','RAIBP:RAIBP:4040:100','SCRX:SCRX:4040:100','FRM1X:FRM1X:4040:100'};
        GARP_TestFactory.createProducts(prodsAUX, new Set<String>{}, new Set<String>{}, new Set<String>{'FFRXF','CBRX','RAIBP','SCRX','FRM1X'});

        Opportunity ebookOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FFRXF');
        System.Debug('ebookOpp:' + ebookOpp);
        
        List<OpportunityLineItem> OppLineItems = new List<OpportunityLineItem>();
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(ebookOpp.id,'CBRX'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(ebookOpp.id,'RAIBP'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(ebookOpp.id,'SCRX'));
        OppLineItems.add(GARP_TestFactory.createOrderIndiviWithOpp(ebookOpp.id,'FRM1X'));
        insert OppLineItems;
        
        ebookOpp.StageName = 'Closed';
        update ebookOpp;
        
        List<eBook_Key__c> eBookKeys = GARP_TestFactory.createEbookKey(ebookOpp);
        System.Debug('eBookKeys:' + eBookKeys);
        insert eBookKeys;
    }
    
    
    @isTest
    static void unitTest_MyProgramsFRM1(){
        
        setup();
        
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        programOpp.StageName = 'Closed';
        update programOpp;
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp,frmContract,'FRM');
        List<Exam_Attempt__c> lstEAs = [select Id, Exam_Site__c, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c, Exam_Part__r.Exam__c, Exam_Part__r.Exam__r.Exam__c from Exam_Attempt__c where id = :frmAttempt.Id];
        
        Exam_Attempt__c frm2Attempt = GARP_TestFactory.createExamAttemptPart2(programOpp, frmContract, lstEAs[0].Exam_Administration__r.Exam_Group__c, lstEAs[0].Exam_Administration__c);
        List<Exam_Attempt__c> lstEA2s = [select Id, Exam_Site__c, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c, Exam_Part__r.Exam__c, Exam_Part__r.Exam__r.Exam__c from Exam_Attempt__c where id = :frm2Attempt.Id];
        
        //setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {
                        
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            
            frmContract.Status = 'Activated';
            update frmContract;
            
            // Normal
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            GARP_MS_MemberPortal.getDashboardInfo('');
            GARP_MS_MemberPortal.EPPOptIn('frm',true);            
            GARP_MS_MemberPortal.getExamResultsListing('');
            GARP_MS_MemberPortal.getAlertBarInfo('');
            GARP_MS_MemberPortal.getComponentAdInfo();
            GARP_BC_MemberPortal.hasPracticeExamAccess(contact, 'frm', frmContract, frmAttempt);            
            GARP_MS_MemberPortal.getErrataFormInfo('frm');
            
            GARP_BC_MyPrograms.validateIDFormat(null,null,null);
            GARP_BC_MyPrograms.validateIDFormat('122','China','Passport');
            GARP_BC_MyPrograms.validateIDFormat('12345678~','China','Passport');
            GARP_BC_MyPrograms.validateIDFormat('12345678O','China','Passport');
            GARP_BC_MyPrograms.validateIDFormat('123456789','China','Passport');
            
            GARP_BC_MyPrograms.validateIDFormat('122','China','Drivers License');
            GARP_BC_MyPrograms.validateIDFormat('123456789123456789','China','Drivers License');
            
            GARP_BC_MyPrograms.validateIDFormat('122','USA','Passport');
            GARP_BC_MyPrograms.validateIDFormat('12345~','USA','Passport');
            GARP_BC_MyPrograms.validateIDFormat('123456','USA','Passport');

            GARP_BC_MyPrograms.validateIDFormat('122','USA','Drivers License');
            GARP_BC_MyPrograms.validateIDFormat('12345~','USA','Drivers License');
            GARP_BC_MyPrograms.validateIDFormat('123456','USA','Drivers License');
            
            GARP_BC_MyPrograms.getProviderURL('ATA','123');
            GARP_BC_MyPrograms.getProviderURL('PSI','123');
            GARP_BC_MyPrograms.getProviderURL('Pearson','123');
            
            GARP_BC_MyPrograms.OSTAIDInfo OSTAIDInfo = new GARP_BC_MyPrograms.OSTAIDInfo();
            
            GARP_BC_MyPrograms.setOSTAIDInfo(contact, OSTAIDInfo);
            
            OSTAIDInfo.IdType = 'Passport';
            OSTAIDInfo.IdLocation = 'China';
            OSTAIDInfo.IdNumber  = '123456789';
            OSTAIDInfo.IdExpireDate  = '01/01/2028';
            
            GARP_BC_MyPrograms.setOSTAIDInfo(contact, OSTAIDInfo);
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsFRMExamSetup1(){
        
        setup();
        
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
            GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        programOpp.StageName = 'Closed';
        update programOpp;
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp,frmContract,'FRM');
        List<Exam_Attempt__c> lstEAs = [select Id, Exam_Site__c, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c, Exam_Part__r.Exam__c, Exam_Part__r.Exam__r.Exam__c from Exam_Attempt__c where id = :frmAttempt.Id];
        
        Exam_Attempt__c frm2Attempt = GARP_TestFactory.createExamAttemptPart2(programOpp, frmContract, lstEAs[0].Exam_Administration__r.Exam_Group__c, lstEAs[0].Exam_Administration__c);
        List<Exam_Attempt__c> lstEA2s = [select Id, Exam_Site__c, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c, Exam_Part__r.Exam__c, Exam_Part__r.Exam__r.Exam__c from Exam_Attempt__c where id = :frm2Attempt.Id];
        
        //setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {
                        
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            
            frmContract.Status = 'Activated';
            update frmContract;
                       
            
            GARP_BC_MyPrograms.returnGetExamSetupFormInfo retGetExamSetupFormInfo = GARP_MS_MemberPortal.getExamSetupFormInfo('frm');
            GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo = new GARP_BC_MyPrograms.examSetupExamSelectionsInfo();
            
            Date tdy = system.today();
            
            /*
            examSetupExamSelectionsInfo.selectedAdminPart1 = frmAttempt.Exam_Administration__c;
            examSetupExamSelectionsInfo.selectedSitePart1 = frmAttempt.Exam_Site__c;                
            examSetupExamSelectionsInfo.selectedAdminPart2 = frm2Attempt.Exam_Administration__c;
            examSetupExamSelectionsInfo.selectedSitePart2 = frm2Attempt.Exam_Site__c;                  
            GARP_MS_MemberPortal.getExamSetupExamSelectionInfo('frm', examSetupExamSelectionsInfo);
			*/
            
            
            // Change Site
            Exam_Administration__c examAdmin = new Exam_Administration__c();
            examAdmin.Exam_Group__c = lstEAs[0].Exam_Administration__r.Exam_Group__c;
			examAdmin.Exam_Admin_Modifications_Start_Date__c = tdy.addDays(30);
            examAdmin.Exam_Admin_Modifications_End_Date__c = tdy.addDays(60);           
            examAdmin.Exam_Scheduling_Start_Date__c = tdy.addDays(30);
            examAdmin.Exam_Scheduling_End_Date__c = tdy.addDays(60);
            examAdmin.Exam_Type__c = 'FRM';
            examAdmin.Registration_Start_Date__c = tdy.addDays(30);
            examAdmin.Registration_End_Date__c = tdy.addDays(60);
            examAdmin.Contingency_Administration__c = False;
            insert examAdmin;
            
            System.debug('****new admin:' + examAdmin);
            
            System.debug('****new part1 exam:' + lstEAs[0].Exam_Part__r.Exam__r.Exam__c);
            
            Exam_Part__c examPart1 = new Exam_Part__c();
            examPart1.Exam__c = lstEAs[0].Exam_Part__r.Exam__c;
            examPart1.Exam_Administration__c = examAdmin.id;
            examPart1.Exam_Date__c = system.today();
            examPart1.Delivery_Method__c = 'CBT';        
            insert examPart1;
            
            System.debug('****new part1:' + examPart1);
            
            Site__c site1 = new Site__c(name = 'test1',Display_Address__c = 'test1',Is_OSTA_Information_Required__c = True,active__c = true,Non_selectable__c = false);
            insert site1; 
            Exam_Sites__c exmSite1 = new Exam_Sites__c(Site__c = site1.id,Exam_Part__c = examPart1.Id, exam__c = lstEA2s[0].Exam_Part__r.Exam__c);
            insert exmSite1;

            System.debug('****new part2 exam:' + lstEA2s[0].Exam_Part__r.Exam__r.Exam__c);

            Exam_Part__c examPart2 = new Exam_Part__c();
            examPart2.Exam__c = lstEA2s[0].Exam_Part__r.Exam__c;
            examPart2.Exam_Administration__c = examAdmin.id;
            examPart2.Exam_Date__c = system.today();
            examPart2.Delivery_Method__c = 'CBT';        
            insert examPart2;
            
            System.debug('****new part2:' + examPart2);
            
            Site__c site2 = new Site__c(name = 'test2',Display_Address__c = 'test2',Is_OSTA_Information_Required__c = True,active__c = true,Non_selectable__c = false);
            insert site2; 
            Exam_Sites__c exmSite2 = new Exam_Sites__c(Site__c = site2.id,Exam_Part__c = examPart2.Id, exam__c = lstEAs[0].Exam_Part__r.Exam__c);
            insert exmSite2;
            
            examSetupExamSelectionsInfo.selectedAdminPart1 = examAdmin.Id;
            examSetupExamSelectionsInfo.selectedSitePart1 = exmSite1.Id;   
            
            examSetupExamSelectionsInfo.selectedAdminPart2 = examAdmin.Id;
            examSetupExamSelectionsInfo.selectedSitePart2 = exmSite2.Id;
            
            GARP_MS_MemberPortal.getExamSetupExamSelectionInfo('frm', examSetupExamSelectionsInfo);
            //GARP_BC_MyPrograms.returnSetExamSetupExamSelectionsChanges retSetChange = GARP_BC_MyPrograms.setExamSetupExamSelectionsChanges(contact,'frm', examSetupExamSelectionsInfo);
            
            
            GARP_MS_MemberPortal.getExamSetupIDInfo('frm', examSetupExamSelectionsInfo);
            
            GARP_BC_MyPrograms.setIdCandidateInfo idCandidateInfo = new GARP_BC_MyPrograms.setIdCandidateInfo();
            
            idCandidateInfo.idName = 'candidate dude';
        	idCandidateInfo.idNumber = '1234567';
        	idCandidateInfo.idType = 'Passport';
        	idCandidateInfo.idExpireDate = '11/21/2037';
        	idCandidateInfo.mobilePhoneLocation = 'United States(+1)';
        	idCandidateInfo.mobilePhoneNumber = '1234567890';
            
            GARP_BC_MyPrograms.returnSetExamSetupIDInfo retSetID = GARP_MS_MemberPortal.setExamSetupIDInfo('frm', examSetupExamSelectionsInfo, idCandidateInfo);
            System.debug('****retSetID:' + retSetID);
            
            GARP_MS_MemberPortal.getExamSetupFeesCheckoutInfo(retSetID.examModificationId);
            GARP_MS_MemberPortal.examSetupAuthorizeRegistrations('frm', False);
            
        }
        
        test.stopTest();
    }

    
    @isTest
    static void unitTest_MyProgramsFRM2(){
        
        setup();
        
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
            GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        programOpp.StageName = 'Closed';
        update programOpp;
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp,frmContract,'FRM');
        List<Exam_Attempt__c> lstEAs = [select Id, Exam_Site__c, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c, Exam_Part__r.Exam__c from Exam_Attempt__c where id = :frmAttempt.Id];
        
        Exam_Attempt__c frm2Attempt = GARP_TestFactory.createExamAttemptPart2(programOpp, frmContract, lstEAs[0].Exam_Administration__r.Exam_Group__c, lstEAs[0].Exam_Administration__c);
        
        //setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {
            
            // Program Not Found -- not working
            //frmContract.AccountId = acct1.Id;
            //update frmContract;
            //GARP_MS_MemberPortal.getFRMProgramDetailInfo();
            
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            
            frmContract.Status = 'Activated';
            update frmContract;
                        
            // Other
            GARP_BC_MyPrograms.examSetupAuthorizeRegistrations(contact,'frm', false);            
            GARP_BC_MyPrograms.isProviderSchedulingComplete(frmAttempt);
                        
            // Expired Contract
            frmContract.Status = 'Expired';
            update frmContract;
            
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            
            // Expired Contract
            frmContract.Status = 'Completed';
            update frmContract;
            
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsFRMBeforeCutOff(){
        
        setup();
        
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        programOpp.StageName = 'Closed';
        update programOpp;
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp,frmContract,'FRM');
        List<Exam_Attempt__c> lstEAs = [select Id, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c from Exam_Attempt__c];
        System.Debug('lstEAs:' + lstEAs);
        
        //setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {
                        
            //GARP_MS_MemberPortal.getFRMProgramDetailInfo();
            
            frmContract.Status = 'Activated';
            update frmContract;
            
            // Scheduling Window Closed
            List<Exam_Administration__c> lstExamAdmins = [select Id, Exam_Scheduling_End_Date__c from Exam_Administration__c];

            lstExamAdmins[0].Exam_Scheduling_Start_Date__c = Date.Today().AddDays(-30);
            lstExamAdmins[0].Exam_Scheduling_End_Date__c = Date.Today().AddDays(10);
            lstExamAdmins[0].Exam_Admin_Modifications_Start_Date__c = Date.Today().AddDays(-30);
            lstExamAdmins[0].Exam_Admin_Modifications_End_Date__c = Date.Today().AddDays(10);
            
            System.Debug('lstExamAdmins:' + lstExamAdmins);
            update lstExamAdmins;
                           
            List<Exam_Part__c> lstExamParts = [select id, Exam_Results_Release_Date__c from Exam_Part__c where id = :lstEAs[0].Exam_Part__c];
            lstExamParts[0].Exam_Results_Release_Date__c = Date.Today().AddDays(-1);
            System.Debug('lstExamParts:' + lstExamParts);
            update lstExamParts;
            
            // Normal
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsFRMAfterCutOffSchedNotComplete(){
        
        setup();
        
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        programOpp.StageName = 'Closed';
        update programOpp;
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp,frmContract,'FRM');
        List<Exam_Attempt__c> lstEAs = [select Id, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c from Exam_Attempt__c];
        System.Debug('lstEAs:' + lstEAs);
        
        //setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {
                        
            //GARP_MS_MemberPortal.getFRMProgramDetailInfo();
            
            frmContract.Status = 'Activated';
            update frmContract;
            
            // Scheduling Window Closed
            List<Exam_Administration__c> lstExamAdmins = [select Id, Exam_Scheduling_End_Date__c from Exam_Administration__c];
            
            lstExamAdmins[0].Exam_Scheduling_Start_Date__c = Date.Today().AddDays(-30);
            lstExamAdmins[0].Exam_Scheduling_End_Date__c = Date.Today().AddDays(-3);
            lstExamAdmins[0].Exam_Admin_Modifications_Start_Date__c = Date.Today().AddDays(-30);
            lstExamAdmins[0].Exam_Admin_Modifications_End_Date__c = Date.Today().AddDays(-3);

            System.Debug('lstExamAdmins:' + lstExamAdmins);
            update lstExamAdmins;
                           
            List<Exam_Part__c> lstExamParts = [select id, Exam_Results_Release_Date__c from Exam_Part__c where id = :lstEAs[0].Exam_Part__c];
            lstExamParts[0].Exam_Results_Release_Date__c = Date.Today().AddDays(-1);
            System.Debug('lstExamParts:' + lstExamParts);
            update lstExamParts;
            
            // Normal
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsFRMAfterCutOffSchedComplete(){
        
        setup();
        
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        programOpp.StageName = 'Closed';
        update programOpp;
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp,frmContract,'FRM');
        List<Exam_Attempt__c> lstEAs = [select Id, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c from Exam_Attempt__c];
        System.Debug('lstEAs:' + lstEAs);
                
        //setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {
                        
            //GARP_MS_MemberPortal.getFRMProgramDetailInfo();
            
            frmContract.Status = 'Activated';
            update frmContract;
            
            // Scheduling Window Closed
            List<Exam_Administration__c> lstExamAdmins = [select Id, Exam_Scheduling_End_Date__c from Exam_Administration__c];
            lstExamAdmins[0].Exam_Scheduling_Start_Date__c = Date.Today().AddDays(-30);
            lstExamAdmins[0].Exam_Scheduling_End_Date__c = Date.Today().AddDays(-10);
            lstExamAdmins[0].Exam_Admin_Modifications_Start_Date__c = Date.Today().AddDays(-30);
            lstExamAdmins[0].Exam_Admin_Modifications_End_Date__c = Date.Today().AddDays(-10);
            System.Debug('lstExamAdmins:' + lstExamAdmins);
            update lstExamAdmins;
                           
            List<Exam_Part__c> lstExamParts = [select id, Exam_Results_Release_Date__c from Exam_Part__c where id = :lstEAs[0].Exam_Part__c];
            lstExamParts[0].Exam_Results_Release_Date__c = Date.Today().AddDays(-1);
            System.Debug('lstExamParts:' + lstExamParts);
            update lstExamParts;
            
            String intDataRecordTypeId = RecordTypeHelper.GetRecordTypeId('Integration_Data__c', 'PSI');
            
            Integration_Data__c intData = new Integration_Data__c(
                Name='int',
                Exam_Registrations__c = frmAttempt.Id,
                PSI_Booking_Local_Time__c = DateTime.Now().AddDays(-3),
                PSI_country__c = 'Canada',
                recordTypeId = intDataRecordTypeId,
                ownerId = user.Id
            );
            insert intData;
            
            frmAttempt.Active_Integration_Data__c = intData.Id;
            update frmAttempt;
            
            // Normal
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            
            // No Results
            frmAttempt.Result__c = NULL;
            update frmAttempt;
          
            
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsFRMPart2Results(){
        
        setup();
        
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        programOpp.StageName = 'Closed';
        update programOpp;
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        Candidate_Requirement__c cr1 = GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        System.Debug('cr1:' + cr1);
        Candidate_Requirement__c cr2 = GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        System.Debug('cr2:' + cr2);
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        cr1.Status__c = 'Completed';
        update cr1;
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp,frmContract,'FRM');
        List<Exam_Attempt__c> lstEAs = [select Id, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c from Exam_Attempt__c];
        System.Debug('lstEAs:' + lstEAs);
        
        Exam_Attempt__c frm2Attempt = GARP_TestFactory.createExamAttemptPart2(programOpp, frmContract, lstEAs[0].Exam_Administration__r.Exam_Group__c, lstEAs[0].Exam_Administration__c);
        
        frmContract.Status = 'Activated';
        update frmContract;
        
        List<Exam_Administration__c> lstExamAdmins = [select Id, Exam_Scheduling_End_Date__c from Exam_Administration__c];

        lstExamAdmins[0].Exam_Scheduling_Start_Date__c = Date.Today().AddDays(-30);
        lstExamAdmins[0].Exam_Scheduling_End_Date__c = Date.Today().AddDays(-10);
        lstExamAdmins[0].Exam_Admin_Modifications_Start_Date__c = Date.Today().AddDays(-30);
        lstExamAdmins[0].Exam_Admin_Modifications_End_Date__c = Date.Today().AddDays(-10);
        
        System.Debug('lstExamAdmins:' + lstExamAdmins);
        update lstExamAdmins;
        
        List<Exam_Part__c> lstExamParts = [select id, Exam_Results_Release_Date__c from Exam_Part__c];
        for(Exam_Part__c ep :lstExamParts) {
        	ep.exam_Results_Release_Date__c = Date.Today().AddDays(-3);    
        }
        System.Debug('lstExamParts:' + lstExamParts);
        update lstExamParts;
        
        
        String intDataRecordTypeId = RecordTypeHelper.GetRecordTypeId('Integration_Data__c', 'PSI');
        
        Integration_Data__c intData = new Integration_Data__c(
            Name='int',
            Exam_Registrations__c = frmAttempt.Id,
            PSI_Booking_Local_Time__c = DateTime.Now().AddDays(-3),
            PSI_country__c = 'Canada',
            recordTypeId = intDataRecordTypeId,
            ownerId = user.Id
        );
        insert intData;
        
        frmAttempt.Active_Integration_Data__c = intData.Id;
        update frmAttempt;

        Integration_Data__c intData2 = new Integration_Data__c(
            Name='int',
            Exam_Registrations__c = frm2Attempt.Id,
            PSI_Booking_Local_Time__c = DateTime.Now().AddDays(-3),
            PSI_country__c = 'Canada',
            recordTypeId = intDataRecordTypeId,
            ownerId = user.Id
        );
        insert intData2;
        
        frm2Attempt.Active_Integration_Data__c = intData2.Id;
        update frm2Attempt;

        //setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {
                        
            // Normal
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsFRMCV(){
        
        setup();
        
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        programOpp.StageName = 'Closed';
        update programOpp;
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        Candidate_Requirement__c cr1 = GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        System.Debug('cr1:' + cr1);
        Candidate_Requirement__c cr2 = GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        System.Debug('cr2:' + cr2);
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        cr1.Status__c = 'Completed';
        update cr1;
        cr2.Status__c = 'Completed';
        update cr2;
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp,frmContract,'FRM');
        List<Exam_Attempt__c> lstEAs = [select Id, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c from Exam_Attempt__c];
        System.Debug('lstEAs:' + lstEAs);
        
        Exam_Attempt__c frm2Attempt = GARP_TestFactory.createExamAttemptPart2(programOpp, frmContract, lstEAs[0].Exam_Administration__r.Exam_Group__c, lstEAs[0].Exam_Administration__c);
        
        frmContract.Status = 'Activated';
        update frmContract;
        
        List<Exam_Administration__c> lstExamAdmins = [select Id, Exam_Scheduling_End_Date__c from Exam_Administration__c];
        
        lstExamAdmins[0].Exam_Scheduling_Start_Date__c = Date.Today().AddDays(-30);
        lstExamAdmins[0].Exam_Scheduling_End_Date__c = Date.Today().AddDays(-10);
        lstExamAdmins[0].Exam_Admin_Modifications_Start_Date__c = Date.Today().AddDays(-30);
        lstExamAdmins[0].Exam_Admin_Modifications_End_Date__c = Date.Today().AddDays(-10);
        
        System.Debug('lstExamAdmins:' + lstExamAdmins);
        update lstExamAdmins;
        
        List<Exam_Part__c> lstExamParts = [select id, Exam_Results_Release_Date__c from Exam_Part__c];
        for(Exam_Part__c ep :lstExamParts) {
        	ep.exam_Results_Release_Date__c = Date.Today().AddDays(-3);    
        }
        System.Debug('lstExamParts:' + lstExamParts);
        update lstExamParts;
        
        
        String intDataRecordTypeId = RecordTypeHelper.GetRecordTypeId('Integration_Data__c', 'PSI');
        
        Integration_Data__c intData = new Integration_Data__c(
            Name='int',
            Exam_Registrations__c = frmAttempt.Id,
            PSI_Booking_Local_Time__c = DateTime.Now().AddDays(-3),
            PSI_country__c = 'Canada',
            recordTypeId = intDataRecordTypeId,
            ownerId = user.Id
        );
        insert intData;
        
        frmAttempt.Active_Integration_Data__c = intData.Id;
        frmAttempt.Result__c = NULL;
        update frmAttempt;

        Integration_Data__c intData2 = new Integration_Data__c(
            Name='int',
            Exam_Registrations__c = frm2Attempt.Id,
            PSI_Booking_Local_Time__c = DateTime.Now().AddDays(-3),
            PSI_country__c = 'Canada',
            recordTypeId = intDataRecordTypeId,
            ownerId = user.Id
        );
        insert intData2;
        
        frm2Attempt.Active_Integration_Data__c = intData2.Id;
        frm2Attempt.Result__c = NULL;
        update frm2Attempt;

        //setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {
                        
            // Normal
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsFRMUnPaid(){
        
        setup();
        
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
            GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp,frmContract,'FRM');
        List<Exam_Attempt__c> lstEAs = [select Id, Exam_Administration__c, Exam_Administration__r.Exam_Group__c from Exam_Attempt__c];
        
        Exam_Attempt__c frm2Attempt = GARP_TestFactory.createExamAttemptPart2(programOpp, frmContract, lstEAs[0].Exam_Administration__r.Exam_Group__c, lstEAs[0].Exam_Administration__c);
        
        setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {
            
            frmContract.AccountId = account.Id;
            update frmContract;
            
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsFRMOther(){
        
        setup();
        
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
            GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp,frmContract,'FRM');
        
        setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {            
            
            frmAttempt.Deferral_Status__c = 'Deferred Out';
            update frmAttempt;
            
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            
            GARP_BC_StudyMaterials.errataFormSubmissionInfo efs = new GARP_BC_StudyMaterials.errataFormSubmissionInfo();
            efs.programType = 'frm';
            efs.studyMaterial = '2024 FRM Exam Part I';
            efs.book = 'Foundations of Risk Management';
            efs.pageNumber = '12';
            efs.errorDescription = 'error';
            GARP_MS_MemberPortal.submitErrataForm(efs);
            
            frmContract.Status = 'Completed';
            update frmContract;
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            
            frmContract.Status = 'Expired';
            update frmContract;
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsERP(){
        
        setup();
        
        Contract erpContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'ERP Program');
        erpContract.Status = 'Activated';
        update erpContract;
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(erpContract,'ERP Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(erpContract,'ERP Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(erpContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(opp,erpContract,'ERP');
                
        test.startTest();
        
        System.runAs(user) {
            GARP_MS_MemberPortal.getERPProgramDetailInfo('');
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyPrograms1(){
        
        setup();
        
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FRM Program');
        frmContract.Status = 'Activated';
        update frmContract;
        
        Id ProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Exam');
        Id ProgReqJobRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Job Experience');
        Id ProgReqCPEId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part I',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'FRM Part II',ProgReqRecId);
        GARP_TestFactory.createCandidateCommitment(frmContract,'Job Experience',ProgReqJobRecId);
        
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(opp,frmContract,'FRM');
                
        test.startTest();
        
        System.runAs(user) {
            
            GARP_MS_MemberPortal.getFRMProgramDetailInfo('');
            
            // Other calls
            GARP_MS_MemberPortal.getComponentEnrolledProgramsInfo();
            GARP_MS_MemberPortal.getProgramsListingInfo('');
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsOtherPrograms(){
        
        setup();
        
        setupEBooks();
        
        test.startTest();
        
        GARP_BC_MyPrograms.getProgramInformation('membership', NULL);
        GARP_BC_MyPrograms.getProgramInformation('affiliate', NULL);
        GARP_BC_MyPrograms.getProgramInformation('webcast', NULL);
        GARP_BC_MyPrograms.getProgramInformation('chaptermeeting', NULL);
        GARP_BC_MyPrograms.getProgramInformation('event', NULL);
        
		GARP_BC_Courses.microCourseInfo mci = new GARP_BC_Courses.microCourseInfo();
        GARP_BC_MyPrograms.getProgramInformation('mci', mci);

        System.runAs(user) {
            
            // Other Programs
            Contract ffrContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'FBR Program');            
            ffrContract.Status = 'Activated';
            GARP_MS_MemberPortal.getFFRProgramDetailInfo();
            
            List<String> prods = new List<String>{'CBRNM:CBRNM:4999:100'};
            GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
            
            Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'CBRNM');
            System.Debug('programOpp:' + programOpp);
            
            Contract frrContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'ICBRR Program');
            frrContract.Opportunity__c = programOpp.Id;
            update frrContract;
            
            Exam_Attempt__c ea = GARP_TestFactory.createExamAttempt(programOpp,frrContract,'FRR');
            System.Debug('ea:' + ea);
            
            GARP_MS_MemberPortal.getFRRProgramDetailInfo();
            
            frrContract.Status = 'Activated';
            update frrContract;            
            GARP_MS_MemberPortal.getFRRProgramDetailInfo();
            
            ea.Result__c = 'Fail';
            ea.Icbrr_Exam_Date__c = Date.Today().AddDays(-3);
            update ea;
            
            GARP_MS_MemberPortal.getFRRProgramDetailInfo();

            ea.Result__c = NULL;
            update ea;
            
            GARP_MS_MemberPortal.getFRRProgramDetailInfo();
            
            frrContract.Status = 'Expired';
            update frrContract;
            GARP_MS_MemberPortal.getFRRProgramDetailInfo();
            
            frrContract.Status = 'Completed';
            update frrContract;
            GARP_MS_MemberPortal.getFRRProgramDetailInfo();
        
        }
        
        test.stopTest();
    }
    
    @isTest
    static void unitTest_MyProgramsOtherPrograms2(){
        
        setup();
        
        setupEBooks();
        
        test.startTest();
        
        System.runAs(user) {
            
            Contract scrContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'SCR Program');
            scrContract.Status = 'Activated';
            update scrContract;
            
            GARP_TestFactory.createExamAttempt(opp,scrContract,'SCR');
            GARP_MS_MemberPortal.getSCRProgramDetailInfo('');
            
            Contract riskaiContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId,'Risk AI Program');
            riskaiContract.Status = 'Activated';
            update riskaiContract;
            
            GARP_TestFactory.createExamAttempt(opp,riskaiContract,'RISKAI');
            GARP_MS_MemberPortal.getRAIProgramDetailInfo('');
            
            // Other calls
            GARP_MS_MemberPortal.getComponentEnrolledProgramsInfo();
            GARP_MS_MemberPortal.getProgramsListingInfo('');
        }
        
        test.stopTest();
    }

    /** Covers GARP_BC_MyPrograms.getLatestExamAttempts RAIJ branch (line 111). */
    @isTest
    static void testGetLatestExamAttemptsWithRAIJ() {
        setup();
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        programOpp.StageName = 'Closed';
        update programOpp;
        Contract raijContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId, 'FRM Program');
        raijContract.Status = 'Activated';
        update raijContract;
        GARP_TestFactory.createExamAttempt(programOpp, raijContract, 'raij');
        test.startTest();
        GARP_BC_MyPrograms.returnLatestExamAttempts result = GARP_BC_MyPrograms.getLatestExamAttempts(contact.Id);
        test.stopTest();
        System.assertNotEquals(null, result, 'getLatestExamAttempts should return non-null');
        System.assert(!result.allExamAttempts.isEmpty(), 'allExamAttempts should contain the RAIJ attempt');
        Boolean hasRAIJ = false;
        for (String key : result.mapLatestExamAttempts.keySet()) {
            if (key.startsWith('RAIJ')) {
                hasRAIJ = true;
                break;
            }
        }
        System.assert(hasRAIJ, 'mapLatestExamAttempts should contain an RAIJ key');
    }

    /** Covers GARP_BC_MyPrograms.getRelatedExamSites with both selectedSitePart1 and selectedSitePart2 (lines 194-205). */
    @isTest
    static void testGetRelatedExamSitesWithBothParts() {
        setup();
        List<String> prods = new List<String>{'FRM1:FRM1:4999:100'};
        GARP_TestFactory.createProducts(prods, new Set<String>{}, new Set<String>{}, new Set<String>{});
        Opportunity programOpp = GARP_TestFactory.createOrder(account.Id, contact.Id, 'FRM1');
        programOpp.StageName = 'Closed';
        update programOpp;
        Contract frmContract = GARP_TestFactory.createProgramContract(contact.Id, contact.accountId, 'FRM Program');
        Exam_Attempt__c frmAttempt = GARP_TestFactory.createExamAttempt(programOpp, frmContract, 'FRM');
        List<Exam_Attempt__c> lstEAs = [SELECT Id, Exam_Site__c, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, Exam_Part__c FROM Exam_Attempt__c WHERE id = :frmAttempt.Id];
        Exam_Attempt__c frm2Attempt = GARP_TestFactory.createExamAttemptPart2(programOpp, frmContract, lstEAs[0].Exam_Administration__r.Exam_Group__c, lstEAs[0].Exam_Administration__c);
        List<Exam_Attempt__c> lstEA2s = [SELECT Id, Exam_Site__c FROM Exam_Attempt__c WHERE id = :frm2Attempt.Id];
        GARP_BC_MyPrograms.examSetupExamSelectionsInfo examSetupExamSelectionsInfo = new GARP_BC_MyPrograms.examSetupExamSelectionsInfo();
        examSetupExamSelectionsInfo.selectedSitePart1 = lstEAs[0].Exam_Site__c;
        examSetupExamSelectionsInfo.selectedSitePart2 = lstEA2s[0].Exam_Site__c;
        test.startTest();
        List<Exam_Sites__c> lstSites = GARP_BC_MyPrograms.getRelatedExamSites(examSetupExamSelectionsInfo);
        test.stopTest();
        System.assertNotEquals(null, lstSites, 'getRelatedExamSites should return non-null list');
        System.assertEquals(2, lstSites.size(), 'getRelatedExamSites should return 2 sites when both part1 and part2 are set');
    }
}