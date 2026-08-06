public class StripeResponseParser {
    // Wrapper for subscription response
    public class SubscriptionResponse {
        public String id;
        public String customer;
        public String status;
        public List<SubscriptionItem> items = new List<SubscriptionItem>();
        public Map<String, String> metadata;
    }
    
    // Wrapper for each subscription item
    public class SubscriptionItem {
        public String id;
        public String priceId;
        public Integer quantity;
    }
    
    /**
* Parse Stripe subscription JSON response into strongly typed Apex object
*/
    public static SubscriptionResponse parseSubscriptionResponse(String jsonResponse) {
        if (String.isBlank(jsonResponse)) {
            return null;
        }
        
        Map<String, Object> rawMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        SubscriptionResponse resp = new SubscriptionResponse();
        resp.id = (String) rawMap.get('id');
        resp.customer = (String) rawMap.get('customer');
        resp.status = (String) rawMap.get('status');
        //resp.metadata = (Map<String, String>) rawMap.get('metadata');
        
        // Handle items
        Map<String, Object> itemsWrapper = (Map<String, Object>) rawMap.get('items');
        if (itemsWrapper != null && itemsWrapper.containsKey('data')) {
            List<Object> itemsData = (List<Object>) itemsWrapper.get('data');
            for (Object obj : itemsData) {
                Map<String, Object> itemMap = (Map<String, Object>) obj;
                SubscriptionItem item = new SubscriptionItem();
                item.id = (String) itemMap.get('id');
                
                if (itemMap.containsKey('price')) {
                    Map<String, Object> priceMap = (Map<String, Object>) itemMap.get('price');
                    item.priceId = (String) priceMap.get('id');
                }
                
                /*item.quantity = itemMap.containsKey('quantity') 
                    ? Integer.valueOf(String.valueOf(itemMap.get('quantity'))) 
                    : null;*/
                
                resp.items.add(item);
            }
        }
        return resp;
    }
}