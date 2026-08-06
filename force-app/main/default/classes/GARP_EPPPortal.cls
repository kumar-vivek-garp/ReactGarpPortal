public without sharing class GARP_EPPPortal {

    public String userName {get;set;}
    public String userEmail {get;set;}
    public String orgName {get;set;}
    public String examYear {get;set;}
    public Boolean hasAccess {get;set;}
    public Boolean blockUser {get;set;}
    public Boolean isMember {get;set;}
    
    public Boolean hasPrograms {get;set;}
    
    public String currentExamTab {get;set;}
    public String currentExamTabName {get;set;}
    public examAdminItemWrapper selectedAdminItem { get; set; }
    
    Public GARP_EPPPortal() {
        
    }
    
    public List<examAdminItemWrapper> examAdminList {get;set;}
    public List<eppTabWrapper> eppTabList {get;set;}
    
    public List<affItemWrapper> affList {get;set;}
    public List<b2bItemWrapper> b2bList {get;set;}
    
    public List<examAdminItemWrapper> getExamAdminFilteredList() {
        List<examAdminItemWrapper> filtered = new List<examAdminItemWrapper>();
        for (examAdminItemWrapper item : examAdminList) {
            if (item.program == currentExamTab) {
                filtered.add(item);
            }
        }
        return filtered;
    }

    public List<affItemWrapper> getAffFilteredList() {
        List<affItemWrapper> filtered = new List<affItemWrapper>();
        for (affItemWrapper item : affList) {
            if (item.program == currentExamTab) {
                filtered.add(item);
            }
        }
        return filtered;
    }

    public List<b2bItemWrapper> getB2BFilteredList() {
        List<b2bItemWrapper> filtered = new List<b2bItemWrapper>();
        for (b2bItemWrapper item : b2bList) {
            if (item.program == currentExamTab) {
                filtered.add(item);
            }
        }
        return filtered;
    }
    
    
    // List of SelectOption for picklist
    public List<SelectOption> getProgramOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for (eppTabWrapper w : eppTabList) {
            options.add(new SelectOption(w.programType, w.programType));
        }
        return options;
    }
    
    public void updateCurrentTab() {
        // currentTab is automatically updated via binding
        System.debug('Selected tab: ' + currentExamTab);
    }
    
    public PageReference init() {
        hasAccess = False;
        isMember = False;
        blockUser = False;
        hasPrograms = False;
        
        GARP_BC_EPPPortal.verifyEPPPortalAccessInfo verifyAccess =  GARP_BC_EPPPortal.verifyEPPPortalAccess();
        
        GARP_Common.debugLog('GARP_EPPPortal','init','verifyAccess.statusCode',verifyAccess.statusCode);
        GARP_Common.debugLog('GARP_EPPPortal','init','verifyAccess.hasAccess',verifyAccess.hasAccess);

        if(verifyAccess.statusCode == 200 && verifyAccess.hasAccess) {
            hasAccess = True;
            isMember = verifyAccess.isMember;
            userName = verifyAccess.userName;
            userEmail = verifyAccess.userEmail;
            orgName = verifyAccess.orgName;
            examYear = String.ValueOf(verifyAccess.currExamYear);
            examAdminList = new List<examAdminItemWrapper>();
            affList = new List<affItemWrapper>();
            b2bList = new List<b2bItemWrapper>();
            
            String examProg = ApexPages.currentPage().getParameters().get('examprog');
            if(examProg != NULL) {
                currentExamTab = examProg;
                if(currentExamTab == 'FRM') {
                    currentExamTabName = 'Financial Risk Manager';
                } else if(currentExamTab == 'SCR') {
                    currentExamTabName = 'Sustainability and Climate Risk';
                } else if(currentExamTab == 'RiskAI') {
                    currentExamTabName = 'Risk and Artificial Intelligence';
                }
            }
            GARP_Common.debugLog('GARP_EPPPortal','init','currentExamTab',currentExamTab);
            
            eppTabList = new List<eppTabWrapper>();
            
            if(!verifyAccess.eppExamAdmins.IsEmpty()) {
                
                for(GARP_BC_EPPPortal.EPPPrograms eppProgam :verifyAccess.examTypes) {
                    eppTabWrapper item = new eppTabWrapper(eppProgam);
                    GARP_Common.debugLog('GARP_EPPPortal','init','Add eppTabWrapper',item);
                    eppTabList.add(item);
                    hasPrograms = True;
                }
                
                for(GARP_BC_EPPPortal.EPPExamAdmin eppExamAdmin :verifyAccess.eppExamAdmins) {
                    
                    GARP_Common.debugLog('GARP_EPPPortal','init','**Loop eppExamAdmin',eppExamAdmin);
                    
                    examAdminItemWrapper item = new examAdminItemWrapper(eppExamAdmin);
                    GARP_Common.debugLog('GARP_EPPPortal','init','Add examAdminItemWrapper',item);
                    examAdminList.add(item);
                }
                GARP_Common.debugLog('GARP_EPPPortal','init','examAdminList',examAdminList);
                
				for(GARP_BC_EPPPortal.affiliateProgramInfo affiliateProgramInfo :verifyAccess.affiliateProgramInfos) {
                    affItemWrapper item = new affItemWrapper(affiliateProgramInfo);
                    GARP_Common.debugLog('GARP_EPPPortal','init','Add affItemWrapper',item);
                    affList.add(item);
                }
                GARP_Common.debugLog('GARP_EPPPortal','init','affList',affList);

				for(GARP_BC_EPPPortal.b2bDealInfo b2bDealInfo :verifyAccess.b2bDealInfos) {
                    b2bItemWrapper item = new b2bItemWrapper(b2bDealInfo);
                    GARP_Common.debugLog('GARP_EPPPortal','init','Add b2bItemWrapper',item);
                    b2bList.add(item);
                }
                GARP_Common.debugLog('GARP_EPPPortal','init','b2bList',b2bList);
                
            }
        } else {
            blockUser = True;
        }
        
        return null;
    }

    public class examAdminItemWrapper {
        public String program {get;set;}
        public String examMonth {get;set;}
        public String examyear {get;set;}
        public String eppDownloadId {get;set;}
        public DateTime lastDownloadDate {get;set;}
        public DateTime lastReferDownloadDate {get;set;}
        
        public Integer numberOfOptIns {get;set;}
        public Integer numberOfReferalsTotal {get;set;}
        public Integer numberOfNetNewReferals {get;set;}
        
        public Boolean isActive {get;set;}
        public Boolean hasFileDownload {get;set;}
        
        public examAdminItemWrapper(GARP_BC_EPPPortal.EPPExamAdmin eppExamAdmin) {
            program = eppExamAdmin.program;
            examMonth = eppExamAdmin.examMonth;
            examyear = eppExamAdmin.examyear;
            
            numberOfOptIns = eppExamAdmin.numberOfOptIns;
            numberOfReferalsTotal = eppExamAdmin.numberOfReferalsTotal;
            numberOfNetNewReferals = eppExamAdmin.numberOfNetNewReferals;
            
            eppDownloadId = eppExamAdmin.eppAccountId;
            
            lastDownloadDate = eppExamAdmin.lastReportDownloadDate;
            lastReferDownloadDate = eppExamAdmin.lastReportReferDownloadDate;
            
            isActive = eppExamAdmin.isActive;
            
            hasFileDownload = False;
            if((eppExamAdmin.numberOfOptIns > 0 && eppExamAdmin.isActive) || eppExamAdmin.numberOfReferalsTotal > 0) {
                hasFileDownload = True;
            }
        }         
    }
    
    public class affItemWrapper {
        public String program {get;set;}
        public String registrationLink {get;set;}
        public String code {get;set;}
        public Integer numberOfRegistrations {get;set;}
        
        public affItemWrapper(GARP_BC_EPPPortal.affiliateProgramInfo affItem) {
            program = affItem.program;
            registrationLink = affItem.registrationLink;
            numberOfRegistrations = affItem.numberOfRegistrations;
            code = affItem.code;
        }         
    }
    
    public class b2bItemWrapper {
        public String program {get;set;}
        public String registrationLink {get;set;}
        public String examType {get;set;}
        public String code {get;set;}
        public Integer seatsAllowed {get;set;}
        public Integer seatsUsed {get;set;}
        public Integer seatsRemaining {get;set;}
        public Integer numberOfRegistrations {get;set;}
        
        public b2bItemWrapper(GARP_BC_EPPPortal.b2bDealInfo b2bItem) {
            program = b2bItem.program;
            registrationLink = b2bItem.registrationLink;
            seatsAllowed = b2bItem.seatsAllowed;
            seatsUsed = b2bItem.seatsUsed;
            seatsRemaining = b2bItem.seatsRemaining;
            examType = b2bItem.examType;
            code = b2bItem.code;
            numberOfRegistrations = b2bItem.numberOfRegistrations;
        }         
    }
    
    public class eppTabWrapper {
		public String programType {get;set;}
        public String programName {get;set;}
        public String programLogo {get;set;}
        public String programRegions {get;set;}
        
        public eppTabWrapper(GARP_BC_EPPPortal.EPPPrograms eppProgram) {
            programType = eppProgram.programType;
            programName = eppProgram.programName;
            programLogo = eppProgram.programLogo;
            programRegions = eppProgram.programRegions;
        }
    }
    
    
    
    
}