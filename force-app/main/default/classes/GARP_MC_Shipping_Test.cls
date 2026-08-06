@isTest
public class GARP_MC_Shipping_Test {
	@isTest
    static void unitTest(){
        
        GARP_MS_Shipping.shipOrderCustomer cust = new GARP_MS_Shipping.shipOrderCustomer();
        cust.contactId = 'Test';
        
        GARP_MS_Shipping.shipOrderAddress addr = new GARP_MS_Shipping.shipOrderAddress();
        addr.countryCode = 'US';
        
        GARP_MS_Shipping.shipOrderLineItem item = new GARP_MS_Shipping.shipOrderLineItem();
        item.glCode = 'Test';
        item.productCode = 'Test';
        
        GARP_MS_Shipping.shipOrder order = new GARP_MS_Shipping.shipOrder();
        order.customer = cust;
        order.lineItems = new List<GARP_MS_Shipping.shipOrderLineItem>{item};
        order.address = addr;
        
        string req = json.serialize(order);
        test.startTest();
        GARP_MC_Shipping.getShippingRateByProduct('Test','Test','Test');
        GARP_MC_Shipping.getShippingRate(req);
        test.stopTest();
    }
}