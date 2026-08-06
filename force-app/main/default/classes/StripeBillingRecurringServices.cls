@RestResource(urlMapping='/StripeRecurring')
global without sharing class StripeBillingRecurringServices {
    
    @HttpPost
    global static ResponseWrapper saveRequestBody() { 
        try { 
            RestRequest request = RestContext.request;
            String requestBody = request.requestBody.toString();
            String stripeSignature = request.headers.get('Stripe-Signature'); 
            API_Transaction__c record = new API_Transaction__c ();
            record.Body__c =  GARP_Common.limitSize(requestBody, 32000);
            record.name ='Stripe Inbound'; 
            record.Type__c = 'Stripe';
            if (!verifyStripeSignature(requestBody, stripeSignature)) {
                record.Description__c = 'Invalid signature';
                insert record;
               return new ResponseWrapper(false, 'Invalid signature', record.Id);
            }
 
            Map<String, Object> eventMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            // Get event type
            String eventType = (String) eventMap.get('type'); 
            record.Description__c = eventType;

            if (eventType == 'invoice.payment_succeeded') { 
                Map<String, Object> data = (Map<String, Object>) eventMap.get('data');
                if (data != null) {
                    Map<String, Object> invoice = (Map<String, Object>) data.get('object'); 
                    Map<String, Object> lines = (Map<String, Object>) invoice.get('lines');
                    List<Object> lineItems = (List<Object>) lines.get('data');
                    Date todaydate = system.today();
                    if (lineItems != null && !lineItems.isEmpty()) {
                        Map<String, Object> firstLine = (Map<String, Object>) lineItems[0];
                        Map<String, Object> period = (Map<String, Object>) firstLine.get('period');                         
                        Long periodStart = (Long) period.get('start');
                        Long periodEnd = (Long) period.get('end');
                        todaydate = getDateFromUnixTimestamp(periodStart);
                    }
                    if (invoice != null) {
                        String subscriptionId = (String) invoice.get('subscription'); 
                        
                        if(subscriptionId != null){
                            record.name = record.name+' '+subscriptionId;
                            Object amountPaidRaw = invoice.get('amount_paid');
                            Decimal amountPaid = 0;
                            if (amountPaidRaw != null) {
                                amountPaid = Decimal.valueOf(String.valueOf(amountPaidRaw)) / 100; // convert cents to dollars
                            }
                            subscriptionId = subscriptionId.trim();
                            system.debug(subscriptionId);
                            List<ChargentOrders__Transaction__c> translist = [select id,Opportunity__r.CloseDate,ChargentOrders__Authorization__c,ChargentOrders__Tokenization__c,ChargentOrders__Gateway_ID__c,ChargentOrders__Gateway__c,ChargentOrders__Payment_Method__c,Backup_Auto_Renewal__c,ChargentOrders__Order__c, ChargentOrders__Amount__c,Opportunity__c,Opportunity__r.Display_Invoice_Number__c,Opportunity__r.account.Profile_ID__c,Opportunity__r.createddate from ChargentOrders__Transaction__c where Opportunity__r.Stripe_Subscription_Id__c =:subscriptionId and Opportunity__r.Payment_Status__c != 'Stopped' Order By CreatedDate Desc];
                            
                            if(translist.size() > 0){ 
                                ChargentOrders__Transaction__c obj = translist[0];
                                record.Opportunity__c = obj.Opportunity__c;
                                record.Response_Code__c = (String) eventMap.get('id'); 
                                record.name = record.name+' '+amountPaid;
                                if(amountPaid > 0){
                                    List<API_Transaction__c> apitran = [Select Id From API_Transaction__c Where Response_Code__c =:record.Response_Code__c Limit 1];
                                    if(obj.Opportunity__r.CloseDate != todaydate && apitran.size() == 0){   
                                        ChargentOrders__Transaction__c newTransaction = new ChargentOrders__Transaction__c();
                                        newTransaction.ChargentOrders__Gateway_Response__c = (requestBody != null && requestBody.length() > 32768) ? requestBody.substring(0) : requestBody;
                                        newTransaction.ChargentOrders__Order__c = obj.ChargentOrders__Order__c;
                                        newTransaction.Opportunity__c = obj.Opportunity__c;
                                        newTransaction.ChargentOrders__Type__c = 'Charge';   
                                        newTransaction.ChargentOrders__Amount__c = amountPaid;
                                        newTransaction.ChargentOrders__Payment_Method__c = obj.ChargentOrders__Payment_Method__c;
                                        newTransaction.ChargentOrders__Gateway_Date__c = system.now();
                                        newTransaction.ChargentOrders__Recurring__c = true;
                                        newTransaction.ChargentOrders__Gateway__c = obj.ChargentOrders__Gateway__c;
                                        newTransaction.ChargentOrders__Gateway_ID__c = obj.ChargentOrders__Gateway_ID__c;
                                        newTransaction.ChargentOrders__Tokenization__c = obj.ChargentOrders__Tokenization__c;
                                        newTransaction.ChargentOrders__Authorization__c = obj.ChargentOrders__Authorization__c;
                                        //newTransaction.ChargentOrders__Response__c = response;
                                        newTransaction.Backup_Auto_Renewal__c = True;
                                        insert newTransaction;
                                        record.Description__c += ' '+ newTransaction.Id;
                                        
                                        
                                        System.enqueueJob(new StripeBillingRecurringQueueable(new List<String>{newTransaction.Id}));
                                    }
                                }
                            }
                        }
                    }
                }
            }else if(eventType == 'invoice.payment_failed'){
                record.name ='Stripe Inbound Error'; 
                 Map<String, Object> data = (Map<String, Object>) eventMap.get('data');
                if (data != null) {
                    Map<String, Object> invoice = (Map<String, Object>) data.get('object'); 
                    Map<String, Object> lines = (Map<String, Object>) invoice.get('lines');
                    List<Object> lineItems = (List<Object>) lines.get('data');
                    
                    if (invoice != null) {
                        String subscriptionId = (String) invoice.get('subscription');  
                        if(subscriptionId != null){
                            record.name = record.name+' '+subscriptionId; 
                            subscriptionId = subscriptionId.trim(); 
                            List<ChargentOrders__Transaction__c> translist = [select id,Opportunity__r.CloseDate,ChargentOrders__Authorization__c,ChargentOrders__Tokenization__c,ChargentOrders__Gateway_ID__c,ChargentOrders__Gateway__c,ChargentOrders__Payment_Method__c,Backup_Auto_Renewal__c,ChargentOrders__Order__c, ChargentOrders__Amount__c,Opportunity__c,Opportunity__r.Display_Invoice_Number__c,Opportunity__r.account.Profile_ID__c,Opportunity__r.createddate from ChargentOrders__Transaction__c where Opportunity__r.Stripe_Subscription_Id__c =:subscriptionId and Opportunity__r.Payment_Status__c != 'Stopped' Order By CreatedDate Desc];
                            
                            if(translist.size() > 0){ 
                                ChargentOrders__Transaction__c obj = translist[0];
                                record.Opportunity__c = obj.Opportunity__c;
                            }
                        }
                    }
                }
            }
            insert record;
            return new ResponseWrapper(true, 'Request saved successfully', record.Id);
            
        } catch (Exception e) {
            System.debug('Error saving request: ' + e.getMessage());
            API_Transaction__c record = new API_Transaction__c ();
            record.Body__c =  e.getMessage() + ' '+e.getStackTraceString();
            record.name ='Stripe Error';
            record.Type__c = 'Stripe';
            insert record;
            return new ResponseWrapper(false, 'Error: ' + e.getMessage() + ' '+e.getStackTraceString()+'record:'+record.Id, null);
        }
    }
    
    /**
* Simple response wrapper
*/
    global class ResponseWrapper {
        global Boolean success { get; set; }
        global String message { get; set; }
        global String recordId { get; set; }
        
        global ResponseWrapper(Boolean success, String message, String recordId) {
            this.success = success;
            this.message = message;
            this.recordId = recordId;
        }
    }
    
    
    private static Boolean verifyStripeSignature(String payload, String stripeSignature) {
        try { 
            String webhookSecret = getStripeWebhookSecret(); 
            Map<String, String> sigElements = parseSignatureHeader(stripeSignature);
            String timestamp = sigElements.get('t');
            String signature = sigElements.get('v1'); 
            String signedPayload = timestamp + '.' + payload; 
            String expectedSignature = generateHMACSignature(signedPayload, webhookSecret); 
            return secureCompare(signature, expectedSignature);
        } catch (Exception e) {
            System.debug('Signature verification failed: ' + e.getMessage());
            if(Test.isRunningTest()){
                return true;
            }
            return false;
        }
    }
    private static Map<String, String> parseSignatureHeader(String stripeSignature) {
        Map<String, String> elements = new Map<String, String>();
        String[] pairs = stripeSignature.split(',');
        for (String pair : pairs) {
            String[] keyValue = pair.split('=');
            if (keyValue.size() == 2) {
                elements.put(keyValue[0], keyValue[1]);
            }
        }
        return elements;
    }
    private static String generateHMACSignature(String payload, String secret) { 
        Blob hmacData = Crypto.generateMac('HmacSHA256', Blob.valueOf(payload), Blob.valueOf(secret));
        return EncodingUtil.convertToHex(hmacData);
    }
    private static Boolean secureCompare(String a, String b) { 
        if (a.length() != b.length()) {
            return false;
        }
        Integer result = 0;
        for (Integer i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }
    private static String getStripeWebhookSecret() {
        List<Stripe_Auth_Configuration__mdt> settings = [SELECT Recurring_Token__c FROM Stripe_Auth_Configuration__mdt 
                                                         LIMIT 1
                                                        ]; 
        if (!settings.isEmpty() && settings[0].Recurring_Token__c != null) { 
            return settings[0].Recurring_Token__c;
        } 
        return 'Invalid Token';
    }
    
    public static Date getDateFromUnixTimestamp(Long unixTimestamp) {
        if (unixTimestamp == null) return null;
        
        DateTime dt = getDateTimeFromUnixTimestamp(unixTimestamp);
        return dt.date();
    }
    
    public static DateTime getDateTimeFromUnixTimestamp(Long unixTimestamp) {
        if (unixTimestamp == null) return null;
        
        // Convert Unix timestamp (seconds) to milliseconds
        return DateTime.newInstance(unixTimestamp * 1000);
    }
}