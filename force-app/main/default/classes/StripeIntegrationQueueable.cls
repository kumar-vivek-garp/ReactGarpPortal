public class StripeIntegrationQueueable implements Queueable, Database.AllowsCallouts {
    
    public static Map<String, Stripe_Product_Configuration__mdt> getStripeProdId() {
        Map<String, Stripe_Product_Configuration__mdt> productIdMap = new Map<String, Stripe_Product_Configuration__mdt>();
        for(Stripe_Product_Configuration__mdt prd :[SELECT Product_Id__c,MasterLabel,Price_Id__c FROM Stripe_Product_Configuration__mdt]){
            productIdMap.put(prd.MasterLabel,prd);
        } 
        return productIdMap;
    }
    
    private List<Stripe_Integration__e> newEvents;
    
    // Constructor accepts list of events
    public StripeIntegrationQueueable(List<Stripe_Integration__e> evts) {
        this.newEvents = new List<Stripe_Integration__e>();
        this.newEvents = evts;
    }
    
    public void execute(QueueableContext context) { 
        try{
        Set<String> customeroppIds = new Set<String>(); 
        Set<String> paymentoppIds = new Set<String>(); 
        Map<String,String> tokenTransactionMap = new Map<String,String>(); 
        Map<String,String> oppProductMap = new Map<String,String>();
        Map<String,Date> programaccMap = new Map<String,Date>();
        for(Stripe_Integration__e evt : newEvents) { 
            if((evt.Action_Type__c == 'Create') && evt.Customer_Id__c == null){
                customeroppIds.add(evt.Opportunity_Id__c);
            }    
            if(evt.Action_Type__c != 'Cancel' && evt.Payment_Date__c == null){
                paymentoppIds.add(evt.Account_Id__c);
            }
        }
        
        if(customeroppIds.size() > 0){
            for(ChargentOrders__Transaction__c crt:[Select Id,Opportunity__c,ChargentOrders__Tokenization__c From ChargentOrders__Transaction__c Where Opportunity__c In:customeroppIds]){
                tokenTransactionMap.put(crt.Opportunity__c,crt.ChargentOrders__Tokenization__c);
            }
        } 
        if(paymentoppIds.size() > 0){
            id memRecTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'Membership');
            for(Contract ct : [select id,AccountId,EndDate from contract where AccountId =: paymentoppIds and recordTypeId =: memRecTypeId and Status = 'Activated ( Auto-Renew )' and Membership_Type__c = 'Individual' Order BY Enddate Desc]){
                if(!programaccMap.containsKey(ct.AccountId))
                programaccMap.put(ct.AccountId,ct.EndDate);
            }
        }
        Map<String, Stripe_Product_Configuration__mdt> productIdMap = getStripeProdId();
        List<StripeSubscriptionServiceUtil.SubscriptionRequest> requests = new List<StripeSubscriptionServiceUtil.SubscriptionRequest>();
            List<StripeInvoicePreview.stRequest> prrequests = new List<StripeInvoicePreview.stRequest>();
        for(Stripe_Integration__e evt : newEvents) { 
            String productId = '';
            String priceId = '';
            Decimal chargeamount = 0;
            if(evt.Charge_Amount__c == 195.00 || evt.Charge_Amount__c == 150.00){
                String prname = String.valueOf(Integer.valueof(evt.Charge_Amount__c));
                productId = productIdMap.containsKey(prname) ? productIdMap.get(prname).Product_Id__c:'';
                priceId = productIdMap.containsKey(prname) ? productIdMap.get(prname).Price_Id__c:'';
                chargeamount = evt.Charge_Amount__c;
                oppProductMap.put(evt.Opportunity_Id__c,productId);
            }else if(evt.Vat_Amount__c != null && evt.Charge_Amount__c != null){
                chargeamount = evt.Charge_Amount__c - evt.Vat_Amount__c; 
                String prname = String.valueOf(Integer.valueof(chargeamount)); 
                productId = productIdMap.containsKey(prname) ? productIdMap.get(prname).Product_Id__c:'';
                priceId = productIdMap.containsKey(prname) ? productIdMap.get(prname).Price_Id__c:'';
                oppProductMap.put(evt.Opportunity_Id__c,productId);
            }
            StripeSubscriptionServiceUtil.SubscriptionRequest req = new StripeSubscriptionServiceUtil.SubscriptionRequest();
            req.action = evt.Action_Type__c;
            req.isAutotax = false;
            req.actionType = evt.Action_Type__c;
            if(tokenTransactionMap.containsKey(evt.Opportunity_Id__c)){
                req.customerId = tokenTransactionMap.get(evt.Opportunity_Id__c);
            }else if(evt.Customer_Id__c != null){
                req.customerId = evt.Customer_Id__c;
            } 
            req.items = new List<StripeSubscriptionServiceUtil.SubscriptionItem>();
            StripeSubscriptionServiceUtil.SubscriptionItem item = new StripeSubscriptionServiceUtil.SubscriptionItem();
            //StripeInvoicePreview.stRequest inpr = new StripeInvoicePreview.stRequest();
            item.productPriceId = productId;
            item.unitamount = chargeamount;  
            if(req.action != 'Create'){
                req.subscriptionId = evt.Subscription_Id__c;
                item.priceId = evt.Stripe_Price_Id__c;
            }
            if(req.action == 'Create' || req.action == 'Update'){
               /* inpr.customerId = req.customerId;
                inpr.oppId = evt.Opportunity_Id__c;
                inpr.quantity = 1;
                inpr.priceId = priceId;
                prrequests.add(inpr); */
                req.isAutotax = true;
            }
            item.quantity = 1;
            req.items.add(item);
            if(evt.Payment_Date__c != null){
                req.billingCycleAnchor = StripeSubscriptionServiceUtil.dateToUnixTimestamp(evt.Payment_Date__c);
            }else if(programaccMap.containsKey(evt.Account_Id__c)){
                req.accountId = evt.Account_Id__c;
                req.billingCycleAnchor = StripeSubscriptionServiceUtil.dateToUnixTimestamp(programaccMap.get(evt.Account_Id__c));
            } 
            req.oppId = evt.Opportunity_Id__c;
            requests.add(req);  
        }
       // Map<String,StripeInvoicePreview.stResult> stprMap = StripeInvoicePreview.previewSubTax(prrequests);
        StripeSubscriptionServiceUtil service = new StripeSubscriptionServiceUtil();
        List<StripeSubscriptionServiceUtil.SubscriptionResult> results = service.processSubscriptions(requests);
        List<API_Transaction__c> apiTransactionList = new List<API_Transaction__c>();
        Map<String,Opportunity> opportunityListMap = new Map<String,Opportunity>();
        for (StripeSubscriptionServiceUtil.SubscriptionResult r : results) {
            API_Transaction__c record = new API_Transaction__c ();
            record.Response_Body__c =  r.resBody;
            record.name ='Stripte '+ r.actionType + ' '+r.oppId;  
            record.Type__c = 'Stripe';
            record.Request_Body__c = r.requestBody;
            record.Opportunity__c = r.oppId;
            apiTransactionList.add(record); 
            Opportunity opp = new Opportunity();
            opp.Id = r.oppId;
            if(r.isException != true && r.isSuccess == true){ 
                StripeResponseParser.SubscriptionResponse result = StripeResponseParser.parseSubscriptionResponse(r.resBody);
                //StripeInvoicePreview.stResult prRes = stprMap.containsKey(opp.Id) ? stprMap.get(opp.Id):new StripeInvoicePreview.stResult();
                if(r.actionType == 'Create'){
                    if(programaccMap.containsKey(r.accountId))
                    opp.Payment_Start_Date__c = programaccMap.get(r.accountId);
                    opp.Stripe_Subscription_Id__c = result.id;
                    opp.Stripe_Price_Id__c = result.items[0].id;
                    opp.Stripe_Outbound_Status__c = 'Created';
                    opp.Stripe_Product_Id__c = oppProductMap.get(opp.Id);
                    /*opp.StripeTaxPreviewRes__c = JSON.serialize(prRes);
                    opp.StripeRecurringTax__c = prRes.taxRate;
                    opp.StripeRecTotalAmount__c = prRes.amountDue; */
                }else if(r.actionType == 'Update'){
                    if(programaccMap.containsKey(r.accountId))
                    opp.Payment_Start_Date__c = programaccMap.get(r.accountId);
                    opp.Stripe_Outbound_Status__c = 'Updated'; 
                    opp.Stripe_Price_Id__c = result.items[0].id;
                    opp.Stripe_Product_Id__c = oppProductMap.get(opp.Id);
                    /*opp.StripeTaxPreviewRes__c = JSON.serialize(prRes);
                    opp.StripeRecurringTax__c = prRes.taxRate;
                    opp.StripeRecTotalAmount__c = prRes.amountDue; */
                } else if(r.actionType == 'Cancel'){
                    opp.Stripe_Subscription_Id__c = null;
                    opp.Stripe_Price_Id__c = null;
                    opp.Stripe_Outbound_Status__c = 'Canceled';
                    opp.Stripe_Product_Id__c = null;
                    opp.StripeTaxPreviewRes__c = '';
                    opp.StripeRecurringTax__c = null;
                    opp.StripeRecTotalAmount__c = null;
                } 
                opportunityListMap.put(opp.Id,opp);  
            }else{
                opp.Stripe_Outbound_Status__c = 'Error';
                opportunityListMap.put(opp.Id,opp); 
            } 
        }
        if(opportunityListMap.size() > 0){
            update opportunityListMap.values();
        }
        if(apiTransactionList.size() > 0){
            insert apiTransactionList;
        }
        }catch(Exception e){ 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String receipientList = system.label.Exception_Recipient_List;
            List<String> toAddresses = new list<string>();
            toAddresses.addall(receipientList.split(','));mail.setToAddresses(toAddresses);
            mail.setSubject('Stripe Integration Stream Event Trigger Failed: '+system.now());
            mail.setPlainTextBody('Stripe Integration Stream Event Trigger Failed with Error: '+e.getMessage()+':'+e.getStackTraceString());
            if(!test.isRunningTest())
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    } 
}