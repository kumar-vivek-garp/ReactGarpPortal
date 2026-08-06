public with sharing class shippingcertsxml {


public static string internationalShipping(List<certificate_shipping__c> lstcerts)
{
    String sXML = '';
    for(certificate_shipping__c certs : lstcerts)
    {
        
        sXML += '<OpenShipment ShipmentOption="SP" ProcessStatus="">\n';
        String strShippName = certs.Shipping_Attention__c;
        String strCompanyName = certs.Shipping_Company_Name__c == null ? strShippName : certs.Shipping_Company_Name__c;
        sXML += '<ShipTo>\n';
        sXML += '<CustomerID></CustomerID>\n';
        sXML += '<CompanyOrName>'+CheckNull(strCompanyName)+'</CompanyOrName>\n';
        sXML += '<Attention>'+strShippName+'</Attention>\n';
        sXML += '<Address1>'+CheckNull(certs.Shipping_Adress1__c)+'</Address1>\n';
        sXML += '<Address2>'+CheckNull(certs.Shipping_Address2__c)+'</Address2>\n';
        sXML += '<Address3>'+CheckNull(certs.Shipping_Address3__c)+'</Address3>\n';
        sXML += '<CountryTerritory>'+CheckNull(certs.Country_Code_for_UPS__c)+'</CountryTerritory>\n';
        sXML += '<PostalCode>'+CheckNull(certs.Shipping_Postal_Code__c)+'</PostalCode>\n';
        sXML += '<CityOrTown>'+CheckNull(certs.Shipping_City__c)+'</CityOrTown>';
        //Spuran to review
        //sXML += '<StateProvinceCounty>'+StateCodes.getStateId(certs.Shipping_Country__c,certs.Shipping_State__c)+'</StateProvinceCounty>\n';
        sXML += '<Telephone>'+CheckNull(certs.Shipping_Phone_No__c)+'</Telephone>\n';
        sXML += '<FaxNumber></FaxNumber>\n';
        sXML += '<EmailAddress>'+CheckNull(certs.Shipping_E_mail__c)+'</EmailAddress>\n';
        sXML += '<TaxIDNumber></TaxIDNumber>\n';
        sXML += '<ReceiverUpsAccountNumber></ReceiverUpsAccountNumber>\n';
        sXML += '<LocationID></LocationID>\n';
        sXML += '<ResidentialIndicator></ResidentialIndicator>\n';
        sXML += '</ShipTo>\n';
        sXML += '<ShipFrom>\n';
        sXML += '<CompanyOrName>GLOBAL ASSN OF RISK PROFSSNLS</CompanyOrName>\n';
        sXML += '<Attention>SHIPPER</Attention>\n';
        sXML += '<Address1>111 TOWN SQUARE PLACE</Address1>\n';
        sXML += '<Address2>SUITE 1410</Address2>\n';
        sXML += '<CountryTerritory>US</CountryTerritory>\n';
        sXML += '<PostalCode>07310</PostalCode>\n';
        sXML += '<CityOrTown>Jersey City</CityOrTown>\n';
        sXML += '<StateProvinceCounty>NJ</StateProvinceCounty>\n';
        sXML += '</ShipFrom>\n';
        sXML += '<ShipmentInformation>\n';
        sXML += '<ServiceType>'+CheckNull(certs.UPS_Service_Code_For_Xml__c)+'</ServiceType>\n';
        sXML += '<NumberOfPackages>1</NumberOfPackages>\n';
        sXML += '<DescriptionOfGoods>Diplomas</DescriptionOfGoods>\n';
        sXML += '<ShipperNumber>7699YE</ShipperNumber>\n';
        sXML += '<BillingOption>PP</BillingOption>\n'; 
        sXML += '<BillTransportationTo>Shipper</BillTransportationTo>\n';
        sXML += '<QVNOption>\n';
        sXML += '<QVNRecipientAndNotificationTypes>\n';
        sXML += '<EMailAddress>'+CheckNull(certs.Shipping_E_mail__c)+'</EMailAddress>\n';
        sXML += '<Ship>1</Ship>\n';
        sXML += '<Exception>1</Exception>\n';
        sXML += '<Delivery>1</Delivery>\n';
        sXML += '</QVNRecipientAndNotificationTypes>\n';
        sXML += '<SubjectLine>Shipping confirmation of your order</SubjectLine>\n';
        sXML += '</QVNOption>\n';
        sXML += '</ShipmentInformation>\n';
        sXML += '<Package>\n';
        sXML += '<PackageType>UPS Letter</PackageType>\n';
        sXML += '<Weight>'+CheckNull(String.valueOf(certs.Total_Package_Weight__c))+'</Weight>\n';
        sXML += '<TrackingNumber></TrackingNumber>\n';
        sXML += '<LargePackageIndicator></LargePackageIndicator>\n';
        sXML += '<Reference1>'+CheckNull(certs.Name)+'</Reference1>\n';
        sXML += '<Reference2>'+CheckNull(certs.Garp_id__c)+'</Reference2>\n';
        sXML += '</Package>\n';
        sXML += '<InternationalDocumentation>\n';
        sXML += '<InvoiceReasonForExport>Sale</InvoiceReasonForExport>\n';
        sXML += '<InvoiceCurrencyCode>US</InvoiceCurrencyCode>\n';
        sXML += '</InternationalDocumentation>\n';       
        sXML+='<Goods>\n';
        sXML+='<DescriptionOfGood>Certificate</DescriptionOfGood>\n';
        sXML+='<Inv-NAFTA-CO-CountryTerritoryOfOrigin>United States</Inv-NAFTA-CO-CountryTerritoryOfOrigin>\n';
        sXML+='<InvoiceUnits>1</InvoiceUnits>\n';
        sXML+='<InvoiceUnitOfMeasure>Piece</InvoiceUnitOfMeasure>\n';
        sXML+='<Invoice-SED-UnitPrice>'+CheckNull(certs.Customs_Cost__c)+'</Invoice-SED-UnitPrice>\n';
        sXML+='</Goods>\n';
        sXML += '</OpenShipment>\n';
        
    }
    return sXML;
    }



public static string CheckNull(String strValue)
{
     if(strValue == null){
        return '';
  
       }else {
        strValue = strValue.replace('&', '&amp;');
        return strValue;
    }

}



public static string domesticShipping(List<certificate_shipping__c> lstcerts)
{
    String sXML = '';
    for(certificate_shipping__c certs : lstcerts)
    {
        
        sXML += '<OpenShipment ShipmentOption="SP" ProcessStatus="">\n';
        String strShippName = certs.Shipping_Attention__c;
        String strCompanyName = certs.Shipping_Company_Name__c == null ? strShippName : certs.Shipping_Company_Name__c;
        sXML += '<ShipTo>\n';
        sXML += '<CustomerID></CustomerID>\n';
        sXML += '<CompanyOrName>'+CheckNull(strCompanyName)+'</CompanyOrName>\n';
        sXML += '<Attention>'+strShippName+'</Attention>\n';
        sXML += '<Address1>'+CheckNull(certs.Shipping_Adress1__c)+'</Address1>\n';
        sXML += '<Address2>'+CheckNull(certs.Shipping_Address2__c)+'</Address2>\n';
        sXML += '<Address3>'+CheckNull(certs.Shipping_Address3__c)+'</Address3>\n';
        sXML += '<CountryTerritory>'+CheckNull(certs.Country_Code_for_UPS__c)+'</CountryTerritory>\n';
        sXML += '<PostalCode>'+CheckNull(certs.Shipping_Postal_Code__c)+'</PostalCode>\n';
        sXML += '<CityOrTown>'+CheckNull(certs.Shipping_City__c)+'</CityOrTown>\n';
        //Spuran to review
        //sXML += '<StateProvinceCounty>'+StateCodes.getStateId(certs.Shipping_Country__c,certs.Shipping_State__c)+'</StateProvinceCounty>\n';
        sXML += '<Telephone>'+CheckNull(certs.Shipping_Phone_No__c)+'</Telephone>\n';
        sXML += '<FaxNumber></FaxNumber>\n';
        sXML += '<EmailAddress>'+CheckNull(certs.Shipping_E_mail__c)+'</EmailAddress>\n';
        sXML += '<TaxIDNumber></TaxIDNumber>\n';
        sXML += '<ReceiverUpsAccountNumber></ReceiverUpsAccountNumber>\n';
        sXML += '<LocationID></LocationID>\n';
        sXML += '<ResidentialIndicator></ResidentialIndicator>\n';
        sXML += '</ShipTo>\n';
        sXML += '<ShipFrom>\n';
        sXML += '<CompanyOrName>GLOBAL ASSN OF RISK PROFSSNLS</CompanyOrName>\n';
        sXML += '<Attention>SHIPPER</Attention>\n';
        sXML += '<Address1>111 TOWN SQUARE PLACE</Address1>\n';
        sXML += '<Address2>SUITE 1410</Address2>\n';
        sXML += '<CountryTerritory>US</CountryTerritory>\n';
        sXML += '<PostalCode>07310</PostalCode>\n';
        sXML += '<CityOrTown>Jersey City</CityOrTown>\n';
        sXML += '<StateProvinceCounty>NJ</StateProvinceCounty>\n';
        sXML += '</ShipFrom>\n';
        sXML += '<ShipmentInformation>\n';
        sXML += '<ServiceType>'+CheckNull(certs.UPS_Service_Code_For_Xml__c)+'</ServiceType>\n';
        sXML += '<NumberOfPackages>1</NumberOfPackages>\n';
        sXML += '<DescriptionOfGoods>Education Materials</DescriptionOfGoods>\n';
        sXML += '<ShipperNumber>7699YE</ShipperNumber>\n';
        sXML += '<BillingOption>PP</BillingOption>\n';
        sXML += '<BillTransportationTo>Shipper</BillTransportationTo>\n';
        sXML += '<QVNOption>\n';
        sXML += '<QVNRecipientAndNotificationTypes>\n';
        sXML += '<EMailAddress>'+CheckNull(certs.Shipping_E_mail__c)+'</EMailAddress>\n';
        sXML += '<Ship>1</Ship>\n';
        sXML += '<Exception>1</Exception>\n';
        sXML += '<Delivery>1</Delivery>\n';
        sXML += '</QVNRecipientAndNotificationTypes>\n';
        sXML += '<SubjectLine>Shipping confirmation of your order</SubjectLine>\n';
        sXML += '</QVNOption>\n';
        sXML += '</ShipmentInformation>\n';
        sXML += '<Package>\n';
        sXML += '<PackageType>CP</PackageType>\n';
        sXML += '<Weight>'+CheckNull(String.valueOf(certs.Total_Package_Weight__c))+'</Weight>\n';
        sXML += '<TrackingNumber></TrackingNumber>\n';
        sXML += '<LargePackageIndicator></LargePackageIndicator>\n';
        sXML += '<Reference1>'+CheckNull(certs.Name)+'</Reference1>\n';
        sXML += '<Reference2>'+CheckNull(certs.Garp_id__c)+'</Reference2>\n';
        sXML += '</Package>\n';
        sXML += '</OpenShipment>\n';

    }
        
    return sXML;    

}

public static String invoicelessXML(List<certificate_shipping__c> lstcerts)
{
    String sXML = '';
    for(certificate_shipping__c certs : lstcerts)
    {       
        
        sXML += '<OpenShipment ShipmentOption="SP" ProcessStatus="">\n';
        String strShippName = certs.Shipping_Attention__c;
        String strCompanyName = certs.Shipping_Company_Name__c == null ? strShippName : certs.Shipping_Company_Name__c;
        sXML += '<ShipTo>\n';
        sXML += '<CustomerID></CustomerID>\n';
        sXML += '<CompanyOrName>'+CheckNull(strCompanyName)+'</CompanyOrName>\n';
        sXML += '<Attention>'+strShippName+'</Attention>\n';
        sXML += '<Address1>'+CheckNull(certs.Shipping_Adress1__c)+'</Address1>\n';
        sXML += '<Address2>'+CheckNull(certs.Shipping_Address2__c)+'</Address2>\n';
        sXML += '<Address3>'+CheckNull(certs.Shipping_Address3__c)+'</Address3>\n';
        sXML += '<CountryTerritory>'+CheckNull(certs.Country_Code_for_UPS__c)+'</CountryTerritory>\n';
        sXML += '<PostalCode>'+CheckNull(certs.Shipping_Postal_Code__c)+'</PostalCode>\n';
        sXML += '<CityOrTown>'+CheckNull(certs.Shipping_City__c)+'</CityOrTown>\n';
        //Spuran to review
        //sXML += '<StateProvinceCounty>'+StateCodes.getStateId(certs.Shipping_Country__c,certs.Shipping_State__c)+'</StateProvinceCounty>\n';
        sXML += '<Telephone>'+CheckNull(certs.Shipping_Phone_No__c)+'</Telephone>\n';
        sXML += '<FaxNumber></FaxNumber>\n';
        sXML += '<EmailAddress>'+CheckNull(certs.Shipping_E_mail__c)+'</EmailAddress>\n';
        sXML += '<TaxIDNumber></TaxIDNumber>\n';
        sXML += '<ReceiverUpsAccountNumber></ReceiverUpsAccountNumber>\n';
        sXML += '<LocationID></LocationID>\n';
        sXML += '<ResidentialIndicator></ResidentialIndicator>\n';
        sXML += '</ShipTo>\n';
        sXML += '<ShipFrom>\n';
        sXML += '<CompanyOrName>GLOBAL ASSN OF RISK PROFSSNLS</CompanyOrName>\n';
        sXML += '<Attention>SHIPPER</Attention>\n';
        sXML += '<Address1>111 TOWN SQUARE PLACE</Address1>\n';
        sXML += '<Address2>SUITE 1410</Address2>\n';
        sXML += '<CountryTerritory>US</CountryTerritory>\n';
        sXML += '<PostalCode>07310</PostalCode>\n';
        sXML += '<CityOrTown>Jersey City</CityOrTown>\n';
        sXML += '<StateProvinceCounty>NJ</StateProvinceCounty>\n';
        sXML += '</ShipFrom>\n';
        sXML += '<ShipmentInformation>\n';
        sXML += '<ServiceType>'+CheckNull(certs.UPS_Service_Code_For_Xml__c)+'</ServiceType>\n';
        sXML += '<NumberOfPackages>1</NumberOfPackages>\n';
        sXML += '<DescriptionOfGoods>Diplomas</DescriptionOfGoods>\n';
        sXML += '<ShipperNumber>7699YE</ShipperNumber>\n';
        sXML += '<BillingOption>PP</BillingOption>\n';
        sXML += '<BillTransportationTo>Shipper</BillTransportationTo>\n';
        sXML += '<QVNOption>\n';
        sXML += '<QVNRecipientAndNotificationTypes>\n';
        sXML += '<EMailAddress>'+CheckNull(certs.Shipping_E_mail__c)+'</EMailAddress>\n';
        sXML += '<Ship>1</Ship>\n';
        sXML += '<Exception>1</Exception>\n';
        sXML += '<Delivery>1</Delivery>\n';
        sXML += '</QVNRecipientAndNotificationTypes>\n';
        sXML += '<SubjectLine>Shipping confirmation of your order</SubjectLine>\n';
        sXML += '</QVNOption>';
        sXML += '</ShipmentInformation>';
        sXML += '<Package>';
        sXML += '<PackageType>EE</PackageType>';
        sXML += '<Weight>'+CheckNull(String.valueOf(certs.Total_Package_Weight__c))+'</Weight>\n';
        sXML += '<TrackingNumber></TrackingNumber>\n';
        sXML += '<LargePackageIndicator></LargePackageIndicator>\n';
        sXML += '<Reference1>'+CheckNull(certs.Name)+'</Reference1>\n';
        sXML += '<Reference2>'+CheckNull(certs.Garp_id__c)+'</Reference2>\n';
        sXML += '</Package>\n';
        sXML += '<InternationalDocumentation>\n';
        sXML += '<InvoiceReasonForExport>Sale</InvoiceReasonForExport>\n';
        sXML += '<InvoiceCurrencyCode>US</InvoiceCurrencyCode>\n';
        sXML += '</InternationalDocumentation>\n';
        sXML+='<Goods>\n';
        sXML+='<DescriptionOfGood>Certificate</DescriptionOfGood>\n';
        sXML+='<Inv-NAFTA-CO-CountryTerritoryOfOrigin>United States</Inv-NAFTA-CO-CountryTerritoryOfOrigin>\n';
        sXML+='<InvoiceUnits>1</InvoiceUnits>\n';
        sXML+='<InvoiceUnitOfMeasure>Piece</InvoiceUnitOfMeasure>\n';
        sXML+='<Invoice-SED-UnitPrice>'+CheckNull(certs.Customs_Cost__c)+'</Invoice-SED-UnitPrice>\n';
        sXML+='</Goods>\n';
        sXML += '</OpenShipment>\n';
        
    }
    return sXML;
    
}

public static String writeExcelBody(List<certificate_shipping__c> lstCerts)
{
     string strExcelBody = '';
     Integer iSerialNo  = 0;
     string CertifiedDate ='';
    for(certificate_shipping__c obj : lstCerts)
    {
       IF(OBJ.Certificate_Type__c=='FRM')
        CertifiedDate =string.valueof(obj.Member__R.KPI_FRM_Certified_Date__c);
        
       IF(OBJ.Certificate_Type__c=='ERP')
        CertifiedDate =string.valueof(obj.Member__R.KPI_ERP_Certified_Date__c);
        
       IF((OBJ.Certificate_Type__c=='ICBRR' || OBJ.Certificate_Type__c=='Risk & Reg') && obj.Member__R.KPI_ICBRR_Result__c =='Pass')
        CertifiedDate =string.valueof(obj.Member__R.KPI_ICBRR_Exam_Date__c);
              
        String Name = obj.Name ;
        string Garpid =obj.Garp_id__c;
        string CertType =obj.Certificate_Type__c;
        
        
       strExcelBody +=   iSerialNo + 1 + ',' +formatCSValue(obj.Member__R.Name) + ',' + formatCSValue(obj.Garp_id__c) + ',' + formatCSValue(obj.Certificate_Type__c)+ ',' + formatCSValue(CertifiedDate)+ ',' + formatCSValue(obj.Member__R.FRM_Resume_Certificate_Sent_Date_Desc__c)+ ',' + formatCSValue(obj.Member__R.ERP_Resume_Certificate_Sent_Date_Desc__c);
   
       
       strExcelBody = strExcelBody.replace('null','');
       strExcelBody += '\r\n';

        iSerialNo++;
        
    }
    
    return strExcelBody;
}


public static string formatCSValue(string val)
{
    if(val == null) return '';
    return val.escapeCsv();
}

}