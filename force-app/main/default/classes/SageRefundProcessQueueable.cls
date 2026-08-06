public class SageRefundProcessQueueable implements Queueable,Database.AllowsCallouts{
    Map<Id,List<Product_Refunds__c>> opptoProdMap;
    Map<String,ChargentOrders__Transaction__c> oppToTransactionMap;
    Map<Id,Id> switchTransMap;
    public SageRefundProcessQueueable(Map<Id,List<Product_Refunds__c>> inputMap,Map<String,ChargentOrders__Transaction__c> oppTransactionMap,Map<Id,Id> switchTransactionMap){
        this.opptoProdMap = inputMap;
        this.oppToTransactionMap = oppTransactionMap;
        this.switchTransMap = switchTransactionMap;
    }
    public void execute(QueueableContext context) {
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        List<Opportunity> OrigOppsToUpdate = new List<Opportunity>();
        List<OpportunityLineItem> lineItemsToInsert = new List<OpportunityLineItem>();
        Map<String,Product_Refunds__c> refundMap = new Map<String,Product_Refunds__c>();
        List<ChargentOrders__Transaction__c> transUpdate = new List<ChargentOrders__Transaction__c>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Set<String> refundCodes = new Set<String>();
        Map<String,PriceBookEntry> priceMap = new Map<String,PriceBookEntry>();
        string siteId = Sage_Default_Records_Ref__mdt.getInstance('Unallocated_Site_Id').value__c;
        //To remove access from benchprep
        Map<String,BenchPrep_Config__mdt> benchPrepCourses = BenchPrep_Config__mdt.getAll();
        Map<Id,List<OpportunityLineItem>> oppToBenchPrepProds = new Map<Id,List<OpportunityLineItem>>();
        List<String> examCodes = new List<String>();
        examCodes = Label.SageRefundProcessExamCodes.split(','); //Moved to Custom Label FRM,SCR,RISKAI,RAIJ
            
            if(opptoProdMap != null){
                Map<Id,Opportunity> oppsMap = new Map<Id,Opportunity>([Select Id,Original_Garp_ID__c,Tax_Authority__c,StageName,AccountId,Billing_Email__c,Payment_Method_New__c,
                                                                       Billing_First_Name__c,Billing_Last_Name__c,
                                                                       Billing_Phone__c,Billing_Company__c,Gateway__c,Gateway__r.Name,
                                                                       Billing_Address__c,Billing_City__c,
                                                                       Billing_State_text__c,Billing_Zip_Postal__c,
                                                                       Billing_Country__c,Shipping_First_Name__c,ia_crm__Intacct_Transaction__c,
                                                                       Shipping_Last_Name__c,Shipping_E_mail__c,Shipping_Company_Name__c,
                                                                       Shipping_Phone_No__c,Shipping_Street__c,Shipping_City__c,
                                                                       Shipping_State__c,Shipping_Postal_Code__c,Shipping_Country__c,
                                                                       RecordTypeId,priceBook2Id,CardType__c,Display_Invoice_Number__c,
                                                                       (Select Id,Tax_Authority__c,UnitPrice,PricebookEntryId,OpportunityId,Product_Id__c,Product2Id,Quantity,TotalPrice,ProductCode,
                                                                        ia_crm__Class__c,ia_crm__Department__c,ia_crm__Intacct_Location__c,Sage_Reporting_Country__c,Site_Code__c,
                                                                        Intacct_Template__c,Warehouse__c,Sage_Reporting_State__c,Sage_Shipping_Country__c,Sage_Shipping_State__c,
                                                                        Vendor_Id__c,Vendor_Name__c,ServiceDate,ia_crm__Project__c,Reference_Id__c from OpportunityLineItems)
                                                                       from Opportunity where Id IN: opptoProdMap.keySet()]);
                
                List<ChargentOrders__Transaction__c> transList = [Select Id,ChargentOrders__Type__c,ChargentOrders__Response_Status__c,ChargentOrders__Gateway__c,ChargentOrders__Gateway__r.Name,
                                                                  ChargentOrders__Tokenization__c,Opportunity__c,ChargentOrders__Gateway_ID__c
                                                                  from ChargentOrders__Transaction__c
                                                                  where ChargentOrders__Type__c = 'Charge' and ChargentOrders__Response_Status__c = 'Approved' and
                                                                  ChargentOrders__Tokenization__c != null and Opportunity__c IN: oppsMap.keyset() 
                                                                  order by ChargentOrders__Gateway_Date__c];
                
                
                Map<Id,ChargentOrders__Transaction__c> tokenMap = new Map<Id,ChargentOrders__Transaction__c>();
                for(ChargentOrders__Transaction__c trans: transList){
                    if(String.isNotBlank(trans.ChargentOrders__Gateway_ID__c)){
                        tokenMap.put(trans.Opportunity__c,trans);
                    }
                }
                //Not using commented by chinnapa
               /* List<OpportunityLineItem> prodList = [Select Id,UnitPrice,Tax_Authority__c,PricebookEntryId,OpportunityId,Product_Id__c,Product2Id,Quantity,TotalPrice,ProductCode,
                                                      ia_crm__Class__c,ia_crm__Department__c,ia_crm__Intacct_Location__c,Sage_Reporting_Country__c,Site_Code__c,
                                                      Intacct_Template__c,Warehouse__c,Sage_Reporting_State__c,Sage_Shipping_Country__c,Sage_Shipping_State__c,
                                                      Vendor_Id__c,Vendor_Name__c
                                                      from OpportunityLineItem 
                                                      where OpportunityId IN:opptoProdMap.keySet()];*/
                
                for(Opportunity opp : oppsMap.values()){
                    if(tokenMap.containsKey(Opp.Id)){
                        opp.Gateway_Token__c = tokenMap.get(Opp.Id).ChargentOrders__Gateway_ID__c;
                        opp.Token__c = tokenMap.get(Opp.Id).ChargentOrders__Tokenization__c;
                        OrigOppsToUpdate.add(opp);
                    }
                    ChargentOrders__Transaction__c cht = oppToTransactionMap.get(opp.Id);
                    Opportunity objOpp = new Opportunity();
                    objOpp.AccountId = opp.AccountId;
                    objOpp.Billing_Email__c = opp.Billing_Email__c;
                    objOpp.Billing_First_Name__c = opp.Billing_First_Name__c;
                    objOpp.Billing_Last_Name__c = opp.Billing_Last_Name__c;
                    objOpp.Billing_Phone__c = opp.Billing_Phone__c;
                    objOpp.Billing_Company__c = opp.Billing_Company__c;
                    objOpp.Billing_Address__c = opp.Billing_Address__c;
                    objOpp.Billing_City__c = opp.Billing_City__c;
                    objOpp.Billing_State_Text__c = opp.Billing_State_Text__c;
                    objOpp.Billing_Zip_Postal__c = opp.Billing_Zip_Postal__c;
                    objOpp.Billing_Country__c = opp.Billing_Country__c;
                    objOpp.Shipping_First_Name__c = opp.Shipping_First_Name__c;
                    objOpp.Shipping_Last_Name__c = opp.Shipping_Last_Name__c;
                    objOpp.Shipping_E_mail__c = opp.Shipping_E_mail__c;
                    objOpp.Shipping_Company_Name__c = opp.Shipping_Company_Name__c;
                    objOpp.Shipping_Phone_No__c = opp.Shipping_Phone_No__c;
                    objOpp.Shipping_Street__c = opp.Shipping_Street__c;
                    objOpp.Shipping_City__c = opp.Shipping_City__c;
                    objOpp.Shipping_State__c = opp.Shipping_State__c;
                    objOpp.Shipping_Postal_Code__c = opp.Shipping_Postal_Code__c;
                    objOpp.Shipping_Country__c = opp.Shipping_Country__c;
                    objOpp.StageName = 'New Lead';
                    objOpp.CloseDate = cht.ChargentOrders__Gateway_Date__c.Date();
                    objOpp.Name = 'Refund Invoice';
                    objOpp.Refund_Opportunity__c = opp.Id;
                    objOpp.RecordTypeId = opp.RecordTypeId;
                    objOpp.priceBook2Id = opp.priceBook2Id;
                    objOpp.Original_Garp_ID__c = opp.Original_Garp_ID__c; // US-61945
                    if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Deferral'){
                        objOpp.ia_crm__Intacct_Transaction__c = 'Salesforce - Deferral Refund';
                    }else{
                        objOpp.ia_crm__Intacct_Transaction__c = 'Salesforce - Refund';
                    }
                    objOpp.Tax_Authority__c = opp.Tax_Authority__c;
                    objOpp.Payment_Method_New__c = cht.ChargentOrders__Payment_Method__c;
                    objOpp.CardType__c = cht.ChargentOrders__Credit_Card_Type__c;
                    objOpp.Token__c = cht.ChargentOrders__Tokenization__c;
                    objOpp.Display_Invoice_Number__c = opp.Display_Invoice_Number__c+'CN';
                    objOpp.Gateway__c = opp.Gateway__c;
                    objOpp.Gateway_Time__c = cht.ChargentOrders__Gateway_Date__c;
                    if(opp.Gateway__c != null && opp.Gateway__r.Name.contains('paypal')){
                        objOpp.Gateway_Token__c = cht.ChargentOrders__Tokenization__c;
                    }else{
                        objOpp.Gateway_Token__c = cht.ChargentOrders__Gateway_ID__c;
                    }
                    
                    oppsToInsert.add(objOpp);
                    
                    List<Product_Refunds__c> prodSet = opptoProdMap.get(opp.Id);
                    for(Product_Refunds__c refund :  prodSet){
                        refundMap.put(String.valueOf(refund.Product__c)+String.valueOf(refund.Opportunity__c), refund);
                        if(String.isNotBlank(refund.Discount_Product_Code__c))
                            refundCodes.add(refund.Discount_Product_Code__c);
                    }
                }
                
                if(!oppsToInsert.isEmpty()){
                    insert oppsToInsert;
                }
                
                List<Opportunity> insertedOppsList = [Select Id,Refund_Opportunity__c, (Select Id,Opportunity__c from Chargent_Orders__r) from opportunity where Id IN: oppsToInsert];
                
                Map<Id,opportunity> refundOppMap = new Map<id,opportunity>();
                
                for(Opportunity opp : insertedOppsList){
                    refundOppMap.put(opp.Refund_Opportunity__c,opp);
                    opp.StageName = 'Closed';
                }
                
                List<PricebookEntry> pbeList = [SELECT Id, Name, Product2Id, ProductCode, Unitprice,Product2.Product_Id__c,Product2.ProductCode 
                                                from PriceBookEntry 
                                                where Pricebook2.Name = 'GARP 2015/2016' AND Product2.ProductCode IN: refundCodes];
                
                for(PricebookEntry pbe : pbeList){
                    priceMap.put(pbe.Product2.ProductCode,pbe);
                }
               
                for(Opportunity opp : oppsMap.values()){
                    List<OpportunityLineItem> benchPrepProds = new List<OpportunityLineItem>();
                    for(OpportunityLineItem oli : opp.OpportunityLineItems){
                        string refundKey = String.valueof(oli.Product2Id) + String.valueof(oli.OpportunityId);
                       // system.debug(oli.ProductCode+' ==  '+examCodes.Contains(oli.ProductCode)+'   <<::>>   '+opp.ia_crm__Intacct_Transaction__c+'   :::    '+refundKey+'    ==   '+refundMap.containsKey(refundKey));
                        if(refundMap.containsKey(refundKey)){
                            Product_Refunds__c refund = refundMap.get(refundKey);
                            decimal discountPrice = oli.UnitPrice - refund.Refund_Amount__c;
                            if(oli.ProductCode == 'MEMA'){
                                continue;
                            }
                            OpportunityLineItem newOli = new OpportunityLineItem();
                            newOli.OpportunityId = refundOppMap.get(opp.Id).Id;
                            newOli.Quantity = oli.Quantity;
                            newOli.UnitPrice = refund.Refund_Amount__c;
                            //newOli.TotalPrice = -1 * oli.TotalPrice;
                            newOli.Product_ID__c = oli.Product_ID__c;
                            newOli.PricebookEntryId = oli.PricebookEntryId;
                            newoli.Product2Id = oli.Product2Id;
                            newOli.For_Sage_Sync_Only__c = true;
                            newOli.ia_crm__Class__c = oli.ia_crm__Class__c;
                            newOli.ia_crm__Department__c = oli.ia_crm__Department__c;
                            newOli.ia_crm__Intacct_Location__c = oli.ia_crm__Intacct_Location__c;
                            newOli.Sage_Reporting_Country__c = oli.Sage_Reporting_Country__c;
                            newOli.Sage_Reporting_State__c = oli.Sage_Reporting_State__c;
                            newOli.Sage_Shipping_Country__c = oli.Sage_Shipping_Country__c;
                            newOli.Sage_Shipping_State__c = oli.Sage_Shipping_State__c;
                            newOli.Vendor_Name__c = oli.Vendor_Name__c;
                            newOli.Vendor_Id__c = oli.Vendor_Id__c;
                            newOli.Warehouse__c = oli.Warehouse__c;
                            newOli.Site_Code__c = oli.Site_Code__c;
                            newOli.Intacct_Template__c = oli.Intacct_Template__c;
                            newOli.ia_crm__Project__c = oli.ia_crm__Project__c;
                            newOli.Reference_Id__c = oli.Reference_Id__c;
                            newOli.Tax_Authority__c = oli.Tax_Authority__c;
                            lineItemsToInsert.add(newoli);
                            
                            if(String.isNotBlank(refund.Discount_Product_Code__c) && priceMap.containsKey(refund.Discount_Product_Code__c)){
                                PricebookEntry pbe = priceMap.get(refund.Discount_Product_Code__c);
                               // system.debug('pbe::>>   '+pbe);
                                OpportunityLineItem newOli2 = new OpportunityLineItem();
                                newOli2.OpportunityId = refundOppMap.get(opp.Id).Id;
                                newOli2.Quantity = oli.Quantity;
                                newOli2.UnitPrice = discountPrice;
                                //newOli.TotalPrice = -1 * oli.TotalPrice;
                                //system.debug('pbe.Product2.Product_Id__c::>>   '+pbe.Product2.Product_Id__c);
                                newOli2.Product_ID__c = pbe.Product2.Product_Id__c;
                                newOli2.PricebookEntryId = pbe.Id;
                                newoli2.Product2Id = oli.Product2Id;
                                newOli2.For_Sage_Sync_Only__c = true;
                                newOli2.ia_crm__Class__c = oli.ia_crm__Class__c;
                                newOli2.ia_crm__Department__c = oli.ia_crm__Department__c;
                                newOli2.ia_crm__Intacct_Location__c = oli.ia_crm__Intacct_Location__c;
                                newOli2.Sage_Reporting_Country__c = oli.Sage_Reporting_Country__c;
                                newOli2.Sage_Reporting_State__c = oli.Sage_Reporting_State__c;
                                newOli2.Sage_Shipping_Country__c = oli.Sage_Shipping_Country__c;
                                newOli2.Sage_Shipping_State__c = oli.Sage_Shipping_State__c;
                                newOli2.Vendor_Name__c = oli.Vendor_Name__c;
                                newOli2.Vendor_Id__c = oli.Vendor_Id__c;
                                newOli2.Warehouse__c = oli.Warehouse__c;
                                newOli2.Site_Code__c = oli.Site_Code__c;
                                newOli2.Tax_Authority__c = oli.Tax_Authority__c;
                                lineItemsToInsert.add(newoli2);
                            }
                            
                            //Get Opp Prods for BenchPrep
                            if(benchPrepCourses.containskey(oli.ProductCode)){
                                benchPrepProds.add(oli);
                            }
                        }else if(examCodes.Contains(oli.ProductCode) && opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Deferral'){
                            OpportunityLineItem examOLi = new OpportunityLineItem();
                            examOLi.OpportunityId = refundOppMap.get(opp.Id).Id;
                            examOLi.Quantity = oli.Quantity;
                            examOLi.UnitPrice = -1 * oLi.UnitPrice;
                            examOLi.Product_ID__c = oli.Product_ID__c;
                            examOLi.PricebookEntryId = oli.PricebookEntryId;
                            examOLi.Product2Id = oli.Product2Id;
                            examOLi.For_Sage_Sync_Only__c = true;
                            examOli.Do_Not_Show_on_Invoice__c = true;
                            examOLi.ia_crm__Class__c = oli.ia_crm__Class__c;
                            examOLi.ia_crm__Department__c = oli.ia_crm__Department__c;
                            examOLi.ia_crm__Intacct_Location__c = oli.ia_crm__Intacct_Location__c;
                            examOLi.Sage_Reporting_Country__c = oli.Sage_Reporting_Country__c;
                            examOLi.Sage_Reporting_State__c = oli.Sage_Reporting_State__c;
                            examOLi.Sage_Shipping_Country__c = oli.Sage_Shipping_Country__c;
                            examOLi.Sage_Shipping_State__c = oli.Sage_Shipping_State__c;
                            examOLi.Vendor_Name__c = oli.Vendor_Name__c;
                            examOLi.Vendor_Id__c = oli.Vendor_Id__c;
                            examOLi.Warehouse__c = oli.Warehouse__c;
                            examOLi.Site_Code__c = oli.Site_Code__c;
                            examOLi.Intacct_Template__c = oli.Intacct_Template__c;
                            examOLi.Tax_Authority__c = oli.Tax_Authority__c;
                            if(oli.ServiceDate > system.today()){
                                examOli.ServiceDate = oli.ServiceDate;
                            }else{
                                examOli.ServiceDate = system.today();
                            }
                            lineItemsToInsert.add(examOli);
                        }
                    }
                    
                    ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
                    trans.Id = oppToTransactionMap.get(opp.Id).Id;
                    trans.Opportunity__c = refundOppMap.get(opp.Id).Id;
                    trans.ChargentOrders__Order__c = !refundOppMap.get(opp.Id).Chargent_Orders__r.isEmpty() ? refundOppMap.get(opp.Id).Chargent_Orders__r[0].Id : null;
                    transUpdate.add(trans);
                    
                    //For benchPrep
                    if(!benchPrepProds.isEmpty()){
                        oppToBenchPrepProds.put(opp.Id,benchPrepProds);
                    }
                }
                
                if(!lineItemsToInsert.isEmpty()){
                    insert lineItemsToInsert;
                }
                
                update insertedOppsList;
                
                if(!OrigOppsToUpdate.isEmpty()){
                    update OrigOppsToUpdate;
                }
                
                //Chain queue to remove benchprep access
                if(!oppToBenchPrepProds.isEmpty()){
                	expireBenchPrep_Queueable benchQueue = new expireBenchPrep_Queueable(oppToBenchPrepProds);
                    ID jobID = System.enqueueJob(benchQueue);
                }
                
            }
        
        if(switchTransMap != null){
            Map<Id,Opportunity> refundOpptoOrigOppMap = new Map<Id,Opportunity>();
            List<Opportunity> refundOpps = [Select Id,Refund_Opportunity__c,(Select Id,Opportunity__c from Chargent_Orders__r) from Opportunity where Refund_Opportunity__c IN: switchTransMap.values() and StageName = 'New Lead'];
            for(Opportunity opp : refundOpps){
                refundOpptoOrigOppMap.put(opp.Refund_Opportunity__c, opp);
                opp.StageName = 'Closed';
                oppsToUpdate.add(opp);
            }
            
            for(Id transId : switchTransMap.keyset()){
                ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
                trans.Id = transId;
                trans.Opportunity__c = refundOpptoOrigOppMap.get(switchTransMap.get(transId)).Id;
                trans.ChargentOrders__Order__c = !refundOpptoOrigOppMap.get(switchTransMap.get(transId)).Chargent_Orders__r.isEmpty() ? refundOpptoOrigOppMap.get(switchTransMap.get(transId)).Chargent_Orders__r[0].Id : null;
                transUpdate.add(trans);
            }
            
            if(!transUpdate.isEmpty()){
                update transUpdate;
            }
            
            if(!oppsToUpdate.isEmpty()){
                update oppsToUpdate;
            }
            
        }
        
    }
    
}