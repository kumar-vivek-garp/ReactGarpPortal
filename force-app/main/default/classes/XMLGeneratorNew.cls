public with sharing class XMLGeneratorNew {
    
    
   public static string internationalShipping(List<Opportunity> lstOpp)
    {
        //Get opp Line Items
        Map<Id,List<OpportunityLineItem>> mapOppLines = new Map<Id,List<OpportunityLineItem>>();
        for(OpportunityLineItem oLineItem : [select id,Product2.id,Product2.Name,Quantity,opportunityId from OpportunityLineItem where opportunityId in: lstOpp])
        {
            if(mapOppLines.containsKey(oLineItem.opportunityId))
                mapOppLines.get(oLineItem.opportunityId).add(oLineItem);
            else
                mapOppLines.put(oLineItem.opportunityId,new List<OpportunityLineItem>{oLineItem});
        }
        
        String sXML = '';
        for(Opportunity opp : lstOpp)
        {
            
            /*String[] arrStreetInfo = opp.Shipping_Street__c.split('\n');
            String s1 = '';
            String s2 = '';
            String s3 = '';
            if (arrStreetInfo != null && arrStreetInfo.size() > 0)
                s1 = arrStreetInfo[0];
            if (arrStreetInfo != null && arrStreetInfo.size() > 1)
                s2 = arrStreetInfo[1];
            if (arrStreetInfo != null && arrStreetInfo.size() > 2)
                s3 = arrStreetInfo[2];*/
            
           sXML += '<OpenShipment ShipmentOption="SP" ProcessStatus="">\n';
            String strShippName = opp.Shipping_First_Name__c + ' ' + opp.Shipping_Last_Name__c;
            String strCompanyName = opp.Shipping_Company_Name__c == null ? strShippName : opp.Shipping_Company_Name__c;
            sXML += '<ShipTo>\n';
            sXML += '<CustomerID></CustomerID>\n';
            sXML += '<CompanyOrName>'+strCompanyName+'</CompanyOrName>\n';
            sXML += '<Attention>'+strShippName+'</Attention>\n';
            sXML += '<Address1>'+CheckNull(opp.Shipping_Address1__c)+'</Address1>\n';
            sXML += '<Address2>'+CheckNull(opp.Shipping_Address2__c)+'</Address2>\n';
            sXML += '<Address3>'+CheckNull(opp.Shipping_Address3__c)+'</Address3>\n';
            sXML += '<CountryTerritory>'+CheckNull(opp.Country_Code_for_UPS__c)+'</CountryTerritory>\n';
            sXML += '<PostalCode>'+CheckNull(opp.Shipping_Postal_Code__c)+'</PostalCode>\n';
            sXML += '<CityOrTown>'+CheckNull(opp.Shipping_City__c)+'</CityOrTown>\n';
//Spuran - Please Reveiw            sXML += '<StateProvinceCounty>'+StateCodes.getStateId(opp.Shipping_Country__c,opp.Shipping_State__c)+'</StateProvinceCounty>\n';
            sXML += '<Telephone>'+CheckNull(opp.Shipping_Phone_No__c)+'</Telephone>\n';
            sXML += '<FaxNumber></FaxNumber>\n';
            sXML += '<EmailAddress>'+CheckNull(opp.Shipping_E_mail__c)+'</EmailAddress>\n';
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
            sXML += '<ServiceType>'+CheckNull(opp.UPS_Service_Code_For_Xml__c)+'</ServiceType>\n';
            sXML += '<NumberOfPackages>1</NumberOfPackages>\n';
            sXML += '<DescriptionOfGoods>Education Materials</DescriptionOfGoods>\n';
            sXML += '<ShipperNumber>7699YE</ShipperNumber>\n';
            sXML += '<BillingOption>PP</BillingOption>\n';
            
            sXML += '<BillTransportationTo>SHP</BillTransportationTo>\n';
            if(opp.Duty_Tax_to_Garp__c)
                sXML += '<BillDutyTaxTo>SHP</BillDutyTaxTo>\n';
            sXML += '<QVNOption>\n';
            sXML += '<QVNRecipientAndNotificationTypes>\n';
            sXML += '<EMailAddress>'+CheckNull(opp.Shipping_E_mail__c)+'</EMailAddress>\n';
            sXML += '<Ship>1</Ship>\n';
            sXML += '<Exception>1</Exception>\n';
            sXML += '<Delivery>1</Delivery>\n';
            sXML += '</QVNRecipientAndNotificationTypes>\n';
            sXML += '<SubjectLine>Shipping confirmation of your order</SubjectLine>\n';
            sXML += '</QVNOption>\n';
            sXML += '</ShipmentInformation>\n';
            sXML += '<Package>\n';
            sXML += '<PackageType>CP</PackageType>\n';
            sXML += '<Weight>'+CheckNull(String.valueOf(opp.Total_Package_Weight__c))+'</Weight>\n';
            sXML += '<TrackingNumber></TrackingNumber>\n';
            sXML += '<LargePackageIndicator></LargePackageIndicator>\n';
            sXML += '<Reference1>'+CheckNull(opp.Display_Invoice_Number__c)+'</Reference1>\n';
            sXML += '<Reference2>'+CheckNull(opp.Product_Ids__c)+'</Reference2>';
            sXML += '</Package>\n';
            sXML += '<InternationalDocumentation>\n';
            sXML += '<InvoiceReasonForExport>Sale</InvoiceReasonForExport>\n';
            sXML += '<InvoiceCurrencyCode>US</InvoiceCurrencyCode>\n';
            sXML += '</InternationalDocumentation>\n';
           
            String strGoodsXML = '';
            if(opp.Product_Names__c != null && opp.Product_Names__c != '')
            {
                String[] arrCustomCost = new String[]{}; 
                Map<String,String> mapCustomCost = new Map<String,String>();                
                if(opp.Customs_Cost__c != null)
                {
                    arrCustomCost = opp.Customs_Cost__c.split(',');
                    Integer iCount = 0;
                    for(String strName : opp.Product_Names__c.split(','))
                    {
                        mapCustomCost.put(strName,arrCustomCost[iCount]);
                        iCount++;
                    }
                        
                }
                Integer iterator = 0;
                //for(String strName : opp.Product_Names__c.split(','))
                //{
                    for(OpportunityLineItem oLItem : mapOppLines.get(opp.Id))
                    {
                       for(Integer i = 0; i < oLItem.Quantity; i++)
                        {
                            strGoodsXML += '<Goods>';
                            strGoodsXML +='<DescriptionOfGood>'+oLItem.Product2.Name+'</DescriptionOfGood>\n';
                            strGoodsXML +='<Inv-NAFTA-CO-CountryTerritoryOfOrigin>United States</Inv-NAFTA-CO-CountryTerritoryOfOrigin>\n';
                            strGoodsXML +='<InvoiceUnits>1</InvoiceUnits>\n';
                            strGoodsXML +='<InvoiceUnitOfMeasure>Piece</InvoiceUnitOfMeasure>\n';
                            if(mapCustomCost.size() >0 && mapCustomCost.get(oLItem.Product2.Name) != null)
                            strGoodsXML +='<Invoice-SED-UnitPrice>'+mapCustomCost.get(oLItem.Product2.Name)+'</Invoice-SED-UnitPrice>\n';
                            strGoodsXML +='</Goods>\n';

                            iterator++;
                        }
                    }

                //}


            }

            sXML += strGoodsXML;
            sXML += '</OpenShipment>\n';
            
        }
        return sXML;
        
    
    }
    
    

    public static string CheckNull(String strValue)
    {
        if(strValue == null)
            return '';
        else
            return strValue;

    }

    
    
    public static string domesticShipping(List<Opportunity> lstOpp)
    {
        String sXML = '';
        for(Opportunity opp : lstOpp)
        {
            //String strAddress = opp.Shipping_Street__c;

            /*String[] arrStreetInfo = strAddress.split('\n');
            String s1 = '';
            String s2 = '';
            String s3 = '';
            if (arrStreetInfo != null && arrStreetInfo.size() > 0)
                s1 = arrStreetInfo[0];
            if (arrStreetInfo != null && arrStreetInfo.size() > 1)
                s2 = arrStreetInfo[1];
            if (arrStreetInfo != null && arrStreetInfo.size() > 2)
                s3 = arrStreetInfo[2];*/
            
            sXML += '<OpenShipment ShipmentOption="SP" ProcessStatus="">\n';
            String strShippName = opp.Shipping_First_Name__c + ' ' + opp.Shipping_Last_Name__c;
            String strCompanyName = opp.Shipping_Company_Name__c == null ? strShippName : opp.Shipping_Company_Name__c;
            sXML += '<ShipTo>\n';
            sXML += '<CustomerID></CustomerID>\n';
            sXML += '<CompanyOrName>'+strCompanyName+'</CompanyOrName>\n';
            sXML += '<Attention>'+strShippName+'</Attention>\n';
            sXML += '<Address1>'+CheckNull(opp.Shipping_Address1__c)+'</Address1>\n';
            sXML += '<Address2>'+CheckNull(opp.Shipping_Address2__c)+'</Address2>\n';
            sXML += '<Address3>'+CheckNull(opp.Shipping_Address3__c)+'</Address3>\n';
            sXML += '<CountryTerritory>'+CheckNull(opp.Country_Code_for_UPS__c)+'</CountryTerritory>\n';
            sXML += '<PostalCode>'+CheckNull(opp.Shipping_Postal_Code__c)+'</PostalCode>\n';
            sXML += '<CityOrTown>'+CheckNull(opp.Shipping_City__c)+'</CityOrTown>\n';
//Spuran - Please Reveiw            sXML += '<StateProvinceCounty>'+StateCodes.getStateId(opp.Shipping_Country__c,opp.Shipping_State__c)+'</StateProvinceCounty>\n';
            sXML += '<Telephone>'+CheckNull(opp.Shipping_Phone_No__c)+'</Telephone>\n';
            sXML += '<FaxNumber></FaxNumber>\n';
            sXML += '<EmailAddress>'+CheckNull(opp.Shipping_E_mail__c)+'</EmailAddress>\n';
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
            sXML += '<ServiceType>'+CheckNull(opp.UPS_Service_Code_For_Xml__c)+'</ServiceType>\n';
            sXML += '<NumberOfPackages>1</NumberOfPackages>\n';
            sXML += '<DescriptionOfGoods>Education Materials</DescriptionOfGoods>\n';
            sXML += '<ShipperNumber>7699YE</ShipperNumber>\n';
            sXML += '<BillingOption>PP</BillingOption>\n';
            sXML += '<BillTransportationTo>SHP</BillTransportationTo>\n';
            sXML += '<QVNOption>\n';
            sXML += '<QVNRecipientAndNotificationTypes>\n';
            sXML += '<EMailAddress>'+CheckNull(opp.Shipping_E_mail__c)+'</EMailAddress>\n';
            sXML += '<Ship>1</Ship>\n';
            sXML += '<Exception>1</Exception>\n';
            sXML += '<Delivery>1</Delivery>\n';
            sXML += '</QVNRecipientAndNotificationTypes>\n';
            sXML += '<SubjectLine>Shipping confirmation of your order</SubjectLine>\n';
            sXML += '</QVNOption>\n';
            sXML += '</ShipmentInformation>\n';
            sXML += '<Package>\n';
            sXML += '<PackageType>CP</PackageType>\n';
            sXML += '<Weight>'+CheckNull(String.valueOf(opp.Total_Package_Weight__c))+'</Weight>\n';
            sXML += '<TrackingNumber></TrackingNumber>\n';
            sXML += '<LargePackageIndicator></LargePackageIndicator>\n';
            sXML += '<Reference1>'+CheckNull(opp.Display_Invoice_Number__c)+'</Reference1>\n';
            sXML += '<Reference2>'+CheckNull(opp.Product_Ids__c)+'</Reference2>\n';
            sXML += '</Package>\n';
            sXML += '</OpenShipment>\n';
    
        }
            
        return sXML;    
    
    }
    
    public static String invoicelessXML(List<opportunity> lstOpp)
    {
        //Get opp Line Items
        Map<Id,List<OpportunityLineItem>> mapOppLines = new Map<Id,List<OpportunityLineItem>>();
        for(OpportunityLineItem oLineItem : [select id,Product2.id,Product2.Name,Quantity,opportunityId from OpportunityLineItem where opportunityId in: lstOpp])
        {
            if(mapOppLines.containsKey(oLineItem.opportunityId))
                mapOppLines.get(oLineItem.opportunityId).add(oLineItem);
            else
                mapOppLines.put(oLineItem.opportunityId,new List<OpportunityLineItem>{oLineItem});
        }
        
        String sXML = '';
        for(Opportunity opp : lstOpp)
        {       
            /*String[] arrStreetInfo = opp.Shipping_Street__c.split('\n');
            String s1 = '';
            String s2 = '';
            String s3 = '';
            if (arrStreetInfo != null && arrStreetInfo.size() > 0)
                s1 = arrStreetInfo[0];
            if (arrStreetInfo != null && arrStreetInfo.size() > 1)
                s2 = arrStreetInfo[1];
            if (arrStreetInfo != null && arrStreetInfo.size() > 2)
                s3 = arrStreetInfo[2];*/
            
            sXML += '<OpenShipment ShipmentOption="SP" ProcessStatus="">\n';
            String strShippName = opp.Shipping_First_Name__c + ' ' + opp.Shipping_Last_Name__c;
            String strCompanyName = opp.Shipping_Company_Name__c == null ? strShippName : opp.Shipping_Company_Name__c;
            sXML += '<ShipTo>\n';
            sXML += '<CustomerID></CustomerID>\n';
            sXML += '<CompanyOrName>'+strCompanyName+'</CompanyOrName>\n';
            sXML += '<Attention>'+strShippName+'</Attention>\n';
            sXML += '<Address1>'+CheckNull(opp.Shipping_Address1__c)+'</Address1>\n';
            sXML += '<Address2>'+CheckNull(opp.Shipping_Address2__c)+'</Address2>\n';
            sXML += '<Address3>'+CheckNull(opp.Shipping_Address3__c)+'</Address3>\n';
            sXML += '<CountryTerritory>'+CheckNull(opp.Country_Code_for_UPS__c)+'</CountryTerritory>\n';
            sXML += '<PostalCode>'+CheckNull(opp.Shipping_Postal_Code__c)+'</PostalCode>\n';
            sXML += '<CityOrTown>'+CheckNull(opp.Shipping_City__c)+'</CityOrTown>\n';
//Spuran - Please Reveiw            sXML += '<StateProvinceCounty>'+StateCodes.getStateId(opp.Shipping_Country__c,opp.Shipping_State__c)+'</StateProvinceCounty>\n';
            sXML += '<Telephone>'+CheckNull(opp.Shipping_Phone_No__c)+'</Telephone>\n';
            sXML += '<FaxNumber></FaxNumber>\n';
            sXML += '<EmailAddress>'+CheckNull(opp.Shipping_E_mail__c)+'</EmailAddress>\n';
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
            sXML += '<ServiceType>'+CheckNull(opp.UPS_Service_Code_For_Xml__c)+'</ServiceType>\n';
            sXML += '<NumberOfPackages>1</NumberOfPackages>\n';
            sXML += '<DescriptionOfGoods>Education Materials</DescriptionOfGoods>\n';
            sXML += '<ShipperNumber>7699YE</ShipperNumber>\n';
            sXML += '<BillingOption>PP</BillingOption>\n';
            sXML += '<BillTransportationTo>SHP</BillTransportationTo>\n';
            if(opp.Duty_Tax_to_Garp__c)
                sXML += '<BillDutyTaxTo>SHP</BillDutyTaxTo>\n';
            sXML += '<QVNOption>\n';
            sXML += '<QVNRecipientAndNotificationTypes>\n';
            sXML += '<EMailAddress>'+CheckNull(opp.Shipping_E_mail__c)+'</EMailAddress>\n';
            sXML += '<Ship>1</Ship>\n';
            sXML += '<Exception>1</Exception>\n';
            sXML += '<Delivery>1</Delivery>\n';
            sXML += '</QVNRecipientAndNotificationTypes>\n';
            sXML += '<SubjectLine>Shipping confirmation of your order</SubjectLine>\n';
            sXML += '</QVNOption>\n';
            sXML += '</ShipmentInformation>\n';
            sXML += '<Package>\n';
            sXML += '<PackageType>CP</PackageType>\n';
            sXML += '<Weight>'+CheckNull(String.valueOf(opp.Total_Package_Weight__c))+'</Weight>\n';
            sXML += '<TrackingNumber></TrackingNumber>\n';
            sXML += '<LargePackageIndicator></LargePackageIndicator>\n';
            sXML += '<Reference1>'+CheckNull(opp.Display_Invoice_Number__c)+'</Reference1>\n';
            sXML += '<Reference2>'+CheckNull(opp.Product_Ids__c)+'</Reference2>\n';
            sXML += '</Package>\n';
            sXML += '<InternationalDocumentation>\n';
            sXML += '<InvoiceReasonForExport>Sale</InvoiceReasonForExport>\n';
            sXML += '<InvoiceCurrencyCode>US</InvoiceCurrencyCode>\n';
            sXML += '</InternationalDocumentation>\n';
            
            String strGoodsXML = '';
            if(opp.Product_Names__c != null && opp.Product_Names__c != '')
            {
                String[] arrCustomCost = opp.Customs_Cost__c.split(',');
                Map<String,String> mapCustomCost = new Map<String,String>();                
                if(opp.Customs_Cost__c != null)
                {
                    arrCustomCost = opp.Customs_Cost__c.split(',');
                    Integer iCount = 0;
                    for(String strName : opp.Product_Names__c.split(','))
                    {
                        mapCustomCost.put(strName,arrCustomCost[iCount]);
                        iCount++;
                    }
                        
                }
                system.debug('mapCustomCost =='+mapCustomCost);
                system.debug('mapOppLines =='+mapOppLines);
                Integer iterator = 0;
                for(OpportunityLineItem oLItem : mapOppLines.get(opp.Id))
                {
                    for(Integer i = 0; i < oLItem.Quantity; i++)
                    {
                        strGoodsXML += '<Goods>';
                        strGoodsXML +='<DescriptionOfGood>'+oLItem.Product2.Name+'</DescriptionOfGood>\n';
                        strGoodsXML +='<Inv-NAFTA-CO-CountryTerritoryOfOrigin>United States</Inv-NAFTA-CO-CountryTerritoryOfOrigin>\n';
                        strGoodsXML +='<InvoiceUnits>1</InvoiceUnits>\n';
                        strGoodsXML +='<InvoiceUnitOfMeasure>Piece</InvoiceUnitOfMeasure>\n';
                        if(mapCustomCost.size() >0 && mapCustomCost.get(oLItem.Product2.Name) != null)
                        strGoodsXML +='<Invoice-SED-UnitPrice>'+mapCustomCost.get(oLItem.Product2.Name)+'</Invoice-SED-UnitPrice>\n';
                        strGoodsXML +='</Goods>\n';

                        iterator++;
                    }
                }



            }
            system.debug('strGoodsXML =='+strGoodsXML);
            sXML += strGoodsXML;
            sXML += '</OpenShipment>\n';
            
        }
        return sXML;
        
    
    }
    
    public static String writeExcelBody(List<Opportunity> lstOpp)
    {
        Map<Id,List<OpportunityLineItem>> mapLineItems = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,Map<String,Integer>> mapProductsCount = new Map<Id,Map<String,Integer>>();
        for(OpportunityLineItem objLineItem : [select id,ProductCode,Product2.Product_ID__c,Product2.Name,Quantity,OpportunityId from OpportunityLineItem where OpportunityId in: lstOpp])

        {
            if(mapLineItems.containsKey(objLineItem.OpportunityId))
            {
                mapLineItems.get(objLineItem.OpportunityId).add(objLineItem);
                Integer iCount = 0;
                if(mapProductsCount != null && mapProductsCount.get(objLineItem.OpportunityId) != null && mapProductsCount.get(objLineItem.OpportunityId).get(objLineItem.Product2.Product_ID__c) != null)
                {
                 iCount = mapProductsCount.get(objLineItem.OpportunityId).get(objLineItem.Product2.Product_ID__c);
                }
                
                mapProductsCount.get(objLineItem.OpportunityId).put(objLineItem.Product2.Product_ID__c,iCount + 1);
                
            }
            else
            {
                mapLineItems.put(objLineItem.OpportunityId,new List<OpportunityLineItem>{objLineItem});
                mapProductsCount.put(objLineItem.OpportunityId,new Map<String,Integer>{objLineItem.Product2.Product_ID__c => 1});
            }
        }
        //SNO\tCompanyName\tAttention\tAddressLine1\tAddressLine2\tAddressLine3\tCity\tState\tCountry\tPostalCode\tWorkPhone\tFaxNumber\tEmailAddress\tServiceType\tFRM1H\tFRM2H\t4030\tCBRNM\tCBRM\tFCBR\tFBRNM\tInvoice Number\tlength\tTotalQuantity'
        string strExcelBody = '';
        Integer iSerialNo  = 0;
        for(Opportunity obj : lstOpp)
        {
            String[] arrStreetInfo ;
            if(obj.Shipping_Street__c != null){
                arrStreetInfo = obj.Shipping_Street__c.split('\n');
            }
            String s1 = '';
            String s2 = '';
            String s3 = '';
            if (arrStreetInfo != null && arrStreetInfo.size() > 0)
                s1 = arrStreetInfo[0];
            if (arrStreetInfo != null && arrStreetInfo.size() > 1)
                s2 = arrStreetInfo[1];
            if (arrStreetInfo != null && arrStreetInfo.size() > 2)
                s3 = arrStreetInfo[2];

            String strAddress = '';
            if(obj.Shipping_Street__c != null)
                strAddress = obj.Shipping_Street__c.replace(',','').replace('\r\n',';');
            String strShippName = obj.Shipping_First_Name__c + ' ' + obj.Shipping_Last_Name__c;
            String strCompanyName = obj.Shipping_Company_Name__c == null ? strShippName : obj.Shipping_Company_Name__c;
            if(strCompanyName.indexOf(',') >= 0)
                strCompanyName = strCompanyName.substring(0,strCompanyName.indexOf(','));
            
            strExcelBody += iSerialNo + 1 + ',' + formatCSValue(strCompanyName) + ',' + formatCSValue(obj.Shipping_First_Name__c) + ',' + formatCSValue(obj.Shipping_Address1__c)+ ',' + formatCSValue(obj.Shipping_Address2__c)+ ',' + formatCSValue(obj.Shipping_Address3__c)+ ',' + formatCSValue(obj.Shipping_City__c)+ ',' + formatCSValue(obj.Shipping_State__c)+ ',' + formatCSValue(obj.Shipping_Country__c)+ ',' + formatCSValue(obj.Shipping_Postal_Code__c)+ ',' + formatCSValue(obj.Shipping_Phone_No__c)+ ',' + '' + ',' +formatCSValue(obj.Shipping_E_mail__c)+ ',' + formatCSValue(obj.Shipping_Serive_Selected__c);
            //FRM1H,FRM2H,4030, CBRNM, CBRM,FCBR,FBRNM 
            String strOppLineItemRow = ',16FRM1H,16FRM2H,16ERP1B,16ERP2B,20FRRHB,3210';
            Integer iQuantity = 0;
            system.debug('mapLineItems == '+mapLineItems);
            Map<String,Integer> mapProductIDsCount = new Map<String,Integer>();
            //Update Line Items information
            if(mapLineItems.containsKey(obj.Id))
            {
                Map<String,Integer> mapCountByProds = null;
                system.debug('mapProductsCount == '+mapProductsCount);
                
                for(OpportunityLineItem objOppLine : mapLineItems.get(obj.Id))
                {
                    if(mapProductIDsCount.containsKey(objOppLine.Product2.Product_ID__c))
                    {
                        integer iVal = mapProductIDsCount.get(objOppLine.Product2.Product_ID__c);
                        mapProductIDsCount.put(objOppLine.Product2.Product_ID__c,ival + integer.valueOf(objOppLine.Quantity));
                    }
                    else
                    mapProductIDsCount.put(objOppLine.Product2.Product_ID__c,integer.valueOf(objOppLine.Quantity));
                    
                    /*system.debug('objOppLine == '+objOppLine);
                    system.debug('objOppLine.Product2.Product_ID__c == '+objOppLine.Product2.Product_ID__c);
                    mapCountByProds = mapProductsCount.get(obj.Id);
                    if(objOppLine.Product2.Product_ID__c == null) continue;
                    if(strOppLineItemRow.indexOf(objOppLine.Product2.Product_ID__c) >= 0)
                    {
                        integer iProdCount = (mapCountByProds == null || mapCountByProds.get(objOppLine.Product2.Product_ID__c) == null) ? 0 : mapCountByProds.get(objOppLine.Product2.Product_ID__c);
                        Integer iQuant = integer.valueOf(objOppLine.Quantity);
                        strOppLineItemRow = strOppLineItemRow.replace(objOppLine.Product2.Product_ID__c,String.valueOf(iQuant));
                        //iQuantity += iProdCount;
                        iQuantity += integer.valueOf(objOppLine.Quantity);
                    }
                    else
                        strOppLineItemRow = strOppLineItemRow.replace(objOppLine.Product2.Product_ID__c,'0');
                    
                }
                */
                }


            }
            system.debug('mapProductIDsCount =='+mapProductIDsCount);
            for(String str : mapProductIDsCount.Keyset())
            {
                iQuantity +=  mapProductIDsCount.get(str);
                strOppLineItemRow = strOppLineItemRow.replace(str,String.valueOf(mapProductIDsCount.get(str)));
            }
             system.debug('strOppLineItemRow =='+strOppLineItemRow);
        strOppLineItemRow = strOppLineItemRow.replace('16FRM1H','').replace('16FRM2H','').replace('16ERP1B','').replace('16ERP2B','').replace('20FRRHB','').replace('3210','');
            //Append Opporutnity and line itme info
            strExcelBody += strOppLineItemRow;
            //Add final infomration
            strExcelBody += ',' + obj.Display_Invoice_Number__c + ',' + ''+ ',' + iQuantity;
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

    public class EmailBodyWrapper
    {

        public String Product_Name;
        public String Product_ID;
        public Decimal Quantity;
    }

    public static string PrepareBodyTable(List<Opportunity> lstOpps)
    {
        Set<String> setProdIds = new Set<String>{'16FRM1H','16FRM2H','16ERP1B','16ERP2B','20FRRHB','3210'};
        Map<String,EmailBodyWrapper> mapProdQuantity = new Map<String,EmailBodyWrapper>();
        for(OpportunityLineItem objLineItem : [select id,ProductCode,Product2.Product_ID__c,Product2.Name,Quantity,OpportunityId from OpportunityLineItem where OpportunityId in : lstOpps and Product2.Product_ID__c in : setProdIds])
        {
            if(mapProdQuantity.containsKey(objLineItem.Product2.Product_ID__c))
            {
                EmailBodyWrapper objWrapper = mapProdQuantity.get(objLineItem.Product2.Product_ID__c);
                objWrapper.Quantity = objWrapper.Quantity + (objLineItem.Quantity == null ? 0 : objLineItem.Quantity);
                mapProdQuantity.put(objLineItem.Product2.Product_ID__c, objWrapper);
            }
            else
            {
                EmailBodyWrapper objWrapper =  new EmailBodyWrapper();
                objWrapper.Quantity = (objLineItem.Quantity == null ? 0 : objLineItem.Quantity);
                objWrapper.Product_ID = objLineItem.Product2.Product_ID__c;
                if(objLineItem.Product2.Name == 'ICBRR Handbooks')
                    objWrapper.Product_Name = 'Risk & Reg (FRR)';
                else
                    objWrapper.Product_Name = objLineItem.Product2.Name;
                mapProdQuantity.put(objLineItem.Product2.Product_ID__c,objWrapper);

            }
                
        }

        String strBody = '';
        strBody += '<HTML>';
        strBody += '<Table border="2">';
        strBody += '<TR>';
        strBody += '<TD>';
        strBody += 'Product Name';  
        strBody += '</TD>';
        //strBody += '</TR>';
       // strBody += '<TR>';
        strBody += '<TD>';
        strBody += 'Product Id';  
        strBody += '</TD>';
        //strBody += '</TR>';
        //strBody += '<TR>';
        strBody += '<TD>';
        strBody += 'Quantity';  
        strBody += '</TD>';
        strBody += '</TR>';
        for(String strID : mapProdQuantity.keySet())
        {
            EmailBodyWrapper objWrap = mapProdQuantity.get(strID);
            strBody += '<TR>';
            strBody += '<TD>';
            strBody += objWrap.Product_Name;
            strBody += '</TD>';
            
            
            strBody += '<TD>';
            strBody += objWrap.Product_ID;
            strBody += '</TD>';
            
            strBody += '<TD>';
            strBody += objWrap.Quantity;
            strBody += '</TD>';
            strBody += '</TR>';

        }

        strBody += '</Table>';
        strBody += '</HTML>';

        return strBody;

    }
    
    

}