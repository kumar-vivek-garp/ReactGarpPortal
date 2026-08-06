public class UpsXmlAddressValidationRequest  {

    transient public String requestXml { get; set; }

    public UpsXmlAddressValidationResponse fetch(){

        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://onlinetools.ups.com/ups.app/xml/XAV');
        req.setMethod('POST');
        req.setBody(this.requestXml);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 

        Http http = new Http();
        HttpResponse res = http.send(req);

        Dom.Document doc = res.getBodyDocument();

        return new UpsXmlAddressValidationResponse(doc);

    }

    public UpsXmlAddressValidationRequest(String address1, String address2, String city, String stateCode, String postalCode, String countryCode){

        string upsAccessLiscenseNumber = 'DC3972F4C25D1D04';
        string upsUserID = 'garpups';
        string upsPassword = '7y8uSAi8o9';

        string xml = '';
        xml+= '<?xml version="1.0"?>';
        xml+= ' <AccessRequest xml:lang="en-US">';
        xml+= '  <AccessLicenseNumber>' + upsAccessLiscenseNumber + '</AccessLicenseNumber>';
        xml+= '       <UserId>' + upsUserID + '</UserId>';
        xml+= '       <Password>' + upsPassword + '</Password>';
        xml+= ' </AccessRequest>';
        xml+= '<?xml version="1.0"?>';
        xml+= ' <AddressValidationRequest xml:lang="en-US">';
        xml+= '       <Request>';
        xml+= '              <TransactionReference>';
        xml+= '                     <CustomerContext>Address Validation</CustomerContext>';
        xml+= '                     <XpciVersion>1.0001</XpciVersion>';
        xml+= '              </TransactionReference>';
        xml+= '              <RequestAction>XAV</RequestAction>';
        xml+= '              <RequestOption>1</RequestOption>';
        xml+= '       </Request>';
        xml+= '       <MaximumListSize>1</MaximumListSize>';
        xml+= '       <AddressKeyFormat>';
        xml+= '              <AddressLine>' + address1 + '</AddressLine>';
        xml+= '              <AddressLine>' + address2 + '</AddressLine>';
        xml+= '              <PoliticalDivision2>' + city + '</PoliticalDivision2>';
        xml+= '              <PoliticalDivision1>' + stateCode + '</PoliticalDivision1>';
        xml+= '              <PostcodePrimaryLow>' + postalCode + '</PostcodePrimaryLow>';
        xml+= '              <CountryCode>' + countryCode + '</CountryCode>';
        xml+= '       </AddressKeyFormat>';
        xml+= '</AddressValidationRequest>';

        this.requestXml = xml;

    }

}