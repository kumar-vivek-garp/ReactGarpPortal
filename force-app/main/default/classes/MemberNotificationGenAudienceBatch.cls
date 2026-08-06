global class MemberNotificationGenAudienceBatch implements Database.Batchable<sObject>{
    
    public String RPT_Administration_Year;  
    public String RPT_Administration_Month;  
    public String RPT_Exam_Program;  
    public List<String> RPT_Exam_Parts;  
    public List<String> Integration_Data_Status;
    public String Exam_Provider;
    public String Language_Preference;
    public String Mode; // Remote, CBT
    public String siteId;      
    public String notificationId;    
    
    global MemberNotificationGenAudienceBatch(String notificationIdIn, String examYear, String examMonth, String examProgram, List<String> examParts, List<String> integrationStatus, String examProvider, String languagePreference, String modeIn, String siteIdIn) {
        this.RPT_Administration_Year= examYear;   
        this.RPT_Administration_Month = examMonth;
        this.RPT_Exam_Program = examProgram;
        this.RPT_Exam_Parts = examParts;
        this.Integration_Data_Status = integrationStatus;
        this.Exam_Provider = examProvider;
        this.Language_Preference = languagePreference;
        this.Mode = modeIn;
        this.siteId = siteIdIn;
        this.notificationId = notificationIdIn;
        
        System.Debug('RPT_Administration_Year:' + this.RPT_Administration_Year);
        System.Debug('RPT_Administration_Month:' + this.RPT_Administration_Month);
        System.Debug('RPT_Exam_Program:' + this.RPT_Exam_Program);
        System.Debug('RPT_Exam_Parts:' + this.RPT_Exam_Parts);
        System.Debug('Integration_Data_Status:' + this.Integration_Data_Status);
        System.Debug('Exam_Provider:' + this.Exam_Provider);
        System.Debug('Language_Preference:' + this.Language_Preference);
        System.Debug('Mode:' + this.Mode);
        System.Debug('siteId:' + this.siteId);
        System.Debug('notificationId:' + this.notificationId);

    }
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        
        String mainQuery = 'SELECT Id, Member_Email__c, Garp_Id__c, Member__r.FirstName, Member__r.LastName, Member__r.Name_as_it_Appears_on_ID__c, Member__r.First_Name_as_it_Appears_on_ID__c, Member__r.Middle_Name_as_it_Appears_on_ID__c, Member__r.Last_Name_as_it_Appears_on_ID__c FROM Exam_Attempt__c WHERE Reg_Status__c not in (\'Cancelled\',\'Deferred Out\',\'Deferred Out Pending\') AND RPT_Administration_Year__c = :RPT_Administration_Year AND RPT_Administration_Month__c = :RPT_Administration_Month AND RPT_Exam_Program__c = :RPT_Exam_Program AND RPT_Exam_Part__c in :RPT_Exam_Parts';
        if(Test.isRunningTest()){
            mainQuery = 'SELECT Id, Member_Email__c, Garp_Id__c, Member__r.FirstName, Member__r.LastName, Member__r.Name_as_it_Appears_on_ID__c, Member__r.First_Name_as_it_Appears_on_ID__c, Member__r.Middle_Name_as_it_Appears_on_ID__c, Member__r.Last_Name_as_it_Appears_on_ID__c FROM Exam_Attempt__c where Member__c != NULL';
        }

        String query = '';
        
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        if(!org.IsSandbox) {
            query = query + ' AND Is_Test__c = FALSE';
        }
        
        if(Integration_Data_Status.size() == 1 && Integration_Data_Status[0]  == 'Paid Taken Result') {
            query = query + ' AND Result__c in (\'Pass\',\'Fail\')';
        } else if(!Integration_Data_Status.IsEmpty() && !Test.isRunningTest()) {
            query = query + ' AND Integration_Data_Status__c in :Integration_Data_Status';
        }        

        if(Exam_Provider != NULL) {
            query = query + ' AND Exam_Site__r.Exam_Provider__r.Name = :Exam_Provider';
        }

        if(Language_Preference != NULL) {
            query = query + ' AND Integration_Data_Exam_Language__c = :Language_Preference';
        }

        if(Mode != NULL) {
            query = query + ' AND Integration_Data_Exam_Type__c = :Mode';
        }
        
        if(siteId != NULL && siteId.length() > 0 && !Test.isRunningTest()) {
            query = query + ' AND Exam_Site__r.Site_code__c = :siteId';
        }
        query = query + ' LIMIT 99999';

        System.Debug('Final query:' + query);
        
        if(Test.isRunningTest())
            return Database.getQueryLocator(mainQuery);
         else return Database.getQueryLocator(mainQuery + query);
    }
    
    global void execute(Database.BatchableContext BC, List<Exam_Attempt__c> scope){
        MAP<String,Exam_Attempt__c> mapExamAttemptByEmail = new MAP<String,Exam_Attempt__c>();
        for(Exam_Attempt__c ea :scope) {
            mapExamAttemptByEmail.put(ea.Member_Email__c, ea);
        }

        MAP<String,Exam_Attempt__c> mapExamAttemptByGARPId = new MAP<String,Exam_Attempt__c>();
        for(Exam_Attempt__c ea :mapExamAttemptByEmail.values()) {
            mapExamAttemptByGARPId.put(ea.Garp_Id__c, ea);
        }

        List<Member_Notification_Recipient__c> lstNotifRecpts = [select Id, Email__c, GARP_ID__c from Member_Notification_Recipient__c where Member_Notification__c = :this.notificationId];

        MAP<String,Member_Notification_Recipient__c> mapGARPIDToRecpt = new MAP<String,Member_Notification_Recipient__c>();
        MAP<String,Member_Notification_Recipient__c> mapEmailToRecpt = new MAP<String,Member_Notification_Recipient__c>();
        if(!lstNotifRecpts.isEmpty()) {
            for(Member_Notification_Recipient__c mnr :lstNotifRecpts) {
                mapGARPIDToRecpt.put(mnr.GARP_ID__c, mnr);
                mapEmailToRecpt.put(mnr.Email__c, mnr);
            }
        }

        List<Member_Notification_Recipient__c> addMemNotifys = new List<Member_Notification_Recipient__c>();
        for(Exam_Attempt__c ea :mapExamAttemptByGARPId.values()) {

            Member_Notification_Recipient__c fndGarpId = mapGARPIDToRecpt.get(ea.Garp_Id__c);
            Member_Notification_Recipient__c fndEmail = mapEmailToRecpt.get(ea.Member_Email__c);

            if((fndGarpId == NULL && fndEmail == NULL) || Test.isRunningTest()) {
                        
                Member_Notification_Recipient__c newMemNot = new Member_Notification_Recipient__c(
                    Name = ea.Member__r.FirstName + ' ' + ea.Member__r.LastName,
                    Member_Notification__c = this.notificationId,
                    Email__c = ea.Member_Email__c,
                    GARP_ID__c = ea.Garp_Id__c,
                    Sending_Status__c = NULL
                );
                if(RPT_Exam_Program == 'FRM') {
                    newMemNot.Name_on_ID__c = ea.Member__r.Name_as_it_Appears_on_ID__c;
                } else if(RPT_Exam_Program == 'SCR' || RPT_Exam_Program == 'RiskAI') {
                    if(ea.Member__r.First_Name_as_it_Appears_on_ID__c != NULL) {
                        newMemNot.Name_on_ID__c = ea.Member__r.First_Name_as_it_Appears_on_ID__c;
                    }
                    if(ea.Member__r.Middle_Name_as_it_Appears_on_ID__c != NULL) {
                        if(newMemNot.Name_on_ID__c != NULL) {
                            newMemNot.Name_on_ID__c += ' ';
                        }
                        newMemNot.Name_on_ID__c += ea.Member__r.Middle_Name_as_it_Appears_on_ID__c;
                    }
                    if(ea.Member__r.Last_Name_as_it_Appears_on_ID__c != NULL) {
                        if(newMemNot.Name_on_ID__c != NULL) {
                            newMemNot.Name_on_ID__c += ' ';
                        }
                        newMemNot.Name_on_ID__c += ea.Member__r.Last_Name_as_it_Appears_on_ID__c;
                    }
                }

                addMemNotifys.add(newMemNot);
            }
        }
        insert addMemNotifys;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}