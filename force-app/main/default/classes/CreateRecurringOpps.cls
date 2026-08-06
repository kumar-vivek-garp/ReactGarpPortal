public class CreateRecurringOpps{
    
    public static boolean bIsRecursive = false;
    
    public static void CreateOpps(Set<Id> oppIds,Map<Id,ChargentOrders__Transaction__c> lstChargents){
        //system.debug('lstChargents == '+lstChargents);
        bIsRecursive = true;    
        List<Opportunity> lstNewOpps = new List<Opportunity>();
        
        //Check opp stage name is recurring intent then call this directly else check for count of of transaction count for this opp and if it has more than one then it should fire
        //Current transaction update opportunity with the clone opp id
        Set<String> setProdCodes = new Set<String>{'MEMI','MEMS','MEMC','GSTTAX','IGSTTAX'};
            Map<String,PriceBookEntry> mapPirceBooks = new Map<String,PriceBookEntry>();
        for(PriceBookEntry objPriceBook : [select unitprice, productcode, product2.Gl_Code__c from PriceBookEntry where Pricebook2.IsActive = true and Pricebook2.IsActive = true and productcode in : setProdCodes and isActive = true])
        {
            mapPirceBooks.put(objPriceBook.productcode,objPriceBook);
        }
        
        
        //Check if transaction is already exists for this opp
        Map<Id,ChargentOrders__Transaction__c> mapExistTransactions = new Map<Id,ChargentOrders__Transaction__c>();
        for(ChargentOrders__Transaction__c objCharge : [select id,name, Created_New_Opportunity__c ,Opportunity__c,ChargentOrders__Order__c,ChargentOrders__Gateway__c,
                                                        ChargentOrders__Gateway__r.Name,ChargentOrders__Tokenization__c,ChargentOrders__Gateway_ID__c
                                                        from ChargentOrders__Transaction__c where Opportunity__c in :oppIds and ChargentOrders__Type__c =: 'Charge' and ChargentOrders__Response_Status__c =: 'Approved'])
        {
            mapExistTransactions.put(objCharge.Opportunity__c,objCharge);
        }
        Id memRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
        Map<Id,Contract> mapContractToOpp = new Map<Id,Contract>();
        for(Contract ct : [select id,Opportunity__c from Contract where Opportunity__c in: oppIds and recordTypeId =: memRecordType])
        {
            mapContractToOpp.put(ct.Opportunity__c,ct);
        }
        Map<String,String> vatPrdCodeMap = new Map<String,String>();
        for(Country_Code__c cr:[SELECT Id,VAT_Product_Code__c,Country__c from Country_Code__c where VAT__c != null AND VAT_Product_Code__c != null]){
            vatPrdCodeMap.put(cr.Country__c,cr.VAT_Product_Code__c);
        }
        Map<Id,Id> mapOppCloneIds = new Map<Id,Id>();
        for(Opportunity objOpp : [select id,Gateway__c,Stripe_Price_Id__c,Stripe_Tax_ProductId__c,Stripe_Product_Id__c,Stripe_Subscription_Id__c,name,accountId,Charge_Amount_Vat__c,Cross_Check__c ,Billing_Zip_Postal__c,Billing_State_text__c,Billing_Phone__c,Billing_First_Name__c,Billing_Last_Name__c,Billing_Email__c,Billing_Fax__c,Billing_Company__c,Billing_Country__c,Billing_Address__c,Billing_City__c,Payment_Status__c,Cloned_From__c,account.Billing_Address_Company__c, account.BillingCity, account.BillingCountry, account.BillingState, account.BillingStreet, account.BillingPostalCode,Account.Member_Email__c, Account.Member_First_Name__c, Account.Member_Last_Name__c,CloseDate,StageName,Auto_Renew__c,Eligible_for_Membership_Extension__c,Charge_Amount__c,(Select Id,ChargentOrders__Tokenization__c from Chargent_Orders__r),Payment_Method_New__c,CardType__c from Opportunity where id in : oppIds])
        {
            
            
            if(mapExistTransactions.get(objOpp.Id) != null || objOpp.StageName == 'Recurring Intent')
            {
                Opportunity objClone = objOpp.Clone();
                objClone.Eligible_for_Membership_Extension__c = true;
                objClone.name = 'Garp Membership';
                objClone.Cross_Check__c = true;
                objClone.Auto_Renew__c = true;
                objClone.Payment_Status__c = '';
                objClone.Cloned_From__c = objOpp.Id;
                objClone.account = objOpp.account;
                objClone.StageName = 'New Lead';
                objClone.Token__c = objOpp.Chargent_Orders__r[0].ChargentOrders__Tokenization__c;
                objClone.Manual_Charge__c = true;
                objClone.CloseDate=system.today();
                objClone.Billing_Address__c = objOpp.account.BillingStreet;
                objClone.Billing_City__c    = objClone.account.BillingCity;
                objClone.Billing_Company__c = objOpp.account.Billing_Address_Company__c;
                objClone.Billing_Country__c = objOpp.account.BillingCountry;
                objClone.Billing_Email__c   = objOpp.Account.Member_Email__c;
                objClone.Billing_Fax__c     = objOpp.Billing_Fax__c;
                objClone.Billing_Last_Name__c    = objOpp.Account.Member_Last_Name__c;
                objClone.Billing_First_Name__c   = objOpp.Account.Member_First_Name__c;
                objClone.Billing_Phone__c   = objOpp.Billing_Phone__c;
                //objClone.ChargentSFA__Billing_Postcode__c= objOpp.account.BillingPostalCode;
                objClone.Billing_State_Text__c   = objOpp.account.BillingState;
                objClone.Billing_Zip_Postal__c= objOpp.account.BillingPostalCode;
                objClone.Payment_Method_New__c = objOpp.Payment_Method_New__c;
                objClone.CardType__c = objOpp.CardType__c;
                objClone.Charge_Amount_VAT__c = objOpp.Charge_Amount_VAT__c;
                objClone.Gateway__c = objOpp.Gateway__c;
                objClone.Stripe_Subscription_Id__c = objOpp.Stripe_Subscription_Id__c; 
                objClone.Stripe_Price_Id__c = objOpp.Stripe_Price_Id__c;  
                objClone.Stripe_Product_Id__c = objOpp.Stripe_Product_Id__c; 
                objClone.Stripe_Tax_ProductId__c = objOpp.Stripe_Tax_ProductId__c;
                if(lstChargents.containskey(objOpp.Id) && lstChargents.get(objOpp.Id).ChargentOrders__Gateway__c != null && lstChargents.get(objOpp.Id).ChargentOrders__Gateway__r.Name.contains('paypal')){
                    objClone.Gateway_Token__c = lstChargents.get(objOpp.Id).ChargentOrders__Tokenization__c;
                    objClone.Gateway_Time__c = lstChargents.get(objOpp.Id).ChargentOrders__Gateway_Date__c;
                }else if(lstChargents.containskey(objOpp.Id)){
                    objClone.Gateway_Token__c = lstChargents.get(objOpp.Id).ChargentOrders__Gateway_ID__c;
                    objClone.Gateway_Time__c = lstChargents.get(objOpp.Id).ChargentOrders__Gateway_Date__c;
                }
                
                lstNewOpps.add(objClone);
                
                
            }
            
        }
        //system.debug('lstNewOpps == '+lstNewOpps);
        if(lstNewOpps.size() > 0)
            insert lstNewOpps;
        
        Map<Id,Id> clonedOppToNewOrdMap = new Map<Id,Id>();
        List<ChargentOrders__ChargentOrder__c> orders = [Select Id,Opportunity__c,Opportunity__r.Cloned_From__c from ChargentOrders__ChargentOrder__c where Opportunity__c IN: lstNewOpps];
        for(ChargentOrders__ChargentOrder__c order : orders){
            clonedOppToNewOrdMap.put(order.Opportunity__r.Cloned_From__c,order.id);
        }
        
        List<Opportunity> updateOpps = new List<Opportunity>();
        List<Contract> updateCOntratcs = new List<Contract>();
        Set<Id> setOppsToUpdateStatus = new Set<ID>();
        List<Opportunity> lstOppStatusUpdates = new List<Opportunity>();
        List<ChargentOrders__ChargentOrder__c> lstOrderStatusUpdates = new List<ChargentOrders__ChargentOrder__c>();
        List<OpportunityLineItem> lstNewOppLineItems = new List<OpportunityLineItem>();
        for(Opportunity objClonedOpp : [select id,name,Stripe_Subscription_Id__c,Stripe_Tax_ProductId__c,Cloned_From__c,Billing_Country__c,Payment_Status__c,Charge_Amount_VAT__c,CloseDate,StageName,Auto_Renew__c,Eligible_for_Membership_Extension__c,Charge_Amount__c from Opportunity where id in : lstNewOpps])
        {
            setOppsToUpdateStatus.add(objClonedOpp.Cloned_From__c);
            OpportunityLineItem oppLineItem = new OpportunityLineItem();
            OpportunityLineItem oppLineItemVAT = new OpportunityLineItem();
            oppLineItem.OpportunityId = objClonedOpp.Id;
            oppLineItem.Quantity = 1;
            oppLineItemVAT.OpportunityId = objClonedOpp.Id;
            oppLineItemVAT.Quantity = 1; 
            String gstProductId = 'GSTTAX';
            if(vatPrdCodeMap.containsKey(objClonedOpp.Billing_Country__c)){
                gstProductId = vatPrdCodeMap.get(objClonedOpp.Billing_Country__c);
            }
            
            if(objClonedOpp.Stripe_Subscription_Id__c != null && objClonedOpp.Stripe_Tax_ProductId__c != null){
                gstProductId = objClonedOpp.Stripe_Tax_ProductId__c;
            }
            if(objClonedOpp.Charge_Amount__c == 195 || 
               (objClonedOpp.Charge_Amount__c > 195 && objClonedOpp.Charge_Amount_VAT__c != null))
            {
                oppLineItem.PricebookEntryId = mapPirceBooks.get('MEMI').Id;
                oppLineItem.UnitPrice =  mapPirceBooks.get('MEMI').unitprice;
                lstNewOppLineItems.add(oppLineItem);
                if(objClonedOpp.Charge_Amount_VAT__c != null){
                    oppLineItemVAT.PricebookEntryId = mapPirceBooks.get(gstProductId).Id;
                    oppLineItemVAT.UnitPrice =  objClonedOpp.Charge_Amount_VAT__c;
                    lstNewOppLineItems.add(oppLineItemVAT);
                }
            }
            else if(objClonedOpp.Charge_Amount__c == 95 || 
                    (objClonedOpp.Charge_Amount__c > 95 && objClonedOpp.Charge_Amount__c < 150 && objClonedOpp.Charge_Amount_VAT__c != null))
            {
                oppLineItem.PricebookEntryId = mapPirceBooks.get('MEMS').Id;
                oppLineItem.UnitPrice =  mapPirceBooks.get('MEMS').unitprice;
                lstNewOppLineItems.add(oppLineItem);
                if(objClonedOpp.Charge_Amount_VAT__c != null){
                    oppLineItemVAT.PricebookEntryId = mapPirceBooks.get(gstProductId).Id;
                    oppLineItemVAT.UnitPrice =  objClonedOpp.Charge_Amount_VAT__c;
                    lstNewOppLineItems.add(oppLineItemVAT);
                }
            }
            else if(objClonedOpp.Charge_Amount__c == 150  || 
                    (objClonedOpp.Charge_Amount__c > 150 && objClonedOpp.Charge_Amount__c < 195 && objClonedOpp.Charge_Amount_VAT__c != null))
            {
                oppLineItem.PricebookEntryId = mapPirceBooks.get('MEMC').Id;
                oppLineItem.UnitPrice =  mapPirceBooks.get('MEMC').unitprice;
                lstNewOppLineItems.add(oppLineItem);
                if(objClonedOpp.Charge_Amount_VAT__c != null){
                    oppLineItemVAT.PricebookEntryId = mapPirceBooks.get(gstProductId).Id;
                    oppLineItemVAT.UnitPrice =  objClonedOpp.Charge_Amount_VAT__c;
                    lstNewOppLineItems.add(oppLineItemVAT);
                }
            }
            
            if(mapContractToOpp.containsKey(objClonedOpp.Cloned_From__c))
            {
                Contract objCon = mapContractToOpp.get(objClonedOpp.Cloned_From__c);
                objCon.Opportunity__c = objClonedOpp.Id;
                updateCOntratcs.add(objCon);
            }
            
            mapOppCloneIds.put(objClonedOpp.Cloned_From__c,objClonedOpp.Id);
            objClonedOpp.StageName = 'Closed';
            updateOpps.add(objClonedOpp);
            
        }
         
        if(lstNewOppLineItems.size() > 0)
            insert lstNewOppLineItems;
        
        if(updateOpps.size() > 0)
            update updateOpps;
        
        if(updateCOntratcs.size() > 0)
            update updateCOntratcs;
        
        for(Opportunity opp : [select id,Payment_Status__c,Token__c,(Select Id,ChargentOrders__Payment_Status__c from Chargent_Orders__r) from opportunity where id in: setOppsToUpdateStatus])
        {
            opp.Payment_Status__c = 'Stopped';
            opp.Stop_Stripe_Callout__c = true;
            opp.Stripe_Subscription_Id__c = null;  
            lstOppStatusUpdates.add(opp);
            for(ChargentOrders__ChargentOrder__c ord : opp.Chargent_Orders__r){
                ord.ChargentOrders__Payment_Status__c = 'Stopped';
                lstOrderStatusUpdates.add(ord);
            }
        }
        
        if(lstOppStatusUpdates.size() > 0)
            update lstOppStatusUpdates;
        if(lstOrderStatusUpdates.size() > 0)
            update lstOrderStatusUpdates;
        //system.debug('mapOppCloneIds :'+mapOppCloneIds);
        if(mapOppCloneIds.size() > 0)
        {
            List<ChargentOrders__Transaction__c> lstTransactions = new List<ChargentOrders__Transaction__c>();
            for(ChargentOrders__Transaction__c obj : [select id, Created_New_Opportunity__c ,Opportunity__c,ChargentOrders__Order__c from ChargentOrders__Transaction__c where id in: lstChargents.values()])
            {
                //system.debug('Transaction :'+obj);
                obj.ChargentOrders__Order__c = clonedOppToNewOrdMap.get(obj.Opportunity__c);
                obj.Opportunity__c = mapOppCloneIds.get(obj.Opportunity__c);
                obj.Created_New_Opportunity__c = true;
                lstTransactions.add(obj);
            }
            //system.debug('lstTransactions :'+lstTransactions);
            update lstTransactions;
        }
    }
}