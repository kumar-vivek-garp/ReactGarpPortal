public class LeadAuditHistory {
    
    public static boolean bPKIDRecusrive2 = false;
        public static boolean CheckifChange = false;

    
    public static void trackLeadFields(List<lead> le, Map<Id, lead> oldMap) {
       
         List<Object_History__c > ObjHistory = new List<Object_History__c >(); 
        
        for(Lead l : Le){
            
       Object_History__c Lh = new Object_History__c();
        if(l.Email != null && oldMap.get(l.Id).Email != l.Email){ 
                Lh.Email_Modified_Value__c = l.Email;
                Lh.Email_Prior_Value__c = oldMap.get(l.Id).Email; 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
            
      

      if(l.FirstName != null && oldMap.get(l.Id).FirstName != l.FirstName){ 
                Lh.First_Name_Modified_Value__c = l.FirstName;
                Lh.First_Name_Prior_Value__c = oldMap.get(l.Id).FirstName; 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }

      if(l.LastName != null && oldMap.get(l.Id).LastName != l.LastName){ 
                Lh.Last_Name_Modified_Value__c = l.LastName;
                Lh.Last_Name_Prior_Value__c = oldMap.get(l.Id).LastName; 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }

       if(l.Email_Daily_News__c != null && oldMap.get(l.Id).Email_Daily_News__c != l.Email_Daily_News__c){ 
                Lh.Daily_News_Modified_Value__c = string.valueof(l.Email_Daily_News__c);
                Lh.Daily_News_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_Daily_News__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
              
            }
            
       if(l.Email_The_Week_in_Risk__c != null && oldMap.get(l.Id).Email_The_Week_in_Risk__c != l.Email_The_Week_in_Risk__c){ 
                Lh.Week_in_Risk_Modified_Value__c = string.valueof(l.Email_The_Week_in_Risk__c);
                Lh.Week_in_Risk_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_The_Week_in_Risk__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
               
            }
      if(l.Email_Chapter_Meetings__c != null && oldMap.get(l.Id).Email_Chapter_Meetings__c != l.Email_Chapter_Meetings__c){ 
                Lh.Chap_Mtg_Modified_Value__c = string.valueof(l.Email_Chapter_Meetings__c);
                Lh.Chap_Mtg_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_Chapter_Meetings__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
        if(l.Exam_Prep_Provider_Outreach__c != null && oldMap.get(l.Id).Exam_Prep_Provider_Outreach__c != l.Exam_Prep_Provider_Outreach__c){ 
                Lh.EPP_Modified_Value__c = string.valueof(l.Exam_Prep_Provider_Outreach__c);
                Lh.EPP_Prior_Value__c = string.valueof(oldMap.get(l.Id).Exam_Prep_Provider_Outreach__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
            
             if(l.Email_Webcasts__c != null && oldMap.get(l.Id).Email_Webcasts__c != l.Email_Webcasts__c){ 
                Lh.Webcast_Modified_Value__c = string.valueof(l.Email_Webcasts__c);
                Lh.Webcast_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_Webcasts__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }

            if(l.Email_Events__c != null && oldMap.get(l.Id).Email_Events__c != l.Email_Events__c){ 
                Lh.Conf_and_Workshop_Modified_Value__c = string.valueof(l.Email_Events__c);
                Lh.Conf_and_Workshop_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_Events__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
            
             if(l.Email_CorporateTeamBuilding__c != null && oldMap.get(l.Id).Email_CorporateTeamBuilding__c != l.Email_CorporateTeamBuilding__c){ 
                Lh.Corp_Team_Modified_Value__c = string.valueof(l.Email_CorporateTeamBuilding__c);
                Lh.Corp_Team_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_CorporateTeamBuilding__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
            
             if(l.SCR_Updates__c != null && oldMap.get(l.Id).SCR_Updates__c != l.SCR_Updates__c){ 
                Lh.SCR_Updates_Modified_Value__c = string.valueof(l.SCR_Updates__c);
                Lh.SCR_Updates_Prior_Value__c = string.valueof(oldMap.get(l.Id).SCR_Updates__c); 
                 CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
             if(l.Email_InsightAnalysis__c != null && oldMap.get(l.Id).Email_InsightAnalysis__c != l.Email_InsightAnalysis__c){ 
                Lh.Insights_Modified_Value__c = string.valueof(l.Email_InsightAnalysis__c);
                Lh.Insights_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_InsightAnalysis__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
             if(l.Email_GARP_Updates__c != null && oldMap.get(l.Id).Email_GARP_Updates__c != l.Email_GARP_Updates__c){ 
                Lh.GARP_Updates_Modified_Value__c = string.valueof(l.Email_GARP_Updates__c);
                CheckifChange = true;
                Lh.GARP_Updates_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_GARP_Updates__c); 
                Lh.Lead__C = l.Id;
                
            }
             if(l.Email_Information_Exchange__c != null && oldMap.get(l.Id).Email_Information_Exchange__c != l.Email_Information_Exchange__c){ 
                Lh.Info_Exchange_Modified_Value__c = string.valueof(l.Email_Information_Exchange__c);
                Lh.Info_Exchange_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_Information_Exchange__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
             if(l.Email_Member_Update__c != null && oldMap.get(l.Id).Email_Member_Update__c != l.Email_Member_Update__c){ 
                Lh.Member_Update_Modified_Value__c = string.valueof(l.Email_Member_Update__c);
                Lh.Member_Update_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_Member_Update__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
             if(l.Email_Career_Center_Job_Board__c != null && oldMap.get(l.Id).Email_Career_Center_Job_Board__c != l.Email_Career_Center_Job_Board__c){ 
                Lh.Career_Center_Modified_Value__c = string.valueof(l.Email_Career_Center_Job_Board__c);
                Lh.Career_Center_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_Career_Center_Job_Board__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
             if(l.Email_CPE_News__c != null && oldMap.get(l.Id).Email_CPE_News__c != l.Email_CPE_News__c){ 
                Lh.CPD_Bulletin_Modified_Value__c = string.valueof(l.Email_CPE_News__c);
                Lh.CPD_Bulletin_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_CPE_News__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
             if(l.HasOptedOutOfEmail != null && oldMap.get(l.Id).HasOptedOutOfEmail != l.HasOptedOutOfEmail){ 
                Lh.Email_Opt_Out_Modified_Value__c = string.valueof(l.HasOptedOutOfEmail);
                Lh.Email_Opt_Out_Prior_Value__c = string.valueof(oldMap.get(l.Id).HasOptedOutOfEmail); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
             if(l.Email_FRM__c != null && oldMap.get(l.Id).Email_FRM__c != l.Email_FRM__c){ 
                Lh.FRM_Exam_Update_Modified_Value__c = string.valueof(l.Email_FRM__c);
                Lh.FRM_Exam_Update_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_FRM__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
             if(l.Email_ERP__c != null && oldMap.get(l.Id).Email_ERP__c != l.Email_ERP__c){ 
                Lh.ERP_Exam_Update_Modified_Value__c = string.valueof(l.Email_ERP__c);
                Lh.ERP_Exam_Update_Prior_Value__c = string.valueof(oldMap.get(l.Id).Email_ERP__c); 
                CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
            
           if(l.Email_Subscription_Change_Source__c != null && oldMap.get(l.Id).Email_Subscription_Change_Source__c != l.Email_Subscription_Change_Source__c){ 
                Lh.Source_that_Made_Change__c = l.Email_Subscription_Change_Source__c;
                Lh.Lead__C = l.Id;
                
            }
      
         if(l.Email_Subscription_Change_Source__c != null && oldMap.get(l.Id).Email_Subscription_Change_Source__c == l.Email_Subscription_Change_Source__c&& CheckifChange == true){ 
                Lh.Source_that_Made_Change__c = 'GARP Employee Update-'+''+l.LastModifiedById;
                 CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }  
         if(((l.Email_Subscription_Change_Source__c == null || l.Email_Subscription_Change_Source__c == '') || (oldMap.get(l.Id).Email_Subscription_Change_Source__c == l.Email_Subscription_Change_Source__c)) && CheckifChange == true){ 
                Lh.Source_that_Made_Change__c = 'GARP Employee Update-'+''+l.LastModifiedById;
                 CheckifChange = true;
                Lh.Lead__C = l.Id;
                
            }
           ObjHistory.add(Lh);

            if(ObjHistory.size()>0){
            system.debug('$$$$$:'+ObjHistory.size());
             system.debug('bPKIDRecusrive2:'+bPKIDRecusrive2);
             bPKIDRecusrive2 = true;
                UPSERT ObjHistory;
                
            }
           
        }

    }

}