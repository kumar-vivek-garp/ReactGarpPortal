public class ExamAttemptHandlerHelper {
    
    public static void updateCandidateRequirement(Map<Id,Exam_Attempt__c> mapEA,List<Exam_Attempt__c> newExamRegList,Map<Id,Exam_Attempt__c> oldMap){
        
        List<Candidate_Requirement__c>  CR_ToUpdate = new List<Candidate_Requirement__c>();
        Map < Id,Candidate_Requirement__c > CRMap = new Map < Id,Candidate_Requirement__c > ();
        List < Contract > contractToUpdate = new List < Contract > ();
        Set <String> contractIdList = new Set <String> ();
        Set <String> examPartIdList = new Set <String> ();
        Set <String> garpIdList = new Set <String> ();
        Map<String,List<Contract>> scrDiscountMap = new Map<String,List<Contract>>();
        
        //Id FRM_Program_Contract_RTId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        //Id ERP_Program_Contract_RTId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ERP_Program');
        //Id ICBRR_Program_Contract_RTId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ICBRR_Program');
        Id SCRProgramRTId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
        Id RISKAIRTId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_AI_Program');
        Id RAIJId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','RAIJ_Program');
        
        for(Exam_Attempt__c sObj : newExamRegList){
            contractIdList.add(sObj.Candidate_Commitment__c);
            examPartIdList.add(sObj.Exam_Part__c);
            garpIdList.add(sObj.Garp_Id__c);
        }
        
        Map<ID, Contract> ContractMap = new Map<ID, Contract>([SELECT Id,Last_Exam_registration_Date__c, AccountId, recordTypeId, recordType.Name, Status, Membership_Type__c, ContractTerm, EndDate, StartDate, All_Requirements_Completed__c, All_Requirements_Completed_Date__c,Last_Day_Contract_can_be_Active__c FROM Contract WHERE Id IN: contractIdList LIMIT 50000]);
        Map<ID, Exam_Part__c> ExamPartMap = new Map<ID, Exam_Part__c>([SELECT Id, Exam_End_Date__c,Exam_Start_Date__c FROM Exam_Part__c WHERE Id IN: examPartIdList LIMIT 50000]);
        Map<ID, Candidate_Requirement__c> initialCRMap = new Map<ID, Candidate_Requirement__c>([SELECT id,Name,Date_of_Completion__c,Status__c,Certificate_Sent_Date__c,RecordTypeId,Candidate_Commitment__c,Exam__c FROM Candidate_Requirement__c WHERE Id in: mapEA.keySet() LIMIT 50000]);
        Map<ID, Contract> SCRContractMap = new Map<ID, Contract>([SELECT Id,Garp_Id__c,Eligible_For_Scr_Discount_Date__c,Eligible_For_Scr_Discount__c,
                                                                  AccountId, recordTypeId, recordType.Name, Status, Membership_Type__c, ContractTerm,EndDate, StartDate, 
                                                                  All_Requirements_Completed__c, All_Requirements_Completed_Date__c,Last_Day_Contract_can_be_Active__c 
                                                                  FROM Contract WHERE Garp_Id__c IN: garpIdList and (Recordtypeid =: SCRProgramRTId OR Recordtypeid =:RISKAIRTId OR Recordtypeid =:RAIJId)
                                                                  and Eligible_For_Scr_Discount__c = true and Eligible_For_Scr_Discount_Date__c != null]);
        
        //Map to check the discount provided for candidate for SCR
        for(Contract contr : SCRContractMap.values() ){
            if(scrDiscountMap.containskey(contr.Garp_Id__c)){
                List<Contract> contrList = scrDiscountMap.get(contr.Garp_Id__c);
                contrList.add(contr);
                scrDiscountMap.put(contr.Garp_Id__c,contrList);
            }else{
                scrDiscountMap.put(contr.Garp_Id__c,new List<Contract>{contr});
            }
        }

        
        for(Candidate_Requirement__c objCR : initialCRMap.Values()){
            Exam_Attempt__c objEA = mapEA.get(objCR.Id);
            if(objEA != null){
                if(objEA.Result__c == 'Pass'){
                    objCR.Date_of_Completion__c = mapEA.get(objCR.Id).Exam_Date__c;
                    objCR.Status__c = 'Completed';
                }
                else{
                    objCR.Date_of_Completion__c = null;
                    objCR.Status__c = null; 
                }
                CR_ToUpdate.add(objCR); 
            }
        }
        
        if(!CR_ToUpdate.isEmpty()){
            update CR_ToUpdate;
        }
        if (contractIdList.size() > 0) {
			set<Id> duplicateList = new set<Id>();           
            for(Exam_Attempt__c ExamAttempt : newExamRegList){
                Contract objContract = ContractMap.get(ExamAttempt.Candidate_Commitment__c);
                Boolean isContractChanged = False;
                String examSection = ExamAttempt.Section__c;
                //Section FRM Part 2
                if(examSection == 'FRM Part 2' && ExamAttempt.Result__c != null && ExamAttempt.Result__c != 'Pass' && ExamAttempt.Result__c != oldMap.get(ExamAttempt.Id).Result__c){
                    if(objContract.Last_Exam_registration_Date__c < system.today() &&  objContract.Last_Day_Contract_can_be_Active__c == null && objContract.Status == 'Activated'){
                        objContract.Status = 'Expired';	
                        isContractChanged = True;
                    }
                } 
                
                if(examSection != 'SCR' && examSection != 'RiskAI' &&  examSection != 'RAIJ' && ExamAttempt.Result__c != oldMap.get(ExamAttempt.Id).Result__c  && ExamAttempt.Result__c == 'Pass'){
                    
                    
                    if(objContract != null && examAttempt.Result__c == 'Pass') {
                        
                        if ((examSection == 'ERP Part II'|| examSection == 'ERP') || (examSection == 'FRM Part 2' || examSection == 'FRM Full')) {
                            Date dtCurrentDay = ExamAttempt.Exam_Date__c;
                            Date dtEndDate = objContract.StartDate;
                            Integer iDiffMnths =dtEndDate.monthsBetween(dtCurrentDay);
                            objContract.ContractTerm = iDiffMnths + 120; //US-62556
                            objContract.Status = 'Activated';
                            isContractChanged = True;
                        }
                        
                        else if (examSection == 'FRM Part 1' || examSection == 'ERP Part I') {
                            Date dtCurrentDay = ExamAttempt.Exam_Date__c;
                            Date dtEndDate = objContract.StartDate;
                            Integer iDiffMnths =dtEndDate.monthsBetween(dtCurrentDay);
                            objContract.ContractTerm = iDiffMnths + 48;
                            objContract.Status = 'Activated';
                            isContractChanged = True;
                        } 
                    }
                }
                
                else if(examSection == 'SCR' || examSection == 'RiskAI' || examSection == 'RAIJ'){ //Chinnapa
                    //'Mark scr program as completed' of 'SCR Completion' Process Builder
                    if(ExamAttempt.Opportunity_StageName__c == 'Closed' && ExamAttempt.Cancelled__c == False && ExamAttempt.Result__c == 'Pass'){
                        objContract.All_Requirements_Completed_Date__c = System.Today();
                        objContract.All_Requirements_Completed__c = True;
                        objContract.Status = 'Completed';
                        isContractChanged = True;
                    }
                    
                    //'Mark Scr Program for Discount' of 'SCR Completion' Process Builder
                    if(ExamAttempt.Result__c != null && ExamAttempt.Result__c != 'Pass' && ExamAttempt.Cancelled__c == False && ExamAttempt.Opportunity_StageName__c == 'Closed' && ExamAttempt.Result__c != oldMap.get(ExamAttempt.Id).Result__c){
                        if(!scrDiscountMap.containskey(ExamAttempt.Garp_Id__c)){
                            objContract.Eligible_For_Scr_Discount_Date__c = System.Today().addMonths(12);
                            objContract.Eligible_For_Scr_Discount__c = True;
                        }else if(scrDiscountMap.containskey(ExamAttempt.Garp_Id__c)){
                            for(Contract contr : scrDiscountMap.get(ExamAttempt.Garp_Id__c)){
                                if(objContract.Id != contr.Id && !duplicateList.contains(contr.Id)){
                                    contr.Eligible_For_Scr_Discount_Date__c = null;
                                    contr.Eligible_For_Scr_Discount__c = false;
                                    duplicateList.add(contr.Id);
                                    contractToUpdate.add(contr);
                                }
                            }
                        }
                        objContract.Status = 'Expired';
                        isContractChanged = True;
                    }
                    
                    
                    //'SCR Deferal' of 'SCR Completion' Process Builder
                    if(ExamAttempt.Cancelled__c == False && (String.isNotBlank(ExamAttempt.Defered__c) || ExamAttempt.Defered__c != oldMap.get(ExamAttempt.Id).Defered__c)){
                        if(objContract.RecordTypeId == SCRProgramRTId && objContract.Status == 'Activated'){
                            objContract.SCR_Deferred_Status__c = String.ValueOf(ExamAttempt.Defered__c);
                            isContractChanged = True;
                        }
                    } 
                }
                 
                //FRRMC
                if(ExamAttempt.Section__c != null && ExamAttempt.Result__c != null && objContract != null && ExamAttempt.Result__c != oldMap.get(ExamAttempt.Id).Result__c && IntegrationsMtdUtil.contractExamSeacionCodes.contains(ExamAttempt.Section__c)){
                    if(examAttempt.Result__c == 'Pass') {
                        objContract.Status = 'Completed';
                        objContract.All_Requirements_Completed__c = True;
                        isContractChanged = True; 
                    }/*else if(ExamAttempt.Result__c != 'Pass' && ExamAttempt.Cancelled__c == False && ExamAttempt.Opportunity_StageName__c == 'Closed'){
                        objContract.Status = 'Expired';
                        isContractChanged = True; 
                    }*/
                }
                if(isContractChanged){  
                    contractToUpdate.add(objContract);
                }
            }
        }
        if(contractToUpdate.size() > 0){ 
            update contractToUpdate;
        }
    }
    
    public static void callExamRegistrationHandlerClass(List<Exam_Attempt__c> newList,Map<Id,Exam_Attempt__c> oldMap){
        try{
            Default_Settings__c atapsisetting = Default_Settings__c.getValues('Default');
            if(atapsisetting.ATA_PSI_Callout__c == true){
                
                //system.debug('ATAPSIUtilClass.examRegistrationTriggerRecursion>>   '+ATAPSIUtilClass.examRegistrationTriggerRecursion);
                if(ATAPSIUtilClass.examRegistrationTriggerRecursion == false){
                    ExamRegistrationHandlerClass.ExamRegistration(newList,oldMap);
                }
            }
        }
        catch(Exception ex){} 
    }
    
}