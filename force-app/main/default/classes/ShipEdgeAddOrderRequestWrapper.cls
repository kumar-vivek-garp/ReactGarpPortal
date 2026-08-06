public class ShipEdgeAddOrderRequestWrapper{
	public String key;	//abc123
	public String warehouse;	//wh0
	public Integer account_id;	//1
	public cls_orders[] orders;
	public class cls_orders {
		public String order_number;	//20
		public String reference_number;	//123
		public String order_comments;	//Comments
		public cls_shipping shipping;
		public cls_customer customer;
		public cls_billing billing;
		public String cod_amount;	//
		public String insurance_amount;	//NO
		public String signature_required;	//NO
		public String residential;	//YES
		public String store_id;	//
		public String release_date;	//
		public cls_items[] items;
	}
	public class cls_shipping {
		public String method;	//DROPSHIP
        public String shipping_charge;
	}
	public class cls_customer {
		public String email;	//test@mail.com
		public String phone;	//123345
		public String first_name;	//Luis1
		public String last_name;	//cust Name
		public String company;	//cust Company
		public String address1;	//123 Campbellton
		public String address2;	//cust Address2
		public String city;	//Montague – PE
		public String state;	//PE
		public String zip;	//C0A 1R0
		public String country;	//Canada
	}
	public class cls_billing {
		public String first_name;	//Bill FName
		public String last_name;	//Bill LName
		public String company;	//Bill Company
		public String address1;	//Bill Address1
		public String address2;	//Bill Address2
		public String city;	//Los angeles
		public String state;	//CA
		public String zip;	//60915
		public String country;	//USA
	}
	public class cls_items {
		public String sku;	//111-01950
		public Integer quantity;	//1
		public String sold_price;	//2.2200
		public String description;	//sell by user example
	}
	public static string parse(ShipEdgeAddOrderRequestWrapper request){
		return JSON.serialize(request);
	}
}