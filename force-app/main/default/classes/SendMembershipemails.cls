global class SendMembershipemails implements Database.Batchable<SObject>{
    
    global string memRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
    
    Public String mode; 
    
    global SendMembershipemails(String modeIn) {
        System.debug('modeIn:' + modeIn);
        
        this.mode= modeIn;   
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Set<integer> days = new Set<integer>{1, 10, 30, 365, 182};
        Set<String> setStatus = new Set<String>{'Activated','Activated ( Auto-Renew )'};
		Date dtEndDate = system.today(); 
        
        String query;
        
        if(test.isRunningTest()) {
            query = 'select id, AccountId, Membership_Renewal_Has_Risk_Net__c, Membership_Renewal_Price__c, Days_remaining__c ,Last_Exam_registration_Date__c,Last_Day_Contract_can_be_Active__c,StartDate,enddate,All_Requirements_Completed__c,recordTypeId,recordType.Name,Membership_Type__c,ContractTerm,Status,ActivatedDate, Part_1_completed_date__c, Part_2_completed_date__c, CV_Reminder_Sent_On__c from Contract limit 1';
        } else if(mode != NULL) {
            query = 'select id, AccountId, Membership_Renewal_Has_Risk_Net__c, Membership_Renewal_Price__c, Days_remaining__c,Last_Exam_registration_Date__c,StartDate,enddate,All_Requirements_Completed__c,Last_Day_Contract_can_be_Active__c,recordTypeId,recordType.Name,Membership_Type__c,ContractTerm,Status,ActivatedDate, Part_1_completed_date__c, Part_2_completed_date__c, CV_Reminder_Sent_On__c  from Contract where id = :mode';
        } else {
            query = 'select id, AccountId, Membership_Renewal_Has_Risk_Net__c, Membership_Renewal_Price__c, Days_remaining__c,Last_Exam_registration_Date__c,StartDate,enddate,All_Requirements_Completed__c,Last_Day_Contract_can_be_Active__c,recordTypeId,recordType.Name,Membership_Type__c,ContractTerm,Status,ActivatedDate, Part_1_completed_date__c, Part_2_completed_date__c, CV_Reminder_Sent_On__c  from Contract where Days_remaining__c  in: days  and ActivatedDate !=null and status in:setStatus';
        }
        System.debug('query:' + query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope){
        
        Set<String> accountIds = new Set<String>();
        for(Contract con : scope) {
            accountIds.add(con.AccountId);
        }
        //System.Debug('accountIds:' + accountIds);     //Chinnapa                                     
        
        List<Contract> lstCertContracts = [select Id, AccountId, recordType.DeveloperName, Status
                                           from Contract 
                                           where recordType.DeveloperName in ('FRM_Program','ERP_Program','SCR_Program','Risk_AI_Program','RAIJ_Program','Risk_Net') AND
                                           Status in ('Completed','Activated','Activated ( Auto-Renew )') AND
                                           AccountId in :accountIds
                                          ];
        System.Debug('lstCertContracts:' + lstCertContracts);                                          
        
        Set<String> certAccts = new Set<String>();
        Set<String> risknetAccts = new Set<String>();
        
        for(Contract cc :lstCertContracts) {
            String recname = cc.recordType.DeveloperName;
            if((recname == 'FRM_Program' || recname == 'ERP_Program' || recname == 'SCR_Program' || recname == 'Risk_AI_Program' || recname == 'RAIJ_Program') && cc.Status == 'Completed') {
            //if((cc.recordType.DeveloperName == 'FRM_Program' || cc.recordType.DeveloperName == 'ERP_Program') && cc.Status == 'Completed') {
                certAccts.add(cc.AccountId);
            }
            if(recname == 'Risk_Net' && (cc.Status == 'Activated' || cc.Status == 'Activated ( Auto-Renew )')) {
                risknetAccts .add(cc.AccountId);
            }
        }
        //System.Debug('certAccts:' + certAccts);                                          
        //System.Debug('risknetAccts:' + risknetAccts);                                          
        
        Map<Id,Contract> mapContract = new Map<Id,Contract>();
        for(Contract con : scope)
        {
            if(con.recordType.Name == 'Membership') {
                
                con.Days_Left__c = con.Days_remaining__c;
                if(certAccts.contains(con.AccountId)) {
                    con.Membership_Renewal_Price__c = 150;
                } else {
                    con.Membership_Renewal_Price__c = 195;
                }
                
                if(risknetAccts.contains(con.AccountId)) {
                    con.Membership_Renewal_Has_Risk_Net__c = True;
                }
                mapContract.put(con.Id,con);
            } else if(con.recordType.Name == 'FRM Program') {
                if(con.Part_1_completed_date__c != NULL && con.Part_2_completed_date__c != NULL) {
                    con.CV_Reminder_Sent_On__c = DateTime.Now();
                    con.Days_Left__c = con.Days_remaining__c;
                    mapContract.put(con.Id,con);
                    //System.Debug('Send Reminder:' + con);
                }
            }

        } 
       // System.Debug('mapContract:' + mapContract);                                          
        update mapContract.values();
    }
    
    global void finish(Database.BatchableContext BC){
    }
}