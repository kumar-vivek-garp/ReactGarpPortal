/**
* Class ContractTriggerHandler
*
* Trigger Handler for the 'Contract'(Contract) SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place. 
*/
public without sharing class ContractTriggerHandler implements TriggerAbstract {
    // Constructor
    
    static Map<id,Contract> newlyCompletedContractMap = new Map<id,Contract>();
    static Map<id,Contract> newlyActivatedContractMap = new Map<id,Contract>();
    static Map<id,Contract> newlyLapsedContractMap = new Map<id,Contract>();
    
    static MAP<id,id> currentContractAndAccountIds = new MAP<id,id>();
    static Map<Id,Contract> mapContractDetails = new Map<Id,contract>();
    static Map<String,set<Id>> mapUpdateEmail = new Map<String,set<Id>>();
    static List<Contract> PearsonVueNewContracts =new List<Contract>();
    static List<Opportunity> lstOpportunitiesUpdate = new List<Opportunity>();
    static Map<Id,Contract> PearsonVueOldMapContracts = new Map<Id,Contract>();
    static List<Id> lstOpp = new List<Id>();  
    static set<Id> riskDotNetContractIds = new set<Id>();
    static Set<Id> setOpps1 = new Set<Id>();
    static Set<String> accountIds = new Set<String>();
    static List<Contact_Update_Event__e> contUpdEvts = new List<Contact_Update_Event__e>();
    static List<certificate_shipping__c> certificateShippingList = new List<certificate_shipping__c>();
    
    static Id SCRRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
    static Id RAIRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_AI_Program');//Chinnapa
    static Id RAIJRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','RAIJ_Program');
    static Id ERPRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ERP_Program');
    static Id FRMRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
    static Id FRR25RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRR25_Program');//Chinnapa
    static Id CPERecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','CPE');
    static Id ICBRRRecId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ICBRR_Program');
    static Id CPECandidateReqRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Candidate_Requirement__c','CPE');
    static Id MembershipContractRTId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
    static Id AttestCandidateReqRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Candidate_Requirement__c','Attest');
    static Id RiskNetId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'Risk_Net');
    static Id OriginalCertificateId = RecordTypeHelper.getRecordTypeIdFromSchema('certificate_shipping__c', 'Original_Certificate');
    public static boolean stopRecurssion = true;
    static boolean stoptbluepublish = false;
    static List<Member_Benchprep__e> memberBenchprep = new List<Member_Benchprep__e>();
    static List<TableauIntegrationQueueable.TableauIntegrationCls> tableauIntegration = new List<TableauIntegrationQueueable.TableauIntegrationCls>(); 
    static boolean stopmempublish = false;
    public ContractTriggerHandler(){
        //system.debug('**********In ContractTriggerHandler Constructor*******  ');
        contUpdEvts = new List<Contact_Update_Event__e>();
        lstOpportunitiesUpdate = new List<Opportunity>();
        certificateShippingList = new List<certificate_shipping__c>();  
    }
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        
    }
    
    public void bulkAfter(){
         
    }
    
    public void beforeInsert(SObject so){
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
       // system.debug('**********In ContractTriggerHandler beforeUpdate*******  ');
        Contract newContract = (Contract)so;
        Contract oldContract = (Contract)oldSo;
        
        if(newContract.RecordTypeId == MembershipContractRTId && newContract.Status != 'Draft' && newContract.Member_Email_Formula__c != null){
            newContract.Member_Email__c = newContract.Member_Email_Formula__c;
        }
        if(newContract.Status == 'Completed' && (newContract.Status != oldContract.Status)) {
            newContract.Member_Email__c = newContract.Member_Email_Formula__c;
        }
        
        if(newContract.ContractTerm != oldContract.ContractTerm && newContract.Status.indexOf('Activ') > -1 ){
            newContract.Days_Left__c = newContract.StartDate.daysBetween(newContract.EndDate);
        }
        
        if (newContract.All_Requirements_Completed__c != oldContract.All_Requirements_Completed__c && newContract.All_Requirements_Completed__c == true ) {
            newContract.All_Requirements_Completed_Date__c = system.today(); 
        }
    }
    
    
    public void beforeDelete(SObject so){
        // Cast the SObject to an Exam_Attempt__c
        //system.debug('**********In ContractTriggerHandler beforeDelete*******  ');
    }
    
    public void afterInsert(SObject so){
        
    }
    
    public void afterUpdate(SObject oldSo, SObject so) {
        //system.debug('**********In ContractTriggerHandler afterUpdate*******  ');
        Contract newContract = (Contract)so;
        Contract oldContract = (Contract)oldSo;
        
        //if(stopRecurssion){
        
        if(newContract.All_Requirements_Completed__c != oldContract.All_Requirements_Completed__c &&
           newContract.All_Requirements_Completed__c == TRUE){
               allRequirementsComplete(newContract,oldContract);
           }
        
        if(newContract.All_Requirements_Completed__c != oldContract.All_Requirements_Completed__c &&
           newContract.All_Requirements_Completed__c == TRUE && newContract.RecordTypeId == FRMRecordTypeId){
               createNewCertificateShipping(newContract,oldContract);
           }
        
        if(newContract.Status != 'Draft' && oldContract.Status != newContract.Status){
            contUpdEvts.add(triggerutilities.getContactEvents(newContract.accountID,'Contract',JSON.serialize(newContract),JSON.serialize(oldContract),newContract.Id));
        }
         
        //US-62165 Start
        Id recId = newContract.RecordTypeId;
        if(newContract.Status != oldContract.Status){            
            //SCR and RAI and FRR25
            if((recId == SCRRecordTypeId || recId == RAIRecordTypeId || recId == RAIJRecordTypeId || recId == FRR25RecordTypeId) && newContract.Status == 'Completed'){
                memberBenchprep.add(triggerutilities.getContractEvents(newContract.Id,'MemberBenchprep'));
            	//system.debug('SCR RAI FRR25 MemberBenchprep');
            }else if(recId == MembershipContractRTId && newContract.Membership_Type__c == 'Individual' && oldContract.Status == 'Draft' && (newContract.Status == 'Activated ( Auto-Renew )' || newContract.Status == 'Activated')){
                //system.debug('Member MemberBenchprep');
                memberBenchprep.add(triggerutilities.getContractEvents(newContract.AccountId,'MemberBenchprep'));
                tableauIntegration.add(triggerutilities.getTableauIntegrations(newContract.AccountId,'CreateUser',newContract.Id));
            }else if(recId == MembershipContractRTId && newContract.Membership_Type__c == 'Individual' && (oldContract.Status == 'Activated ( Auto-Renew )' || oldContract.Status == 'Activated') && (newContract.Status == 'Expired' || newContract.Status == 'Canceled')){
                //system.debug('Member Canceled MemberBenchprep');
                memberBenchprep.add(triggerutilities.getContractEvents(newContract.AccountId,'MemberBenchprep'));
                tableauIntegration.add(triggerutilities.getTableauIntegrations(newContract.AccountId,'RemoveUser',newContract.Id));
            }else if(recId == FRMRecordTypeId && newContract.Part_2_completed_date__c != null && (newContract.Status == 'Expired' || newContract.Status == 'Activated')){
                memberBenchprep.add(triggerutilities.getContractEvents(newContract.Id,'MemberBenchprep'));
                //system.debug('FRM Expried MemberBenchprep');
            } else if(recId == MembershipContractRTId && newContract.Membership_Type__c == 'Individual' && oldContract.Status == 'Expired' && (newContract.Status == 'Activated ( Auto-Renew )' || newContract.Status == 'Activated')){
                 tableauIntegration.add(triggerutilities.getTableauIntegrations(newContract.AccountId,'CreateUser',newContract.Id));
            }
        } 
        if(recId == FRMRecordTypeId && newContract.Part_2_completed_date__c != null && newContract.Status == 'Activated' && newContract.Part_2_completed_date__c != oldContract.Part_2_completed_date__c){
            memberBenchprep.add(triggerutilities.getContractEvents(newContract.Id,'MemberBenchprep'));
           // system.debug('FRM MemberBenchprep');
        }else if(recId == MembershipContractRTId && newContract.Membership_Type__c == 'Individual' && newContract.EndDate != null && newContract.EndDate != oldContract.EndDate && (newContract.Status == 'Activated ( Auto-Renew )' || newContract.Status == 'Activated')){
            //system.debug('Member MemberTermChanged');
            memberBenchprep.add(triggerutilities.getContractEvents(newContract.AccountId,'MemberTermChanged'));
        }
         //US-62165 End
        if(recId == SCRRecordTypeId || recId == RAIRecordTypeId || recId == RAIJRecordTypeId || recId == ICBRRRecId) {
            PearsonVueNewContracts.add(newContract);
            PearsonVueOldMapContracts.put(newContract.Id,oldContract);
        }
        if( (oldContract.ContractTerm != newContract.ContractTerm
             || oldContract.Pearson_Member_Last_Name__c != newContract.Pearson_Member_Last_Name__c 
             || oldContract.Pearson_Member_First_Name__c != newContract.Pearson_Member_First_Name__c
             || oldContract.Pearson_Phone_No__c != newContract.Pearson_Phone_No__c
             || oldContract.Member_Email__c != newContract.Member_Email__c 
             || oldContract.Status != newContract.Status) 
           && recId == RiskNetId  
           && newContract.API_Transaction_Status__c == null
          ) {
              if(newContract.Status == 'Activated' || newContract.Status == 'Canceled' || newContract.Status == 'Expired') 
              { 
                  riskDotNetContractIds.add(newContract.Id);
              }
          }
        
        // AG Store newly Activated and Expired Contracts
        if(oldContract.Status != newContract.Status && newContract.Status.indexOf('Activ') > -1 && recId == MembershipContractRTId && (newContract.Membership_Type__c == 'Individual' || newContract.Membership_Type__c == 'Affiliate')) {
           // system.debug('check account Id:'+newContract.AccountId);
           // system.debug('check account Id:'+accountIds);
            accountIds.add(newContract.AccountId);
           // system.debug('check account Id:'+accountIds);
        }
        if(oldContract.Status != newContract.Status && newContract.Status == 'Expired' && recId == MembershipContractRTId && newContract.Membership_Type__c == 'Individual') {
            accountIds.add(newContract.AccountId);
        }
        if(oldContract.All_Requirements_Completed__c != newContract.All_Requirements_Completed__c && newContract.All_Requirements_Completed__c == True && recId == FRMRecordTypeId) {
            accountIds.add(newContract.AccountId);
        }
        if(oldContract.Status != newContract.Status && newContract.Status == 'Canceled' && 
           ((newContract.RecordTypeId == MembershipContractRTId && newContract.Membership_Type__c == 'Individual')
            || newContract.RecordTypeId == FRMRecordTypeId
            || newContract.RecordTypeId == ERPRecordTypeId)) {
                accountIds.add(newContract.AccountId);
            }
        
        if((oldContract.status == 'Activated ( Auto-Renew )' && newContract.Status != 'Activated ( Auto-Renew )')
           && newContract.RecordTypeID == MembershipContractRTId 
           &&(newContract.Membership_type__C =='Individual' || newContract.Membership_type__C =='student') 
           && oldContract.status != newContract.status)
        {
            setOpps1.add(newContract.Opportunity__c);
            lstOpp.add(newContract.Opportunity__c);
        }
        //}
        
       
    }
    
    public void afterDelete(SObject so){
        //system.debug('**********In ContractTriggerHandler afterDelete*******  ');
    }
    
    /**
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this
* method to accomplish any final operations such as creation or updates of other records.
*/
    
    public void andFinally(){
        //system.debug('**********In ContractTriggerHandler andFinally*******  ');
        //if(stopRecurssion){
        // ChargentSFAPayment
        if(Trigger.isAfter && Trigger.isUpdate ) {
            
            if(certificateShippingList.size() > 0  && stopRecurssion){
				//system.debug(certificateShippingList.size()+'  certificateShippingList  ::>>    '+certificateShippingList);
                insert certificateShippingList;
            }
			
            if(lstOpp.size() > 0) {
                List<Opportunity> opp = [SELECT id,Do_Not_change_amount__c,Payment_Status__c,Certified_Membership_Individual__c,
                                         Payment_Frequency__c,Payment_Stop__c,Next_Transaction_Date__c,
                                         Manual_Charge__c,Charge_Amount__c,Payment_Start_Date__c 
                                         FROM Opportunity
                                         WHERE id IN : lstOpp ];
                if(setOpps1.size()>0) {
                    lstOpportunitiesUpdate.addAll(ContractTriggerHelper.StoppingChargentSFAPayment(opp,setOpps1)); 
                } 
            }
            
            if(lstOpportunitiesUpdate.size()>0){
                update lstOpportunitiesUpdate; 
            }
            
            // CPE Contract
            if(newlyCompletedContractMap.size()>0 && stopRecurssion){
                stopRecurssion = false;
                ContractTriggerHelper.CPEContract(newlyCompletedContractMap,currentContractAndAccountIds);
                
            }
            if(!riskDotNetContractIds.isEmpty()) {
                List<Integration_Stream_Event__e> riskDotNetEvent = TriggerUtilities.getIntgEvents(riskDotNetContractIds, 'Contract', 'RiskDotNet');
                EventBus.publish(riskDotNetEvent);  
            }
            /*if(!PearsonVueNewContracts.isEmpty() && !PearsonVueOldMapContracts.isEmpty()) {
ScrContractTriggerHelper.createPearsonVueData(PearsonVueNewContracts,PearsonVueOldMapContracts);
}*/
            if(!accountIds.isEmpty()){
                ContractTriggerHelper.publishFontevaEvents(accountIds);
            }
            
            //Publish platform events to update contacts
            if(!contUpdEvts.isEmpty()){
                //system.debug(contUpdEvts.size()+'   <<::contUpdEvts::>>   '+contUpdEvts);
                Eventbus.publish(contUpdEvts);
            } 
            //US-62165
            if(!memberBenchprep.isEmpty() && !stopmempublish){
               // system.debug('memberBenchprep >>> :'+memberBenchprep);
                 Eventbus.publish(memberBenchprep);
                 stopmempublish = true;
            }
            //US-62469
            if(!tableauIntegration.isEmpty() && !stoptbluepublish){
                System.enqueueJob(new TableauIntegrationQueueable(tableauIntegration));
                stoptbluepublish = true;
            }
        }
        
        
        //}
    }
    
    public void allRequirementsComplete(Contract newContract, Contract oldContract) {
        //system.debug('newContract====>'+newContract.Id);
        Map<String,Pearson_Exam_Series_Configuration__mdt> FRRSeriesTypeList = IntegrationsMtdUtil.getIsFRRSeriesProgramType();
        Id rtId = newContract.RecordTypeId;
        if ((rtId == ERPRecordTypeId || rtId == FRMRecordTypeId ||
             rtId == SCRRecordTypeId || rtId == RAIRecordTypeId || rtId == RAIJRecordTypeId || rtId == CPERecordTypeId || FRRSeriesTypeList.containsKey(rtId)) &&
            newContract.All_Requirements_Completed__c == TRUE) {
                if ((oldContract != NULL && (oldContract.status == 'Activated' || oldContract.status == 'Activated ( Auto-Renew )') && 
                     newContract.All_Requirements_Completed__c != oldContract.All_Requirements_Completed__c )) {
                        
                         newlyCompletedContractMap.put(newContract.id,newContract) ;
                         currentContractAndAccountIds.put(newContract.AccountId,newContract.CustomerSignedId);
                     }
            }
        //system.debug('newlyCompletedContractMap====>'+newlyCompletedContractMap);
    }
    
    public void createNewCertificateShipping(Contract newContract, Contract oldContract) {
		certificate_shipping__c cs = new certificate_shipping__c();
        if(newContract.CustomerSignedId != null){
            cs.Member__c = newContract.CustomerSignedId;
            cs.Certificate_Type__c = 'FRM';
            cs.Garp_id__c = newContract.GARP_ID__c;
            cs.RecordTypeId = OriginalCertificateId;
            certificateShippingList.add(cs);
            //system.debug(certificateShippingList.size()+'  createNewCertificateShipping certificateShippingList  ::>>    '+certificateShippingList);
        }
    }
}