public class StripeInvoicePreview {
    public static Boolean skipStripeTaxTrigger = false;
    public class stRequest {
        public String customerId;
        public String priceId;
        public Integer quantity;
        public String oppId;
    }
    
    public class stResult {
        public Decimal subtotal;
        public Decimal total;
        public Decimal amountDue;
        public String currencyval;
        
        public Decimal texPersent;
        public Decimal taxRate;
        public Decimal taxAmount;
        public String taxRateId;
        public String errorMesage;
        public String customeraddress;
        public String productCode;
        //public String rawResponse;
    }
    
    
    public class StripeConfig {
        public String apikey;
        public String endpoint;
        // JSON array of { "code": <countryCode>, "name": <countryName>, "prcode": <productCode> }
        public String productCodeJson;
    }

    public static StripeConfig getConfig() {
        StripeConfig cfg = new StripeConfig();
        List<Stripe_Auth_Configuration__mdt> settings = [
            SELECT Api_Key__c,InvoicePreview__c,Stripe_Product_Code__c
            FROM Stripe_Auth_Configuration__mdt
            LIMIT 1
        ];
        if (!settings.isEmpty() && settings[0].Api_Key__c != null) {
            cfg.apikey = settings[0].Api_Key__c;
            cfg.endpoint = settings[0].InvoicePreview__c;
            cfg.productCodeJson = settings[0].Stripe_Product_Code__c;
        }
        return cfg;
    }

    /**
     * Resolve a product code by matching the customer's country against the configured
     * country -> product-code mapping JSON. Returns null when there is no match or the
     * mapping is missing / malformed.
     */
    public static String resolveProductCode(String mappingJson, String country) {
        if (String.isBlank(mappingJson) || String.isBlank(country)) {
            return null;
        }
        try {
            List<Object> entries = (List<Object>) JSON.deserializeUntyped(mappingJson);
            for (Object o : entries) {
                Map<String, Object> entry = (Map<String, Object>) o;
                if (country.equalsIgnoreCase(String.valueOf(entry.get('code')))) {
                    Object pr = entry.get('prcode');
                    return pr == null ? null : String.valueOf(pr);
                }
            }
        } catch (Exception ex) {
            // Malformed mapping JSON - leave the product code unresolved.
        }
        return null;
    }

    public static stResult previewSubTax(stRequest st) {
        return previewSubTax(st, getConfig());
    }

    public static stResult previewSubTax(stRequest st, StripeConfig cfg) {
        stResult result = new stResult();
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();

            req.setEndpoint(cfg.endpoint);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + cfg.apikey);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

            String body =
                'customer=' + EncodingUtil.urlEncode(st.customerId, 'UTF-8') +
                '&subscription_details[items][0][price]=' + EncodingUtil.urlEncode(st.priceId, 'UTF-8') +
                '&subscription_details[items][0][quantity]=' + EncodingUtil.urlEncode(String.valueOf(st.quantity), 'UTF-8') +
                '&automatic_tax[enabled]=true';

            req.setBody(body);

            HttpResponse res = http.send(req);

            if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
                result.errorMesage = 'Stripe error: ' + res.getStatusCode() + ' - ' + res.getBody();
            }

            Map<String, Object> jsonRes =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

 
            if(jsonRes.containsKey('amount_due')){
                Decimal ad = Decimal.valueOf(String.valueOf(jsonRes.get('amount_due')));
                result.amountDue = (ad / 100).setScale(2);
            }


            result.taxAmount = 0;
            result.taxRate = 0;
            result.taxRateId = null;

            // customer_address is an object, e.g. {city, country, line1, line2, postal_code, state}.
            Object custAddrObj = jsonRes.get('customer_address');
            result.customeraddress = String.valueOf(custAddrObj);
            String custCountry;
            if (custAddrObj instanceof Map<String, Object>) {
                custCountry = String.valueOf(((Map<String, Object>) custAddrObj).get('country'));
            }
            // Map the customer's country to a configured product code, when a mapping is supplied.
            result.productCode = resolveProductCode(cfg.productCodeJson, custCountry);

            if (jsonRes.containsKey('total_tax_amounts') && jsonRes.get('total_tax_amounts') != null) {
                List<Object> taxes = (List<Object>) jsonRes.get('total_tax_amounts');

                for (Object t : taxes) {
                    Map<String, Object> tax = (Map<String, Object>) t;

                    // Tax amount
                    if (tax.containsKey('amount') && tax.get('amount') != null) {
                        // result.taxAmount = Integer.valueOf(String.valueOf(tax.get('amount')));
                        Decimal amount = Decimal.valueOf(String.valueOf(tax.get('amount')));
                        result.taxRate = (amount / 100).setScale(2);
                        Decimal ta = Decimal.valueOf(String.valueOf(tax.get('taxable_amount')));
                        result.taxAmount = (ta / 100).setScale(2);
                        result.texPersent = null;
                    }

                    // Manual tax rate ID
                    if (tax.containsKey('tax_rate') && tax.get('tax_rate') != null) {
                        result.taxRateId = String.valueOf(tax.get('tax_rate'));
                    }

                }
            }
            //result.rawResponse = res.getBody();
        }catch(Exception ex){
            result.errorMesage = 'Stripe Error: '+ex.getMessage();
        }

        return result;
    }
}