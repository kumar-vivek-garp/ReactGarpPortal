/**
 * The pure rules of buying one study material, shared by the submit hook and
 * the form so the two cannot disagree about what is complete, which id pays,
 * or where the provider sends the browser back.
 */

import type {
	MaterialPurchaseResult,
	MaterialQuote,
	MaterialShipTo,
} from "@/api/study-materials/types"
import { resolveSettlementId } from "@/lib/registration-checkout"

/**
 * Whichever id `materialPurchase` handed back — the order under the immediate
 * flow, the staged row under the deferred one. The same rule the exam and
 * event legs use, so there is one of it.
 */
export function resolvePayableId(
	result: Pick<MaterialPurchaseResult, "orderId" | "stagedId">,
): string | null {
	return resolveSettlementId(result)
}

/**
 * Apex `isPostable`: street, city and country non-blank. State and postal
 * code are never demanded — asking for a province a country does not use
 * would block a legitimate address.
 */
export function isShippingAddressComplete(
	address: Pick<MaterialShipTo, "street" | "city" | "country"> | null | undefined,
): boolean {
	return Boolean(
		address?.street?.trim() && address?.city?.trim() && address?.country?.trim(),
	)
}

/**
 * The checkout return addresses.
 *
 * Success LEAVES this route for the listing, so it is built from the org base
 * path rather than the current pathname. Cancel comes back here, and
 * `location.pathname` already carries the base path. One flag each, nothing
 * else: the listing's notice needs no order number, and the order itself is
 * in Order History.
 */
export function buildMaterialCheckoutUrls(
	location: { origin: string; pathname: string },
	basePath: string,
): { successUrl: string; cancelUrl: string } {
	const base = basePath.replace(/\/+$/, "")
	const success = new URLSearchParams({ purchased: "1" })
	const cancel = new URLSearchParams({ checkout_cancelled: "1" })
	return {
		successUrl: `${location.origin}${base}/study-materials?${success.toString()}`,
		cancelUrl: `${location.origin}${location.pathname}?${cancel.toString()}`,
	}
}

export type QuoteLine = {
	key: "item" | "shipping" | "total"
	label: string
	/** Null means the figure is not known yet — shipping before a country is chosen. */
	amount: number | null
	emphasis?: boolean
}

/** Item; shipping only for a printed book; total. Tax is the provider's, at checkout. */
export function materialQuoteLines(
	quote: Pick<MaterialQuote, "price" | "shipping" | "total" | "isShippable">,
): QuoteLine[] {
	const lines: QuoteLine[] = [{ key: "item", label: "Item", amount: quote.price }]
	if (quote.isShippable) {
		lines.push({ key: "shipping", label: "Shipping", amount: quote.shipping })
	}
	lines.push({ key: "total", label: "Total", amount: quote.total, emphasis: true })
	return lines
}

/**
 * Shipping is charged per country, so the quoted figure holds only while the
 * address stays in the country it was priced for. True once the member has
 * moved it somewhere else.
 */
export function shippingCountryDiffers(
	recordCountry: string | null | undefined,
	chosen: string | null | undefined,
): boolean {
	const from = recordCountry?.trim()
	const to = chosen?.trim()
	if (!from || !to) return false
	return from.toLowerCase() !== to.toLowerCase()
}
