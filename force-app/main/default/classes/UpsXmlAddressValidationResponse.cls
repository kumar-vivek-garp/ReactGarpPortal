public class UpsXmlAddressValidationResponse  {

    public Response response                        { get; set; }
    public Boolean exactMatch                       { get; set; }
    public List<AddressKeyFormat> addressKeyFormats { get; set; }

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

    public class AddressKeyFormat{

        public List<String> addressLines    { get; set; }
        public String region                { get; set; }
        public String politicalDivision2    { get; set; }
        public String politicalDivision1    { get; set; }
        public String postcodePrimaryLow    { get; set; }
        public String postcodeExtendedLow   { get; set; }
        public String countryCode           { get; set; }

        public AddressKeyFormat(Dom.XMLNode node){  

            this.addressLines = new List<String>();

            List<Dom.XmlNode> nodes = node.getChildElements();

            for(Integer i = 0; i < nodes.size(); i++){
                if(nodes[i].getName() == 'AddressLine'){
                   addressLines.add(nodes[i].getText());
                }
            } 

            this.region                 = node.getChildElement('Region', null).getText();
            this.politicalDivision2     = node.getChildElement('PoliticalDivision2', null).getText();
            this.politicalDivision1     = node.getChildElement('PoliticalDivision1', null).getText();
            this.postcodePrimaryLow     = node.getChildElement('PostcodePrimaryLow', null).getText();
            this.postcodeExtendedLow    = node.getChildElement('PostcodeExtendedLow', null).getText();
            this.countryCode            = node.getChildElement('CountryCode', null).getText();

        }

    }

    public UpsXmlAddressValidationResponse(Dom.Document doc){
        
        Dom.XMLNode root = doc.getRootElement();

        this.exactMatch = false;
        this.addressKeyFormats = new List<AddressKeyFormat>();
        
        for(Dom.XMLNode node : root.getChildElements()){
            if(node.getName() == 'AddressKeyFormat'){
                AddressKeyFormat addressKeyFormat = new AddressKeyFormat(node);
                this.addressKeyFormats.add(addressKeyFormat);
            }else if(node.getName() == 'Response'){
                this.response = new Response(node);
            }else if(node.getName() == 'ValidAddressIndicator'){
                this.exactMatch = true;
            }else if(node.getName() == 'AmbiguousAddressIndicator'){
                this.exactMatch = false;
            }
        } 
        
    }

}