public class UpsXmlRatingServiceSelectionRequest  {

    public String requestXml    { get; set; }
    public String postalCode    { get; set; }
    public String countryCode   { get; set; }
    public Decimal totalWeight  { get; set; }

    public UpsXmlRatingServiceSelectionResponse fetch(){

            HttpRequest req = new HttpRequest();
            
            req.setEndpoint('https://wwwcie.ups.com/ups.app/xml/Rate');
            req.setMethod('POST');
            req.setBody(this.requestXml);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
            req.setTimeout(120000);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
    
            Dom.Document doc = res.getBodyDocument();
          
            return new UpsXmlRatingServiceSelectionResponse(doc, countryCode);

    }

    public UpsXmlRatingServiceSelectionRequest(String countryCode, String postalCode, Decimal totalWeight){

        String upsAccessLicenseNumber = 'DC3972F4C25D1D04';
        String upsUserId = 'garpups';
        String upsPassword = '7y8uSAi8o9';
        
        String xml = '';
        xml += '<?xml version="1.0"?>';
        xml += '<AccessRequest xml:lang="en-US">';
        xml += '    <AccessLicenseNumber>' + upsAccessLicenseNumber + '</AccessLicenseNumber>';
        xml += '    <UserId>' + upsUserId + '</UserId>';
        xml += '    <Password>' + upsPassword + '</Password>';
        xml += '</AccessRequest>';
        xml += '<?xml version="1.0"?>';
        xml += '<RatingServiceSelectionRequest xml:lang="en-US">';
        xml += '    <Request>';
        xml += '        <TransactionReference>';
        xml += '            <CustomerContext>Rating and Service</CustomerContext>';
        xml += '            <XpciVersion>1.0001</XpciVersion>';
        xml += '        </TransactionReference>';
        xml += '        <RequestAction>Rate</RequestAction>';
        xml += '        <RequestOption>shop</RequestOption>';
        xml += '    </Request>';
        xml += '    <PickupType>';
        xml += '        <Code>01</Code>';
        xml += '    </PickupType>';
        xml += '    <Shipment>';
        xml += '        <Shipper>';
        xml += '            <Address>';
        xml += '                <PostalCode>08831</PostalCode>';
        xml += '            </Address>';
        xml += '        </Shipper>';
        xml += '        <ShipTo>';
        xml += '            <Address>';
        xml += '                <PostalCode>' + postalCode + '</PostalCode>';
        xml += '                <CountryCode>' + countryCode + '</CountryCode>';
        xml += '            </Address>';
        xml += '        </ShipTo>';
        xml += '        <Service>';
        xml += '            <Code>11</Code>';
        xml += '        </Service>';
        xml += '        <Package>';
        xml += '            <PackagingType>';
        xml += '                <Code>02</Code>';
        xml += '                <Description>Package</Description>';
        xml += '            </PackagingType>';
        xml += '            <Description>Rate Shopping</Description>';
        xml += '            <PackageWeight>';
        xml += '                <Weight>' + totalWeight + '</Weight>';
        xml += '            </PackageWeight>';
        xml += '        </Package>';
        xml += '        <ShipmentServiceOptions/>';
        xml += '    </Shipment>';
        xml += '</RatingServiceSelectionRequest>';  

        this.requestXml = xml;
        this.postalCode = postalCode;
        this.countryCode = countryCode;
        this.totalWeight = totalWeight;

    }



}