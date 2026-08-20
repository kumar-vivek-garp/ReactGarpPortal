/**
 * In-app order detail under My Account — mirrors list at
 * `/my-account?tab=order-history`. Param accepts Opportunity Id or invoice
 * number (Apex matches both). Legacy `/order-details/:id` redirects here.
 */

export function orderDetailsPath(
	orderIdOrInvoice: string | null | undefined,
): string | null {
	const key = orderIdOrInvoice?.trim()
	if (!key) return null
	return `/my-account/orders/${encodeURIComponent(key)}`
}
