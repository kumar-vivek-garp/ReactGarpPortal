/**
 * Finalizes a $0 event registration order off the shopper's critical path.
 *
 * Enqueued by GARP_EventRegFast_Controller.completeFreeOrderAsync right after
 * setRegistration returns, so the Register click does not block ~4s on the
 * Opportunity close-stage trigger cascade (line items, Closed, Affiliate contract,
 * Sage events). Runs in its own transaction after setRegistration has committed —
 * the same timing the synchronous completeFreeOrder relied on — so the Chargent
 * order it needs is already present.
 *
 * Best-effort: a failure here never affects the shopper (they have already been
 * navigated to the confirmation page and are registered). It is logged, not rethrown,
 * so the async job does not surface an uncatchable AuraHandledException.
 */
public without sharing class GARP_EventRegFreeOrderQueueable implements Queueable {

    private final String orderId;
    private final String contactId;

    public GARP_EventRegFreeOrderQueueable(String orderId, String contactId) {
        this.orderId = orderId;
        this.contactId = contactId;
    }

    public void execute(QueueableContext context) {
        try {
            GARP_EventRegFast_Controller.finalizeFreeOrder(orderId, contactId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'GARP_EventRegFreeOrderQueueable finalize failed for order ' + orderId + ': '
                + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}