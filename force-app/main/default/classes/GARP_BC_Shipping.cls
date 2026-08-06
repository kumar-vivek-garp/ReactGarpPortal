public class GARP_BC_Shipping {

    // New Wrappers
    public class verifyAddressInfo {
        public Boolean hasShipping;
        public Boolean billingSameAsShipping;
        public GARP_Common.address billingAddress;
        public GARP_Common.address shippingAddress;
        //public List<GARP_BC_Orders.productInfo> selectedProducts;
    }
    
    public class retVerifyAddress {
        public Boolean isBillingAddressValid;
        public String billingAddressErrors;
        public Boolean isShippingAddressValid;
        public String shippingAddressErrors;      
        public Decimal shippingAmount;          
        public Boolean isBillingAllowed;
        public Boolean isShippingAllowed; 
        public Boolean isCreditCardAllowed;
        public Boolean isWireAllowed;
        public Boolean isCheckAllowed;
        public Boolean postalCodeBillingRequired;
        public Boolean provinceBillingRequired;                
        public Boolean postalCodeShippingRequired;
        public Boolean provinceShippingRequired;                
    }
    
    // Legacy
    public static Boolean verifyShippingAddress(String street1, String street2, String city, String stateCode, String postalCode, String countryCode){
        
        if(countryCode != 'US') {
            return True;
        }
        
        UpsXmlAddressValidationResponse addressValidationResponse = 
            new UpsXmlAddressValidationRequest(street1, street2, city, stateCode, postalCode, countryCode).fetch();
        
        System.debug('addressValidationResponse.response:' + addressValidationResponse.response);
        System.debug('addressValidationResponse.addressKeyFormats size:' + addressValidationResponse.addressKeyFormats.size());        
        System.debug('addressValidationResponse.addressKeyFormats:' + addressValidationResponse.addressKeyFormats);        
        
        if(addressValidationResponse.response.errorCode == '264002' || addressValidationResponse.addressKeyFormats.isEmpty()) {
            System.debug('Invalid1');
            return False;
        } else if(!addressValidationResponse.addressKeyFormats.isEmpty() && addressValidationResponse.addressKeyFormats.size() > 1) {
            System.debug('Invalid2');
            return False;            
        } else {
            if(addressValidationResponse.addressKeyFormats[0].postcodePrimaryLow != postalCode) {
                System.debug('Invalid3');    
                return False;                            
            }    
        }
        
        return True;
    }
    
    public static Shipping_Charge__c getShippingRate(String productCode, String glCode, String countryCode){
        Shipping_Charge__c ret;
        
        if(countryCode != NULL && glCode != NULL && countryCode.length() > 0 && glCode.length() > 0) {
            List<Shipping_Charge__c> lstShip = [select id, Shipping_Charge__c from Shipping_Charge__c where Product_Code__c = :productCode AND GL_Code__c = :glCode AND Country_Code__r.LetterCode__c = :countryCode];
            if(!lstShip.isEmpty()) {
                ret = lstShip[0];
            }
        }
        return ret;
    }
    
    public static Shipping_Charge__c getShippingRate(GARP_MS_Shipping.shipOrder shipOrder){
        Shipping_Charge__c ret;
        
        
        if(shipOrder == NULL || shipOrder.lineItems == NULL || shipOrder.address == NULL || shipOrder.address.countrycode == NULL) {
            return ret;
        }

        System.debug('shipOrder:' + shipOrder);

        
        Set<String> prodCodes = new Set<String>();
        Set<String> glCodes = new Set<String>();
        
        Integer totalQuantity = 0;
        for(GARP_MS_Shipping.shipOrderLineItem lineItem :shipOrder.lineItems) {
            prodCodes.add(lineItem.productCode);
            glCodes.add(lineItem.glCode);
        }
        
        System.debug('prodCodes:' + prodCodes);
        System.debug('glCodes:' + glCodes);
        
        if(prodCodes.size() > 0) {
            GARP_MS_Shipping.shipOrderLineItem lineItem = shipOrder.lineItems[0];

            List<Shipping_Charge__c> lstShip = [select id, Shipping_Charge__c, Product_Code__c, GL_Code__c 
                                                from Shipping_Charge__c 
                                                where 
                                                Product_Code__c <> NULL AND
                                                GL_Code__c <> NULL AND
                                                Country_Code__r.LetterCode__c <> NULL AND
                                                Product_Code__c in :prodCodes AND 
                                                GL_Code__c in :glCodes AND 
                                                Country_Code__r.LetterCode__c = :shipOrder.address.countrycode];
            System.debug('lstShip:' + lstShip);
            MAP<String,Shipping_Charge__c> mapShipCharges = new MAP<String,Shipping_Charge__c>();
                        
            if(!lstShip.isEmpty()) {

                for(Shipping_Charge__c sc :lstShip) {
                    mapShipCharges.put(sc.Product_Code__c + '~' + sc.GL_Code__c,sc);
                }
                
                for(GARP_MS_Shipping.shipOrderLineItem li :shipOrder.lineItems) {
                    Shipping_Charge__c fndShipCharge = mapShipCharges.get(li.productCode + '~' + li.glCode);
                    if(fndShipCharge != NULL) {
                        totalQuantity += li.quantity;                    
                    }
                }
                
                if(totalQuantity > 1) {
                    if(shipOrder.address.countrycode == 'US') {
                        ret = new Shipping_Charge__c(
                            Shipping_Charge__c = 70
                        );                        
                        
                    } else {
                        ret = new Shipping_Charge__c(
                            Shipping_Charge__c = 165
                        );                        
                    }
                } else {
                    ret = lstShip[0];    
                }
            }
        }
        
        return ret;
    }
    
    public static List<OpportunityLineItem> stageShippingOpportunityLineItems(GARP_MS_Shipping.shipOrder shipOrder){
        
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        Integer numberOfShippableProducts = 0;
        Decimal totalShippingCost = 0;
        
        Set<String> prodCodes = new Set<String>();
        Set<String> glCodes = new Set<String>();
        
        Integer totalQuantity = 0;
        for(GARP_MS_Shipping.shipOrderLineItem lineItem :shipOrder.lineItems) {
            prodCodes.add(lineItem.productCode);
            glCodes.add(lineItem.glCode);
        }
        
        System.debug('prodCodes:' + prodCodes);
        System.debug('glCodes:' + glCodes);
        
        Set<String> shippableProductIds = new Set<String>();
        for(PricebookEntry pbe: [
            SELECT Id, Product2.Id, Product2.Weight__c, Product2.Taxable__c, Product2.ProductCode, Product2.GL_Code__c
            FROM PricebookEntry 
            WHERE Product2.ProductCode in :prodCodes AND Product2.GL_Code__c in :glCodes AND
            IsActive = TRUE AND Pricebook2.IsActive = TRUE AND Product2.IsActive = TRUE
        ]){
            if(pbe.Product2.Weight__c != null && pbe.Product2.Weight__c > 0){
                shippableProductIds.add(pbe.Product2.Id);
            }
        } 
        numberOfShippableProducts = shippableProductIds.size();
        
        system.debug('numberOfShippableProducts:' + shippableProductIds);
        
        Shipping_Charge__c fndShipRate = GARP_MS_Shipping.getShippingRate(shipOrder);
        system.debug('fndShipRate:' + fndShipRate);
        
        if(fndShipRate != NULL) {
            
            totalShippingCost = fndShipRate.Shipping_Charge__c;
                        
            // --- New logic for Sage
            List<PricebookEntry> pbeShip = [
                SELECT Id, UnitPrice, ProductCode, Product2Id, Product2.Name, Product2.Weight__c, Product2.Taxable__c, Product2.Product_ID__c, Pricebook2Id
                FROM PricebookEntry 
                WHERE IsActive = TRUE AND Pricebook2.IsActive = TRUE AND Product2.IsActive = TRUE AND 
                ProductCode in ('SHIPFRM1','SHIPFRM2','SHIPSCR','SHIPRAIJ','SHIPFRR','SHIPFFR')
            ];
            system.debug('pbeShip:' + pbeShip);
            
            if(!pbeShip.isEmpty()) {
                MAP<String,PricebookEntry> mapShipPrices = new MAP<String,PricebookEntry>();
                for(PricebookEntry pbes :pbeShip) {
                    mapShipPrices.put(pbes.ProductCode, pbes);
                }
                system.debug('mapShipPrices:' + mapShipPrices);
                
                for(GARP_MS_Shipping.shipOrderLineItem li :shipOrder.lineItems) {
                    
                    system.debug('li:' + li);
                    
                    if(li.productCode == 'FRM1H') {
                        
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPFRM1');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1
                            );
                            system.debug('oli:' + oli);
                            oppLineItems.add(oli);
                        }
                    } else if(li.productCode == 'FRM2H') {
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPFRM2');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1
                            );
                            oppLineItems.add(oli);
                        }
                    } else if(li.productCode == 'SCRH') {
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPSCR');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1
                            );
                            oppLineItems.add(oli);
                        }
                    } else if(li.productCode == 'RAIJH' || li.productCode == 'RAIJHC') {
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPRAIJ');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1
                            );
                            system.debug('oli:' + oli);
                            oppLineItems.add(oli);
                        }
                    } else if(li.productCode == 'CBRHB') {
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPFRR');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1
                            );
                            oppLineItems.add(oli);
                        }
                    } else if(li.productCode == 'FBRHB') {
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPFFR');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1
                            );
                            oppLineItems.add(oli);
                        }
                    }
                }
            }   
        }
        system.debug('oppLineItems:' + oppLineItems);
        return oppLineItems;
    }
    
    // AG 1/3/3033 - Validate Address and return Shipping Fee
    public static retVerifyAddress verifyAddress(verifyAddressInfo verifyAddressInfo) {
        
        GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','verifyAddressInfo',verifyAddressInfo);
        
        retVerifyAddress ret = new retVerifyAddress();
        ret.isBillingAddressValid = true;
        ret.isBillingAllowed = true;
        ret.isShippingAddressValid= true;
        ret.isShippingAllowed = true;
        ret.billingAddressErrors = '';
        ret.shippingAddressErrors= '';        
        
        Integer SIZE_ADDRESS_LINE_MAX = 32;
        
        // Step 1 - Verify Address Input
        if(verifyAddressInfo == NULL || verifyAddressInfo.billingAddress == NULL) {
            ret.isBillingAddressValid = false;
            ret.billingAddressErrors = 'Billing Address is missing';
        }
        if(verifyAddressInfo.hasShipping == NULL || (verifyAddressInfo.hasShipping && verifyAddressInfo.billingSameAsShipping == False && verifyAddressInfo.shippingAddress == NULL)) {
            ret.isShippingAddressValid = false;
            ret.shippingAddressErrors= 'Shipping Address is missing';        
        }
        
        GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','isBillingAddressValid',ret.billingAddressErrors);
        GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','isShippingAddressValid',ret.shippingAddressErrors);
                
        Country_Code__c fndBillingCountry;
        MAP<String, Country_Code__c> mapCC = getCountryCodesMap();
        if(ret.isBillingAddressValid && ret.isShippingAddressValid) {
            
            GARP_StripeClass.retSetupStripe stripeInitInfo = GARP_StripeClass.isStripeEnabled();
            
            if(verifyAddressInfo.billingAddress.country != NULL) {
        
                fndBillingCountry = mapCC.get(verifyAddressInfo.billingAddress.country);
                GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','fndBillingCountry',fndBillingCountry);
                
                if(fndBillingCountry != NULL) {
                    ret.isBillingAllowed = fndBillingCountry.Is_Billing_Allowed__c;
                    ret.isCreditCardAllowed = fndBillingCountry.Is_Credit_Card_Allowed__c;
                    ret.isWireAllowed = fndBillingCountry.Is_Wire_Allowed__c;
                    ret.isCheckAllowed = fndBillingCountry.Is_Check_Allowed__c;
                    ret.postalCodeBillingRequired = fndBillingCountry.Postal_Code_Required__c;
                    ret.provinceBillingRequired = fndBillingCountry.Provence_Required__c;
                }
            }
            
            if(String.IsEmpty(verifyAddressInfo.billingAddress.country)) {
                ret.isBillingAddressValid = false;
                ret.billingAddressErrors = 'Billing country is missing';
            }
            if(verifyAddressInfo.hasShipping && verifyAddressInfo.billingSameAsShipping == False && String.IsEmpty(verifyAddressInfo.shippingAddress.country)) {
                ret.isShippingAddressValid = false;
                ret.shippingAddressErrors= 'Shipping country is missing';        
            }
            
            GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','isBillingAddressValid',ret.billingAddressErrors);
            GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','isShippingAddressValid',ret.shippingAddressErrors);
                        
            if(ret.isBillingAddressValid && ret.isShippingAddressValid && !stripeInitInfo.useStripeTax) {
            
                if(fndBillingCountry != NULL) {
                   
                    if(String.IsEmpty(verifyAddressInfo.billingAddress.street1)) {
                        ret.isBillingAddressValid = false;
                        ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing street is missing');
                    } else {
                        if(GARP_Common.hasNonWesternChars(verifyAddressInfo.billingAddress.street1)) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing street has non-western characters');
                        } else if(verifyAddressInfo.billingAddress.street1.length() > SIZE_ADDRESS_LINE_MAX) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing street is greater than ' + SIZE_ADDRESS_LINE_MAX + ' charachters');
                        }
                    }
                    
                    GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','billingAddressErrors1',ret.billingAddressErrors);
                    
                    if(!String.IsEmpty(verifyAddressInfo.billingAddress.street2)) {
                        if(GARP_Common.hasNonWesternChars(verifyAddressInfo.billingAddress.street2)) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing street 2 has non-western characters');
                        } else if(verifyAddressInfo.billingAddress.street2.length() > SIZE_ADDRESS_LINE_MAX) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing street 2 is greater than ' + SIZE_ADDRESS_LINE_MAX + ' charachters');
                        } else if(verifyAddressInfo.billingAddress.street2 == verifyAddressInfo.billingAddress.street1) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing street 2 is the same as street1');
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','billingAddressErrors2',ret.billingAddressErrors);
                    
                    if(!String.IsEmpty(verifyAddressInfo.billingAddress.street3)) {
                        if(GARP_Common.hasNonWesternChars(verifyAddressInfo.billingAddress.street3)) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing street 3 has non-western characters');
                        } else if(verifyAddressInfo.billingAddress.street3.length() > SIZE_ADDRESS_LINE_MAX) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing street 3 is greater than ' + SIZE_ADDRESS_LINE_MAX + ' charachters');
                        } else if(verifyAddressInfo.billingAddress.street3 == verifyAddressInfo.billingAddress.street1) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing street 3 is the same as street1');
                        } else if(verifyAddressInfo.billingAddress.street3 == verifyAddressInfo.billingAddress.street2) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing street 3 is the same as street 2');
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','billingAddressErrors3',ret.billingAddressErrors);
                    
                    if(String.IsEmpty(verifyAddressInfo.billingAddress.city)) {
                        ret.isBillingAddressValid = false;
                        ret.billingAddressErrors += GARP_Common.addError(ret.billingAddressErrors, 'Billing city is missing');
                    } else {
                        if(GARP_Common.hasNonWesternChars(verifyAddressInfo.billingAddress.city)) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing city has non-western characters');
                        } else if(verifyAddressInfo.billingAddress.city.length() > SIZE_ADDRESS_LINE_MAX) {
                            ret.isBillingAddressValid = false;
                            ret.billingAddressErrors = GARP_Common.addError(ret.billingAddressErrors, 'Billing city is greater than ' + SIZE_ADDRESS_LINE_MAX + ' charachters');
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','billingAddressErrors4',ret.billingAddressErrors);
                    
                    if(fndBillingCountry.Postal_Code_Required__c && String.IsEmpty(verifyAddressInfo.billingAddress.postalCode)) {
                        ret.isBillingAddressValid = false;
                        ret.billingAddressErrors += GARP_Common.addError(ret.billingAddressErrors, 'Billing postal code is missing');
                    }
                    if(fndBillingCountry.Provence_Required__c && String.IsEmpty(verifyAddressInfo.billingAddress.province)) {
                        ret.isBillingAddressValid = false;
                        ret.billingAddressErrors += GARP_Common.addError(ret.billingAddressErrors, 'Billing province is missing');
                    }
                    GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','billingAddressErrors5',ret.billingAddressErrors);
                    
                } else {
                    ret.isBillingAddressValid = false;
                    ret.billingAddressErrors = 'Billing country not found';
                }
                    
                GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','isBillingAddressValid',ret.billingAddressErrors);
                GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','isShippingAddressValid',ret.shippingAddressErrors);
                    
                // Verify Seperate Shipping Address
                if(verifyAddressInfo.hasShipping && verifyAddressInfo.billingSameAsShipping == False) {
                    
                    Country_Code__c fndShippingCountry = mapCC.get(verifyAddressInfo.shippingAddress.country);
                    GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','fndShippingCountry',fndShippingCountry);
                    
                    if(fndShippingCountry != NULL) {
                        
                        ret.postalCodeShippingRequired = fndShippingCountry.Postal_Code_Required__c;
                        ret.provinceShippingRequired = fndShippingCountry.Provence_Required__c;
                        
                        if(String.IsEmpty(verifyAddressInfo.shippingAddress.street1)) {
                            ret.isShippingAddressValid = false;
                            ret.shippingAddressErrors = GARP_Common.addError(ret.shippingAddressErrors, 'Billing street is missing');
                        }
                        if(String.IsEmpty(verifyAddressInfo.shippingAddress.city)) {
                            ret.isShippingAddressValid = false;
                            ret.shippingAddressErrors += GARP_Common.addError(ret.shippingAddressErrors, 'Billing street is missing');
                        }
                        if(fndShippingCountry.Postal_Code_Required__c && String.IsEmpty(verifyAddressInfo.shippingAddress.postalCode)) {
                            ret.isShippingAddressValid = false;
                            ret.shippingAddressErrors += GARP_Common.addError(ret.shippingAddressErrors, 'Billing postal code is missing');
                        }
                        if(fndShippingCountry.Provence_Required__c && String.IsEmpty(verifyAddressInfo.shippingAddress.province)) {
                            ret.isShippingAddressValid = false;
                            ret.shippingAddressErrors += GARP_Common.addError(ret.shippingAddressErrors, 'province is missing');
                        }
                        GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','shippingAddressErrors',ret.shippingAddressErrors);
                        
                    } else {
                        ret.isShippingAddressValid = false;
                        ret.shippingAddressErrors = 'Shipping country not found';
                    }
                }
                
                GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','isBillingAddressValid',ret.billingAddressErrors);
                GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','isShippingAddressValid',ret.shippingAddressErrors);
                
                // Step 2 - UPS Verify Shipping Address
                if((verifyAddressInfo.hasShipping && ret.isBillingAddressValid) || (!verifyAddressInfo.hasShipping && ret.isShippingAddressValid)) {
                    
                    GARP_Common.address verifyShippingAddress = verifyAddressInfo.billingAddress;
                    if(verifyAddressInfo.billingSameAsShipping == False) {
                        verifyShippingAddress = verifyAddressInfo.shippingAddress;
                    }
                    
                    GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','verifyShippingAddress',verifyShippingAddress);
                    
                    // If US & Canada verify address with UPS
                    Country_Code__c fndShippingCountry = mapCC.get(verifyShippingAddress.country);
                    GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','fndShippingCountry',fndShippingCountry);
                    
                    if(fndShippingCountry != NULL) {
                        
                        ret.isShippingAllowed = fndShippingCountry.Is_Shipping_Allowed__c;
                        
                        GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','isShippingAllowed',ret.isShippingAllowed);
                        GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','LetterCode__c',fndShippingCountry.LetterCode__c);
                        
                        if(fndShippingCountry.LetterCode__c == 'US' || fndShippingCountry.LetterCode__c == 'CA') {
                            
                            MAP<String,String> stateCodes = new MAP<String,String>();
                            for(Province__c p :fndShippingCountry.Provinces__r) {
                                stateCodes.put(p.name, p.code__c);
                            }
                            GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','stateCodes',stateCodes);
                            
                            String stateCode = stateCodes.get(verifyShippingAddress.province);
                            GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','stateCode',stateCode);
                            
                            if(stateCode != NULL) {
                                /*
                                UpsXmlAddressValidationResponse addressValidationResponse = 
                                    new UpsXmlAddressValidationRequest(verifyShippingAddress.street1, verifyShippingAddress.street2, 
                                                                       verifyShippingAddress.city, stateCode, 
                                                                       verifyShippingAddress.postalCode, fndShippingCountry.LetterCode__c).fetch();
                                
                                GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','addressValidationResponse.response',addressValidationResponse.response);
                                
                                if(addressValidationResponse.response.errorCode == '264002' || addressValidationResponse.addressKeyFormats.isEmpty()) {
                                    ret.isShippingAddressValid = false;
                                    ret.shippingAddressErrors = 'UPS could not validate this address';
                                } else if(!addressValidationResponse.addressKeyFormats.isEmpty() && addressValidationResponse.addressKeyFormats.size() > 1) {
                                    ret.isShippingAddressValid = false;
                                    ret.shippingAddressErrors = 'UPS could not validate this address';         
                                } else {
                                    if(addressValidationResponse.addressKeyFormats[0].postcodePrimaryLow != verifyAddressInfo.shippingAddress.postalCode) {
                                        ret.isShippingAddressValid = false;
                                        ret.shippingAddressErrors = 'UPS could not validate this address';                          
                                    }    
                                }
                                GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','shippingAddressErrors',ret.shippingAddressErrors);
                                */
                                // TODO-- Validation not withing in DEV!!
                                ret.isShippingAddressValid = true;
                            }
                        }
                    }
                    
                    GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','shippingAddressErrors',ret.shippingAddressErrors);
                    
                    /*
                    GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','selectedProducts',verifyAddressInfo.selectedProducts);
                                        
                    // Get Shipping Amount
                    if(ret.isShippingAddressValid && !verifyAddressInfo.selectedProducts.IsEmpty()) {
                        
                        // Setup shipping order
                        GARP_MS_Shipping.shipOrder shipOrder = new GARP_MS_Shipping.shipOrder();                        
                        shipOrder.address = new GARP_MS_Shipping.shipOrderAddress();
                        shipOrder.address.countrycode = fndShippingCountry.LetterCode__c;
                        shipOrder.lineItems = new List<GARP_MS_Shipping.shipOrderLineItem>();
                        for(GARP_BC_Orders.productInfo pi :verifyAddressInfo.selectedProducts) {
                            if(pi.needsShipping != NULL && pi.needsShipping) {
                                GARP_MS_Shipping.shipOrderLineItem ssLi = new GARP_MS_Shipping.shipOrderLineItem();
                                ssLi.productCode = pi.productCode;
                                ssLi.glCode =  pi.gLCode;
                                ssLi.quantity = pi.quantity;
                                ssLi.needsShipping = True;
                                shipOrder.lineItems.add(ssLi);
                            }
                        }
                        
                        GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','shipOrder',shipOrder);
                        
                        Shipping_Charge__c shippingCharge = getShippingRate(shipOrder);
                        GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','shippingCharge',shippingCharge);
                        
                        if(shippingCharge != NULL) {
                            ret.shippingAmount = shippingCharge.Shipping_Charge__c;
                        }
                        GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','shippingAmount',ret.shippingAmount);
                    }
                    */
                }
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Shipping','verifyAddress','Final ret',ret);
        return ret;
    }
    
    public static MAP<String, Country_Code__c> getCountryCodesMap() {
        List<Country_Code__c> countryCodes = [select Id, Name, Country__c, LetterCode__c, Is_Billing_Allowed__c, 
                                       Is_Shipping_Allowed__c, Is_Credit_Card_Allowed__c, PhoneCode__c, 
                                       VAT__c, VAT_Product_Code__c, ISOCode__c, Compliance__c,
                                       Is_Wire_Allowed__c, Is_Check_Allowed__c, Is_ACH_Allowed__c, Postal_Code_Required__c, 
                                       Provence_Required__c, (select id, name, code__c from Provinces__r Order by Name)
                                       from Country_Code__c];
        GARP_Common.debugLog('GARP_BC_Shipping','getCountryCodesMap','countryCodes',countryCodes);
        
        MAP<String, Country_Code__c> mapCC = new MAP<String, Country_Code__c>();
        for(Country_Code__c cc :countryCodes) {
            mapCC.put(cc.Country__c, cc);
        }
        GARP_Common.debugLog('GARP_BC_Shipping','getCountryCodesMap','countryCodes',countryCodes);
        
        return mapCC;
    }
    
    public static Shipping_Charge__c getShippingRate(GARP_Common.address shippingAddress, List<GARP_BC_Orders.productInfo> selectedProducts, MAP<String, Country_Code__c> mapCC) {
        Shipping_Charge__c shippingCharge;
        
        GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','shippingAddress',shippingAddress);
        GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','selectedProducts',selectedProducts);
        GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','mapCC',mapCC);
                
        Country_Code__c fndShippingCountry = mapCC.get(shippingAddress.country);
        GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','fndShippingCountry',fndShippingCountry);
        
        if(fndShippingCountry != NULL) {
            GARP_MS_Shipping.shipOrder shipOrder = new GARP_MS_Shipping.shipOrder();
            shipOrder.address = new GARP_MS_Shipping.shipOrderAddress();
            shipOrder.address.countrycode = fndShippingCountry.LetterCode__c;
            shipOrder.lineItems = new List<GARP_MS_Shipping.shipOrderLineItem>();
            for(GARP_BC_Orders.productInfo pi :selectedProducts) {
                if(pi.needsShipping != NULL && pi.needsShipping) {
                    GARP_MS_Shipping.shipOrderLineItem ssLi = new GARP_MS_Shipping.shipOrderLineItem();
                    ssLi.productCode = pi.productCode;
                    ssLi.glCode =  pi.gLCode;
                    ssLi.quantity = pi.quantity;
                    ssLi.needsShipping = True;
                    shipOrder.lineItems.add(ssLi);
                }
            }
            
            GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','shipOrder',shipOrder);
            shippingCharge = getShippingRate(shipOrder);
            
            GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','shippingCharge',shippingCharge);
        }
        return shippingCharge;
    }
    
    // bookType = [FRM1,FRM2,SCR,FFR,RAI,RAIJ]
    public static Decimal getBulkShippingRate(String country, String bookType, Integer quantity, MAP<String,Country_Code__c> mapCC) {
        
        GARP_Common.debugLog('GARP_BC_Shipping','getBulkShippingRate','country',country);
        GARP_Common.debugLog('GARP_BC_Shipping','getBulkShippingRate','bookType',bookType);
        GARP_Common.debugLog('GARP_BC_Shipping','getBulkShippingRate','quantity',quantity);
        GARP_Common.debugLog('GARP_BC_Shipping','getBulkShippingRate','mapCC',mapCC);
        
        
        if(quantity < 1 || quantity > 5) {
            return 0;
        }
        
        if(bookType != 'FRM1' && bookType != 'FRM2' && bookType != 'SCR' && bookType != 'FRR' && bookType != 'RAI' && bookType != 'RAIJ') {
            return 0;
        }
       
        
        MAP<String,Decimal> mapRates = new MAP<String,Decimal>();
        /* mapRates.put('FRM1:Europe:1',113.00);
        mapRates.put('FRM2:Europe:1',126.00);
        mapRates.put('SCR:Europe:1',47.00);  
        mapRates.put('RAI:Europe:1',79.00);
        mapRates.put('RAIJ:Europe:1',79.00);
        mapRates.put('FRR:Europe:1',130.00);                
        mapRates.put('FRM1:NorthAmerica:1',49.00);
        mapRates.put('FRM2:NorthAmerica:1',59.00);
        mapRates.put('SCR:NorthAmerica:1',35.50); 
        mapRates.put('RAI:NorthAmerica:1',55.50); 
        mapRates.put('RAIJ:NorthAmerica:1',55.50);
        mapRates.put('FRR:NorthAmerica:1',57.00);                
        mapRates.put('FRM1:RestWorld:1',129.00);
        mapRates.put('FRM2:RestWorld:1',141.00);
        mapRates.put('SCR:RestWorld:1',55.00);
        mapRates.put('RAI:RestWorld:1',87.00);                
        mapRates.put('RAIJ:RestWorld:1',87.00);
        mapRates.put('FRR:RestWorld:1',149.00);
        
        mapRates.put('FRM1:Europe:2',194.00);
        mapRates.put('FRM2:Europe:2',324.00);
        mapRates.put('SCR:Europe:2',93.00);
        mapRates.put('RAI:Europe:2',93.00); 
        mapRates.put('RAIJ:Europe:2',93.00);
        mapRates.put('FRR:Europe:2',194.00);                
        mapRates.put('FRM1:NorthAmerica:2',93.00);
        mapRates.put('FRM2:NorthAmerica:2',112.00);
        mapRates.put('SCR:NorthAmerica:2',46.00);
        mapRates.put('RAI:NorthAmerica:2',46.00);
        mapRates.put('RAIJ:NorthAmerica:2',46.00);
        mapRates.put('FRR:NorthAmerica:2',93.00);                
        mapRates.put('FRM1:RestWorld:2',241.00);
        mapRates.put('FRM2:RestWorld:2',253.00);
        mapRates.put('SCR:RestWorld:2',128.00);
        mapRates.put('RAI:RestWorld:2',128.00);
        mapRates.put('RAIJ:RestWorld:2',128.00);
        mapRates.put('FRR:RestWorld:2',241.00);                
        
        mapRates.put('FRM1:Europe:3',265.00);
        mapRates.put('FRM2:Europe:3',364.00);
        mapRates.put('SCR:Europe:3',111.00);  
        mapRates.put('RAI:Europe:3',111.00);
        mapRates.put('RAIJ:Europe:3',111.00);
        mapRates.put('FRR:Europe:3',253.00);                
        mapRates.put('FRM1:NorthAmerica:3',114.00);
        mapRates.put('FRM2:NorthAmerica:3',182.00);
        mapRates.put('SCR:NorthAmerica:3',69.00);
        mapRates.put('RAI:NorthAmerica:3',69.00);
        mapRates.put('RAIJ:NorthAmerica:3',69.00);
        mapRates.put('FRR:NorthAmerica:3',114.00);                
        mapRates.put('FRM1:RestWorld:3',359.00);
        mapRates.put('FRM2:RestWorld:3',424.00);
        mapRates.put('SCR:RestWorld:3',147.00);  
        mapRates.put('RAI:RestWorld:3',147.00);
        mapRates.put('RAIJ:RestWorld:3',147.00);
        mapRates.put('FRR:RestWorld:3',305.00);                
        
        mapRates.put('FRM1:Europe:4',406.00);
        mapRates.put('FRM2:Europe:4',406.00);
        mapRates.put('SCR:Europe:4',139.00);
        mapRates.put('RAI:Europe:4',139.00);
        mapRates.put('RAIJ:Europe:4',139.00);
        mapRates.put('FRR:Europe:4',406.00);                
        mapRates.put('FRM1:NorthAmerica:4',160.00);
        mapRates.put('FRM2:NorthAmerica:4',194.00);
        mapRates.put('SCR:NorthAmerica:4',85.00); 
        mapRates.put('RAI:NorthAmerica:4',85.00);
        mapRates.put('RAIJ:NorthAmerica:4',85.00);
        mapRates.put('FRR:NorthAmerica:4',160.00);                
        mapRates.put('FRM1:RestWorld:4',455.00);
        mapRates.put('FRM2:RestWorld:4',455.00);
        mapRates.put('SCR:RestWorld:4',178.00);
        mapRates.put('RAI:RestWorld:4',178.00);
        mapRates.put('RAIJ:RestWorld:4',178.00);
        mapRates.put('FRR:RestWorld:4',455.00);                
        
        mapRates.put('FRM1:Europe:5',465.00);
        mapRates.put('FRM2:Europe:5',488.00);
        mapRates.put('SCR:Europe:5',151.00);
        mapRates.put('RAI:Europe:5',151.00);
        mapRates.put('RAIJ:Europe:5',151.00);
        mapRates.put('FRR:Europe:5',465.00);                
        mapRates.put('FRM1:NorthAmerica:5',187.00);
        mapRates.put('FRM2:NorthAmerica:5',215.00);
        mapRates.put('SCR:NorthAmerica:5',95.00);
        mapRates.put('RAI:NorthAmerica:5',95.00);
        mapRates.put('RAIJ:NorthAmerica:5',95.00);
        mapRates.put('FRR:NorthAmerica:5',187.00);                
        mapRates.put('FRM1:RestWorld:5',508.00);
        mapRates.put('FRM2:RestWorld:5',536.00);
        mapRates.put('SCR:RestWorld:5',194.00);
        mapRates.put('RAI:RestWorld:5',194.00);
        mapRates.put('RAIJ:RestWorld:5',194.00);
        mapRates.put('FRR:RestWorld:5',508.00); 
        */                
        Bulk_Shipping_Price__mdt bsp = [Select Id,Price__c From Bulk_Shipping_Price__mdt Where DeveloperName ='Shipping_Price'];
        // Directly deserialize into Map<String, Decimal>
        Map<String, Decimal> ratesMap =
            (Map<String, Decimal>) JSON.deserialize(
                bsp.Price__c,
                Map<String, Decimal>.class
            );
        
        // Merge into existing map
        mapRates.putAll(ratesMap);
        if(mapCC == NULL) {
            
            List<Country_Code__c> lstCC = [select Id, Country__c, Country_Code_Region__c, Country_Code_Subregion__c from Country_Code__c];
            GARP_Common.debugLog('GARP_BC_Shipping','getBulkShippingRate','lstCC ',lstCC );
            
            mapCC = new MAP<String,Country_Code__c>();
            if(!lstCC.IsEmpty()) {
                for(Country_Code__c cc :lstCC) {
                    mapCC.put(cc.Country__c, cc);
                }
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Shipping','getBulkShippingRate','mapCC',mapCC);
        
        if(mapCC.values().size() > 0) {
            Country_Code__c cc = mapCC.get(country);
            GARP_Common.debugLog('GARP_BC_Shipping','getBulkShippingRate','cc ',cc); 
            if(cc != NULL) {
                String regionKey;
                if(cc.Country_Code_Subregion__c == 'North America') {
                    regionKey = 'NorthAmerica';
                } else if(cc.Country_Code_Region__c == 'Europe') {
                    regionKey = 'Europe';                
                } else {
                    regionKey = 'RestWorld'; 
                }
                GARP_Common.debugLog('GARP_BC_Shipping','getBulkShippingRate','regionKey',regionKey);
                
                String key = bookType + ':' + regionKey + ':' + String.ValueOf(quantity); 
                GARP_Common.debugLog('GARP_BC_Shipping','getBulkShippingRate','key',key);
                
                Decimal rate = mapRates.get(key);
                GARP_Common.debugLog('GARP_BC_Shipping','getBulkShippingRate','rate',rate);
                
                return rate;
            }
        }
        return 0;
    }

    /* NEW VERSION
    public static Shipping_Charge__c getShippingRate(GARP_MS_Shipping.shipOrder shipOrder) {
        Shipping_Charge__c ret;
        
        GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','shipOrder',shipOrder);

        Set<String> prodCodes = new Set<String>();
        Set<String> glCodes = new Set<String>();
        
        Integer totalQuantity = 0;
        Integer cntNeedShipping = 0;
        for(GARP_MS_Shipping.shipOrderLineItem lineItem :shipOrder.lineItems) {
            prodCodes.add(lineItem.productCode);
            glCodes.add(lineItem.glCode);
            if(lineItem.needsShipping != NULL && lineItem.needsShipping == True) {
                cntNeedShipping++;
            }
        }
        GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','cntNeedShipping',cntNeedShipping);
        GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','prodCodes',prodCodes);
        GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','glCodes',glCodes);
                
        Integer cntShipping=0;
        if(prodCodes.size() > 0) {
            GARP_MS_Shipping.shipOrderLineItem lineItem = shipOrder.lineItems[0];

            GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','countrycode',shipOrder.address.countrycode);
            
            List<Shipping_Charge__c> lstShip = [select id, Shipping_Charge__c, Product_Code__c, GL_Code__c from Shipping_Charge__c where Product_Code__c in :prodCodes AND GL_Code__c in :glCodes AND Country_Code__r.LetterCode__c = :shipOrder.address.countrycode];
            GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','lstShip',lstShip);
            
            MAP<String,Shipping_Charge__c> mapShipCharges = new MAP<String,Shipping_Charge__c>();
                        
            if(!lstShip.isEmpty()) {

                for(Shipping_Charge__c sc :lstShip) {
                    mapShipCharges.put(sc.Product_Code__c + '~' + sc.GL_Code__c,sc);
                }
                GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','mapShipCharges',mapShipCharges);
                
                for(GARP_MS_Shipping.shipOrderLineItem li :shipOrder.lineItems) {
                    Shipping_Charge__c fndShipCharge = mapShipCharges.get(li.productCode + '~' + li.glCode);
                    if(fndShipCharge != NULL && li.quantity != NULL) {
                        totalQuantity += li.quantity; 
                        cntShipping++;                   
                    }
                }
                GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','totalQuantity',totalQuantity);
                GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','cntShipping',cntShipping);
                
                if(totalQuantity > 1) {
                    if(shipOrder.address.countrycode == 'US') {
                        ret = new Shipping_Charge__c(
                            Shipping_Charge__c = 70
                        );                        
                        
                    } else {
                        ret = new Shipping_Charge__c(
                            Shipping_Charge__c = 165
                        );                        
                    }
                } else {
                    ret = lstShip[0];    
                }
                GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','ret',ret);
            }
        }
        
        // If the number of products that need shipping
        // does not match the number shipped
        // do not send response, some products cannot be shipped
        GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','cntShipping',cntShipping);
        GARP_Common.debugLog('GARP_BC_Shipping','getShippingRate','cntNeedShipping',cntNeedShipping);
        if(cntShipping != cntNeedShipping) {
            ret=null;
        }
        
        return ret;
    }

public static List<OpportunityLineItem> stageShippingOpportunityLineItems(GARP_MS_Shipping.shipOrder shipOrder){
        
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        Integer numberOfShippableProducts = 0;
        Decimal totalShippingCost = 0;
        
        Set<String> prodCodes = new Set<String>();
        Set<String> glCodes = new Set<String>();
        
        Integer totalQuantity = 0;
        for(GARP_MS_Shipping.shipOrderLineItem lineItem :shipOrder.lineItems) {
            prodCodes.add(lineItem.productCode);
            glCodes.add(lineItem.glCode);
        }
        
        System.debug('prodCodes:' + prodCodes);
        System.debug('glCodes:' + glCodes);
        
        Set<String> shippableProductIds = new Set<String>();
        for(PricebookEntry pbe: [
            SELECT Id, Product2.Id, Product2.Weight__c, Product2.Taxable__c, Product2.ProductCode, Product2.GL_Code__c
            FROM PricebookEntry 
            WHERE Product2.ProductCode in :prodCodes AND Product2.GL_Code__c in :glCodes AND
            IsActive = TRUE AND Pricebook2.IsActive = TRUE AND Product2.IsActive = TRUE
        ]){
            if(pbe.Product2.Weight__c != null && pbe.Product2.Weight__c > 0){
                shippableProductIds.add(pbe.Product2.Id);
            }
        } 
        numberOfShippableProducts = shippableProductIds.size();
        
        system.debug('numberOfShippableProducts:' + shippableProductIds);
        
        Shipping_Charge__c fndShipRate = getShippingRate(shipOrder);
        system.debug('fndShipRate:' + fndShipRate);
        
        if(fndShipRate != NULL) {
            
            totalShippingCost = fndShipRate.Shipping_Charge__c;
                        
            // --- New logic for Sage
            List<PricebookEntry> pbeShip = [
                SELECT Id, UnitPrice, ProductCode, Product2Id, Product2.Name, Product2.Weight__c, Product2.Taxable__c, Product2.Product_ID__c, Pricebook2Id
                FROM PricebookEntry 
                WHERE IsActive = TRUE AND Pricebook2.IsActive = TRUE AND Product2.IsActive = TRUE AND 
                ProductCode in ('SHIPFRM1','SHIPFRM2','SHIPSCR','SHIPRAIJ','SHIPFRR','SHIPFFR')
            ];
            system.debug('pbeShip:' + pbeShip);
            
            if(!pbeShip.isEmpty()) {
                MAP<String,PricebookEntry> mapShipPrices = new MAP<String,PricebookEntry>();
                for(PricebookEntry pbes :pbeShip) {
                    mapShipPrices.put(pbes.ProductCode, pbes);
                }
                system.debug('mapShipPrices:' + mapShipPrices);
                
                for(GARP_MS_Shipping.shipOrderLineItem li :shipOrder.lineItems) {
                    
                    system.debug('li:' + li);
                    
                    if(li.productCode == 'FRM1H') {
                        
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPFRM1');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1,
                                Description         = fndPrice.Product2.Name
                            );
                            system.debug('oli:' + oli);
                            oppLineItems.add(oli);
                        }
                    } else if(li.productCode == 'FRM2H') {
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPFRM2');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1,
                                Description         = fndPrice.Product2.Name
                            );
                            oppLineItems.add(oli);
                        }
                    } else if(li.productCode == 'SCRH') {
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPSCR');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1,
                                Description         = fndPrice.Product2.Name
                            );
                            oppLineItems.add(oli);
                        }
                    } else if(li.productCode == 'RAIJH' || li.productCode == 'RAIJHC') {
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPRAIJ');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1,
                                Description         = fndPrice.Product2.Name
                            );
                            oppLineItems.add(oli);
                        }
                    } else if(li.productCode == 'CBRHI') {
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPFRR');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1,
                                Description         = fndPrice.Product2.Name
                            );
                            oppLineItems.add(oli);
                        }
                    } else if(li.productCode == 'FBRHB') {
                        PricebookEntry fndPrice = mapShipPrices.get('SHIPFFR');
                        if(fndPrice != NULL) {                        
                            OpportunityLineItem oli = new OpportunityLineItem(                               
                                PricebookEntryId    = fndPrice.Id,
                                Product2Id          = fndPrice.Product2Id,
                                UnitPrice           = totalShippingCost / numberOfShippableProducts,
                                Quantity            = 1,
                                Description         = fndPrice.Product2.Name
                            );
                            oppLineItems.add(oli);
                        }
                    }
                }
            }   
        }
        system.debug('oppLineItems:' + oppLineItems);
        return oppLineItems;
    }
    */
}