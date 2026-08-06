public class webHookRequestWrapper{
    public cls_order order;
    public String event;	//orders/shipped_v2
    public String origin;	//shine1
    public class cls_order {
        public String id;	//11937
        public cls_status status;
        public String tracking_number;	//WEBHOOKTEST123
        public String order_number;	//11937
        public String order_reference;	//
        public String carrier_name;	//USPS
        public String shipping_method;	//EUSFCD
        public String order_comments;	//This is a note to my customer.
        public cls_cart cart;
        public cls_customer customer;
        public String insurance;	//NO
        public String residential;	//YES
        public string shipping_charge;
        public cls_order_attributes[] order_attributes;
        public cls_account account;
        public cls_cod cod;
        public cls_items[] items;
    }
    public class cls_status {
        public String id;	//9
        public String description;	//shipped
    }
    public class cls_cart {
        public cls_id id;
        public cls_store_name store_name;
        public cls_cart_name cart_name;
    }
    public class cls_id {
    }
    public class cls_store_name {
    }
    public class cls_cart_name {
    }
    public class cls_customer {
        public String email;	//andrew@shipedge.com
        public String phone;	//+18559020077
        public String firstname;	//Kitten
        public String lastname;	//Fan
        public String company;	//
        public String address1;	//4364 South Alston Ave
        public String address2;	//Suite 120
        public String full_address;	//4364 South Alston Ave Suite 120
        public String city;	//Durham
        public String state;	//NC
        public String zip;	//27713
        public String country;	//US
    }
    public class cls_order_attributes {
        public String attribute;	//subtotal
        public String value;	//9.68
    }
    public class cls_account {
        public String company_name;	//Kittens for Days
        public cls_account_attributes[] account_attributes;
    }
    public class cls_account_attributes {
    }
    public class cls_cod {
        public String value;	//
    }
    public class cls_items {
        public String sku;	//3167551
        public String quantity;	//1
        public String sold_price;	//3.69
        public String lot;	//
        public cls_serials[] serials;
        public cls_item_attributes[] item_attributes;
    }
    class cls_serials {
    }
    public class cls_item_attributes {
    }
    public static webHookRequestWrapper parse(String json){
        return (webHookRequestWrapper) System.JSON.deserialize(json, webHookRequestWrapper.class);
    }
    
    
    public static String testParse() {
		String json = '{\"order\":{\"id\":\"11937\",\"status\":{\"id\":\"9\",\"description\":\"shipped\"},\"tracking_number\":\"WEBHOOKTEST123\",\"order_number\":\"11937\",\"order_reference\":\"\",\"carrier_name\":\"USPS\",\"shipping_method\":\"EUSFCD\",\"order_comments\":\"This is a note to my customer.\",\"cart\":{\"id\":null,\"store_name\":null,\"cart_name\":null},\"customer\":{\"email\":\"andrew@shipedge.com\",\"phone\":\"+18559020077\",\"firstname\":\"Kitten\",\"lastname\":\"Fan\",\"company\":\"\",\"address1\":\"4364 South Alston Ave\",\"address2\":\"Suite 120\",\"full_address\":\"4364 South Alston Ave Suite 120\",\"city\":\"Durham\",\"state\":\"NC\",\"zip\":\"27713\",\"country\":\"US\"},\"insurance\":\"NO\",\"residential\":\"YES\",\"shipping_charge\":null,\"order_attributes\":[{\"attribute\":\"subtotal\",\"value\":\"9.68\"},{\"attribute\":\"total\",\"value\":\"14.68\"},{\"attribute\":\"handling estimate\",\"value\":\"5.00\"},{\"attribute\":\"shipping cost\",\"value\":\"0.00\"},{\"attribute\":\"_return_data_\",\"value\":\"null\"}],\"account\":{\"company_name\":\"Kittens for Days\",\"account_attributes\":[]},\"cod\":{\"value\":\"\"},\"items\":[{\"sku\":\"3167551\",\"quantity\":\"1\",\"sold_price\":\"3.69\",\"lot\":\"\",\"serials\":[],\"item_attributes\":[]},{\"sku\":\"3114062\",\"quantity\":\"1\",\"sold_price\":\"5.99\",\"lot\":\"\",\"serials\":[],\"item_attributes\":[]}]},\"event\":\"orders\\/shipped_v2\",\"origin\":\"shine1\"}';
		
		return json;
	}
}