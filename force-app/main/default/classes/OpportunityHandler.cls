/**
* Class OpportunityHandler
* 
* Trigger Handler for the Opportunity SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class OpportunityHandler implements TriggerAbstract {
    
    static Map<Id,Opportunity> closedOppsMap = new Map<Id,Opportunity>();
    //static Map<Id,Opportunity> bulkOppsCloseMap = new Map<Id,Opportunity>();
    static Map<Id,Opportunity> renewOpps = new Map<Id,Opportunity>();
    static Map<Id,Contract> mapOppToMemberContract = new Map<Id,Contract>();
    static Map<String,Set<Id>> contractUpdateToRecordIdMap = new Map<String,Set<Id>>();
    static Map<String,Set<Id>> examRegUpdateToRecordIdMap = new Map<String,Set<Id>>();
    static Map<String,Set<Id>> eventRegUpdateToRecordIdMap = new Map<String,Set<Id>>();
    static Map<Id,OpportunityLineItem> lineItemByOpportunityId = new Map<Id, OpportunityLineItem>();
    static Map<Id,List<OpportunityLineItem>> oppToProductsMap = new Map<Id,List<OpportunityLineItem>>();
    static Map<Id,Contract> mapMemberShipContracts = new Map<Id,Contract>();
    static Map<Id,String> mapPrevoiusMemberShipContracts = new Map<Id,String>();
    static Set<Id> setExamRegMods = new Set<Id>();
    static Set<Id> closedOppsAccIdSet = new Set<Id>();
    static Set<Id> acctIdSetForContractAutoRenew = new Set<Id>();
    static Set<String> accIdSet = new Set<String>();
    static List<Contract> contractList = new List<Contract>();
    static List<Contact> contactList = new List<Contact>();
    static List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
    static Map<String, Set<Id>> methodToOppsMap = new Map<String, Set<Id>>();
    static Id manualRecId = RecordTypeHelper.getRecordTypeIdFromSchema('Opportunity','Manual');
    static Map<String,updateids__c> mapSettings = updateids__c.getAll();
    static Map<String,Opportunity_Product_Mapping__mdt> oppProductToMethodMap = new Map<String,Opportunity_Product_Mapping__mdt>();
    //static Map<String,List<Product_Refunds__c>> oppProductRefundsMap = new Map<String,List<Product_Refunds__c>>();
    static Set<String> productCodes = new Set<String>();
    static Set<String> glCodes = new Set<String>();
    static Set<String> productKeys = new Set<String>();
    static Set<Id> opCompanyUpdateIds = new Set<Id>();
    static Set<Id> opDeferPayUpdateIds = new Set<Id>();
    public static boolean stopRecurssion = false;
    public static boolean closedOppsRecurssion = false;
    static List<Opportunity> closedRecOppsList = new List<Opportunity>();
    Set<Id> transationOppList = new Set<Id>();
    static boolean shipEdgeCall = false;
    static boolean sageReallocationCall = false;
    static boolean sageIntegration = false;
    static List<Sage_Updates__e> sageEvents = new List<Sage_Updates__e>();
    static List<Stripe_Integration__e> stripeEvents = new List<Stripe_Integration__e>();
    Set<String>  stripeTaxIds = new Set<String>();
    Map<Id,Opportunity> aftUpdMapForOrder;
    boolean enableStripe = false;
    Boolean isStripeEvent = false;
    
    public class oppLineWrapper {
        public string Product_Codes;
        public Decimal Product_Weight; 
        public string Product_Names;
        public string Product_SKU;
        public string Customs_Cost;
        public string taxAuthority;
    }
    // Constructor
    public OpportunityHandler(){
        aftUpdMapForOrder = new Map<Id,Opportunity>();
        if(!test.isrunningtest()){
            enableStripe = Default_Settings__c.getValues('EnableStripe').Active__c;
        }
    }
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        if(!trigger.isDelete){
            for(sobject opp : trigger.new){
                string accId = (String)opp.get('AccountId');
                accIdSet.add(accId);
                String stagename = (String)opp.get('stagename');
                if(Trigger.oldMap != null && ((stagename == 'Closed' || stagename == 'Recurring Intent' || stagename == 'Closed Lost') && Trigger.oldMap.get(opp.Id).get('StageName') != stagename)){
                    closedRecOppsList.add((Opportunity)opp);
                    closedOppsRecurssion = true;
                }
            }
        }
        if(trigger.isInsert || !closedRecOppsList.isEmpty()){
            contractList = [Select Id,Status,StartDate,EndDate,RecordTypeId,name, Enrollment_paid_for_2009__c, accountId,Opportunity__c,Second_Attempt_FRR__c,Membership_Type__c,ContractTerm
                            from Contract
                            where AccountId IN: accIdSet];
            Id memberRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
            for (Contract objContract: contractList){
                if(objContract.RecordTypeId == memberRecordTypeID){
                    String MembershipType = objContract.Membership_Type__c;
                    String status = objContract.Status;
                    if (MembershipType == 'Individual' || MembershipType == 'Student' ){
                        mapMemberShipContracts.put(objContract.accountId, objContract);
                        if((status == 'Draft' || status == 'Activated') && objContract.Opportunity__c != null && (MembershipType == 'Individual' || MembershipType == 'Affiliate'))
                            mapOppToMemberContract.put(objContract.Opportunity__c, objContract);
                    }
                    if (status == 'Activated' || status == 'Activated ( Auto-Renew )' || status == 'Expired') {
                        mapPrevoiusMemberShipContracts.put(objContract.accountId, MembershipType);                    
                    }
                }
            }
        }
        if(trigger.isUpdate){
            if(!stopRecurssion || closedOppsRecurssion){
                oppProductToMethodMap = OpportunityTriggerHelper_New.getOppProductMethodMap();
                
                List<OpportunityLineItem> productList = new List<OpportunityLineItem>();
                
                if(trigger.newMap != null){
                    productList = [SELECT Id, Name, ProductCode,Exam_Registration__r.Member__c, Product2Id,Opportunity.OSTA_Exam_Site_Code__c,TotalPrice,Product_SKU__c,
                                   Opportunity.OSTA_Opportunity_Refund__c, Opportunity.Exam_Registration_Modification__c, Product2.Family, Product2.Tax_Authority__c,
                                   Event__c, Exam_Site__r.Id, Exam_Registration__c, OpportunityId, UnitPrice, Quantity, Opportunity.AccountId,
                                   Product2.Department__c, Product2.ia_crm__Intacct_Entity__c, Product2.Class__c, Sage_Reporting_Country__c,
                                   Opportunity.GARP_Member_ID__c, Scholarship_Application__c,Exam_Registration__r.Exam_Date__c,Description,For_Sage_Sync_Only__c,
                                   Product2.Is_Shippable__c, Product2.Weight__c, Product2.Product_ID__c,Product2.Bookstore__c,Product2.Name, Product2.Customs_Cost__c,
                                   Product2.GL_Code__c,Opportunity.StageName,Opportunity.Billing_Email__c,Product2.Company__c,Product2.ProductCode
                                   FROM OpportunityLineItem 
                                   WHERE OpportunityId in :trigger.newMap.keyset()];
                    
                    //oppProductRefundsMap = OpportunityTriggerHelper_New.getOppProductRefundsMap(trigger.newMap.keyset());
                }
                
                for(OpportunityLineItem oli : productList){
                    if(oppToProductsMap.containsKey(oli.OpportunityId)){
                        List<OpportunityLineItem> oppProds = oppToProductsMap.get(oli.OpportunityId);
                        oppProds.add(oli);
                        oppToProductsMap.put(oli.OpportunityId,oppProds);
                    }else{
                        oppToProductsMap.put(oli.OpportunityId,new List<OpportunityLineItem>{oli});
                    }
                    if (oli.Product2.Company__c == 'GRA') {
                        opCompanyUpdateIds.add(oli.OpportunityId);
                    }
                    if (oli.Product2.ProductCode == 'PRFEE' && oli.Product2.GL_Code__c == '6110')
                        opDeferPayUpdateIds.add(oli.OpportunityId);
                } 
                if(!closedRecOppsList.isEmpty()){
                    //Transaction Count (US-62384)
                    for(AggregateResult ar:[SELECT Opportunity__c, COUNT(Id) recordCount FROM ChargentOrders__Transaction__c where Opportunity__c In:closedRecOppsList AND ChargentOrders__Type__c = 'Charge' AND ChargentOrders__Response_Status__c ='Approved'
                                            GROUP BY Opportunity__c HAVING COUNT(Id) > 1]){
                                                Id oppId = (Id) ar.get('Opportunity__c');
                                              transationOppList.add(oppId); 
                                            }
                }
                if (Trigger.isDelete){}
            }
        }
    }
    
    public void bulkAfter(){
        
    }
    
    public void beforeInsert(SObject so){
        if(!stopRecurssion){
            Opportunity newOpp = (Opportunity)so;
            UpdateFieldsInsertUpdate(newOpp,null);
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        Opportunity newOpp = (Opportunity)so;
        Opportunity oldOpp = (Opportunity)oldSo;
        
        if(newOpp.company_check__c > 0 ){
            newOpp.Company__c = 'GRA';
        }else if(newOpp.company_check__c == 0 ){
            newOpp.Company__c = 'GARP';
        }
        if(mapSettings.containsKey(newOpp.Company__c) && !enableStripe && newOpp.Gateway__c == null){
            newOpp.Gateway__c = mapSettings.get(newOpp.Company__c).Record_id__c;
        }else if(enableStripe && newOpp.Gateway__c == null){
            newOpp.Gateway__c = mapSettings.get('Stripe').Record_id__c;
        }
        
        
        if(!stopRecurssion){
            UpdateFieldsInsertUpdate(newOpp,oldOpp);
            procShpCnclAndRsnd(newOpp,oldOpp);
            procSageIntegration(newOpp,oldOpp);
        }
        if(!closedRecOppsList.isEmpty() && closedOppsRecurssion){
            processBeforeUpdateAndGetMaps(newOpp,oldOpp);
            sageUpdate(newOpp,oldOpp);
        } 
    }
    
    public void beforeDelete(SObject so){
        
    }
    
    public void afterInsert(SObject so){
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        Opportunity newOpp = (Opportunity)so;
        Opportunity oldOpp = (Opportunity)oldSo;
        if(!stopRecurssion){
            processAfterUpdate(newOpp,oldOpp);
            sageProcessReallocation(newOpp,OldOpp); 
             
            if((newOpp.StripeTaxMethod__c == 'Regular') && newOpp.StripeTaxMethod__c != oldOpp.StripeTaxMethod__c){
                stripeTaxIds.add(newOpp.Id);
            }
        }
        if(isStripeEvent == false){
            stripeIntegration(newOpp,oldOpp); 
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
        if(!stopRecurssion || closedOppsRecurssion){
            if(trigger.isAfter){
                if(trigger.isInsert){
                    // commented. need to rework after Spuran complete OpportunityTriggerHelper_New
                    OpportunityTriggerHelper_New.upsertOrders((Map<Id,Opportunity>)trigger.newMap);
                }
                if(trigger.isUpdate){
                    /*system.debug(contractList);
                    system.debug('Check this map');
                    system.debug(examRegUpdateToRecordIdMap);*/
                    if(!aftUpdMapForOrder.keySet().isEmpty()){
                        // commented. need to rework after Spuran complete OpportunityTriggerHelper_New
                        OpportunityTriggerHelper_New.upsertOrders(aftUpdMapForOrder);
                    }
                    ExamManagementController.dmlListWrapper dmlList = new ExamManagementController.dmlListWrapper();
                    if(!closedOppsAccIdSet.isEmpty() || !acctIdSetForContractAutoRenew.isEmpty()){
                        contactList = [Select Id,RecordTypeId,GARP_Member_Id__c,KPI_Membership_Auto_Renew_Status__c,AccountId,
                                       FirstName,LastName,Email,HomePhone                           
                                       from Contact
                                       where AccountId IN: closedOppsAccIdSet OR AccountId IN: acctIdSetForContractAutoRenew]; 
                    }
                    if(!closedOppsMap.isEmpty() || shipEdgeCall == true || sageReallocationCall == true || sageIntegration == true)
                        processOpportunityProductMethods(closedOppsMap);
                    if(!setExamRegMods.isEmpty()){
                        dmlList = ExamManagementController.processExamRegModsBulk(setExamRegMods);
                    }
                    OpportunityTriggerHelper_New.updateContracts(contractList,contactList,contractUpdateToRecordIdMap,lineItemByOpportunityId,renewOpps,dmlList.contractsToUpdate,dmlList.contractsToInsert);
                    /*if(!bulkOppsCloseMap.isEmpty())
                    OpportunityTriggerHelper_New.closeBulkOrders(bulkOppsCloseMap);*/
                    if(!examRegUpdateToRecordIdMap.isEmpty() || dmlList!= null)
                        OpportunityTriggerHelper_New.updateExamAttempts(examRegUpdateToRecordIdMap,dmlList.examRegToUpdate);
                    if(!eventRegUpdateToRecordIdMap.isEmpty())
                        OpportunityTriggerHelper_New.updateEventRegistrations(eventRegUpdateToRecordIdMap);
                    if(productCodes.size() > 0) {
                        OpportunityTriggerHelper_New.closeRateOffers(productCodes, glCodes, contactList, productKeys);
                    }
                    if(!sageEvents.isEmpty()){
                        EventBus.publish(sageEvents);
                    }
                   
                    if(closedOppsRecurssion)
                        closedOppsRecurssion = false;
                    
                    if(!stripeEvents.isEmpty()){ 
                        EventBus.publish(stripeEvents);
                    }
                    if(!stripeTaxIds.isEmpty()){  
                        System.enqueueJob(new StripeTaxCalQueueable(stripeTaxIds));
                    }
                     stopRecurssion = true;
                }
            }
            
           
        }
         
    }
    
    public void UpdateFieldsInsertUpdate(Opportunity newOpp,Opportunity oldOpp){
        //process before trigger updates
        if ( newOpp.Has_Books__c == true) {                                
            List<String> strAddress  = new List<String>();
            if(String.isNotBlank(newOpp.Shipping_Street__c) ){
                strAddress = newOpp.Shipping_Street__c.split('\n');
                if (strAddress != null && (String.isBlank(newOpp.Shipping_Address1__c) || (oldOpp != null && newOpp.Shipping_Street__c != oldOpp.Shipping_Street__c))) {
                    newOpp.Shipping_Address1__c = (strAddress.size() > 0) ? strAddress[0] : null;
                    newOpp.Shipping_Address2__c = (strAddress.size() > 1) ? strAddress[1] : null;
                    newOpp.Shipping_Address3__c = (strAddress.size() > 2) ? strAddress[2] : null;
                    newOpp.Shipping_Address__c = newOpp.Shipping_Address1__c +''+ newOpp.Shipping_Address2__c +''+newOpp.Shipping_Address3__c;
                }
            }
            if(newOpp.Ups_Stage__c == null && newOpp.StageName == 'Closed')
                newOpp.Ups_Stage__c = 'New Order';
        }
        
        CountryCodes__c countryCodes = CountryCodes__c.getValues(newOpp.Shipping_Country__c);
        newOpp.Country_Code_for_UPS__c = countryCodes != null ? countryCodes.Country_Code__c : '';
        newOpp.Pay_By_Wire_Check__c = false;
        
        
        if(oldOpp != null && opDeferPayUpdateIds.contains(newOpp.id)){
            newOpp.Pay_By_Wire_Check__c = true;
        }
        
        if(oldOpp == null){
            newOpp.Type = 'New Business';
            if(mapMemberShipContracts.containsKey(newOpp.accountId))
                newOpp.Type = 'Existing Business';
            if(mapPrevoiusMemberShipContracts.containsKey(newOpp.accountId))
                newOpp.Previous_Memerbship__c = mapPrevoiusMemberShipContracts.get(newOpp.accountId);
        }
    
        if(String.isNotBlank(newOpp.Manual_State__c)){
            newOpp.Billing_State_Text__c = newOpp.Manual_State__c;
            newOpp.Manual_State__c = '';
        }
        
        if(oldOpp != null && newOpp.Alternate_Method_of_Payment__c == 'Wire'){
            updateEventRegUpdateMap('UpdatePayment',newOpp.id);
        }
        
        if(newOpp.Ups_Stage__c == 'Sent to GT' && (oldOpp == null || (newOpp.Ups_Stage__c != oldOpp.Ups_Stage__c))){
            newOpp.Date_Sent_to_GT__c = system.today();
        }
        
        if(oldOpp != null && newOpp.ia_crm__Intacct_Sync_Status_1__c == 'OK' && newOpp.ia_crm__Intacct_Sync_Status_1__c != oldOpp.ia_crm__Intacct_Sync_Status_1__c && newOpp.Sage_Sync_Date__c == null){
            newOpp.Sage_Sync_Date__c = system.today();
        }
        
        if(newOpp.ia_crm__Intacct_Sync_Status_1__c != null && newOpp.ia_crm__Intacct_Sync_Status_1__c != 'OK' && newOpp.ia_crm__Intacct_Sync_Status_1__c != 'In Process' && newOpp.Sage_Sync_Date__c == null){
            newOpp.Sage_Order_Approved__c = false;
        }
        
        if(newOpp.Auto_Renew__c){
            newOpp.Manual_Charge__c = True;
        }
    }
    
    public void sageUpdate(Opportunity newOpp,Opportunity oldOpp){
        String paymentType;
        string gateway = Sage_Default_Records_Ref__mdt.getInstance('Stripe_Gateway').value__c;
        newOpp.Sage_Paid_Date__c = newOpp.CloseDate;
        newOpp.ia_crm__Term__c = Sage_Default_Records_Ref__mdt.getInstance('Intacct_Term_Record_Id').value__c;
        
        if(newOpp.Payment_Method_New__c == 'Credit Card'){
            if(newOpp.Gateway__c == gateway){
                paymentType = 'ST';
            }else if(newOpp.CardType__c == 'AMEX' ){
                paymentType = 'AE';
            }else{
                paymentType = 'FD';
            }
        }else if(newOpp.Payment_Method_New__c == 'Wire Transfer'){
            paymentType = 'WI';
        }else if(newOpp.Payment_Method_New__c == 'Check'){
            paymentType = 'CK';
        }else if(newOpp.Payment_Method_New__c == 'ACH'){
            paymentType = 'AH';
        }else if(newOpp.Payment_Method_New__c == 'Free'){
            paymentType = 'FE';
        }else if(newOpp.Payment_Method_New__c == 'Bulk Order'){
            paymentType = 'BO';
        }else if(newOpp.Payment_Method_New__c == 'Convert'){
            paymentType = 'CO';
        }else if(newOpp.Payment_Method_New__c == 'Charge Back Accepted' || newOpp.Payment_Method_New__c == 'Charge Back Loss'){
            paymentType = 'CB';
        }else if(newOpp.Payment_Method_New__c == 'Alipay' || newOpp.Payment_Method_New__c == 'Wechatpay'){
            paymentType = 'ST';
        }else if(newOpp.Payment_Method_New__c == 'Internal Refund'){
            paymentType = 'IR';
        }
       
        DateTime dt;
        if(newOpp.Team_Registration__c != null && newOpp.Team_Registration_Paid_Date__c != null){
            dt = datetime.newInstance(newOpp.Team_Registration_Paid_Date__c.year(),newOpp.Team_Registration_Paid_Date__c.month(),newOpp.Team_Registration_Paid_Date__c.day());
        }else{
            //dt = datetime.newInstance(newOpp.CloseDate.year(),newOpp.CloseDate.month(),newOpp.CloseDate.day());
            if((newOpp.Payment_Method_New__c == 'Credit Card' || newOpp.Payment_Method_New__c == 'Alipay' || newOpp.Payment_Method_New__c == 'Wechatpay') && newOpp.Gateway_Time__c != null){
                dt = newOpp.Gateway_Time__c;
            }else{
                dt = datetime.newInstance(newOpp.CloseDate.year(),newOpp.CloseDate.month(),newOpp.CloseDate.day());
            }

        }
        String dateTimeStr = dt.formatGmt('MMddyy');  
        if(transationOppList.size() > 0 && transationOppList.contains(newOpp.Id)){
           paymentType = 'MP';
        } 
        newOpp.Sage_Document_Number__c = paymentType+dateTimeStr;
        if(newOpp.ia_crm__Intacct_Transaction__c == null){
            if(newOpp.Exam_Registration_Modification__c != null){
                newOpp.ia_crm__Intacct_Transaction__c = 'Salesforce - Deferral';
            }else{
                newOpp.ia_crm__Intacct_Transaction__c = 'Salesforce - Sales Invoice';
            } 
        }
        
        if(newOpp.ia_crm__Intacct_Transaction__c == 'Salesforce - Refund' && newOpp.Has_Membership__c == true){
            newOpp.Sage_Reallocation_Sync_Status__c = ' Submitted to API';
        }
    }
    
    public void processBeforeUpdateAndGetMaps(Opportunity newOpp,Opportunity oldOpp){
        /*system.debug('processBeforeUpdateAndGetMaps::>>   '+newOpp.stagename+'   ----        '+oldOpp.stagename);
        system.debug('processBeforeUpdateAndGetMaps::>>   '+newOpp);
        system.debug('processBeforeUpdateAndGetMaps::>>   '+oldOpp);*/
        //OpportunityTriggerHelper_New.updateAmtFields(newOpp,oppToProductsMap,oppProductRefundsMap);
        if(newOpp.stagename == 'Closed'&& newOpp.StageName != oldOpp.stageName){
            if(newOpp.Auto_Renew__c){
                newOpp.Payment_Status__c = 'Recurring';
                newOpp.Payment_Frequency__c = 'Annual';
                newOpp.Payment_Stop__c = 'Unending';
                newOpp.Stripe_Outbound_Type__c = 'Create';
                Contract con = mapOppToMemberContract.containsKey(newOpp.Id) ? mapOppToMemberContract.get(newOpp.Id) : null;
                if(con != null)
                    newOpp.Payment_Start_Date__c = con.Enddate;
                if(newOpp.Do_Not_change_amount__c == true || newOpp.Certified_Membership_Individual__c == true)
                    newOpp.Charge_Amount__c = 150;
                else if(newOpp.Do_Not_change_amount__c != true)
                    newOpp.Charge_Amount__c = 195;
            }
            
            // AG 9/18/2025 - Set on all Closing Opp, helps fire emails
            newOpp.Email_Purchase_Complete__c = True;
                
            closedOppsAccIdSet.add(newOpp.AccountId);
            closedOppsMap.put(newOpp.id,newOpp);
            processOpportunityProductsForClosedOpps(newOpp);
            //Get Exam Registration Modification Ids to process deferrals
            if(newOpp.Exam_Registration_Modification__c != null){
                setExamRegMods.add(newOpp.Exam_Registration_Modification__c);
            }
            //Get Opps for Instritutional bulk order close
            //system.debug((newOpp.RecordTypeID == manualRecId)+'  --  '+newOpp.Institutional_Sale__c+'  --  '+newOpp.Institutional_Sale_Stage__c+'  --  '+newOpp.Inst_Sale_Emails__c);
            /*if (newOpp.RecordTypeID == manualRecId && newOpp.Institutional_Sale__c == True && newOpp.Institutional_Sale_Stage__c == 'Approved' && newOpp.Inst_Sale_Emails__c != null) {
                bulkOppsCloseMap.put(newOpp.Id, newOpp);                
            }*/
            //Get Opps for renewal
            if (newOpp.Renew_Membership__c || newOpp.Eligible_for_Membership_Extension__c || newOpp.Auto_Renew__c || newOpp.Wiley__c) {
                renewOpps.put(newOpp.AccountId, newOpp);
            }
            
            if(newOpp.Ups_Stage__c == 'New Order' && newOpp.Has_Books__c == true && newOpp.Cancel_Books__c == false){
                 if(methodToOppsMap.containsKey('ShipEdgeAdd')){
                     Set<Id> oppSet = methodToOppsMap.get('ShipEdgeAdd');
                     oppSet.add(newOpp.Id);
                     methodToOppsMap.put('ShipEdgeAdd',oppSet);
                 }else{
                     methodToOppsMap.put('ShipEdgeAdd',new Set<Id>{newOpp.Id});
                 }
            }
            
            Sage_Updates__e evt = new Sage_Updates__e();
            evt.Opportunity_Id__c = newOpp.Id;
            sageEvents.add(evt);
            
        }
        
        if(newOpp.stagename == 'Recurring Intent' && newOpp.StageName != oldOpp.stageName && newOpp.Auto_Renew__c){
            if(newOpp.Auto_Renew__c){
                newOpp.Payment_Status__c = 'Recurring';
                newOpp.Payment_Frequency__c = 'Annual';
                newOpp.Payment_Stop__c = 'Unending';
                newOpp.Stripe_Outbound_Type__c = 'Create';
                Contract con = mapOppToMemberContract.containsKey(newOpp.Id) ? mapOppToMemberContract.get(newOpp.Id) : null;
                if(con != null)
                    newOpp.Payment_Start_Date__c = con.Enddate;
                if(newOpp.Do_Not_change_amount__c == true || newOpp.Certified_Membership_Individual__c == true)
                    newOpp.Charge_Amount__c = 150;
                else if(newOpp.Do_Not_change_amount__c != true)
                    newOpp.Charge_Amount__c = 195;
            }
            acctIdSetForContractAutoRenew.add(newOpp.AccountId);
            updateOppsForContractUpdateMap('UpdateRecurringIntent',newOpp.AccountId);
        }
        
        
        if(newOpp.StageName == 'Closed Lost' && newOpp.StageName != oldOpp.StageName){
            if(newOpp.Event_Order__c == true)
                updateEventRegUpdateMap('UpdateCanceled',newOpp.id);
            if(newOpp.Auto_Renew__c){
                newOpp.Payment_Status__c = 'Stopped';
                newOpp.Stripe_Outbound_Type__c = 'Cancel';
            }
        }
    }
    
    public void processAfterUpdate(Opportunity newOpp,Opportunity oldOpp){
        if(newOpp.Gateway__c != oldOpp.Gateway__c || newOpp.Display_Invoice_Number__c != oldOpp.Display_Invoice_Number__c || newOpp.Name != oldOpp.Name ||
           //newOpp.Token__c != oldOpp.Token__c || newOpp.CardType__c != oldOpp.CardType__c || newOpp.Payment_Method_New__c != oldOpp.Payment_Method_New__c ||
           newOpp.Payment_Status__c != oldOpp.Payment_Status__c || newOpp.Payment_Frequency__c != oldOpp.Payment_Frequency__c || newOpp.Charge_Date__c != oldOpp.Charge_Date__c || 
           newOpp.Payment_Stop__c != oldOpp.Payment_Stop__c || newOpp.Payment_End_Date__c != oldOpp.Payment_End_Date__c || newOpp.Payment_Start_Date__c != oldOpp.Payment_Start_Date__c || 
           newOpp.Next_Transaction_Date__c != oldOpp.Next_Transaction_Date__c || newOpp.Manual_Charge__c != oldOpp.Manual_Charge__c || newOpp.Charge_Amount__c != oldOpp.Charge_Amount__c || 
           newOpp.Payment_Count__c != oldOpp.Payment_Count__c || newOpp.Billing_Address__c != oldOpp.Billing_Address__c || newOpp.Billing_Address_Line_2__c != oldOpp.Billing_Address_Line_2__c || 
           newOpp.Billing_City__c != oldOpp.Billing_City__c || newOpp.Billing_Company__c != oldOpp.Billing_Company__c || newOpp.Billing_Country__c != oldOpp.Billing_Country__c || 
           newOpp.Billing_Email__c != oldOpp.Billing_Email__c || newOpp.Billing_Fax__c != oldOpp.Billing_Fax__c || newOpp.Billing_First_Name__c != oldOpp.Billing_First_Name__c || 
           newOpp.Billing_Last_Name__c != oldOpp.Billing_Last_Name__c || newOpp.Billing_Phone__c != oldOpp.Billing_Phone__c || newOpp.Billing_State_Text__c != oldOpp.Billing_State_Text__c || 
           newOpp.Billing_Zip_Postal__c != oldOpp.Billing_Zip_Postal__c || newOpp.Shipping_Address__c != oldOpp.Shipping_Address__c || newOpp.Do_Not_Change_Amount__c != oldOpp.Do_Not_Change_Amount__c ||
           newOpp.Amount != oldOpp.Amount
          ){
            aftUpdMapForOrder.put(newOpp.Id,newOpp);
        }
    }
    
    public void procShpCnclAndRsnd(Opportunity newOpp,Opportunity oldOpp){
        //ShipEdge integration
        if((newOpp.Resend_Order_To_ShipEdge__c == true && newOpp.Resend_Order_To_ShipEdge__c != oldOpp.Resend_Order_To_ShipEdge__c) || 
           (newOpp.Cancel_Books__c == true && newOpp.Cancel_Books__c != oldOpp.Cancel_Books__c)){
            //Method to call ShipEdge integration for books shipping
            //system.debug('Check Ship Edge');
            if((newOpp.Ups_Stage__c == 'New Order' || newOpp.Ups_Stage__c == 'Order Error') && newOpp.Has_Books__c == true && newOpp.Cancel_Books__c == false && newOpp.Resend_Order_To_ShipEdge__c == true){
                //system.debug('Check Ship Edge Add');
                shipEdgeCall = true;
                if(methodToOppsMap.containsKey('ShipEdgeAdd')){
                    Set<Id> oppSet = methodToOppsMap.get('ShipEdgeAdd');
                    oppSet.add(newOpp.Id);
                    methodToOppsMap.put('ShipEdgeAdd',oppSet);
                }else{
                    methodToOppsMap.put('ShipEdgeAdd',new Set<Id>{newOpp.Id});
                }
            }else if(newOpp.Cancel_Books__c == true && newOpp.Has_Books__c == true){
                //system.debug('Check Ship Edge Cancel');
                if(String.isNotBlank(newOpp.Tracking_Number__c)){
                    newOpp.adderror('Ship Order cannot be canceled after Tracking Number is generated.');
                }else if(methodToOppsMap.containsKey('ShipEdgeCancel')){
                    shipEdgeCall = true;
                     Set<Id> oppSet = methodToOppsMap.get('ShipEdgeCancel');
                     oppSet.add(newOpp.Id);
                     methodToOppsMap.put('ShipEdgeCancel',oppSet);
                 }else{
                     shipEdgeCall = true;
                     methodToOppsMap.put('ShipEdgeCancel',new Set<Id>{newOpp.Id});
                 }
            }
        }
    }
    
    public void procSageIntegration(Opportunity newOpp,Opportunity oldOpp){
        if(newOpp.Sage_Order_Approved__c == true && newOpp.Sage_Order_Approved__c != oldOpp.Sage_Order_Approved__c){
            sageIntegration = true;
            if(methodToOppsMap.containsKey('SageOrderProcess')){
                Set<Id> oppSet = methodToOppsMap.get('SageOrderProcess');
                oppSet.add(newOpp.Id);
                methodToOppsMap.put('SageOrderProcess',oppSet);
            }else{
                methodToOppsMap.put('SageOrderProcess',new Set<Id>{newOpp.Id});
            }
        }
    }
    
    public void sageProcessReallocation(Opportunity newOpp,Opportunity oldOpp){
        if(newOpp.ia_crm__Intacct_Transaction__c == 'Salesforce - Refund' 
           && newOpp.ia_crm__Intacct_Sync_Status_1__c == 'OK' && newOpp.ia_crm__Intacct_Sync_Status_1__c != oldOpp.ia_crm__Intacct_Sync_Status_1__c){
               sageReallocationCall = true;
               if(methodToOppsMap.containsKey('SAGEREALLOCATION')){
                   Set<Id> oppSet = methodToOppsMap.get('SAGEREALLOCATION');
                   oppSet.add(newOpp.Id);
                   methodToOppsMap.put('SAGEREALLOCATION',oppSet);
               }else{
                   methodToOppsMap.put('SAGEREALLOCATION',new Set<Id>{newOpp.Id});
               }
        }
    }
    
    public void processOpportunityProductsForClosedOpps(Opportunity opp){
        boolean updateOppShippingDetails = false;
        boolean updateTaxAuthority = false;
        oppLineWrapper oWrapper = new oppLineWrapper();
        if(oppToProductsMap.containsKey(opp.Id)){
            for(OpportunityLineItem oli : oppToProductsMap.get(opp.Id)){
                if(oli.For_Sage_Sync_Only__c == false){
                    //system.debug(' in   processOpportunityProductsForClosedOpps::>>   '+oli.ProductCode);
                    //For Product rate offer method
                    if(oli.Opportunity.Billing_Email__c != NULL) {
                        productCodes.add(oli.ProductCode);
                        glCodes.add(oli.Product2.GL_Code__c);
                        productKeys.add(oli.ProductCode + ':' + oli.Product2.GL_Code__c + ':' + oli.Opportunity.Billing_Email__c.tolowercase());
                    }
                    if(oppProductToMethodMap.containskey(oli.ProductCode) || (oli.Product2.family != null && oppProductToMethodMap.containskey(oli.Product2.family))){
                        string methodName = oppProductToMethodMap.containskey(oli.ProductCode) ? oppProductToMethodMap.get(oli.ProductCode).Map_Key__c : (oppProductToMethodMap.containskey(oli.Product2.family) ? oppProductToMethodMap.get(oli.Product2.family).Map_Key__c : null);
                            //system.debug(' in2   processOpportunityProductsForClosedOpps::>>   '+methodName);
                        boolean priceCheck = oppProductToMethodMap.containskey(oli.ProductCode) ? oppProductToMethodMap.get(oli.ProductCode).Price_Check__c : false;
                        if(methodName != null && methodToOppsMap.containsKey(methodName)){
                            Set<Id> oppSet = methodToOppsMap.get(methodName);
                            if(methodName == 'ScholarshipApplication'){
                                oppSet.add(oli.Scholarship_Application__c);
                            }else{
                                oppSet.add(oli.OpportunityId);
                            }
                            methodToOppsMap.put(methodName,oppSet);
                        }else if (methodName != null){
                            if(methodName == 'UpdateContracts'){
                                if(priceCheck == true && oli.UnitPrice == 250){
                                    updateOppsForContractUpdateMap('UpdateFRRor2009',oli.Opportunity.AccountId);
                                }else if(priceCheck == false){
                                    updateOppsForContractUpdateMap('UpdateFRRor2009',oli.Opportunity.AccountId);
                                }
                            }else if(methodName == 'OSTAProgram' && oli.Opportunity.Exam_Registration_Modification__c == null){
                                updateOppsForContractUpdateMap('OSTAProgram',oli.OpportunityId);
                                lineItemByOpportunityId.put(oli.OpportunityId, oli);
                            }else if(methodName == 'ScholarshipApplication'){
                                methodToOppsMap.put(methodName,new Set<Id>{oli.Scholarship_Application__c});
                            }else if(methodName == 'ATAPSIIntegration' || oli.ProductCode == 'CBRNM' || oli.ProductCode == 'CBR' || oli.ProductCode == 'CBR2A'){
                                updateIdsForRecordIdMap('ATAPSIIntegration',oli.OpportunityId);
                                if(oli.ProductCode == 'CBRNM' || oli.ProductCode == 'CBR' || oli.ProductCode == 'CBR2A'){
                                    updateIdsForRecordIdMap('FRREBookANDYardStick',oli.OpportunityId);
                                }
                            }else if(methodName == 'ExtendRiskDotNet'){
                                updateOppsForContractUpdateMap('ExtendRiskDotNet',oli.OpportunityId);
                                lineItemByOpportunityId.put(oli.OpportunityId, oli);
                            }else if(methodName == 'IndividualMember'){
                                updateOppsForContractUpdateMap('IndividualMember',oli.Opportunity.AccountId);
                            }else if(methodName == 'IndividualMemberHalfYear'){
                                updateOppsForContractUpdateMap('IndividualMemberHalfYear',oli.Opportunity.AccountId);
                            }else if(methodName == 'AffiliateMember'){
                                updateOppsForContractUpdateMap('AffiliateMember',oli.Opportunity.AccountId);
                            }else if(methodName == 'RetabulationRequest'){
                                updateIdsForRecordIdMap('RetabulationRequest',oli.Exam_Registration__c);
                                if(oli.Exam_Registration__r.Exam_Date__c != null){
                                    Datetime dt = Datetime.newInstance(oli.Exam_Registration__r.Exam_Date__c, Time.newInstance(0, 0, 0, 0));
                                    oli.Description = dt.format('MMM YYYY');
                                    oliToUpdate.add(oli);
                                }
                            }else{
                                methodToOppsMap.put(methodName,new Set<Id>{oli.OpportunityId});
                            }
                        }
                    }
                    if(oli.ProductCode == 'Ship'){
                        opp.Shipping_Serive_Selected__c = oli.Description;
                        opp.UPS_Service_Code_For_Xml__c = opportunityTriggerUtils_New.getUPSCode(oli.Description);
                    }
                    if(oli.Product2.Is_Shippable__c == true){
                        updateOppShippingDetails = true;
                        if(oWrapper.Product_Codes == null)
                            oWrapper.Product_Codes =   oli.Product2.Product_ID__c;
                        else
                            oWrapper.Product_Codes =   oWrapper.Product_Codes + ',' +oli.Product2.Product_ID__c;
                        
                        if(oWrapper.Product_Names == null)
                            oWrapper.Product_Names =   oli.Product2.Name;
                        else
                            oWrapper.Product_Names =   oWrapper.Product_Names + ',' +oli.Product2.Name;
                        
                        if(oWrapper.Customs_Cost == null)
                            oWrapper.Customs_Cost =   string.valueof(oli.quantity * integer.valueof(oli.Product2.Customs_Cost__c));
                        else
                            oWrapper.Customs_Cost =   oWrapper.Customs_Cost + ',' +string.valueof(oli.quantity * integer.valueof(oli.Product2.Customs_Cost__c));
                        
                        
                        if(oWrapper.Product_Weight == null)
                            oWrapper.Product_Weight =   oli.quantity *oli.Product2.Weight__c;
                        else
                            oWrapper.Product_Weight =   oWrapper.Product_Weight + (oli.quantity *oli.Product2.Weight__c);
                        
                        if(oWrapper.Product_SKU == null)
                            oWrapper.Product_SKU =   oli.Product_SKU__c;
                        else
                            oWrapper.Product_SKU =   oWrapper.Product_SKU + ',' +oli.Product_SKU__c;
                        
                    }
                    if(String.isNotBlank(oli.Product2.Tax_Authority__c)){
                        updateTaxAuthority = true;
                        oWrapper.taxAuthority = oli.Product2.Tax_Authority__c;
                    }
                }
            }
        }
        
        if(updateOppShippingDetails){
            opp.Total_Package_Weight__c = oWrapper.Product_Weight;
            opp.Product_Ids__c = oWrapper.Product_Codes;
            opp.Product_Names__c = oWrapper.Product_Names;
            opp.Customs_Cost__c = oWrapper.Customs_Cost;
            opp.Products_SKU__c = oWrapper.Product_SKU;
        }
        
        if(updateTaxAuthority){
            opp.Tax_Authority__c = oWrapper.taxAuthority;
        }
    }
    
    public void processOpportunityProductMethods(Map<Id,Opportunity> closedOppsMap){
        List<Integration_Stream_Event__e> eventList = new List<Integration_Stream_Event__e>();
        for(string method : methodToOppsMap.keyset()){
            if(method == 'ERP2EBook' || method == 'FFREBook' || method == 'FRM1EBook' || method == 'FRM2EBook' || 
               method == 'FRREBook' || method == 'SCREBook' || method == 'ChapterMeeting' || method == 'FRREBookANDYardStick' || 
               method == 'provisionEvents' || method == 'ShipEdgeAdd' || method == 'ShipEdgeCancel' || method == 'SAGEREALLOCATION' || 
               method == 'SCRBenchPrep' || method == 'SageOrderProcess' || method == 'FRMBenchPrep' || method == 'FRMBenchExam'){
                   List<Integration_Stream_Event__e> evtList = TriggerUtilities.getIntgEvents(methodToOppsMap.get(method),'Opportunity',method);
                   eventList.addAll(evtList);
               }else if(method == 'CreateDuplicateShippingFRM'){
                   OpportunityTriggerHelper_New.processDuplicateShipping(methodToOppsMap.get(method),closedOppsMap,'FRM',contactList);
               }else if(method == 'CreateDuplicateShippingERP'){
                   OpportunityTriggerHelper_New.processDuplicateShipping(methodToOppsMap.get(method),closedOppsMap,'ERP',contactList);
               }else if(method == 'ScholarshipApplication'){
                   OpportunityTriggerHelper_New.setScholarshipApplicationStatusAsUsed(methodToOppsMap.get(method));
               }
        }
        
        if(!oliToUpdate.isEmpty()){
                update oliToUpdate;
        }
        if(!eventList.isEmpty()){
                EventBus.publish(eventList);
        }
    }
    
    public void updateOppsForContractUpdateMap(String updateReason,Id recordId){
        if(contractUpdateToRecordIdMap.containsKey(updateReason)){
            Set<Id> recordIdSet = contractUpdateToRecordIdMap.get(updateReason);
            recordIdSet.add(recordId);
            contractUpdateToRecordIdMap.put(updateReason,recordIdSet);
        }else{
            contractUpdateToRecordIdMap.put(updateReason,new Set<Id>{recordId});
        }
    }
    
    public void updateIdsForRecordIdMap(String updateReason,Id recordId){
        if(examRegUpdateToRecordIdMap.containsKey(updateReason)){
            Set<Id> recordIdSet = examRegUpdateToRecordIdMap.get(updateReason);
            recordIdSet.add(recordId);
            examRegUpdateToRecordIdMap.put(updateReason,recordIdSet);
        }else{
            examRegUpdateToRecordIdMap.put(updateReason,new Set<Id>{recordId});
        }
    }
    
    public void updateEventRegUpdateMap(String updateReason,Id recordId){
        if(eventRegUpdateToRecordIdMap.containsKey(updateReason)){
            Set<Id> recordIdSet = eventRegUpdateToRecordIdMap.get(updateReason);
            recordIdSet.add(recordId);
            eventRegUpdateToRecordIdMap.put(updateReason,recordIdSet);
        }else{
            eventRegUpdateToRecordIdMap.put(updateReason,new Set<Id>{recordId});
        }
    }
    
    public void stripeIntegration(Opportunity newOpp,Opportunity oldOpp){ 
        if(newOpp.Stop_Stripe_Callout__c == false){
            Decimal ss = (newOpp.Charge_Amount__c == 195 || newOpp.Charge_Amount__c == 150)
                ? newOpp.Charge_Amount__c
                : ((newOpp.LastRecurringAmount__c == 195 || newOpp.LastRecurringAmount__c == 150)
                   ? newOpp.LastRecurringAmount__c
                   : newOpp.Charge_Amount__c);
            if(newOpp.Payment_Status__c == 'Recurring' && newOpp.Charge_Amount__c != null){
                if(newOpp.Stripe_Subscription_Id__c == null && newOpp.Stripe_Outbound_Type__c == 'Create' && (newOpp.Payment_Status__c != oldOpp.Payment_Status__c || newOpp.Stripe_Outbound_Type__c != oldOpp.Stripe_Outbound_Type__c)){
                    Stripe_Integration__e st = new Stripe_Integration__e();
                    st.Action_Type__c = 'Create'; 
                    st.Opportunity_Id__c = newOpp.Id;
                    st.Charge_Amount__c = ss;
                    st.Vat_Amount__c = newOpp.Charge_Amount_VAT__c;
                    st.Customer_Id__c = newOpp.Token__c; 
                    st.Payment_Date__c = newOpp.Payment_Start_Date__c;
                    st.Account_Id__c = newOpp.AccountId;
                    stripeEvents.add(st); 
                    isStripeEvent = true;
                }else if(newOpp.Stripe_Subscription_Id__c != null  && ((newOpp.Charge_Amount__c != oldOpp.Charge_Amount__c || newOpp.Payment_Start_Date__c != oldOpp.Payment_Start_Date__c))){
                    Stripe_Integration__e st = new Stripe_Integration__e();
                     st.Action_Type__c = 'Update'; 
                    st.Opportunity_Id__c = newOpp.Id;
                    st.Charge_Amount__c = ss; 
                    st.Vat_Amount__c = newOpp.Charge_Amount_VAT__c;
                    st.Stripe_Price_Id__c = newOpp.Stripe_Price_Id__c;
                    st.Subscription_Id__c = newOpp.Stripe_Subscription_Id__c;
                    st.Payment_Date__c = newOpp.Payment_Start_Date__c;
                    st.Account_Id__c = newOpp.AccountId;
                     st.Customer_Id__c = newOpp.Token__c; 
                    stripeEvents.add(st);
                     isStripeEvent = true;
                }
            }
            if(newOpp.Stripe_Subscription_Id__c != null && newOpp.Stripe_Outbound_Type__c == 'Cancel' && ((newOpp.Payment_Status__c == 'Stopped' && newOpp.Stripe_Outbound_Type__c != 'Refunded' && newOpp.Payment_Status__c != oldOpp.Payment_Status__c) || (newOpp.Stripe_Outbound_Type__c != oldOpp.Stripe_Outbound_Type__c))){
                Stripe_Integration__e st = new Stripe_Integration__e();
                st.Action_Type__c = 'Cancel'; 
                st.Opportunity_Id__c = newOpp.Id;
                st.Charge_Amount__c = ss; 
                st.Vat_Amount__c = newOpp.Charge_Amount_VAT__c;
                st.Stripe_Price_Id__c = newOpp.Stripe_Price_Id__c;
                st.Subscription_Id__c = newOpp.Stripe_Subscription_Id__c;
                stripeEvents.add(st); 
                 isStripeEvent = true;
            } 
        } 
    }
    
    
}