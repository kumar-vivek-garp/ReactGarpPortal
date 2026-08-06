public with sharing class StripeCheckoutController {

   @AuraEnabled
    public static String createCheckoutSession(String productName, Decimal amount, Integer quantity) {
        try {
            GARP_StripeSettings__c stripeSetting = GARP_StripeClass.getStripeSettings();
            if (stripeSetting == NULL || String.isBlank(stripeSetting.Server_Side_API_Key__c)) {
                throw new AuraHandledException('Stripe is not configured.');
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.stripe.com/v1/checkout/sessions');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + stripeSetting.Server_Side_API_Key__c);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

            // amount must be in cents (smallest currency unit)
            Integer amountInCents = (Integer) (amount * 100);

            String body = 'mode=payment'
                + '&ui_mode=embedded'
                + '&line_items[0][price_data][currency]=usd'
                + '&line_items[0][price_data][unit_amount]=' + amountInCents
                + '&line_items[0][price_data][product_data][name]=' + EncodingUtil.urlEncode(productName, 'UTF-8')
                + '&line_items[0][quantity]=' + quantity
                + '&return_url=' + EncodingUtil.urlEncode(
                    URL.getOrgDomainUrl().toExternalForm() + '/checkout-return?session_id={CHECKOUT_SESSION_ID}',
                    'UTF-8'
                  );

            req.setBody(body);
            req.setTimeout(20000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('Stripe response status: ' + res.getStatusCode());
            System.debug('Stripe response body: ' + res.getBody());

            if (res.getStatusCode() != 200) {
                AuraHandledException ex = new AuraHandledException(res.getBody());
                ex.setMessage('Stripe error (' + res.getStatusCode() + '): ' + res.getBody());
                throw ex;
            }

            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            return (String) responseMap.get('client_secret');

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Stripe callout failed: ' + e.getMessage() + '\n' + e.getStackTraceString());
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage('Failed to create Checkout Session: ' + e.getMessage());
            throw ex;
        }
    }
}