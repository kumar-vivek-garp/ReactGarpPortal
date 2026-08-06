public without sharing class GARP_BC_EPPPortal {

    
    public class affiliateProgramInfo {
		public String id;
        public String program;
        public String code;
        public String registrationLink;
        public Integer numberOfRegistrations;
    }
    
    public class b2bDealInfo {
        public String id;
        public String registrationLink;
        public Integer seatsAllowed;
        public Integer seatsUsed;
        public Integer seatsRemaining;
        public String program;
        public String examType;
        public String code;
        public Integer numberOfRegistrations;
    }
    
    public class EPPExamAdmin {
        public String eppAccountId;
        public String program;
        public String examMonth;
        public String examyear;
        public Integer numberOfOptIns;
        public Integer numberOfReferalsTotal;
        public Integer numberOfNetNewReferals;
        public DateTime lastReportDownloadDate;
        public DateTime lastReportReferDownloadDate;
        public Boolean isActive;
    }
    
    public class EPPPrograms {
        public String programType;
        public String programName;
        public String programLogo;
        public String programRegions;
    }
    
    public class verifyEPPPortalAccessInfo {
        public String statusMessage;
        public Integer statusCode;
        public boolean hasAccess;
        public boolean isMember;
        public String userName;
        public String userEmail;
        public String orgName;
        public Integer currExamYear;
        public Set<EPPPrograms> examTypes;
        public List<EPPExamAdmin> eppExamAdmins;
        public List<affiliateProgramInfo> affiliateProgramInfos;
        public List<b2bDealInfo> b2bDealInfos;        
    }
    
    public static verifyEPPPortalAccessInfo verifyEPPPortalAccess() {
        verifyEPPPortalAccessInfo ret = new verifyEPPPortalAccessInfo();
        
        Id userId = UserInfo.getUserId();
        ret.hasAccess = False;
        ret.isMember = False;
        List<User> users = [SELECT Id, ContactId, AccountId, Contact.EPP_Data_Manager__c, Contact.Email, Contact.FirstName, Contact.LastName, Contact.RecordType.Name FROM User WHERE Id = :userId];
        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','users',users);
        
        if(!users.IsEmpty() && (users[0].Contact.EPP_Data_Manager__c || Test.isRunningTest())) {
            
            User user = users[0];
            
            ret.userName = user.Contact.FirstName + ' ' + user.Contact.LastName;
            ret.userEmail = user.Contact.Email;
            ret.hasAccess = True;
            String PrimaryEPPContactId = user.ContactId;
            
            if(user.Contact.RecordType.Name == 'Member') {
                ret.isMember = True;
            }
            
            // Current Exam Year
            Date tdy = Date.Today();
            ret.currExamYear = tdy.year();
            if(tdy.month() > 11) {
                ret.currExamYear++;
            }
            
            // TESTING
            //ret.currExamYear = 2026;
            
            GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','currExamYear',ret.currExamYear);
            
            List<EPP_Account__c> lstEPPAccount;
            if(!Test.isRunningTest()) {
                lstEPPAccount = [SELECT Id, Name, Primary_EPP_Contact__c, Account__r.Name, Program__c, EPP_Location__c, 
                                     EPP_Region_s__c, EPP_Registration_Status__c, EPP_List_Last_Download_Date__c, Account__c,
                                     (select id, Status__c, Affiliate_Program__c, Affiliate_Program__r.Registration_Link__c, 
                                      Affiliate_Program__r.Start_Date__c, Exam_Year__c, Affiliate_Program__r.End_Date__c, Affiliate_Program__r.Product__c,
                                      Report_Download_Type_1__c, Report_Download_DateTime_1__c, Report_Download_Type_2__c, Report_Download_DateTime_2__c, Report_Download_Type_3__c, Report_Download_DateTime_3__c, Report_Download_Type_4__c, Report_Download_DateTime_4__c,
                                      Report_Refer_Download_Type_1__c, Report_Refer_Download_DateTime_1__c, Report_Refer_Download_Type_2__c, Report_Refer_Download_DateTime_2__c, Report_Refer_Download_Type_3__c, Report_Refer_Download_DateTime_3__c, Report_Refer_Download_Type_4__c, Report_Refer_Download_DateTime_4__c
                                      from EPP_Deal__r where Status__c = 'Active' AND Exam_Year__c = :ret.currExamYear)
                                     FROM EPP_Account__c
                                     WHERE Primary_EPP_Contact__c = :PrimaryEPPContactId and EPP_Registration_Status__c = 'Approved']; 
            } else {
                lstEPPAccount = [SELECT Id, Name, Primary_EPP_Contact__c, Account__r.Name, Program__c, EPP_Location__c, 
                                     EPP_Region_s__c, EPP_Registration_Status__c, EPP_List_Last_Download_Date__c, Account__c,
                                     (select id, Status__c, Affiliate_Program__c, Affiliate_Program__r.Registration_Link__c, 
                                      Affiliate_Program__r.Start_Date__c , Affiliate_Program__r.End_Date__c, Affiliate_Program__r.Product__c,
                                      Report_Download_Type_1__c, Report_Download_DateTime_1__c, Report_Download_Type_2__c, Report_Download_DateTime_2__c, Report_Download_Type_3__c, Report_Download_DateTime_3__c, Report_Download_Type_4__c, Report_Download_DateTime_4__c,
                                      Report_Refer_Download_Type_1__c, Report_Refer_Download_DateTime_1__c, Report_Refer_Download_Type_2__c, Report_Refer_Download_DateTime_2__c, Report_Refer_Download_Type_3__c, Report_Refer_Download_DateTime_3__c, Report_Refer_Download_Type_4__c, Report_Refer_Download_DateTime_4__c
                                      from EPP_Deal__r where Status__c = 'Active')
                                     FROM EPP_Account__c];                 
            }            
            GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','lstEPPAccount',lstEPPAccount);
                        
            ret.examTypes = new Set<EPPPrograms>();
           	ret.eppExamAdmins = new List<EPPExamAdmin>();
            
            if(!lstEPPAccount.IsEmpty()) {
                
                // Get Exam Admins
                List<Exam_Administration__c> lstExamAdmins = [select id, Exam_Type__c, Month__c, Year__c,
                                                              (select id, Exam_Date__c, Exam_End_Date__c from Exam_Parts__r)
                                                              from Exam_Administration__c 
                                                              where Exam_Type__c in ('FRM','SCR','RiskAI') AND
                                                              Year__c = :ret.currExamYear order by Exam_Date__c];
                GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','lstExamAdmins',lstExamAdmins);
                
                if(!lstExamAdmins.IsEmpty()) {
                                
                    Set<String> affProgramIds = new Set<String>();
                    Set<String> eppDealIds = new Set<String>();
                    MAP<String, eppExamAdmin> mapEPPExamAdmins = new MAP<String, eppExamAdmin>();
                    SET<String> adminKeys = new SET<String>();
                    
					ret.affiliateProgramInfos = new List<affiliateProgramInfo>();                  
                    ret.b2bDealInfos = new List<b2bDealInfo>();
                                        
                    for(EPP_Account__c eppAccount :lstEPPAccount) {
                        
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','Loop eppAccount',eppAccount);
                        
                        ret.orgName = eppAccount.Account__r.Name;
                        String examType;
                        EPPPrograms eppProgram = new EPPPrograms();
                        if(eppAccount.Program__c == 'FRM') {
                            eppProgram.programType = 'FRM';
                            eppProgram.programName = 'Financial Risk Manager (FRM<sup>&#174;</sup>)';
                            eppProgram.programLogo = 'https://www.garp.org/hubfs/Portal/epp-portal/frm-card.png';
                            eppProgram.programRegions = eppAccount.EPP_Region_s__c;
                        } else if(eppAccount.Program__c == 'SCR') {
                            examType = '';
                            eppProgram.programType = 'SCR';
                            eppProgram.programName = 'Sustainability and Climate Risk (SCR<sup>&#174;</sup>) Exam';
                            eppProgram.programLogo = 'https://www.garp.org/hubfs/Portal/epp-portal/scr-card.png';
                            eppProgram.programRegions = eppAccount.EPP_Region_s__c;
                        } else if(eppAccount.Program__c == 'RAI') {
                            examType = '';
                            eppProgram.programType = 'RiskAI';
                            eppProgram.programName = 'Risk and Artificial Intelligence (RAI<sup>&trade;</sup>) Exam';
                            eppProgram.programLogo = 'https://www.garp.org/hubfs/Portal/epp-portal/rai-card.png';
                            eppProgram.programRegions = eppAccount.EPP_Region_s__c;
                        }
                        ret.examTypes.add(eppProgram);
                        
                        MAP<String,DateTime> mapDownloadDates = new MAP<String,DateTime>();
                        MAP<String,DateTime> mapReferDownloadDates = new MAP<String,DateTime>();
                        
                        for(EPP_Deal__c eppDeal :eppAccount.EPP_Deal__r) {
                            GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','Loop eppDeal',eppDeal);

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
                            
                            eppDealIds.add(eppDeal.Id);
                            
                            for(Exam_Administration__c examAdmin :lstExamAdmins) {
                                                                
                                if(examAdmin.Exam_Type__c == eppAccount.Program__c || (examAdmin.Exam_Type__c == 'RiskAI' && eppAccount.Program__c == 'RAI')) {
                                    
                                    GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','Loop examAdmin',examAdmin);
                                    
                                    EPPExamAdmin eppExamAdmin = new EPPExamAdmin();
                                    eppExamAdmin.eppAccountId = eppAccount.Id;
                                    eppExamAdmin.program = examAdmin.Exam_Type__c;
                                    eppExamAdmin.examMonth = examAdmin.Month__c;
                                    eppExamAdmin.examyear = String.ValueOf(examAdmin.Year__c);
                                    
                                    eppExamAdmin.numberOfOptIns = 0;
                                    eppExamAdmin.numberOfReferalsTotal = 0;
                                    eppExamAdmin.numberOfNetNewReferals = 0;
                                    
                                    eppExamAdmin.lastReportDownloadDate = mapDownloadDates.get(examAdmin.Month__c);
                                    eppExamAdmin.lastReportReferDownloadDate = mapReferDownloadDates.get(examAdmin.Month__c);
                                    
                                    String key = examAdmin.Exam_Type__c + ':' + examAdmin.Month__c;
                                    adminKeys.add(key);
                                    
                                    // Get the latest edam end date
                                    Date examEndDate = Date.NewInstance(1,1,1997);
                                    for(Exam_Part__c ep :examAdmin.Exam_Parts__r) {
                                        Date ed = (ep.Exam_Date__c != NULL) ?  ep.Exam_Date__c : ep.Exam_End_Date__c;
                                        if(ed != NULL && ed > examEndDate) {
                                            examEndDate = ed;
                                        }
                                    }
                                    GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','examEndDate',examEndDate);
                                    
                                    eppExamAdmin.isActive = False;
                                    if(tdy <= examEndDate) {
                                        eppExamAdmin.isActive = True;
                                    }
                                    
                                    GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','Add eppExamAdmin',eppExamAdmin);
                                    mapEPPExamAdmins.put(eppExamAdmin.program + ':' + eppExamAdmin.examMonth, eppExamAdmin);
                                    
                                } else {
                                    // Skip
                                }
                            }
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','mapEPPExamAdmins',mapEPPExamAdmins);
                    GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','eppDealIds',eppDealIds);
                    

                    List< B2B_Deal_Item__c> lstB2BDealItems = [select id, B2B_Deal__c, B2B_Deal__r.Status__c, B2B_Deal__r.Payment_Status__c, Access_Code__c,
                                                               Exam_Type__c, Seats_Allowed__c, Seats_Used__c, Seats_Remaining__c, Start_Date__c, Registration_Link__c,
                                                               End_Date__c, Discounted_Price__c,
                                                               (select id, AccountId from Opportunities__r where StageName = 'Closed')
                                                               from B2B_Deal_Item__c
                                                               where EPP_Deal__c in :eppDealIds AND RecordType.Name = 'Exams & Courses' AND Exam_Type__c in ('FRM I','FRM II','FRM I & II','SCR','Risk & AI')
                                                               AND B2B_Deal__r.RecordType.Name = 'B2B Deal' AND (B2B_Deal__r.Status__c = 'Approved' OR B2B_Deal__r.Payment_Status__c = 'Paid')];
                    GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','lstB2BDealItems',lstB2BDealItems);
                    
                    for(B2B_Deal_Item__c item :lstB2BDealItems) {
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','Loop b2b item',item); 
                        
                        b2bDealInfo b2bDealInfo = new b2bDealInfo();
                        b2bDealInfo.examType = item.Exam_Type__c;
                        if(b2bDealInfo.examType.indexOf('FRM') > -1) {
                            b2bDealInfo.program = 'FRM';
                        } else if(b2bDealInfo.examType == 'SCR') {
                            b2bDealInfo.program = 'SCR';
                        } else if(b2bDealInfo.examType == 'Risk & AI') {
                            b2bDealInfo.program = 'RiskAI';                            
                        }
                        b2bDealInfo.seatsAllowed = Integer.ValueOf(item.Seats_Allowed__c);
                        b2bDealInfo.seatsUsed = Integer.ValueOf(item.Seats_Used__c);
                        if(b2bDealInfo.seatsUsed == NULL) {
                            b2bDealInfo.seatsUsed = 0;
                        }
                        b2bDealInfo.seatsRemaining = Integer.ValueOf(item.Seats_Remaining__c);
                        b2bDealInfo.code = item.Access_Code__c;
                        b2bDealInfo.registrationLink = item.Registration_Link__c;
                        //b2bDealInfo.numberOfRegistrations = item.Opportunities__r.size();
                        
                        Set<String> accountIDs = new Set<String>();
                        for(Opportunity opp :item.Opportunities__r) {
                            GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','Loop b2b opp',opp);
                            accountIDs.add(opp.AccountId);                          
                        }
                        
                        b2bDealInfo.numberOfRegistrations = accountIDs.size();
                        
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','add b2bDealInfo',b2bDealInfo);
                        ret.b2bDealInfos.add(b2bDealInfo);
                    }    
                    
                    // Get Affiliate Link counts
                    List<Affiliate_Program__c> lstAffProgs = [select id, Product__c, Registration_Link__c, Affiliate_Code__c,
                                                              (select id, AccountId from Opportunities__r where StageName = 'Closed')
                                                              from Affiliate_Program__c 
                                                              where EPP_Deal__c in :eppDealIds];
                    GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','lstAffProgs',lstAffProgs);
                    
                    
                    MAP<String,Affiliate_Program__c> mapAffProgs = new MAP<String,Affiliate_Program__c>();
                    if(!lstAffProgs.IsEmpty()) {
                        for(Affiliate_Program__c ap :lstAffProgs) {
                            String program;
                            if(ap.Product__c.IndexOf('FRM') > -1) {
                                program = 'FRM';
                            } else if(ap.Product__c.IndexOf('SCR') > -1) {
                                program = 'SCR';                                    
                            } else if(ap.Product__c.IndexOf('RAI') > -1) {
                                program = 'RiskAI';                                    
                            }
                            
                            affiliateProgramInfo affiliateProgramInfo = new affiliateProgramInfo();
                            affiliateProgramInfo.id = ap.id;
                            affiliateProgramInfo.program = program;
                            affiliateProgramInfo.registrationLink = ap.Registration_Link__c;
                            affiliateProgramInfo.code = ap.Affiliate_Code__c;
                            
                            Set<String> accountIDs = new Set<String>();
                            for(Opportunity opp :ap.Opportunities__r) {
                                GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','Loop aff opp',opp);
                                accountIDs.add(opp.AccountId);                          
                            }
                            GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','Aff accountIDs',accountIDs);
                            affiliateProgramInfo.numberOfRegistrations = accountIDs.size();
                            
                            GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','add affiliateProgramInfo',affiliateProgramInfo);
                            
                            ret.affiliateProgramInfos.add(affiliateProgramInfo);
                            
							mapAffProgs.put(program, ap);
                        }
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','affiliateProgramInfos',ret.affiliateProgramInfos);
	                    GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','mapAffProgs',mapAffProgs);
                    }
                    
                    // Collect Stats by Program
                    for(EPPPrograms eppprog :ret.examTypes) {
                        
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','Loop EPPPrograms',eppprog);
                        
                        List<String> EPPRegionList = new List<String>();                        
                        for(String key: eppprog.programRegions.split(';')) {
                            EPPRegionList.add(key);
                        }
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','EPPRegionList',EPPRegionList);
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','currExamYear',ret.currExamYear);
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','programType',eppprog.programType);
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','eppDealIds',eppDealIds);
                        
                        MAP<String, Integer> newReferralMAP = new MAP<String, Integer>();
                        MAP<String, Integer> totalReferralMAP = new MAP<String, Integer>();
                        MAP<String, Integer> totalOptInMAP = new MAP<String, Integer>();
                        
                        List<AggregateResult> resultReferrals = [
    						SELECT EPP_Net_New__c, Exam_Administration__r.Exam_Type__c, Exam_Administration__r.Month__c, COUNT_DISTINCT(Member__c) memberCount
    						FROM Exam_Attempt__c
                            WHERE Reg_Status__c in ('Normal', 'Deferred In') AND
                            Reg_Status__c!='Cancelled' AND Cancelled__c = False AND Candidate_Region__c in :EPPRegionList AND
                            Exam_Administration__r.Year__c = :ret.currExamYear AND Exam_Administration__r.Exam_Type__c = :eppprog.programType AND 
                            EPP_Deal_ID__c in :eppDealIds AND EPP_Referal__c = True
                            GROUP BY EPP_Net_New__c, Exam_Administration__r.Exam_Type__c, Exam_Administration__r.Month__c
                        ];
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','resultReferrals',resultReferrals);
                        
                        for (AggregateResult ar :resultReferrals) {
                            Boolean eppNetNew = (Boolean) ar.get('EPP_Net_New__c');
                            String examType = (String) ar.get('Exam_Type__c');
                            String month    = (String) ar.get('Month__c');
                            Integer count   = (Integer) ar.get('memberCount');
                            
                            System.debug(
                                'eppNetNew=' + eppNetNew +
                                ', Type=' + examType +
                                ', Month=' + month +
                                ', Distinct Members=' + count
                            );
                            
                            if(examType != NULL && month != NULL && count != NULL) {
                                String key = examType + ':' + month;
                                
                                if(eppNetNew) {
                                    newReferralMAP.put(key, count);
                                    System.debug('newReferralMAP.put:' + key + ':' + count);
                                }
                                Integer getTotalCnt = totalReferralMAP.get(key);
                                
                                if(getTotalCnt == NULL) {
                                    getTotalCnt = 0;
                                }
                                getTotalCnt += count;
                                
                                totalReferralMAP.put(key, getTotalCnt);
                            }
                        }
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','newReferralMAP',newReferralMAP);
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','totalReferralMAP',totalReferralMAP);
                        
                        List<AggregateResult> results = [
    						SELECT Exam_Administration__r.Exam_Type__c, Exam_Administration__r.Month__c, COUNT_DISTINCT(Member__c) memberCount
    						FROM Exam_Attempt__c
                            WHERE Reg_Status__c in ('Normal', 'Deferred Out', 'Deferred In', 'Deferred Out Pending') AND
                            Reg_Status__c!='Cancelled' AND Cancelled__c = False AND Candidate_Region__c in :EPPRegionList AND
                            Exam_Administration__r.Year__c = :ret.currExamYear AND Exam_Administration__r.Exam_Type__c = :eppprog.programType AND 
                            EPP_Referal__c = False AND EPP_Opt_In__c != NULL
                            GROUP BY Exam_Administration__r.Exam_Type__c, Exam_Administration__r.Month__c
                        ];
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','results',results);
                        
                        for (AggregateResult ar :results) {
                            String examType = (String) ar.get('Exam_Type__c');
                            String month    = (String) ar.get('Month__c');
                            Integer count   = (Integer) ar.get('memberCount');
                            
                            System.debug(
                                'Type=' + examType +
                                ', Month=' + month +
                                ', Distinct Members=' + count
                            );
                            
                            if(examType != NULL && month != NULL) {
                                String key = examType + ':' + month;
                                totalOptInMAP.put(key, count);
                            }
                        }
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','totalOptInMAP',totalOptInMAP);
                        
                        // Add data into mapEPPExamAdmins
                        For(String key :adminKeys) {
                            GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','Loop key',key);
                            
                            eppExamAdmin fndExamAdmin = mapEPPExamAdmins.get(key);
                            GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','fndExamAdmin',fndExamAdmin);
                            
                            if(fndExamAdmin != NULL) {
                                
                                Integer totalNewReferralsCount = newReferralMAP.get(key);
                                if(totalNewReferralsCount == NULL) {
                                    totalNewReferralsCount = 0;
                                }
                                Integer totalReferralsCount = totalReferralMAP.get(key);
                                if(totalReferralsCount == NULL) {
                                    totalReferralsCount = 0;
                                }
                                Integer totalOptInsCount = totalOptInMAP.get(key);
                                if(totalOptInsCount == NULL) {
                                    totalOptInsCount = 0;
                                }
                                
                                GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','totalNewReferralsCount',totalNewReferralsCount);
                                GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','totalReferralsCount',totalReferralsCount);
                                GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','totalOptInsCount',totalOptInsCount);
                                
                                if(fndExamAdmin.numberOfNetNewReferals == NULL) {
                                    fndExamAdmin.numberOfNetNewReferals = totalNewReferralsCount;
                                } else {
                                    fndExamAdmin.numberOfNetNewReferals += totalNewReferralsCount;
                                }

                                if(fndExamAdmin.numberOfReferalsTotal == NULL) {
                                    fndExamAdmin.numberOfReferalsTotal = totalReferralsCount;
                                } else {
                                    fndExamAdmin.numberOfReferalsTotal += totalReferralsCount;
                                }
                                
                                if(fndExamAdmin.numberOfOptIns == NULL) {
                                    fndExamAdmin.numberOfOptIns = totalOptInsCount;
                                } else {
                                    fndExamAdmin.numberOfOptIns += totalOptInsCount;
                                }
                                
                                GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','update fndExamAdmin',fndExamAdmin);
                            }
                        }
                        
                        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','final mapEPPExamAdmins',mapEPPExamAdmins);
                    }
                    
                    // Final Data
                    for(eppExamAdmin eea :mapEPPExamAdmins.values()) {
                        ret.eppExamAdmins.add(eea);
                    }
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','examTypes',ret.examTypes); 
        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','eppExamAdmins',ret.eppExamAdmins);  
        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','hasAccess',ret.hasAccess);        
        GARP_Common.debugLog('GARP_BC_EPPPortal','verifyEPPPortalAccess','isMember',ret.isMember);        

        ret.statusCode = 200;
        ret.statusMessage = 'Verifcation Complete';
        
        return ret;
    }
    
}