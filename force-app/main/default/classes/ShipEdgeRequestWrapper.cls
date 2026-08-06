/*
 * This Class is usedfor Ship Edge API request for Ping, Get and Cancel requests
*/

public class ShipEdgeRequestWrapper{
	public String key;
	public String warehouse;
	public Integer account_id;
    public String id;
    public string order_number;
    
	public static string parse(ShipEdgeRequestWrapper request){
		return JSON.serialize(request);
	}
}