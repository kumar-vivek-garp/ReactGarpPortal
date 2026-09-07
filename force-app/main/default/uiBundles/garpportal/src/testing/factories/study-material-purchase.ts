/**
 * Typed fixtures for buying one study material (`GARP_Portal_MaterialPurchase`
 * and `orderCheckout`). Typed against the api types so a contract drift
 * breaks compilation.
 */

import type { OrderCheckoutResult } from "@/api/orders/types"
import type {
	MaterialPurchaseResult,
	MaterialQuote,
	MaterialShipTo,
} from "@/api/study-materials/types"

export function materialShipTo(
	overrides: Partial<MaterialShipTo> = {},
): MaterialShipTo {
	return {
		company: null,
		street: "111 Main Street",
		street2: null,
		city: "Jersey City",
		state: "NJ",
		postalCode: "07302",
		country: "United States",
		phone: null,
		...overrides,
	}
}

/** A shippable printed book, priced with US shipping. */
export function materialQuote(
	overrides: Partial<MaterialQuote> = {},
): MaterialQuote {
	return {
		statusMessage: "Success",
		statusCode: 200,
		productCode: "SCRH",
		title: "2026 SCR Book",
		imageURL: null,
		price: 100,
		shipping: 15,
		total: 115,
		isShippable: true,
		shipTo: materialShipTo(),
		shippableCountries: ["Canada", "United Kingdom", "United States"],
		...overrides,
	}
}

/** The immediate flow's answer — an Opportunity to take to checkout. */
export function materialPurchaseResult(
	overrides: Partial<MaterialPurchaseResult> = {},
): MaterialPurchaseResult {
	return {
		statusMessage: "Success",
		statusCode: 200,
		orderId: "006PUR00000000001",
		orderNumber: "INV-0009",
		stagedId: null,
		registrationRef: null,
		total: 115,
		...overrides,
	}
}

export function orderCheckoutResult(
	overrides: Partial<OrderCheckoutResult & { statusCode: number }> = {},
): OrderCheckoutResult & { statusCode: number; statusMessage: string | null } {
	return {
		statusCode: 200,
		statusMessage: null,
		checkoutUrl: "#hosted-checkout",
		orderNumber: "INV-0009",
		...overrides,
	}
}
