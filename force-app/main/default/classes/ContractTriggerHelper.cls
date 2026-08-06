/*
* HelperClass for ContractTriggerHandler 
* */

public class ContractTriggerHelper {
    
    /*
* StoppingChargentSFAPayment - Used to Stop the Payment based on the Contract status not eaqual to 'Activated ( Auto-Renew )'
* */
    public static List<Opportunity> StoppingChargentSFAPayment(List<Opportunity> opp,Set<Id> setOpps1) {
        List<Opportunity> lstOpps = new List<Opportunity>();
        for(Opportunity objOpp : opp)
        {
            objOpp.Payment_Status__c = 'Stopped';
            objOpp.Stripe_Outbound_Type__c = 'Cancel';
            lstOpps.add(objOpp);
        }
        
        return lstOpps;
        // update lstOpps;
    }
    
    /*
* CPEContract method performes the logic that needs to be done when allrequirements is true
* */
    public static void CPEContract(Map<id,Contract> newlyCompletedContractMap, Map<id,id> contractAcctIds ) {        
        map<id,id> ContractID2reqID = new map<id,id>() ;
        Map<id,id> currentContractRecordTypeIds = new map<id,id>();
        Map<Id,Contract> accountToCPEContractMap = new  Map<Id,Contract>();
        List<Contract> UpdateEmailOnContact = new List<Contract>();
        list<Candidate_Requirement__c> newAttestRequirements = new List<Candidate_Requirement__c>();
        List<Contract> contractsToUpdate = new List<Contract>();
        list<contract> newCPEContracts = new List<contract>();
        list<Candidate_Requirement__c> newCPERequirements = new List<Candidate_Requirement__c>();
        list< Candidate_Requirement__c > CPERequirementsToUpdate = new List<Candidate_Requirement__c>();
        list<CPE_Claim__c> lstCreateCpeClaim = new list<CPE_Claim__c>();
        
    
        // RecordType Id's
        id SCRExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'SCR_Program');
        id RAIExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'Risk_AI_Program'); //Chinnapa
        id RAIJExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'RAIJ_Program');
        id FRMExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRM_Program');
        id ERPExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'ERP_Program');
        id ICBRRExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'ICBRR_Program');
        id FRR25ExamTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRR25_Program');
        
        id progReqCPECredit = RecordTypeHelper.getRecordTypeIdFromSchema('Candidate_Requirement__c', 'CPE');
        id CPETypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'CPE');
        id MembershipTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'Membership');
        Id examRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Candidate_Requirement__c', 'Exam');
        Id AttestCandidateReqRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Candidate_Requirement__c','Attest');
        Map<String,Pearson_Exam_Series_Configuration__mdt> FRRSeriesTypeList = IntegrationsMtdUtil.getIsFRRSeriesProgramType();
        String cpeClaimActivityTypeId = System.Label.PassingRelevantCPEClaimRecord;
        Date today = date.today();
        Date laststartDt;        
        Date ThisStartDt;
        Date NextStartDt;
        Date startDt; 
        Integer yearval = date.today().year();
        if(today.month() >= 7) {
            startDt = date.newInstance(yearval+1, 1, 1 );
            lastStartDt = date.newInstance(yearval-1, 1, 1 );
            ThisStartDt = date.newInstance(yearval, 1, 1 );
            NextStartDt = date.newInstance(yearval+1, 1, 1 );
        } else {
            laststartDt = date.newInstance(yearval-1, 1, 1 );
            ThisStartDt = date.newInstance(yearval, 1, 1 );
            startDt = date.newInstance(yearval, 1, 1 );
        }
        
        List<Contract> lstContract = [SELECT Id,  AccountId, Opportunity__c, OwnerId, StartDate,EndDate,Status,
                                       Opportunity__r.AccountId,Opportunity__r.Frm1__c,Opportunity__r.Frm2__c,Opportunity__r.Erp1__c,Opportunity__r.Erp2__c,CustomerSignedId,
                                       (Select Id,CPE_Credit_Requirement__c,Candidate_Commitment__c,GARP_ID__c from Candidate_Requirements__r where recordTypeID =: progReqCPECredit) 
                                       FROM Contract  
                                       WHERE AccountId IN :contractAcctIds.keySet() 
                                       AND RecordTypeId =: CPETypeId];
         
        for( contract c : lstContract) {
            if((c.Status == 'Activated ( Auto-Renew )' || c.Status == 'Completed') && 
               (c.StartDate == lastStartDt || c.StartDate == ThisStartDt || c.StartDate == NextStartDt)) {
                   accountToCPEContractMap.put(c.AccountId,c);
               }
        }
 
        for ( contract c : newlyCompletedContractMap.values()){
            if(accountToCPEContractMap.containsKey(c.AccountId))
            {
                Contract cpe = accountToCPEContractMap.get(c.AccountId);
                if (cpe.Candidate_Requirements__r != null && !cpe.Candidate_Requirements__r.isEmpty()) {
                Candidate_Requirement__c cr = cpe.Candidate_Requirements__r[0];
                 Id recid = c.RecordTypeID;
                if((recid == SCRExamTypeId || recid == RAIExamTypeId || recid == RAIJExamTypeId) && (cpe.Status == 'Activated ( Auto-Renew )' || cpe.Status == 'Activated') ){
                    CPE_Claim__c  cpeClaim = new CPE_Claim__c ();
                    cpeClaim.Candidate_Requirement__c = cr.id;
                    cpeClaim.CPE_Activity_Type__c = cpeClaimActivityTypeId;
                    cpeClaim.Credits_Earned__c = 20;//US-62588
                    cpeClaim.Member__c = c.CustomerSignedId;
                    cpeClaim.Date_of_Completion__c = Date.Today() ;
                    cpeClaim.EventTitle__c = 'Sustainability and Climate Risk (SCR) Exam';
                    cpeClaim.Area_of_Study__c = 'Sustainability and Climate Risk';
                    if(c.RecordTypeID == RAIExamTypeId){
                       cpeClaim.EventTitle__c = 'RAI Completed'; 
                       cpeClaim.Area_of_Study__c = 'Risk And AI';
                    }else if(c.RecordTypeID == RAIJExamTypeId){
                       cpeClaim.EventTitle__c = 'RAIJ Completed'; 
                       cpeClaim.Area_of_Study__c = 'Risk and AI in Japanese';
                    }
                   
                    cpeClaim.Provider__c = c.Opportunity__r.AccountId;
                    if(cpe.Opportunity__r.Frm1__c == true || cpe.Opportunity__r.Frm2__c == true){
                        cpeClaim.FRM__c = true;
                    } else if(cpe.Opportunity__r.Erp1__c == true || cpe.Opportunity__r.Erp2__c == true) {
                        cpeClaim.ERP__c = true;
                    }
                    lstCreateCpeClaim.add(cpeClaim);
                }else if(FRRSeriesTypeList.containsKey(recid)){
                    CPE_Claim__c  cpeClaim = new CPE_Claim__c ();
                    cpeClaim.Candidate_Requirement__c = cr.id;
                    cpeClaim.CPE_Activity_Type__c = cpeClaimActivityTypeId;
                    cpeClaim.Credits_Earned__c = 5;
                    cpeClaim.Member__c = c.CustomerSignedId;
                    cpeClaim.Date_of_Completion__c = Date.Today() ;
                    cpeClaim.EventTitle__c = FRRSeriesTypeList.get(c.RecordTypeID).Event_Title__c;
                    cpeClaim.Area_of_Study__c = FRRSeriesTypeList.get(c.RecordTypeID).Area_of_Study__c;
                    if(c.RecordTypeID == FRR25ExamTypeId){ 
                        cpeClaim.Credits_Earned__c = 20;
                    }
                    
                    cpeClaim.Provider__c = c.Opportunity__r.AccountId;
                    if(cpe.Opportunity__r.Frm1__c == true || cpe.Opportunity__r.Frm2__c == true){
                        cpeClaim.FRM__c = true;
                    } else if(cpe.Opportunity__r.Erp1__c == true || cpe.Opportunity__r.Erp2__c == true) {
                        cpeClaim.ERP__c = true;
                    }
                    lstCreateCpeClaim.add(cpeClaim);
                }else if(recid == ERPExamTypeId || recid == FRMExamTypeId){
                    cr.CPE_Credit_Requirement__c = 40;
                    CPERequirementsToUpdate.add(cr);
                    if(cpe.Status == 'Completed' && (cpe.StartDate == lastStartDt || cpe.StartDate == ThisStartDt || cpe.StartDate == NextStartDt)){
                        cpe.Status = 'Activated ( Auto-Renew )';
                        contractsToUpdate.add(cpe);
                    }
                }else{
                    contract newCPEContract = new contract (AccountId = c.AccountId,OwnerId = c.OwnerId,ContractTerm = 24, Opportunity__c = c.Opportunity__c,RecordTypeId = CPETypeId,StartDate = startDt,Status = 'draft',CustomerSignedId = c.CustomerSignedId);
                    newCPEContracts.add(newCPEContract) ;
                    if(currentContractRecordTypeIds.get(c.AccountId) == SCRExamTypeId || currentContractRecordTypeIds.get(c.AccountId) == RAIExamTypeId || currentContractRecordTypeIds.get(c.AccountId) == RAIJExamTypeId){
                       // system.debug('add SCR');
                        newCPERequirements.add ( new Candidate_Requirement__c ( Candidate_Commitment__c = c.id, recordTypeID = progReqCPECredit,Name = 'CPE', Status__c = 'Initial', CPE_Credit_Requirement__c  = currentContractRecordTypeIds.get(c.AccountId) == SCRExamTypeId ? 20 : 10 )) ;                  
                    } else if(currentContractRecordTypeIds.get(c.AccountId) == FRMExamTypeId|| currentContractRecordTypeIds.get(c.AccountId) == ERPExamTypeId){
                       // system.debug('Add FRM/ERP');
                        newCPERequirements.add ( new Candidate_Requirement__c ( Candidate_Commitment__c = c.id, recordTypeID = progReqCPECredit,Name = 'CPE', Status__c = 'Initial', CPE_Credit_Requirement__c = 40 )) ;                   
                    } 
                    currentContractRecordTypeIds.put(c.AccountId, c.RecordTypeId);
                }
                }
            } else if(!accountToCPEContractMap.containsKey(c.AccountId) && !FRRSeriesTypeList.containsKey(c.RecordTypeID)){
                contract newCPEContract = new contract (AccountId = c.AccountId,OwnerId = c.OwnerId,ContractTerm = 24, Opportunity__c = c.Opportunity__c,RecordTypeId = CPETypeId,StartDate = startDt,Status = 'draft', CustomerSignedId = c.CustomerSignedId);
                newCPEContracts.add(newCPEContract) ;
                currentContractRecordTypeIds.put(c.AccountId, c.RecordTypeId);
            }
        }
        
        if(!newCPEContracts.isEmpty())
            insert newCPEContracts;
        
        for( Contract c: newCPEContracts ) {
            c.status = 'Activated ( Auto-Renew )';
            newAttestRequirements.add ( new Candidate_Requirement__c ( Candidate_Commitment__c = c.id, recordTypeID = AttestCandidateReqRecordTypeId ,Prerequisite__c = ContractID2reqID.get( c.id ),Name = 'Attest', Status__c = 'Initial' )) ;
            if(currentContractRecordTypeIds.get(c.AccountId) == SCRExamTypeId || currentContractRecordTypeIds.get(c.AccountId) == RAIExamTypeId || currentContractRecordTypeIds.get(c.AccountId) == RAIJExamTypeId){
                //system.debug('add SCR');
                newCPERequirements.add ( new Candidate_Requirement__c ( Candidate_Commitment__c = c.id, recordTypeID = progReqCPECredit,Name = 'CPE', Status__c = 'Initial', CPE_Credit_Requirement__c  = currentContractRecordTypeIds.get(c.AccountId) == SCRExamTypeId ? 20 : 10 )) ;                  
            } else if(currentContractRecordTypeIds.get(c.AccountId) == FRMExamTypeId || currentContractRecordTypeIds.get(c.AccountId) == ERPExamTypeId){
                newCPERequirements.add ( new Candidate_Requirement__c ( Candidate_Commitment__c = c.id, recordTypeID = progReqCPECredit,Name = 'CPE', Status__c = 'Initial', CPE_Credit_Requirement__c = 40 )) ;                   
            }  
            contractsToUpdate.add(c);
        }
        
        if(!contractsToUpdate.isEmpty()){
            update contractsToUpdate ;
        }
        
        if(!CPERequirementsToUpdate.isEmpty()){
            update CPERequirementsToUpdate;
        }
        if(!lstCreateCpeClaim.isEmpty()){
            //system.debug('lstCreateCpeClaim===>'+lstCreateCpeClaim);
            insert lstCreateCpeClaim;
        }
        
        if(!newAttestRequirements.isEmpty()){
            insert newAttestRequirements ;   
        }
        
        if(!newCPERequirements.isEmpty()){
            insert newCPERequirements ; 
        }
        
    }
    
    public static void publishFontevaEvents(Set<String> accountIds){
       List<Fonteva_Updates__e> updates = new List<Fonteva_Updates__e>();
       if(!accountIds.isEmpty()){
           for(String accId : accountIds){
               Fonteva_Updates__e fontUpd = new Fonteva_Updates__e();
               fontUpd.Account_Id__c = accId;
               updates.add(fontUpd);
           }
       }
       if(!updates.isEmpty()) {
           EventBus.publish(updates);
       }
    }
}