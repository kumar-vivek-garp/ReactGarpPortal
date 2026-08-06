public class opportunityTriggerUtils_New { 
    public static String MobiusProductYear;
    public static Contract getNewRiskContract(OpportunityLineItem oli,Map<Id,Contact> accIdToContactMap){
        Id riskNetRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_Net');
        Contract riskContract = new Contract();
        riskContract.Name = 'Risk.net';
        riskContract.Status = 'Draft';
        if(accIdToContactMap.containsKey(oli.Opportunity.AccountId)){
            Contact contact = accIdToContactMap.get(oli.Opportunity.AccountId);
            riskContract.CustomerSignedId = contact.Id;
            riskContract.Pearson_Member_First_Name__c = contact.FirstName;
            riskContract.Pearson_Member_Last_Name__c = contact.LastName;
            riskContract.Member_Email__c = contact.Email;
            riskContract.Pearson_Phone_No__c = contact.HomePhone;
        }
        riskContract.accountId = oli.Opportunity.AccountId;
        riskContract.Opportunity__c = oli.OpportunityId;
        riskContract.StartDate = system.today();
        if(oli.UnitPrice == 100){
            riskContract.ContractTerm = 12;
        }else{
            riskContract.ContractTerm = Integer.valueOf(oli.quantity);
        }
        riskContract.recordTypeID = riskNetRecordTypeID;
        return riskContract;
    }
    
    public static Contract getNewMemberContract(Opportunity opp,Id memberRecordType,string strMemberShipType){
        Contract objContract = new Contract();
        objContract.status = 'Draft';
        objContract.accountId = opp.accountId;
        objContract.Opportunity__c = opp.Id;
        objContract.StartDate = system.today();
        if(strMemberShipType != 'HalfYearFree'){
            objContract.Membership_Type__c = strMemberShipType;
            objContract.ContractTerm  = 12;
        }else{
            objContract.Membership_Type__c = 'Individual';
            objContract.ContractTerm  = 6;
        }
        objContract.recordTypeID = memberRecordType;
        return objContract; 
        
    }
    
    public static Contract getNewOSTAContract(Id accountId,Id OppId,Id contactId,Id OSTARecTypeId,ID FRMProgramId){
        Contract ostaContract = new Contract();
        ostaContract.AccountId = accountId;
        ostaContract.Opportunity__c = OppId;
        ostaContract.RecordTypeId = OSTARecTypeId;
        ostaContract.FRM_Exam_Program__c = FRMProgramId != null ? FRMProgramId:null;
        ostaContract.Status = 'Draft';
        ostaContract.Name = 'OSTA Program';
        ostaContract.StartDate = System.today();
        ostaContract.ContractTerm = 9999;
        ostaContract.CustomerSignedId = contactId;
        
        return ostaContract;
    }
    
    public static void unprovisionMobiuseBook(Map<Id, String> garpMemberIdByOpportunityId, String exam, String part) {
        Set<Integer> productIds = new Set<Integer>();
        Map<String, Mobius_Products__c> mobiusProducts = Mobius_Products__c.getall();                
        Mobius_Products__c MobiusProductYearObj = mobiusProducts.get(exam + ' Current Year');
        if(MobiusProductYearObj != null) {
            MobiusProductYear = MobiusProductYearObj.Year__c;
            
            
            for(Mobius_Products__c mobiusProduct :mobiusProducts.values()) {
                if(mobiusProduct.Year__c == MobiusProductYear && mobiusProduct.Exam__c == exam && mobiusProduct.Part__c == part){
                    productIds.add(Integer.valueOf(mobiusProduct.Product_Id__c));
                }
            }
        
            
            for(String key: garpMemberIdByOpportunityId.keySet()){
                system.debug('');
                MobiusAPI.mUnProvisionAnEBook(key, Integer.valueOf(garpMemberIdByOpportunityId.get(key)), productIds);
            }
        }
    }
    
    public static void cancelFFRA(Set<Id> oppIDs) {
        system.debug('* * * cancelFFR ...'+ oppIDs);
        MAP<ID,ID> ids = new MAP<ID,ID>();
        MAP<ID,ID> contactAcct = new MAP<ID,ID>();
        
        LIST<Opportunity> opps = [select Id, AccountId, Billing_Email__c from Opportunity where ID in :oppIDs];
        for(Opportunity opp :opps) {
            ids.put(opp.AccountId, opp.id);
        }
        system.debug('ids:' + ids);
        LIST<Contact> conts = [select Id, AccountId from Contact where AccountId in :ids.keySet()];
        for(Contact cont :conts) {
            contactAcct.put(cont.AccountId, cont.id);
        }
        system.debug('contactAcct:' + contactAcct);
        /* Spuran - Please review
        for(Opportunity opp :opps) {
            ID contId = contactAcct.get(opp.AccountId);
            if(contId != NULL) {
                //smartProsAPI - Class had deleted
                API_Transaction__c trans = smartProsAPI.cancelPurchaseStart(opp.Billing_Email__c, opp.Id);
                smartProsAPI.SendRequest(trans.Request__c, trans.Id);
                
            }
        }*/
        Id fbrRecordType = RecordTypeHelper.GetRecordTypeId('Contract', 'FBR Program');
        List<Contract> lstContr = [select Id, Status, AccountID from Contract where AccountID in :ids.keySet() and RecordTypeID = :fbrRecordType];
        for(Contract contr :lstContr) {
            contr.Status = 'Canceled';
        }
        update lstContr;
    }
    
    public static String getUPSCode(String strDesc) {
        if(strDesc == null) return 'ERROR';
        if(strDesc.IndexOf('UPS Next Day Air Saver') >= 0)
            return '1DP';
        if(strDesc.IndexOf('UPS Next Day Air Early A.M.') >= 0)
            return '1DM';
        if(strDesc.IndexOf('UPS Worldwide Express Plus') >= 0)
            return 'EP';
        if(strDesc.IndexOf('UPS 2nd Day Air A.M.') >= 0)
            return '2DM';
        if(strDesc.IndexOf('UPS Saver') >= 0)
            return 'SV';
        if(strDesc.IndexOf('UPS Next Day Air') >= 0)
            return '1DA';
        if(strDesc.IndexOf('UPS 2nd Day Air') >= 0)
            return '2DA';
        if(strDesc.IndexOf('UPS Ground') >= 0)
            return 'GND';
        if(strDesc.IndexOf('UPS Worldwide Express')  >= 0)
            return 'ES';
        if(strDesc.IndexOf('UPS Worldwide Expedited') >= 0)
            return 'EX';
        if(strDesc.IndexOf('UPS Standard') >= 0)
            return 'ST';
        if(strDesc.IndexOf('UPS 3 Day Select') >= 0)
            return '3DS';
        return 'ERROR';
    }
    
}