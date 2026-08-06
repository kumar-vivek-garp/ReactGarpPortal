/**
 * Visualforce controller for the on-page Stripe Embedded Checkout screen used by
 * the new event-registration flow (garpEventStripeCheckout.page).
 *
 * WHY VISUALFORCE: Stripe.js / Embedded Checkout cannot run inside a native LWC
 * under Lightning Web Security (LWS blocks Stripe's required window listeners, and
 * Stripe refuses to load from anywhere but js.stripe.com). A Visualforce page runs
 * OUTSIDE LWS, so Stripe works there — the LWC hosts this page in an iframe.
 *
 * It reuses the standalone GARP_EventReg_* stack (no legacy GARP_StripeClass): it
 * asks GARP_EventReg_Gateway.getEmbeddedCheckoutSession for a Checkout Session
 * client_secret (ui_mode=embedded) + publishable key + the order summary, so the
 * page can render order details alongside the embedded payment. Payment is
 * finalized asynchronously by the existing Stripe webhook (unchanged).
 */
public without sharing class garpEventStripeCheckoutCtrl {

    public String clientSecret { get; private set; }
    public String publishableKey { get; private set; }
    public String orderNumber { get; private set; }
    public Boolean isError { get; private set; }
    public String errorMsg { get; private set; }
    public Decimal total { get; private set; }
    public String currencyIso { get; private set; }
    public List<LineVM> lines { get; private set; }

    public class LineVM {
        public String name { get; set; }
        public Decimal amount { get; set; }
    }

    public PageReference init() {
        isError = false;
        lines = new List<LineVM>();
        currencyIso = 'USD';

        String oid = ApexPages.currentPage().getParameters().get('oid');
        String returnUrl = ApexPages.currentPage().getParameters().get('returnUrl');
        if (String.isBlank(oid)) {
            isError = true; errorMsg = 'No order specified.'; return null;
        }

        try {
            String reqJson = JSON.serialize(new Map<String, Object>{ 'orderId' => oid, 'returnUrl' => returnUrl });
            String resJson = new GARP_EventReg_Gateway().getEmbeddedCheckoutSession(reqJson);
            Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(resJson);

            orderNumber = (String) res.get('orderNumber');
            if (res.get('currencyIso') != null) { currencyIso = (String) res.get('currencyIso'); }
            if (res.get('total') != null) { total = (Decimal) res.get('total'); }
            Object items = res.get('items');
            if (items instanceof List<Object>) {
                for (Object it : (List<Object>) items) {
                    Map<String, Object> m = (Map<String, Object>) it;
                    LineVM vm = new LineVM();
                    vm.name = (String) m.get('name');
                    if (m.get('amount') != null) { vm.amount = (Decimal) m.get('amount'); }
                    lines.add(vm);
                }
            }

            if (res.get('isError') == true) {
                isError = true; errorMsg = (String) res.get('msg');
                return null;
            }
            clientSecret = (String) res.get('clientSecret');
            publishableKey = (String) res.get('publishableKey');
            if (String.isBlank(clientSecret)) { isError = true; errorMsg = 'Unable to initialize payment.'; }
        } catch (Exception e) {
            isError = true; errorMsg = e.getMessage();
        }
        return null;
    }
}