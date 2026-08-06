global class GARP_MemberProfileSummaryBatch implements Database.Batchable<sObject>{

    // Run all
    //Database.executeBatch(new GARP_MemberProfileSummaryBatch('all',NULL,NULL,'normal',true, true)); 
    
    // Run all needed
    //Database.executeBatch(new GARP_MemberProfileSummaryBatch('needed',NULL,NULL,'normal',true, false)); 

    // Run needed on 1 contact
    //Database.executeBatch(new GARP_MemberProfileSummaryBatch('needed',NULL,'0034000001acwmY','fine',false, false)); 

    // Run 1 contact force
    // Database.executeBatch(new GARP_MemberProfileSummaryBatch('user','0035d00007I9INe',NULL,'fine',true, true));
    
    public String mode; 
    public String modeParam; 
    public String contactId; 
    public String debug; 
    public Boolean doUpdates;
    public Boolean forceOppUpdates;
    public DateTime runStartDateTime;
    
    global GARP_MemberProfileSummaryBatch(String modeIn, String modeParamIn, String contactIn, String debugIn, Boolean doUpdatesIn, Boolean forceOppUpdatesIn) {
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','GARP_MemberProfileSummaryBatch','modeIn',modeIn);
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','GARP_MemberProfileSummaryBatch','modeParamIn',modeParamIn);
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','GARP_MemberProfileSummaryBatch','debugIn',debugIn);
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','GARP_MemberProfileSummaryBatch','doUpdatesIn',doUpdatesIn);
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','GARP_MemberProfileSummaryBatch','forceOppUpdatesIn',forceOppUpdatesIn);
        
        this.mode = modeIn;   
        this.modeParam = modeParamIn;   
        this.contactId = contactIn;
        if(debugIn == null) {
            this.debug = 'none';
        } else {
            this.debug = debugIn;       
        }
        this.doUpdates = doUpdatesIn;
        this.forceOppUpdates = forceOppUpdatesIn;
        
        this.runStartDateTime = DateTime.now();
        
        System.debug('**constructor***runStartDateTime:' + this.runStartDateTime);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        String query;
        
        if(mode == 'all') {
            query = 'SELECT Id, AccountId, Member_Profile_Summary__c, Member_Profile_Last_Updated__c FROM Contact where Recordtype.DeveloperName = \'Member\' AND IS_TEST__c = FALSE order by CreatedDate DESC';
        } else if(mode == 'unknown') {
            query = 'SELECT Id, AccountId, Member_Profile_Summary__c, Member_Profile_Last_Updated__c FROM Contact where Recordtype.DeveloperName = \'Member\' AND IS_TEST__c = FALSE AND Member_Profile_Summary__r.Orders_First_Type__c = \'Unknown\'';
        } else if(mode == 'batch') {
            query = 'SELECT Id, AccountId, Member_Profile_Summary__c, Member_Profile_Last_Updated__c FROM Contact where Account.batch__c = True';
        } else if(mode == 'user') {
            query = 'SELECT Id, AccountId, Member_Profile_Summary__c, Member_Profile_Last_Updated__c FROM Contact where id = :modeParam';
        } else if(mode == 'needed') {
            
            //Date lastUpdatedDate;
            //if(modeParam == NULL) {
            //    lastUpdatedDate = Date.Today().AddDays(-1);
            //} else {
            //    lastUpdatedDate = Date.ValueOf(modeParam);   
            //}
            //GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','start','lastUpdatedDate',lastUpdatedDate);            
            
            //query = 'SELECT Id, AccountId, Member_Profile_Summary__c, Member_Profile_Last_Updated__c FROM Contact where Recordtype.DeveloperName = \'Member\' AND IS_TEST__c = FALSE AND (Member_Profile_Last_Updated__c = NULL OR Member_Profile_Last_Updated__c < :lastUpdatedDate)';
            query = 'SELECT Id, AccountId, Member_Profile_Summary__c, Member_Profile_Last_Updated__c FROM Contact where Recordtype.DeveloperName = \'Member\' AND IS_TEST__c = FALSE';
            if(contactId != NULL) {
                query = 'SELECT Id, AccountId, Member_Profile_Summary__c, Member_Profile_Last_Updated__c FROM Contact where Recordtype.DeveloperName = \'Member\' AND IS_TEST__c = FALSE AND id = :contactId';
            }
        }
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','start','query',query);
        
        System.debug('**start***runStartDateTime:' + this.runStartDateTime);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        Set<String> accountIDs = new Set<String>();
        Set<String> contactIDs = new Set<String>();
        Set<Contact> neededContacts = new Set<Contact>();
        
        MAP<String,String> mapExistingMemProfileIdContactIds = new MAP<String,String>();
        MAP<String,Member_Profile_Summary__c> mapContactMemProfiles = new MAP<String,Member_Profile_Summary__c>();
        
        Set<String> neededAccountIDs = new Set<String>();
        Set<String> neededContactIDs = new Set<String>();
        
        // Holds the latest date of contact's stuff
        MAP<String,DateTime> mapContactLastUpdate = new MAP<String,DateTime>();
        
        Date tdy = Date.Today();
        DateTime now = DateTime.now();
        
        // Last Time MPS Ran
        Default_Settings__c settings = Default_Settings__c.getAll().get('Default'); 
                
        System.debug('**execute***runStartDateTime:' + this.runStartDateTime);
        
        if(mode == 'needed') {
            
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','Find needed',modeParam);
            
            MAP<String, String> mapAccountIdToContactId = new MAP<String, String>();
                        
            for(Contact cont :scope) {
                accountIDs.add(cont.AccountId);
                contactIDs.add(cont.Id);
                mapAccountIdToContactId.put(cont.AccountId, cont.Id);
            }
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','accountIDs',accountIDs);
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','contactIDs',contactIDs);
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','mapAccountIdToContactId',mapAccountIdToContactId);
            
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','now',now);
            
            DateTime lastMPSRun = DateTime.newInstance(1970,1,1,0,0,0);
            if(settings != NULL && settings.MPS_Last_Run__c != NULL) {            
                lastMPSRun = settings.MPS_Last_Run__c;
            }
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','lastMPSRun',lastMPSRun);

            //lastMPSRun = lastMPSRun.dateGMT();
            //GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','lastMPSRun GMT',lastMPSRun);
            
            MAP<String, Date> mapContactLatestUpdate = new MAP<String, Date>();
            MAP<String, Date> mapAccountLatestUpdate = new MAP<String, Date>();
            
            List<Contract> lstNeedContracts = [select Id, AccountId, LastModifiedDate from Contract where AccountId in :accountIDs AND LastModifiedDate > :lastMPSRun];
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','lstNeedContracts',lstNeedContracts);
            
            for(Contract cont :lstNeedContracts) {
                String contactId = mapAccountIdToContactId.get(cont.AccountId);
                if(contactId != NULL) {
                    //DateTime lastMod = mapContactLastUpdate.get(cont.AccountId);
                    //if(lastMod == NULL || lastMod > cont.LastModifiedDate) {
                        neededAccountIDs.add(cont.AccountId); 
                        //mapContactLastUpdate.put(contactId, cont.LastModifiedDate);
                    //}
                }
            }
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','neededAccountIDs 1',neededAccountIDs);
            
            List<Candidate_Requirement__c> lstNeedProgramRequirements = [select Id, LastModifiedDate, Candidate_Commitment__r.AccountId from Candidate_Requirement__c where Candidate_Commitment__r.AccountId in :accountIDs AND LastModifiedDate > :lastMPSRun];
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','lstNeedProgramRequirements',lstNeedProgramRequirements); 
            
            for(Candidate_Requirement__c pr :lstNeedProgramRequirements) {                
                String contactId = mapAccountIdToContactId.get(pr.Candidate_Commitment__r.AccountId);
                if(contactId != NULL) {
                    //DateTime lastMod = mapContactLastUpdate.get(pr.Candidate_Commitment__r.AccountId);
                    //if(lastMod == NULL || lastMod > pr.LastModifiedDate) {
                        neededAccountIDs.add(pr.Candidate_Commitment__r.AccountId); 
                        //mapContactLastUpdate.put(contactId, pr.LastModifiedDate);
                    //}
                }
            }
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','neededAccountIDs 2',neededAccountIDs);
            
            List<Exam_Attempt__c> lstNeedExamAttempts = [select Id, Member__c, LastModifiedDate from Exam_Attempt__c where Member__c in :contactIDs AND LastModifiedDate > :lastMPSRun];
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','lstNeedExamAttempts',lstNeedExamAttempts);
            
            for(Exam_Attempt__c ea :lstNeedExamAttempts) {
                //DateTime lastMod = mapContactLastUpdate.get(ea.Member__c);
                //if(lastMod == NULL || lastMod > ea.LastModifiedDate) {
                    neededContactIDs.add(ea.Member__c);
                    //mapContactLastUpdate.put(ea.Member__c, ea.LastModifiedDate);
                //}
            }            
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','neededContactIDs 3',neededContactIDs);
            
            List<Opportunity> lstNeedOpps = [select Id, AccountId, LastModifiedDate, Order_Summary_Last_Updated_Date__c 
                                             from Opportunity 
                                             where AccountId in :accountIDs AND ia_crm__Intacct_Transaction__c != 'Salesforce - Refund'];
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','lstNeedOpps',lstNeedOpps);
            
            for(Opportunity opp :lstNeedOpps) {
                String contactId = mapAccountIdToContactId.get(opp.AccountId);
                if(contactId != NULL) {
                    
                    GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','opp',opp);
                    
                    if(opp.Order_Summary_Last_Updated_Date__c == NULL || opp.LastModifiedDate > opp.Order_Summary_Last_Updated_Date__c) {
                        neededAccountIDs.add(opp.AccountId); 
                    }
                }
            }
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','neededAccountIDs 4',neededAccountIDs);
            
            List<Event_Registration__c> lstNeedEventRegistrations = [select Id, Contact__c,LastModifiedDate from Event_Registration__c where LastModifiedDate > :lastMPSRun AND Contact__c in :contactIDs]; 
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','lstNeedEventRegistrations',lstNeedEventRegistrations);
            
            for(Event_Registration__c er :lstNeedEventRegistrations) {
                //DateTime lastMod = mapContactLastUpdate.get(er.Contact__c);
                //if(lastMod == NULL || lastMod > er.LastModifiedDate) {
                    neededContactIDs.add(er.Contact__c);
                    //mapContactLastUpdate.put(er.Contact__c, er.LastModifiedDate);
                //}
            }
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','neededContactIDs 5',neededContactIDs);
            
            List<Webcast_Registration__c> lstNeedWebcastRegistrations = [select Id, Contact__c, LastModifiedDate from Webcast_Registration__c where LastModifiedDate > :lastMPSRun AND Contact__c in :contactIDs]; 
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','lstNeedWebcastRegistrations',lstNeedWebcastRegistrations);
            
            for(Webcast_Registration__c wr:lstNeedWebcastRegistrations) {
                //DateTime lastMod = mapContactLastUpdate.get(wr.Contact__c);
                //if(lastMod == NULL || lastMod > wr.LastModifiedDate) {
                    neededContactIDs.add(wr.Contact__c);
                    //mapContactLastUpdate.put(wr.Contact__c, wr.LastModifiedDate);
                //}
            }
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','neededContactIDs 6',neededContactIDs);
            
            List<Chapter_Meeting_Registration__c> lstNeedChapterMeetingRegistrations = [select Id, Contact__c,LastModifiedDate from Chapter_Meeting_Registration__c where LastModifiedDate > :lastMPSRun AND Contact__c in :contactIDs]; 
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','lstNeedChapterMeetingRegistrations',lstNeedChapterMeetingRegistrations);
            
            for(Chapter_Meeting_Registration__c cmr :lstNeedChapterMeetingRegistrations) {
                //DateTime lastMod = mapContactLastUpdate.get(cmr.Contact__c);
                //if(lastMod == NULL || lastMod > cmr.LastModifiedDate) {
                    neededContactIDs.add(cmr.Contact__c);
                    //mapContactLastUpdate.put(cmr.Contact__c, cmr.LastModifiedDate);
                //}
            }
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','neededContactIDs final',neededContactIDs);
            
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','neededContactIDs',neededContactIDs);
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','neededAccountIDs',neededAccountIDs);
            
            // Reset to blank
            accountIDs = new Set<String>();
            contactIDs = new Set<String>();
            
        }
               
        List<Contact> lstNewContacts = new List<Contact>();
        List<Contact> lstExsitingContacts = new List<Contact>();
        for(Contact cont :scope) {  
            
            if(debug=='fine')
                GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','Loop contact',cont);
            
            // Existing Member_Profile_Summary
            if(cont.Member_Profile_Summary__c != NULL) {
                
                if(mode != 'needed' || neededContactIDs.contains(cont.Id) || neededAccountIDs.contains(cont.AccountId)) {

                    if(debug=='fine')
                        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','Yes Needed',cont.Id);
                    
                    mapExistingMemProfileIdContactIds.put(cont.Member_Profile_Summary__c, cont.Id);
                    lstExsitingContacts.add(cont);
                    accountIDs.add(cont.AccountId);
                    contactIDs.add(cont.Id);
                    neededContacts.add(cont);
                }
            } else {
                // New Member_Profile_Summary
                lstNewContacts.add(cont);
                Member_Profile_Summary__c newMemProfile = new Member_Profile_Summary__c();
                newMemProfile.ContactId__c = cont.Id;
                mapContactMemProfiles.put(cont.Id, newMemProfile);
                accountIDs.add(cont.AccountId);
                contactIDs.add(cont.Id);
                neededContacts.add(cont);
            }   
        }
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','mapExistingMemProfileIdContactIds',mapExistingMemProfileIdContactIds);
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','mapContactMemProfiles',mapContactMemProfiles);
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','lstNewContacts',lstNewContacts);

        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','accountIDs',accountIDs);
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','contactIDs',contactIDs);
        GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','neededContacts',neededContacts);

        GARP_BC_MemberProfile.calcMemberProfileSummary(mapExistingMemProfileIdContactIds, mapContactMemProfiles, accountIDs, contactIDs, neededContacts, lstNewContacts, lstExsitingContacts, debug, doUpdates, forceOppUpdates);
        
    }
    
    public static String getExamResult(String examResultIn) {
        String normalizedExamResult;
        if(examResultIn != NULL) {
            String examResultLow = examResultIn.ToLowerCase();
            if(examResultLow.IndexOf('show') > -1) {
                normalizedExamResult = 'No Show';
            } else if(examResultLow.IndexOf('graded') > -1) {
                normalizedExamResult = 'Not Graded';
            } else {
                normalizedExamResult = examResultIn;
            }
        }
        
        return normalizedExamResult;
    }
    
    public static String getExamScore(Exam_Attempt__c examAttempt, String debug) {
        // Calc Score
        Decimal score = 0;
        Integer count = 0;
        if(examAttempt.Quartile_1__c != NULL) {
            score += examAttempt.Quartile_1__c;
            count++;
        }
        if(examAttempt.Quartile_2__c != NULL) {
            score += examAttempt.Quartile_2__c;
            count++;
        }
        if(examAttempt.Quartile_3__c != NULL) {
            score += examAttempt.Quartile_3__c;
            count++;
        }
        if(examAttempt.Quartile_4__c != NULL) {
            score += examAttempt.Quartile_4__c;
            count++;
        }
        if(examAttempt.Quartile_5__c != NULL) {
            score += examAttempt.Quartile_5__c;
            count++;
        }
        if(examAttempt.Quartile_6__c != NULL) {
            score += examAttempt.Quartile_6__c;
            count++;
        }
        if(examAttempt.Quartile_7__c != NULL) {
            score += examAttempt.Quartile_7__c;
            count++;
        }
        if(examAttempt.Quartile_8__c != NULL) {
            score += examAttempt.Quartile_8__c;
            count++;
        }
        if(debug=='fine')
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getExamScore','score',score);
        if(debug=='fine')
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getExamScore','count',count);
        
        String scoreName;
        if(count > 0 && score > 0) {
            Decimal ratio = score / count;
            if(debug=='fine')
                GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getExamScore','ratio',ratio);
            
            if(ratio > 0 && ratio <= 1.5) {
                scoreName = 'Excellent';
            } else if(ratio > 1.5 && ratio <= 2.5) {
                scoreName = 'Good';
            } else if(ratio > 2.5 && ratio <= 3.5) {
                scoreName = 'Fair';
            } else {
                scoreName = 'Poor';
            }
            if(debug=='fine')
                GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getExamScore','last score',scoreName);
        }
        return scoreName;
    }

    public static Date getExamAdminDate(Exam_Attempt__c examAttempt) {
        map<String, String> monthMap = new map<String, String> {
            'January' => '1',
                'February' => '2',
                'March' => '3',
                'April' => '4',
                'May' => '5',
                'June' => '6',
                'July' => '7',
                'August' => '8',
                'September' => '9',
                'October' => '10',
                'November' => '11',
                'December' => '12'
                };
                    
        Date dt;
        String m = monthMap.get(examAttempt.RPT_Administration_Month__c);
        if(m != NULL) {
            dt = Date.ValueOf(examAttempt.RPT_Administration_Year__c + '-' + m + '-1');
        }
        return dt;
    }
    
    
    public class oppInfo {
        String oppType;
        Boolean hasStudyMaterials;
        Boolean hasMembership;
        Decimal membershipAmount;
    }
    
    public static oppInfo getOppTypeName(Opportunity opp, MAP<String, String> mapOppEventRegs, String debug) {
        oppInfo oppInfo = new oppInfo();
        oppInfo.oppType = 'Unknown';
        oppInfo.hasStudyMaterials=False;
        oppInfo.hasMembership=False;
        oppInfo.membershipAmount=0;
        
        if(debug=='fine')
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getOppTypeName','opp',opp);
        if(debug=='fine')
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getOppTypeName','mapOppEventRegs',mapOppEventRegs);
        
        Set<String> frmMainProductCodes = new Set<String>{'FRM1E','FRM1S','FRM1L','FRM2E','FRM2S','FRM2L'};
        Set<String> erpMainProductCodes = new Set<String>{'ENC1E','ENC1S','ENC1L','ENC2E','ENC2S','ENC2L'};
        Set<String> scrMainProductCodes = new Set<String>{'SCRCME','SCRCMS','SCRME','SCRMS','SCRNME','SCRNMS','SCR2A'};
        Set<String> frrMainProductCodes = new Set<String>{'CBR','CBRNM','CBR2A'};
        Set<String> ffrMainProductCodes = new Set<String>{'FCBR','FBRNM'};
        Set<String> membershipProductCodes = new Set<String>{'MEMI','MEMC','MEMF','MEMS','AFREE'};  
        Set<String> studyMaterialsProductCodes = new Set<String>{'FRM1H','FRM1X','FRM2H','FRM2X','FRMC1','FRMC2','ENC1B','ENC1X','ENC2B','ENC2X','ENCC1','ENCC2','SCRH','SCRX','SCRCN','SCRBP','CBRHB','CBRX','FFRXF'}; 
        Set<String> certReplaceMainProductCodes = new Set<String>{'DCERTFRM','DCERTSCR'};
        Set<String> examRescheduleMainProductCodes = new Set<String>{'FRM1','FRM2'};
            
        if(!opp.OpportunityLineItems.IsEmpty()) {
            String mainProductName;
            for(OpportunityLineItem oli :opp.OpportunityLineItems) {
                
                if(debug=='fine')
                    GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getOppTypeName','Loop line',oli);
                
                String fndEventReg = mapOppEventRegs.get(opp.Id);
                if(debug=='fine')
                    GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getOppTypeName','fndEventReg',fndEventReg);
                
                if(frmMainProductCodes.contains(oli.ProductCode)) {
                    mainProductName = 'FRM';
                } else if(erpMainProductCodes.contains(oli.ProductCode)) {
                    mainProductName = 'ERP';
                } else if(scrMainProductCodes.contains(oli.ProductCode)) {
                    mainProductName = 'SCR';
                } else if(frrMainProductCodes.contains(oli.ProductCode)) {
                    mainProductName = 'FRR';
                } else if(ffrMainProductCodes.contains(oli.ProductCode)) {
                    mainProductName = 'FFR';
                } else if(certReplaceMainProductCodes.contains(oli.ProductCode)) {
                    mainProductName = 'Certificate Replacement';
                } else if(examRescheduleMainProductCodes.contains(oli.ProductCode) && oli.Product2.GL_Code__c == '4020') {
                    mainProductName = 'Exam Reschedule';
                } else if(fndEventReg != NULL) {
                    mainProductName = 'Event';
                }
                if(debug=='fine')
                    GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getOppTypeName','mainProductName',mainProductName);
                
                if(membershipProductCodes.contains(oli.ProductCode)) {
                    oppInfo.hasMembership = TRUE;
                    oppInfo.membershipAmount = oli.TotalPrice;
                }
                if(studyMaterialsProductCodes.contains(oli.ProductCode)) {
                    oppInfo.hasStudyMaterials = TRUE;
                } else if(oli.Description != NULL && oli.Description.ToLowerCase().IndexOf('handbook') > -1) {
                    oppInfo.hasStudyMaterials = TRUE;
                }
                if(debug=='fine')
                    GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getOppTypeName','hasMembership',oppInfo.hasMembership);
                if(debug=='fine')
                    GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','getOppTypeName','hasStudyMaterials',oppInfo.hasStudyMaterials);
            }
            if(mainProductName == NULL && oppInfo.hasStudyMaterials) {
                oppInfo.oppType = 'Study Materials';
            } else if(mainProductName == NULL && oppInfo.hasMembership) {
                oppInfo.oppType = 'Membership';
            } else if(mainProductName != NULL) {
                oppInfo.oppType = mainProductName;
            }
        }
        return oppInfo;
    }
    
    global void finish(Database.BatchableContext BC){
        
        System.debug('**finish***runStartDateTime:' + this.runStartDateTime);
        
        Default_Settings__c settings = Default_Settings__c.getAll().get('Default'); 
        if(doUpdates && settings != NULL) {
            settings.MPS_Last_Run__c = this.runStartDateTime;
            update settings;
            GARP_Common.debugLog('GARP_MemberProfileSummaryBatch','execute','set lastMPSRun',settings.MPS_Last_Run__c);
        }
    }

}