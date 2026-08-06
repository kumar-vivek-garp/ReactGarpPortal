global class chargemodificationsonopp implements Database.Batchable<SObject>, Database.AllowsCallouts {
   global Set<String> opprecId = new Set<String>();
    
    global chargemodificationsonopp(){
        
    }
    global chargemodificationsonopp(Set<String> opp){
        this.opprecId = opp;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> setStatus = new Set<String>{'Recurring'}; 
            String query = 'select id,Charge_Amount_VAT__c,accountId,account.ShippingCountry,account.BillingCountry,Payment_Status__c ,Payment_Count__c, Charge_Amount__c,Manual_Charge__c,Next_Transaction_Date__c,Token__c,Payment_Start_Date__c ,Payment_End_Date__c ,Payment_Stop__c ,Charge_Date__c ,Payment_Frequency__c,IsStripeTax__c,LastRecurringAmount__c from Opportunity where Payment_Status__c in : setStatus';
        if(!opprecId.isEmpty()){
            query += ' And Id In:opprecId';
        }
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        Map<Id,Contract> memContractsMap = new Map<Id,Contract>();
        Map<String,String> tokenMap = new Map<String,String>();
        StripeInvoicePreview.StripeConfig stCfg = StripeInvoicePreview.getConfig();
        Set<String> oppIds = new Set<String>();
        id memRecTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'Membership');
        Set<Id> setAccIds = new Set<Id>();
        for(Opportunity obj : scope){
            oppIds.add(obj.Id);
            setAccIds.add(obj.accountId);
        }
        Map<String, Stripe_Product_Configuration__mdt> allMetadata = Stripe_Product_Configuration__mdt.getAll();
        if(oppIds.size() > 0){
            for(ChargentOrders__Transaction__c crt:[Select Id,Opportunity__c,ChargentOrders__Tokenization__c From ChargentOrders__Transaction__c Where Opportunity__c In:oppIds]){
                tokenMap.put(crt.Opportunity__c,crt.ChargentOrders__Tokenization__c);
            }
        } 
        List<Contact> contacts = [Select Id, MailingCountry,Accountid from Contact where AccountId IN: setAccIds];
        Map<Id,Contact> accToContactMap = new Map<Id,Contact>();
        for(Contact con: contacts){
            accToContactMap.put(con.AccountId, con);
        }
        
       /* Map<String,Decimal> countryVatMap = new Map<String,Decimal>();
        for(Country_Code__c cc : [SELECT Id,Country__c,VAT__c FROM Country_Code__c WHERE VAT__c != NULL ]){
            countryVatMap.put(cc.Country__c,cc.VAT__c);
        } */
        
        AggregateResult[] groupedResults = [select SUM(ContractTerm) term,accountId from Contract where accountId in : setAccIds and recordTypeId = : memRecTypeId and Membership_Type__c = 'Student' group by accountId];
        
        Map<Id,boolean> mapContacts = new Map<Id,boolean>();
        
        
        Id frmRecType = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
        Id erpRecType = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','ERP_Program');
        Id scrRecType = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
        Id raiRecType = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_AI_Program');
        Id raijRecType = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','RAIJ_Program');//Chinnapa
        
        Set<Id> recTypeIds = new Set<Id>{memRecTypeId,frmRecType,erpRecType,scrRecType,raiRecType,raijRecType};
        Set<Id> prrecTypeIds = new Set<Id>{frmRecType,erpRecType,scrRecType,raiRecType,raijRecType};            
        for (Contract ct : [SELECT Id, Name, AccountId, Status, EndDate, RecordTypeId, Membership_Type__c FROM Contract WHERE AccountId IN :setAccIds AND RecordTypeId IN :recTypeIds]) {
            if(prrecTypeIds.contains(ct.recordTypeId) && ct.Status == 'Completed'){
                mapContacts.put(ct.accountID,true);
            }else if(ct.recordTypeId == memRecTypeId && ct.Status == 'Activated ( Auto-Renew )' && ct.Membership_Type__c == 'Individual'){
                memContractsMap.put(ct.accountID, ct);
            }  
        }
        
        Map<Id,Decimal> mapAccountTerm = new Map<Id,Decimal>();
        for (AggregateResult Result: groupedResults){
            mapAccountTerm.put((Id)Result.get('accountId'),(Decimal) Result.get('term'));
        }
        
        //List<Opportunity> lstUpdateOpps = new List<Opportunity>();
        Map<Id, Opportunity> oppsToUpdateMap = new Map<Id, Opportunity>();
        for(Opportunity objUpdate : scope){
            Decimal vatPercent = 0.00;
            Decimal chAmount = 0.00;
           /*if(objUpdate.account.BillingCountry != Null && countryVatMap.containsKey(objUpdate.account.BillingCountry) 
               && accToContactMap.containskey(objUpdate.accountId) && accToContactMap.get(objUpdate.accountId).MailingCountry != null 
               && countryVatMap.containsKey(accToContactMap.get(objUpdate.accountId).MailingCountry)) {
                vatPercent = countryVatMap.get(objUpdate.account.BillingCountry) / 100; 
            } */
            /*if(vatPercent == 0.00 && objUpdate.account.ShippingCountry != Null && countryVatMap.containsKey(objUpdate.account.ShippingCountry)){
                vatPercent = countryVatMap.get(objUpdate.account.ShippingCountry) / 100;
            }*/
            
            if(mapContacts.get(objUpdate.accountID) != null && objUpdate.Charge_Amount__c != 150){
                if(memContractsMap.containsKey(objUpdate.accountID)){
                    objUpdate.Payment_Start_Date__c = memContractsMap.get(objUpdate.accountID).EndDate;
                }
             /* if(vatPercent > 0){
                    Decimal currentvat = (150 * vatPercent).setscale(2);
                    if(objUpdate.Charge_Amount_VAT__c == null || currentvat != objUpdate.Charge_Amount_VAT__c){
                        objUpdate.Charge_Amount_VAT__c = currentvat;
                        chAmount = 150;
                        objUpdate.Charge_Amount__c = 150 + objUpdate.Charge_Amount_VAT__c;
                    }
                }else{
                    objUpdate.Charge_Amount__c = 150;
                    chAmount = 150;
                } */ 
                objUpdate.Charge_Amount__c = 150;
                chAmount = 150;
                objUpdate.Do_Not_change_amount__c = true;
                //lstUpdateOpps.add(objUpdate);
                oppsToUpdateMap.put(objUpdate.Id,objUpdate);
            }
            
            else if(mapAccountTerm.get(objUpdate.accountId) >= 24 && objUpdate.Charge_Amount__c != 95){ 
                if(memContractsMap.containsKey(objUpdate.accountID)){
                    objUpdate.Payment_Start_Date__c = memContractsMap.get(objUpdate.accountID).EndDate;
                }
              /* if(vatPercent > 0){
                    Decimal currentvat = (195 * vatPercent).setscale(2);
                    if(objUpdate.Charge_Amount_VAT__c == null || currentvat != objUpdate.Charge_Amount_VAT__c){
                        objUpdate.Charge_Amount_VAT__c = currentvat;
                        chAmount = 195;
                        objUpdate.Charge_Amount__c = 195 + objUpdate.Charge_Amount_VAT__c;
                    }
                }else{
                    objUpdate.Charge_Amount__c = 195;
                    chAmount = 195;
                } */
                objUpdate.Charge_Amount__c = 195;
                chAmount = 195; 
                //lstUpdateOpps.add(objUpdate);
                oppsToUpdateMap.put(objUpdate.Id,objUpdate);
            }
            
            else if(objUpdate.Charge_Amount__c != 195 && objUpdate.Charge_Amount__c != 150){
                if(memContractsMap.containsKey(objUpdate.accountID)){
                    objUpdate.Payment_Start_Date__c = memContractsMap.get(objUpdate.accountID).EndDate;
                }
               /* if(vatPercent > 0){
                    Decimal currentvat = (195 * vatPercent).setscale(2);
                    if(objUpdate.Charge_Amount_VAT__c == null || currentvat != objUpdate.Charge_Amount_VAT__c){
                        objUpdate.Charge_Amount_VAT__c = currentvat;
                        chAmount = 195;
                        objUpdate.Charge_Amount__c = 195 + objUpdate.Charge_Amount_VAT__c;
                    }
                }else{
                    objUpdate.Charge_Amount__c = 195;
                    chAmount = 195;
                } */

                objUpdate.Charge_Amount__c = 195;
                chAmount = 195;
                //lstUpdateOpps.add(objUpdate);
                oppsToUpdateMap.put(objUpdate.Id,objUpdate);
            }
            
            if(memContractsMap.containsKey(objUpdate.accountID) ){
               // Boolean updaterecords = false;
                if(objUpdate.Charge_Amount__c == 195 || objUpdate.Charge_Amount__c == 150){
                    chAmount = objUpdate.Charge_Amount__c;
                }
                 /*   if(vatPercent > 0){
                         Decimal currentvat =  (objUpdate.Charge_Amount__c * vatPercent).setscale(2);
                        decimal chargeamount = objUpdate.Charge_Amount__c;
                        chAmount = objUpdate.Charge_Amount__c;
                        if(objUpdate.Charge_Amount_VAT__c != null){
                            chargeamount = objUpdate.Charge_Amount__c + objUpdate.Charge_Amount_VAT__c;
                        } 
                        if(objUpdate.Charge_Amount_VAT__c == null || chargeamount != objUpdate.Charge_Amount__c){
                            objUpdate.Charge_Amount_VAT__c = currentvat;
                            objUpdate.Charge_Amount__c = objUpdate.Charge_Amount__c + objUpdate.Charge_Amount_VAT__c;
                            updaterecords = true;
                        }
                    }
                } */
				if(objUpdate.Payment_Start_Date__c == null){
					objUpdate.Payment_Start_Date__c = memContractsMap.get(objUpdate.accountID).EndDate;
                    oppsToUpdateMap.put(objUpdate.Id,objUpdate);
				} 
            } 
            String mtdKey = 'Charge_'+Integer.valueof(chAmount);
            // Fire Stripe only when the base charge actually changed (vs the amount tax was last calculated for),
            // or when tax has not yet been calculated / a recalc was forced (IsStripeTax__c = false, e.g. address change).
            Boolean baseChanged = (chAmount != objUpdate.LastRecurringAmount__c);
            Boolean needsRecalc = (objUpdate.IsStripeTax__c != true);
            if(chAmount > 0 && (baseChanged || needsRecalc) && allMetadata.containsKey(mtdKey)){
                StripeInvoicePreview.stRequest inpr = new StripeInvoicePreview.stRequest();
                if(tokenMap.containsKey(objUpdate.Id)){
                    inpr.customerId = tokenMap.get(objUpdate.Id);
                }else if(objUpdate.Token__c != null){
                    inpr.customerId = objUpdate.Token__c;
                }
                inpr.oppId = objUpdate.Id;
                inpr.quantity = 1;
                inpr.priceId = allMetadata.get(mtdKey).Price_Id__c;
                try{
                    StripeInvoicePreview.stResult prRes = StripeInvoicePreview.previewSubTax(inpr, stCfg);
                    objUpdate.StripeTaxPreviewRes__c = JSON.serialize(prRes);
                    objUpdate.StripeRecurringTax__c = prRes.taxRate;
                    objUpdate.StripeRecTotalAmount__c = prRes.amountDue;
                    if(prRes.taxRate <= 0){
                        objUpdate.Charge_Amount_VAT__c = prRes.taxRate; 
                        objUpdate.Stripe_Tax_ProductId__c = prRes.productCode;
                    }
                    objUpdate.Charge_Amount__c = prRes.amountDue; //Using for paypal
                    // Mark tax as calculated and record the base amount it was calculated for,
                    // so future runs skip Stripe unless the base changes or a recalc is forced.
                    objUpdate.IsStripeTax__c = true;
                    objUpdate.LastRecurringAmount__c = chAmount; // using for Stripe Billing Price
                    oppsToUpdateMap.put(objUpdate.Id,objUpdate);
                }catch(Exception ex){ 
                    objUpdate.StripeTaxPreviewRes__c = 'Stripe Preview Error:'+ex.getMessage();
                    oppsToUpdateMap.put(objUpdate.Id,objUpdate);
                }
            }
        }

        try{
            List<Opportunity> lstUpdateOpps = oppsToUpdateMap.values();
            
            if (!lstUpdateOpps.isEmpty()) {
                update lstUpdateOpps;
            }  
        }catch(Exception ex){
             system.debug(ex.getMessage());
        }
    }
    
    
    
    global void finish(Database.BatchableContext BC){}
}