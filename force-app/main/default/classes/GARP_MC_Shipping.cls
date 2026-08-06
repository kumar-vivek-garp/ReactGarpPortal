public without sharing class GARP_MC_Shipping {

    @AuraEnabled(cacheable = false)
    public static Shipping_Charge__c getShippingRateByProduct(String productCode, String glCode, String countryCode){
        return GARP_MS_Shipping.getShippingRate(productCode, glCode, countryCode);
    }
    
    @AuraEnabled(cacheable = false)
    public static Shipping_Charge__c getShippingRate(String rawJson){
        
        System.debug('rawJson:' + rawJson);
        
        GARP_MS_Shipping.shipOrder shipOrder = (GARP_MS_Shipping.shipOrder)JSON.deserialize(rawJson, GARP_MS_Shipping.shipOrder.class);
        return GARP_MS_Shipping.getShippingRate(shipOrder);
    }
    
}