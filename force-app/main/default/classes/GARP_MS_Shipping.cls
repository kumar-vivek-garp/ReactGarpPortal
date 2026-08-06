public class GARP_MS_Shipping {
    
    // LWC Wrappers
    public class shipOrderCustomer {
        @AuraEnabled Public String contactId {get;set;}
    }
    
    public class shipOrderAddress {
        @AuraEnabled Public String countryCode {get;set;}
    }

    public class shipOrderLineItem {
        @AuraEnabled Public String productCode {get;set;}
        @AuraEnabled Public String glCode {get;set;}
        @AuraEnabled Public Integer quantity {get;set;}
        @AuraEnabled Public Boolean needsShipping {get;set;}
    }
    
    public class shipOrder {
        @AuraEnabled Public shipOrderCustomer customer {get;set;}
        @AuraEnabled Public shipOrderAddress address {get;set;}
        @AuraEnabled Public List<shipOrderLineItem> lineItems {get;set;}
    }
    
    
	// Legacy Methods   
    public static Shipping_Charge__c getShippingRate(String productCode, String glCode, String countryCode){
        return GARP_BC_Shipping.getShippingRate(productCode, glCode, countryCode);
    }

    @RemoteAction
    public static Shipping_Charge__c getShippingRate(GARP_MS_Shipping.shipOrder shipOrder){
        return GARP_BC_Shipping.getShippingRate(shipOrder);
    }

    @RemoteAction
    public static Boolean verifyShippingAddress(String street1, String street2, String city, String stateCode, String postalCode, String countryCode){
        return GARP_BC_Shipping.verifyShippingAddress(street1, street2, city, stateCode, postalCode, countryCode);
    }

    // New Service Methods
    @RemoteAction
    public static GARP_BC_Shipping.retVerifyAddress verifyAddress(GARP_BC_Shipping.verifyAddressInfo verifyAddressInfo) {
        return GARP_BC_Shipping.verifyAddress(verifyAddressInfo);
    }
    
    public GARP_MS_Shipping(sfdcAppRemoter ctrl){} 
}