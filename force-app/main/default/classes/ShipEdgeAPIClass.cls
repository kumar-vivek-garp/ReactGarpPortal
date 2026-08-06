public class ShipEdgeAPIClass {
    
    public static ShipEdgeAddOrderResponseWrapper getShipEdgeAddOrder(Set<Id> OppId) {
		
        string endPoint = '/add_orders';
        ShipEdgeMDT__mdt shipEdgeMDT = ShipEdgeMDT__mdt.getInstance('ShipEdge');
        List<Opportunity> lstUpdateOpps = new List<Opportunity>();
        List<B2B_Deal_Item__c> lstUpdatebulkdeals = new List<B2B_Deal_Item__c>();
        List<Integration_Log__c> logs = new List<Integration_Log__c>();
        Map<String,Opportunity> invoiceToOppMap = new Map<String,Opportunity>();
		String studyMaterialRT = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Study_Materials');
        List<Opportunity> oppList = [SELECT Id,B2B_Deal_Item__c,B2B_Deal_Item__r.RecordTypeId, Display_Invoice_Number__c,Customs_Cost__c,Products_SKU__c,Tracking_Number__c,Team_Registration__c,Team_Registration__r.Include_Books__c,
                                     Shipping_E_mail__c,Shipping_Phone_No__c,Resend_Order_To_ShipEdge__c,ShipEdge_Order_Error__c,Ups_Stage__c,Ship_Edge_Order_Id__c,
                                     Shipping_First_Name__c,Shipping_Last_Name__c,Shipping_Company_Name__c,Shipping_Address1__c,Shipping_Address2__c,Shipping_City__c,Shipping_State__c,Shipping_Postal_Code__c,Shipping_Country__c,
                                     Billing_First_Name__c,Billing_Last_Name__c,Billing_Company__c,Billing_Address__c,Billing_Address_Line_2__c,Billing_City__c,Billing_State_Text__c,Billing_Zip_Postal__c,Billing_Country__c,
                                     (Select OpportunityId,UnitPrice,Product_SKU__c,Product2.Customs_Cost__c,Product2.Is_Shippable__c,Quantity,ProductCode from OpportunityLineItems)
                                     FROM Opportunity WHERE id IN: OppId];
        
        system.debug(oppList.size()+'   <<::oppList::>>'+oppList);
        
        if(oppList.size() > 0){                
            List<ShipEdgeAddOrderRequestWrapper.cls_orders> wrapper_clsOrdersList = new List<ShipEdgeAddOrderRequestWrapper.cls_orders>();
            
            ShipEdgeAddOrderRequestWrapper reqWrapper = new ShipEdgeAddOrderRequestWrapper();
            ShipEdgeAddOrderResponseWrapper AddOrderResponseWrapper = new ShipEdgeAddOrderResponseWrapper();
            
            reqWrapper.key = shipEdgeMDT.APIKey__c;
            reqWrapper.warehouse = shipEdgeMDT.WareHouse__c;
            reqWrapper.account_id = Integer.valueOf(shipEdgeMDT.AccountId__c);
            
            for(Opportunity opp : oppList){
                invoiceToOppMap.put(opp.Display_Invoice_Number__c,opp);
                
                ShipEdgeAddOrderRequestWrapper.cls_orders wrapper_clsOrders = new ShipEdgeAddOrderRequestWrapper.cls_orders();
                ShipEdgeAddOrderRequestWrapper.cls_shipping wrapper_clsShipping = new ShipEdgeAddOrderRequestWrapper.cls_shipping();
                ShipEdgeAddOrderRequestWrapper.cls_customer wrapper_clsCustomer = new ShipEdgeAddOrderRequestWrapper.cls_customer();
                ShipEdgeAddOrderRequestWrapper.cls_billing wrapper_clsBilling = new ShipEdgeAddOrderRequestWrapper.cls_billing();
                List<ShipEdgeAddOrderRequestWrapper.cls_items> wrapper_clsItemsList = new List<ShipEdgeAddOrderRequestWrapper.cls_items>();
                
                wrapper_clsOrders.order_number = opp.Display_Invoice_Number__c;
                
                wrapper_clsShipping.method = 'ECON2D';
                wrapper_clsCustomer.address1 = opp.Shipping_Address1__c;
                wrapper_clsCustomer.address2 = opp.Shipping_Address2__c;
                wrapper_clsCustomer.email = opp.Shipping_E_mail__c;
                wrapper_clsCustomer.phone = opp.Shipping_Phone_No__c;
                wrapper_clsCustomer.first_name = opp.Shipping_First_Name__c;
                wrapper_clsCustomer.last_name = opp.Shipping_Last_Name__c;
                wrapper_clsCustomer.company = opp.Shipping_Company_Name__c;
                wrapper_clsCustomer.city = opp.Shipping_City__c;
                wrapper_clsCustomer.state = opp.Shipping_State__c;
                wrapper_clsCustomer.zip = opp.Shipping_Postal_Code__c;
                if(opp.Shipping_Country__c == 'South Korea'){
                	wrapper_clsCustomer.country = 'Korea South';
                }else{
                    wrapper_clsCustomer.country = opp.Shipping_Country__c;
                }
                
                wrapper_clsBilling.address1 = opp.Billing_Address__c;
                wrapper_clsBilling.address2 = opp.Billing_Address_Line_2__c;
                wrapper_clsBilling.first_name = opp.Billing_First_Name__c;
                wrapper_clsBilling.last_name = opp.Billing_Last_Name__c;
                wrapper_clsBilling.company = opp.Billing_Company__c;
                wrapper_clsBilling.city = opp.Billing_City__c;
                wrapper_clsBilling.state = opp.Billing_State_Text__c;
                wrapper_clsBilling.zip = opp.Billing_Zip_Postal__c;
                if(opp.Billing_Country__c == 'South Korea'){
                	wrapper_clsBilling.country = 'Korea South';
                }else{
                    wrapper_clsBilling.country = opp.Billing_Country__c;
                }
                
                Decimal Cus_Cost = 0.0;
                for(OpportunityLineItem oppsku : opp.OpportunityLineItems){
                    if(oppsku.Product2.Is_Shippable__c == true){
                        ShipEdgeAddOrderRequestWrapper.cls_items wrapper_clsItems = new ShipEdgeAddOrderRequestWrapper.cls_items();
                        wrapper_clsItems.sku = oppsku.Product_SKU__c;
                        wrapper_clsItems.quantity = Integer.valueOf(oppsku.Quantity);
                        Cus_Cost =  Cus_Cost + oppsku.quantity * integer.valueof(oppsku.Product2.Customs_Cost__c);
                        wrapper_clsItemsList.add(wrapper_clsItems);
                    }
                    
                    if(oppsku.ProductCode == 'SHIPBULK'){
                        wrapper_clsShipping.shipping_charge = String.valueof(oppsku.UnitPrice);
                    }
                }
                
                wrapper_clsOrders.insurance_amount = String.valueOf(Cus_Cost);
                wrapper_clsOrders.items = wrapper_clsItemsList;
                wrapper_clsOrders.shipping = wrapper_clsShipping;
                wrapper_clsOrders.customer = wrapper_clsCustomer;
                wrapper_clsOrders.billing = wrapper_clsBilling;
                
                wrapper_clsOrdersList.add(wrapper_clsOrders);
                
            }
            reqWrapper.orders = wrapper_clsOrdersList;
            
            system.debug('reqWrapper::>>   '+reqWrapper);
            
            //string reqBody = JSON.serialize(reqWrapper);
            string reqBody = ShipEdgeAddOrderRequestWrapper.parse(reqWrapper);
            
            String JsonResponse = callOutMethod(reqBody,endPoint);
            
            if(jsonResponse != 'Failed'){
                AddOrderResponseWrapper = ShipEdgeAddOrderResponseWrapper.parse(JsonResponse);
                ShipEdgeAddOrderResponseWrapper.cls_orders order = AddOrderResponseWrapper.orders;
                //Update Success Orders
                if(order != null){
                    for(ShipEdgeAddOrderResponseWrapper.cls_allow allowed : order.allow){
                        if(invoiceToOppMap.containsKey(allowed.order_number)){
                            Opportunity opp = invoiceToOppMap.get(allowed.order_number);
                            opp.Ups_Stage__c = 'Sent To GT';
                            opp.Ship_Edge_Order_Id__c = allowed.OrderID;
                            opp.Resend_Order_To_ShipEdge__c = false;
                            opp.ShipEdge_Order_Error__c = '';
                            lstUpdateOpps.add(opp);
                            logs.add(createlogrecord(opp.id,reqBody,JsonResponse,'Success','ShipEdgeAddOrder'));
                            
                            if(opp.B2B_Deal_Item__c != null && opp.B2B_Deal_Item__r.RecordTypeId == studyMaterialRT){
                                B2B_Deal_Item__c deal = new B2B_Deal_Item__c();
                                deal.Id = opp.B2B_Deal_Item__c;
                                deal.Shipping_Status__c = 'Sent to Fulfillment Center';
                                lstUpdatebulkdeals.add(deal);
                            }
                        }
                    }
                    //Update Failed Orders
                    for(ShipEdgeAddOrderResponseWrapper.cls_denied denied : order.denied){
                        if(invoiceToOppMap.containsKey(denied.order_number)){
                            Opportunity opp = invoiceToOppMap.get(denied.order_number);
                            opp.Ups_Stage__c = 'Order Error';
                            opp.ShipEdge_Order_Error__c = denied.CommentAPI;
                            opp.Resend_Order_To_ShipEdge__c = false;
                            lstUpdateOpps.add(opp);
                            logs.add(createlogrecord(opp.id,reqBody,JsonResponse,'Success','ShipEdgeAddOrder'));
                            
                            if(opp.B2B_Deal_Item__c != null && opp.B2B_Deal_Item__r.RecordTypeId == studyMaterialRT){
                                B2B_Deal_Item__c deal = new B2B_Deal_Item__c();
                                deal.Id = opp.B2B_Deal_Item__c;
                                deal.Shipping_Status__c = 'Order Error';
                                lstUpdatebulkdeals.add(deal);
                            }
                        }
                    }
                }
            }else{
                for(Opportunity opp : oppList){
                    opp.Ups_Stage__c = 'Order Error';
                    opp.ShipEdge_Order_Error__c = 'Add Order Call Failed';
                    opp.Resend_Order_To_ShipEdge__c = false;
                    lstUpdateOpps.add(opp);
                    logs.add(createlogrecord(opp.id,reqBody,JsonResponse,'Error','ShipEdgeAddOrder'));
                    
                    if(opp.B2B_Deal_Item__c != null && opp.B2B_Deal_Item__r.RecordTypeId == studyMaterialRT){
                        B2B_Deal_Item__c deal = new B2B_Deal_Item__c();
                        deal.Id = opp.B2B_Deal_Item__c;
                        deal.Shipping_Status__c = 'Order Error';
                        lstUpdatebulkdeals.add(deal);
                    }
                }
            }
            
            if(!lstUpdateOpps.isEmpty())
                update lstUpdateOpps;
            
            if(!logs.isEmpty())
                update lstUpdatebulkdeals;
            
            if(!logs.isEmpty())
                insert logs;
            
            return AddOrderResponseWrapper;
        }
        return null;
    }
    
    
    public static ShipEdgeGetOrderResponseWrapper getShipEdgeGetOrder(String OppId) {
        string endPoint = '/get_order';
        ShipEdgeRequestWrapper reqWrapper = new ShipEdgeRequestWrapper();
        ShipEdgeGetOrderResponseWrapper response = new ShipEdgeGetOrderResponseWrapper();
        Integration_Log__c log = new Integration_Log__c();
        
        Opportunity opp = [SELECT Id,Display_Invoice_Number__c,Ship_Edge_Order_Id__c FROM Opportunity WHERE Id =: OppId];
        
        ShipEdgeMDT__mdt shipEdgeMDT = ShipEdgeMDT__mdt.getInstance('ShipEdge');
        
        reqWrapper.id = opp.Ship_Edge_Order_Id__c;
        reqWrapper.key = shipEdgeMDT.APIKey__c;
        reqWrapper.warehouse = shipEdgeMDT.WareHouse__c;
        reqWrapper.account_id = Integer.valueOf(shipEdgeMDT.AccountId__c);
        reqWrapper.order_number =  opp.Display_Invoice_Number__c;
        
        string reqBody = ShipEdgeRequestWrapper.parse(reqWrapper);
        
        String JsonResponse = callOutMethod(reqBody,endPoint);
        if(JsonResponse != 'Failed'){
            system.debug(JsonResponse);
            JsonResponse = JsonResponse.replace('"date"', '"date_x"');
            response = ShipEdgeGetOrderResponseWrapper.parse(JsonResponse);
            system.debug('obj::>>  '+response);
            log = createlogrecord(opp.id,reqBody,JsonResponse,'Success','ShipEdgeGetOrder');
        }else{
        	log = createlogrecord(opp.id,reqBody,JsonResponse,'Error','ShipEdgeGetOrder');
        }
        
        insert log;
        return response;
    }
    
    public static ShipEdgeQueueableClass.cancelWrapper cancelOrder(String OppId) {
        string endPoint = '/cancel_order';
        system.debug('Check here');
        ShipEdgeRequestWrapper reqWrapper = new ShipEdgeRequestWrapper();
        ShipEdgeResponseWrapper response = new ShipEdgeResponseWrapper();
        ShipEdgeQueueableClass.cancelWrapper classResp = new ShipEdgeQueueableClass.cancelWrapper();
        Integration_Log__c log = new Integration_Log__c();
        
        Opportunity opp = [SELECT Id,Display_Invoice_Number__c,Ship_Edge_Order_Id__c,
                                  Resend_Order_To_ShipEdge__c,ShipEdge_Order_Error__c,Ups_Stage__c 
                           FROM Opportunity WHERE Id =: OppId];
        
        ShipEdgeMDT__mdt shipEdgeMDT = ShipEdgeMDT__mdt.getInstance('ShipEdge');
        
        reqWrapper.order_number = opp.Display_Invoice_Number__c;
        reqWrapper.key = shipEdgeMDT.APIKey__c;
        reqWrapper.warehouse = shipEdgeMDT.WareHouse__c;
        reqWrapper.account_id = Integer.valueOf(shipEdgeMDT.AccountId__c);
        
        string reqBody = ShipEdgeRequestWrapper.parse(reqWrapper);
        
        String JsonResponse = callOutMethod(reqBody,endPoint);
        if(JsonResponse != 'Failed'){
            response = ShipEdgeResponseWrapper.parse(JsonResponse);
            if(response.status == 'successful'){
                opp.Ups_Stage__c = 'Canceled';
                opp.ShipEdge_Order_Error__c = '';
                opp.Resend_Order_To_ShipEdge__c = false;
                log = createlogrecord(opp.id,reqBody,JsonResponse,'Success','ShipEdgeCancelOrder');
            }else{
                opp.ShipEdge_Order_Error__c = 'Cancel Request Failed';
                opp.Resend_Order_To_ShipEdge__c = false;
                log = createlogrecord(opp.id,reqBody,JsonResponse,'Success','ShipEdgeCancelOrder');
            }
            
        }else{
            opp.ShipEdge_Order_Error__c = 'Cancel Request Failed';
            opp.Resend_Order_To_ShipEdge__c = false;
            log = createlogrecord(opp.id,reqBody,JsonResponse,'Error','ShipEdgeCancelOrder');
        }
        
        classResp.opp = opp;
        classResp.log = log;
        
        return classResp;
    }
    
    
    public static string getShipEdgePing() {
        string endPoint = '/ping';
        ShipEdgeRequestWrapper reqWrapper = new ShipEdgeRequestWrapper();
        
        ShipEdgeMDT__mdt shipEdgeMDT = ShipEdgeMDT__mdt.getInstance('ShipEdge');
        
        reqWrapper.key = shipEdgeMDT.APIKey__c;
        reqWrapper.warehouse = shipEdgeMDT.WareHouse__c;
        reqWrapper.account_id = Integer.valueOf(shipEdgeMDT.AccountId__c);
        
        string reqBody = ShipEdgeRequestWrapper.parse(reqWrapper);
        
        String JsonResponse = callOutMethod(reqBody,endPoint);
        system.debug('Check here');
        return jsonResponse;
    }
    
    
    public static String callOutMethod(String reqBody,string endpoint) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        req.setMethod('POST');
        req.setEndpoint('callout:ShipEdgeNC'+endpoint); 
        req.setHeader('Content-Type', 'application/json');
        req.setBody(reqBody);
        system.debug('request::>>  '+req);
        system.debug('request::>>  '+req.getBody());
        
        String JsonResponse;
        if(Test.isRunningTest()){
            JsonResponse = '{\"orders\" : {\"allow\":[{\"order_number\":\"W3368129\",\"OrderID\":\"W3368127\"}],\"denied\":[{\"order_number\":\"W3368130\",\"CommentAPI\":\"563\",\"OrderID\":\"W3368127\"}]}'+'}';
            //JsonResponse = '{\"access\":{\"account_id\":\"ts\",\"access\":\"rwerw\",\"warehouse\":\"yrtyr\",\"total_orders\":45645,\"message\":\"etet\",\"batch_id\": 75656},\"orders\":{\"allow\":[{\"order_number\":\"W3368129\",\"OrderID\":\"W3368127\"}],\"denied\":[{\"order_number\":\"W3368130\",\"CommentAPI\":\"563\",\"OrderID\":\"W3368127\"}]}}';
        }else{
            res = http.send(req);
            JsonResponse = res.getStatusCode() == 200 ? res.getBody() : 'Failed';
            /*
            if(res.getStatusCode() == 200){
                JsonResponse = res.getBody();
            }else{
                JsonResponse = 'Failed';
            }
            */
        }
        
        return JsonResponse;
    }
    
    
    /*public static String totalCustomsCost(String CustomsCost) {
        Double sumValue = 0;
        for(String cc : CustomsCost.split(',')){
            sumValue = sumValue + Double.valueOf(cc.trim());
        }
        return (String.valueOf(sumValue));
    }*/
    
    public static Integration_Log__c createLogRecord(string oppId,String request,string response,string Status,string integrationType){
        Integration_Log__c log = new Integration_Log__c();
        log.Integration_Type__c = integrationType;
        log.Status__c = Status;
        log.Platform_Event_Type__c = 'Integration Stream Event';
        log.Request__c = request;
        log.response__c = response;
        log.Opportunity__c = oppId;
        
        return log;
    }
    
}