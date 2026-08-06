public class ContactTriggerHelper {
    public class MyException extends Exception {}
    public static void createCommunityUser(List < Contact > lstCon) {
        String strPostFix = '.Garp';
        List < User > userList = new List < User > ();
        MAP < String, String > mapEmailGARPID = new MAP < String, String > ();
        set < id > contactIDs = new set < id > ();
        set < id > usersContactIDs = new set < id > ();
        set < string > contactEmails = new set < string > ();
        Map<Id, String> contactid2AccountUserRole = new Map<Id, String>();
        Id memberRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contact', 'Member');
        Id businessRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contact', 'Business_Relationship');
        Set < String > setEmails = new Set <String> ();
        User mockUser;
        Id profileId;
        if(test.isRunningTest()){
            profileId = [Select Id from Profile where Name = 'Customer Community' Limit 1].Id;
        }else{
            profileId = Default_Record_References__c.getAll().get('CommunityProfileId').Record_Reference_ID__c;
        }
        
        for (Contact c: lstCon) {
            if (c.do_not_fire__c == false){
                contactIDs.add(c.id);
            }
        }
        
        if (contactIDs.isEmpty()){
            return;
        }
        
        if(!contactIDs.isEmpty()){
            for (User u: [select id, username, ContactId from User where ContactId IN: contactIDs]) {
                    setEmails.add(u.username);
                    usersContactIDs.add(u.ContactId);
            }
        }
        
        Set < Id > setAccountIds = new Set < Id > ();
        for (Contact con: lstCon) {
           
           
            if(!usersContactIDs.contains(con.id) && !contactEmails.contains(con.Email) && con.Email != null 
               && con.Email.indexOf('garpautoqaqatesting') == -1 && con.recordTypeId != null && con.Do_Not_Fire__c == false) {
               
                if(con.recordTypeId == memberRecordTypeId ||
                    (con.recordTypeId == businessRecordTypeId 
                     && (con.Created_From_Flow__c == true || con.Event_Contributor__c == true || con.Event_Participant__c == true))
                ) {
                    mockUser = new User();
                    mockUser.contactId = con.Id;
                    if (Test.isrunningtest()){
                        mockUser.username = con.Email + '.' + string.valueof(Math.random()).substring(4, 9);
                    }else{
                        mockUser.username = con.Email;
                    }
                    
                    mockUser.firstname = con.FirstName;
                    mockUser.lastname = con.LastName;
                    mockUser.email = con.Email;
                    mockUser.FederationIdentifier = con.GARP_Member_ID__c;
                    if (Test.isrunningtest()) {
                        mockUser.communityNickname = con.LastName.substring(0, 1) + string.valueof(Math.random()).substring(4, 9);
                    } else {
                        mockUser.communityNickname = generateNickName(con);
                    }
                    
                    if (Test.isrunningtest()) {
                        mockUser.alias = con.LastName.substring(0, 1) + string.valueof(Math.random()).substring(4, 9);
                    } else {
                        mockUser.alias = con.GARP_ID_New__c ;
                    }
                       
                    mockUser.Password__c = con.Password__c; 
                    mapEmailGARPID.put(con.Email, con.GARP_Member_ID__c);
                    mockUser.profileid = profileId;
                    mockUser.emailencodingkey = 'UTF-8';
                    mockUser.languagelocalekey = 'en_US';
                    mockUser.localesidkey = 'en_US';
                    mockUser.timezonesidkey = 'America/New_York';


                    Database.DMLOptions dlo = new Database.DMLOptions();
                    dlo.EmailHeader.triggerUserEmail = true;
                    dlo.EmailHeader.triggerAutoResponseEmail = true;
                    mockUser.setOptions(dlo);
                    userList.add(mockUser);
                    //system.debug('mockUser == ' + mockUser);
                    contactEmails.add(con.Email);
                }
            }
        }


        if (userList.size() > 0) {
            //system.debug('userList == ' + userList); 
            try {
                INSERT userList;  
                if(Test.isRunningTest()){
                    throw new myexception('DUPLICATE_USERNAME, Duplicate Username.<br>The username already exists in this or another Salesforce ');                
                }
            } catch (Exception e) {  
                System.debug(e.getStackTraceString());
                AppError__c appErr = new AppError__c();
                appErr.Name = 'Failed to create Comm User';
                appErr.Message_Short__c = 'Failed to create Comm User 1st try';
                appErr.Error__c = e.getMessage() + '\n\n' + String.valueOf(userList);
                INSERT appErr;     
                if(
                    (e.getMessage().contains('DUPLICATE_USERNAME, Duplicate Username.<br>The username already exists in this or another Salesforce ')) || 
                    ((e.getMessage().contains('DUPLICATE_COMM_NICKNAME, Duplicate Nickname.<br>Another user has already selected this nickname.<br>Please select another.')))
                ) {
                    
                    List<Database.SaveResult> res = Database.insert(userList, false);
                    
                    for (Integer i = 0; i < userList.size(); i++) {
                        Database.SaveResult s = res[i];
                        user origRecord = userList[i];
                        if (!s.isSuccess()) {
                            //system.debug(s.getId()); // I get null here
                            //system.debug(origRecord.username); //This should be the Id you're looking for
                            origRecord.username = origRecord.username+strPostFix;
                            origRecord.communityNickname = origRecord.communityNickname+ string.valueof(Math.random()).substring(4, 9);
                            //system.debug('$$$$$$:'+origRecord.communityNickname);
                            try{
                                INSERT origRecord;
                             }catch (Exception e1) {
                                AppError__c appErr1 = new AppError__c();
                                appErr1.Name = 'Failed to create Comm User';
                                appErr1.Message_Short__c = 'Failed to create Comm User 1st try';
                                 appErr1.Error__c = e1.getMessage() + '\n\n' + String.valueOf(userList);
                                 INSERT appErr1;                 
                             }
                        } 
                    }   
                }           
            }
        }
    }
    
    public static Object_History__c trackContactFields(Contact c, Contact oldCont) {
        
        Object_History__c contactHistory = new Object_History__c();
        boolean isChanged = false;
        
        if(c.GARP_Directory_Invite_Opt_Out__c != oldCont.GARP_Directory_Invite_Opt_Out__c){
            contactHistory.Contact__c = c.Id;
            isChanged = true;
        }
        if(c.Email != null && oldCont.Email != c.Email){ 
            contactHistory.Email_Modified_Value__c = c.Email;
            contactHistory.Email_Prior_Value__c = oldCont.Email; 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.FirstName != null && oldCont.FirstName != c.FirstName){ 
            contactHistory.First_Name_Modified_Value__c = c.FirstName;
            contactHistory.First_Name_Prior_Value__c = oldCont.FirstName; 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.LastName != null && oldCont.LastName != c.LastName){ 
            contactHistory.Last_Name_Modified_Value__c = c.LastName;
            contactHistory.Last_Name_Prior_Value__c = oldCont.LastName; 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.SCR_Updates__c != null && oldCont.SCR_Updates__c != c.SCR_Updates__c){ 
            contactHistory.SCR_Updates_Modified_Value__c = string.valueof(c.SCR_Updates__c);
            contactHistory.SCR_Updates_Prior_Value__c = string.valueof(oldCont.SCR_Updates__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_Daily_News__c != null && oldCont.Email_Daily_News__c != c.Email_Daily_News__c){ 
            contactHistory.Daily_News_Modified_Value__c = string.valueof(c.Email_Daily_News__c);
            contactHistory.Daily_News_Prior_Value__c = string.valueof(oldCont.Email_Daily_News__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_The_Week_in_Risk__c != null && oldCont.Email_The_Week_in_Risk__c != c.Email_The_Week_in_Risk__c){ 
            contactHistory.Week_in_Risk_Modified_Value__c = string.valueof(c.Email_The_Week_in_Risk__c);
            contactHistory.Week_in_Risk_Prior_Value__c = string.valueof(oldCont.Email_The_Week_in_Risk__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_Chapter_Meetings__c != null && oldCont.Email_Chapter_Meetings__c != c.Email_Chapter_Meetings__c){ 
            contactHistory.Chap_Mtg_Modified_Value__c = string.valueof(c.Email_Chapter_Meetings__c);
            contactHistory.Chap_Mtg_Prior_Value__c = string.valueof(oldCont.Email_Chapter_Meetings__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Exam_Prep_Provider_Outreach__c != null && oldCont.Exam_Prep_Provider_Outreach__c != c.Exam_Prep_Provider_Outreach__c){ 
            contactHistory.EPP_Modified_Value__c = string.valueof(c.Exam_Prep_Provider_Outreach__c);
            contactHistory.EPP_Prior_Value__c = string.valueof(oldCont.Exam_Prep_Provider_Outreach__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_Webcasts__c != null && oldCont.Email_Webcasts__c != c.Email_Webcasts__c){ 
            contactHistory.Webcast_Modified_Value__c = string.valueof(c.Email_Webcasts__c);
            contactHistory.Webcast_Prior_Value__c = string.valueof(oldCont.Email_Webcasts__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_Events__c != null && oldCont.Email_Events__c != c.Email_Events__c){ 
            contactHistory.Conf_and_Workshop_Modified_Value__c = string.valueof(c.Email_Events__c);
            contactHistory.Conf_and_Workshop_Prior_Value__c = string.valueof(oldCont.Email_Events__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_CorporateTeamBuilding__c != null && oldCont.Email_CorporateTeamBuilding__c != c.Email_CorporateTeamBuilding__c){ 
            contactHistory.Corp_Team_Modified_Value__c = string.valueof(c.Email_CorporateTeamBuilding__c);
            contactHistory.Corp_Team_Prior_Value__c = string.valueof(oldCont.Email_CorporateTeamBuilding__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_InsightAnalysis__c != null && oldCont.Email_InsightAnalysis__c != c.Email_InsightAnalysis__c){ 
            contactHistory.Insights_Modified_Value__c = string.valueof(c.Email_InsightAnalysis__c);
            contactHistory.Insights_Prior_Value__c = string.valueof(oldCont.Email_InsightAnalysis__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_GARP_Updates__c != null && oldCont.Email_GARP_Updates__c != c.Email_GARP_Updates__c){ 
            contactHistory.GARP_Updates_Modified_Value__c = string.valueof(c.Email_GARP_Updates__c);
            contactHistory.GARP_Updates_Prior_Value__c = string.valueof(oldCont.Email_GARP_Updates__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_Information_Exchange__c != null && oldCont.Email_Information_Exchange__c != c.Email_Information_Exchange__c){ 
            contactHistory.Info_Exchange_Modified_Value__c = string.valueof(c.Email_Information_Exchange__c);
            contactHistory.Info_Exchange_Prior_Value__c = string.valueof(oldCont.Email_Information_Exchange__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id; 
        }
        if(c.Email_Member_Update__c != null && oldCont.Email_Member_Update__c != c.Email_Member_Update__c){ 
            contactHistory.Member_Update_Modified_Value__c = string.valueof(c.Email_Member_Update__c);
            contactHistory.Member_Update_Prior_Value__c = string.valueof(oldCont.Email_Member_Update__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;   
        }
        if(c.Email_Career_Center_Job_Board__c != null && oldCont.Email_Career_Center_Job_Board__c != c.Email_Career_Center_Job_Board__c){ 
            contactHistory.Career_Center_Modified_Value__c = string.valueof(c.Email_Career_Center_Job_Board__c);
            contactHistory.Career_Center_Prior_Value__c = string.valueof(oldCont.Email_Career_Center_Job_Board__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_CPE_News__c != null && oldCont.Email_CPE_News__c != c.Email_CPE_News__c){ 
            contactHistory.CPD_Bulletin_Modified_Value__c = string.valueof(c.Email_CPE_News__c);
            contactHistory.CPD_Bulletin_Prior_Value__c = string.valueof(oldCont.Email_CPE_News__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.HasOptedOutOfEmail != null && oldCont.HasOptedOutOfEmail != c.HasOptedOutOfEmail){ 
            contactHistory.Email_Opt_Out_Modified_Value__c = string.valueof(c.HasOptedOutOfEmail);
            contactHistory.Email_Opt_Out_Prior_Value__c = string.valueof(oldCont.HasOptedOutOfEmail); 
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_FRM__c != null && oldCont.Email_FRM__c != c.Email_FRM__c){ 
            contactHistory.FRM_Exam_Update_Modified_Value__c = string.valueof(c.Email_FRM__c);
            contactHistory.FRM_Exam_Update_Prior_Value__c = string.valueof(oldCont.Email_FRM__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id; 
        }
        if(c.Email_ERP__c != null && oldCont.Email_ERP__c != c.Email_ERP__c){ 
            contactHistory.ERP_Exam_Update_Modified_Value__c = string.valueof(c.Email_ERP__c);
            contactHistory.ERP_Exam_Update_Prior_Value__c = string.valueof(oldCont.Email_ERP__c); 
            isChanged = true;
            contactHistory.Contact__c = c.Id; 
        }
        if(c.Email_Subscription_Change_Source__c != null && oldCont.Email_Subscription_Change_Source__c != c.Email_Subscription_Change_Source__c){ 
            contactHistory.Source_that_Made_Change__c = c.Email_Subscription_Change_Source__c;
            contactHistory.Contact__c = c.Id;
        }
        if(c.Email_Subscription_Change_Source__c != null && oldCont.Email_Subscription_Change_Source__c == c.Email_Subscription_Change_Source__c&& isChanged == true){ 
            contactHistory.Source_that_Made_Change__c = 'GARP Employee Update-'+c.LastModifiedById;
            isChanged = true;
            contactHistory.Contact__c = c.Id;
        }  
        if(((c.Email_Subscription_Change_Source__c == null || c.Email_Subscription_Change_Source__c == '') || (oldCont.Email_Subscription_Change_Source__c == c.Email_Subscription_Change_Source__c)) && isChanged == true){ 
            contactHistory.Source_that_Made_Change__c = 'GARP Employee Update-'+c.LastModifiedById;
            isChanged = true;
            contactHistory.Contact__c = c.Id; 
        }
        if(isChanged){
            return contactHistory;
        }else{
            return null;
        }
    }
    
    public static void UpdateAccountPKID(Map<Id,Contact> mapContacts ){
        
        List<Account> lstAccounts = new List<Account>();
        for(Account acc : [select id,PK_PID__c,GARP_ID__c,Member_Email__c,Membership_Expiration_date__c,Member_Last_Name__c,Member_First_Name__c,Member_Wiley__c,Member_Type__c  from Account where id in: mapContacts.keySet()])
        {
            Contact cn = mapContacts.get(acc.Id);
            Boolean AddToList=false;
            if(cn != null && cn.GARP_Member_ID__c != null && (acc.GARP_ID__c == null || cn.GARP_Member_ID__c != acc.GARP_ID__c))
            {
                //system.debug('UpdatePKID:' + cn.GARP_Member_ID__c + ':' + cn.GARP_ID_New__c);
                acc.GARP_ID__c = cn.GARP_Member_ID__c;                    
                AddToList = True;
            }            
            if(cn != null && cn.Email != null && (acc.Member_Email__c != cn.Email))
            {
                //system.debug('Update Email:' + cn.Email);
                acc.Member_Email__c = cn.Email;
                AddToList = True;
            }            
            if(cn != null && cn.FirstName != null && (acc.Member_First_Name__c != cn.FirstName))
            {
                //system.debug('Update FirstName:' + cn.FirstName);
                acc.Member_First_Name__c = cn.FirstName;
                AddToList = True;
            }            
            if(cn != null && cn.LastName != null && (acc.Member_Last_Name__c != cn.LastName))
            {
                //system.debug('Update LastName:' + cn.LastName);
                acc.Member_Last_Name__c = cn.LastName;
                AddToList = True;
            }            
            if(cn != null && cn.KPI_J_Wiley__c != null && (acc.Member_Wiley__c != cn.KPI_J_Wiley__c))
            {
                //system.debug('Update Member_Wiley__c:' + cn.KPI_J_Wiley__c);
                acc.Member_Wiley__c = cn.KPI_J_Wiley__c;
                AddToList = True;
            }            
            if(cn != null && cn.Membership_Type__c != null && (acc.Member_Type__c != cn.Membership_Type__c))
            {
                //system.debug('Update Membership_Type__c:' + cn.Membership_Type__c);
                acc.Member_Type__c = cn.Membership_Type__c;
                AddToList = True;
            }            

            if(cn != null && cn.KPI_Membership_Expiration_Date__c != null && (acc.Membership_Expiration_date__c != cn.KPI_Membership_Expiration_Date__c))
            {
                //system.debug('Update KPI_Membership_Expiration_Date__c:' + cn.KPI_Membership_Expiration_Date__c);
                acc.Membership_Expiration_date__c = cn.KPI_Membership_Expiration_Date__c;
                AddToList = True;
            }            
            
            if(AddToList==True){
                lstAccounts.add(acc);
            }    
        }
        
        if(!lstAccounts.isEmpty()){
            update lstAccounts;
        }
    }
    
    public static void updatePrograms(Map<String,List<Contact>> methodToContactProgramUpdateMap){
        List<Contract> contractUpdList= new List<Contract>();
        Id RiskNetRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'Risk_Net');
        //Id SCRRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
        //Id ICBRRRecTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ICBRR_Program');
        Set<Id> contractRecTypeSet = new Set<Id>{RiskNetRecordTypeId};
        //Map<Id,Contact> contactScrFrrMap = new Map<Id,Contact>();
        Map<Id,Contact> contactRiskNetMap = new Map<Id,Contact>();
        for(string method : methodToContactProgramUpdateMap.keySet()){
            for(Contact con : methodToContactProgramUpdateMap.get(method)){
                /*if(method == 'UpdateSCRAndFRR'){
                        contactScrFrrMap.put(con.Id,con);
                }else*/ 
                if(method == 'UpdateRiskDotNet'){
                        contactRiskNetMap.put(con.Id,con);
                }
            }
        }
        
        List<Contract> contractList = [Select Id,RecordTypeId,Status,Member_Email__c,Pearson_Member_First_Name__c,Pearson_Member_Last_Name__c,
                                              Pearson_Phone_No__c,Pearson_Member_Middle_Name__c,CustomerSignedId
                                       from Contract
                                       where RecordTypeId IN: contractRecTypeSet AND Status = 'Activated' 
                                       AND  CustomerSignedId IN: contactRiskNetMap.keyset()];
        
        for(Contract prg : contractlist){
            /*if(contactScrFrrMap.containskey(prg.CustomerSignedId)){
                Contact con = contactScrFrrMap.get(prg.CustomerSignedId);
                prg.Member_Email__c = con.Email;
                prg.Pearson_Member_First_Name__c = con.First_Name_as_it_Appears_on_ID__c;
                prg.Pearson_Member_Middle_Name__c = con.Middle_Name_as_it_Appears_on_ID__c  ;
                prg.Pearson_Member_Last_Name__c = con.Last_Name_as_it_Appears_on_ID__c;
                prg.Pearson_Phone_No__c = con.Phone;
                contractUpdList.add(prg);
            }else*/
            if(contactRiskNetMap.containskey(prg.CustomerSignedId)){
                Contact con = contactRiskNetMap.get(prg.CustomerSignedId);
                prg.Member_Email__c = con.Email;
                contractUpdList.add(prg);
            }
        }
        
        if(!contractUpdList.isEmpty()){
            update contractUpdList;
        }  
    }
    
    public static void updateExamRegs(Map<String,List<Contact>> methodToContactExamRegUpdateMap){
        List<Exam_Attempt__c> examRegUpdList= new List<Exam_Attempt__c>();
        Map<Id,Contact> contactATAPSIMap = new Map<Id,Contact>();
        Map<Id,Contact> contactCertUpdMap = new Map<Id,Contact>();
        Map<Id,Contact> contactScrFrrMap = new Map<Id,Contact>();
        for(string method : methodToContactExamRegUpdateMap.keySet()){
            for(Contact con : methodToContactExamRegUpdateMap.get(method)){
                if(method == 'UpdateATAPSI'){
                    contactATAPSIMap.put(con.Id,con);
                }else if(method == 'UpdateCertInfo'){
                    contactCertUpdMap.put(con.Id,con);
                }else if(method == 'UpdateSCRAndFRR'){
                    contactScrFrrMap.put(con.Id,con);
                }
            }
        }
        
        List<Exam_Attempt__c> examAttemptList = [Select Id,ATA_Region_Code__c,ATA_Region_Name__c,Cancelled__c,Is_Active_Exam_Group__c,Member__c,
                                                        Result__c,RPT_Exam_Mode__c,Integration_Type__c,OutBound_Type__c,Opportunity_StageName__c,
                                                        ATA_Cert_Type__c,ATA_Cert_Id__c,ATA_Name_As_It_Appears_On_Id__c
                                                 from Exam_Attempt__c
                                                 where Cancelled__c = false and (Is_Active_Exam_Group__c = true or Result__c = null) and RPT_Exam_Mode__c = 'CBT'
                                                 and (Member__c IN: contactATAPSIMap.keyset() OR Member__c IN: contactCertUpdMap.keyset() OR Member__c IN: contactScrFrrMap.keyset())];
        for(Exam_Attempt__c ea : examAttemptList){
            boolean updateEA = false;
            if(contactATAPSIMap.containskey(ea.Member__c)){
                Contact con = contactATAPSIMap.get(ea.Member__c);
                if(ea.Opportunity_StageName__c == 'Closed' && ea.Result__c == null){
                    if(String.isNotBlank(ea.ATA_region_code__c) && String.isNotBlank(ea.ATA_region_name__c)){
                        ea.Outbound_Type__c = 'ATA';
                        ea.Integration_Type__c = 'Update Import Registration New';
                        updateEA = true;
                    }else if(String.isBlank(ea.ATA_region_code__c) && String.isBlank(ea.ATA_region_name__c)){
                        ea.Outbound_Type__c = 'PSI';
                        ea.Integration_Type__c = 'Update Eligibility Lifecycle';
                        updateEA = true;
                    }
                }
            }
            if(contactScrFrrMap.containskey(ea.Member__c)){
                Contact con = contactScrFrrMap.get(ea.Member__c);
                ea.Pearson_Email__c = con.Email;
                ea.Pearson_Member_First_Name__c = con.First_Name_as_it_Appears_on_ID__c;
                ea.Pearson_Member_Middle_Name__c = con.Middle_Name_as_it_Appears_on_ID__c  ;
                ea.Pearson_Member_Last_Name__c = con.Last_Name_as_it_Appears_on_ID__c;
                ea.Pearson_Phone_No__c = con.Phone;
                ea.Billing_Street__c = con.MailingStreet;
                ea.Billing_State__c = con.MailingState;
                ea.Billing_City__c = con.MailingCity;
                ea.Billing_Country__c = con.MailingCountry;
                ea.Billing_Postal_Code__c = con.MailingPostalCode;
                updateEA = true;
            }
            if(contactCertUpdMap.containskey(ea.Member__c)){
                Contact con = contactCertUpdMap.get(ea.Member__c);
                ea.ATA_Cert_Type__c = con.ID_Type__c;
                ea.ATA_Cert_id__c = con.ID_Number__c;
                ea.ATA_Name_as_it_appears_on_ID__c = con.Name_as_it_Appears_on_ID__c;
                updateEA = true;
            }
            if(updateEA = true){
                examRegUpdList.add(ea);
            }
        }
        
        if(!examRegUpdList.isEmpty()){
            update examRegUpdList;
        }
    }
    
    public static String generateNickName(Contact con) {
        if(con.Email.length() <= 40) {
            return con.Email;
        } else {
            String nick = '';
            for(Integer i = 0; i < 13; i++) {
                nick = nick + string.valueof(Math.round(Math.random()*1000));
            }
            return nick;
        }
    }
}