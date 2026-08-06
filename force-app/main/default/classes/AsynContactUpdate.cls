public class AsynContactUpdate {
    
    public static void updateContactFromExamAttempt(Set<Id> contactIds){
        List<Contact> updatedConList = new List<Contact>();
        Map<Id,List<Exam_Attempt__c>> contactToAttemptList = new Map<Id,List<Exam_Attempt__c>>();
        Map<String,String> examNameMap = new Map<String,String>();
            examNameMap.put('FRM Part 1','FRM Exam Part I');
            examNameMap.put('FRM Part 2','FRM Exam Part II');
        
        List<Contact> ContactList =  [select id, KPI_First_FRM_Part_I_Exam_Date__c, KPI_First_FRM_Part_II_Exam_Date__c, KPI_First_ERP_Part_I_Exam_Date__c, 
                                      KPI_First_ERP_Part_II_Exam_Date__c, KPI_First_FRM_Part_I_Exam_Result__c, KPI_First_FRM_Part_II_Exam_Result__c, 
                                      KPI_First_ERP_Part_I_Exam_Result__c, KPI_First_ERP_Part_II_Exam_Result__c, KPI_ERP_Part_I_Attempts__c, 
                                      KPI_ERP_Part_II_Attempts__c, KPI_FRM_Part_I_Attempts__c, KPI_FRM_Part_II_Attempts__c, KPI_ERP_Part_I_Pass_Exam_Date__c, 
                                      KPI_ERP_Part_II_Pass_Exam_Date__c, KPI_FRM_Part_I_Pass_Exam_Date__c, KPI_FRM_Part_II_Pass_Exam_Date__c,Membership_Type__c,
                                      Scholarship_Status__c, KPI_Last_Exam_Registration_Scholarship__c,KPI_Last_Exam_Registration_RA__c,KPI_Last_Exam_Registration_ADA__c,
                                      KPI_Last_Exam_Registration_Type__c,KPI_Last_Exam_Location__c,KPI_Last_Exam_Registration__c, KPI_Last_Exam_Violation__c,
                                      KPI_Last_Exam_Result__c,KPI_Last_Exam_Check_In__c, KPI_Last_Exam_Deferral_Status__c, KPI_Current_Exam_Reg_Business_Type__c, 
                                      KPI_Exam_Deferral_Status__c, KPI_Current_Exam_Date__c,KPI_Current_Exam_Location__c,KPI_Current_Exam_Reg_Scholarship__c,
                                      KPI_Current_Exam_Registration_RA__c, KPI_Current_Exam_Registration_ADA__c,KPI_Current_Exam_Registration_Date__c,
                                      KPI_Current_Exam_Registration__c, KPI_Current_Exam_Registration_Type__c, KPI_FRM_Last_Registration_Date__c,KPI_ERP_Last_Registration_Date__c,
                                      KPI_ICBRR_Result__c,KPI_ICBRR_Registration_Count__c,KPI_Membership_Since__c,KPI_Exam_Attempt_ID_2__c, RPT_First_FRM_Part_II_Registration_Exam__c,
                                      RPT_First_ERP_Part_II_Registration_Exam__c, KPI_SCR_Attempts__c, KPI_SCR_Last_Integration_Data_Status__c,KPI_Exam_Attempt_ID__c, accountId 
                                      from contact where Id in: contactIds];
        
        List<Exam_Attempt__c> filteredExamAttempt = [ SELECT Id, Name, Exam_Date__c, Section__c, Icbrr_Exam_Date__c, ICBRR_Submission_Status__c, Registered_On__c, Member__c,
                                                     Opportunity__r.CloseDate, Opportunity__r.StageName, CreatedDate, ADA_Status__c, RAD_Status__c, Scholarship_Status__c, 
                                                     Cancelled__c, hasViolation__c, Checked_In__c, Result__c, Defered__c, Exam_Site__r.Site__r.Display_Address__c, 
                                                     Exam_Site__r.Name, Exam_Site__r.Exam__r.Exam__c, Exam_Site__r.Exam_Date__c, Exam_Site__r.Exam__r.Exam_Date__c, 
                                                     Exam_Site__r.Exam__r.Exam_Group__c, Exam_Site__r.Exam__r.Exam_Group__r.Active__c, Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_For_Early_Registration__c, 
                                                     Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_For_Late_Registration__c, Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_For_Standard_Registration__c, Session__c,
                                                     Member__r.GARP_ID__c, Member__r.name, Exam_Site__r.Site__r.Site_Code__c, Room__r.name, Seat_No__c, Reg_Status__c, RPT_Registration_Type__c, 
                                                     Integration_Data_Status__c FROM Exam_Attempt__c
                                                     WHERE  Member__C in :contactIds AND Reg_Status__c != 'Cancelled'  ORDER BY Exam_Site__r.Exam_Date__c];
        
        for(Exam_Attempt__c ea : filteredExamAttempt){
            if(contactToAttemptList.containsKey(ea.Member__c)){
                List<Exam_Attempt__c> eaList = contactToAttemptList.get(ea.Member__c);
                eaList.add(ea);
                contactToAttemptList.put(ea.Member__c, eaList);
            }else{
                contactToAttemptList.put(ea.Member__c, new List<Exam_Attempt__c>{ea});
            }
        }

        for(Contact objContact: ContactList){
            
            objContact.KPI_SCR_Attempts__c = null;
            objContact.KPI_SCR_Last_Integration_Data_Status__c = null;
            
            objContact.KPI_ICBRR_Exam_Date__c = null;
            objContact.KPI_ICBRR_Result__c = null;
            objContact.KPI_ICBRR_Registration_Count__c = 0;
            objContact.KPI_Current_Exam_Registration__c = null;
            
            // Now save for Part I and II
            objContact.KPI_Current_Exam_Registration_Type__c = null;
            objContact.KPI_Current_Exam_Registration_II_Type__c = null;
            
            objContact.KPI_Current_Exam_Registration_I_Status__c = null;
            objContact.KPI_Current_Exam_Registration_II_Status__c = null;
                
            objContact.KPI_Current_Exam_Location__c = null;
            objContact.KPI_Current_Exam_Reg_Business_Type__c = null;
            objContact.KPI_Current_Exam_Registration_ADA__c = false;
            objContact.KPI_Current_Exam_Registration_RA__c = false;
            objContact.KPI_Current_Exam_Reg_Scholarship__c = false;
            objContact.Scholarship_Status__c = null;
            objContact.KPI_Current_Exam_Registration_Date__c = null;
            objContact.KPI_Current_Exam_Date__c = null;
            objContact.KPI_Exam_Deferral_Status__c = null;
            
            objContact.KPI_Last_Exam_Result__c = null;
            objContact.KPI_Last_Exam_Violation__c = false;
            objContact.KPI_Last_Exam_Registration__c = null;
            objContact.KPI_Last_Exam_Location__c = null;
            objContact.KPI_Last_Exam_Registration_Type__c = null;
            objContact.KPI_Last_Exam_Registration_ADA__c = false;
            objContact.KPI_Last_Exam_Registration_RA__c = false;
            objContact.KPI_Last_Exam_Registration_Scholarship__c = false;
            objContact.KPI_Last_Exam_Date__c = null;
            objContact.KPI_Last_Exam_Deferral_Status__c = null;
            
            objContact.KPI_Exam_Attempt_ID__c = null;
            objContact.KPI_Exam_Attempt_ID_2__c = null; 
            
            objContact.KPI_Last_Exam_Check_In__c = false;
            
            objContact.RPT_First_FRM_Registration_Exam_Date__c = null;
            objContact.RPT_First_ERP_Registration_Exam_Date__c = null;
            
            objContact.RPT_First_FRM_Part_II_Registration_Exam__c = null;
            objContact.RPT_First_ERP_Part_II_Registration_Exam__c  = null;
            
            objContact.KPI_FRM_Last_Registration_Date__c = null;
            objContact.KPI_ERP_Last_Registration_Date__c = null;
    
            objContact.KPI_First_FRM_Exam_Date__c = null;
            objContact.KPI_First_ERP_Exam_Date__c = null;
            
            objContact.KPI_First_FRM_Part_I_Exam_Date__c = null;
            objContact.KPI_First_FRM_Part_II_Exam_Date__c = null;
            objContact.KPI_First_ERP_Part_I_Exam_Date__c = null;
            objContact.KPI_First_ERP_Part_II_Exam_Date__c = null;
            objContact.KPI_First_FRM_Part_I_Exam_Result__c = null;
            objContact.KPI_First_FRM_Part_II_Exam_Result__c = null;
            objContact.KPI_First_ERP_Part_I_Exam_Result__c = null;
            objContact.KPI_First_ERP_Part_II_Exam_Result__c = null;
            objContact.KPI_ERP_Part_I_Attempts__c = null;
            objContact.KPI_ERP_Part_II_Attempts__c = null;
            objContact.KPI_FRM_Part_I_Attempts__c = null;
            objContact.KPI_FRM_Part_II_Attempts__c = null;
            objContact.KPI_ERP_Part_I_Pass_Exam_Date__c = null;
            objContact.KPI_ERP_Part_II_Pass_Exam_Date__c = null;
            objContact.KPI_FRM_Part_I_Pass_Exam_Date__c = null;
            objContact.KPI_FRM_Part_II_Pass_Exam_Date__c = null;
            
            objContact.FRM_Part_I_Last_Registration_Exam_Date__c = null;
            objContact.FRM_Part_I_Last_Exam_Result__c = null;
            objContact.FRM_Part_I_Last_Exam_Violation__c = false;
            objContact.FRM_Part_II_Last_Registration_Exam_Date__c = null;
            objContact.FRM_Part_II_Last_Exam_Result__c = null;
            objContact.FRM_Part_II_Last_Exam_Violation__c = false;
            objContact.ERP_Last_Registration_Exam_Date__c = null;
            objContact.ERP_Last_Exam_Result__c = null;
            objContact.ERP_Last_Violation__c = false;
            objContact.ERP_Part_II_Last_Registration_Exam_Date__c = null;
            objContact.ERP_Part_II_Last_Exam_Result__c = null;
            objContact.ERP_Part_II_Last_Exam_Violation__c = false;
            
            
            Boolean activeFound=false;
            Boolean activeDeferal=false;
            Integer activeCnt=0;
            Exam_Attempt__c lastResult=null;
            
            Exam_Attempt__c lastFRMResult=null;
            Exam_Attempt__c lastERPResult=null;
            
            Exam_Attempt__c ICBRRLastResult=null;
            
            List<Exam_Attempt__c> lstLastExam = new List<Exam_Attempt__c>();
            List<Exam_Attempt__c> lstCurrentExam = new List<Exam_Attempt__c>();
            
            if(contactToAttemptList.containsKey(objContact.Id)){
                for(Exam_Attempt__c ea : contactToAttemptList.get(objContact.Id)) {
                    if(ea.Member__C == objContact.Id && ea.Exam_Site__r != NULL && ea.Exam_Site__r.Exam__r != NULL && ea.Exam_Site__r.Exam__r.Exam__c != NULL && 
                       ea.Exam_Site__r.Exam__r.Exam_Group__r != NULL && ea.Exam_Site__r.Exam_Date__c != NULL && ea.Opportunity__r != NULL) {
                        
                       // system.debug('* * * Exam Attempt: ' + ea.Id);
                        
                        // Find most recent previous Exam Registrations
                        if(ea.Exam_Site__r.Exam__r.Exam__c != 'ICBRR' && (ea.Opportunity__r.StageName == 'Closed' || ea.Opportunity__r.StageName == 'Closed Won') &&  
                           ea.Exam_Site__r.Exam__r.Exam_Group__r.Active__c != True) {
                            if(lstLastExam.size() > 0) {
                                Exam_Attempt__c lea = lstLastExam.get(0);
                                if(lea.Exam_Site__r.Exam_Date__c != ea.Exam_Site__r.Exam_Date__c) {
                                    lstLastExam = new List<Exam_Attempt__c>();
                                }
                            }
                            lstLastExam.add(ea);  
                        }
                        
                        // SCR
                        if(ea.Exam_Site__r.Exam__r.Exam__c == 'SCR') {
                           if(objContact.KPI_SCR_Attempts__c  == Null){
                               objContact.KPI_SCR_Attempts__c = 1;
                           } else {
                               objContact.KPI_SCR_Attempts__c++;
                           }
                           
                           if(ea.Integration_Data_Status__c != 'Expired'&& ea.Integration_Data_Status__c != 'Lapsed'){
                               objContact.KPI_SCR_Last_Integration_Data_Status__c  = ea.Integration_Data_Status__c;
                           }
                        }
                                               
                        // Find current Exam Registrations
                        if(ea.Exam_Site__r.Exam__r.Exam__c != 'ICBRR' && 
                           ea.Exam_Site__r.Exam__r.Exam_Group__r.Active__c == True) {
                            if(lstCurrentExam.size() > 0) {
                                Exam_Attempt__c lea = lstCurrentExam.get(0);
                                if(lea.Exam_Site__r.Exam_Date__c != ea.Exam_Site__r.Exam_Date__c) {
                                    lstCurrentExam = new List<Exam_Attempt__c>();
                                }
                            }
                            lstCurrentExam.add(ea);  
                        }
                        
                        
                        if(ea.Exam_Site__r.Exam__r.Exam__c == 'ICBRR') {
                            if(ea.Result__c != null && (ICBRRLastResult == null || ICBRRLastResult.Result__c != 'Pass'))
                                ICBRRLastResult = ea;
                                   
                            if(ea.ICBRR_Submission_Status__c != NULL)
                                objContact.KPI_ICBRR_Registration_Count__c++;                    
                        }
                        
                        //system.debug('ea.Exam_Site__r.Exam__r.Exam__c==========>'+ea.Exam_Site__r.Exam__r.Exam__c);              
                        //system.debug('ea.Exam_Date__c ==========>'+ea.Exam_Date__c );              
                        
                        if(ea.Exam_Date__c != NULL) {
                            if((ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 1' || ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Full Program') && objContact.RPT_First_FRM_Registration_Exam_Date__c == NULL) {
                                objContact.RPT_First_FRM_Registration_Exam_Date__c = ea.Exam_Date__c;
                            }
                            if((ea.Exam_Site__r.Exam__r.Exam__c == 'ERP Exam Part I' || ea.Exam_Site__r.Exam__r.Exam__c == 'ERP') && objContact.RPT_First_ERP_Registration_Exam_Date__c == NULL) {
                                objContact.RPT_First_ERP_Registration_Exam_Date__c = ea.Exam_Date__c;
                            }
                            
                            //system.debug('Already? ea.RPT_First_FRM_Part_II_Registration_Exam__c ==========>'+objContact.RPT_First_FRM_Part_II_Registration_Exam__c );                                  
                            
                            if(ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 2' && objContact.RPT_First_FRM_Part_II_Registration_Exam__c == NULL) {  
                                objContact.RPT_First_FRM_Part_II_Registration_Exam__c = ea.Exam_Date__c;
                               // system.debug('UPDATE ea.Exam_Date__c ==========>'+objContact.RPT_First_FRM_Part_II_Registration_Exam__c );                                  
                                
                            }
                            if(ea.Exam_Site__r.Exam__r.Exam__c == 'ERP Exam Part II' && objContact.RPT_First_ERP_Part_II_Registration_Exam__c == NULL) {
                                objContact.RPT_First_ERP_Part_II_Registration_Exam__c = ea.Exam_Date__c;
                            }
                        }
                         
                        // Only collect these stats once the entire exam admin is over
                        if(ea.result__c != NULL && ea.Exam_Date__c != NULL) {
        
                            if(ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 1') {
                               
                               // Save most recent Info
                               objContact.FRM_Part_I_Last_Registration_Exam_Date__c = ea.Exam_Date__c;
                               objContact.FRM_Part_I_Last_Exam_Violation__c = ea.hasViolation__c;                       
                               objContact.FRM_Part_I_Last_Exam_Result__c = ea.result__c;
                               
                                if(objContact.KPI_FRM_Part_I_Attempts__c == Null)
                                    objContact.KPI_FRM_Part_I_Attempts__c=1;
                                else objContact.KPI_FRM_Part_I_Attempts__c++;                        
                               
                               // If earliest Attempt set First Attempt Info
                               if(objContact.KPI_First_FRM_Part_I_Exam_Date__c == NULL) {
                                   objContact.KPI_First_FRM_Part_I_Exam_Date__c = ea.Exam_Date__c;
                                   objContact.KPI_First_FRM_Exam_Date__c = ea.Exam_Date__c;
                               }
                               
                               // If earliest Result set First Attempt Info
                               if(objContact.KPI_First_FRM_Part_I_Exam_Result__c == NULL) {
                                   objContact.KPI_First_FRM_Part_I_Exam_Result__c = ea.Result__c;                                
                               }
                               
                               // If Result is Pass set
                               if(ea.Result__c == 'Pass') {
                                   objContact.KPI_FRM_Part_I_Pass_Exam_Date__c = ea.Exam_Date__c;
                               }                        
                               
                           }
                           
                           // If a valid FRM Part II Exam Attempt
                           if(ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 2') {
                               
                               // Save most recent Info
                               objContact.FRM_Part_II_Last_Registration_Exam_Date__c = ea.Exam_Date__c;
                               objContact.FRM_Part_II_Last_Exam_Violation__c = ea.hasViolation__c;
                               objContact.FRM_Part_II_Last_Exam_Result__c = ea.Result__c;
                               
                               if(objContact.KPI_FRM_Part_II_Attempts__c == Null)
                                   objContact.KPI_FRM_Part_II_Attempts__c=1;
                               else objContact.KPI_FRM_Part_II_Attempts__c++;
                               
                               // If earliest Attempt set First Attempt Info
                               if(objContact.KPI_First_FRM_Part_II_Exam_Date__c == NULL) {
                                   objContact.KPI_First_FRM_Part_II_Exam_Date__c = ea.Exam_Date__c;                        
                               }
                               
                               // If earliest Result set First Attempt Info
                               if(objContact.KPI_First_FRM_Part_II_Exam_Result__c == NULL) {
                                   objContact.KPI_First_FRM_Part_II_Exam_Result__c = ea.Result__c;                                
                               }
                               
                               // If Result is Pass set
                               if(ea.Result__c != NULL && ea.Result__c == 'Pass') {
                                   objContact.KPI_FRM_Part_II_Pass_Exam_Date__c = ea.Exam_Date__c;
                               }                  
                               
                           }
                           
                           // If a valid ERP Part I Exam Attempt
                           if(ea.Exam_Site__r.Exam__r.Exam__c == 'ERP Exam Part I') {
                               
                               // Save most recent Info
                               objContact.ERP_Last_Registration_Exam_Date__c = ea.Exam_Date__c; 
                               objContact.ERP_Last_Violation__c = ea.hasViolation__c;
                               objContact.ERP_Last_Exam_Result__c = ea.result__c;  
                               
                               if(objContact.KPI_ERP_Part_I_Attempts__c == Null)
                                   objContact.KPI_ERP_Part_I_Attempts__c=1;
                               else objContact.KPI_ERP_Part_I_Attempts__c++;
                               
                               // If earliest Attempt set First Attempt Info
                               if(objContact.KPI_First_ERP_Part_I_Exam_Date__c == NULL) {
                                   objContact.KPI_First_ERP_Part_I_Exam_Date__c = ea.Exam_Date__c;
                                   objContact.KPI_First_ERP_Exam_Date__c = ea.Exam_Date__c;
                               }
                               
                               // If earliest Result set First Attempt Info
                               if(objContact.KPI_First_ERP_Part_I_Exam_Result__c == NULL) {
                                   objContact.KPI_First_ERP_Part_I_Exam_Result__c = ea.Result__c;                                
                               }
                               
                               // If Result is Pass set
                               if(ea.Result__c != NULL && ea.Result__c == 'Pass') {
                                   objContact.KPI_ERP_Part_I_Pass_Exam_Date__c = ea.Exam_Date__c;
                               }
                           }
                           
                           // If a valid ERP Part II Exam Attempt
                           if(ea.Exam_Site__r.Exam__r.Exam__c == 'ERP Exam Part II') {
                               
                               // Save most recent Info
                               objContact.ERP_Part_II_Last_Registration_Exam_Date__c = ea.Exam_Date__c; 
                               objContact.ERP_Part_II_Last_Exam_Violation__c = ea.hasViolation__c;
                               objContact.ERP_Part_II_Last_Exam_Result__c = ea.result__c;  
                               
                               if(objContact.KPI_ERP_Part_II_Attempts__c == Null)
                                   objContact.KPI_ERP_Part_II_Attempts__c=1;
                               else objContact.KPI_ERP_Part_II_Attempts__c++;
                               
                               // If earliest Attempt set First Attempt Info
                               if(objContact.KPI_First_ERP_Part_II_Exam_Date__c == NULL) {
                                   objContact.KPI_First_ERP_Part_II_Exam_Date__c = ea.Exam_Date__c;                        
                               }
                               
                               // If earliest Result set First Attempt Info
                               if(objContact.KPI_First_ERP_Part_II_Exam_Result__c == NULL) {
                                   objContact.KPI_First_ERP_Part_II_Exam_Result__c = ea.Result__c;                                
                               }
                               
                               // If Result is Pass set
                               if(ea.Result__c != NULL && ea.Result__c == 'Pass') {
                                   objContact.KPI_ERP_Part_II_Pass_Exam_Date__c = ea.Exam_Date__c;
                               }
                           }
                        }
                    }
                }
            }
            
            // Set ICBRR Result
            if(ICBRRLastResult != null) {
                objContact.KPI_ICBRR_Result__c = ICBRRLastResult.Result__c;
                objContact.KPI_ICBRR_Exam_Date__c = ICBRRLastResult.Icbrr_Exam_Date__c;
       
            }
            
            // Set Last (non-Active) Exam Registration Data
            Integer deferCount = 0;
            String deferredLastExamName;
            for(Exam_Attempt__c ea : lstLastExam) {
                String examName = ea.Exam_Site__r.Exam__r.Exam__c;
                String niceExamName = examNameMap.get(examName);
                if(niceExamName == null) {
                    niceExamName = examName;
                }
                
                // Exam Date            
                if(ea.Exam_Site__r.Exam_Date__c != null) {
                    Datetime dt = datetime.newInstance(ea.Exam_Site__r.Exam_Date__c.year(), ea.Exam_Site__r.Exam_Date__c.month(),ea.Exam_Site__r.Exam_Date__c.day());
                    if(objContact.KPI_Last_Exam_Date__c != dt.format('MMMM yyyy')) {
                        deferCount = 0;
                    }
                    objContact.KPI_Last_Exam_Date__c = dt.format('MMMM yyyy');                
                }            
    
                if(ea.Defered__c != NULL && ea.Defered__c.toLowerCase().indexOf('approved') > -1) {
                    //objContact.KPI_Last_Exam_Deferral_Status__c = 'Deferred';
                    deferCount++;
    
                    // Exam Name
                    if(deferredLastExamName != null && deferredLastExamName.toLowerCase().indexOf('frm') > -1) {
                        deferredLastExamName = 'FRM Exam Part I & II';
                    } else if(deferredLastExamName != null && deferredLastExamName.toLowerCase().indexOf('erp') > -1) {
                        deferredLastExamName = 'ERP Exam Part I & II';
                    } else {
                        deferredLastExamName = niceExamName;
                    }
    
                    
                } else {
                    
                    // Exam Name
                    if(objContact.KPI_Last_Exam_Registration__c != null && objContact.KPI_Last_Exam_Registration__c.toLowerCase().indexOf('frm') > -1) {
                        objContact.KPI_Last_Exam_Registration__c = 'FRM Exam Part I & II';
                    } else if(objContact.KPI_Last_Exam_Registration__c != null && objContact.KPI_Last_Exam_Registration__c.toLowerCase().indexOf('erp') > -1) {
                        objContact.KPI_Last_Exam_Registration__c = 'ERP Exam Part I & II';
                    } else {
                        objContact.KPI_Last_Exam_Registration__c = niceExamName;
                    }
                    
                }
                                        
                // FRM / ERP Exam Date
                if(ea.Exam_Site__r.Exam__r.Exam__c != null && ea.Exam_Site__r.Exam__r.Exam__c.indexOf('FRM') > -1)
                    objContact.KPI_FRM_Last_Registration_Date__c = ea.Exam_Site__r.Exam_Date__c;
                if(ea.Exam_Site__r.Exam__r.Exam__c != null && ea.Exam_Site__r.Exam__r.Exam__c.indexOf('ERP') > -1)
                    objContact.KPI_ERP_Last_Registration_Date__c = ea.Exam_Site__r.Exam_Date__c;   
                
                // Exam Location
                if(ea.Exam_Site__r.Site__r.Display_Address__c != null && ea.Exam_Site__r.Site__r.Display_Address__c.length() > 255)
                    objContact.KPI_Last_Exam_Location__c = ea.Exam_Site__r.Site__r.Display_Address__c.substring(1,255);
                else objContact.KPI_Last_Exam_Location__c = ea.Exam_Site__r.Site__r.Display_Address__c;
                
                // Registration Type - most recent
                if(ea.CreatedDate <= ea.Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_For_Early_Registration__c) {
                    objContact.KPI_Last_Exam_Registration_Type__c = 'Early';
                } else if(ea.CreatedDate <= ea.Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_For_Standard_Registration__c) {
                    objContact.KPI_Last_Exam_Registration_Type__c = 'Standard';
                } else if(ea.CreatedDate <= ea.Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_For_Late_Registration__c) {
                    objContact.KPI_Last_Exam_Registration_Type__c = 'Late';
                }                
                
                // Last Exam Data - Results
                objContact.KPI_Last_Exam_Check_In__c = ea.Checked_In__c;
                objContact.KPI_Last_Exam_Result__c = ea.Result__c;
                objContact.KPI_Last_Exam_Violation__c = ea.hasViolation__c;
                
                if(ea.ADA_Status__c != null && ea.ADA_Status__c.toLowerCase().indexOf('approved') > -1) {
                    objContact.KPI_Last_Exam_Registration_ADA__c = true;    
                }
                if(ea.RAD_Status__c != null && ea.RAD_Status__c.toLowerCase().indexOf('approved') > -1) {
                    objContact.KPI_Last_Exam_Registration_RA__c = true;    
                }
                if(ea.Scholarship_Status__c != null && ea.Scholarship_Status__c.toLowerCase().indexOf('approved') > -1) {
                    objContact.KPI_Last_Exam_Registration_Scholarship__c = true;    
                }                        
            }
            
            
            //System.assert(false, 'BOOM!' + lstCurrentExam);
            
            // Set Active Exam Registration Data
            Integer currDeferCount = 0;
            String deferredExamName;
            for(Exam_Attempt__c ea : lstCurrentExam) {
                String examName = ea.Exam_Site__r.Exam__r.Exam__c;
                String niceExamName = examNameMap.get(examName);
                if(niceExamName == null) {
                    niceExamName = examName;
                }
    
                if(ea.Defered__c != null && ea.Defered__c.toLowerCase().indexOf('pending') > -1) {
                    currDeferCount++;
                    
                    // Exam Name
                    if(deferredExamName != null && deferredExamName.toLowerCase().indexOf('frm') > -1) {
                        deferredExamName = 'FRM Exam Part I & II';
                    } else if(deferredExamName != null && deferredExamName.toLowerCase().indexOf('erp') > -1) {
                        deferredExamName = 'ERP Exam Part I & II';
                    } else {
                        deferredExamName = niceExamName;
                    }
                    
                } else {
                                    
                    // Exam Name
                    if(objContact.KPI_Current_Exam_Registration__c != null && objContact.KPI_Current_Exam_Registration__c.toLowerCase().indexOf('frm') > -1) {
                        objContact.KPI_Current_Exam_Registration__c = 'FRM Exam Part I & II';
                    } else if(objContact.KPI_Current_Exam_Registration__c != null && objContact.KPI_Current_Exam_Registration__c.toLowerCase().indexOf('erp') > -1) {
                        objContact.KPI_Current_Exam_Registration__c = 'ERP Exam Part I & II';
                    } else {
                        objContact.KPI_Current_Exam_Registration__c = niceExamName;
                    }
                }
    
                // Exam Date            
                if(ea.Exam_Site__r.Exam_Date__c != null) {
                    Datetime dt = datetime.newInstance(ea.Exam_Site__r.Exam_Date__c.year(), ea.Exam_Site__r.Exam_Date__c.month(),ea.Exam_Site__r.Exam_Date__c.day());
                    objContact.KPI_Current_Exam_Date__c = dt.format('MMMM dd, yyyy');                
                }            
                
                // Exam Location
                if(ea.Exam_Site__r.Site__r.Display_Address__c != null && ea.Exam_Site__r.Site__r.Display_Address__c.length() > 255)
                    objContact.KPI_Current_Exam_Location__c = ea.Exam_Site__r.Site__r.Display_Address__c.substring(1,255);
                else objContact.KPI_Current_Exam_Location__c = ea.Exam_Site__r.Site__r.Display_Address__c;
                
                // Id - most recent
                if(objContact.KPI_Exam_Attempt_ID__c == null) {
                    objContact.KPI_Exam_Attempt_ID__c = ea.id;
                } else {
                    objContact.KPI_Exam_Attempt_ID_2__c = ea.id;
                }
                
                // Regostration Date - most recent
                objContact.KPI_Current_Exam_Registration_Date__c = ea.Registered_On__c;
                
                // Registration Type - most recent
                String regType = ea.RPT_Registration_Type__c.replace(' Registration','');
                if(ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 1' || ea.Exam_Site__r.Exam__r.Exam__c == 'ERP Exam Part I') {
                    objContact.KPI_Current_Exam_Registration_Type__c = regType;
                    objContact.KPI_Current_Exam_Registration_I_Status__c = ea.Reg_Status__c;
                } else {
                    objContact.KPI_Current_Exam_Registration_II_Type__c = regType;
                    objContact.KPI_Current_Exam_Registration_II_Status__c = ea.Reg_Status__c;
                }
                    
    
                                
                if(ea.ADA_Status__c != null && ea.ADA_Status__c.toLowerCase().indexOf('approved') > -1) {
                    objContact.KPI_Current_Exam_Registration_ADA__c = true;    
                }
                if(ea.RAD_Status__c != null && ea.RAD_Status__c.toLowerCase().indexOf('approved') > -1) {
                    objContact.KPI_Current_Exam_Registration_RA__c = true;    
                }
                if(ea.Scholarship_Status__c != null && ea.Scholarship_Status__c.toLowerCase().indexOf('approved') > -1) {
                    objContact.KPI_Current_Exam_Reg_Scholarship__c = true;    
                }            
                
                if(ea.Scholarship_Status__c != NULL)
                    objContact.Scholarship_Status__c = ea.Scholarship_Status__c;            
            }
    
            if(lstCurrentExam.size() > 0 && lstLastExam.size() > 0) {
                objContact.KPI_Current_Exam_Reg_Business_Type__c = 'Renewal';
            } else if(lstCurrentExam.size() > 0) {
                objContact.KPI_Current_Exam_Reg_Business_Type__c = 'New';
            }
            if(lstCurrentExam.size() > 0 && lstCurrentExam.size() == currDeferCount) {
                objContact.KPI_Current_Exam_Reg_Business_Type__c = 'New';
                objContact.KPI_Exam_Deferral_Status__c='Defferral Pending';
                objContact.KPI_Current_Exam_Registration__c = deferredExamName;
            }
            
            //System.assert(false, 'BOOM!' + lstLastExam.size() + ':' + deferCount);
            
            if(lstLastExam.size() > 0 && lstLastExam.size() == deferCount) {
                objContact.KPI_Last_Exam_Deferral_Status__c='Defferred';
                objContact.KPI_Last_Exam_Registration__c = deferredLastExamName;
            }        
            //system.debug('* * * Add Contact: ' + objContact);
            updatedConList.add(objContact);
        }
        
        if(!updatedConList.isEmpty()){
        	update updatedConList;
        }
    }
    
    /**
    * UpdateFields method is used to update the contacts and opportunity fields based on the contract status 
    * */
    public static void updateContactFromContract(Set<Id> recordIds)
    {
        Map<Id,List<Contract>> mapNewActIdsContract = new Map<Id,List<Contract>>();
        Set<Contract> lstContractsFromMapAccountIds = new Set<Contract>();
        Set<Id> accIdsForCPE = new Set<Id>();
        //Date lastDate = null;
        List<Contact> lstContactUpdate = new List<Contact>();
        Map<Id,List<Candidate_Requirement__c>> mapCandidateRequirements = new Map<Id,List<Candidate_Requirement__c>>();
        Id SCRExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
        Id RAIExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_AI_Program');//Chinnapa
        Id RAIJExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','RAIJ_Program');
        Id ERPExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ERP_Program');
        Id FRMExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        Id ICBRRExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ICBRR_Program');
        Id CPETypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','CPE');
        Id MembershipTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        Id CPECandidateReqRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Candidate_Requirement__c','CPE');
        Id jobRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Candidate_Requirement__c', 'Job_Experience');
        Id examRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Candidate_Requirement__c', 'Exam');
        id FBRExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FBR_Program');
        Date nowDateTime = date.today();
        
        List<Contract> contractList = [Select Id,AccountId,Status,StartDate,EndDate,All_Requirements_Completed__c,RecordTypeId,Membership_Type__c,Opportunity__r.Program_Abbrev__c,
                                       All_Requirements_Completed_Date__c
                                       from Contract 
                                       where AccountId IN: recordIds  Order By StartDate];
         Set<Id> validRtIds = new Set<Id>{
                FRMExamTypeId, ERPExamTypeId, CPETypeId, SCRExamTypeId, RAIExamTypeId,RAIJExamTypeId
            }; //Chinnapa
          
        for(Contract newContract : contractList ){
        	if(mapNewActIdsContract.containsKey(newContract.AccountId)){
                List<Contract> lstCon = mapNewActIdsContract.get(newContract.AccountId);
                lstCon.add(newContract);
                mapNewActIdsContract.put(newContract.AccountId,lstCon);
            } else {
                mapNewActIdsContract.put(newContract.AccountId,new List<Contract> {newContract});
            }
            
           /* if (newContract.recordTypeId == FRMExamTypeId || newContract.recordTypeId == ERPExamTypeId || newContract.recordTypeId == CPETypeId || newContract.recordTypeId == SCRExamTypeId || newContract.recordTypeId == RAIExamTypeId){
                lstContractsFromMapAccountIds.add(newContract);
            }
            
            if(newContract.Status == 'Completed' && (newContract.recordTypeId == FRMExamTypeId || newContract.recordTypeId == ERPExamTypeId || newContract.recordTypeId == CPETypeId || newContract.recordTypeId == SCRExamTypeId || newContract.recordTypeId == RAIExamTypeId)){
                accIdsForCPE.add(newContract.AccountId);
            }*/

            
            if (validRtIds.contains(newContract.RecordTypeId)) {
                lstContractsFromMapAccountIds.add(newContract);

                if (newContract.Status == 'Completed') {
                    accIdsForCPE.add(newContract.AccountId);
                }
            }
        } 
        
        if(!lstContractsFromMapAccountIds.isEmpty()){
            for (Candidate_Requirement__c canReq : [select Id, Name, RecordTypeID, Status__c, Certificate_Sent_Date__c, Date_of_Failed_Review__c, 
                                                    Date_of_Ready_for_Review__c, Date_of_Completion__c, Approved_Credits_Total__c, Candidate_Commitment__c,
                                                    Approved_Credits__c, Candidate_Commitment__r.StartDate 
                                                    from Candidate_Requirement__c 
                                                    where Candidate_Commitment__c in : lstContractsFromMapAccountIds]) 
            {
                if(mapCandidateRequirements.ContainsKey(canReq.Candidate_Commitment__c)) {
                    List<Candidate_Requirement__c> lstCanReq =  mapCandidateRequirements.get(canReq.Candidate_Commitment__c);
                    lstCanReq.add(canReq);
                    mapCandidateRequirements.put(canReq.Candidate_Commitment__c,lstCanReq);
                } else {
                    mapCandidateRequirements.put(canReq.Candidate_Commitment__c,new List<Candidate_Requirement__c> {canReq});
                }
            }
        }
        
        for (Contact objContact: [select id, KPI_Member__c, Membership_Type__c, CVent_Contact_Type__c, KPI_Membership_Since__c,
                                  KPI_Membership_Expiration_Date__c, KPI_Membership_Payment_Lapsed_Months__c, KPI_Membership_Payment_Status__c,
                                  KPI_Membership_Source__c, KPI_Membership_Original_Business_Type__c, KPI_Membership_Renewal_Type__c,
                                  KPI_Membership_Business_Type__c, KPI_Membership_Renewal_Count__c, KPI_Membership_Original_Type__c,
                                  KPI_Membership_Renew_Count__c, KPI_Membership_Comp_Count__c,
                                  KPI_Membership_Converted_Exam_Comp__c,KPI_Membership_Converted_Affiliate__c,
                                  KPI_Membership_Renewal_Date__c, Membership_Last_Contract_Start_Date__c, KPI_Membership_Purchase_History__c,
                                  KPI_Membership_Contract_History__c, Membership_Caluclated_Expiration_Date__c,
                                  KPI_FRM_Resume_Status__c, KPI_FRM_Resume_Status_Date__c, KPI_FRM_Resume_Certificate_Sent_Date__c, KPI_FRM_Resume_Submission_Date__c,
                                  KPI_ERP_Resume_Status__c, KPI_ERP_Resume_Status_Date__c, KPI_ERP_Resume_Certificate_Sent_Date__c, KPI_ERP_Resume_Submission_Date__c,
                                  KPI_FRM_Resume_Program_Requirement_ID__c, KPI_ERP_Resume_Program_Requirement_ID__c,
                                  KPI_FRM_Certified_Date__c, KPI_FRM_Certified_Year__c, KPI_FRM_Certified__c, KPI_FRM_Candidate__c,
                                  KPI_FRM_Holder__c, KPI_FRM_Candidate_Payment_Lapsed_Months__c, KPI_FRM_Candidate_Payment_Status__c,
                                  KPI_FRM_Candidate_Business_Type__c, KPI_ERP_Certified_Date__c, KPI_ERP_Certified_Year__c,
                                  KPI_FRM_Program_Start_Date__c, KPI_FRM_Program_Expiration_Date__c, KPI_ERP_Program_Start_Date__c, KPI_ERP_Program_Expiration_Date__c,
                                  KPI_ERP_Certified__c, KPI_ERP_Candidate__c, KPI_ERP_Holder__c, KPI_ERP_Candidate_Payment_Lapsed_Months__c,
                                  KPI_ERP_Candidate_Payment_Status__c, KPI_ERP_Candidate_Business_Type__c, KPI_ICBRR_Participant__c,FRR_Participant__c,
                                  KPI_FBR_Participant__c, KPI_CPE_Participation__c, KPI_CPE_Current_Cycle__c, KPI_CPE_Credits__c,
                                  KPI_CPE_Last_Completed_Cycle__c, KPI_CPE_Requirement_Status__c, CPE_Current_Program_Requirement__c, accountId,
                                  KPI_SCR_Candidate__c, KPI_SCR_Holder__c, KPI_SCR_Completion_Date__c,
                                  KPI_Wiley__c, KPI_Wiley_Business_Type__c, KPI_Wiley_Join_Date__c, KPI_Wiley_Payment_Status__c, Date_Joined__c,              
                                  Email_Member_Update__c, MailingCountry
                                  from contact 
                                  where accountId in : mapNewActIdsContract.keySet()
                                 ]) 
        {
            Contract lastMemberContract = null;
            boolean foundActiveMembership = false;
            objContact.KPI_SCR_Candidate__c = false;
            objContact.KPI_SCR_Holder__c = false;
            objContact.KPI_SCR_Completion_Date__c = null;
            
            objContact.KPI_FRM_Program_Start_Date__c = null;
            objContact.KPI_FRM_Program_Expiration_Date__c = null;
            objContact.KPI_ERP_Program_Start_Date__c = null;
            objContact.KPI_ERP_Program_Expiration_Date__c = null;
            objContact.KPI_FRM_Certified_Date__c = null;
            objContact.KPI_FRM_Certified_Member_Status__c = null;
            objContact.KPI_FRM_Certified__c = false;
            objContact.KPI_FRM_Candidate__c = false;
            objContact.KPI_FRM_Holder__c = false;
            
            objContact.KPI_ERP_Certified_Date__c = null;
            objContact.KPI_ERP_Certified__c = false;
            objContact.KPI_ERP_Certified_Member_Status__c = null;
            objContact.KPI_ERP_Candidate__c = false;
            objContact.KPI_ERP_Holder__c = false;
            objContact.KPI_ERP_Candidate_Payment_Lapsed_Months__c = null;
            objContact.KPI_ERP_Candidate_Payment_Status__c = null;
            
            objContact.KPI_ICBRR_Participant__c = false;
            objContact.FRR_Participant__c = false;
            objContact.KPI_FBR_Participant__c = false;
            
            objContact.KPI_CPE_Participation__c = false;
            objContact.KPI_CPE_Current_Cycle__c = null;
            objContact.CPE_Last_Cycle__c = null;
            objContact.KPI_CPE_Credits__c = null;
            objContact.KPI_CPE_Last_Completed_Cycle__c = null;
            objContact.KPI_CPE_Requirement_Status__c = null;
            objContact.CPE_Current_Program_Requirement__c = null;
            
            objContact.KPI_Member__c = false;
            objContact.KPI_Membership_Since__c = null;
            objContact.KPI_Membership_Expiration_Date__c = null;
            objContact.Email_Member_Update__c = false;
            objContact.Date_Joined__c = null;
            objContact.Membership_Type__c = 'Affiliate';
            objContact.KPI_Membership_Payment_Status__c = null;
            if(accIdsForCPE.contains(objContact.AccountId)){
                objContact.Email_CPE_News__c = true;
            }
            
            List<Contract> contracts = mapNewActIdsContract.get(objContact.AccountId);
            for(Contract con : contracts) {
                
                
                Date lastDate = null;
                if(con.RecordTypeId == MembershipTypeId && (con.status == 'Completed' || con.status == 'Activated' || con.status == 'Activated ( Auto-Renew )')) 
                {
                    if(objContact.KPI_Membership_Since__c == NULL) {
                        objContact.KPI_Membership_Since__c = con.StartDate;
                    } else if(con.StartDate < objContact.KPI_Membership_Since__c ) {
                        objContact.KPI_Membership_Since__c = con.StartDate;
                    }
                }
                
                Boolean passNotDone = false;
                if (validRtIds.contains(con.RecordTypeId))
                {
                    Candidate_Requirement__c lastCR = new Candidate_Requirement__c();
                    if(mapCandidateRequirements.ContainsKey(con.Id)) {
                        for (Candidate_Requirement__c cr: mapCandidateRequirements.get(con.Id)) 
                        {
                            if (cr.Candidate_Commitment__c == con.Id) {
                                if (cr.Name == 'CPE') {
                                    objContact.KPI_CPE_Requirement_Status__c = 'Pending';
                                    if (cr.Status__c == 'Completed') {
                                        objContact.KPI_CPE_Last_Completed_Cycle__c = String.valueOf(cr.Candidate_Commitment__r.StartDate.year()) + '/' + String.valueOf(cr.Candidate_Commitment__r.StartDate.year() + 1);
                                        if ((cr.Candidate_Commitment__r.StartDate.year() + 2) == Date.today().year() || (cr.Candidate_Commitment__r.StartDate.year() + 3) == Date.today().year()) {
                                            lastCR = cr;
                                            objContact.KPI_CPE_Requirement_Status__c = 'In Good Standing';
                                        }
                                    }
                                }
                                if (cr.Status__c == 'Completed' && (lastDate == null || cr.Date_of_Completion__c >= lastDate)) {
                                    lastDate = cr.Date_of_Completion__c;
                                }
                            }
                            if(cr.recordTypeId == CPECandidateReqRecordTypeId) {
                                if(con.status == 'Activated' || con.status == 'Completed' ) {
                                    objContact.CPE_Current_Program_Requirement__c = cr.Id;
                                }
                                objContact.KPI_CPE_Credits__c = cr.Approved_Credits_Total__c;
                            }
                            
                            if (cr.RecordTypeID == examRecordTypeID && cr.Status__c != 'Completed')
                                passNotDone = true;
                        } 
                    }
                    if (lastCR != null && lastCR.Status__c != 'Completed') {
                        objContact.KPI_CPE_Requirement_Status__c = 'Lapsed';
                    }
                }
                
                if (con.recordTypeId == MembershipTypeId){
                    if(con.status !='Canceled' && con.status != 'Draft') 
                    {
                        objContact.KPI_Member__c = true; 
                        objContact.Membership_Type__c = con.Membership_Type__c;
                    }
                }
                
                if(con.recordTypeId == SCRExamTypeId) 
                {
                    if(con.status == 'Completed') {
                        objContact.KPI_SCR_Holder__c = true;
                        if(con.All_Requirements_Completed__c == true){
                            objContact.KPI_SCR_Completion_Date__c = con.All_Requirements_Completed_Date__c;
                        }
                    }
                    else if(con.status =='Activated') {
                        objContact.KPI_SCR_Candidate__c = true;
                    }
                }
                
                if (con.recordTypeId == FRMExamTypeId)
                {
                    if(con.status == 'Activated' || con.status == 'Expired' || con.status == 'Completed')
                    {
                        if(objContact.KPI_FRM_Program_Start_Date__c == NULL || con.StartDate <= objContact.KPI_FRM_Program_Start_Date__c )
                        {
                            //system.debug('* * * Contract Status is:'+con.status); 
                            objContact.KPI_FRM_Program_Start_Date__c = con.StartDate;                        
                        }
                        if (con.status =='Expired' || con.status == 'Activated') {
                            objContact.KPI_FRM_Program_Expiration_Date__c = con.EndDate;
                        } else if (con.status == 'Completed') {
                            objContact.KPI_FRM_Program_Expiration_Date__c = con.All_Requirements_Completed_Date__c;
                        }
                    }
                    if (con.All_Requirements_Completed__c){
                        if(lastDate != null) {
                            objContact.KPI_FRM_Certified_Date__c = lastDate;
                        }
                        objContact.KPI_FRM_Certified__c = true;
                        objContact.KPI_FRM_Holder__c = false;
                        if(lastMemberContract != NULL && lastDate <= lastMemberContract.EndDate) {
                            if(lastMemberContract != null && lastMemberContract.Membership_Type__c != null)
                                objContact.KPI_FRM_Certified_Member_Status__c = lastMemberContract.Membership_Type__c + ' In Good Standing';
                        } else {
                            if(lastMemberContract != null && lastMemberContract.Membership_Type__c != null)
                                objContact.KPI_FRM_Certified_Member_Status__c = lastMemberContract.Membership_Type__c + ' Lapsed';    
                        }
                    } else {
                        if (passNotDone) {
                            objContact.KPI_FRM_Holder__c = false;
                            objContact.KPI_FRM_Candidate__c = true;
                        } else {
                            objContact.KPI_FRM_Holder__c = true;
                            objContact.KPI_FRM_Candidate__c = true;
                        }
                    }
                }
                
                if (con.recordTypeId == ERPExamTypeId)
                {
                    if(con.status == 'Activated' || con.status == 'Expired' || con.status == 'Completed')
                    {                                     
                        if(objContact.KPI_ERP_Program_Start_Date__c == NULL || con.StartDate <= objContact.KPI_ERP_Program_Start_Date__c)
                        {
                           // system.debug('* * * Contract Status is:'+con.status); 
                            objContact.KPI_ERP_Program_Start_Date__c  = con.StartDate;                        
                        }
                        if (con.status =='Expired' || con.status == 'Activated') {
                            objContact.KPI_ERP_Program_Expiration_Date__c = con.EndDate;
                        } else if (con.status == 'Completed') {
                            objContact.KPI_ERP_Program_Expiration_Date__c = con.All_Requirements_Completed_Date__c;
                        }
                    }
                    if (con.All_Requirements_Completed__c){
                        if(lastDate != null) {
                            objContact.KPI_ERP_Certified_Date__c = lastDate;
                        }
                        if( objContact.KPI_ERP_Certified__c == false){
                            objContact.KPI_ERP_Certified__c = true;
                        }
                        objContact.KPI_ERP_Holder__c = false;
                        if(lastMemberContract != NULL && lastDate <= lastMemberContract.EndDate) {
                            if(lastMemberContract != null && lastMemberContract.Membership_Type__c != null)
                                objContact.KPI_ERP_Certified_Member_Status__c = lastMemberContract.Membership_Type__c + ' In Good Standing';
                        } else {
                            if(lastMemberContract != null && lastMemberContract.Membership_Type__c != null)
                                objContact.KPI_ERP_Certified_Member_Status__c = lastMemberContract.Membership_Type__c + ' Lapsed';    
                        }
                    } else {
                        if (passNotDone) {
                            objContact.KPI_ERP_Holder__c = false;
                            objContact.KPI_ERP_Candidate__c = true;
                        } else {
                            objContact.KPI_ERP_Holder__c = true;
                            objContact.KPI_ERP_Candidate__c = true;
                        }
                    }
                }
                
                if (con.recordTypeId == ICBRRExamTypeId) 
                {
                    if(con.status == 'Activated' || con.status == 'Completed') {
                        if(con.Opportunity__r.Program_Abbrev__c == 'ICBRR')
                            objContact.KPI_ICBRR_Participant__c = true;
                        else 
                            objContact.FRR_Participant__c = true;
                    }
                    
                }
                
                if (con.recordTypeId == MembershipTypeId)
                {
                    if(con.status == 'Activated' || con.status == 'Activated ( Auto-Renew )') {
                        objContact.KPI_Member__c = true;
                        objContact.KPI_Membership_Expiration_Date__c = con.EndDate;
                        objContact.KPI_Membership_Payment_Status__c = 'In Good Standing';
                        objContact.KPI_Membership_Payment_Lapsed_Months__c = null;
                        if (objContact.MailingCountry != 'Canada' && (con.Membership_Type__c == 'Individual' || con.Membership_Type__c == 'Student')) {
                            objContact.Email_Member_Update__c = true;
                        }
                        foundActiveMembership = true;
                    }
                    if(con.status == 'Expired' && foundActiveMembership == false){
                        if(date.today() > con.EndDate) {
                            objContact.KPI_Membership_Expiration_Date__c = con.EndDate;
                            Integer monthDiff = con.EndDate.monthsBetween(nowDateTime);
                            objContact.KPI_Membership_Payment_Lapsed_Months__c = monthDiff;
                            objContact.KPI_Membership_Payment_Status__c = 'Lapsed';
                        }
                    }
                    if(con.status != 'Draft'){
                        if(con.StartDate != date.newinstance(1999, 1, 1)){
                            if(objContact.Date_Joined__c == null)
                            	objContact.Date_Joined__c = con.StartDate;
                        }
                    }

                    if (lastMemberContract == null) {
                        lastMemberContract = con;
                    }else if (lastMemberContract != null) {
                        if (con.StartDate > lastMemberContract.StartDate)
                            lastMemberContract = con;
                    }
                }
                
                if (con.recordTypeId == CPETypeId)
                { 
                    if (con.status.contains('Activated') || con.status =='Completed' || con.status == 'Expired') {
                        if (con.StartDate != null) { 
                            if(objContact.KPI_CPE_Current_Cycle__c != NULL) {
                                objContact.CPE_Last_Cycle__c = objContact.KPI_CPE_Current_Cycle__c;
                            }
                            objContact.KPI_CPE_Current_Cycle__c = String.valueOf(con.StartDate.year()) + '/' + String.valueOf(con.StartDate.year() + 1);
                            
                            if (con.StartDate.year() <= Date.today().year()) {
                                objContact.KPI_CPE_Participation__c = true;
                            }
                        }
                    }
                }
                if (con.recordTypeId == FBRExamTypeId) {
                    objContact.KPI_FBR_Participant__c = true;
                }
            }
            lstContactUpdate.add(objContact);
        }
        
        // Update contacts
        if(!lstContactUpdate.isEmpty()){
            update lstContactUpdate;
            
        }
    }
}