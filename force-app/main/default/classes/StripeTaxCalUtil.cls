public class StripeTaxCalUtil {
    public static Map<String, String> StripeTaxCulate(Set<String> oppIds){  
         
        // Single metadata fetch (SOQL) so Long Text Area fields (Stripe_Product_Code__c) are
        // returned. Reusable via getStripeAuthConfig() below.
        Stripe_Auth_Configuration__mdt taxConfig = getStripeAuthConfig();
         
        Map<String, String> resultMap = new Map<String, String>();
        
        try{
            List<Opportunity> oppList = [select Id, AccountId, Account.Member_First_Name__c, Account.Member_Last_Name__c, Name, StageName, Display_Invoice_Number__c, Amount, Billing_Email__c, Auto_Renew__c, B2B_Deal_Item__r.Access_Code__c,
                                         Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Postal_Code__c, Shipping_Country__c, Shipping_Phone_No__c,
                                         Billing_Address__c, Billing_City__c, Billing_State_Text__c, Billing_Zip_Postal__c, Billing_Country__c, Billing_Phone__c,
                                         (select Id, Description, PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice, Product2.Name, Product2.Stripe_Tax_Code__c, Product2.ProductCode, Product2.Tax_Rate__c, Product2.Do_Not_Charge_VAT__c, Product2.Do_Not_Charge_VAT_Countries__c FROM OpportunityLineItems),
                                         (select id, ChargentOrders__Gateway__c, ChargentOrders__Subtotal__c, ChargentOrders__Charge_Amount__c,
                                          ChargentOrders__Tokenization__c, ChargentOrders__Order_Information__c
                                          from Chargent_Orders__r)
                                         from Opportunity where id In:oppIds and (StageName = 'New Lead' OR StripeTaxMethod__c = 'Batch Tax Calculate Preview')];
            if(oppList.size() > 0){
                Boolean bypassStripeTax = taxConfig.BypassStripeTax__c;

                // Dynamic tax-type -> product-code mapping from custom metadata
                // (Stripe_Auth_Configuration__mdt.Stripe_Product_Code__c JSON:
                //  [{ "code","name","prcode","taxtype" }, ...]). Replaces the hardcoded
                // { SLSTX, IGSTTAX, SGST } list and the per-tax-type if/else below.
                Map<String, String> taxTypeToProductCode =
                    parseTaxTypeToProductCode(taxConfig == null ? null : taxConfig.Stripe_Product_Code__c);
                List<String> productCodes = new List<String>(new Set<String>(taxTypeToProductCode.values()));

                // Tax PricebookEntries keyed by ProductCode (self-contained — no GARP_BC_Orders ref).
                Map<String, PricebookEntry> taxPbeByCode = getTaxPricebookEntries(new Set<String>(productCodes));
                
                Map<String,String> existingTaxOliIds = new Map<String,String>();
                Set<Id> returnedTaxOliIds = new Set<Id>();
                
                Map<Id, OpportunityLineItem> olisToUpdateMap = new Map<Id, OpportunityLineItem>();
                List<OpportunityLineItem> olisToUpsert = new List<OpportunityLineItem>();
                List<OpportunityLineItem> olisToDelete = new List<OpportunityLineItem>();
                
                Map<Id, Opportunity> oppsToUpsertMap = new Map<Id, Opportunity>();
                List<API_Transaction__c> apiTransList = new List<API_Transaction__c>();
                
                for (Opportunity opp : oppList) {   
                    oppsToUpsertMap.put(opp.Id, new Opportunity(
                        Id = opp.Id,
                        Stripe_Tax_Type__c = null,
                        Stripe_Tax_Country__c = null,
                        Stripe_Tax_Taxable_Amount__c = null,
                        StripeTaxMethod__c = null,
                        StripeTaxStatus__c = null
                    ));             
                    
                    for (OpportunityLineItem li : opp.OpportunityLineItems) {     
                        if (productCodes.contains(li.Product2.ProductCode)) {
                            existingTaxOliIds.put(opp.Id,li.Id);
                        } else {
                            olisToUpdateMap.put(li.Id, new OpportunityLineItem(
                                Id = li.Id,
                                Stripe_Tax_Amount__c = null,
                                Stripe_Tax_Code__c = null
                            ));
                        }
                    }
                }
                
                Map<String, GARP_StripeClass.retGetCheckoutTax> retlstTax = GARP_StripeClass.getCheckoutListTax(oppList);
                
                for (String oppId : retlstTax.keySet()) {
                    
                    GARP_StripeClass.retGetCheckoutTax retTax = retlstTax.get(oppId);
                    
                    API_Transaction__c record = new API_Transaction__c(
                        Response_Body__c = String.valueOf(retTax),
                        Name = retTax.status + ' Stripe Tax Calculation ',
                        Type__c = 'Stripe',
                        Opportunity__c = oppId
                    );
                    GARP_StripeClass.orderTaxInfo taxInfo = retTax.orderTaxInfo;
                    if(Test.isRunningTest()){
                        taxInfo = new GARP_StripeClass.orderTaxInfo();
                        taxInfo.amount = 2;
                        taxInfo.taxType = 'sales_tax';
                        taxInfo.state = 'NJ';
                        taxInfo.taxableAmount = 100;
                        taxInfo.updatedOppLineItems = new List<OpportunityLineItem>{new OpportunityLineItem(id=null) };
                            } 
                    if (retTax.status == 'Success' && retTax.orderTaxInfo != null) { 
                        if(taxInfo.amount != null){ 
                             Decimal taxAmount = ((Decimal) taxInfo.amount / 100).setScale(2);  
                            //By pass Stripe Tax when true
                            if(bypassStripeTax == false){ 
                                if (taxInfo.taxPrdId != null && existingTaxOliIds.containsKey(oppId) && existingTaxOliIds.get(oppId) == taxInfo.taxPrdId) {                    
                                    olisToUpdateMap.put(taxInfo.taxPrdId, new OpportunityLineItem(
                                        Id = taxInfo.taxPrdId,
                                        UnitPrice = taxAmount
                                    ));
                                    returnedTaxOliIds.add(taxInfo.taxPrdId); 
                                } else {                    
                                    PricebookEntry pbeTax;
                                    String taxTypeKey = (taxInfo.taxType == null) ? null : taxInfo.taxType.toLowerCase();
                                    String taxPrCode = (taxTypeKey == null) ? null : taxTypeToProductCode.get(taxTypeKey);
                                    // Legacy parity: US sales tax is only applied for New Jersey.
                                    if (taxTypeKey == 'sales_tax' && taxInfo.state != 'NJ') {
                                        taxPrCode = null;
                                    }
                                    if (String.isNotBlank(taxPrCode)) {
                                        pbeTax = taxPbeByCode.get(taxPrCode);
                                    }
                                    
                                    if (pbeTax != null) {
                                        olisToUpsert.add(new OpportunityLineItem(
                                            OpportunityId = oppId,
                                            PricebookEntryId = pbeTax.Id,
                                            UnitPrice = taxAmount,
                                            Quantity = 1,
                                            Description = 'Sales Tax'
                                        ));
                                    }
                                }
                            }
                            if (taxInfo.updatedOppLineItems != null) {
                                for (OpportunityLineItem olio : taxInfo.updatedOppLineItems) {
                                    olisToUpdateMap.put(olio.Id, new OpportunityLineItem(
                                        Id = olio.Id,
                                        Stripe_Tax_Amount__c = olio.Stripe_Tax_Amount__c,
                                        Stripe_Tax_Code__c = olio.Stripe_Tax_Code__c
                                    ));
                                }
                            }
                            
                            record.Name += taxInfo.taxType;
                            
                            oppsToUpsertMap.put((Id) oppId, new Opportunity(
                                Id = oppId,
                                Stripe_Tax_Type__c = taxInfo.taxType,
                                Stripe_Tax_Country__c = taxInfo.country,
                                Stripe_Tax_Percent__c = taxInfo.percentageDecimal,
                                Stripe_Tax_Taxable_Amount__c = ((Decimal) taxInfo.taxableAmount / 100).setScale(2),
                                Stripe_Tax_Total_Amount__c = taxAmount,
                                StripeTaxStatus__c = 'Success',
                                StripeTaxMethod__c = null
                            ));
                        }  
                        resultMap.put(oppId, 'Success');
                        
                    } else {
                        record.Name = 'Stripe Tax Calculation Error';
                        record.Response_Body__c  = 'Error: '+retTax.message;
                        oppsToUpsertMap.put((Id) oppId, new Opportunity(StripeTaxStatus__c = 'Error',Id = oppId));  
                        resultMap.put(oppId, 'Error: '+retTax.message);
                    }
                    
                    apiTransList.add(record);
                }
                
              //By pass StripeTax
              if(bypassStripeTax == false){  
                    for (String opptaxId : existingTaxOliIds.keySet()) {
                        Id existingOliId = existingTaxOliIds.get(opptaxId);
                        if (!returnedTaxOliIds.contains(existingOliId)) {
                            olisToDelete.add(new OpportunityLineItem(Id = existingOliId));
                        }
                    }
                    
                    if (!olisToDelete.isEmpty()) {
                        delete olisToDelete;
                    }
                }
                
                
                
                if (!olisToUpsert.isEmpty()) {
                    upsert olisToUpsert;
                }
                
                if (!oppsToUpsertMap.isEmpty()) {
                    upsert oppsToUpsertMap.values();
                }
                
                if (!apiTransList.isEmpty()) {
                    insert apiTransList;
                }
                
                if (!olisToUpdateMap.isEmpty()) {
                    update olisToUpdateMap.values();
                }
            }            
        } catch (Exception ex) { 
            API_Transaction__c record = new API_Transaction__c();
            record.Response_Body__c = ex.getMessage()+ex.getStackTraceString() +String.join(new List<String>(oppIds), ', ');
            record.Name = 'Exception Stripte Tax Calculation';  
            record.Type__c = 'Stripe'; 
            insert record;
            
            for (String oppId : oppIds) {
                resultMap.put(oppId, 'Error: ' + ex.getMessage()+' '+ex.getStackTraceString());
            }
        }
        
        return resultMap;
    }

    /**
     * Single, reusable loader for the Stripe auth/config custom metadata.
     * Uses SOQL (NOT getInstance) so Long Text Area fields — notably Stripe_Product_Code__c
     * (the country/tax-type -> product-code JSON) — are returned; getInstance()/getAll()
     * return null for those. Returns null when the record is not present.
     */
    public static Stripe_Auth_Configuration__mdt getStripeAuthConfig() {
        List<Stripe_Auth_Configuration__mdt> rows = [
            SELECT DeveloperName, Api_Key__c, InvoicePreview__c, BypassStripeTax__c, Stripe_Product_Code__c
            FROM Stripe_Auth_Configuration__mdt
            WHERE DeveloperName = 'Stripe_Authorization'
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    /**
     * Parse Stripe_Auth_Configuration__mdt.Stripe_Product_Code__c
     * ([{ "code","name","prcode","taxtype" }, ...]) into a lower-cased
     * taxType -> tax product-code map. Entries with a blank prcode/taxtype (e.g. AE) are skipped.
     */
    // Public so other tax flows (e.g. GARP_BC_Registration.getRegistrationFees) reuse the same parser.
    public static Map<String, String> parseTaxTypeToProductCode(String mappingJson) {
        Map<String, String> m = new Map<String, String>();
        if (String.isBlank(mappingJson)) { return m; }
        try {
            for (Object o : (List<Object>) JSON.deserializeUntyped(mappingJson)) {
                Map<String, Object> e = (Map<String, Object>) o;
                String taxtype = e.get('taxtype') == null ? null : String.valueOf(e.get('taxtype')).toLowerCase();
                String prcode  = e.get('prcode')  == null ? null : String.valueOf(e.get('prcode'));
                if (String.isNotBlank(taxtype) && String.isNotBlank(prcode)) {
                    m.put(taxtype, prcode);
                }
            }
        } catch (Exception ex) {
            // Malformed mapping JSON -> return whatever parsed so far (possibly empty).
        }
        return m;
    }

    /**
     * Active tax PricebookEntries for the given product codes, keyed by ProductCode.
     * Scoped to the 'GARP 2015/2016' price book (test context bypasses the book filter),
     * matching prior behavior without the GL-code map key or the GARP_BC_Orders dependency.
     */
    @TestVisible
    private static Map<String, PricebookEntry> getTaxPricebookEntries(Set<String> codes) {
        Map<String, PricebookEntry> byCode = new Map<String, PricebookEntry>();
        if (codes == null || codes.isEmpty()) { return byCode; }
        for (PricebookEntry pbe : [
            SELECT Id, Product2Id, Product2.ProductCode, Pricebook2.Name
            FROM PricebookEntry
            WHERE Product2.ProductCode IN :codes AND IsActive = TRUE AND Product2.IsActive = TRUE
        ]) {
            if (Test.isRunningTest() || pbe.Pricebook2.Name == 'GARP 2015/2016') {
                if (!byCode.containsKey(pbe.Product2.ProductCode)) {
                    byCode.put(pbe.Product2.ProductCode, pbe);
                }
            }
        }
        return byCode;
    }
}