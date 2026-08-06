/**
* Class ProductRefundsTriggerHandler
*
* Trigger Handler for the (Product_Refunds__c) SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class ProductRefundsTriggerHandler implements TriggerAbstract {
    
    static List<MembershipRefundCodes__c > MembershipRefundCodeList = MembershipRefundCodes__c.getall().values();
    static Map<Id, String> garpMemberIdByOpportunityId = new Map<Id, String>();
    static List<Product_Refunds__c> lstProdRefunds = new List<Product_Refunds__c>();
    static Set<ID> setOpps = new Set<Id>();
    static Set<String> setCancelPracticeExamIds = new Set<String>();
    static Set<ID> setCancelPracticeExamOppIds = new Set<Id>();
    static Set<ID> setCancelEbooksOppIds = new Set<Id>();
    static Set<ID> setCancelERPOppIds = new Set<Id>();
    static Set<ID> setcancelEventOppIds = new Set<Id>();
    static Set<ID> setCancelFFRA = new Set<Id>();
    static Set<ID> setCancelFFRAoppIds2 = new Set<Id>();
    static Set<ID> setCancelFRMOppIds = new Set<Id>();
    static Set<ID> setCancelOTSAOppIds = new Set<Id>();
    static Set<ID> setCancelFRMEAoppIds1 = new Set<Id>();
    static Set<ID> setCancelFRMEAoppIds2 = new Set<Id>();
    static Set<ID> setCancelERPEAOppIds = new Set<Id>();
    static Set<ID> setCancelERPEAoppIds1 = new Set<Id>();
    static Set<ID> setCancelERPEAoppIds2 = new Set<Id>();
    static Set<ID> setScrOppIds = new Set<Id>();
    static Set<ID> setRiskAIOppIds = new Set<Id>();
    static Set<ID> setRiajOppIds = new Set<Id>();    
    static Set<ID> setCancelFrrOppIds = new Set<Id>();
    static Set<ID> AddMisc = new Set<Id>();
    static integer term;
    static Set<ID> setCancelwiley = new Set<Id>();
    static Set<ID> setCancelRiskDotNet = new Set<Id>();
    static Set<Id> refundIds = new Set<Id>(); 
    Map<String,Exam_Attempt__c> updateCancelledExamMap = new Map<String,Exam_Attempt__c>(); 
    Map<String,Contract> updateCancelledContractMap = new  Map<String,Contract>();
   // public static Map<String,Pearson_Exam_Series_Configuration__mdt> PearsonProgramNameConfigMap = IntegrationsMtdUtil.getByProgramTypeConfiguration();
    public static boolean stopRecurssion = true;
    
    // Constructor
    public ProductRefundsTriggerHandler(){
        //system.debug('**********In ProductRefundsTriggerHandler Constructor*******  ');
    }
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        //system.debug('**********In ProductRefundsTriggerHandler bulkBefore*******  ');
        if(stopRecurssion){
            
        }
    }
    
    public void bulkAfter(){
        //system.debug('**********In ProductRefundsTriggerHandler bulkAfter*******  ');
        Set<String> programNames = new Set<String>();
        Set<String> sectionNames = new Set<String>();
        Map<String, Set<String>> cancelProgramTypeMap = new Map<String, Set<String>>();
        Map<String, Set<String>> cancelExamSectioneMap = new Map<String, Set<String>>();
        if(stopRecurssion && !trigger.isDelete){
            for(Product_Refunds__c pr: (List<Product_Refunds__c>)Trigger.new){
                garpMemberIdByOpportunityId.put(pr.Opportunity__c, pr.GARP_ID__c);
                
                //updated logic for FRR25
                if(pr.Status__c == 'Completed' && pr.Cancel_Program_Name__c != null && pr.Cancel_Exam_Section_Name__c != null){ 
                    programNames.add(pr.Cancel_Program_Name__c);
                    sectionNames.add(pr.Cancel_Exam_Section_Name__c);
                    if (cancelProgramTypeMap.containsKey(pr.Opportunity__c)) {
                        cancelProgramTypeMap.get(pr.Opportunity__c).add(pr.Cancel_Program_Name__c);
                    } else {
                        cancelProgramTypeMap.put(pr.Opportunity__c, new Set<String>{pr.Cancel_Program_Name__c});
                    } 
                    if (cancelExamSectioneMap.containsKey(pr.Opportunity__c)) {
                        cancelExamSectioneMap.get(pr.Opportunity__c).add(pr.Cancel_Exam_Section_Name__c);
                    } else {
                        cancelExamSectioneMap.put(pr.Opportunity__c, new Set<String>{pr.Cancel_Exam_Section_Name__c});
                    }  
                }
            } 
            
            //updated logic for FRR25
            try{ 
                if(cancelProgramTypeMap.size() >0){
                    for(Contract ct : [select id,Opportunity__c,Status,RecordType.Name from contract where Status = 'Activated' and recordType.Name In:programNames and Opportunity__c in: cancelProgramTypeMap.keySet()])
                    {	
                        if(cancelProgramTypeMap.get(ct.Opportunity__c).contains(ct.RecordType.Name)){
                            ct.Status = 'Canceled';
                            updateCancelledContractMap.put(ct.Id,ct); 
                        } 
                    } 
                    
                    for(Exam_Attempt__c ea : [select id,Cancelled__c,Section__c,opportunity__C from Exam_Attempt__c where opportunity__C in: cancelExamSectioneMap.keySet() and Section__c In:sectionNames])
                    {
                        if(cancelExamSectioneMap.get(ea.Opportunity__c).contains(ea.Section__c)){
                            ea.Cancelled__c = true;
                            updateCancelledExamMap.put(ea.Id,ea); 
                        }
                    } 
                }
            }catch(Exception ex){
                System.debug('Error '+ex.getMessage() +' '+ex.getLinenumber());
            }
        }
    }
    
    public void beforeInsert(SObject so){
        //system.debug('**********In ProductRefundsTriggerHandler beforeInsert*******  ');
        if(stopRecurssion){
            
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
       // system.debug('**********In ProductRefundsTriggerHandler beforeUpdate*******  ');
        
        if(stopRecurssion){
            
        }
    }
    
    public void beforeDelete(SObject so){
       // system.debug('**********In ProductRefundsTriggerHandler beforeDelete*******  ');
        
    }
    
    public void afterInsert(SObject so){
        //system.debug('**********In ProductRefundsTriggerHandler afterInsert*******  ');
        
        Product_Refunds__c newProductRefund = (Product_Refunds__c)so;
        
        if(stopRecurssion){
            for(MembershipRefundCodes__c ref : MembershipRefundCodeList){
                if(ref.Product_Code__c == newProductRefund.Product_Code__c){
                    if(newProductRefund.Status__c == 'Approved' && (newProductRefund.Take_Membership__c || newProductRefund.Charge_Back__c)){
                       // system.debug('Test here here here');
                        lstProdRefunds.add(newProductRefund);
                        setOpps.add(newProductRefund.Opportunity__c);
                    }
                }
            }
            
            
            if(newProductRefund.Cancel_E_book__c && newProductRefund.Status__c == 'Completed'){
                
                setCancelPracticeExamIds.add(newProductRefund.Product_Code__c);
                setCancelPracticeExamOppIds.add(newProductRefund.Opportunity__c);
                
                setCancelEbooksOppIds.add(newProductRefund.Opportunity__c);
                
                //check for key
                if(garpMemberIdByOpportunityId.containsKey(newProductRefund.Opportunity__c)){
                    
                    //create a map of opportunities to refund
                    Map<Id, String> toRefund = new Map<Id, String>();               
                    toRefund.put(newProductRefund.Opportunity__c, garpMemberIdByOpportunityId.get(newProductRefund.Opportunity__c));
                    
                    //system.debug('toRefund=======>'+toRefund);                
                    //if FRM 1 or FRM 2 ebook 
                    if(newProductRefund.Product_Code__c == 'FRM1X'){
                        opportunityTriggerUtils_New.unprovisionMobiuseBook(toRefund, 'FRM', 'I');
                    } else if(newProductRefund.Product_Code__c == 'FRM2X'){
                        opportunityTriggerUtils_New.unprovisionMobiuseBook(toRefund, 'FRM', 'II');
                    } else if(newProductRefund.Product_Code__c == 'SCRX'){
                        opportunityTriggerUtils_New.unprovisionMobiuseBook(toRefund, 'SCR', 'I');
                    } else if(newProductRefund.Product_Code__c == 'ENC1X'){
                        opportunityTriggerUtils_New.unprovisionMobiuseBook(toRefund, 'ERP', 'I');
                    } else if(newProductRefund.Product_Code__c == 'ENC2X'){
                        opportunityTriggerUtils_New.unprovisionMobiuseBook(toRefund, 'ERP', 'II');
                    } 
                }
                
            }
            
            
            //system.debug(setCancelOpportunitiesForEventRegistration);
            
            
            
            if (newProductRefund.Status__c == 'Completed') {  
                if(newProductRefund.Cancel_ERP_Enrollment__c){
                    setCancelERPOppIds.add(newProductRefund.Opportunity__c);
                }
                //     get all the opportunities in a Set
                //     get all the opportunities in relation to events in a MAP                
                if(newProductRefund.Cancel_Event__c){
                    setcancelEventOppIds.add(newProductRefund.Opportunity__c);
                }
                if(newProductRefund.Cancel_FBRA__c){
                    setCancelFFRA.add(newProductRefund.Opportunity__c);
                    setCancelFFRAoppIds2.add(newProductRefund.Opportunity__c);
                } 
                if(newProductRefund.Cancel_FRM_Enrollment__c){
                    setCancelFRMOppIds.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_OTSA__c){
                    setCancelOTSAOppIds.add(newProductRefund.Opportunity__c);
                }                
                if(newProductRefund.Cancel_FRM1__c){
                    setCancelFRMEAoppIds1.add(newProductRefund.Opportunity__c);
                }                
                if(newProductRefund.Cancel_FRM2__c){
                    setCancelFRMEAoppIds2.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_ERP__c){
                    setCancelERPEAOppIds.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_ERP1__c){
                    setCancelERPEAoppIds1.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_ERP2__c){
                    setCancelERPEAoppIds2.add(newProductRefund.Opportunity__c);
                }
                if (newProductRefund.Cancel_SCR__c) {
                    setScrOppIds.add(newProductRefund.Opportunity__c);
                }               
                if (newProductRefund.Cancel_RISK_AI__c) {
                    setRiskAIOppIds.add(newProductRefund.Opportunity__c);
                }               
                if (newProductRefund.Cancel_RAIJ__c) {
                    setRiajOppIds.add(newProductRefund.Opportunity__c);
                }
                if(newProductRefund.Cancel_FRR__c){
                    setCancelFrrOppIds.add(newProductRefund.Opportunity__c);
                }
                if(newProductRefund.Cancel_Practice_exam__c == true){
                    setCancelPracticeExamIds.add(newProductRefund.Product_Code__c);
                    setCancelPracticeExamOppIds.add(newProductRefund.Opportunity__c);
                }                
                if(newProductRefund.Re_stocking_fees__c){
                    AddMisc.add(newProductRefund.Opportunity__c);                    
                }
                
                if(newProductRefund.Cancel_Wiley__c){
                    setCancelwiley.add(newProductRefund.Opportunity__c);
                    if(newProductRefund.Wiley_Quantity__c !=null )
                        term = integer.valueof(newProductRefund.Wiley_Quantity__c) ;
                }
                
                if(newProductRefund.Cancel_Risk_Net__c){
                    setCancelRiskDotNet.add(newProductRefund.Opportunity__c);
                } 
            } 
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        //system.debug('**********In ProductRefundsTriggerHandler afterUpdate*******  ');
        
        Product_Refunds__c newProductRefund = (Product_Refunds__c)so;
        Product_Refunds__c oldProductRefund = (Product_Refunds__c)oldSo;
        
        if(stopRecurssion){
            for(MembershipRefundCodes__c ref : MembershipRefundCodeList){
                if(ref.Product_Code__c == newProductRefund.Product_Code__c){
                    if((newProductRefund.Status__c != oldProductRefund.Status__c) && newProductRefund.Status__c == 'Approved' && 
                       (newProductRefund.Take_Membership__c || newProductRefund.Charge_Back__c)){
                          // system.debug('Test here here here');
                           lstProdRefunds.add(newProductRefund);
                           setOpps.add(newProductRefund.Opportunity__c);
                       }
                }
            }
            
            
            
            if(newProductRefund.Cancel_E_book__c && newProductRefund.Status__c == 'Completed'){
                
                setCancelPracticeExamIds.add(newProductRefund.Product_Code__c);
                setCancelPracticeExamOppIds.add(newProductRefund.Opportunity__c);
                
                setCancelEbooksOppIds.add(newProductRefund.Opportunity__c);
                
                //check for key
                if(garpMemberIdByOpportunityId.containsKey(newProductRefund.Opportunity__c)){
                    
                    //create a map of opportunities to refund
                    Map<Id, String> toRefund = new Map<Id, String>();               
                    toRefund.put(newProductRefund.Opportunity__c, garpMemberIdByOpportunityId.get(newProductRefund.Opportunity__c));
                    
                   // system.debug('toRefund=======>'+toRefund);                
                    //if FRM 1 or FRM 2 ebook 
                    if(newProductRefund.Product_Code__c == 'FRM1X'){
                        opportunityTriggerUtils_New.unprovisionMobiuseBook(toRefund, 'FRM', 'I');
                    } else if(newProductRefund.Product_Code__c == 'FRM2X'){
                        opportunityTriggerUtils_New.unprovisionMobiuseBook(toRefund, 'FRM', 'II');
                    } else if(newProductRefund.Product_Code__c == 'SCRX'){
                        opportunityTriggerUtils_New.unprovisionMobiuseBook(toRefund, 'SCR', 'I');
                    } else if(newProductRefund.Product_Code__c == 'ENC1X'){
                        opportunityTriggerUtils_New.unprovisionMobiuseBook(toRefund, 'ERP', 'I');
                    } else if(newProductRefund.Product_Code__c == 'ENC2X'){
                        opportunityTriggerUtils_New.unprovisionMobiuseBook(toRefund, 'ERP', 'II');
                    } 
                }
            }
            
            
            if(newProductRefund.Cancel_ERP_Enrollment__c&& newProductRefund.Status__c == 'Completed'){
                setCancelERPOppIds.add(newProductRefund.Opportunity__c);
            }
            //     get all the opportunities in a Set
            //     get all the opportunities in relation to events in a MAP
            
            if(newProductRefund.Status__c == 'Completed' && newProductRefund.Cancel_Event__c){
                setcancelEventOppIds.add(newProductRefund.Opportunity__c);
            }
            //system.debug(setCancelOpportunitiesForEventRegistration);
            
            if(newProductRefund.Status__c == 'Completed' && (newProductRefund.Cancel_FBRA__c) && (newProductRefund.Status__c != oldProductRefund.Status__c)){
                setCancelFFRA.add(newProductRefund.Opportunity__c);
                setCancelFFRAoppIds2.add(newProductRefund.Opportunity__c);
            } 
            if(newProductRefund.Status__c == 'Completed'){
                if(newProductRefund.Cancel_FRM_Enrollment__c){
                    setCancelFRMOppIds.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_OTSA__c){
                    setCancelOTSAOppIds.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_FRM1__c){
                    setCancelFRMEAoppIds1.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_FRM2__c){
                    setCancelFRMEAoppIds2.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_ERP__c){
                    setCancelERPEAOppIds.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_ERP1__c){
                    setCancelERPEAoppIds1.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_ERP2__c){
                    setCancelERPEAoppIds2.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_SCR__c){
                    setScrOppIds.add(newProductRefund.Opportunity__c);
                }
                if(newProductRefund.Cancel_RISK_AI__c){
                    setRiskAIOppIds.add(newProductRefund.Opportunity__c);
                }
                if (newProductRefund.Cancel_RAIJ__c) {
                    setRiajOppIds.add(newProductRefund.Opportunity__c);
                }
                if(newProductRefund.Cancel_FRR__c){
                    setCancelFrrOppIds.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Cancel_Practice_exam__c == true){
                    setCancelPracticeExamIds.add(newProductRefund.Product_Code__c);
                    setCancelPracticeExamOppIds.add(newProductRefund.Opportunity__c);
                }
                
                if(newProductRefund.Re_stocking_fees__c){
                    AddMisc.add(newProductRefund.Opportunity__c);
                    
                }
                
                if(newProductRefund.Cancel_Wiley__c){
                    setCancelwiley.add(newProductRefund.Opportunity__c);
                    if(newProductRefund.Wiley_Quantity__c !=null )
                        term = integer.valueof(newProductRefund.Wiley_Quantity__c) ;
                }
                
                if(newProductRefund.Cancel_Risk_Net__c){
                    setCancelRiskDotNet.add(newProductRefund.Opportunity__c);
                }
            }
            
            if(newProductRefund.Status__c == 'Approved' && newProductRefund.Status__c != oldProductRefund.Status__c
               && newProductRefund.Legacy_Transaction__c != null && newProductRefund.Payment_Order_Transaction__c == null){
                   refundIds.add(newProductRefund.Id);
               }
             
            
        }
    }
    
    public void afterDelete(SObject so){
       // system.debug('**********In ProductRefundsTriggerHandler afterDelete*******  ');
    }
    
    /**
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally(){
        if(!trigger.isDelete && stopRecurssion){
            if(!setCancelwiley.isEmpty())
            {
                Set<Id> setAccs1 = new Set<Id>();
                for(Opportunity opp: [select id,accountId from opportunity where id in: setCancelwiley]) {
                    // RiskDotNetUtilityClass.CreateUser(opp.id,'Inactive');
                    setAccs1.add(opp.accountId);
                }
                if(!updatewileyByRefunds.bRecursive)
                    updatewileyByRefunds.updatewileyTerm(setAccs1,term);
            }
            
            if(!setCancelRiskDotNet.isEmpty())
            {
                //system.debug('======Risk.net========');
                //system.debug('setCancelRiskDotNet========>'+setCancelRiskDotNet);
                Id riskNetId = RecordTypeHelper.GetRecordTypeId('Contract', 'Risk.Net');
                List<Contract> conlst = new List<Contract>();
                for(contract con: [select id,CustomerSignedId from contract where (recordTypeID =:riskNetId) and Opportunity__c in: setCancelRiskDotNet]) {
                    //system.debug('con======>'+con);
                    con.status =  'Canceled';
                    conlst.add(con);
                }
                if(!conlst.isempty()){
                    update conlst;
                }
            }
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            if(!setOpps.isEmpty())
            {
                Set<Id> setAccs = new Set<Id>();
                      for(Opportunity opp: [select id,accountId,Payment_Status__c,Payment_Frequency__c,
                                      Payment_Stop__c,Charge_Amount__c,
                                      Payment_Start_Date__c 
                                      from opportunity where id in: setOpps]){
                    //system.debug('Test here here here 22');
                    setAccs.add(opp.accountId);
                    if(opp.Payment_Status__c == 'Recurring'){
                        //system.debug('Test here here here 44');
                        opp.Payment_Status__c = 'Stopped';
                        opp.Stripe_Outbound_Type__c = 'Cancel';
                        opp.Payment_Frequency__c = null;
                		opp.Payment_Stop__c = null;
                        opp.Charge_Amount__c = null;
                        opp.Payment_Start_Date__c = null;
                        oppsToUpdate.add(opp);
                    }
                } 
                if(!updateContractByRefunds.bRecursive)
                    updateContractByRefunds.updateContractTerm(setAccs);  
                
                if(!oppsToUpdate.isEmpty()){
                    //system.debug('Test here here here 33');
                    update oppsToUpdate;
                }
                
            }
            
            if(!setCancelFFRAoppIds2.isEmpty())
            {
                
            }
            
            if(!setCancelEbooksOppIds.isEmpty())
            {
                List<eBook_Key__c> lstEbooks = new List<eBook_Key__c>();
                for(eBook_Key__c eBook : [select id,Cancelled__c,Opportunity__c from eBook_Key__c where Opportunity__c in: setCancelEbooksOppIds])
                {
                    eBook.Cancelled__c = true;
                    lstEbooks.add(eBook);
                }
                
                if(!lstEbooks.isEmpty()){
                    update lstEbooks;
				}
                
            } 
            
            if(!setCancelERPOppIds.isEmpty())
            {
                Set<Id> setAccountIds = new Set<Id>();
                for(Opportunity opp : [select id,accountId from opportunity where id in: setCancelERPOppIds])
                {
                    setAccountIds.add(opp.accountId);
                }
                // Id frmRecType = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');
                Id erpRecType = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program');
                List<Contract> lstContracts = new List<Contract>();
                for(Contract ct : [select id,Status from contract where Status = 'Activated ( Auto-Renew )' and (recordTypeID =:erpRecType) and accountID in: setAccountIds])
                {
                    ct.Status = 'Canceled';
                    lstContracts.add(ct);
                }
                if(!lstContracts.isEmpty()){
                    update lstContracts;
				}
            }   
            
           /* if(!setCancelScrOppIds.isEmpty())
            {
                List<Exam_Attempt__c> lstEA = new List<Exam_Attempt__c>();
                Id scrRecType = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program');
                List<Contract> lstContracts = new List<Contract>();
                for(Contract ct : [select id,Status from contract where Status = 'Activated' and (recordTypeID =:scrRecType) and Opportunity__c in: setCancelScrOppIds])
                {
                    ct.Status = 'Canceled';
                    lstContracts.add(ct);
                }
                if(!lstContracts.isEmpty()){
                    update lstContracts;	
				}
                for(Exam_Attempt__c ea : [select id,Cancelled__c,Section__c,opportunity__C from Exam_Attempt__c where opportunity__C in: setCancelScrOppIds and Section__c ='SCR'])
                {
                    ea.Cancelled__c = true;
                    lstEA.add(ea);
                }
                if(!lstEA.isEmpty()){
                    update lstEA;
                }
            } 
            if(!setCancelRiskAIOppIds.isEmpty()) //Chinnapa
            {
                List<Exam_Attempt__c> lstEA = new List<Exam_Attempt__c>();
                Id scrRecType = RecordTypeHelper.GetRecordTypeId('Contract','Risk AI Program');
                List<Contract> lstContracts = new List<Contract>();
                for(Contract ct : [select id,Status from contract where Status = 'Activated' and (recordTypeID =:scrRecType) and Opportunity__c in: setCancelRiskAIOppIds])
                {
                    ct.Status = 'Canceled';
                    lstContracts.add(ct);
                }
                if(!lstContracts.isEmpty()){
                    update lstContracts;	
				}
                for(Exam_Attempt__c ea : [select id,Cancelled__c,Section__c,opportunity__C from Exam_Attempt__c where opportunity__C in: setCancelRiskAIOppIds and Section__c ='RiskAI'])
                {
                    ea.Cancelled__c = true;
                    lstEA.add(ea);
                }
                if(!lstEA.isEmpty()){
                    update lstEA;
                }
            } */
            
            Set<Id> allOppIds = new Set<Id>();
            allOppIds.addAll(setScrOppIds);
            allOppIds.addAll(setRiskAIOppIds);
            allOppIds.addAll(setRiajOppIds);
            
            if (!allOppIds.isEmpty()) {                
                // Record Types
                Id scrTypeId    = RecordTypeHelper.GetRecordTypeId('Contract', 'SCR Program');
                Id riskAITypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Risk AI Program');
                Id raijTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'RAIJ Program');
                
                // --- Contracts ---
                List<Contract> lstContracts = new List<Contract>();
                
                for (Contract ct : [
                    SELECT Id, Status, RecordTypeId, Opportunity__c
                    FROM Contract
                    WHERE Status = 'Activated'
                    AND RecordTypeId IN :new Set<Id>{ scrTypeId, riskAITypeId,raijTypeId }
                    AND Opportunity__c IN :allOppIds
                ]) {
                    // Optional: only cancel if the opp is in the matching bucket (extra safety)
                    Boolean shouldCancel =
                        (ct.RecordTypeId == scrTypeId    && setScrOppIds.contains(ct.Opportunity__c)) ||
                        (ct.RecordTypeId == riskAITypeId && setRiskAIOppIds.contains(ct.Opportunity__c)) ||
                        (ct.RecordTypeId == raijTypeId && setRiajOppIds.contains(ct.Opportunity__c));
                    
                    if (shouldCancel) {
                        ct.Status = 'Canceled';
                        lstContracts.add(ct);
                    }
                }
                
                if (!lstContracts.isEmpty()) {
                    update lstContracts;
                }
                
                // --- Exam Attempts ---
                List<Exam_Attempt__c> lstEA = new List<Exam_Attempt__c>();
                
                for (Exam_Attempt__c ea : [
                    SELECT Id, Cancelled__c, Section__c, Opportunity__c
                    FROM Exam_Attempt__c
                    WHERE Opportunity__c IN :allOppIds
                    AND Section__c IN ('SCR', 'RiskAI','RIAJ')
                    AND Cancelled__c = false
                ]) {
                    Boolean shouldCancel =
                        (ea.Section__c == 'SCR'    && setScrOppIds.contains(ea.Opportunity__c)) ||
                        (ea.Section__c == 'RiskAI' && setRiskAIOppIds.contains(ea.Opportunity__c)) ||
                        (ea.Section__c == 'RIAJ' && setRiajOppIds.contains(ea.Opportunity__c));
                    
                    if (shouldCancel) {
                        ea.Cancelled__c = true;
                        lstEA.add(ea);
                    }
                }
                
                if (!lstEA.isEmpty()) {
                    update lstEA;
                }
            }
            
            if(!setCancelFrrOppIds.isEmpty())
            {
                List<Exam_Attempt__c> lstEA = new List<Exam_Attempt__c>();
                Id FrrRecType = RecordTypeHelper.GetRecordTypeId('Contract','ICBRR Program');
                List<Contract> lstContracts = new List<Contract>();
                for(Contract ct : [select id,Status from contract where Status = 'Activated ( Auto-Renew )' and (recordTypeID =:FrrRecType) and Opportunity__c in: setCancelFrrOppIds])
                {
                    ct.Status = 'Canceled';
                    lstContracts.add(ct);
                }
                if(!lstContracts.isEmpty()){
                    update lstContracts;
				}
                
                for(Exam_Attempt__c ea : [select id,Cancelled__c,Section__c,opportunity__C from Exam_Attempt__c where opportunity__C in: setCancelFrrOppIds and Section__c ='ICBRR'])
                {
                    ea.Cancelled__c = true;
                    lstEA.add(ea);
                }
                if(!lstEA.isEmpty()){
                    update lstEA;
				}
                
            } 
            
            if(!setCancelFRMOppIds.isEmpty())
            {
                Set<Id> setAccountIds = new Set<Id>();
                for(Opportunity opp : [select id,accountId from opportunity where id in: setCancelFRMOppIds])
                {
                    setAccountIds.add(opp.accountId);
                }
                Id frmRecType = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');
                //Id erpRecType = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program');
                List<Contract> lstContracts = new List<Contract>();
                for(Contract ct : [select id,Status from contract where Status = 'Activated ( Auto-Renew )' and (recordTypeID =:frmRecType) and accountID in: setAccountIds])
                {
                    ct.Status = 'Canceled';
                    lstContracts.add(ct);
                }
                if(!lstContracts.isEmpty()){
                    update lstContracts;
				}
            }   
            
            
            if(!setCancelOTSAOppIds.isEmpty())
            {
                Id OTSARecType = RecordTypeHelper.GetRecordTypeId('Contract','OSTA Program');
                List<Contract> lstContracts = new List<Contract>();
                for(Contract ct : [select id,Status from contract where Status = 'Activated ( Auto-Renew )' and (recordTypeID =:OTSARecType) and Opportunity__c in: setCancelOTSAOppIds])
                {
                    ct.Status = 'Canceled';
                    lstContracts.add(ct);
                }
                if(!lstContracts.isEmpty()){
                    update lstContracts;
				}
            }   
            
            
            if(!setCancelFFRA.isEmpty())
            {
                Set<Id> setAccountIds = new Set<Id>();
                for(Opportunity opp : [select id,accountId from opportunity where id in: setCancelFFRA])
                {
                    setAccountIds.add(opp.accountId);
                }
                Id fbraRecType = RecordTypeHelper.GetRecordTypeId('Contract','FBRA Program');
                //Id erpRecType = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program');
                List<Contract> lstContracts = new List<Contract>();
                for(Contract ct : [select id,Status from contract where Status = 'Activated ( Auto-Renew )' and (recordTypeID =:fbraRecType) and accountID in: setAccountIds])
                {
                    ct.Status = 'Canceled';
                    lstContracts.add(ct);
                    opportunityTriggerUtils_New.cancelFFRA(setCancelFFRAoppIds2);
                }
                if(!lstContracts.isEmpty()){
                    update lstContracts;
				}
            }   
            
            
            if(!setCancelFRMEAoppIds1.isEmpty())
            {
                Set<Id> setoppids = new Set<Id>();
                List<Exam_Attempt__c> lstEA = new List<Exam_Attempt__c>();
                
                for(Opportunity opp : [select id,accountId from opportunity where id in: setCancelFRMEAoppIds1])
                {
                    setoppids.add(opp.Id);
                }
                
                for(Exam_Attempt__c ea : [select id,Cancelled__c,Section__c,opportunity__C from Exam_Attempt__c where opportunity__C in: setoppids and Section__c ='FRM Part 1'])
                {
                    ea.Cancelled__c = true;
                    lstEA.add(ea);
                }
                if(!lstEA.isEmpty()){
                    update lstEA;
				}
                
                // 01/29/2019 Xiang - Move [US-12115] logic out of Registration transaction (Previously in Trigger)
                if(!setoppids.isEmpty()) {
                    // If FRM Part 1 is cancelled, then mark Opportunity Is_Exam_Cancelled__c true
                    List<Opportunity> oppsUpdt = new List<Opportunity>();
                    for(Id oppId : setoppids) {
                        oppsUpdt.add(new Opportunity(Id = oppId, Is_Exam_Cancelled__c = true));
                    }
                    update oppsUpdt;
                }
            }   
            
            if(!setCancelFRMEAoppIds2.isEmpty())
            {
                Set<Id> setoppids = new Set<Id>();
                List<Exam_Attempt__c> lstEA = new List<Exam_Attempt__c>();
                Set<Id> targetOppIds = new Set<Id>();
                
                for(Opportunity opp : [select id,accountId from opportunity where id in: setCancelFRMEAoppIds2])
                {
                    setoppids.add(opp.Id);
                }
                
                for(Exam_Attempt__c ea : [select id, Cancelled__c, Section__c ,opportunity__C, Other_Exam_Registrations__c from Exam_Attempt__c where opportunity__C in: setoppids and Section__c ='FRM Part 2'])
                {
                    ea.Cancelled__c = true;
                    lstEA.add(ea);
                    
                    // 01/29/2019 Xiang - Move [US-12115] logic out of Registration transaction (Previously in Trigger)
                    if(ea.Other_Exam_Registrations__c == NULL) {
                        targetOppIds.add(ea.Opportunity__c);
                    }
                }
                if(!lstEA.isEmpty()){
                    update lstEA;
				}
                
                // If FRM Part 2 is cancelled and it is stand alone, mark Opportunity Is_Exam_Cancelled__c true
                if(!targetOppIds.isEmpty()) {
                    List<Opportunity> oppsUpdt = new List<Opportunity>();
                    for(Id oppId : targetOppIds) {
                        oppsUpdt.add(new Opportunity(Id = oppId, Is_Exam_Cancelled__c = true));
                    }
                    update oppsUpdt;
                }
            }   
            
            
            if(!setCancelERPEAoppIds1.isEmpty())
            {
                Set<Id> setoppids = new Set<Id>();
                List<Exam_Attempt__c> lstEA = new List<Exam_Attempt__c>();
                
                for(Opportunity opp : [select id,accountId from opportunity where id in: setCancelERPEAoppIds1])
                {
                    setoppids.add(opp.Id);
                }
                
                for(Exam_Attempt__c ea : [select id,Cancelled__c,Section__c,opportunity__C from Exam_Attempt__c where opportunity__C in: setoppids and Section__c ='ERP Exam Part I'])
                {
                    ea.Cancelled__c = true;
                    lstEA.add(ea);
                }
                if(!lstEA.isEmpty()){
                    update lstEA;
				}
                
                // 01/29/2019 Xiang - Move [US-12115] logic out of Registration transaction (Previously in Trigger)
                if(!setoppids.isEmpty()) {
                    // If ERP Part 1 is cancelled, then mark Opportunity Is_Exam_Cancelled__c true
                    List<Opportunity> oppsUpdt = new List<Opportunity>();
                    for(Id oppId : setoppids) {
                        oppsUpdt.add(new Opportunity(Id = oppId, Is_Exam_Cancelled__c = true));
                    }
                    update oppsUpdt;
                }
            }   
            
            if(!setCancelERPEAoppIds2.isEmpty())
            {
                Set<Id> setoppids = new Set<Id>();
                List<Exam_Attempt__c> lstEA = new List<Exam_Attempt__c>();
                Set<Id> targetOppIds = new Set<Id>();
                
                for(Opportunity opp : [select id,accountId from opportunity where id in: setCancelERPEAoppIds2])
                {
                    setoppids.add(opp.Id);
                }
                
                for(Exam_Attempt__c ea : [select id,Cancelled__c, Section__c ,opportunity__C, Other_Exam_Registrations__c from Exam_Attempt__c where opportunity__C in: setoppids and Section__c ='ERP Exam Part II'])
                {
                    ea.Cancelled__c = true;
                    lstEA.add(ea);
                    
                    // 01/29/2019 Xiang - Move [US-12115] logic out of Registration transaction (Previously in Trigger)
                    if(ea.Other_Exam_Registrations__c == NULL) {
                        targetOppIds.add(ea.Opportunity__c);
                    }
                }
                if(!lstEA.isEmpty()){
                    update lstEA;
				}
                
                // If ERP Part 2 is cancelled and it is stand alone, mark Opportunity Is_Exam_Cancelled__c true
                if(!targetOppIds.isEmpty()) {
                    List<Opportunity> oppsUpdt = new List<Opportunity>();
                    for(Id oppId : targetOppIds) {
                        oppsUpdt.add(new Opportunity(Id = oppId, Is_Exam_Cancelled__c = true));
                    }
                    update oppsUpdt;
                }
            }   
            
            if(!AddMisc.isEmpty())
            {
                
                list<OpportunityLineItem> opl = new list<OpportunityLineItem>();
                Set<Id> setoppids = new Set<Id>();
                List<Exam_Attempt__c> lstEA = new List<Exam_Attempt__c>();
                Integer iRecCount = 0;
                
                for(Opportunity opp : [select id,accountId, Stop_Recurring__c from opportunity where id in: AddMisc and Stop_Recurring__c =false])
                {
                    setoppids.add(opp.Id);
                }
                for(Opportunity opp1 : [select id from opportunity where id in: setoppids ])
                {
                    integer pr = (integer)[select count(id) r from Product_Refunds__c where Opportunity__c in :setoppids and Re_stocking_fees__c =true] [0].get('r');
                    //integer ff = pr[0].get('r');
                    PriceBookEntry PricebookEntryId = new PriceBookEntry();
                    PricebookEntryId = [select unitprice,productcode,Product2.GL_Code__c from PriceBookEntry where Pricebook2.IsActive = true and productcode ='MISC' and isActive = true];
                    OpportunityLineItem oppLineItem = new OpportunityLineItem();
                    oppLineItem.OpportunityId = opp1.id;
                    oppLineItem.PricebookEntryId = PricebookEntryId.Id;
                    oppLineItem.Quantity = 1;
                    oppLineItem.Description ='Restocking-fees';
                    oppLineItem.UnitPrice = 25.00*pr;   
                    opplineitem.Stop_Recurring__c =true;
                    //insert oppLineItem;
                    //lstEA.add(ea);
                    opl.add(oppLineItem);
                }
                if(!opl.isEmpty()){
                    insert opl;
				}
            }   
            
            
            if(!setCancelERPEAOppIds.isEmpty())
            {
                Set<Id> setoppids = new Set<Id>();
                List<Exam_Attempt__c> lstEA = new List<Exam_Attempt__c>();
                for(Opportunity opp : [select id,accountId from opportunity where id in: setCancelERPEAOppIds])
                {
                    setoppids.add(opp.id);
                }
                
                for(Exam_Attempt__c ea : [select id,Cancelled__c,opportunity__C from Exam_Attempt__c where opportunity__C in: setoppids])
                {
                    ea.Cancelled__c = true;
                    lstEA.add(ea);
                }
                if(!lstEA.isEmpty()){
                    update lstEA;
				}
            } 
            
            // Event Refunds
            // Assumes to cancel all Registrations realted to the Opportunity
            // Does not support two seperate events on 1 Opp
            Set<Id> setEventIds = new Set<Id>();
            List<Event_Registration__c> setAllMatchingEventRegistrations = new List<Event_Registration__c>();
            for (Event_Registration__c er: [select id, Event__c, Status__c, Opportunity__c from Event_Registration__c where Opportunity__c in :setcancelEventOppIds]) {        
                er.Status__c  = 'Cancelled';
                setAllMatchingEventRegistrations.add(er);
            }
            if(!setAllMatchingEventRegistrations.isEmpty()){
                update setAllMatchingEventRegistrations;
			}
            
            
            if(!setCancelPracticeExamIds.isEmpty()){
                //system.debug('update===>');
                List<OpportunityLineItem> oppLineItemslst = new List<OpportunityLineItem>();
                for(OpportunityLineItem  oppLine : [select id from OpportunityLineItem where ProductCode IN:setCancelPracticeExamIds and OpportunityId IN:setCancelPracticeExamOppIds]){
                    oppLine.Cancel_Refunded__c = true;
                    oppLineItemslst.add(oppLine);
                    //system.debug(' Cancel_Refunded__c =====>');
                }
                if(!oppLineItemslst.isEmpty()){
                    update oppLineItemslst;
                }
            }
            
            
            try{ 
                if(updateCancelledContractMap.size() > 0){ 
                    if(!updateCancelledContractMap.isEmpty()){
                        update updateCancelledContractMap.values();
                    }
                    if(!updateCancelledExamMap.isEmpty()){
                        update updateCancelledExamMap.values();
                    }
                }
            }catch(Exception ex){
                System.debug('Error '+ex.getMessage() +' '+ex.getLinenumber());
            }

            
            if(!refundIds.isEmpty()){
                ProdRefundsOrderCreate_Queueable orderQueue = new ProdRefundsOrderCreate_Queueable(refundIds);
                ID jobID = System.enqueueJob(orderQueue);
            }
            
        }
        
        if(trigger.isAfter){
            stopRecurssion = false;
        }
    }
}