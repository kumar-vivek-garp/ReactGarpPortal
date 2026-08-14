public class OpportunityTriggerHelper_New {
    
    public static Map<String,Opportunity_Product_Mapping__mdt> getOppProductMethodMap(){
        Map<String,Opportunity_Product_Mapping__mdt> oppProductToMethodMap = new Map<String,Opportunity_Product_Mapping__mdt>();
        List<Opportunity_Product_Mapping__mdt> oppsMetadata = [Select DeveloperName,MasterLabel,Map_Key__c,Price_Check__c,Product_Category__c,Product_Sub_Category__c from Opportunity_Product_Mapping__mdt where Map_Key__c != null];
        
        for(Opportunity_Product_Mapping__mdt opm : oppsMetadata){
            oppProductToMethodMap.put(opm.DeveloperName,opm);
        }
        return oppProductToMethodMap;
    }
    
    public static Map<String,Opportunity_Product_Mapping__mdt> getOppProductMethodMapAllProducts(){
        Map<String,Opportunity_Product_Mapping__mdt> oppProductToMethodMap = new Map<String,Opportunity_Product_Mapping__mdt>();
        List<Opportunity_Product_Mapping__mdt> oppsMetadata = [Select DeveloperName,MasterLabel,Map_Key__c,Price_Check__c,Product_Category__c,Product_Sub_Category__c from Opportunity_Product_Mapping__mdt];
        
        for(Opportunity_Product_Mapping__mdt opm : oppsMetadata){
            oppProductToMethodMap.put(opm.DeveloperName,opm);
        }
        return oppProductToMethodMap;
    }
    
    public static void setScholarshipApplicationStatusAsUsed(Set<Id> scholarshipApplicationIds){
        
        List<Scholarship_Application__c> scholarshipApplications = [
            SELECT Id, Status__c, Applicant__c, Exam_Group__c, Exam_Group__r.Next_Exam_Group__c
            FROM Scholarship_Application__c
            WHERE
            Status__c = 'Approved' AND
            Id IN :scholarshipApplicationIds
        ];
        
        for(Scholarship_Application__c sa: scholarshipApplications){
            sa.Status__c = 'Used';
        }
        
        if(!scholarshipApplications.isEmpty()){
            UPDATE scholarshipApplications;
        }
    }
    
    public static void processDuplicateShipping(Set<Id> oppsIdSet,Map<Id,Opportunity> newMap,String certType,List<Contact> contactList){
        Map<Id,String> acctToCertMap = new Map<Id,String>();
        for(Id oppId : oppsIdSet){
            if(newMap.containsKey(oppId)){
                acctToCertMap.put(newMap.get(oppId).AccountId,certType);
            }
        }
        if(!acctToCertMap.isEmpty()){
            CreateDuplicateShipping(acctToCertMap,contactList);
        }
        
    }
    
    public static void CreateDuplicateShipping(Map<Id,String> accountToCert,List<Contact> contactList){
        List<certificate_shipping__c> certShipList = new List<certificate_shipping__c>();
        Id DuplicateCertificates = RecordTypeHelper.getRecordTypeIdFromSchema('certificate_shipping__c','Duplicate_Certificate');
        Map<Id,Contact> mapContact = new Map<Id,Contact>();  
        
        for(Contact ct : contactList){
            mapContact.put(ct.accountId,ct);
        }
        
        for(Id accountId : accountToCert.keyset()){
            certificate_shipping__c c = new certificate_shipping__c();
            c.Member__c = mapContact.get(accountId).Id;
            c.RecordTypeid = DuplicateCertificates;
            c.Garp_id__c = mapContact.get(accountId).GARP_Member_Id__c;
            c.Certificate_Type__c = accountToCert.get(accountId);
            c.Run_Now__c = true;
            certShipList.add(c);
        }
        
        if(!certShipList.isEmpty()){
            insert certShipList;
        }    }
    
    public static void updateContracts(List<Contract> contractList,List<Contact> contactList,Map<String,Set<Id>> contractUpdateToRecIdMap,Map<Id, OpportunityLineItem> lineItemByOpportunityId,Map<Id,Opportunity> renewOpps,List<Contract> ostaContractsUpdate,List<Contract> ostaContractsInsert){
        List<Contract> lstContractsToUpdate = new List<Contract>();
        List<Contract> lstContractsToInsert = new List<Contract>();
        List<Contract> insertedContractList = new List<Contract>();
        List<Contact> lstContacts = new List<Contact>();
        List<OpportunitylineItem> oliToUpdate = new List<OpportunitylineItem>();
        Map<Id,Contract> accIdToOSTAMap = new Map<Id,Contract>();
        Map<Id,Contract> accIdToFRMMap = new Map<Id,Contract>();
        Map<Id,Contract> accIdToRiskDotnetMap = new Map<Id,Contract>();
        Map<Id,Contact> accIdToContactMap = new Map<Id,Contact>();
        Map<Id,String> accIdToMemberTypeMap = new Map<Id,String>();
        Set<Id> foundMemPrgsForAccounts = new Set<Id>();
        Id memberRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        Id frmRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRM_Program');
        Id erpRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'ERP_Program');
        Id frrRecTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'ICBRR_Program');
        Id frr25RecTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRR25_Program');
        Id OSTARecTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'OSTA_Program');
        Id riskNetRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_Net');
        Id fbrRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FBR_Program');
        Id fbraRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FBRA_Program');
        Id SCRRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
        Id RiskAIProgramID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_AI_Program');
        Id RAIJProgramID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','RAIJ_Program');
        Id ARPMProgramID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ARPM_Program');
        // Get Micro Course Programs
        List<Exam__c> lstExam = [select id, MC_Course_Program_Record_Type_API_Name__c from Exam__c where Exam_Group__r.RecordType.Name = 'MicroCourse'];
        Set<String> microCourseRecordTypes = new Set<String>();
        for(Exam__c ex :lstExam) {        
            String recTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', ex.MC_Course_Program_Record_Type_API_Name__c);
            microCourseRecordTypes.add(recTypeId);
        }
        
        if(ostaContractsInsert != null && !ostaContractsInsert.isEmpty())
            lstContractsToInsert.addAll(ostaContractsInsert);
        if(ostaContractsUpdate != null && !ostaContractsUpdate.isEmpty())
            lstContractsToUpdate.addAll(ostaContractsUpdate);
        
        for(String s : contractUpdateToRecIdMap.keyset()){
            if(s == 'AffiliateMember'){
                for(id accId : contractUpdateToRecIdMap.get(s)){
                    accIdToMemberTypeMap.put(accId,'Affiliate');
                }
            }else if(s == 'IndividualMember'){
                for(id accId : contractUpdateToRecIdMap.get(s)){
                    accIdToMemberTypeMap.put(accId,'Individual');
                }
            }else if(s == 'IndividualMemberHalfYear'){
                for(id accId : contractUpdateToRecIdMap.get(s)){
                    accIdToMemberTypeMap.put(accId,'HalfYearFree');
                }
            }
            
        }
        
       // system.debug('check map:'+accIdToMemberTypeMap);
        
        //Update contacts
        for(Contact objCon : contactList)
        {
           // system.debug('Check this place');
            accIdToContactMap.put(objCon.AccountId,objCon);
            if(contractUpdateToRecIdMap.containskey('UpdateRecurringIntent') && contractUpdateToRecIdMap.get('UpdateRecurringIntent').contains(objCon.AccountId)){
                objCon.KPI_Membership_Auto_Renew_Status__c = true;
                lstContacts.add(objcon);
            }
        }
        //Update RecurringIntentContracts
        for(Contract objContr : contractList){
            boolean updateContract = false;
            if(contractUpdateToRecIdMap.containskey('UpdateRecurringIntent') && contractUpdateToRecIdMap.get('UpdateRecurringIntent').contains(objContr.AccountId) 
               && objContr.RecordTypeId == memberRecordTypeID && (objContr.Status == 'Activated' || objContr.Status == 'Draft')){
                   objContr.status = 'Activated ( Auto-Renew )';
                   updateContract = true;
               }
            //Update secnd FRR or 2009 register contracts 
            if(contractUpdateToRecIdMap.containskey('UpdateFRRor2009') && contractUpdateToRecIdMap.get('UpdateFRRor2009').contains(objContr.AccountId) ){
                if(objContr.status == 'Activated ( Auto-Renew )' || objContr.status == 'Activated'){
                    if(objContr.RecordTypeId == frmRecordTypeID || objContr.RecordTypeId == erpRecordTypeID){
                        objContr.Enrollment_paid_for_2009__c = true;
                        updateContract = true;
                    }else if(objContr.RecordTypeId == frrRecTypeId){
                        objContr.Second_Attempt_FRR__c = true;
                        updateContract = true;
                    }
                }
            }
            //Create Maps to use later for different record types 
            if((objContr.status == 'Activated ( Auto-Renew )' || objContr.status == 'Activated' || objContr.Status == 'Draft') && objContr.RecordTypeId == frmRecordTypeID){
                accIdToFRMMap.put(objContr.AccountId,objContr);
            }
            
            if((objContr.status == 'Activated ( Auto-Renew )' || objContr.status == 'Activated') && objContr.RecordTypeId == OSTARecTypeId){
                accIdToOSTAMap.put(objContr.AccountId,objContr);
            }
            
            if((objContr.status == 'Activated ( Auto-Renew )' || objContr.status == 'Activated' || objContr.Status == 'Draft') && objContr.RecordTypeId == riskNetRecordTypeID){
                accIdToRiskDotnetMap.put(objContr.AccountId,objContr);
            }
            //Activate different Renew contracts 
            Id renewOppId = renewOpps.containsKey(objContr.AccountId) ? renewOpps.get(objContr.AccountId).Id : null;
            if(objContr.status == 'Draft' && objContr.recordTypeID == riskNetRecordTypeID && objContr.Opportunity__c == renewOppId){
                objContr.status = 'Activated';
                updateContract = true;
            }
            if(objContr.status == 'Draft' && (objContr.recordTypeID == SCRRecordTypeID || objContr.recordTypeID == RiskAIProgramID || objContr.recordTypeID == RAIJProgramID || objContr.recordTypeID == frrRecTypeId || objContr.recordTypeID == frr25RecTypeId || objContr.recordTypeID == ARPMProgramID || microCourseRecordTypes.contains(objContr.recordTypeID)) && objContr.Opportunity__c == renewOppId){
                objContr.status = 'Activated';
                objContr.StartDate = system.today();
                updateContract = true;
            }
            if(objContr.status == 'Draft' && (objContr.recordTypeID == frmRecordTypeID || objContr.recordTypeID == erpRecordTypeID || objContr.recordTypeID == fbrRecordTypeID  || objContr.recordTypeID ==fbraRecordTypeID) && objContr.Opportunity__c == renewOppId){
                objContr.status = 'Activated ( Auto-Renew )';
                objContr.StartDate = system.today();
                updateContract = true;
            }
            //Activat or Create Member Contracts
            if(objContr.RecordTypeId == memberRecordTypeID){
                /*system.debug('check map:'+accIdToMemberTypeMap);
                system.debug('check map get:'+accIdToMemberTypeMap.get(objContr.AccountId));
                system.debug('Inside Membership loop:'+objContr.Membership_type__c);*/
                if(objContr.Status == 'Draft' && objContr.Opportunity__c == renewOppId){
                    //system.debug('Inside Membership loop 1:'+objContr.Membership_type__c);
                    if(renewOpps.get(objContr.AccountId).Auto_Renew__c|| objContr.Membership_Type__c == 'Affiliate'){ 
                        objContr.status ='Activated ( Auto-Renew )';
                    }
                    else{ 
                        objContr.status ='Activated';
                    }
                    objContr.StartDate = system.today();
                    updateContract = true;
                    if(accIdToMemberTypeMap.containskey(objContr.AccountId))
                        foundMemPrgsForAccounts.add(objContr.AccountId);
                }else if(objContr.status.contains('Activated') 
                         && accIdToMemberTypeMap.containskey(objContr.AccountId) && objContr.Membership_Type__c == accIdToMemberTypeMap.get(objContr.AccountId))
                {
                   // system.debug('Inside Membership loop 2:'+objContr.Membership_type__c);
                    objContr.ContractTerm = objContr.ContractTerm + 12;
                    if(renewOpps.containsKey(objContr.AccountId) && renewOpps.get(objContr.AccountId).Auto_Renew__c) 
                        objContr.status ='Activated ( Auto-Renew )';
                    updateContract = true;
                    foundMemPrgsForAccounts.add(objContr.AccountId);
                }else if(objContr.status.contains('Activated') 
                         && accIdToMemberTypeMap.containskey(objContr.AccountId) && objContr.Membership_Type__c == 'Individual' && accIdToMemberTypeMap.get(objContr.AccountId) == 'HalfYearFree')
                {
                   // system.debug('Inside Membership loop 3:'+objContr.Membership_type__c);
                    objContr.ContractTerm = objContr.ContractTerm + 6;
                    if(renewOpps.containsKey(objContr.AccountId) && renewOpps.get(objContr.AccountId).Auto_Renew__c) 
                        objContr.status ='Activated ( Auto-Renew )';
                    updateContract = true;
                    foundMemPrgsForAccounts.add(objContr.AccountId);
                }else if((objContr.status.contains('Activated')) && accIdToMemberTypeMap.containskey(objContr.AccountId) 
                         && objContr.Membership_Type__c != accIdToMemberTypeMap.get(objContr.AccountId)
                        )
                {
                   // system.debug('Inside Membership loop 3:'+objContr.Membership_type__c);
                    objContr.status = 'Canceled';
                    updateContract = true;
                }
                
            }
            
            if(updateContract)
                lstContractsToUpdate.add(objContr);
        }
        
        if(!accIdToMemberTypeMap.isEmpty()){
            for(Id accId : accIdToMemberTypeMap.keyset()){
                if(!foundMemPrgsForAccounts.contains(accId)){
                    Contract newContract = opportunityTriggerUtils_New.getNewMemberContract(renewOpps.get(accId),memberRecordTypeID,accIdToMemberTypeMap.get(accId));
                    lstContractsToInsert.add(newContract);
                }
            }
        }
        
        
        if(!lineItemByOpportunityId.isEmpty()){
            for(Id oppId : lineItemByOpportunityId.keyset()){
                OpportunityLineItem oli = lineItemByOpportunityId.get(oppId);
                if(contractUpdateToRecIdMap.containskey('OSTAProgram') && contractUpdateToRecIdMap.get('OSTAProgram').contains(oppId) &&!accIdToOSTAMap.containskey(oli.Opportunity.AccountId)){
                    Id frmProgramId = accIdToFRMMap.containskey(oli.Opportunity.AccountId)?accIdToFRMMap.get(oli.Opportunity.AccountId).Id:null;
                    Contract ostaContract = opportunityTriggerUtils_New.getNewOSTAContract(oli.Opportunity.AccountId,oli.OpportunityId,accIdToContactMap.get(oli.Opportunity.AccountId).Id,OSTARecTypeId,frmProgramId);
                    lstContractsToInsert.add(ostaContract);
                }
                
                if(contractUpdateToRecIdMap.containskey('ExtendRiskDotNet') && contractUpdateToRecIdMap.get('ExtendRiskDotNet').contains(oppId)){
                   /* system.debug('Check 4');
                    system.debug(accIdToRiskDotnetMap);*/
                    Contract riskContract = accIdToRiskDotnetMap.containskey(oli.Opportunity.AccountId)?accIdToRiskDotnetMap.get(oli.Opportunity.AccountId):null;
                    if (riskContract != null && riskContract.status == 'Draft') {
                        riskContract.ContractTerm = Integer.valueOf(oli.quantity);
                        riskContract.Opportunity__c = oli.OpportunityId;
                        riskContract.Status = 'Activated';
                        lstContractsToUpdate.add(riskContract);
                    } else if (riskContract != null && riskContract.status != 'Draft') {
                        // Expiring the existing Contracts
                        riskContract.status = 'Expired';
                        riskContract.Opportunity__c = oli.OpportunityId;
                        lstContractsToUpdate.add(riskContract);
                        // Create new Contract after updating the existing 'Activated' or 'Activated-Autorenew'
                        Contract newRiskContract = opportunityTriggerUtils_New.getNewRiskContract(oli,accIdToContactMap);
                        lstContractsToInsert.add(newRiskContract);                        
                    } else {
                        Contract newRiskContract = opportunityTriggerUtils_New.getNewRiskContract(oli,accIdToContactMap);
                        lstContractsToInsert.add(newRiskContract);
                    }
                }
            }
        }
        
        if(!lstContractsToInsert.isEmpty()){
            insert lstContractsToInsert;
            insertedContractList = [Select Id,Status,AccountId,RecordTypeId from Contract where Id IN: lstContractsToInsert];
        }
        
        for(Contract cont : insertedContractList){
            if(cont.RecordTypeId == OSTARecTypeId){
                accIdToOSTAMap.put(cont.AccountId,cont);
                cont.Status = 'Activated ( Auto-Renew )';
            }else if(cont.RecordTypeId == riskNetRecordTypeID){
                cont.Status = 'Activated';
            }else if(cont.RecordTypeId == memberRecordTypeID){
                if(renewOpps.containsKey(cont.AccountId) && renewOpps.get(cont.AccountId).Auto_Renew__c){ 
                    cont.status ='Activated ( Auto-Renew )';
                }else{
                    cont.Status = 'Activated';
                }
            }
            lstContractsToUpdate.add(cont);
        }
        
        if(!lineItemByOpportunityId.isEmpty() && contractUpdateToRecIdMap.containskey('OSTAProgram')){
            for(Id oppId : lineItemByOpportunityId.keyset()){
                OpportunityLineItem oli = lineItemByOpportunityId.get(oppId);
                oli.Program__c = accIdToOSTAMap.containskey(oli.Opportunity.AccountId)?accIdToOSTAMap.get(oli.Opportunity.AccountId).Id:null;
                oliToUpdate.add(oli);
            }
        }
        
        if(!lstContacts.isEmpty()){
            update lstContacts;
        }
        
        if(!lstContractsToUpdate.isEmpty()){
            update lstContractsToUpdate;
        }
        if(!oliToUpdate.isEmpty()){
            update oliToUpdate;        
        }
        
    }
    
    public static void updateExamAttempts(Map<String,Set<Id>> examRegUpdateToRecordIdMap,List<Exam_Attempt__c> deferralRegToUpdate){
        Set<Id> examRegIdsForRetabulation = new Set<Id>();
        Set<Id> OppIdsForATAPSI = new Set<Id>(); 
        List<Exam_Attempt__c> lstUpdateEAs = new List<Exam_Attempt__c>();
       Map<String,Pearson_Exam_Series_Configuration__mdt> PearsonSectionTypeConfigMap = IntegrationsMtdUtil.getBySectionConfiguration();
        if(deferralRegToUpdate != null && !deferralRegToUpdate.isEmpty())
            lstUpdateEAs.addAll(deferralRegToUpdate);
        
        if(examRegUpdateToRecordIdMap.containskey('RetabulationRequest')){
            examRegIdsForRetabulation = examRegUpdateToRecordIdMap.get('RetabulationRequest');
        }
        if(examRegUpdateToRecordIdMap.containskey('ATAPSIIntegration')){
            OppIdsForATAPSI = examRegUpdateToRecordIdMap.get('ATAPSIIntegration');
        }
        //system.debug('>>>'+OppIdsForATAPSI);
        if(!OppIdsForATAPSI.isEmpty() || !examRegIdsForRetabulation.isEmpty()){
            List < Exam_Attempt__c > lstExamAttempts = [select id, Section__c,Opportunity_StageName__c,Opportunity__c,Cancelled__c , ATA_subject_code__c, ATA_subject_name__c,Re_score_Status__c, 
                                                        ATA_region_code__c,ATA_region_name__c , Exam_Part__r.Delivery_Method__c, Member__c, Defered__c,Exam_Site__r.Exam__r.Exam_Group__r.Active__c 
                                                        from Exam_Attempt__c 
                                                        where  ((Exam_Site__r.Exam__r.Exam_Group__r.Active__c = true OR Exam_Site__r.Exam__r.Exam_Group__r.SCR_Active__c = true OR Section__c = 'ICBRR') and Cancelled__c = false 
                                                                and Opportunity_StageName__c ='closed' and Opportunity__c in :OppIdsForATAPSI 
                                                                and Exam_Part__r.Delivery_Method__c!='Pen and Paper') OR ID IN: examRegIdsForRetabulation];
           
            for (Exam_Attempt__c updEA: lstExamAttempts) {
                boolean updateEA = false;
                if(OppIdsForATAPSI.contains(updEA.Opportunity__c)){
                    if(updEA.ATA_region_name__c  !=null && updEA.ATA_region_code__c != null){
                        updEA.Outbound_Type__c ='ATA';
                        updEA.Integration_Type__c ='Import Registration New';
                        updateEA = true;
                    }else if(updEA.ATA_region_name__c ==null && updEA.ATA_region_code__c ==null){
                       // if(updEa.Section__c == 'SCR' || updEa.Section__c == 'RAI' || updEa.Section__c == 'ICBRR'){
                        if(PearsonSectionTypeConfigMap.containsKey(updEa.Section__c)){
                            updEA.Outbound_Type__c ='Pearson';
                            updEA.Integration_Type__c ='Ping Database;CDD;EAD';
                            updateEA = true;
                        }else{
                            updEA.Outbound_Type__c ='PSI';
                            updEA.Integration_Type__c ='Eligibility Lifecycle';
                            updateEA = true;
                        }
                    }
                }
                if(examRegIdsForRetabulation.contains(updEA.Id)){
                    updEA.Re_score_Status__c = 'Awaiting Review';
                    updateEA = true;
                }
                
                if(updateEA)
                    lstUpdateEAs.add(updEA);
            }
        }
        if(!lstUpdateEAs.isEmpty()){
            update lstUpdateEAs;
        } 
    }
    
    public static void updateEventRegistrations(Map<String,Set<Id>> eventRegUpdateToRecordIdMap){
        Set<Id> oppIdForCancelUpdate = new Set<Id>();
        Set<Id> oppIdForPaymentUpdate = new Set<Id>();
        List<Event_Registration__c> evtRegToUpdate = new List<Event_Registration__c>();
        for(String method : eventRegUpdateToRecordIdMap.keyset()){
            if(method == 'UpdateCanceled'){
                oppIdForCancelUpdate.addAll(eventRegUpdateToRecordIdMap.get(method));
            }
            if(method == 'UpdatePayment'){
                oppIdForPaymentUpdate.addAll(eventRegUpdateToRecordIdMap.get(method));
            }
        }
        
        List<Event_Registration__c> evtRegList = [Select Id,Opportunity_Method_of_payment__c,Status__c,Opportunity__c 
                                                  from Event_Registration__c 
                                                  where Opportunity__c In: oppIdForCancelUpdate OR Opportunity__c In: oppIdForPaymentUpdate];
        
        for(Event_Registration__c er : evtRegList){
            boolean updateReg = false;
            if(oppIdForPaymentUpdate.contains(er.Opportunity__c) && String.isBlank(er.Opportunity_Method_of_payment__c)){
                er.Opportunity_Method_of_payment__c = 'Wire';
                updateReg = true;
            }
            if(oppIdForCancelUpdate.contains(er.Opportunity__c)){
                er.Status__c = 'Cancelled';
                updateReg = true;
            }
            
            if(updateReg)
                evtRegToUpdate.add(er);
        }
        
        if(!evtRegToUpdate.isEmpty()){
            update evtRegToUpdate;
        }
    }
    
    public static void upsertOrders(Map<Id,Opportunity> oppsMap){
       // system.debug('Map:'+oppsMap);
        List<ChargentOrders__ChargentOrder__c> ordersToUpsert = new List<ChargentOrders__ChargentOrder__c>();
        Map<Id,ChargentOrders__ChargentOrder__c> oppToOrderMap = new Map<Id,ChargentOrders__ChargentOrder__c>();
        
        List<ChargentOrders__ChargentOrder__c> oppsOrders = [Select Id,Opportunity__c,ChargentOrders__Gateway__c,
                                                             ChargentOrders__Payment_Method__c,ChargentOrders__Payment_Status__c,
                                                             ChargentOrders__Payment_Frequency__c,ChargentOrders__Charge_Date__c,
                                                             ChargentOrders__Payment_Stop__c,ChargentOrders__Payment_End_Date__c,
                                                             ChargentOrders__Payment_Start_Date__c,
                                                             ChargentOrders__Manual_Charge__c,ChargentOrders__Charge_Amount__c,
                                                             ChargentOrders__Payment_Count__c
                                                             from ChargentOrders__ChargentOrder__c
                                                             where Opportunity__c IN: oppsMap.keyset()];
        
        for(ChargentOrders__ChargentOrder__c order : oppsOrders){
            oppToOrderMap.put(order.Opportunity__c,order);            
        }
        
        for(Opportunity opp : oppsMap.values()){
            ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c();
            if(oppToOrderMap.containsKey(opp.Id)){
                order.Id = oppToOrderMap.get(Opp.Id).Id;
            }else{
                order.Opportunity__c = opp.id;
            }
            if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Refund' || opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Switch'){
                order.ChargentOrders__Invoice_Number__c = opp.Display_Invoice_Number__c;
            }else{
                order.ChargentOrders__Invoice_Number__c = 'W'+opp.GARP_Invoice_Number__c;
            }
            order.ChargentOrders__Subtotal__c = opp.Amount;
            order.ChargentOrders__Gateway__c = opp.Gateway__c;
            order.ChargentOrders__Tokenization__c = opp.Token__c;
            order.ChargentOrders__Card_Type__c = opp.CardType__c;
            order.ChargentOrders__Payment_Method__c = opp.Payment_Method_New__c;
            order.ChargentOrders__Payment_Status__c = opp.Payment_Status__c;
            order.ChargentOrders__Payment_Frequency__c = opp.Payment_Frequency__c;
            order.ChargentOrders__Charge_Date__c = opp.Charge_Date__c;
            order.ChargentOrders__Payment_Stop__c = opp.Payment_Stop__c;
            order.ChargentOrders__Payment_End_Date__c = opp.Payment_End_Date__c;
            order.ChargentOrders__Payment_Start_Date__c = opp.Payment_Start_Date__c;
            //order.ChargentOrders__Next_Transaction_Date__c = opp.Next_Transaction_Date__c;
            order.ChargentOrders__Manual_Charge__c = opp.Manual_Charge__c;
            order.ChargentOrders__Charge_Amount__c = opp.Charge_Amount__c;
            order.ChargentOrders__Payment_Count__c = opp.Payment_Count__c;
            order.ChargentOrders__Billing_Address__c = opp.Billing_Address__c;
            order.ChargentOrders__Billing_Address_Line_2__c = opp.Billing_Address_Line_2__c;
            order.ChargentOrders__Billing_City__c = opp.Billing_City__c;
            order.ChargentOrders__Billing_Company__c = opp.Billing_Company__c;
            order.ChargentOrders__Billing_Country__c = opp.Billing_Country__c;
            order.ChargentOrders__Billing_Email__c = opp.Billing_Email__c;
            order.ChargentOrders__Billing_Fax__c = opp.Billing_Fax__c;
            order.ChargentOrders__Billing_First_Name__c = opp.Billing_First_Name__c;
            order.ChargentOrders__Billing_Last_Name__c = opp.Billing_Last_Name__c;
            order.ChargentOrders__Billing_Phone__c = opp.Billing_Phone__c;
            order.ChargentOrders__Billing_State_Province__c = opp.Billing_State_Text__c;
            order.ChargentOrders__Billing_Zip_Postal__c = opp.Billing_Zip_Postal__c;
            order.ChargentOrders__Shipping_Address__c = opp.Shipping_Address__c;
            order.Do_Not_Change_Amount__c = opp.Do_Not_Change_Amount__c;
            if(String.isNotBlank(opp.Order_Type_New__c)){
                order.ChargentOrders__Order_Information__c = order.ChargentOrders__Invoice_Number__c+';'+opp.GARP_Member_ID__c+';'+opp.Order_Type_New__c;
            }else{
                order.ChargentOrders__Order_Information__c = order.ChargentOrders__Invoice_Number__c+';'+opp.GARP_Member_ID__c+';'+opp.Name;
            }
            ordersToUpsert.add(order);
        }
        
        if(!ordersToUpsert.isEmpty()){
            upsert ordersToUpsert;
        }
    }
    
    public static void closeRateOffers(Set<String> productCodes, Set<String> glCodes, List<Contact> lstContact, Set<String> productKeys){
        
        MAP<String,String> mapEmailCont = new MAP<String,String>();
        for(Contact c :lstContact) {
            mapEmailCont.put(c.Email.tolowercase(),c.Id);
        }
        
        LIST<Product_Rate_Offering__c> lstRates = [select id, Customer_Email__c, Status__c, 
                                                   Current_Product__r.ProductCode, Current_Product__r.GL_Code__c, 
                                                   Contact__c, Attestation_Required__c
                                                   from Product_Rate_Offering__c WHERE
                                                   Current_Product__r.ProductCode in :productCodes AND 
                                                   Current_Product__r.GL_Code__c in :glCodes AND 
                                                   Customer_Email__c in :mapEmailCont.keyset() AND Status__c = 'Active'];
        
        if(lstRates != NULL && lstRates.size() > 0) {
            List<Product_Rate_Offering__c> updateProductRates = new List<Product_Rate_Offering__c>();
            for(Product_Rate_Offering__c pro :lstRates) {
                if(productKeys.contains(pro.Current_Product__r.ProductCode + ':' + pro.Current_Product__r.GL_Code__c + ':' + pro.Customer_Email__c.tolowercase())) {
                    if(pro.Attestation_Required__c) {
                        pro.Status__c = 'Attested';
                    } else {
                        pro.Status__c = 'Used';
                    }
                    pro.Contact__c = mapEmailCont.get(pro.Customer_Email__c.tolowercase());
                    updateProductRates.add(pro);
                }
            }
            update updateProductRates;
        }
    }
    
    /*public static void closeBulkOrders(Map<Id, Opportunity> masterOrdersMap) {

if(!masterOrdersMap.isEmpty()) {

List<ChargentOrders__Transaction__c> transactions = [
SELECT Id, Name, Opportunity__c, ChargentOrders__Amount__c, ChargentOrders__Gateway_ID__c, ChargentOrders__Gateway_Date__c, ChargentOrders__Type__c, ChargentOrders__Response_Status__c, ChargentOrders__Payment_Method__c 
FROM ChargentOrders__Transaction__c 
WHERE Opportunity__c in :masterOrdersMap.keyset()
];
Map<Id, ChargentOrders__Transaction__c> transactionByMasterOrderId = new Map<Id, ChargentOrders__Transaction__c>();
for(ChargentOrders__Transaction__c t: transactions){
transactionByMasterOrderId.put(t.Opportunity__c, t);
}
List<Opportunity> childOpportunities = [SELECT Id, Name, StageName, Inst_Sale_Opp__c 
FROM Opportunity 
WHERE Inst_Sale_Opp__c in :masterOrdersMap.keyset()];


List<Opportunity> childOppportunitiesToClose = new List<Opportunity>();
Map<Id, ChargentOrders__Transaction__c> childOppportunityTransactionsByOpportunityId = new Map<Id, ChargentOrders__Transaction__c>();        

for(Opportunity childOpportunity : childOpportunities) {

if(childOpportunity.StageName != 'Closed Lost'){

Opportunity masterOpportunity = masterOrdersMap.get(childOpportunity.Inst_Sale_Opp__c);

childOpportunity.StageName =  'Closed';

if(transactionByMasterOrderId.containsKey(masterOpportunity.Id)){

ChargentOrders__Gateway_Date__cTransaction__c masterOrderTransaction = transactionByMasterOrderId.get(masterOpportunity.Id);

ChargentOrders__Gateway_Date__cTransaction__c childOppportunityTransaction = new ChargentOrders__Transaction__c();

childOppportunityTransaction. ChargentOrders__Amount__c         = masterOrderTransaction. ChargentOrders__Amount__c;
childOppportunityTransaction. ChargentOrders__Gateway_Date__c   = masterOrderTransaction. ChargentOrders__Gateway_Date__c;
childOppportunityTransaction. ChargentOrders__Type__c           = masterOrderTransaction. ChargentOrders__Type__c;
childOppportunityTransaction. ChargentOrders__Payment_Method__c = masterOrderTransaction. ChargentOrders__Payment_Method__c;
childOppportunityTransaction. ChargentOrders__Gateway_ID__c     = masterOrderTransaction. ChargentOrders__Gateway_ID__c;
childOppportunityTransaction. Opportunity__c    = childOpportunity.Id;

childOppportunityTransactionsByOpportunityId.put(childOpportunity.Id, childOppportunityTransaction);

}

childOppportunitiesToClose.add(childOpportunity);

}

}

database.executeBatch(new BulkCloseInstitutionalSaleOrdersBatch(childOppportunitiesToClose, childOppportunityTransactionsByOpportunityId), 1);
}          
}*/
    
    /*public static Map<String,List<Product_Refunds__c>> getOppProductRefundsMap(Set<Id> oppIds){
Map<String,List<Product_Refunds__c>> oppProductRefundsMap = new Map<String,List<Product_Refunds__c>>();
List<Product_Refunds__c> refundList = [select Id, Refund_amount__c, Opportunity__c, Opportunity__r.AccountId,
Product__r.ProductCode, Product__r.Product_ID__c, Product__r.GL_Code__c from Product_Refunds__c where
Status__c = 'Completed'
and Opportunity__c in : oppIds];

for(Product_Refunds__c pr : refundList){
List <Product_Refunds__c> lst = oppProductRefundsMap.get(pr.Opportunity__c);
if (lst == null) {
List <Product_Refunds__c> newlst = new List <Product_Refunds__c> ();
newlst.add(pr);
oppProductRefundsMap.put(pr.Opportunity__c, newlst);
} else {
lst.add(pr);
oppProductRefundsMap.put(pr.Opportunity__c, lst);
}
}
return oppProductRefundsMap;
}

public static void updateAmtFields(Opportunity newOpp,Map<Id,List<OpportunityLineItem>> oppToProductsMap,Map<String,List<Product_Refunds__c>> oppProductRefundsMap){
Decimal frm1total = 0;
Decimal frm2total = 0;
Decimal erp1total = 0;
Decimal erp2total = 0;
Decimal erptotal = 0;
Decimal memtotal = 0;
Decimal wtotal = 0;

Decimal frmEnrollTotal = 0;
Decimal erpEnrollTotal = 0;

Map<String,Product_Refunds__c> lExamPR = new Map<String,Product_Refunds__c>();
Map<String,Product_Refunds__c> lMemPR = new Map<String,Product_Refunds__c>();
Map<String,Product_Refunds__c> lWileyPR = new Map<String,Product_Refunds__c>();
Map<String,Product_Refunds__c> lEnrollPR = new Map<String,Product_Refunds__c>();

if(oppProductRefundsMap.containsKey(newOpp.Id)){
for(Product_Refunds__c pr: oppProductRefundsMap.get(newOpp.Id)){
String productId = pr.Product__r.Product_ID__c.isNumeric() ? 'X'+pr.Product__r.Product_ID__c : pr.Product__r.Product_ID__c;
Opportunity_Product_Mapping__mdt productCodeMapping = Opportunity_Product_Mapping__mdt.getInstance(pr.Product__r.productCode);
Opportunity_Product_Mapping__mdt productIdMapping = Opportunity_Product_Mapping__mdt.getInstance(productId);
if((productCodeMapping != null && productCodeMapping.Product_Category__c == 'MemberShip') || (productIdMapping != null && productIdMapping.Product_Category__c == 'MemberShip')){
lMemPR.put(pr.Product__r.productCode,pr);
}

if((productCodeMapping != null && productCodeMapping.Product_Category__c == 'Enroll') || (productIdMapping != null && productIdMapping.Product_Category__c == 'Enroll')){
lEnrollPR.put(pr.Product__r.productCode,pr);
}

if((productCodeMapping != null && productCodeMapping.Product_Category__c == 'Exam') || (productIdMapping != null && productIdMapping.Product_Category__c == 'Exam')){
lExamPR.put(pr.Product__r.productCode,pr);
}

if(pr.Product__r.GL_Code__c == '2007' && ((productCodeMapping != null && productCodeMapping.Product_Category__c == 'Wiley') || (productIdMapping != null && productIdMapping.Product_Category__c == 'Wiley'))){
lWileyPR.put(pr.Product__r.productCode,pr);
}
}

}

if(oppToProductsMap.containskey(newOpp.Id)){
for(OpportunityLineItem ol: oppToProductsMap.get(newOpp.Id)){
String productId = (ol.Product2.Product_ID__c != null && ol.Product2.Product_ID__c.isNumeric()) ? 'X'+ol.Product2.Product_ID__c : ol.Product2.Product_ID__c;
Opportunity_Product_Mapping__mdt productCodeIdMapping = Opportunity_Product_Mapping__mdt.getInstance(ol.Product2.productCode) != null ? Opportunity_Product_Mapping__mdt.getInstance(ol.Product2.productCode) : Opportunity_Product_Mapping__mdt.getInstance(productId);

if(productCodeIdMapping != null && productCodeIdMapping.Product_Category__c == 'MemberShip'){
if(!lMemPR.containskey(ol.Product2.ProductCode)){
memtotal += ol.TotalPrice; 
}
}

if(ol.Product2.GL_Code__c == '2007' && (productCodeIdMapping != null && productCodeIdMapping.Product_Category__c == 'Wiley')){

if(!lWileyPR.containskey(ol.Product2.ProductCode)){
wtotal += ol.TotalPrice;
}
}

if(productCodeIdMapping != null && productCodeIdMapping.Product_Category__c == 'Enroll'){
if(productCodeIdMapping.Product_Sub_Category__c == 'FRM'){
if(!lEnrollPR.containskey(ol.Product2.ProductCode)){
frmEnrollTotal += ol.TotalPrice; 
} 
}else if(productCodeIdMapping.Product_Sub_Category__c == 'ERP'){
if(!lEnrollPR.containskey(ol.Product2.ProductCode)){
erpEnrollTotal += ol.TotalPrice; 
}
}
}

if(productCodeIdMapping != null && productCodeIdMapping.Product_Category__c == 'Exam'){
if(productCodeIdMapping.Product_Sub_Category__c == 'FRM1'){
if(!lExamPR.containskey(ol.Product2.ProductCode)){
frm1total += ol.TotalPrice; 
} 
}else if(productCodeIdMapping.Product_Sub_Category__c == 'FRM2'){
if(!lExamPR.containskey(ol.Product2.ProductCode)){
frm2total += ol.TotalPrice; 
}
}else if(productCodeIdMapping.Product_Sub_Category__c == 'ERP1'){
if(!lExamPR.containskey(ol.Product2.ProductCode)){
erp1total += ol.TotalPrice; 
}
}else if(productCodeIdMapping.Product_Sub_Category__c == 'ERP2'){
if(!lExamPR.containskey(ol.Product2.ProductCode)){
erp2total += ol.TotalPrice; 
}
}else if(productCodeIdMapping.Product_Sub_Category__c == 'ERP'){
if(!lExamPR.containskey(ol.Product2.ProductCode)){
erptotal += ol.TotalPrice; 
}
}
}
}
}

newOpp.FRM_1_Registration_Fee__c = frm1total;
newOpp.FRM_2_Registration_Fee__c = frm2total;
newOpp.ERP_Registration_Fee__c = erptotal;
newOpp.ERP_1_Registration_Fee__c = erp1total;
newOpp.ERP_2_Registration_Fee__c = erp2total;
newOpp.ERP_Enrollment_Fee__c = erpEnrollTotal;
newOpp.FRM_Enrollment_Fee__c = frmEnrollTotal;
newOpp.Membership_Fee__c = memtotal;
newOpp.Risk_net_fee__c = wtotal;
}*/
}