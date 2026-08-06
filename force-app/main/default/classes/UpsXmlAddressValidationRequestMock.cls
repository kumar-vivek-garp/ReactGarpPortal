global class UpsXmlAddressValidationRequestMock implements HttpCalloutMock{

    public String xml { get; set; }
    
	global HttpResponse respond(HttpRequest req){
         
		HttpResponse res = new HttpResponse();
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		res.setBody(xml);
		return res;
        
    }
    
    global UpsXmlAddressValidationRequestMock(Boolean isAmbiguousResponse){
        
        if(isAmbiguousResponse){
            this.xml = '<?xml version="1.0"?><AddressValidationResponse> <Response> <TransactionReference> <CustomerContext>Address Validation</CustomerContext> <XpciVersion>1.0001</XpciVersion> </TransactionReference> <ResponseStatusCode>1</ResponseStatusCode> <ResponseStatusDescription>Success</ResponseStatusDescription> </Response> <AmbiguousAddressIndicator/> <AddressKeyFormat> <AddressLine>2-48 RIVER DR S</AddressLine> <Region>JERSEY CITY NJ 07310-1702</Region> <PoliticalDivision2>JERSEY CITY</PoliticalDivision2> <PoliticalDivision1>NJ</PoliticalDivision1> <PostcodePrimaryLow>07310</PostcodePrimaryLow> <PostcodeExtendedLow>1702</PostcodeExtendedLow> <CountryCode>US</CountryCode> </AddressKeyFormat></AddressValidationResponse>';
        }else{
            this.xml = '<?xml version="1.0"?><AddressValidationResponse> <Response> <TransactionReference> <CustomerContext>Address Validation</CustomerContext> <XpciVersion>1.0001</XpciVersion> </TransactionReference> <ResponseStatusCode>1</ResponseStatusCode> <ResponseStatusDescription>Success</ResponseStatusDescription> </Response> <ValidAddressIndicator/> <AddressKeyFormat> <AddressLine>55 RIVER DR S</AddressLine> <AddressLine>APT 1015</AddressLine> <Region>JERSEY CITY NJ 07310-2742</Region> <PoliticalDivision2>JERSEY CITY</PoliticalDivision2> <PoliticalDivision1>NJ</PoliticalDivision1> <PostcodePrimaryLow>07310</PostcodePrimaryLow> <PostcodeExtendedLow>2742</PostcodeExtendedLow> <CountryCode>US</CountryCode> </AddressKeyFormat></AddressValidationResponse>';
        }
        
    }
    
}