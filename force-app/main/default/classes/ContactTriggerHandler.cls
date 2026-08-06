/**
* Class ContactTriggerHandler
*
* Trigger Handler for the Contact SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class ContactTriggerHandler implements TriggerAbstract {
    public static boolean stopRecurssion = false;
    static List<Object_History__c > contactHistories = new List<Object_History__c >();
    static Map<Id,Contact> accIdToContactMap = new Map<Id,Contact>();
    static string userType = UserInfo.getUserType();
    static Map<String,List<Contact>> methodToContactProgramUpdateMap = new Map<String,List<Contact>>();
    static Map<String,List<Contact>> methodToContactExamRegUpdateMap = new Map<String,List<Contact>>();
    //Default_Record_References__c drr;
    static String unmatchedAccountId = Default_Record_References__c.getAll().get('UNMATCHED-BUSINESS-ACCOUNT') != null ? Default_Record_References__c.getAll().get('UNMATCHED-BUSINESS-ACCOUNT').Record_Reference_ID__c :null;
    static Id memberRecId = RecordTypeHelper.getRecordTypeIdFromSchema('Contact','Member');
    Set<Id> contactIdsToSync = new Set<Id>();
    // Constructor
    public ContactTriggerHandler(){
        /*
        drr = Default_Record_References__c.getAll().get('UNMATCHED-BUSINESS-ACCOUNT');
        if(drr != null)
            unmatchedAccountId =  drr.Record_Reference_ID__c;
        */
    }
    
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {
        if(!stopRecurssion){
            
            if (Trigger.isDelete){}
        }
    }
    
    public void bulkAfter(){
    }
    
    public void beforeInsert(SObject so){
        if(!stopRecurssion){
            Contact newCont = (Contact)so;
            processBeforeUpdateAndInsert(newCont,null);
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        Contact newCont = (Contact)so;
        Contact oldCont = (Contact)oldSo;
        if(!stopRecurssion){
            processBeforeUpdateAndInsert(newCont,oldCont);
            processFieldUpdates(newCont,oldCont);
        }
    }
     
    public void beforeDelete(SObject so){
        // Cast the SObject to an Contact
        Contact myCont = (Contact)so;
        
    }
    
    public void afterInsert(SObject so){
        Contact newCont = (Contact)so;
        if(!stopRecurssion){
            processAfterUpdateAndInsert(newCont,null);
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        Contact newCont = (Contact)so;
        Contact oldCont = (Contact)oldSo;
        if(!stopRecurssion){
            processAfterUpdateAndInsert(newCont,oldCont);
            Object_History__c obj = ContactTriggerHelper.trackContactFields(newCont,oldCont);
            if(obj != null)       
            contactHistories.add(obj);
        }
        
        if (newCont.Email != null && newCont.Email != oldCont.Email) { 
            contactIdsToSync.add(newCont.Id);
        }
    }
    
    public void afterDelete(SObject so){
    }
    
    /**
    * andFinally
    *
    * This method is called once all records have been processed by the trigger. Use this
    * method to accomplish any final operations such as creation or updates of other records.
    */
    public void andFinally(){
        if(!stopRecurssion){
            if(trigger.isAfter){
                if(trigger.isUpdate){
                    stopRecurssion = true;
                    ContactTriggerHelper.createCommunityUser(trigger.new);
                    if (!contactIdsToSync.isEmpty()) {
                        System.enqueueJob(new SyncUserEmailFromContactQueueable(contactIdsToSync));
                    }
                    if(!accIdToContactMap.isEmpty()){
                        ContactTriggerHelper.UpdateAccountPKID(accIdToContactMap);
                    }
                    if(!methodToContactProgramUpdateMap.isEmpty()){
                        ContactTriggerHelper.UpdatePrograms(methodToContactProgramUpdateMap);
                    }
                    if(!methodToContactExamRegUpdateMap.isEmpty()){
                        ContactTriggerHelper.UpdateExamRegs(methodToContactExamRegUpdateMap);
                    }
                    if(!contactHistories.isEmpty()){
                        insert contactHistories;
                    }
                }
            }
        }
    }
    
    public void processBeforeUpdateAndInsert(Contact newCont,Contact oldCont){
        if(newCont.KPI_CPE_Participation__c == true){
            if(newCont.KPI_Membership_Payment_Status__c == 'Lapsed' && (newCont.KPI_CPE_Last_Cycle_Credits__c > 0 || newCont.KPI_CPE_Credits__c > 0)){
                newCont.CPD_User_Type__c = 'Lapsed Active';
                
            }else if(String.isNotBlank(newCont.KPI_CPE_Last_Completed_Cycle__c) && newCont.KPI_Membership_Payment_Status__c == 'Lapsed'
               && (newCont.KPI_CPE_Last_Cycle_Credits__c == 0 || newCont.KPI_CPE_Last_Cycle_Credits__c == null)
               && (newCont.KPI_CPE_Credits__c == 0 || newCont.KPI_CPE_Credits__c == null)){
                newCont.CPD_User_Type__c = 'Lapsed InActive';
                   
            }else if(newCont.KPI_Membership_Payment_Status__c == 'Lapsed' && (newCont.KPI_CPE_Credits__c == 0 || newCont.KPI_CPE_Credits__c == null)
               && (String.isBlank(newCont.KPI_CPE_Last_Completed_Cycle__c) || newCont.KPI_CPE_Last_Completed_Cycle__c == null)
               && (newCont.KPI_CPE_Last_Cycle_Credits__c == 0 || newCont.KPI_CPE_Last_Cycle_Credits__c == null)){
                newCont.CPD_User_Type__c = 'Lapsed New';
                   
            }else if(newCont.KPI_Membership_Payment_Status__c == 'In Good Standing' && (newCont.KPI_CPE_Last_Cycle_Credits__c > 0 || newCont.KPI_CPE_Credits__c > 0)){
                newCont.CPD_User_Type__c = 'Paid Active';
                
            }else if(newCont.KPI_Membership_Payment_Status__c == 'In Good Standing' && String.isNotBlank(newCont.KPI_CPE_Last_Completed_Cycle__c)
               && newCont.KPI_CPE_Last_Cycle_Credits__c == 0 && newCont.KPI_CPE_Credits__c == 0){
                newCont.CPD_User_Type__c = 'Paid InActive';
                   
            }else if(newCont.KPI_Membership_Payment_Status__c == 'In Good Standing' && (newCont.KPI_CPE_Credits__c == 0 || newCont.KPI_CPE_Credits__c == null)
               && (String.isBlank(newCont.KPI_CPE_Last_Completed_Cycle__c) || newCont.KPI_CPE_Last_Completed_Cycle__c == null)
               && (newCont.KPI_CPE_Last_Cycle_Credits__c == 0 || newCont.KPI_CPE_Last_Cycle_Credits__c == null)){
                newCont.CPD_User_Type__c = 'Paid New';
            }
        }
            
        if(newCont.GARP_Directory_Opt_In__c == true && (oldCont == null || newCont.GARP_Directory_Opt_In__c != oldCont.GARP_Directory_Opt_In__c)){
            newCont.GARP_Directory_Opt_In_Date__c = system.today();
        }
        if(newCont.GARP_Directory_Invite_Opt_Out__c == true && (oldCont == null || newCont.GARP_Directory_Invite_Opt_Out__c != oldCont.GARP_Directory_Invite_Opt_Out__c)){
            newCont.GARP_Directory_Opt_Out_Date__c = system.today();
        }
        if(newCont.Bloomberg_Profile_Opt_In__c == true && (oldCont == null || newCont.Bloomberg_Profile_Opt_In__c != oldCont.Bloomberg_Profile_Opt_In__c)){
            newCont.Bloomberg_Profile_Opt_In_Date__c = system.now();
        }
        if(String.isNotBlank(newCont.Other_Qualifications__c) && (oldCont == null || newCont.Other_Qualifications__c != oldCont.Other_Qualifications__c)){
            newCont.Professional_Designation_Other__c = true;
        }
        
        if(newCont.Email_Daily_News__c || newCont.SCR_Updates__c || newCont.Email_The_Week_in_Risk__c || newCont.Email_Chapter_Meetings__c || newCont.Exam_Prep_Provider_Outreach__c
           || newCont.Email_Member_Update__c || newCont.Email_GARP_Updates__c || newCont.Email_Career_Center_Job_Board__c || newCont.Email_CPE_News__c || newCont.Email_Events__c
           || newCont.Email_Information_Exchange__c || newCont.Email_InsightAnalysis__c || newCont.Email_Webcasts__c || newCont.Email_FRM__c || newCont.Email_ERP__c){
               if(oldCont == null || 
                  (newCont.Email_Daily_News__c != oldCont.Email_Daily_News__c || newCont.SCR_Updates__c != oldCont.SCR_Updates__c
                  || newCont.Email_The_Week_in_Risk__c != oldCont.Email_The_Week_in_Risk__c || newCont.Email_Chapter_Meetings__c != oldCont.Email_Chapter_Meetings__c
                  || newCont.Exam_Prep_Provider_Outreach__c != oldCont.Exam_Prep_Provider_Outreach__c || newCont.Email_Member_Update__c != oldCont.Email_Member_Update__c
                  || newCont.Email_GARP_Updates__c != oldCont.Email_GARP_Updates__c || newCont.Email_Career_Center_Job_Board__c != oldCont.Email_Career_Center_Job_Board__c
                  || newCont.Email_CPE_News__c != oldCont.Email_CPE_News__c || newCont.Email_Events__c != oldCont.Email_Events__c
                  || newCont.Email_Information_Exchange__c != oldCont.Email_Information_Exchange__c || newCont.Email_InsightAnalysis__c != oldCont.Email_InsightAnalysis__c
                  || newCont.Email_Webcasts__c != oldCont.Email_Webcasts__c || newCont.Email_FRM__c != oldCont.Email_FRM__c || newCont.Email_ERP__c != oldCont.Email_ERP__c) )
               {
                   newCOnt.Last_Date_Subscription_Changed__c = system.today();
                   newCont.HasOptedOutOfEmail = false; 
               }
        }
    }
    
    public void processFieldUpdates(Contact newCont,Contact oldCont){
        system.debug(newCont.Company__c+'  ----Company__c---    '+oldCont.Company__c);
        if(newCont.Company__c != oldCont.Company__c){
            newCont.Company_Last_Updated__c = system.now();
            if(String.isNotBlank(newCont.Company__c))
                newCont.Company_Association_Processed__c = false;
        }
        if(newCont.FirstName != oldCont.FirstName || newCont.LastName != oldCont.LastName || newCont.Email != oldCont.Email 
           || newCont.OtherPhone != oldCont.OtherPhone || newCont.HomePhone != oldCont.HomePhone || newCont.Middle_Initial__c != oldCont.Middle_Initial__c){
               if(userType == 'Standard')
                   newCont.Date_Contact_Last_Updated_GARP_Employee__c = system.today();
               else
                   newCont.Date_Contact_Last_Updated_by_GARP_Member__c = system.today();
           }
        if(newCont.Currently_in_School_Status__c  != oldCont.Currently_in_School_Status__c  || newCont.Currently_in_School__c  != oldCont.Currently_in_School__c 
           || newCont.School_Name__c  != oldCont.School_Name__c  || newCont.Degree_Program_Name__c  != oldCont.Degree_Program_Name__c){
               if(userType == 'Standard')
                   newCont.Date_Educational_Info_Last_Updated_GARP__c = system.today();
               else
                   newCont.Date_Educational_Info_LastUpdated_Member__c = system.today();
           }
        if(newCont.Currently_Working__c  != oldCont.Currently_Working__c  || newCont.Currently_Working_Status__c  != oldCont.Currently_Working_Status__c 
           || newCont.Company__c  != oldCont.Company__c  || newCont.Title  != oldCont.Title || newCont.Corporate_Title__c  != oldCont.Corporate_Title__c
           || newCont.Area_of_Concentration__c  != oldCont.Area_of_Concentration__c  || newCont.Job_Function__c  != oldCont.Job_Function__c 
           || newCont.Years_of_Experience__c  != oldCont.Years_of_Experience__c || newCont.Other_Qualifications__c  != oldCont.Other_Qualifications__c){
               if(userType == 'Standard')
                   newCont.Date_Employment_LastUpdate_GARP_Employee__c = system.today();
               else
                   newCont.Date_Employment_LastUpdated_GARP_Member__c = system.today();
        } 
    }
    
    public void processAfterUpdateAndInsert(Contact newCont,Contact oldCont){
        if(newCont.AccountId != null && newCont.RecordTypeID == memberRecId && newCont.AccountId != unmatchedAccountId) {
                accIdToContactMap.put(newCont.accountId,newCont);
        } 
        if(((String.isNotBlank(newCont.First_Name_as_it_Appears_on_ID__c) || String.isNotBlank(newCont.Last_Name_as_it_Appears_on_ID__c) 
           || String.isNotBlank(newCont.Middle_Name_as_it_Appears_on_ID__c) || String.isNotBlank(newCont.Email )) 
            && (oldCont == null || (newCont.First_Name_as_it_Appears_on_ID__c != oldCont.First_Name_as_it_Appears_on_ID__c 
                                   || newCont.Last_Name_as_it_Appears_on_ID__c != oldCont.Last_Name_as_it_Appears_on_ID__c
                                   || newCont.Middle_Name_as_it_Appears_on_ID__c != oldCont.Middle_Name_as_it_Appears_on_ID__c
                                   || newCont.Email != oldCont.Email
                                   || newCont.MailingStreet != oldCont.MailingStreet
                                   || newCont.MailingCity != oldCont.MailingCity
                                   || newCont.MailingState != oldCOnt.MailingState
                                   || newCont.MailingCountry != oldCont.MailingCountry
                                   || newCont.MailingPostalCode != oldCOnt.MailingPostalCode)))
           || (String.isNotBlank(newCont.Phone) && (oldCont != null && newCont.Phone != oldCont.Phone))){
               if(methodToContactExamRegUpdateMap.containsKey('UpdateSCRAndFRR')){
                   List<Contact> contactList = methodToContactExamRegUpdateMap.get('UpdateSCRAndFRR');
                   contactList.add(newCont);
                   methodToContactExamRegUpdateMap.put('UpdateSCRAndFRR',contactList);
               }else{
                   methodToContactExamRegUpdateMap.put('UpdateSCRAndFRR',new List<Contact>{newCont});
               }
           }
        if(oldCont != null && (newCont.Email != oldCont.Email)){
               if(methodToContactProgramUpdateMap.containsKey('UpdateRiskDotNet')){
                   List<Contact> contactList = methodToContactProgramUpdateMap.get('UpdateRiskDotNet');
                   contactList.add(newCont);
                   methodToContactProgramUpdateMap.put('UpdateRiskDotNet',contactList);
               }else{
                   methodToContactProgramUpdateMap.put('UpdateRiskDotNet',new List<Contact>{newCont});
               }
           }
        
        if(oldCont != null && (newCont.Email != oldCont.Email || newCont.Phone != oldCont.Phone)){
               if(methodToContactExamRegUpdateMap.containsKey('UpdateATAPSI')){
                   List<Contact> contactList = methodToContactExamRegUpdateMap.get('UpdateATAPSI');
                   contactList.add(newCont);
                   methodToContactExamRegUpdateMap.put('UpdateATAPSI',contactList);
               }else{
                   methodToContactExamRegUpdateMap.put('UpdateATAPSI',new List<Contact>{newCont});
               }
           }
        if((String.isNotBlank(newCont.Name_as_it_Appears_on_ID__c) || String.isNotBlank(newCont.ID_Type__c) || String.isNotBlank(newCont.ID_Number__c))
           && (oldCont == null || (newCont.Name_as_it_Appears_on_ID__c  != oldCont.Name_as_it_Appears_on_ID__c  
                                   || newCont.ID_Type__c  != oldCont.ID_Type__c || newCont.ID_Number__c != oldCont.ID_Number__c ))){
               if(methodToContactExamRegUpdateMap.containsKey('UpdateCertInfo')){
                   List<Contact> contactList = methodToContactExamRegUpdateMap.get('UpdateCertInfo');
                   contactList.add(newCont);
                   methodToContactExamRegUpdateMap.put('UpdateCertInfo',contactList);
               }else{
                   methodToContactExamRegUpdateMap.put('UpdateCertInfo',new List<Contact>{newCont});          
               }
         }
    }
}