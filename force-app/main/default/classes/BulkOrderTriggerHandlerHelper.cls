public without sharing class BulkOrderTriggerHandlerHelper {
    
    public Static void createOpportunity(Map<String,Bulk_Orders__c> bulkOrderMap){
        
        List<String> pcList = new List<String>{'FRM1H','FRM2H','SCRH','CBRHB','SHIPBULK','DISCFRMEPP','DISCSCREPP','DISCSCRAP','DISCFRMAP','RAIH','DISCRAIEPP','DISCRAIAP','SCRCANDISC','RAICANDISC'};
            List<Opportunity> OppInsertList = new List<Opportunity>();
        List<OpportunityLineItem> oliInsertList = new List<OpportunityLineItem>();
        Map<String,PricebookEntry> pbeMap = new Map<String,PricebookEntry>();
        List<ChargentOrders__Transaction__c> transList = new List<ChargentOrders__Transaction__c>();
        Map<String,String> oppCOMap = new Map<String,String>();
        
        for(PricebookEntry pbe : [SELECT Id,Product2Id,UnitPrice,Product2.ProductCode,Product2.Product_Id__c FROM PricebookEntry 
                                  WHERE Product2.ProductCode IN : pcList AND Pricebook2.IsActive = TRUE AND Pricebook2.Name = 'GARP 2015/2016'])
        {
            pbeMap.put(pbe.Product2.ProductCode,pbe);
        }
        
        Map<Id,Bulk_Orders__c> boRecMap = new Map<Id,Bulk_Orders__c>([SELECT Id,Team_Registration__c,Team_Registration__r.Account__c,Shipping_Attention__c,Shipping_Company__c,
                                                                      Team_Registration__r.Shipping_Cost__c, Team_Registration__r.Account__r.BillingStreet,B2B_Deal_Item__c,
                                                                      Team_Registration__r.Account__r.BillingCity, Team_Registration__r.Account__r.BillingCountry,B2B_Deal_Item__r.Shipping_Cost__c,
                                                                      Team_Registration__r.Account__r.BillingState, Team_Registration__r.Account__r.BillingPostalCode,
                                                                      FRM_Part_I_Books__c,FRM_Part_II_Books__c,RAI_Hard_Books__c,SCR_Books__c,B2B_Deal_Item__r.Discounted_SCR_Hard_Books__c,B2B_Deal_Item__r.Discounted_RAI_Hard_Books__c,B2B_Deal_Item__r.Discount_Type__c,B2B_Deal_Item__r.Discount_Percent__c
                                                                      FROM Bulk_Orders__c WHERE Id IN: bulkOrderMap.KeySet()]);
        
        for(Bulk_Orders__c boRec : boRecMap.Values())
        {
            Bulk_Orders__c bo = bulkOrderMap.get(boRec.Id);
            Opportunity opp = new Opportunity();
            opp.AccountId = boRec.Team_Registration__r.Account__c;
            opp.B2B_Deal_Item__c = boRec.B2B_Deal_Item__c;
            opp.Shipping_First_Name__c = boRec.Shipping_Attention__c;
            opp.Shipping_Company_Name__c = bo.Shipping_Company__c;
            opp.Shipping_Street__c = bo.Shipping_Address_1__c;
            opp.Shipping_State__c = bo.Shipping_State_Provence__c;
            opp.Shipping_City__c = bo.Shipping_City__c;
            opp.Shipping_Country__c = bo.Shipping_Country__c;
            opp.Shipping_Postal_Code__c = bo.Shipping_Postal_Code__c;
            opp.Shipping_Phone_No__c = bo.Shipping_Phone_Number__c;
            opp.Shipping_E_mail__c = bo.E_mail__c;
            opp.Bulk_Orders__c = bo.Id;
            opp.Team_Registration__c = bo.Team_Registration__c;
            opp.Name = 'Bulk Order';
            opp.StageName = 'New Lead';
            opp.ia_crm__Intacct_Transaction__c = 'Salesforce - Bulk Order';
            opp.CloseDate = System.today();
            opp.Billing_Address__c = boRec.Team_Registration__r.Account__r.BillingStreet;
            opp.Billing_City__c = boRec.Team_Registration__r.Account__r.BillingCity;
            opp.Billing_Country__c = boRec.Team_Registration__r.Account__r.BillingCountry;
            opp.Billing_State_Text__c = boRec.Team_Registration__r.Account__r.BillingState;
            opp.Billing_Zip_Postal__c = boRec.Team_Registration__r.Account__r.BillingPostalCode;
            Opp.Has_Books__c = true;
            opp.Ups_Stage__c = 'New Order';
            OppInsertList.add(opp);
        }
        
        if(!OppInsertList.isEmpty()){
            Savepoint sp = Database.setSavepoint();
            try{
                insert OppInsertList;
                
                for(ChargentOrders__ChargentOrder__c co : [Select Id,Opportunity__c from ChargentOrders__ChargentOrder__c 
                                                           WHERE Opportunity__c IN: OppInsertList]){
                                                               oppCOMap.put(co.Opportunity__c ,co.Id); 
                                                           }
                for(Opportunity opp : OppInsertList){
                    Bulk_Orders__c bo = bulkOrderMap.get(opp.Bulk_Orders__c);
                    Bulk_Orders__c boRelatedValueRec = boRecMap.get(opp.Bulk_Orders__c);
                    decimal frmBookValue = 0;
                    decimal scrBookValue = 0;
                    decimal raiBookValue = 0;
                    if(bo.FRM_Part_I_Books__c > 0){
                        PricebookEntry pbe = pbeMap.get('FRM1H');
                        OpportunityLineItem oli = new OpportunityLineItem(PricebookEntryId = pbe.Id,Product2Id = pbe.Product2Id,
                                                                          OpportunityId = opp.Id,UnitPrice = pbe.UnitPrice,Product_Id__c = pbe.Product2.Product_id__c,
                                                                          Quantity = bo.FRM_Part_I_Books__c);
                        frmBookValue += oli.UnitPrice * oli.Quantity;
                        oliInsertList.add(oli);
                    }
                    if(bo.FRM_Part_II_Books__c > 0){
                        PricebookEntry pbe = pbeMap.get('FRM2H');
                        OpportunityLineItem oli = new OpportunityLineItem(PricebookEntryId = pbe.Id,Product2Id = pbe.Product2Id,
                                                                          OpportunityId = opp.Id,UnitPrice = pbe.UnitPrice,Product_Id__c = pbe.Product2.Product_id__c,
                                                                          Quantity = bo.FRM_Part_II_Books__c);
                        frmBookValue += oli.UnitPrice * oli.Quantity;
                        oliInsertList.add(oli);
                    }
                    if(bo.FRR_Books__c > 0){
                        PricebookEntry pbe = pbeMap.get('CBRHB');
                        OpportunityLineItem oli = new OpportunityLineItem(PricebookEntryId = pbe.Id,Product2Id = pbe.Product2Id,
                                                                          OpportunityId = opp.Id,UnitPrice = pbe.UnitPrice,Product_Id__c = pbe.Product2.Product_id__c,
                                                                          Quantity = bo.FRR_Books__c);
                        oliInsertList.add(oli);
                    }
                    if(bo.SCR_Books__c > 0){
                        PricebookEntry pbe = pbeMap.get('SCRH');
                        Decimal discountedSCR = boRelatedValueRec.B2B_Deal_Item__r.Discounted_SCR_Hard_Books__c;
                        Decimal Quantity = discountedSCR > 0?discountedSCR+bo.SCR_Books__c:bo.SCR_Books__c;
                        OpportunityLineItem oli = new OpportunityLineItem(PricebookEntryId = pbe.Id,Product2Id = pbe.Product2Id,
                                                                          OpportunityId = opp.Id,UnitPrice = pbe.UnitPrice,Product_Id__c = pbe.Product2.Product_id__c,
                                                                          Quantity = Quantity);
                        scrBookValue += oli.UnitPrice * oli.Quantity;
                        oliInsertList.add(oli);
                        if(discountedSCR > 0){
                            PricebookEntry pbed = pbeMap.get('SCRCANDISC');
                            OpportunityLineItem olid = new OpportunityLineItem(PricebookEntryId = pbed.Id,Product2Id = pbed.Product2Id,
                                                                              OpportunityId = opp.Id,UnitPrice =-200,Product_Id__c = pbed.Product2.Product_id__c,
                                                                              Quantity = discountedSCR);
                            
                            oliInsertList.add(olid);
                        }
                    }
                    if(bo.RAI_Hard_Books__c > 0){
                        PricebookEntry pbe = pbeMap.get('RAIH');
                        Decimal discountedRAI = boRelatedValueRec.B2B_Deal_Item__r.Discounted_RAI_Hard_Books__c;
                        Decimal Quantity = discountedRAI > 0?discountedRAI+bo.RAI_Hard_Books__c:bo.RAI_Hard_Books__c;
                        OpportunityLineItem oli = new OpportunityLineItem(PricebookEntryId = pbe.Id,Product2Id = pbe.Product2Id,
                                                                          OpportunityId = opp.Id,UnitPrice = pbe.UnitPrice,Product_Id__c = pbe.Product2.Product_id__c,
                                                                          Quantity = Quantity);
                        raiBookValue += oli.UnitPrice * oli.Quantity;
                        oliInsertList.add(oli);
                         if(discountedRAI > 0){
                            PricebookEntry pbed = pbeMap.get('RAICANDISC');
                            OpportunityLineItem olid = new OpportunityLineItem(PricebookEntryId = pbed.Id,Product2Id = pbed.Product2Id,
                                                                              OpportunityId = opp.Id,UnitPrice =-200,Product_Id__c = pbed.Product2.Product_id__c,
                                                                              Quantity = discountedRAI);
                             
                            oliInsertList.add(olid);
                        }
                    }
                    if(boRelatedValueRec.B2B_Deal_Item__r.Shipping_Cost__c > 0){
                        PricebookEntry pbe = pbeMap.get('SHIPBULK');
                        OpportunityLineItem oli = new OpportunityLineItem(PricebookEntryId = pbe.Id,Product2Id = pbe.Product2Id,
                                                                          OpportunityId = opp.Id,Product_Id__c = pbe.Product2.Product_id__c,
                                                                          UnitPrice = boRelatedValueRec.B2B_Deal_Item__r.Shipping_Cost__c,
                                                                          Quantity = 1);
                        oliInsertList.add(oli);
                    }
                    
                    if(boRelatedValueRec.B2B_Deal_Item__r.Discount_Type__c != null && boRelatedValueRec.B2B_Deal_Item__r.Discount_Percent__c != null){
                        if(frmBookValue != null && frmBookValue != 0){
                            PricebookEntry FRMpbe = new PricebookEntry();
                            decimal frmDiscount = frmBookValue * (boRelatedValueRec.B2B_Deal_Item__r.Discount_Percent__c * (-1) / 100);
                            if(boRelatedValueRec.B2B_Deal_Item__r.Discount_Type__c == 'EPP'){
                                FRMpbe = pbeMap.get('DISCFRMEPP');
                            }else if(boRelatedValueRec.B2B_Deal_Item__r.Discount_Type__c == 'Academic'){
                                FRMpbe = pbeMap.get('DISCFRMAP');
                            }
                            OpportunityLineItem oli = new OpportunityLineItem(PricebookEntryId = FRMpbe.Id,Product2Id = FRMpbe.Product2Id,
                                                                  OpportunityId = opp.Id,UnitPrice = frmDiscount,
                                                                  Product_Id__c = FRMpbe.Product2.Product_id__c,Quantity = 1);
                            oliInsertList.add(oli);
                        }
                        if(scrBookValue != null && scrBookValue != 0){
                            PricebookEntry SCRpbe = new PricebookEntry();
                            decimal scrDiscount = scrBookValue * (boRelatedValueRec.B2B_Deal_Item__r.Discount_Percent__c * (-1) / 100);
                            if(boRelatedValueRec.B2B_Deal_Item__r.Discount_Type__c == 'EPP'){
                                SCRpbe = pbeMap.get('DISCSCREPP');
                            }else if(boRelatedValueRec.B2B_Deal_Item__r.Discount_Type__c == 'Academic'){
                                SCRpbe = pbeMap.get('DISCSCRAP');
                            }
                            OpportunityLineItem oli = new OpportunityLineItem(PricebookEntryId = SCRpbe.Id,Product2Id = SCRpbe.Product2Id,
                                                                  OpportunityId = opp.Id,UnitPrice = scrDiscount,
                                                                  Product_Id__c = SCRpbe.Product2.Product_id__c,Quantity = 1);
                            oliInsertList.add(oli);
                        }
                        if(raiBookValue != null && raiBookValue != 0){
                            PricebookEntry RAIpbe = new PricebookEntry();
                            decimal raiDiscount = raiBookValue * (boRelatedValueRec.B2B_Deal_Item__r.Discount_Percent__c * (-1) / 100);
                            if(boRelatedValueRec.B2B_Deal_Item__r.Discount_Type__c == 'EPP'){
                                RAIpbe = pbeMap.get('DISCRAIEPP');
                            }else if(boRelatedValueRec.B2B_Deal_Item__r.Discount_Type__c == 'Academic'){
                                RAIpbe = pbeMap.get('DISCRAIAP');
                            }
                            if(RAIpbe != null){
                                OpportunityLineItem oli = new OpportunityLineItem(PricebookEntryId = RAIpbe.Id,Product2Id = RAIpbe.Product2Id,
                                                                                  OpportunityId = opp.Id,UnitPrice = raiDiscount,
                                                                                  Product_Id__c = RAIpbe.Product2.Product_id__c,Quantity = 1);
                                oliInsertList.add(oli);
                            }
                        }
                        
                    }
                    ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
                    trans.Opportunity__c = opp.Id;
                    trans.ChargentOrders__Amount__c = 0.00;
                    trans.ChargentOrders__Response_Message__c = 'Approved';
                    trans.ChargentOrders__Response_Status__c = 'Approved';
                    trans.ChargentOrders__Type__c = 'Charge';
                    if(oppCOMap.size() > 0 && oppCOMap.containsKey(opp.Id)){ trans.ChargentOrders__Order__c = oppCOMap.get(opp.Id); }
                    trans.ChargentOrders__Payment_Method__c ='Bulk Order';
                    trans.ChargentOrders__Gateway_Date__c =system.now();
                    transList.add(trans);
                    
                }
                if(!oliInsertList.IsEmpty()){
                    insert oliInsertList;
                    insert transList;
                }
            }catch(Exception e){
                System.debug('Exception_Message'+e.getMessage());
                Database.rollback(sp);
            }
        }
    }
    
}