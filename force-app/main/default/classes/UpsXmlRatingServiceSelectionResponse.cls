public class UpsXmlRatingServiceSelectionResponse {

    public Response response                            { get; set; }
    public List<RatedShipment> ratedShipments           { get; set; }
    public Map<String, RatedShipment> ratedShipmentsMap { get; set; }
    
    public class Response{
    
        public String responseStatusCode { get; set; }
        public String responseStatusDescription { get; set; }
        public String errorSeverity { get; set; }
        public String errorCode { get; set; }
        public String errorDescription { get; set; }
        
        public Response(Dom.XMLNode node){
            
            this.responseStatusCode = node.getChildElement('ResponseStatusCode', null).getText();
            this.responseStatusDescription = node.getChildElement('ResponseStatusDescription', null).getText();
            if(node.getChildElement('Error', null) != null){
                this.errorSeverity = node.getChildElement('Error', null).getChildElement('ErrorSeverity', null).getText();
                this.errorCode = node.getChildElement('Error', null).getChildElement('ErrorCode', null).getText();
                this.errorDescription = node.getChildElement('Error', null).getChildElement('ErrorDescription', null).getText();
            }
            
        }
        
    }

    public class RatedShipment{

        public String label 					{ get; set; }        
        public String serviceCode 				{ get; set; }
        public String currencyCode 				{ get; set; }
        public String monetaryValue 			{ get; set; }
        public String guaranteedDaysToDelivery 	{ get; set; }
        public String scheduledDeliveryTime		{ get; set; }

        public RatedShipment(){}

        public RatedShipment(Dom.XMLNode node){
            
            this.serviceCode 				= node.getChildElement('Service', null).getChildElement('Code', null).getText();
            this.currencyCode 				= node.getChildElement('TotalCharges', null).getChildElement('CurrencyCode', null).getText();
            this.monetaryValue 				= node.getChildElement('TotalCharges', null).getChildElement('MonetaryValue', null).getText();
            this.guaranteedDaysToDelivery 	= node.getChildElement('GuaranteedDaysToDelivery', null).getText();
            this.scheduledDeliveryTime		= node.getChildElement('ScheduledDeliveryTime', null).getText();
            
        }
        
    }    

    public String calculateDiscount(Decimal price, Decimal discount){

        Decimal total = price - ((price * discount)/100);

        if(total < 14) total = 14;

        return String.valueOf(total.setScale(2));

    }
   
    public UpsXmlRatingServiceSelectionResponse(Dom.Document doc, String countryCode){

        Map<String, String> upsProductsMap = new Map<String, String>();
        
        upsProductsMap.put('01','UPS Next Day Air');
        upsProductsMap.put('02','UPS 2nd Day Air');
        upsProductsMap.put('03','UPS Ground');
        upsProductsMap.put('07','UPS Worldwide Express');
        upsProductsMap.put('08','UPS Worldwide Expedited');
        upsProductsMap.put('11','UPS Standard');
        upsProductsMap.put('12','UPS 3 Day Select');
        upsProductsMap.put('13','UPS Next Day Air Saver');
        upsProductsMap.put('14','UPS Next Day Air Early A.M.');
        upsProductsMap.put('54','UPS Worldwide Express Plus');
        upsProductsMap.put('59','UPS 2nd Day Air A.M.');
        upsProductsMap.put('65','UPS Saver');

        Dom.XMLNode root = doc.getRootElement();
        
        this.ratedShipments = new List<RatedShipment>();
        this.ratedShipmentsMap = new Map<String, RatedShipment>();

        Decimal discount = 0;

        if(countryCode == 'US'){
            discount = (Label.UPS_Discount_Percentage) == '' ? 0 : Decimal.valueOf(Label.UPS_Discount_Percentage);
        }else{
            discount = (Label.OutsideUSCA_UPS_Discount_Percentage) == '' ? 0 : Decimal.valueOf(Label.OutsideUSCA_UPS_Discount_Percentage);
        }

        for(Dom.XMLNode node : root.getChildElements()){
            if(node.getName() == 'RatedShipment'){

                RatedShipment ratedShipment = new RatedShipment(node);

                if(countryCode == 'CA'){

                    if(ratedShipment.serviceCode != '65') continue;

                    ratedShipment.monetaryValue = calculateDiscount(Decimal.valueOf(ratedShipment.monetaryValue), discount);
                    this.ratedShipments.add(ratedShipment);
                    this.ratedShipmentsMap.put(ratedShipment.serviceCode, ratedShipment);
                          
                }else if(
                    countryCode == 'HK'||
                    countryCode == 'BH'||
                    countryCode == 'IL'||
                    countryCode == 'LB'||
                    countryCode == 'AE'
                ){

                    if(ratedShipment.serviceCode == '07'|| ratedShipment.serviceCode == '54') continue;

                    ratedShipment.monetaryValue = calculateDiscount(Decimal.valueOf(ratedShipment.monetaryValue), discount);
                    this.ratedShipments.add(ratedShipment);
                    this.ratedShipmentsMap.put(ratedShipment.serviceCode, ratedShipment);
                 
                }else {
                  
                    if(ratedShipment.serviceCode == '54') continue;

                    ratedShipment.monetaryValue = calculateDiscount(Decimal.valueOf(ratedShipment.monetaryValue), discount);
                    this.ratedShipments.add(ratedShipment);
                    this.ratedShipmentsMap.put(ratedShipment.serviceCode, ratedShipment);
                    
                }

                ratedShipment.label = upsProductsMap.get(ratedShipment.serviceCode) + ' - USD ' + ratedShipment.monetaryValue;

               
            }else if(node.getName() == 'Response'){
                this.response = new Response(node);
            }
        } 
        
    }
    
}