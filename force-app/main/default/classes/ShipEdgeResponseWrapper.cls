/*
 * This Class is used for Ship Edge API response for Ping and Cancel requests
*/

public class ShipEdgeResponseWrapper {

	public String status;
	public String result;
    
	
	public static ShipEdgeResponseWrapper parse(String json) {
		return (ShipEdgeResponseWrapper) System.JSON.deserialize(json, ShipEdgeResponseWrapper.class);
	}
}