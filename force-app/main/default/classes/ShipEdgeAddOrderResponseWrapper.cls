public class ShipEdgeAddOrderResponseWrapper{
	public cls_access access;
	public cls_orders orders;
	public class cls_access {
		public String account_id;	//1
		public String access;	//Allow: add_orders
		public String warehouse;	//wh0
		public Integer total_orders;	//2
		public String message;	//All orders in system
		public Integer batch_id;	//1
	}
	public class cls_orders {
		public cls_allow[] allow;
		public cls_denied[] denied;
	}
	public class cls_allow {
		public String order_number;	//20
		public String OrderID;	//1
	}
	public class cls_denied {
		public String order_number;	//21
		public String CommentAPI;	//Check Field:SKU
		public String OrderID;	//false
	}
	public static ShipEdgeAddOrderResponseWrapper parse(String json){
		return (ShipEdgeAddOrderResponseWrapper) System.JSON.deserialize(json, ShipEdgeAddOrderResponseWrapper.class);
	}
}