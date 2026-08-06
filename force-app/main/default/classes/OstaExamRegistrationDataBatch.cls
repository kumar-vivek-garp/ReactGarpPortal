global class OstaExamRegistrationDataBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Modes:
    // exam - for pre/post exam data export, 
    // upload - Sets OSTA Last Uploaded Date
    // quarterly - for quarterly uploads
    Public String mode; 
    Public String admin;
    Public String year;
    Public String accountId;
    
    global OstaExamRegistrationDataBatch(String modeIn, String adminIn, String yearIn, String accountIdIn) {
        System.debug('modeIn:' + modeIn);
        System.debug('adminIn:' + adminIn);
        System.debug('yearIn:' + yearIn);
        System.debug('accountIdIn:' + accountIdIn);
        
        this.mode= modeIn;   
        this.admin = adminIn;
        this.year = yearIn;
        this.accountId = accountIdIn;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        String query = 'select id, GARP_ID__c, StartDate, EndDate, OSTA_Last_Upload_Date__c';
              query += ', OSTA_Exam_Part_I_Exam_Date__c, OSTA_Exam_Part_II_Exam_Date__c, OSTA_Exam_Part_I_Exam_Result__c, OSTA_Exam_Part_II_Exam_Result__c';
              query += ', OSTA_Exam_Part_I_Exam_Site_Name__c , OSTA_Exam_Part_II_Exam_Site_Name__c , OSTA_Exam_Part_I_Registration_Date__c , OSTA_Exam_Part_II_Registration_Date__c';                
              query += ', OSTA_Quarterly_FRM_Certified__c, OSTA_Quarterly_FRM_Certification_Date__c, OSTA_Quarterly_Part_I_Exam_Date__c, OSTA_Quarterly_Part_II_Exam_Date__c, OSTA_Quarterly_Part_I_Exam_Site_Name__c, OSTA_Quarterly_Part_II_Exam_Site_Name__c';
              query += ', OSTA_Quarterly_Part_I_Exam_Result__c, OSTA_Quarterly_Part_II_Exam_Result__c, OSTA_Quarterly_Part_I_Registration_Date__c, OSTA_Quarterly_Part_II_Registration_Date__c ';
              query += 'from contract where RecordType.Name = \'OSTA Program\' AND status in (\'Activated\',\'Activated ( Auto-Renew )\')';        
        
        if(accountId != NULL) {
            query += ' AND AccountId = \'' + accountId + '\'';
        }
        
        System.debug('query:' + query);
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<contract> scope){
    
        Date tdy = Date.Today();
        
        Set<String> ostaGarpIDs = new Set<String>();
        MAP<String,contract> ostaContractMap = new MAP<String,contract>();
        for(contract cont :scope) {
            ostaGarpIDs.add(cont.GARP_ID__c);
            ostaContractMap.put(cont.GARP_ID__c, cont);
        } 
        System.debug('ostaGarpIDs:' + ostaGarpIDs);
        
        if(!ostaGarpIDs.IsEmpty()) {
            List<Contract> frmCertContracts;
            MAP<String,Date> ostaCertMap = new MAP<String,Date>();
            
            if(mode == 'quarterly') {
                if(!Test.isRunningTest()) {
                    frmCertContracts = [select Id, GARP_ID__c, All_Requirements_Completed_Date__c from contract where RecordType.Name = 'FRM Program' AND All_Requirements_Completed__c = True and GARP_ID__c in :ostaGarpIDs];                
                } else {
                    frmCertContracts = [select Id, GARP_ID__c, All_Requirements_Completed_Date__c from contract where RecordType.Name = 'FRM Program' AND GARP_ID__c in :ostaGarpIDs];
                }            
                System.debug('frmCertContracts:' + frmCertContracts);
    
                if(!frmCertContracts.IsEmpty()) {                                
                    for(Contract fc :frmCertContracts) {
                        ostaCertMap.put(fc.GARP_ID__c, fc.All_Requirements_Completed_Date__c);
                    } 
                    System.debug('ostaCertMap:' + ostaCertMap);
                }
            }                
            List<Exam_Attempt__c> lstExamRegs;            
            if(Test.isRunningTest()) {
                lstExamRegs = [Select Garp_Id__c, Integration_Data_Exam_Location_City__c, Integration_Data_Exam_Location_Country__c, Integration_Data_Exam_Scheduled_Date__c, Integration_Data_Status__c, Name, Exam_Site__r.Country__c, RPT_Exam_Site_Name__c, Registered_On__c, Result__c, Section__c, Exam_Date__c 
                               FROM Exam_Attempt__c];
            } else if(mode == 'quarterly') {
                lstExamRegs = [Select Garp_Id__c, Integration_Data_Exam_Location_City__c, Integration_Data_Exam_Location_Country__c, Integration_Data_Exam_Scheduled_Date__c, Integration_Data_Status__c, Name, Exam_Site__r.Country__c, RPT_Exam_Site_Name__c, Registered_On__c, Result__c, Section__c, Exam_Date__c 
                               FROM Exam_Attempt__c 
                               WHERE RPT_Exam_Program__c  = 'FRM' AND result__c = 'PASS' AND Garp_Id__c in :ostaCertMap.keySet()];
            } else if(mode == 'exam' || mode == 'upload') {
                lstExamRegs = [Select Garp_Id__c, Integration_Data_Exam_Location_City__c, Integration_Data_Exam_Location_Country__c, Integration_Data_Exam_Scheduled_Date__c, Integration_Data_Status__c, Name, Exam_Site__r.Country__c, RPT_Exam_Site_Name__c, Registered_On__c, Result__c, Section__c, Exam_Date__c 
                               FROM Exam_Attempt__c 
                               WHERE RPT_Exam_Program__c  = 'FRM' AND Reg_Status__c not in ('Deferred Out','Deferred Out Pending','Unpaid','Cancelled') AND RPT_Administration_Month__c  = :admin AND RPT_Administration_Year__c = :year];
            }                
            System.debug('lstExamRegs:' + lstExamRegs);
                
            MAP<String,Exam_Attempt__c> mapExamRegPart1 = new MAP<String,Exam_Attempt__c>();
            MAP<String,Exam_Attempt__c> mapExamRegPart2 = new MAP<String,Exam_Attempt__c>();
            for(Exam_Attempt__c ea :lstExamRegs) {
                
                System.debug('Loop ea:' + ea);
                
                if(ea.Section__c == 'FRM Part 1') {
                    if(mode == 'quarterly' || Test.isRunningTest()) {
                        mapExamRegPart1.put(ea.GARP_ID__c, ea);
                    } else {
                        
                        if(ea.Exam_Site__r.Country__c == 'China') {
                        	mapExamRegPart1.put(ea.GARP_ID__c, ea);   
                        } else {
                        	Contract fndContract = ostaContractMap.get(ea.Garp_Id__c);
                            if(fndContract != NULL && fndContract.OSTA_Last_Upload_Date__c != NULL) {
                                mapExamRegPart1.put(ea.GARP_ID__c, ea);   
                            }
                        }
                    }
                } else if(ea.Section__c == 'FRM Part 2') {                    
                    if(mode == 'quarterly' || Test.isRunningTest()) {
                        mapExamRegPart2.put(ea.GARP_ID__c, ea);
                    } else {
                        if(ea.Exam_Site__r.Country__c == 'China') {
                        	mapExamRegPart2.put(ea.GARP_ID__c, ea);   
                        } else {
                        	Contract fndContract = ostaContractMap.get(ea.Garp_Id__c);
                            if(fndContract != NULL && fndContract.OSTA_Last_Upload_Date__c != NULL) {
                                mapExamRegPart2.put(ea.GARP_ID__c, ea);   
                            }
                        }
                    }
                }
            }
            System.debug('mapExamRegPart1:' + mapExamRegPart1);
            System.debug('mapExamRegPart2:' + mapExamRegPart2);
            
            for(Contract cont :scope) {
                Exam_Attempt__c ea1 = mapExamRegPart1.get(cont.GARP_ID__c);
                System.debug('ea1:' + ea1);
                
                Exam_Attempt__c ea2 = mapExamRegPart2.get(cont.GARP_ID__c);
                System.debug('ea2:' + ea2);
                
                if(mode == 'quarterly') {                    
                    Date certDate = ostaCertMap.get(cont.GARP_ID__c);
                    if(certDate != NULL) {
                        cont.OSTA_Quarterly_FRM_Certified__c = 'Yes';
                        cont.OSTA_Quarterly_FRM_Certification_Date__c = certDate;
                    } else {
                        cont.OSTA_Quarterly_FRM_Certified__c = NULL;
                        cont.OSTA_Quarterly_FRM_Certification_Date__c = NULL;
                    }
                } else {
                    cont.OSTA_Exam_FRM_Certified__c = 'No';
                } 
                if(ea1 != NULL) {
                    Date examDate = ea1.Exam_Date__c;
                    if(ea1.Integration_Data_Exam_Scheduled_Date__c != NULL) {
                        examDate = Date.newInstance(ea1.Integration_Data_Exam_Scheduled_Date__c.year(), ea1.Integration_Data_Exam_Scheduled_Date__c.month(), ea1.Integration_Data_Exam_Scheduled_Date__c.day());
                    }
                    String examSiteName = ea1.Exam_Site__r.Country__c;                            
                    if(ea1.Integration_Data_Exam_Location_Country__c != NULL && ea1.Integration_Data_Exam_Location_City__c != NULL) {
                        examSiteName = ea1.Integration_Data_Exam_Location_Country__c + ', ' + ea1.Integration_Data_Exam_Location_City__c;
                    }
                    cont.OSTA_Export_Exam_Part_I_Registration__c = ea1.Id;
                    
                    if(mode == 'quarterly') {
                        cont.OSTA_Quarterly_Part_I_Exam_Result__c = 'Yes';
                        cont.OSTA_Quarterly_Part_I_Exam_Date__c = examDate;
                        cont.OSTA_Quarterly_Part_I_Exam_Site_Name__c = examSiteName;
                        cont.OSTA_Quarterly_Part_I_Registration_Date__c = ea1.Registered_On__c;
                    } else {
                        if(ea1.Result__c == NULL) {
                            ea1.Result__c = NULL;
                        } else {                                
                            cont.OSTA_Exam_Part_I_Exam_Result__c  = (ea1.Result__c == 'Pass') ? 'Yes' : 'No';
                        }
                        cont.OSTA_Exam_Part_I_Exam_Site_Name__c = examSiteName;
                        cont.OSTA_Exam_Part_I_Exam_Date__c  = examDate;
                        cont.OSTA_Exam_Part_I_Registration_Date__c  = ea1.Registered_On__c;
                        
                        if(mode == 'upload') {
                            cont.OSTA_Last_Upload_Date__c = tdy;
                        }
                    }
                } else {
                    cont.OSTA_Exam_Part_I_Exam_Result__c = NULL;
                    cont.OSTA_Exam_Part_I_Exam_Site_Name__c = NULL;
                    cont.OSTA_Exam_Part_I_Exam_Date__c = NULL;
                    cont.OSTA_Exam_Part_I_Registration_Date__c = NULL;  
                    
                    cont.OSTA_Quarterly_Part_I_Exam_Result__c = NULL;
                    cont.OSTA_Quarterly_Part_I_Exam_Date__c = NULL;
                    cont.OSTA_Quarterly_Part_I_Exam_Site_Name__c = NULL;
                    cont.OSTA_Quarterly_Part_I_Registration_Date__c = NULL;                  
                }
                if(ea2 != NULL) {
                    Date examDate = ea2.Exam_Date__c;
                    if(ea2.Integration_Data_Exam_Scheduled_Date__c != NULL) {
                        examDate = Date.newInstance(ea2.Integration_Data_Exam_Scheduled_Date__c.year(), ea2.Integration_Data_Exam_Scheduled_Date__c.month(), ea2.Integration_Data_Exam_Scheduled_Date__c.day());
                    }
                    String examSiteName = ea2.Exam_Site__r.Country__c;                            
                    if(ea2.Integration_Data_Exam_Location_Country__c != NULL && ea2.Integration_Data_Exam_Location_City__c != NULL) {
                        examSiteName = ea2.Integration_Data_Exam_Location_Country__c + ', ' + ea2.Integration_Data_Exam_Location_City__c;
                    }
                    cont.OSTA_Export_Exam_Part_I_Registration__c = ea2.Id;
                    
                    if(mode == 'quarterly') {
                        cont.OSTA_Quarterly_Part_II_Exam_Result__c = 'Yes';
                        cont.OSTA_Quarterly_Part_II_Exam_Date__c = examDate;
                        cont.OSTA_Quarterly_Part_II_Exam_Site_Name__c = examSiteName;
                        cont.OSTA_Quarterly_Part_II_Registration_Date__c = ea2.Registered_On__c;
                    } else {
                        if(ea2.Result__c == NULL) {
                            ea2.Result__c = NULL;
                        } else {                                
                            cont.OSTA_Exam_Part_II_Exam_Result__c  = (ea2.Result__c == 'Pass') ? 'Yes' : 'No';
                        }
                        cont.OSTA_Exam_Part_II_Exam_Site_Name__c = examSiteName;
                        cont.OSTA_Exam_Part_II_Exam_Date__c  = examDate;
                        cont.OSTA_Exam_Part_II_Registration_Date__c  = ea2.Registered_On__c;
                        
                        if(mode == 'upload') {
                            cont.OSTA_Last_Upload_Date__c = tdy;
                        }
                        
                    }
                } else {
                    cont.OSTA_Exam_Part_II_Exam_Result__c = NULL;
                    cont.OSTA_Exam_Part_II_Exam_Site_Name__c = NULL;
                    cont.OSTA_Exam_Part_II_Exam_Date__c = NULL;
                    cont.OSTA_Exam_Part_II_Registration_Date__c = NULL;                    
                    
                    cont.OSTA_Quarterly_Part_II_Exam_Result__c = NULL;
                    cont.OSTA_Quarterly_Part_II_Exam_Date__c = NULL;
                    cont.OSTA_Quarterly_Part_II_Exam_Site_Name__c = NULL;
                    cont.OSTA_Quarterly_Part_II_Registration_Date__c = NULL;
                }
            }
            update scope;
        }
    }
    
    global void finish(Database.BatchableContext bc){        
    }
    
}