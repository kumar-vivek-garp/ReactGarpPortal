public class ShipEdgeGetOrderResponseWrapper{
	public String status;	//successful
	public String total_orders;	//109
	public Integer total_pages;	//5
	public order order;
    class order {
        public List<cls_order> orders;
    }
    class cls_order {
		public String order_id;	//1
		public String order_number;	//1
		public String reference_number;
        
        public String date_x;	//2019-10-18 00:00:00
		public cls_status status;
		public String pending_date;	//2019-10-18 15:58:03
		public String shipping_date;	//2019-10-18 16:50:07
		public String last_update;	//2019-10-21 14:04:53
		public String order_comments;	//
		public cls_customer customer;
		public cls_billing billing;
		public cls_shipping shipping;
		public cls_items[] items;
		public cls_attributes[] attributes;
		public cls_account account;
	}
	class cls_status {
		public String id;	//9
		public String description;	//shipped
	}
	class cls_customer {
		public String first_name;	//bruce
		public String last_name;	//wayne
		public String address1;	//464 South Alston Avenue
		public String address2;	//#120
		public String email;	//email@email.com
		public String phone;	//9540001122
		public String city;	//Durham
		public String state;	//NC
		public String zip;	//27713
		public String country;	//United States
	}
	class cls_billing {
		public String first_name;	//bruce
		public String last_name;	//wayne
		public String address1;	//464 South Alston Avenue
		public String address2;	//#120
		public String city;	//Durham
		public String state;	//NC
		public String zip;	//27713
		public String country;	//United States
	}
	class cls_shipping {
		public String method;	//FCD
		public String description;	//USPS First Class Mail (2-6)
		public String tracking_number;	//1234567
	}
	class cls_items {
		public String item_id;	//1
		public String sku;	//S00063
		public String quantity;	//1
		public String sold_price;	//0.00
		public String description;	//
		public cls_attributes[] attributes;
		public cls_product product;
	}
	class cls_attributes {
		public String id;	//3571
		public String attributte_name;	//attr1
		public String attribute_value;	//11
		public String description;	//desc
	}
	class cls_product {
		public String product_id;	//1
		public String account_id;	//1
		public String sku;	//S00063
		public string upc;
		public String description;	//test
		public String harmonization_code;	//
		public String quantity_in_warehouse;	//69
		public String quantity_available;	//74
		public String quantity_hurt;	//0
		public String quantity_shipped;	//24
		public String cost;	//4.00
		public String retail;	//5.00
		public String discontinued;	//N
		public date discontinued_date;
		public String created_date;	//2018-09-04 20:58:47
		public String updated_date;	//2019-10-22 17:00:19
		public String weight;	//0.3000
		public String width;	//0.400
		public String height;	//0.300
		public String length;	//0.200
		public cls_distribution_center distribution_center;
		public cls_supplier supplier;
		public cls_package_type package_type;
		public cls_attributes[] attributes;
	}
	class cls_distribution_center {
		public String id;	//1
		public String name;	//WH0
	}
	class cls_supplier {
		public string id;
		public string name;
	}
	class cls_package_type {
		public string id;
		public string name;
	}
	class cls_account {
		public String account_id;	//1
		public String account_name;	//shipedge
		public String company_name;	//shipedge
		public String contact_name;	//Peter Parker
		public String address1;	//106 Capitola Dr
		public string address2;
		public String city;	//Durham
		public String state;	//NC
		public String postal_code;	//27713
		public String country;	//USA
		public String phone;	//9192930940
		public String email;	//integrations@shipedge.com
		public String activated;	//true
		public cls_attributes[] attributes;
	}
	public static ShipEdgeGetOrderResponseWrapper parse(String json){
		return (ShipEdgeGetOrderResponseWrapper) System.JSON.deserialize(json, ShipEdgeGetOrderResponseWrapper.class);
	}

}