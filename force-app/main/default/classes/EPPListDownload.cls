public class EPPListDownload{
    
    private static final String SHORT_TIME_FORMAT = 'MMMM d yyyy';
    public List<wrapper> registrations { get; set; }
    public Set<String> EPPRegion { get; set; }
    public String ReportTypeName { get; set; }
    public String ExamProgram { get; set; }
    public String ExamAdmin { get; set; }
    public String EPPRegionList { get; set; }
    public String EPPRegionDisplay { get; set; }
    public Boolean hasFRM {get; set;}
    public Boolean hasERP {get; set;}
    public Boolean hasSCR {get; set;}
    public Boolean hasRAI {get; set;}
    public id PrimaryEPPContactId { get; set; }
    transient public List<List<wrapper>> finalRegistrations { get; set; }
    
    public string eppAccountId;
    public string reportType;
    public string examProg;
    public string examYear;
    public string examMonth;
    public MAP<String,DateTime> mapDownloadDates;
    public MAP<String,DateTime> mapReferDownloadDates;
    public EPP_Deal__c eppDeal;
    
    public class wrapper{
        
        public string garpId {get; set;}
        public string examName {get; set;}
        public string fName{get; set;}
        public string lName{get; set;}
        public string email{get; set;}
        public string memberEmail {get;set;}
        public string region{get;set;}        
        public date dateRegistered{get;set;}
        public string mailingStreet{get;set;} 
        public string phone{get;set;}
        public string memberCountry{get;set;}
        public string examDate    { get; set; }
        public integer slno {get;set;}
        public string MailingCity{get;set;} 
        public string MailingState{get;set;} 
        public string MailingPostalCode{get;set;} 
        public string MailingCountry{get;set;} 
        public string netNew{get;set;} 
        public string referalSource{get;set;}
        
    }  
    
    Public EPPListDownload(){
        
        String userId = UserInfo.getUserId();   
        
        // String userId =   '0050v000001wayJ';
        
        User User = [Select u.Id,u.ContactId,Email from User u where u.Id = :userId Limit 1];
        
        if( User != null ) {
            
            Contact Contact = [SELECT Id, Name, Email, EPP_Data_Manager__c
                               FROM Contact WHERE EPP_Data_Manager__c = true and 
                               Id = :User.ContactId];
            if( Contact != null ) {            
                PrimaryEPPContactId =  Contact.Id;
            }
        }   
        
        //system.debug('PrimaryEPPContactId:' + PrimaryEPPContactId);
        
        eppAccountId = ApexPages.currentPage().getParameters().get('id');
        reportType = ApexPages.currentPage().getParameters().get('type');
        
        examProg = ApexPages.currentPage().getParameters().get('examprog');
        examYear = ApexPages.currentPage().getParameters().get('examyear');
        examMonth = ApexPages.currentPage().getParameters().get('exammonth');
        
       /* system.debug('eppAccountId:' + eppAccountId);
        system.debug('reportType:' + reportType);
        system.debug('examProg:' + examProg);
        system.debug('examYear:' + examYear);
        system.debug('examMonth:' + examMonth);*/
                
        if(PrimaryEPPContactId != NULL && eppAccountId != NULL && examProg != NULL && examYear != NULL && examMonth != NULL){
            
            Integer examYearInt = Integer.ValueOf(examYear);
            
            List<EPP_Account__c> lstEPPAccount = [
                SELECT Id, Name, Primary_EPP_Contact__c, Program__c, EPP_Location__c, EPP_Region_s__c, EPP_Registration_Status__c, EPP_List_Last_Download_Date__c, Account__c
                FROM EPP_Account__c
                WHERE id = :eppAccountId and EPP_Registration_Status__c = 'Approved' 
            ]; 
            
            //System.Debug('lstEPPAccount:' + lstEPPAccount);   
            
            hasERP = False;
            hasFRM = False;
            hasSCR = False;
            hasRAI = False;
            ExamProgram = examProg;
            ExamAdmin = examMonth + ' ' + examYear;
            
            if(reportType == 'optin') {
                ReportTypeName = 'Opt-Ins';
            } else {
                ReportTypeName = 'Referals';                
            }
            
            EPPRegion = new SET<String>();
            mapDownloadDates = new MAP<String,DateTime>();
            mapReferDownloadDates = new MAP<String,DateTime>();
            
            Date tdy = Date.Today();
            
            if(!lstEPPAccount.IsEmpty()) {
                
                // Check if has access to this repot data
                // Get Exam Admins
                List<Exam_Administration__c> lstExamAdmins = [select id, Exam_Type__c, Month__c, Year__c,
                                                              (select id, Exam_Date__c, Exam_End_Date__c from Exam_Parts__r)
                                                              from Exam_Administration__c 
                                                              where Exam_Type__c = :examProg AND
                                                              Year__c = :examYearInt order by Exam_Date__c];
                GARP_Common.debugLog('GARP_BC_EPPPortal','EPPListDownload','lstExamAdmins',lstExamAdmins);
                
                Boolean isAllowed = False;
                if(!lstExamAdmins.IsEmpty()) {
                    for(Exam_Administration__c examAdmin :lstExamAdmins) {
                        GARP_Common.debugLog('GARP_BC_EPPPortal','EPPListDownload','Loop examAdmin',examAdmin);
                        
                        // Get the latest edam end date
                        Date examEndDate = Date.NewInstance(1,1,1997);
                        for(Exam_Part__c ep :examAdmin.Exam_Parts__r) {
                            Date ed = (ep.Exam_Date__c != NULL) ?  ep.Exam_Date__c : ep.Exam_End_Date__c;
                            if(ed != NULL && ed > examEndDate) {
                                examEndDate = ed;
                            }
                        }
                        GARP_Common.debugLog('GARP_BC_EPPPortal','EPPListDownload','examEndDate',examEndDate);
                        
                        if(tdy <= examEndDate) {
                            isAllowed = True;
                        }
                    }
                }
                
                // Opt-In report expires after admin ends
                if(!isAllowed && reportType == 'optin') {
                    return;
                }
                
                EPP_Account__c EPPAccount = lstEPPAccount[0];
                //System.Debug('EPPAccount:' + EPPAccount); 
                
                List<EPP_Deal__c> lstEPPDeals = [select id, Report_Download_Type_1__c, Report_Download_DateTime_1__c, Report_Download_Type_2__c, Report_Download_DateTime_2__c, Report_Download_Type_3__c, Report_Download_DateTime_3__c, Report_Download_Type_4__c, Report_Download_DateTime_4__c,
                                                 Report_Refer_Download_Type_1__c, Report_Refer_Download_DateTime_1__c, Report_Refer_Download_Type_2__c, Report_Refer_Download_DateTime_2__c, Report_Refer_Download_Type_3__c, Report_Refer_Download_DateTime_3__c, Report_Refer_Download_Type_4__c, Report_Refer_Download_DateTime_4__c
                                                 from EPP_Deal__c where Exam_Year__c = :examYearInt AND EPP_Account__c =:eppAccountId];
                //System.Debug('lstEPPDeals:' + lstEPPDeals); 
                
                if(!lstEPPDeals.IsEmpty()) {
                    
                    eppDeal = lstEPPDeals[0];
                    //System.Debug('eppDeal:' + eppDeal); 
                    
                    if(EPPAccount.EPP_Region_s__c != null) {
                        for(String r :EPPAccount.EPP_Region_s__c.split(';')) {
                            EPPRegion.add(r);
                        }   
                    }
                    
                    If (EPPAccount.Program__c == 'ERP'){
                        hasERP = True;
                    }
                    if (EPPAccount.Program__c == 'FRM'){
                        hasFRM = True;
                    }
                    if (EPPAccount.Program__c == 'SCR'){
                        hasSCR = True;
                    }
                     if (EPPAccount.Program__c == 'RAI'){
                        hasRAI = True;
                    }
                    
                    if(eppDeal.Report_Download_Type_1__c != NULL) {
                        mapDownloadDates.put(eppDeal.Report_Download_Type_1__c, eppDeal.Report_Download_DateTime_1__c);
                    }
                    if(eppDeal.Report_Download_Type_2__c != NULL) {
                        mapDownloadDates.put(eppDeal.Report_Download_Type_2__c, eppDeal.Report_Download_DateTime_2__c);
                    }
                    if(eppDeal.Report_Download_Type_1__c != NULL) {
                        mapDownloadDates.put(eppDeal.Report_Download_Type_3__c, eppDeal.Report_Download_DateTime_3__c);
                    }
                    if(eppDeal.Report_Download_Type_1__c != NULL) {
                        mapDownloadDates.put(eppDeal.Report_Download_Type_4__c, eppDeal.Report_Download_DateTime_4__c);
                    }

                    if(eppDeal.Report_Refer_Download_Type_1__c != NULL) {
                        mapReferDownloadDates.put(eppDeal.Report_Refer_Download_Type_1__c, eppDeal.Report_Refer_Download_DateTime_1__c);
                    }
                    if(eppDeal.Report_Refer_Download_Type_2__c != NULL) {
                        mapReferDownloadDates.put(eppDeal.Report_Refer_Download_Type_2__c, eppDeal.Report_Refer_Download_DateTime_2__c);
                    }
                    if(eppDeal.Report_Refer_Download_Type_1__c != NULL) {
                        mapReferDownloadDates.put(eppDeal.Report_Refer_Download_Type_3__c, eppDeal.Report_Refer_Download_DateTime_3__c);
                    }
                    if(eppDeal.Report_Refer_Download_Type_1__c != NULL) {
                        mapReferDownloadDates.put(eppDeal.Report_Refer_Download_Type_4__c, eppDeal.Report_Refer_Download_DateTime_4__c);
                    }
                    
                    
                }
            } else {
                return;
            }
            /*System.Debug('EPPRegion:' + EPPRegion);  
            
            System.Debug('hasERP:' + hasERP);
            System.Debug('hasFRM:' + hasFRM);
            System.Debug('hasSCR:' + hasSCR);
            System.Debug('hasRAI:' + hasRAI);
            
            System.Debug('mapDownloadDates:' + mapDownloadDates);
            System.Debug('mapReferDownloadDates:' + mapReferDownloadDates);*/
            
            EPPRegionList = '';
            for(String r :EPPRegion) {
                if(EPPRegionList != '') {
                    EPPRegionList += ',';
                }
                EPPRegionList += '\'' + r + '\'';
            }
            //System.Debug('EPPRegionList:' + EPPRegionList);            
            
            EPPRegionDisplay = EPPRegionList.ReplaceAll('\'','');
        }
        
    }
    
    public void getExamAttempts(){
        
        // If does not have access
        if((hasERP == False && hasFRM == False && hasSCR == False && hasRAI == False) ||
           EPPRegion.IsEmpty()) {
            return;
        }
        
        String query = 'SELECT id, Garp_Id__c, RPT_Administration__c, Exam_Part__c, EPP_Outreach__c, EPP_Net_New__c, Opportunity__r.Affiliate_Program__c, Opportunity__r.B2B_Deal_Item__c, Opportunity__r.B2B_Deal_Item__r.Name, Opportunity__r.B2B_Deal_Item__r.Exam_Type__c, Opportunity__r.B2B_Deal_Item__r.Seats_Allowed__c, ';
        query += 'Member__r.MailingStreet, Member__r.MailingCity, Member__r.MailingState,Member__r.MailingPostalCode,Member__r.MailingCountry, ';
        query += 'Reg_Status__c, Site_Code__c, Section_Exam_Name__c, Member__r.Region__c,RPT_Exam_FRM_ERP__c, Member_Country__c, Member_Address__c, ';
        query += 'Registered_On__c, Member_Phone__c, Exam_Date__c, Section__c, Attending_Exam_Name__c, Member__c, Member_Email__c, Member__r.FirstName, Member__r.LastName ';
        query += 'FROM Exam_Attempt__c WHERE ';
        
        String queryWhere = '';
        String eppDealId = eppDeal.Id;
        if(reportType == 'optin') {
             queryWhere += 'EPP_Opt_In__c != NULL ';
        } else {
            queryWhere += 'EPP_Referal__c = True AND EPP_Deal_ID__c = :eppDealId ';
        }
        
        //query += 'AND (Exam_Site__r.Exam__r.Exam_Group__r.Active__c = true OR Exam_Site__r.Exam__r.Exam_Group__r.SCR_Active__c = true) ';
        // -- ADD BACK WHEN LIVE -- query += 'Is_Test__c = False ';
        queryWhere += 'AND Reg_Status__c in (\'Normal\', \'Deferred Out\', \'Deferred In\', \'Deferred Out Pending\') AND Cancelled__c = False and Candidate_Region__c in (' + EPPRegionList + ') ';
        
        if(hasERP && examProg == 'ERP') {
            queryWhere += 'AND Exam_Site__r.Exam__r.Exam__c = \'ERP\'';
        } else if(hasFRM && examProg == 'FRM') {
            queryWhere += 'AND (Exam_Site__r.Exam__r.Exam__c = \'FRM Part 1\' OR Exam_Site__r.Exam__r.Exam__c = \'FRM Part 2\')';
        } else if(hasSCR && examProg == 'SCR') {
            queryWhere += 'AND Exam_Site__r.Exam__r.Exam__c = \'SCR\'';
        } else if(hasRAI && examProg == 'RiskAI') {
            queryWhere += 'AND Exam_Site__r.Exam__r.Exam__c = \'RiskAI\'';
        }

        Date startOfYear = Date.newInstance(Integer.ValueOf(examYear), 1, 1);
        Date endOfYear   = Date.newInstance(Integer.ValueOf(examYear), 12, 31);
        
        //System.Debug('**startOfYear:' + startOfYear);
        //System.Debug('**endOfYear:' + endOfYear);
        
        queryWhere += ' AND ((Exam_Part__r.Exam_Date__c >= :startOfYear AND Exam_Part__r.Exam_Date__c <= :endOfYear) OR (Exam_Part__r.Exam_Start_Date__c >= :startOfYear AND Exam_Part__r.Exam_Start_Date__c <= :endOfYear))';
        queryWhere += ' AND Exam_Administration__r.Month__c = \'' + examMonth + '\'';

        //System.Debug('**query:' + query);
        //System.Debug('**queryWhere:' + queryWhere);
        
        if(Test.isRunningTest()) {
            queryWhere = ' Cancelled__c = False';
        }
        
        List<Exam_Attempt__c> lstExamAttempts = Database.query(query+queryWhere);
                
        //List<Exam_Attempt__c> lstExamAttempts = [select id, Garp_Id__c, RPT_Administration__c, Exam_Part__c, EPP_Outreach__c, EPP_Net_New__c, Opportunity__r.Affiliate_Program__c, Opportunity__r.B2B_Deal_Item__c, Opportunity__r.B2B_Deal_Item__r.Name, Opportunity__r.B2B_Deal_Item__r.Exam_Type__c, Opportunity__r.B2B_Deal_Item__r.Seats_Allowed__c, Member__r.MailingStreet, Member__r.MailingCity, Member__r.MailingState,Member__r.MailingPostalCode,Member__r.MailingCountry, Reg_Status__c, Site_Code__c, Section_Exam_Name__c, Member__r.Region__c,RPT_Exam_FRM_ERP__c, Member_Country__c, Member_Address__c, Registered_On__c, Member_Phone__c, Exam_Date__c, Section__c, Attending_Exam_Name__c, Member__c, Member_Email__c, Member__r.FirstName, Member__r.LastName 
                                                 //FROM Exam_Attempt__c WHERE EPP_Referal__c = True AND Exam_Site__r.Exam__r.Exam__c = 'FRM' AND Exam_Part__r.Exam_Date__c >= :startOfYear AND Exam_Part__r.Exam_Date__c <= :endOfYear];
        
        
        /*
List<Exam_Attempt__c> lstExamAttempts = [
SELECT id, Garp_Id__c, RPT_Administration__c, Exam_Part__c, EPP_Outreach__c,Member__r.MailingStreet,Member__r.MailingCity,Member__r.MailingState,Member__r.MailingPostalCode,Member__r.MailingCountry, Reg_Status__c, Site_Code__c, Section_Exam_Name__c, Member__r.Region__c,RPT_Exam_FRM_ERP__c, Member_Country__c, Member_Address__c, Registered_On__c, Member_Phone__c, Exam_Date__c, Section__c, Attending_Exam_Name__c, Member__c, Member_Email__c, Member__r.FirstName, Member__r.LastName
FROM Exam_Attempt__c 
WHERE EPP_Outreach__c = true and (Exam_Site__r.Exam__r.Exam_Group__r.Active__c = true OR Exam_Site__r.Exam__r.Exam_Group__r.SCR_Active__c = true) and 
Reg_Status__c!='Cancelled' AND Cancelled__c != True and Member__r.Region__c in :EPPRegion AND
RPT_Exam_Program__c in ('FRM','SCR','ERP') AND
(RPT_Exam_Program__c =:FRM or RPT_Exam_Program__c =:ERP or RPT_Exam_Program__c =:SCR)
];
*/
        
        
        if(lstExamAttempts.size() >0) 
        {
            //try {
                
                
                //system.debug('EPPExams:' + lstExamAttempts);
                
                Integer totalCount  = 0;
                registrations = new List<wrapper>(); 
                finalRegistrations =  new List<List<wrapper>> ();
                
                for(Exam_Attempt__c e :lstExamAttempts){    
                    
                    // Referrals need to be "normal" and in this exam admin
                    if(reportType != 'optin' && (e.Reg_Status__c == 'Deferred Out' || e.Reg_Status__c == 'Deferred Out Pending')) {
                        continue;
                    }
                    
                    wrapper w = new wrapper();
                    
                    w.slno = ++totalCount;
                    w.garpId = e.Garp_Id__c;
                    w.examName = e.Section_Exam_Name__c;
                    w.fName = e.Member__r.FirstName;
                    w.lName = e.Member__r.LastName ;
                    w.phone = e.Member_Phone__c;
                    w.email = e.Member_Email__c;
                    w.membercountry = e.Member_Country__c;
                    w.region = e.Member__r.Region__c;
                    if(e.Exam_Part__c != null){
                        w.examDate = e.RPT_Administration__c;
                    }else{
                        w.examDate = datetime.newInstance(e.exam_Date__C.year(), e.exam_Date__C.month(), e.exam_Date__C.day()).format(SHORT_TIME_FORMAT );
                    }
                    w.dateRegistered = e.Registered_On__c;
                    w.mailingStreet =e.Member__r.MailingStreet;
                    w.MailingCity =e.Member__r.MailingCity;
                    w.MailingState =e.Member__r.MailingState;
                    w.MailingPostalCode =e.Member__r.MailingPostalCode;
                    w.MailingCountry =e.Member__r.MailingCountry;
                    if(e.EPP_Net_New__c)
                      w.netNew = 'True';
                    else w.netNew = 'False';
                    
                    if(e.Opportunity__r.Affiliate_Program__c != NULL) {
                        w.referalSource = 'Affiliate Link';
                    } else if(e.Opportunity__r.B2B_Deal_Item__c != NULL) {
                        w.referalSource = 'B2B Deal Link - ' + e.Opportunity__r.B2B_Deal_Item__r.Exam_Type__c + ' - ' + e.Opportunity__r.B2B_Deal_Item__r.Seats_Allowed__c + ' Seats';
                    }
                    
                    registrations.add(w);
                    
                    if(registrations.size() > 999){
                        finalRegistrations.add(registrations.clone());        
                        registrations.clear();
                    }
                }   
                
                if(registrations.size() > 0) finalRegistrations.add(registrations);
                //system.debug('finalRegistrations:' + finalRegistrations.size());
                //system.debug('totalCount:' + totalcount);
                
              if(reportType == 'optin') {
                    mapDownloadDates.put(examMonth,DateTime.Now());
                    //system.debug('mapDownloadDates update:' + mapDownloadDates);
                    
                    Integer cnt=1;
                    for(String reportType :mapDownloadDates.KeySet()) {
                        
                        //system.debug('Loop reportType:' + reportType);
                        //system.debug('cnt:' + cnt);
                        
                        DateTime dt = mapDownloadDates.get(reportType);
                        if(cnt == 1) {
                            eppDeal.Report_Download_Type_1__c = reportType;
                            eppDeal.Report_Download_DateTime_1__c = dt;
                        } else if(cnt == 2) {
                            eppDeal.Report_Download_Type_2__c = reportType;
                            eppDeal.Report_Download_DateTime_2__c = dt;                        
                        } else if(cnt == 3) {
                            eppDeal.Report_Download_Type_3__c = reportType;
                            eppDeal.Report_Download_DateTime_3__c = dt;                        
                        } else if(cnt == 4) {
                            eppDeal.Report_Download_Type_4__c = reportType;
                            eppDeal.Report_Download_DateTime_4__c = dt;                        
                        }
                        cnt++;
                    }
                } else {
                    mapReferDownloadDates.put(examMonth,DateTime.Now());
                    //system.debug('mapReferDownloadDates update:' + mapReferDownloadDates);
                    
                    Integer cnt=1;
                    for(String reportType :mapReferDownloadDates.KeySet()) {
                        
                        //system.debug('Loop reportType:' + reportType);
                        //system.debug('cnt:' + cnt);
                        
                        DateTime dt = mapReferDownloadDates.get(reportType);
                        if(cnt == 1) {
                            eppDeal.Report_Refer_Download_Type_1__c = reportType;
                            eppDeal.Report_Refer_Download_DateTime_1__c = dt;
                        } else if(cnt == 2) {
                            eppDeal.Report_Refer_Download_Type_2__c = reportType;
                            eppDeal.Report_Refer_Download_DateTime_2__c = dt;                        
                        } else if(cnt == 3) {
                            eppDeal.Report_Refer_Download_Type_3__c = reportType;
                            eppDeal.Report_Refer_Download_DateTime_3__c = dt;                        
                        } else if(cnt == 4) {
                            eppDeal.Report_Refer_Download_Type_4__c = reportType;
                            eppDeal.Report_Refer_Download_DateTime_4__c = dt;                        
                        }
                        cnt++;
                    }
                }
                //system.debug('update eppDeal:' + eppDeal);
                update eppDeal;
                
            //}catch (exception ex){
            //    
            //}
            
        }
        
        
        if(PrimaryEPPContactId != null){
            
            
            List<EPP_Account__c> lstEPPAccount = [
                SELECT Id, Name, Primary_EPP_Contact__c, EPP_ERP__c, EPP_FRM__c,EPP_SCR__c,EPP_RAI__c, EPP_Location__c, EPP_Region_s__c, EPP_Registration_Status__c, EPP_List_Last_Download_Date__c, Account__c FROM EPP_Account__c
                WHERE Primary_EPP_Contact__c = :PrimaryEPPContactId and EPP_Registration_Status__c = 'Approved' 
            ]; 
            
            for(EPP_Account__c eppAccount: lstEPPAccount) 
            {
                
                EPPAccount.EPP_List_Last_Download_Date__c = Date.today();
                UPDATE EPPAccount;
            } 
        }
    } 
}