global class UpdateKPI implements Database.Batchable<sObject>,Database.StateFul{
    
    public String mode;  
    public Boolean batch;
    
    global UpdateKPI (String inMode){
        this.mode = inMode;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Date dtToday = system.today();
        String testID = NULL;
        String[] arrText;
        String Paid_Active = 'Paid Active';
        String Lapsed_Active = 'Lapsed Active';
        String Paid_New = 'Paid New';
        String Lapsed_In_Active = 'Lapsed In-Active';
        String Paid_In_Active = 'Paid In-Active';
        String cycle1 = '2021/2022';
        String cycle2 = '2022/2023';
        batch = false;
        
        String Paid_Precycle = 'Paid Precycle';
        String Lapsed_Precycle = 'Lapsed Precycle';
        String cycle3 = '2021/2022';
        String cycle4 = '2022/2023';
        
        Integer currYear = dtToday.year();
        if(dtToday.month() == 12) {
            currYear++;
        }
        String CurrentExamYear = String.valueOf(currYear);
        String CurrentExamMonthName = 'Nov';
        if(dtToday.month() >= 1 && dtToday.month() <= 4) {
            CurrentExamMonthName = 'May';
        }
        system.debug('CurrentExamMonthName:' + CurrentExamMonthName);
        system.debug('CurrentExamYear:' + CurrentExamYear);

        //system.assert(false, 'BOOM!'+ CurrentExamYear);
        
        
        if(mode != null && mode.indexOf('~') > -1) {
            arrText = mode.split('~');                    
            if(arrText.size() > 1) {
                mode =   arrText[0];
                if(arrText[1] == 'NULL')
                    testID = NULL;
                else testID = arrText[1];  
                if(testID != NULL && testID == 'batch') {
                    batch = true;
                }
            }
            if(arrText.size() > 2) {
                String strDate = arrText[2];
                String[] arrTextDate = strDate.split(':');    
                dtToday = Date.newInstance(Integer.valueOf(arrTextDate[0]),Integer.valueOf(arrTextDate[1]),Integer.valueOf(arrTextDate[2]));
            }
        }
        
        system.debug('mode:' + mode);
        system.debug('batch:' + batch);
        system.debug('testID:' + testID);
        system.debug('dtToday:' + dtToday);
        Id memberRecordTypeID = RecordTypeHelper.GetRecordTypeId('Contact','Member');
        String query = '';
        
        if(mode != null && mode == 'memberprogramcountdown') {
            Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
            List<Contract> plist = [select accountId from Contract where RecordTypeId = :recordTypeID and (Status = 'Activated' or Status = 'Activated ( Auto-Renew )') and (Membership_Type__c = 'Individual' or Membership_Type__c = 'Student') and Days_Left__c > -1 and Days_Left__c < 31 order by accountId]; 
            List<ID> ids = new List<ID>();
            for(Contract c :plist)
                ids.add(c.accountId);
            List<Account> aList = [Select Id from Account where Id in :ids];
            
            
            
            if(testID != null && batch == false) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and id = :testID ';
            } else if(testID != null && batch == true) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and Processed_By_Batch__c = true ';
            } else {
                query = 'Select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and accountId in :aList and KPI_Last_Updated_Date__c !=: dtToday';    
            }
            
            
           } else if(mode != null && mode == 'precycle') {
            if(testID != null && batch == false) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and id = :testID ';
            } else if(testID != null && batch == true) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and Processed_By_Batch__c = true ';
            } else {
                query = 'Select Id, Name, AccountId, KPI_Last_Updated_Date__c From Contact WHERE RecordTypeId = :memberRecordTypeID and (KPI_CPE_Current_Cycle__c = :cycle3 OR KPI_CPE_Current_Cycle__c = :cycle4) and KPI_CPE_Participation__c = false and (CPD_User_Type_Name__c = :Paid_Precycle OR CPD_User_Type_Name__c = :Lapsed_Precycle) and KPI_Last_Updated_Date__c !=: dtToday';   
            }
            
        } else if(mode != null && mode == 'claim') {
            if(testID != null && batch == false) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and id = :testID ';
            } else if(testID != null && batch == true) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and Processed_By_Batch__c = true ';
            } else {
                query = 'Select Id, Name, AccountId, KPI_Last_Updated_Date__c From Contact WHERE RecordTypeId = :memberRecordTypeID and (KPI_CPE_Current_Cycle__c = :cycle1 OR KPI_CPE_Current_Cycle__c = :cycle2) and KPI_CPE_Participation__c = true and (CPD_User_Type_Name__c = :Paid_Active OR CPD_User_Type_Name__c = :Lapsed_Active OR CPD_User_Type_Name__c = :Paid_New OR CPD_User_Type_Name__c = :Paid_In_Active OR CPD_User_Type_Name__c = :Lapsed_In_Active) and KPI_Last_Updated_Date__c !=: dtToday';   
            }
            
        } else if(mode != null && mode == 'memberprogram') {

            if(testID != null && batch == false) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and Membership_Type__c = \'Individual\' and id = :testID ';
            } else if(testID != null && batch == true) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and Membership_Type__c = \'Individual\' and Processed_By_Batch__c = true ';
            } else {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and Membership_Type__c = \'Individual\' and KPI_Last_Updated_Date__c !=: dtToday';    
            }    
            
        } else if(mode != null && mode == 'currentexamattempt') {

            if(testID != null && batch == false) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and id = :testID ';
            } else if(testID != null && batch == true) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and Processed_By_Batch__c = true ';
            } else {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and KPI_Last_Updated_Date__c !=: dtToday and Id in (SELECT member__c FROM Exam_Attempt__c where (RPT_Exam_FRM_ERP__c = \'FRM\' OR RPT_Exam_FRM_ERP__c = \'ERP\') and RPT_Exam_Year__c = :CurrentExamYear and RPT_Exam_Month__c = :CurrentExamMonthName and Reg_Status__c != \'Cancelled\')';    
            }       
        } else if(mode != null && mode == 'fixexamattempt') {

            if(testID != null && batch == false) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and id = :testID ';
            } else if(testID != null && batch == true) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and Processed_By_Batch__c = true ';
            } else {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and KPI_Last_Updated_Date__c !=: dtToday and Id in (SELECT member__c FROM Exam_Attempt__c where  (RPT_Exam_FRM_ERP__c = \'FRM\' OR RPT_Exam_FRM_ERP__c = \'ERP\') and RPT_Exam_Year__c = :CurrentExamYear and RPT_Exam_Month__c = :CurrentExamMonthName and Reg_Status__c != \'Cancelled\' and Member__r.KPI_Current_Exam_Registration__c = \'\')';    
            }       
            
        } else {
            if(testID != null && batch == false) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and id = :testID ';
            } else if(testID != null && batch == true) {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and Processed_By_Batch__c = true ';
            } else {
                query = 'select Id, Name, AccountId, KPI_Last_Updated_Date__c from Contact where RecordTypeId = :memberRecordTypeID and KPI_Last_Updated_Date__c !=: dtToday';    
            }            
        }
         system.debug('query:' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        List<Id> ids = new List<Id>();
        List<Contact> clist = new List<Contact>();
        for(Contact con : scope) {
            ids.add(con.AccountId);
            clist.add(con);
        }
        List<Account> alist = [select Id, Name from Account where id in :ids]; 
        
        List<Exam_Attempt__c> elist;
        if(mode == null || mode.indexOf('examattempt') > -1) 
            elist = [Select Id, Name, Member__c from Exam_Attempt__c where Member__C in :clist];
        
        List<Contract> plist;
        if(mode == null || (mode!=null && mode.indexOf('contract') > -1))
            plist = [select Id, Name, AccountId from Contract where accountId in :alist]; 

        if(mode == 'memberprogram') {
            Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
            plist = [select accountId from Contract where accountId in :alist and RecordTypeId = :recordTypeID and Status != 'Draft']; 
        }
        
        if(mode == 'memberprogramcountdown') {
            Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
            plist = [select Id from Contract where accountId in :alist and RecordTypeId = :recordTypeID and (Status = 'Activated' or Status = 'Activated ( Auto-Renew )') and (Membership_Type__c = 'Individual' or Membership_Type__c = 'Student') and Days_Left__c > -1 and Days_Left__c < 31]; 
        }
        
        
        
       if(mode == 'precycle') {
            Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','CPE');
            plist = [select accountId from Contract where accountId in :alist and RecordTypeId = :recordTypeID and (Status = 'Activated' or Status = 'Activated ( Auto-Renew )')]; 
        }  
        
        
        
        List<CPE_Claim__c> claimList;
        if(mode == null || (mode!=null && mode.indexOf('claim') > -1))         
            claimList = [select Id, Name, Candidate_Requirement__r.Candidate_Commitment__r.AccountId from CPE_Claim__c where Candidate_Requirement__r.Candidate_Commitment__r.AccountId in :ids];
        
        List<Contract> lstContract = new List<Contract>();
        List<Exam_Attempt__c> lstEa = new List<Exam_Attempt__c>();
        List<CPE_Claim__c> lstClaim = new List<CPE_Claim__c>();
        
        if(mode == null || (mode!=null && (mode.indexOf('contract') > -1  || mode == 'datejoined'))) {
            MAP<ID,ID> contractMap = new MAP<ID,ID>();
            for(Contract con : plist) {
                if(con.AccountId != null) {
                    ID fnd = contractMap.get(con.AccountId);
                    if(fnd == null) { 
                        lstContract.add(con);
                        //system.debug('* * * Contracts: ' + con.Name);
                    }
                    contractMap.put(con.AccountId,con.Id);
                }
            }            
            update lstContract;
        }
        
        if(mode == null || (mode!=null && mode.indexOf('memberprogram') > -1) || (mode!=null && mode.indexOf('precycle') > -1)) {
            update plist;
        }
        
        if(mode == null || (mode!=null && mode.indexOf('examattempt') > -1)) {   
            MAP<ID,ID> examattemptMap = new MAP<ID,ID>();
            for(Exam_Attempt__c ea : elist) {
                if(ea.Member__C != null) {
                    ID fnd = examattemptMap.get(ea.Member__C);
                    if(fnd == null) { 
                        lstEa.add(ea);
                        system.debug('* * * examattempt: ' + ea.Name);
                    }
                    examattemptMap.put(ea.Member__C,ea.Id);
                }
            }            
            update lstEa;
        }
        
        if(mode == null || (mode!=null && mode.indexOf('claim') > -1)) {   
            MAP<ID,ID> claimMap = new MAP<ID,ID>();
            for(CPE_Claim__c claim : claimList) {
                if(claim.Candidate_Requirement__r.Candidate_Commitment__r.AccountId != null) {
                    ID fnd = claimMap.get(claim.Candidate_Requirement__r.Candidate_Commitment__r.AccountId);
                    if(fnd == null) { 
                        lstClaim.add(claim);
                        system.debug('* * * Claim: ' + claim.Name);
                    }
                    claimMap.put(claim.Candidate_Requirement__r.Candidate_Commitment__r.AccountId,claim.Id);
                }
            }
            update lstClaim;
        }
        
        
     
     
 /*        if(mode == null || (mode!=null && mode.indexOf('precycle') > -1)) {   
            for(Contact con : clist)
                con.KPI_CPE_Participation__c = true;
            update lstClaim;
        } */


        
        
        if(mode!=null && mode.indexOf('clear') > -1) {
            for(Contact con : clist)
                con.KPI_Last_Updated_Date__c = NULL;
            update clist;
        }
        
        
        for(Contact con : clist)
            if(batch == true) {
                con.Processed_By_Batch__c = false;
            } else {
                con.KPI_Last_Updated_Date__c = date.today();    
            }
            
        update clist;
        
        
    }
    
    
    global void finish(Database.BatchableContext BC){
        
    }
}